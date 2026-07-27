# shellcheck shell=bash
# sailor.manifest: the per-consumer install baseline (version + payload checksums).
# Format (deterministic, G3):
#   # sailor-version: <semver>
#   # installed-at: <YYYY-MM-DD>
#   <sha256>  <relpath>        (payload files, LC_ALL=C sorted by path)

SAILOR_MANIFEST_NAME="sailor.manifest"

# sailor_write_manifest <target_dir> <version>
sailor_write_manifest() {
  local target="$1" version="$2" f
  local date; date="$(date -u +%F 2>/dev/null || echo unknown)"
  {
    printf '# sailor-version: %s\n' "$version"
    printf '# installed-at: %s\n' "$date"
    for f in "${SAILOR_PAYLOAD_FILES[@]}"; do
      [ -f "$target/$f" ] && printf '%s  %s\n' "$(sailor_sha256 "$target/$f")" "$f"
    done | LC_ALL=C sort -k2,2
  } > "$target/$SAILOR_MANIFEST_NAME"
}

# sailor_manifest_sha <manifest_file> <relpath>  -> prints the FIRST matching sha or returns 1
# Format is "<64-hex-sha><2 spaces><relpath>"; split by fixed offset so paths with spaces still match.
sailor_manifest_sha() {
  awk -v p="$2" '
    $0 !~ /^#/ && length($0) > 66 {
      sha = substr($0, 1, 64); rel = substr($0, 67)
      if (rel == p) { print sha; exit 0 }
    }
    END { exit 1 }' "$1" 2>/dev/null
}

# sailor_manifest_version <manifest_file>
sailor_manifest_version() {
  awk -F': ' '/^# sailor-version:/{print $2; exit}' "$1" 2>/dev/null
}
