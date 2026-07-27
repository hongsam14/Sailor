#!/usr/bin/env bash
# Property-based harness (PBT-01/04/08). Seeded + reproducible; the seed is logged.
#   ./tests/prop/run.sh [SEED] [ITERATIONS]
# Properties:
#   P1 idempotency        — a second update with the same source is a no-op
#   P2 manifest round-trip — parse(render(m)) == m
#   P3 learner-data        — Knowledge/*.md and dialogue/*.md never change across any flow
#   P4 classify oracle     — classification matches the FileState truth table
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/payload.sh"; . "$ROOT/installer/lib/checksum.sh"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/manifest.sh"; . "$ROOT/installer/lib/classify.sh"

SEED="${1:-12345}"; ITER="${2:-25}"; RANDOM="$SEED"
echo "[prop] SEED=$SEED ITER=$ITER  (rerun: ./tests/prop/run.sh $SEED $ITER)"
INSTALL="bash $ROOT/installer/install.sh"
fail=0
rnd() { echo $((RANDOM % $1)); }
rstr() { local n=$((RANDOM%8+3)) s="" i; for ((i=0;i<n;i++)); do s+="$(printf '%x' $((RANDOM%16)))"; done; echo "$s"; }
hex64() { local s="" i; for ((i=0;i<64;i++)); do s+="$(printf '%x' $((RANDOM%16)))"; done; echo "$s"; }   # realistic 64-hex sha

# ---- P2: manifest round-trip ----
p2() {
  local i j n rel sha mf tmp; tmp="$(mktemp -d)"; mf="$tmp/sailor.manifest"
  for ((i=0;i<ITER;i++)); do
    : > "$mf"; printf '# sailor-version: 1.2.3\n# installed-at: 2026-01-01\n' > "$mf"
    n=$((RANDOM%5+1)); local rels=() shas=()
    for ((j=0;j<n;j++)); do rel="dir/f$j.md"; sha="$(hex64)"; rels+=("$rel"); shas+=("$sha"); printf '%s  %s\n' "$sha" "$rel" >> "$mf"; done
    for ((j=0;j<n;j++)); do
      got="$(sailor_manifest_sha "$mf" "${rels[$j]}" || true)"
      if [ "$got" != "${shas[$j]}" ]; then echo "  P2 FAIL rel=${rels[$j]} want=${shas[$j]} got=$got"; fail=1; fi
    done
  done
  rm -rf "$tmp"; echo "  P2 manifest round-trip: done ($ITER)"
}

# ---- P4: classify oracle ----
p4() {
  local tmp src tgt; tmp="$(mktemp -d)"; src="$tmp/src"; tgt="$tmp/tgt"; mkdir -p "$src" "$tgt"
  printf 'INCOMING\n' > "$src/AGENTS.md"; printf '1.0.0\n' > "$src/VERSION"
  # ensure only these two are present in src so classify iterates predictably
  local base_mf="$tmp/base"; : > "$base_mf"
  # case NEW: target missing AGENTS.md
  sailor_classify "$src" "$tgt" /dev/null
  in_list AGENTS.md "${SAILOR_ADD[@]:-}" || { echo "  P4 FAIL NEW"; fail=1; }
  # case UNCHANGED vs baseline: on-disk == baseline != incoming → UPDATE
  printf 'OLD\n' > "$tgt/AGENTS.md"; printf 'VOLD\n' > "$tgt/VERSION"
  printf '%s  AGENTS.md\n' "$(sailor_sha256 "$tgt/AGENTS.md")" > "$base_mf"
  sailor_classify "$src" "$tgt" "$base_mf"
  in_list AGENTS.md "${SAILOR_UPDATE[@]:-}" || { echo "  P4 FAIL UPDATE(unchanged-baseline)"; fail=1; }
  # case LOCAL_MOD: on-disk != baseline and != incoming → CONFLICT
  printf 'LOCAL\n' > "$tgt/AGENTS.md"
  sailor_classify "$src" "$tgt" "$base_mf"
  in_list AGENTS.md "${SAILOR_CONFLICT[@]:-}" || { echo "  P4 FAIL CONFLICT"; fail=1; }
  # case NOOP: on-disk == incoming
  cp "$src/AGENTS.md" "$tgt/AGENTS.md"
  sailor_classify "$src" "$tgt" "$base_mf"
  in_list AGENTS.md "${SAILOR_NOOP[@]:-}" || { echo "  P4 FAIL NOOP"; fail=1; }
  rm -rf "$tmp"; echo "  P4 classify oracle: done"
}
in_list() { local x="$1"; shift; local e; for e in "$@"; do [ "$e" = "$x" ] && return 0; done; return 1; }

# ---- P1 idempotency + P3 learner-data ----
p1p3() {
  local i tmp tgt b1 b2
  for ((i=0;i<ITER;i++)); do
    tgt="$(mktemp -d)"
    # random pre-existing noise (some contract files pre-seeded with random content)
    [ "$(rnd 2)" = "0" ] && printf 'random-%s\n' "$(rstr)" > "$tgt/AGENTS.md"
    $INSTALL install "$tgt" --source "$ROOT" >/dev/null 2>&1 || { $INSTALL install "$tgt" --source "$ROOT" --force >/dev/null 2>&1; }
    # add random learner data
    mkdir -p "$tgt/Knowledge" "$tgt/dialogue" "$tgt/assessments"
    printf 'k-%s\n' "$(rstr)" > "$tgt/Knowledge/note-$i.md"
    printf 'd-%s\n' "$(rstr)" > "$tgt/dialogue/topic-$i.md"
    printf 'a-%s\n' "$(rstr)" > "$tgt/assessments/exam-$i.md"
    b1="$(sailor_sha256 "$tgt/Knowledge/note-$i.md")"; b2="$(sailor_sha256 "$tgt/dialogue/topic-$i.md")"
    b3="$(sailor_sha256 "$tgt/assessments/exam-$i.md")"
    # P1: second update is a no-op
    $INSTALL update "$tgt" --source "$ROOT" --force >/dev/null 2>&1
    out2="$($INSTALL update "$tgt" --source "$ROOT" 2>&1)"
    echo "$out2" | grep -q "add=0 update=0 conflict=0" || { echo "  P1 FAIL iter=$i: $out2"; fail=1; }
    # P3: learner data unchanged
    [ "$(sailor_sha256 "$tgt/Knowledge/note-$i.md")" = "$b1" ] || { echo "  P3 FAIL Knowledge iter=$i"; fail=1; }
    [ "$(sailor_sha256 "$tgt/dialogue/topic-$i.md")" = "$b2" ] || { echo "  P3 FAIL dialogue iter=$i"; fail=1; }
    [ "$(sailor_sha256 "$tgt/assessments/exam-$i.md")" = "$b3" ] || { echo "  P3 FAIL assessments iter=$i"; fail=1; }
    rm -rf "$tgt"
  done
  echo "  P1 idempotency + P3 learner-data: done ($ITER)"
}

p2; p4; p1p3
if [ "$fail" -eq 0 ]; then echo "[prop] ALL PASS (seed=$SEED)"; else echo "[prop] FAILURES (seed=$SEED)"; fi
exit "$fail"
