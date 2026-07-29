#!/usr/bin/env bash
# Unit regression tests for the code-review fixes (runnable without bats).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/payload.sh"; . "$ROOT/installer/lib/checksum.sh"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/manifest.sh"; . "$ROOT/installer/lib/classify.sh"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/apply.sh"; . "$ROOT/installer/lib/fetch.sh"

fail=0
ok(){ echo "  ok: $1"; }
no(){ echo "  FAIL: $1"; fail=1; }
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# U1 — manifest lookup handles a path containing spaces (finding #10)
sha="$(printf 'abc' | { sha256sum 2>/dev/null || shasum -a 256; } | awk '{print $1}')"
printf '# h\n%s  Skill/my file.md\n' "$sha" > "$tmp/m"
got="$(sailor_manifest_sha "$tmp/m" "Skill/my file.md" || true)"
[ "$got" = "$sha" ] && ok "U1 manifest sha with spaces" || no "U1 manifest sha with spaces (got='$got')"

# U2 — classify is fail-closed when the checksum tool fails (finding #5)
(
  sailor_sha256(){ return 1; }             # stub: no working sha tool
  s="$tmp/s"; t="$tmp/t"; mkdir -p "$s" "$t"
  printf 'v\n' > "$s/VERSION"; printf 'A\n' > "$s/AGENTS.md"; printf 'B\n' > "$t/AGENTS.md"
  sailor_classify "$s" "$t" /dev/null
  [ "$?" -eq 3 ]
) && ok "U2 classify fail-closed on sha failure" || no "U2 classify fail-closed on sha failure"

# U3 — verify_payload is fail-closed when a manifest entry is missing (finding #2)
v="$tmp/v"; mkdir -p "$v"
for f in "${SAILOR_PAYLOAD_FILES[@]}"; do mkdir -p "$v/$(dirname "$f")"; printf 'x-%s\n' "$f" > "$v/$f"; done
{ printf '# h\n'; for f in "${SAILOR_PAYLOAD_FILES[@]}"; do [ "$f" = "AGENTS.md" ] && continue; printf '%s  %s\n' "$(sailor_sha256 "$v/$f")" "$f"; done; } > "$v/payload.manifest"
sailor_verify_payload "$v"; [ "$?" -eq 3 ] && ok "U3 verify fail-closed on missing entry" || no "U3 verify fail-closed on missing entry"

# U4 — learner-data protection covers assessments/ (but not its template)
sailor_is_learner_data "assessments/exam.md" && ok "U4 assessments/*.md protected" || no "U4 assessments/*.md protected"
sailor_is_learner_data "assessments/_TEMPLATE.md" && no "U4b assessments/_TEMPLATE installable" || ok "U4b assessments/_TEMPLATE installable"

# U6 — learner-data protection covers reading/ (but not its template)  [reading-companion FR-20, P4]
sailor_is_learner_data "reading/my-book.md" && ok "U6 reading/*.md protected" || no "U6 reading/*.md protected"
sailor_is_learner_data "reading/_TEMPLATE.md" && no "U6b reading/_TEMPLATE installable" || ok "U6b reading/_TEMPLATE installable"

# U5 — apply rolls back cleanly and leaves no nested .sailortmp (findings #7/#8)
s="$tmp/as"; t="$tmp/at"; mkdir -p "$s/Skill" "$t/Skill"
printf 'ok\n' > "$s/Skill/ok.md"          # exists; "Skill/missing.md" does not → cp fails mid-apply
sailor_apply "$s" "$t" "Skill/ok.md" "Skill/missing.md"; rc=$?
[ "$rc" -eq 1 ] && ok "U5 apply rc=1 (rolled back)" || no "U5 apply rc=$rc"
[ -z "$(find "$t" -name '*.sailortmp' 2>/dev/null)" ] && ok "U5b no leftover .sailortmp (recursive cleanup)" || no "U5b leftover .sailortmp"
[ ! -e "$t/Skill/ok.md" ] && ok "U5c rolled back the added file" || no "U5c added file survived rollback"

[ "$fail" -eq 0 ] && echo "[unit] ALL PASS" || echo "[unit] FAILURES"
exit "$fail"
