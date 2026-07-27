#!/usr/bin/env bash
# Regenerate payload.manifest deterministically (G3). Run from the Sailor repo root.
#   ./scripts/gen-payload-manifest.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/payload.sh"
# shellcheck source=/dev/null
. "$ROOT/installer/lib/checksum.sh"

cd "$ROOT" || exit 1
out="$ROOT/payload.manifest"
{
  printf '# sailor-payload-version: %s\n' "$(cat "$ROOT/VERSION")"
  for f in "${SAILOR_PAYLOAD_FILES[@]}"; do
    [ -f "$ROOT/$f" ] && printf '%s  %s\n' "$(sailor_sha256 "$ROOT/$f")" "$f"
  done | LC_ALL=C sort -k2,2
} > "$out"
echo "wrote $out"
