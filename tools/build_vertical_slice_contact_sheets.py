#!/usr/bin/env python3
"""Render local native-scale environment and resident review sheets for M2.

The ignored source libraries remain outside release content.  This tool creates
workstation-only review evidence: selected source sheets are composited at one
source pixel per output pixel, and the population identities assigned to each
world are shown in all eight directions on a shared 48-pixel field grid.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, UnidentifiedImageError


DIRECTIONS = ("north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west")
FIELD_GRID_PIXELS = 48
PADDING = 10
LABEL_HEIGHT = 16
LABEL_WIDTH = 330
MAX_ROW_WIDTH = 4096
BACKGROUND = (20, 24, 34, 255)
GRID = (62, 77, 98, 255)
BASELINE = (228, 186, 76, 255)
TEXT = (238, 241, 248, 255)
MUTED = (174, 185, 204, 255)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def relative(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def load_config(path: Path) -> list[dict[str, Any]]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    worlds = raw.get("worlds")
    if raw.get("schemaVersion") != 1 or not isinstance(worlds, list):
        raise ValueError("vertical-slice contact-sheet config must use schemaVersion 1 with worlds")
    seen: set[str] = set()
    for world in worlds:
        if not isinstance(world, dict):
            raise ValueError("each vertical-slice contact-sheet world must be an object")
        world_id = world.get("id")
        room_prefix = world.get("roomPrefix")
        globs = world.get("environmentSourceGlobs")
        if (
            not isinstance(world_id, str) or not world_id or world_id in seen
            or not isinstance(room_prefix, str) or not room_prefix
            or not isinstance(globs, list) or not globs or not all(isinstance(item, str) and item for item in globs)
        ):
            raise ValueError("world records need unique id, roomPrefix, and environmentSourceGlobs")
        seen.add(world_id)
    return sorted(worlds, key=lambda world: str(world["id"]))


def environment_sources(root: Path, world: dict[str, Any]) -> list[Path]:
    selected: dict[str, Path] = {}
    for pattern in world["environmentSourceGlobs"]:
        matches = sorted(root.glob(pattern), key=lambda path: path.as_posix().casefold())
        if not matches:
            raise ValueError(f"{world['id']} source pattern has no files: {pattern}")
        for path in matches:
            if not path.is_file() or path.suffix.casefold() != ".png":
                raise ValueError(f"{world['id']} source pattern selected a non-PNG file: {path}")
            selected[relative(root, path)] = path
    return [selected[key] for key in sorted(selected, key=str.casefold)]


def ascii_label(value: str) -> str:
    return value.encode("ascii", "replace").decode("ascii")


def render_environment(root: Path, world: dict[str, Any]) -> tuple[bytes, list[dict[str, Any]]]:
    records: list[dict[str, Any]] = []
    sources: list[tuple[str, Image.Image]] = []
    for path in environment_sources(root, world):
        try:
            with Image.open(path) as source:
                image = source.convert("RGBA")
        except (OSError, UnidentifiedImageError) as error:
            raise ValueError(f"cannot read {path}: {error}") from error
        label = relative(root, path)
        records.append({"path": label, "sha256": sha256(path), "dimensions": [image.width, image.height]})
        sources.append((label, image))

    rows: list[list[tuple[str, Image.Image]]] = []
    row: list[tuple[str, Image.Image]] = []
    width = PADDING
    for item in sources:
        item_width = item[1].width + PADDING
        if row and width + item_width > MAX_ROW_WIDTH:
            rows.append(row)
            row = []
            width = PADDING
        row.append(item)
        width += item_width
    if row:
        rows.append(row)
    canvas_width = max(sum(image.width + PADDING for _, image in row) + PADDING for row in rows)
    canvas_height = PADDING + sum(max(image.height + LABEL_HEIGHT for _, image in row) + PADDING for row in rows)
    canvas = Image.new("RGBA", (canvas_width, canvas_height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    top = PADDING
    for row in rows:
        row_height = max(image.height + LABEL_HEIGHT for _, image in row)
        left = PADDING
        for label, image in row:
            draw.text((left, top), ascii_label(label), fill=TEXT)
            canvas.alpha_composite(image, (left, top + LABEL_HEIGHT))
            left += image.width + PADDING
        top += row_height + PADDING
    buffer = io.BytesIO()
    canvas.save(buffer, format="PNG")
    return buffer.getvalue(), records


def draw_grid(draw: ImageDraw.ImageDraw, left: int, top: int, width: int, height: int) -> None:
    for x in range(left, left + width + 1, FIELD_GRID_PIXELS):
        draw.line((x, top, x, top + height), fill=GRID)
    for y in range(top, top + height + 1, FIELD_GRID_PIXELS):
        draw.line((left, y, left + width, y), fill=GRID)


def render_population(root: Path, source_root: Path, world: dict[str, Any]) -> tuple[bytes, list[dict[str, Any]]]:
    registry = json.loads((root / "game/ben_rpg/population/generated/population_registry.json").read_text(encoding="utf-8"))
    identities = [
        item for item in registry.get("identities", [])
        if str(item.get("canonicalHome", "")).startswith(str(world["roomPrefix"]))
    ]
    if not identities:
        raise ValueError(f"{world['id']} has no registered population identities")
    identities.sort(key=lambda item: str(item["id"]))
    entries: list[tuple[dict[str, Any], list[Image.Image]]] = []
    records: list[dict[str, Any]] = []
    max_width = max_height = 1
    for identity in identities:
        source_identity = identity.get("sourceIdentity")
        if not isinstance(source_identity, dict):
            raise ValueError(f"population identity has no source identity: {identity.get('id')}")
        identity_root = source_root / str(source_identity["collection"]) / str(source_identity["folder"])
        rotations: list[Image.Image] = []
        rotation_records: list[dict[str, Any]] = []
        for direction in DIRECTIONS:
            path = identity_root / "rotations" / f"{direction}.png"
            if not path.is_file():
                raise ValueError(f"{identity['id']} is missing {direction} rotation")
            try:
                with Image.open(path) as source:
                    frame = source.convert("RGBA")
            except (OSError, UnidentifiedImageError) as error:
                raise ValueError(f"cannot read {path}: {error}") from error
            rotations.append(frame)
            max_width = max(max_width, frame.width)
            max_height = max(max_height, frame.height)
            rotation_records.append({
                "direction": direction,
                "path": relative(root, path),
                "sha256": sha256(path),
                "dimensions": [frame.width, frame.height],
            })
        records.append({
            "id": identity["id"], "canonicalHome": identity["canonicalHome"],
            "sourceIdentity": source_identity, "rotations": rotation_records,
        })
        entries.append((identity, rotations))

    cell_width = max_width + PADDING * 2
    cell_height = max_height + PADDING * 2
    width = LABEL_WIDTH + len(DIRECTIONS) * cell_width + PADDING
    height = 44 + len(entries) * cell_height + PADDING
    canvas = Image.new("RGBA", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    draw.text((PADDING, PADDING), f"{world['id']} residents: native pixels; 48px grid; yellow = foot baseline", fill=MUTED)
    for column, direction in enumerate(DIRECTIONS):
        draw.text((LABEL_WIDTH + column * cell_width + PADDING, 25), direction, fill=TEXT)
    for row, (identity, frames) in enumerate(entries):
        top = 44 + row * cell_height
        draw.text((PADDING, top + PADDING), ascii_label(f"{identity['canonicalHome']} {identity['sourceIdentity']['folder']}"), fill=TEXT)
        for column, frame in enumerate(frames):
            left = LABEL_WIDTH + column * cell_width
            draw_grid(draw, left, top, cell_width, cell_height)
            frame_left = left + (cell_width - frame.width) // 2
            frame_top = top + cell_height - PADDING - frame.height
            canvas.alpha_composite(frame, (frame_left, frame_top))
            draw.line((left, top + cell_height - PADDING, left + cell_width, top + cell_height - PADDING), fill=BASELINE)
    buffer = io.BytesIO()
    canvas.save(buffer, format="PNG")
    return buffer.getvalue(), records


def build(root: Path, source_root: Path, config_path: Path) -> tuple[dict[str, bytes], dict[str, Any]]:
    expected: dict[str, bytes] = {}
    worlds: list[dict[str, Any]] = []
    for world in load_config(config_path):
        environment, environment_records = render_environment(root, world)
        population, population_records = render_population(root, source_root, world)
        expected[f"{world['id']}-environment.png"] = environment
        expected[f"{world['id']}-population.png"] = population
        worlds.append({
            "id": world["id"], "roomPrefix": world["roomPrefix"], "distributionEligibility": "review_required",
            "environmentSheet": f"{world['id']}-environment.png", "environmentSources": environment_records,
            "populationSheet": f"{world['id']}-population.png", "populationIdentities": population_records,
        })
    manifest = {
        "schemaVersion": 1,
        "purpose": "local_native_scale_review_only; not release art, profile approval, or distribution admission",
        "sharedFieldGridPixels": FIELD_GRID_PIXELS,
        "worlds": worlds,
    }
    expected["vertical_slice_contact_sheets.json"] = (json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode("utf-8")
    return expected, manifest


def write_or_check(root: Path, source_root: Path, config_path: Path, output_dir: Path, check: bool) -> None:
    expected, manifest = build(root, source_root, config_path)
    paths = {output_dir / name: payload for name, payload in expected.items()}
    if check:
        stale = [path for path, payload in paths.items() if not path.is_file() or path.read_bytes() != payload]
        if stale:
            raise ValueError(f"vertical-slice contact sheets are missing or stale: {stale[0]}")
        print(f"Vertical-slice contact sheets are current: {output_dir} ({len(manifest['worlds'])} worlds)")
        return
    output_dir.mkdir(parents=True, exist_ok=True)
    for path, payload in paths.items():
        path.write_bytes(payload)
    print(f"Wrote local native-scale vertical-slice contact sheets: {output_dir} ({len(manifest['worlds'])} worlds)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--source-root", type=Path, default=Path("assets/characters/SakPix - 8-Direction Characters - ALL AS OF 7-3-26"))
    parser.add_argument("--config", type=Path, default=Path("game/validation/review_configs/m2_vertical_slice_contact_sheets.json"))
    parser.add_argument("--output-dir", type=Path, default=Path("test-artifacts/vertical-slice-contact-sheets"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    source_root = args.source_root if args.source_root.is_absolute() else root / args.source_root
    config = args.config if args.config.is_absolute() else root / args.config
    output_dir = args.output_dir if args.output_dir.is_absolute() else root / args.output_dir
    if not source_root.is_dir():
        raise ValueError(f"population source root is unavailable: {source_root}")
    write_or_check(root, source_root.resolve(), config.resolve(), output_dir.resolve(), args.check)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Vertical-slice contact sheet error: {error}", file=sys.stderr)
        raise SystemExit(1)
