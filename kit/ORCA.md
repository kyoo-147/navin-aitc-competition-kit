# Orca Runtime Policy

Verified baseline: Orca 1.4.215 + Codex 0.160 on Windows. Orca is the visible runtime/workspace host, Codex is the worker, and BTC Gateway is the provider.

## Required Codex launcher

Orca Settings:

```text
Command:   C:\Users\hoang\.codex\codex-orca.cmd
Arguments: <empty>
Import:    ~/.codex
```

The wrapper pins the intended `CODEX_HOME`. It fingerprints `model`, `model_provider`, `model_catalog_json`, `forced_login_method`, and catalog contents. Cache sync and `codex app-server daemon restart` happen only when that fingerprint changes, preventing a same-preset worker launch from interrupting existing workers.

Direct `codex` is not accepted from an Orca-inherited shell unless `CODEX_HOME` is explicitly verified.

## Preflight

```text
orca status --json
orca worktree current --json
orca terminal list --json
```

Inspect installed CLI help before using version-sensitive commands. Failed preflight is `BLOCKED`, not permission to silently move to another runtime/provider.

## Worktrees and terminals

Every concurrent writer gets an isolated Orca-managed worktree. Capture exact worktree ID, terminal handle, and process incarnation. Read-only workers may use separate terminals against an existing checkout.

While `orchestration worker-start` fails at `agent_readiness`, use terminal handoff:

```text
orca worktree create --repo id:<repoId> --name <lane> --base-branch <ref> --setup run --json
orca terminal create --worktree id:<repoId>::<path> --title "<lane> codex" --shell cmd.exe --command "C:\Users\hoang\.codex\codex-orca.cmd" --json
orca terminal read --terminal <handle> --limit 200 --json
orca terminal send --terminal <handle> --text "<brief>" --enter --wait-submit 30 --json
orca terminal read --terminal <handle> --cursor <nextCursor> --limit 500 --json
```

`turn_started` is delivery proof. `accepted: true` alone is not. Poll with returned cursors. `tui-idle` is advisory and must not be used as completion proof.

## Provider proof

Picker/footer labels are not evidence. Read `session_meta.model_provider` from the worker rollout under the active `CODEX_HOME`.

```text
thucchien  = valid BTC competition transport
commandcode = SIMULATED_ROUTING_NON_BTC_TRANSPORT
```

## Acceptance and cleanup

The Captain independently verifies provider metadata, Git diff/status, tests/build, real API/UI behavior, local/server AI Log evidence, and commit state. Close only exact task-owned handles after integration or safe preservation. Preserve dirty/ambiguous state and report `UNKNOWN` or `BLOCKED`.
The Captain independently verifies provider metadata, Git diff/status, tests/build, real API/UI behavior, local/server AI Log evidence, and commit state. Close only exact task-owned handles after integration or safe preservation. Preserve dirty/ambiguous state and report `UNKNOWN` or `BLOCKED`.

The user gives one high-level task to the Captain. The Captain may create up to two writer worktrees and one read-only reviewer terminal. Writers never share a checkout; the reviewer never writes to writer worktrees. Use the scale rule: spawn only when independent ownership and observable acceptance outweigh coordination cost.
