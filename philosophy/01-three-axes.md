# 01 — The Three Axes

Sailor's contract stands on three axes. Each answers a different question, and together they keep the
tutor honest and the learner active.

## Axis 1 — `AGENTS.md` (the Contract): *how the tutor behaves*
A **self-contained** operating contract. Any LLM session — even with zero prior context — can act
correctly using only `AGENTS.md`. It defines identity, the Prime Directive, language policy, the HITL
gates, the SOLO rubric, anti-patterns, and the bootstrap/handoff rules. It is the constitution.

## Axis 2 — `Skill/` (Procedures): *what the tutor can DO*
Reusable, named **procedures** the tutor applies at a gate — e.g. a hint ladder, a diagnostic, the
file-dialogue protocol. A Skill is a repeatable method with a trigger, a step-by-step procedure, and a
guardrail that forbids revealing unearned answers. Skills make good tutoring *transferable* across
topics and sessions.

## Axis 3 — `Knowledge/` (Facts): *what is TRUE and citable*
The **source of truth**: verified, citable facts with provenance and a mastery level. Grounding order is
`Knowledge/` > `Skill/` > general knowledge (which must be flagged). Knowledge entries are preferably
**learner-authored at L4**, because teaching-back is what cements understanding.

## How they bind together
```
            Prime Directive (00)
                    |
     +--------------+--------------+
     |              |              |
  AGENTS.md       Skill/        Knowledge/
 (behavior)     (procedure)      (truth)
     |              |              |
     +----- HITL 3-Gate + SOLO ----+       <- the binding mechanism (02)
                    |
             dialogue/<topic>.md            <- where it happens, on disk (FR-10)
                    |
             a new Knowledge/ entry         <- the durable output
```

- **AGENTS.md** says *how*; **Skill/** says *with what method*; **Knowledge/** says *grounded in what truth*.
- The **HITL 3-Gate + SOLO** loop ([[02-hitl-and-solo]]) is the engine that moves a learner across the
  three axes: a Draft (behavior) guided by a Skill (procedure), verified against Knowledge (truth),
  articulated until it *becomes* new Knowledge.

## Data vs. contract (a boundary that matters)
- **Contract & procedures** (`AGENTS.md`, `Skill/*`, templates) are shipped/updated by Sailor.
- **Learner data** (`Knowledge/*` entries, `dialogue/*` transcripts) belongs to the learner and is
  **never overwritten** by the installer. Understanding, once earned, is not clobbered by an update.

See also: [[00-prime-directive]], [[02-hitl-and-solo]].
