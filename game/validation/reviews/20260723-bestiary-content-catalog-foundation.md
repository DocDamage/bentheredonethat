# Bestiary content catalog foundation — 2026-07-23

## Delivered scope

- Added `CampaignBestiaryCatalog` as the active authority for all 38 current
  core-enemy definitions: stats, rewards, actions, element/status rates,
  approved battle profile IDs, and authored animation metadata.
- Preserved `CampaignCombatDatabase.enemy_actor()` as the compatibility and
  runtime-construction boundary. It resolves the catalog's approved visual
  profile and builds the existing battle actor shape unchanged.
- Added catalog validation, order/catalog completeness validation, and an
  isolated bestiary smoke scene that checks every generated runtime actor
  against its content record.

## Verification

- `test-artifacts/20260723-234810-9413c0e4` passed action, bestiary, encounter,
  address-encounter, content-validator, battle-UI, and backdrop-profile smoke
  scenes. It reports 84 actions, 38 enemies, 53 core encounter contracts,
  nine runtime-gated Ashfall contracts, 24 live backdrop samples, and an
  unchanged production-save sentinel.
- `npm run check` passed: 16 browser tests and 26 visual-tool tests.

## Remaining work

- Encounter reward/loot content now has a separate active catalog and evidence
  record; the remaining work is address-specific balance/reward admission.
- No Ashfall enemy, backdrop, balance/reward record, or runtime room is
  admitted by this work; all address encounters remain disabled.
