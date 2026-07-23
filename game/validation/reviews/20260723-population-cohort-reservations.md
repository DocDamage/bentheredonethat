# M1-POPULATION-COHORT-RESERVATIONS-01

- State: Verified automated scheduling-safety contract
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Reviewer: automated contract; admitted identity and gameplay population review remain pending

## Intended result

Keep room-owned population cohorts from reserving cells used by ports, safe
arrivals, interactions, treasures, bosses, and save anchors. The generated
registry remains the scheduling authority; this work only strengthens cell
occupancy safety and does not admit unreviewed character assets to runtime.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_population_scheduler_smoke.tscn',
  'tests/campaign_manifest_room_smoke.tscn',
  'tests/campaign_asterion_first_rooms_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=4` and `sentinel=True` in
  `test-artifacts/20260723-115327-0418280d`.
- The scheduler test verifies the generated 267-identity registry with nine
  quarantined identities, preserves explicit caller reservations, and rejects
  a runtime profile assigned to the `HM-05` save-anchor cell.
- The manifest cohort fixture exposes its applied reservation set; Asterion
  and full Mansion handoff fixtures retain their active-room cohort contracts.

## Decision

The occupancy reservation contract is verified. It does not fulfill the plan's
remaining requirement to admit approved profiles, spawn the exact roster, or
review live movement and dialogue schedules.
