---
# Skill Frontmatter (required)
id: socratic-hint-ladder
title: Socratic Hint Ladder
category: scaffolding
trigger: learner is fully stuck at Gate 1 (Draft) and asks for the answer
gate: Draft
solo_target: L1
requires: none
distribution: example
source: reasoned from general principles
verified: true
updated: 2026-07-28
---

# Socratic Hint Ladder

## 1. Purpose
Move a stuck learner from "give me the answer" to their own first attempt, by offering the *smallest*
hint that unblocks thinking — never the solution. Serves durable understanding, not speed.

## 2. When to Apply (Trigger)
- **IF** the learner is stuck at Gate 1 and requests the answer → **THEN** climb the ladder one rung.
- **Do NOT apply when:** the learner has NOT yet attempted anything — first ask for any attempt.

## 3. Preconditions
- Current gate: Draft
- Assessed SOLO level: L0–L1
- Required context: none

## 4. Procedure (Step-by-Step)
1. **Rung 1 — Reframe:** restate the problem in simpler terms or a smaller case. Ask them to try that.
2. **Rung 2 — Point to the domain:** name the *concept area* to look at (not the mechanism). Ask a question.
3. **Rung 3 — Single leading question:** ask ONE question whose answer is a step, not the whole solution.
4. **Stop climbing** the moment the learner produces any reasoning; return to normal Gate 1 flow.

> **Guardrail:** Never reveal the solution. Each rung is a question or a narrowing, not an answer.

## 5. Example (Illustrative Only)
**Context:** 🔴 L0 on recursion base cases, stuck at Gate 1.
**Application:**
> Learner: "Just tell me why my factorial recursion overflows."
> AI: "🔴 L0 — Let's not jump to the fix. Rung 1: what value should `factorial(0)` return, and does your
> code ever return WITHOUT calling itself again? → Trace `factorial(1)` by hand and tell me what happens."

## 6. Success Criteria
- [ ] Learner produced their OWN reasoning (no unearned answer given).
- [ ] SOLO level was stated.
- [ ] Learner advanced ≥1 level, OR the gap was clearly surfaced.

## 7. Related
- Skills: file-based-socratic-dialogue
- Knowledge: (topic-dependent)
