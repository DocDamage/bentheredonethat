#!/usr/bin/env python3
"""Build the Cinder Gate beacon and filter-cache visual derivatives."""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path

from PIL import Image


SPECS = (
    {
        "id": "ashfall_cinder_gate_air_beacon",
        "source": Path("assets/Tilesets/Wasteland survivor kit/18. Light sources and fire barrels.png"),
        "checksum": "f836b9638187790f1eec033e20d025bacf9bed56e35ffbb8a1cc5fd36f5a182b",
        "region": (626, 394, 112, 144),
        "output": Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_air_beacon.png"),
        "description": "Exact emergency-beacon crop for AF-01's air-quality interaction; no colour, alpha, or scale changes.",
    },
    {
        "id": "ashfall_cinder_gate_filter_cache",
        "source": Path("assets/Tilesets/Wasteland survivor kit/16. Loot and survival props.png"),
        "checksum": "3760542af6506073bd3dc927126f545ec1db44f27e26e3e3ef3beefe0fb7b6f4",
        "region": (1210, 180, 160, 144),
        "output": Path("game/ben_rpg/visual_assets/derived/ashfall_cinder_gate_filter_cache.png"),
        "description": "Exact medical-survival cache crop for AF-01's one-time filter reward; no colour, alpha, or scale changes.",
    },
)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build(root: Path, spec: dict) -> tuple[bytes, str]:
    source_path = root / spec["source"]
    source_data = source_path.read_bytes()
    if sha256(source_data) != spec["checksum"]:
        raise ValueError(f"Ashfall feature source checksum changed: {source_path}")
    x, y, width, height = spec["region"]
    with Image.open(io.BytesIO(source_data)) as source:
        image = source.convert("RGBA").crop((x, y, x + width, y + height))
    output = io.BytesIO()
    image.save(output, format="PNG", optimize=False, compress_level=9)
    png = output.getvalue()
    metadata = {
        "schemaVersion": 1,
        "asset": spec["output"].as_posix(),
        "derivedChecksum": sha256(png),
        "dimensions": [image.width, image.height],
        "source": {"path": spec["source"].as_posix(), "checksum": spec["checksum"], "region": list(spec["region"])},
        "bindings": {"roomIds": ["AF-01"], "profileIds": [], "runtimeStatus": "prototype_scene_admission"},
        "transform": {"id": f"{spec['id']}_crop_v1", "description": spec["description"]},
    }
    return png, json.dumps(metadata, indent=2, sort_keys=True) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    for spec in SPECS:
        png, metadata = build(root, spec)
        output_path = root / spec["output"]
        metadata_path = output_path.with_suffix(".metadata.json")
        if args.check:
            if not output_path.is_file() or output_path.read_bytes() != png:
                raise ValueError(f"Ashfall feature derivative is missing or stale: {output_path}")
            if not metadata_path.is_file() or metadata_path.read_text(encoding="utf-8") != metadata:
                raise ValueError(f"Ashfall feature metadata is missing or stale: {metadata_path}")
        else:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_bytes(png)
            metadata_path.write_text(metadata, encoding="utf-8", newline="\n")
    print("Ashfall Cinder Gate feature derivatives are current." if args.check else "Wrote Ashfall Cinder Gate feature derivatives.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(f"Ashfall feature derivative error: {error}")
        raise SystemExit(1)
