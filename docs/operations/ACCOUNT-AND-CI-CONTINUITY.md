# Account and CI Continuity Runbook

## Purpose

Keep legitimate team work moving when one member has an authentication outage, local credential failure, quota issue, or temporary unavailability. This runbook never authorizes bypassing GitHub enforcement, BTC rules, account suspension, billing restrictions, or access controls.

## Authority

- `kyoo-147` is the normal repository administrator and integration leader.
- `navincase0001` and `navincase0002` are authorized collaborators with `write` access. They may fetch, create/push their own branches, open/review PRs, and merge PRs when GitHub permissions and the leader's assignment allow it.
- Every action must use the acting member's real profile, SSH key, Git identity, isolated GitHub CLI configuration, and workspace.
- Never share passwords/tokens or silently fall back to another profile.

## Leader unavailable

For an ordinary login/token/device/quota outage:

1. Record the incident and exact limitation without secrets.
2. A member continues only within existing GitHub permission and assigned scope.
3. Work remains branch-first; no force-push or direct push to `main`.
4. Another actual member reviews the diff. Account switching by one operator is not independent review.
5. Merge through GitHub only after local gates pass and repository state is current.
6. Inform the leader and reconcile decisions when access returns.

If GitHub disabled/suspended/locked an account or repository for enforcement, policy, security, abuse, or billing reasons, **do not use another account to evade the restriction**. Stop affected operations, preserve local work, contact GitHub support and BTC when relevant, and wait for authorized resolution.

## CI unavailable

Changing actor accounts does not repair repository/account-level GitHub Actions `startup_failure`. When CI cannot start:

1. Label status `CI UNAVAILABLE`; do not report CI passed.
2. Run the authoritative local gates from a clean, current checkout:

```powershell
python scripts/verify_harness.py
python -m unittest discover -s tests -v
git diff --check
git status --short --branch
```

3. A second real member reruns the same gates in their isolated clone when available.
4. Attach exact commands/results to the PR without secrets or private logs.
5. Merge only if the challenge timeline requires it, local gates pass, review is complete, and no BTC rule requires hosted CI.
6. Retry hosted CI after the service/account issue is resolved.

Do not mirror private competition code to another account/repository merely to obtain free CI unless the leader explicitly approves it and BTC rules permit that repository/resource.

## Emergency merge

A member may merge an approved PR only when:

- their GitHub account has permission;
- the PR is current with `main` and has no unresolved conflict;
- required local gates passed;
- the actual diff was reviewed;
- the merge does not circumvent a GitHub/BTC restriction;
- the action and evidence are recorded.

Use squash merge and delete the branch. Never force-push `main`.
