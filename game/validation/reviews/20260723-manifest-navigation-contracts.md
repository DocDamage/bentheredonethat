# M1-NAV-CONTRACT-02 — Manifest navigation baseline

- State: Verified automated contract; collision/art acceptance pending
- Milestone: M1 — Shared manifest room platform
- Commit SHA: `f55b0fcd4e37e0558a3d66378ddf97b21f0b344f`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); collision/navigation reviewer (unassigned)

## Intended result

Make the shared navigation validator cover every manifest room rather than only
the synthetic test room. This establishes a data-contract floor for migration;
it does not claim that the generated rectangular walkability or collision masks
are final authored geometry.

## Contract and scope

- Every one of the 102 core room records must expose a navigation ID,
  collision-mask ID, nonempty navigation record, walkable population anchors,
  safe arrivals, three adjacent follower cells at each arrival, and one
  connected required-anchor component.
- The manifest room smoke retains a direct assertion for follower-safe arrival
  space and connection in `TEST-01`.
- Non-goal: approving collision against final visible architecture, declaring
  generated open interiors as useful-cell totals, or replacing per-room
  tile-by-tile layout and nav records.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_manifest_room_smoke.tscn',
  'tests/campaign_manifest_transition_installer_smoke.tscn',
  'tests/campaign_hm01_authored_room_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn'
) -TimeoutSeconds 360
```

- Result: 5/5 passed.
- Artifact root: `test-artifacts/20260723-073449-be3687ac`.
- Production-save sentinel: unchanged (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remained present
  and is not accepted by this work package.

## Required follow-up evidence

- Per-room `.layout.json` and `.nav.json` records with terrain, architecture,
  blocked cells, safe arrivals, NPC routes, connected components, and useful
  cell totals.
- Native-scale collision and traversal captures, keyboard/mouse/controller
  evidence, and save/reload fixtures for each accepted room.
