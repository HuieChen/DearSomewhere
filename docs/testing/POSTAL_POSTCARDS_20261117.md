# Layered postal postcards — 2026-11-17

The supplied PSD's rack cards now support pick up, enlarge and return. This corrects the flattened-background-only replacement. Nine exposed raster layers are selectable; three additional layers are completely hidden by the counter and have no invisible hotspots. One authored layer contains a stack and remains a stack.

Original PSD and saved room composite are unchanged. `postcards/cards.json` records source hashes and every derivative. Faces retain the source soft-light finish. Hit masks subtract the rails, telephone and other foreground alpha. Local removal patches use the PSD recomposition delta against the saved composite, preserving the painted foreground.

The modal shows the complete original face, with Put back, ×, Escape and outside-click return. It blocks room navigation and tool shortcuts, restores the shelf on forced teardown, and does not alter inventory, evidence, time or saves. Existing paper audio is reused; no new music or voice is introduced.

Sequential review (one implementer, not independent agents):

- Design/UI: direct object interaction, subtle source-shaped hover, no invented reverse or explanatory prose.
- Art: inspected all nine extracted faces and rendered feather/lower-card views; original low-resolution painted edges remain visible when enlarged.
- Godot/QA: source GPU input suite 78/78, room layout 35/35, production postal route 20/20. The fixture exercises all nine actual pointer targets, foreground rejection, rapid Escape, all return controls, forced teardown, Chinese/English and unchanged game state. Corrected the fixture's global-to-local probe calculation before the final source run.
- Audio: existing paper cue connected once per action; dummy-driver tests do not establish listening acceptance.

Final integrated package and native results are recorded below after verification. Full-game/novice acceptance and unrelated walking quality are not certified by this focused change.
