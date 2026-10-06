# Codex Portable Profile

Tracked source files:

- `AGENTS.md`, `BUILD_PLAYBOOK.md`, `TASTE_UI.md`: global working rules.
- `config.normal.template.toml`: provider-neutral safe baseline.
- `config.aitc.template.toml`: BTC Responses provider template with environment-only key lookup.
- `hooks.safe.template.json`: empty user hook baseline. Official AI Log hooks remain project-local and are never overwritten.
- `codex-orca.cmd`, `codex-runtime-refresh.ps1`: canonical Orca/Codex launch path.

Runtime files under a user's `.codex` directory are generated outputs. Do not copy login state, sessions, logs, databases, attachments, caches, PID files or machine paths into this directory.
