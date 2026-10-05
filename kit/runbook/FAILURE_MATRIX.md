# Failure Matrix

| Symptom | Required action |
|---|---|
| HTTP 400 | Compare endpoint, schema, and model with current BTC docs. Remove unsupported fields. |
| HTTP 401/403 | Stop. Verify the correct organizer key and endpoint without printing the key. Escalate if unresolved. |
| HTTP 429 | Check team spend, RPM, TPM, and parallel limits. Reduce concurrency/context and retry with bounded backoff. |
| HTTP 5xx/timeout | Use bounded idempotent retry. Change only to another live BTC model after confirming provider/model failure. |
| Codex answers but tools fail | Check Responses/tool compatibility and exact live model. Do not switch provider. |
| Picker shows the previous provider | Verify `CODEX_HOME` and the atomic preset, run conditional runtime refresh, open a new session, then inspect rollout provider. |
| Direct `codex` uses an Orca account home | Stop and launch `C:\Users\hoang\.codex\codex-orca.cmd`; do not trust inherited `CODEX_HOME`. |
| Orca `worker-start` times out at `agent_readiness` | Use visible terminal handoff, require `turn_started`, and poll with cursor reads. |
| `tui-idle` never satisfies | Treat it as advisory; inspect incremental output and verify Git/runtime evidence. |
| AI Log submit is not `202` | Stop model work. Preserve logs, repair official scripts/config, retry, then verify readback. |
| AI Log readback lacks required events | Launch Codex at repo root, check hooks, create a real event, submit, and read back again. Never synthesize logs. |
| Pre-push shows `bash\r` or BOM error | Normalize the local hook to UTF-8 without BOM and line endings compatible with Git Bash. |
| Merge conflict | Stop overlapping writers. Captain integrates or serializes ownership. |
| Hard bug survives two attempts | Use `$aitc-diagnose`, create a minimal repro, then escalate with reduced evidence. |
| Spend >= `$35` | Leader review before expensive work. |
| Spend >= `$42` | Economy mode. Stop redundant calls. |
| Spend >= `$45` | Block nonessential calls. Reserve only for approved P0/deploy/submission work. |
| Hosted Actions cannot start | Report `CI UNAVAILABLE`; run and report local checks separately. |
