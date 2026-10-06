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

`scripts/sync-variant.ps1` is preparation/DRILL-only. It hard-blocks `OFFICIAL` mode. Do not copy this vendored kit, third-party skills, or reusable templates into the official submission. During the official session, create only challenge work under `chung-khao/`.

Official project paths use `ProjectRelativeRoot = "chung-khao"`; DRILL uses `ProjectRelativeRoot = "."`. Git pathspecs must be converted from project-relative to repository-relative form before `ls-files`, `status`, `diff`, lock, or writer-preflight checks.

## Git flow

Use branches and real human review for normal work. Direct pushes to `main` are only allowed when the organizer explicitly requires them for a bounded task.
