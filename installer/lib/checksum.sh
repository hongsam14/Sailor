# shellcheck shell=bash
# Portable sha256 (Linux: sha256sum, macOS: shasum -a 256) — FD-Q2=A.

sailor_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "sailor: no sha256 tool found (need 'sha256sum' or 'shasum')" >&2
    return 1
  fi
}
