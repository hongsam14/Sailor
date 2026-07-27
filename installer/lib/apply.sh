# shellcheck shell=bash
# Atomic apply with rollback (BR-3, SECURITY-15). Fail-closed.
# Returns: 0 ok; 1 apply failed and target rolled back to pre-run bytes;
#          2 apply failed AND rollback could not fully restore (target may be inconsistent).

# sailor_apply <src_dir> <target_dir> <relpath...>
sailor_apply() {
  local src="$1" target="$2"; shift 2
  local files=("$@") f rc=0
  [ "${#files[@]}" -eq 0 ] && return 0
  local backup; backup="$(mktemp -d "${TMPDIR:-/tmp}/sailor-backup.XXXXXX")" || return 1
  local applied=()
  for f in "${files[@]}"; do
    if ! mkdir -p "$target/$(dirname "$f")"; then rc=1; break; fi
    if [ -e "$target/$f" ]; then
      if ! { mkdir -p "$backup/$(dirname "$f")" && cp -p "$target/$f" "$backup/$f"; }; then rc=1; break; fi
    fi
    if cp -p "$src/$f" "$target/$f.sailortmp" && mv "$target/$f.sailortmp" "$target/$f"; then
      applied+=("$f")
    else
      rc=1; break
    fi
  done
  if [ "$rc" -ne 0 ]; then
    local a restore_fail=0
    if [ "${#applied[@]}" -gt 0 ]; then
      for a in "${applied[@]}"; do
        if [ -e "$backup/$a" ]; then
          cp -p "$backup/$a" "$target/$a" || restore_fail=1     # checked: a failed restore is surfaced
        else
          rm -f "$target/$a" || restore_fail=1
        fi
      done
    fi
    find "$target" -type f -name '*.sailortmp' -delete 2>/dev/null   # recursive: also nested staging files
    rm -rf "$backup"
    [ "$restore_fail" -eq 0 ] && return 1 || return 2
  fi
  rm -rf "$backup"
  return 0
}
