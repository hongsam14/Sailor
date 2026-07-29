---
# Reading Frontmatter (required) — a file-based book-reading transcript (Skill `reading-companion`)
book: <human title>                 # e.g. "Structure and Interpretation of Computer Programs"
book_slug: <slug>                   # kebab-case id -> filename reading/<book_slug>.md ; e.g. "sicp"
language: <ko | en>                 # follows the learner (AGENTS.md §3)
current_chapter: <ref>              # last section worked, e.g. "1.1.5"
current_gate: <Draft | Verify | Articulate>
mastery_level: <L0 | L1 | L2 | L3 | L4>
status: <in-progress | paused | completed>
started: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
knowledge_targets: []               # ids this reading aims to produce / has produced (PLURAL — one book, many facts)
---

# Reading — <Book>

> Protocol (Skill `reading-companion`): one file per book; chapters ACCRETE as `## Chapter/Section N` blocks.
> Per section: the tutor stores a SHORT snippet (≤ ~1–2 sentences + citation — copyright-safe), the learner
> writes their OWN paraphrase, then the tutor runs a section-level Socratic loop (ONE question + empty
> `[Answer]:`, then STOPS). A keystone concept needing an L0→L4 drill spins off to `dialogue/<topic>.md`.
> On 🔵 L4, the learner authors `Knowledge/<id>.md` (tutor cites); the candidate is marked promoted here.

<!--
COPYRIGHT GUARDRAIL: never paste bulk book text. Quote at most ~1–2 sentences per section to anchor the
discussion; everything else is the learner's own paraphrase/notes.
LEARNER DATA: this file is yours — the Sailor installer never creates, modifies, or deletes reading/*.md.
-->

---

## Chapter/Section <N> — <title>

**Snippet:** "<≤ 1–2 sentences, verbatim>" (<book> <chapter/section/page>)

**Learner paraphrase:** <the learner restates the passage in their OWN words — the tutor never fills this>

### Turn 1 — Draft
**Tutor:** <one Socratic question — never the answer>

[Answer]: 

<!--
After the learner fills [Answer]: above, the tutor appends:

**SOLO:** L<k> — <assessment following the level's PATTERN (§6)>
**Action:** <mapped action / next scaffolding question>

### Turn 2 — <Gate>
**Tutor:** <next question>

[Answer]: 
-->

### Candidate Knowledge
<!-- fact-worthy concepts from THIS section; each lives ONLY here until 🔵 L4 (no Knowledge/ file before then) -->
- concept: <name> | status: identified | deep_dive: <dialogue/<topic>.md | none> | knowledge_id: <none until promoted>

### Deep dives
<!-- links to dialogue/<topic>.md spun off for concepts needing an L0→L4 drill -->
- deep_dive: <dialogue/<topic>.md | none>

---

## Outcome (filled as concepts reach 🔵 L4)
- **Knowledge entry:** `Knowledge/<id>.md`  (learner-authored; tutor cited)
- **Verified at Gate 2 by:** <human | pending>
- **Provenance:** this `reading/<book_slug>.md` (and any `dialogue/<topic>.md` used)
