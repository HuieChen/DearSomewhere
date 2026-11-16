# Supplied dialogue and character handwriting — 2026-11-17

Imported the user's dialogue manuscripts into a chapter-indexed runtime catalog and connected two independent conversations in the exploration build. Dialogue now selects a handwriting profile by the current speaker. The original source documents, letter bodies, mechanism copy, character artwork and save formats are unchanged.

## Content and binding

- 820 organized source records across 24 supplied chapters; chapters 4, 18, 19, 21 and 28 are absent. The sample workbook belongs to chapter 3 according to the supplied assignment and flow, despite its internal heading.
- 441 spoken records are bound to Anne and eight NPCs: Xanni, Rae, cici, 冥冥, 咸鱼, 夏透明, 尘缘 and 闹闹. Source filenames and paragraph/cell locations remain on the records. Maya has a confirmed name and a handwriting profile, but no supplied dialogue.
- Explicit user mapping: 塔罗师 = 夏透明; 餐车摊主 = 咸鱼. Manuscript alias 石泳琪 = 咸鱼. The NPC design explicitly identifies 巫巫 = cici; this includes her chapters 2 and 7. Monssner spelling is normalized to Mossner without inventing an actor binding.
- Unbound dialogue: Mossner, Arthur, Theo, BEETMAN, 宇星晴, 周晓六, 小孩, 邻居, 小浣熊 and 海鸥. 南星 has nonverbal directions. Siri was preserved from concurrent main; this batch does not provide Siri dialogue/design.
- Only Xanni's optional music chat and 尘缘's explanation of the blank-letter agreement are enabled as ambient conversations. Delivery reactions and mutually exclusive branches remain chapter data, requiring real event integration. Importing data does not implement a 29-chapter campaign or authorize fake delivery state changes.
- Dialogue stages, letter excerpts, choices, narration and design notes are separate in the user-facing report. Runtime NPC speech excludes standalone letter excerpts and unbound actors. Text is not translated or silently rewritten.

## Handwriting implementation

Seventeen profiles use OFL fonts plus per-character width, slant, spacing, weight, ink tone, line spacing and deterministic baseline/opacity variation. No whole-script fonts are claimed to have been drawn from scratch. Font files retain their upstream bytes; provenance and complete OFL notices are shipped.

Anne uses compact playful writing; cici uses a distinct, more open marker-based hand. Maya uses blue-black fountain-pen-style regular writing with calligraphic terminals. Rae uses light, narrow, spaced writing. The unnamed guitarist uses energetic cursive writing; Arthur uses vintage warm-brown writing with slight static irregularity. Other profiles follow the NPC design's personality/occupation. Theo's profile is provisional because the design document has no dedicated page for him. Guitarist and Theo are not conflated; neither are Rae and 宇星晴.

`character_handwriting.gd` styles both dialogue text and its speaker label; player options use Anne. The effect never uses elapsed time, so simulated unsteady pen marks do not shake the screen. Font fallbacks retain Chinese/Latin coverage. Existing masked placeholder conversations stay masked; only explicitly supplied conversations reveal text.

The RichTextLabel backing text is kept synchronized when changing fonts. Literal source brackets are escaped before the private effect markup is applied. This prevents theme refresh from restoring a previous line. Long passages are paginated at punctuation to at most 52 characters per page, keeping the complete page inside the authored notebook without requiring vertical scrolling.

## Sequential role passes

- **Writer / design:** compared the 29-chapter flow, assignment screenshot, manuscript speakers and NPC design; preserved source discrepancies for user review instead of rewriting them. Original twelve dialogue/flow files passed SHA-256 unchanged checks.
- **Gameplay / Godot:** isolated catalog and host adapter; no postal state transitions; opt-in authored text; actor-bound approach/click target; retained concurrent named cast, Siri, loading, field tools, postcards and door changes.
- **Art:** inspected the three engine-rendered handwriting sheets and actual notebook renders. Corrected clipped specimen cards and paginated long dialogue without reducing handwriting size. Artwork is untouched.
- **Adversarial QA:** caught and corrected old-line restoration after speaker/font changes. Source scoped GPU checks pass 636/636: handwriting 72, supplied dialogue 524, current names 40. These cover all enabled dialogue pages, source text and speakers, full text bounds, static ink, literal brackets, normal completion, close/Escape, reentry, state preservation, zh/en UI and 1280×720 / 1920×1080 / 2560×1440 renders. The manuscripts themselves remain Chinese in both UI languages.
- **Audio:** existing paper/flip cues are retained. Tests use the Dummy mixer; no new listening acceptance is claimed.
- **Producer / UX:** `studio.py impact` identifies CORE-NPC and its relevant roles. The studio board was not advanced or declared complete. First-player and complete campaign acceptance remain outside these checks.

## Validation evidence

Source scoped receipts: `D:/Codex-build-cache/dear-dialogue-qa/handwriting-source-final/`.
Full default engine checks and selected-resource build are run separately by `tools/build.ps1`; final packed receipts and native review are recorded in the release receipt below.

Earlier failed runs are retained in `handwriting-source-r2` through `r4` and `text-debug`: specimen height failures and previous-line restoration were real findings, not accepted passes. The first build before the shorter pagination is superseded by `handwriting-release`.

## Release receipt

- Final integrated runtime source: `8ba37db85b5184ac040b4b26e480db66b2cede01`, including concurrent main through `a5c63a1`. The subsequent receipt commit changes documentation only.
- Full default engine checks: `test-results/check-20261117-054220/`; selected-resource export audit: `test-results/package-20261117-054314/export-audit.json`, 1,406 entries and 290 verified raw resources.
- Final PCK scoped GPU checks: `D:/Codex-build-cache/dear-dialogue-qa/integrated-packed/`, **636 checks, zero failures** (72 handwriting + 524 supplied dialogue + 40 named cast). These execute the actual exported resources, not the source directory.
- Delivered PCK SHA-256: `0140ede9caf52289e10d06efd209a0bee6fb8765fb740b88b9c8a9113e555cb0`.
- Official release EXE SHA-256: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.
- Native Windows input review used an isolated save and PCK `ac54a4127beb9c49487e4c6d9e9d7353205aaa53b4b460e62e1e7454fee0589f`: clicked Xanni in the street, observed Anne's opening line, clicked the actual advance arrow and observed Xanni's different handwriting, then Esc returned to exploration. Screenshot saved in the user-facing outputs. This review preceded the final concurrent courier-alpha/postal-arrow merge; the dialogue implementation is identical, and the final integrated PCK passed the complete scoped checks above. No claim of final full-game human acceptance is made.
- Source manuscripts remain private and immutable. The searchable HTML report, full organized JSON, three typography specimen sheets, native screenshot and matching playable package are delivered together in this chat's `outputs` directory.
