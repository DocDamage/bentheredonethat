# M4-AS-PV-CONTRACT-01 — Asterion and Primeval authored-room contracts

- State: Implemented contracts; acceptance blocked by preproduction gates
- Milestone: M4 — Universe migration
- Base commit: `5ff1aae9`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Intended result

Preserve the locked `AS-01`–`AS-14` and `PV-01`–`PV-14` graph contracts while
the complete art-admission, provenance, contact-sheet, and population work
packages are completed. These scenes must stay manifest-owned and may not add
new bootstrap geometry or raw source-library paths.

## Data contract

- Stable room ID, blueprint/dimensions, reciprocal ports, gate predicates,
  encounter policy, anchors, feature IDs, and profile IDs are supplied by
  `CampaignRoomRegistry`.
- Asterion medical (`AS-04`) and Primeval relay nest (`PV-07`) own their
  save-point interactions and register their stable save IDs while streamed.
- Active room runtime owns navigation and port installation; the facility
  portal is the only town-facing transition supplied by bootstrap.
- Non-goals: bulk runtime admission of ignored Tilesets/EXPANSION/SakPix
  source libraries, final art approval, roster activation, and release status.

## Production work-package matrix

This record fulfills the documentation portion of the Section 19 batch for the
two next migration worlds. The registry, rather than this table, remains the
executable authority for exact port IDs, gates, scenes, interactions, profile
IDs, and reciprocal arrivals.

- User-visible result: Asterion retains its dock-to-control route and Primeval
  retains its grove-to-caldera route while optional loops remain bidirectional.
- Migration anchors: `FI-06 -> AS-01` and `FI-07 -> PV-01`; streamed save IDs
  are `asterion_medical` (`AS-04`) and `primeval_relay` (`PV-07`).
- Traversal targets: not yet specified or measured. This is intentionally a
  preproduction blocker, not an assumed target.
- Provisional performance budget for both worlds: 960x540 logical canvas, 60
  FPS target, p95 <=16.7 ms, p99 <=33.3 ms, <=2 s room transition, <=1 GB peak
  memory. No declared minimum machine or measurements exist.

| World / room | Locked blueprint | Current generated navigation cells | Anchors | Executable destinations |
| --- | --- | ---: | ---: | --- |
| AS-01 | L1 | 352 | 6 | FI-06, AS-02, AS-14 |
| AS-02 | M2 | 216 | 4 | AS-01, AS-03, AS-09 |
| AS-03 | M3 | 240 | 4 | AS-02, AS-12, AS-13 |
| AS-04 | M4 | 224 | 4 | AS-13, AS-12 |
| AS-05 | M1 | 192 | 4 | AS-13, AS-06, AS-10 |
| AS-06 | L2 | 384 | 6 | AS-05, AS-07 |
| AS-07 | M3 | 240 | 4 | AS-06, AS-08, AS-10, AS-13, AS-14 |
| AS-08 | L4 | 396 | 6 | AS-07, AS-11 |
| AS-09 | M1 | 192 | 4 | AS-02 |
| AS-10 | L2 | 384 | 6 | AS-05, AS-07 |
| AS-11 | M3 | 240 | 4 | AS-13, AS-08 |
| AS-12 | M4 | 224 | 4 | AS-03, AS-04 |
| AS-13 | M1 | 192 | 4 | AS-03, AS-04, AS-05, AS-07, AS-11 |
| AS-14 | S2 | 112 | 2 | AS-01, AS-07 |
| PV-01 | L1 | 352 | 6 | FI-07, PV-02, PV-13 |
| PV-02 | M2 | 216 | 4 | PV-01, PV-03, PV-13 |
| PV-03 | L3 | 416 | 6 | PV-02, PV-04, PV-07, PV-10, PV-14 |
| PV-04 | M4 | 224 | 4 | PV-03, PV-05, PV-11 |
| PV-05 | L1 | 352 | 6 | PV-04, PV-06, PV-09, PV-13 |
| PV-06 | M2 | 216 | 4 | PV-05 |
| PV-07 | L3 | 416 | 6 | PV-03, PV-08, PV-11, PV-14 |
| PV-08 | L4 | 396 | 6 | PV-07, PV-12, PV-14 |
| PV-09 | M1 | 192 | 4 | PV-05, PV-13 |
| PV-10 | L2 | 384 | 6 | PV-03 |
| PV-11 | M3 | 240 | 4 | PV-04, PV-07 |
| PV-12 | L4 | 396 | 6 | PV-08 |
| PV-13 | M1 | 192 | 4 | PV-01, PV-02, PV-05, PV-09 |
| PV-14 | S2 | 112 | 2 | PV-03, PV-07, PV-08 |

The generated counts are not final useful-walkable-cell totals: the manifest
navigation builder currently supplies an open interior rectangle. Each row
needs final authored collision, walkable-cell, safe-arrival, and foreground
audits before it can claim the Section 9.4 size class.

The first Asterion collision-audit batch now replaces those generated interiors
with authored docking/cargo/medical layouts: `AS-01` 247 closed / 248 restored,
`AS-02` 150, `AS-03` 169, and `AS-04` 148 closed / 149 post-ambush useful cells.
Their navigation and collision IDs
are scene-owned manifest records; every remaining Asterion row remains a
generated baseline until its own audit lands.

### Art, population, and state-capture requirements

- The current `visualProfileIds` arrays in `CampaignRoomRegistry` are the only
  runtime profile list. They do not admit the locked Space Station/Jurassic
  source families or their supporting packs.
- `pack_provenance_decisions.json` binds the named Asterion and Primeval Tilesets
  packs to the checksum-pinned root `assets/Tilesets/license.txt` evidence and
  its optional-credit statement. All decisions remain `review_required` pending
  final derivative admission and licensing review.
- Active population roster: none. Existing 2-6 anchor capacities are not a
  SakPix roster, schedule, eight-direction binding, or route reservation.
- Required captures: every room at first visit, stabilized, and postgame;
  native/resolution matrix; keyboard/mouse and controller; every port, gate,
  boss return, facility entry/return, and streamed save anchor.
- Required saves: pre-medical and medical-anchor Asterion states; pre-relay,
  relay-anchor, and post-caldera Primeval states, plus each relevant optional
  gate state.

## Required evidence before acceptance

- One work package per world with exact room graph, useful-cell totals,
  traversal targets, state capture matrix, cohort roster, performance budget,
  and approved asset/profile list.
- Deterministic source inventory and per-pack provenance decision for the
  selected first-pass sources.
- Native-scale contact sheets and visual sign-off for density, palette,
  perspective, headings, crops, and foot anchors.
- Keyboard/mouse, controller, save/reload, navigation-safe-arrival, and
  population-cohort evidence for every admitted active room.

## Focused Asterion navigation evidence (first collision batch)

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/content_validator_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn',
  'tests/asterion_layout_smoke.tscn',
  'tests/asterion_scenario_smoke.tscn'
) -TimeoutSeconds 360
```

- Result: 4/4 passed across the two isolated runner batches.
- Artifact roots: `test-artifacts/20260723-093904-e3473214` and
  `test-artifacts/20260723-093919-b3829aae`.
- Production-save sentinel: unchanged (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remained present;
  this focused batch neither attributes nor accepts that release-level issue.

## Decision

Rework required before acceptance: no distribution eligibility, contact-sheet
approval, or user visual/input sign-off is recorded for either world. The first
four Asterion layouts are verified collision-contract evidence only; the
remaining Asterion and all Primeval layouts still require their own audits.
