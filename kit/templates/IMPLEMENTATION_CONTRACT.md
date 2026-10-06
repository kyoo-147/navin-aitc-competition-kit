# Implementation Contract

Freeze this file before parallel writers start. Changes require captain approval and notification to every affected lane.

## User outcome

- User:
- Problem:
- Smallest complete flow:
- Out of scope:

## Runtime boundary

- Official repository path:
- Final-round project path under `chung-khao/`:
- Start command:
- Test command:
- Build command:
- Deploy target:

## Interface

### Inputs

| Name | Type | Required | Validation |
|---|---|---:|---|

### Outputs

| Name | Type | Meaning |
|---|---|---|

### API or module contract

```text
method/path/function:
request:
response:
error states:
```

## Shared states

- Loading:
- Empty:
- Success:
- Recoverable error:
- Blocking error:

## Pre-implementation lock

- Brief: CONFIRMED / BLOCKED
- Architecture Lavish: LOCKED_BY_USER / BLOCKED
- UX Flow Lavish: LOCKED_BY_USER / BLOCKED
- Project contract: LOCKED / BLOCKED
- `implementation-gate.ps1`: IMPLEMENTATION ALLOWED / BLOCKED

## Ownership

| Lane | Paths owned | Must not edit | Acceptance command |
|---|---|---|---|
| Lane A: highest-value independent subsystem | | Lane B paths | |
| Lane B: second independent subsystem | | Lane A paths | |
| Captain integration | Integration-only paths | Locked decisions without user approval | |
| Read-only reviewer | None | All source | |

## Merge order

1. Both lanes start from exact `LOCK_BASE_SHA` and deliver their canary contribution.
2. Captain runs the minute 40-50 real integration canary.
3. If it fails, freeze scope and repair the same slice; if it passes, lanes continue.
4. Captain integrates verified commits and resolves only contract-conformant conflicts.
5. Captain runs real end-to-end behavior and fixed-point review.

## Acceptance evidence

- Functional:
- Tests:
- Runtime:
- Deployment:
- AI Log:
- Spend:
- Submission:
