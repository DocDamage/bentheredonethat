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
- Added `CampaignAddressRoomCollision` to materialize each of those 84
  record-owned perimeter cells as a native `StaticBody2D` with one 48×48
  `CollisionShape2D`. The AF-01 scene configures this node directly from its
  navigation record; it does not duplicate ports, encounter policy, or story
  state.
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
- After the collision addition, the focused record, AF-01 scene, and content
  validator suite passed at `test-artifacts/20260724-000209-f70f4f05`; the
  refreshed guarded windowed capture passed at
  `test-artifacts/20260724-000225-8e7c246d`. The scene test verifies all 84
  native bodies, their one-shape ownership, and the interior/perimeter cell
  boundary.

## Still gated

- AF-01 is not registered in the campaign graph or address gateway.
- The arrival raid remains a non-runtime contract pending its actor, backdrop,
  balance, and runtime encounter integration, so no stabilized
  encounter/population capture exists yet.
- Input/controller traversal, save/reload, final art composition, and reviewer
  acceptance remain required. The scene-owned perimeter collision foundation
  is present, but it has not yet been exercised by a live streamed player.
