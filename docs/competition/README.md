# Round 2 Knowledge Pack

Authoritative order:

1. Challenge package and live instructions issued by BTC.
2. Official Round 2 documentation under `https://docs.thucchien.ai/docs/round-2/`.
3. General competition rules at `https://thucchien.ai/the-le-cuoc-thi/`.
4. This repository's sourced summaries.

## Documents

- `ROUND-2-RULES.md` — mandatory environment, devices, monitoring, submission, violations.
- `TECHNICAL-CAPABILITIES.md` — gateway, models, modalities, budget and compatibility.
- `AI-LOG-COMPLIANCE.md` — required logging and privacy boundary.
- `COMPETITION-DAY-CHECKLIST.md` — operational checklist.
- `SOURCE-REGISTER.md` — all discovered official Round 2 pages and retrieval metadata.
- `FACTS-INFERENCES-UNKNOWNS.md` — epistemic status and open questions.

Refresh source availability locally with:

```powershell
uv run scripts/refresh_official_sources.py
```

Raw fetched pages go to ignored `.cache/official-docs/`; the repository stores the source registry and first-party summaries, not a vendored copy of BTC documentation.

## Active test execution

- [Mandatory technical test: Gateway and AI Log](MANDATORY-TECHNICAL-TEST.md)
