# M2-HM-MANIFEST-01 — Haunted Mansion manifest runtime

- State: Verified automated contract; visual/product acceptance pending
- Milestone: M2 — Mansion quality vertical slice
- Commit SHA: `5ff1aae9`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Intended result

Run the complete `HM-01` through `HM-16` graph through the shared authored-room
runtime. The production facility portal enters `HM-01`; the active room owns
its navigation, reciprocal ports, interactions, boss contract, save anchors,
and streamed presentation layers. This record does not grant final visual,
distribution, controller, or performance approval.

## Contract and scope

- The 16 stable `HM-*` IDs resolve through `CampaignRoomRegistry` to scene-backed
  records, a common staged world origin, and declared layers.
- The 4:44 route, the Gallery/Nursery clock-hand chain, optional loops,
  two Mansion save anchors, and `mansion_archive_boss` remain room-owned.
- Facility portal creation uses `_create_manifest_facility_portal`; the obsolete
  Mansion-only transition constructor is no longer a test dependency.
- Save anchors register only while their room is active. Switching rooms removes
  the prior room's runtime anchor so shared staging coordinates cannot unlock
  roster editing at an unrelated current-room location.

## Automated evidence

Command run against the commit worktree:

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_manifest_transition_installer_smoke.tscn',
  'tests/campaign_hm01_authored_room_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn',
  'tests/mansion_scenario_smoke.tscn',
  'tests/mansion_layout_smoke.tscn',
  'tests/mansion_puzzle_smoke.tscn',
  'tests/mansion_encounter_integration_smoke.tscn',
  'tests/universe_save_points_smoke.tscn'
) -TimeoutSeconds 360
```

- Result: 9/9 passed.
- Artifact root: `test-artifacts/20260723-055204-61693668`.
- Production-save sentinel: unchanged (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remained present;
  this batch neither attributes nor accepts that release-level baseline.

## Required follow-up evidence

- Native-scale first-visit and stabilized captures for every Mansion room.
- Keyboard/mouse and controller traversal of every port, interaction, boss
  return, and facility entry/return path.
- Save/reload from each active Mansion anchor in a user-visible run.
- Per-source distribution eligibility, attribution, and crop/palette/scale
  review for the Mansion slice.
- Product/visual reviewer decision: pending. This work package is verified by
  automated evidence only; M2 is not accepted.

