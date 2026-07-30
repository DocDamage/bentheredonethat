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
- Traversal targets are design contracts, not measured evidence: an Asterion
  first visit from `AS-01` through medical, hydroponics, oxygen restore, and
  `AS-08` should take 8-12 minutes; the restored `AS-01 -> AS-08` route should
  take at most 4 minutes. A Primeval first visit from `PV-01` through the Cave
  Computer decode, Relay reset, and `PV-08` should take 10-14 minutes; the
  reset `PV-01 -> PV-08` route should take at most 5 minutes. Each world also
  targets a 15-20 minute optional-loop return. These timings require native
  keyboard and controller measurement before acceptance.
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
navigation builder formerly supplied an open interior rectangle. Every listed
Primeval room now has an authored collision/useful-cell contract; its remaining
safe-arrival, foreground, art, and input evidence is still required before it
can claim the Section 9.4 size class.

The first Asterion collision-audit batch now replaces those generated interiors
with authored docking/cargo/medical layouts: `AS-01` 247 closed / 248 restored,
`AS-02` 150, `AS-03` 169, and `AS-04` 148 closed / 149 post-ambush useful cells.
Their navigation and collision IDs
are scene-owned manifest records; every remaining Asterion row remains a
generated baseline until its own audit lands.

The second Asterion batch covers the hydroponics-to-control route: `AS-05` 128,
`AS-06` 259 closed / 260 restored, `AS-07` 179 closed / 183 restored, and
`AS-08` 263 closed / 264 post-completion useful cells. The remaining service,
observation, maintenance, cryo, pressure-lock, and tram rooms remain baseline
contracts until their separate collision audit.

The final Asterion batch audits that service-side loop: `AS-09` 119, `AS-10`
259 closed / 260 restored, `AS-11` 162 closed / 164 post-completion, `AS-12`
148 closed / 149 post-ambush, `AS-13` 143 closed / 145 restored, and `AS-14`
71 closed / 72 restored useful cells.

### Art, population, optional-content, and state-capture requirements

- The current `visualProfileIds` arrays in `CampaignRoomRegistry` are the only
  runtime profile list. They do not admit the locked Space Station/Jurassic
  source families or their supporting packs.
- `pack_provenance_decisions.json` binds the named Asterion and Primeval Tilesets
  packs to the checksum-pinned root `assets/Tilesets/license.txt` evidence and
  its optional-credit statement. The product owner confirmed current
  distribution rights on July 23, 2026; new sources still require an evidence
  update before admission.
- Population contract: the generated 258-identity registry reserves 10
  distribution-confirmed identities for Asterion (`AS-01`, `AS-02`, `AS-03`, `AS-06`,
  `AS-07`, `AS-08`, `AS-10` ×3, and `AS-11`) plus the Astronaut story actor;
  it reserves 15 for Primeval (`PV-01`, `PV-03`, `PV-04` ×3, `PV-05`, `PV-06`,
  `PV-08` ×2, `PV-09`, `PV-11`, `PV-12` ×3, and `PV-14`) plus the Caveman story
  actor. These are target homes, not active spawns: all still need runtime
  profile binding, story-phase schedules, and occupancy reservation review.
- Optional-content contract: Asterion optional rooms are `AS-09` through
  `AS-12`, with `AS-13` and `AS-14` as reciprocal service/pressure loops;
  Primeval optional rooms are `PV-09` through `PV-12`, with `PV-13` and
  `PV-14` as reciprocal river/lava bypasses. None may become a critical-path
  dependency.
- Required captures: every room at first visit, stabilized, and postgame;
  native/resolution matrix; keyboard/mouse and controller; every port, gate,
  boss return, facility entry/return, and streamed save anchor. The minimum
  technical matrix is 42 Asterion frames and 42 Primeval frames (14 rooms ×
  three states), with additional pre/post medical, oxygen, terminal-decode,
  relay-reset, and boss-return fixtures where those states change a room.
- Required saves: pre-medical and medical-anchor Asterion states; pre-relay,
  relay-anchor, and post-caldera Primeval states, plus each relevant optional
  gate state.

## Native-scale review-input regeneration

The July 23 deterministic contact-sheet batch regenerated and freshness-checked
the following local reviewer inputs under
`test-artifacts/vertical-slice-contact-sheets/`:

- Asterion: 16 source-environment sheets and all 10 target population
  identities (`asterion-environment.png`, `asterion-population.png`).
- Primeval: 31 source-environment sheets and all 15 target population
  identities (`primeval-environment.png`, `primeval-population.png`).

`vertical_slice_contact_sheets.json` records their source checksums and
eight-direction rotations. These artifacts are evidence-generation outputs
only; they do not approve palette, density, crop, foot anchors, distribution
eligibility, or active population.

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

The second collision batch repeated the same four scenes successfully at
`test-artifacts/20260723-094413-40804b6c` and
`test-artifacts/20260723-094426-5085642e`; its production-save sentinel also
remained unchanged (`sentinel=True`).

The final Asterion batch repeated the same four scenes successfully at
`test-artifacts/20260723-095043-01600d35` and
`test-artifacts/20260723-095056-c6ae251c`; its production-save sentinel also
remained unchanged (`sentinel=True`).

The first Primeval collision batch passed the same four contracts at
`test-artifacts/20260723-095439-a298248b` and
`test-artifacts/20260723-095457-f1d6a4bd`; its production-save sentinel also
remained unchanged (`sentinel=True`). `PV-01` has 247 closed / 248 decoded
cells, `PV-02` has 150, `PV-03` has 296-299 across terminal/caldera states,
and `PV-04` has 150 authored useful cells.

The second Primeval collision batch passed at
`test-artifacts/20260723-095659-a7730c4a` and
`test-artifacts/20260723-095714-eba4df34`; its production-save sentinel also
remained unchanged (`sentinel=True`). `PV-05` has 257 closed / 258 decoded,
`PV-06` 144-145, `PV-07` 296-298, and `PV-08` 262-265 authored useful cells.

The final Primeval batch passed at `test-artifacts/20260723-100433-a7cce308`
and `test-artifacts/20260723-100445-bf9462ac`; its production-save sentinel
also remained unchanged (`sentinel=True`). `PV-09` has 120, `PV-10` 259-260,
`PV-11` 162-164, `PV-12` 262-265, `PV-13` 141, and `PV-14` 71-72 authored
useful cells.

## Decision

Rework required before acceptance: no distribution eligibility, contact-sheet
approval, or user visual/input sign-off is recorded for either world. All 14
Asterion and Primeval layouts are verified collision-contract evidence only.
Their distribution eligibility, contact-sheet approval, and user
visual/input sign-off remain outstanding.
