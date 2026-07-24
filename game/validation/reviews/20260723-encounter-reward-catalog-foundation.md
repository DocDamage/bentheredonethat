# Encounter reward catalog foundation — 2026-07-23

## Delivered scope

- Added `CampaignEncounterRewardCatalog` as the active owner of existing
  deterministic boss/trial rewards and per-universe procedural loot tables.
- Preserved `CampaignCombatDatabase.roll_loot()` as the compatibility facade
  used by battle victory, universe treasure, and campaign save code.
- Added validation for 12 fixed-reward encounter IDs, per-drop identity/kind,
  and the corresponding encounter catalog references. The reward smoke checks
  all fixed rewards plus the seven core-universe introductory reward contracts.

## Verification

- `test-artifacts/20260723-235511-5dc5d4d4` passed the eight-scene action,
  bestiary, encounter, reward, address-encounter, content-validator, battle
  UI, and backdrop-profile suite. It reports 84 actions, 38 enemies, 53 core
  encounter contracts, 12 fixed reward contracts, nine runtime-gated Ashfall
  contracts, 24 live backdrop samples, and an unchanged production-save
  sentinel.
- `npm run check` passed: 16 browser tests and 26 visual-tool tests.

## Remaining work

- The inactive pre-extraction encounter/action snapshots remain only as
  temporary characterization baselines and should be removed in a later
  ownership-only cleanup after an explicit parity decision.
- Ashfall remains non-runtime. It still needs admitted actor/backdrop assets,
  a balance/reward pass, a registered gateway/room flow, population, save and
  return behavior, native captures, and reviewer acceptance.
