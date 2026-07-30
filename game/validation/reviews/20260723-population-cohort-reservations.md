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
.\tools\run_godot_isolated.ps1 `
  -Scene @('tests/campaign_population_scheduler_smoke.tscn') `
  -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=1` and `sentinel=True` in
  `test-artifacts/20260723-172353-03b90fe2`.
- The scheduler test verifies the generated 258-identity complete-source
  registry, preserves explicit caller reservations, and rejects a blocked
  profile and a profile assigned to the `HM-05` save-anchor cell.
- A wider four-scene rerun retained at
  `test-artifacts/20260723-172409-bb0a1160` passed the population scheduler,
  manifest-room, and Asterion fixtures. `campaign_hm01_live_handoff_smoke`
  exited 1 before its success marker and emitted no diagnostic beyond startup;
  that broader handoff regression remains open and is not counted as passing
  evidence for this revision.

## Decision

The earlier focused handoff result is superseded by the July 23 full smoke
matrix. The host command limit split its 134 save-isolated scenes into 87 logs
at `test-artifacts/20260723-180041-0cc1f390` and a successful 47-scene
continuation at `test-artifacts/20260723-182138-547178c9`; both preserve the
production-save sentinel and contain no functional test failure.

The occupancy reservation contract is verified. It does not fulfill the plan's
remaining requirement to admit approved profiles, spawn the exact roster, or
review live movement and dialogue schedules.
