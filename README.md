# NR-00 — NAVIN Research AITC Round 2 Harness

Private competition harness for team **AITC-918 — NAVIN Research**.

This repository is the team's preparation, implementation, evidence, and controlled delivery workspace. It is separate from the official BTC repository `ai-thuc-chien/aitc2026-team-918-navin-research`.

## Start here

1. Read `AGENTS.md`.
2. Read `docs/competition/README.md` and `docs/competition/ROUND-2-RULES.md`.
3. Read `docs/operations/WORKFLOW.md`.
4. Before the official timed session, complete `docs/competition/COMPETITION-DAY-CHECKLIST.md`.

## Workspace layout

```text
.ai/                     Agent identity and operating protocols
config/                  Machine-readable official-source registry
scripts/                 AI log and harness verification/refresh scripts
docs/competition/        Sourced Round 2 knowledge pack
docs/operations/         Git, member workspace, and SS-WD operating rules
workspace/product/       Product source after the official challenge is known
workspace/evidence/      Test/demo evidence safe to commit
workspace/submission/    Final reviewed submission staging area
```

## Hard boundaries

- Official BTC instructions override this repository.
- During the official session, only tools/models/resources explicitly permitted by BTC may be used.
- AI usage logging must remain complete and truthful.
- Never commit secrets, AI/API keys, credentials, private keys, raw AI logs, monitoring recordings, or private worker transcripts.
- Research and preparation claims must cite official URLs and distinguish facts, inferences, and unknowns.
- `main` is integration-only: member branches → PR → review → leader merge.

## Verification

```powershell
python scripts/verify_harness.py
python -m unittest discover -s tests -v
git diff --check
```
