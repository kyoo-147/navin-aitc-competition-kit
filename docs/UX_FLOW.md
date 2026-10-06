# Portable Setup Flow

Status: LOCKED
UX Flow Lavish: `../artifacts/ux-flow.html`
Approval: user approved guided-safe mode and the light-theme setup board in Lavish.

## Primary journey

```text
clone private kit
→ bootstrap plan
→ explicit apply with backup
→ human enters secrets
→ read-only doctor
→ clone official repository
→ BTC preflight and provider/log proof
```

## Command states

- PLAN: show CREATE, UPDATE, PRESERVE and BLOCK without mutation.
- APPLY: backup allowlisted files, stage, validate and atomically replace.
- USER ACTION REQUIRED: authentication, secret entry or consequential approval.
- READY: local doctor passed; this does not replace live BTC preflight.

## Browser interaction

- Static work uses fetch/curl.
- Interactive evidence uses an isolated browser and stops afterward.
- Personal Chrome requires explicit per-session permission.
- One attach failure ends the attempt.

## Responsive/readability decision

Lavish artifacts use a light theme, high-contrast text and architecture/flow boards composed of clearly labeled blocks.
