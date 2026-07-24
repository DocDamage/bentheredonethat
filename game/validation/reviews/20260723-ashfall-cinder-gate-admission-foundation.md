# Ashfall Cinder Gate admission foundation — 2026-07-23

## Work package

- ID: ashfall-cinder-gate-admission-foundation
- Milestone: mandatory-address asset admission
- State: Implemented; not visually accepted
- Dependencies: the required-address catalog (AF-01) and the existing
  owner-confirmed Tilesets license evidence.

## Delivered scope

- Added one checksum-pinned source decision for the Ashlands sheet
  tf_B_ashlands_1.png. The decision is limited to the AF-01 Cinder Gate
  derivative and retains the recorded optional-attribution evidence.
- Added a deterministic builder and metadata record for the 64×104 dead-tree
  crop. Rebuilding verifies the source checksum, exact crop rectangle, output
  checksum, and the AF-01 binding.
- The source is classified as DERIVATIVE_SOURCE; the output remains an
  admission foundation and has no profile, streamed scene, or runtime
  reference yet.
- Narrowed the release-source-root validator so only derivative provenance
  metadata may record a local source-library path. Runtime scenes, scripts, and
  other JSON records remain prohibited from pointing at staging roots.

## Verification

- python tools/build_ashfall_cinder_gate_derivative.py --check passed.
- npm run check passed: 16 browser tests and 25 visual-tool tests.
- npm run validate:runtime-assets passed, including the visual inventory,
  provenance ledger, manifest, contact sheet, population registry, and
  release-source-root boundary.

## Required follow-through

- AF-01 still needs its full room/layout/navigation records, authored scene,
  native first-visit and stabilized captures, population and encounter work,
  and reviewer acceptance before this derivative can receive a runtime visual
  profile or make Ashfall streamable.
