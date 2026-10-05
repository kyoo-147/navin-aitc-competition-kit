# Model Routing and Spend Policy

The queryable local snapshot lives in `knowledge/`. Use `scripts/model-query.ps1` for routing decisions and `scripts/spend-ledger.ps1` for measured run accounting.

## Codex transport boundary

Switch `model`, `model_provider`, `model_catalog_json`, and `forced_login_method` as one unit. The `/model` picker lists whatever the active catalog contains while the transport comes from the active provider; mixing them offers model IDs the endpoint may not serve and fails only at request time. A picker label is not proof of which provider served a request - read the worker session's `session_meta.model_provider`.

Launch through `codex-orca.cmd`. Its runtime fingerprint prevents stale picker caches while avoiding an app-server restart for every same-preset worker. A provider/catalog change restarts the managed daemon once; subsequent workers reuse the current preset without interrupting active sessions.

Codex uses the Responses API. For BTC Codex workers, the default ceiling is `gpt-6-luna` with `none` or `low` reasoning. BTC DeepSeek and Gemini coding/research routes documented in this kit use `/chat/completions`; do not select them for a Codex Responses worker without a separate canary-proven chat harness.

Google Search remains inside BTC:

- OpenAI text models use `web_search` on BTC `/responses`.
- Gemini uses `googleSearch` on BTC `/chat/completions`, outside the Codex Responses worker path.
- DeepSeek does not support web search.

Live BTC documentation, `/key/info`, `/team/info?team_id=...`, current pricing, and task-relevant canaries are authoritative. `config/routing.json` is dated guidance, not a runtime allowlist.

## Rule

Use the cheapest live model that reliably completes the task. Escalate from evidence, not model reputation.

| Tier | Work | Action |
|---|---|---|
| T0 | grep, formatting, validation, tests, deterministic scripts | no model call |
| T1 | routine implementation and clear fixes | cheapest canary-passing candidate |
| T2 | multi-file integration and substantive review | strongest benchmarked general candidate |
| T3 | security, concurrency, architecture blocker | reasoning/pro tier with captain approval |
| Emergency | deployment, submission, or scoring-critical blocker | leader-approved model and reserve |

Candidate names in `config/routing.json` came from supplied preparation material. A name appearing there does not prove availability, price, quality, or tool compatibility.

## Day-of canary

Test only candidates relevant to the current task. Keep each canary small and record:

- success or failure;
- latency;
- Responses/tool compatibility;
- answer quality for the role;
- approximate spend when available.

Do not turn benchmarking into a project.

## Escalation gate

Escalate only when one is true:

- two bounded attempts fail for the same model-capability reason;
- an independent reviewer rejects substantive correctness;
- a required capability is missing;
- retries now cost more than a stronger model;
- the blocker threatens deployment, submission, or a scoring-critical path.

Do not model-hop for code, test, workspace, policy, or Git failures.

## Spend gates

Read team spend from `team_info`, not one key's `info.spend`.

- below `$35`: normal, avoid waste;
- `$35` or more: leader review;
- `$42` or more: economy mode;
- `$45` or more: block nonessential calls;
- `$50` or live `max_budget`: stop.

Premium calls and the emergency reserve always require leader approval.

## Context

Use short worker briefs and repository paths instead of repeatedly pasting large source blocks. Never include keys, `.env`, private AI logs, or personal data in context.
