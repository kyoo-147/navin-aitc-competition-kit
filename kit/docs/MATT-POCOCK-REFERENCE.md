# Matt Pocock Skill Reference

Reference repository: https://github.com/mattpocock/skills

The kit does not bulk-install this repository. It borrows only the operating ideas that fit a two-hour competition:

- `grill-me` / `grill-with-docs`: clarify product ambiguity and preserve decisions;
- `implement`: build one complete outcome from a spec;
- `tdd`: red → green vertical slices at public seams;
- `diagnosing-bugs`: reproduce first, then fix root cause with a regression check;
- `code-review`: review Standards and Spec separately;
- `retro`: turn repeated mistakes into rules or deterministic checks.

Competition adaptation:

- no 20-node task graph;
- no bulk skill installation;
- no issue tracker requirement;
- maximum two concurrent writers and one read-only reviewer;
- research, prototype, PRD, implementation, integration, and E2E remain explicit phases;
- Captain decides when to dispatch and when to work directly.

This is a reference and is not an allowlist for external providers, tools, or competition resources.

## Competition adaptation implemented

The active adaptation is defined by `docs/ENGINEERING-LOOP.md` and the Captain, Worker, and Reviewer skills. Supporting templates are `PRODUCT_SPEC.md`, `VERTICAL_SLICE.md`, `GLOSSARY.md`, `ADR.md`, `REVIEW_REPORT.md`, and `SHORT_RETRO.md`.

The adaptation keeps clarification, shared language, prototype gates, explicit non-goals, behavior-first feedback loops, fixed-point review, and retro. It deliberately omits the mandatory issue tracker, large ticket frontier, unbounded implementer fanout, and PR ceremony that do not fit a two-hour round.
