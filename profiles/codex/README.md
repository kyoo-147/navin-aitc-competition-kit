# Codex Portable Profile

Tracked source files:

- `AGENTS.md`, `BUILD_PLAYBOOK.md`, `TASTE_UI.md`: global working rules.
- `config.normal.template.toml`: provider-neutral safe baseline.
- `config.aitc.template.toml`: BTC Responses provider template with environment-only key lookup.
- `hooks.safe.template.json`: empty user hook baseline. Official AI Log hooks remain project-local and are never overwritten.
- `codex-orca.cmd`, `codex-runtime-refresh.ps1`: canonical Orca/Codex launch path.

Runtime files under a user's `.codex` directory are generated outputs. Do not copy login state, sessions, logs, databases, attachments, caches, PID files or machine paths into this directory.

## Captured machine profile

- `codex-orca.installed.cmd` is an exact machine-specific wrapper snapshot for audit evidence; bootstrap renders the portable template for a new username/path.
- `skills/` contains the reviewed snapshot of user-installed Codex skills. Codex-managed `.system` skills are excluded.
- Use `setup/restore-machine-profile.ps1 -RestoreUserSkills` only when reproducing the full global user skill set. The AITC competition profile itself remains restricted by `manifests/skills.json`.
