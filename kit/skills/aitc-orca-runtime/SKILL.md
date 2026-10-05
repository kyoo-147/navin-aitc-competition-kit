---
name: aitc-orca-runtime
description: Operate visible Codex workers through Orca with explicit preflight, isolated writer worktrees, exact terminal/worktree identity, bounded observation, evidence-based acceptance, and conservative cleanup.
---

# AITC Orca Runtime

Orca is the runtime host. Codex is the worker. BTC Gateway is the provider. Never conflate them.

## Preflight

Run and inspect:

```text
orca status --json
orca worktree current --json
orca terminal list --json
```

If a create/send command is not known for the installed Orca version, inspect CLI help rather than guessing.

## Create

- Read-only worker: separate visible terminal in an appropriate existing worktree.
- Concurrent writer: isolated Orca-managed Git worktree.
- Capture exact worktree ID and terminal handle.
- Do not create duplicate terminals when worktree creation already returns one.

## Send

Use a compact worker brief. Treat a successful send as input acceptance only. Do not resend merely because the worker is slow.

## Observe

Use bounded waits and incremental/cursor reads when supported. A terminal becoming idle is not proof of task success.

## Accept

Verify the repository evidence independently:

- files/diff;
- test/build output;
- runtime/API/UI behavior;
- commit and Git status.

## Cleanup

Close only task-owned exact handles after the work is integrated or safely preserved. Dirty/unknown state is preserved and reported, never force-cleaned.
