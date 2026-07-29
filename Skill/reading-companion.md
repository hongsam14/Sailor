---
# Skill Frontmatter (required)
id: reading-companion
title: Reading Companion
category: pedagogy
trigger: The learner pastes a book passage OR asks to co-read / resume a specific CS/technical book
gate: any
solo_target: any
requires: filesystem          # file-first; with no filesystem, fall back to plain chat (same as file-based-socratic-dialogue)
distribution: core
source: reasoned from general principles
verified: true
updated: 2026-07-29
---

# Reading Companion

## 1. Purpose
Be the learner's **running-mate** through a CS/technical book: the learner pastes a section/chapter, and
you raise their **durable comprehension** via the Socratic HITL loop (AGENTS.md §5–§6). Understood concepts
become **learner-authored `Knowledge/` entries**. This serves the Prime Directive (durable understanding),
NOT faster reading. Scope is **CS/technical books only**.

## 2. When to Apply (Trigger)
- **IF** the learner **pastes a book passage** (paragraph/section) **OR** asks to **co-read / resume a
  specific book** → apply this skill, working through `reading/<book-slug>.md`.
- **Do NOT apply when:** the learner is working a concept with **no book passage in play** → that is general
  tutoring; use `file-based-socratic-dialogue` instead. On ambiguity, ask exactly ONE clarifying question.

> **Skill vs Mode.** This trigger is mutually exclusive with `file-based-socratic-dialogue`'s trigger — only
> one fires per turn. It is NOT in tension with §4 step 3 below: there you **delegate to File Dialogue Mode**
> (the `dialogue/` medium) for a deep drill; that is this skill staying in control and invoking a medium, not
> the other skill's trigger firing.

## 3. Preconditions
- Current gate: any (Draft to start). Assessed SOLO: any.
- Required context: a writable `reading/` directory and `reading/_TEMPLATE.md`.
- No filesystem → run the identical loop in chat (skip file writes); never claim a write that did not happen (§10).

## 4. Procedure (Step-by-Step)
1. **Open/continue** `reading/<book-slug>.md` from `reading/_TEMPLATE.md`; set frontmatter (`book`,
   `book_slug`, `language` per §3, `current_chapter`, `current_gate`, `mastery_level`, `status: in-progress`).
2. **Capture** the pasted section as a new `## Chapter/Section N` block:
   - a **snippet**: at most **~1–2 sentences** quoted + a citation (chapter/section/page). **Never** paste
     bulk book text — this is copyright-safe capture.
   - a `Learner paraphrase:` line the **learner** fills in their own words (you never fill it — §8).
3. **Socratic loop (section-level, integrative — not per-sentence):** append `## Turn N — <Gate>` with ONE
   Socratic question + an empty `[Answer]:`; then STOP and wait. Read the learner's answer, append
   `**SOLO:** L<k>` (following that level's PATTERN, §6) + the mapped `**Action:**`. Loop Draft→Verify→Articulate.
4. **Deep dive (delegate to File Dialogue Mode):** for a keystone concept that needs a full L0→L4 drill
   (learner < L3 on a fact-worthy concept, or explicit request), **spin off** a `dialogue/<topic>.md`
   (apply `file-based-socratic-dialogue`, AGENTS.md §12) and record `deep_dive: dialogue/<topic>.md` in the
   block. The drill runs there; the reading block keeps the link.
5. **Candidate Knowledge:** list any fact-worthy concept under the block's `## Candidate Knowledge`
   (status: identified). Before mastery it lives **only** here — do NOT create a `Knowledge/` file yet.
6. **Promote on 🔵 L4 (Gate 2 verified):** the **learner authors** `Knowledge/<id>.md` in their own words;
   you fill only frontmatter + source citation (§7), add `provenance:` back to the dialogue (or this reading
   file), mark the candidate `promoted → Knowledge/<id>.md`, and add the id to `knowledge_targets`.
7. **Advance / handoff:** do NOT move to the next section until the current core reaches ≥ 🟢 L3 (§6). On
   pause/end, emit the §11 Session Handoff with an additive `reading_file:` line (and `dialogue_file:` if a
   drill is active).

> **Guardrails (§8):** never write the learner's paraphrase/`[Answer]:`; never reveal an unearned answer
> (give ONE scaffolding hint if stuck); always state a SOLO level; keep CS terms in English; follow the
> learner's language (§3). **No Skill extraction** — a reusable method the book teaches is captured as a
> Knowledge candidate, never as a `Skill/` entry (that stays a maintainer act).

## 5. Example (Illustrative Only)
> DOMAIN-SPECIFIC example; the PROCEDURE is general.

**Context:** learner co-reading "SICP", pastes §1.1 on the substitution model.
**Application:**
> Tutor (appends to `reading/sicp.md`):
> ```
> ## Chapter/Section 1.1 — The Substitution Model
> **Snippet:** "...the substitution model ... is only the first of these models." (SICP §1.1.5)
> **Learner paraphrase:**
>
> ## Turn 1 — Draft
> **Tutor:** In your own words, what does the substitution model claim happens when a procedure is applied?
> [Answer]:
> ```
> Learner fills paraphrase + `[Answer]:`. Tutor appends `**SOLO:** L2 ...` + `**Action:**` + the next Turn.
> A keystone the learner is shaky on (e.g. applicative vs normal order) → spin off `dialogue/evaluation-order.md`.

## 6. Success Criteria
- [ ] Each turn recorded the learner's OWN reasoning (no unearned answer; snippet stayed ~1–2 sentences).
- [ ] Every learner answer got a stated SOLO level.
- [ ] Candidates stayed in `reading/` until 🔵 L4; promoted entries are learner-authored with provenance.
- [ ] No `Skill/` entry was created by this loop.

## 7. Related
- Skills: `file-based-socratic-dialogue` (deep per-concept drills), `web-grounded-verification` (fact-check
  before promotion), `problem-authoring-and-grading` (assess comprehension).
- Knowledge: the entries named by `knowledge_targets`.
