# shellcheck shell=bash
# Human-readable, non-secret status output (SECURITY-03 light).

sailor_join() { local IFS=' '; echo "$*"; }

sailor_report_plan() {
  local prefix="$1"
  printf '%s add=%d update=%d conflict=%d noop=%d protected(learner-data)=untouched\n' \
    "$prefix" "${#SAILOR_ADD[@]}" "${#SAILOR_UPDATE[@]}" "${#SAILOR_CONFLICT[@]}" "${#SAILOR_NOOP[@]}"
  [ "${#SAILOR_ADD[@]}"      -gt 0 ] && printf '  + add:      %s\n' "$(sailor_join "${SAILOR_ADD[@]}")"
  [ "${#SAILOR_UPDATE[@]}"   -gt 0 ] && printf '  ~ update:   %s\n' "$(sailor_join "${SAILOR_UPDATE[@]}")"
  [ "${#SAILOR_CONFLICT[@]}" -gt 0 ] && printf '  ! conflict: %s\n' "$(sailor_join "${SAILOR_CONFLICT[@]}")"
  return 0
}

sailor_report_conflicts() {
  echo "sailor: local modifications would be overwritten (aborting, no changes made):" >&2
  local f
  for f in "${SAILOR_CONFLICT[@]}"; do echo "  ! $f" >&2; done
  echo "  → re-run with --force to overwrite, or --dry-run to preview." >&2
}

sailor_newsession_reminder() {
  cat <<'EOF'

Structural verify passed. NOTE: the *behavioral* self-containment test is manual —
paste AGENTS.md into a fresh LLM session and run the New-Session Test in README.md.
EOF
}
