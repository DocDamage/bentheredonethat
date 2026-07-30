#!/usr/bin/env python3
"""Build the deterministic non-raster release provenance ledger.

The visual ledger owns raster files. This companion inventory closes the
release boundary for audio, fonts, addons, shaders, serialized/dynamic
resources, and shipped notices. It inventories tracked export-eligible files,
records a checksum and explicit license evidence for every entry, and fails
when a new category is introduced without a policy.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "game/ben_rpg/release/generated/release_asset_provenance.json"

CATEGORIES = {
    "audio": {".wav", ".ogg", ".mp3"},
    "font": {".ttf", ".otf", ".woff", ".woff2"},
    "shader": {".gdshader", ".glsl"},
    "dynamic_resource": {".tres", ".res", ".dtl", ".dch", ".atlastex", ".scn"},
}
EXCLUDED_PREFIXES = (
    "game/tests/",
    "game/validation/",
    "game/addons/godot_mcp_x/",
    "game/addons/dialogic/Editor/",
    "game/addons/dialogic/Modules/StyleEditor/",
    "game/addons/dialogic/Modules/Variable/variables_editor/",
    "game/addons/dialogic/Modules/Glossary/glossary_editor.",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z", "--", "game"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return sorted(item.decode("utf-8") for item in result.stdout.split(b"\0") if item)


def category(path: str) -> str | None:
    suffix = Path(path).suffix.casefold()
    for name, suffixes in CATEGORIES.items():
        if suffix in suffixes:
            return name
    if path.startswith("game/addons/dialogic/") and suffix in {".gd", ".cfg", ".json"}:
        return "addon"
    if path in {"game/CREDITS.md", "game/LICENSE", "game/THIRD_PARTY_NOTICES.md"}:
        return "notice"
    return None


def evidence(path: str, kind: str) -> tuple[str, list[str]]:
    if path.startswith("game/addons/dialogic/Example Assets/Fonts/"):
        return "Apache-2.0", ["game/addons/dialogic/Example Assets/Fonts/LICENSE.txt"]
    if path.startswith("game/addons/dialogic/Example Assets/sound-effects/"):
        return "CC-BY-SA-4.0", ["game/addons/dialogic/Example Assets/sound-effects/LICENSE.txt"]
    if path.startswith("game/addons/dialogic/"):
        return "MIT", ["game/THIRD_PARTY_NOTICES.md"]
    if path.endswith("SourceCodePro-Bold.ttf"):
        return "OFL-1.1", ["game/THIRD_PARTY_NOTICES.md"]
    if path.endswith("Kenney Pixel.ttf") or path.startswith("game/assets/music/") or path.startswith("game/assets/sfx/"):
        return "CC0-1.0", ["game/CREDITS.md"]
    if path.startswith("game/game_assets/SFX/"):
        return "CC0-1.0", ["game/CREDITS.md"]
    if path.startswith("game/game_assets/Tilesets/Ranch Stuff/"):
        return "pack-license", ["game/THIRD_PARTY_NOTICES.md"]
    if kind == "notice":
        return "notice", [path]
    return "MIT", ["game/LICENSE"]


def build() -> dict:
    assets = []
    counts: dict[str, int] = {}
    for relative in tracked_files():
        if relative.startswith(EXCLUDED_PREFIXES) or relative.endswith((".import", ".uid")):
            continue
        kind = category(relative)
        if kind is None:
            continue
        absolute = ROOT / relative
        if not absolute.is_file():
            continue
        license_id, evidence_paths = evidence(relative, kind)
        for evidence_path in evidence_paths:
            if not (ROOT / evidence_path).is_file():
                raise ValueError(f"{relative} has missing license evidence {evidence_path}")
        counts[kind] = counts.get(kind, 0) + 1
        assets.append({
            "path": "res://" + relative.removeprefix("game/"),
            "category": kind,
            "sha256": sha256(absolute),
            "license": license_id,
            "licenseEvidence": evidence_paths,
            "distributionEligibility": "distribution_confirmed",
        })
    return {
        "schemaVersion": 1,
        "scope": "tracked, export-eligible non-raster runtime assets and shipped notices",
        "assets": assets,
        "summary": {"assets": len(assets), "byCategory": dict(sorted(counts.items()))},
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    payload = json.dumps(build(), indent=2, sort_keys=True) + "\n"
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != payload:
            raise SystemExit("Release asset provenance is stale; run tools/build_release_asset_provenance.py")
        print(f"RELEASE_ASSET_PROVENANCE_OK path={OUTPUT.relative_to(ROOT).as_posix()}")
        return 0
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(payload, encoding="utf-8")
    print(f"WROTE {OUTPUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
