# AF-01 Cinder Gate room-record foundation — 2026-07-23

## Delivered scope

- Added the first equivalent Section 23.14 room/layout/navigation record for
  AF-01 Cinder Gate.
- Locked the L2 26×18 dimensions, all three port safe-arrival cells, 384
  walkable interior cells, interaction beacon, filter treasure, survivor-watch
  anchors, foreground cells, and the admitted dead-tree derivative reference.
- The record is runtime-gated: it names no scene and does not claim that
  Ashfall is streamable, visually accepted, or combat-ready.

## Verification

- address_room_records_smoke passed at
  test-artifacts/20260723-225356-e1e9b3a9.
- content_validator_smoke passed at
  test-artifacts/20260723-225409-26ce1e30.

## Required follow-through

- Add a profile-backed scene, collision/foreground audit, address gateway,
  Cinder Gate battle definition and balance pass, then capture first-visit and
  stabilized native views before allowing AF-01 into runtime streaming.
