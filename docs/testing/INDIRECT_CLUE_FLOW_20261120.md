# Indirect clue flow QA · 2026-11-20

## Scope

本轮调整了五日流程的默认信息密度。开场主管、邮袋、完成一步后的过场提示和小镇手记都改为先给可观察片段，再由玩家主动展开地图、纸页或原始记录。

## Automated results

- `tests/indirect_clue_flow_20261120.gd`: 10 checks / 0 failures。
- `tests/campaign_authored_turns_20261119.gd`: 175 checks / 0 failures。
- `tests/five_day_experience_smoke.gd`: source run passed。
- `tests/five_day_state_smoke.gd`: source run passed。
- Same indirect-clue and authored-dialogue tests against the exported PCK: 10 / 0 and 175 / 0。

## Export

- Source commit: `2278b6eaf3157fa49cce2654e25960fd0c52dfa4`。
- PCK SHA-256: `ecb5b143ab68a284cc1002a5fc996d66676757d789b319ad78adbdbd619e0317`。
- Matching playable package: `DearSomewhere-IndirectClues-20261120`。

## Acceptance boundary

Automated checks cover the production host and exported PCK. They do not replace a first-time human playthrough, visual comparison against Pelican Post's actual inset gameplay art, or listening acceptance for audio.

