# M1-MANIFEST-SAVE-CONTEXT-01

- State: Verified automated migration and reload contract
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Reviewer: automated contract; gameplay save/reload acceptance remains product-owned

## Intended result

Persist a stable `last_manifest_room_id` with every save so streamed rooms that
share a universe staging origin can reload their exact active room. Migrate the
five retired legacy stages in each of the seven core universes from version 19
coordinates to a validated `Nw` safe arrival in the matching manifest room.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/save_migrator_smoke.tscn',
  'tests/save_v18_fixture_smoke.tscn',
  'tests/campaign_manifest_save_context_smoke.tscn',
  'tests/campaign_manifest_room_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=5` and `sentinel=True` in
  `test-artifacts/20260723-113810-a480d2cb`.
- The v20 migration rejects future schemas, preserves non-manifest town saves,
  maps legacy Mansion and Asterion samples to `HM-01` and `AS-03`, and sends
  them to their two-cells-inward `Nw` arrival coordinates.
- A serialized `HM-06` location reloads its saved room ID, activates the room
  runtime and streamer, restores the player at the saved safe cell, and selects
  the matching manifest camera area.

## Decision

This verifies the data and runtime restore path. It does not replace future
manual save/reload capture review across every story state, nor accept the
existing shutdown-only ObjectDB/resource warnings.
