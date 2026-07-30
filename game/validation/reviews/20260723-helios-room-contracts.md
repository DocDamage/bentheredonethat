# Helios room navigation and collision contracts

## Scope

`HE-01` through `HE-14` now declare scene-owned authored navigation and
collision IDs in `CampaignRoomRegistry`. The layouts replace the manifest's
open-interior generated navigation baseline with explicit walkable rectangles
and useful-cell bounds for the Skybridge, Customs, Market, Concourse,
Substation, Clinic, Core Approach, Solar Core, Service Undercity, Night Garden,
Recreation Stack, Hologram Archive, Grid Junction, and Maintenance Lift.

This is collision-contract evidence only. It does not grant visual,
foreground, safe-arrival capture, controller-input, population, provenance, or
licensing acceptance.

## Focused milestone evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/content_validator_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn'
) -TimeoutSeconds 360

.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/helios_layout_smoke.tscn',
  'tests/helios_scenario_smoke.tscn'
) -TimeoutSeconds 360
```

- Registry and content contracts passed at
  `test-artifacts/20260723-101612-63a23836`.
- Helios layout and scenario contracts passed at
  `test-artifacts/20260723-101622-3ac30dde`.
- Both isolated runs retained the production-save sentinel (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remains; this
  milestone neither attributes nor accepts that release-level issue.

## Decision

Rework remains required before acceptance: no distribution eligibility,
contact-sheet approval, or user visual/input sign-off is recorded for Helios.
