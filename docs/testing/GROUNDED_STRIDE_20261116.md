# Painted stride and world travel

The user clarified that the legs move but the actor appears to slide. The prior constant 2x playback change is superseded.

The twelve movie frames repeat a four-pose gait three times. In the first stance the dark boot's measured source contact moves approximately 939 -> 742 -> 554 pixels, against a source height of 1830 pixels. The 295-pixel street actor therefore needs about 31 world pixels between adjacent stance poses. Fixed 12-fps playback at 200 world pixels/second moved only 16.7 world pixels per pose, causing the supporting foot to slide backwards.

Runtime now advances the original phase timeline by actual distance divided by painted stride size (0.42 actor heights per four-pose stride). Changing actor height, maximum speed or Shift acceleration no longer changes the ratio of foot motion to travel. Source PNGs, source durations, geometry and single-silhouette rendering are retained. Grounded footstep cues use two contacts per four-pose stride; hidden turning cannot emit steps.

The standing turn now finishes before translation begins. Initial facing is selected before this turn, and existing moving retargets still brake before reversing. This removes whole-body sideways sliding during the turn. The existing 0.24-second turn is intentional; it is not a frame-pacing fix.

## Evidence

- Source: walk framebuffer 7/0, turn continuity 60/0, movement/input smoke 90/0.
- GPU screenshots measure the rendered dark boot across three stance poses at actor heights 156 and 295. Contact-centroid drift stays below four framebuffer pixels, including antialiasing/sole-shape differences. This tests sampled contacts; it does not claim continuous foot locking between the four authored poses.
- Native window: an actual ground click was observed taking the actor into the walking pose, moving along the street and returning to idle at the destination. Subjective gait approval remains with the user.
- Visual review retained crisp original silhouettes. Implementation review corrected world-distance/size coupling; adversarial checks cover stationary turns, movement resumption, reverse/cancel, callbacks and 30/60/144-Hz consistency. Audio review checked distance-based event timing only; subjective listening was not performed.

Exported-package checks and hash are recorded in the local delivery receipt. No original save or artwork was modified.
