#!/usr/bin/env python3
"""Validate the generated curated art asset catalog against the asset tree.

Usage:
    python tools/validate_curated_asset_catalog.py
    python tools/validate_curated_asset_catalog.py --deep
    python tools/validate_curated_asset_catalog.py path/to/catalog.js --root path/to/game

The validator deliberately reads the JavaScript assignment without executing it.
It exits non-zero for schema, path, crop, animation, duplicate, or coverage errors.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import posixpath
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any, Iterable

try:
    from PIL import Image
except ImportError:  # pragma: no cover - handled in main
    Image = None  # type: ignore[assignment]


SUPPORTED = frozenset({".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"})
ASSET_LIBRARY_ROOT = "assets"
IGNORED_DIRS = frozenset(
    {".git", ".playwright-cli", "output", "music", "sfx", "node_modules", "__pycache__", "tools"}
)
# Assets restored beneath this root are an unreviewed local staging library, not
# part of the approved curated source library.  Keeping it explicit prevents a
# workstation sync from changing the catalog denominator, while `path()` still
# rejects any attempt to publish a curated entry from the quarantine.
QUARANTINED_SOURCE_ROOTS = frozenset({"expansion"})
ASSIGNMENT = re.compile(r"window\s*\.\s*CURATED_ART_ASSET_CATALOG\s*=\s*")
AERO_PATH = "assets/characters/quirky npcs/fullcolor/aeronaut.png"
AERO_RECT = (7, 6, 27, 59)
AERO_FLIGHT_FRAMES = ((0, 0, 46, 66), (46, 0, 46, 66), (92, 0, 46, 66))


@dataclass(frozen=True)
class Issue:
    level: str
    code: str
    message: str


class Validator:
    def __init__(self, root: Path, catalog: dict[str, Any], deep: bool = False) -> None:
        self.root = root.resolve()
        self.catalog = catalog
        self.deep = deep
        self.issues: list[Issue] = []
        self.actual: dict[str, str] = {}
        self.covered: set[str] = set()
        self.image_info: dict[str, tuple[int, int, str, int]] = {}
        self.deep_crops: dict[str, list[tuple[tuple[int, int, int, int], str, int | None]]] = defaultdict(list)
        self.ids: dict[str, str] = {}
        self.source_ids: set[str] = set()
        self.sources_by_id: dict[str, dict[str, Any]] = {}
        self.source_paths: dict[str, list[dict[str, Any]]] = defaultdict(list)
        self.source_hashes: dict[str, list[dict[str, Any]]] = defaultdict(list)
        self.source_count = 0
        self.variant_count = 0
        self.region_count = 0
        self.animation_count = 0

    def error(self, code: str, message: str) -> None:
        self.issues.append(Issue("ERROR", code, message))

    def warn(self, code: str, message: str) -> None:
        self.issues.append(Issue("WARN", code, message))

    @staticmethod
    def _ignored(parts: tuple[str, ...]) -> bool:
        if not parts:
            return False
        if parts[0].casefold() in IGNORED_DIRS or parts[0].startswith("."):
            return True
        if (
            len(parts) >= 2
            and parts[0] == ASSET_LIBRARY_ROOT
            and parts[1].casefold() in QUARANTINED_SOURCE_ROOTS
        ):
            return True
        return any(part.casefold() in IGNORED_DIRS for part in parts[:-1])

    def scan_files(self) -> None:
        asset_root = self.root / ASSET_LIBRARY_ROOT
        if not asset_root.is_dir():
            self.error("missing-asset-library", f"Expected curated asset library at {asset_root}")
            return
        for base, dirs, files in os.walk(asset_root):
            rel_base = Path(base).relative_to(self.root)
            dirs[:] = [
                d for d in dirs
                if not self._ignored(tuple((rel_base / d).parts))
            ]
            for filename in files:
                if Path(filename).suffix.casefold() not in SUPPORTED:
                    continue
                rel = (rel_base / filename).as_posix()
                parts = PurePosixPath(rel).parts
                if self._ignored(parts) or (len(parts) == 1 and filename.startswith("_")):
                    continue
                key = rel.casefold()
                if key in self.actual and self.actual[key] != rel:
                    self.error("path-case-collision", f"Two files differ only by case: {self.actual[key]!r}, {rel!r}")
                self.actual[key] = rel

    def register_id(self, value: Any, label: str, source: bool = False) -> str | None:
        if not isinstance(value, str) or not value.strip():
            self.error("invalid-id", f"{label} must have a non-empty string id")
            return None
        if value in self.ids:
            self.error("duplicate-id", f"id {value!r} is shared by {self.ids[value]} and {label}")
        else:
            self.ids[value] = label
        if source:
            self.source_ids.add(value)
        return value

    def path(self, raw: Any, label: str, cover: bool = True) -> str | None:
        if not isinstance(raw, str) or not raw:
            self.error("invalid-path", f"{label} has no valid relative path")
            return None
        if "\\" in raw or raw.startswith(("/", "./")) or re.match(r"^[A-Za-z]:", raw):
            self.error("unnormalized-path", f"{label} path must be root-relative POSIX form: {raw!r}")
            return None
        pure = PurePosixPath(raw)
        if any(p in {"", ".", ".."} for p in pure.parts) or posixpath.normpath(raw) != raw:
            self.error("unnormalized-path", f"{label} path is not normalized: {raw!r}")
            return None
        if not pure.parts or pure.parts[0] != ASSET_LIBRARY_ROOT:
            self.error("outside-asset-library", f"{label} must stay under {ASSET_LIBRARY_ROOT}/: {raw!r}")
            return None
        if pure.suffix.casefold() not in SUPPORTED:
            self.error("unsupported-path", f"{label} points to an unsupported raster type: {raw!r}")
            return None
        if self._ignored(pure.parts) or (len(pure.parts) == 1 and pure.name.startswith("_")):
            self.error("ignored-path-exposed", f"{label} exposes QA/ignored output: {raw!r}")
            return None
        key = raw.casefold()
        expected = self.actual.get(key)
        if expected is None:
            self.error("missing-path", f"{label} does not exist in the asset tree: {raw!r}")
            return None
        if expected != raw:
            self.error("path-case", f"{label} uses {raw!r}; portable spelling is {expected!r}")
        if cover:
            self.covered.add(key)
        return expected

    def info(self, rel: str, label: str) -> tuple[int, int, str, int] | None:
        key = rel.casefold()
        if key in self.image_info:
            return self.image_info[key]
        try:
            with Image.open(self.root / Path(rel)) as image:  # type: ignore[union-attr]
                result = (image.width, image.height, (image.format or "").lower(), int(getattr(image, "n_frames", 1)))
        except Exception as exc:
            self.error("unreadable-image", f"{label} cannot be read by Pillow: {exc}")
            return None
        self.image_info[key] = result
        return result

    @staticmethod
    def number(value: Any, integer: bool = False) -> float | int | None:
        if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
            return None
        if integer and int(value) != value:
            return None
        return int(value) if integer else value

    def rect(self, value: Any, label: str, required: bool = True) -> tuple[int, int, int, int] | None:
        vals: Any = None
        if isinstance(value, (list, tuple)) and len(value) == 4:
            vals = value
        elif isinstance(value, dict):
            if all(k in value for k in ("x", "y", "w", "h")):
                vals = [value["x"], value["y"], value["w"], value["h"]]
            elif all(k in value for k in ("x", "y", "width", "height")):
                vals = [value["x"], value["y"], value["width"], value["height"]]
            else:
                for key in ("crop", "bounds", "rect", "contentBounds", "alphaBounds"):
                    if key in value:
                        return self.rect(value[key], f"{label}.{key}", required)
        if vals is None or any(self.number(v, True) is None for v in vals):
            if required:
                self.error("invalid-rect", f"{label} must be [x,y,w,h] or an equivalent integer object")
            return None
        x, y, w, h = (int(v) for v in vals)
        if x < 0 or y < 0 or w <= 0 or h <= 0:
            self.error("invalid-rect", f"{label} has non-positive or negative geometry: {(x, y, w, h)}")
            return None
        return x, y, w, h

    def check_rect(
        self,
        rel: str | None,
        rect: tuple[int, int, int, int] | None,
        label: str,
        deep: bool = True,
        frame_index: int | None = None,
    ) -> None:
        if rel is None or rect is None:
            return
        image = self.info(rel, label)
        if image is None:
            return
        x, y, w, h = rect
        if x + w > image[0] or y + h > image[1]:
            self.error("crop-out-of-range", f"{label} {rect} exceeds {rel!r} dimensions {image[0]}x{image[1]}")
            return
        if self.deep and deep:
            self.deep_crops[rel.casefold()].append((rect, label, frame_index))

    def validate_grid(self, grid: Any, rel: str | None, label: str, usable: bool) -> None:
        if not isinstance(grid, dict):
            self.error("invalid-grid", f"{label} must be an object")
            return
        required = ("cellWidth", "cellHeight", "columns", "rows")
        vals = {k: self.number(grid.get(k), True) for k in required}
        if any(v is None or v <= 0 for v in vals.values()):
            self.error("invalid-grid", f"{label} needs positive integer cellWidth, cellHeight, columns, and rows")
            return
        margin = grid.get("margin", 0)
        spacing = grid.get("spacing", 0)
        mx = my = int(margin) if self.number(margin, True) is not None else 0
        sx = sy = int(spacing) if self.number(spacing, True) is not None else 0
        if isinstance(margin, dict):
            mx, my = int(margin.get("x", 0)), int(margin.get("y", 0))
        if isinstance(spacing, dict):
            sx, sy = int(spacing.get("x", 0)), int(spacing.get("y", 0))
        x = grid.get("x", mx)
        y = grid.get("y", my)
        if self.number(x, True) is None or self.number(y, True) is None or min(int(x), int(y), mx, my, sx, sy) < 0:
            self.error("invalid-grid", f"{label} has invalid origin, margin, or spacing")
            return
        cw, ch, cols, rows = (int(vals[k]) for k in required)
        extent = (int(x), int(y), cols * cw + (cols - 1) * sx, rows * ch + (rows - 1) * sy)
        self.check_rect(rel, extent, label, deep=usable)
        count = grid.get("count", cols * rows)
        if self.number(count, True) is None or not 0 < int(count) <= cols * rows:
            self.error("invalid-grid-count", f"{label}.count must be between 1 and {cols * rows}")

    def validate_animation(self, anim: Any, default_rel: str | None, label: str, usable: bool) -> None:
        if not isinstance(anim, dict):
            self.error("invalid-animation", f"{label} must be an object")
            return
        self.animation_count += 1
        frames = anim.get("frames", [])
        frame_count = anim.get("frameCount", len(frames) if isinstance(frames, list) else frames)
        if self.number(frame_count, True) is None or int(frame_count) <= 0:
            self.error("invalid-frame-count", f"{label}.frameCount must be a positive integer")
            return
        frame_count = int(frame_count)
        durations: list[float] = []
        if isinstance(frames, list):
            if len(frames) != frame_count:
                self.error("frame-count-mismatch", f"{label} declares {frame_count} frames but contains {len(frames)}")
            for index, frame in enumerate(frames):
                if not isinstance(frame, dict):
                    self.error("invalid-frame", f"{label}.frames[{index}] must be an object")
                    continue
                raw_src = frame.get("src")
                rel = default_rel if raw_src is None else self.path(raw_src, f"{label}.frames[{index}].src")
                crop = self.rect(frame, f"{label}.frames[{index}]")
                frame_index = frame.get("index") if self.number(frame.get("index"), True) is not None else None
                self.check_rect(rel, crop, f"{label}.frames[{index}]", deep=usable, frame_index=frame_index)
                if "duration" in frame:
                    duration = self.number(frame["duration"])
                    if duration is None or duration <= 0:
                        self.error("invalid-duration", f"{label}.frames[{index}].duration must be positive")
                    else:
                        durations.append(float(duration))
        elif not isinstance(frames, int):
            self.error("invalid-frames", f"{label}.frames must be a list or frame count")
        fps = anim.get("fps")
        if fps is not None and (self.number(fps) is None or float(fps) <= 0):
            self.error("invalid-fps", f"{label}.fps must be positive")
        total = anim.get("duration")
        if total is not None:
            if self.number(total) is None or float(total) <= 0:
                self.error("invalid-duration", f"{label}.duration must be positive")
            elif len(durations) == frame_count and not math.isclose(sum(durations), float(total), abs_tol=1.0):
                self.error("duration-mismatch", f"{label} frame durations sum to {sum(durations):g}ms, not {float(total):g}ms")
        if default_rel:
            info = self.info(default_rel, label)
            if info and info[3] > 1 and info[3] != frame_count:
                self.error("gif-frame-mismatch", f"{label} declares {frame_count} frames; {default_rel!r} contains {info[3]}")

    def alias_paths(self, aliases: Any, label: str) -> Iterable[str]:
        if aliases is None:
            return []
        if not isinstance(aliases, list):
            aliases = [aliases]
        result: list[str] = []
        for index, alias in enumerate(aliases):
            value = alias.get("src", alias.get("path")) if isinstance(alias, dict) else alias
            if isinstance(value, str) and PurePosixPath(value).suffix.casefold() in SUPPORTED:
                rel = self.path(value, f"{label}.aliases[{index}]")
                if rel:
                    result.append(rel)
        return result

    def validate_source(self, source: Any, index: int) -> None:
        label = f"sources[{index}]"
        if not isinstance(source, dict):
            self.error("invalid-source", f"{label} must be an object")
            return
        self.source_count += 1
        if not isinstance(source.get("name"), str) or not source["name"].strip():
            self.error("missing-display-name", f"{label}.name must be a non-empty string")
        if source.get("category") not in {"buildings", "terrain", "nature", "furniture", "decor", "characters", "effects", "interface"}:
            self.error("invalid-library-category", f"{label}.category is not a supported build category")
        sid = self.register_id(source.get("id"), label, source=True)
        if sid:
            self.sources_by_id[sid] = source
        rel = self.path(source.get("src"), f"{label}.src")
        if rel:
            self.source_paths[rel.casefold()].append(source)
        sha1 = source.get("sha1")
        if isinstance(sha1, str) and sha1:
            self.source_hashes[sha1.casefold()].append(source)
        usable = source.get("usable", True) is not False
        info = self.info(rel, label) if rel else None
        if info:
            width, height = source.get("width"), source.get("height")
            if self.number(width, True) is None or self.number(height, True) is None:
                self.error("missing-dimensions", f"{label} needs integer width and height")
            elif (int(width), int(height)) != info[:2]:
                self.error("dimension-mismatch", f"{label} says {width}x{height}; Pillow reports {info[0]}x{info[1]}")
        for key in ("bounds", "alphaBounds", "contentBounds"):
            if source.get(key) is not None:
                crop = self.rect(source[key], f"{label}.{key}")
                self.check_rect(rel, crop, f"{label}.{key}", deep=usable)
            elif key == "bounds" and usable:
                self.error("missing-bounds", f"{label}.bounds is required for a usable raster")
        self.alias_paths(source.get("aliases"), label)
        regions = source.get("regions", [])
        if not isinstance(regions, list):
            self.error("invalid-regions", f"{label}.regions must be a list")
            regions = []
        seen_regions: set[tuple[int, int, int, int]] = set()
        for ri, region in enumerate(regions):
            rlabel = f"{label}.regions[{ri}]"
            crop = self.rect(region, rlabel)
            if crop is None:
                continue
            if crop in seen_regions:
                self.error("duplicate-region", f"{rlabel} repeats crop {crop}")
            seen_regions.add(crop)
            self.region_count += 1
            self.check_rect(rel, crop, rlabel, deep=usable)
        variants = source.get("variants", [])
        if not isinstance(variants, list):
            self.error("invalid-variants", f"{label}.variants must be a list")
            variants = []
        for vi, variant in enumerate(variants):
            vlabel = f"{label}.variants[{vi}]"
            if not isinstance(variant, dict):
                self.error("invalid-variant", f"{vlabel} must be an object")
                continue
            self.variant_count += 1
            self.register_id(variant.get("id"), vlabel)
            vrel = rel if variant.get("src") is None else self.path(variant.get("src"), f"{vlabel}.src")
            crop = self.rect(variant, vlabel)
            vusable = usable and variant.get("usable", True) is not False
            self.check_rect(vrel, crop, vlabel, deep=vusable)
            if "grid" in variant:
                self.validate_grid(variant["grid"], vrel, f"{vlabel}.grid", vusable)
            if "animation" in variant:
                self.validate_animation(variant["animation"], vrel, f"{vlabel}.animation", vusable)
        if "grid" in source:
            self.validate_grid(source["grid"], rel, f"{label}.grid", usable)
        if "animation" in source:
            self.validate_animation(source["animation"], rel, f"{label}.animation", usable)

    def validate_refs_and_duplicates(self, sources: list[Any]) -> None:
        for index, source in enumerate(sources):
            if not isinstance(source, dict):
                continue
            for key in ("canonicalId", "coveredBy"):
                ref = source.get(key)
                refs = ref if isinstance(ref, list) else [ref]
                for value in refs:
                    if value is not None and isinstance(value, str) and value not in self.source_ids:
                        self.error("dangling-source-ref", f"sources[{index}].{key} refers to unknown source id {value!r}")
        for key, group in self.source_paths.items():
            if len(group) > 1:
                self.error("duplicate-source-path", f"Asset path {self.actual.get(key, key)!r} is exposed by {len(group)} source records; use aliases")
        for sha1, group in self.source_hashes.items():
            usable = [s for s in group if s.get("usable", True) is not False]
            if len(usable) > 1:
                ids = [s.get("id") for s in usable]
                linked = all(s.get("canonicalId") or s.get("coveredBy") or s.get("aliases") for s in usable[1:])
                if not linked:
                    self.error("duplicate-content", f"SHA-1 {sha1} is exposed as multiple usable sources without aliases: {ids}")

    def validate_aero(self, sources: list[Any]) -> None:
        found = False
        exact = False
        exact_flight = False
        for source in sources:
            if not isinstance(source, dict) or str(source.get("src", "")).casefold() != AERO_PATH.casefold():
                continue
            found = True
            for variant in source.get("variants", []):
                if isinstance(variant, dict) and variant.get("usable", True) is not False:
                    if self.rect(variant, "Aero variant", required=False) == AERO_RECT:
                        exact = True
                    animation = variant.get("animation")
                    if isinstance(animation, dict) and isinstance(animation.get("frames"), list):
                        frame_rects = tuple(
                            crop for frame in animation["frames"]
                            if isinstance(frame, dict)
                            and (crop := self.rect(frame, "Aero flight frame", required=False)) is not None
                        )
                        if frame_rects == AERO_FLIGHT_FRAMES:
                            exact_flight = True
        if not found:
            self.error("aero-missing", f"Required balloon NPC source {AERO_PATH!r} is absent")
        elif not exact:
            self.error("aero-crop", f"Aero needs a usable variant with exact crop {AERO_RECT}")
        if found and not exact_flight:
            self.error("aero-animation", f"Aero needs a full-canvas top-row flight animation {AERO_FLIGHT_FRAMES}")

    def check_deep_crops(self) -> None:
        for key, crops in self.deep_crops.items():
            rel = self.actual.get(key)
            if not rel:
                continue
            try:
                with Image.open(self.root / Path(rel)) as image:  # type: ignore[union-attr]
                    for crop, label, frame_index in crops:
                        image.seek(frame_index or 0)
                        tile = image.crop((crop[0], crop[1], crop[0] + crop[2], crop[1] + crop[3]))
                        if tile.convert("RGBA").getchannel("A").getbbox() is None:
                            self.error("blank-crop", f"{label} is fully transparent")
            except Exception as exc:
                self.error("deep-read", f"Could not deep-check {rel!r}: {exc}")

    def run(self) -> None:
        self.scan_files()
        if not isinstance(self.catalog, dict):
            self.error("invalid-root", "Catalog root must be an object")
            return
        sources = self.catalog.get("sources")
        if not isinstance(sources, list):
            self.error("missing-sources", "Catalog must contain a sources array")
            return
        for index, source in enumerate(sources):
            self.validate_source(source, index)
        self.validate_refs_and_duplicates(sources)
        self.validate_aero(sources)
        missing = sorted(set(self.actual) - self.covered)
        if missing:
            shown = ", ".join(repr(self.actual[k]) for k in missing[:12])
            tail = "" if len(missing) <= 12 else f" (and {len(missing) - 12} more)"
            self.error("coverage", f"{len(missing)} supported raster files are not covered by sources/aliases/frame refs: {shown}{tail}")
        if self.deep:
            self.check_deep_crops()


def load_catalog(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8-sig")
    match = ASSIGNMENT.search(text)
    if not match:
        raise ValueError("expected `window.CURATED_ART_ASSET_CATALOG = {...}`")
    payload = text[match.end():].lstrip()
    value, end = json.JSONDecoder().raw_decode(payload)
    trailing = payload[end:].strip()
    if trailing not in {"", ";"}:
        raise ValueError("unexpected content after catalog assignment")
    if not isinstance(value, dict):
        raise ValueError("catalog assignment must contain an object")
    return value


def parse_args(argv: list[str]) -> argparse.Namespace:
    default_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description="Validate curated-asset-catalog.js against its raster asset tree.")
    parser.add_argument("catalog", nargs="?", type=Path, help="catalog JS path (default: <root>/curated-asset-catalog.js)")
    parser.add_argument("--root", type=Path, default=default_root, help="asset-tree root (default: project root)")
    parser.add_argument("--deep", action="store_true", help="also decode every usable crop and reject fully transparent crops")
    parser.add_argument("--verbose", action="store_true", help="print every issue instead of the first 100")
    parser.add_argument("--json", action="store_true", dest="json_output", help="emit the summary as JSON")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    if Image is None:
        print("ERROR: Pillow is required (`python -m pip install Pillow`).", file=sys.stderr)
        return 2
    root = args.root.resolve()
    catalog_path = (args.catalog or (root / "curated-asset-catalog.js")).resolve()
    try:
        catalog = load_catalog(catalog_path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"ERROR: cannot load {catalog_path}: {exc}", file=sys.stderr)
        return 2
    validator = Validator(root, catalog, deep=args.deep)
    validator.run()
    errors = [issue for issue in validator.issues if issue.level == "ERROR"]
    warnings = [issue for issue in validator.issues if issue.level == "WARN"]
    summary = {
        "ok": not errors,
        "errors": len(errors),
        "warnings": len(warnings),
        "sources": validator.source_count,
        "variants": validator.variant_count,
        "regions": validator.region_count,
        "animations": validator.animation_count,
        "rasterFiles": len(validator.actual),
        "coveredFiles": len(validator.covered & set(validator.actual)),
        "deep": args.deep,
    }
    if args.json_output:
        print(json.dumps({**summary, "issues": [issue.__dict__ for issue in validator.issues]}, indent=2))
    else:
        limit = None if args.verbose else 100
        for issue in validator.issues[:limit]:
            print(f"{issue.level} [{issue.code}] {issue.message}")
        if limit is not None and len(validator.issues) > limit:
            print(f"... {len(validator.issues) - limit} more issues (use --verbose)")
        status = "PASS" if not errors else "FAIL"
        print(
            f"{status}: {validator.source_count} sources, {validator.variant_count} variants, "
            f"{validator.region_count} compact regions, "
            f"{validator.animation_count} animations; {summary['coveredFiles']}/{summary['rasterFiles']} rasters covered; "
            f"{len(errors)} errors, {len(warnings)} warnings."
        )
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
