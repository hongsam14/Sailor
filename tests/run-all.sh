#!/usr/bin/env bash
# Run the full quality gate: shellcheck (if present) + bats (if present) + property harness.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rc=0

echo "== shellcheck =="
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -x "$ROOT/installer/install.sh" "$ROOT"/installer/lib/*.sh "$ROOT"/scripts/*.sh || rc=1
else
  echo "shellcheck not installed — skipped (runs in CI)"
fi

echo "== bats example tests =="
if command -v bats >/dev/null 2>&1; then
  bats "$ROOT/tests/example" || rc=1
else
  echo "bats not installed — skipped (runs in CI)"
fi

echo "== unit regression tests =="
bash "$ROOT/tests/unit.sh" || rc=1

echo "== property harness =="
bash "$ROOT/tests/prop/run.sh" "${SAILOR_SEED:-12345}" "${SAILOR_ITER:-25}" || rc=1

[ "$rc" -eq 0 ] && echo "ALL GREEN" || echo "FAILURES (rc=$rc)"
exit "$rc"
