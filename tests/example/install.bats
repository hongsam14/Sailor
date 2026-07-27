#!/usr/bin/env bats
# Example-based tests (PBT-10). Pins the key install scenarios E1–E7.

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  TARGET="$(mktemp -d "${BATS_TMPDIR:-/tmp}/sailor-t.XXXXXX")"
  INSTALL="bash $ROOT/installer/install.sh"
}
teardown() { rm -rf "$TARGET"; }

@test "E1 fresh install writes payload + manifest + VERSION" {
  run $INSTALL install "$TARGET" --source "$ROOT"
  [ "$status" -eq 0 ]
  [ -f "$TARGET/AGENTS.md" ]
  [ -f "$TARGET/Skill/file-based-socratic-dialogue.md" ]
  [ -f "$TARGET/dialogue/_TEMPLATE.md" ]
  [ -f "$TARGET/sailor.manifest" ]
  [ -f "$TARGET/VERSION" ]
}

@test "E2 no-op update makes no changes" {
  $INSTALL install "$TARGET" --source "$ROOT"
  run $INSTALL update "$TARGET" --source "$ROOT"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "noop=9"
}

@test "E3 locally-modified contract file → exit 2, no writes" {
  $INSTALL install "$TARGET" --source "$ROOT"
  printf '\n# local\n' >> "$TARGET/AGENTS.md"
  before="$(sha_of "$TARGET/AGENTS.md")"
  run $INSTALL update "$TARGET" --source "$ROOT"
  [ "$status" -eq 2 ]
  [ "$(sha_of "$TARGET/AGENTS.md")" = "$before" ]
}

@test "E4 --force overwrites conflict, preserves learner data" {
  $INSTALL install "$TARGET" --source "$ROOT"
  printf '\n# local\n' >> "$TARGET/AGENTS.md"
  printf 'note\n' > "$TARGET/Knowledge/mine.md"
  run $INSTALL update "$TARGET" --source "$ROOT" --force
  [ "$status" -eq 0 ]
  ! grep -q "# local" "$TARGET/AGENTS.md"
  [ "$(cat "$TARGET/Knowledge/mine.md")" = "note" ]
}

@test "E5 Codyssey-style adoption via install --force" {
  # pre-existing contract files without a manifest
  cp "$ROOT/AGENTS.md" "$TARGET/AGENTS.md"
  printf '# older\n' >> "$TARGET/AGENTS.md"
  run $INSTALL install "$TARGET" --source "$ROOT" --force
  [ "$status" -eq 0 ]
  [ -f "$TARGET/sailor.manifest" ]
}

@test "E6 verify detects drift" {
  $INSTALL install "$TARGET" --source "$ROOT"
  printf '\n# drift\n' >> "$TARGET/AGENTS.md"
  run $INSTALL verify "$TARGET"
  [ "$status" -eq 4 ]
}

@test "E7 learner Knowledge + dialogue + assessments never modified across update" {
  $INSTALL install "$TARGET" --source "$ROOT"
  printf 'k\n' > "$TARGET/Knowledge/tcp.md"
  printf 'd\n' > "$TARGET/dialogue/x.md"
  printf 'a\n' > "$TARGET/assessments/exam.md"
  b1="$(sha_of "$TARGET/Knowledge/tcp.md")"; b2="$(sha_of "$TARGET/dialogue/x.md")"; b3="$(sha_of "$TARGET/assessments/exam.md")"
  $INSTALL update "$TARGET" --source "$ROOT" --force
  [ "$(sha_of "$TARGET/Knowledge/tcp.md")" = "$b1" ]
  [ "$(sha_of "$TARGET/dialogue/x.md")" = "$b2" ]
  [ "$(sha_of "$TARGET/assessments/exam.md")" = "$b3" ]
}

@test "E8 trailing value-less --source errors quickly (no infinite loop)" {
  run timeout 5 bash "$ROOT/installer/install.sh" install "$TARGET" --source
  [ "$status" -ne 124 ]   # 124 = timed out = still hanging
  [ "$status" -ne 0 ]
}

@test "E10 install into a dir with an edited contract file conflicts (no silent overwrite)" {
  cp "$ROOT/AGENTS.md" "$TARGET/AGENTS.md"
  printf '\n# mine\n' >> "$TARGET/AGENTS.md"
  before="$(sha_of "$TARGET/AGENTS.md")"
  run $INSTALL install "$TARGET" --source "$ROOT"
  [ "$status" -eq 2 ]
  [ "$(sha_of "$TARGET/AGENTS.md")" = "$before" ]
}

sha_of() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | awk '{print $1}';
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}
