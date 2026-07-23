#!/usr/bin/env python3
"""Build local, native-scale SakPix eight-direction review sheets.

The supplied SakPix library is intentionally ignored and remains outside the
runtime tree.  These sheets are therefore local review evidence, not derived
runtime art and not an admission decision.  Every rotation-complete identity
is rendered at its original pixel dimensions on a shared 48-pixel field grid;
incomplete identities remain visibly quarantined in the output manifest.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import re
import sys
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, UnidentifiedImageError


DIRECTIONS = (
    "north", "north-east", "east", "south-east",
    "south", "south-west", "west", "north-west",
)
FIELD_GRID_PIXELS = 48
PADDING = 8
LABEL_WIDTH = 248
HEADER_HEIGHT = 42
BACKGROUND = (20, 24, 34, 255)
GRID = (62, 77, 98, 255)
BASELINE = (228, 186, 76, 255)
TEXT = (238, 241, 248, 255)
MUTED_TEXT = (174, 185, 204, 255)


def ascii_label(value: str) -> str:
    """Keep review labels readable with Pillow's portable default font."""
    return value.encode("ascii", "replace").decode("ascii")


def output_stem(index: int, collection: str) -> str:
    safe = re.sub(r"[^a-z0-9]+", "-", collection.lower()).strip("-")[:42] or "collection"
    digest = hashlib.sha256(collection.encode("utf-8")).hexdigest()[:10]
    return f"{index:02d}-{safe}-{digest}"


def rotations_for(identity: Path) -> dict[str, Path]:
    rotation_dir = identity / "rotations"
    return {direction: rotation_dir / f"{direction}.png" for direction in DIRECTIONS if (rotation_dir / f"{direction}.png").is_file()}


def draw_grid(draw: ImageDraw.ImageDraw, left: int, top: int, width: int, height: int) -> None:
    for x in range(left, left + width + 1, FIELD_GRID_PIXELS):
        draw.line((x, top, x, top + height), fill=GRID)
    for y in range(top, top + height + 1, FIELD_GRID_PIXELS):
        draw.line((left, y, left + width, y), fill=GRID)


def render_collection(collection: str, identities: list[Path]) -> tuple[bytes, dict[str, Any]]:
    """Render one collection and return PNG bytes plus its review record."""
    complete: list[tuple[Path, list[Image.Image]]] = []
    quarantined: list[dict[str, Any]] = []
    max_width = max_height = 1
    for identity in identities:
        rotations = rotations_for(identity)
        missing = [direction for direction in DIRECTIONS if direction not in rotations]
        if missing:
            quarantined.append({"folder": identity.name, "missingRotations": missing})
            continue
        frames: list[Image.Image] = []
        try:
            for direction in DIRECTIONS:
                with Image.open(rotations[direction]) as source:
                    frame = source.convert("RGBA")
                    frames.append(frame)
                    max_width = max(max_width, frame.width)
                    max_height = max(max_height, frame.height)
        except (OSError, UnidentifiedImageError) as error:
            raise ValueError(f"cannot read {collection}/{identity.name} rotations: {error}") from error
        complete.append((identity, frames))

    cell_width = max_width + PADDING * 2
    cell_height = max_height + PADDING * 2
    width = LABEL_WIDTH + len(DIRECTIONS) * cell_width + PADDING
    height = HEADER_HEIGHT + max(1, len(complete)) * cell_height + PADDING
    image = Image.new("RGBA", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(image)
    draw.text((PADDING, PADDING), ascii_label(collection), fill=TEXT)
    draw.text((PADDING, PADDING + 14), "native pixels; 48px field-grid; yellow = shared foot baseline", fill=MUTED_TEXT)
    for index, direction in enumerate(DIRECTIONS):
        draw.text((LABEL_WIDTH + index * cell_width + PADDING, PADDING + 26), direction, fill=TEXT)

    for row, (identity, frames) in enumerate(complete):
        row_top = HEADER_HEIGHT + row * cell_height
        draw.text((PADDING, row_top + PADDING), ascii_label(identity.name), fill=TEXT)
        for column, frame in enumerate(frames):
            cell_left = LABEL_WIDTH + column * cell_width
            draw_grid(draw, cell_left, row_top, cell_width, cell_height)
            frame_left = cell_left + (cell_width - frame.width) // 2
            frame_top = row_top + cell_height - PADDING - frame.height
            image.alpha_composite(frame, (frame_left, frame_top))
            draw.line((cell_left, row_top + cell_height - PADDING, cell_left + cell_width, row_top + cell_height - PADDING), fill=BASELINE)

    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue(), {
        "collection": collection,
        "completeIdentityCount": len(complete),
        "quarantinedIdentityCount": len(quarantined),
        "quarantined": quarantined,
        "nativeFrameMaximum": [max_width, max_height],
    }


def build(source_root: Path) -> dict[str, tuple[bytes, dict[str, Any]]]:
    if not source_root.is_dir():
        raise ValueError(f"population source root is unavailable: {source_root}")
    result: dict[str, tuple[bytes, dict[str, Any]]] = {}
    collections = sorted((path for path in source_root.iterdir() if path.is_dir()), key=lambda path: path.name)
    if len(collections) != 25:
        raise ValueError(f"population source root must contain 25 collections, found {len(collections)}")
    for collection in collections:
        identities = sorted((path for path in collection.iterdir() if path.is_dir()), key=lambda path: path.name)
        result[collection.name] = render_collection(collection.name, identities)
    return result


def manifest_for(rendered: dict[str, tuple[bytes, dict[str, Any]]]) -> bytes:
    collections: list[dict[str, Any]] = []
    for index, (collection, (payload, record)) in enumerate(rendered.items(), start=1):
        item = dict(record)
        item["sheet"] = f"{output_stem(index, collection)}.png"
        item["sha256"] = hashlib.sha256(payload).hexdigest()
        collections.append(item)
    manifest = {
        "schemaVersion": 1,
        "purpose": "local_review_only",
        "sharedFieldGridPixels": FIELD_GRID_PIXELS,
        "directions": list(DIRECTIONS),
        "collections": collections,
    }
    return (json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode("utf-8")


def write_or_check(source_root: Path, output_dir: Path, check: bool) -> None:
    rendered = build(source_root)
    manifest = manifest_for(rendered)
    expected: dict[Path, bytes] = {output_dir / "population_contact_sheets.json": manifest}
    for index, (collection, (payload, _record)) in enumerate(rendered.items(), start=1):
        expected[output_dir / f"{output_stem(index, collection)}.png"] = payload
    if check:
        stale = [path for path, payload in expected.items() if not path.is_file() or path.read_bytes() != payload]
        if stale:
            raise ValueError(f"population contact sheets are missing or stale: {stale[0]}")
        print(f"Population contact sheets are current: {output_dir} ({len(rendered)} collections)")
        return
    output_dir.mkdir(parents=True, exist_ok=True)
    for path, payload in expected.items():
        path.write_bytes(payload)
    print(f"Wrote local native-scale population contact sheets: {output_dir} ({len(rendered)} collections)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, default=Path("test-artifacts/population-contact-sheets"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    source_root = args.source_root if args.source_root.is_absolute() else root / args.source_root
    output_dir = args.output_dir if args.output_dir.is_absolute() else root / args.output_dir
    write_or_check(source_root.resolve(), output_dir.resolve(), args.check)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Population contact sheet error: {error}", file=sys.stderr)
        raise SystemExit(1)
