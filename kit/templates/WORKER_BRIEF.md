# Worker Brief

## OUTCOME

One complete result, written as an observable behavior.

## OWN

- `path/or/module`

## DO_NOT_TOUCH

- `path/or/module`

## ACCEPTANCE

1. ...
2. ...
3. ...

## PUBLIC TEST SEAM

`<API, CLI, UI flow, or public module interface>`

For a bug, provide one already-run command that reproduces the exact symptom before implementation. For a feature, identify the first behavior check that should go red.

## VERIFY
## VERIFY

```text
<targeted test or command>
<build/typecheck if relevant>
<real smoke path>
```

## RETURN

- status;
- changed files;
- verification results;
- commit SHA;
- blockers/integration notes.

## RUNTIME

- official repository/worktree:
- BTC-only; worker must not change provider/catalog/home:
- no secret or `.env` reads:
- expected provider proof: `session_meta.model_provider = thucchien`:

## EVIDENCE RETURN

- session ID and rollout path;
- provider metadata;
- exact Git branch/HEAD/status;
- local AI Log status when required.

## MAX_SPEND / MODEL TIER

T1 by default: choose the cheapest live canary-passing candidate. Prefer `gpt-6-luna` for Codex Responses or `deepseek-flash` for a validated chat harness. T2 may use `gpt-5.6-luna` or `deepseek-v4-pro`. T3 is read-only final review with `gpt-5.6-sol` and Captain approval. Never change provider, catalog, or `CODEX_HOME`.

## SECURITY

Never read `.env`, credential stores, SSH keys, browser profiles, or private vaults. If the application needs a secret, the human sets the environment variable and the application reads it; the worker must not see the value.
