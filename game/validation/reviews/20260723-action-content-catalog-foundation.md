# Action content catalog foundation — 2026-07-23

## Delivered scope

- Added `CampaignActionCatalog` as the active content authority for all 84
  current combat actions, including stable IDs, targeting, effect shape, item
  requirements, and display metadata.
- Preserved `CampaignCombatDatabase.action()` and `action_ids()` as the public
  compatibility facade used by the menu, ATB model, battle presentation,
  content validator, recruits, and balance harness.
- Added direct catalog validation, per-ID facade parity validation, and an
  isolated action-catalog smoke scene. The old in-file literal is retained as
  a non-active characterization snapshot for the staged ownership migration.

## Verification

- `test-artifacts/20260723-234403-69de5079` passed the action catalog,
  encounter catalog, address encounter catalog, content validator, battle UI,
  and backdrop-profile smoke scenes. It reports 84 actions, 53 core encounter
  contracts, 9 runtime-gated Ashfall contracts, 24 live backdrop samples, and
  an unchanged production-save sentinel.
- `npm run check` passed: 16 browser tests and 26 visual-tool tests.

## Remaining work

- The bestiary and reward extraction follow-up is recorded separately in the
  matching 20260723 evidence records; no address enemy or action is admitted
  by this change.
- Remove the retained action and encounter snapshots only after their staged
  parity baselines are no longer required.
- Ashfall stays non-runtime until actor/backdrop admission, balancing,
  room/gateway ownership, save/return behavior, and reviewer evidence exist.
