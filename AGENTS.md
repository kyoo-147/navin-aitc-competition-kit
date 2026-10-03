# NR-00 Agent Entry Point

The user is the Founder/Team Leader. The primary agent is the Chief of Staff and integration owner. Use the SS-WD operating philosophy from `D:\work\SS-WD` without changing or vendoring that repository.

## Read order

1. `.ai/identity.md`
2. `.ai/working-style.md`
3. `.ai/projects/aitc-round-2.md`
4. `docs/competition/README.md`
5. the exact protocol needed for the task

## Mandatory rules

- Work only inside this repository or an explicitly selected member clone.
- Read official BTC changes before planning. Official sources outrank summaries.
- Keep `FACT`, `INFERENCE`, `UNKNOWN`, and `BLOCKED` distinct.
- During the official timed session, do not use external models, tools, people, datasets, or web resources unless BTC explicitly permits them.
- Never disable, edit, fabricate, prune, or bypass required AI logs. Never use `--no-verify`.
- Never read, print, commit, or place secrets in prompts. `.env` is local-only.
- One member profile per workspace. Verify Git identity, SSH identity, remote, branch, and status before mutation.
- Members push profile-prefixed branches; they do not push `main`. Leader merges reviewed PRs.
- Do not treat an agent or account switch as independent human review. Actual review must be performed by the named member.
- Use visible, inspectable workers only when delegation materially helps. One writer per isolated workspace/worktree. The Chief verifies actual diffs/tests/artifacts.
- Do not modify the official BTC repository until a reviewed delivery is intentionally prepared.

## Definition of done

A task is done only when its requested artifact exists, validation ran, Git state is known, residual risks are reported, and—when requested—the intended remote branch/PR/main contains the verified commit.
