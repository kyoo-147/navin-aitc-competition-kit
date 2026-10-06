# Portable Kit Architecture

Status: LOCKED
Architecture Lavish: `../artifacts/architecture.html`
Approval: user approved the light-theme architecture board in Lavish.

## Boundaries

1. Source: private Git repository owns kit, setup, profiles and manifests.
2. Control: bootstrap plans, backs up allowlisted files, validates staging, then applies.
3. Runtime: generated user Codex home plus a separately cloned official repository.
4. Proof: doctor, competition gates, checksums and rollback.

## Stack

- PowerShell 5.1-compatible setup scripts for Windows.
- JSON manifests and state files.
- Git for source/version identity.
- npm only when explicit tool installation is requested.

## State ownership

- Git owns templates, scripts, skill sources and version expectations.
- User home owns generated runtime configuration and private state.
- Official repo owns organizer hooks and all final-round work under `chung-khao/`.
- Humans own all credentials and consequential actions.

## Failure paths

- Missing prerequisite: BLOCKED without mutation.
- Existing destination: PRESERVE in plan mode; backup before approved replacement.
- Invalid staged output: BLOCKED before destination replacement.
- Missing secret: USER ACTION REQUIRED, never fabricated.
- Failed browser attach: hard stop, no retry or Chrome restart.

## Security

No auth stores, tokens, sessions, chats, logs, browser profiles, cookies, databases, PID files or caches enter the portable source.
