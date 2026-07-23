# M2-HM-MANIFEST-01 — Haunted Mansion manifest runtime

- State: Verified automated contract; visual/product acceptance pending
- Milestone: M2 — Mansion quality vertical slice
- Commit SHA: `5ff1aae9`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Intended result

Run the complete `HM-01` through `HM-16` graph through the shared authored-room
runtime. The production facility portal enters `HM-01`; the active room owns
its navigation, reciprocal ports, interactions, boss contract, save anchors,
and streamed presentation layers. This record does not grant final visual,
distribution, controller, or performance approval.

## Contract and scope

- The 16 stable `HM-*` IDs resolve through `CampaignRoomRegistry` to scene-backed
  records, a common staged world origin, and declared layers.
- The 4:44 route, the Gallery/Nursery clock-hand chain, optional loops,
  two Mansion save anchors, and `mansion_archive_boss` remain room-owned.
- Facility portal creation uses `_create_manifest_facility_portal`; the obsolete
  Mansion-only transition constructor is no longer a test dependency.
- Save anchors register only while their room is active. Switching rooms removes
  the prior room's runtime anchor so shared staging coordinates cannot unlock
  roster editing at an unrelated current-room location.

## Production work-package matrix

This is the Section 19 work-package record for the locked Mansion graph.  The
registry is the executable source for port IDs, reciprocal bindings, room
scenes, interaction IDs, gates, and profile IDs.  This matrix makes the
remaining production contract auditable rather than implying that an authored
scene already has final collision or art approval.

- User-visible result: a 16-room, reciprocal Haunted Mansion route that keeps
  the 4:44 sequence and makes its optional loops useful on a stabilized return.
- Non-goals: admitting ignored source-library art, assigning the SakPix roster,
  or granting visual, licensing, controller, performance, or product approval.
- Runtime contract: `CampaignRoomRegistry.MANSION_ROOMS`, room scenes under
  `res://ben_rpg/world/rooms/`, `CampaignRoomRuntime`, and
  `CampaignRoomFeatureInstaller`.
- Migration anchors: `FI-05 -> HM-01`; save IDs `mansion_archive` in `HM-05`
  and `mansion_ballroom_antechamber` in `HM-08`; boss return is owned by
  `HM-09`.
- Traversal target: the `HM-05 -> HM-16 -> HM-08 -> HM-09` stabilized shortcut
  must become a 2-5 minute return route. First-visit, stabilized, and postgame
  route timings are not yet measured.
- Provisional performance budget: 960x540 logical canvas, 60 FPS target, p95
  <=16.7 ms, p99 <=33.3 ms, <=2 s room transition, <=1 GB peak memory. The
  minimum machine and measurements remain unrecorded.

| Room | Locked class / manifest blueprint | Current generated navigation cells | Population anchors | Executable port destinations |
| --- | --- | ---: | ---: | --- |
| HM-01 | C / M1 | 105 authored | 4 | FI-05, HM-02 |
| HM-02 | C / L2 | 215 closed / 216 opened authored | 6 | HM-01, HM-03, HM-04 [4:44], HM-10 |
| HM-03 | C / M3 | 134 authored | 4 | HM-02 |
| HM-04 | C / S1 | 60 baseline / 62 closed / 63 opened authored | 2 | HM-02, HM-05, HM-12 [13:13] |
| HM-05 | C / M1 | 110 baseline / 111 closed / 112 opened authored | 4 | HM-04, HM-11, HM-14, HM-16 [shortcut] |
| HM-06 | C / L2 | 207 authored | 6 | HM-14, HM-15 |
| HM-07 | C / M3 | 136 authored | 4 | HM-15, HM-08, HM-11 [latch] |
| HM-08 | C / M4 | 121 baseline / 124 opened authored | 4 | HM-07, HM-09 [two hands], HM-13, HM-16 [shortcut] |
| HM-09 | C / L1 | 197 authored | 6 | HM-08 |
| HM-10 | O / M2 | 114 authored | 4 | HM-02, HM-15 |
| HM-11 | O / M3 | 136 authored | 4 | HM-05, HM-07 [latch], HM-12 [crypt key] |
| HM-12 | O / L4 | 216 authored | 6 | HM-04 [13:13], HM-11 [crypt key] |
| HM-13 | O / M1 | 101 closed / 102 opened authored | 4 | HM-14, HM-08 [attic latch] |
| HM-14 | X / M2 | 121 baseline / 122 entered authored | 4 | HM-05, HM-06, HM-13 |
| HM-15 | X / S3 | 76 authored | 2 | HM-06, HM-07, HM-10 |
| HM-16 | X / M4 | 112 authored | 4 | HM-05, HM-08 [shortcut] |

HM-01 owns a first authored 105-cell rain-gate layout: facade collision, side
routes, porch, wet-stone crossway, and forecourt are recorded in the manifest
and consumed by `CampaignNavigationBuilder`. HM-02 owns a 215-cell closed /
216-cell 4:44-opened west-foyer layout: entry gallery, central clock hall,
servants' wallpaper seam, and south lounge are explicit collision space. HM-03
adds a 134-cell bookshelf-bounded study, while HM-04 adds a 60-cell baseline,
62-cell entered pendulum passage (63 when its
optional undercroft route opens). These rooms' M/L/S-range counts are
automatically verified but still need visual/input/capture acceptance.
HM-05 records archive aisles, its save-clock floor, and two follower-safe side
vestibules (110-112 cells); HM-14 records its upper balcony, stair landing, and
attic vestibule (121-122 cells). Their M-range counts are automatically
verified, without granting visual/input/capture acceptance.
HM-06 adds an L-scale portrait gallery with distinct upper arrivals, a central
ambush/stage floor, and south viewing balcony (207 cells); HM-15 adds the
S-scale reflected-service link (76 cells). Their gallery-to-Nursery route is
covered by the existing live handoff fixture, but visual/input/capture approval
remains pending.
HM-07 now records the music-box, toy-chest, and chapel-latch floor (136 cells),
including a follower-safe side vestibule. HM-08 records the ballroom-lock and
respite-clock preparation area plus its gated side vestibule (121 baseline /
124 opened cells). The live fixture verifies both clock-hand rewards, the save
anchor, and the boss-door release; visual/input/capture approval remains pending.
HM-09 now has a 197-cell Clock Mirror arena with a dedicated approach and results
floor; HM-10 has a 114-cell conservatory branch with stable north arrivals and
return path. The live handoff fixture verifies boss victory/reward and the
conservatory branch; visual/input/capture approval remains pending.
HM-11 now records a 136-cell Chapel with its crypt-key side vestibule; HM-12
records a 216-cell Undercroft; HM-13 records a 101/102-cell attic with gated
stair return; and HM-16 records a 112-cell Kitchen Lift shortcut. This closes
the automated collision/useful-cell audit for all 16 Mansion rooms, but does not
grant visual, input, capture, licensing, population, or release acceptance.
The remaining rooms' cell values are generated open-interior counts, not audited
useful-cell totals. They materially exceed the Section 9.4 S/M/L ranges in
several rooms because final collision ownership is still a generated rectangle.
Therefore the matrix records a production blocker for every remaining room: an
authored collision/navigation audit and measured useful-cell total are required
before the locked size budget can be claimed.

### Art, population, and state-capture requirements

- The current runtime profiles are the per-room `visualProfileIds` declared in
  `CampaignRoomRegistry`; they are derivatives only and do not admit the
  proposed Haunted Mansion, Crimson Gothic, or supporting source packs.
- Pack-level decision record: `res://ben_rpg/visual_assets/pack_provenance_decisions.json`
  identifies the canonical Haunted Mansion set and its checksum-identical runtime
  duplicate. Its terms and optional-credit record is bound to the checksum-pinned
  `assets/Tilesets/license.txt` inventory record, but it retains `review_required`
  until final runtime-derivative admission and licensing review. It is provenance
  evidence, not a distribution approval.
- Native-scale source-sheet and resident-review evidence is generated locally by
  `tools/build_vertical_slice_contact_sheets.py` from the exact M2 review config.
  Its ignored `test-artifacts/vertical-slice-contact-sheets/` output is reviewer
  input only: it does not crop/admit source art or approve density, palette,
  perspective, character height, or foot anchors.
- Population contract: the generated 258-identity registry reserves 54
  review-required identities for the Mansion, with canonical-home counts
  `HM-01` 3, `HM-04` 3, `HM-06` 5, `HM-07` 2, `HM-08` 1, `HM-09` 2, `HM-10` 5,
  `HM-11` 6, `HM-12` 12, `HM-13` 4, `HM-14` 3, `HM-15` 7, and `HM-16` 1.
  This is the exact target roster, not active population: all identities remain
  blocked on profile admission, story-phase schedules, eight-direction binding,
  and occupancy reservations. The current manifest therefore has only 2-6
  anchor capacities per room.
- Optional-content contract: `HM-10` through `HM-13` are optional rooms;
  `HM-14` through `HM-16` are reciprocal shortcut/loop connectors. Neither the
  optional content nor its rewards may become a critical-path dependency.
- Required captures: each `HM-*` room at first visit, stabilized, and postgame
  (48 technical capture records);
  960x540 native plus required desktop sizes; keyboard/mouse and controller;
  all ports, save anchors, interactions, boss return, and FI-05 entry/return.
- Required save fixtures: pre-4:44, Archive anchor, both hands installed,
  post-boss/stabilized, and 13:13/crypt-key optional state.

## Automated evidence

Command run against the commit worktree:

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/campaign_room_registry_smoke.tscn',
  'tests/campaign_manifest_transition_installer_smoke.tscn',
  'tests/campaign_hm01_authored_room_smoke.tscn',
  'tests/campaign_hm01_live_handoff_smoke.tscn',
  'tests/mansion_scenario_smoke.tscn',
  'tests/mansion_layout_smoke.tscn',
  'tests/mansion_puzzle_smoke.tscn',
  'tests/mansion_encounter_integration_smoke.tscn',
  'tests/universe_save_points_smoke.tscn'
) -TimeoutSeconds 360
```

- Result: 9/9 passed.
- Artifact root: `test-artifacts/20260723-055204-61693668`.
- Production-save sentinel: unchanged (`sentinel=True`).
- The known shutdown-only 61 ObjectDB / 26 resource signature remained present;
  this batch neither attributes nor accepts that release-level baseline.

## Required follow-up evidence

- Native-scale first-visit and stabilized captures for every Mansion room.
- Keyboard/mouse and controller traversal of every port, interaction, boss
  return, and facility entry/return path.
- Save/reload from each active Mansion anchor in a user-visible run.
- Per-source distribution eligibility, attribution, and crop/palette/scale
  review for the Mansion slice.
- Product/visual reviewer decision: pending. This work package is verified by
  automated evidence only; M2 is not accepted.
