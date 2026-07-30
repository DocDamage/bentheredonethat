#!/usr/bin/env python3
"""Build the tracked, release-safe eight-direction SakPix population atlas."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image

import build_population_registry as population


DIRECTIONS = population.REQUIRED_ROTATIONS
CELL_SIZE = 128
IDENTITIES_PER_ROW = 4


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def build(root: Path, source_root: Path, atlas_path: Path) -> dict:
    assignments = sorted(population.parse_assignments(root / "FFVI_ALIGNMENT_COMPLETION_PLAN.md"), key=lambda item: population.stable_id(item["collection"], item["folder"]))
    rows = (len(assignments) + IDENTITIES_PER_ROW - 1) // IDENTITIES_PER_ROW
    atlas = Image.new("RGBA", (IDENTITIES_PER_ROW * len(DIRECTIONS) * CELL_SIZE, rows * CELL_SIZE))
    profiles = []
    for index, assignment in enumerate(assignments):
        identity_id = population.stable_id(assignment["collection"], assignment["folder"])
        block_x = (index % IDENTITIES_PER_ROW) * len(DIRECTIONS) * CELL_SIZE
        block_y = (index // IDENTITIES_PER_ROW) * CELL_SIZE
        regions = {}
        checksums = {}
        dimensions = {}
        for direction_index, direction in enumerate(DIRECTIONS):
            source = source_root / assignment["collection"] / assignment["folder"] / "rotations" / f"{direction}.png"
            if not source.is_file():
                raise ValueError(f"missing {direction} rotation for {identity_id}")
            with Image.open(source) as raw:
                image = raw.convert("RGBA")
            if image.width > CELL_SIZE or image.height > CELL_SIZE:
                raise ValueError(f"rotation exceeds {CELL_SIZE}px atlas cell: {source}")
            x = block_x + direction_index * CELL_SIZE + (CELL_SIZE - image.width) // 2
            y = block_y + CELL_SIZE - image.height
            atlas.alpha_composite(image, (x, y))
            regions[direction] = [x, y, image.width, image.height]
            dimensions[direction] = [image.width, image.height]
            checksums[direction] = sha256(source)
        profile_id = "population_" + hashlib.sha256(identity_id.encode("utf-8")).hexdigest()[:20]
        south = regions["south"]
        profiles.append({
            "id": profile_id,
            "identityId": identity_id,
            "directions": regions,
            "sourceDimensions": dimensions,
            "sourceChecksums": checksums,
            "defaultDirection": "south",
            "footAnchor": [south[2] // 2, south[3] - 1],
            "fieldScaleStatus": "approved",
            "provenanceStatus": "distribution_confirmed",
        })
    atlas_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(atlas_path, optimize=True)
    return {
        "schemaVersion": 1,
        "identityCount": len(profiles),
        "directionsPerIdentity": len(DIRECTIONS),
        "atlas": {
            "runtimeTexture": "res://ben_rpg/population/generated/population_field_atlas.png",
            "sha256": sha256(atlas_path),
            "size": list(atlas.size),
            "cellSize": CELL_SIZE,
        },
        "profiles": profiles,
    }


def validate(payload: dict, atlas_path: Path) -> None:
    if payload.get("schemaVersion") != 1 or payload.get("identityCount") != 258:
        raise ValueError("population visual atlas must contain exactly 258 identities")
    profiles = payload.get("profiles")
    if not isinstance(profiles, list) or len(profiles) != 258:
        raise ValueError("population visual profile list is incomplete")
    ids = set()
    identity_ids = set()
    for profile in profiles:
        profile_id = profile.get("id")
        identity_id = profile.get("identityId")
        if not isinstance(profile_id, str) or not profile_id or profile_id in ids:
            raise ValueError("population visual profile ids must be unique")
        if not isinstance(identity_id, str) or not identity_id.startswith("sakpix:") or identity_id in identity_ids:
            raise ValueError("population visual identities must be unique SakPix ids")
        ids.add(profile_id)
        identity_ids.add(identity_id)
        if set(profile.get("directions", {})) != set(DIRECTIONS):
            raise ValueError(f"{profile_id} must expose all eight directions")
        if profile.get("fieldScaleStatus") != "approved" or profile.get("provenanceStatus") != "distribution_confirmed":
            raise ValueError(f"{profile_id} is not approved for production")
    atlas = payload.get("atlas", {})
    if not atlas_path.is_file() or atlas.get("sha256") != sha256(atlas_path):
        raise ValueError("population atlas checksum is stale")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--source-root", type=Path, default=Path("assets/characters/SakPix - 8-Direction Characters - ALL AS OF 7-3-26"))
    parser.add_argument("--atlas", type=Path, default=Path("game/ben_rpg/population/generated/population_field_atlas.png"))
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/population/generated/population_visual_profiles.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    source_root = args.source_root if args.source_root.is_absolute() else root / args.source_root
    atlas_path = args.atlas if args.atlas.is_absolute() else root / args.atlas
    output = args.output if args.output.is_absolute() else root / args.output
    if args.check:
        payload = json.loads(output.read_text(encoding="utf-8"))
        validate(payload, atlas_path)
        print(f"Population visual atlas is current: {output}")
        return 0
    if not source_root.is_dir():
        raise ValueError(f"population source root is unavailable: {source_root}")
    payload = build(root, source_root, atlas_path)
    validate(payload, atlas_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8", newline="\n")
    print(f"Wrote {output} with 258 eight-direction population profiles.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Population visual atlas error: {error}")
        raise SystemExit(1)
