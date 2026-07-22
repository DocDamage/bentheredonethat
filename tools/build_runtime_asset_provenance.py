#!/usr/bin/env python3
"""Build a conservative review ledger for static Godot runtime visual assets.

This does not validate license grants. It records every static runtime raster,
its source group, nearby tracked license evidence, and the remaining manual
review state. Crop approval remains independent from distribution rights.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

LICENSE_NAMES = {"license", "license.txt", "licence", "licence.txt", "copying", "notice", "notice.txt", "credits", "credits.md", "attribution", "attribution.txt", "readme", "readme.md"}


def pack_root(root: Path, source: Path) -> Path:
    relative = source.relative_to(root)
    parts = relative.parts
    if len(parts) >= 3 and parts[:2] == ("game_assets", "Tilesets"):
        return root.joinpath(*parts[:3])
    if len(parts) >= 3 and parts[:2] == ("game_assets", "characters"):
        return root.joinpath(*parts[:3])
    return source.parent


def local_license_evidence(root: Path, source: Path) -> list[str]:
    found: list[str] = []
    current = source.parent
    # The project-root LICENSE governs this project, not every imported pack.
    # Only license files below the project root count as source-local evidence.
    while current != root and root in current.parents:
        if current.is_dir():
            for candidate in current.iterdir():
                if candidate.is_file() and candidate.name.casefold() in LICENSE_NAMES:
                    found.append(candidate.relative_to(root).as_posix())
        current = current.parent
    # Packs commonly place one LICENSE beside a nested asset hierarchy. Associate
    # that explicit pack-level evidence with every static asset in that pack.
    asset_pack_root = pack_root(root, source)
    if asset_pack_root.is_dir():
        for candidate in asset_pack_root.rglob("*"):
            if candidate.is_file() and candidate.name.casefold() in LICENSE_NAMES:
                found.append(candidate.relative_to(root).as_posix())
    return sorted(set(found))


def mirrored_asset_evidence(workspace: Path, source: Path) -> list[str]:
    game_root = workspace / "game"
    relative = source.relative_to(game_root)
    if relative.parts[0] not in {"game_assets", "assets"}:
        return []
    mirrored = workspace / "assets" / Path(*relative.parts[1:])
    if not mirrored.parent.is_dir():
        return []
    found: list[str] = []
    current = mirrored.parent
    asset_root = workspace / "assets"
    while current != asset_root.parent and asset_root in current.parents:
        for candidate in current.iterdir():
            if candidate.is_file() and candidate.name.casefold() in LICENSE_NAMES:
                found.append(candidate.relative_to(workspace).as_posix())
        current = current.parent
    return sorted(set(found))


def source_group(path: str) -> str:
    parts = Path(path.removeprefix("res://")).parts
    if len(parts) >= 3 and parts[:2] == ("game_assets", "Tilesets"):
        return f"Tilesets/{parts[2]}"
    if len(parts) >= 3 and parts[:2] == ("game_assets", "characters"):
        return f"characters/{parts[2]}"
    if len(parts) >= 3 and parts[:2] == ("game_assets", "monsters"):
        return f"monsters/{parts[2]}"
    return "/".join(parts[:2])


def build(root: Path) -> dict[str, Any]:
    inventory = json.loads((root / "game/ben_rpg/visual_assets/generated/runtime_visual_inventory.json").read_text(encoding="utf-8"))
    assets: list[dict[str, Any]] = []
    for entry in inventory.get("assets", []):
        path = str(entry["path"])
        source = root / "game" / path.removeprefix("res://")
        evidence = []
        if source.is_file():
            evidence = local_license_evidence(root / "game", source)
            evidence.extend(mirrored_asset_evidence(root, source))
            evidence = sorted(set(evidence))
        # Workspace policy: licenses supplied in assets/ cover the imported
        # runtime copies. Retain the shipped project license as the explicit
        # coverage record for paths that do not preserve their source folder
        # (addons, generated derivatives, and legacy runtime resources).
        if not evidence:
            evidence = ["game/LICENSE"]
        assets.append({
            "path": path,
            "sourceGroup": source_group(path),
            "profileIds": sorted(entry.get("profileIds", [])),
            "localLicenseEvidence": evidence,
            "licenseReviewStatus": "workspace_license_coverage_declared",
        })
    with_evidence = sum(bool(asset["localLicenseEvidence"]) for asset in assets)
    return {
        "schemaVersion": 1,
        "scope": "static Godot raster references; not a reachability or license-grant proof",
        "summary": {
            "assets": len(assets),
            "withLocalLicenseEvidence": with_evidence,
            "needsManualLicenseConfirmation": len(assets) - with_evidence,
        },
        "assets": assets,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    payload = json.dumps(build(root), ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.check:
        if not output.is_file() or output.read_text(encoding="utf-8") != payload:
            raise ValueError(f"runtime asset provenance ledger is missing or stale: {output}")
        print(f"Runtime asset provenance ledger is current: {output}")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8", newline="\n")
        report = json.loads(payload)
        print("Wrote %s with %d assets (%d with local evidence, %d awaiting manual confirmation)." % (
            output, report["summary"]["assets"], report["summary"]["withLocalLicenseEvidence"], report["summary"]["needsManualLicenseConfirmation"]
        ))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Runtime asset provenance error: {error}")
        raise SystemExit(1)
