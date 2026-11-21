# Walk transition polish — 2026-11-21

The supplied courier walk remains the source of truth. During movement the
renderer now interpolates the registered upper body toward the next supplied
pose while keeping the current lower body and planted boot pixels. This removes
the visible six-fps head and shoulder snap without inventing a new silhouette,
changing the source frames, or shifting the foot coordinates.

The transition is shader-only and resets for standing, turn and gesture poses.
The existing turn bridge, distance-driven phase, acceleration/braking and
footstep cadence remain unchanged.

Validation on the current source:

- `tests/final_walker_smoke.gd`: 101 checks, zero failures.
- `tests/supplied_cast_20261119.gd`: 54 checks, zero failures.
- `tests/post_office_layout_input.gd`: 30 checks, zero failures.
- A selected-resource Windows package was rebuilt with the official Godot
  4.7.2 template. The new PCK SHA-256 is recorded in the delivery metadata.

The package build used `-SkipChecks` after the focused source suites above;
this document does not claim a full novice playthrough or human hand-feel
acceptance.
