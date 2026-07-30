# Battle lifecycle and address-encounter foundation — 2026-07-23

## Delivered scope

- Introduced CampaignBattleLifecycle as the non-UI owner for encounter
  sightings, victory reward application, autosave, retry, and return-to-town
  state transitions. CampaignBattle retains only its presentation, input, and
  orchestration responsibilities.
- Added CampaignAddressEncounterCatalog. Its first contract is the mandatory
  AF-01 Cinder Gate arrival raid, bound by stable ID through the required
  address catalog and the global content validator. The catalog now covers all
  nine Ashfall rooms whose Section 23.5 policy is zone, scripted-only, or boss;
  the three explicitly encounter-free rooms have no contract.
- The address contract is explicitly non-runtime and marked
  blocked_pending_combat_database_refactor. It has no live enemy actor,
  backdrop, balance, or routing claim.

## Verification

- address_encounter_catalog_smoke passed at
  test-artifacts/20260723-224653-e9da885f.
- required_address_catalog_smoke passed at
  test-artifacts/20260723-224703-241d2dad.
- content_validator_smoke passed at
  test-artifacts/20260723-224713-745a7054.
- encounter_autosave_smoke passed at
  test-artifacts/20260723-224824-efde0a46.
- campaign_battle_ui_smoke passed at
  test-artifacts/20260723-224851-0ea5d5b8.
- The expanded nine-contract address catalog passed at
  test-artifacts/20260723-225158-5f756964; content validation passed again at
  test-artifacts/20260723-225207-1352224b.

## Remaining refactor work

- The legacy combat database still owns existing core-universe encounter and
  loot definitions. Those definitions and the address balance pass must move to
  validated content records before AF-01 can receive a live battle definition.
