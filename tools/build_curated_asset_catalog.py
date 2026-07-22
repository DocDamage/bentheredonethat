#!/usr/bin/env python3
"""Build a deterministic, browser-loadable catalog of useful raster crops.

The pipeline stores only metadata: variants point at crops in the original source
files, so running it never produces thousands of duplicate cropped PNGs.
"""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from pathlib import Path, PurePosixPath, PureWindowsPath
from typing import Any, Iterable

try:
    from PIL import Image, ImageFilter, UnidentifiedImageError
except ImportError as exc:  # pragma: no cover - exercised by CLI users
    raise SystemExit("Pillow is required. Install it with: python -m pip install Pillow") from exc


PIPELINE_VERSION = "1.2.0"
RASTER_EXTENSIONS = {".png", ".gif", ".jpg", ".jpeg", ".webp", ".bmp"}
SOURCE_EXTENSIONS = {".psd", ".ase", ".aseprite"}
ARCHIVE_EXTENSIONS = {".zip", ".rar", ".7z"}
HARD_IGNORED_DIRS = {
    ".git", ".playwright-cli", "node_modules", "__pycache__", "output", "Music", "SFX"
}
PREVIEW_DIRS = {"promo", "promos", "preview", "previews", "screenshots", "samples", "thumbnails"}
PREVIEW_STEMS = {
    "preview", "sample", "banner", "cover", "thumbnail", "screenshot", "animation name",
    "store banner", "contact sheet", "showcase"
}
SHEET_WORDS = {"sheet", "spritesheet", "sprite sheet", "atlas", "strip", "frames"}
TILE_WORDS = {"tile", "tiles", "tileset", "tilemap", "autotile"}
ANIMATION_WORDS = {
    "animation", "animated", "idle", "walk", "walking", "run", "running", "attack", "hurt",
    "death", "jump", "fall", "fly", "move", "cast", "crouch", "crouching", "standing", "atk",
    "interact", "land", "grow"
}
AUTOTILE_WORDS = {"autotile", "tilea1", "tilea2", "tilea3", "tilea4", "tilea5"}
DIMENSION_RE = re.compile(
    r"(?<!\d)(?P<w>\d{1,4})\s*[xX×]\s*(?P<h>\d{1,4})"
    r"(?:[_\s-]*(?P<count>\d{1,4})\s*(?:frames?|fr))?",
    re.IGNORECASE,
)
SEQUENCE_RE = re.compile(r"^(?P<prefix>.*?)(?:[_\s-]?frame)?[_\s-](?P<index>\d{1,4})$", re.IGNORECASE)
POST_APOC_SHEET_RE = re.compile(r"(?:-|_)sheet(?P<count>\d+)$", re.IGNORECASE)


def posix_relative(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def normalized_key(value: str) -> str:
    return value.replace("\\", "/").casefold()


LEGACY_ASSET_PREFIXES = (
    ("assets/Main Character/", "assets/characters/Main Character/"),
    ("assets/NPCs/", "assets/characters/NPCs/"),
    ("assets/Topdown Monsters Part 1/", "assets/characters/Topdown Monsters Part 1/"),
    ("assets/Baby Dragon/", "assets/characters/Baby Dragon/"),
    ("assets/Bots and Bolts 2D robot/", "assets/characters/Bots and Bolts 2D robot/"),
    ("assets/quirky npcs/", "assets/characters/quirky npcs/"),
    ("assets/More Tilesets/", "assets/Tilesets/"),
    ("assets/Ranch Stuff/", "assets/Tilesets/Ranch Stuff/"),
)


def migrate_asset_path(value: str) -> str:
    migrated = value.replace("\\", "/")
    for old_prefix, new_prefix in LEGACY_ASSET_PREFIXES:
        migrated = migrated.replace(old_prefix, new_prefix)
    return migrated


def migrate_document_paths(value: Any) -> Any:
    """Apply the reorganized asset roots to legacy override/alias documents in memory."""
    if isinstance(value, str):
        return migrate_asset_path(value)
    if isinstance(value, list):
        return [migrate_document_paths(item) for item in value]
    if isinstance(value, dict):
        return {migrate_asset_path(str(key)): migrate_document_paths(item) for key, item in value.items()}
    return value


def stable_id(prefix: str, *parts: object) -> str:
    raw = "\0".join(str(part) for part in parts).encode("utf-8", "surrogatepass")
    return f"{prefix}-{hashlib.sha1(raw).hexdigest()[:14]}"


KNOWN_ACRONYMS = {
    "2d": "2D", "3d": "3D", "ai": "AI", "fx": "FX", "gif": "GIF", "gui": "GUI",
    "hud": "HUD", "iso": "Isometric", "mv": "MV", "mz": "MZ", "npc": "NPC",
    "png": "PNG", "rmmv": "RPG Maker MV", "rmmz": "RPG Maker MZ", "rpg": "RPG",
    "td": "Top Down", "ui": "UI",
}
GENERIC_LIBRARY_DIRS = {
    "animation", "animations", "asset", "assets", "character", "characters", "export",
    "exports", "full color", "gif", "images", "object", "objects", "objects separately",
    "png", "rmmv", "rmmz", "sprites", "tiles", "top down",
}
LIBRARY_CATEGORIES = {"buildings", "terrain", "nature", "furniture", "decor", "characters", "effects", "interface"}


def clean_name(stem: str) -> str:
    """Turn art-production filenames into compact labels without changing their identity."""
    value = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", str(stem))
    value = re.sub(r"(?<=[A-Z])(?=[A-Z][a-z])", " ", value)
    value = re.sub(r"[_-]+", " ", value)
    value = re.sub(r"\b([23])\s+D\b", r"\1d", value, flags=re.IGNORECASE)
    value = re.sub(r"^[!$#@]+", "", value)
    value = re.sub(r"(?:\s+|^)(?:copy|export|final)(?:\s*\d+)?$", "", value, flags=re.IGNORECASE)
    value = re.sub(r"\s+\d{2,4}\s*[xX×]\s*\d{2,4}$", "", value)
    value = re.sub(r"\s+", " ", value).strip(" .-_")
    if not value:
        return "Asset"
    words_out: list[str] = []
    for token in value.split():
        replacement = KNOWN_ACRONYMS.get(token.casefold())
        if replacement:
            words_out.extend(replacement.split())
        elif token.isupper() and len(token) > 3:
            words_out.append(token.title())
        elif token.islower():
            words_out.append(token.capitalize())
        else:
            words_out.append(token)
    return " ".join(words_out)


def display_asset_name(relative: str) -> str:
    """Create a useful catalog name, adding path context when the filename is generic."""
    path = PurePosixPath(relative)
    raw_stem = path.stem
    name = clean_name(raw_stem)
    parents = [clean_name(part) for part in path.parts[:-1]]
    meaningful = [part for part in parents if part.casefold() not in GENERIC_LIBRARY_DIRS and not part.startswith("_")]

    frame_match = re.fullmatch(r"(?:frame\s*)?(\d{1,4})", name, re.IGNORECASE)
    if raw_stem.casefold().startswith("frame") and frame_match:
        direction = parents[-1] if parents else ""
        action = parents[-2] if len(parents) > 1 else (meaningful[-1] if meaningful else "Animation")
        return " · ".join(part for part in (action, direction, f"Frame {int(frame_match.group(1)) + 1}") if part)

    if re.fullmatch(r"\d{1,4}", raw_stem):
        collection = meaningful[-1] if meaningful else "Asset Collection"
        collection = re.sub(
            r"\s+(?:Pixel Art )?(?:Asset )?(?:Tileset|Pack|Mega Pack)$", "", collection,
            flags=re.IGNORECASE,
        ).strip() or collection
        return f"{collection} · Sheet {int(raw_stem)}"

    set_match = re.fullmatch(r"Set\s+(\d+)\s*\((\d+)\)", name, re.IGNORECASE)
    if set_match:
        collection = meaningful[-1] if meaningful else "Asset Set"
        return f"{collection} · Set {int(set_match.group(1))}.{int(set_match.group(2))}"

    name = re.sub(r"^Dfgui\s+Icon\s+(.+)$", r"\1 Icon", name, flags=re.IGNORECASE)
    name = re.sub(r"\bDetilazation\b", "Detailing", name, flags=re.IGNORECASE)
    name = re.sub(r"\bCrystael\b", "Crystal", name, flags=re.IGNORECASE)
    return name


def pack_name(relative: str) -> str:
    parts = PurePosixPath(relative).parts
    # Physical files live under one assets root, while the editor exposes the
    # original pack/folder hierarchy rather than a redundant "Assets" group.
    if parts and parts[0].casefold() == "assets":
        parts = parts[1:]
    # Recruit artwork is intentionally one folder deeper than ordinary packs:
    # assets / characters / Recruitable Characters / <character pack> / ...
    # Keep that authored character-pack name visible in the catalog filter.
    if len(parts) >= 4 and parts[0].casefold() == "characters" and parts[1].casefold() == "recruitable characters":
        return " / ".join((clean_name(parts[1]), clean_name(parts[2])))
    if len(parts) == 1:
        return "Root assets"
    return " / ".join(clean_name(part) for part in parts[: min(2, len(parts) - 1)])


def library_category(relative: str, kind: str) -> str:
    text = clean_name(relative).casefold()
    checks = (
        ("characters", ("character", "npc", "enemy", "monster", "zombie", "skeleton", "villager", "robot", "dragon", "ben franklin")),
        ("buildings", ("building", "house", "cottage", "shop", "castle", "roof", "door", "window", "wall", "arch", "tower", "village")),
        ("furniture", ("furniture", "chair", "table", "desk", "bed", "sofa", "couch", "bench", "shelf", "cabinet", "counter", "stool")),
        ("nature", ("nature", "tree", "plant", "flower", "bush", "grass", "rock", "stone", "crystal", "mushroom", "forest", "water", "river")),
        ("terrain", ("terrain", "ground", "floor", "road", "path", "tile", "tileset", "autotile", "map")),
        ("effects", ("effect", " fx", "magic", "lightning", "fire", "smoke", "spark", "explosion", "particle")),
        ("interface", (" gui", " ui", "icon", "button", "cursor", "hud", "banner", "panel")),
        ("decor", ("decor", "prop", "object", "sign", "lamp", "light", "food", "tool", "weapon", "vehicle")),
    )
    for category, keywords in checks:
        if any(keyword in text for keyword in keywords):
            return category
    if kind in {"tileset", "autotile", "tile-sheet"}:
        return "terrain"
    if kind in {"animation", "spritesheet", "character-sheet"}:
        return "characters"
    return "decor"


def words(value: str) -> set[str]:
    normalized = re.sub(r"[^a-z0-9]+", " ", value.casefold()).strip()
    tokens = set(normalized.split())
    tokens.add(normalized)
    return tokens


def is_preview_path(relative: str) -> bool:
    path = PurePosixPath(relative)
    if path.parent == PurePosixPath(".") and path.name.startswith("_"):
        return True
    if any(part.casefold() in PREVIEW_DIRS for part in path.parts[:-1]):
        return True
    stem = clean_name(path.stem).casefold()
    if stem in PREVIEW_STEMS:
        return True
    if stem.startswith((
        "preview ", "sample ", "screenshot ", "thumbnail ", "contact sheet ",
        "little guide", "free demo",
    )):
        return True
    stem_tokens = set(stem.split())
    return (
        stem.endswith((" contact", " boxes"))
        or bool(stem_tokens & {"preview", "showcase"})
        or any(token.startswith("example") for token in stem_tokens)
    )


def walk_files(root: Path, extensions: set[str]) -> list[Path]:
    found: list[Path] = []
    for current, dirs, files in os.walk(root):
        dirs[:] = sorted(
            (name for name in dirs if name not in HARD_IGNORED_DIRS), key=str.casefold
        )
        current_path = Path(current)
        for name in sorted(files, key=str.casefold):
            path = current_path / name
            if path.suffix.casefold() in extensions:
                found.append(path)
    return sorted(found, key=lambda path: normalized_key(posix_relative(path, root)))


def sha1_file(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_overrides(path: Path | None) -> dict[str, Any]:
    if not path:
        return {"version": 1, "profiles": [], "sources": {}}
    try:
        data = migrate_document_paths(json.loads(path.read_text(encoding="utf-8")))
    except FileNotFoundError:
        return {"version": 1, "profiles": [], "sources": {}}
    if not isinstance(data, dict):
        raise ValueError("override file must contain a JSON object")
    data.setdefault("profiles", [])
    data.setdefault("sources", {})
    return data


def load_source_aliases(path: Path | None, overrides: dict[str, Any]) -> dict[str, list[str]]:
    mappings: dict[str, Any] = dict(overrides.get("editableSources", {}))
    if path and path.is_file():
        try:
            document = migrate_document_paths(json.loads(path.read_text(encoding="utf-8")))
            if isinstance(document, dict):
                external = document.get("sources", document)
                if isinstance(external, dict):
                    mappings.update(external)
        except (OSError, json.JSONDecodeError):
            pass
    normalized: dict[str, list[str]] = {}
    for source, value in mappings.items():
        if isinstance(value, dict):
            value = value.get("representedBy", [])
        if isinstance(value, str):
            value = [value]
        if isinstance(value, list):
            normalized[normalized_key(str(source))] = sorted(
                {str(item).replace("\\", "/") for item in value if isinstance(item, str)}, key=str.casefold
            )
    return normalized


def override_for(relative: str, overrides: dict[str, Any]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for profile in overrides.get("profiles", []):
        if isinstance(profile, dict) and fnmatch.fnmatchcase(normalized_key(relative), normalized_key(str(profile.get("glob", "")))):
            result.update({key: value for key, value in profile.items() if key != "glob"})
    explicit = overrides.get("sources", {}).get(relative)
    if explicit is None:
        explicit = overrides.get("sources", {}).get(normalized_key(relative))
    if isinstance(explicit, dict):
        result.update(explicit)
    return result


def safe_archive_member(name: str) -> bool:
    normalized = name.replace("\\", "/")
    if not normalized or "\0" in normalized or normalized.startswith(("/", "//")):
        return False
    if re.match(r"^[A-Za-z]:", normalized):
        return False
    parts = PurePosixPath(normalized).parts
    return all(part not in {"", ".", ".."} and ":" not in part for part in parts)


def list_archive(path: Path, seven_zip: str | None) -> tuple[list[dict[str, str]], str | None]:
    executable = seven_zip or shutil.which("7z")
    if not executable:
        return [], "7z_not_found"
    completed = subprocess.run(
        [executable, "l", "-slt", "-ba", str(path)], capture_output=True, text=True,
        encoding="utf-8", errors="replace", check=False,
    )
    if completed.returncode:
        return [], f"7z_list_failed:{completed.returncode}"
    entries: list[dict[str, str]] = []
    current: dict[str, str] = {}
    for line in completed.stdout.splitlines() + [""]:
        if not line.strip():
            if current.get("Path"):
                entries.append(current)
            current = {}
        elif " = " in line:
            key, value = line.split(" = ", 1)
            current[key] = value
    return entries, None


def inventory_archives(root: Path, extract: bool, extract_name: str, seven_zip: str | None) -> list[dict[str, Any]]:
    inventory: list[dict[str, Any]] = []
    for path in walk_files(root, ARCHIVE_EXTENSIONS):
        relative = posix_relative(path, root)
        entries, error = list_archive(path, seven_zip)
        unsafe = [entry.get("Path", "") for entry in entries if not safe_archive_member(entry.get("Path", ""))]
        links = [
            entry.get("Path", "") for entry in entries
            if entry.get("Symbolic Link", "").strip() or entry.get("Hard Link", "").strip()
        ]
        files = [entry for entry in entries if entry.get("Folder") != "+"]
        raster_count = sum(Path(entry.get("Path", "")).suffix.casefold() in RASTER_EXTENSIONS for entry in files)
        source_count = sum(Path(entry.get("Path", "")).suffix.casefold() in SOURCE_EXTENSIONS for entry in files)
        record: dict[str, Any] = {
            "src": relative,
            "format": path.suffix.casefold().lstrip("."),
            "memberCount": len(files),
            "rasterCount": raster_count,
            "editableSourceCount": source_count,
            "unsafeMembers": sorted(set(unsafe + links), key=str.casefold),
            "status": "inventory_error" if error else "inventoried",
        }
        if error:
            record["reason"] = error
        if extract:
            if error or unsafe or links:
                record["status"] = "blocked_unsafe_or_unreadable"
            else:
                destination = path.parent / extract_name / re.sub(r"[^A-Za-z0-9._ -]+", "_", path.stem)
                destination.mkdir(parents=True, exist_ok=True)
                executable = seven_zip or shutil.which("7z")
                assert executable
                completed = subprocess.run(
                    [executable, "x", str(path), f"-o{destination}", "-y", "-aoa"],
                    capture_output=True, text=True, encoding="utf-8", errors="replace", check=False,
                )
                record["status"] = "extracted" if completed.returncode == 0 else "extract_failed"
                record["extractedTo"] = posix_relative(destination, root)
                if completed.returncode:
                    record["reason"] = f"7z_extract_failed:{completed.returncode}"
        inventory.append(record)
    return inventory


def xml_local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def tiled_metadata(root: Path) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for metadata_path in walk_files(root, {".tsx", ".tmx"}):
        try:
            document = ET.parse(metadata_path).getroot()
        except (ET.ParseError, OSError):
            continue
        candidates = [document] if xml_local_name(document.tag) == "tileset" else [
            element for element in document.iter() if xml_local_name(element.tag) == "tileset"
        ]
        for tileset in candidates:
            image = next((child for child in tileset if xml_local_name(child.tag) == "image"), None)
            if image is None or not image.get("source"):
                continue
            image_path = (metadata_path.parent / image.get("source", "")).resolve()
            try:
                relative = posix_relative(image_path, root)
            except ValueError:
                continue
            tile_width = int(tileset.get("tilewidth", "0") or 0)
            tile_height = int(tileset.get("tileheight", "0") or 0)
            columns = int(tileset.get("columns", "0") or 0)
            count = int(tileset.get("tilecount", "0") or 0)
            margin = int(tileset.get("margin", "0") or 0)
            spacing = int(tileset.get("spacing", "0") or 0)
            if min(tile_width, tile_height, columns) <= 0:
                continue
            animations: dict[int, list[dict[str, int]]] = {}
            for tile in (child for child in tileset if xml_local_name(child.tag) == "tile"):
                animation = next((child for child in tile if xml_local_name(child.tag) == "animation"), None)
                if animation is None:
                    continue
                frames = [
                    {"tileid": int(frame.get("tileid", "0")), "duration": int(frame.get("duration", "0"))}
                    for frame in animation if xml_local_name(frame.tag) == "frame"
                ]
                if frames:
                    animations[int(tile.get("id", "0"))] = frames
            result[normalized_key(relative)] = {
                "grid": {
                    "x": margin, "y": margin, "cellWidth": tile_width, "cellHeight": tile_height,
                    "columns": columns, "rows": (count + columns - 1) // columns, "count": count,
                    "margin": margin, "spacing": spacing, "source": "tiled-metadata", "confidence": 1.0,
                },
                "tileAnimations": animations,
                "metadata": posix_relative(metadata_path, root),
            }
    return result


def resolve_manifest_source(metadata_path: Path, raw_source: str, root: Path) -> Path | None:
    basename = PureWindowsPath(raw_source).name or PurePosixPath(raw_source).name
    for ancestor in metadata_path.parents:
        candidate = ancestor / basename
        if candidate.is_file():
            try:
                candidate.resolve().relative_to(root.resolve())
                return candidate
            except ValueError:
                return None
        if ancestor == root:
            break
    return None


def json_crop_metadata(root: Path) -> dict[str, list[dict[str, Any]]]:
    result: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for metadata_path in walk_files(root, {".json"}):
        if metadata_path.name.casefold() != "sprites.json":
            continue
        try:
            data = json.loads(metadata_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if not isinstance(data, list):
            continue
        for entry in data:
            if not isinstance(entry, dict) or not isinstance(entry.get("bbox"), dict):
                continue
            source_path = resolve_manifest_source(metadata_path, str(entry.get("source_file", "")), root)
            if not source_path:
                continue
            bbox = entry["bbox"]
            try:
                crop = [int(bbox["x"]), int(bbox["y"]), int(bbox["width"]), int(bbox["height"])]
            except (KeyError, TypeError, ValueError):
                continue
            relative = posix_relative(source_path, root)
            result[normalized_key(relative)].append({
                "name": clean_name(str(entry.get("id") or entry.get("category") or "sprite")),
                "crop": crop,
                "kind": "sprite",
                "category": entry.get("category"),
                "source": "json-sprite-manifest",
                "metadata": posix_relative(metadata_path, root),
            })
    for variants in result.values():
        variants.sort(key=lambda item: (item["crop"][1], item["crop"][0], item["name"].casefold()))
    return result


def sequence_groups(paths: list[Path], root: Path, default_frame_ms: int) -> dict[str, dict[str, Any]]:
    groups: dict[tuple[str, str], list[tuple[int, Path]]] = defaultdict(list)
    for path in paths:
        stem = path.stem
        match = SEQUENCE_RE.match(stem)
        if not match:
            continue
        parent_words = words(path.parent.as_posix()) | words(stem)
        explicitly_framed = stem.casefold().startswith("frame_") or "frame" in stem.casefold()
        if not explicitly_framed and not (parent_words & ANIMATION_WORDS):
            continue
        groups[(normalized_key(posix_relative(path.parent, root)), match.group("prefix").casefold())].append(
            (int(match.group("index")), path)
        )
    by_source: dict[str, dict[str, Any]] = {}
    for (_, prefix), members in groups.items():
        members.sort(key=lambda item: (item[0], normalized_key(posix_relative(item[1], root))))
        if len(members) < 2:
            continue
        lead_relative = posix_relative(members[0][1], root)
        frames = []
        for _, path in members:
            try:
                with Image.open(path) as frame_image:
                    frame_width, frame_height = frame_image.size
                    if ("A" in frame_image.getbands() or "transparency" in frame_image.info
                            ) and frame_image.convert("RGBA").getchannel("A").getbbox() is None:
                        continue
            except (OSError, UnidentifiedImageError):
                continue
            frames.append({
                "src": posix_relative(path, root), "x": 0, "y": 0,
                "w": frame_width, "h": frame_height, "duration": default_frame_ms,
            })
        if len(frames) < 2:
            continue
        animation = {
            "frameCount": len(frames), "frames": frames,
            "fps": round(1000 / default_frame_ms, 4), "duration": len(frames) * default_frame_ms,
            "source": "filename-sequence",
        }
        by_source[normalized_key(lead_relative)] = {"role": "lead", "animation": animation, "name": clean_name(prefix)}
        lead_id = stable_id("source", lead_relative)
        for _, member in members[1:]:
            by_source[normalized_key(posix_relative(member, root))] = {"role": "member", "coveredBy": lead_id}
    return by_source


def mask_bounds(mask: Image.Image) -> list[int] | None:
    bbox = mask.getbbox()
    if not bbox:
        return None
    return [bbox[0], bbox[1], bbox[2] - bbox[0], bbox[3] - bbox[1]]


def connected_islands(mask: Image.Image, gap: int, minimum_area: int, maximum: int) -> list[list[int]]:
    expanded = mask.filter(ImageFilter.MaxFilter(gap * 2 + 1)) if gap else mask
    width, height = expanded.size
    data = expanded.tobytes()
    parent: list[int] = []
    boxes: list[list[int]] = []

    def make_label(x0: int, y: int, x1: int) -> int:
        label = len(parent)
        parent.append(label)
        boxes.append([x0, y, x1, y + 1])
        return label

    def find(label: int) -> int:
        while parent[label] != label:
            parent[label] = parent[parent[label]]
            label = parent[label]
        return label

    def union(a: int, b: int) -> int:
        a, b = find(a), find(b)
        if a == b:
            return a
        if a > b:
            a, b = b, a
        parent[b] = a
        boxes[a] = [
            min(boxes[a][0], boxes[b][0]), min(boxes[a][1], boxes[b][1]),
            max(boxes[a][2], boxes[b][2]), max(boxes[a][3], boxes[b][3]),
        ]
        return a

    previous: list[tuple[int, int, int]] = []
    for y in range(height):
        row = data[y * width : (y + 1) * width]
        runs: list[tuple[int, int, int]] = []
        cursor = 0
        while cursor < width:
            start = row.find(b"\xff", cursor)
            if start < 0:
                break
            end = row.find(b"\x00", start)
            if end < 0:
                end = width
            overlaps = [label for px0, px1, label in previous if px1 >= start and px0 <= end]
            label = make_label(start, y, end)
            for other in overlaps:
                label = union(label, other)
            root_label = find(label)
            boxes[root_label][2] = max(boxes[root_label][2], end)
            boxes[root_label][3] = y + 1
            runs.append((start, end, root_label))
            cursor = end + 1
        previous = [(x0, x1, find(label)) for x0, x1, label in runs]

    roots = sorted({find(index) for index in range(len(parent))}, key=lambda label: (boxes[label][1], boxes[label][0]))
    crops: list[list[int]] = []
    for label in roots:
        x0, y0, x1, y1 = boxes[label]
        original = mask.crop((x0, y0, x1, y1))
        bbox = original.getbbox()
        if not bbox:
            continue
        crop = [x0 + bbox[0], y0 + bbox[1], bbox[2] - bbox[0], bbox[3] - bbox[1]]
        area = original.histogram()[255]
        if area >= minimum_area:
            crops.append(crop)
        if len(crops) >= maximum:
            break
    return crops


def classify_hint(relative: str) -> tuple[str, bool]:
    hint_words = words(clean_name(PurePosixPath(relative).stem) + " " + PurePosixPath(relative).parent.as_posix())
    stem = PurePosixPath(relative).stem.casefold()
    autotile = bool(hint_words & AUTOTILE_WORDS) or bool(re.search(r"(?:^|[_-])a[1-5](?:[_-]|$)", stem))
    if hint_words & ANIMATION_WORDS:
        return "animation", autotile
    if hint_words & TILE_WORDS:
        return "tileset", autotile
    if hint_words & SHEET_WORDS:
        return "spritesheet", autotile
    return "standalone", autotile


def filename_grid(relative: str, width: int, height: int) -> tuple[dict[str, Any] | None, int | None]:
    stem = PurePosixPath(relative).stem
    post_apoc = POST_APOC_SHEET_RE.search(stem)
    if post_apoc and "post-apocalypse pixel art" in normalized_key(relative):
        declared = int(post_apoc.group("count"))
        actual = declared
        recovered = False
        if declared > 0 and width % declared:
            if declared == 6 and width % 7 == 0:
                actual, recovered = 7, True
            else:
                actual = 0
        if actual:
            grid = {
                "x": 0, "y": 0, "cellWidth": width // actual, "cellHeight": height,
                "columns": actual, "rows": 1, "count": actual,
                "margin": 0, "spacing": 0, "source": "post-apocalypse-sheet-name", "confidence": 0.99,
                "declaredFrames": declared,
            }
            if recovered:
                grid["recoveredFrames"] = actual
                grid["warning"] = "declared_sheet_count_mismatch_recovered"
            return grid, actual
    matches = list(DIMENSION_RE.finditer(stem))
    if matches:
        match = matches[-1]
        cell_width, named_height = int(match.group("w")), int(match.group("h"))
        count = int(match.group("count")) if match.group("count") else None
        if count is None:
            # Some supplied strips put a direction between WxH and the final frame
            # count, e.g. chest_opening_22x25_down_4frames.
            trailing_count = re.search(
                r"(?:^|[_\s-])(\d{1,4})\s*(?:frames?|fr)(?:$|[_\s-])",
                stem[match.end():], re.IGNORECASE,
            )
            if trailing_count:
                count = int(trailing_count.group(1))
        if count and cell_width > 0 and width >= cell_width * count:
            columns = width // cell_width
            # Ranch character sheets store three animation frames in each of four direction rows.
            rows = max(1, height // named_height) if "/characters/" in normalized_key(relative) else 1
            cell_height = named_height if rows > 1 else height
            available = columns * rows
            grid = {
                "x": 0, "y": 0, "cellWidth": cell_width, "cellHeight": cell_height,
                "columns": columns, "rows": rows, "count": available,
                "margin": 0, "spacing": 0, "source": "filename-dimensions", "confidence": 0.98,
                "declaredFrames": count,
            }
            if rows > 1:
                grid["rowSequences"] = True
            return grid, count
        if ("sheet" in stem.casefold() or "tile" in stem.casefold()) and width % cell_width == 0 and height % named_height == 0:
            columns, rows = width // cell_width, height // named_height
            if 1 < columns * rows <= 4096:
                return ({
                    "x": 0, "y": 0, "cellWidth": cell_width, "cellHeight": named_height,
                    "columns": columns, "rows": rows, "count": columns * rows,
                    "margin": 0, "spacing": 0, "source": "filename-dimensions", "confidence": 0.92,
                }, count)
    key = normalized_key(relative)
    if key.startswith("assets/"):
        key = key[len("assets/"):]
    if key.startswith("topdown monsters part 1/") and stem.isdigit() and 0 <= int(stem) <= 10 and width % 8 == 0 and height % 18 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 8, "cellHeight": height // 18,
            "columns": 8, "rows": 18, "count": 144, "margin": 0, "spacing": 0,
            "source": "topdown-monster-profile", "confidence": 1.0, "rowSequences": True,
        }, 8)
    if stem.startswith(("$", "!$")) and width % 3 == 0 and height % 4 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 3, "cellHeight": height // 4,
            "columns": 3, "rows": 4, "count": 12, "margin": 0, "spacing": 0,
            "source": "rpg-single-character-profile", "confidence": 0.98, "rowSequences": True,
            "directionNames": ["south", "west", "east", "north"],
            "frameOrder": [0, 1, 2, 1], "idleFrame": 1,
        }, 3)
    path_key = f"/{key}/"
    if "/faces/" in path_key and width % 4 == 0 and height % 2 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 4, "cellHeight": height // 2,
            "columns": 4, "rows": 2, "count": 8, "margin": 0, "spacing": 0,
            "source": "rpg-face-profile", "confidence": 0.98, "static": True,
        }, None)
    if ("/sv actors/" in path_key or "/sv_actors/" in path_key) and width % 9 == 0 and height % 6 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 9, "cellHeight": height // 6,
            "columns": 9, "rows": 6, "count": 54, "margin": 0, "spacing": 0,
            "source": "rpg-sideview-actor-profile", "confidence": 0.98, "rowSequences": True,
        }, None)
    multi_character = (
        "/characters/" in path_key
        or bool(re.search(r"(?:^|_)chars(?:_|$)", stem.casefold()))
        or (stem.startswith("!") and not stem.startswith("!$"))
    )
    if multi_character and width % 12 == 0 and height % 8 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 12, "cellHeight": height // 8,
            "columns": 12, "rows": 8, "count": 96, "margin": 0, "spacing": 0,
            "source": "rpg-multi-character-profile", "confidence": 0.98,
            "directionNames": ["south", "west", "east", "north"],
            "frameOrder": [0, 1, 2, 1], "idleFrame": 1,
            "characterBlocks": {"columns": 4, "rows": 2, "directions": 4, "frames": 3},
        }, None)
    tile_sheet = (
        bool(re.search(r"tile[bcde](?:_|$)", stem.casefold()))
        or bool(re.search(r"(?:^|_)(?:tf|outside|inside|dungeon)_[bcde](?:_|$)", stem.casefold()))
    )
    if tile_sheet and width == height and width % 16 == 0:
        return ({
            "x": 0, "y": 0, "cellWidth": width // 16, "cellHeight": height // 16,
            "columns": 16, "rows": 16, "count": 256, "margin": 0, "spacing": 0,
            "source": "rpg-b-e-tilesheet-profile", "confidence": 0.98, "static": True,
        }, None)
    return None, None


def make_variant(source_id: str, relative: str, name: str, crop: list[int], kind: str, suffix: str,
                 usable: bool = True, animation: dict[str, Any] | None = None) -> dict[str, Any]:
    variant: dict[str, Any] = {
        "id": stable_id("variant", source_id, suffix, *crop), "name": name, "src": relative,
        "x": crop[0], "y": crop[1], "w": crop[2], "h": crop[3], "kind": kind, "usable": usable,
    }
    if animation:
        variant["animation"] = animation
    return variant


def grid_variants(source_id: str, relative: str, base_name: str, grid: dict[str, Any], width: int, height: int,
                  tile_animations: dict[int, list[dict[str, int]]] | None, maximum: int,
                  frame_ms: int, mask: Image.Image | None = None) -> tuple[list[dict[str, Any]], dict[str, Any] | None]:
    variants: list[dict[str, Any]] = []
    animation_frames: list[dict[str, Any]] = []
    columns = int(grid["columns"])
    total_count = int(grid.get("count", columns * int(grid["rows"])))
    spacing, margin = int(grid.get("spacing", 0)), int(grid.get("margin", 0))
    cell_width, cell_height = int(grid["cellWidth"]), int(grid["cellHeight"])

    def has_content(x: int, y: int, crop_width: int = cell_width, crop_height: int = cell_height) -> bool:
        return mask is None or mask.crop((x, y, x + crop_width, y + crop_height)).getbbox() is not None

    selected_indices = set(range(min(total_count, maximum)))
    if tile_animations:
        selected_indices.update(index for index in tile_animations if 0 <= index < total_count)
    for index in sorted(selected_indices):
        column, row = index % columns, index // columns
        x = int(grid.get("x", margin)) + column * (cell_width + spacing)
        y = int(grid.get("y", margin)) + row * (cell_height + spacing)
        if x < 0 or y < 0 or x + cell_width > width or y + cell_height > height:
            continue
        frame_animation = None
        if tile_animations and index in tile_animations:
            raw_frames = tile_animations[index]
            frames: list[dict[str, Any]] = []
            for raw in raw_frames:
                tile_id = raw["tileid"]
                fc, fr = tile_id % columns, tile_id // columns
                fx = int(grid.get("x", margin)) + fc * (cell_width + spacing)
                fy = int(grid.get("y", margin)) + fr * (cell_height + spacing)
                if fx + cell_width <= width and fy + cell_height <= height and has_content(fx, fy):
                    frames.append({
                        "src": relative, "x": fx, "y": fy, "w": cell_width, "h": cell_height,
                        "duration": raw.get("duration") or frame_ms,
                    })
            frame_animation = {
                "frameCount": len(frames), "frames": frames,
                "duration": sum(frame["duration"] for frame in frames), "source": "tiled-metadata",
            } if frames else None
        display_crop = [x, y, cell_width, cell_height]
        if not has_content(x, y):
            if not frame_animation:
                continue
            first_visible = frame_animation["frames"][0]
            display_crop = [first_visible["x"], first_visible["y"], first_visible["w"], first_visible["h"]]
        kind = "animation" if frame_animation else ("tile" if grid.get("kind") == "tile" or "tile" in grid.get("source", "") else "frame")
        variant = make_variant(
            source_id, relative, f"{base_name} {index + 1}", display_crop,
            kind, f"grid:{index}", animation=frame_animation,
        )
        variant["frame"] = index
        variants.append(variant)
        animation_frames.append({"src": relative, "x": x, "y": y, "w": cell_width, "h": cell_height, "duration": frame_ms})
    animation = None
    if grid.get("characterBlocks"):
        block = grid["characterBlocks"]
        sequences = []
        block_columns, block_rows = int(block["columns"]), int(block["rows"])
        directions, frames_per_direction = int(block["directions"]), int(block["frames"])
        direction_names = grid.get("directionNames", [])
        frame_order = grid.get("frameOrder", list(range(frames_per_direction)))
        if (not isinstance(frame_order, list) or not frame_order
                or any(not isinstance(index, int) or index < 0 or index >= frames_per_direction for index in frame_order)):
            frame_order = list(range(frames_per_direction))
        for block_row in range(block_rows):
            for block_column in range(block_columns):
                character = block_row * block_columns + block_column
                for direction in range(directions):
                    frames = []
                    row = block_row * directions + direction
                    for frame_index in frame_order:
                        column = block_column * frames_per_direction + frame_index
                        x = int(grid.get("x", margin)) + column * (cell_width + spacing)
                        y = int(grid.get("y", margin)) + row * (cell_height + spacing)
                        if x + cell_width <= width and y + cell_height <= height and has_content(x, y):
                            frames.append({
                                "src": relative, "x": x, "y": y, "w": cell_width, "h": cell_height,
                                "duration": frame_ms,
                            })
                    if not frames:
                        continue
                    block_animation = {
                        "frameCount": len(frames), "frames": frames, "fps": round(1000 / frame_ms, 4),
                        "duration": len(frames) * frame_ms, "source": grid.get("source"),
                        "character": character, "direction": direction,
                    }
                    if direction < len(direction_names):
                        block_animation["directionName"] = direction_names[direction]
                    sequences.append(block_animation)
                    idle_index = int(grid.get("idleFrame", 0))
                    idle_column = block_column * frames_per_direction + min(max(idle_index, 0), frames_per_direction - 1)
                    idle_x = int(grid.get("x", margin)) + idle_column * (cell_width + spacing)
                    idle_y = int(grid.get("y", margin)) + row * (cell_height + spacing)
                    first = next((frame for frame in frames if frame["x"] == idle_x and frame["y"] == idle_y), frames[0])
                    direction_label = direction_names[direction] if direction < len(direction_names) else f"direction {direction + 1}"
                    variants.append(make_variant(
                        source_id, relative, f"{base_name} character {character + 1} — {direction_label}",
                        [first["x"], first["y"], first["w"], first["h"]], "animation",
                        f"character:{character}:direction:{direction}", animation=block_animation,
                    ))
        animation = {
            "frameCount": sum(sequence["frameCount"] for sequence in sequences),
            "frames": [frame for sequence in sequences for frame in sequence["frames"]],
            "duration": sum(sequence["duration"] for sequence in sequences),
            "layout": {"columns": columns, "rows": int(grid["rows"])},
            "sequences": sequences, "source": grid.get("source"),
        }
    elif grid.get("rowSequences") and columns > 1:
        sequences = []
        direction_names = grid.get("directionNames", [])
        frame_order = grid.get("frameOrder", list(range(columns)))
        if (not isinstance(frame_order, list) or not frame_order
                or any(not isinstance(index, int) or index < 0 or index >= columns for index in frame_order)):
            frame_order = list(range(columns))
        for row in range(int(grid["rows"])):
            frames = []
            for column in frame_order:
                index = row * columns + column
                if index >= total_count:
                    break
                x = int(grid.get("x", margin)) + column * (cell_width + spacing)
                y = int(grid.get("y", margin)) + row * (cell_height + spacing)
                if x + cell_width <= width and y + cell_height <= height and has_content(x, y):
                    frames.append({
                        "src": relative, "x": x, "y": y, "w": cell_width, "h": cell_height,
                        "duration": frame_ms,
                    })
            if not frames:
                continue
            row_animation = {
                "frameCount": len(frames), "frames": frames, "fps": round(1000 / frame_ms, 4),
                "duration": len(frames) * frame_ms, "source": grid.get("source"), "sequence": row,
            }
            if row < len(direction_names):
                row_animation["directionName"] = direction_names[row]
            sequences.append(row_animation)
            idle_column = min(max(int(grid.get("idleFrame", 0)), 0), columns - 1)
            idle_x = int(grid.get("x", margin)) + idle_column * (cell_width + spacing)
            idle_y = int(grid.get("y", margin)) + row * (cell_height + spacing)
            first = next((frame for frame in frames if frame["x"] == idle_x and frame["y"] == idle_y), frames[0])
            direction_label = direction_names[row] if row < len(direction_names) else f"direction {row + 1}"
            variants.append(make_variant(
                source_id, relative, f"{base_name} — {direction_label}",
                [first["x"], first["y"], first["w"], first["h"]], "animation", f"row-sequence:{row}",
                animation=row_animation,
            ))
        animation = {
            "frameCount": sum(sequence["frameCount"] for sequence in sequences),
            "frames": [frame for sequence in sequences for frame in sequence["frames"]],
            "duration": sum(sequence["duration"] for sequence in sequences),
            "layout": {"columns": columns, "rows": int(grid["rows"])},
            "sequences": sequences, "source": grid.get("source"),
        }
    elif (not grid.get("static") and len(variants) > 1
          and (grid.get("kind") != "tile" or grid.get("declaredFrames"))):
        animation = {
            "frameCount": len(animation_frames), "frames": animation_frames,
            "fps": round(1000 / frame_ms, 4), "duration": len(animation_frames) * frame_ms,
            "layout": {"columns": columns, "rows": int(grid["rows"])}, "source": grid.get("source"),
        }
    return variants, animation


def analyze_raster(path: Path, root: Path, args: argparse.Namespace, overrides: dict[str, Any],
                   tiled: dict[str, dict[str, Any]], json_crops: dict[str, list[dict[str, Any]]],
                   sequences: dict[str, dict[str, Any]]) -> dict[str, Any]:
    relative = posix_relative(path, root)
    key = normalized_key(relative)
    source_id = stable_id("source", relative)
    source_override = override_for(relative, overrides)
    preview = is_preview_path(relative) or bool(source_override.get("preview", False))
    hint_kind, autotile = classify_hint(relative)
    source_kind = str(source_override.get("kind", hint_kind))
    source: dict[str, Any] = {
        "id": source_id, "src": relative,
        "name": str(source_override.get("name") or display_asset_name(relative)),
        "pack": str(source_override.get("pack") or pack_name(relative)),
        "category": str(source_override.get("category") or library_category(relative, source_kind)),
        "kind": source_kind, "usable": not preview,
        "reason": "preview_or_reference_art" if preview else None,
        "width": 0, "height": 0, "format": path.suffix.casefold().lstrip("."),
        "sha1": sha1_file(path), "alpha": {"hasAlpha": False, "coverage": None, "threshold": args.alpha_threshold},
        "bounds": None, "preview": preview, "variants": [],
    }
    try:
        with Image.open(path) as image:
            width, height = image.size
            source["width"], source["height"] = width, height
            source["format"] = (image.format or source["format"]).casefold()
            pixel_count = width * height
            is_animated_file = bool(getattr(image, "is_animated", False) and getattr(image, "n_frames", 1) > 1)
            mask = None
            if pixel_count <= args.max_analysis_pixels:
                rgba = image.convert("RGBA")
                alpha_channel = rgba.getchannel("A")
                has_alpha = "A" in image.getbands() or "transparency" in image.info
                source["alpha"]["hasAlpha"] = has_alpha
                if has_alpha:
                    mask = alpha_channel.point(lambda value: 255 if value >= args.alpha_threshold else 0)
                    histogram = mask.histogram()
                    source["alpha"]["coverage"] = round(histogram[255] / pixel_count, 6) if pixel_count else 0
                    source["bounds"] = mask_bounds(mask)
                else:
                    source["bounds"] = [0, 0, width, height]
                    source["alpha"]["coverage"] = 1.0
            else:
                source["bounds"] = [0, 0, width, height]
                source["alpha"]["analysisSkipped"] = "pixel_limit"

            if source_override.get("preserveCanvas") and source["bounds"]:
                source["contentBounds"] = source["bounds"]
                source["bounds"] = [0, 0, width, height]

            if not source["bounds"]:
                source["usable"] = False
                source["reason"] = "fully_transparent"
                source["kind"] = "empty"
                return source

            if preview:
                return source

            if autotile and key not in tiled and not source_override.get("grid"):
                source["kind"] = "autotile"
                source["usable"] = False
                source["reason"] = "autotile_requires_compositor_or_metadata"
                return source

            metadata_grid = tiled.get(key, {}).get("grid")
            grid = source_override.get("grid") or metadata_grid
            declared_frames = None
            if grid:
                grid = dict(grid)
                if "cellWidth" not in grid and grid.get("columns"):
                    grid["cellWidth"] = width // int(grid["columns"])
                if "cellHeight" not in grid and grid.get("rows"):
                    grid["cellHeight"] = height // int(grid["rows"])
                grid.setdefault("x", 0); grid.setdefault("y", 0); grid.setdefault("margin", 0); grid.setdefault("spacing", 0)
                grid.setdefault("columns", max(1, width // int(grid["cellWidth"])))
                grid.setdefault("rows", max(1, height // int(grid["cellHeight"])))
                grid.setdefault("count", int(grid["columns"]) * int(grid["rows"]))
                grid.setdefault("source", "override" if source_override.get("grid") else "tiled-metadata")
                grid.setdefault("confidence", 1.0)
            elif key not in json_crops and not is_animated_file:
                grid, declared_frames = filename_grid(relative, width, height)

            explicit_variants = source_override.get("variants", [])
            manifest_variants = json_crops.get(key, [])
            for index, spec in enumerate([*explicit_variants, *manifest_variants]):
                crop = spec.get("crop") or [spec.get("x"), spec.get("y"), spec.get("w"), spec.get("h")]
                if len(crop) != 4 or not all(isinstance(value, int) for value in crop):
                    continue
                x, y, crop_width, crop_height = crop
                if min(x, y) < 0 or crop_width <= 0 or crop_height <= 0 or x + crop_width > width or y + crop_height > height:
                    continue
                variant = make_variant(
                    source_id, relative, str(spec.get("name") or f"{source['name']} {index + 1}"), crop,
                    str(spec.get("kind") or "sprite"), str(spec.get("id") or f"explicit:{index}"),
                    bool(spec.get("usable", True)), spec.get("animation"),
                )
                variant["detection"] = spec.get("source", "override")
                if spec.get("category"):
                    variant["category"] = spec["category"]
                source["variants"].append(variant)

            sequence = sequences.get(key)
            if sequence and sequence.get("role") == "member":
                source["usable"] = False
                source["reason"] = "animation_sequence_member"
                source["coveredBy"] = sequence["coveredBy"]
                return source

            if is_animated_file:
                durations: list[int] = []
                for frame_index in range(image.n_frames):
                    image.seek(frame_index)
                    durations.append(int(image.info.get("duration", args.default_frame_ms) or args.default_frame_ms))
                # A GIF's first frame can occupy less than later composited frames. Keeping the
                # full logical canvas guarantees playback is never clipped.
                crop = [0, 0, width, height]
                source["bounds"] = crop
                frames = [
                    {"src": relative, "x": crop[0], "y": crop[1], "w": crop[2], "h": crop[3], "duration": duration}
                    for duration in durations
                ]
                animation = {
                    "frameCount": len(frames), "frames": frames, "duration": sum(durations),
                    "fps": round(1000 / (sum(durations) / len(durations)), 4), "source": "animated-image",
                }
                source["kind"] = "animation"
                source["animation"] = animation
                source["variants"].append(make_variant(source_id, relative, source["name"], crop, "animation", "animated", animation=animation))
            elif sequence and sequence.get("role") == "lead":
                animation = sequence["animation"]
                source["kind"] = "animation"
                source["animation"] = animation
                source["variants"].append(make_variant(
                    source_id, relative, sequence.get("name") or source["name"], [0, 0, width, height],
                    "animation", "sequence", animation=animation,
                ))
            elif grid:
                if metadata_grid:
                    source["kind"] = "tileset"
                grid["kind"] = "tile" if source["kind"] == "tileset" or grid.get("source") == "tiled-metadata" else "frame"
                source["grid"] = grid
                variants, animation = grid_variants(
                    source_id, relative, source["name"], grid, width, height,
                    tiled.get(key, {}).get("tileAnimations"), args.max_variants_per_source, args.default_frame_ms, mask,
                )
                existing_crops = {(v["x"], v["y"], v["w"], v["h"]) for v in source["variants"]}
                source["variants"].extend(v for v in variants if (v["x"], v["y"], v["w"], v["h"]) not in existing_crops)
                if animation and (
                    source["kind"] != "tileset" or declared_frames
                    or grid.get("rowSequences") or grid.get("characterBlocks")
                ):
                    if grid.get("rowSequences") or grid.get("characterBlocks"):
                        # Direction rows are independent animations. Keeping them only on the
                        # dedicated row variants prevents static cells from inheriting a flattened
                        # all-directions playback sequence in the editor.
                        source["animations"] = animation.get("sequences", [])
                    elif animation.get("frames"):
                        source["animations"] = [animation]
                        first = animation["frames"][0]
                        source["variants"].append(make_variant(
                            source_id, relative, f"{source['name']} — animated",
                            [first["x"], first["y"], first["w"], first["h"]],
                            "animation", "grid-animation", animation=animation,
                        ))
                    source["kind"] = "animation" if declared_frames else "spritesheet"
            elif not source["variants"] and mask is not None and source["alpha"]["coverage"] is not None and source["alpha"]["coverage"] < 0.9:
                minimum_area = max(args.min_island_area, (width * height) // 200_000)
                islands = connected_islands(mask, args.island_gap, minimum_area, args.max_regions_per_source)
                significant = [crop for crop in islands if crop[2] * crop[3] >= minimum_area]
                if len(significant) >= 3 or (len(significant) == 2 and source["kind"] in {"spritesheet", "tileset"}):
                    source["kind"] = "spritesheet" if source["kind"] == "standalone" else source["kind"]
                    # Keep the complete compact crop inventory, but expose only a small initial
                    # card set. The editor's region picker can materialize any remaining crop;
                    # repeating full id/name/src metadata for every region made the JS enormous.
                    source["regions"] = significant
                    source["regionsConfidence"] = 0.75
                    source["regionsReason"] = "inferred alpha regions require manual review"
                    source["regionsReview"] = True
                    source["review"] = True
                    source["reason"] = "alpha_island_inference_requires_review"
                    for index, crop in enumerate(significant[: args.max_island_cards]):
                        source["variants"].append(make_variant(
                            source_id, relative, f"{source['name']} {index + 1}", crop,
                            "sprite", f"island:{index}",
                        ))
                    source["detection"] = {
                        "method": "alpha-islands", "confidence": 0.75, "gap": args.island_gap,
                        "regionCount": len(significant), "listedCards": min(len(significant), args.max_island_cards),
                    }
                else:
                    crop = source["bounds"]
                    source["variants"].append(make_variant(source_id, relative, source["name"], crop, "standalone", "trim"))
            elif not source["variants"]:
                crop = source["bounds"]
                source["variants"].append(make_variant(source_id, relative, source["name"], crop, source["kind"], "full"))

            if explicit_variants and source_override.get("replaceVariants"):
                allowed = {stable_id("variant", source_id, str(spec.get("id") or f"explicit:{index}"), *(spec.get("crop") or [])) for index, spec in enumerate(explicit_variants)}
                source["variants"] = [variant for variant in source["variants"] if variant["id"] in allowed]
            if source_override.get("reason"):
                source["reason"] = source_override["reason"]
            if "usable" in source_override:
                source["usable"] = bool(source_override["usable"])
            if not source["variants"] and source["usable"]:
                source["usable"] = False
                source["reason"] = source["reason"] or "no_safe_variants_detected"
            return source
    except (UnidentifiedImageError, OSError, ValueError) as exc:
        source["usable"] = False
        source["reason"] = f"unreadable:{type(exc).__name__}"
        return source


def deduplicate_sources(sources: list[dict[str, Any]]) -> None:
    by_hash: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for source in sources:
        by_hash[source["sha1"]].append(source)
    for group in by_hash.values():
        if len(group) < 2:
            continue
        canonical = min(
            group,
            key=lambda source: (
                0 if source.get("grid", {}).get("source") == "tiled-metadata" else 1,
                1 if source.get("preview") else 0,
                1 if "tiled_files" in normalized_key(source["src"]) else 0,
                len(source["src"]), normalized_key(source["src"]),
            ),
        )
        aliases = []
        for duplicate in group:
            if duplicate is canonical:
                continue
            aliases.append({"id": duplicate["id"], "src": duplicate["src"], "name": duplicate["name"], "pack": duplicate["pack"]})
            duplicate["usable"] = False
            duplicate["reason"] = "duplicate_content"
            duplicate["canonicalId"] = canonical["id"]
            duplicate["variants"] = []
        canonical["aliases"] = sorted(aliases, key=lambda alias: normalized_key(alias["src"]))


def unsupported_sources(root: Path, aliases: dict[str, list[str]]) -> list[dict[str, Any]]:
    records = []
    for path in walk_files(root, SOURCE_EXTENSIONS):
        relative = posix_relative(path, root)
        extension = path.suffix.casefold()
        represented = [
            target for target in aliases.get(normalized_key(relative), [])
            if (root / PurePosixPath(target)).is_file() and PurePosixPath(target).suffix.casefold() in RASTER_EXTENSIONS
        ]
        record = {
            "id": stable_id("unsupported", relative), "src": relative,
            "format": extension.lstrip("."),
            "status": "represented_by_raster" if represented else "convertible_source",
            "reason": "supplied_browser_export_available" if represented else "requires_export_to_png_or_gif_before_browser_use",
        }
        if represented:
            record["representedBy"] = represented
        records.append(record)
    return records


def validate_catalog(catalog: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    ids: set[str] = set()
    for source in catalog["sources"]:
        if not isinstance(source.get("name"), str) or not source["name"].strip():
            errors.append(f"missing display name: {source.get('src', source.get('id'))}")
        if source.get("category") not in LIBRARY_CATEGORIES:
            errors.append(f"invalid library category: {source.get('src', source.get('id'))} -> {source.get('category')!r}")
        if source["id"] in ids:
            errors.append(f"duplicate source id: {source['id']}")
        ids.add(source["id"])
        for variant in source["variants"]:
            if variant["id"] in ids:
                errors.append(f"duplicate variant id: {variant['id']}")
            ids.add(variant["id"])
            if min(variant["x"], variant["y"]) < 0 or variant["w"] <= 0 or variant["h"] <= 0:
                errors.append(f"invalid crop: {variant['id']}")
            if variant["x"] + variant["w"] > source["width"] or variant["y"] + variant["h"] > source["height"]:
                errors.append(f"out-of-bounds crop: {variant['id']}")
    return errors


def build_catalog(args: argparse.Namespace) -> dict[str, Any]:
    root = args.root.resolve()
    archives = inventory_archives(root, args.extract_archives, args.archive_extract_dir, args.seven_zip)
    raster_paths = walk_files(root, RASTER_EXTENSIONS)
    ignored_diagnostics = [
        posix_relative(path, root) for path in raster_paths
        if path.parent.resolve() == root and path.name.startswith("_")
    ]
    raster_paths = [
        path for path in raster_paths
        if not (path.parent.resolve() == root and path.name.startswith("_"))
    ]
    output_paths = {args.output.resolve()}
    if args.json_output:
        output_paths.add(args.json_output.resolve())
    raster_paths = [path for path in raster_paths if path.resolve() not in output_paths]
    if args.include:
        raster_paths = [
            path for path in raster_paths
            if any(fnmatch.fnmatchcase(normalized_key(posix_relative(path, root)), normalized_key(pattern)) for pattern in args.include)
        ]
    if args.limit:
        raster_paths = raster_paths[: args.limit]
    overrides = load_overrides(args.overrides)
    source_aliases = load_source_aliases(args.source_aliases, overrides)
    tiled = tiled_metadata(root)
    json_crops = json_crop_metadata(root)
    sequences = sequence_groups(raster_paths, root, args.default_frame_ms)
    sources: list[dict[str, Any]] = []
    for index, path in enumerate(raster_paths, 1):
        sources.append(analyze_raster(path, root, args, overrides, tiled, json_crops, sequences))
        if not args.quiet and (index % 250 == 0 or index == len(raster_paths)):
            print(f"Analyzed {index}/{len(raster_paths)} raster sources...", file=sys.stderr)
    deduplicate_sources(sources)
    sources.sort(key=lambda source: (source["pack"].casefold(), source["name"].casefold(), normalized_key(source["src"])))
    unsupported = unsupported_sources(root, source_aliases)
    kind_counts = Counter(source["kind"] for source in sources)
    usable_sources = sum(bool(source["usable"]) for source in sources)
    usable_variants = sum(sum(bool(variant["usable"]) for variant in source["variants"]) for source in sources if source["usable"])
    excluded = [
        {"id": source["id"], "src": source["src"], "reason": source["reason"]}
        for source in sources if not source["usable"]
    ]
    catalog: dict[str, Any] = {
        "schemaVersion": 1,
        "pipelineVersion": PIPELINE_VERSION,
        "stats": {
            "scannedRasterSources": len(sources), "usableSources": usable_sources,
            "excludedSources": len(sources) - usable_sources, "usableVariants": usable_variants,
            "duplicateSources": sum(source.get("reason") == "duplicate_content" for source in sources),
            "previewSources": sum(bool(source.get("preview")) for source in sources),
            "reviewSources": sum(bool(source.get("review")) and bool(source.get("usable")) for source in sources),
            "editableSourceFiles": len(unsupported),
            "representedEditableSources": sum(item["status"] == "represented_by_raster" for item in unsupported),
            "unsupportedEditableSources": sum(item["status"] != "represented_by_raster" for item in unsupported),
            "archiveCount": len(archives), "archivedRasterMembers": sum(item["rasterCount"] for item in archives),
            "ignoredDiagnosticFiles": len(ignored_diagnostics),
            "kinds": dict(sorted(kind_counts.items())),
        },
        "sources": sources,
        "excluded": excluded,
        "unsupported": unsupported,
        "archives": archives,
        "ignored": [
            {"src": relative, "reason": "root_diagnostic_or_qa_artifact"}
            for relative in sorted(ignored_diagnostics, key=str.casefold)
        ],
    }
    errors = validate_catalog(catalog)
    if errors:
        raise RuntimeError("catalog validation failed:\n" + "\n".join(errors[:50]))
    return catalog


def write_catalog(catalog: dict[str, Any], output: Path, json_output: Path | None, pretty: bool) -> None:
    separators = None if pretty else (",", ":")
    indent = 2 if pretty else None
    payload = json.dumps(catalog, ensure_ascii=False, sort_keys=True, separators=separators, indent=indent)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(f"window.CURATED_ART_ASSET_CATALOG={payload};\n", encoding="utf-8", newline="\n")
    if json_output:
        json_output.parent.mkdir(parents=True, exist_ok=True)
        json_output.write_text(payload + "\n", encoding="utf-8", newline="\n")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Classify raster assets and emit crop/animation metadata without duplicating images.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--root", type=Path, default=Path.cwd(), help="workspace root to scan")
    parser.add_argument("--output", type=Path, default=Path("curated-asset-catalog.js"), help="browser-loadable JS output")
    parser.add_argument("--json-output", type=Path, help="optional plain JSON output for tooling")
    parser.add_argument("--overrides", type=Path, default=Path("asset-pipeline-overrides.json"), help="JSON profiles/explicit crops")
    parser.add_argument("--source-aliases", type=Path, default=Path("asset-source-aliases.json"),
                        help="editable-source to browser-raster representation mappings")
    parser.add_argument("--include", action="append", help="case-insensitive glob relative to root; repeatable")
    parser.add_argument("--limit", type=int, default=0, help="process only the first N matching rasters (smoke tests)")
    parser.add_argument("--alpha-threshold", type=int, default=8, choices=range(1, 256), metavar="1..255")
    parser.add_argument("--island-gap", type=int, default=2, choices=range(0, 8), metavar="0..7")
    parser.add_argument("--min-island-area", type=int, default=16)
    parser.add_argument("--max-analysis-pixels", type=int, default=4_000_000)
    parser.add_argument("--max-variants-per-source", type=int, default=64,
                        help="representative regular-grid cards; complete grid metadata is retained")
    parser.add_argument("--max-island-cards", type=int, default=4,
                        help="initial cards per alpha-island source; every crop remains in source.regions")
    parser.add_argument("--max-regions-per-source", type=int, default=512,
                        help="safety cap for compact alpha-island region detection")
    parser.add_argument("--default-frame-ms", type=int, default=125)
    parser.add_argument("--extract-archives", action="store_true", help="safely extract inventoried archives before scanning")
    parser.add_argument("--archive-extract-dir", default="_extracted", help="deterministic sibling extraction directory")
    parser.add_argument("--seven-zip", help="path to 7z executable (auto-detected by default)")
    parser.add_argument("--pretty", action="store_true", help="pretty-print output (larger file)")
    parser.add_argument("--quiet", action="store_true", help="suppress progress messages")
    args = parser.parse_args(argv)
    if (args.limit < 0 or args.min_island_area < 1 or args.max_analysis_pixels < 1
            or args.max_variants_per_source < 1 or args.max_island_cards < 1
            or args.max_regions_per_source < args.max_island_cards or args.default_frame_ms < 1):
        parser.error("numeric limits and frame duration must be positive")
    if not args.output.is_absolute():
        args.output = args.root / args.output
    if args.json_output and not args.json_output.is_absolute():
        args.json_output = args.root / args.json_output
    if args.overrides and not args.overrides.is_absolute():
        args.overrides = args.root / args.overrides
    if args.source_aliases and not args.source_aliases.is_absolute():
        args.source_aliases = args.root / args.source_aliases
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    catalog = build_catalog(args)
    write_catalog(catalog, args.output, args.json_output, args.pretty)
    if not args.quiet:
        stats = catalog["stats"]
        print(
            f"Wrote {args.output} with {stats['usableVariants']} usable variants from "
            f"{stats['usableSources']}/{stats['scannedRasterSources']} raster sources."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
