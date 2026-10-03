# Multimodal Generation and Evaluation Playbook

> **Scope:** a compact, auditable runbook for image, video, and audio work through the BTC Gateway. It uses only the repository's official-source registry and technical summaries. Refresh drift-prone model names and prices before use.

## Epistemic labels

- **FACT** — stated in the repository's official-source summaries or linked official documentation.
- **INFERENCE** — an operational recommendation derived from those facts; validate it against the live challenge rules.
- **UNKNOWN** — not established by the current source set; do not silently assume it.

## 1. Before generating

1. **FACT:** Use the BTC Gateway (`https://api.thucchien.ai`) with `Authorization: Bearer <API key>`; the gateway exposes modality capabilities depending on model. Keep the key in an environment variable or local `.env`, never in prompts or evidence.
2. **FACT:** Team budget and RPM/TPM limits are shared across keys. Check `/key/info` and then `/team/info?team_id=...` before an expensive experiment.
3. **INFERENCE:** Write a small job card before the request: modality, model, prompt/input reference, parameters, expected artifact, acceptance checks, maximum attempts, and spend stop condition.
4. **UNKNOWN:** The current source set does not establish the challenge's exact permitted models, external assets, or quality rubric. Resolve those from the live challenge package before relying on them.

## 2. Cheap-first generation strategy

1. **INFERENCE:** Start with one cheap representative request and stop if the output already meets the acceptance checks. Escalate model/quality/length only after recording why the first attempt failed.
2. **FACT:** The technical guidance recommends cheap routine models, caching/reusing deterministic artifacts when rules allow, capped concurrency, and bounded retries for 429 responses.
3. **INFERENCE:** Keep concurrency low by default; never use parallel requests to hide an unknown budget impact. Record model, parameters, request count, latency, cost header, and artifact outcome—never the key.
4. **FACT:** Search can carry an extra per-query/call charge; DeepSeek does not support web search in the summarized capability matrix. Do not add search unless the task requires it and the selected model supports it.

## 3. Modality lanes

### Image

- **FACT:** Image generation uses `/images/generations`. Gemini/Nano Banana accepts `aspect_ratio`, one image per request, and base64 output; OpenAI image models use `size` and `quality`.
- **INFERENCE:** Validate the returned payload before treating it as an artifact: decode the image, confirm it is non-empty and has the requested/acceptable dimensions, and compute a content hash for evidence.
- **INFERENCE:** Evaluate against a short rubric: prompt/content match, composition, legibility, prohibited/unsafe content, and reproducibility metadata (model plus parameters).

### Video

- **FACT:** The documented Veo flow is asynchronous: `POST /v1/videos` starts a task, `GET /v1/videos/{id}` polls status, and `/content` downloads the result. Video is billed when created even if it is never downloaded.
- **INFERENCE:** Treat the task ID as durable state. Persist a redacted job record, poll with a bounded interval/timeout, stop on terminal failure, and download only after successful status.
- **INFERENCE:** Begin with the documented lite, 4-second representative request. Check the downloaded file exists, is non-zero, decodes as video, and satisfies the requested duration/format before visual review.
- **UNKNOWN:** The repository does not establish exact polling intervals, terminal status names, codec guarantees, or the challenge's permitted video settings; do not claim these without checking the live API/docs.

### Audio

- **FACT:** The official source registry includes Text-to-Speech and Speech-to-Text user/API documentation. The technical capability summary lists TTS and STT as gateway modalities.
- **INFERENCE:** For generated speech, verify a non-empty playable audio artifact, duration, sample/format metadata where available, and a transcript or human checklist for intelligibility and content fidelity. For STT evaluation, retain the input reference and compare the returned transcript against a human-reviewed reference without placing sensitive audio in prompts or reports.
- **UNKNOWN:** The current repository summary does not specify voices, audio formats, language coverage, or objective quality thresholds.

## 4. Artifact and evidence gate

Do not report success from an HTTP status alone. For every attempt, record a safe evidence row containing:

- timestamp, modality, model, non-secret request parameters, and a stable job/request ID;
- request count, latency, response status/error class, and cost header when provided;
- artifact path or content hash, byte size, and decode/playability check;
- evaluation result (`PASS`, `FAIL`, or `UNKNOWN`) with the exact failed check;
- retry/abandon reason and final disposition.

**FACT:** AI work must record prompts, tool calls/results/errors, and required session/final events through the competition's AI-log configuration. **INFERENCE:** Keep experiment evidence separate from the key and avoid copying raw private inputs into a report. Never edit, omit, fabricate, or disable required AI-log events.

## 5. Budget and failure controls

- **FACT:** Check key and team spend before expensive experiments; shared RPM/TPM and budget apply across keys.
- **INFERENCE:** Enforce a per-job attempt cap, a global remaining-budget threshold, and a wall-clock timeout. Reserve budget for final verification and submission rather than spending it all on exploration.
- **FACT:** Video charges at creation, including when the output is not downloaded. Therefore, run the cheapest representative video first and verify the download path before increasing volume.
- **INFERENCE:** On 429, retry with bounded backoff and a hard retry limit. On malformed/undecodable output, mark `FAIL` and do not silently regenerate indefinitely. On an unknown charge or status, mark `UNKNOWN` and stop escalation.

## Source register

All sources below are official BTC documentation already registered in this repository (`docs/competition/SOURCE-REGISTER.md`), with summaries in `docs/competition/TECHNICAL-CAPABILITIES.md` and `docs/competition/AI-LOG-COMPLIANCE.md`:

- [Image Generation API](https://docs.thucchien.ai/docs/round-2/api-reference/image-generation)
- [Image Generation user guide](https://docs.thucchien.ai/docs/round-2/user-guide/image-generation)
- [Video start](https://docs.thucchien.ai/docs/round-2/api-reference/video-generation-start)
- [Video status](https://docs.thucchien.ai/docs/round-2/api-reference/video-generation-status)
- [Video download](https://docs.thucchien.ai/docs/round-2/api-reference/video-generation-download)
- [Veo 3.1 asynchronous flow](https://docs.thucchien.ai/docs/round-2/user-guide/video-generation-veo3)
- [Speech-to-Text API](https://docs.thucchien.ai/docs/round-2/api-reference/speech-to-text)
- [Text-to-Speech API](https://docs.thucchien.ai/docs/round-2/api-reference/text-to-speech)
- [Pricing](https://docs.thucchien.ai/docs/round-2/user-guide/pricing)
- [Spend checking](https://docs.thucchien.ai/docs/round-2/api-reference/spend-checking)
- [AI Log configuration](https://docs.thucchien.ai/docs/round-2/ai-log-guide)
