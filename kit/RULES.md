# Competition Rules

## Authority order

1. Live organizer challenge instructions.
2. Current BTC documentation and organizer repository files.
3. Team leader decisions.
4. This kit.
5. Dated snapshots and preparation notes.

Stop and ask the leader when sources conflict.

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
- A local file is not server proof. Require successful submission status `202` and confirm entries through the BTC readback API.
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
- Lock the implementation contract before parallel frontend/backend work.
- Use one writer per checkout or isolated worktree.
- Use one to three workers by default and only for independent scopes.
- Keep humans responsible for consequential actions, review, merge, deployment, and submission.
- Do not add fake data, fake health, fake metrics, placeholder production paths, or silent fallback.

## Evidence

- Inspect diffs, tests, runtime behavior, logs, deployment, and artifacts.
- If hosted Actions cannot start, report `CI UNAVAILABLE`; local checks are not hosted CI.
- A URL or HTTP 200 alone is not deployment proof.
- Do not claim submission complete without a visible `Đã nộp` state or receipt.
