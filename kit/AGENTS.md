# NAVIN AITC Agent Instructions

Read `RULES.md`, `docs/OFFICIAL-REPO-BOUNDARY.md`, and the applicable runbook before acting.

## Required behavior

- Verify the exact repository, branch, HEAD, remotes, and dirty state before edits.
- Read project-local instructions before changing code.
- Work only in the assigned checkout or isolated worktree.
- Use BTC Gateway only during competition.
- Never read or print secret files. Never include secrets in prompts.
- Fail closed when Gateway identity, budget, hooks, or server-side AI logging is unverified.
- Prefer reuse, small interfaces, and the smallest complete vertical slice.
- Reproduce failures, fix root causes, add targeted tests, and rerun the user path.
- Do not claim completion from worker prose alone.

## Parallel work

The captain may use at most three lanes by default:

1. integration and orchestration;
2. backend or AI implementation;
3. frontend/product surface, evaluation/data, or deployment.

Before parallel writers start, freeze `templates/IMPLEMENTATION_CONTRACT.md` into the project with request/response schemas, paths, states, ownership, and acceptance commands.

## Completion report

Include:

- exact changed files;
- commands run and outputs;
- runtime or deployment evidence;
- known risks and unverified items;
- branch and commit when delivery is authorized;
- one of `VERIFIED`, `UNVERIFIED`, `BLOCKED`, or `CI UNAVAILABLE`.

Do not add model names to commit subjects or co-author metadata.
