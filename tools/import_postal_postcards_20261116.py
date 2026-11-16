"""Extract the supplied rack layers, real occlusion masks and removal patches.

Requires psd-tools, Pillow and numpy. Original PSD/composite stay immutable.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter, ImageOps
from psd_tools import PSDImage
from psd_tools.constants import BlendMode
from psd_tools.composite.blend import soft_light

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/authoring/post_office_20261116/postcards'
SOURCE_SHA = '7c81c89043f54219d0852c74b7aa78fb0d7216760816c8190197510dd80961da'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    source = parser.parse_args().source
    assert digest(source) == SOURCE_SHA
    psd = PSDImage.open(source)
    original_path = ROOT / 'assets/authoring/post_office_20261116/room_pair.png'
    original_sha = digest(original_path)
    original = Image.open(original_path).convert('RGBA')
    assert psd[12].is_group() and len(psd[12]) == 18
    assert psd[21].blend_mode == BlendMode.SOFT_LIGHT and psd[21].opacity == 110
    tone = psd[21].topil(apply_icc=False)
    leaves = [layer for layer in psd.descendants() if not layer.is_group() and layer.is_visible()]
    # Actual source alpha, not the export's full-canvas layer bounds.
    alphas = {id(layer): layer.topil(apply_icc=False).getchannel('A') for layer in leaves}
    OUT.mkdir(parents=True, exist_ok=True)
    records = []
    obscured = []
    for index in range(5, 17):
        layer = psd[12][index]
        assert layer.blend_mode == BlendMode.NORMAL and layer.opacity == 255
        pixels = layer.topil(apply_icc=False)
        box = pixels.getchannel('A').getbbox()
        face = pixels.crop(box)
        visible = np.asarray(face.getchannel('A')).astype(np.float32) / 255
        for above in leaves[leaves.index(layer)+1:]:
            if above.blend_mode in (BlendMode.NORMAL, BlendMode.PASS_THROUGH):
                visible *= 1 - np.asarray(alphas[id(above)].crop(box)).astype(np.float32) / 255 * above.opacity / 255
        count = int((visible > .5).sum())
        if count < 100:
            obscured.append({'layer_path': [12, index], 'visible_pixels': count})
            print('fully occluded', index, count, flush=True)
            continue
        name = f'postcard_{index:02d}'
        rgba = np.asarray(face).copy()
        tint = np.asarray(tone.crop(box)).astype(np.float32)/255
        rgb = rgba[:, :, :3].astype(np.float32)/255
        amount = tint[:, :, 3:4] * psd[21].opacity/255
        rgba[:, :, :3] = np.rint(np.clip(rgb*(1-amount)+soft_light(rgb,tint[:, :, :3])*amount,0,1)*255).astype('uint8')
        Image.fromarray(rgba).save(OUT/(name+'.png'))
        mask = np.full_like(rgba, 255)
        mask[:, :, 3] = np.rint(visible*255).astype('uint8')
        Image.fromarray(mask).save(OUT/(name+'_hit.png'))
        # Restore the author-painted pixels behind the lifted layer, including
        # the original rail and telephone. Preserve the saved composite exactly
        # outside the affected pixels despite compositor rounding differences.
        baseline = np.asarray(psd.composite(viewport=box,ignore_preview=True,apply_icc=False).convert('RGB')).astype('int16')
        removed = np.asarray(psd.composite(viewport=box,ignore_preview=True,apply_icc=False,layer_filter=lambda candidate: candidate.is_visible() and candidate is not layer).convert('RGB')).astype('int16')
        saved = np.asarray(original.crop(box)).copy()
        saved[:, :, :3] = np.clip(saved[:, :, :3].astype('int16')+removed-baseline,0,255).astype('uint8')
        Image.fromarray(saved).save(OUT/(name+'_removed.png'))
        inner = ImageOps.expand(Image.fromarray(((visible > .5)*255).astype('uint8')),border=1,fill=0)
        while True:
            smaller = inner.filter(ImageFilter.MinFilter(3))
            if smaller.getbbox() is None:
                break
            inner = smaller
        ys,xs = np.nonzero(np.asarray(inner))
        y,x = int(ys[len(ys)//2]-1),int(xs[len(xs)//2]-1)
        records.append({'id': name, 'layer_path': [12,index], 'layer_name': layer.name,
                        'source_rect': [box[0],box[1],box[2]-box[0],box[3]-box[1]],
                        'visible_pixels': count, 'probe_source_point': [int(x+box[0]),int(y+box[1])],
                        'face': f'res://assets/authoring/post_office_20261116/postcards/{name}.png',
                        'hit_mask': f'res://assets/authoring/post_office_20261116/postcards/{name}_hit.png',
                        'removed_patch': f'res://assets/authoring/post_office_20261116/postcards/{name}_removed.png'})
        print('extracted', name, 'visible pixels', count, flush=True)
    record = {'source_sha256': SOURCE_SHA, 'saved_composite_sha256': original_sha,
              'ai_generated': False, 'cards': records, 'fully_occluded_layers': obscured,
              'method': 'original RGBA card layers with authored soft-light finish; masks subtract foreground alpha; local removal patches from PSD recomposition delta',
              'files': {p.name: digest(p) for p in sorted(OUT.glob('*.png'))}}
    assert digest(source) == SOURCE_SHA and digest(original_path) == original_sha
    (OUT/'cards.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('CARDS', len(records), 'SOURCE_UNCHANGED', flush=True)

if __name__ == '__main__':
    main()
