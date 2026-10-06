# NAVIN AITC Competition Kit

Reusable, fail-closed operating kit for NAVIN Research in AITC 2026 Round 2.

This repository is a preparation and tooling source. It is not the official submission repository.

## Official repository boundary

The organizer-owned team repository is authoritative during the final round.

All final-round source code, documentation, demo assets, and deliverables must live under its `chung-khao/` directory. Organizer-provided root files such as AI Log hooks remain at repository root.

Run coding tools from the official repository root so BTC hooks can record required events. Do not open only `chung-khao/` as the workspace.

See [docs/OFFICIAL-REPO-BOUNDARY.md](docs/OFFICIAL-REPO-BOUNDARY.md).

## Credentials

Use only the organizer-defined variables:

- `THUCCHIEN_API_KEY` for BTC Gateway model calls.
- `AI_LOG_API_KEY` for BTC AI Log submission and readback.
- `AI_LOG_SERVER=https://live.thucchien.ai/api/ingest`.

Keep them in the official repository's ignored `.env` or in the current process environment. Never place a value in this kit, a prompt, a screenshot, Git history, or model-visible output.

The kit does not define a separate product key. If the final product calls the Gateway, use an organizer-issued Gateway key according to the live challenge instructions and keep it server-side.

## First use

From PowerShell:

```powershell
cd D:\path\to\navin-aitc-competition-kit\kit

# Prepare the official clone and install the canonical wrapper/skills without storing secrets in this kit.
.\scripts\bootstrap.ps1 `
  -RepoPath D:\path\to\aitc2026-team-918-navin-research `
  -Model <live-verified-model> `
  -CodexHome "$HOME\.codex" `
  -InstallSkills

# Offline structure and manifest check.
.\scripts\verify.ps1

# Live identity, budget, hook and existing server-log checks. This makes no model call.
.\scripts\preflight.ps1 `
  -RepoPath D:\path\to\aitc2026-team-918-navin-research `
  -Model <selected-model>

# One small Codex canary through BTC Gateway. It must log, submit with 202,
# and read the same session back from the BTC server.
.\scripts\codex-canary.ps1 `
  -RepoPath D:\path\to\aitc2026-team-918-navin-research `
  -Model <selected-model>

# Start Codex at official repo root through BTC Gateway.
.\scripts\start-codex.ps1 `
  -RepoPath D:\path\to\aitc2026-team-918-navin-research `
  -Model <live-verified-model>

# Verify rollout provider plus local events for the resulting session.
.\scripts\session-preflight.ps1 `
  -RepoPath D:\path\to\aitc2026-team-918-navin-research `
  -RequireServerLog
```

`bootstrap.ps1` never asks for or prints a key, preserves an existing user config unless `-ForceConfig` is explicit, preserves user hooks, installs the conditional runtime wrapper, and optionally installs the three reviewed AITC skills. Populate the official clone's ignored `.env` or the process environment yourself before live preflight.

## Reusable variant clone

To place a reviewable copy of the operational kit inside the official final-round boundary:

```powershell
.\scripts\sync-variant.ps1 `
  -OfficialRepo D:\path\to\aitc2026-team-918-navin-research
```

The destination is `chung-khao/navin-competition-kit/`. The script refuses to overwrite an existing destination unless `-Force` is explicit. It excludes preparation screenshots and raw source material.

Do not run this against the official repository until the team has reviewed the kit and intentionally decided to commit that variant.

## Competition flow

1. Read the live challenge and current BTC documentation.
2. Run `budget.ps1` and live preflight.
3. Run the logged Codex canary and verify its session on the BTC AI Log server.
4. Lock `templates/IMPLEMENTATION_CONTRACT.md` before parallel writers start.
5. Build the smallest complete vertical slice.
6. Give one task to the Captain. It may use two isolated writer lanes and one read-only reviewer; see `CODEX-PROMPT-FLOW.md`.
7. Integrate early, run task-relevant tests, deploy, and capture evidence.
8. Stop nonessential model calls at policy gates.
9. Freeze, submit, and capture a visible receipt.

## Directory map

- `config/` - dated routing guidance and spend policy.
- `CODEX-PROMPT-FLOW.md` - one-prompt Captain routing, model selection, spawn limits, and evidence contract.
- `docs/` - team operating guides, official-repository boundary, Codex/Pi scope policy, copied Codex guides under `docs/codex/`, Pi skill migration matrix, and Codex settings optimization notes.
- `runbook/` - timed and failure runbooks.
- `scripts/` - bootstrap, conditional Codex runtime refresh, preflight/session proof, budget, Orca, sync, and verification.
- `skills/` - captain, worker, and reviewer skills. Runtime and orchestration are Captain procedures, not separate skill sprawl.
- `templates/` - idea brief, worker brief, implementation contract, acceptance matrix, and review report.
- `references/` - preparation-only screenshots and source material. Not included in the official variant.
- `licenses/` and `THIRD_PARTY_NOTES.md` - attribution.

## Non-negotiable status labels

Use `VERIFIED`, `UNVERIFIED`, `BLOCKED`, `CI UNAVAILABLE`, `USER ACTION REQUIRED`, and `TARGET/UNMEASURED` literally. Worker completion text is not evidence.
