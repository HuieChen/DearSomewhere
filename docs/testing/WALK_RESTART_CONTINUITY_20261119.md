# Walk restart continuity — 2026-11-19

A second click during the short stop-settle window previously reset `_walk_time` to the turn bridge and cleared `_step_distance`. The visible result was a sudden pose jump (source pose 9 to pose 2) and a broken footstep rhythm. `walk_to()` now resets only after `_pose_mix` has returned to authored idle; a restart during settling preserves the current phase and accumulated distance. Fully idle starts still use the preserved turn bridge.

Evidence: the isolated restart probe preserved phase 1.56393195382452, pose 9 and step distance 22.663232421875. The candidate package passed the existing 60 turn checks, 13 rendered-pose checks, 78 postcard checks, and the expanded 101-check final walker smoke. The shader compiler emitted the known non-fatal custom sampler diagnostic while loading the courier material; no SCRIPT ERROR or test failure occurred.

The supplied twelve-frame, 6 fps source and five authored turn frames remain unchanged. No pose deformation or synthetic frame was added.
