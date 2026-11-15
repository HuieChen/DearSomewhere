# Upper-body registration and detached matte cleanup

The user still reports choppy walking and clarified that small black dots also occur across the whole screen. These are tracked separately.

## Implemented and measured

- Offline analysis found 603 alpha-covered pixels disconnected from the courier's main silhouette across the twelve immutable source frames. Runtime clears only the recorded spans, after checking the source SHA-256, before premultiplication/mipmap generation. Every solid body pixel and a three-source-pixel antialias margin are retained. The source PNGs and movie are unchanged.
- A rigid upper-body translation was measured for every source pose. Runtime cubic interpolation supplies continuous head/body placement between source samples, feathering to zero above the boots. It does not crossfade two silhouettes or warp the feet. The last walking offset is retained during the short stop before the original turn bridge.
- Numeric registration/cleanup metadata is packaged; the analysis tool outputs JSON only. No image-processing package is a runtime dependency.
- Source checks: framebuffer/cleanup/ground contact 9/0; turn continuity 60/0; movement/input 90/0. The framebuffer test observes intermediate upper-body movement, retained opaque area, unchanged held-pose boot pixels, all recorded remnants cleared and supporting-foot drift below four pixels at both actor sizes.
- A native review window was inspected and a real ground click produced the walking pose and street movement. Earlier owned review windows were closed to avoid confusing old revisions. Subjective smoothness acceptance is still open.

## Still unresolved

The four distinct painted leg poses remain discrete. This change smooths upper-body position; it is not a full newly drawn in-between animation. Do not describe it as complete 60-fps gait interpolation.

The reported whole-screen black dots have not been reproduced in the current native view or four sampled postal-street positions. Static GPU comparisons with motion enabled/disabled use the same lighting blend. These samples do not rule out intermittent artifacts, other scenes, another build, or display-only symptoms. Courier debris removal must not be represented as fixing the whole-screen report. A screenshot/short recording or reproducible location/time is still needed for that issue.

Package check totals and SHA-256 are in the local delivery receipt. Full game acceptance is not implied by these scoped results.
