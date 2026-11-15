# Map typography and current-main integration

The post-office hub badge now uses the shared rounded font and the selected language (`主枢纽` / `Main hub`). Its width and baseline follow the measured text. The landmark paper captions, dwell timing, transit icon, pets and current-location dot remain as authored on current main. The rejected selection lighting is not restored; original map SHA256 remains `3ace307814071c4bb8990a6eb52b28f70cfcbaa9806f9b20a167dd53cc67d815`.

Runtime source: `a94033c5ee3c1fd9fc17f25883d598fcab73b0be`, integrating collaborator main `0ff26bd1c59950d5e15656aa73fff869c64a1d7a`. Relative to that main, the only runtime change is the hub badge. Subsequent changes are test isolation and this evidence record. The selected export retains the new walking shader, recorder changes and paper navigation.

## Actual exported package

- PCK SHA256: `05a5976eca2392a6c36857cfd68c62fa114bce5208ff648f6a32b5bce05d405d`.
- Official Windows template SHA256: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.
- Standard selected-resource packaging: 1,275 entries, 250 raw resources verified. No QA override is packaged. Broad build checks were explicitly skipped; scoped actual-PCK checks below are the new evidence.
- Offscreen GPU, empty host and isolated userdata: unchanged-map/caption checks 104/0; pointer and keyboard map routing 44/0; exploration navigation 21/0; paper navigation and repeated-key protection 30/0; isolated recorder 44/0; walking shader rendering 4/0. Total 247 checks, zero assertion failures in the final runs.
- Recorder deliberately provokes two `ERR_FILE_CANT_WRITE` diagnostics and verifies retained PCM and successful retry. Other final suite logs have no ERROR or SCRIPT ERROR. Existing raw-image loader warnings remain; the actual raw resources are verified and rendered from the PCK.
- Captured zh/en at 1280, 1920 and 2560 widths. Inspected final Chinese 1280 and English 2560 hub layouts plus movie frames: both badge strings fit, hierarchy is restrained, and captions follow buildings without added illumination. A seven-second normal-speed MovieWriter preview exercises hover, held press and canceled travel. It is silent and uses engine events, not OS input.

Evidence directories under the current task's `work/`: `map-integrated-qa-20261116`, `recorder-isolated-qa-20261116`, `walk-integrated-qa-20261116`, and `map-integrated-movie-20261116`. Export audit: `test-results/package-20261116-004404`. Delivered copy includes consolidated receipts and the preview.

## Rejected and corrected checks

The initial installed-package audit reported two Escape failures after an 80 ms settle. Reading the newly merged implementation established a 120 ms paper dismissal; the old immediate-close source passing the same fixture did not establish a functional regression in the newer package. The map fixture now waits for actual dismissal with a 500 ms deadline. No Escape runtime workaround was added.

The map pixel fixture predates the separately authored animated hub. It now excludes only that small icon/badge rectangle; all 13 destination checks still require unchanged pixels everywhere outside the selected caption and hub area. Original art hash verification remains intact.

An additional recorder run failed an aiming assertion and then lost its recorder instance, timing out without a receipt. It is retained as failed evidence, not counted as passed. A sequential rerun with an unfocusable test window and bounded 60 fps passed all 44 assertions, including actual PCM, failed-write recovery and nested Escape. Those isolation settings are now in the fixture; recorder runtime code was not changed. The walking fixture wrote its receipt to its isolated default user directory rather than the runner's `--qa-out`; that original receipt was collected without rerunning or inventing results.

## Sequential review and limits

Design/UX review kept the current landmark-relative feedback and keyboard/pointer ownership. Implementation/Godot review confined runtime changes to localization and font metrics. Art review inspected actual package frames and unchanged source bytes. Adversarial QA checked canceled travel, repeated keys, paper replacement, language/layout and recorder failure recovery. Audio review covers captured PCM and bus cleanup only; Dummy audio is not a listening review.

Studio status/ready/dispatch/impact were consulted. CORE-MAP still depends on the historical CORE-BAG handoff; this focused follow-up does not advance that board or claim the broader story complete. Native OS-input playtesting, listening and human aesthetic acceptance remain separate and were not performed in this background pass. No personal saves were used.
