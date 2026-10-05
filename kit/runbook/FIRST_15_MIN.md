# First 15 Minutes

## Minute 0-5

- Read the complete live challenge before coding.
- Extract mandatory deliverables, scoring items, forbidden approaches, deployment, and submission obligations.
- Confirm final project path under `chung-khao/`.
- Run budget, preflight, the smallest logged canary, and session preflight. Stop unless rollout provider is `thucchien`, local events exist, submission is `202`, and BTC readback matches the same session.

## Minute 5-10

- Fill `templates/ACCEPTANCE_MATRIX.md`.
- Define the smallest complete real flow.
- Choose the simplest architecture that can deliver it.
- Freeze `templates/IMPLEMENTATION_CONTRACT.md` into the project.

## Minute 10-15

- Use the Captain directly for small or overlapping tasks.
- If parallel work is justified, create at most two isolated writer worktrees with non-overlapping paths.
- A third visible Orca lane may be a read-only scout/reviewer only; require `turn_started`, then poll with `terminal read --cursor`.
- Start integration planning immediately. Do not wait for isolated lanes to become perfect.
