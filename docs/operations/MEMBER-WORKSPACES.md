# Member Workspaces on the Shared Machine

## Paths and identities

| Role | Local clone | GitHub | SSH host | Branch prefix | GH CLI profile |
|---|---|---|---|---|---|
| Leader | `D:\work\nr-00\nr-00` | `kyoo-147` | `github-aitc-leader` | `cuong/` | `leader` |
| Minh | `D:\work\nr-00\nr-00-member-workspaces\nguyen-doan-nhat-minh` | `navincase0001` | `github-aitc-minh` | `minh/` | `minh` |
| Long | `D:\work\nr-00\nr-00-member-workspaces\bui-hoang-long` | `navincase0002` | `github-aitc-long` | `long/` | `long` |

## Natural-language routing

- “Dùng profile Nhật Minh…” selects only Minh's clone/account and a `minh/*` branch.
- “Dùng profile Hoàng Long…” selects only Long's clone/account and a `long/*` branch.
- “Leader review/merge…” uses the leader clone and the isolated `leader` GitHub CLI wrapper.

Before mutation, the agent must print/verify name, noreply email, origin URL, current branch/status, `ssh -T` identity, and GH API identity. A mismatch is `BLOCKED`; never switch credentials silently.

## GitHub CLI

Use the isolated wrappers at:

```text
D:\work\nr-00\aitc-member-workspaces\scripts\gh-profile.ps1
D:\work\nr-00\aitc-member-workspaces\scripts\gh-profile.sh
```

Examples:

```powershell
D:\work\nr-00\aitc-member-workspaces\scripts\gh-profile.ps1 minh pr create ...
D:\work\nr-00\aitc-member-workspaces\scripts\gh-profile.ps1 leader pr merge ...
```

## AI log setup

Every clone must run `scripts/setup_hooks.*` locally and have the team AI-log `.env` configured locally. The token is never copied through Git or chat. A local push guard composes identity/branch checks with official log submission; rerunning BTC's setup script may overwrite that local guard, so restore/verify the guard before the next push.

## Persistent inspection mode

The leader prefers each member workspace to keep one visible Pi terminal open and idle after a task so work, history, and the next assignment are easy to inspect.

- After task settlement and merge, sync the member clone back to clean `main`.
- Close only the supervised task terminal owned by that dispatch when orchestration requires release.
- Then create or retain one clearly titled user-owned Pi terminal for that member workspace.
- Do not send new work automatically; leave the terminal idle until the leader assigns a task.
- Do not close, sleep, or remove these persistent member terminals/workspaces unless the leader explicitly requests cleanup or a verified security/resource issue requires escalation.
- Persistent terminal presence is convenience, not task evidence. Every new task still needs identity preflight, a fresh profile branch, bounded ownership, validation, and PR review.

Current intended titles:

```text
Pi — Nguyễn Đoàn Nhật Minh — navincase0001
Pi — Bùi Hoàng Long — navincase0002
```
