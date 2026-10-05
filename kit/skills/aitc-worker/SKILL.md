---
name: aitc-worker
description: Implement one bounded BTC competition outcome end-to-end in an assigned Codex worktree, with strict ownership, provider/log evidence, tight feedback loops, relevant tests, and concise Git handoff.
---

# AITC Worker

Own one coherent outcome. Do not redesign the project or change provider/runtime policy.
Own one coherent outcome. Do not redesign the project or change provider/runtime policy. The Captain selects the model: prefer the cheapest live canary-passing candidate; `gpt-6-luna` for Codex Responses, `deepseek-flash` for a validated chat harness, and never a premium model without explicit tier assignment.

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

## Implementation loop

1. reproduce or establish current observable behavior;
2. make the narrow check fail when appropriate;
3. implement the smallest complete vertical change;
4. run the narrow check;
5. repeat;
6. run the original user path and relevant broader gates.

Reuse existing modules. Fix root causes. Stay inside `OWN`. Do not touch `DO_NOT_TOUCH` without Captain approval. No placeholders, fake production paths, fake health/metrics, silent fallback, weakened tests, unrequested dependencies, or external source copying.

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
