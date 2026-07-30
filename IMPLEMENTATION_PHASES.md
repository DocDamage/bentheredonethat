# Production Implementation Phases

This is the execution view of `FFVI_ALIGNMENT_COMPLETION_PLAN.md`. The detailed
plan remains the authority for room graphs, content requirements, asset sources,
and acceptance criteria. This file defines the order in which that work can be
built and accepted.

## Locked target

- 192 mandatory locations: 102 core-universe rooms, 15 New Philadelphia rooms,
  11 facility interiors, and 64 required-address rooms.
- Benjamin Franklin, Abraham Lincoln, and Mahatma Gandhi remain core playable
  protagonists from the opening through the ending.
- Exactly 258 eligible SakPix identities receive canonical homes, schedules,
  story phases, and complete eight-direction field art.
- Six mandatory address campaigns—Ashfall, Pelagic, Steamforge, Frontier,
  Warfront, and Liminal—must resolve before the Empyreal ending.
- Windows is the current implementation baseline. Additional shipping platforms
  are a product decision in Phase 7.

## Status vocabulary

Each work package moves through these states. Do not skip a state or use
`complete` as a synonym for `implemented`.

| State | Required evidence |
| --- | --- |
| Contracted | Validated content, room, layout, navigation, population, and asset/provenance records exist. |
| Implemented | The authored scene and gameplay behavior exist behind the production runtime. |
| Verified | Targeted automated tests, save/reload, and capture generation pass. |
| Accepted | Real keyboard/controller traversal, native-scale visual review, performance review, and product sign-off pass. |

A phase closes only when every exit gate is recorded against an exact commit.

## Phase map

| Phase | Production outcome | Weight | Current state |
| --- | --- | ---: | --- |
| 0. Baseline and scope control | One trustworthy build/test baseline | 5% | Active; refresh required for current worktree |
| 1. Expansion architecture | Safe data-driven platform for 192 rooms | 10% | Complete; verified at `f3ec2199` |
| 2. Mansion vertical slice | One final-quality, end-to-end chapter | 15% | Verified automated; human acceptance pending |
| 3. New Philadelphia and facilities | Final hub plus movable facility contract | 15% | Contracts and staged scenes exist; runtime migration open |
| 4. Core universe production | All 102 core-universe rooms accepted | 20% | Contracts/layouts exist; acceptance largely open |
| 5. Mandatory address production | All 64 address rooms accepted | 20% | Contracts exist; AF-01 is the first gated prototype |
| 6. Population, progression, and side content | Full roster and campaign integration | 5% | Registry exists; production placement/integration open |
| 7. Content lock and release candidate | Measured, licensed, signed, shippable build | 10% | Not started as a release phase |

Weights are progress-reporting weights, not schedule estimates. Progress is
earned only when a phase deliverable reaches its stated gate.

## Phase 0 — Baseline and scope control

### Deliverables

1. Reconcile or intentionally remove every untracked production file; ignore
   generated `.uid` and cache noise through repository policy where appropriate.
2. Record the exact commit, Godot version, test discovery count, artifact root,
   production-save sentinel result, and validation commands in a dated audit.
3. Run the fast checks, runtime asset validation, full isolated Godot smoke
   suite, and clean Windows export/launch.
4. Confirm the 192-room, 258-identity, six-address, and protagonist-trio scope in
   the content validators so scope drift fails loudly.
5. Record unresolved product decisions: storefront, additional platforms,
   minimum hardware, shipping version, publisher identity, and signing method.

### Exit gate

- `npm run check` passes.
- `npm run validate:runtime-assets` passes.
- Every discovered Godot smoke scene passes in one recorded save-safe baseline.
- A clean Windows build launches outside the editor without test/MCP resources.
- The working tree and exact tested commit are documented.

## Phase 1 — Expansion architecture

### Deliverables

1. Finish extracting content catalogs and bounded runtime services behind the
   existing `CampaignState` compatibility facade.
2. Reduce `campaign_bootstrap.gd` to lifecycle/orchestration; prohibit new
   room-specific geometry, interactions, gates, and encounter branches there.
3. Freeze `campaign_map_visual.gd` as a legacy adapter. Every production room
   renders through an authored scene and the manifest room runtime.
4. Complete the room registry, streamer, transition router, camera controller,
   feature installer, encounter runtime, and safe-arrival contracts.
5. Split town placement/domain behavior from HUD/story guidance.
6. Replace hardcoded resident profiles with the generated population registry,
   schedule resolver, occupancy rules, and actor factory.
7. Preserve save-schema migration for legacy area/cell positions and all public
   compatibility calls while ownership moves.

### Exit gate

- Characterization fixtures pass before and after each ownership move.
- One manifest-only room proves load/unload, camera bounds, collision,
  reciprocal transition, population reservation, encounter ownership, and
  save/reload without legacy geometry.
- Existing opening, construction, Mansion puzzle, universe gates, battles,
  recruits, recall, ending, and migrated saves retain parity.
- No new production-room implementation enters the frozen legacy renderer or
  bootstrap.

### Completion record — 2026-07-29

- Exact implementation commit: `f3ec2199`.
- Evidence: `game/validation/reviews/20260729-phase1-expansion-architecture.md`.
- Full isolated suite: 160 of 160 discovered smoke scenes passed at
  `test-artifacts/20260729-231133-765e94b6`; the production-save sentinel was
  unchanged.
- `npm run check` and `npm run validate:runtime-assets` passed.
- The manifest-only architecture fixture locks the registry, streamer,
  transition router, camera, navigation, feature, encounter, population
  scheduler, and actor-factory boundaries and prevents expansion IDs from
  entering the frozen bootstrap or legacy renderer.

## Phase 2 — Mansion vertical slice

This phase proves the production pipeline before it is multiplied across the
remaining campaign.

### Work packages

1. Accept the opening and Franklin laboratory handoff into the final room
   runtime, including Ben/Lincoln/Gandhi party continuity.
2. Complete and accept `HM-01` through `HM-16` in graph order.
3. Move every Mansion puzzle, interaction, treasure, encounter, save point,
   recruit event, boss result, and restoration state to scene-owned contracts.
4. Admit the exact art and population sources; close scale, crop, perspective,
   collision, foreground, lighting, and provenance decisions.
5. Complete the 4:44 puzzle, boss, defeat/retry, recall lockout, partial-puzzle
   reload, stabilization, town consequence, and postgame paths.
6. Balance and playtest the opening-through-Mansion experience as a coherent
   90–150 minute slice.

### Exit gate

- All 16 rooms are accepted, not merely captured or smoke-tested.
- First-visit and stabilized captures plus every special-state capture pass at
  supported resolutions.
- Keyboard/mouse and controller playthroughs complete the slice.
- Fresh and migrated saves preserve every allowed boundary.
- A blind player can understand the route, solve the puzzle, read the boss
  states, and recover from defeat without developer guidance.
- Frame pacing meets the provisional budget on the development baseline.

### Verification record — 2026-07-30

- Exact implementation commit: `c4e97fa2`.
- Evidence: `game/validation/reviews/20260730-phase2-mansion-vertical-slice.md`.
- All 16 rooms now stream with authored navigation, room-owned interactions,
  scripted encounters, saves, optional rewards, 4:44 state, boss persistence,
  stabilization, and postgame state coverage.
- The 161-scene isolated Godot suite, fast/tool checks, runtime-asset checks,
  288-frame state/resolution capture matrix, and 16-room performance diagnostic
  pass on the Windows development baseline.
- Phase 2 remains `Verified`, not `Accepted`, until a human completes the
  keyboard/controller, blind-route, balance, accessibility, and product/visual
  sign-off gates required above.

## Phase 3 — New Philadelphia and facilities

### Work packages

1. Implement and accept `NP-01` through `NP-15` in connected district slices:
   `NP-01`–`NP-04`, `NP-05`–`NP-07`, `NP-08`–`NP-10`, and `NP-11`–`NP-15`.
2. Replace the legacy founding map with the authored district streamer while
   preserving existing construction saves and quest flags.
3. Implement all 11 facility interiors (`FI-01`–`FI-11`) and stable lot sockets.
4. Separate facility placement, services, jobs, upgrades, portal selection,
   objective guidance, and presentation into tested ownership boundaries.
5. Add district population cohorts, routes, town phases, construction states,
   universe imports, and post-stabilization changes.
6. Complete the deferred campaign-menu and sandbox-editor decompositions before
   adding their expansion-only screens or district workflows.

### Exit gate

- All 15 hub rooms and 11 facility interiors are accepted.
- The 11-by-11 placement matrix (121 combinations) enters and returns through
  the correct lot, survives save/reload, and preserves jobs and portal state.
- Founding, relocation, recall, services, objectives, and resident schedules
  work with keyboard/mouse and controller.
- `NP-15` keeps gated, reciprocal routes to `AF-01` and `WF-01`; no placeholder
  shortcut substitutes for either route.

### Verification record — 2026-07-30

- Exact implementation commit: `73a347c1`.
- Evidence: `game/validation/reviews/20260730-phase3-new-philadelphia-facilities.md`.
- All 15 hub rooms and 11 stable facility interiors now run through the annex
  streamer with migrated lot identities, population phases, construction and
  universe-import states, service/job ownership, and save-safe relocation.
- The 162-scene isolated Godot suite, fast/tool checks, runtime-asset checks,
  121-case facility placement matrix, and focused mansion/facility return pass.
- Phase 3 remains `Verified`, not `Accepted`, until a human completes the
  keyboard/controller, resident-schedule, accessibility, visual, and product
  sign-off gates required above.

## Phase 4 — Core universe production

Process one universe at a time. A later universe may be contracted while the
current one is reviewed, but it cannot be marked accepted early.

### Production order

1. Asterion `AS-01`–`AS-14`.
2. Primeval `PV-01`–`PV-14`.
3. Helios `HE-01`–`HE-14`.
4. Frosthold `FR-01`–`FR-14`.
5. Moonpetal `MP-01`–`MP-14`.
6. Empyreal `EM-01`–`EM-16`, including the provisional ending handoff.

### Per-universe deliverables

- Admit exact primary/supporting art, derivatives, battle stages, actors, audio,
  population cohort, and provenance records.
- Implement authored terrain, architecture, collision, foreground, interactions,
  treasures, safe points, encounters, puzzle/state mechanics, boss, restoration,
  and town consequences.
- Replace generated-interior and legacy-coordinate compatibility behavior with
  room-owned layouts and zones.
- Verify every port, shortcut, state gate, arrival, follower position, recall,
  defeat return, boss result, and save boundary.
- Run balance, accessibility, native-scale capture, performance, keyboard, and
  controller review before moving to the next universe.

### Exit gate

- All 102 core-universe rooms are accepted.
- Every universe has a readable signature mechanic, pre/post state, boss,
  battle stage, population, town consequence, and save-safe traversal.
- The opening-to-Empyreal path works with the protagonist trio in field, battle,
  menu, dialogue, progression, save, and ending flows.

## Phase 5 — Mandatory address production

Do not enable an address in the production streamer until its entire chapter
passes the room, asset, population, battle, progression, and return-path gates.

### Production order

1. Ashfall `AF-01`–`AF-12`.
2. Pelagic `PL-01`–`PL-12`.
3. Steamforge `SF-01`–`SF-12`.
4. Frontier `FT-01`–`FT-10`.
5. Warfront `WF-01`–`WF-10`.
6. Liminal `LM-01`–`LM-08`.

### Per-address deliverables

- Admit the chapter's source packs, room profiles, resident/recruit profiles,
  enemies, backdrops, rewards, audio, credits, and provenance.
- Implement all critical, optional-detour, and connective rooms with reciprocal
  graph fixtures and a safe return to the named New Philadelphia room.
- Implement chapter quest, progression flag, encounter set, boss, restoration,
  reward transaction, optional detours, and population phase changes.
- Balance the chapter with no required random drop, timer, optional recruit, or
  job dependency.
- Record automated, visual, input, save/reload, performance, and human review.

### Exit gate

- All 64 address rooms are accepted.
- Each resolution flag is awarded exactly once and survives migration/reload.
- All six resolution flags are required for the final Empyreal ending.
- Optional rooms remain optional and cannot hard-lock chapter progression.

## Phase 6 — Population, progression, and side content

Population work happens alongside room production, but this phase closes the
campaign-wide integration after all homes exist.

### Deliverables

1. Bind all 258 eligible identities to one canonical home, approved profiles,
   story phases, schedules, routes, occupancy rules, and dialogue/reaction sets.
2. Complete Lincoln, Gandhi, required named-character arcs, approved recruit
   arcs, field/battle/menu/progression coverage, and ending reactions.
3. Finish facility jobs, inventions, equipment/skill progression, economy,
   bestiary, optional quests, rare events, postgame reactions, and rematches.
4. Run low-, median-, and high-combat simulations plus minimum-job and
   offline-heavy paths; remove main-path RNG/timer/economy traps.
5. Verify that no room schedules more than six residents and that routes never
   enter ports, safe zones, puzzles, treasures, or facility-door cells.

### Exit gate

- The population audit reports exactly 258 valid, checksum-matched identities.
- Every identity appears in an appropriate home/state without route conflicts.
- Required characters and progression systems work across the entire campaign.
- Optional content cannot block, duplicate, or invalidate main-story rewards.

## Phase 7 — Content lock and release candidate

### Deliverables

1. Freeze content and produce the complete 192-location graph audit, 121-case
   facility matrix, 258-identity audit, and capture matrix.
2. Archive at least 384 baseline captures—first visit and stabilized for every
   location—plus all special states, with resolution, input mode, and commit.
3. Archive two fresh-save end-to-end playthroughs and one migrated-save run,
   including defeat/retry, recall, partial-puzzle reload, and backup recovery.
4. Complete keyboard/mouse and controller playthroughs at every supported
   resolution, accessibility review, and color/sound-independent cue review.
5. Measure campaign duration, load/save time, frame pacing, and memory on the
   declared minimum hardware; investigate or explicitly baseline shutdown-only
   ObjectDB/resource warnings over a multi-hour session.
6. Extend provenance to audio, fonts, addons, dynamic resources, and all newly
   introduced assets; finalize credits and third-party notices.
7. Decide shipping platforms/storefronts, set the shipping version and publisher
   metadata, configure signing/notarization, and reproduce release exports on a
   clean release machine/CI runner.

### Exit gate

- Every release blocker in `game/RELEASE_READINESS.md` has recorded evidence.
- Clean checkout checks, runtime assets, all Godot tests, full playthroughs,
  performance budgets, memory soak, imports, licenses, credits, and signed
  export/launch pass for the exact release commit.
- Zero known progression hardlocks, invalid targets, duplicate results, or
  save-loss defects remain.

## Standard room work package

Use this checklist for every production room. A room does not count toward
implementation progress until items 1–6 pass, and does not count toward accepted
phase progress until all ten pass.

1. Contract: validate ID, class, blueprint, dimensions, ports, story states,
   encounters, treasure, features, and population references.
2. Assets: approve source/derivative/profile IDs, license evidence, credits,
   crop, density, scale, pivot, and checksum.
3. Layout: author exact terrain, architecture, props, interactions, foreground,
   weather/lighting, and collision ownership.
4. Navigation: verify safe arrivals, follower cells, connected required anchors,
   route reservations, unused blocked ports, and reciprocal edges.
5. Gameplay: implement interactions, puzzle/gate state, encounters, rewards,
   save point, recall/defeat/boss returns, and population phases.
6. Automation: pass content/resource load, room, graph, navigation, encounter,
   save migration, streaming, and changed-area smoke tests.
7. Captures: record first-visit, stabilized, and every special state at native
   scale with exact commit metadata.
8. Traversal: complete keyboard/mouse and controller routes through every port,
   interaction, treasure, puzzle, shortcut, and return path.
9. Quality: pass visual, accessibility, balance, frame-pacing, and save/reload
   review.
10. Acceptance: record reviewer/product-owner approval and enable the room in
    the production registry.

## Verification cadence

For each work package:

1. Run syntax/unit/tool checks: `npm run check`.
2. Run changed-area isolated Godot scenes through
   `tools/run_godot_isolated.ps1`.
3. Run `npm run validate:runtime-assets` whenever runtime art, profiles,
   population records, provenance, or generated manifests change.
4. Run `npm run validate:source-library` when local source-library admission or
   curation changes.
5. At the end of each accepted phase, run every discovered isolated Godot smoke
   scene and archive its artifact root with the exact commit.
6. At release-candidate boundaries, run the clean export/launch, full human
   traversal matrix, performance test, and multi-hour soak.

## Progress reporting

Report progress by accepted phase deliverables, not file count or test count.
Each status update should contain:

- phase and work package;
- state: contracted, implemented, verified, or accepted;
- exact commit and artifact paths;
- automated results;
- human/visual/save/performance evidence;
- open gate and next bounded work package.

Recalculate the overall percentage from the phase weights only when acceptance
evidence changes. Contract and implementation progress may be reported inside a
phase, but it does not earn the phase's full weight.
