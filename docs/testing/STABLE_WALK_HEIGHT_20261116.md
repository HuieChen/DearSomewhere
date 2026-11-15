# Stable walking height

User feedback: the courier rises and falls while walking. The previous registration interpolated the source's full vertical head displacement, preserving an excessive bob instead of stabilizing it.

The desired upper-body Y is now fixed to the side pose used by the existing turn bridge. Each source pose's measured vertical offset is cancelled; horizontal registration remains continuous. Boots keep their exact UVs and world anchor. The original source images, detached-matte cleanup and distance-based stride are preserved.

GPU evidence: 48 samples through the complete cycle at the 295-pixel street height measured a 16-pixel top-edge excursion before and 2 pixels after. Regression coverage now renders both directions at 156 and 295 pixels: top-edge range is respectively 1 and 2 pixels, allowing original hair/cap silhouette differences. It also retains boot-contact and matte-removal checks.

Source validation: `walk_render_20261115` 13/0, `walk_turn_continuity_20261110` 60/0, `final_walker_smoke` 90/0. These are GPU/engine checks, not player acceptance. A fresh native review window opened, but desktop capture was obstructed by foreground user interaction; native input review was not completed. Package validation/hash are in the local delivery receipt.
