# M0 validation-contract repair

- Work-package ID: `M0-validation-contracts`
- Milestone/state: M0 — Implemented; remote verification pending
- Commit SHA: `a3078811824aec5438f091ff9d2c92be828a5060` (initial checkpoint);
  follow-up CI configuration commit pending.
- Build version: 0.3.0
- Intended result: CI validates tracked runtime assets from a clean checkout;
  curator workstations validate the ignored source library separately.
- Non-goals: source-license approval, visual acceptance, and remote CI results.

## Changed contracts

- `npm run validate:runtime-assets` checks the tracked runtime manifest,
  inventory, contact sheet, and provenance ledger.
- `npm run validate:source-library` requires the approved local `assets/`
  library, then validates the curated catalog and all 51 NPC definitions.
- `npm run validate:assets` is the local aggregate. GitHub Actions now runs the
  clean-checkout runtime command instead.
- The catalog generator accepts only files in the canonical `assets/` library,
  excluding mirrored runtime copies from catalog discovery.

## Automated evidence

- `npm run check`: pass, 16/16 browser tests.
- `npm run validate:runtime-assets`: pass.
- `npm run validate:source-library`: pass; 21,018/21,018 rasters and 51/51 NPCs.
- `npm run validate:assets`: pending repeat after this checkpoint is committed.

## Native/input/persistence/performance evidence

Not applicable to this validation-only work package. No scene, save fixture, or
native capture changed. The existing isolated smoke and performance gates remain
required for M0 acceptance.

## Review decision

Rework required before acceptance: the first remote run
([29946389799](https://github.com/DocDamage/bentheredonethat/actions/runs/29946389799))
proved that checkout omitted Git LFS runtime images. Preserve that failure, push
the LFS-enabled workflow follow-up, then obtain a clean remote CI run for its
exact SHA. The LFS-enabled retry
([29946979206](https://github.com/DocDamage/bentheredonethat/actions/runs/29946979206))
then proved the generated contact sheet is intentionally absent from a clean
checkout; the runtime gate must rebuild it before validating provenance. Product/
visual reviewer: user.
