# Replicate the NAVIN Codex and AITC workstation

This runbook recreates the reviewed, portable parts of the current Windows setup on a new machine. It does not copy secrets or opaque runtime state.

## What is reproduced

- global Codex guidance: `AGENTS.md`, `BUILD_PLAYBOOK.md`, `TASTE_UI.md`;
- portable Codex configuration for Normal or AITC mode;
- rendered `codex-orca.cmd` and `codex-runtime-refresh.ps1`;
- BTC model catalog snapshot and local-only hook policy;
- AITC allowlisted runtime skills;
- optional snapshot of all 21 user-installed Codex skills under `profiles/codex/skills/`;
- pinned Lavish and browser tooling from `manifests/tools.json`;
- contract-first Captain/Worker/Reviewer/Design Studio workflow;
- official `chung-khao/`, Human Lock, `LOCK_BASE_SHA`, early integration, E2E and provenance gates.

## Intentionally not reproduced

Never copy these from the old machine:

- API keys, passwords, OAuth/auth stores, `.env` values or private keys;
- sessions, conversations, history, memories, attachments or transcripts;
- SQLite databases, logs, daemon/PID/lock state, caches or temporary files;
- browser profiles, cookies, extensions or personal signed-in state;
- `.codex/skills/.system`; Codex installs and updates these internal skills itself.

A new machine must log in and receive secrets independently.

## Current verified baseline

Read the exact current versions from `manifests/tools.json`. At the captured baseline:

- Windows PowerShell 5.1+;
- Git 2.40+;
- Node.js 20+ and npm 10+;
- Codex CLI 0.160.0+;
- Orca 1.4.215+;
- `lavish-axi` exactly 0.1.63;
- `chrome-devtools-axi` 0.1.39+;
- `chrome-devtools-mcp` 1.10.1+.

Live BTC instructions override this snapshot.

## 1. Install prerequisites

Open PowerShell as the target user:

```powershell
winget install --id Git.Git -e
winget install --id OpenJS.NodeJS.LTS -e
npm install -g @openai/codex
```

Install Orca using its approved Windows installer. Close and reopen the terminal, then verify:

```powershell
git --version
node --version
npm --version
codex --version
orca --version
```

## 2. Clone the private kit

```powershell
Set-Location D:\work

git clone https://github.com/kyoo-147/navin-aitc-competition-kit.git
Set-Location .\navin-aitc-competition-kit

git status --short --branch
git rev-parse HEAD
```

The checkout must be clean and at the intended `origin/main` SHA.

## 3. Review the restore plan

AITC-only runtime skills:

```powershell
.\setup\restore-machine-profile.ps1 `
  -Profile Aitc `
  -Model gpt-6-luna `
  -InstallTools
```

Full user skill snapshot, matching the old machine's user-installed skill set:

```powershell
.\setup\restore-machine-profile.ps1 `
  -Profile Aitc `
  -Model gpt-6-luna `
  -InstallTools `
  -RestoreUserSkills
```

Plan mode makes no target-home changes.

## 4. Apply on a fresh machine

For a new or disposable Codex home:

```powershell
.\setup\restore-machine-profile.ps1 `
  -Profile Aitc `
  -Model gpt-6-luna `
  -InstallTools `
  -RestoreUserSkills `
  -ReplaceConfig `
  -Apply
```

For an existing Codex home, omit `-ReplaceConfig` first. The installer preserves `config.toml` and hooks unless replacement is explicit. Every overwritten managed file or skill is backed up beneath:

```text
%CODEX_HOME%\backups\
```

The portable wrapper is rendered from `profiles/codex/codex-orca.cmd`. `profiles/codex/codex-orca.installed.cmd` is an exact snapshot from the captured machine and is evidence only; do not copy its hardcoded username path to another user account.

## 5. Verify the restored machine

```powershell
.\setup\doctor.ps1 -Profile Aitc
.\setup\verify-portable.ps1
```

Required evidence includes:

- managed file hashes pass;
- portable checksums pass;
- secret scan passes;
- browser auto-attach is disabled;
- Chrome DevTools AXI SessionStart hooks are absent;
- Lavish is exactly 0.1.63;
- `codex-orca.cmd` exists under `%CODEX_HOME%`;
- `aitc-design-studio` exists;
- AITC config contains:

```toml
[shell_environment_policy]
ignore_default_excludes = false
```

`doctor.ps1` may report `USER ACTION REQUIRED` for missing keys. That is expected before local secret entry.

## 6. Enter credentials locally

Never commit or transfer keys through this repository. Enter the required values in the official clone's ignored `.env` or in the current process environment, following live BTC instructions:

```text
THUCCHIEN_API_KEY
AI_LOG_API_KEY
AI_LOG_SERVER
```

Run BTC preflight only when Gateway access is available. Catalog presence alone is not provider/tool proof.

## 7. Official competition repository

Clone the organizer repository separately. Do not vendor this kit into it during OFFICIAL mode.

```text
official-repo/
  organizer hooks and scripts at repository root
  chung-khao/
    docs/
    contracts/
    design/
    artifacts/
    app/
```

Launch Codex from the official repository root so organizer hooks load. In OFFICIAL mode:

```text
ProjectRelativeRoot = chung-khao
```

In DRILL mode:

```text
ProjectRelativeRoot = .
```

## 8. Competition workflow

```text
ask OFFICIAL or DRILL
→ ingest challenge
→ factual research when required
→ Human Brief
→ Architecture direction
→ Design Studio directions and prototype
→ independent P0/P1/P2 design review
→ human feedback
→ Architecture + UX/Design Lavish locks
→ compile project/application/design contracts
→ commit Human Lock files
→ create PROJECT_LOCK and LOCK_BASE_SHA
→ Lane A || Lane B from exact lock SHA
→ minute 40-50 real integration canary
→ continue independent work after pass
→ full integration and E2E
→ deploy and smoke
→ push
→ AI Log submit 202
→ same-session readback
→ final submission receipt
```

Lane A and Lane B are selected from the locked architecture; they are not fixed Backend/Frontend roles. Never exceed two writers and one read-only reviewer.

For open-ended multimodal challenges, follow `kit/RULES.md` and `kit/skills/aitc-captain/SKILL.md`: source-backed research, one structured content request when sufficient, locked media budget, prompt-hash cache, request ledger, early mandatory video, and BTC Gateway only.

## 9. Update and rollback

Update from Git and reapply safely:

```powershell
.\setup\update.ps1 -Profile Aitc
.\setup\update.ps1 -Profile Aitc -Apply
```

Preview and apply rollback:

```powershell
.\setup\rollback.ps1
.\setup\rollback.ps1 -Apply
```

After every update, rerun doctor and portable verification. Never describe a machine as identical until hashes, tools, profile, skills, hooks and workflow gates have all been checked.
