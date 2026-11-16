# Supplied postal interior replacement

User request: replace the post-office scene using `未命名作品(3).psd`.
The PSD contains a 5120×1440 saved two-room composite and 106 layer records.
Its embedded profile is sRGB IEC61966-2.1. The original remains untouched and
private; the repository contains only its lossless saved-composite PNG and
provenance. No layer recomposition, resize, recolor or generated art was used.

Source SHA-256: `7c81c89043f54219d0852c74b7aa78fb0d7216760816c8190197510dd80961da`.
PNG SHA-256: `b7ff790a70d11f9212c2b91781434ea9ca710f2d5fa8aa8004b1d82d3fe71e21`.
The importer compares all decoded RGBA pixels after PNG reopening and rechecks
the source hash. The old JPEG and provenance are preserved separately.

## Sequential implementation and review

- Art/source: retain the complete two 2560×1440 halves. Unlike the previous JPEG,
  this source has no purple middle guide, so no source columns are omitted.
- Layout: preserve the 1920×1080 logical room and current arrow transitions.
  Register the door hit area and handle feedback to the new left-room painting.
- Motion: remove the old book-page/pinned-note shader from this scene. Those
  source-specific masks would distort unrelated objects in the replacement.
- Gameplay: keep current production HUD, locked modal navigation, return to the
  exterior, room state, and saves. Do not reactivate disabled book/desk hotspots
  for removed or different painted objects.
- QA: existing layout suite passes 35 checks at 1280×720, 1920×1080 and 2560×1440.
  Production host fixture passes 20 checks in Chinese/English, including room
  switches, bag blocking, actual exit and exterior reentry, and unchanged time.
  Source evidence: `postal-psd-source-qa-20261116` in the local build cache.
- Adversarial finding: the older broad `experience_routes_20261106` fixture
  exceeded its three-second transition assumption and then dereferenced a nil
  modal. Its interrupted run is not counted as a pass. The focused production
  fixture waits for completion with a bounded timeout and covers this change.
- Audio: no audio implementation or files changed; listening acceptance is not
  inferred from Dummy mixer checks. No full-game acceptance claim is made.

Export selection validates the new source/PNG hashes and retains its raw PNG and
provenance. Final PCK: 1275 entries; the same 55 checks pass from an empty host
project using the packaged runtime. SHA-256:
`d56f98c3692ee8ddb6403120e906ace6c1825a8e4556cd5563e96cab0a38b0e9`.
Native packaged window: inspected left counter, clicked the actual right arrow
and observed the new workroom. The existing launcher's PCK was backed up and
updated with matching hashes. Source PSD hash was rechecked unchanged.
