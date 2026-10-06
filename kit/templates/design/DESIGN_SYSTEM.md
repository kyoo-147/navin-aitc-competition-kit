# Design System

Status: LOCKED DERIVED VIEW

## Direction

**Utility** is the chosen direction. It favors high-contrast light surfaces, system typography, clear evidence states, and low-cost motion. Calm Product was considered for softer hierarchy; Console was considered for dense technical views. Both are rejected for the default kit surface because they reduce scan speed or increase density.

## Typography

Use system sans. Headings are short and strong; body copy is practical. Do not use remote fonts or decorative type.

## Spacing and shape

Use 4/8/12/16/24/32 spacing. Use 6px small radius and 10px medium radius. Borders are visible and shadows are optional and restrained.

## Surface hierarchy

White panel on light neutral background. Blue or violet is reserved for navigation/action identity, green means verified, amber means human decision or user action, red means blocked/failure.

## Components

Buttons have one primary action per view. Inputs retain entered data on error. Navigation is explicit. Cards do not nest without a content reason.

## Feedback states

Every real flow defines empty, loading, success, error, offline and permission-required states. Errors include a useful message and retry path when retryable.

## Responsive and accessibility

Small laptop is the primary target. At narrow widths, columns collapse to one; tables scroll rather than shrink unreadably. Keyboard order follows visual order, focus is visible, color is never the only status signal, and reduced motion is respected.
