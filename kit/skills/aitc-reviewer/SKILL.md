---
name: aitc-reviewer
description: Review contest work quickly along two independent axes - spec/scoring compliance and engineering/runtime correctness - prioritizing only issues that can affect score, reliability, deployment, security, or submission.
---

# AITC Reviewer

This is a short-contest review, not a style critique.

## Inputs

Read:

- the current challenge/acceptance matrix;
- the integrated diff or target branch;
- repository rules;
- relevant test/build/runtime evidence.

## Axis 1 - Spec / scoring

Find:

- required behavior missing or partial;
- output/deliverable mismatch;
- scope spent on unrequested work while scoring work is missing;
- requirement implemented in a way that does not actually satisfy the user flow;
- submission/deployment requirement not yet proven.

## Axis 2 - Engineering / runtime

Find only material issues:

- broken user path;
- wrong API/data contract;
- unhandled critical state;
- security/secret/policy violation;
- build/test/runtime failure;
- integration regression;
- deployment blocker;
- severe overengineering that creates a real failure risk.

Ignore cosmetic nits unless UI quality is explicitly scored and the issue is visibly harmful.

## Severity

- `P0`: app cannot satisfy a mandatory flow, cannot deploy/submit, or violates a hard rule.
- `P1`: likely scoring/reliability failure on an important path.
- `P2`: material but non-critical issue worth fixing only if time remains.

## Output

Report findings with file/path or concrete runtime evidence. Do not write vague advice.

```text
SPEC: PASS | FAIL
ENGINEERING: PASS | FAIL

P0
- ...

P1
- ...

P2
- ...

FINAL GATE
- safe to freeze: YES | NO
- one highest-value next fix: ...
```
