# Crisp walking cadence

User feedback: no walking outline; walking feels too choppy.

## Final behavior

- Draw one original pose at a time, including the brief stop before the turn. Removed the two-pose crossfade that produced doubled hair, hand and boot contours.
- Play the twelve supplied poses at 12 fps at normal speed, instead of 6 fps. Source movie, PNG hashes, geometry and pose order are unchanged. This is a runtime playback-rate change, not newly drawn frames or a claim of 60-fps character animation.
- Movement speed, distance-driven phase, acceleration, braking, keyboard ownership and the existing separate turn timing are retained. Existing premultiplied alpha and contour-colour cleanup avoid black matte fringes without adding a stroke.
- The walk shader samples one pose instead of two. No motion-field textures or image-processing dependencies ship.

## Review and validation

Visual/implementation review rejected prolonged crossfades (double silhouettes) and an experimental optical-flow candidate (distorted extremities). Neither candidate is in the final runtime. The final single-pose GPU captures preserve the original art and opaque body. Audio cues remain distance-driven; listening acceptance was not performed.

Source validation: `walk_render_20261115` 5/0, `walk_turn_continuity_20261110` 60/0, `final_walker_smoke` 88/0. This covers real framebuffer pose changes at 1/12 second, no mid-pose ghosting, source hashes, turn return, input/callback ownership and 30/60/144-Hz movement consistency.

Street diagnostic: 360-frame offscreen samples were 6.05 ms median / 6.375 ms p95 before and 8.947 ms median / 27.391 ms p95 afterwards. Other game/test processes were concurrently active; these samples do not establish a performance improvement or a stable framerate. The actionable correction is animation cadence and silhouette clarity, not a verified system-wide FPS fix.

A native review window opened, but capture failed and the user stopped Computer Use with physical Escape. No further desktop input was sent. Native motion/subjective smoothness remains unverified. Only isolated QA userdata was used. Broader game acceptance and the old studio book queue are unchanged.

Packaged validation and publication hashes are recorded in the local delivery receipt.
