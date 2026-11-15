# Paper navigation and interaction polish

Runtime source: `b73724f568fb99c63e4d26d0cfaa9e74930b9ad6`, integrating collaborator main `495616674fef3a006d1d6a3385f5edab1e21f312`.

## Result

- Passive paper overlays enter over 160 ms and dismiss over 120 ms. Escape, crosses and Pause/Resume share the dismissal path. Outgoing paper owns input until it finishes; replacement cancels its tween and verifies the instance before freeing anything.
- B and M toggle the bag and map. These passive surfaces can switch directly to another tool through B/M/J/C/R. Camera, recorder, dialogue and editable document close/save safeguards retain ownership.
- Mouse and keyboard tool entry remember the corresponding quickbar opener. Bag tab/filter rebuilds preserve their existing scroll/focus and avoid replaying the backdrop fade.
- Bag uses the common paper backing/shadow and a persistent selected-tab underline. Tooltips expose existing keyboard shortcuts.
- Button feedback has one cancellable tween. Disabled, hidden, focus transfer and window focus loss reset the press. A child-node method connection disconnects when the button is freed.
- Latest collaborator recorder controls and supplied wave-loading artwork are integrated. Short scene changes retain the collaborator's loading-free transition. Coverage synchronizes all loading children on the final frame, and headless transitions skip the unavailable post-draw event.
- The walker smoke fixture now validates the currently selected twelve-frame, six-fps supplied cycle, its source hashes/geometry and movement behavior. Test harness process cleanup guards missing CommandLine values.

## Evidence

- Standard `tools/check.ps1` passed during final build, including Python studio/media checks and all default headless engine suites. Private archival checks and the full optional GPU matrix were not run.
- Actual exported PCK, offscreen OpenGL with Dummy audio and isolated userdata: paper navigation 30/0, existing bag navigation 30/0, loading lifecycle/pixel readback 13/0, button interruption 10/0. Total: 83 checks, zero failures.
- Walker additionally passed offscreen GPU: 87/0, no ERROR/FAIL log lines.
- Export inventory: 1,275 entries and 250 verified raw resources. PCK SHA256: `2febc1edc57062ff2b6ca46c1e8c029a4c1353c713e1c1d00038ad5bde1d1b44`.
- Native final EXE window displayed the title and entered the postal interior through Continue. Further native interaction was interrupted by user input/window minimization; no complete native interaction or listening acceptance is claimed.

Local evidence: `D:/Codex-build-cache/paper-polish-packed-qa`, `D:/Codex-build-cache/paper-polish-build.log`, `test-results/check-20261115-234930`, and `test-results/package-20261115-235027`.

Earlier attempts are retained: an unguarded missing tween metadata read was corrected; one bilingual fixture failed to reset its initial tab; the first button GPU fixture asserted before its tween finished. The final button fixture waits for completion and uses an unfocusable test window. These were not recorded as passes.

This focused pass does not advance the broader story/novice acceptance gate. The interaction direction continues the earlier [SEASON research](https://blog.playstation.com/2022/06/02/discover-the-gameplay-and-story-of-season-a-letter-to-the-future/): tools should support a continuous observation and recording flow.
