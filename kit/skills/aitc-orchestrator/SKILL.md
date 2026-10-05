---
name: aitc-orchestrator
description: Operate NAVIN Research's BTC-only competition workflow: secure bootstrap, Codex/Orca runtime refresh, Gateway and AI Log gates, isolated visible workers, evidence-based integration, budget routing, and fail-closed submission.
---

# AITC Orchestrator

Use only for NAVIN Research AITC preparation or the official timed session. Live organizer instructions and current official BTC documentation override repository policy and this skill.

## Non-negotiable safety

- Never expose, prompt, commit, screenshot, or print secrets.
- During the timed session use BTC-authorized models/resources only.
- Never disable, fabricate, prune, edit, or bypass required AI logs.
- Never claim Gateway, logging, Git, CI, tests, deployment, or submission without direct evidence.
- One writer per checkout; concurrent writers use isolated Orca-managed worktrees.
- Account/model labels are not provider proof; use rollout metadata.

## Start-of-session sequence

1. Read live challenge, deadline, allowed resources, and submission channel.
2. Run `bootstrap.ps1` without passing secrets on the command line.
3. Run `preflight.ps1`; Gateway `/key/info` must return 200 and team must not be blocked.
4. Run the smallest `codex-canary.ps1`.
5. Require rollout `session_meta.model_provider=thucchien`.
6. Require local `UserPromptSubmit` and `Stop`, submit status 202, and BTC readback for the same session.
7. Run Orca preflight and capture exact worktree/terminal identities.
8. Record redacted team spend and budget state.

Primary implementation is `BLOCKED` until mandatory gates pass.

## Codex runtime

Orca must launch:

```text
C:\Users\hoang\.codex\codex-orca.cmd
```

with empty Orca Arguments. The wrapper pins `CODEX_HOME`, refreshes catalog caches and restarts the managed app-server only when the atomic provider/model/catalog fingerprint changes. Never call direct `codex` from an Orca-inherited shell when its `CODEX_HOME` is unknown.

Switch `model`, `model_provider`, `model_catalog_json`, and `forced_login_method` together. `thucchien` is valid competition transport; `commandcode` is preparation simulation only.

## Worker orchestration

Use at most three independent lanes. Freeze contracts first. Each brief includes `OUTCOME`, `OWN`, `DO_NOT_TOUCH`, `ACCEPTANCE`, `VERIFY`, `RETURN`, `MAX_SPEND / MODEL TIER`, and runtime restrictions.

Use visible terminal handoff while supervised `worker-start` fails at `agent_readiness`. Require a `turn_started` receipt, then poll with `orca terminal read --cursor <nextCursor>`. `tui-idle` is not completion evidence.

The Captain independently verifies rollout provider, diff, tests/build, runtime path, local/server logs, commit, and Git status before integration.

## Routing and budget

Use deterministic T0 work before models. Start with the cheapest canary-proven model and escalate only for repeated capability failure, reviewer rejection, missing capability, worse retry economics, or a scoring-critical blocker. Never model-hop for code, Git, workspace, hook, test, or policy failures.

At $35 require leader review, at $42 enter economy mode, at $45 block nonessential calls, and at the organizer cap stop.

## Failure handling

- 400: inspect endpoint/schema/model compatibility.
- 401/403: stop and verify key/team permission without exposing secrets.
- 429: inspect shared budget/RPM/TPM and reduce concurrency/context.
- 5xx/timeout: at most two bounded idempotent retries.
- Hook failure, submit not 202, or missing readback: stop model work and repair logging.

## Completion

Use exact statuses `VERIFIED`, `UNVERIFIED`, `CI UNAVAILABLE`, `BLOCKED`, and `USER ACTION REQUIRED`. Report files, commands/results, session/provider evidence, local/server AI Log evidence, branch/SHA/status, budget, residual risks, and submission receipt state.
