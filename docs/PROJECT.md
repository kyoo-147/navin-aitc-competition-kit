# Portable Competition Kit

Status: LOCKED

## Goal and users

- Goal: reproduce the reviewed NAVIN AITC Codex/Orca environment safely on another Windows machine from one private repository.
- Primary users: NAVIN AITC leader and authorized teammates.
- Smallest complete outcome: clone, plan, apply, enter secrets manually, run doctor, then preflight the official repository.

## Must have

- Secret-free portable profiles, skills, wrappers, settings templates and version manifests.
- Guided safe bootstrap with plan, allowlisted backup, validation and atomic writes.
- Read-only doctor and explicit rollback.
- Official repository boundary and browser isolation policy.
- Machine-verifiable tests and checksums.

## Out of scope

- Copying raw user homes, auth, sessions, history, browser data, logs, SQLite state or caches.
- Automatic secret entry, GitHub login, deployment or competition submission.
- Overwriting organizer-owned root hooks.

## Acceptance

- Clean-home simulation installs expected files without secrets.
- Existing user files are preserved or backed up before replacement.
- Doctor reports PASS/BLOCKED/USER ACTION REQUIRED truthfully.
- Browser auto-connect and browser SessionStart hooks remain disabled.
- Full kit verification and tests pass.
