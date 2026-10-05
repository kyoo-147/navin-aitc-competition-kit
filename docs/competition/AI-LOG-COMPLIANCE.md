# AI Log Compliance

Source: https://docs.thucchien.ai/docs/round-2/ai-log-guide

Retrieved: 2026-10-03.

## Mandatory

- Round 2 AI work must record prompts, tool calls/results/errors, and required session/final events.
- Teams must use models through the BTC API Gateway during the competition.
- Logging requires an `origin` remote. Team identity comes from the private AI log token, not the repo/student fields.
- Required hook/config files live at repository root; open the agent at the repository root.
- Each clone must run `scripts/setup_hooks.*` once because `.git/hooks` is not committed.
- Push submission failure retains logs and must be investigated; HTTP 403 means the team's table is locked.

## Prohibited

Never manually delete/edit/add AI-log lines, omit events, disable hooks while working, falsify timestamps/events, alter prompt/output before sending, or submit another team's token/logs.

## Privacy

BTC receives raw prompts, commands, read/edited file content, outputs, errors, and responses. Therefore agents must never read/print secrets. `.env`, auth stores, SSH keys, credentials, private recordings, and personal data are out of scope.

## Preflight

```powershell
python --version
git remote -v
powershell -ExecutionPolicy Bypass -File scripts\setup_hooks.ps1
python scripts\submit_log.py
```

`python-dotenv` must be available for `.env` loading. A valid team token is still required and must be entered locally by a team member, never through chat.

## Codex session proof

For Codex, validate logging against the exact rollout session rather than checking only that `.ai-log/session.jsonl` exists:

1. open Codex at the official repository root through the canonical wrapper;
2. read rollout `session_meta.id` and require `session_meta.model_provider=thucchien`;
3. require local `UserPromptSubmit` and `Stop` entries with that same session ID;
4. run the organizer submit script and require HTTP `202`;
5. read BTC entries back and require the same session ID/events.

Global user hooks may coexist with project hooks. Bootstrap must preserve user hooks; competition log hooks remain project-local under the official repository `.codex/hooks.json`.
