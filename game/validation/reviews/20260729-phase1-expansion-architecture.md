# Phase 1 expansion architecture verification

- Phase/work package: Phase 1 — Expansion architecture
- State: Verified; implementation exit gate complete
- Exact implementation commit: `f3ec2199`
- Godot: `4.7.1.stable.official.a13da4feb`
- Full isolated artifact: `test-artifacts/20260729-231133-765e94b6`
- Focused architecture artifact: `test-artifacts/20260729-231055-0f871649`
- Focused population/streaming artifact: `test-artifacts/20260729-230950-2097f6ee`

## Closed boundary

The generated 258-identity registry and reservation scheduler now terminate in
a dedicated actor factory. The factory realizes only admitted, field-scale
profile assignments and makes each actor a child of the active room's
`PopulationCohort`, so streamer replacement releases the cohort and actors
together. Incomplete and unadmitted assignments remain unavailable rather than
silently receiving placeholder art.

The Phase 1 architecture fixture locks the required registry, streamer,
transition, camera, navigation, feature, encounter, population scheduler, and
actor-factory components. It also rejects expansion room IDs entering
`campaign_bootstrap.gd` or the frozen `campaign_map_visual.gd`, and proves that
the manifest-only room has no branch in either legacy file.

## Verification

- `npm run check`: passed (16 JavaScript tests; 26 visual-tool tests).
- `npm run validate:runtime-assets`: passed, including the 258-identity
  generated population registry and release source-reference boundary.
- All 160 discovered `*_smoke.tscn` scenes passed in one isolated run.
- Full-run logs contain zero `_FAILED`, parser-error, script-error, or assertion
  markers; the production-save sentinel was unchanged.
- Manifest proof covers one active root, 101 replacements across 102 core
  rooms, reciprocal transitions, safe arrivals, camera bounds, navigation,
  feature installation, encounter ownership, controller arrival movement,
  population reservation/admission, and save/migration parity.

Godot's known shutdown-only ObjectDB/resource warnings remain visible in the
logs and unchanged from the recorded baseline; no runtime fixture failed on
them. Phase 2 room-by-room visual, balance, performance, and product acceptance
remain separate gates and are not claimed here.
