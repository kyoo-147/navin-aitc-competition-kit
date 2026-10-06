---
name: lavish
description: Turn complex or visual agent responses into rich, reviewable HTML artifacts the user can annotate and send feedback on, using the lavish-axi CLI. Use when about to give a plan, comparison, diagram, table, code diff, report, or anything easier to grasp visually than as prose.
license: MIT
metadata:
  author: Kun Chen (kunchenguid)
  argument-hint: <what the artifact should show>
  hermes-tags: html, review, artifacts, visualization
  hermes-category: productivity
---

# Lavish Editor

Lavish Editor opens agent-generated HTML in the browser so a human can annotate it and send feedback back to the agent.
Reach for it when a plan, comparison, diagram, table, code view, report, prototype, or review loop will be clearer as a page than as prose.

## AITC local-only override

Competition use is intentionally pinned and offline. Use only the preinstalled global `lavish-axi` executable at the exact version in `manifests/tools.json`; run `kit/scripts/lavish-offline-check.ps1` before lock. Never invoke `npx`, install or update at runtime, use `lavish share`, publish remotely, or reference remote assets, Tailwind CDN, Google Fonts, or remote JavaScript.

Allowed artifacts are local HTML with inline/local CSS, inline/local JavaScript, system fonts, and local SVG. Use:

- `lavish-axi --help` for commands and the review loop;
- `lavish-axi design` for design direction;
- `lavish-axi playbook <id>` for a relevant local playbook;
- `lavish-axi <html-file>` and the exact `lavish-axi poll ...` command returned by the CLI.

Do not use cloud sharing even when the CLI offers it. The local review session is the only approved AITC path.

## Request

$ARGUMENTS

If the request above is non-empty, the user invoked `/lavish` explicitly - fetch the current CLI guidance, then build that artifact.
If it is empty, infer what to visualize from the conversation.
