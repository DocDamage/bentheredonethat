# WP-POP-BOUNDARY-01 — Population registry and release-source boundary

- State: Implemented
- Milestone: M0 verification green / M2 preproduction
- Base commit: `68f2e6efeab8c9c5f8e0525aff701613bcf1e8af`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewer: product/visual reviewer (user)

## Intended result

Create a stable, runtime-safe canonical registry for every SakPix source
identity before new residents are hand-authored, and make the clean-checkout
release gate reject direct references to the ignored Tilesets, EXPANSION, and
SakPix staging roots. This batch does not admit source art, bind runtime
profiles, spawn new residents, or provide visual acceptance.

## Contracts and affected files

- `tools/build_population_registry.py` parses the locked Section 23.12 table,
  verifies rotations when the curator source library is present, and generates
  `game/ben_rpg/population/generated/population_registry.json` without local
  source paths.
- The generated registry has 267 identities: 258 complete eight-direction
  sources and 9 quarantined incomplete sources. All have `review_required`
  provenance and no runtime profile until asset admission.
- `tools/validate_release_source_references.py` rejects direct use of
  `assets/Tilesets`, `assets/EXPANSION`, and the SakPix staging root in release
  code/data. Runtime derivatives under `game/game_assets/` remain allowed.

## Automated evidence

- `npm run test:visual-tools`: pass, 11 tests.
- `npm run validate:runtime-assets`: pass.
- `npm run validate:source-library`: pass; 21,018 catalogued rasters, 51/51
  NPC visuals editor-ready, and the verified 267-identity registry generated.

## Required follow-up evidence

- Native-resolution visual, keyboard/mouse, controller, and save/reload checks
  are not applicable until an admitted population cohort is wired into an
  authored room.
- No capture paths exist for this data-only batch.
- Performance impact is limited to build-time validation; no runtime actor
  loading was introduced.
- Product/visual reviewer decision: pending. This work package is implemented,
  not accepted.
