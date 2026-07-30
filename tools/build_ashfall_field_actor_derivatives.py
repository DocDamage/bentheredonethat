#!/usr/bin/env python3
"""Build checksum-pinned eight-direction AF-01 field-actor derivatives."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


DIRECTIONS = ("north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west")
ACTORS = {
    "scrap_kid": "1._SCRAP_KID_FREE",
    "dust_hunter": "4._DUST_HUNTER",
    "iron_sentinel": "9._IRON_SENTINEL",
}
SOURCE_ROOT = Path("assets/characters/SakPix - 8-Direction Characters - ALL AS OF 7-3-26/☢️ WASTELAND LEGENDS")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build(root: Path) -> list[tuple[Path, bytes, str]]:
    outputs: list[tuple[Path, bytes, str]] = []
    for actor_id, folder in ACTORS.items():
        for direction in DIRECTIONS:
            source = root / SOURCE_ROOT / folder / "rotations" / f"{direction}.png"
            data = source.read_bytes()
            output = root / "game/ben_rpg/visual_assets/derived" / f"af01_{actor_id}_{direction}.png"
            metadata = {
                "schemaVersion": 1,
                "asset": output.relative_to(root).as_posix(),
                "derivedChecksum": sha256(data),
                "dimensions": [92, 92],
                "source": {"path": source.relative_to(root).as_posix(), "checksum": sha256(data), "region": [0, 0, 92, 92]},
                "bindings": {"roomIds": ["AF-01"], "actorId": f"af01_{actor_id}_field_actor", "direction": direction, "runtimeStatus": "field_profile_admission"},
                "transform": {"id": "exact_source_copy_v1", "description": "Exact supplied rotation copy; no crop, colour, alpha, or scale transform."},
            }
            outputs.append((output, data, json.dumps(metadata, ensure_ascii=False, indent=2, sort_keys=True) + "\n"))
    return outputs


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    for output, data, metadata in build(root):
        metadata_path = output.with_suffix(".metadata.json")
        if args.check:
            if not output.is_file() or output.read_bytes() != data:
                raise ValueError(f"Ashfall field-actor derivative is missing or stale: {output}")
            if not metadata_path.is_file() or metadata_path.read_text(encoding="utf-8") != metadata:
                raise ValueError(f"Ashfall field-actor metadata is missing or stale: {metadata_path}")
        else:
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(data)
            metadata_path.write_text(metadata, encoding="utf-8", newline="\n")
    print("Ashfall field-actor derivatives are current." if args.check else "Wrote Ashfall field-actor derivatives.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(f"Ashfall field-actor derivative error: {error}")
        raise SystemExit(1)
