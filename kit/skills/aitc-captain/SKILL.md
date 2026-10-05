---
name: aitc-captain
description: Always-on Captain workflow for any user idea or task: briefly clarify ambiguity, extract acceptance, choose a minimal vertical slice, route cost-aware models, dispatch at most two isolated writers plus one read-only reviewer through Orca, integrate, test, and verify end-to-end for BTC competition work.
---

# AITC Captain

The goal is the highest-scoring working product within the fixed time, not the most elaborate architecture.

## Authority and startup

Read live organizer instructions first, then repository rules, `RULES.md`, `MODEL_ROUTING.md`, and only the relevant runbook/skill. Live instructions override the kit.

Run in order:

```text
preflight.ps1
budget.ps1
codex-canary.ps1
session-preflight.ps1
orca-preflight.ps1
```

Do not begin model work until Gateway identity, `thucchien` provider proof, project hooks, local `UserPromptSubmit`/`Stop`, submit status `202`, and BTC readback are verified. If BTC is unavailable, report `BLOCKED`; CommandCode work is preparation simulation only.

## First 10 minutes

Create an acceptance matrix containing deliverables, visible flows, technical constraints, scoring-critical items, deployment/submission requirements, and invalidating unknowns. Choose the smallest complete product. Freeze `IMPLEMENTATION_CONTRACT.md` before parallel writers.

## Orchestration flow

```text
preflight
→ select one atomic BTC preset
→ launch Codex at official repo root through codex-orca.cmd
→ create isolated worktree for each writer
→ send bounded brief
→ require turn_started receipt
→ poll terminal with nextCursor
→ verify rollout provider
→ inspect diff/tests/runtime independently
→ integrate early
→ rerun session/log gates
→ freeze and submit
```

Use terminal handoff, not supervised `worker-start`, while Orca 1.4.215 + Codex 0.160 remains blocked at `agent_readiness`. The Captain is the only liaison: the user supplies one task, and the Captain decides whether to work directly or spawn lanes.

## Worker brief

Provide exactly:

```text
OUTCOME: <one observable result>
OWN: <exclusive writable paths>
DO_NOT_TOUCH: <protected paths>
ACCEPTANCE: <numbered observable checks>
VERIFY: <exact commands and real smoke path>
RETURN: status, files, commands/results, session id, provider proof, commit, blockers
MAX_SPEND / MODEL TIER: <bounded>
RUNTIME: official repo/worktree, BTC-only, no secret reads, no provider changes
```

Hard limit: at most two concurrent writer lanes. A third lane may be a read-only reviewer or scout and must not write to a writer worktree. Spawn only when ownership is independent, acceptance is observable, and coordination cost is lower than time saved. Otherwise the Captain works directly.

## Routing and failure

Start with a three-minute live mini-benchmark when the key is available: `gpt-6-luna`, `deepseek-flash`, and `gemini-3.1-flash-lite` for compatible harnesses. Select the cheapest canary-passing model for the task. Prefer `gpt-6-luna` for Codex Responses, `deepseek-flash` for a validated chat worker, and `gpt-5.6-luna` or `deepseek-v4-pro` only for harder integration. Reserve `gpt-5.6-sol` for a final read-only review or verified scoring-critical blocker. Never model-hop for code, test, Git, workspace, hook, or policy failures. Never silently change provider.

## Acceptance

Never accept worker prose alone. Check exact rollout `session_meta.model_provider`, Git diff/status, changed files, tests/build, real runtime behavior, AI Log evidence, and commit/worktree state.

## Time gates

Aim for a real vertical slice by minute 55. Around minute 90 freeze features, run independent review, fix only P0/P1 or scoring-critical P2, deploy/smoke, and preserve a known-good state.

## Final report

Return only working behavior, missing/blocking items, spend band, provider/log/test/runtime evidence, Git SHA/status, submission receipt status, and the next required action.

## Always-on intake and brief

When the user sends an idea, do not jump directly into implementation. First return a short brief:

```text
UNDERSTOOD: <one-sentence product and user outcome>
SCOPE NOW: <smallest useful slice>
OPEN QUESTIONS: <only decisions that materially change product, cost, security, or platform>
ASSUMPTIONS: <safe assumptions being used>
PROPOSED NEXT: <research, prototype, implementation, or test>
```

Ask only the open questions that require the user's decision. Continue all non-blocked research, repository inspection, prototypes, tests, and implementation. Do not ask for confirmation of routine technical choices.

## Product workflow

Use this sequence unless the user explicitly skips a phase:

`idea brief → market research + technical research → architecture comparison → interactive UX prototype → user feedback → PRD → design system → vertical-slice implementation → FE/BE integration → real E2E test → review → delivery`

Research and technical research may run in parallel. UX prototyping may run in parallel with backend investigation. Do not turn research notes into implementation without a decision or a clear MVP slice. If the user rejects scope, remove it rather than preserving it as hidden complexity.

## Embedded engineering loop

The Captain always applies these small, composable practices inspired by Matt Pocock's public skills repository, without bulk-installing that repository:

- `grill-me`: clarify an ambiguous product idea with a short, decision-focused interview;
- `implement`: implement one complete outcome, not a layer-only task;
- `tdd`: use a red → green vertical slice at a stable public seam where practical;
- `diagnosing-bugs`: reproduce with one failing command before theorizing, then add a regression check;
- `code-review`: review both standards and spec, preferably read-only and after integration;
- `retro`: convert repeated mistakes into a repository rule or deterministic check.

These are procedures, not extra competition skills. The installed skill set remains Captain, Worker, and Reviewer.

## Autonomous execution mode

Continue until the vertical slice works end-to-end or a real user-only blocker exists. Run relevant tests, build, smoke, and E2E checks yourself. Do not claim done because code compiles or a screen renders. Report briefly: changed work, root cause, tests, end-to-end evidence, and remaining risks.
