# Third-party methodology notes

This kit contains original competition-specific adaptations informed by public MIT-licensed projects. It does not vendor their runtimes or application source.

## Matt Pocock - `mattpocock/skills`

Upstream: https://github.com/mattpocock/skills

Reviewed revision: `4588b32`

MIT License. Concepts adapted into the competition skills include:

- small/composable skills rather than a giant framework;
- implementation with frequent feedback;
- behavior-focused testing at public seams;
- debugging by establishing a tight red/green feedback loop before theorizing;
- separating spec compliance from engineering/standards review;
- decision-focused grilling, shared domain vocabulary, and short ADRs;
- prototypes as decision evidence rather than automatic production code;
- explicit out-of-scope boundaries;
- tracer-bullet vertical slices and small dependency frontiers;
- fixed-point diff review;
- retrospectives that improve checks, navigation, standards, and tool economy.

The competition-specific prose and templates are modified adaptations, not verbatim upstream workflow files. The kit preserves user control, limits concurrent writers to two, adds BTC provider/log provenance, and removes the upstream requirement for a large issue-tracker/task-graph workflow.

The original MIT license text is included at `licenses/Matt-Pocock-MIT.txt`.

## NAVIN Research SS-WD - `kyoo-147/SS-WD`

MIT License. Concepts adapted include:

- separation of control plane, runtime host, and worker harness;
- visible workers;
- one isolated worktree per concurrent writer;
- selective delegation;
- exact runtime/workspace identity;
- evidence-based acceptance and conservative cleanup;
- Orca as a replaceable runtime host rather than the orchestration architecture itself.

The original MIT license text is included at `licenses/SS-WD-MIT.txt`.

## Competition use

These methodologies are prepared before the contest. The kit intentionally contains no starter application/source template to copy into the BTC contest repository.
