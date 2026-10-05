---
name: aitc-orca-runtime
description: Operate visible Codex workers through Orca with conditional provider/catalog refresh, exact terminal/worktree identity, turn-start receipts, cursor polling, rollout provider proof, independent acceptance, and conservative cleanup.
---

# AITC Orca Runtime

Orca is the runtime host. Codex is the worker. BTC Gateway (`thucchien`) is the competition provider. Never conflate them.

## Runtime preflight

```text
orca status --json
orca worktree current --json
orca terminal list --json
```

Orca Settings for Codex:

```text
Command:   C:\Users\hoang\.codex\codex-orca.cmd
Arguments: <empty>
Import:    ~/.codex
```

The wrapper sets `CODEX_HOME`, fingerprints the active provider/model/catalog, refreshes model caches only when that fingerprint changes, and then uses the official `codex app-server daemon restart`. It must not restart the daemon for every same-preset worker because that would interrupt parallel sessions.

## Provider switch

Switch `model`, `model_provider`, `model_catalog_json`, and `forced_login_method` together. Open a new Codex session through the wrapper. Never use `/model` to change transport.

Competition proof:

```text
session_meta.model_provider = thucchien
```

`commandcode` is preparation/simulation only and must be labeled `SIMULATED_ROUTING_NON_BTC_TRANSPORT`.

## Create a writer

Concurrent writers require separate Orca-managed worktrees:

```text
orca worktree create --repo id:<repoId> --name <lane> --base-branch <ref> --setup run --json
orca terminal create --worktree id:<repoId>::<path> --title "<lane> codex" --shell cmd.exe --command "C:\Users\hoang\.codex\codex-orca.cmd" --json
```

For a fresh read-only worker in an existing worktree, create only a separate terminal. Capture the exact worktree ID, terminal handle, and process incarnation from returned JSON.

## Send and observe

Read once before sending and retain `nextCursor`:

```text
orca terminal read --terminal <handle> --limit 200 --json
orca terminal send --terminal <handle> --text "<bounded brief>" --enter --wait-submit 30 --json
```

A valid delivery receipt contains `turn_started`. `accepted: true` alone proves only queued input. Never resend after an ambiguous timeout until the terminal and receipt are inspected; use the returned `--retry-request` only for the exact same payload when required.

Poll incrementally:

```text
orca terminal read --terminal <handle> --cursor <nextCursor> --limit 500 --json
```

Use bounded intervals and update the cursor from each response. Use `--screen` only to inspect the current rendered TUI. Do not use `tui-idle` as completion proof; this Codex/Orca combination can remain non-idle after work is complete.

## Accept

Independently verify:

- rollout `session_meta.model_provider`;
- exact files and diff;
- targeted tests/build;
- runtime/API/UI path;
- commit and Git status;
- local AI Log events for the same session when required.

Worker prose and terminal text are supporting evidence, not acceptance.

## Cleanup

Close only task-owned exact handles after integration or safe preservation. Dirty or ambiguous worktrees remain intact and are reported `UNKNOWN` or `BLOCKED`; never force-clean them.
