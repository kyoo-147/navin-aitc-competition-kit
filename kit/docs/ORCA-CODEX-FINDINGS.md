# Orca + Codex Runtime Findings (2026-10-05 drill)

Evidence source: drill run `run_436910d2ada7`, Orca `1.4.215`, `OpenAI Codex v0.160.0`, Windows host.
Every claim below was reproduced in this environment.

## 1. Supervised orchestration cannot prompt Codex - use terminal handoff

`orca orchestration worker-start` (both `--agent codex` and `--terminal <handle>`) consistently failed at
stage `agent_readiness` with `lastError: timeout`, even though the Codex TUI was already sitting at
`› Ask Codex to do anything`.

Root cause: `worker-show` reports `observation.agentWait: null`. Orca's readiness gate waits on an agent
signal that this Codex build does not emit, so the start never reaches the prompt-injection step. The
terminal it created stayed empty, and no task spec was ever delivered.

Consequences:

- `--timeout-ms` does not rescue it; the gate is signal-based, not duration-based.
- After three consecutive failures the Task is circuit-broken to `failed` and cannot be re-dispatched.
- `worker-release` on those receipts closes only the empty terminal; `worker-abandon` settles the
  orchestration record while leaving the terminal alive.

Working path used instead (reliable, visible, still Orca-managed):

```text
orca worktree create --repo id:<repoId> --name <lane> --no-parent --setup skip --json
orca terminal create --worktree id:<repoId>::<path> --title "<lane> codex" --shell cmd.exe --command "C:\Users\hoang\.codex\codex-orca.cmd" --json
orca terminal send  --terminal <handle> --text "<task brief>" --enter --wait-submit 30 --json
orca terminal read  --terminal <handle> --cursor <nextCursor> --limit 500 --json
```

`terminal send --wait-submit` returns `turn_started` when the agent actually began the turn. That is the
delivery proof to record; `accepted: true` alone is not.

`tui-idle` also did not report `satisfied: true` for these Codex sessions, so treat it as advisory and
confirm completion by reading the terminal plus verifying Git.

## 2. Orca "paired parking" blocks input while a Codex dialog is open

When Codex shows an approval dialog, `orca terminal send` fails with `agent_prompt_blocked` and asks for
`--retry-request`. Re-issuing still fails while the dialog is open.

Verified workaround: answer the dialog through the visible window instead of the terminal channel.

```text
orca terminal switch --terminal <handle> --json
orca computer press-key --app Orca --key Return --restore-window --no-screenshot --json
```

This is a UI action. Prefer removing the dialog entirely by running Codex in no-approval mode (section 3).

## 3. Always-on no-approval mode

Set these top-level keys in every Codex config the runtime can load:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

This is equivalent to `codex --dangerously-bypass-approvals-and-sandbox`. It removes the interactive
approval dialog that otherwise blocks both the agent and Orca input, and it lets the agent write a linked
worktree's Git index, which is stored outside the worktree under the main repository's
`.git/worktrees/<name>/`. Without it, `git add`/`git commit` inside a linked worktree fails with
`index.lock: Permission denied`.

Security note: this grants unrestricted filesystem and shell access to the agent. Use it only on a
dedicated competition workstation with trusted repositories.

## 4. Orca worktrees need an Orca-managed repository

`orca repo add --path <dir>` registers a repository, but `orchestration worker-start --worktree new-child`
rejects a repository with no remote identity as a "folder project". Creating the checkout with
`orca worktree create --repo id:<repoId> --name <lane>` works and places the worktree under
`C:\Users\hoang\orca\workspaces\<repo>\<lane>`, matching the managed layout used by the other projects.

Do not hand-create Git worktrees outside that tree. They register as separate Orca repositories and
fragment the workspace list.

## 5. Catalog and provider must always switch together

Observed: the Codex `/model` picker listed `BTC - GPT-6 Luna`, `BTC - DeepSeek Flash`, `BTC - Gemini 2.5
Flash`, while the actually served provider was `commandcode`.

The picker label comes from `model_catalog_json`; the transport comes from `model_provider`. A catalog
from one provider combined with another provider's endpoint offers model IDs the endpoint may not serve,
which surfaces at request time as an unsupported-model error rather than at selection time.

Rule: switch the preset block as one unit - `model`, `model_provider`, `model_catalog_json`, and
`forced_login_method` together. Never mix a catalog from one provider with another provider's endpoint.

Verification that a run really used the intended provider: read the worker session's
`session_meta.model_provider` under the active `CODEX_HOME` `sessions/` tree. The picker label is not
evidence.

## 6. Codex config layering under Orca

Orca-launched Codex terminals read a managed home, not the user's default. In this environment the
effective home for agent terminals was:

```text
C:\Users\hoang\AppData\Roaming\orca\codex-runtime-home\home
```

Editing only `C:\Users\hoang\.codex\config.toml` originally left Orca workers on the previous model because
Orca and the managed app-server retained the earlier home/catalog in memory. The verified launcher is now:

```text
C:\Users\hoang\.codex\codex-orca.cmd
```

It pins `CODEX_HOME`, synchronizes the active catalog cache across discovered Orca homes, and runs the
official `codex app-server daemon restart` only when the provider/model/catalog fingerprint changes.
Orca Arguments must be empty because the wrapper already supplies no-approval and hook-trust flags.

Do not restart on every same-preset worker launch: that interrupts active parallel Codex sessions.

## 7. Token and cost accounting

Real per-worker token counts are available from the Codex session rollout files:

```text
<CODEX_HOME>/sessions/<year>/<month>/<day>/rollout-*.jsonl
```

Read the `token_count` payload's `total_token_usage` (`input_tokens`, `cached_input_tokens`,
`output_tokens`, `reasoning_output_tokens`). Record them through `scripts/spend-ledger.ps1`, and always
label non-BTC transports as `SIMULATED_ROUTING_NON_BTC_TRANSPORT`.

## 8. Hook scope and skill scope

Competition AI Log hooks are project-local under the official repository `.codex/hooks.json`. User-level
`CODEX_HOME/hooks.json` may contain unrelated personal hooks and must not be overwritten by bootstrap.
Preflight validates project hooks; a real canary proves execution by matching local and server events to
the rollout session ID.

Codex user skills live under `<CODEX_HOME>/skills`; project skills live under `.agents/skills` (or
`.codex/skills`). The kit installs only the five AITC operational skills globally by default. Do not bulk
copy Pi skills into competition Codex because Pi-specific tools and external services may be unavailable
or prohibited.
