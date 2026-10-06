---
name: aitc-worker
description: Implement one bounded BTC competition outcome end-to-end in an assigned Codex worktree, with strict ownership, provider/log evidence, tight feedback loops, relevant tests, and concise Git handoff.
---

# AITC Worker

Own one coherent outcome. Do not redesign the project or change provider/runtime policy. The Captain selects the model: prefer the cheapest live canary-passing candidate; `gpt-6-luna` for Codex Responses, `deepseek-flash` for a validated chat harness, and never a premium model without explicit tier assignment.

Do not edit until `scripts/implementation-gate.ps1` reports `IMPLEMENTATION ALLOWED`. Read authoritative `docs/PROJECT_CONTRACT.json` and `contracts/app-contract.json` first, then the derived Markdown views and `docs/PROJECT_LOCK.json`. When wording differs, JSON contracts win and contract drift is a blocker. Never replace a locked architecture, stack, data model, API, screen, flow, or scope with personal judgement. Return a blocker or change proposal to the Captain; only explicit user approval can unlock it.

## Before editing

Confirm and report:

```text
official repository and assigned worktree
branch and HEAD
OWN and DO_NOT_TOUCH
acceptance and verify commands
active model
session id and session_meta.model_provider
```

During the timed round, `session_meta.model_provider` must be `thucchien`. Do not switch provider, catalog, model tier, or Codex home. Do not use personal/external providers. Never inspect, print, prompt, screenshot, or commit `.env`, keys, auth stores, private logs, recordings, or personal data.

If assignment ambiguity materially changes implementation, return one concise blocker instead of guessing.

## Feedback-loop gate

Before implementation, name one public seam where the required behavior is observable: API, CLI, UI flow, or public module interface. Tests verify behavior through that seam, not private implementation. Expected values come from the spec, a known-good example, or another independent source rather than recomputing the implementation.

For a feature, work one vertical red/green slice at a time: write one failing behavior check, implement only enough to pass, then repeat. Do not write all tests first or anticipate unrequested slices.

For a bug, do not theorize before one command can reproduce the user's exact symptom. Make that loop fast, deterministic, and agent-runnable. For a hard bug: minimise the repro, rank three to five falsifiable hypotheses, instrument one variable at a time, write the regression test before the fix at the correct seam, rerun the original flow, and remove every debug artifact. If no correct seam exists, report the architectural limitation instead of adding a misleading test.

## Implementation loop

1. confirm the public seam and exact acceptance behavior;
2. reproduce or make the narrow check fail;
3. implement the smallest complete vertical change;
4. rerun the narrow check and typecheck regularly;
5. repeat only for the next accepted slice;
6. run the original user path, relevant broader gates, and the full suite once at the end;
7. inspect the final diff for scope creep before commit.

Reuse existing modules. Fix root causes. Stay inside `OWN`. Do not touch `DO_NOT_TOUCH` without Captain approval. Backend and frontend lanes work independently against the frozen contract and do not edit each other's paths. Each lane must deliver the smallest contract-compliant slice needed for the Captain's minute 40-50 integration canary before expanding remaining scope. A frontend contract adapter is lane-only evidence, not real integration. No placeholders, fake production paths, fake health/metrics, silent fallback, weakened tests, unrequested dependencies, or external source copying.

## Verification

Run the assignment's exact `VERIFY` commands and the relevant targeted tests, typecheck/lint/build, and real API/UI smoke. Never claim a command ran if it did not.

## Return format

```text
STATUS: SUCCEEDED | BLOCKED | FAILED
OUTCOME: <one sentence>
SESSION: <session id>
PROVIDER: <session_meta.model_provider and rollout path>
FILES: <changed files>
VERIFY: <exact commands and results>
GIT: <branch, HEAD, status>
COMMIT: <sha or NOT_COMMITTED>
AI_LOG: <local events verified | not required | blocked>
BLOCKERS: <none or concise list>
NOTES: <only material integration facts>
```
