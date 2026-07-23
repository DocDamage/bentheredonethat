#!/usr/bin/env python3
"""Emit a deterministic inventory of literal raster candidates in Godot code.

This is deliberately an inventory, not a reachability proof or a claim that every
source has an approved crop profile. It gives profile work a stable denominator
and fails CI when a static asset reference changes without refreshing the review.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

RASTER_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg"}
STRING_PATTERN = re.compile(r'(["\'])(.*?)(?<!\\)\1')
CONST_PATTERN = re.compile(r'^\s*const\s+([A-Z][A-Z0-9_]*)\s*(?::[^=]+)?=\s*(["\'])(.*?)(?<!\\)\2')
CONCAT_PATTERN = re.compile(r'\b([A-Z][A-Z0-9_]*)\s*\+\s*(["\'])(.*?)(?<!\\)\2')
UNPROFILED_CLASSIFICATIONS = {
    "third_party_addon_ui",
    "legacy_compatibility_visual",
    "dynamic_template_visual",
}


def release_files(root: Path) -> list[Path]:
    game = root / "game"
    return sorted(
        path
        for suffix in ("*.gd", "*.tscn")
        for path in game.rglob(suffix)
        if "tests" not in path.parts and "validation" not in path.parts and "editor" not in {part.lower() for part in path.parts}
    )


def is_raster(value: str) -> bool:
    return Path(value).suffix.lower() in RASTER_SUFFIXES


def is_release_raster(value: str) -> bool:
    """Exclude static editor and example references stripped from release builds."""
    parts = {part.casefold() for part in Path(value.removeprefix("res://")).parts}
    if "editor" in parts or "example assets" in parts:
        return False
    return is_raster(value)


def profile_sources(root: Path) -> dict[str, list[dict[str, Any]]]:
    profiles_path = root / "game/ben_rpg/visual_assets/visual_profiles.json"
    profile_text = profiles_path.read_text(encoding="utf-8")
    raw: dict[str, Any] = json.loads(profile_text)
    lines = profile_text.splitlines()
    result: dict[str, list[dict[str, Any]]] = defaultdict(list)
    search_start = 0
    for profile in raw.get("profiles", []):
        texture = profile.get("source", {}).get("runtimeTexture", "")
        if isinstance(texture, str) and texture.startswith("game/"):
            source_line = 0
            marker = f'"runtimeTexture": "{texture}"'
            for index in range(search_start, len(lines)):
                if marker in lines[index]:
                    source_line = index + 1
                    search_start = index + 1
                    break
            result["res://" + texture.removeprefix("game/")].append({
                "file": profiles_path.relative_to(root).as_posix(),
                "line": source_line,
                "resolution": "profile_runtime_texture",
                "profileId": str(profile.get("id", "")),
            })
    return result


def unprofiled_classification(asset_path: str) -> str:
    """Make every remaining gap explicit without treating it as profile approval.

    The inventory deliberately includes bundled addon UI and compatibility
    scenes so the release denominator cannot hide them. Those sources have
    different next actions from campaign-owned content profiles: addon art must
    be tracked as a third-party dependency, compatibility scenes must migrate,
    and %s paths must resolve through data-owned profile IDs.
    """
    if asset_path.startswith("res://addons/"):
        return "third_party_addon_ui"
    if "%s" in asset_path:
        return "dynamic_template_visual"
    return "legacy_compatibility_visual"


def build(root: Path) -> dict[str, Any]:
    profiles = profile_sources(root)
    references: dict[str, list[dict[str, Any]]] = defaultdict(list)
    constants: dict[str, str] = {}
    for path in release_files(root):
        text = path.read_text(encoding="utf-8")
        relative = path.relative_to(root).as_posix()
        for line_number, line in enumerate(text.splitlines(), start=1):
            const_match = CONST_PATTERN.match(line)
            if const_match:
                value = const_match.group(3)
                if value.startswith("res://"):
                    constants[const_match.group(1)] = value
            for _, value in STRING_PATTERN.findall(line):
                if value.startswith("res://") and is_release_raster(value):
                    references[value].append({"file": relative, "line": line_number, "resolution": "literal"})
            for name, _, suffix in CONCAT_PATTERN.findall(line):
                base = constants.get(name)
                if base:
                    value = base + suffix
                    if is_release_raster(value):
                        references[value].append({"file": relative, "line": line_number, "resolution": "constant_concat"})
    # Profile-owned paths are runtime paths too. Without these references, a
    # renderer refactor from load("res://...") to registry.texture(profile_id)
    # would accidentally remove an asset from the release provenance ledger.
    for asset_path, profile_references in profiles.items():
        references[asset_path].extend(profile_references)
    entries = []
    for asset_path in sorted(references):
        refs = sorted(references[asset_path], key=lambda item: (item["file"], item["line"], item["resolution"]))
        entries.append(
            {
                "path": asset_path,
                "profileIds": sorted(reference["profileId"] for reference in profiles.get(asset_path, [])),
                "references": refs,
            }
        )
    for entry in entries:
        if not entry["profileIds"]:
            entry["unprofiledClassification"] = unprofiled_classification(entry["path"])
    profiled = sum(1 for entry in entries if entry["profileIds"])
    unprofiled_by_classification = {
        classification: sum(entry.get("unprofiledClassification") == classification for entry in entries)
        for classification in sorted(UNPROFILED_CLASSIFICATIONS)
    }
    return {
        "schemaVersion": 2,
        "scope": "static Godot .gd/.tscn raster literals and approved profile runtime textures (tests, validation, and editor-only paths excluded)",
        "stats": {
            "assets": len(entries),
            "profiledAssetSources": profiled,
            "unprofiledAssetSources": len(entries) - profiled,
            "unprofiledByClassification": unprofiled_by_classification,
        },
        "assets": entries,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/visual_assets/generated/runtime_visual_inventory.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    payload = json.dumps(build(root), ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.check:
        if not output.is_file() or output.read_text(encoding="utf-8") != payload:
            raise ValueError(f"runtime visual inventory is missing or stale: {output}")
        print(f"Runtime visual inventory is current: {output}")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8", newline="\n")
        inventory = json.loads(payload)
        print("Wrote %s with %d asset sources (%d profiled, %d unprofiled)." % (
            output, inventory["stats"]["assets"], inventory["stats"]["profiledAssetSources"], inventory["stats"]["unprofiledAssetSources"]
        ))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Runtime visual inventory error: {error}", file=sys.stderr)
        raise SystemExit(1)
