# Orca Runtime Policy

For the verified Orca 1.4.215 + Codex 0.160 behaviour, the working worker path, the always-on
no-approval keys, the catalog/provider rule, and where token counts live, read
`docs/ORCA-CODEX-FINDINGS.md`. Supervised `worker-start` for Codex fails at `agent_readiness` in that
combination; use the terminal-handoff path documented there.

Orca is the visible runtime/workspace host for this kit. It is not the AI provider and not the competition control plane.

Keep three concepts separate:

1. Captain/control plane - task lifecycle, ownership, routing, evidence.
2. Orca/runtime host - visible terminals and worktrees.
3. Codex/worker harness - the coding agent and selected BTC model.

Changing runtime host must not change task ownership or acceptance criteria.

## Preflight

Use the version-matched Orca CLI. At minimum:

```text
orca status --json
orca worktree current --json
orca terminal list --json
```

If the installed Orca version differs, inspect `orca --help`, `orca worktree --help`, and `orca terminal --help` before using creation/send commands. Do not guess an unsupported command.

A failed Orca preflight is `BLOCKED`; do not silently move the task elsewhere.

## Writers

Every concurrent writer gets an isolated Git worktree. Capture the exact worktree identity and terminal handle returned by Orca. Display labels are not authoritative IDs.

Default to two writers. More writers require non-overlapping ownership and an obvious time benefit.

## Read-only workers

Scouts and reviewers may use separate visible terminals against the source checkout when they do not mutate files. If they need to edit, promote them to an isolated writer worktree.

## Send / observe

A send receipt proves only that input was accepted. It does not prove the agent started or completed the requested work.

Observe with bounded waits/reads. Do not resend a prompt simply because output is slow. Inspect the terminal first.

## Accepting worker output

Terminal text is supporting evidence only. The Captain independently checks:

- Git diff/status;
- changed files;
- relevant tests/build;
- runtime/API/UI behavior;
- commit/worktree state.

## Cleanup

Before releasing an Orca worktree:

1. confirm the exact repository/worktree identity;
2. confirm intended work is integrated or safely preserved;
3. inspect Git status;
4. retain any useful report/evidence;
5. close only the exact task-owned terminal/worktree.

If identity or dirty state is uncertain, preserve the workspace and report `UNKNOWN` instead of forcing cleanup.
