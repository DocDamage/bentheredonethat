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
- Added a checksum-pinned `ashfall_cinder_gate_barricade` derivative from the
  already admitted Ashlands sheet. The new 96×48 source crop is rendered at
  288×144 world pixels as AF-01's central Cinder Gate landmark; its explicit
  6×3-cell footprint adds 18 native collision bodies and leaves a connected
  366-cell interior route. The profile remains `prototype_only` pending visual
  review.
- Corrected each bound AF-01 arrival to the locked two-cell-inward blueprint
  location and recorded its exact follower formation: `Nw` `(8,3)`, `E1`
  `(22,6)`, and `Sw` `(8,14)`. The room-record validator now derives each
  safe cell, three-cell opening, and follower positions from the L2 blueprint
  rather than accepting merely walkable coordinates.
- Added the runtime-gated AF-01 survivor-watch population contract. It binds
  Scrap Kid at `P1` and Dust Hunter at `P2` to their complete, canonical AF-01
  registry identities after the arrival raid, while recording Iron Sentinel as
  an AF-05-canonical visitor at `P3` only after the bunker defense clears.
  Their runtime profiles and actor scenes remain unadmitted, so this is roster
  ownership rather than a claim that residents are visible in the scene.
- Added supplied Wasteland-survivor-kit derivatives for the exact `Icenter`
  air-quality beacon and `Tnw` air-filter cache. Their record-owned props and
  inert scene markers use the locked `(13,9)` and `(4,4)` cells respectively;
  they deliberately do not yet execute gameplay or grant loot outside the
  unavailable address runtime.
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
- The landmark composition, 102 record-owned native collision bodies (84
  perimeter plus 18 barricade), and profile-backed barricade texture passed at
  `test-artifacts/20260724-001632-8718bee8`; its refreshed guarded windowed
  capture passed at `test-artifacts/20260724-001646-60c70f07`.
- The AF-01 population catalog, room-record linkage, collision scene, existing
  population scheduler, and aggregate content validator passed together at
  `test-artifacts/20260724-002633-c3326e6d`. This proves roster ownership and
  deliberate runtime gating; it does not admit field actors.
- The complete AF-01 feature visual milestone passed at
  `test-artifacts/20260724-003920-17207ad2`: record, scene, population, and
  aggregate-content checks passed alongside a guarded windowed capture. The
  refreshed capture is a prototype visual check, not final acceptance.

## Still gated

- AF-01 is not registered in the campaign graph or address gateway.
- The arrival raid remains a non-runtime contract pending its actor, backdrop,
  balance, and runtime encounter integration; the survivor watch also awaits
  field-profile/actor admission. The beacon and cache markers are scene-owned
  but intentionally inert until the address runtime exists. No stabilized
  encounter/population capture exists yet.
- Input/controller traversal, save/reload, final art composition, and reviewer
  acceptance remain required. The scene-owned perimeter collision foundation
  and landmark footprint are present, but they have not yet been exercised by
  a live streamed player.
