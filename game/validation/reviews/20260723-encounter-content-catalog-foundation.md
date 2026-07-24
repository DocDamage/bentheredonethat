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

- `encounter_catalog_smoke`, `content_validator_smoke`, and
  `campaign_battle_ui_smoke` completed successfully in the isolated run at
  `test-artifacts/20260723-232925-2bb723a8`.
- `battle_backdrop_profile_smoke` was launched in that same run but remained
  active beyond the runner window without emitting a pass or failure line. Its
  retained log is diagnostic evidence only and does not count as a pass.

## Remaining work

- Remove the retained in-file pre-extraction snapshot once its parity baseline
  is no longer needed for the staged refactor.
- Extract battle reward content and validate the first address encounter with
  a real enemy definition, balance pass, and return/save behavior.
- Ashfall remains non-runtime until those combat and gateway gates close.
