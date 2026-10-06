# Competition Engineering Loop

This is the small, competition-safe adaptation of ideas from Matt Pocock's MIT-licensed `mattpocock/skills` repository. The upstream license is in `licenses/Matt-Pocock-MIT.txt`; attribution and adaptation notes are in `THIRD_PARTY_NOTES.md`.

## Principles

1. Clarify the requirement before coding.
2. Use a shared product vocabulary to reduce ambiguity and repeated context.
3. Deliver narrow, verifiable vertical slices.
4. Build the shortest reliable feedback loop.
5. Review Spec, Standards, and Competition Provenance independently.
6. Improve the agent environment after each drill instead of only repairing code.
7. Keep the user in control; the workflow serves decisions rather than owning them.

## Main flow

```text
idea
→ clarification gate
→ prototype only if a runnable answer is needed
→ spec with explicit out of scope
→ one or a few vertical slices
→ implementation with red/green feedback
→ fixed-point review
→ integration and real E2E
→ commit/push/submit when authorized
→ short retro
```

## Clarification gate

Captain asks at most one to three questions before dispatch. Ask only when the answer changes product behavior, platform, cost, security, acceptance, or a hard-to-reverse decision. Facts that can be researched are the Captain's job. Safe technical choices are assumptions and do not block non-dependent work.

Persist durable language in `GLOSSARY.md` and hard-to-reverse decisions in short ADRs. Do not create either for trivial or temporary choices.

## Prototype gate

Prototype only when conversation cannot settle a question. A prototype answers one question about state, flow, interaction, or architecture. It is evidence, not production code, unless it later passes production acceptance independently.

## Spec gate

A spec contains the problem, solution, user stories, implementation decisions, testing seams, and explicit out of scope. Synthesize settled discussion; do not restart the interview. Prefer existing public seams and the smallest number of new seams.

## Vertical slices

Each slice must deliver a narrow end-to-end behavior across the necessary layers and be demoable alone. Avoid horizontal tickets such as "build database" or "build frontend" unless a mechanical refactor cannot remain green as a vertical slice.

For a two-hour round, use one slice whenever possible. Never exceed two concurrent writers. Dependency graphs remain small and explicit; no workflow engine is required.

## Feedback-loop gate

A feature uses one test at a public seam, one minimal implementation, then repeats. A bug must have one command that can reproduce the user's exact symptom before root-cause theories drive implementation. The loop should be deterministic, fast, and agent-runnable.

For hard bugs:

```text
feedback loop
→ reproduce
→ minimise
→ rank 3-5 falsifiable hypotheses
→ instrument one variable at a time
→ regression test
→ fix
→ rerun original flow
→ remove debug instrumentation
```

If no correct test seam exists, report that architectural limitation rather than adding a misleading test.

## Fixed-point review

Pin a SHA, branch, tag, or merge base before review. Review `git diff <fixed-point>...HEAD` and keep three reports separate:

- Spec: missing, partial, wrong, or unrequested behavior.
- Standards: documented-rule violations and material design smells.
- Competition Provenance: provider, AI Log, tests, runtime, Git/worktree, spend, and submission evidence.

One passing axis must not hide a failure in another.

## Short retro

After each drill or significant failure, identify at most three environment improvements. Prefer, in order:

1. deterministic lint/test/hook;
2. navigation pointer;
3. reviewer-only judgement rule;
4. tool or context-economy improvement.

Mechanical mistakes become checks, not more prose in global instructions. Apply changes only after confirming they are reusable and do not conflict with live competition rules.

## Context economy

Keep common rules stable and point workers to source files. Worker prompts contain only assignment-specific outcome, ownership, acceptance, seams, model tier, and return evidence. Do not duplicate the entire spec in every prompt. Start a fresh worker context per independent slice.
