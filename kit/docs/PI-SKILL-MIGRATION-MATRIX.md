# Pi Skill Migration Matrix

Source inventory: `C:\Users\hoang\.pi\agent\skills`.

Default rule: do not bulk-install Pi skills into Codex. The kit has three core skills - Captain, Worker, Reviewer - plus the thirteen explicitly approved task skills below. Task skills are discovered by description and loaded only when the task matches; live rules and verified dependencies still apply.

## Safe candidates for task-local Codex use

- `accessibility`
- `best-practices`
- `commit`
- `create-cli`
- `frontend-design`
- `performance`
- `playwright-cli`
- `react-best-practices`
- `react-native-skills`
- `summarize`
- `uv`
- `web-design-guidelines`
- `web-quality-audit`
- `web-quality-seo`
- `writing-guidelines`
- `github`
- `update-changelog`

These remain on-demand, not always-on. Inspect the skill before copying it into a project.

## UI/design skills - use selectively

- `design-taste-frontend`
- `design-taste-frontend-v1`
- `frontend-design-v2`
- `high-end-visual-design`
- `industrial-brutalist-ui`
- `minimalist-ui`
- `gpt-taste`
- `stitch-design-taste`
- `brandkit`
- `image-to-code`
- `imagegen-frontend-web`
- `imagegen-frontend-mobile`
- `redesign-existing-projects`

Use `TASTE_UI.md` first. Do not stack multiple visual systems or introduce image-generation dependencies unless the task requires them.

## Specialized tools - not competition defaults

- `anachb`, `oebb-scotty`, `openscad`, `ghidra`, `tldraw-api`, `tldraw-offline`, `tmux`, `computer-use`, `orca-cli`, `orchestration`
- `audio-transcription`, `transcribe`, `peekaboo`, `realbrowser`, `web-browser`
- `seo`, `seo-audit`, `seo-backlinks`, `seo-cluster`, `seo-competitor-pages`, `seo-content`, `seo-content-brief`, `seo-dataforseo`, `seo-drift`, `seo-ecommerce`, `seo-flow`, `seo-geo`, `seo-google`, `seo-hreflang`, `seo-image-gen`, `seo-images`, `seo-local`, `seo-maps`, `seo-page`, `seo-plan`, `seo-programmatic`, `seo-schema`, `seo-sitemap`, `seo-sxo`, `seo-technical`
- `deploy-to-vercel`, `vercel-cli-with-tokens`, `vercel-optimize`

Use only with explicit scope, verified credentials, and live competition permission.

## Personal-state or external-service skills - do not migrate automatically

- `apple-mail`, `gog`, `google-workspace`, `sentry`, `oracle`, `pi-share`, `native-web-search`
- `seo-dataforseo`, `vercel-cli-with-tokens`, `deploy-to-vercel`
- image-generation and browser-profile skills when they require personal accounts or private state

These can expose private data, depend on external services, or use Pi-specific tools. Keep them out of the competition runtime unless explicitly reviewed.

## Matt Pocock reference

For engineering behavior, prefer the embedded Captain procedures based on `implement`, `tdd`, `diagnosing-bugs`, `code-review`, and `retro` rather than installing a second orchestration framework.

## Exact installed inventory

The current Pi inventory contains 84 `SKILL.md` entries. Exact directory names are:

`accessibility`, `anachb`, `apple-mail`, `audio-transcription`, `best-practices`, `brandkit`, `brutalist-skill`, `commit`, `composition-patterns`, `core-web-vitals`, `create-cli`, `deploy-to-vercel`, `design-taste-frontend`, `design-taste-frontend-v1`, `frontend-design`, `frontend-design-v2`, `ghidra`, `github`, `gog`, `google-workspace`, `gpt-tasteskill`, `high-end-visual-design`, `image-to-code-skill`, `imagegen-frontend-mobile`, `imagegen-frontend-web`, `industrial-brutalist-ui`, `librarian`, `minimalist-skill`, `native-web-search`, `oebb-scotty`, `openscad`, `oracle`, `output-skill`, `peekaboo`, `performance`, `pi-share`, `playwright-cli`, `react-best-practices`, `react-native-skills`, `react-view-transitions`, `realbrowser`, `redesign-skill`, `sentry`, `seo`, `seo-audit`, `seo-backlinks`, `seo-cluster`, `seo-competitor-pages`, `seo-content`, `seo-content-brief`, `seo-dataforseo`, `seo-drift`, `seo-ecommerce`, `seo-flow`, `seo-geo`, `seo-google`, `seo-hreflang`, `seo-image-gen`, `seo-images`, `seo-local`, `seo-maps`, `seo-page`, `seo-plan`, `seo-programmatic`, `seo-schema`, `seo-sitemap`, `seo-sxo`, `seo-technical`, `soft-skill`, `stitch-skill`, `summarize`, `taste-skill`, `taste-skill-v1`, `tldraw-api`, `tldraw-offline`, `tmux`, `transcribe`, `update-changelog`, `uv`, `vercel-cli-with-tokens`, `vercel-optimize`, `web-browser`, `web-clone`, `web-design-guidelines`, `web-quality-audit`, `web-quality-seo`, `writing-guidelines`.
