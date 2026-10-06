# Codex Settings Optimization

This is a read-only audit baseline for the local Codex home. It contains no credential values.

## Safe baseline

- Keep one active provider/model/catalog preset.
- Use the canonical `codex-orca.cmd` wrapper so `CODEX_HOME` and the runtime fingerprint are stable.
- Keep only the three AITC skills installed by default: Captain, Worker, Reviewer.
- Load UI/build rules only when the task is UI/product work.
- Keep hooks enabled for competition sessions.
- Use the smallest reasoning level that passes the task.
- Use a short common context prefix and a small worker brief to improve cache reuse.
- Do deterministic inspection, tests, formatting, and parsing without a model.

## Current local observations

- Codex CLI: 0.160.0.
- Orca: 1.4.215.
- User Codex skills after cleanup: three AITC skills plus task-specific `lavish`, `stow`, and `tldraw-offline`.
- Re-creatable Codex cache observed: about 19 files and 122 MB.
- Active configuration contains browser, visualization, document, PDF, spreadsheet, presentation, template, calendar, and Slack plugins.
- `node_repl` is the only configured MCP server.
- The stale `lavish.backup-*` skill folder was removed.

## Do not delete automatically

- `sessions/`, rollout files, or AI Log evidence.
- `models-*.json` catalogs while a session may use them.
- hooks, project trust entries, or the canonical wrapper.
- `lavish`, `tldraw-offline`, or `stow` without confirming the user's current workflow.
- active runtime/plugin files while Orca or Codex is running.

## Safe optional cleanup

Only after closing Codex/Orca sessions and confirming no current task uses them:

- stale remote plugin catalogs;
- old app directory/server-info/tool cache entries;
- old ambient suggestions and attachments that are not evidence;
- unused project trust entries, one at a time, after checking the path.

These are re-creatable caches, not competition evidence. Never claim cleanup unless the before/after size and process impact are checked.

## Security finding

Provider bearer-token lines and an unrelated Anthropic auth line were present in the local config before this audit. Their values were not copied into the repository. The lines were removed from the local config; the credentials must be rotated because they were exposed in local configuration history/output. Future providers must read credentials from environment variables or a secret manager, not `config.toml`.

## Worker audit

A real Orca Codex worker was spawned with a read-only settings-audit brief. It received a `turn_started` receipt, but the active provider returned HTTP 429 and the worker did not produce a report. That is `BLOCKED`, not evidence of a completed audit.
