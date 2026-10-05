# NAVIN AITC Competition Kit

This directory is the design and implementation home for the reusable competition-day setup derived from the proven `kyoo-147/nr-00` harness.

## Intended deliverables

| Area | Tracked artifact | Local-only artifact |
|---|---|---|
| Rules and runbooks | `docs/competition/`, `docs/competition-kit/` | live notes containing private context |
| Model routing | `config/competition/*.json` | runtime model response if it contains team data |
| Orchestration | `skills/aitc-orchestrator/SKILL.md` | private worker transcripts |
| Secure setup | planned bootstrap and preflight scripts | `.env`, keys, account configuration |
| Verification | tests and redacted reports | raw AI logs and unredacted diagnostics |
| Submission | reviewed evidence manifest | credentials, monitoring recordings, PII |

## Build order

1. Lock rules, budget thresholds, and model-routing policy.
2. Implement a secret-safe bootstrap that accepts new BTC keys without printing them.
3. Implement a fail-closed preflight for Gateway, AI Log, Git identity, hooks, and spend.
4. Add fixture-based tests for redaction, auth failure, throttling, malformed payloads, and threshold behavior.
5. Add the orchestrator adapter for the approved coding agents.
6. Rehearse in disposable clones before using the official BTC repository.

## Current status

- Existing Round 2 knowledge pack and technical-test evidence workflow: inherited and previously verified in the source harness.
- Budget and router policies: initial proposal, subject to leader review.
- Model catalog: dated snapshot only; it is not a competition-day allowlist.
- Secure bootstrap, full preflight, spend guard, and orchestrator runtime: not implemented yet.

No secret belongs in this repository.
