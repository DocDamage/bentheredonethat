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
ELIGIBILITY_STATES = {"distribution_confirmed", "review_required", "rejected"}


def load_eligibility(root: Path) -> tuple[str, dict[str, str]]:
    path = root / "game/ben_rpg/visual_assets/distribution_eligibility.json"
    raw = json.loads(path.read_text(encoding="utf-8"))
    if raw.get("schemaVersion") != 1:
        raise ValueError("distribution eligibility ledger must use schemaVersion 1")
    default = raw.get("default")
    if default not in ELIGIBILITY_STATES:
        raise ValueError("distribution eligibility ledger default must be a known state")
    entries = raw.get("assets", {})
    if not isinstance(entries, dict):
        raise ValueError("distribution eligibility ledger assets must be an object")
    result: dict[str, str] = {}
    for asset_path, entry in entries.items():
        status = entry.get("status") if isinstance(entry, dict) else entry
        if not isinstance(asset_path, str) or not asset_path.startswith("res://") or status not in ELIGIBILITY_STATES:
            raise ValueError("distribution eligibility asset entries need a res:// path and known state")
        result[asset_path] = status
    return default, result


def load_pack_decisions(root: Path) -> list[dict[str, Any]]:
    path = root / "game/ben_rpg/visual_assets/pack_provenance_decisions.json"
    raw = json.loads(path.read_text(encoding="utf-8"))
    if raw.get("schemaVersion") != 1 or not isinstance(raw.get("decisions"), list):
        raise ValueError("pack provenance decisions must use schemaVersion 1 with a decisions list")
    inventory_path = root / "game/validation/generated/source_library_inventory.json"
    inventory = json.loads(inventory_path.read_text(encoding="utf-8"))
    inventory_hashes: dict[tuple[str, str], str] = {}
    for library in inventory.get("libraries", []):
        if not isinstance(library, dict) or not isinstance(library.get("label"), str):
            continue
        for record in library.get("rootFiles", []):
            if isinstance(record, dict) and isinstance(record.get("path"), str) and isinstance(record.get("sha256"), str):
                inventory_hashes[(library["label"], record["path"])] = record["sha256"]

    def verify_evidence(decision_id: str, kind: str, evidence: Any) -> None:
        if not isinstance(evidence, list) or not evidence:
            raise ValueError(f"pack provenance decision {decision_id} needs {kind} evidence")
        for record in evidence:
            if not isinstance(record, dict):
                raise ValueError(f"pack provenance decision {decision_id} has invalid {kind} evidence")
            if record.get("inventory") != "game/validation/generated/source_library_inventory.json":
                raise ValueError(f"pack provenance decision {decision_id} must reference the tracked source inventory")
            library = record.get("library")
            evidence_path = record.get("path")
            checksum = record.get("sha256")
            if not isinstance(library, str) or not isinstance(evidence_path, str) or not isinstance(checksum, str):
                raise ValueError(f"pack provenance decision {decision_id} has incomplete {kind} evidence")
            if inventory_hashes.get((library, evidence_path)) != checksum:
                raise ValueError(f"pack provenance decision {decision_id} has stale {kind} evidence for {library}/{evidence_path}")

    decisions: list[dict[str, Any]] = []
    seen: set[str] = set()
    for decision in raw["decisions"]:
        if not isinstance(decision, dict):
            raise ValueError("pack provenance decisions must be objects")
        decision_id = decision.get("id")
        status = decision.get("decision")
        if not isinstance(decision_id, str) or not decision_id or decision_id in seen or status not in ELIGIBILITY_STATES:
            raise ValueError("pack provenance decisions need unique ids and known eligibility states")
        verify_evidence(decision_id, "terms", decision.get("termsEvidence"))
        verify_evidence(decision_id, "credit", decision.get("creditEvidence"))
        seen.add(decision_id)
        decisions.append(decision)
    return sorted(decisions, key=lambda decision: str(decision["id"]))


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
    default_eligibility, eligibility_overrides = load_eligibility(root)
    pack_decisions = load_pack_decisions(root)
    assets: list[dict[str, Any]] = []
    for entry in inventory.get("assets", []):
        path = str(entry["path"])
        source = root / "game" / path.removeprefix("res://")
        evidence = []
        if source.is_file():
            evidence = local_license_evidence(root / "game", source)
        # The runtime ledger must reproduce from a clean checkout. Source-library
        # licensing remains a separate curator-workstation concern, so only
        # tracked game-local evidence can contribute to this artifact.
        if not evidence:
            evidence = ["game/LICENSE"]
        eligibility = eligibility_overrides.get(path, default_eligibility)
        assets.append({
            "path": path,
            "sourceGroup": source_group(path),
            "profileIds": sorted(entry.get("profileIds", [])),
            "unprofiledClassification": entry.get("unprofiledClassification", ""),
            "localLicenseEvidence": evidence,
            "distributionEligibility": eligibility,
            "licenseReviewStatus": eligibility,
        })
    with_evidence = sum(bool(asset["localLicenseEvidence"]) for asset in assets)
    eligibility_counts = {state: sum(asset["distributionEligibility"] == state for asset in assets) for state in sorted(ELIGIBILITY_STATES)}
    classification_counts: dict[str, int] = {}
    for asset in assets:
        classification = asset["unprofiledClassification"]
        if classification:
            classification_counts[classification] = classification_counts.get(classification, 0) + 1
    return {
        "schemaVersion": 2,
        "scope": "static Godot raster references; not a reachability or license-grant proof",
        "summary": {
            "assets": len(assets),
            "withLocalLicenseEvidence": with_evidence,
            "needsManualLicenseConfirmation": len(assets) - with_evidence,
            "distributionEligibility": eligibility_counts,
            "unprofiledByClassification": dict(sorted(classification_counts.items())),
        },
        "packProvenanceDecisions": pack_decisions,
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
