# Manifest streaming runtime evidence

- State: Automated runtime evidence verified; release acceptance pending
- Milestone: Manifest-wide active-room streaming characterization
- Commit status: prepared before commit
- Build version: Godot project `0.3.0`
- Implementer: Codex

## Scope

`tests/campaign_manifest_streaming_smoke.tscn` activates every one of the 102
authored manifest rooms through `CampaignRoomRuntime`. For each activation it
checks that runtime and streamer identity agree, the active root belongs to the
streamer and carries the requested room ID, the streamer has exactly one child,
and the prior root has been freed.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene \
  'tests/campaign_manifest_streaming_smoke.tscn', \
  'tests/campaign_room_characterization_smoke.tscn', \
  'tests/campaign_navigation_characterization_smoke.tscn' \
  -TimeoutSeconds 180 -KeepArtifacts
```

- Artifact root: `test-artifacts/20260723-161852-7f987ee7`.
- Streaming result: 102 room activations, exactly one active root, and 101
  released prior roots; the complete graph was not retained in the streamer.
- Companion characterization confirmed 264 transitions, 36 interactions, six
  bosses, eight save points, five treasures, 36 gates, six visible-floor cells,
  15 blocked-scenery cells, all 11 facility footprints, and 264 follower-safe
  live arrivals.
- The isolated runner preserved the production-save sentinel. The known
  shutdown-only 61 ObjectDB / 26 resource warnings are not release evidence.

## Remaining gates

This proves the single-active-root replacement boundary only. It does not prove
approved vista-neighbor policy, population cohort scheduling, memory/performance
budgets, full controller traversal, room-by-room visual acceptance, licensing,
product review, or release acceptance.
