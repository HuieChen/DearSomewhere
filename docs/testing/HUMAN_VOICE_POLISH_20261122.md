# Human voice polish — 2026-11-22

## Why this pass exists

The five-day route had a repeated clue voice. Many prompts used the same abstract pattern, explained the player's next thought, and closed with a system-like reminder to confirm the answer. That made the authored town feel machine-written even though the supplied scene art and long conversations were retained.

## Changes

- Rewrote the campaign's indirect leads around things a player can actually see, such as curled photo corners, pressed writing, paw marks, stamps, folds, and missing lines.
- Removed the repeated meta copy that called a clue an answer or instructed the player to carry it until a suitable object appeared.
- Kept the destination hidden in the satchel and journal surfaces. The player still has to inspect the object, listen to a person, or open the map themselves.
- Replaced the opening briefing with a short desk-side instruction and replaced the English untranslated fallback with a plain editorial note.
- Left the supplied dialogue turns and source art untouched. The pass changes connective UI copy only.

## Verification

- `indirect_clue_flow_20261120.gd` passed with 12 checks and 0 failures.
- `campaign_authored_turns_20261119.gd` passed with 175 checks and 0 failures.
- `five_day_experience_smoke.gd` passed with 172 checks and 0 failures.

The Godot runs also reported the existing shutdown ObjectDB/resource-retirement warnings. They did not affect the assertion results and are retained as an environment cleanup follow-up.
