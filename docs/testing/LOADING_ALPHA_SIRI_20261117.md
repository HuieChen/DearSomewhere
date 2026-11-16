# Loading alpha and Siri — 2026-11-17

The loading figure had associated RGB from HEVC decoding. Treating those pixels as straight RGB and premultiplying again darkened translucent cyan strokes. Runtime now reads the exact PNG bytes, keeps the associated RGB, and uses a premultiplied blend shader that fades RGB and alpha together. Hidden decoder RGB is clamped to alpha. All six source frame SHA-256 values still match their original manifest; no recoloring, erosion, frame replacement or invented animation poses.

Approved paper background, centered figure and plain `Loading N%` remain. The caption uses the existing OFL-licensed Caveat pen handwriting font. No wave bar/capsule returns.

The supplied raccoon PNG is copied byte-for-byte as `siri.png`, with non-destructive alpha bounds [308,367,1386,2033]. Siri stands at market world foot [9850,850], height 250. Nearby nameplate says Siri in both languages. Existing named residents and saves are preserved. No unprovided dialogue has been invented.

## Sequential review evidence

- Design/UI: latest approved loading composition retained; only alpha handling and caption font changed.
- Art: inspected rendered 1600x900 loading screenshot and 1280x720 market screenshot. Cyan strokes remain clean; Siri is fully visible beside the vegetable stall and in proportion with Anne.
- Runtime/QA: final PCK loading suite 32 checks; ten-character naming/placement suite 40; exploration-state suite 63; integrated postal postcard suite 78 (213 total). All passed, no shader/script errors. Initial analytic alpha fixture was obscured by the overlay due to fixture z-order; corrected the fixture and reran. Original failed log retained.
- Native Windows: inspected actual `Alpha and Siri Review` window from the scoped PCK before the unrelated postal merge, first on loading, then at the market with nearby Siri name. Native key-triggered fixture transition was not observed; automated GPU fade readback and lifecycle checks passed. Native checks here are visual inspections, not a full interaction/playthrough acceptance.
- Audio: unchanged; no new listening acceptance claimed. CORE-BOOK and whole-game acceptance remain open.

Final integrated package SHA-256: `12f824488cea1ba4bb800cb6ba44835632586648d7a0e5ab2a026a908caacfea`. Preserves main `76b6b39` postal postcard interaction. Earlier visually inspected scoped package: `7c327c696bdf70cdebb98b1e9fb8b9d5ff279d19ad17e0a5e72b8f75bd459df6`; loading/figure runtime unchanged by merge.
Evidence: `D:/Codex-build-cache/walk-acceptance-20261110/alpha-siri-1117-integrated-qa/` (results.json, per-suite receipts, engine logs and screenshots). Source QA: sibling `alpha-siri-1117-source-qa/`.
Build used focused checks separately (`-SkipChecks`); the package resource inventory verified all 283 selected raw files. Raw PNG loading emits Godot's generic export warning; raw files are explicitly included and both loading and Siri were tested from the exported PCK.
