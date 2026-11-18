# Walker resume regression timing

The November 8 fixture checked fresh movement after 0.20–0.25 seconds.
The current courier first completes an authored 0.24-second standing turn,
then accelerates. Those deadlines therefore rejected valid movement before
the first step. The previously reported 22 failures were reproduced on both
the baseline and background-budget candidate; no runtime fix was implied.

This test-only correction observes deterministic motion after 0.50 seconds,
retains the displacement/velocity assertions, and checks that fresh input
starts the turn without sliding at 0.12 seconds. Held-key blocking, independent
direction release, focus loss, repeated modal cycles and cancelled click
callbacks remain covered. Negative stationary assertions now observe longer.

For real-frame host tests, a fixed 0.50-second timer intermittently failed
the bag-close case: the next run with diagnostics passed with approximately
39 pixels of travel and an unblocked held key. The final fixture waits for
the original >5-pixel threshold with a hard 2-second wall-clock deadline.
It still fails if movement never resumes; it is not a frame-time benchmark.

Final result: **69 checks, 0 failures**, using the actual five-day release PCK
SHA256 `d17e2293ca9dba93f2a23ffe18c607de2e170be39f53a670559bf4920e195deb`.
Escape and bag modal cases both reported completed turns, enabled/focused
movement, held input, no blocked keys and positive velocity.
GPU rendering used synthetic engine input and simulated focus notifications,
isolated QA saves/preferences and a Dummy mixer. This is not new OS-input,
listening or human gameplay acceptance.

Local evidence: `D:/Codex-build-cache/dear-efficiency-20261117/resume-20261119/`.
The existing game package and five-day campaign are unchanged by this patch.
The original failed results remain historical evidence; this report supersedes
the unresolved timing diagnosis in BACKGROUND_FRAME_BUDGET_20261117.md.
