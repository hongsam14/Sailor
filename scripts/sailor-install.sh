#!/usr/bin/env bash
# Sailor curl|bash bootstrap.
#
#   curl -fsSL https://raw.githubusercontent.com/hongsam14/Sailor/<TAG>/scripts/sailor-install.sh \
#     | bash -s -- <target-repo> [--force] [--dry-run]
#
# TRUST BOUNDARY (G4/SECURITY-13): this bootstrap is fetched over the network and cannot verify
# itself. Pin <TAG> to a RELEASED TAG (never a branch) so HTTPS + the immutable tag establish
# baseline trust. The installer then integrity-verifies the payload against payload.manifest before
# writing anything. NOTE: that manifest ships inside the same archive, so it detects corruption, not
# a fully-controlled malicious archive — for that, set SAILOR_EXPECT_DIGEST to the manifest's known
# sha256 (published out-of-band); it is enforced as an out-of-archive anchor.
set -uo pipefail

REPO="${SAILOR_REPO:-https://github.com/hongsam14/Sailor}"
REF="${SAILOR_REF:-}"           # export SAILOR_REF=<tag> ; required (no floating default)
if [ -z "$REF" ]; then
  echo "sailor: set SAILOR_REF=<released-tag> before piping (refusing floating install)" >&2
  exit 3
fi
command -v curl >/dev/null 2>&1 || { echo "sailor: curl required" >&2; exit 3; }
command -v tar  >/dev/null 2>&1 || { echo "sailor: tar required"  >&2; exit 3; }

tmp="$(mktemp -d "${TMPDIR:-/tmp}/sailor-boot.XXXXXX")" || exit 3
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$REPO/archive/$REF.tar.gz" -o "$tmp/pkg.tgz" || { echo "sailor: download failed" >&2; exit 3; }
mkdir -p "$tmp/x" && tar -xzf "$tmp/pkg.tgz" -C "$tmp/x" || { echo "sailor: extract failed" >&2; exit 3; }
root="$(find "$tmp/x" -mindepth 1 -maxdepth 1 -type d | head -1)"
[ -n "$root" ] || { echo "sailor: empty archive" >&2; exit 3; }

# install.sh verifies the payload on the --source path too; forward an optional out-of-archive pin.
if [ -n "${SAILOR_EXPECT_DIGEST:-}" ]; then
  exec bash "$root/installer/install.sh" install "$@" --source "$root" --expect-digest "$SAILOR_EXPECT_DIGEST"
else
  exec bash "$root/installer/install.sh" install "$@" --source "$root"
fi
