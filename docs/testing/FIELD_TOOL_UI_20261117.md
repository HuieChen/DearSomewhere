# Compact, unified field tools and direct doorway exit

Latest user corrections: make the camera buttons smaller; unify recorder and camera UI; remove the pictured door feedback entirely and let a click on the door exit. The intermediate restrained handle-light treatment is superseded and is absent from the final runtime.

## Changes

- `field_tool_ui.gd` owns the shared positions, button theme, type and label treatment. Camera and recorder now share the top-left heading/actions, top-centre status, top-right close and bottom-centre primary action. Camera format 520x48 -> 320x38; secondary actions 300x48 -> 210/190x38; close 74x68 -> 48x46; zoom/reset controls and thumbnail also shrink. Main action artwork uses 88x88. Keep the approved cream/blue style, red recording identity, camera framing and original paper ejection.
- Recorder removes the long opaque dock. Its state/time/meters occupy the same compact status position as the camera format. The recordings drawer opens beneath the left actions, like the film controls. Monitoring still permits walking; opening the drawer stops movement; recording, playback, metadata and save-retry logic are retained.
- The door draws nothing in any state. Its entire rectangular hit area accepts a click, including the glass away from the handle. Mouse-down invokes the guarded exit immediately; the artificial 140ms wait, painted glint and handle coordinates are removed. Existing modal/transition guards still apply.
- Preserve main through `76b6b39`, including the selected paper/centred-figure/plain-percentage loading, Tarot naming, supplied cast names and inspectable postal postcards. Original scene and character asset bytes are unchanged by this correction.

## Verification

Sequential implementation, UX/art inspection and adversarial QA were performed in this window; these are not independent agents or player acceptance.

- Default source/build checks passed on the unified tool implementation. After merging the later postcard/cast changes, the final packaging invocation used `-SkipChecks`; this is not counted as another default-check run. Final pack inventory: 1376 entries, 281 raw files verified.
- Actual final PCK, isolated userdata, OpenGL and Dummy audio: **353 checks, 0 failures**. Composition 21, film 35, photo flow 28, recorder 44, state integrity 63, postal room/door 24, loading 26, postcards 78, cast names 34.
- Door checks compare the rendered door region before/after focus (identical) and assert that pressing the glass starts exit synchronously. Both languages cover room changes, modal blocking, exterior reentry and preserved time.
- Inspected source GPU camera/recorder frames in Chinese/English at 1280x720, 1600x900 and camera 1920x1080. Compact controls fit without text overflow; horizontal/instant camera and drawers remain usable.
- Native release candidate: observed title -> postal room -> camera, format switching and photo ejection. The later unified recorder was visually inspected in a native Godot window loading the final PCK with an isolated fixture. Native record-key delivery was not confirmed, so no native recording/playback or listening acceptance is claimed. Pointer automation hit a screenshot-cache error and is not counted as pointer acceptance.
- Retained the first failed composition run. That older test assumed capture automatically opens review; the current accepted design leaves the camera live. The test now explicitly enters review before asserting that review arrows cannot pan. Both capture behaviour and review isolation are checked.

Final runtime source: `5dfcd75a0969ccee16ebc52ecb1b12814846d1be`.

Final PCK SHA256: `9ef309ed740a7f47ba0bc320fb5754ad4860e8f36c8b6bbcd47437580a6feaef`.

Official release EXE SHA256: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.

Evidence: `D:/Codex-build-cache/camera-compact-20261116/` (final-package receipts, source GPU frames, build/package logs, failed first attempt and isolated native logs). Earlier candidate packages in that folder are superseded by `playable-final`.
