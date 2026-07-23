# M1-ROOM-GRAPH-REPORT-01

- State: Verified automated graph contract
- Milestone: M1 — shared manifest room platform
- Implementer: Codex
- Reviewer: automated contract; full capture and gameplay review remain product-owned

## Intended result

Generate a data-only report for the seven authored universe graphs without
instantiating rooms. For fresh, mid-puzzle, stabilized, and postgame states it
must expose room nodes, active and blocked gates, reciprocal edges, reachable
and unreachable rooms, save points, and facility-return edges.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_room_graph_report_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_manifest_transition_installer_smoke.tscn',
  'tests/campaign_manifest_save_context_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn'
) -TimeoutSeconds 420
```

- Passed with `ISOLATED_RUN_OK scenes=5` and `sentinel=True` in
  `test-artifacts/20260723-115042-459a122e`.
- The graph report contains 102 nodes across seven core worlds for all four
  named story states.
- The fixture verifies that `HM-02.E1` is blocked in fresh state, becomes
  active when the 4:44 flag is present, the stabilized Mansion has no
  unreachable rooms, save records remain discoverable, and `FI-05` remains an
  explicit facility-return edge.

## Decision

The manifest graph data and gate reporting are verified. This does not replace
visual captures, controller traversal, or manual story-state acceptance for
every room.
