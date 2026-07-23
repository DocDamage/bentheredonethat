# WP-POP-BOUNDARY-01 — Population registry and release-source boundary

- State: Implemented
- Milestone: M0 verification green / M2 preproduction
- Base commit: `68f2e6efeab8c9c5f8e0525aff701613bcf1e8af`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewer: product/visual reviewer (user)

## Intended result

Create a stable, runtime-safe canonical registry for every eligible SakPix
identity before new residents are hand-authored, and make the clean-checkout
release gate reject direct references to the ignored Tilesets, EXPANSION, and
SakPix staging roots. This batch does not admit source art, bind runtime
profiles, spawn new residents, or provide visual acceptance.

## Contracts and affected files

- `tools/build_population_registry.py` parses the locked Section 23.12 table,
  verifies rotations when the curator source library is present, and generates
  `game/ben_rpg/population/generated/population_registry.json` without local
  source paths.
- The generated registry has 258 identities, all backed by complete
  eight-direction sources. Incomplete source directories are excluded from the
  plan and registry. All eligible identities have `review_required` provenance
  and no runtime profile until asset admission.
- `tools/validate_release_source_references.py` rejects direct use of
  `assets/Tilesets`, `assets/EXPANSION`, and the SakPix staging root in release
  code/data. Runtime derivatives under `game/game_assets/` remain allowed.

## Automated evidence

- `npm run test:visual-tools`: pass, 23 tests on July 23, 2026.
- Focused clean-checkout and source-backed registry checks both pass; the
  source-backed result contains exactly 258 complete identities and no
  incomplete entries.
- `npm run validate:runtime-assets` currently stops at the stale runtime visual
  inventory created by the wider uncommitted stage/character additions. The
  population-registry check itself passes.
- `npm run validate:source-library` currently stops at curated-catalog coverage:
  232 newly supplied Gandhi animation rasters are not yet catalogued
  (`21,018/21,250` rasters covered). This is a separate asset-admission blocker;
  the 258-identity SakPix source-backed registry generation passes when run
  directly.

## Required follow-up evidence

The stale-inventory and Gandhi-coverage notes above are superseded by the
July 23 milestone rerun: `npm run validate:assets` now passes. The Gandhi source
folder is explicitly quarantined from the curator denominator pending license
evidence, and the generated runtime visual inventory, manifest, provenance
ledger, and profile contact sheet are current.

- Native-resolution visual, keyboard/mouse, controller, and save/reload checks
  are not applicable until an admitted population cohort is wired into an
  authored room.
- No capture paths exist for this data-only batch.
- Performance impact is limited to build-time validation; no runtime actor
  loading was introduced.
- Product/visual reviewer decision: pending. This work package is implemented,
  not accepted.
