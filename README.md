# NAVIN AITC Competition Kit

Private preparation and reusable operating kit for team **AITC-918 - NAVIN Research**.

## Clone and configure a teammate machine

This private repository is the canonical portable source. Do not copy a raw user `.codex` directory.

```powershell
git clone https://github.com/kyoo-147/navin-aitc-competition-kit
cd navin-aitc-competition-kit

# Safe default: plan only, no target-home changes.
.\setup\bootstrap.ps1 -Profile Normal

# Apply only after reviewing CREATE / UPDATE / PRESERVE / BLOCK output.
.\setup\bootstrap.ps1 -Profile Normal -Apply
.\setup\doctor.ps1 -Profile Normal
```

For BTC competition mode, use `-Profile Aitc`, enter secrets yourself only after bootstrap, then run doctor with `-OfficialRepo`. Full setup, rollback and update commands are in [`setup/README.md`](setup/README.md). Security boundaries are in [`SECURITY.md`](SECURITY.md).

This repository is separate from the organizer-owned team repository. It must never receive secrets or raw private AI logs.

## Canonical reusable kit

The reviewed operational variant lives at [`kit/`](kit/README.md).

It includes:

- official-repository boundary rules;
- secret-safe bootstrap and private Codex Gateway configuration;
- fail-closed live preflight;
- correct team spend lookup through `/key/info` then `/team/info?team_id=...`;
- BTC AI Log server readback checks;
- budget gates and dated routing guidance;
- Orca runtime checks and bounded worker skills;
- implementation contract, review, evidence, and submission runbooks;
- a safe sync command for `chung-khao/navin-competition-kit/`.

Preparation screenshots and upstream source material are retained under `kit/references/` but are excluded from the official-repository variant.

## Official repository rule

All final-round source, documentation, demo assets, and deliverables must live under the official repository's `chung-khao/` directory. Organizer-provided root hook infrastructure remains at root. AI tools must be opened at official repository root so logging hooks load.

## Start

```powershell
cd kit
.\scripts\verify.ps1
Get-Content .\README.md
```

Then follow the bootstrap and live preflight commands in `kit/README.md`.

## Repository layers

- `kit/` - canonical reusable operational variant.
- `docs/competition/` - sourced Round 2 knowledge inherited from the validated harness.
- `config/competition/` - earlier policy snapshots retained for provenance.
- Captain orchestration - the earlier orchestrator proposal is folded into `kit/skills/aitc-captain/`; no separate orchestrator skill is installed.
- `tests/` and `scripts/verify_harness.py` - repository-wide static verification.

Live BTC instructions always override snapshots and internal runbooks.

## Verification

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File kit\scripts\update-manifest.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File setup\update-portable-manifest.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File kit\scripts\verify.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File setup\verify-portable.ps1
python scripts\verify_harness.py
python -m unittest discover -s tests -v
git diff --check
```
