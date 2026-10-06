---
name: aitc-design-studio
description: Deterministic, local-only design pipeline using the BTC model and Lavish; compiles approved product taste into auditable design contracts.
---

# AITC Design Studio

This is a workflow, not a model or external design API. Use only the BTC-approved model route and local Lavish. Never use Claude Design, Figma AI, v0, Lovable, remote design APIs, cloud publishing, or a third design artifact.

## Gate

Run after Spec/Research, Human Brief, and an Architecture direction exist. The Design Studio creates the directions and prototype that feed the UX / Design / Experience Lavish artifact; it must not require that artifact to be approved before starting. If `screens.kind=CLI_ONLY`, explicitly set `screens.design_lock_required=false` and report `DESIGN LOCK SKIPPED: CLI-only`; missing/null is invalid.

For a UI project, the sequence is mandatory:

```text
SPEC / RESEARCH
  -> HUMAN BRIEF
  -> ARCHITECTURE DIRECTION
  -> DESIGN BRIEF
  -> 2-3 DESIGN DIRECTIONS
  -> HUMAN CHOICE IN UX / DESIGN / EXPERIENCE LAVISH
  -> UX / DESIGN / EXPERIENCE LAVISH
  -> INTERACTIVE WIREFRAME / PROTOTYPE
  -> DESIGN CRITIQUE BY A DIFFERENT READ-ONLY REVIEWER
  -> HUMAN FEEDBACK
  -> ARCHITECTURE LAVISH LOCK + UX / DESIGN LAVISH LOCK
  -> DESIGN CONTRACT
  -> DESIGN LOCK
  -> IMPLEMENTATION
```

## Design Brief

Read the locked contracts and produce `design/DESIGN_BRIEF.md` with structured values for:

```yaml
product_type:
target_user:
primary_job:
platform:
screen_count_estimate:
design_goal:
tone:
density:
interaction_style:
must_feel:
must_not_feel:
primary_action:
secondary_actions:
constraints:
accessibility:
responsive_targets:
```

This is the anti-taste-drift input. Facts come from the brief and contract; design choices are explicitly labeled choices.

## Directions and human choice

Generate two or three materially different directions. At minimum show typography, spacing, layout, navigation, component language, hierarchy, interaction pattern and one sample screen. The human may choose one direction or mix named attributes, for example `Layout=A; Typography=B; Navigation=A`. Record chosen and rejected directions in the existing UX / Design / Experience Lavish artifact, then wait for approval. Do not silently choose for the human.

## UX and prototype

Define screen map, user journey, inputs, outputs, actions and navigation. Every screen contract defines purpose, primary action, empty, loading, error, success, offline and permission states. Generate an interactive local HTML/CSS/JS prototype using inline CSS, system fonts, local SVG and inline JS only. No Tailwind CDN, Google Fonts, remote icon library, remote JS, remote assets, `lavish-axi share`, `ht-ml.app`, or publish command.

## Independent design critique

Use `aitc-reviewer` as a read-only reviewer with a design-review task. The generator must not approve its own prototype. Review only:

- hierarchy and flow clarity;
- consistency with the chosen direction;
- accessibility and keyboard path;
- responsive layout;
- requirement compliance;
- unnecessary complexity.

Return findings as `P0`, `P1`, or `P2`. P0/P1 must be fixed before lock. P2 may be recorded as removable scope. The reviewer must not redesign the whole application or change the chosen direction without human approval.

## Compiled handoff

After approval, compile exactly:

```text
design/
  DESIGN_BRIEF.md
  DESIGN_SYSTEM.md
  SCREEN_CONTRACTS.md
  COMPONENTS.md
  TOKENS.css
  DESIGN_LOCK.json
```

The FE worker implements these contracts; it may not invent a second component language. `DESIGN_LOCK.json` records the chosen direction, artifact, contract paths, reviewer result and approval identity. `DESIGN_LOCK` is required only when `screens.design_lock_required=true`.

## Handoff

Return `DESIGN_BRIEF`, `DIRECTIONS`, `HUMAN_CHOICE`, `UX_FLOW`, `PROTOTYPE`, `CRITIQUE`, `DESIGN_CONTRACT`, `DESIGN_LOCK`, exact files, and checks run. Preserve `VERIFIED`, `UNVERIFIED`, `BLOCKED`, `USER ACTION REQUIRED`, `DESIGNED/PROPOSED`, and `TARGET/UNMEASURED` labels. The Captain owns approval and integration.
