# Phase 6 — Population, progression, and side content verification

- State: Verified automated; human acceptance pending
- Exact implementation commit: `a9be2e6f`
- Engine: Godot 4.7.1 stable
- Scope: 258 SakPix identities, core/named character arcs, campaign
  progression systems, optional content, rare events, and postgame reactions

## Implemented result

All 258 eligible identities now bind one-to-one to checksum-backed runtime
profiles in a tracked 6.1 MB field atlas. Every profile contains all eight
approved rotations, retains its canonical source identity, and realizes through
the room-owned population actor. The production scheduler selects canonical
home, story phase, and bounded cohort records from the generated registry,
limits each room cohort to six, reserves ports/safe arrivals/gameplay features,
and relocates an anchor within a bounded room-safe radius when authored content
occupies its planned cell.

Core and annex room contracts expose the complete P1-P6 reservation surface
needed by the locked population plan. Every identity was instantiated at its
canonical home and rotated through all eight directions by the Phase 6 gate.
Lincoln and Gandhi field scenes no longer enter the obsolete optional Rift
Exhibition recruitment path; both use mandatory-protagonist dialogue through
the main campaign and postgame.

The existing facility jobs, inventions, equipment/skills, economy receipts,
bestiary, quests, recruit progression, ending, and rewardless Tribunal rematch
remain integrated. The campaign balance harness now names explicit
`minimum_job` and `offline_heavy` profiles in addition to low-, median-, and
high-combat routes. Rare-event rewards use save-backed one-shot flags and
economy receipts, and authored postgame reactions cover the protagonist trio
and rotating resident population.

## Automated evidence

- `npm run check`: 16 JavaScript tests and 28 visual/tool tests passed.
- `npm run validate:runtime-assets`: the population atlas/checksum contract,
  population registry, visual inventory/manifest/provenance, derivatives,
  contact sheet, and release-source quarantine all passed.
- Focused Phase 6 gate passed at
  `test-artifacts/20260730-060927-723eaf62`; it verifies 258 unique homes and
  profiles, eight directions per identity, conflict-free scheduling, the
  six-resident cohort ceiling, protagonist/named arcs, jobs/inventions/skills/
  bestiary integration, 200 deterministic route simulations, idempotent rare
  rewards, save/reload, rematches, and postgame reactions.
- Eleven-scene touched-system regression passed at
  `test-artifacts/20260730-061031-1e0f82b0`, covering population scheduling and
  actor creation, Phase 4 rooms, ending/rematch, balance, offline jobs,
  inventions, economy, quests, and bestiary persistence.
- Full isolated Godot suite: 165/165 discovered smoke scenes passed at
  `test-artifacts/20260730-061123-983d2df9`; all 165 logs contain success
  markers and the production-save sentinel was unchanged.
- `git diff --check` and the staged diff check passed before the implementation
  commit.

## Review corrections included

- Replaced the zero-profile population registry with unique eight-direction
  runtime bindings for all 258 eligible identities.
- Expanded final room reservations to honor P1-P6 assignments and added bounded
  collision recovery for plan anchors occupied by ports, saves, encounters,
  puzzles, treasures, or other authored features.
- Removed Lincoln and Gandhi from the optional recruit-trial interaction and
  gave both mandatory-protagonist field and postgame reactions.

## Gates that cannot be self-certified

Phase 6 implementation and automated verification are complete. Per the
project acceptance policy, the phase remains `Verified`, not `Accepted`, until
a human records keyboard/controller resident interaction review, native-scale
population visual review, campaign balance/accessibility review, minimum-
hardware population performance, and product-owner approval.
