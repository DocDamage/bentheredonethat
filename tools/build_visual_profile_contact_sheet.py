#!/usr/bin/env python3
"""Render approved visual-profile crops into a deterministic native-scale sheet."""

from __future__ import annotations

import argparse
import io
import json
from pathlib import Path

from PIL import Image, ImageDraw

PADDING = 12
MIN_CELL_WIDTH = 112
LABEL_PADDING = 3
LINE_HEIGHT = 12
BACKGROUND = (24, 28, 38, 255)
GRID = (74, 86, 108, 255)
TEXT = (235, 240, 250, 255)


def wrapped_label(draw: ImageDraw.ImageDraw, profile_id: str, width: int) -> list[str]:
    """Wrap stable ids at underscores so labels never spill into another crop."""
    words = profile_id.split("_")
    lines: list[str] = []
    line = ""
    for word in words:
        candidate = word if not line else line + "_" + word
        if line and draw.textbbox((0, 0), candidate)[2] > width - LABEL_PADDING * 2:
            lines.append(line)
            line = word
        else:
            line = candidate
    if line:
        lines.append(line)
    return lines


def render(root: Path) -> bytes:
    raw = json.loads((root / "game/ben_rpg/visual_assets/visual_profiles.json").read_text(encoding="utf-8"))
    profiles = sorted(raw["profiles"], key=lambda profile: profile["id"])
    crops: list[tuple[str, Image.Image]] = []
    for profile in profiles:
        source = profile["source"]
        x, y, width, height = source["region"]
        with Image.open(root / source["runtimeTexture"]) as image:
            crops.append((profile["id"], image.convert("RGBA").crop((x, y, x + width, y + height))))
    label_probe = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    items: list[dict[str, object]] = []
    for profile_id, crop in crops:
        cell_width = max(crop.width, MIN_CELL_WIDTH)
        lines = wrapped_label(label_probe, profile_id, cell_width)
        items.append({
            "id": profile_id,
            "crop": crop,
            "width": cell_width,
            "label_height": len(lines) * LINE_HEIGHT + LABEL_PADDING * 2,
            "lines": lines,
        })
    rows: list[list[dict[str, object]]] = []
    row: list[dict[str, object]] = []
    row_width = PADDING
    max_width = 1200
    for item in items:
        item_width = int(item["width"]) + PADDING
        if row and row_width + item_width > max_width:
            rows.append(row)
            row = []
            row_width = PADDING
        row.append(item)
        row_width += item_width
    if row:
        rows.append(row)
    width = max(sum(int(item["width"]) + PADDING for item in row) + PADDING for row in rows)
    height = sum(max((item["crop"].height + int(item["label_height"]) for item in row)) + PADDING for row in rows) + PADDING
    sheet = Image.new("RGBA", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(sheet)
    cursor_y = PADDING
    for row in rows:
        row_height = max(item["crop"].height + int(item["label_height"]) for item in row)
        cursor_x = PADDING
        for item in row:
            crop = item["crop"]
            cell_width = int(item["width"])
            label_height = int(item["label_height"])
            crop_x = cursor_x + int((cell_width - crop.width) / 2)
            draw.rectangle((crop_x - 1, cursor_y + label_height - 1, crop_x + crop.width, cursor_y + label_height + crop.height), outline=GRID)
            for line_index, line in enumerate(item["lines"]):
                draw.text((cursor_x + LABEL_PADDING, cursor_y + LABEL_PADDING + line_index * LINE_HEIGHT), line, fill=TEXT)
            sheet.alpha_composite(crop, (crop_x, cursor_y + label_height))
            cursor_x += cell_width + PADDING
        cursor_y += row_height + PADDING
    buffer = io.BytesIO()
    sheet.save(buffer, format="PNG")
    return buffer.getvalue()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/visual_assets/generated/visual_profile_contact_sheet.png"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    payload = render(root)
    if args.check:
        if not output.is_file() or output.read_bytes() != payload:
            raise ValueError(f"visual profile contact sheet is missing: {output}")
        print(f"Visual profile contact sheet is current: {output}")
        return 0
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(payload)
    print(f"Wrote native-scale visual profile contact sheet: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Visual profile contact sheet error: {error}")
        raise SystemExit(1)
