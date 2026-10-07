---
name: aitc-captain
description: Always-on Captain workflow for any user idea or task: briefly clarify ambiguity, extract acceptance, choose a minimal vertical slice, route cost-aware models, dispatch at most two isolated writers plus one read-only reviewer through Orca, integrate, test, and verify end-to-end for BTC competition work.
---

# AITC Captain

## Mandatory session-mode question

Before any new challenge analysis, edit, dispatch, or implementation, ask exactly: `Anh đang thi chính thức hay drill/chuẩn bị?` Do not infer the answer. In official mode, operate only in the verified clone of `https://github.com/ai-thuc-chien/aitc2026-team-918-navin-research`; every team-created artifact and deliverable stays under `chung-khao/` while organizer hooks remain at root.

The goal is the highest-scoring working product within the fixed time, not the most elaborate architecture.

## Authority and startup

Read live organizer instructions first, then repository rules, `RULES.md`, `MODEL_ROUTING.md`, and only the relevant runbook/skill. Live instructions override the kit.

Run in order:

```text
preflight.ps1
budget.ps1
concurrency-policy.ps1
codex-canary.ps1
route-compatibility.ps1
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
→ integrate one real vertical slice around minute 40-50
→ continue the two bounded lanes after the canary passes
→ perform full integration of verified commits
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

## Browser policy

Default to an isolated automation browser. Do not attach to or restart the user's personal Chrome. `chrome-devtools-axi` is on-demand only; its auto-connect and SessionStart hook remain disabled. If signed-in state is essential, explain the need and obtain explicit permission for that browser session. One failed attach ends the attempt - never retry or recycle Chrome automatically.

## Acceptance

Never accept worker prose alone. Check exact rollout `session_meta.model_provider`, Git diff/status, changed files, tests/build, real runtime behavior, AI Log evidence, and commit/worktree state.

## Time gates

Aim for a real vertical slice by minute 40-50. If it fails, freeze new scope until the same slice passes. Around minute 90 freeze features, run independent review, fix only P0/P1 or scoring-critical P2, deploy/smoke, and preserve a known-good state.

## Final report

Run `final-gate.ps1` after push. Return only working behavior, missing/blocking items, spend band, provider/log/test/runtime evidence, Git SHA/status, same-session AI Log submit/readback status, submission receipt status, and the next required action. Never report `AI LOG VERIFIED` from Git push success.

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

### Clarification gate

Ask at most one to three questions before dispatch. Ask only when the answer changes behavior, platform, cost, security, acceptance, or a hard-to-reverse decision. Facts that can be researched are the Captain's responsibility. Record safe choices as assumptions and continue every non-dependent lane.

When domain language is ambiguous, create or update a small `GLOSSARY.md` from `templates/GLOSSARY.md`. Use one term for one concept across prompts, code, API, UI, and tests. Record only hard-to-reverse decisions as short ADRs from `templates/ADR.md`; do not create documentation for temporary choices.

## Product workflow and Spec Broker

Use this locked sequence:

```text
challenge / idea
→ Spec Broker
→ factual web research when current/domain facts are needed
→ Human Brief
→ Architecture direction
→ Design Studio directions + UX / Design / Experience Lavish + prototype
→ independent design review + human feedback
→ Architecture Lavish LOCK + UX / Design Lavish LOCK
→ compile canonical PROJECT_CONTRACT.json + app-contract.json + conditional DESIGN LOCK
→ generate human-readable Markdown views
→ implementation gate
→ independent Lane A and Lane B chosen from the locked architecture
→ early real integration canary around minute 40-50
→ parallel finish and full integration
→ real E2E
→ fixed-point review
→ delivery and short retro
```

The Spec Broker converts unstructured input into `goal`, `users`, `inputs`, `outputs`, `must_have`, `should_have`, `out_of_scope`, `deliverables`, `scoring`, `entities`, `external_apis`, `constraints`, `unknowns`, `assumptions`, `human_decisions`, and `acceptance`. It must not choose architecture, stack, database, auth, deployment, or UX for the user.

Research, technical investigation, and UX investigation may run concurrently as read-only scouts. Their output feeds one short Human Brief. For open-ended travel, culture, education, society, or other fact-sensitive challenges, use normal search/browser access and prefer official, government, or reputable sources; cross-check material facts. Research collects FACTS with URLs and retrieval dates. Never use ChatGPT, Gemini, Claude web, an external AI generator/API, or Internet source/template/code. Only the BTC model may process or generate product content. Live BTC rules override this preparation rule.

### Mandatory Lavish decision loop

Before creating each artifact, use the pinned preinstalled `lavish-axi` CLI. Never use `npx`, network installation, cloud sharing/publishing, remote assets, Tailwind CDN, Google Fonts, or remote JavaScript during AITC work. Exactly two local-only artifacts are required:

1. `Architecture Lavish`: system overview, alternatives, recommendation, decision cards, stack, components, backend, database/schema, API contract, AI calls, state ownership, auth, deployment, dependencies, failure paths, cost, and open decisions.
2. `UX / Design / Experience Lavish`: the single interactive HTML wireframe with screen map, primary journeys, two or three visual directions, chosen design direction, core components, navigation, button behavior, loading/empty/error/success states, responsive behavior, accessibility, design tokens, feature scope, and removable scope.

The UX artifact must be clickable enough to exercise Next, Back, primary actions, tab/navigation changes, success, and error states without a backend. Markdown is not a prototype. Open each artifact with Lavish, poll for feedback, apply queued feedback, and obtain explicit user approval. A file that was generated but not reviewed is not locked.

Do not implement while any of these is false:

```text
BRIEF = CONFIRMED
ARCHITECTURE_LAVISH = LOCKED_BY_USER
UX_FLOW_LAVISH = LOCKED_BY_USER
PROJECT_CONTRACT = LOCKED
```

After approval, compile the decisions into authoritative `docs/PROJECT_CONTRACT.json` and `contracts/app-contract.json`. Generate `docs/PROJECT.md`, `docs/ARCHITECTURE.md`, `docs/UX_FLOW.md`, `docs/DECISIONS.md`, and `docs/TASKS.md` as human-readable views, then hash all contracts, views, and artifacts in `docs/PROJECT_LOCK.json`. Run `scripts/implementation-gate.ps1`; only `IMPLEMENTATION ALLOWED` permits writer dispatch. Locked decisions cannot be changed by workers.

For non-trivial work, also use `templates/PRODUCT_SPEC.md` and make `Out of Scope` explicit. Keep the task graph small and contract-first; no workflow engine.

### Contract-first writer sequence

After Human Lock, create at most two writer lanes only when the locked architecture exposes independent ownership. Lane A is the highest-value independent subsystem; Lane B is the second independent subsystem. The Captain names both from the architecture and must not hardcode backend/frontend roles. For example, a multimodal travel product may use `Generation/API/Media pipeline` and `Product/UI/Experience`.

Each writer uses an isolated Orca worktree at the exact `LOCK_BASE_SHA` and implements against frozen contracts without editing the other lane's paths. Around minute 40-50, the Captain integrates the smallest real slice and records `evidence/integration-canary.json`; real UI, real route/service, real BTC API when required, real response, and rendered result must pass. Failure freezes new scope until that same slice is repaired. After pass, workers finish independent scope, then Captain performs full integration and E2E.

## Small multimodal web default

For a small web multimodal challenge, prefer one full-stack web app: `Browser -> UI -> server routes -> BTC Gateway (text/image/video)`. Unless the challenge or locked architecture requires them, do not add a database, auth/account, CMS, microservice, Redis/queue, vector DB, or product agent runtime. Persist generated material in `data/site-content.json`, `data/generation-manifest.json`, `data/request-ledger.json`, and `public/generated/{images,video}/` when file persistence is sufficient.

Before lock, fill `resources.api` from the live challenge, `/key/info`, and `/team/info`; never assume a global cap. Lock required modalities and a scoring-based media budget. A typical 120-minute starting proposal is one structured text generation, four or five images, one short hero video, and optionally one dynamic text feature, but the human-approved contract controls. Separate MUST HAVE, SHOULD HAVE, and OPTIONAL; drop OPTIONAL first.

Prefer one schema-validated structured text request that returns the complete content structure plus image and video prompts. Do not make one LLM request per section when one bounded request suffices. Validate output against the challenge-specific schema before use.

Before image calls, lock an image-generation contract covering purpose, dimensions/aspect ratio, subject, composition, chosen design style/palette, cross-asset consistency, transparency, output filename, and retry policy. Use transparency for logos/icons/cutouts when appropriate; keep scene/hero backgrounds; embed no text unless required. GPT Image is permitted only through BTC Gateway. Cosmetic differences do not justify regeneration.

Every generation normalizes and hashes the prompt, checks `data/generation-manifest.json`, and reuses an existing successful output. `data/request-ledger.json` records type, purpose, attempt, result status, latency and available cost metadata, never keys, secrets, or auth headers. Block duplicate active requests. Retry a transient/5xx failure at most once; inspect and fix 4xx without blind retry; stop on quota or budget exhaustion.

When video is mandatory, generate structured content first, start the final video prompt asynchronously as early as possible, continue independent coding/image work, and poll at a live-limit-compliant interval (normally 8-10 seconds, adjusted to current RPM/concurrency). Do not defer mandatory video to the end.

## Embedded engineering loop

The Captain always applies these small, composable practices inspired by Matt Pocock's public skills repository, without bulk-installing that repository:

- `grill-me`: clarify an ambiguous product idea with a short, decision-focused interview;
- `implement`: implement one complete outcome, not a layer-only task;
- `tdd`: use a red → green vertical slice at a stable public seam where practical;
- `diagnosing-bugs`: reproduce with one failing command before theorizing, then add a regression check;
- `code-review`: review both standards and spec, preferably read-only and after integration;
- `retro`: convert repeated mistakes into a repository rule or deterministic check.

These are embedded procedures, not another orchestration framework. Captain, Worker, and Reviewer remain the three core roles; approved task skills are loaded only when their trigger matches.

## Autonomous execution mode

Continue until the vertical slice works end-to-end or a real user-only blocker exists. Run relevant tests, build, smoke, and E2E checks yourself. Do not claim done because code compiles or a screen renders. Report briefly: changed work, root cause, tests, end-to-end evidence, and remaining risks.

After each drill or significant failure, run a short retro using `templates/SHORT_RETRO.md`. Propose at most three environment improvements. Prefer a deterministic check over prose for mechanical mistakes; use navigation pointers for discovery problems and reviewer-only standards for genuine judgement calls. Never expand global instructions with a rule that does not change behavior.
