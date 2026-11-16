# User-assigned character names

The nine supplied screenshots map, in order, to 夏透明 (TarotGuest), Xanni (record_clerk), Maya (bookseller), 闹闹 (Naonao), Rae (lookout), 咸鱼 (chef), 尘缘 (FoodTruckGuest), 冥冥 (grocer), cici (community). The player is Anne. Existing internal IDs and source artwork remain unchanged.

Nearby NPC names fade in above the corresponding actor, ignore pointer events, and hide with the courier during conversations. Both language modes preserve the exact supplied spelling. Existing conversation speaker labels use these names; managed chef lines resolve Chef/餐车老板 to 咸鱼 and You/你 to Anne. Anne retains the player-side portrait emphasis. Ambient neighbours receive names without invented conversations. Unnamed guitarist/resident roles are unchanged.

Latest collaborator revision 684d6cc is included: centered transparent loading figure on light paper, plain Loading percentage, and Tarot shop naming. Runtime merge: 6f83f5f.

Validation: default build checks passed; actual final PCK OpenGL3/Dummy isolated-userdata fixture `character_names_20261116.gd` passed 34 assertions, covering all nine world bindings, nearby visibility, close-up hiding and bilingual Maya/Anne/managed-chef labels. Rendered Maya world and Anne dialogue screenshots were inspected. Native preview launched, but a complete native name-click sequence was not verified; do not treat automated checks as that acceptance.

The initial source check failed because the newly fetched postal art had not been imported. The normal build imported it; final packed checks passed. Evidence: `D:/Codex-build-cache/names-20261116/final-qa`, `final-build.log`; package inventory `test-results/package-20261116-234656/export-audit.json`.

Final PCK SHA256: `5a10808cb9de1b8ee3ce5eeb94a91cf86e1214dfcb5b1dd8bab627dd3926aaea`.
