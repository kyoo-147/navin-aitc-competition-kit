# Local Competition Knowledge Base

This directory is a dated, queryable snapshot for model routing and spend decisions. Live BTC documentation, `/key/info`, `/team/info`, response headers, and canaries override every local value.

## Files

| File | Purpose |
|---|---|
| `model-registry.json` | Models, endpoints, prices, reasoning/search capability, Codex Responses compatibility. |
| `routing-policy.json` | Task tiers, default ceiling, budget gates, escalation rules. |
| `tracking-schema.json` | Required run ledger fields and operational tables. |

## Critical transport rule

Codex uses the Responses API. BTC OpenAI text models support `/responses`; BTC DeepSeek and Gemini workflows documented here use `/chat/completions`, so they are not Codex worker candidates unless a separately validated chat-completions harness is used.

Google Search is allowed through BTC only:

- OpenAI text models: `web_search` on BTC `/responses`.
- Gemini: `googleSearch` on BTC `/chat/completions`; not the Codex Responses transport.
- DeepSeek: unsupported.

## Default policy

- `$50` simulated or live team cap, governed by total-spend thresholds rather than phase envelopes.
- Start with T0 deterministic work or the cheapest live T1 candidate.
- Benchmark `gpt-6-luna`, `deepseek-flash`, and Gemini Flash Lite when the key is available.
- Prefer `gpt-6-luna` for Codex Responses; use DeepSeek only through a validated chat harness.
- Use `gpt-5.6-luna`/DeepSeek V4 Pro for harder integration and cap final review at `gpt-5.6-sol`.

## Query

```powershell
pwsh -File .\scripts\model-query.ps1 -Task codex_routine
pwsh -File .\scripts\model-query.ps1 -Model gpt-6-luna
pwsh -File .\scripts\model-query.ps1 -Task web_research_codex -CodexOnly
```

## Tracking

Initialize a simulation ledger and append measured records:

```powershell
pwsh -File .\scripts\spend-ledger.ps1 -Action Init -LedgerPath .\evidence\drill-ledger.jsonl -BudgetUsd 50
pwsh -File .\scripts\spend-ledger.ps1 -Action Status -LedgerPath .\evidence\drill-ledger.jsonl -BudgetUsd 50
```

Never label estimated spend as live BTC spend. Use `SIMULATED_ROUTING_NON_BTC_TRANSPORT` when the BTC gateway was not the actual transport.
