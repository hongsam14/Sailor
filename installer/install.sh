#!/usr/bin/env bash
# Sailor installer — install / update / verify the AI-Tutor contract in a target repo.
# Copy-based, manifest-tracked, 3-way safe. Never overwrites learner Knowledge/dialogue/assessment data.
set -uo pipefail

SAILOR_SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAILOR_LIB="$SAILOR_SELF_DIR/lib"
for _m in payload checksum manifest classify apply report fetch; do
  # shellcheck source=/dev/null
  . "$SAILOR_LIB/$_m.sh"
done

SAILOR_EXPECT_DIGEST="${SAILOR_EXPECT_DIGEST:-}"

sailor_usage() {
  cat <<'EOF'
Sailor installer — install / update / verify the AI-Tutor contract.

Usage:
  install.sh install <target-repo> [--source DIR | --ref TAG] [--expect-digest SHA] [--force] [--dry-run]
  install.sh update  <target-repo> [--source DIR | --ref TAG] [--expect-digest SHA] [--force] [--dry-run]
  install.sh verify  <target-repo>

Source resolution:
  --source DIR       use a local Sailor tree (manual/offline; also used by tests)
  --ref TAG          fetch a pinned release tarball over the network
  (neither)          use the Sailor clone this script lives in

Integrity:
  --expect-digest SHA   require payload.manifest's own sha256 to equal SHA (out-of-archive pin, SECURITY-13)

Exit codes: 0 ok · 1 usage/precondition · 2 conflict (no --force) · 3 fetch/integrity · 4 apply/rollback.
EOF
}

sailor_die() { echo "sailor: $1" >&2; exit "${2:-1}"; }

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    install|update|verify) ;;
    -h|--help|help|"") sailor_usage; exit 0 ;;
    *) sailor_die "unknown command '$cmd' (install|update|verify)" 1 ;;
  esac

  local target="" source_dir="" ref="" force=0 dry=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --source)        [ $# -ge 2 ] || sailor_die "--source requires a value" 1; source_dir="$2"; shift 2 ;;
      --ref)           [ $# -ge 2 ] || sailor_die "--ref requires a value" 1; ref="$2"; shift 2 ;;
      --expect-digest) [ $# -ge 2 ] || sailor_die "--expect-digest requires a value" 1; SAILOR_EXPECT_DIGEST="$2"; shift 2 ;;
      --force)         force=1; shift ;;
      --dry-run)       dry=1; shift ;;
      -h|--help)       sailor_usage; exit 0 ;;
      -*)              sailor_die "unknown flag '$1'" 1 ;;
      *)               [ -z "$target" ] && target="$1" || sailor_die "unexpected argument '$1'" 1; shift ;;
    esac
  done

  [ -n "$target" ] || sailor_die "missing <target-repo>" 1
  [ -d "$target" ] || sailor_die "target is not a directory: $target" 1

  if [ "$cmd" = "verify" ]; then cmd_verify "$target"; return; fi

  # Resolve source
  local src fetched=""
  if [ -n "$source_dir" ] && [ -n "$ref" ]; then sailor_die "use only one of --source / --ref" 1; fi
  if [ -n "$source_dir" ]; then
    src="$source_dir"
  elif [ -n "$ref" ]; then
    src="$(sailor_fetch "$ref")" || exit 3
    fetched="$src"
  else
    src="$(cd "$SAILOR_SELF_DIR/.." && pwd)"    # the Sailor clone we live in
  fi
  [ -f "$src/VERSION" ] || sailor_die "source has no VERSION: $src" 1

  # Fail-closed integrity: verify the source payload against its payload.manifest for EVERY flow
  # (closes the --source/curl|bash gap). Note: an in-archive manifest detects corruption, not
  # authenticity — use --expect-digest (or a pinned tag over HTTPS) to anchor trust.
  sailor_verify_payload "$src" || sailor_die "source payload failed integrity verification" 3

  case "$cmd" in
    install) cmd_install "$src" "$target" "$force" "$dry" ;;
    update)  cmd_update  "$src" "$target" "$force" "$dry" ;;
  esac
  local rc=$?
  [ -n "$fetched" ] && rm -rf "$(dirname "$fetched")" 2>/dev/null
  return $rc
}

cmd_install() {
  local src="$1" target="$2" force="$3" dry="$4"
  if [ -f "$target/$SAILOR_MANIFEST_NAME" ] && [ "$force" -ne 1 ]; then
    sailor_die "already installed (sailor.manifest present); use 'update'" 1
  fi
  sailor_classify "$src" "$target" /dev/null || sailor_die "checksum failure during classification" 3
  _apply_plan "$src" "$target" "$force" "$dry" "install"
}

cmd_update() {
  local src="$1" target="$2" force="$3" dry="$4"
  [ -f "$target/$SAILOR_MANIFEST_NAME" ] || sailor_die "no sailor.manifest; run 'install' first" 1
  sailor_classify "$src" "$target" "$target/$SAILOR_MANIFEST_NAME" || sailor_die "checksum failure during classification" 3
  _apply_plan "$src" "$target" "$force" "$dry" "update"
}

_apply_plan() {
  local src="$1" target="$2" force="$3" dry="$4" verb="$5"
  if [ "${#SAILOR_CONFLICT[@]}" -gt 0 ] && [ "$force" -ne 1 ]; then
    sailor_report_conflicts
    exit 2
  fi
  # Build the apply list WITHOUT expanding empty arrays (bash 3.2 + set -u safe).
  local list=()
  [ "${#SAILOR_ADD[@]}"    -gt 0 ] && list+=("${SAILOR_ADD[@]}")
  [ "${#SAILOR_UPDATE[@]}" -gt 0 ] && list+=("${SAILOR_UPDATE[@]}")
  [ "$force" -eq 1 ] && [ "${#SAILOR_CONFLICT[@]}" -gt 0 ] && list+=("${SAILOR_CONFLICT[@]}")

  if [ "$dry" -eq 1 ]; then
    sailor_report_plan "DRY-RUN ($verb):"
    return 0
  fi
  if [ "${#list[@]}" -gt 0 ]; then
    sailor_apply "$src" "$target" "${list[@]}"
    local arc=$?
    if [ "$arc" -eq 1 ]; then
      sailor_die "apply failed; target rolled back to pre-run state" 4
    elif [ "$arc" -eq 2 ]; then
      sailor_die "apply failed AND rollback INCOMPLETE — target may be inconsistent; restore from git and retry" 4
    fi
  fi
  sailor_write_manifest "$target" "$(cat "$src/VERSION")"
  sailor_report_plan "$verb complete:"
  echo "sailor: version $(cat "$src/VERSION") recorded in $target/$SAILOR_MANIFEST_NAME"
}

cmd_verify() {
  local target="$1" mf="$1/$SAILOR_MANIFEST_NAME"
  [ -f "$mf" ] || sailor_die "no sailor.manifest in $target" 1
  local drift=() rel sha got
  while read -r sha rel; do
    case "$sha" in \#*|"") continue ;; esac
    if [ ! -f "$target/$rel" ]; then drift+=("missing:$rel"); continue; fi
    if ! got="$(sailor_sha256 "$target/$rel")" || [ -z "$got" ]; then
      sailor_die "cannot checksum $rel during verify (fail-closed)" 4
    fi
    [ "$got" != "$sha" ] && drift+=("modified:$rel")
  done < "$mf"
  if [ "${#drift[@]}" -gt 0 ]; then
    echo "sailor: drift detected:" >&2
    printf '  ! %s\n' "${drift[@]}" >&2
    exit 4
  fi
  echo "sailor: verify OK — installed at version $(sailor_manifest_version "$mf")"
  sailor_newsession_reminder
}

main "$@"
