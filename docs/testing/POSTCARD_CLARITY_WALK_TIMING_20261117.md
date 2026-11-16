# Postcard clarity and walk startup timing

The enlarged postal cards exposed the softness of their original 123–203 px
layers. Inspection now uses a separate premultiplied texture, cubic sampling
and a narrow antialiased coverage contour. The old offset shadow is removed;
enlargement is capped at 2.8x and 460 px high. Original files, painted colour,
shelf composites, selection masks and slot restoration are unchanged. This
does not invent missing detail or replace source art with an AI redraw.

Turn completion previously consumed the render delta before the movement
substeps reused that same time. In a 300 ms startup simulation, 10 fps moved
5.9583 px while 30/60/120 fps moved 2.75 px. Updating turn progress inside the
same 120 Hz substeps gives 2.75 px and 73.3333 px/s at all four rates. All five
authored turns, twelve supplied walk frames and the source 6 fps cadence are
retained. No foot shear, new poses or crossfade silhouettes are introduced.

Integrated main through a5c63a1, retaining the native-alpha courier correction,
Siri, loading changes and the current field tool UI. Runtime commit: 70db3af.
Final PCK SHA256: d1ea8a2cd20f09e11ff1e43432043fd0970c57bb11b42aaa76ae9bb87cd18631.

Sequential review and validation:

- Design: retain source shapes and original gait; fix sampling and timing only.
- Implementation: original card textures remain immutable; a close-up-only
  material avoids changing rack appearance. Turn and travel share a clock.
- Adversarial QA: final actual PCK passes 78 postal checks, 91 walker checks,
  60 movement/turn checks and 13 rendered-pose checks (242 total). Native-alpha
  validation passes all 12 frames / 25,778 partially transparent edge samples.
- Art: inspected full-scene card 05 and 11 captures, plus card 05 in the native
  game window. Original card colour and hand-painted irregularity remain.
- Native input: actual final PCK, isolated userdata; clicked Put back, opened
  the map, selected grocery, walked right to a stop and started walking left.
  This confirms routing, turn/arrival states and visible source poses; it is
  not continuous-motion measurement or human smoothness acceptance.
- Audio: unchanged in this scope; Dummy-mixer tests are not listening tests.

Build/check logs: test-results/check-20261117-052718 and
test-results/package-20261117-052804. Detailed captures and receipts:
D:/Codex-build-cache/clarity-20261117/{source-final,final-packed,final-walk}.

Retained failed attempts: initial card-11 size assertion failed due floating
point rounding at 460 px, fixed with 0.01 px tolerance. First packed turn test
could not read its test-only reference JSON (intentionally excluded from the
player package); rerun passed with its explicit external reference path.
The temporary export-selection merge conflict was regenerated and corrected
before the successful final build. No failed run counts as a pass.

Limits: low-resolution source interiors retain their original soft brushwork;
the four principal walk poses at 6 fps still have a low-frame animation feel.
These repairs do not establish whole-game performance or player acceptance.
