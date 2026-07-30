#!/usr/bin/env python3
"""Build AF-01's battle vista from its admitted Cinder Gate derivatives."""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path

from PIL import Image


GROUND = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_ground.png")
BARRICADE = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_barricade.png")
OUTPUT = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_battle_backdrop.png")
METADATA = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_battle_backdrop.metadata.json")
GROUND_SHA256 = "c65b64be23b7a1fd86f8bba9f74167b34ed658d6391fc3dc1babf9182b1907c5"
BARRICADE_SHA256 = "ba4cca14d60a230730247f94a76d47e97c4765a0362635237487bcef500a283e"
SIZE = (384, 360)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _read_verified(root: Path, path: Path, checksum: str) -> bytes:
    data = (root / path).read_bytes()
    if sha256(data) != checksum:
        raise ValueError(f"Ashfall battle backdrop input checksum changed: {path}")
    return data


def build(root: Path) -> tuple[bytes, str]:
    ground_data = _read_verified(root, GROUND, GROUND_SHA256)
    barricade_data = _read_verified(root, BARRICADE, BARRICADE_SHA256)
    with Image.open(io.BytesIO(ground_data)) as ground_source, Image.open(io.BytesIO(barricade_data)) as barricade_source:
        ground = ground_source.convert("RGBA").resize((48, 48), Image.Resampling.NEAREST)
        barricade = barricade_source.convert("RGBA").resize((288, 144), Image.Resampling.NEAREST)
        image = Image.new("RGBA", SIZE)
        for y in range(0, SIZE[1], ground.height):
            for x in range(0, SIZE[0], ground.width):
                image.alpha_composite(ground, (x, y))
        image.alpha_composite(barricade, (48, 92))
    output = io.BytesIO()
    image.save(output, format="PNG", optimize=False, compress_level=9)
    png = output.getvalue()
    metadata = {
        "schemaVersion": 1,
        "asset": OUTPUT.as_posix(),
        "derivedChecksum": sha256(png),
        "dimensions": list(SIZE),
        "sources": [
            {"path": GROUND.as_posix(), "checksum": GROUND_SHA256},
            {"path": BARRICADE.as_posix(), "checksum": BARRICADE_SHA256},
        ],
        "bindings": {
            "roomIds": ["AF-01"],
            "profileIds": ["ashfall_cinder_gate_battle_backdrop"],
            "encounterIds": ["ashfall_cinder_gate_arrival_raid"],
            "runtimeStatus": "combat_content_foundation",
        },
        "transform": {
            "id": "ashfall_cinder_gate_battle_backdrop_v1",
            "description": "Nearest-neighbor 384x360 battle vista tiled from admitted ash ground with the admitted Cinder Gate barricade.",
        },
    }
    return png, json.dumps(metadata, indent=2, sort_keys=True) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    png, metadata = build(root)
    output_path = root / OUTPUT
    metadata_path = root / METADATA
    if args.check:
        if not output_path.is_file() or output_path.read_bytes() != png:
            raise ValueError(f"Ashfall battle backdrop is missing or stale: {output_path}")
        if not metadata_path.is_file() or metadata_path.read_text(encoding="utf-8") != metadata:
            raise ValueError(f"Ashfall battle backdrop metadata is missing or stale: {metadata_path}")
        print(f"Ashfall battle backdrop is current: {output_path}")
        return 0
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(png)
    metadata_path.write_text(metadata, encoding="utf-8", newline="\n")
    print(f"Wrote {output_path} and {metadata_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(f"Ashfall battle backdrop error: {error}")
        raise SystemExit(1)
