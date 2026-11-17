# Five-day playable flow — 2026-11-18

The supplied October DOCX is the route authority. SHA-256: `18acd0e0c74481cee5a00553e5b0f001fd1d208b0e26382a86e8c902afbfde50`. It remains outside the repository and unmodified. Its 353 nonempty paragraphs were read, not treated as operational instructions. This change makes a playable flow adaptation; it does not claim final writing, illustration, duration or human comfort acceptance.

## Design and implementation pass

31 events / 112 steps cover the five days, with three optional anonymous deliveries in one side event. Delivered letters and unresolved work persist separately from the old exploration save. No global morality score or irreversible bad ending. Work may be put away; every privacy branch reconnects to the main route.

| Day | Route |
| --- | --- |
| 1 | Mossner handoff → Anne's first letter → verify mayor identity / bone / paw receipt → false Offer → pack job materials → Xanni photo → find music card at night → postal upstairs → bed |
| 2 | Mayor's returned evaluation → paw-wax letter, intact/private-open alternatives → animal food request / Siri / Arthur → backlog birthday-card search → ingredient matching and cooking → actual parcel damage report → upstairs / bed |
| 3 | Open authorized war letter and verify Arthur → reorder Cici's forwarding labels → nested future-self letter → blank letter to 尘缘 → Maya's original/public interview discrepancy → upstairs / bed. Anonymous letters remain optional. |
| 4 | Maya's permission and interview comparison → old quarrel: intact / contact / hold / visibly edit → seal Maya's private letter without seeing its body → Visible music application → public To Solmere route → Rae verifies and privately opens her own letter → shelf/region/serial radio lookup → upstairs / bed |
| 5 | Mayor gift packing and reply → identify card maker/recipient and deliver → owner-confirmed cover letter → grandmother's final letter and storage choice → recording → player's editable letter → seal/send → continued free exploration |

Paper interactions include full-page reading, evidence matching, chronological reorder, grid packing with rotation/overlap/bounds checks, ingredient selection and cooking operations, persistent visible strike-through edits, and editable final letter. Arthur's optional 9×9 five-in-a-row has legal alternating moves, win/draw recognition, threat-aware responses and saved unfinished games. No timer or penalty for leaving it.

Time is milestone-based in `data/campaign/five_days.json`: morning 09:00, selected midday/afternoon nodes, first music search at 19:45, radio delivery in the evening. Existing four-period panorama blending, character light and ambience use this clock. Idle exploration does not consume a deadline. Sleep alone starts the next day at 09:00. Upstairs is a real `postal_loft` view entered from the postal right room; downstairs restores that same room, including after Continue.

Opening uses the existing postal panorama, courier and supplied envelope; three brief player-paced beats lead into the actual postal scene and first conversation. Skip/Esc is available. Existing camera, recordings, photo album, map, Settings and walking remain connected.

## Art and narrative handoff

`data/campaign/presentation.json` centralizes envelope, portraits, optional loft background and performance audio. Replace these without changing event IDs, dependencies or saved progress. A loft illustration should be 1600×900 (or proportional): desk at (150,585,650,170), bed at (1050,470,420,235), downstairs at (80,780,220,60). The current loft is functional vector blocking, not finished art. Missing NPC portraits remain absent rather than being filled with another character's portrait.

Connective dialogue and shortened letter bodies adapt the supplied flow; they are not represented as verbatim, author-approved manuscripts. Existing supplied dialogue remains intact in its own catalog. Two optional anonymous recipients are provisional. Photo objects currently record descriptions/evidence rather than complete new photo illustrations. Performance playback temporarily uses the existing guitar loop; it is not a newly supplied historical performance. These are replacement/author-review items, not hidden implementation claims.

## Research and applied choices

Research is based on official descriptions and creator/publisher materials, not a claimed frame-by-frame playthrough of other games' openings.

- [The Granny Detective Society](https://store.steampowered.com/app/4240620/The_Granny_Detective_Society/): observation/investigation and varied puzzle interactions. Applied here as envelope observation → witness/record comparison → player inference → recipient response; the opening introduces the place before the task.
- [Spiritfarer](https://thunderlotusgames.com/games/spiritfarer/): care, everyday activities and relationships around loss. Applied as repeated postal work, meals, end-of-day rest and unforced reconciliation; not a borrowed plot or asset.
- [SEASON, creator's story presentation](https://www.scavengers.ca/journal/new-trailer-reveals-the-story-and-characters-of-season-a-letter-to-the-future): exploration, recording and meeting people. Applied as room to stop, listen, photograph and retain observed facts between deliveries.
- [Unpacking](https://www.unpackinggame.com/): placing personal belongings as an interaction and storytelling medium. Applied as non-timed packing with several legal layouts and persistent physical work.

## Sequential technical / adversarial QA

Evidence root: `D:/Codex-build-cache/dear-flow-20261117/`. All test saves use unique `user://qa/` paths. Source and private user saves are not test fixtures.

- State regression: `tests/five_day_state_smoke.gd`, 3,504 checks / 0 failures (`state-final.log`). Four choice variants reach the ending; each step survives save/reload; wrong places, duplicate completion, wrong deductions, missing/overlapping contents, sleep gates and optional-route continuation are checked. Corrupt-primary recovery and a deliberately unwritable destination are tested; expected write-error diagnostics remain in the log.
- Production-host input: `tests/five_day_playthrough.gd`, 615 checks / 0 failures (`input-5.log`). Routed mouse/key input traverses the complete five-day route, including private opening, visible edits, packing, cooking, night objects and final typing. Every resulting checkpoint is reopened by the state loader. This is engine-input/GPU evidence, not native OS input or a novice playtest.
- Experience fixtures: `tests/five_day_experience_smoke.gd`, 173 checks / 0 failures (`experience-1.log`). Actual opening beats/skip-independent entrance; document page and final-letter draft survive title/Continue; interrupted talk does not advance; narrative night and non-ticking idle clock; second-floor up/down/Continue; unfinished work prevents sleep; Arthur answers and retains his board. Fixture setup is explicit; this does not duplicate a full human route.
- Visual captures include arrival, envelope, every interaction type, packed objects, all four nights, narrative night street, chess and ending. Review found a blank envelope caused by an ignored authoring image not being imported; fixed by exact raw-image loading and explicit export inclusion.
- Earlier failed attempts are retained: JSON number conversion broke page/step keys after reload; normalized persisted indices. Synthetic drag exposed a mouse-coordinate dependency; positions now derive from the event coordinates. A subsequent typed-variable parse issue was corrected before the passing route.

## Workflow boundaries

`studio.py status/ready/dispatch` was run before implementation. Historical STORY-LETTER01 readiness remains blocked by CORE-WALK / single-active-story review. The user's new full-flow request explicitly supersedes that earlier implementation queue; no historical acceptance evidence or board completion was fabricated. No parallel agents were spawned. Original supplied image/video/document files and legacy progress remain preserved.

English campaign translation, full manuscript integration, final artwork/audio, measured 3–4-hour pacing and novice comfort acceptance are not inferred from automated passes.

## Final candidate verification

Runtime source: `70bdcaeff9ba4cb14c56334ddd19fce66673d535`, merging upstream `24fd6013e424183932ac41863c0fe6422c7de532`. The upstream localized ambient dialogue and recorder layout are retained. The candidate PCK SHA-256 is `d17e2293ca9dba93f2a23ffe18c607de2e170be39f53a670559bf4920e195deb`; executable SHA-256 is `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.

- Default `tools/check.ps1` completed successfully (`default-checks.log`). It explicitly does not claim the entire optional GPU suite.
- Export integrity checked 1,426 entries and 293 raw files (`build.log`).
- The actual exported PCK passed the full five-day routed-input regression: 615 checks / 0 failures (`packed-route.log`).
- The same PCK passed upstream localized dialogue regression: 130 checks / 0 failures (`merged-dialogue/receipt.json`) and recorder regression: 44 checks / 0 failures (`merged-recorder/receipt.json`). Recorder tests use Dummy audio; injected write failures are intentional. They do not establish human listening acceptance.
- Native Windows input against the release executable verified title → loading → all three opening beats → actual postal interior/Mossner → first-envelope inspection → incorrect inference and retry → correct recipient/read. Esc put the letter away; save-to-title and Continue restored the current first-letter task. The isolated QA window was then closed normally. `native.log` contains no engine warnings/errors. This is a native opening/save subset, not a claimed five-day human playthrough.

Publication and the two Latest-directory backups/hash checks are recorded externally in `publication.json`, `sync-five-day.json` and each package's `SOURCE_VERSION.json`, so the verified Git commit need not contain a self-referential hash. Existing user progress and the separately running dialogue package are not overwritten.
