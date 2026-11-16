"""Extract the supplied 6 fps MOV; preserve source order and shared registration.

Usage: python tools/import_walk_20261110.py SOURCE_MOV FFMPEG
Only derived frames enter the repository. Never writes the source movie.
"""
import hashlib, json, subprocess, sys, tempfile
from pathlib import Path
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1]
source, ffmpeg = Path(sys.argv[1]), sys.argv[2]
out = root / 'assets/authoring/courier_walk_20261110'
out.mkdir(parents=True, exist_ok=True)
frames = []
with tempfile.TemporaryDirectory() as tmp:
    subprocess.run([ffmpeg, '-v', 'error', '-i', str(source), '-vf',
                    'crop=1200:1920:780:730', '-pix_fmt', 'rgba', '-fps_mode', 'passthrough',
                    str(Path(tmp)/'frame_%02d.png')], check=True)
    inputs = sorted(Path(tmp).glob('frame_*.png'))
    assert len(inputs) == 12, 'Unexpected source duration/frame count'
    for index, path in enumerate(inputs):
        # Shared crop avoids frame-by-frame scaling or registration jitter.
        # FFmpeg 9 decodes this HEVC video's auxiliary alpha plane. Older
        # decoders returned opaque RGB, which must never be colour-keyed:
        # near-black RGB includes real ink and is not a coverage measure.
        rgba = np.array(Image.open(path).convert('RGBA'))
        alpha = rgba[:, :, 3]
        assert (alpha == 0).sum() > alpha.size * .3, 'Decoder did not expose native alpha'
        assert ((alpha > 0) & (alpha < 255)).sum() > 1000, 'Missing original antialiasing'
        target = out/f'walk_{index:02d}.png'
        Image.fromarray(rgba).save(target)
        frames.append(dict(path='res://'+target.relative_to(root).as_posix(),
                           duration_seconds=1/6, source_frame=index,
                           reference_height_px=1830, foot_anchor_px=[770,1905],
                           sha256=hashlib.sha256(target.read_bytes()).hexdigest()))
(out/'walk.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    fps=6, source_size=[4096,3074], shared_source_crop=[780,730,1200,1920],
    alpha_source='native HEVC auxiliary alpha, FFmpeg 9 RGBA; premultiplied RGB; no colour key or erosion',
    premultiplied_alpha=True,
    ai_generated=False, frames=frames), indent=2)+'\n', encoding='utf-8')
print(f'Imported {len(frames)} original frames at 6 fps')
