# Codex scopes and Pi migration for competition

## Scope policy

### Machine/admin scope

Do not install competition keys, hooks, or broad skill bundles machine-wide. Machine-wide changes need administrator impact, are harder to audit, and can affect unrelated Windows users. Keep only required executables on PATH: Git, Python, PowerShell, Bash, Codex, and Orca.

### User scope (recommended)

Use one canonical home:

```text
C:\Users\hoang\.codex
```

User-scoped assets:

```text
config.toml
models-btc.json
models-commandcode.json
codex-orca.cmd
codex-runtime-refresh.ps1
skills\aitc-*
```

This scope follows every Orca worktree and avoids copying operational skills into the organizer repository. Secrets do not belong in this directory's committed artifacts; load organizer keys from the official clone's ignored `.env` or current process.

### Project scope

Codex discovers repository skills under `.agents/skills` and `.codex/skills`. Use project scope only when the files are intentionally reviewed for that repository and organizer rules permit adding them. Project AI Log hooks stay in the official root `.codex/hooks.json` and must not be replaced by user hooks.

For the official competition repository, prefer user-scoped AITC skills plus root `AGENTS.md` and organizer hooks. Do not dirty `main` merely to duplicate globally installed skills. If project-local installation is approved:

```powershell
.\kit\scripts\install-skills.ps1 -Scope Project -ProjectPath D:\path\to\official-repo
```

Review and commit those files deliberately, or remove them before submission; never hide required source changes with local excludes.

## What to migrate from Pi

Pi settings are not Codex configuration. Do not copy `~/.pi/agent/settings.json` into Codex. Translate only durable behavior into `AGENTS.md`, Codex config, and compatible `SKILL.md` files.

### Install for competition

Install only the three reviewed AITC skills:

- `aitc-captain`
- `aitc-worker`
- `aitc-reviewer`

These are provider-safe operational skills and are maintained in this kit.

### Reuse only when the live challenge requires it and BTC permits it

Potentially portable Pi skills include GitHub, commit discipline, Playwright/browser testing, accessibility, web quality/performance, React/frontend guidance, CLI design, and deployment guidance. Before copying any one skill, inspect it for Pi-only tools, external model calls, web services, tokens, or absolute paths, then test it in Codex.

### Do not bulk migrate

Do not automatically copy Pi skills for subagents/council, Pi session sharing, Pi memory, Grok/native web search, personal browser profiles, email/Google Workspace, Sentry, external image generation, Oracle/second-model review, Vercel tokens, transport tools, or unrelated product workflows. They either depend on Pi-specific tools, external services, personal state, or capabilities that may be prohibited during the timed round.

Existing non-AITC Codex user skills/plugins should be treated as unavailable during competition unless the live rules explicitly permit them. The Captain brief must say BTC-only and no external provider/tool fallback.

## Pi settings mapping

| Pi setting/behavior | Codex equivalent | Action |
|---|---|---|
| default provider/model/thinking | `config.toml` atomic preset | configure explicitly |
| shell path | Orca terminal `--shell cmd.exe` and exact commands | document, do not copy JSON |
| user preferences/rules | project `AGENTS.md` | translate relevant rules |
| Pi skills | Codex `<CODEX_HOME>/skills` or `.agents/skills` | selective compatibility review |
| Pi subagents | visible Orca Codex terminals/worktrees | use AITC Orca runtime skill |
| Pi memory | repository docs/contracts/evidence | do not migrate private memory |
| Pi packages/extensions | no automatic equivalent | install only if organizer-authorized |
| theme/UI settings | none needed for task execution | do not migrate |

## Installation and verification

```powershell
# User scope
.\kit\scripts\install-skills.ps1 -Scope User -CodexHome "$HOME\.codex"

# Confirm files
Get-ChildItem "$HOME\.codex\skills\aitc-*\SKILL.md"

# Refresh runtime only if preset/catalog changed
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\codex-runtime-refresh.ps1"

# Open through the canonical wrapper
& "$HOME\.codex\codex-orca.cmd"
```

After changing skills, open a new Codex session or force a skills reload. Skill presence does not prove provider or AI Log compliance; use rollout metadata and session preflight.
