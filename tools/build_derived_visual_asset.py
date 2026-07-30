#!/usr/bin/env python3
"""Create a deterministic nearest-neighbour derived visual crop for Godot."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def pair(value: str) -> tuple[int, int]:
    values = tuple(int(part) for part in value.split(","))
    if len(values) != 2 or min(values) <= 0:
        raise argparse.ArgumentTypeError("expected positive width,height")
    return values


def rect(value: str) -> tuple[int, int, int, int]:
    values = tuple(int(part) for part in value.split(","))
    if len(values) != 4 or values[2] <= 0 or values[3] <= 0:
        raise argparse.ArgumentTypeError("expected x,y,width,height")
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--crop", type=rect, required=True)
    parser.add_argument("--size", type=pair, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with Image.open(args.source) as source:
        x, y, width, height = args.crop
        if x < 0 or y < 0 or x + width > source.width or y + height > source.height:
            parser.error("crop is outside the source image")
        crop = source.convert("RGBA").crop((x, y, x + width, y + height))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    crop.resize(args.size, Image.Resampling.NEAREST).save(args.output)
    print(f"Wrote derived visual asset: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
