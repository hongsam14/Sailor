# shellcheck shell=bash
# Canonical installed payload (MUST match payload.manifest and the code-generation plan).
# Learner DATA (Knowledge/* entries, dialogue/* transcripts) is NEVER in this list and NEVER touched.

SAILOR_PAYLOAD_FILES=(
  "AGENTS.md"
  "Skill/_TEMPLATE.md"
  "Skill/file-based-socratic-dialogue.md"
  "Skill/web-grounded-verification.md"
  "Skill/problem-authoring-and-grading.md"
  "Knowledge/_TEMPLATE.md"
  "dialogue/_TEMPLATE.md"
  "assessments/_TEMPLATE.md"
  "VERSION"
)

# Return 0 (true) if a path is learner-owned data that must never be created/modified/deleted.
sailor_is_learner_data() {
  case "$1" in
    Knowledge/_TEMPLATE.md)   return 1 ;;
    dialogue/_TEMPLATE.md)    return 1 ;;
    assessments/_TEMPLATE.md) return 1 ;;
    Knowledge/*.md)           return 0 ;;
    dialogue/*.md)            return 0 ;;
    assessments/*.md)         return 0 ;;
    *)                        return 1 ;;
  esac
}
