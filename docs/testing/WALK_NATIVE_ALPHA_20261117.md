# Native courier alpha correction

User screenshots showed black fragments on the hair curl, fringe and face.
The old importer discarded the movie's auxiliary alpha, guessed coverage from
RGB darkness, then eroded the result. This left matte fragments while risking
real dark ink. FFmpeg 9 exposes the original HEVC alpha plane.

Re-extract the same twelve frames, original 6 fps sequence and shared
1200 x 1920 crop from the immutable supplied movie. Preserve decoded RGBA;
its colour is already premultiplied, so prepare mipmaps without multiplying
alpha a second time. The canvas shader converts once for straight-alpha
blending. Remove the old neighbour-colour substitution. Retain disconnected
speck removal, existing numeric pose registration, all five turn assets,
timing, movement controls, palette and saves. No AI redraw or synthetic gait.

Source validation: native-alpha regression covers all twelve frames and
25,778 partially transparent head-edge samples, with zero darkened samples.
GPU sheets cover both directions on cream and sunset-coloured backgrounds;
curl, hair tips and jaw are visibly clean, with eyes/lashes/mouth retained.
Movement/turn suite passes 60 checks; height/render suite passes 13 checks.
Original turn hashes are unchanged. Actual exported-package checks and
native-window status are recorded in the package delivery receipt separately.
These checks do not declare user acceptance of overall gait or art.
