# Team Workflow

This harness follows SS-WD principles: Chief-led decomposition, visible member workspaces, one writer per scope, evidence before integration, and fail-closed identity/cleanup.

## Roles

- Leader `kyoo-147`: plans, assigns, reviews, integrates, verifies, and merges.
- Minh `navincase0001`: LLM/retrieval/agent/research lane; branches `minh/*`.
- Long `navincase0002`: ML/data/inference/evaluation lane; branches `long/*`.

## Standard sequence

1. Leader fetches official sources and converts the challenge into bounded tasks.
2. Member clone verifies Git/SSH/GitHub identity.
3. Member updates clean `main`, creates the required prefixed branch, implements and tests.
4. Member pushes branch and opens PR; no self-merge by default.
5. Leader reviews actual diff/tests/runtime/evidence, requests fixes or squash-merges.
6. Leader verifies `origin/main` and submission staging.

## Required preflight

```bash
git config --get user.name
git config --get user.email
git remote get-url origin
git status --short --branch
ssh -T <profile-host>
git fetch origin --prune
git pull --ff-only origin main
```

Wrong/unknown identity, dirty ambiguous state, missing monitoring, missing authorization, or unverified official rule is `BLOCKED`; never silently fall back.

## Branches

- Leader: `cuong/<slug>`
- Minh: `minh/<slug>`
- Long: `long/<slug>`

No direct push or force-push to `main`. Use PRs and squash merge. Account separation does not create independent human review; the actual named member must review.
