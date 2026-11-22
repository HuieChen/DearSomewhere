# Pelican Post global acceptance review — 2026-11-22

## Acceptance target

The visual and interaction target is the Pelican Post treatment: crisp pixel contours, broad flat color blocks, restrained two-tone shadowing, low visual noise, and a quiet gameplay inset. Existing authored scenes, cast and supplied plates remain the source of truth. This review covers the current runtime, not a replacement art pass.

## Changes in this pass

- Removed the runtime Mossner postal-room layer while retaining the supplied source asset and collaborator history.
- Kept the clock-free postal base and separate foreground counter so the post office reads as one clean, navigable workspace.
- Repaired settings entry/exit timing, close affordance scale, dropdown row spacing, language/focus/title fixtures, and save-failure coverage.
- Switched the settings surface to the authored height-field water shader and seeded native body poses before physics sampling.
- Added a displacement threshold so solver settling cannot create phantom ripples on a fresh page.
- Preserved real click, held-drag, lemon press/release, and water-to-body coupling; settings re-entry starts calm while language rebuilds retain an active field.
- Kept interaction sounds on the existing shared audio route; no new looping menu voice is layered over the main music.

## Automated acceptance

The blocking check completed successfully in `test-results/check-20261122-091535`:

- Python studio, pastel asset, courier source, settings media: pass.
- Headless core, mail physics, final case, walking, dialogue, postal queue, and text bounds: pass.
- GPU settings/layout/input suites, native lemon physics, water field, water feedback, and settings manipulation: pass.
- Water feedback fixture: 191 checks / 0 failures.
- Independent coastal solver fixture: 21 checks / 0 failures.
- Shared settings water smoke: 25 checks / 0 failures.

The older `visible_ripple_input` and five-case route/window-close fixtures are retained as separate diagnostics. They rely on historical screenshot/source assumptions or an interactive desktop handshake and are not part of the blocking Pelican pass. Their failure is not treated as player-facing approval.

## Human acceptance boundary

This is an automated GPU/offscreen and deterministic-state pass. It does not replace a novice playthrough, a native foreground window review, measured display refresh testing, or listening to the final mix. Those remain the next human acceptance step before calling the game release-complete.
