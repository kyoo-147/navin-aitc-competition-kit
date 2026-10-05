---
name: aitc-orchestrator
description: Operate NAVIN Research's AITC competition workflow: secure key bootstrap, Gateway and AI Log preflight, budget-aware model routing, isolated member work, evidence review, and fail-closed submission preparation.
---

# AITC Orchestrator

Use this skill only for the NAVIN Research AITC preparation or official timed session.

## Authority order

1. Live challenge package and instructions from BTC.
2. Current official BTC documentation.
3. Repository rules and machine-readable policy under `config/competition/`.
4. This skill.

If sources conflict, stop and report the conflict. Never silently choose the more convenient rule.

## Non-negotiable safety

- Never read a secret aloud, print it, put it in a prompt, commit it, or include it in screenshots.
- Treat any key pasted into chat or command history as exposed; ask whether BTC requires rotation.
- Use only BTC-authorized tools, models, resources, and people during the timed session.
- Never disable, alter, fabricate, prune, or bypass required AI logs.
- Never claim Gateway, AI Log, Git, CI, tests, or submission succeeded without direct evidence.
- One real member identity per fixed clone. One writer per checkout.
- Normal integration is member branch to PR to real review to leader merge. Direct `main` is allowed only when a live BTC instruction explicitly requires it.

## Start-of-session sequence

1. Read the live challenge and deadline. Record any changes from the stored rules.
2. Refresh official documentation if external access is permitted.
3. Run the secure bootstrap. Secrets must enter through an interactive prompt or an ignored local environment file, never command-line arguments.
4. Run the preflight gates:
   - repository root, expected remote, member Git identity, branch, and status;
   - required hook exists, is executable where applicable, and has valid encoding;
   - Gateway `/key/info` returns HTTP 200;
   - an allowed low-cost model completes one minimal canary request;
   - AI Log submission returns 202 and a server read confirms the new entry;
   - team spend and available model list are captured in a redacted report.
5. Do not begin primary implementation until all mandatory gates pass or the leader records an explicit `BLOCKED` state.

## Task orchestration

For every task, record:

- owner and fixed workspace;
- exact writable paths;
- acceptance checks;
- initial model tier;
- maximum task spend;
- dependencies and merge order;
- evidence required for completion.

Parallelize only independent scopes. Do not run concurrent writers in one checkout.

## Model routing

Use deterministic tools before models.

- **T0**: search, formatting, tests, lint, build, scripts. No model call.
- **T1**: routine coding, extraction, documentation, clear bug fixes. Start with the cheapest canary-proven model.
- **T2**: cross-file design, ambiguous bugs, standard review. Use the best value model from the current mini-benchmark.
- **T3**: architecture, security, concurrency, difficult root cause. Require failure evidence and a compact context packet.
- **T4**: premium emergency tier for a score-critical blocker. Leader approval and a per-request cap are mandatory.

Escalate only when one of these is true:

- two bounded attempts fail with the same verified defect;
- a reviewer rejects the result with reproducible evidence;
- the task requires a capability absent from the current tier;
- the expected cost of another cheap attempt exceeds one stronger attempt.

Never infer capability from model name or price. On competition day, rebuild the allowlist from `/key/info` and a tiny task-relevant benchmark.

## Budget policy

Load `config/competition/budget-policy.json`. Default envelope for a USD 50 team budget:

- discovery and benchmark: USD 4;
- main build: USD 20;
- review and hard reasoning: USD 10;
- multimodal or media: USD 6 only if required;
- final QA and repair: USD 5;
- emergency reserve: USD 5.

At USD 35, leader reviews remaining work. At USD 42, enter economy mode. At USD 45, block all nonessential model calls. Reserve and T4 require leader approval.

## Failure handling

- **400**: inspect model and payload compatibility; do not rotate keys.
- **401/403**: stop, verify endpoint/key/permission without printing secrets, then contact BTC if unresolved.
- **429**: inspect shared RPM, TPM, and spend; reduce concurrency/context and use jittered backoff.
- **5xx/timeout**: at most two bounded retries for idempotent calls, then use a same-tier fallback or report `BLOCKED`.
- **AI Log not 202 or entry not visible**: stop model work and repair logging before continuing.

## Completion report

Use exact statuses: `VERIFIED`, `UNVERIFIED`, `CI UNAVAILABLE`, `BLOCKED`, and `USER ACTION REQUIRED`.

Report changed files, tests/commands, Git branch and SHA, budget used if known, evidence paths, residual risks, and the next action. A worker message alone is not evidence.
