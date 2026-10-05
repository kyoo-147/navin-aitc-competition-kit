# One Prompt to Captain, Evidence Back

The user speaks to one Captain. The Captain decides whether to work directly or spawn lanes; the user does not need to write worker commands.

## Routing

1. Read the task and extract one smallest complete vertical slice.
2. Do T0 work first: inspect files, tests, contracts, and existing scripts without a model.
3. If model work is needed, select the cheapest live canary-passing candidate:
   - `gpt-6-luna` for Codex Responses;
   - `deepseek-flash` for a validated Chat Completions worker;
   - Gemini Flash Lite only for a validated compatible harness.
4. Use `gpt-5.6-luna` or DeepSeek V4 Pro only for harder integration after evidence.
5. Use `gpt-5.6-sol` only for a final read-only review or a verified scoring-critical blocker, with Captain approval.

The dated snapshot is not a live allowlist. `/key/info`, current catalog, canary, and response cost headers override it.

## Spawn rule

- Small task, overlapping ownership, or expensive merge: Captain works directly.
- Independent outcomes with non-overlapping paths: spawn at most two writer worktrees.
- Optional third lane: one read-only scout/reviewer; it must not write to a writer worktree.
- Every writer gets an Orca-managed worktree and terminal. Capture worktree ID, terminal handle, `turn_started`, cursor-poll output, rollout session ID, provider metadata, tests, and Git status.

## Prompt contract

```text
OUTCOME: one observable vertical slice
OWN: exclusive writable paths
DO_NOT_TOUCH: protected paths and secrets
ACCEPTANCE: numbered observable requirements
VERIFY: exact tests, build, and real smoke path
RETURN: files, commands/results, blockers, SHA/status
MAX_SPEND / MODEL TIER: T1 unless Captain approves escalation
RUNTIME: official worktree, BTC-only, no provider/catalog/home changes
```

Workers must never read `.env`, credential stores, SSH keys, browser profiles, or private vaults. Humans set environment variables; application code reads them.

## Acceptance

Do not accept agent prose. Require requirement satisfaction, code, targeted tests, build/typecheck, real flow, integrated branch, and deployment proof when required. Label missing proof `UNVERIFIED` or `BLOCKED`.
