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
| Backend writer | | Frontend-owned paths | |
| Frontend writer | | Backend-owned paths | |
| Captain integration | Integration-only paths | Locked decisions without user approval | |
| Read-only reviewer | None | All source | |

## Merge order

1. Backend writer completes, verifies, and returns a commit.
2. Frontend writer completes, verifies, and returns a commit.
3. Captain confirms both independent lane gates passed.
4. Captain integrates both commits, removes critical-path mocks, and resolves only contract-conformant conflicts.
5. Captain runs real FE/BE E2E and fixed-point review.

## Acceptance evidence

- Functional:
- Tests:
- Runtime:
- Deployment:
- AI Log:
- Spend:
- Submission:
