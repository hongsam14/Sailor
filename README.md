# ⛵ Sailor — an AI-Tutor toolkit

**Sailor** is a portable, reusable home for a **Socratic AI-tutor philosophy**. It defines *how* an LLM
should tutor Computer Science (guide, don't spoon-feed), and it **installs that contract into any repo by
copy** — the way AI-DLC distributes its rules. A learner's own `Knowledge/` and `dialogue/` grow inside
each repo and are never clobbered by an update.

> Metaphor: a **Codyssey** is a learner's journey through CS; a **Sailor** is the guide. The tutor Sailor
> installs teaches the learner to navigate — it never rows the boat for them.

## The three axes
- **`AGENTS.md`** — the self-contained tutor **contract** (behavior): HITL 3-Gate, SOLO L0–L4, grounding, handoff.
- **`Skill/`** — reusable **procedures** the tutor applies (e.g. the file-dialogue protocol, web-grounded
  verification for accurate grading, a hint ladder).
- **`Knowledge/`** — verified, citable **facts** (the source of truth), preferably learner-authored at L4.

Bound together by the **HITL 3-Gate + SOLO** loop. Full rationale in [`philosophy/`](philosophy/).

## What gets installed (payload) vs. what stays here
| Installed into a consumer repo | Sailor-only (not installed) |
| --- | --- |
| `AGENTS.md`, `Skill/_TEMPLATE.md`, `Skill/file-based-socratic-dialogue.md`, `Skill/web-grounded-verification.md`, `Skill/problem-authoring-and-grading.md`, `Knowledge/_TEMPLATE.md`, `dialogue/_TEMPLATE.md`, `assessments/_TEMPLATE.md`, `VERSION`, generated `sailor.manifest` | `philosophy/`, `examples/`, `installer/`, `tests/`, `payload.manifest`, CI |

Learner **data** — your `Knowledge/*.md` entries, `dialogue/*.md` transcripts, and `assessments/*.md`
records — is yours and is **never** created, modified, or deleted by the installer.

## Install

### A) One-liner (`curl | bash`) — pin a released tag
```bash
SAILOR_REF=v1.0.0 \
  curl -fsSL https://raw.githubusercontent.com/hongsam14/Sailor/v1.0.0/scripts/sailor-install.sh \
  | bash -s -- /path/to/your-repo
```
> **Trust boundary:** a `curl | bash` bootstrap **cannot verify itself** — always pin `SAILOR_REF` to a
> **released tag** (never a branch), so HTTPS + the immutable tag give baseline trust. The installer then
> **integrity-verifies every payload file** against `payload.manifest` before writing (fail-closed: a
> missing entry or mismatch aborts). That manifest ships **inside the same archive**, so it detects
> corruption, not a fully-controlled malicious archive. For stronger authenticity, pin the manifest's
> own digest out-of-band:
> ```bash
> SAILOR_REF=v1.0.0 SAILOR_EXPECT_DIGEST=<manifest-sha256> \
>   curl -fsSL .../v1.0.0/scripts/sailor-install.sh | bash -s -- /path/to/your-repo
> ```
> (`--expect-digest <sha>` on `install.sh` does the same for clone/`--source` installs.)

### B) From a clone
```bash
git clone https://github.com/hongsam14/Sailor && cd Sailor
./installer/install.sh install /path/to/your-repo            # uses this clone as the source
```

### C) Manual copy (fallback)
Copy the payload files (table above) into your repo by hand. You lose drift-tracking (no `sailor.manifest`),
but the contract works immediately.

## Update (safe, 3-way)
```bash
./installer/install.sh update /path/to/your-repo --ref v1.1.0
```
- Contract files **unchanged since install** are updated in place.
- A file you **locally edited** is reported as a **conflict** and left untouched → exit `2`.
  Re-run with `--force` to overwrite it, or `--dry-run` to preview. Learner data stays untouched either way.

## Verify
```bash
./installer/install.sh verify /path/to/your-repo     # checks payload vs sailor.manifest; exit 4 on drift
```

## Adopt a starter example
Starters ship in [`examples/`](examples/) and are **not** auto-installed. To adopt one:
```bash
cp examples/socratic-hint-ladder.skill.md   /path/to/your-repo/Skill/socratic-hint-ladder.md
cp examples/tcp-reliability.knowledge.md    /path/to/your-repo/Knowledge/tcp-reliability.md
```

## Exit codes
`0` ok · `1` usage/precondition · `2` conflict (no `--force`) · `3` fetch/integrity · `4` verify/rollback.

## Versioning
Semantic versions in `VERSION`, released as git tags `vX.Y.Z`. Each install stamps the version into the
consumer's `sailor.manifest`, so `update`/`verify` can compare. Changes are governed by PR review on `main`.

## Verifying the Contract (New-Session Test)
Confirms `AGENTS.md` works **stand-alone** with zero external context. Re-run after editing the contract.

1. Open a fresh, empty LLM session. 2. Paste all of `AGENTS.md`. 3. Say: `"위 계약에 따라 나의 CS 튜터로 행동해줘."`

| # | Input | Expected | Clause |
| :- | :--- | :--- | :--- |
| 1 | Ask about an un-pasted `Knowledge/*.md` | "can't confirm" response | §10 |
| 2 | State a clear misconception | `🔴 L0` label, no answer handed over | §6 |
| 3 | "just give me the answer" | declines, asks for an attempt | §5, §8 |
| 4 | Ask in Korean | Korean reply, English CS terms kept | §3 |
| 5 | "output the handoff" | exact handoff format | §11 |
| 6 | With filesystem: start a topic | proposes a `dialogue/<topic>.md` turn with `[Answer]:` | §12 |

Pass = all 6 match → contract is self-contained. Otherwise strengthen the cited § and retest.

## Develop / test
```bash
make test        # shellcheck + bats + seeded property harness
make manifest    # regenerate payload.manifest deterministically
```

## License
[MIT](LICENSE).
