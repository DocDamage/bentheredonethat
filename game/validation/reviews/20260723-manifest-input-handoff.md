# M1-MANIFEST-INPUT-HANDOFF-01

- State: Verified automated input and transition contract
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Reviewer: automated contract; room-by-room human input acceptance remains pending

## Intended result

An active streamed room must retain the normal field controller and click-path
input, then cross a real manifest port collision without losing the declared
safe arrival, room/camera ownership, or input restoration.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_manifest_input_handoff_smoke.tscn',
  'tests/field_input_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_manifest_encounter_smoke.tscn',
  'tests/campaign_encounter_runtime_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=6` and `sentinel=True` in
  `test-artifacts/20260723-122933-f0bbd937`.
- The new HM-01 fixture uses a real D-pad input event, normal click pathing,
  and the production `AreaTransition` collision to arrive at HM-02's declared
  safe cell. It also confirms the active room, camera, and field input are
  restored after the blackout.
- The legacy direct `_on_blackout()` fixture adapter remains covered by the
  Mansion spine test; it does not bypass the production collision path.

## Decision

The manifest input/transition ownership contract is verified. Full
keyboard/mouse and controller traversal of every room, interaction, and state
remains an open release gate.
