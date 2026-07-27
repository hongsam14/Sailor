# shellcheck shell=bash
# Fetch the payload from a PINNED ref (SECURITY-10) and verify its integrity (SECURITY-13).
# Network path (FD-Q1=A: curl + release tarball). Refuses floating branches.

SAILOR_REPO="${SAILOR_REPO:-https://github.com/hongsam14/Sailor}"

# sailor_verify_payload <src_dir> — checks payload files against <src_dir>/payload.manifest.
# FAIL-CLOSED: a missing manifest, a missing payload file, a missing checksum entry, or any mismatch
# all fail. Optional out-of-archive anchor: if SAILOR_EXPECT_DIGEST is set, the manifest's own sha256
# must equal it (defeats an attacker who rewrites both files and manifest inside one archive).
sailor_verify_payload() {
  local src="$1" mf="$1/payload.manifest" f want got
  [ -f "$mf" ] || { echo "sailor: payload.manifest missing; cannot verify integrity" >&2; return 3; }
  if [ -n "${SAILOR_EXPECT_DIGEST:-}" ]; then
    local man_sha; man_sha="$(sailor_sha256 "$mf")" || return 3
    if [ "$man_sha" != "$SAILOR_EXPECT_DIGEST" ]; then
      echo "sailor: payload.manifest digest does not match --expect-digest pin" >&2; return 3
    fi
  fi
  for f in "${SAILOR_PAYLOAD_FILES[@]}"; do
    [ -f "$src/$f" ] || { echo "sailor: payload file missing: $f" >&2; return 3; }
    want="$(sailor_manifest_sha "$mf" "$f" || true)"
    [ -n "$want" ] || { echo "sailor: no manifest checksum for '$f' (refusing — fail-closed)" >&2; return 3; }
    got="$(sailor_sha256 "$src/$f")" || return 3
    if [ "$want" != "$got" ]; then
      echo "sailor: integrity mismatch for $f" >&2; return 3
    fi
  done
  return 0
}

# sailor_fetch <ref> — prints the extracted source dir on success
sailor_fetch() {
  local ref="$1"
  case "$ref" in
    ""|main|master|HEAD|develop|dev)
      echo "sailor: refusing floating ref '$ref' — pin a released tag or commit (SECURITY-10)" >&2
      return 3 ;;
  esac
  command -v curl >/dev/null 2>&1 || { echo "sailor: 'curl' is required for --ref" >&2; return 3; }
  command -v tar  >/dev/null 2>&1 || { echo "sailor: 'tar' is required for --ref" >&2; return 3; }
  local tmp; tmp="$(mktemp -d "${TMPDIR:-/tmp}/sailor-fetch.XXXXXX")" || return 3
  mkdir -p "$tmp/extract"
  if ! curl -fsSL "$SAILOR_REPO/archive/$ref.tar.gz" -o "$tmp/pkg.tgz"; then
    echo "sailor: download failed for ref '$ref'" >&2; rm -rf "$tmp"; return 3
  fi
  if ! tar -xzf "$tmp/pkg.tgz" -C "$tmp/extract"; then
    echo "sailor: extract failed" >&2; rm -rf "$tmp"; return 3
  fi
  local root; root="$(find "$tmp/extract" -mindepth 1 -maxdepth 1 -type d | head -1)"
  [ -n "$root" ] || { echo "sailor: empty archive" >&2; rm -rf "$tmp"; return 3; }
  sailor_verify_payload "$root" || { rm -rf "$tmp"; return 3; }
  echo "$root"
}
