# Layered postal postcards — 2026-11-17

The supplied PSD's rack cards now support pick up, enlarge and return. This corrects the flattened-background-only replacement. Nine exposed raster layers are selectable; three additional layers are completely hidden by the counter and have no invisible hotspots. One authored layer contains a stack and remains a stack.

Original PSD and saved room composite are unchanged. `postcards/cards.json` records source hashes and every derivative. Faces retain the source soft-light finish. Hit masks subtract the rails, telephone and other foreground alpha. Local removal patches use the PSD recomposition delta against the saved composite, preserving the painted foreground.

The modal shows the complete original face, with Put back, ×, Escape and outside-click return. It blocks room navigation and tool shortcuts, restores the shelf on forced teardown, and does not alter inventory, evidence, time or saves. Existing paper audio is reused; no new music or voice is introduced.

Sequential review (one implementer, not independent agents):

- Design/UI: direct object interaction, subtle source-shaped hover, no invented reverse or explanatory prose.
- Art: inspected all nine extracted faces and rendered feather/lower-card views; original low-resolution painted edges remain visible when enlarged.
- Godot/QA: source GPU input suite 78/78, room layout 35/35, production postal route 20/20. The fixture exercises all nine actual pointer targets, foreground rejection, rapid Escape, all return controls, forced teardown, Chinese/English and unchanged game state. Corrected the fixture's global-to-local probe calculation before the final source run.
- Audio: existing paper cue connected once per action; dummy-driver tests do not establish listening acceptance.

Final integrated package: merged collaborator main `5107bed` (cast names and loading presentation), regenerated export selection without dropping either side, exported 1,363 entries. Actual PCK SHA256 `9c1553f2cde4e3c49339dbc6fa8c85f949723f9e845bb80e66f2c7144f72cd0e`. From an empty host directory with isolated userdata, the final package passes 193 checks: postcards 78, room layout 35, postal route 20, character names 34, loading transition 26. No SCRIPT ERROR/ERROR lines in these final suite logs. Raw-image loading warnings remain; required bytes are explicitly included and exercised from the PCK.

Native Windows observation: the final PCK opened in `Dear Somewhere - Postcard Review`, showing the supplied room, rack, HUD and arrows. Computer Use click injection twice returned `unknown screenshotId screenshot-0`; after refreshing/restoring the window the same error persisted. Native pick-up/return therefore remains unverified; routed GPU pointer/key tests above passed. Do not count this as human interaction/listening acceptance. Full-game/novice acceptance and unrelated walking quality are not certified by this focused change.

Local evidence: exploration build cache `postal-postcards-source-final`, `postal-postcards-integrated-qa`, `postal-postcards-native`. The earlier pre-integration package also passed its 133 scoped checks but is superseded. The source import initially exposed a Variant inference parse error, corrected with an explicit bool before successful runs. No failing fixture was counted as a pass.
