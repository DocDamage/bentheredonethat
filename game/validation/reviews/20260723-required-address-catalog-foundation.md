# Required-address catalog foundation — 2026-07-23

## Delivered scope

- Encoded the locked Section 23.5-23.10 matrix for all six mandatory address
  chapters: Ashfall, Pelagic, Steamforge, Frontier, Warfront, and Liminal.
- The catalog contains all 64 required rooms, their exact section blueprint,
  `C`/`O`/`X` budget, named port bindings, chapter lead, resolution flag, and
  one-time completion reward.
- Added missing `H1` blueprint geometry to the shared manifest matrix.
- Address data is explicitly `runtimeEnabled = false`. It is validated by the
  normal content validator but cannot stream before per-address source
  admission, authored room scenes, collision/navigation, and population work.

## Verification

- `required_address_catalog_smoke` passed at
  `test-artifacts/20260723-222630-71b94477`, proving six address definitions,
  the 64-room total, class budgets, legal blueprint ports, and runtime gating.
- `campaign_world_catalog_smoke` passed at
  `test-artifacts/20260723-222643-37c173d5`.
- `content_validator_smoke` passed at
  `test-artifacts/20260723-222713-fb2f3b93`; the address validator is included
  in the normal startup validator.
- `npm run check` passed. The runtime inventory was regenerated, and all
  runtime-asset subchecks (inventory, provenance, manifest, contact sheet,
  population registry, facade, and release source references) passed.
