# Franklin's Multiversal Township

## FFVI Alignment and Completion Plan

**Created:** July 22, 2026
**Project target:** `game/project.godot` (Godot 4.7.1)
**Secondary implementation:** browser prototype at the repository root
**Current verdict:** Mechanically substantial and well tested, but not yet visually, architecturally, or operationally ready to ship.

---

## 1. Purpose

This plan converts the full-project audit into an ordered implementation program. Its goal is to bring the game as close as practical to the exploration, presentation, readability, and combat feel of a 16-bit Final Fantasy VI-style JRPG while preserving the game's own Benjamin Franklin, town-building, multiverse, recruit, and facility-management scope.

This is not a request to copy Final Fantasy VI assets, maps, dialogue, characters, or protected content. "FFVI alignment" in this plan means adopting comparable design principles:

- Cohesive pixel scale and visual language.
- Layered top-down exploration with foreground occlusion.
- Readable multi-screen towns and dungeons.
- Side-view active-time combat with clear command flow.
- Strong party identity, progression, equipment, status, and formation systems.
- Environmental storytelling, secrets, optional paths, and memorable set pieces.
- Compact, legible menus and battle information.

---

## 2. Verified baseline

The following evidence was reproduced during the July 22, 2026 audit:

- [x] All 80 isolated Godot smoke scenes passed.
- [x] All 14 browser unit tests passed.
- [x] The Godot runtime visual manifest is current.
- [x] The browser produced no console errors during the inspected campaign opening.
- [x] All 54 observed browser network requests returned HTTP 200.
- [x] The current Git working tree was clean before this plan was added.
- [x] The Godot project has a complete authored path from opening through ending and postgame.
- [x] Combat includes ATB timing, active/wait modes, formations, equipment, skills, elements, statuses, items, loot, recruitment, EXP, Duckets, and results.
- [x] The latest captures for 35 authored universe rooms show no obvious full-sheet rendering, atlas headings, or gross neighboring-sprite bleed.
- [x] Nearest-neighbor filtering and rounded placement are used in the primary procedural field renderer.

The baseline does **not** prove that the project is finished. Automated tests currently prove system contracts and resource validity more strongly than visual quality, exploration quality, complete playability, performance, or shipping readiness.

---

## 3. Audit conclusion

The game is closer to FFVI in combat systems than in exploration or presentation.

### Strong areas

- Side-view active-time combat.
- Five-person company formation plus an autonomous companion slot.
- Character commands and individual battle animation states.
- Equipment, skills, elements, status effects, consumables, loot, and progression.
- Persistent saves, migrations, bestiary, recruits, facilities, jobs, quests, and postgame.
- Broad automated smoke coverage.
- A complete campaign outline with seven themed universes.

### Areas preventing completion

- Most universe areas are extremely small and use nearly identical five-stage topology.
- The renderer paints most field art into one flat `Node2D` draw pass.
- Foreground/background relationships and Y-sorting are not robust.
- Runtime crop approval covers only a small fraction of direct atlas call sites.
- Source packs use visibly different pixel densities and semantic scales.
- Town buildings and some universe props do not look like they belong to one game.
- The browser asset-readiness validator fails for all 51 NPCs because it ignores path aliases.
- The browser title card clips controls at smaller desktop viewports.
- Shutdown leak warnings, licensing review, performance measurements, and full playthrough sign-offs remain open.

---

## 4. Priority definitions

| Priority | Meaning |
| --- | --- |
| P0 | A failing required check, corrupted/inaccessible content, save risk, or release-blocking correctness problem. |
| P1 | A major visual, architectural, level-design, or gameplay-quality gap that prevents the intended JRPG standard. |
| P2 | Important usability, consistency, maintainability, accessibility, or polish work. |
| P3 | Optimization, optional content, production convenience, and final release refinement. |

Work should proceed in dependency order. Adding more universes, props, or recruits before the P0/P1 field foundation is repaired will increase rework.

### 4.1 Execution states and checkbox meaning

Every work package and milestone must use one of these states:

| State | Meaning |
| --- | --- |
| Not started | No implementation evidence exists. |
| In progress | Work is active, but its implementation contract is incomplete. |
| Blocked | A named dependency prevents meaningful forward progress. |
| Implemented | The intended code/content exists and focused automated checks pass. |
| Verified | Required automated checks, traversal/input, capture, and persistence evidence pass. |
| Accepted | The named reviewer has approved the recorded evidence and no required rework remains. |

A checked item means only that the action named by that item is complete. An
implemented prototype is not visually accepted unless the item explicitly says
that all Section 18 sign-off evidence was reviewed and accepted. Historical
baseline checkboxes in Section 2 remain point-in-time evidence; current counts
and status come from the latest dated progress audit.

### 4.2 Work-package contract

Before implementation begins, each batch must record:

- Stable work-package ID and milestone.
- Current state and dependencies.
- Intended user-visible result and non-goals.
- Primary files or data contracts expected to change.
- Focused automated checks and the full-suite gate.
- Required native captures, input methods, and save fixtures.
- Performance and license/provenance impact.
- Evidence path, responsible implementer, and required reviewer.

The evidence record belongs at
`game/validation/reviews/YYYYMMDD-<work-package>.md` and must contain the commit
SHA, build version, scene/save used, native resolution, capture paths, keyboard
and controller results, save/reload results, known defects, reviewer, review
date, and an `accepted` or `rework required` decision. The user is the default
product/visual reviewer unless approval is explicitly delegated.

### 4.3 Source-control and remote-CI contract

- Use a feature branch for each coherent milestone slice; avoid mixing unrelated
  content production, architecture, and release work in one review unit.
- Push the feature branch and open a draft pull request, or use
  `workflow_dispatch`, before claiming remote CI evidence. The current workflow
  runs automatically for pull requests and pushes to `main`, not ordinary
  feature-branch pushes.
- Record the tested head SHA and require the remote checks to match it.
- Do not merge with an unresolved P0 or with missing required artifacts.
- Preserve failed-run logs and link the successful replacement run rather than
  deleting the failure history.

---

## 5. Phase 0 — Restore a trustworthy verification baseline

### 5.1 Separate clean-checkout and local source-library validation — P0

**Problem:** `npm run validate:assets` reports `0/51 NPC visuals are editor-ready`. Runtime NPC paths use legacy prefixes such as `assets/NPCs/`, while the curated catalog indexes reorganized paths such as `assets/characters/NPCs/`. The browser resolves these through `asset-paths.js`, but `tools/validate_npc_asset_readiness.js` looks up raw paths directly.

The alias defect is fixed, but the aggregate command now mixes two different
contracts. The ignored `assets/` source library contains zero tracked files and
cannot exist in a normal GitHub checkout, while runtime visual manifests and
release assets are tracked. CI must never require an ignored local source tree
unless that tree is restored explicitly as a licensed artifact.

**Primary files:**

- `tools/validate_npc_asset_readiness.js`
- `asset-paths.js`
- `game.js`
- `curated-asset-catalog.js`

**Tasks:**

- [x] Move the path-prefix mapping into a small shared module usable from the browser and Node.
- [x] Normalize every NPC source path before catalog lookup.
- [x] Normalize direction-file and animation-frame paths as well as primary sheet paths.
- [x] Add a regression test covering every declared aliased root.
- [x] Confirm that invalid or genuinely missing assets still fail clearly.
- [x] Add `validate:runtime-assets` for checks that work from a clean checkout:
  runtime manifest, runtime inventory, contact sheet, provenance ledger, and
  other tracked release contracts.
- [x] Add `validate:source-library` for the curated catalog and NPC readiness;
  make its requirement for the ignored `assets/` tree explicit.
- [x] Keep `validate:assets` as the local aggregate of both contracts, not as a
  clean-checkout CI command.
- [x] Rebuild and review `curated-asset-catalog.js` after the 488 newly
  synchronized source rasters are intentionally admitted or excluded.
- [x] Change the GitHub workflow to run the clean-checkout runtime command. Run
  source-library validation remotely only if an approved asset artifact is
  restored first.

**Acceptance criteria:**

- [ ] `npm run validate:runtime-assets` exits 0 from a fresh clone with no local
  `assets/` directory.
- [ ] `npm run validate:source-library` and the local aggregate
  `npm run validate:assets` exit 0 when the approved source library is present.
- [x] All 51 NPCs report editor-ready.
- [x] Removing or misspelling a required NPC file makes the validator fail.
- [ ] Browser network requests still resolve to the reorganized asset paths.

### 5.2 Preserve isolated save safety — P0

- [x] Continue using `tools/run_godot_isolated.ps1` for all automated Godot scenes.
- [x] Retain the production-save sentinel check.
- [x] Never run destructive save/reset tests against the normal Godot user-data directory.
- [ ] Record artifact paths and test version in each release candidate report.

### 5.3 Make CI evidence authoritative — P1

- [x] Publish the prepared GitHub workflow on a feature branch.
- [ ] Open a draft pull request or manually dispatch the workflow for the exact
  head SHA being evaluated.
- [ ] Record the first clean remote pass of every smoke scene discovered at that
  commit. Record the count as evidence; do not hard-code it as the gate.
- [ ] Run `npm run check` plus the clean-checkout runtime-asset command in CI.
- [x] Fail CI when the visual manifest is stale.
- [x] Retain logs for failed Godot scenes.
- [ ] Prove the workflow passes from a clean checkout without the ignored
  `assets/` source library.

---

## 6. Phase 1 — Establish one coherent pixel and camera standard

### 6.1 Adopt a field-scale bible — P1

The current project combines 16-, 48-, 96-, and higher-density art with manually selected 0.5x, 1x, and 2x scales. Scaling may be mathematically integral while still being semantically inconsistent.

**Required standards:**

- [ ] Keep the movement grid at 48 world pixels unless a prototype proves a better replacement.
- [ ] Define a standard field-character height range.
- [ ] Define doorway, single-story facade, multi-story facade, tree, counter, bed, chair, treasure, and boss size ranges relative to a character.
- [ ] Require integer or exact reciprocal scaling with nearest-neighbor filtering.
- [ ] Prohibit arbitrary fractional scale and fractional final placement.
- [ ] Define foot anchors and collision bases separately from visible image bounds.
- [ ] Define battle-sprite scale separately from field-sprite scale.
- [ ] Define portrait crops separately from both field and battle frames.

**Suggested density conversions:**

| Source density | World conversion |
| --- | --- |
| 16-pixel tile art | 3x nearest to 48 world pixels |
| 24-pixel tile art | 2x nearest to 48 world pixels |
| 48-pixel tile art | 1x native |
| 96-pixel tile art | 0.5x nearest to 48 world pixels |

These are starting rules, not permission to combine visually incompatible packs without art direction.

### 6.2 Lock a pixel-stable camera — P1

- [ ] Choose the intended logical resolution and document why it fits the field scale.
- [ ] Ensure the camera lands on integer world pixels after following and transitions.
- [ ] Verify one-tile movement at the default window size, native 1080p, 1440p, 4K, and common 16:10 sizes.
- [ ] Eliminate visible single-pixel shimmer in movement captures.
- [ ] Avoid showing large empty voids around small rooms.
- [ ] Make the camera reveal enough upcoming path for navigation without making characters and UI unreadably small.

### 6.3 Normalize the town first — P1

The town is the game's recurring hub and should establish the visual contract used everywhere else.

- [ ] Normalize all facility facades to the scale bible.
- [ ] Align every visible doorway with its interaction cell and apron.
- [ ] Replace or rework buildings whose source perspective cannot match the shared town perspective.
- [ ] Normalize roads, grass, foundations, shadows, trees, signs, and residents.
- [ ] Ensure landmark buildings are larger because of role, not because their source pack has more pixels.
- [ ] Review roof, wall, and tree collision against the final visible footprints.

**Acceptance criteria:**

- [ ] Every facility can be identified at a glance without reading its label.
- [ ] No facade looks like a thumbnail, presentation crop, or unrelated art style pasted onto grass.
- [ ] Character, doorway, window, and story-height relationships are consistent.
- [ ] Native-scale overview and close-up captures receive visual sign-off.

---

## 7. Phase 2 — Replace the flat field renderer

### 7.1 Migrate away from one procedural draw pass — P1

**Problem:** `CampaignMapVisual` loads many textures and paints almost every environment through `draw_texture_rect_region` in one `Node2D`. This does not provide dependable field depth.

**Primary files:**

- `game/ben_rpg/world/campaign_map_visual.gd`
- `game/ben_rpg/world/campaign_bootstrap.gd`
- `game/ben_rpg/world/campaign_map_visual.gd`
- `game/ben_rpg/world/party_follower_train.gd`

**Target scene structure:**

```text
AreaRoot
├── GroundLayer
├── LowDecorationLayer
├── NavigationAndCollision
├── YSortedActorsAndProps
│   ├── Player
│   ├── Followers
│   ├── NPCs
│   └── TallProps
├── ForegroundLayer
├── InteractionLayer
├── EncounterLayer
└── CameraAndAreaMetadata
```

**Tasks:**

- [ ] Keep current public transition/state APIs while extracting one area at a time.
- [ ] Convert ground and repeatable architecture to `TileMapLayer` or equivalent authored scene data.
- [ ] Convert interactive/tall objects into independent prop scenes with foot anchors.
- [ ] Put characters and appropriate props in a shared Y-sorted layer.
- [ ] Split tall sprites when their lower collision base and upper foreground portion need different draw behavior.
- [ ] Use explicit foreground layers for arches, tree canopies, roof edges, upper walls, and chandeliers.
- [ ] Keep collision, interaction, and visible object ownership in the same area resource.
- [ ] Stop redrawing inactive universes.

**Acceptance criteria:**

- [ ] Ben can pass naturally in front of and behind every major prop.
- [ ] Followers maintain the same depth relationship without clipping through foreground art.
- [ ] Click-to-move and controller movement use the same navigation representation.
- [ ] No transition depends on invisible gaps in a procedural drawing.
- [ ] The old renderer can be removed after all authored areas migrate.

### 7.2 Reduce monolithic responsibilities — P2

Current high-risk file sizes include approximately:

- `campaign_state.gd`: 4,044 lines.
- `campaign_bootstrap.gd`: 2,479 lines.
- `campaign_menu.gd`: 1,850 lines.
- `campaign_map_visual.gd`: 1,177 lines.
- `campaign_battle.gd`: 975 lines.

Refactor incrementally behind existing interfaces:

- [ ] Move immutable content definitions into validated data resources.
- [ ] Extract world-area construction and transition registration by universe.
- [ ] Extract save serialization/migration from live campaign behavior.
- [ ] Split menu pages into controllers/components.
- [ ] Split battle presentation from battle rules and state transitions.
- [ ] Add focused tests before moving each responsibility.

---

## 8. Phase 3 — Complete runtime crop and asset provenance coverage

### 8.0 Establish asset eligibility before deeper integration — P0/P1

Licensing cannot remain only a final release activity. Replacing an asset after
level construction, derived-art work, collision tuning, and capture approval
would create avoidable rework.

- [x] Give every source used by a release profile one of three explicit states:
  `distribution_confirmed`, `review_required`, or `rejected`.
- [x] Prevent an asset in `review_required` from receiving final visual
  acceptance. It may appear in a clearly labeled non-release prototype only.
- [x] Prevent generation or acceptance of derived assets from a rejected source.
- [ ] Review terms for every source used by the laboratory, town, and Mansion
  vertical slice before M2 acceptance.
- [ ] Record attribution text and modification status when the source is first
  accepted, rather than deferring all notice work to Phase 9.

Phase 9 still owns final credits, platform packaging, and the complete
distribution audit. This early gate only establishes that implementation is not
building deeper dependencies on an ineligible source.

### 8.1 Expand visual profiles from five entries to full coverage — P1

The audit found roughly 161 direct atlas-region call sites in the primary field renderer but only five entries in `visual_profiles.json`.

**Required profile fields:**

- Stable visual ID.
- Asset kind.
- Source pack and exact source path.
- Source checksum.
- Exact crop rectangle or derived-asset path.
- Alpha bounds.
- Source density.
- World draw size.
- Foot anchor or pivot.
- Doorway/interaction anchor where applicable.
- Collision footprint class.
- Scale class.
- Crop approval state.
- License reference.
- Golden-capture reference.

**Tasks:**

- [ ] Inventory every runtime visual reference, not only direct `Rect2` calls.
- [ ] Include buildings, terrain cells, props, field characters, followers, NPCs, battle actors, portraits, icons, VFX, treasure, anchors, and UI panels.
- [ ] Reject rectangles that cross atlas cells or include neighboring objects.
- [ ] Reject presentation headings, legends, sample-layout fragments, and catalog labels.
- [ ] Generate derived PNGs when masking, layer splitting, density normalization, or frame alignment cannot be represented safely by a rectangle.
- [ ] Commit deterministic derived assets and their source metadata.
- [ ] Make the runtime resolve through profile IDs instead of scattered raw paths and coordinates.

**Acceptance criteria:**

- [ ] 100% of release-referenced visuals have approved profiles.
- [ ] Zero unprofiled raw atlas crop calls remain in release code.
- [ ] Crop bounds are validated against source dimensions.
- [ ] Transparent-prop crops do not cut opaque pixels on a boundary unless explicitly approved.
- [ ] Every profile points to a valid license/provenance record.

### 8.2 Build golden contact sheets — P1

- [ ] Character field frames by direction.
- [ ] Character battle states.
- [ ] Portraits.
- [ ] Town buildings and doorway anchors.
- [ ] Common props by semantic size.
- [ ] Every universe's ground, architecture, and major landmarks.
- [ ] UI frames, icons, and battle VFX.

Each contact sheet must be reviewed at nearest-neighbor native scale. Downscaled montages are useful for composition but cannot close a one-pixel crop task.

---

## 9. Phase 4 — Expand levels to proper JRPG scale

### 9.1 Replace the repeated five-lane topology — P1

**Current condition:** Most universes block the full 28x18 container and open five 6x3 rectangles, sometimes with a narrow branch. This produces approximately 90 base walkable cells for an entire universe.

**New level standard:**

Each universe should contain a small but meaningful collection of authored maps rather than five camera-sized encounter lanes. Every universe does not need to be enormous, but it must support exploration instead of only staging.

Each universe should include:

- [ ] A readable entrance and return route.
- [ ] At least one navigational branch.
- [ ] At least one loop or shortcut.
- [ ] At least one optional treasure or interaction off the critical path.
- [ ] At least one environmental set piece.
- [ ] A distinct puzzle or traversal grammar.
- [x] A safe or low-pressure room before the main boss.
- [ ] A boss arena sized for the battle's narrative importance.
- [ ] Clear landmarks that prevent navigation from becoming identical corridors.
- [ ] Meaningful reuse after stabilization when the story calls for it.

### 9.2 Recommended vertical-slice order

#### A. Laboratory and town

- [ ] Finalize camera, player scale, doorway scale, collision, and Y-sorting.
- [ ] Ensure the laboratory reads as a real workplace instead of a large tiled showroom.
- [ ] Ensure the town supports fast repeat visits without feeling empty.

#### B. Haunted Mansion

- [ ] Expand foyer, archive, gallery, nursery, ballroom, and connecting passages.
- [ ] Add foreground walls, door frames, shelves, stairs, and chandeliers.
- [ ] Use loops/shortcuts appropriate to a puzzle mansion.
- [ ] Preserve the 4:44 clue chain and boss progression.
- [ ] Use this as the proof that crops, scale, collision, depth, and room size all work together.

#### C. Asterion Station

- [ ] Expand the dock into a real arrival bay.
- [ ] Give mess, hydroponics, medical, and control distinct footprints rather than the same 8x8 shell.
- [ ] Use hatches, pressure locks, oxygen routing, and windows as navigation landmarks.

#### D. Primeval Expanse

- [ ] Build connected outdoor paths with canopy foreground layers.
- [ ] Separate settlement, ruins, nest, and caldera through terrain and traversal, not only props.
- [ ] Add elevation/bridge cues where source art supports them.

#### E. Helios Arcology

- [ ] Break full authored quadrants into navigable foreground/background layers.
- [ ] Preserve city perspective while making routes wider and more legible.
- [ ] Distinguish market, transit, clinic, skybridge, and core through gameplay as well as scenery.

#### F. Frosthold Kingdom

- [ ] Expand gate, market, causeway, rune hall, and throne approach.
- [ ] Normalize castle, house, crystal, bridge, and character scale.
- [ ] Give the crystal causeway and rune hall real traversal identities.

#### G. Moonpetal Court

- [ ] Replace narrow processional strips with connected courtyards and gardens.
- [ ] Normalize gates, temple architecture, ponds, gardens, and characters.
- [ ] Add foreground gates and trees that characters can pass behind.

#### H. Empyreal Court

- [ ] Preserve the strongest existing composition while expanding terrace traversal.
- [ ] Add readable gravity routes, foreground columns, and platform connections.
- [ ] Avoid repeating the same small marble terrace five times.

### 9.3 Level acceptance criteria

- [ ] Every level is captured at gameplay scale and native scale.
- [ ] Every walkable cell matches visible ground.
- [ ] Every solid cell matches visible obstruction or intentional boundary.
- [ ] No route crosses black/gray void or unpainted scenery.
- [ ] No room is approved solely because a smoke test reaches its exit.
- [ ] A first-time player can identify the critical route without an invisible trigger hunt.
- [ ] Optional paths are visually signposted but not confused with the critical route.
- [ ] Backtracking time is measured and remains reasonable.

---

## 10. Phase 5 — Bring battle presentation up to the system quality

The battle rules are one of the project's strongest areas. Presentation should make their depth immediately legible.

### 10.1 Preserve and refine FFVI-inspired strengths — P1/P2

- [ ] Preserve side-view party/enemy staging.
- [ ] Preserve active/wait ATB behavior and speed options.
- [ ] Preserve formation effects, elements, status effects, individual commands, items, and results.
- [ ] Keep each actor's individual idle, attack, power, hit, victory, defeat, and death states.

### 10.2 Improve battle readability — P1

- [ ] Increase command, name, HP/MP, status, and ATB readability at the default 960x540 window.
- [ ] Ensure the selected actor and target are unmistakable.
- [ ] Give foreground and background actors consistent battle scale.
- [ ] Normalize boss scale without covering UI or party silhouettes.
- [ ] Keep command navigation compact enough to feel like a classic console JRPG.
- [ ] Ensure effects communicate element, hit, miss, resistance, weakness, healing, status, KO, and revive.
- [ ] Review animation timing with reduced-motion and reduced-flash options.

### 10.3 Battle acceptance criteria

- [ ] A player can identify whose turn is ready without reading a tooltip.
- [ ] All five party members, the companion, and all enemies remain readable simultaneously.
- [ ] UI remains legible at supported resolutions.
- [ ] Wait mode actually pauses enemy progression during command selection.
- [ ] Active mode continues according to the selected speed.
- [ ] Target legality, revive rules, and formation protection remain covered by tests.

---

## 11. Phase 6 — Browser prototype cleanup

The browser implementation is not the release target, but it is part of the repository and should not advertise failing validation or inaccessible controls.

### 11.1 Fix title-screen clipping — P1/P2

**Observed evidence:** At 800x600, `.start-card` had a 560-pixel client height and approximately 710 pixels of content while using `overflow: hidden`. Continue and save-management content were clipped.

**Tasks:**

- [ ] Constrain the grid row with `minmax(0, 1fr)` or an equivalent layout.
- [ ] Make `.start-copy` the actual scroll container.
- [ ] Ensure focus navigation scrolls focused controls into view.
- [ ] Test empty-save and populated-save title states.
- [ ] Test the expanded save manager and town-founder setup.

**Viewport matrix:**

- [ ] 800x600.
- [ ] 1024x768.
- [ ] 1280x720.
- [ ] 1366x768.
- [ ] 1440x900.
- [ ] Narrow/mobile breakpoint.

### 11.2 Clarify implementation ownership — P2

- [ ] Keep `GODOT_PROJECT.md` explicit that `game/` is the release target.
- [ ] Decide whether the browser prototype is maintained, archived, or converted into a promotional/demo build.
- [ ] Avoid duplicating new campaign systems in both implementations without a clear purpose.
- [ ] Separate browser-only asset validation from Godot release validation while keeping both green.

---

## 12. Phase 7 — Accessibility, controls, and UX sign-off

- [ ] Complete a keyboard/mouse playthrough.
- [ ] Complete a modern-controller playthrough.
- [ ] Test click-to-move around every large prop and transition.
- [ ] Test controller focus recovery after every modal and battle transition.
- [ ] Test text speed, auto-advance, reduced motion, reduced flash, audio levels, fullscreen, battle mode, and battle speed persistence.
- [ ] Check color contrast and non-color status cues.
- [ ] Verify all important prompts fit the default and smallest supported resolution.
- [ ] Verify save, backup, recovery, and migrated-save messaging.

---

## 13. Phase 8 — Performance and shutdown stability

### 13.1 Investigate the shutdown baseline — P1/P2

The isolated suite succeeds but emits repeated shutdown warnings, usually 61 ObjectDB instances and 26 resources, with some scenes reporting higher values and occasional leaked canvas RIDs.

- [ ] Run representative scenes with `--verbose`.
- [ ] Record instance/resource classes by scene.
- [ ] Separate engine/addon baseline objects from game-owned growth.
- [x] Verify whether the common 61/26 signature occurs before a smoke scene
  instantiates campaign or visual-renderer content: the empty-scene startup
  baseline reproduces it after project autoload initialization alone.
- [ ] Run a multi-hour transition, battle, menu, save/load, and sandbox soak.
- [ ] Confirm counts do not increase after repeated cycles.
- [ ] Fix game-owned retained nodes, timers, signals, viewports, textures, and RIDs.
- [ ] Document any accepted engine/addon baseline with Godot version and reproduction steps.

### 13.2 Measure real performance — P1/P2

Before M2 can be accepted, record and approve the minimum development test
machine and the numeric budgets below in `game/RELEASE_READINESS.md`. These are
provisional engineering targets; changing one requires a dated rationale and
reviewer approval.

| Metric | Provisional target |
| --- | --- |
| Logical canvas | 960x540 with integer/nearest-neighbor presentation |
| Minimum supported window | 1280x720; also verify 1920x1080, 2560x1440, 3840x2160, and a common 16:10 size |
| Field and battle frame pacing | 60 FPS target; p95 frame time at or below 16.7 ms and p99 at or below 33.3 ms on the declared minimum machine |
| Warm title-to-field load | At or below 5 seconds |
| Universe transition | At or below 2 seconds |
| Battle entry/results return | At or below 2 seconds each |
| Early/mid/postgame save and load | At or below 1 second each |
| Peak memory | At or below 1 GB, with no positive growth trend across the required soak |
| Windows package | At or below 400 MB unless a reviewed content increase justifies a new budget |

Browser viewport coverage remains separate and must retain the sizes listed in
Phase 6.

- [ ] Declare minimum CPU, GPU, memory, storage, and resolution.
- [ ] Approve or revise the provisional numeric budgets and record the decision.
- [ ] Measure title-to-field load time.
- [ ] Measure universe transition time.
- [ ] Measure battle transition and results time.
- [ ] Measure save and load duration at early, mid, and postgame states.
- [ ] Record steady-state and peak memory.
- [ ] Record frame pacing in town, every universe, full-party battle, heavy VFX, and sandbox edit mode.
- [ ] Profile import/export and first-run shader/cache behavior.

### 13.3 Reduce distribution size — P3

The current Windows executable is approximately 323 MB. The repository also retains a much larger source-art library.

- [ ] Confirm only runtime-referenced assets are exported.
- [ ] Exclude validation captures, tests, editor tooling, unused template content, and source masters.
- [ ] Confirm audio formats and bitrates are appropriate.
- [ ] Avoid duplicate runtime copies of identical assets.
- [ ] Record final executable/package size per platform.

---

## 14. Phase 9 — Licensing and release production

### 14.1 Complete provenance — P0 for release

This phase completes and packages the eligibility work begun in Phase 3; it does
not postpone per-asset distribution decisions until the end of production.

- [ ] Inventory every distributed art pack.
- [ ] Inventory every distributed audio track and sound effect.
- [ ] Inventory fonts, addons, template code, shaders, and derived assets.
- [ ] Record author, source, license, modification status, attribution requirement, and redistribution permission.
- [ ] Link every visual profile to its provenance entry.
- [ ] Consolidate required notices into shipped credits.
- [ ] Remove any asset whose distribution permission cannot be established.

### 14.2 Platform and build decisions — P0 for release

- [ ] Choose supported platforms and storefronts.
- [ ] Choose minimum hardware and supported resolutions.
- [ ] Approve the shipping version.
- [ ] Set final publisher, product, copyright, signing, and notarization metadata.
- [ ] Install matching Godot 4.7.1 export templates on release and CI machines.
- [ ] Reproduce the clean Windows release outside the editor.
- [ ] Add signing/notarization where required.

### 14.3 Required playthrough evidence — P0 for release

- [ ] Fresh keyboard/mouse playthrough 1.
- [ ] Fresh controller playthrough 2.
- [ ] Migrated-save playthrough.
- [ ] Recall during every allowed campaign phase.
- [ ] Defeat/retry at representative normal and boss encounters.
- [ ] Save/reload during partially completed puzzles.
- [ ] Backup recovery after primary-save damage simulation.
- [ ] Postgame free-roam and no-reward rematch verification.

---

## 15. Verification commands

### Browser and tracked runtime checks

```powershell
npm run check
npm run validate:runtime-assets
```

`validate:runtime-assets` is the required target command after Phase 0 splits
the validation contracts. Until then, run the tracked manifest, inventory,
contact-sheet, and provenance commands individually. This command must pass in a
fresh clone without `assets/`.

### Local source-library checks

```powershell
if (-not (Test-Path -LiteralPath '.\assets')) { throw 'Local source-art library is required.' }
npm run validate:source-library
npm run validate:assets
```

These are workstation/asset-curation gates. They become remote gates only when
CI explicitly restores an approved source-library artifact.

### Godot isolated smoke suite

```powershell
.\tools\run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 360
```

The runner discovers every `*_smoke.tscn` scene at the tested commit. A pass
requires all discovered scenes; the numerical count is recorded in the artifact
report but is not hard-coded into the milestone.

### Windows release

```powershell
.\tools\build_windows_release.ps1
```

### Visual review

Run each current or replacement validation scene with the project-local Godot
4.7.1 executable in windowed mode, then inspect the resulting image at native
scale. The universe visual-capture scenes must fail rather than claim success
when run headlessly. Automated visual-scene completion does not count as visual
approval.

Create or update the corresponding
`game/validation/reviews/YYYYMMDD-<work-package>.md` record before marking a
visual, input, or persistence gate accepted.

---

## 16. Required test matrix

| Area | Automated | Native capture | Keyboard/mouse | Controller | Save/reload | Performance |
| --- | --- | --- | --- | --- | --- | --- |
| Title/options | Required | Required | Required | Required | Required | Basic |
| Laboratory | Required | Required | Required | Required | Required | Required |
| Town/building | Required | Required | Required | Required | Required | Required |
| Mansion | Required | Required | Required | Required | Required | Required |
| Asterion | Required | Required | Required | Required | Required | Required |
| Primeval | Required | Required | Required | Required | Required | Required |
| Helios | Required | Required | Required | Required | Required | Required |
| Frosthold | Required | Required | Required | Required | Required | Required |
| Moonpetal | Required | Required | Required | Required | Required | Required |
| Empyreal | Required | Required | Required | Required | Required | Required |
| Battle | Required | Required | Required | Required | Required | Required |
| Company menus | Required | Required | Required | Required | Required | Basic |
| Sandbox | Required | Required | Required | Required | Required | Required |
| Ending/postgame | Required | Required | Required | Required | Required | Basic |

---

## 17. Milestone roadmap

### M0 — Verification green

- All browser tests discovered at the tested commit pass.
- Clean-checkout runtime-asset validation passes without `assets/`.
- Local source-library validation passes, including all 51 NPCs, when the
  approved ignored source tree is present.
- Every Godot smoke scene discovered at the tested commit passes through the
  isolated runner with `sentinel=True`.
- A draft pull request or manual dispatch records a clean remote run for the
  exact head SHA and retains its artifacts.

### M1 — Visual foundation

- Field-scale bible approved.
- Pixel-stable camera approved.
- Runtime visual-profile coverage reaches 100% for the vertical slice.
- Layered renderer works in laboratory, town, and Mansion.

### M2 — Mansion quality vertical slice

- Mansion maps expanded beyond 6x3 lanes.
- Full foreground/background traversal works.
- Crop, scale, collision, interaction, battle, save/reload, and controller sign-offs pass.
- Native-scale captures are approved.
- Every release asset used by the slice has `distribution_confirmed` provenance.

### M3 — Shared campaign systems presentation

- Battle UI readability approved.
- Company menu readability approved.
- Shared anchors, treasure, encounters, followers, transitions, and area metadata use the new architecture.

### M4 — Universe migration

M4 implementation may exist experimentally, but M4 acceptance work does not
start until M0 and M2 are accepted. Keep at most one universe migration in
acceptance review at a time so visual, input, collision, and save evidence stay
auditable.

- Asterion and Primeval complete.
- Helios and Frosthold complete.
- Moonpetal and Empyreal complete.
- Ending and postgame routes verified after migration.

### M5 — Polish and production

- Full resolution/input matrix passes.
- Performance targets pass.
- Shutdown growth is fixed or explicitly baselined.
- Browser prototype issues are resolved or the prototype is formally archived.

### M6 — Release candidate

- Licensing/provenance complete.
- Platform/version/signing decisions complete.
- Two fresh playthroughs and one migrated-save playthrough archived.
- Clean export and launch reproduced outside the editor.
- No unresolved P0 or P1 findings.

---

## 18. Project definition of done

The project is done only when all of the following are true.

### Content

- [ ] The campaign is playable from opening through ending and postgame without developer intervention.
- [ ] Every authored universe has meaningful exploration, not only encounter lanes.
- [ ] Required and optional progression communicate their purpose clearly.

### Reliability

- [ ] All automated checks pass locally and remotely.
- [ ] Fresh, migrated, backup-recovered, retry, recall, and partial-puzzle saves behave correctly.
- [ ] No known progression blocker, invalid combat target, item-ownership corruption, or save-loss defect remains.

### Presentation

- [ ] All runtime visuals have approved profiles and provenance.
- [ ] No known atlas bleed, clipped sprite, presentation-sheet fragment, wrong pivot, or inconsistent semantic scale remains.
- [ ] Characters pass correctly in front of and behind world objects.
- [ ] Town, field, battle, and menus look like parts of one game.
- [ ] Every room and major UI state has an approved native-scale capture.

### Level design

- [ ] Every walkable cell matches visible ground.
- [ ] Every major area contains meaningful navigation and at least one non-critical-path reward or interaction.
- [ ] Boss spaces and narrative set pieces have appropriate scale and staging.
- [ ] Backtracking and encounter pressure have been measured in complete playthroughs.

### UX and accessibility

- [ ] Keyboard/mouse and controller playthroughs pass.
- [ ] Supported resolutions expose all required controls and readable text.
- [ ] Reduced motion, reduced flash, text, audio, battle speed/mode, and fullscreen options work and persist.

### Performance and release

- [ ] Frame rate, frame pacing, memory, load time, save time, and package size meet declared targets.
- [ ] No uninvestigated resource growth remains across a multi-hour soak.
- [ ] Licensing, credits, platform metadata, export, signing, and external launch checks are complete.

### Sign-off rule

No level, crop, collision, UI, or battle-presentation task may be marked complete solely because it compiles or passes a smoke test. Completion requires:

1. Automated contract coverage.
2. Real traversal or interaction.
3. Native-scale visual capture.
4. Crop/scale/depth inspection.
5. Keyboard/mouse verification.
6. Controller verification.
7. Save/reload verification where state persists.
8. Recorded reviewer approval.

---

## 19. Immediate next implementation batch

Complete these tasks before adding new campaign content:

1. [x] Split clean-checkout runtime validation from local source-library
   validation and route CI to the clean-checkout command.
2. [x] Rebuild and review `curated-asset-catalog.js` for the 488 newly
   synchronized rasters, then restore the local aggregate asset gate.
3. [x] Implement the field-scale bible and logical camera baseline.
4. [ ] Record native-resolution reviewer approval for the field-scale and camera
   decisions; the implementation checkmark above is not acceptance.
5. [ ] Extend the visual-profile schema and inventory every visual used by
   laboratory, town, and Mansion.
6. [ ] Confirm distribution eligibility for every release asset used by that
   vertical slice.
7. [x] Implement a layered laboratory area as the smallest renderer proof.
8. [x] Implement one town block with Y-sorted props, foreground roofs/trees,
   aligned collision, and doorway anchors.
9. [x] Implement the expanded Mansion vertical slice.
10. [x] Implement the battle UI scale pass at the default 960x540 window.
11. [x] Implement browser title-card overflow fixes at 800x600 and 1280x720.
12. [ ] Run and record native-scale visual, keyboard/mouse, controller,
   save/reload, and provisional performance sign-off for the vertical slice.
13. [ ] Open a draft pull request or dispatch the workflow, then archive the
   first clean remote baseline for the exact tested SHA.

Only after every unchecked item in this batch is accepted should another
universe enter acceptance review. Existing M4 work remains exploratory evidence
until then.

---

## 20. Progress audit — July 22, 2026, 1:45 PM EDT

This snapshot records implementation evidence without overriding the sign-off
rule in Section 18. Broad phase checklists above remain open until their visual,
input, save, performance, and reviewer-approval criteria are all satisfied.

### Overall assessment

The plan is moving in the intended dependency order, and implementation has
advanced materially beyond the original Phase 0-only checklist state. The main
tracking problem was that completed engineering work was recorded in
`game/RELEASE_READINESS.md` and new tests but not summarized in this plan.
M0 is not green, and no later milestone is complete; M1 through M3 are active in
parallel at the implementation/proof stage.

| Milestone | Audit state | Evidence | Remaining gate |
| --- | --- | --- | --- |
| M0 — Verification green | Blocked | Browser syntax/unit checks pass 16/16; isolated Godot save sentinel remains protected; CI workflow exists locally | `npm run validate:assets` fails on 488 newly materialized source rasters; fresh Godot run was 83/84 before the deterministic test fix; workflow is not published and has no remote pass |
| M1 — Visual foundation | In progress | `FIELD_SCALE_BIBLE.md`, 254 visual profiles, runtime inventory/provenance generators, layered field registry, seven foreground scripts, camera rounding, and focused smoke tests exist | Vertical-slice profile coverage is not 100%; only 135/159 static runtime textures are profiled; native-scale review and camera/resolution sign-off remain open |
| M2 — Mansion vertical slice | In progress | Mansion layout expansion, foreground capture, collision/layout smoke coverage, and refreshed room captures exist | Full native-scale, keyboard/mouse, controller, save/reload, and reviewer sign-off has not been recorded |
| M3 — Shared presentation | In progress | Battle profile coverage, battle accessibility tests, text scaling, persisted accessibility settings, and field-layer/transition-soak tests exist | Human readability and input sign-off remain open; shared field architecture is transitional rather than a complete replacement of the procedural renderer |
| M4 — Universe migration | Started early | Each universe has an expanded 8x4 room footprint/layout contract; Asterion, Primeval, Frosthold, Moonpetal, and Empyreal foreground implementations exist; refreshed captures and layout tests exist | This work must not be called complete before M0 and the vertical-slice acceptance gates close; Helios lacks a matching foreground module, and no universe has complete human sign-off |
| M5 — Polish/production | Started, not complete | 12-cycle field transition soak, performance diagnostic scene, browser overflow work, accessibility preferences, and shutdown-baseline tests exist | Multi-hour soak, declared performance targets, resolution/input matrix, shutdown ownership decision, and browser product decision remain open |
| M6 — Release candidate | Not started | Runtime provenance ledger and local CI configuration provide foundations | Licensing review, platform/signing decisions, external clean export, remote CI, and required archived playthroughs remain open |

### Fresh verification evidence

- `npm run check`: pass, 16/16 browser tests.
- `npm run validate:assets`: fail at curated catalog coverage; 20,530 of
  21,018 detected source rasters are covered, leaving 488 uncatalogued files.
  The sample failures were created locally at approximately 1:22 PM under the
  ignored `assets/board games/` source library, after the earlier clean baseline.
- `tools/run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 360`: 83/84 scenes
  passed in 674.2 seconds. The retained artifact root is
  `test-artifacts/20260722-133147-e2949947`. The only failure was
  `opening_presentation_smoke`, whose wall-clock/frame-count assertion passed on
  immediate isolated rerun. The animation now advances its idle patrol from its
  own accumulated frame delta instead of global wall-clock time, and the test
  advances a fixed 0.8 simulated seconds without wrapping the six-frame cycle;
  three consecutive targeted isolated runs passed with `sentinel=True`. A new
  clean 84/84 aggregate run is still required before the suite is accepted.
- The validators that follow curated-catalog coverage all pass when run
  independently: NPC readiness is 51/51, and the runtime visual manifest,
  visual inventory, contact sheet, and provenance ledger are current.
- The repeated 61-ObjectDB/26-resource shutdown signature is still present.
  Several content-heavy tests exceed it, so the existing baseline investigation
  and multi-hour no-growth requirement remain necessary.

### Process improvements adopted

1. Treat this section as the audit ledger and append a dated snapshot after each
   major implementation batch; do not infer progress solely from old checkboxes.
2. Report milestone state as `not started`, `in progress`, `blocked`, or
   `accepted`. Reserve `complete` for the full Section 18 sign-off bundle.
3. Run the fast browser/unit checks and targeted changed-area Godot scenes before
   the 84-scene suite. Run the full suite only after those pass, then record its
   exact artifact root and elapsed time.
4. Rebuild the curated source catalog whenever ignored source assets are added or
   newly synchronized; otherwise the aggregate asset gate can regress without a
   tracked code change.
5. Keep the dependency guard: universe expansion may continue as exploratory
   work, but it must not displace M0 repair or M1/M2 acceptance work.

### Correct next sequence

1. Split the asset-validation contracts and make clean-checkout CI executable.
2. Rebuild/review the curated source catalog and restore the local aggregate
   asset gate.
3. Rerun and archive one clean pass of every currently discovered isolated Godot
   smoke scene.
4. Open a draft pull request or manually dispatch the workflow and record clean
   remote browser, runtime-asset, and Godot jobs for the exact head SHA.
5. Confirm distribution eligibility and finish the 24 unprofiled static runtime
   textures needed by the vertical slice.
6. Record its native-scale visual, input, save, performance, and reviewer
   acceptance evidence.
7. Only then promote the remaining universe migrations from implementation
   evidence to acceptance work.

---

## 21. Implementation-readiness amendment — July 22, 2026

This amendment closes the planning gaps found after publishing commit `8efa95e`
on `codex/ffvi-alignment-foundation`:

- CI and local source-library validation now have separate planned contracts.
- Test-suite success is discovery-based instead of tied to a stale numerical
  count.
- `implemented`, `verified`, and `accepted` are distinct states.
- Remote evidence requires a draft pull request or manual workflow dispatch for
  the exact head SHA.
- Asset distribution eligibility moves ahead of deeper vertical-slice
  integration.
- Provisional performance budgets and a concrete reviewer-evidence record are
  defined.

With these amendments, the plan needs no further structural design work before
the next implementation batch. M0 validation repair and M1/M2 acceptance remain
the critical path.
