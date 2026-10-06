# Portable Setup

Windows teammate flow:

```powershell
git clone https://github.com/kyoo-147/navin-aitc-competition-kit
cd navin-aitc-competition-kit

# 1. Read-only plan. Makes no target-home changes.
.\setup\bootstrap.ps1 -Profile Normal

# 2. Apply after reviewing the plan.
.\setup\bootstrap.ps1 -Profile Normal -Apply

# 3. Read-only verification.
.\setup\doctor.ps1 -Profile Normal
```

For competition profile generation:

```powershell
.\setup\bootstrap.ps1 -Profile Aitc -Model gpt-6-luna
.\setup\bootstrap.ps1 -Profile Aitc -Model gpt-6-luna -Apply -ReplaceConfig
$kit = (Get-Location).Path
$official = 'D:\path\to\aitc2026-team-918-navin-research'
Set-Location $official
& "$kit\setup\doctor.ps1" -Profile Aitc -OfficialRepo $official
```

`-ReplaceConfig` is intentionally explicit. Without it, an existing `config.toml` is preserved.

Optional CLI installation:

```powershell
.\setup\bootstrap.ps1 -Profile Normal -InstallTools
.\setup\bootstrap.ps1 -Profile Normal -InstallTools -Apply
```

This installs pinned/on-demand tools. AITC Lavish is exactly `lavish-axi@0.1.63` and must be installed before the round; competition runtime never uses `npx` or remote assets. Browser attachment and browser SessionStart hooks remain disabled.

Rollback is plan-first:

```powershell
.\setup\rollback.ps1
.\setup\rollback.ps1 -Apply
```

Update is fail-closed on a dirty checkout:

```powershell
.\setup\update.ps1
.\setup\update.ps1 -Apply
```

Safe export allows only `AGENTS.md`, `BUILD_PLAYBOOK.md`, and `TASTE_UI.md`:

```powershell
.\setup\export-safe-profile.ps1
.\setup\export-safe-profile.ps1 -Apply
```

Never copy a raw user `.codex` directory. See `SECURITY.md`.
