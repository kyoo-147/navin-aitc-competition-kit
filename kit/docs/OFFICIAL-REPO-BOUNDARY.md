# Official Repository Boundary

## Confirmed requirement

The official team repository states that all final-round source, documentation, and demo-related content must be placed under `chung-khao/`.

Therefore:

- final application code belongs under `chung-khao/`;
- final-round plans, evidence intended for the repository, test fixtures, deployment files, and demo assets belong under `chung-khao/`;
- a committed copy of this competition kit must also live under `chung-khao/`.

## Root exceptions

BTC's organizer-provided AI Log and tool-hook files are root infrastructure and must remain where the organizer template expects them, including files such as:

- `.codex/`;
- `.agents/`;
- `.ai-log/`;
- `scripts/submit_log.py`;
- `scripts/setup_hooks.ps1`;
- `.env.example` and the ignored local `.env`.

Do not move those files into `chung-khao/` merely to make the tree look uniform. The organizer's current repository and documentation override this guide.

## Workspace root

Launch Codex and other supported AI tools from the official repository root. Opening only the `chung-khao/` subdirectory can prevent workspace hooks from loading and can cause required AI events to be lost.

## Reusable kit versus deliverable

The standalone `navin-aitc-competition-kit` repository is preparation tooling and may stay separate.

If the team wants a self-contained version in the official repository, run `scripts/sync-variant.ps1`. It writes only to:

`chung-khao/navin-competition-kit/`

Review the resulting diff before committing. The sync excludes raw preparation screenshots and source material.

## Git flow

Use branches and real human review for normal work. Direct pushes to `main` are only allowed when the organizer explicitly requires them for a bounded task.
