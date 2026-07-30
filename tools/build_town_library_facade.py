#!/usr/bin/env python3
"""Build the Town Library's transparent facade from its authored showcase crop.

The Modern World Overworld pack paints this library directly over its own lawn.
The game needs the facade on the campaign's shared ground, so this deterministic
derivation removes only the measured showcase-lawn colour range.  Keeping the
PNG and its source metadata in the repository makes the transform reviewable and
prevents the renderer from performing an untracked pixel mutation at runtime.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path

from PIL import Image

SOURCE = Path("game/game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png")
OUTPUT = Path("game/ben_rpg/visual_assets/derived/town_library_facade.png")
METADATA = Path("game/ben_rpg/visual_assets/derived/town_library_facade.metadata.json")
SOURCE_SHA256 = "64a43b2b6abdcb31777d129b9121ef85e7ebf9a04aef43200c169f01690019e2"
REGION = (141, 290, 102, 96)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def is_showcase_lawn(red: int, green: int, blue: int, alpha: int) -> bool:
    """Match the previous GDScript colour thresholds exactly in 8-bit space."""
    return (
        alpha > 0
        and 115 <= red <= 153
        and 174 <= green <= 209
        and 64 <= blue <= 122
        and green - red >= 36
    )


def build(root: Path) -> tuple[bytes, str]:
    source_path = root / SOURCE
    source_data = source_path.read_bytes()
    if sha256(source_data) != SOURCE_SHA256:
        raise ValueError(f"Library source checksum changed: {source_path}")
    with Image.open(io.BytesIO(source_data)) as source:
        image = source.convert("RGBA").crop((REGION[0], REGION[1], REGION[0] + REGION[2], REGION[1] + REGION[3]))
    pixels = image.load()
    removed = 0
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if is_showcase_lawn(red, green, blue, alpha):
                pixels[x, y] = (red, green, blue, 0)
                removed += 1
    output = io.BytesIO()
    image.save(output, format="PNG", optimize=False, compress_level=9)
    png = output.getvalue()
    metadata = {
        "schemaVersion": 1,
        "asset": OUTPUT.as_posix(),
        "derivedChecksum": sha256(png),
        "dimensions": [image.width, image.height],
        "source": {
            "path": SOURCE.as_posix(),
            "checksum": SOURCE_SHA256,
            "region": list(REGION),
        },
        "transform": {
            "id": "town_library_showcase_lawn_transparency_v1",
            "description": "Sets alpha to zero for the source pack's measured showcase-lawn colour range.",
            "pixelsMadeTransparent": removed,
            "thresholds8Bit": {"red": [115, 153], "green": [174, 209], "blue": [64, 122], "minimumGreenMinusRed": 36},
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
            raise ValueError(f"derived library facade is missing or stale: {output_path}")
        if not metadata_path.is_file() or metadata_path.read_text(encoding="utf-8") != metadata:
            raise ValueError(f"derived library facade metadata is missing or stale: {metadata_path}")
        print(f"Town Library derived facade is current: {output_path}")
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
        print(f"Town Library derived facade error: {error}")
        raise SystemExit(1)
