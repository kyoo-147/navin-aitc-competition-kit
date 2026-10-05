---
name: aitc-diagnose
description: Diagnose a hard contest bug under time pressure by first building a tight reproducible feedback loop, then testing ranked hypotheses, fixing the root cause, and re-running the original flow.
---

# AITC Diagnose

Use for a real blocker that survived an ordinary fix attempt. This is adapted for a short contest: fast feedback first, theories second.

## 1. Build a red/green loop

Before theorizing, create the fastest reliable signal that catches the exact symptom:

1. targeted test;
2. curl/HTTP request;
3. CLI fixture;
4. browser smoke;
5. minimal replay/harness.

The loop must be able to fail on the reported bug and pass after the fix. "It did not crash" is not enough.

## 2. Reproduce and minimize

Confirm the loop shows the same symptom the user/acceptance flow shows. Remove irrelevant inputs/steps until the smallest useful repro remains.

## 3. Rank hypotheses

Create 2-3 falsifiable hypotheses. For each, state what observation would disprove it. Test the highest-value discriminator first.

Do not scatter logs everywhere. Add only targeted instrumentation and label temporary debug output so it can be removed.

## 4. Fix the cause

Where a correct test seam exists:

- keep the repro red;
- add/retain a regression check;
- make the smallest root-cause fix;
- make the check green;
- rerun the original full flow.

## 5. Timebox / escalate

If two bounded attempts or roughly 8 minutes do not materially narrow the cause:

- summarize the repro and eliminated hypotheses;
- escalate to the Captain;
- recommend a stronger model only with the evidence/context already reduced.

Do not spend premium reasoning on an unstructured dump.

## 6. Cleanup

Remove temporary instrumentation, rerun the original flow, and return the root cause plus verification evidence.
