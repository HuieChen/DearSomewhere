"""Export the author's saved PSD composite without recomposing or repainting."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE_SHA = '7c81c89043f54219d0852c74b7aa78fb0d7216760816c8190197510dd80961da'
OUT = ROOT / 'assets/authoring/post_office_20261116'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    source = parser.parse_args().source
    before = hashlib.sha256(source.read_bytes()).hexdigest()
    assert before == SOURCE_SHA, 'Unexpected source PSD'
    with Image.open(source) as psd:
        assert psd.size == (5120, 1440) and psd.mode == 'RGBA'
        pixels = psd.copy()  # Frame zero is the saved merged composite.
        profile = psd.info.get('icc_profile', b'')
        layer_count = len(psd.layers)
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / 'room_pair.png'
    if path.exists():
        with Image.open(path) as existing:
            assert existing.size == pixels.size and existing.mode == pixels.mode
            assert existing.tobytes() == pixels.tobytes(), 'Refusing to overwrite different art'
    else:
        pixels.save(path, icc_profile=profile)
    with Image.open(path) as exported:
        assert exported.tobytes() == pixels.tobytes()
    assert hashlib.sha256(source.read_bytes()).hexdigest() == before
    record = {
        'source_kind': 'user_psd_saved_composite', 'source_filename': source.name,
        'source_sha256': before, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'pixel_sha256': hashlib.sha256(pixels.tobytes()).hexdigest(),
        'stored_file': path.name, 'dimensions': list(pixels.size), 'mode': pixels.mode,
        'layer_record_count': layer_count, 'ai_generated': False,
        'method': 'Pillow PSD frame zero; saved composite pixels; ICC profile retained without conversion',
        'recomposed': False, 'resized': False, 'source_unchanged': True,
        'regions': [[0, 0, 2560, 1440], [2560, 0, 2560, 1440]],
        'authorization': 'User supplied this PSD and requested replacement of the post office scene.'
    }
    (OUT / 'provenance.json').write_text(json.dumps(record, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({'size': pixels.size, 'png_sha256': record['sha256'], 'source_unchanged': True}))

if __name__ == '__main__':
    main()
