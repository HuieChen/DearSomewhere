# Continuous courier foot planting — 2026-11-16

The user still saw sliding after the discrete stance checks passed. Those checks
missed the supporting foot moving with the root between source pose changes.
This supersedes the earlier claim that matching a few stance endpoints was enough.

## Change

- Measure each original boot's sole and backward travel from the immutable source
  PNGs. Give each phase the world distance its supporting boot actually covers.
- Articulate the original boot pixels continuously from the knee. A supporting
  sole moves backward relative to the root while the other boot lifts and swings.
- Use numeric region spans around solid boot pigment, including the compressed
  edge, so moving a boot does not leave its old dark fringe behind.
- Retain the existing turn/idle images, distance-driven movement, head-height
  stabilization and detached-alpha cleanup. No source PNG/video was rewritten;
  no crossfade or generated replacement drawing was introduced.

## Verification

Source checks pass 231/231: continuous framebuffer contacts 24, rendered height
and alpha 13, turn/source continuity 60, controller 90, recorder 44.

The new contact fixture renders eight samples per pose across all twelve poses,
both directions, at actor heights 156 and 295. It measures the visible solid sole
against the world, not just controller arithmetic. At height 295 the maximum
horizontal contact range is 2.17px and vertical range is 1px. At height 156 these
are 2.90px and 2px. The full-loop top-edge range remains 2px / 1px respectively.
These small ranges include antialiased centroid changes between painted shapes.

Native source preview: a real ground click was observed starting rightward
movement, followed by arrival in the preserved idle; a subsequent leftward
ground click was observed turning and walking left. This is sampled native
interaction evidence, not user acceptance of animation quality or a continuous
frame-pacing benchmark. The source still contains four distinct drawn poses.

Initial headless runs of render-dependent fixtures were stopped because they
wait for GPU frame completion. The successful runs use offscreen OpenGL. The
recorder intentionally exercises unwritable-output recovery, which emits two
expected ERR_FILE_CANT_WRITE errors. Its 44 assertions pass; listening acceptance
is separate.

Evidence directory: `D:/Codex-build-cache/dear-exploration-audio-20261110/` under
`walk-footplant-continuous`, `walk-footplant-source`, and `walk-footplant-native`.
Packaged verification and installed hash are recorded in the local delivery
receipt after the final package completes.
