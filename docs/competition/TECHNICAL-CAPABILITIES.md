# Technical Capabilities and Cost Controls

Sources:
- https://docs.thucchien.ai/docs/round-2/user-guide/introduction
- https://docs.thucchien.ai/docs/round-2/user-guide/core-concepts
- https://docs.thucchien.ai/docs/round-2/user-guide/openai-deepseek
- https://docs.thucchien.ai/docs/round-2/user-guide/pricing
- https://docs.thucchien.ai/docs/round-2/user-guide/google-search-grounding
- https://docs.thucchien.ai/docs/round-2/user-guide/video-generation-veo3

Retrieved: 2026-10-03. Model names/prices are drift-prone; refresh before use.

## Gateway

- Base endpoint: `https://api.thucchien.ai`; OpenAI-compatible routes commonly use `/v1`.
- Authentication: `Authorization: Bearer <API key>`.
- Keep keys only in environment variables/local `.env`; never commit or paste into an agent prompt.
- One gateway exposes text, image, video, TTS, STT, embeddings, moderation, and web search depending on model.

## Safe default routing

- Routine text: `gpt-6-luna`, `deepseek-flash`, or a permitted Flash model.
- Hard reasoning/refactor: escalate only after evidence; expensive models can consume budget rapidly.
- OpenAI reasoning models: prefer `max_completion_tokens`; use supported `reasoning_effort`; hidden reasoning tokens are billed as output.
- DeepSeek thinking is on by default; disable it for extraction/classification/rewrite when appropriate.
- Tool-using agents with modern OpenAI models should use Responses-compatible harnesses such as Codex; Chat Completions may fail during reasoning tool calls.

## Modalities

- Images: `/images/generations`; Gemini/Nano Banana uses `aspect_ratio`, one image/request and base64 output. OpenAI image models use `size` and `quality`.
- Video: asynchronous `POST /v1/videos` → poll `GET /v1/videos/{id}` → download `/content`. Start with lite, 4 seconds; video is billed when created even if never downloaded.
- Web search: Gemini uses `googleSearch` through Chat Completions; OpenAI uses `web_search` through Responses; DeepSeek does not support it. Search has an extra per-query/call charge.
- Budget: inspect `/key/info`, then `/team/info?team_id=...`; team budget/RPM/TPM are shared across keys.

## Cost policy

1. Check team spend before each expensive experiment.
2. Run one cheap representative request first.
3. Cache/reuse deterministic artifacts when rules allow.
4. Cap concurrency and implement bounded retries for 429s.
5. Record model, parameters, request count, latency, cost header, and artifact outcome in safe evidence—never the key.
