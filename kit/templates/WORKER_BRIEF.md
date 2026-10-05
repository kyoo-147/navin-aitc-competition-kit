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
## MAX_SPEND / MODEL TIER

T1 by default. Escalate only through Captain.
