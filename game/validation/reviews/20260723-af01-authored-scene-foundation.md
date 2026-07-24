# AF-01 Cinder Gate authored-scene foundation — 2026-07-23

## Delivered scope

- Added the first AF-01 `.tscn` and its record-backed ground, prop, and
  foreground layers. The scene reads its dimensions, navigation metadata, and
  profile IDs from `CampaignAddressRoomRecords`; it defines no raw asset path,
  graph link, or encounter data of its own.
- Extended the room/layout/navigation record with a full 26×18 ash-terrain
  run, two boundary dead-tree placements, 384 connected walkable cells, 84
  explicit boundary-blocked cells, all three port arrival cells, and three
  follower-safe cells per arrival.
- Added a profile-backed fallback for deterministic derived PNGs that have not
  received Godot import sidecars in an isolated project.
- Produced a guarded windowed first-visit capture at
  `game/validation/af01-cinder-gate-scene-first-visit.png`.

## Verification

- `address_room_records_smoke`, `ashfall_cinder_gate_scene_smoke`, and
  `content_validator_smoke` passed together at
  `test-artifacts/20260723-232414-8c2ba592`.
- The guarded windowed scene capture passed at
  `test-artifacts/20260723-231655-837db32e`.
- The capture was inspected at gameplay scale. It proves profile-backed
  rendering and avoids exterior viewport void; it is not a visual acceptance.

## Still gated

- AF-01 is not registered in the campaign graph or address gateway.
- The arrival raid remains a non-runtime contract pending the combat-database
  refactor, so no stabilized encounter/population capture exists yet.
- Collision shape audit, input/controller traversal, save/reload, balance,
  final art composition, and reviewer acceptance remain required.
