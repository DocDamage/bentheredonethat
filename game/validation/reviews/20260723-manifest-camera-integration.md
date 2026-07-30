# M1-CAMERA-INTEGRATION-01

- State: Verified automated integration; visual camera-composition approval remains pending
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Required reviewer: product/visual reviewer (user)

## Intended result

Make `CampaignCameraController` the live owner of camera limits for manifest
rooms. It must convert a room's local pixel bounds and world-cell origin into
the scaled canvas coordinates expected by `Camera2D`, consume the streamer's
active-room signal, and leave the five-room Mansion compatibility adapter in
control of its legacy areas.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_manifest_room_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_field_scale_smoke.tscn',
  'tests/frosthold_scenario_smoke.tscn',
  'tests/moonpetal_scenario_smoke.tscn',
  'tests/empyreal_scenario_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=6` and `sentinel=True` in
  `test-artifacts/20260723-113048-9a48f134`.
- The manifest fixture verifies unload clearing, `FR-03` global scaled limits
  (`Rect2i(48000, 0, 2688, 1728)` at 2x canvas scale), direct `Camera2D`
  application, and clearing on the legacy Mansion stream transition.
- Frosthold, Moonpetal, and Empyreal scenario fixtures each passed after the
  live controller wiring.

## Decision

The coordinate and ownership handoff is verified. This does not approve the
composition, zoom, player-scale, doorway-scale, or visual readability criteria
for every authored room. The known shutdown-only ObjectDB/resource warnings
remain open and are not accepted by this work package.
