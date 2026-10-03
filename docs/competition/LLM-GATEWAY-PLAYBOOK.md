# LLM Gateway Playbook

A small, evidence-first playbook for text and LLM-agent work in Round 2. **FACT** statements below are limited to this repository's official-source summaries; **UNKNOWN** statements must be resolved from the live challenge package or refreshed official documentation.

## 1. Gateway boundary

**FACT** — Competition models must be called through the BTC API Gateway and AI work must be logged. The gateway base endpoint recorded here is `https://api.thucchien.ai`; OpenAI-compatible routes commonly use `/v1`. Authentication is `Authorization: Bearer <API key>`.

**FACT** — Keep keys only in environment variables/local `.env`; never commit or paste them into prompts. Never put keys in evidence: record the model, parameters, request count, latency, cost header, and artifact outcome instead.

**UNKNOWN** — The challenge package may restrict models, tools, packages, datasets, or routes beyond the current summaries. Confirm those limits before implementation.

Sources: [Introduction](https://docs.thucchien.ai/docs/round-2/user-guide/introduction), [Core concepts](https://docs.thucchien.ai/docs/round-2/user-guide/core-concepts), [AI Log guide](https://docs.thucchien.ai/docs/round-2/ai-log-guide).

## 2. Route by task, not by habit

1. **Routine text / extraction / rewrite (FACT):** start with `gpt-6-luna`, `deepseek-flash`, or another permitted Flash model. For DeepSeek, thinking is on by default; disable it for extraction, classification, or rewrite when appropriate.
2. **Hard reasoning / refactor (FACT):** escalate only after evidence that the cheaper route is insufficient; expensive models can consume budget rapidly.
3. **Tool-using agent (FACT):** use a modern OpenAI model with a Responses-compatible harness such as Codex. The technical summary warns that Chat Completions may fail during reasoning tool calls.
4. **Web search (FACT):** OpenAI uses `web_search` through Responses; Gemini uses `googleSearch` through Chat Completions; DeepSeek does not support web search. Search has an extra per-query/call charge.

**UNKNOWN** — The summaries do not establish a complete current model/parameter compatibility matrix, model availability guarantee, or challenge-specific default. Treat model names and prices as drift-prone and refresh before use.

## 3. Responses vs Chat Completions

- **FACT — Responses path:** the repository's technical summary identifies Responses as the path for OpenAI `web_search` and recommends Responses-compatible harnesses for modern OpenAI tool-using agents.
- **FACT — Chat Completions path:** the source registry lists a BTC Chat Completions text-generation API reference; the technical summary identifies Gemini `googleSearch` through Chat Completions.
- **FACT — selection rule:** choose the path supported by the selected model and tool call. Do not assume that a Chat Completions request can substitute for an agent's reasoning/tool-call path.
- **UNKNOWN:** exact request/response schemas, supported model list, tool-call lifecycle, and whether a particular model supports both APIs must be checked in the current official API reference before coding.

Keep an adapter boundary around the gateway client so routing, retries, spend evidence, and API-shape changes do not spread through product code.

## 4. Budget, latency, and retry loop

**FACT** — Team budget and RPM/TPM limits are shared across keys. Inspect `/key/info` and then `/team/info?team_id=...` before an expensive experiment. Video is not text work, but the recorded policy also shows that billing can occur at creation time; do not infer that an unconsumed artifact is free.

Recommended bounded loop:

1. Inspect spend and limits.
2. Send one cheap representative request.
3. Cap concurrency.
4. Retry 429s with a bounded retry count/backoff; stop rather than creating an unbounded spend loop.
5. Cache/reuse deterministic artifacts when rules allow.
6. Record model, parameters, request count, latency, cost header, and artifact outcome without recording the key.

**FACT** — For OpenAI reasoning models, prefer `max_completion_tokens` and use supported `reasoning_effort`; hidden reasoning tokens are billed as output.

**UNKNOWN** — Current prices, quotas, retry-after behavior, and exact token parameter support are not stable in this repository. Refresh the official pricing/API pages immediately before timed work.

Source: [Pricing](https://docs.thucchien.ai/docs/round-2/user-guide/pricing), [OpenAI and DeepSeek](https://docs.thucchien.ai/docs/round-2/user-guide/openai-deepseek), [Spend checking API](https://docs.thucchien.ai/docs/round-2/api-reference/spend-checking).

## 5. Agent-work checklist

- **FACT:** open the agent at repository root and preserve required AI-log events, including prompts, tool calls/results/errors, and required session/final events.
- **FACT:** never read, print, edit, delete, disable, or fabricate AI-log lines; never read or expose `.env`, auth stores, SSH keys, credentials, or personal data.
- **FACT:** keep calls through the BTC Gateway during competition work.
- **UNKNOWN:** exact challenge statement, allowed-resource list, deadline, submission path, and model/API allowances remain challenge-package decisions.

Before relying on any route, write down: selected model, API path (Responses or Chat Completions), tools, token budget, retry cap, and evidence fields. If any item is unsupported or unclear, label it **UNKNOWN** and stop that path until the official source resolves it.

## Source scope

This playbook uses only the repository's summaries and URLs in `docs/competition/SOURCE-REGISTER.md`, principally `TECHNICAL-CAPABILITIES.md`, `AI-LOG-COMPLIANCE.md`, `FACTS-INFERENCES-UNKNOWNS.md`, and `ROUND-2-RULES.md`. Retrieved dates in those files are **2026-10-03**; model names and prices must be refreshed before use.
