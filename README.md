# NAVIN AITC Competition Kit

Private competition-day setup, skill, routing, and verification kit for team **AITC-918 — NAVIN Research**. It was initialized from the proven `kyoo-147/nr-00` harness so its sourced rules and operating history remain available.

This repository is separate from the official BTC repository `ai-thuc-chien/aitc2026-team-918-navin-research`. It must never receive secrets or raw private AI logs.

## Start here

1. Read `AGENTS.md`.
2. Read `docs/competition/README.md` and `docs/competition/ROUND-2-RULES.md`.
3. Read `docs/competition-kit/README.md` and `skills/aitc-orchestrator/SKILL.md`.
4. Read `docs/operations/WORKFLOW.md`.
5. Before the official timed session, complete `docs/competition/COMPETITION-DAY-CHECKLIST.md`.

## Workspace layout

```text
.ai/                     Agent identity and operating protocols
config/                  Official sources plus budget/model/router policies
skills/                  Competition-specific orchestration instructions
scripts/                 AI log and harness verification/refresh scripts
docs/competition/        Sourced Round 2 knowledge pack
docs/competition-kit/    Competition-day kit design and implementation status
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
