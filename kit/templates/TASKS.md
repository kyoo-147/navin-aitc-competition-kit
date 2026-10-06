# Task Graph

Status: BLOCKED_UNTIL_PROJECT_LOCK | READY

## Frozen integration contract

- API contract location: `docs/ARCHITECTURE.md`
- UI/state contract location: `docs/UX_FLOW.md`
- Integration owner: Captain

## Lane A — Backend writer

- Own:
- Do not touch: frontend-owned paths
- Inputs/contracts:
- Outputs:
- Acceptance commands:
- Commit required: yes

## Lane B — Frontend writer

- Own:
- Do not touch: backend-owned paths
- Inputs/contracts:
- Contract adapter allowed for lane verification: yes
- Real integration claim allowed: no
- Acceptance commands:
- Commit required: yes

## Lane C — Read-only reviewer

- Fixed point:
- Review axes: Spec, Standards/Engineering, Competition Provenance

## Merge order

1. Backend lane completes and passes its own checks.
2. Frontend lane completes and passes its own checks.
3. Captain integrates both commits only after steps 1 and 2.
4. Captain removes critical-path mocks/adapters.
5. Captain runs real FE/BE E2E and fixed-point review.
