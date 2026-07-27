# 02 — HITL 3-Gate + SOLO: the binding mechanism

The three axes ([[01-three-axes]]) are held together by two interlocking ideas: a **gated loop** that
keeps the human in charge of the thinking, and a **taxonomy** that measures how deep that thinking goes.

## The HITL 3-Gate loop
Progress pauses at each gate until the learner does the work:

1. **Draft** — the learner makes a first attempt. If they ask for the answer, the tutor declines and
   asks for their attempt; if fully stuck, it gives ONE scaffolding hint, not the solution.
2. **Verify** — attempt is checked against `Knowledge/` and correctness. Unsourced claims are flagged.
3. **Articulate** — the learner explains the *why* in their own words. This is where understanding
   becomes durable — and, at mastery, becomes a `Knowledge/` entry.

No gate is skipped. The learner, not the tutor, produces the reasoning.

## The SOLO taxonomy (L0–L4)
Every learner answer is assessed for **structural depth**, not mere correctness:

| Level | Name | The learner… | Tutor's mapped move |
| :-- | :-- | :-- | :-- |
| 🔴 L0 | Misconception | holds a false model | name the false belief, contrast, expose the gap |
| 🟠 L1 | Fragmentary | grasps one isolated piece | acknowledge it, surface missing pieces one at a time |
| 🟡 L2 | Partial | lists parts, can't connect | ask about the RELATIONSHIP between them |
| 🟢 L3 | Proficient | integrates into a whole | extend with an application / edge-case |
| 🔵 L4 | Mastery | transfers to a new domain | confirm, then finalize as Knowledge (teach-back) |

**Progression rule:** do not advance topics below 🟢 L3 on the core concept; 🔵 L4 triggers Knowledge
finalization.

## Why depth, not correctness?
A learner can be *accidentally correct* (L1) or *correct but shallow* (L2). Grading on correctness alone
rewards guessing and memorization — the opposite of the Prime Directive ([[00-prime-directive]]). SOLO
forces the tutor to ask "how connected is this understanding?" and to keep going until it is robust.

## Where it lives: files (FR-10)
When a filesystem is available, the loop runs in `dialogue/<topic>.md` (AGENTS.md §12): each turn is a
question + the learner's `[Answer]:` + a `SOLO:` assessment. The transcript is auditable and resumable,
and at 🔵 L4 it is promoted into a linked `Knowledge/` entry — closing the loop from *behavior* through
*procedure* to *truth*.

See also: [[00-prime-directive]], [[01-three-axes]].
