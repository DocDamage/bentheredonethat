# M1-MANIFEST-ENCOUNTER-CONTRACT-01

- State: Verified automated policy/runtime contract
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Reviewer: automated contract; balance and encounter-placement acceptance remain pending

## Intended result

Give every authored room an explicit encounter contract: policy, formation pool,
threshold range, anti-repeat depth, cooldown, and zone source. The active
streamed room must own its random director while keeping ports, safe arrivals,
features, treasures, bosses, and save points outside random encounter zones.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_manifest_encounter_smoke.tscn',
  'tests/campaign_encounter_runtime_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn',
  'tests/mansion_encounter_integration_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=5` and `sentinel=True` in
  `test-artifacts/20260723-120236-8b9d9bf3`.
- `HM-02` proves zone policy, a manifest pool, an eight-step cooldown, and
  safe-arrival exclusion; scripted-only `HM-06` has no random pool.
- The runtime fixture proves legacy compatibility controllers remain bound and
  a zone room activates its room-owned director, while a scripted-only room
  removes it.

## Decision

The ownership and safety contract is verified. Formation balance, individual
zone art placement, and every story-state encounter review remain open.
