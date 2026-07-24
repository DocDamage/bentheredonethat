#!/usr/bin/env python3
"""Validate visual profiles and emit a deterministic Godot runtime manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

from PIL import Image

SCALE_CLASSES = {"actor", "building", "landmark", "prop", "tile"}
CROP_APPROVAL_STATES = {"approved"}
DISTRIBUTION_ELIGIBILITY_STATES = {"distribution_confirmed", "review_required", "rejected"}
RELEASE_VISUAL_ACCEPTANCE_STATES = {"prototype_only", "final_approved"}
APPROVED_FIELD_RENDER_SCALES = (0.5, 1.0, 2.0, 3.0)
SURFACES = {"field", "battle", "portrait", "ui"}


def fail(message: str) -> None:
    raise ValueError(message)


def rect(value: Any, label: str) -> list[int]:
    if not isinstance(value, list) or len(value) != 4 or any(isinstance(v, bool) or not isinstance(v, int) for v in value):
        fail(f"{label} must be [x, y, width, height] integers")
    if value[0] < 0 or value[1] < 0 or value[2] <= 0 or value[3] <= 0:
        fail(f"{label} must have non-negative origin and positive size")
    return value


def pair(value: Any, label: str, positive: bool = False) -> list[int]:
    if not isinstance(value, list) or len(value) != 2 or any(isinstance(v, bool) or not isinstance(v, int) for v in value):
        fail(f"{label} must be two integer values")
    if positive and any(v <= 0 for v in value):
        fail(f"{label} values must be positive")
    return value


def contained(inner: list[int], outer: list[int], label: str) -> None:
    if inner[0] < outer[0] or inner[1] < outer[1] or inner[0] + inner[2] > outer[0] + outer[2] or inner[1] + inner[3] > outer[1] + outer[3]:
        fail(f"{label} is outside its allowed bounds")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def ids_sha256(ids: list[str]) -> str:
    return hashlib.sha256(("\n".join(sorted(ids)) + "\n").encode("utf-8")).hexdigest()


def load_profile_review_decision(root: Path, profile_ids: list[str]) -> set[str] | None:
    path = root / "game/ben_rpg/visual_assets/profile_review_decisions.json"
    if not path.is_file():
        return None
    raw = json.loads(path.read_text(encoding="utf-8"))
    if raw.get("schemaVersion") != 1 or raw.get("decision") != "final_approved":
        fail("profile review decision must record schemaVersion 1 final_approved approval")
    pending = raw.get("pendingProfileIds")
    if not isinstance(pending, list) or not all(isinstance(profile_id, str) for profile_id in pending):
        fail("profile review decision pendingProfileIds must be string ids")
    if len(set(pending)) != len(pending) or not set(pending).issubset(set(profile_ids)):
        fail("profile review decision names an invalid or duplicate pending profile")
    if raw.get("reviewedProfileSetSha256") != ids_sha256(profile_ids):
        fail("profile review decision does not match the current profile set")
    approved = sorted(set(profile_ids) - set(pending))
    if raw.get("approvedProfileCount") != len(approved) or raw.get("approvedProfileSetSha256") != ids_sha256(approved):
        fail("profile review decision does not match the approved profile set")
    return set(approved)


def inferred_surface(kind: str) -> str:
    if "portrait" in kind:
        return "portrait"
    if kind.startswith("battle_"):
        return "battle"
    if kind.startswith("ui_") or kind == "icon":
        return "ui"
    return "field"


def matching_field_render_scale(source_region: list[int], world_draw_size: list[int]) -> float | None:
    for scale in APPROVED_FIELD_RENDER_SCALES:
        if world_draw_size == [round(source_region[2] * scale), round(source_region[3] * scale)]:
            return scale
    return None


def validate(root: Path, raw: dict[str, Any]) -> dict[str, Any]:
    if raw.get("schemaVersion") != 2:
        fail("visual profiles must use schemaVersion 2")
    profiles = raw.get("profiles")
    if not isinstance(profiles, list) or not profiles:
        fail("profiles must be a non-empty list")
    if not all(isinstance(profile, dict) and isinstance(profile.get("id"), str) for profile in profiles):
        fail("profiles must have object records with string ids before review resolution")
    final_approved_ids = load_profile_review_decision(root, [str(profile["id"]) for profile in profiles])
    seen: set[str] = set()
    provenance_path = root / "game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json"
    provenance = json.loads(provenance_path.read_text(encoding="utf-8"))
    eligibility_by_path = {
        str(asset.get("path")): asset.get("distributionEligibility")
        for asset in provenance.get("assets", []) if isinstance(asset, dict)
    }
    output: list[dict[str, Any]] = []
    for profile in profiles:
        if not isinstance(profile, dict):
            fail("each profile must be an object")
        profile_id = profile.get("id")
        if not isinstance(profile_id, str) or not profile_id or profile_id in seen:
            fail(f"profile id must be unique and non-empty: {profile_id!r}")
        seen.add(profile_id)
        if not isinstance(profile.get("kind"), str) or not profile["kind"]:
            fail(f"{profile_id}.kind must be non-empty")
        source = profile.get("source")
        placement = profile.get("placement")
        if not isinstance(source, dict) or not isinstance(placement, dict):
            fail(f"{profile_id} needs source and placement objects")
        texture = source.get("runtimeTexture")
        if not isinstance(texture, str) or texture.startswith(("/", "\\")) or ".." in Path(texture).parts:
            fail(f"{profile_id}.source.runtimeTexture must be workspace-relative")
        texture_path = (root / texture).resolve()
        if not texture_path.is_file() or root not in texture_path.parents:
            fail(f"{profile_id} references missing texture {texture!r}")
        runtime_path = "res://" + texture.removeprefix("game/").replace("\\", "/")
        eligibility = eligibility_by_path.get(runtime_path)
        if eligibility not in DISTRIBUTION_ELIGIBILITY_STATES:
            fail(f"{profile_id} has no distribution eligibility record for {runtime_path}")
        if eligibility == "rejected":
            fail(f"{profile_id} cannot use rejected source {runtime_path}")
        if final_approved_ids is None:
            release_visual_acceptance = profile.get("releaseVisualAcceptance", "prototype_only")
        else:
            release_visual_acceptance = "final_approved" if profile_id in final_approved_ids else "prototype_only"
        if release_visual_acceptance not in RELEASE_VISUAL_ACCEPTANCE_STATES:
            fail(f"{profile_id}.releaseVisualAcceptance must be prototype_only or final_approved")
        if release_visual_acceptance == "final_approved" and eligibility != "distribution_confirmed":
            fail(f"{profile_id} cannot receive final visual acceptance while {runtime_path} is {eligibility}")
        source_region = rect(source.get("region"), f"{profile_id}.source.region")
        alpha_bounds = rect(source.get("alphaBounds", source_region), f"{profile_id}.source.alphaBounds")
        with Image.open(texture_path) as image:
            texture_bounds = [0, 0, image.width, image.height]
        source_checksum = source.get("sourceChecksum")
        if not isinstance(source_checksum, str) or len(source_checksum) != 64:
            fail(f"{profile_id}.source.sourceChecksum must be a SHA-256 checksum")
        actual_checksum = sha256(texture_path)
        if source_checksum != actual_checksum:
            fail(f"{profile_id}.source.sourceChecksum does not match {texture}")
        source_density = source.get("sourceDensity")
        if isinstance(source_density, bool) or not isinstance(source_density, int) or source_density <= 0:
            fail(f"{profile_id}.source.sourceDensity must be a positive integer")
        contained(source_region, texture_bounds, f"{profile_id}.source.region")
        contained(alpha_bounds, source_region, f"{profile_id}.source.alphaBounds")
        foot_anchor = pair(placement.get("footAnchor"), f"{profile_id}.placement.footAnchor")
        if not (0 <= foot_anchor[0] < source_region[2] and 0 <= foot_anchor[1] < source_region[3]):
            fail(f"{profile_id}.placement.footAnchor must be inside source.region")
        scale_class = placement.get("scaleClass")
        if scale_class not in SCALE_CLASSES:
            fail(f"{profile_id}.placement.scaleClass is invalid")
        collision_footprint = placement.get("collisionFootprint")
        if not isinstance(collision_footprint, str) or not collision_footprint:
            fail(f"{profile_id}.placement.collisionFootprint must be non-empty")
        crop_approval = profile.get("cropApproval")
        if crop_approval not in CROP_APPROVAL_STATES:
            fail(f"{profile_id}.cropApproval must be approved")
        golden_capture = profile.get("goldenCapture")
        if not isinstance(golden_capture, str) or not golden_capture:
            fail(f"{profile_id}.goldenCapture must be a workspace-relative path")
        golden_capture_path = (root / golden_capture).resolve()
        if not golden_capture_path.is_file() or root not in golden_capture_path.parents:
            fail(f"{profile_id}.goldenCapture references missing file {golden_capture!r}")
        license_reference = profile.get("licenseReference")
        if not isinstance(license_reference, str) or not license_reference or license_reference.startswith(("/", "\\")) or ".." in Path(license_reference).parts:
            fail(f"{profile_id}.licenseReference must be a workspace-relative evidence path")
        license_reference_path = (root / license_reference).resolve()
        if not license_reference_path.is_file() or root not in license_reference_path.parents:
            fail(f"{profile_id}.licenseReference references missing evidence {license_reference!r}")
        world_draw_size = pair(profile.get("worldDrawSize"), f"{profile_id}.worldDrawSize", positive=True)
        surface = profile.get("surface", inferred_surface(profile["kind"]))
        if surface not in SURFACES:
            fail(f"{profile_id}.surface is invalid")
        render_scale = matching_field_render_scale(source_region, world_draw_size) if surface == "field" else None
        legacy_scale_exception = profile.get("legacyScaleException", "")
        if not isinstance(legacy_scale_exception, str):
            fail(f"{profile_id}.legacyScaleException must be a string when present")
        if surface == "field" and render_scale is None and release_visual_acceptance == "final_approved" and not legacy_scale_exception:
            fail(f"{profile_id} cannot receive final visual acceptance with an arbitrary field scale")
        if surface != "field" and legacy_scale_exception:
            fail(f"{profile_id}.legacyScaleException is only valid for field profiles")
        if release_visual_acceptance == "final_approved" and legacy_scale_exception:
            fail(f"{profile_id} cannot receive final visual acceptance while it has a legacy scale exception")
        render_scale_y = render_scale
        if render_scale is None:
            render_scale = world_draw_size[0] / source_region[2]
            render_scale_y = world_draw_size[1] / source_region[3]
            if legacy_scale_exception and abs(render_scale - render_scale_y) > 0.000001:
                fail(f"{profile_id}.legacyScaleException must preserve a uniform render scale")
        field_scale_status = "approved"
        if surface == "field" and legacy_scale_exception:
            field_scale_status = "legacy_exception"
        elif surface == "field" and matching_field_render_scale(source_region, world_draw_size) is None:
            field_scale_status = "prototype_review_required"
        normalized = {
            "id": profile_id,
            "kind": profile["kind"],
            "source": {
                "pack": source.get("pack", ""),
                "runtimeTexture": texture.replace("\\", "/"),
                "sha256": actual_checksum,
                "sourceChecksum": source_checksum,
                "sourceDensity": source_density,
                "region": source_region,
                "alphaBounds": alpha_bounds,
            },
            "placement": {"footAnchor": foot_anchor, "scaleClass": scale_class, "collisionFootprint": collision_footprint},
            "worldDrawSize": world_draw_size,
            "surface": surface,
            "renderScale": render_scale,
            "renderScaleY": render_scale_y,
            "fieldScaleStatus": field_scale_status,
            "licenseReference": license_reference.replace("\\", "/"),
            "distributionEligibility": eligibility,
            "releaseVisualAcceptance": release_visual_acceptance,
            "cropApproval": crop_approval,
            "goldenCapture": golden_capture.replace("\\", "/"),
        }
        if legacy_scale_exception:
            normalized["legacyScaleException"] = legacy_scale_exception
        if "doorway" in placement:
            doorway = pair(placement["doorway"], f"{profile_id}.placement.doorway")
            if not (0 <= doorway[0] < source_region[2] and 0 <= doorway[1] < source_region[3]):
                fail(f"{profile_id}.placement.doorway must be inside source.region")
            normalized["placement"]["doorway"] = doorway
        output.append(normalized)
    return {"schemaVersion": 2, "profiles": sorted(output, key=lambda item: item["id"])}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--profiles", type=Path, default=Path("game/ben_rpg/visual_assets/visual_profiles.json"))
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/visual_assets/generated/runtime_visual_manifest.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    profiles = args.profiles if args.profiles.is_absolute() else root / args.profiles
    output = args.output if args.output.is_absolute() else root / args.output
    manifest = validate(root, json.loads(profiles.read_text(encoding="utf-8")))
    payload = json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.check:
        if not output.is_file() or output.read_text(encoding="utf-8") != payload:
            fail(f"runtime manifest is missing or stale: {output}")
        print(f"Visual manifest is valid and current: {output}")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8", newline="\n")
        print(f"Wrote {output} with {len(manifest['profiles'])} visual profiles.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Visual manifest error: {error}", file=sys.stderr)
        raise SystemExit(1)
