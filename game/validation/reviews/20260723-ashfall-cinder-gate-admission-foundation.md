# Ashfall Cinder Gate admission foundation — 2026-07-23

## Work package

- ID: ashfall-cinder-gate-admission-foundation
- Milestone: mandatory-address asset admission
- State: Implemented; not visually accepted
- Dependencies: the required-address catalog (AF-01) and the existing
  owner-confirmed Tilesets license evidence.

## Delivered scope

- Added a checksum-pinned source decision for the two Ashlands source sheets
  used by the AF-01 Cinder Gate derivatives. The decision remains limited to
  that one address room and retains the recorded optional-attribution evidence.
- Added deterministic builders and metadata records for the 64×104 dead-tree
  crop and the repeatable 16×16 ash-ground cell. Rebuilding verifies each
  source checksum, exact crop rectangle, output checksum, and AF-01 binding.
- The source is classified as DERIVATIVE_SOURCE. Both outputs are now
  prototype-only profiles in the non-streamed AF-01 scene; neither is final
  visually accepted.
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

- AF-01 still needs collision audit, stabilized native capture, population and
  encounter work, address-gateway integration, and reviewer acceptance before
  Ashfall becomes streamable.
