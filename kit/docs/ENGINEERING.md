# Engineering Playbook

Use this only after current challenge instructions and repository rules are understood.

1. Map the real user, workflow, input, output, constraint, failure, and acceptance criteria.
2. Search the repository and official APIs before creating new code or dependencies.
3. Define one real end-to-end slice: real input, real processing, real output.
4. Prefer deterministic validation and software before model reasoning.
5. Keep model/provider access behind a small replaceable boundary.
6. Test early with malformed, missing, long, slow, and provider-failure inputs.
7. Design verification with the feature: schema, tests, cross-checks, human approval, rollback.
8. Deploy early enough to expose environment and integration failures.
9. Measure result quality, latency, spend, reliability, and intervention.
10. Expand only when evidence shows the next capability is needed.

A feature is incomplete if its real flow does not run, its failure path is hidden, or its evidence is only prose.
