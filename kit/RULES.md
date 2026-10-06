# Competition Rules

## Authority order

1. Live organizer challenge instructions.
2. Current BTC documentation and organizer repository files.
3. Team leader decisions.
4. This kit.
5. Dated snapshots and preparation notes.

Stop and ask the leader when sources conflict.

## Session mode gate

- Before analyzing, editing, dispatching, or implementing a new challenge, ask: `Anh đang thi chính thức hay drill/chuẩn bị?`
- Do not infer official mode from the directory, date, key, or user urgency.
- In `OFFICIAL` mode, work only in `https://github.com/ai-thuc-chien/aitc2026-team-918-navin-research` and its verified local clone. All source, planning files, Lavish artifacts, evidence, and deliverables belong under `chung-khao/`; organizer hooks/config remain at repository root.
- In `DRILL` mode, label provider and evidence truthfully and never present the result as official competition work.

## Research and content provenance

- For open-ended or fact-sensitive challenges, Captain researches current facts before content lock using normal search/browser access and official, government, or reputable sources; cross-check material claims and preserve URLs/retrieval dates.
- Research gathers FACTS only. BTC models may transform/generate product content afterward.
- Do not use ChatGPT/Gemini/Claude web, external AI generators/APIs, or copied Internet code/templates. Live BTC rules always have highest priority.

## Pre-implementation lock

Implementation is forbidden until all gates are true:

```text
BRIEF = CONFIRMED
ARCHITECTURE_LAVISH = LOCKED_BY_USER
UX_FLOW_LAVISH = LOCKED_BY_USER
PROJECT_CONTRACT = LOCKED
```

- The Spec Broker compiles the challenge into structured requirements but must not choose architecture or UX for the user.
- Exactly two user-reviewable Lavish artifacts are mandatory before implementation: Architecture and UX / Design / Experience Flow.
- UI projects additionally require the internal `aitc-design-studio` pipeline: Design Brief, 2-3 directions, human choice, interactive prototype, independent P0/P1/P2 critique, and `DESIGN_LOCK`. CLI-only projects set `screens.design_lock_required=false` and skip it.
- Architecture Lavish covers stack, components, backend, database, schema, API contract, AI calls, state ownership, auth, deployment, dependencies, failure paths, alternatives, recommendation, and open decisions.
- UX Lavish is an interactive HTML wireframe covering screen map, journeys, actions, navigation, empty/loading/error/success states, responsive behavior, necessary features, and removable scope.
- The Captain must poll and incorporate user feedback. A generated HTML file without user review is not locked.
- During AITC work, Lavish uses the preinstalled pinned `lavish-axi` executable only. Do not invoke `npx`, cloud share/publish, remote assets, Tailwind CDN, Google Fonts, or remote JavaScript. Artifacts use local HTML, inline/local CSS and JavaScript, system fonts, and local SVG only.
- After approval, compile the authoritative `docs/PROJECT_CONTRACT.json`, `contracts/app-contract.json`, and, for UI, the `design/` contracts. Generate the human-readable views. Commit every Human Lock file, then run `lock-project.ps1`; `docs/PROJECT_LOCK.json` records the exact `LOCK_BASE_SHA` and hashes all required contracts, design files, views, and both Lavish artifacts.
- Workers resolve ambiguity from the canonical JSON contracts. Markdown never overrides the canonical or boundary contract.
- Run `scripts/implementation-gate.ps1`. It must verify locked files are tracked, clean relative to `LOCK_BASE_SHA`, and output `IMPLEMENTATION ALLOWED` plus `LOCK_BASE_SHA=<sha>` before execution.
- Locked decisions are immutable to workers. Changes require explicit user approval, updated artifacts/docs, a new lock timestamp, and notification to every affected lane.

## Official repository

- Run AI tools from the official team repository root.
- Put all final-round source, documentation, demo assets, and deliverables under `chung-khao/`.
- Keep organizer-provided root hook/config files where BTC placed them.
- Do not edit preparation or upstream repositories as a substitute for official delivery.
- Normal team work uses branch, PR, human review, and merge unless the organizer explicitly requires another flow.

## Providers and credentials

- During the timed round, all model calls use BTC Gateway only.
- No personal OpenAI, Gemini, Navin Gateway, or free-provider fallback.
- `THUCCHIEN_API_KEY` is the Gateway variable used by Codex.
- `AI_LOG_API_KEY` and `AI_LOG_SERVER` are the BTC logging variables.
- Never print, commit, prompt, screenshot, or copy secret values into artifacts.
- Treat a pasted or logged secret as exposed and ask the leader whether BTC requires rotation.

## AI logging

- AI Log is fail-closed for model work.
- Preserve required Codex events: `UserPromptSubmit`, `PostToolUse`, and `Stop`.
- Do not hand-edit `.ai-log/`, synthesize events, remove required events, alter timestamps, or submit another team's logs.
- A local file or successful Git push is not server proof. The final sequence is push, submit AI Log, require status `202`, then confirm same-session entries through the BTC readback API.
- Open the AI tool at official repository root because hooks can be skipped from a subdirectory.

## Routing and spend

- Live `/key/info`, `/team/info?team_id=...`, current pricing, and a task-relevant canary override snapshots.
- Do not infer quality or tool reliability from model name or price.
- Default budget gates: leader review at `$35`, economy mode at `$42`, block nonessential calls at `$45`, absolute organizer cap `$50`.
- Premium models and emergency reserve require leader approval.
- Escalate only after verified failure, reviewer rejection, missing capability, or worse retry economics.

## Execution

- Start with the smallest working vertical slice.
- Use deterministic software for deterministic work.
- Lock the canonical project contract and application boundary contract before parallel work.
- After lock, create every Lane A/B Orca worktree from the exact `LOCK_BASE_SHA`; run `writer-preflight.ps1` before model work. Lane A owns the highest-value independent subsystem and Lane B the second independent subsystem, selected from the locked architecture; roles are never hardcoded to backend/frontend.
- Around minute 40-50, the Captain integrates one smallest real vertical slice: real UI to real backend endpoint to real AI/API when required to real response rendered by the UI. Failure freezes new scope until the same slice passes.
- After the early canary, writers continue their remaining independent scopes. The Captain later performs full integration, removes critical-path adapters/mocks, and proves real full-product E2E.
- In AITC profile, bootstrap exposes only `aitc-captain`, `aitc-worker`, `aitc-reviewer`, `aitc-design-studio`, `lavish`, and on-demand browser skills. Other task skills remain repository references and are not runtime policy.
- Lock live API resources, required modalities, generation policy, and media counts before implementation. Use structured generation, prompt-hash reuse, one transient retry maximum, no blind 4xx retry, and stop on quota/budget exhaustion.
- If mandatory, start video after validated structured content as early as practical and poll within live API limits while independent work continues.
- Use one writer per checkout or isolated worktree.
- Use one to three workers by default and only for independent scopes.
- Keep humans responsible for consequential actions, review, merge, deployment, and submission.
- Do not add fake data, fake health, fake metrics, placeholder production paths, or silent fallback.

## Browser automation safety

- Browser work defaults to an isolated automation profile. The user's personal Chrome, signed-in profile, tabs, cookies, extensions, history, and saved data are out of scope.
- `chrome-devtools-axi` may be installed as an on-demand skill, but auto-connect, browser URL attachment, and SessionStart hooks remain disabled.
- Never attach to, restart, close, or relaunch the user's Chrome unless the leader explicitly authorizes that exact session after the Captain explains why isolated browsing is insufficient.
- A failed attach is a hard stop. Do not retry, recreate the bridge, or restart Chrome automatically.
- Official browser evidence must be produced from the official repository workflow, saved under `chung-khao/`, scrubbed of secrets/personal data, and labeled with the tested commit and command.
- Stop isolated browser processes after verification. Do not leave background bridges or automation listeners running.

## Evidence

- Inspect diffs, tests, runtime behavior, logs, deployment, and artifacts.
- If hosted Actions cannot start, report `CI UNAVAILABLE`; local checks are not hosted CI.
- A URL or HTTP 200 alone is not deployment proof.
- Do not claim submission complete without a visible `Đã nộp` state or receipt.
