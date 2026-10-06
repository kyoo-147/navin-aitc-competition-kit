# One Prompt to Captain, Evidence Back

The user speaks to one Captain. The Captain decides whether to work directly or spawn lanes; the user does not need to write worker commands.

## Mandatory intake and lock

1. Ask whether this is `OFFICIAL` or `DRILL`; do not infer it.
2. In official mode, use only the verified clone of `ai-thuc-chien/aitc2026-team-918-navin-research`, with team-created files under `chung-khao/`.
3. Run Spec Broker and parallel read-only requirements, technical, and UX investigation.
4. Brief the user, then create exactly two review surfaces with Lavish: Architecture and interactive UX Flow.
5. Poll feedback until the user explicitly locks both.
6. Compile the five source-of-truth documents and create `PROJECT_LOCK.json`.
7. Run `implementation-gate.ps1`; implementation remains forbidden until it prints `IMPLEMENTATION ALLOWED`.

## Routing after lock

1. Read the locked task graph and frozen API/state contract.
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
- For a product with both surfaces, spawn one backend writer and one frontend writer in separate worktrees from exact `LOCK_BASE_SHA`. They work independently against the frozen contract, meet at the early real integration canary around minute 40-50, then continue their remaining scopes.
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

Do not accept agent prose. Require both architecture-selected lane commits and checks; run the early real integration canary before remaining scope, then require requirement satisfaction, code, targeted tests, build/typecheck, real full-product flow without critical-path mocks, integrated branch, and deployment proof when required. Label missing proof `UNVERIFIED` or `BLOCKED`.
