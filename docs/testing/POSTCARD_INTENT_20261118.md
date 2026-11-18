# Postcard click intent — 2026-11-18

Based on main 106deb1, retaining the five-day campaign, authored card clarity, dialogue and recorder changes.

Backdrop dismissal now requires both press and release outside the card. Dragging off a card, releasing without a matching press, and switching applications during a press no longer return it accidentally. Application focus loss cancels the pending gesture. Explicit return controls retain their existing behavior. Stationary shelf highlights no longer request a redraw every frame; the short fade still updates while changing.

Validation: source routed-GPU intent regression 7/7; source five-day experience regression 173/173; actual exported PCK intent 7/7 and postal layout 35/35. The experience suite reports existing exit cleanup diagnostics (25 objects / 5 resources); this is not a clean-shutdown claim. Export initially failed because its default temporary location was unwritable; reran with temp and userdata inside the authorized build directory. Export completed with the existing unused DialogueManager C# example diagnostics. Pack inventory contains 1,415 entries. PCK SHA256: fa8bf7ce757c5904c328c6dd42e1fbf06ae63799d564241aa406a102658fa811.

Evidence: build cache postcard-intent-20261118 and postcard-intent-20261118-r2 export/inventory. Native OS input was not repeated; these are routed engine-input tests. No full-game aesthetic, native gesture or listening acceptance is claimed.
