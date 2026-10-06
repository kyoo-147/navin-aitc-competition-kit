# Security Boundary

## Never commit or export

- API keys, bearer tokens, passwords, private keys or auth stores.
- `.env` values, Codex/Claude login state or GitHub credentials.
- Sessions, conversations, history, memories, attachments or transcripts.
- SQLite databases, logs, daemon state, PID/lock files or caches.
- Browser profiles, cookies, extensions, history or saved data.
- Raw `%USERPROFILE%\.codex`, `.claude`, `.agents` or browser directories.

## Portable source rule

Only reviewed templates, documentation, skills, wrappers, manifests and setup scripts belong in this repository. `setup/export-safe-profile.ps1` exports three documentation files from a user Codex home and nothing else.

## Credentials on a new machine

The bootstrap never asks for or writes credentials. Authorized users enter required values after installation into the official clone's ignored `.env` or the current process environment. Doctor reports presence only and never prints values.

## Browser safety

Browser automation uses isolated sessions by default. Personal Chrome attachment, restart or control requires explicit permission for that exact session. One failed attachment attempt is a hard stop.

## Reporting

If a credential appears in tracked content, logs, terminal output or a screenshot, stop, remove it from active use and rotate it. Removing a line from Git does not make an exposed credential safe again.
