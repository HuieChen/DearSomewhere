# Map typography and current-main integration

The post-office hub badge now uses the shared rounded font and the selected language (`主枢纽` / `Main hub`). Its width and baseline follow the measured text. The landmark paper captions, dwell timing, transit icon, pets and current-location dot remain as authored on current main. The rejected selection lighting is not restored; original map SHA256 remains `3ace307814071c4bb8990a6eb52b28f70cfcbaa9806f9b20a167dd53cc67d815`.

Runtime source: `120d1c5b48e6c529ad63fbee91c92984131a77d9`, integrating collaborator main `ff013f4`. Relative to that main, the only runtime change is the hub badge. Subsequent changes are test isolation and this evidence record. The selected export retains the latest painted stride, registration/matte cleanup, recorder/media recovery and paper navigation. Runtime publication 120d1c5 passed the GitHub Studio adapter integrity workflow.

## Actual exported package

- PCK SHA256: `5f6f282423d974e113c1896fed016972812a405b7bfa0161b66fee531c9dc605`.
- Official Windows template SHA256: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.
- Standard selected-resource packaging: 1,279 entries, 251 raw resources verified. No QA override is packaged. Broad build checks were explicitly skipped; scoped actual-PCK checks below are the new evidence.
- Offscreen GPU, empty host and isolated userdata: unchanged-map/caption checks 104/0; pointer and keyboard map routing 44/0; exploration navigation 21/0; paper navigation and repeated-key protection 30/0; isolated recorder 44/0; walking shader/rendered ground contact 9/0; exploration/media state integrity 63/0. Total 315 checks, zero assertion failures in the final runs.
- Recorder deliberately provokes two `ERR_FILE_CANT_WRITE` diagnostics and verifies retained PCM and successful retry. Other final suite logs have no ERROR or SCRIPT ERROR. Existing raw-image loader warnings remain; the actual raw resources are verified and rendered from the PCK.
- Captured zh/en at 1280, 1920 and 2560 widths. Inspected final Chinese 1280 and English 2560 hub layouts plus movie frames: both badge strings fit, hierarchy is restrained, and captions follow buildings without added illumination. A seven-second normal-speed MovieWriter preview exercises hover, held press and canceled travel. It is silent and uses engine events, not OS input.

Evidence directories under the current task's `work/`: `map-current-qa-20261116`, `map-current-navigation-20261116`, and `map-current-movie-20261116`. Export audit: `test-results/package-20261116-015444`. Delivered copy includes consolidated receipts and the preview.

## Rejected and corrected checks

The initial installed-package audit reported two Escape failures after an 80 ms settle. Reading the newly merged implementation established a 120 ms paper dismissal; the old immediate-close source passing the same fixture did not establish a functional regression in the newer package. The map fixture now waits for actual dismissal with a 500 ms deadline. No Escape runtime workaround was added.

The map pixel fixture predates the separately authored animated hub. It now excludes only that small icon/badge rectangle; all 13 destination checks still require unchanged pixels everywhere outside the selected caption and hub area. Original art hash verification remains intact.

An additional recorder run failed an aiming assertion and then lost its recorder instance, timing out without a receipt. It is retained as failed evidence, not counted as passed. A sequential rerun with an unfocusable test window and bounded 60 fps passed all 44 assertions, including actual PCM, failed-write recovery and nested Escape. Those isolation settings are now in the fixture alongside the collaborator focus isolation; recorder runtime code was not changed by this map pass. An earlier walking fixture wrote its receipt to its isolated default user directory rather than the runner's `--qa-out`; that original receipt was collected without rerunning or inventing results.

The last integration initially failed the old ground-click assertion: it expected translation after 150 ms, while the current standing turn intentionally lasts 240 ms before stepping. The fixture now waits for translation with a 750 ms deadline, preserving the movement assertion; its final 21/0 receipt supersedes that failed run. One earlier paper fixture emitted shutdown resource diagnostics after only two frames. Allowing owned sound retirement before freeing the host removed those diagnostics in the final actual-PCK run. Neither correction changes player behavior.

## Sequential review and limits

Design/UX review kept the current landmark-relative feedback and keyboard/pointer ownership. Implementation/Godot review confined runtime changes to localization and font metrics. Art review inspected actual package frames and unchanged source bytes. Adversarial QA checked canceled travel, repeated keys, paper replacement, language/layout and recorder failure recovery. Audio review covers captured PCM and bus cleanup only; Dummy audio is not a listening review.

Studio status/ready/dispatch/impact were consulted. CORE-MAP still depends on the historical CORE-BAG handoff; this focused follow-up does not advance that board or claim the broader story complete. Native OS-input playtesting, listening and human aesthetic acceptance remain separate and were not performed in this background pass. No personal saves were used.
