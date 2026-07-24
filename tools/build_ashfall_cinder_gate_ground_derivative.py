#!/usr/bin/env python3
"""Build the Cinder Gate's repeatable ash-ground tile from its licensed sheet."""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path

from PIL import Image


SOURCE = Path("assets/Tilesets/Ashlands Tileset/1x/tf_A1_ashlands_1.png")
OUTPUT = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_ground.png")
METADATA = Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_ground.metadata.json")
SOURCE_SHA256 = "f45630241d7f010e823778a3d9af813969ee13345a330414abab7e6a93be5c04"
REGION = (0, 64, 16, 16)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build(root: Path) -> tuple[bytes, str]:
    source_path = root / SOURCE
    source_data = source_path.read_bytes()
    if sha256(source_data) != SOURCE_SHA256:
        raise ValueError(f"Ashfall ground source checksum changed: {source_path}")
    with Image.open(io.BytesIO(source_data)) as source:
        image = source.convert("RGBA").crop((REGION[0], REGION[1], REGION[0] + REGION[2], REGION[1] + REGION[3]))
    output = io.BytesIO()
    image.save(output, format="PNG", optimize=False, compress_level=9)
    png = output.getvalue()
    metadata = {
        "schemaVersion": 1,
        "asset": OUTPUT.as_posix(),
        "derivedChecksum": sha256(png),
        "dimensions": [image.width, image.height],
        "source": {"path": SOURCE.as_posix(), "checksum": SOURCE_SHA256, "region": list(REGION)},
        "bindings": {"roomIds": ["AF-01"], "profileIds": [], "runtimeStatus": "prototype_scene_admission"},
        "transform": {
            "id": "ashfall_cinder_gate_ground_crop_v1",
            "description": "Exact repeatable ash-ground cell for AF-01; no colour, alpha, or scale changes.",
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
            raise ValueError(f"Ashfall ground derivative is missing or stale: {output_path}")
        if not metadata_path.is_file() or metadata_path.read_text(encoding="utf-8") != metadata:
            raise ValueError(f"Ashfall ground metadata is missing or stale: {metadata_path}")
        print(f"Ashfall Cinder Gate ground derivative is current: {output_path}")
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
        print(f"Ashfall Cinder Gate ground derivative error: {error}")
        raise SystemExit(1)
