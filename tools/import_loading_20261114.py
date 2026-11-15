"""Extract the supplied transparent loading animation without redrawing its line art."""
import hashlib, json, subprocess, sys, tempfile
from pathlib import Path
import numpy as np
from PIL import Image

root = Path(__file__).resolve().parents[1]
source, ffmpeg = Path(sys.argv[1]), sys.argv[2]
out = root / 'assets/authoring/loading_20261114'
out.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory() as tmp:
    subprocess.run([ffmpeg, '-v', 'error', '-i', str(source), '-fps_mode', 'passthrough',
                    str(Path(tmp) / 'frame_%02d.png')], check=True)
    inputs = sorted(Path(tmp).glob('frame_*.png'))
    if len(inputs) != 6:
        raise RuntimeError(f'Expected six 5fps frames, got {len(inputs)}')
    rgba = []
    for path in inputs:
        # HEVC contains authored alpha. Never derive opacity from RGB: that
        # exposes hidden matte/color pixels and weakens the cyan line strokes.
        image = Image.open(path)
        if image.mode != 'RGBA':
            raise RuntimeError('Decoder did not expose the source alpha channel')
        frame = np.asarray(image).copy()
        if frame[:, :, 3].min() == 255:
            raise RuntimeError('Source transparency was lost during decode')
        rgba.append(frame)
    union = np.zeros(rgba[0].shape[:2], dtype=bool)
    for frame in rgba:
        union |= frame[:, :, 3] > 0
    ys, xs = np.where(union)
    pad = 36
    box = (max(0, int(xs.min()) - pad), max(0, int(ys.min()) - pad),
           min(rgba[0].shape[1], int(xs.max()) + pad + 1),
           min(rgba[0].shape[0], int(ys.max()) + pad + 1))
    frames = []
    for i, frame in enumerate(rgba):
        target = out / f'frame_{i:02d}.png'
        Image.fromarray(frame).crop(box).save(target)
        frames.append({'path': 'res://' + target.relative_to(root).as_posix(),
                       'duration_seconds': 0.2,
                       'source_frame': i,
                       'sha256': hashlib.sha256(target.read_bytes()).hexdigest()})
(out / 'manifest.json').write_text(json.dumps({
    'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
    'source_fps': 5, 'frame_count': 6, 'crop': box,
    'ai_generated': False, 'alpha': 'native HEVC alpha preserved byte-for-byte', 'frames': frames}, indent=2) + '\n', encoding='utf-8')
print(f'Imported {len(frames)} authored loading frames, crop={box}')
