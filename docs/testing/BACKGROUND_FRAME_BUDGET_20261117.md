# Background rendering budget

The game now caps rendering at 20 FPS when another application owns focus,
then restores the previous foreground limit. Existing limits below 20 remain
intact. This reduces unnecessary background frames without changing physics
frequency, time scale, audio playback, saves or pause state. Transfers between
windows inside the game do not trigger the limit. Headless tests, unfocusable
QA windows and fixed-rate movie capture retain their existing timing.

Implementation uses an event-driven child of the final game host, without a
per-frame polling callback. The cap is restored when that child is removed.
An explicit external cap change while backgrounded is preserved.

## Verification

- Policy regression: 19 checks, zero failures (including repeated focus events,
  existing 0/60/144/10 limits, paused tree, teardown and external cap changes).
- Standard build checks passed; selected-resource inventory includes the new
  script and its UID. Original supplied artwork was not edited.
- Packaged settings continuity: 164 checks, zero failures.
- Packaged walk/turn continuity: 60 checks, zero failures.
- Actual Windows window was opened and inspected at the cover and postal
  interior. Computer Use switched focus to Explorer and back. The instrumented
  package recorded background cap 20 at 20 FPS, followed by foreground cap 0
  at 164.34 FPS after restoration. This measures frame production, not GPU
  utilization, perceived smoothness, or listening acceptance.
- The final package was rebuilt on top of upstream `4492267`, preserving its
  dialogue-only character names and the preceding handwriting correction.
  The budget implementation is identical to the native-tested candidate.

## Open evidence

The older `walker_resume_input_20261108` offscreen fixture reports 22 failures
out of 67 checks on both the prior released package and the first candidate.
The two failure lists were compared and are identical. They are retained as
an unresolved baseline test issue, not relabeled as passing or claimed fixed.
The current walk/turn suite passes; full human gameplay acceptance remains open.

Sequential review by the implementing agent (no independent reviewer): design
and implementation preserve foreground behavior and existing lower caps; QA
includes duplicate events, paused state and cleanup; art has no changed source
assets; audio listening was not assessed. This scoped correction does not close
the broader CORE-BOOK or whole-game acceptance gates.

Local evidence is under `D:/Codex-build-cache/dear-efficiency-20261117/`:
`budget-final.log`, `build-final.log`, `qa-final/`, `native-run3.json`,
`baseline/walker/receipt.json` and `qa/walker_resume_input_20261108/receipt.json`.
The final playable package is `play-final/DearSomewhere.exe` with matching PCK.

Engine API basis: [application focus notifications](https://docs.godotengine.org/en/stable/classes/class_node.html)
and [frame-rate limits](https://docs.godotengine.org/en/stable/tutorials/rendering/jitter_stutter.html).
