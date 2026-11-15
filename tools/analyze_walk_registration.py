"""Measure immutable walk PNGs; write numeric runtime metadata, never images.

Requires numpy, Pillow and opencv-python-headless 4.10.0.84.
"""
import hashlib
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = ROOT / "assets/authoring/courier_walk_20261110"


def main():
    manifest = json.loads((DIRECTORY / "walk.json").read_text(encoding="utf-8"))
    entries = {}
    reference = None
    for frame in manifest["frames"]:
        path = ROOT / frame["path"].removeprefix("res://")
        assert hashlib.sha256(path.read_bytes()).hexdigest() == frame["sha256"]
        pixels = np.asarray(Image.open(path).convert("RGBA"))
        alpha = pixels[:, :, 3]
        count, labels, stats, _ = cv2.connectedComponentsWithStats((alpha > 16).astype("uint8"), 8)
        main_label = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        body = (labels == main_label).astype("uint8")
        # Keep every solid body pixel plus a three-source-pixel AA margin.
        keep = cv2.dilate(body, np.ones((7, 7), dtype="uint8")) > 0
        remove = (alpha > 0) & ~keep
        assert not np.any(remove & (labels == main_label))
        spans = []
        for y in np.where(remove.any(axis=1))[0]:
            edges = np.diff(np.pad(remove[y].astype("int8"), (1, 1)))
            for start, end in zip(np.where(edges == 1)[0], np.where(edges == -1)[0]):
                spans.append([int(start), int(y), int(end - start)])
        head = cv2.resize(body[:1100].astype("float32"), (300, 275), interpolation=cv2.INTER_AREA)
        if reference is None:
            reference = head.copy()
        score, translation = cv2.findTransformECC(reference, head, np.eye(2, 3, dtype="float32"), cv2.MOTION_TRANSLATION, (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 100, 1e-5))
        assert score > 0.75
        red, green, blue = (pixels[:, :, channel].astype(float) for channel in range(3))
        boot = (alpha > 240) & (red > green * .85) & (red < green * 1.3) & (blue < green * .85)
        boot[:1450] = False
        contacts = []
        boot_seeds = []
        # Use interior pigment bins, excluding the other boot's compressed
        # dark fringe from the sole measurement.
        for mask in [boot & (red // 8 == 4) & (green // 8 == 4) & (blue // 8 == 2), boot & (red // 8 == 10) & (green // 8 == 10) & (blue // 8 == 6)]:
            boot_seeds.append(mask)
            ys, xs = np.where(mask)
            bottom = int(ys.max())
            sole = xs[ys >= bottom - 20]
            contacts.append([round(float(sole.mean()), 3), bottom])
        entries[path.name] = {"source_sha256": frame["sha256"], "clear_spans": spans, "removed_pixels": int(remove.sum()), "head_translation_px": [round(float(value * 4), 4) for value in translation[:, 2]], "registration_score": round(float(score), 5), "foot_contacts_px": contacts}
        distances = [cv2.distanceTransform((~seed).astype('uint8'), cv2.DIST_L2, 5) for seed in boot_seeds]
        boot_spans = []
        for side in range(2):
            # Include the compressed fringe around the measured solid pigment.
            # Classifying its nearly black RGB directly would leave debris behind.
            below_knee = np.arange(alpha.shape[0])[:, None] >= 1600
            region = ((distances[side] < 18) | below_knee) & (distances[side] <= distances[1-side])
            region[:1450] = False
            for y in np.where(region.any(axis=1))[0]:
                edges = np.diff(np.pad(region[y].astype('int8'), (1, 1)))
                for start, end in zip(np.where(edges == 1)[0], np.where(edges == -1)[0]):
                    boot_spans.append([int(start), int(y), int(end-start), side])
        entries[path.name]['boot_spans'] = boot_spans
        print(path.name, "removed", int(remove.sum()), "head", entries[path.name]["head_translation_px"])
    values = list(entries.values())
    for index, entry in enumerate(values):
        support = 1 if index % 4 == 3 else 0
        entry["stance_travel_px"] = round(entry["foot_contacts_px"][support][0] - values[(index + 1) % len(values)]["foot_contacts_px"][support][0], 3)
        assert entry["stance_travel_px"] > 50
    (DIRECTORY / "runtime_registration.json").write_text(json.dumps({"method": "connected alpha support plus measured upper-body and boot registration; no source rewrite", "frames": entries}, separators=(",", ":")) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
