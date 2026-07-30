# Phase 7 — content lock and release candidate

- State: implemented; automated verification complete; human acceptance open
- Date: July 30, 2026
- Release channel: unsigned Windows x86_64 direct-download candidate
- Product metadata: Ben There, Done That / DocDamage / 1.0.0

## Locked scope and automation

`ben_rpg/release/release_contract.json` is the machine-readable release
contract. `phase7_content_lock_release_candidate_smoke` verifies 192 locations
(102 core and 90 annex), the 121 facility combinations, 258 population
identities, 384 required captures, six address campaigns, two fresh campaign
simulations, one migrated campaign simulation, defeat/retry, recall, partial
puzzle reload, backup recovery, ending, and postgame free roam.

The final native capture run is
`test-artifacts/20260730-074836-55155ecf`. It produced 384 PNGs (fresh and
stabilized for every one of the 192 room IDs) plus a JSON manifest with state,
resolution, input-review status, and capture tag. The runner rebuilds the live
runtime at universe boundaries so pathfinder and population state cannot bleed
between worlds. Representative captures from every renderer family were
visually inspected during implementation. The resulting renderer pass replaces
raw sprite-sheet draws and broad placeholder fields with bounded architecture,
paths, material variation, landmarks, props, framing, and dark out-of-bounds
surrounds across Mansion/Rain Gate, Asterion, Primeval, Helios, Moonpetal,
Franklin Laboratory, Frosthold, and Empyreal scenes.

## Verification evidence

- Fast checks: 31 Python/Node tests pass.
- Runtime asset gate: passes, including deterministic release provenance for
  362 non-raster assets (audio, fonts, Dialogic addon runtime, shaders, dynamic
  resources, and notices).
- Source library: 21,711/21,711 curated rasters pass; 51/51 NPC visuals are
  editor-ready; population registry contains exactly 258 eligible identities.
- Godot resources: 847 resources load (457 scripts, 257 scenes, 108 serialized
  resources, and 25 dialogue resources).
- Godot suite: the host limit split 166 sorted smoke scenes into 83-scene
  artifacts `test-artifacts/20260730-072419-0fb844dd` and
  `test-artifacts/20260730-073939-37d81cf6`. Review found one Helios stable-node
  naming regression in the first batch; it was fixed and the failed scene,
  Helios layout, resource load, and Phase 7 contract all pass in
  `test-artifacts/20260730-074810-0135af1e` with `sentinel=True`.
- Performance diagnostic: `test-artifacts/20260730-070736-70550c33` on the
  i5-14600K/RTX 3060 workstation reports 16.569 ms mean, 17.634 ms p95, and
  22.281 ms p99 overall; 325,025,158 bytes peak static memory; 3.574 ms save;
  8.353 ms load; and sub-51 ms sampled area activation. The strict 16.7 ms p95
  target and 5,000 ms startup target are narrowly missed (17.634 ms and
  5,070.329 ms), so performance acceptance remains open.
- Unsigned local Windows export: 370,127,064 bytes, SHA-256
  `41D38B3F21DB5C9633217176A557589FBB88CA8DA6076831BBCB11A7172236FA`;
  version/publisher metadata are 1.0.0/DocDamage and the executable launched
  headlessly for 30 frames. The build script now validates stdout and stderr,
  supports required Authenticode signing, and writes a release manifest.

## Open acceptance gates

Phase 7 must not be labeled accepted or publicly shippable until all of these
are recorded for the exact release commit:

1. Human keyboard/mouse and modern-controller playthroughs at every supported
   resolution, including accessibility and color/sound-independent cue review.
2. Two human fresh-save end-to-end runs and one human migrated-save run.
3. Minimum-hardware campaign-duration, frame-pacing, save/load, and memory
   measurement plus a multi-hour shutdown-warning soak.
4. Product-owner visual approval of the complete native capture matrix.
5. Successful clean GitHub export/launch artifact for the pushed commit.
6. Timestamped Authenticode signing and signature verification for the public
   executable using the release certificate.
