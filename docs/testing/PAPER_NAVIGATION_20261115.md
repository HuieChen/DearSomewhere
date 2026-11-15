# Paper navigation and interaction polish

Final runtime source: `862f2c5faaaa25edec231e2e9f3c8d244a7464d7`, integrating collaborator main `6cb23a4912262eae77e846bda9b20c938f9d7db8`. The final package also preserves the requested direct new-journey entry without its former confirmation.

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
- Final integrated exported PCK, offscreen OpenGL with Dummy audio and isolated userdata: paper navigation 30/0, existing bag navigation 30/0, loading lifecycle/pixel readback 13/0, button interruption 10/0, updated UI/direct-start suite 17/0. Total: 100 checks, zero failures; no ERROR or SCRIPT ERROR log lines. Existing raw-image loading warnings remain, with the required raw files verified in the export inventory.
- Walker additionally passed offscreen GPU: 87/0, no ERROR/FAIL log lines.
- Final export inventory: 1,275 entries and 250 verified raw resources. PCK SHA256: `f8b006bdb2c6d15ee777f37ec46153171605f56c137f4f151b7f1d74b127ad3a`.
- The preceding package (before the direct-start merge) displayed the title and entered the postal interior through Continue in a native EXE window. Further native interaction was interrupted by user input/window minimization. The final integrated package has automated validation above, with native interaction and listening acceptance still pending.

Final evidence: `D:/Codex-build-cache/paper-polish-integrated-qa`, `D:/Codex-build-cache/paper-polish-integrated-build.log`, `test-results/check-20261116-000022`, and `test-results/package-20261116-000100`. Pre-merge evidence remains in `D:/Codex-build-cache/paper-polish-packed-qa` and `D:/Codex-build-cache/paper-polish-build.log`.

Earlier attempts are retained: an unguarded missing tween metadata read was corrected; one bilingual fixture failed to reset its initial tab; the first button GPU fixture asserted before its tween finished. The final button fixture waits for completion and uses an unfocusable test window. These were not recorded as passes.

This focused pass does not advance the broader story/novice acceptance gate. The interaction direction continues the earlier [SEASON research](https://blog.playstation.com/2022/06/02/discover-the-gameplay-and-story-of-season-a-letter-to-the-future/): tools should support a continuous observation and recording flow.
