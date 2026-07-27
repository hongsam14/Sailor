# shellcheck shell=bash
# 3-way classification (Q3=A). Populates indexed arrays with relpaths:
#   SAILOR_ADD SAILOR_UPDATE SAILOR_CONFLICT SAILOR_NOOP
# Fail-closed: returns non-zero (3) if any checksum cannot be computed — never a silent NOOP.
# No-baseline files that differ are CONFLICT (not a silent overwrite) — they need --force.

# sailor_classify <src_dir> <target_dir> <baseline_manifest_or_/dev/null>  -> 0 ok | 3 checksum error
sailor_classify() {
  local src="$1" target="$2" baseline="$3" f disk incoming base
  SAILOR_ADD=(); SAILOR_UPDATE=(); SAILOR_CONFLICT=(); SAILOR_NOOP=()
  for f in "${SAILOR_PAYLOAD_FILES[@]}"; do
    [ -f "$src/$f" ] || continue                 # only ship files present in source
    sailor_is_learner_data "$f" && continue      # never touch learner data (defensive)
    if [ ! -e "$target/$f" ]; then
      SAILOR_ADD+=("$f"); continue
    fi
    if ! incoming="$(sailor_sha256 "$src/$f")" || [ -z "$incoming" ]; then
      echo "sailor: cannot checksum source '$f' (fail-closed)" >&2; return 3
    fi
    if ! disk="$(sailor_sha256 "$target/$f")" || [ -z "$disk" ]; then
      echo "sailor: cannot checksum target '$f' (fail-closed)" >&2; return 3
    fi
    base="$(sailor_manifest_sha "$baseline" "$f" 2>/dev/null || true)"
    if [ "$disk" = "$incoming" ]; then
      SAILOR_NOOP+=("$f")                         # already at incoming content
    elif [ -n "$base" ] && [ "$disk" = "$base" ]; then
      SAILOR_UPDATE+=("$f")                        # unchanged since install → safe overwrite
    else
      SAILOR_CONFLICT+=("$f")                      # locally modified OR no baseline & differs → needs --force
    fi
  done
  return 0
}
