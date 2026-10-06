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
challenge / idea
→ ask OFFICIAL or DRILL
→ Spec Broker structures the input
→ factual research + technical + UX scouts investigate as needed
→ Human Brief
→ Architecture direction
→ Design Studio directions + UX / Design / Experience prototype
→ independent design review + human feedback
→ Architecture Lavish LOCK + UX / Design Lavish LOCK
→ compile PROJECT / ARCHITECTURE / UX_FLOW / DECISIONS / TASKS
→ deterministic implementation gate
→ highest-value Lane A || second independent Lane B
→ real minute 40-50 integration canary
→ lanes finish independently
→ real full E2E
→ fixed-point review
→ commit/push/submit when authorized
→ short retro
```

The Spec Broker is a compiler from unstructured challenge text to structured requirements. It exposes unknowns and human decisions; it cannot make architecture or UX decisions. The two Lavish artifacts are mandatory decision surfaces, not optional decoration. Their user-approved state becomes repository source of truth and is hash-locked by `scripts/lock-project.ps1`.

## Clarification gate

Captain asks at most one to three questions before dispatch. Ask only when the answer changes product behavior, platform, cost, security, acceptance, or a hard-to-reverse decision. Facts that can be researched are the Captain's job. Safe technical choices are assumptions and do not block non-dependent work.

Persist durable language in `GLOSSARY.md` and hard-to-reverse decisions in short ADRs. Do not create either for trivial or temporary choices.

## Pre-implementation and prototype gate

Implementation is blocked until the brief, Architecture Lavish, UX / Design / Experience Lavish, and project contract are explicitly locked by the user. The second artifact must be a real interactive HTML wireframe plus visual directions, components, states, responsive behavior, accessibility and tokens; Markdown is insufficient. A prototype remains decision evidence, not production code, unless it later passes production acceptance independently.

## Spec gate

A spec contains the problem, solution, user stories, implementation decisions, testing seams, and explicit out of scope. Synthesize settled discussion; do not restart the interview. Prefer existing public seams and the smallest number of new seams.

## Vertical slices

The locked project contract defines the final vertical slice and `LOCK_BASE_SHA`. Implementation uses at most two deliberately independent, architecture-selected lanes: Lane A is the highest-value subsystem and Lane B is the second independent subsystem. They meet at a real minute 40-50 canary, continue remaining scope after it passes, and only then undergo final integration. Each lane must pass its own acceptance; the integrated result must deliver the narrow end-to-end behavior and remove critical-path mocks.

Never exceed two concurrent writers. Dependency graphs remain small and explicit; no workflow engine is required.

## Open-ended research and multimodal generation

When content depends on current/domain facts, research the normal web first and retain sources; external AI and copied code/templates are forbidden. For a small multimodal web product, prefer one full-stack app with server routes to BTC Gateway and file-backed generated assets unless requirements justify heavier infrastructure.

Lock live API limits, modalities, media counts, and MUST/SHOULD/OPTIONAL scope in the canonical contract. Prefer one validated structured generation request. Every media request uses a locked image/video prompt contract, prompt hash, manifest lookup, duplicate prevention, bounded retry, and secret-free request ledger. Start mandatory video early after structured content and poll within live limits.

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
