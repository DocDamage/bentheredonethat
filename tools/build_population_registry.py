#!/usr/bin/env python3
"""Generate and validate the canonical SakPix population registry.

The plan owns the editorial assignment of every eligible supplied identity.  This tool
turns that locked table into a compact runtime-safe registry: it retains stable
collection/folder keys, but never emits a path into the ignored source library.
When a curator workstation has the library present, it also verifies the eight
direction sheets. Incomplete source folders are excluded from planned content.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any


REQUIRED_ROTATIONS = (
    "north", "north-east", "east", "south-east",
    "south", "south-west", "west", "north-west",
)
PLANNED_IDENTITY_COUNT = 258
PHASE_PATTERN = re.compile(r"`?([FSP])(!?)(?:-([A-Z]))?@P([1-6])`?")
TABLE_START = "### 23.12 Complete SakPix canonical-home and story-phase registry"
TABLE_END = "#### Secondary visitor and relocation schedules"
PROVENANCE_STATES = {"distribution_confirmed", "review_required"}


def stable_id(collection: str, folder: str) -> str:
    # Collection and folder names are the supplied source identity keys. JSON
    # escaping preserves them exactly without leaking a local filesystem path.
    return f"sakpix:{collection}/{folder}"


def parse_assignments(plan: Path) -> list[dict[str, str]]:
    text = plan.read_text(encoding="utf-8")
    if TABLE_START not in text or TABLE_END not in text:
        raise ValueError("population assignment table is missing from the completion plan")
    section = text.split(TABLE_START, 1)[1].split(TABLE_END, 1)[0]
    assignments: list[dict[str, str]] = []
    for line in section.splitlines():
        if not line.startswith("| `"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != 4:
            continue
        collection, folder, home, schedule = (cell.strip("`") for cell in cells)
        assignments.append({"collection": collection, "folder": folder, "home": home, "schedule": schedule})
    if len(assignments) != PLANNED_IDENTITY_COUNT:
        raise ValueError(
            f"population plan must assign exactly {PLANNED_IDENTITY_COUNT} eligible identities, "
            f"found {len(assignments)}"
        )
    if len({stable_id(item['collection'], item['folder']) for item in assignments}) != len(assignments):
        raise ValueError("population plan assigns at least one source identity more than once")
    return assignments


def source_rotations(source_root: Path, collection: str, folder: str) -> list[str]:
    rotations = source_root / collection / folder / "rotations"
    if not rotations.is_dir():
        return []
    return sorted(path.stem for path in rotations.glob("*.png"))


def provenance_status(root: Path) -> str:
    path = root / "game/ben_rpg/population/provenance_decision.json"
    raw = json.loads(path.read_text(encoding="utf-8"))
    status = raw.get("status")
    if raw.get("schemaVersion") != 1 or status not in PROVENANCE_STATES:
        raise ValueError("population provenance decision must use schemaVersion 1 and a known status")
    return status


def identity_record(assignment: dict[str, str], rotations: list[str] | None, admitted_status: str) -> dict[str, Any]:
    match = PHASE_PATTERN.search(assignment["schedule"])
    if rotations is None:
        rotation_state = "unverified"
        available: list[str] = []
    else:
        available = rotations
        rotation_state = "complete" if set(rotations) == set(REQUIRED_ROTATIONS) else "incomplete"
    record: dict[str, Any] = {
        "id": stable_id(assignment["collection"], assignment["folder"]),
        "sourceIdentity": {"collection": assignment["collection"], "folder": assignment["folder"]},
        "canonicalHome": assignment["home"],
        "sourceRotationState": rotation_state,
        "availableRotations": available,
        "runtimeProfileId": None,
        "provenanceStatus": admitted_status,
    }
    if match is None:
        raise ValueError(f"eligible identity {record['id']} has no active schedule in the population plan")
    phase, hostile, cohort, anchor = match.groups()
    record["schedule"] = {
        "phase": phase,
        "anchor": f"P{anchor}",
        "cohort": cohort,
        "route": "bounded_hostile" if hostile else "anchor_to_interaction",
    }
    record["planSchedule"] = assignment["schedule"]
    return record


def build(root: Path, source_root: Path | None = None) -> dict[str, Any]:
    assignments = parse_assignments(root / "FFVI_ALIGNMENT_COMPLETION_PLAN.md")
    admitted_status = provenance_status(root)
    records = [
        identity_record(item, source_rotations(source_root, item["collection"], item["folder"]) if source_root else None, admitted_status)
        for item in assignments
    ]
    if source_root:
        discovered = {
            stable_id(collection.name, folder.name)
            for collection in source_root.iterdir() if collection.is_dir()
            for folder in collection.iterdir() if folder.is_dir()
            if set(source_rotations(source_root, collection.name, folder.name)) == set(REQUIRED_ROTATIONS)
        }
        assigned = {record["id"] for record in records}
        if discovered != assigned:
            missing = sorted(assigned - discovered)
            extra = sorted(discovered - assigned)
            raise ValueError(
                "eligible population source assignment mismatch: "
                f"missing={len(missing)}, extra={len(extra)}"
            )
    result = {
        "schemaVersion": 1,
        "sourceLibraryRequiredForVerification": bool(source_root),
        "identities": sorted(records, key=lambda item: item["id"]),
    }
    validate(result, source_verified=bool(source_root))
    return result


def validate(raw: dict[str, Any], source_verified: bool | None = None) -> None:
    if raw.get("schemaVersion") != 1:
        raise ValueError("population registry must use schemaVersion 1")
    identities = raw.get("identities")
    if not isinstance(identities, list) or len(identities) != PLANNED_IDENTITY_COUNT:
        raise ValueError(
            f"population registry must contain exactly {PLANNED_IDENTITY_COUNT} eligible identities"
        )
    ids: set[str] = set()
    complete = unverified = 0
    occupancy: Counter[tuple[str, str, str | None]] = Counter()
    for item in identities:
        if not isinstance(item, dict):
            raise ValueError("population identity must be an object")
        identity_id = item.get("id")
        source = item.get("sourceIdentity")
        schedule = item.get("schedule")
        state = item.get("sourceRotationState")
        if not isinstance(identity_id, str) or not identity_id.startswith("sakpix:") or identity_id in ids:
            raise ValueError("population identities need unique stable SakPix ids")
        ids.add(identity_id)
        if not isinstance(source, dict) or not all(isinstance(source.get(key), str) and source[key] for key in ("collection", "folder")):
            raise ValueError(f"{identity_id} needs collection and folder source identity keys")
        if identity_id != stable_id(source["collection"], source["folder"]):
            raise ValueError(f"{identity_id} does not match its source identity keys")
        home = item.get("canonicalHome")
        if not isinstance(home, str) or not re.fullmatch(r"(?:NP|FI|HM|AS|PV|HE|FR|MP|EM|AF|PL|SF|FT|WF|LM)-\d{2}", home):
            raise ValueError(f"{identity_id} has an invalid canonical home")
        if state not in {"complete", "unverified"}:
            raise ValueError(f"{identity_id} has an invalid rotation state")
        if not isinstance(schedule, dict):
            raise ValueError(f"{identity_id} needs a schedule")
        phase = schedule.get("phase")
        if state == "unverified":
            unverified += 1
        else:
            complete += 1
            if phase not in {"F", "S", "P"} or schedule.get("anchor") not in {f"P{index}" for index in range(1, 7)}:
                raise ValueError(f"{identity_id} has an invalid active schedule")
            occupancy[(item["canonicalHome"], phase, schedule.get("cohort"))] += 1
        provenance = item.get("provenanceStatus")
        if provenance not in PROVENANCE_STATES:
            raise ValueError(f"{identity_id} has an invalid provenance status")
        if item.get("runtimeProfileId") is not None and provenance != "distribution_confirmed":
            raise ValueError(f"{identity_id} cannot bind a runtime profile before provenance admission")
    if source_verified:
        if (complete, unverified) != (PLANNED_IDENTITY_COUNT, 0):
            raise ValueError(
                f"verified registry must contain {PLANNED_IDENTITY_COUNT} complete identities, "
                f"got {complete} complete/{unverified} unverified"
            )
    elif source_verified is False and complete:
        raise ValueError("clean-checkout registry cannot claim source rotation verification")
    elif source_verified is None and (complete, unverified) not in {
        (PLANNED_IDENTITY_COUNT, 0),
        (0, PLANNED_IDENTITY_COUNT),
    }:
        raise ValueError("registry contains a partial source-verification result")
    overcrowded = [key for key, count in occupancy.items() if count > 6]
    if overcrowded:
        raise ValueError(f"population schedule exceeds six identities in a room cohort: {overcrowded[0]}")


def plan_contract(raw: dict[str, Any]) -> list[dict[str, Any]]:
    """Return fields that must follow the locked plan in every checkout."""
    return [
        {
            "id": item["id"],
            "sourceIdentity": item["sourceIdentity"],
            "canonicalHome": item["canonicalHome"],
            "schedule": item["schedule"],
            "runtimeProfileId": item["runtimeProfileId"],
            "provenanceStatus": item["provenanceStatus"],
            "planSchedule": item["planSchedule"],
        }
        for item in raw["identities"]
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--source-root", type=Path)
    parser.add_argument("--output", type=Path, default=Path("game/ben_rpg/population/generated/population_registry.json"))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    source_root = None if args.source_root is None else (args.source_root if args.source_root.is_absolute() else root / args.source_root).resolve()
    if source_root is not None and not source_root.is_dir():
        raise ValueError(f"population source root is unavailable: {source_root}")
    output = args.output if args.output.is_absolute() else root / args.output
    generated = build(root, source_root)
    payload = json.dumps(generated, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.check:
        if not output.is_file():
            raise ValueError(f"population registry is missing or stale: {output}")
        current = json.loads(output.read_text(encoding="utf-8"))
        validate(current, source_verified=bool(source_root) if source_root else None)
        if source_root:
            if output.read_text(encoding="utf-8") != payload:
                raise ValueError(f"population registry is missing or stale: {output}")
        elif plan_contract(current) != plan_contract(generated):
            raise ValueError(f"population registry does not match the locked plan: {output}")
        print(f"Population registry is current: {output}")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8", newline="\n")
        state = "verified" if source_root else "clean-checkout"
        print(f"Wrote {output} with {PLANNED_IDENTITY_COUNT} eligible {state} population identities.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Population registry error: {error}", file=sys.stderr)
        raise SystemExit(1)
