# Components

Status: LOCKED DERIVED VIEW

- `DecisionPanel`: one decision, rationale, evidence, approve/change action.
- `ContractBoard`: canonical authority flowing to derived views and lanes.
- `EvidenceState`: explicit VERIFIED, UNVERIFIED, BLOCKED, USER ACTION REQUIRED.
- `Timeline`: contest minute gates including early canary.
- `StatusTable`: rule, pass condition, failure action.
- `ApprovalForm`: human choice with a visible queued feedback receipt.
- `ResultState`: clear success, error, retry and next action.

Frontend workers implement these names only when the challenge contract requires them; they do not add a parallel design language.
