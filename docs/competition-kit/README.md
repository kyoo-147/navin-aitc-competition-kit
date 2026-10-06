# Competition Kit Status

The canonical reusable implementation is [`../../kit/`](../../kit/README.md).

## Implemented

- organizer-aligned credential names;
- private Codex config using BTC Gateway Responses API;
- official hook setup with Windows UTF-8 BOM normalization;
- fail-closed structure, Gateway, team budget, model canary, and AI Log server readback preflight;
- spend guard using `team_id` from `/key/info` and nested `team_info` fields;
- explicit `chung-khao/` delivery boundary;
- safe reusable-variant sync into `chung-khao/navin-competition-kit/`;
- bounded captain, worker, reviewer, diagnosis, and Orca skills;
- implementation contract and timed runbooks;
- content manifest and offline verifier.

## Deliberately not implemented

- a starter application or hidden product template;
- any personal-provider fallback;
- automatic secret storage outside the ignored official `.env` or current process;
- automatic commit, push, merge, deployment, or submission;
- claims that dated model names or prices are current.

## Required live proof

Static verification cannot prove Gateway availability, a selected model, current spend, AI Log ingestion, deployment, or platform submission. Those remain day-of checks against official systems.
