# M4-MANIFEST-COMPAT-01 — Later-universe manifest compatibility fixtures

- State: Verified automated contract; visual/product acceptance pending
- Milestone: M4 — Asterion through Empyreal manifest-room compatibility
- Commit SHA: `9703b52614dab76345fae0bb53999db8d6fe56ee`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Intended result

Keep the later-universe gameplay smoke coverage meaningful after internal
transitions, interactive props, treasure caches, and navigation become
room-scoped. This fixture migration does not grant visual, licensing,
controller, performance, or product approval.

## Contract and scope

- Six layout fixtures activate every authored room in the Asterion, Primeval,
  Helios, Frosthold, Moonpetal, and Empyreal registries. They require the
  seven room layers, declared visual profiles, a navigable population anchor in
  the manifest navigation record, and state-gated reciprocal ports where the
  manifest declares one.
- Helios, Frosthold, Moonpetal, and Empyreal scenario fixtures retain their
  battle, recruit, crafting, boss-loot, and save-metadata coverage while
  resolving every room feature through the active streamer's `InteractionLayer`.
- The five late-universe treasure caches install only in their designated
  active room and retain controller/mouse affordances, randomized loot,
  duplicate prevention, and save/reload state.
- The Bulkhead Warden fixture checks its authored manifest-relative Asterion
  anchor instead of the retired global map coordinate.
- Non-goal: migrating the legacy encounter-controller coordinate regions or
  global recruit compatibility nodes. Those production ownership moves still
  require their own room-runtime conversion, native traversal evidence, and
  acceptance review.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/asterion_layout_smoke.tscn',
  'tests/primeval_layout_smoke.tscn',
  'tests/helios_layout_smoke.tscn',
  'tests/frosthold_layout_smoke.tscn',
  'tests/moonpetal_layout_smoke.tscn',
  'tests/empyreal_layout_smoke.tscn',
  'tests/universe_treasure_smoke.tscn',
  'tests/bulkhead_warden_recruit_smoke.tscn',
  'tests/asterion_scenario_smoke.tscn',
  'tests/primeval_scenario_smoke.tscn',
  'tests/helios_scenario_smoke.tscn',
  'tests/frosthold_scenario_smoke.tscn',
  'tests/moonpetal_scenario_smoke.tscn',
  'tests/empyreal_scenario_smoke.tscn'
) -TimeoutSeconds 480
```

- Result: 14/14 passed.
- Artifact root: `test-artifacts/20260723-071930-76abb6a3`.
- Production-save sentinel: unchanged (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remained present;
  this focused batch neither attributes nor accepts that release-level issue.

## Required follow-up evidence

- Native 960x540 captures of each later-universe room at first visit and
  stabilized state, plus keyboard/mouse and controller traversal of every port
  and feature.
- Save/reload verification from all registered later-universe save points in a
  user-visible playthrough.
- Collision/useful-cell audits and final per-source visual/provenance approval.
- Room-owned encounter-controller and recruit ownership migration, before the
  legacy global compatibility fixtures can be retired.
