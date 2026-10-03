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
