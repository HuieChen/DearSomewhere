# Walk and recorder correction

User feedback: remove the courier's outline, fix uneven walking, and redesign the unattractive recorder UI.

## Implemented

- Walk textures use premultiplied alpha before mipmap generation. A separate walk material corrects partial-coverage contour colour; original PNGs and movie remain unchanged.
- The normal walking branch now reaches the interpolation code. Both frames are combined in one shader pass, keeping overlapping body pixels opaque. No generated animation frames are selected; the twelve source frames retain their two-second cadence.
- Starting and stopping use the same side pose as the original turn bridge. Stopping no longer sweeps backwards through several source frames in 70 ms.
- Recorder controls share one compact cream dock at the top, clear of the ground and character. One round record/stop control, playback, recordings, time and live stereo meters remain visible. Direction hints are available from the library or H.
- Recorder ground input transforms screen-local coordinates into the scrolled panorama, fixing wrong-direction clicks.
- Esc while naming a recording closes the library and restores movement. A subsequent Esc puts the recorder away. Direction-toggle feedback uses the existing paper sound.

## Evidence

- `walk_turn_continuity_20261110`: 60/60, including all source hashes, preserved turns, arrival/cancel, facing and 30/60/144 Hz consistency.
- `walk_render_20261115`: 4/4. Actual GPU framebuffers differ at intermediate times; 5611 overlapping sampled pixels remain opaque. This catches the previously bypassed draw route and translucent-body regression.
- `exploration_recorder_20261110`: 44/44 after correction. Covers actual stereo PCM, meters, save/reopen/rename/replay, failed-write recovery, movement, scrolled clicks, nested Escape, Chinese/English and 1280/1920/2560 widths.
- `experience_comfort_20261106`: 58/58 after merging loading/transition changes.
- Original 60/4/43 focused suites also passed against the first packed candidate. Final packed validation is recorded in the local package receipt, including the added Escape case and writable evidence paths.

## Review boundaries

The native window was inspected visually. The Windows input helper showed inconsistent DPI coordinates and then reported an active request; native pointer playthrough and subjective smoothness approval are not claimed. This remains a six-fps authored source with runtime frame blending, not newly drawn 60-fps animation. Preserve that distinction when discussing quality.

One follow-up run crashed in NVIDIA OpenGL while building the existing fountain texture; its log is retained. A subsequent isolated run completed all 44 recorder checks. Expected failed-write errors in the recorder test deliberately exercise recovery. No full-game or novice acceptance is implied by these scoped results.

Sequential review: visual pass selected the top dock to avoid covering feet; implementation pass repaired the draw route and coordinate conversion; adversarial pass found opacity loss, stale clock label bounds and swallowed Escape; audio pass verified recording data and bus cleanup. Broader narrative acceptance remains separate.
