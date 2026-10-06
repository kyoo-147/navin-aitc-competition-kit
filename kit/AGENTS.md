# NAVIN AITC Agent Instructions

Read `RULES.md`, `docs/OFFICIAL-REPO-BOUNDARY.md`, and the applicable runbook before acting.
Read `RULES.md`, `docs/OFFICIAL-REPO-BOUNDARY.md`, and the applicable runbook before acting. For product and UI work, also read `docs/codex/BUILD_PLAYBOOK.md`, `docs/codex/TASTE_UI.md`, and `docs/codex/AGENTS.md`; competition rules and live BTC instructions override those general guides.

## Required behavior

- Verify the exact repository, branch, HEAD, remotes, and dirty state before edits.
- Read project-local instructions before changing code.
- Work only in the assigned checkout or isolated worktree.
- Use BTC Gateway only during competition.
- Never read or print secret files. Never include secrets in prompts.
- Fail closed when Gateway identity, budget, hooks, or server-side AI logging is unverified.
- Launch Codex through the canonical `codex-orca.cmd`; direct `codex` is invalid when effective `CODEX_HOME` is unknown.
- Treat `session_meta.model_provider = thucchien` as provider proof; picker/footer labels are not proof.
- Prefer reuse, small interfaces, and the smallest complete vertical slice.
- Reproduce failures, fix root causes, add targeted tests, and rerun the user path.
- Do not claim completion from worker prose alone.

## Parallel work

The captain may use at most three lanes:

1. writer A;
2. writer B;
3. read-only reviewer or scout.

Never run more than two concurrent writers. Every writer has an isolated Orca-managed worktree. The third lane cannot write to a writer worktree.

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
