# Task Graph

Status: BLOCKED_UNTIL_PROJECT_LOCK | READY

## Frozen integration contract

- Boundary contract: `contracts/app-contract.json`
- Product/design contracts: `docs/PROJECT_CONTRACT.json` and conditional `design/`
- Integration owner: Captain
- ProjectRelativeRoot: `chung-khao` in OFFICIAL, `.` in DRILL

## Lane A — highest-value independent subsystem

- Outcome:
- Why highest-value:
- Own:
- Do not touch: Lane B paths
- Inputs/contracts:
- Canary contribution:
- Acceptance commands:
- Commit required: yes

## Lane B — second independent subsystem

- Outcome:
- Why independent:
- Own:
- Do not touch: Lane A paths
- Inputs/contracts:
- Canary contribution:
- Acceptance commands:
- Commit required: yes

## Lane C — read-only reviewer

- Fixed point:
- Review axes: Spec, Standards/Engineering, Competition Provenance
- Design review when applicable: P0/P1/P2 only; no redesign

## Integration order

1. Start Lane A and Lane B from exact `LOCK_BASE_SHA`.
2. Around minute 40-50, integrate the smallest real UI -> route/service -> BTC API when required -> real result -> render slice.
3. On failure, freeze new scope and repair that slice.
4. On pass, lanes continue remaining independent work.
5. Captain integrates verified commits, removes critical-path adapters, and runs real E2E.
