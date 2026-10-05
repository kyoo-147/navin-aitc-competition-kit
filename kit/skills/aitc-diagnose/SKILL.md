---
name: aitc-diagnose
description: Diagnose a hard contest bug with a tight reproducible loop, ranked hypotheses, root-cause repair, and dedicated playbooks for Codex provider/catalog, Orca delivery, and AI Log failures.
---

# AITC Diagnose

Use after an ordinary bounded fix fails. Build evidence before theories.

## Core loop

1. Create the fastest reliable red/green signal: targeted test, curl, CLI fixture, browser smoke, or minimal replay.
2. Reproduce the exact user symptom and minimize irrelevant inputs.
3. Rank 2-3 falsifiable hypotheses and test the highest-value discriminator.
4. Make the smallest root-cause fix and retain a regression check.
5. Rerun both the narrow check and original full flow.
6. Remove temporary instrumentation.

If two bounded attempts or roughly eight minutes do not narrow the cause, return the repro, eliminated hypotheses, and next discriminator to the Captain. Do not spend premium reasoning on an unstructured dump.

## Wrong model picker/provider playbook

```text
check effective CODEX_HOME
→ inspect top-level model/model_provider/model_catalog_json/forced_login_method
→ verify catalog file exists and contains selected model
→ run conditional codex-runtime-refresh.ps1
→ restart app-server daemon only when fingerprint changed
→ open a new session through codex-orca.cmd
→ verify rollout session_meta.model_provider
```

Do not infer transport from picker/footer labels. Do not change only `/model`.

## Orca delivery playbook

```text
confirm exact terminal handle and incarnation
→ read and retain nextCursor
→ send once with --wait-submit
→ require turn_started or inspect ambiguous receipt
→ poll with --cursor
→ verify Git/runtime independently
```

Do not rely on `tui-idle` and do not resend merely because output is slow.

## AI Log playbook

```text
confirm Codex cwd is official repo root
→ inspect project .codex/hooks.json for UserPromptSubmit/PostToolUse/Stop
→ verify referenced scripts and bash/python resolve
→ reproduce with one real canary, never synthetic log editing
→ match local events to rollout session id
→ submit and require 202
→ read back the same session from BTC
```

Never delete/edit/add `.ai-log` lines to make a gate pass. Preserve failed pending logs and hook stderr evidence.
