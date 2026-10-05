# Michael's UI Taste

These are Michael's default principles for designing or modifying UI.

## Core

- Understand the purpose of the screen before thinking about its layout.
- Each screen should have one clear primary task.
- UI exists to help users complete work, not to decorate the product.
- When a UI is not working, remove and simplify before adding.
- Do not add features merely because there is empty space.
- Do not make the UI more complex than necessary.

## Vibe and Consistency

- The UI must match the vibe, concept, and style Michael requests.
- When a reference exists, follow it closely instead of creating an unrelated interpretation.
- Typography, spacing, radius, icons, buttons, colors, and component behavior must remain consistent.
- Do not let AI create a new convention on every page.
- The same action must use the same name, style, and behavior everywhere.

## Hierarchy

- Every screen needs a clear visual priority.
- Use size, weight, contrast, and spacing to guide attention.
- The primary element does not need to be made excessively large.
- Reduce the prominence of secondary content when necessary so the primary task remains clear.
- Hide or collapse infrequently used actions.
- Prefer progressive disclosure over showing everything at once.

## Color

- Color must have a purpose: brand, state, priority, data, or action.
- Interface chrome should be relatively muted so important content stands out.
- Do not default to saturated blue, purple, gradients, or glow effects.
- Do not use color merely to make the UI look "AI-generated".

## Icons

- Use one consistent icon system.
- Do not use emoji as UI icons.
- Do not mix multiple icon libraries without a clear reason.

## Layout

- Avoid repetitive AI-generated layouts.
- Not every dashboard needs KPI cards, a chart, and an activity feed.
- Do not pack too much information into a card, row, or table.
- Prioritize appropriate density and fast scanning.

## Real Data

Always test the UI with difficult data:

- Very long names
- Null values
- Missing images
- Text overflow
- Very large numbers
- Very long lists
- Thousands of rows
- Uneven content

The UI must not look good only with ideal mock data.

## States

Empty, loading, and error states are real screens.

Do not show a blank screen while the system is processing.

Always tell the user:

- What is happening
- What the system is doing
- Whether the operation succeeded
- Whether an error occurred
- What they should do next

Use skeletons, progress indicators, and feedback when they improve perceived speed.

## Safety

Dangerous actions need appropriate friction.

Delete, payment, and irreversible actions should use one or more of:

- Confirmation
- Undo
- Typed confirmation
- Clear warning

## Motion

Animation should exist only when it helps explain:

- State change
- Transition
- Progress
- Completion
- Spatial relationship

Do not add animation merely for decoration.

## Final Rule

When choosing between:

`more impressive`

and

`clearer, simpler, and more purposeful`

default to the second option.
