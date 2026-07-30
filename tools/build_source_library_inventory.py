#!/usr/bin/env python3
"""Inventory ignored source libraries without allowing them into release data.

The output is a curator-workstation artifact under ``game/validation``.  It
records every file's checksum and raster dimensions, groups the result by
top-level pack, and exposes exact duplicate families plus files that need a
manual engine-demo or licensing decision.  It deliberately does not admit art
to runtime profiles.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import Any

from PIL import Image, UnidentifiedImageError


RASTER_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".svg"}
LICENSE_NAMES = {"license", "license.txt", "licence", "licence.txt", "copying", "notice", "notice.txt", "credits", "credits.md", "attribution", "attribution.txt", "readme", "readme.md"}
ENGINE_SUFFIXES = {".exe", ".dll", ".pck", ".godot", ".rpgsave", ".rvdata", ".rvdata2", ".rmmzsave", ".js", ".html", ".ttf", ".otf", ".woff", ".woff2"}
ENGINE_DIR_MARKERS = {"demo", "demos", "example", "examples", "sample", "samples", ".godot", "node_modules"}
PLAN_DISPOSITION_HEADING = "#### Complete `assets/Tilesets` disposition register"
PLAN_DISPOSITION_END_HEADING = "#### Required showcase-sheet bindings"
PLAN_DISPOSITION_PATTERN = re.compile(r"^\| `([^`]+)` \|[^|]*\| ([^|]+) \| (.+) \|$")
PLAN_DISPOSITIONS = {
    "Core-P": "core_primary",
    "Core-S": "core_secondary",
    "Annex": "optional_address",
    "Reserve": "reserve",
    "Support": "shared_support",
    "Duplicate": "duplicate_quarantine",
}


def locked_tileset_dispositions(root: Path) -> dict[str, dict[str, str]]:
    """Read the plan's complete Tilesets register as a checked curation input.

    The source library remains ignored, so the plan is the tracked authority for
    the intended use of each top-level pack.  This deliberately records a plan
    disposition and destination, not a license grant or runtime admission.
    """
    plan_path = root / "FFVI_ALIGNMENT_COMPLETION_PLAN.md"
    if not plan_path.is_file():
        raise ValueError(f"locked Tilesets disposition register is missing: {plan_path}")
    plan = plan_path.read_text(encoding="utf-8")
    try:
        table = plan.split(PLAN_DISPOSITION_HEADING, 1)[1].split(PLAN_DISPOSITION_END_HEADING, 1)[0]
    except IndexError as error:
        raise ValueError("locked Tilesets disposition register is missing or incomplete") from error
    dispositions: dict[str, dict[str, str]] = {}
    for line in table.splitlines():
        match = PLAN_DISPOSITION_PATTERN.match(line)
        if not match:
            continue
        pack, source_disposition, destination = match.groups()
        disposition = PLAN_DISPOSITIONS.get(source_disposition)
        if disposition is None:
            raise ValueError(f"unknown plan disposition for Tilesets/{pack}: {source_disposition}")
        if pack in dispositions:
            raise ValueError(f"duplicate plan disposition for Tilesets/{pack}")
        dispositions[pack] = {
            "disposition": disposition,
            "planDisposition": source_disposition,
            "plannedDestination": destination,
        }
    if not dispositions:
        raise ValueError("locked Tilesets disposition register has no pack rows")
    return dispositions


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def source_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*") if path.is_file())


def image_dimensions(path: Path) -> list[int] | None:
    if path.suffix.casefold() not in RASTER_SUFFIXES or path.suffix.casefold() == ".svg":
        return None
    try:
        with Image.open(path) as image:
            return [image.width, image.height]
    except (UnidentifiedImageError, OSError):
        return None


def pack_name(library_root: Path, path: Path) -> str | None:
    relative = path.relative_to(library_root)
    return relative.parts[0] if len(relative.parts) > 1 else None


def is_engine_demo(library_root: Path, path: Path) -> bool:
    relative = path.relative_to(library_root)
    return path.suffix.casefold() in ENGINE_SUFFIXES or any(part.casefold() in ENGINE_DIR_MARKERS for part in relative.parts[:-1])


def file_record(root: Path, path: Path) -> dict[str, Any]:
    relative = path.relative_to(root).as_posix()
    return {
        "path": relative,
        "extension": path.suffix.casefold() or "[no extension]",
        "bytes": path.stat().st_size,
        "sha256": sha256(path),
        "dimensions": image_dimensions(path),
        "engineDemoCandidate": is_engine_demo(root, path),
        "licenseCandidate": path.name.casefold() in LICENSE_NAMES,
    }


def inventory_root(
    label: str, root: Path, planned_dispositions: dict[str, dict[str, str]] | None = None
) -> tuple[dict[str, Any], dict[str, list[str]]]:
    if not root.is_dir():
        raise ValueError(f"source library root is unavailable: {root}")
    by_pack: dict[str, list[dict[str, Any]]] = defaultdict(list)
    root_files: list[dict[str, Any]] = []
    duplicates: dict[str, list[str]] = defaultdict(list)
    paths = source_files(root)
    # Checksumming and opening tens of thousands of ignored rasters is entirely
    # workstation-local. A bounded pool keeps this evidence pass practical
    # without changing its deterministic, sorted output.
    with ThreadPoolExecutor(max_workers=8) as executor:
        records = executor.map(lambda candidate: file_record(root, candidate), paths)
        for record in records:
            relative = record["path"]
            checksum = record["sha256"]
            path = root / relative
            pack = pack_name(root, path)
            if pack is None:
                root_files.append(record)
            else:
                by_pack[pack].append(record)
            duplicates[checksum].append(f"{label}/{relative}")
    packs: list[dict[str, Any]] = []
    for name in sorted(by_pack, key=str.casefold):
        files = sorted(by_pack[name], key=lambda item: item["path"].casefold())
        dimensions = Counter(f"{item['dimensions'][0]}x{item['dimensions'][1]}" for item in files if item["dimensions"])
        extensions = Counter(item["extension"] for item in files)
        digest = hashlib.sha256("\n".join(f"{item['path']}\0{item['sha256']}" for item in files).encode("utf-8")).hexdigest()
        plan_record = (planned_dispositions or {}).get(name)
        packs.append({
            "id": f"{label}:{name}",
            "pack": name,
            "disposition": plan_record["disposition"] if plan_record else "unclassified_pending_review",
            "planDisposition": plan_record["planDisposition"] if plan_record else None,
            "plannedDestination": plan_record["plannedDestination"] if plan_record else None,
            "distributionEligibility": "review_required",
            "contentChecksum": digest,
            "fileCount": len(files),
            "extensionCounts": dict(sorted(extensions.items())),
            "rasterDimensionCounts": dict(sorted(dimensions.items())),
            "licenseCandidates": [item["path"] for item in files if item["licenseCandidate"]],
            "engineDemoExclusions": [item["path"] for item in files if item["engineDemoCandidate"]],
            "files": files,
        })
    return {
        "label": label,
        "packCount": len(packs),
        "rootFiles": sorted(root_files, key=lambda item: item["path"].casefold()),
        "rootLicenseCandidates": [item["path"] for item in root_files if item["licenseCandidate"]],
        "packs": packs,
    }, duplicates


def build(root: Path, tilesets_root: Path, expansion_root: Path) -> dict[str, Any]:
    planned_tilesets = locked_tileset_dispositions(root)
    actual_tilesets = {path.name for path in tilesets_root.iterdir() if path.is_dir()}
    missing = sorted(actual_tilesets - set(planned_tilesets), key=str.casefold)
    unknown = sorted(set(planned_tilesets) - actual_tilesets, key=str.casefold)
    if missing or unknown:
        details = []
        if missing:
            details.append("missing plan rows: " + ", ".join(missing))
        if unknown:
            details.append("unknown plan rows: " + ", ".join(unknown))
        raise ValueError("locked Tilesets disposition register does not match source library; " + "; ".join(details))
    tilesets, tile_duplicates = inventory_root("Tilesets", tilesets_root, planned_tilesets)
    expansion, expansion_duplicates = inventory_root("EXPANSION", expansion_root)
    duplicates: dict[str, list[str]] = defaultdict(list)
    for family in (tile_duplicates, expansion_duplicates):
        for checksum, paths in family.items():
            duplicates[checksum].extend(paths)
    duplicate_families = [
        {"sha256": checksum, "paths": sorted(paths, key=str.casefold)}
        for checksum, paths in sorted(duplicates.items()) if len(paths) > 1
    ]
    disposition_counts = Counter(pack["disposition"] for pack in tilesets["packs"])
    return {
        "schemaVersion": 2,
        "scope": "ignored curator source libraries; Tilesets dispositions are locked planning inputs, not release runtime data or license grants",
        "nearDuplicateStatus": "not_computed",
        "libraries": [tilesets, expansion],
        "exactDuplicateFamilies": duplicate_families,
        "summary": {
            "packs": tilesets["packCount"] + expansion["packCount"],
            "files": sum(pack["fileCount"] for library in (tilesets, expansion) for pack in library["packs"]),
            "exactDuplicateFamilies": len(duplicate_families),
            "tilesetsDispositionCounts": dict(sorted(disposition_counts.items())),
            "packsAwaitingDistributionReview": tilesets["packCount"] + expansion["packCount"],
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--tilesets-root", type=Path, default=Path("assets/Tilesets"))
    parser.add_argument("--expansion-root", type=Path, default=Path("assets/EXPANSION"))
    parser.add_argument("--output", type=Path, default=Path("game/validation/generated/source_library_inventory.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    tilesets_root = args.tilesets_root if args.tilesets_root.is_absolute() else root / args.tilesets_root
    expansion_root = args.expansion_root if args.expansion_root.is_absolute() else root / args.expansion_root
    output = args.output if args.output.is_absolute() else root / args.output
    payload = json.dumps(build(root, tilesets_root, expansion_root), ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.check:
        if not output.is_file() or output.read_text(encoding="utf-8") != payload:
            raise ValueError(f"source library inventory is missing or stale: {output}")
        print(f"Source library inventory is current: {output}")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8", newline="\n")
        inventory = json.loads(payload)
        print("Wrote %s with %d packs, %d files, and %d exact duplicate families." % (
            output, inventory["summary"]["packs"], inventory["summary"]["files"], inventory["summary"]["exactDuplicateFamilies"]
        ))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Source library inventory error: {error}", file=sys.stderr)
        raise SystemExit(1)
