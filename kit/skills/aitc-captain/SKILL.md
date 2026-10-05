---
name: aitc-captain
description: Run a short AI coding competition: extract scoring requirements, choose the smallest complete product, dispatch independent workers through Orca, route BTC Gateway models by cost/evidence, integrate early, verify, freeze scope, and prepare submission.
---

# AITC Captain

Use this skill as the contest control plane. The goal is the highest-scoring working product within the fixed time, not the most elaborate architecture.

## Start

Read, in order:

1. the current official challenge/rules;
2. repository `AGENTS.md`/README/conventions;
3. this kit's `RULES.md` and `MODEL_ROUTING.md`;
4. only the additional skill/reference needed for the current task.

The official challenge overrides all prewritten assumptions.

## First 10 minutes

Extract an acceptance matrix with:

- required output/deliverables;
- required user-visible flows;
- mandatory technical constraints;
- scoring-critical features;
- deployment/submission requirements;
- unknowns that could invalidate the build.

Then choose the **smallest complete product** that can satisfy those requirements.

Do not design optional infrastructure before the first vertical slice exists.

## Decompose by coherent ownership

Default to two writer lanes, not many microtasks.

Good split examples:

- core/backend vs frontend/user-flow;
- ingestion/processing vs presentation/control;
- main implementation vs independent integration module.

Add read-only scout/reviewer lanes only when they are genuinely independent.

For each worker, provide exactly:

```text
OUTCOME
OWN
DO_NOT_TOUCH
ACCEPTANCE
VERIFY
RETURN
MAX_SPEND / MODEL TIER
```

If two workers would need to edit the same module repeatedly, serialize or redraw ownership instead of accepting merge conflict as normal.

## Scale rule

Spawn another worker only when:

- the task is independent;
- ownership does not overlap;
- acceptance is observable;
- integration cost is lower than expected time saved.

Otherwise do the work directly.

## Model routing

Use live Gateway information as truth. Start cheap. Escalate only from evidence. Premium/reasoning-heavy calls require Captain approval.

Never change provider/runtime silently after a task failure. Distinguish:

- provider/model unavailable;
- task/code failure;
- test failure;
- workspace/Git failure;
- contest-policy failure.

## Integration clock

Aim for the first real vertical slice by minute 55 or earlier.

Integrate before both lanes are "perfect". A working end-to-end path reveals contract mismatches while there is still time.

At approximately minute 90:

- freeze new features;
- run reviewer;
- fix only P0/P1 or scoring-critical P2 issues;
- deploy and smoke the real flow;
- preserve a known-good state.

## Accept worker output

Never accept a verbal completion message alone. Verify the diff, tests/build, runtime behavior, and repository state.

## Final report

Return only:

- what is working;
- what remains missing/blocking;
- spend band;
- verification evidence;
- next action required before submission.
