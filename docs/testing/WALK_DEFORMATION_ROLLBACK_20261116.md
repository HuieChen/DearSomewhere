# Rejected walking deformation — corrective rollback

The user's direct feedback is "人走路怎么越来越奇怪了". The preceding
continuous-footplant change is rejected, irrespective of its numeric test pass.

## Sequential review

- Design/art: unequal pose dwell (especially the long fourth pose), large boot
  shear and synthetic lifting changed the supplied gait. Remove those effects.
- Implementation: restore the walker, shader, numeric registration generator,
  registration data and two existing fixtures to their `6fe9198` versions. Keep
  detached-alpha cleanup and stable head height. Preserve all concurrent main
  changes to UI, sound, loading and scene transitions.
- Adversarial QA: remove the test for the rejected synthetic stance; its pass
  cannot prove anatomical shape or natural motion. Recheck the original pose
  hashes, timing, turns, movement controls, alpha and height.
- Audio: revert the footstep-distance change with its gait change; listening
  acceptance is not inferred from tests. Current collaborator audio work stays.
- Producer: this is regression containment, not acceptance of all walking.
  Earlier sliding/choppiness complaints remain open. Studio's historic story
  gate is NOT_COMPLETE; the explicit current repair takes precedence over its
  old story order, without advancing its completion state.

No supplied PNG or source video was edited. No new gait synthesis is introduced.
Verification and installed-package details are recorded in the delivery receipt.

Source checks pass 163/163 (render, turn continuity, controller). The final PCK
passes those plus the recorder fixture: 207/207. Native packaged window was
opened and a ground click visibly started the restored original-pose walk.
These checks prove removal of the rejected path, not natural-motion acceptance.
PCK SHA-256: `6EC73DCCFDD53FA46E2871C3556BB05B72AF57701159A86D07F87E59329A1803`.
