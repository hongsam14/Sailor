# Changelog

All notable changes to Sailor are documented here. Format loosely follows
[Keep a Changelog]; versions follow SemVer.

## [1.0.0] — 2026-07-28
### Added
- Initial release of the **Sailor** AI-Tutor toolkit.
- Contract `AGENTS.md` (Socratic tutor: HITL 3-Gate, SOLO L0–L4, Knowledge/Skill grounding, session handoff).
- **File Dialogue Mode** (FR-10): file-based Socratic Q&A via `dialogue/<topic>.md`, linked to `Knowledge/`.
- Core Skill `Skill/file-based-socratic-dialogue.md`; templates for Skill, Knowledge, dialogue.
- **Web-augmented grounding** (FR-11): core Skill `Skill/web-grounded-verification.md` + AGENTS.md §4
  tier 3 (web, authority-judged, cited) and Gate 2 rule — used for accurate problem-posing/grading;
  optional capability that degrades to flagged general reasoning when no web tool is available.
- **Assessment Mode** (FR-12): pose a verified problem + **summative grading** (verdict + SOLO + rubric +
  citations, fail-closed). Core Skill `Skill/problem-authoring-and-grading.md`, AGENTS.md §13,
  `assessments/_TEMPLATE.md` (learner data, installer-protected).
- Skill template gains `requires:` (none|filesystem|web-tool) and `distribution:` (core|example) fields.
- Philosophy docs (`philosophy/`) and worked examples (`examples/`).
- Copy-based installer `installer/install.sh` (`install` / `update` / `verify`) with a manifest-based
  3-way safe update, non-destructive to learner Knowledge and dialogues.
- Tests (bats + property harness + unit regression suite) and pinned CI.

### Hardened (post code-review)
- Fail-closed payload integrity: verification runs on the `--source`/curl|bash path too, aborts on a
  missing manifest entry, and supports an out-of-archive `--expect-digest`/`SAILOR_EXPECT_DIGEST` anchor.
- Installer no longer silently overwrites a locally-edited contract file (now a conflict), and is
  fail-closed on checksum-tool failure.
- Atomic apply: rollback checks restore success (distinct exit for incomplete rollback) and cleans up
  nested `*.sailortmp`. Arg parsing rejects value-less `--source/--ref` (no infinite loop). Empty-array
  handling is bash 3.2 + `set -u` safe. Manifest parsing tolerates paths with spaces.
