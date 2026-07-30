# Encounter content catalog foundation — 2026-07-23

## Delivered scope

- Added `CampaignEncounterCatalog` as the active source of the 53 existing
  core-universe encounter contracts: stable IDs, display names, formations,
  backdrop profile IDs, scripted/boss policy, and the Mansion clock boss phase
  policy.
- Retained `CampaignCombatDatabase.encounter*` as a compatibility facade for
  current battle, room, reward, and save callers. The facade now delegates to
  the catalog, while actor construction, actions, rewards, and presentation
  remain out of scope for this extraction.
- Extended the content validator with direct catalog validation and a per-ID
  facade-parity check.

## Verification

- The complete catalog, content-validator, battle-UI, and backdrop suite
  passed together at `test-artifacts/20260723-233417-f68a80d9`: 53 contracts
  and 24 live backdrop samples. The backdrop fixture instantiates only the
  battle scene, avoiding unrelated main-scene startup.

## Remaining work

- Remove the retained in-file pre-extraction snapshot once its parity baseline
  is no longer needed for the staged refactor.
- Extract battle reward content and validate the first address encounter with
  a real enemy definition, balance pass, and return/save behavior.
- Ashfall remains non-runtime until those combat and gateway gates close.
