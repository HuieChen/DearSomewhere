# Field tool follow-up — compact controls, nested return and live location

The current five-day route remains on main. This focused pass keeps the latest recorder placement and makes the remaining camera/recorder behavior consistent.

## Findings and fixes

- The camera buttons already had a paper press child, while recorder buttons installed a second, locally wired feedback path. The shared `field_tool_ui.gd` button now owns the same press motion and paper cue for both tools. Recorder keeps the author-directed record button at `(1060,128)` and its red identity.
- Camera Esc now follows the nested interaction order: review first, film panel second, camera last. Closing the film panel returns keyboard focus to the film button, so the next Esc is the intentional camera exit.
- Recorder location text was created once and then left stale while `location_provider` changed during movement. A named shared-position label now updates with the provider every frame without reopening the recorder or interrupting recording.

## Validation

`tests/field_tool_consistency_20261119.gd` runs the production host with isolated userdata and routed keyboard/pointer input in Chinese and English. It covers held press, disabled and focus-loss cleanup, format activation, film-panel Esc, focus restoration, recorder location changes, nested library open/close, preserved record position and scoped screenshots.

Result: **26 checks, 0 failures** in `D:/Codex-build-cache/field-tools-followup-20261118/fixed-final/`.

This is engine/GPU fixture evidence. Native OS recording input, listening quality and novice acceptance remain separate gates.
