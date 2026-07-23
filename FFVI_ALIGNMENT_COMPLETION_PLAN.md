# Franklin's Multiversal Township

## FFVI Alignment and Completion Plan

**Created:** July 22, 2026
**Expanded-world amendment:** July 22, 2026
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

- [x] `npm run validate:runtime-assets` exits 0 from a fresh clone with no local
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
- [x] Open a draft pull request or manually dispatch the workflow for the exact
  head SHA being evaluated.
- [x] Record the first clean remote pass of every smoke scene discovered at that
  commit. Record the count as evidence; do not hard-code it as the gate.
- [x] Run `npm run check` plus the clean-checkout runtime-asset command in CI.
- [x] Fail CI when the visual manifest is stale.
- [x] Retain logs for failed Godot scenes.
- [x] Prove the workflow passes from a clean checkout without the ignored
  `assets/` source library.

---

## 6. Phase 1 — Establish one coherent pixel and camera standard

### 6.1 Adopt a field-scale bible — P1

The current project combines 16-, 48-, 96-, and higher-density art with manually selected 0.5x, 1x, and 2x scales. Scaling may be mathematically integral while still being semantically inconsistent.

**Required standards:**

- [x] Keep the movement grid at 48 world pixels unless a prototype proves a better replacement.
- [x] Define a standard field-character height range.
- [x] Define doorway, single-story facade, multi-story facade, tree, counter, bed, chair, treasure, and boss size ranges relative to a character.
- [x] Require integer or exact reciprocal scaling with nearest-neighbor filtering for new field profiles.
- [ ] Prohibit arbitrary fractional scale and fractional final placement. One prototype-only Mansion profile has an explicit 0.75x migration exception pending capture-parity replacement; final-approved profiles are rejected without an approved scale.
- [x] Define foot anchors and collision bases separately from visible image bounds.
- [x] Define battle-sprite scale separately from field-sprite scale.
- [x] Define portrait crops separately from both field and battle frames.

**Suggested density conversions:**

| Source density | World conversion |
| --- | --- |
| 16-pixel tile art | 3x nearest to 48 world pixels |
| 24-pixel tile art | 2x nearest to 48 world pixels |
| 48-pixel tile art | 1x native |
| 96-pixel tile art | 0.5x nearest to 48 world pixels |

These are starting rules, not permission to combine visually incompatible packs without art direction.

### 6.2 Lock a pixel-stable camera — P1

- [x] Choose the intended logical resolution and document why it fits the field scale.
- [x] Ensure the camera lands on integer world pixels after following and transitions.
- [x] Verify one-tile movement at the default window size, native 1080p, 1440p, 4K, and common 16:10 sizes through deterministic camera-frame coverage.
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

#### Expansion-library admission contract

Three local source roots are now explicit inputs to the larger-world program:

- `assets/EXPANSION/`: 63,303 staged files, including 61,760 images and many
  duplicated engine demos, resolution variants, source documents, and
  non-runtime files.
- `assets/Tilesets/`: 149 top-level environment packs, 5,715 files, and 4,904
  images (about 2.14 GB). This is the primary authored environment library for
  the 102-room expansion, not a legacy folder to be sampled incidentally.
- `assets/characters/SakPix - 8-Direction Characters - ALL AS OF 7-3-26/`:
  25 themed collections, 267 character folders, and 2,213 images.

These are source libraries, not runtime folders. No map, scene, profile, or
save record may depend directly on either long staging path. The admission
pipeline must select the smallest useful source set, assign a stable pack and
asset ID, record its checksum and license evidence, generate any normalized
runtime derivative, and then reference that approved derivative through the
visual-profile system.

The SakPix root and per-pack license files state CC0 1.0 terms. The Tilesets
root also contains a CC0 1.0 license, while the staged monster and SciGo roots
and the Kelvana Prime pack contain CC0 terms. The recorded license scope still
has to be bound to every admitted pack and derived crop. This evidence does not
establish the status of every other expansion folder: the broader
staging tree includes credit lists, bundled RPG Maker projects, and material
with named third-party credit requirements. Each pack still requires its own
provenance decision; a neighboring CC0 file must never be treated as covering
an unrelated pack.

- [ ] Generate a deterministic expansion inventory grouped by pack, file type,
  dimensions, checksum, duplicate family, and likely world assignment.
- [ ] Give all 149 `assets/Tilesets` packs an explicit disposition: primary
  world kit, secondary compatible kit, optional-address kit, duplicate, reserve,
  or rejected. No top-level pack may be silently omitted from the inventory.
- [ ] Assign every shortlisted pack `distribution_confirmed`,
  `review_required`, or `rejected`; retain the exact license/terms file in the
  provenance record.
- [ ] Exclude bundled executables, saves, JavaScript projects, fonts, demos,
  preview art, PSD working files, and redundant RPG Maker density variants from
  runtime import unless a reviewed work package explicitly needs them.
- [ ] Choose one density/source variant per admitted tileset and document the
  conversion to the 48-pixel movement grid.
- [ ] Detect identical and near-identical files before copying any staged art
  into the approved source library.
- [ ] Build per-world candidate contact sheets before map construction; approve
  palette, perspective, density, and semantic scale as a set rather than one
  prop at a time.
- [ ] Add a validation rule that fails when release code references
  `assets/EXPANSION/`, `assets/Tilesets/`, or the long SakPix staging root
  directly instead of an admitted runtime derivative/profile.
- [ ] Rebuild the curated catalog only from admitted files. The remaining
  staging tree stays quarantined and does not inflate the approved-library
  denominator.

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

**New level standard:** Each universe becomes a connected collection of authored
zones rather than five enlarged encounter boxes. Scaling the old geometry or
repeating decorative filler does not count as expansion.

The following are minimum production targets. A work package may exceed them.
Reducing one requires playtest evidence and explicit reviewer approval; unused
space, inaccessible scenery, or splitting one old room at an arbitrary seam
cannot satisfy the count.

| Measure | Required target per main universe |
| --- | --- |
| Authored rooms/zones | 14-16 according to the locked per-universe budget below |
| Distinct camera compositions | 16-24, with landmarks rather than repeated shells |
| Walkable footprint | 900-1,800 useful cells after collision, approximately 10-20x the current 90-cell baseline |
| First critical-path visit | 16-30 minutes excluding battles and dialogue |
| Stabilized return route | 3-7 minutes after opening meaningful shortcuts |
| Optional content | At least 4 detours, 2 substantial reward spaces, and 2 world-reactive interactions |
| Population | 16-30 active local character identities per population state, adjusted for intentionally lonely or hostile areas; additional identities may rotate by story phase |
| Boss staging | Dedicated approach, safe/reset space, and arena composition that is not a reused corridor |

#### Locked room budget

| Universe | Critical-route rooms | Optional rooms | Connective/shortcut rooms | Total |
| --- | ---: | ---: | ---: | ---: |
| Haunted Mansion | 9 | 4 | 3 | **16** |
| Asterion Station | 8 | 4 | 2 | **14** |
| Primeval Expanse | 8 | 4 | 2 | **14** |
| Helios Arcology | 8 | 4 | 2 | **14** |
| Frosthold Kingdom | 8 | 4 | 2 | **14** |
| Moonpetal Court | 8 | 4 | 2 | **14** |
| Empyreal Court | 9 | 5 | 2 | **16** |
| **Campaign-universe total** | **58** | **29** | **15** | **102** |

A room is an authored playable area with its own topology, recognizable
landmark, and encounter, interaction, traversal, puzzle, narrative, or reward
purpose. A short hallway, loading seam, palette swap, empty field, or duplicated
layout does not become a room merely because it has a separate scene or camera
boundary. One continuous map may contain multiple rooms only when their spatial
boundaries and gameplay identities are clear during play.

Useful cells must support navigation, staging, discovery, interaction, or
visual orientation. Inaccessible filler behind walls, duplicated empty floor,
and scenery outside the playable camera do not count toward the footprint.

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
- [ ] At least one vista or landmark visible before it becomes reachable.
- [ ] At least one state change that alters residents, access, scenery, or
  traversal after the universe is stabilized.
- [ ] Encounter-free breathing room between major pressure sequences.

### 9.2 Populate worlds with associated 8-direction characters — P1

The SakPix library is the default source for new ambient residents, guards,
specialists, witnesses, and local rivals. Existing named recruits and story
actors keep their identities unless a reviewed narrative work package replaces
them. Generic placeholders must not remain where an approved, thematically
associated SakPix character is available.

Most SakPix packs contain 10-11 characters with eight directional PNGs named
`north`, `north-east`, `east`, `south-east`, `south`, `south-west`, `west`, and
`north-west`. Source frames range from 84x84 to 124x124, so importing them at
one common scale without normalization is prohibited. The Premium Enchanted
Forest collection currently has complete rotation folders for only 6 of its 14
character folders; the other eight contain no rotation PNGs. Frontier
`7._DYNAMITE_BILL` has seven directions but lacks `east.png`. The verified
usable total is therefore 258 fully eight-direction identities out of 267
character folders. These nine incomplete identities are quarantined and cannot
be claimed as eight-direction-ready or assigned to a moving population slot.

#### Character integration contract

- [ ] Create a data-driven world-population registry with stable NPC ID, source
  pack, eight direction paths, normalized foot anchor, field scale, home world,
  home zone, story phase, schedule/patrol, dialogue bark, interaction role,
  collision policy, visual profile, and provenance ID.
- [ ] Generate one native-scale contact sheet per pack showing all eight
  directions on the shared field grid before any character receives final
  approval.
- [ ] Normalize visible height and foot placement without stretching source
  pixels or anchoring from transparent canvas bounds.
- [ ] Preserve the last travel direction while idle and use diagonal art for
  diagonal motion. A character advertised as 8-direction must not collapse to
  four directions at runtime.
- [ ] Give every moving resident a bounded route, wait behavior, and occupancy
  rule so it cannot block a doorway, transition, treasure, anchor, or puzzle.
- [ ] Persist story-phase relocation and one-time dialogue where required; do
  not serialize transient frame state or pathfinding internals.
- [ ] Give every one of the 25 collections a recorded disposition: assigned to
  a core world, assigned to an optional annex, reserved with a reason, or
  rejected. No collection may silently disappear from planning.
- [ ] Represent every assigned core collection with at least two approved
  identities and use at least 70% of the rotation-complete identities in its
  primary world across first-visit, stabilized, and postgame population states.
- [ ] Target the population range in Section 9.1 without placing every resident
  on one screen; use schedules, interiors, patrols, and post-stabilization
  arrivals to keep composition readable.

#### Pack-to-world assignment

| Destination | Mandatory core SakPix collections | Supporting or conditional use |
| --- | --- | --- |
| New Philadelphia and facilities | Cozy Village NPC Collection Vol.1; Kingdom Citizens | Steampunk Empire at the Observatory, Armory, workshops, and Belfry machinery |
| Haunted Mansion | Crimson Vampire Hunters; Dark Gothic Fantasy; Psychological Horror Dungeon | Dark Fantasy Dungeon Heroes and Nightmare Slashers as trapped explorers, apparitions, or hostile field actors; Legendary Infernal characters only in the sealed undercroft |
| Asterion Station | SCI-FI LEGENDS | Warfront Elite as station security/boarding personnel; selected Steampunk engineers only through the Observatory connection |
| Primeval Expanse | Beastfolk Legends; Premium Enchanted Forest | Dragonborn Champions at the caldera/roost; Frontier Legends only in a distinct borough or trailhead annex |
| Helios Arcology | Cyberpunk Neon Fantasy | Heroic Legends as solar civic icons; Ring Legends and World Championship Heroes inside the optional recreation stack rather than scattered through civic areas |
| Frosthold Kingdom | Frozen Kingdom Fantasy | Frost, holy, and celestial identities from Arcane Magic & Witchcraft; do not import fire/necromancer identities without a specific opposing faction |
| Moonpetal Court | Eternal Samurai & Yokai Warriors | Nature/blossom identities from Premium Enchanted Forest and appropriate fox/cat/owl/rabbit Beastfolk as court visitors |
| Empyreal Court | Heroic Legends | Holy/celestial Arcane identities and Dragonborn envoys on upper terraces |
| Ashfall optional annex | Wasteland Legends; Legendary Infernal Kingdom Champions | Uses the Ashlands, cursed-land, lava, and post-apocalypse environment families after the main worlds meet their size targets |
| Pelagic optional annex | Summer Beach Girls; Atlantis Royal Guard | Uses Beach Tileset and Seabed; it remains an annex rather than diluting an unrelated core universe |

Collections listed in more than one row are split by named identity, not cloned
as unrelated copies. The population registry must give each identity one
canonical home and explain any intentional multiverse cameo.

### 9.3 Supplied environment asset map

`assets/Tilesets` is the primary environment source. `assets/EXPANSION` is a
supplemental source for missing transitions, monsters, VFX, and alternate
density options. The following mapping is a curation contract, not automatic
approval and not permission to combine every listed pack in one room.

| Destination | Primary `assets/Tilesets` kits | Secondary/supplemental kits | Content role |
| --- | --- | --- | --- |
| New Philadelphia | Modern World Overworld; Medieval village town; Cozy farming village; Cozy Spring; Modern Laboratory Assets | Cafe/Cozy Cafe, Environment Decor, Farm Assets, Fantasy Structures & Props, SciGo nature | Larger civic, residential, farming, shoreline, laboratory, and facility districts with coherent building scale |
| Haunted Mansion | **Haunted Mansion**; Crimson Gothic Castle | Haunted Mansion Pixel Art duplicate family, Psychological Horror Dungeon, Dark Gothic City, Ruined Dungeon, undead land objects, Abandoned Hospital | Purpose-built exterior/interior shell, staircases/clocks/furniture, then grand-room and undercroft variation without abandoning the house's visual identity |
| Asterion Station | **Space Station Interior Tileset**; Scifi space station; Sci-Fi Spaceship Interior | Asteroid Base, Moon Base, Infected Spaceship, Galacti-Chron Kelvana/Interstellar/Warehouse | Complete hydroponics, medical, cargo, armory, observation, pressure-door, maintenance, and command vocabularies |
| Primeval Expanse | **Jurassic world**; Alien Jungle; Rainforest Survival; Stone Age Modern Life | Jungle Tileset, Forest Wilderness, Magic/fairy forest, fungus cave, belly of the monster, Volcanic | Purpose-built prehistoric terrain, fossils, ruins, eggs/nests, camp props, alien flora, cave, canopy, and caldera transitions |
| Helios Arcology | **Cyberpunk City Tileset**; Bright Cyberpunk; Cyberpunk Pixel Art; Tokyo Nights | Modern Subway, Modern Arcade, Modern Bar & Nightclub, Modern Pharmacy, Modern Office, XModern Arcade, selected Galacti transit | Distinct skybridge, market, subway, clinic, rooftop, nightlife, civic, service, and recreation districts |
| Frosthold Kingdom | **Frozen kingdom**; Frostbound viking village; Snowy Village | Crystalice Forest, ICE CAVERN, Antarctic Research Station, Time Fantasy winter, selected Final Tower | Full castle/village/market/bridge/rune/cave vocabulary plus lived-in settlement and strong magical-ice set pieces |
| Moonpetal Court | **Sakura Temple Asset Pack**; Dreamy World | Tokyo Nights sakura/street details, Magic Forest, Royal Props, fairy forest | Temple facades, gates, framed gardens, ponds, bridges, tea service, lanterns, memory reflections, and dream-state variants |
| Empyreal Court | **Ancient Greek Mythology**; Roman Empire; Flying Islands | Cloud City, GOLDEN PALACE, Final Tower, Dreamy World cloud terrain | Marble roads, columns, stairs, statues, forum, market, reliquary, cloud bridges, floating vegetation, and tribunal interiors |
| Ashfall optional address | Green-Apocalyptic Ruins; Wasteland survivor kit; Desert Wasteland | Ashlands, cursed land, Dark Dimension, Lava Cavern, Nuclear War Ruins, Post-Apocalyptic sets, scorched desert | Coherent home for Wasteland and Infernal rosters rather than contaminating Primeval or Mansion |
| Pelagic optional address | Underwater Ocean Depths; Underwater World & Sunken Ruins; Seabed | Beach, Survival Island, Pirate harbor, Luxury Cruise Ship | Coherent surface-to-depth route for Summer Beach and Atlantis rosters |
| Steamforge optional address | Steamforged industrial; Steampunk Pixel Art; Ferrum Junkyard/Slums | Factory Ruins, Dark Steel City, Dieselpunk Houses, Modern Industrial Factory | Bridges, boilers, tanks, slums, foundries, and airship-industry spaces for the Steampunk roster |
| Frontier optional address | Wild West Pixel Art; Ranch Stuff | Farm, scorched desert, Survival Shelter, Desert Arabian Nights | Settlement, rail, ranch, canyon, and mine vocabulary for Frontier characters |
| Warfront optional address | World War I Trench Warfare; WW1 Trench & Bunker; WW1/WWII Ruins | Normandy Landing, Medieval Battlefield, Forest Warzone, Modern Military Submarine | A contained war-history rift for Warfront characters; it must not turn Asterion into a generic military base |

#### Complete `assets/Tilesets` disposition register

This register prevents attractive packs from disappearing behind broad category
names. `Core-P` means a required primary core-world kit; `Core-S` means a
required supporting core-world kit with a bounded role; `Annex` means a named
optional address that does not count toward the 102 core rooms; `Reserve` means
hold for a separately approved transition, anomaly, or district; `Support` is a
non-environment population/UI/enemy source; and `Duplicate` means quarantine
until checksum and content comparison select one canonical source. Disposition
is not license acceptance: every admitted file still passes Section 8.

The file/image counts below are the July 22, 2026 source snapshot. Every one of
the 149 top-level directories has exactly one row. The rows total 5,714 files
and 4,904 images; adding the root `license.txt` yields the stated 5,715-file
folder total. Disposition totals are 25 `Core-P`, 54 `Core-S`, 53 `Annex`, 6
`Reserve`, 4 `Support`, and 7 `Duplicate` directories.

| Top-level pack | Files / images | Disposition | Locked destination or reason |
| --- | ---: | --- | --- |
| `Abandoned Hospital Tileset` | 4 / 4 | Core-S | Mansion medical/servants decay in `HM-04`, `HM-12`, or a documented side-room derivative only |
| `Abandoned Nuclear Bunker Pixel Art Tileset` | 8 / 8 | Annex | Ashfall bunker exterior and blast-door vocabulary |
| `Airplane Interior & Exterior Pixel Art Tileset Pack` | 5 / 5 | Reserve | New Philadelphia airport/transport anomaly; do not place inside Asterion |
| `Alien Jungle Tileset` | 7 / 7 | Core-P | Primeval alien-canopy contrast in `PV-04` through `PV-07` |
| `Ancient Greek Mythology` | 20 / 20 | Core-P | Empyreal marble, temples, stairs, fountains, statues, markets, and divine tiles |
| `Antarctic Research Station Pixel Tileset` | 7 / 7 | Core-S | Frosthold `FR-02` relief/field station props, not the kingdom's base architecture |
| `Ashlands Tileset` | 16 / 16 | Annex | Ashfall ground, ash drifts, dead terrain, and infernal boundary |
| `Asteroid Base Pixel Art Tileset` | 7 / 7 | Core-S | Asterion structural maintenance and `AS-11` trial shell |
| `Backrooms Pixel Art Tileset` | 11 / 11 | Reserve | Standalone anomaly address only; its visual grammar does not enter a core world |
| `Backrooms Poolcore Pixel Art Tileset` | 9 / 9 | Reserve | Standalone liminal/pool anomaly, optionally reached from Pelagic |
| `Beach Tileset` | 5 / 5 | Annex | Pelagic surface landing and beach-to-harbor transition |
| `belly of the monster` | 27 / 27 | Core-S | Primeval relay interior accents in `PV-07` only; never general terrain |
| `Bright Cyberpunk Pixel Art Tileset Pack` | 8 / 8 | Core-P | Helios luminous civic facade, market, and rooftop material |
| `Cafe Assets` | 33 / 32 | Core-S | Canonical cafe/interior candidate for New Philadelphia and Moonpetal service props |
| `Cloud City Tileset` | 22 / 22 | Core-S | Empyreal lift, ferry, moving-cloud, and high-terrace accents |
| `Cozy Cafe Asset Pack` | 32 / 32 | Duplicate | Candidate duplicate of `Cafe Assets`; quarantine until checksums choose the canonical set |
| `Cozy farming village` | 20 / 20 | Core-P | New Philadelphia farm/residential outskirts and lived-in prop vocabulary |
| `Cozy Spring Asset Pack` | 20 / 20 | Core-P | New Philadelphia spring shoreline, vegetation, paths, bridges, and town transitions |
| `Crimson Gothic Castle` | 28 / 28 | Core-P | Mansion grand architecture for `HM-06`, `HM-08`, `HM-09`, and chapel/undercroft boundaries |
| `Crystalice Forest` | 5 / 5 | Core-S | Frosthold `FR-10` safe-trail crystal animation and forest landmark kit |
| `cursed land` | 86 / 85 | Annex | Ashfall cursed districts; a tightly cropped subset may support Mansion undercroft after approval |
| `Cyberpunk City Tileset` | 23 / 23 | Core-P | Helios base city kit for skybridge, street, market, civic, and service districts |
| `Cyberpunk Pixel Art` | 20 / 20 | Core-P | Canonical candidate for Helios architecture/props after duplicate comparison |
| `Cyberpunk Pixel Art Asset Pack` | 20 / 20 | Duplicate | Candidate duplicate of `Cyberpunk Pixel Art` |
| `Dark Dimension Tileset` | 20 / 20 | Annex | Ashfall void boundary or a future anomaly; not generic Mansion filler |
| `Dark Gothic City Pixel Art Tileset Pack` | 9 / 9 | Core-S | Mansion exterior apparitions, sealed streetscape vista, and postgame visitors |
| `Dark RPG GUI Kit - Pixel Art Asset Pack` | 43 / 43 | Support | UI candidate only; excluded from room-tileset counts and requires a separate UI profile review |
| `Dark Steel City Tileset` | 6 / 6 | Annex | Steamforge heavy-city shell; limited Helios undercity use requires a district transition record |
| `Desert arabian nights` | 20 / 20 | Annex | Frontier desert settlement/market address |
| `Desert Wasteland Pixel Tileset` | 6 / 6 | Annex | Ashfall and Frontier badlands transition kit |
| `Dieselpunk Houses` | 1 / 1 | Annex | Steamforge residential silhouette and skyline |
| `Dreamy World Pixel Art Tileset Pack` | 7 / 7 | Core-P | Moonpetal memory/reflection layer; Core-S for Empyreal cloud-state variants |
| `Dungeon Asset Pack` | 15 / 15 | Core-S | Mansion reusable dungeon/crypt props after perspective and density review |
| `Elven Forest Asset Pack` | 2 / 2 | Reserve | Future forest enclave; Primeval use requires proof it does not dilute the prehistoric identity |
| `Environment Decor` | 60 / 60 | Core-S | New Philadelphia shared outdoor props through semantic-size profiles |
| `Factory Monster Pack 1` | 10 / 10 | Support | Steamforge enemy/encounter source, not walkable terrain |
| `Factory Ruins Pixel Art Tileset Pack` | 5 / 5 | Annex | Steamforge ruined foundry and machinery district |
| `fairy forest` | 40 / 40 | Core-S | Moonpetal dream-garden and Primeval post-stabilization flora, never base ground |
| `Fantasy Forest RPG Maker Tileset` | 1 / 1 | Reserve | Density-variant forest source held until a specific conversion proves useful |
| `Fantasy Houses Tileset` | 1 / 1 | Core-S | New Philadelphia peripheral house silhouettes after scale approval |
| `Fantasy Structures & Props - Pixel Art Asset Pack` | 56 / 56 | Core-S | New Philadelphia civic/farm structures and reusable prop profiles |
| `Farm Assets` | 7 / 7 | Core-S | Canonical farm-detail candidate for New Philadelphia |
| `Farm Tileset - Pixel Art` | 7 / 7 | Duplicate | Candidate duplicate of `Farm Assets` |
| `Ferrum Junkyard 1` | 1 / 1 | Annex | Steamforge junkyard ground/structure sheet |
| `Ferrum Junkyard Heroes` | 36 / 32 | Support | Steamforge residents/enemies; population source, not environment geometry |
| `Ferrum Tileset Dieselpunk Slums 1` | 1 / 1 | Annex | Steamforge lower-slum district, first sheet |
| `Ferrum Tileset; Dieselpunk Slums 2` | 1 / 1 | Annex | Steamforge lower-slum district, complementary second sheet |
| `Final Tower` | 44 / 44 | Core-S | Empyreal archive/tribunal vertical details and Frosthold final-court accents only |
| `Flying Islands` | 124 / 110 | Core-P | Empyreal ground, bridges, clouds, waterfalls, rocks, plants, animated landmarks, and ferry platforms |
| `Forest Warzone Pixel Art Tileset Pack` | 9 / 9 | Annex | Warfront forest campaign district |
| `Forest Wilderness Pixel Art Tileset Pack` | 11 / 11 | Core-S | Primeval canopy outskirts and river transition terrain |
| `Frostbound viking village` | 21 / 21 | Core-P | Frosthold inhabited village, bridges, docks, market, armory, totems, and set pieces |
| `Frozen kingdom` | 20 / 20 | Core-P | Frosthold castle, snow ground, paths, cliffs, houses, market, runes, bridges, and monuments |
| `fungus cave` | 79 / 79 | Core-S | Primeval `PV-09` base kit and cave transition accents |
| `Futuristic War Ruins Pixel Art Tileset Pack` | 10 / 10 | Annex | Warfront future-battle rift; never a substitute for Asterion's station identity |
| `Gaming room interiors` | 20 / 20 | Core-S | Helios `HE-11` recreation stack and controlled New Philadelphia leisure interior use |
| `GOLDEN PALACE` | 4 / 4 | Core-S | Empyreal `EM-09` and `EM-14` high-value interiors after density normalization |
| `Great War RPG Maker Houses` | 2 / 2 | Annex | Warfront rear-line settlement; RPG Maker density requires explicit conversion |
| `Green-Apocalyptic Ruins Tileset` | 13 / 13 | Annex | Ashfall overgrown urban ruins and reclamation-state variant |
| `Haunted Mansion` | 5 / 5 | Core-P | Mansion canonical exterior/interior, stair, clock, chandelier, furniture, and damaged-house vocabulary |
| `Haunted Mansion Pixel Art Tileset Pack` | 10 / 5 | Duplicate | Alternate packaging of `Haunted Mansion`; quarantine extra wrappers/demos |
| `ICE CAVERN` | 5 / 5 | Core-S | Frosthold `FR-11` blueglass cavern base |
| `Infected Spaceship Interior Horror Tileset Pack` | 10 / 10 | Core-S | Asterion quarantined maintenance/horror pocket; do not recolor the whole station |
| `Jungle Tileset` | 13 / 13 | Core-S | Primeval water, vegetation, and route-transition support |
| `Jurassic world` | 22 / 22 | Core-P | Primeval's full prehistoric vocabulary: terrain, fossils, ruins, nests, tools, tracks, dinosaurs, and young variants |
| `Lava Cavern` | 4 / 4 | Core-S | Primeval `PV-14` and caldera under-route; Annex support for Ashfall |
| `Level Map Assets Pixel Art` | 255 / 252 | Support | World-map/diagram/UI candidate; prohibited as room terrain without a separate interface work package |
| `Luxury Cruise Ship Pixel Art Tileset Pack` | 8 / 8 | Annex | Pelagic surface hub/interior |
| `Magic Forest Asset Pack` | 17 / 17 | Core-S | Moonpetal magical-garden details and narrowly approved Primeval restoration flora |
| `Magic wizard academy` | 20 / 20 | Core-S | New Philadelphia research/archive interiors and Belfry educational spaces |
| `Mars Base Tileset` | 7 / 7 | Core-S | Asterion remote-base observation or optional maintenance pocket, distinct from station core |
| `Medieval Army Camp Tileset Pack` | 6 / 6 | Annex | Warfront early-history camp or New Philadelphia historical event only |
| `Medieval Battlefield & Ruins Pixel Art Tileset Pack` | 9 / 9 | Annex | Warfront medieval battle layer |
| `Medieval Castle Fantasy - Pixel Art Tileset` | 9 / 9 | Core-S | New Philadelphia civic/fortified boundary; limited Mansion exterior derivative if profile-approved |
| `Medieval Fantasy Dungeon & Prison Pixel Art Tileset Pack` | 7 / 7 | Core-S | Mansion undercroft/prison service spaces |
| `Medieval Fantasy Town Pixel Art Tileset Pack` | 16 / 16 | Core-S | New Philadelphia dense old-town district |
| `Medieval Plague Town Tileset` | 7 / 7 | Core-S | Mansion sealed exterior-memory vista or Ashfall annex; no ordinary town reuse |
| `Medieval Siege & Castle Tileset` | 8 / 8 | Annex | Warfront siege district |
| `Medieval village town` | 21 / 21 | Core-P | New Philadelphia main old-town architecture, streets, shops, and residences |
| `Modern Airport Pixel Art Tileset Pack` | 7 / 7 | Core-S | New Philadelphia transit district paired with the airplane reserve only if authored |
| `Modern Arcade Game Center Pixel Art Tileset Pack` | 5 / 5 | Core-S | Helios `HE-11` arcade subset; canonical relationship to `XModern Arcade` must be checked |
| `Modern Bar & Nightclub` | 6 / 6 | Core-S | Canonical candidate for Helios nightlife interior |
| `Modern Bar & Nightclub Pixel Art Tileset Pack` | 6 / 6 | Duplicate | Candidate duplicate of `Modern Bar & Nightclub` |
| `Modern Construction Site Pixel Art Tileset Pack` | 8 / 8 | Core-S | New Philadelphia growth district or Helios service works with bounded construction hazards |
| `Modern Gas Station Pixel Art Tileset Pack` | 5 / 5 | Core-S | New Philadelphia roadside district; no random sci-fi placement |
| `Modern Gym Fitness Center Pixel Art Tileset Pack` | 5 / 5 | Core-S | Helios recreation stack or New Philadelphia civic interior |
| `Modern Industrial Factory Pixel Art Tileset Pack` | 6 / 6 | Annex | Steamforge clean industrial district; Helios use requires a specific undercity boundary |
| `Modern Interior Pixel Art Tileset` | 9 / 9 | Core-S | New Philadelphia apartments/offices and Helios ordinary resident interiors |
| `Modern Laboratory Assets` | 9 / 9 | Core-P | Canonical New Philadelphia laboratory/facility kit candidate |
| `Modern Laboratory Pixel Art Tileset Pack` | 14 / 7 | Duplicate | Alternate laboratory packaging; compare sheets and wrappers before selecting canonical files |
| `Modern Military Submarine Pixel Art Tileset Pack` | 5 / 5 | Annex | Warfront/Pelagic crossover address only |
| `Modern Office Interior Tileset` | 4 / 4 | Core-S | Helios civic administration and New Philadelphia offices |
| `Modern Pharmacy Pixel Art Tileset Pack` | 5 / 5 | Core-S | Helios `HE-06` clinic support and New Philadelphia retail health interior |
| `Modern Prison Pixel Art Tileset Pack` | 10 / 10 | Reserve | Future justice/anomaly district; not needed for the 102-room core |
| `Modern Restaurant` | 7 / 7 | Core-S | Canonical candidate for New Philadelphia and Helios food interiors |
| `Modern Restaurant Pixel Art Tileset Pack` | 5 / 5 | Duplicate | Possible trimmed/alternate `Modern Restaurant` family; compare before admission |
| `Modern Subway Station Tileset Pack` | 6 / 6 | Core-S | Helios `HE-04`, `HE-13`, and transit-node visual grammar |
| `Modern Waste Management Plant Pixel Art Tileset Pack` | 5 / 5 | Core-S | Helios service undercity or Ashfall entry transition, never a generic prop dump |
| `Modern World Overworld Pixel Tileset` | 14 / 7 | Core-P | New Philadelphia modern roads, civic blocks, shoreline, and overworld transitions |
| `Monder Interiors` | 4 / 4 | Core-S | New Philadelphia ordinary interiors; retain source spelling in provenance |
| `Moon Base pixel art Tileset` | 9 / 9 | Core-S | Asterion lunar outpost/observation details and sealed optional room |
| `Normandy Landing Pixel Art Tileset Pack` | 9 / 9 | Annex | Warfront coastal battle district |
| `Nuclear Bunker Interior Pixel Art Tileset` | 7 / 7 | Annex | Ashfall bunker interior paired with the abandoned bunker exterior |
| `Nuclear War Ruins Tileset` | 10 / 10 | Annex | Ashfall destroyed-city district |
| `Pirate Age Pixel Tileset Pack` | 10 / 10 | Annex | Pelagic pirate route, ships, and port support |
| `Pirate harbor` | 21 / 21 | Annex | Pelagic major harbor and surface settlement |
| `Post-Apocalypse Pixel Art` | 1,386 / 1,386 | Annex | Ashfall broad prop/terrain library; aggressively deduplicate and profile only used cells |
| `Post-Apocalyptic Abandoned Supermarket Tileset` | 455 / 452 | Annex | Ashfall supermarket dungeon; exclude previews/wrappers and admit only used derivatives |
| `Post-Apocalyptic Polluted Wasteland Pixel Art Tileset Pack` | 8 / 8 | Annex | Ashfall toxic exterior |
| `Post-Apocalyptic Subway Station Tileset Pack` | 5 / 5 | Annex | Ashfall underground transit route |
| `Post-Apocalyptic War Ruins Tileset` | 17 / 17 | Annex | Ashfall/Warfront ruined conflict boundary |
| `Post-Apocalyptic Wasteland Survival Farm Tileset` | 5 / 5 | Annex | Ashfall inhabited recovery district |
| `Post-Apocalyptic Zombie City Tileset` | 8 / 8 | Annex | Ashfall infected city district |
| `Psychological Horror Dungeon` | 16 / 16 | Core-S | Mansion mechanisms, mirrors, apparition rooms, and undercroft mood layer |
| `Rainforest Survival Pixel Art Tileset Pack` | 11 / 11 | Core-P | Primeval canopy, rivers, bridges, survival props, and layered traversal |
| `Ranch Stuff` | 1,386 / 634 | Annex | Frontier ranch/rail settlement; reject engine/demo payloads and admit only deterministic derivatives |
| `Roman Empire Pixel Art Tileset` | 14 / 14 | Core-P | Empyreal forum, roads, stands, civic props, and tribunal floor language |
| `Royal Props collection` | 1 / 1 | Core-S | Mansion, Moonpetal, and Empyreal high-status props after crop/scale approval |
| `Ruined Dungeon` | 28 / 28 | Core-S | Mansion chapel/undercroft and bounded Primeval ancient-ruin transitions |
| `Sakura Temple Asset Pack` | 20 / 20 | Core-P | Moonpetal complete temple, roof, gate, garden, pond, bridge, lantern, cafe, and furnishing vocabulary |
| `Sci-Fi Spaceship Interior Tileset Pack` | 10 / 10 | Core-P | Asterion cargo, weapons, lockers, machinery, and ship-interior details |
| `Scifi space station` | 21 / 21 | Core-P | Asterion canonical floors, walls, airlocks, observation, consoles, lab, power, pipes, cargo, hazards, and props |
| `scorched desert` | 3 / 3 | Annex | Frontier/Ashfall transition ground |
| `Seabed` | 26 / 15 | Annex | Pelagic seabed base; inspect non-image payload and retain only runtime derivatives |
| `Snowy Village Pixel Art Asset Pack` | 20 / 20 | Core-P | Frosthold village houses, food, residents' props, magic ice, and thawed-state details |
| `Space Station Interior Tileset` | 5 / 5 | Core-P | Asterion large authored room sheets, especially hydroponics, medical, and pressure-door compositions |
| `Steamforged industrial` | 21 / 21 | Annex | Steamforge bridges, boilers, pipes, tanks, platforms, and industrial set pieces |
| `Steampunk Pixel Art Tileset` | 11 / 11 | Annex | Steamforge civic/airship architecture; a small admitted subset supports New Philadelphia Observatory machinery |
| `Stone Age Modern Life Pixel Art Tileset Pack` | 9 / 9 | Core-P | Primeval `PV-03` borough homes, civic props, and anachronistic-comedy identity |
| `Supermarket Tileset` | 11 / 11 | Core-S | New Philadelphia active supermarket/interior, contrasted with Ashfall's abandoned version |
| `Survival Island Pixel Art Tileset` | 7 / 7 | Annex | Pelagic island approach and resource route |
| `Survival Shelter Tileset` | 9 / 9 | Annex | Ashfall or Frontier protected settlement |
| `Time Fantasy winter` | 19 / 19 | Core-S | Frosthold transition/legacy winter details after density normalization |
| `Tokyo Nights` | 20 / 20 | Core-S | Helios street/night district and a bounded Moonpetal artisan-lane accent set |
| `undead land objects` | 140 / 139 | Core-S | Mansion grave/undercroft props; broader use belongs in Ashfall |
| `Underwater Ocean Depths` | 20 / 20 | Annex | Pelagic deep-ocean terrain, fauna silhouettes, and pressure transition |
| `Underwater World & Sunken Ruins Pixel Art Tileset` | 8 / 8 | Annex | Pelagic submerged-city/ruin district |
| `Viking Age Pixel Art Tileset Pack` | 6 / 6 | Core-S | Frosthold lived-in Viking props and settlement variation |
| `Volcanic` | 21 / 21 | Core-S | Primeval `PV-08` caldera and `PV-14` lava-tube transitions |
| `Wasteland Abandoned Parking Lot Pixel Art Tileset Pack` | 5 / 5 | Annex | Ashfall urban approach |
| `Wasteland School Pixel Art Tileset` | 7 / 7 | Annex | Ashfall community-history side district |
| `Wasteland survivor kit` | 20 / 20 | Annex | Ashfall resident settlement, equipment, and survival props |
| `Wild West Pixel Art Tileset` | 15 / 15 | Annex | Frontier town, rail, mine, and canyon core |
| `World War I Trench Warfare Tileset` | 15 / 15 | Annex | Warfront trench core |
| `WW1 Ruins Pixel Art Tileset Pack` | 6 / 6 | Annex | Warfront ruined rear-line district |
| `WW1 Trench & Bunker Pixel Art Tileset Pack` | 6 / 6 | Annex | Warfront trench/bunker companion kit |
| `WWII City Ruins Pixel Art Tileset Pack` | 5 / 5 | Annex | Warfront city-ruins district |
| `XModern Arcade` | 42 / 41 | Core-S | Helios `HE-11` expanded arcade/recreation source; compare overlap with the smaller modern arcade pack |
| `Zombie apocalypse` | 21 / 21 | Annex | Ashfall zombie-city and recovery-state environment |

#### Required showcase-sheet bindings

The first derivative batch must prove the best supplied material in actual room
compositions. These are required bindings, not mood-board suggestions. A work
package may add compatible sheets, but it may not replace these with generic
terrain or use a full presentation sheet as one giant sprite.

| Destination | Required source sheets or source groups | Locked room use and composition proof |
| --- | --- | --- |
| New Philadelphia | `Modern World Overworld Pixel Tileset`; `Medieval village town`; `Cozy farming village`; `Cozy Spring Asset Pack`; `Modern Laboratory Assets`; `Modern Interior Pixel Art Tileset` | Author visibly different modern civic, old-town, farm/spring, laboratory, and ordinary-interior districts. The contact sheet must prove a common doorway/actor scale before these families meet at district transitions. |
| Mansion | All five `Haunted Mansion/1.png`-`5.png` source sheets plus the five `Crimson Gothic Castle` set groups | `HM-01` establishes the supplied exterior/graves; `HM-02`, `HM-04`, `HM-05`, `HM-14`, and `HM-16` prove house floors, clocks, furniture, stairs, service spaces, and rail occlusion; `HM-06`, `HM-08`, and `HM-09` prove the large Crimson gallery/vestibule/ballroom vocabulary; `HM-11`-`HM-13` prove chapel, crypt, and attic variation. Because these sources use generic filenames and embedded headings, the derivative manifest must add semantic names and exact crop rectangles. |
| Asterion | `Scifi space station/1. Metal floor tiles.png`, `2. Sci-fi wall tiles.png`, `4. Doors and airlocks.png`, `5. Windows and observation panels.png`, `6. Control panels and consoles.png`, `7. Computers and screens.png`, `8. Pipes and ventilation.png`, `9. Cables and wiring.png`, `12. Laboratory equipment.png`, `13. Energy and power services.png`, `16. Crates and cargo props.png`, and all five `Space Station Interior Tileset/space ship` sheets | `AS-01`-`AS-03` prove dock/cargo/commons; `AS-04`-`AS-06` prove medical, hydroponic, power, pipe, and oxygen state changes; `AS-07`-`AS-08` prove command/control; `AS-10` proves a real observation vista; `AS-11`-`AS-14` prove maintenance, cryo, pressure-lock, and tram silhouettes. |
| Primeval | The complete 22-sheet `Jurassic world` set, especially `1. Prehistoric ground tiles.png`, `4. Volcanic rock tiles.png`, `5. Water and swamp tiles.png`, `6. Dinosaur bones and fossils.png`, `10. Stone ruins.png`, `11. Dinosaur nests and eggs.png`, `17. Cliffs and rock formations.png`, `18. Dinosaur footprints.png`, `19. Modular jungle ruins.png`, `21. Dinosaurs.png`, and `22. Dinosaur variants and babies.png` | `PV-01`/`PV-02` prove ground, tracks, river, and signal stones; `PV-04`/`PV-05` prove canopy and monumental ruins; `PV-07`/`PV-11` prove nests, eggs, adult/baby silhouettes, and non-extermination storytelling; `PV-08`/`PV-14` prove volcanic terrain; `PV-10` proves the fossil quarry. At least one adult dinosaur must be a moving field landmark and at least one baby/nest composition must be non-hostile. |
| Helios | `Cyberpunk Pixel Art/Floor tiles.png`, `Wall tiles and edges.png`, `Doors and arches.png`, `Signs and holograms.png`, `Machines and tech.png`, `Pipes, cables and vents.png`, `Rooftop and building tops.png`, `Stairs, ladders and Railings.png`, `Vehicles and transports.png`, all 23 `Cyberpunk City Tileset` images, all eight `Bright Cyberpunk` images, and `Modern Subway Station Tileset Pack` | `HE-01`-`HE-03` prove elevated exterior/civic/market language; `HE-04`, `HE-05`, and `HE-13` prove subway, power, and skyrail navigation; `HE-06` proves a readable clinic rather than another neon corridor; `HE-09` proves pipes/service undercity; `HE-10` proves rooftop greenery; `HE-11` proves arcade/recreation; `HE-12` proves hologram archive; `HE-14` proves a distinct maintenance lift shortcut. |
| Frosthold | `Frozen kingdom` sheets 1-20; `Frostbound viking village` sheets 1-20; `Snowy Village` sheets 1-20, especially frozen-market, runes, ice bridges, Nordic buildings, village interiors, warm lights, food, weather, and magic-ice sheets | `FR-01`-`FR-04` prove gate, inhabited thawyard/market, and causeway; `FR-05`-`FR-08` prove lien devices, rune hall, throne approach, and boss chamber; `FR-09` must visibly use cabins, ovens/food, warm lights, and ordinary furniture; `FR-10`/`FR-11` prove crystal forest and magic ice; `FR-13`/`FR-14` prove bridge, aqueduct, and thaw-state water. The village must look inhabited, not like an empty snow dungeon. |
| Moonpetal | All 20 named `Sakura Temple Asset Pack` sheets, including `Shrine Gates.png`, `temple building parts.png`, `Roof tiles.png`, `Decorative framed garden tiles.png`, `Water and ponds.png`, `Bridges and railings.png`, `Lanterns and lights.png`, `Food, drink and cafe props.png`, and `Furniture and seating.png`; all seven `Dreamy World` sheets as effect candidates | `MP-01` proves layered gates; `MP-02` proves a populated blossom court; `MP-03`/`MP-09`/`MP-12` prove food, counters, seating, shops, and lived-in culture; `MP-04`/`MP-10` prove ponds/bridges/reflections; `MP-05`-`MP-08` prove pavilion, bell walk, palace facade, and interior; `MP-13`/`MP-14` prove roof occlusion and reflected shortcut. Dreamy material stays in reflection/cloud layers rather than replacing temple geometry. |
| Empyreal | `Ancient Greek Mythology` sheets 1-20, especially marble, walls, columns, gates, stairs, roads, fountains, sacred trees, statues, altars, market, furniture, ruins, and divine magic; `Flying Islands/PNG/Bridges.png`, `Clouds*.png`, `Flying_rocks.png`, `Ground_grass_flying.png`, `Waterfalls.png`, animated trees/statues, and separate crystals/ruins; all 14 `Roman Empire` sheets as civic candidates | `EM-01`/`EM-02` prove floating quay and marble rise; `EM-03`/`EM-04` prove garden/forum civic life; `EM-05`/`EM-06` prove mechanical lift and multi-island bridge; `EM-07`/`EM-14` prove reliquary and vault; `EM-09` proves a tribunal, not a reused plaza; `EM-10` proves upward weather/water; `EM-12`/`EM-13` prove broad optional terraces; `EM-16` visibly animates a public cloud ferry. The committed derivative set must preserve alpha, animation timing, landing shadows, and void-safe collision. |

The inventory must explicitly collapse known duplicate families before import,
including `Haunted Mansion` / `Haunted Mansion Pixel Art Tileset Pack`,
`Cyberpunk Pixel Art` / `Cyberpunk Pixel Art Asset Pack`, `Cafe Assets` /
`Cozy Cafe Asset Pack`, and `Farm Assets` / `Farm Tileset - Pixel Art` where
checksums confirm identity. Presentation headers embedded above atlas content
must be cropped out in deterministic derivatives; they are never runtime art.

Each room chooses one base-terrain family, one architecture family, and at most
one supporting prop family unless its work package documents a transition
between visual districts. HoriHori backgrounds, portraits, icons, spells, and
the 10 staged monster packs remain supporting libraries and require an exact
battle, portrait, reward, or VFX use plus the same profile/provenance gates.

### 9.4 Locked 102-room manifest

This manifest is the level-design contract, not a naming suggestion. IDs are
stable save/debug/validation keys. `C` is a critical-route room, `O` is an
optional room, and `X` is a connective or shortcut room. Size classes count
useful walkable cells after collision: `S` = 60-89, `M` = 90-139, and `L` =
140-220. Every listed link is two-way unless explicitly marked one-way. A gate
must name the story condition that changes its navigation state.

Each room implementation must record exact entry anchors, camera bounds,
encounter policy, NPC roster by story phase, interaction IDs, treasure IDs,
foreground occluders, collision resource, music/ambience, and first-visit,
stabilized, and postgame variants in the room manifest data.

#### Haunted Mansion — 16 rooms

First-visit graph spine: `HM-01 → HM-02 ⇄ HM-03 → HM-04 → HM-05 → HM-14 →
HM-06 → HM-15 → HM-07 → HM-08 → HM-09`. Optional branches reconnect rather
than terminate wherever the fiction permits.

| ID / room | Class / size | Links and gate | Required gameplay and state | Expansion art and population |
| --- | --- | --- | --- | --- |
| `HM-01` Rain Gate and Forecourt | C / M | Town portal, `HM-02` | Establish the house silhouette, locked return gate, foyer-intro formation, and a dry porch safe strip. After stabilization, two Vampire Hunters establish a watch post. | Haunted Mansion exterior shell and graves, Crimson Gothic gate, Ruined Dungeon masonry; 2 hunters after victory, Nightmare silhouette before entry. |
| `HM-02` West Foyer and Impossible Clock | C / L | `HM-01`, `HM-03`, `HM-04` `[4:44]`, `HM-10` | Preserve the foyer clear, thirteen-setting clock, first examination, 4:44 input, House-Key Fragment, Anchor Shard, and 13:13 post-invention secret. The servants' door changes visibly from wallpaper seam to open passage. | Haunted Mansion floors, staircases, chandeliers, grandfather clocks, and furniture as the primary kit; Crimson Gothic/Psychological details; sparse Dark Gothic apparitions. |
| `HM-03` Household Ledger Study | C / M | `HM-02` | Hold the false book row and ledger entry that explicitly sends the player back to `HM-02`. Add rotating shelves as a short sightline puzzle, not another combination lock. | Haunted Mansion cracked walls, cupboards, bookcases, rugs, and clocks with Crimson Gothic library accents; one Vampire Hunter researcher after stabilization. |
| `HM-04` Servants' Clock Passage | C / S | `HM-02` `[4:44]`, `HM-05`, `HM-12` `[13:13]` | Pendulum-blade timing corridor with wall alcoves; teach foreground wall occlusion and preserve the opened 4:44 route. The 13:13 resonance reveals the undercroft stair without blocking the campaign. | Haunted Mansion damaged floor/wall pieces and clocks plus Psychological Horror mechanisms; hostile Nightmare apparition patrol only. |
| `HM-05` Servants' Archive | C / M | `HM-04`, `HM-11`, `HM-14`, `HM-16` `[shortcut]` | Preserve the Archive Anchor Clock as full restore/save/retry. Add servant records that identify Gallery and Nursery as “memory” and “childhood,” foreshadowing the two clock hands. | Haunted Mansion cabinets/clocks plus Crimson Gothic archive and Royal Props; 2 trapped Kingdom Citizens first visit, relocated after victory. |
| `HM-06` Portrait Gallery | C / L | `HM-14`, `HM-15` | Preserve portrait ambush, Silver Hour Hand, false-bottom cache, supplied portrait enemies, and camera-facing central portrait. Frames rotate sightlines after the ambush to reveal an optional door. | Crimson Gothic grand-gallery architecture over Haunted Mansion floors/furniture, Psychological portraits; Dark Gothic nobles and Vampire Hunter witness after clear. |
| `HM-07` Nursery of Borrowed Years | C / M | `HM-15`, `HM-08`, `HM-11` `[one-way latch]` | Preserve doll ambush, music-box use of Silver Hour Hand, Brass Minute Hand, toy-chest cache, and wooden raptor joke. Cleared dolls remain inert landmarks rather than vanishing. | Haunted Mansion wood floors, wardrobes, couches, rugs, and ghost props with Psychological Horror nursery dressing; Nightmare doll/keeper field actors. |
| `HM-08` Ballroom Antechamber | C / M | `HM-07`, `HM-09` `[two hands]`, `HM-13`, `HM-16` `[shortcut]` | Preserve Nursery Respite Clock, full restore flag, and two-socket ballroom gate. Show both collected hands in the lock and keep a danger-free preparation area. | Haunted Mansion staircase/clock kit with Crimson Gothic vestibule, banners, and door surround; 2 Vampire Hunters after both hands are installed. |
| `HM-09` Grand Ballroom at 4:44 | C / L | `HM-08` | Dedicated Haunted Clock Mirror arena with long approach, no random encounter, scripted boss boundary, results return anchor, Epic Anchored Chronometer, Anchor Core, and stabilized lighting/music variant. | Crimson Gothic ballroom shell with Haunted Mansion chandeliers, rugs, clocks, sofas, and cracked floor variants; Clock Mirror centered with clear party staging. |
| `HM-10` Dead Conservatory | O / M | `HM-02`, `HM-15` | Branching plant-path room with Cursed Tree elite, herb cache, and a shutter shortcut opened from inside. Plants revive after stabilization but retain one impossible black rose clue. | Crimson Gothic glass, Magic/fairy-forest plants after palette approval, Cursed Trees monster pack; Enchanted Forest visitor postgame. |
| `HM-11` Mourning Chapel | O / M | `HM-05`, `HM-07` `[latch]`, `HM-12` `[crypt key]` | Optional stained-glass alignment reveals a fixed anti-curse accessory and unlocks the undercroft's second entrance; provides a loop between Archive and Nursery. | Crimson Gothic chapel, Ruined Dungeon crypt; Crimson Vampire Hunter pair and Psychological priestess apparition. |
| `HM-12` Sealed Undercroft | O / L | `HM-04` `[13:13]`, `HM-11` `[crypt key]` | Post-invention optional mini-dungeon room containing the temporal field note/Anchor Dust payoff, an infernal elite, and an exit opened from either side. Never required for Ballroom access. | Ruined/Psychological Dungeon, undead objects; 2 Legendary Infernal identities and one Dark Fantasy Dungeon explorer. |
| `HM-13` Dollmaker's Attic | O / M | `HM-14`, `HM-08` `[attic latch]` | Vertical clutter maze above Nursery; recover the maker's invoice and a doll-resistant charm, then lower the attic stair to Antechamber. No duplicate music-box puzzle. | Haunted Mansion wardrobes, broken furniture, stairs, rugs, and cobwebs with Psychological props; Nightmare Slasher dollmaker and Dark Gothic scavenger. |
| `HM-14` West Stair and Portrait Balcony | X / M | `HM-05`, `HM-06`, `HM-13` | Multi-level stair composition that previews Gallery below, establishes correct actor/railing occlusion, and routes to Attic. One banister breaks after Gallery clear to shorten return travel. | Haunted Mansion staircase and railing pieces as primary geometry, Crimson Gothic balcony accents; nonblocking Vampire Hunter patrol after clear. |
| `HM-15` Mirror Corridor | X / S | `HM-06`, `HM-07`, `HM-10` | Three-way connector whose mirrors show the next room's landmark; one false reflection spawns a single scripted encounter, then becomes a reliable loop. | Psychological mirrors, Gothic wall set; one Dark Gothic reflection actor, no random encounters after clear. |
| `HM-16` Kitchen and Service Lift | X / M | `HM-05`, `HM-08` `[open from Antechamber]` | Service-space loop with pantry supplies and a lift opened from the far side; becomes the 2-5 minute stabilized return route from Archive to Ballroom. | Crimson Gothic service tiles, Royal Props kitchen; rescued Kingdom Citizens and Vampire Hunter quartermaster after victory. |

#### Asterion Station — 14 rooms

First-visit graph spine: `AS-01 → AS-02 → AS-03 → AS-13`, then Medical
`AS-04` supplies the Biocircuit and Hydroponics `AS-05 → AS-06` restores oxygen;
oxygen opens `AS-07 → AS-08`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Expansion art and population |
| --- | --- | --- | --- | --- |
| `AS-01` Docking Collar 7 | C / L | Observatory portal, `AS-02`, `AS-14` `[oxygen]` | Preserve dock intro battle and Astronaut meeting. Use pressure-door staging, visible exterior stars, cargo-loader cover, and a safe return pad. After stabilization, arrivals replace hostile drones. | Scifi space station metal floors/windows/airlocks plus Sci-Fi Spaceship cargo props; Astronaut and 3 SCI-FI LEGENDS crew after clear. |
| `AS-02` Customs and Cargo Intake | C / M | `AS-01`, `AS-03`, `AS-09` | Separate freight lanes from inspection booths; introduce station shift records and visibly preview the locked customs vault. One cargo belt creates a traversable loop, not a forced conveyor gimmick. | Sci-Fi Spaceship Interior weapons/lockers/crates plus Scifi space station cargo/doors; SCI-FI quartermaster and 2 Warfront officers after stabilization. |
| `AS-03` Mess Deck and Crew Commons | C / M | `AS-02`, `AS-12`, `AS-13` | Central low-pressure hub with crew logs pointing to Medical and Hydroponics. Before oxygen it is emergency-lit and empty; afterward tables, vending units, and residents activate. | Scifi space station furniture/storage/food props with Space Station Interior walls; 4 SCI-FI crew across staggered schedules. |
| `AS-04` Medical Triage | C / M | `AS-13`, `AS-12` `[patient door]` | Preserve medical robot ambush, refrigerated Asterion Biocircuit drawer, and emergency save beacon/full restore. Keep all interaction cells outside robot patrol occupancy. | Scifi space station laboratory equipment plus Space Station Interior tanks/consoles; SCI-FI medic and Warfront combat medic after ambush. |
| `AS-05` Hydroponics Outer Walk | C / M | `AS-13`, `AS-06`, `AS-10` | Preserve greenhouse patrol/ambush while creating two canopy lanes around a sealed central greenhouse. Blue oxygen lines visibly terminate at `AS-06`. | Space Station Interior hydroponic beds, irrigation, crops, drones, plant tanks, and window walls; SCI-FI botanist after restoration. |
| `AS-06` Oxygen Biocircuit Core | C / L | `AS-05`, `AS-07` `[install Biocircuit]` | Install the Medical Biocircuit, consume quest item, restore party, switch emergency-red art/audio to breathable-blue state, and unlock Command Spine plus Dock tram. No random encounter after repair. | Scifi space station energy/power and laboratory sheets with Space Station Interior biotanks; Quantum Engineer and Nebula Mechanic maintain core after repair. |
| `AS-07` Command Spine | C / M | `AS-06`, `AS-08`, `AS-10`, `AS-13` `[oxygen]`, `AS-14` `[oxygen]` | Security checkpoint gauntlet with control-gate message and windows previewing Mother Computer. Include two cover routes that converge before Control; after boss it is a populated administrative corridor. | Scifi space station consoles/screens/doors over Space Station Interior floors; 3 Warfront security before boss, SCI-FI officers after. |
| `AS-08` Station Control | C / L | `AS-07`, `AS-11` `[post-boss bulkhead]` | Dedicated Mother Computer arena; preserve station-complete flags, Ion Pistol reward, Astronaut recruitment completion, boss-results return, and full stabilized console state. | Scifi space station command consoles/energy services with Asteroid Base structural accents; Mother Computer centered, 3 SCI-FI operators after victory. |
| `AS-09` Bonded Customs Vault | O / M | `AS-02` `[Astronaut assist]` | Preserve cargo override, 2 Tonics, Ether, 36 Duckets, and specialist bonus. Add a manifest-matching shelf puzzle with no penalty and a one-time contraband gear cache. | Sci-Fi Spaceship Interior armory displays, lockers, ammo and cargo plus Warehouse crates; SCI-FI quartermaster after opened. |
| `AS-10` Observation Ring | O / L | `AS-05`, `AS-07` `[pressure cycle]` | Curved vista route with shutter controls, one optional zero-pressure combat formation, and a star-chart secret that previews Empyreal without unlocking it. Opens a loop between Hydro and Command. | Scifi space station observation panels plus Space Station Interior star windows; Stellar Oracle and Astral Blade visitor after stabilization. |
| `AS-11` Structural Maintenance Bay | O / M | `AS-13` `[maintenance key]`, `AS-08` `[post-boss bulkhead]` | Home of the post-stabilization Bulkhead Warden trial. Use load-bearing switch sequencing, engineering loot, and a two-sided shortcut; trial arena must not overlap the doorway. | Asteroid Base structure plus Sci-Fi Spaceship machinery and Scifi space-station service props; Bulkhead Warden, Warfront engineer, SCI-FI mechanic. |
| `AS-12` Cryosleep Berths | O / M | `AS-03`, `AS-04` `[patient door]` | Optional identity/log room with selectable pod releases after oxygen restoration, one medical supply cache, and residents who relocate to Mess instead of permanently crowding berths. | Space Station Interior stasis pods and Scifi space station medical/storage props; 3 SCI-FI identities distributed by state. |
| `AS-13` Pressure-Lock Junction | X / M | `AS-03`, `AS-04`, `AS-05`, `AS-07` `[oxygen]`, `AS-11` | Four-way readable hub with colored pipe/door symbols. Before oxygen, route Medical and Hydro independently; afterward open Command without changing unrelated collision. | Kelvana pressure locks and signs; one Warfront patrol with doorway exclusion zones. |
| `AS-14` Service Tram | X / S | `AS-01`, `AS-07` `[oxygen restored]` | Short tram platform and travel cut that becomes the principal stabilized Dock-to-Control shortcut. Tram state, arrival anchor, and camera handoff must save/reload safely. | Interstellar transit assets; SCI-FI navigator and mechanic after restoration. |

#### Primeval Expanse — 14 rooms

First-visit graph spine: `PV-01 → PV-02 → PV-03 → PV-04 → PV-05 → PV-06`;
the decoded terminal opens `PV-07`, whose reset opens `PV-08`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Expansion art and population |
| --- | --- | --- | --- | --- |
| `PV-01` Thunderfern Grove | C / L | Trailhead portal, `PV-02`, `PV-13` `[vine cut]` | Preserve Grove intro fight and readable Trailhead return. Use two looping clearings, canopy occlusion, and tracks foreshadowing the Tyrant without placing the boss here. | Jurassic world ground/ferns plus Rainforest Survival canopy; Beastfolk scouts after clear, dinosaur field silhouettes. |
| `PV-02` Stone-Signal Crossing | C / M | `PV-01`, `PV-03`, `PV-13` | Preserve the carved traffic totem and meteor-warning clue that unlocks Paleo-Linguistic Telegraph research. Make three pulsing signal stones control safe crossing windows after the intro fight. | Jurassic world prehistoric ground/stone ruins with Rainforest river pieces; Caveman maintenance marker, 2 Beastfolk travelers. |
| `PV-03` Primeval Borough | C / L | `PV-02`, `PV-04`, `PV-07` `[terminal decoded]`, `PV-10`, `PV-14` `[relay reset]` | Preserve Caveman meeting and make the settlement the population hub. Show locked Relay trail from the borough; traffic turns green and residents change routes after reset. | Stone Age Modern Life architecture plus Jurassic world camp props/fences; 8-10 Beastfolk/Enchanted Forest residents by schedule. |
| `PV-04` Canopy Causeway | C / M | `PV-03`, `PV-05`, `PV-11` | Elevated branch network with foreground leaves, under-bridge glimpses, and two routes around a territorial dinosaur. One rope bridge lowers from Ruins for return travel. | Rainforest Survival terrain/bridges with Alien Jungle canopy accents; Beastfolk ranger patrol. |
| `PV-05` Jungle Ruins Court | C / L | `PV-04`, `PV-06`, `PV-09`, `PV-13` `[open from Ruins]` | Monumental ruin hub that points to Cave Terminal through repeated signal glyphs. Include a scripted ruin formation and a specialist-readable supply hollow. | Jurassic world Stone Ruins sheet as primary architecture, Alien Jungle flora secondary; Enchanted Forest druid and alchemist after clear. |
| `PV-06` Cave Computer Vault | C / M | `PV-05`; interaction remotely unlocks `PV-03 ⇄ PV-07` | Preserve translator requirement, Cave OS dialogue, terminal-decoded flag, specialist survey, and explicit remote opening of Relay trail. The terminal is the focal interaction, not hidden among props. | Jurassic stone ruins/fossils over fungus-cave ground with a deliberately isolated ancient-tech profile; Owl Sorceress after decoding. |
| `PV-07` Relay Nest | C / L | `PV-03` `[terminal decoded]`, `PV-08` `[relay reset]`, `PV-11`, `PV-14` | Preserve dinosaur-attendant ambush, anchor totem/save/full restore, relay polarity reset, all-green borough state, and Caldera opening. Egg-shaped relay stays visible after use. | Jurassic world Dinosaur Nests and Eggs sheet as primary, belly-of-monster organic accents only inside relay; Dragonborn scout after clear. |
| `PV-08` Caldera Crown | C / L | `PV-07`, `PV-12` `[post-boss]`, `PV-14` `[relay reset]` | Dedicated Tyrant of the Morning Commute arena with approach vista, no random battle, Meteor-Tempered Mammoth Club reward, Caveman recruitment completion, and cooled post-victory route. | Jurassic volcanic-rock ground plus Volcanic cliffs/effects; Tyrant only first visit, Dragonborn delegation postgame. |
| `PV-09` Luminous Fungal Hollow | O / M | `PV-05`, `PV-13` | Light-spore path puzzle, fixed restorative fungus cache, optional fungal monster formation, and second exit to River Switchbacks. Does not reuse terminal decoding. | fungus cave complete kit; Butterfly Witch and Rabbit Elemental visitor after clear. |
| `PV-10` Fossil Survey Quarry | O / L | `PV-03` | Fossil-layer excavation with three readable eras, equipment material reward, and post-stabilization Mossback Surveyor recruitment trial staged away from entrance. | Jurassic world Dinosaur Bones and Fossils with Rainforest cliff ground; Mossback Surveyor and Beastfolk laborers. |
| `PV-11` Raptor Nursery | O / M | `PV-04`, `PV-07` `[open nest latch]` | Non-boss stealth/avoidance room where egg protection, not extermination, yields the best reward. Opens a one-way latch into Relay Nest and changes to a calm nursery after reset. | Jurassic world egg/nest/prehistoric-plant sheets; Blossom Priestess and Dragon Priestess post-state. |
| `PV-12` Storm Dragon Roost | O / L | `PV-08` `[boss defeated]` | High-level post-stabilization challenge with wind/rock traversal, one elite dragon formation, Dragonborn lore, and a fixed lightning-resistant charm. No main-quest flag. | Flying-rock details plus Jungle caldera, Dragon monster pack; 4 Dragonborn identities. |
| `PV-13` River Switchbacks | X / M | `PV-01` `[cut vine]`, `PV-02`, `PV-05` `[open ruin gate]`, `PV-09` | Low-route loop under canopy with stepping stones and a vine cut from the far side. Provides an encounter-light return path and visually tracks water toward Borough. | Jungle water/bridges, SciGo water only after profile approval; Beastfolk fisher. |
| `PV-14` Lava-Tube Municipal Bypass | X / S | `PV-03`, `PV-07`, `PV-08` `[relay reset]` | Fossilized service tunnel whose three doors activate when traffic turns green; becomes the stabilized Borough/Nest/Caldera shortcut. No random encounters after activation. | Lava Cavern and Ruined Dungeon tunnel; Caveman maintenance crew after reset. |

#### Helios Arcology — 14 rooms

First-visit graph spine: `HE-01 → HE-02 → HE-03 → HE-13 → HE-04 → HE-05`;
the Phase Inverter opens Clinic `HE-06`, both disabled daylight nodes open
`HE-07 → HE-08`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Expansion art and population |
| --- | --- | --- | --- | --- |
| `HE-01` Afterlight Skybridge | C / L | Afterlight Club portal, `HE-02`, `HE-14` `[nodes disabled]` | Preserve skybridge intro fight and return anchor. Use moving city depth, a shaded safe strip, and the first visible but unreachable rooftop night garden. | Cyberpunk City exterior/rail pieces with Tokyo Nights skyline and signs; 3 Cyberpunk commuters after clear. |
| `HE-02` Curfew Customs | C / M | `HE-01`, `HE-03`, `HE-10` `[roof badge]` | Security lanes teach permanent-day curfew rules. Player reroutes one scanner to create a loop; post-stabilization checkpoint becomes a public information desk. | Cyberpunk doors/machines/banners; 2 Cyber Enforcers first state, civilians after victory. |
| `HE-03` Public Market | C / L | `HE-02`, `HE-11`, `HE-12`, `HE-13` | Preserve Neon Viper meeting and Ordinance terminal that unlocks Nocturnal Phase Inverter. Build vendor loop, central landmark, readable exits, and state change from heat-exhausted to evening market. | Bright Cyberpunk Cyber Mart/Health Hub pieces with Cyberpunk City/Tokyo vending and signage; 8-10 Cyberpunk vendors/commuters. |
| `HE-04` Transit Concourse | C / L | `HE-13`, `HE-05`, `HE-09` | Multi-platform navigation with train timing as cover rather than instant damage. Clearly sign the phase substation and service-level branch. | Cyberpunk City subway platforms plus Modern Subway architecture/signage; Cyberpunk guards, commuters, later Cobalt Courier. |
| `HE-05` Transit Phase Substation | C / M | `HE-04` | Preserve inverter requirement, transit-node-disabled flag, specialist assist, and visible shutdown of half the Arcology daylight grid. One compact circuit-routing interaction, then a safe room. | Cyberpunk machines/FX; Neon Hacker and Quantum Mind support identities after disable. |
| `HE-06` Recovery Clinic | C / L | `HE-13` `[Phase Inverter crafted]`, `HE-07` `[both nodes]` | Preserve clinic ambush, clinic-node disable, full restore, and second half of core gate. Divide waiting, treatment, and power areas without separate filler rooms. | Bright Cyberpunk Health Hub with Modern Pharmacy treatment props; clinic staff/patients replace security after clear. |
| `HE-07` Civic Core Approach | C / M | `HE-06` `[both nodes]`, `HE-08`, `HE-10`, `HE-12`, `HE-14` `[both nodes]` | Twilight boulevard with mirrored solar pylons and final command patrol. Both node shutdowns must visibly darken the locked Core aperture. | Cyberpunk civic architecture, approved Golden Palace accents only if palette-matched; Heroic civic guard. |
| `HE-08` Solar Core | C / L | `HE-07` | Dedicated Civic Sun arena; preserve core-open gate, Midnight Capacitor reward, Neon Viper recruitment completion, stabilized night cycle, and results return. Avoid combat UI over the core silhouette. | Cyberpunk core machines/FX, HoriHori battle VFX if approved; Civic Sun first state, technicians afterward. |
| `HE-09` Service Undercity | O / L | `HE-04`, `HE-13` `[open service lift]` | Pipe-and-maintenance loop beneath Transit with one optional security formation, technician cache, and post-stabilization Cobalt Courier trial/delivery route. | Modern Subway service tunnels plus Cyberpunk City lower-level utilities; Cobalt Courier, Neon Mechanic, 2 maintenance residents. |
| `HE-10` Rooftop Night Garden | O / M | `HE-02` `[roof badge]`, `HE-07` `[open terrace gate]` | Previewed from Skybridge; after first node disable, shadow-growing plants reveal a treasure path. Opens a second exit at Civic Approach and changes under real night. | Cyberpunk Pixel Art rooftops/greenery plus Tokyo Nights sakura details; Heroic/Cyberpunk visitors after stabilization. |
| `HE-11` Recreation Stack | O / L | `HE-03` | Three-height civic recreation room with boxing ring, compact pitch, spectator loop, optional tournament interaction, and fixed noncombat reward. It houses sports packs without leaking them into government zones. | Modern Arcade Game Center, XModern Arcade, Modern Gym, and Cyberpunk fixtures; Ring Legends and World Championship identities. |
| `HE-12` Hologram Archive | O / M | `HE-03`, `HE-07` `[archive override]` | Compare censored “eternal noon” records to original night footage; alignment interaction yields research notes and opens a quiet Market/Core loop. | Cyberpunk holograms and approved HoriHori portraits; Heroic Legends curator and Hologram Mage. |
| `HE-13` Skyrail Exchange | X / M | `HE-03`, `HE-04`, `HE-06` `[Inverter]`, `HE-09` `[service lift]` | Central three-line interchange with color/shape signage, unambiguous clinic gate, and safe transfer floor. Trains and NPCs cannot occupy transition cells. | Cyberpunk City subway kit plus Modern Subway signs/turnstiles; 4 rotating commuters with platform exclusion zones. |
| `HE-14` Midnight Maintenance Lift | X / S | `HE-01`, `HE-07` `[both nodes disabled]` | Direct Skybridge-to-Core return route unlocked when the grid enters evening phase. Persist car position abstractly and always load it at the player's floor. | Cyberpunk elevator/lighting; one mechanic after activation. |

#### Frosthold Kingdom — 14 rooms

First-visit graph spine: `FR-01 → FR-02 → FR-03 → FR-04 → FR-05`; the
Thermal Arbitration Coil opens `FR-06`, the Rune Hall victory opens `FR-07`,
and its final seal opens `FR-08`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Supplied art and population |
| --- | --- | --- | --- | --- |
| `FR-01` Whitewind Snow Gate | C / L | Cold Storage portal, `FR-02`, `FR-13` `[open from aqueduct]` | Preserve gate intro battle, readable return point, and first view of the distant Ice Throne. Wind gusts alter particles, not player control; gatehouse becomes staffed after clear. | Frozen kingdom snow/path/castle walls plus Snowy Village weather; 3 Frozen Kingdom guards after clear. |
| `FR-02` Refugee Thawyard | C / M | `FR-01`, `FR-03`, `FR-09`, `FR-13` | Establish the confiscated-heat crisis through extinguished braziers and residents sheltering behind windbreaks. Lighting and resident positions change as later seals thaw. | Frostbound Viking buildings/palisades and Snowy Village supplies; 5-6 Frozen citizens, hunter, and merchant schedules. |
| `FR-03` Frozen Market | C / L | `FR-02`, `FR-04`, `FR-09`, `FR-14` `[throne seal voided]` | Preserve Frost Lich Emperor meeting and heat-tax rune that unlocks Thermal Arbitration Coil research. Create two stall loops and a central assessed-heat monument; market reopens after stabilization. | Frozen kingdom market stalls/houses/statues with Frostbound props; 8-10 Frozen roster residents by phase. |
| `FR-04` Crystal Causeway West | C / L | `FR-03`, `FR-05`, `FR-10` | Broad visible ice bridge with lower frozen river, wind shelters, and preview of the first tax seal. Use railings and crack patterns to sign walkability; no invisible ice paths. | Frozen kingdom icy bridges/water/glacier cliffs plus Crystalice details; 2 Snow Huntress patrols. |
| `FR-05` First Thermal Lien | C / M | `FR-04`, `FR-06` `[Thermal Arbitration Coil]` | Preserve causeway-seal interaction, specialist thermal assist, and exact gate from closed/frozen to thawed/open. The Coil's seventeen-clause animation must not replay on routine backtracking. | Snowy Village magical-ice portals/runes plus Frozen kingdom rune stones; Arcane Frost Enchantress witness after opening. |
| `FR-06` Rune Hall Nave | C / L | `FR-05`, `FR-07` `[ambush cleared]`, `FR-11` `[cave latch]`, `FR-13` `[open furnace]` | Preserve rune ambush, persistent save brazier/full restore, and route condition for final seal. Use three readable rune aisles and a central battle floor; cleared patrols become petitioners. | Frozen kingdom magical runes/castle walls plus Frostbound rune monoliths; Frozen priestess, paladin, and Arcane visitor after clear. |
| `FR-07` Throne Approach and Final Lien | C / M | `FR-06`, `FR-08` `[ambush + Coil]`, `FR-12`, `FR-14` `[void lien]` | Preserve final throne-seal logic, full restore, and Ice Throne opening. Show the Whiteout Auditor beyond a transparent ice aperture without triggering combat early. | Frozen kingdom castle doors/statues/runes with Snowy Village magic ice; royal guards relocate after seal. |
| `FR-08` Ice Throne Audit Chamber | C / L | `FR-07`, `FR-14` `[post-boss sluice]` | Dedicated Whiteout Auditor arena; preserve Crown of Repealed Winter reward, Frost Lich recruitment completion, stabilization flags, results return, and thawed throne variant. | Frozen kingdom ice-castle shell, thrones/statues, Snowy magic effects; Auditor first state, Lich court and citizens afterward. |
| `FR-09` Lower Village Hearthline | O / L | `FR-02`, `FR-03` | Inhabited residential loop with frozen wells, communal ovens, errands, and a fixed warmth-resistant accessory earned by relighting three legally distinct hearths. No combat after Gate clear. | Frostbound Viking village, Snowy Village cabins/food; 8 Frozen residents including blacksmith, child, baker, hunter. |
| `FR-10` Crystalice Forest | O / L | `FR-04`, `FR-11` | Branching forest where animated crystals mark safe trails during whiteout pulses. One elite collector patrol guards a crystal gear cache; second exit reaches Ice Cavern. | Crystalice Forest animated tiles plus Frozen kingdom pines/cliffs; Snow Huntress and Frost Assassin field actors. |
| `FR-11` Blueglass Ice Cavern | O / M | `FR-10`, `FR-06` `[open rune-side latch]` | Reflection-routing puzzle directs warm light through three crystals, awards a rare elemental charm, and opens a one-way Rune Hall latch to form a loop. | ICE CAVERN base with Snowy Village magic ice/portals; Crystal Priestess after puzzle. |
| `FR-12` Treasury of Collected Warmth | O / M | `FR-07` `[three audit seals]` | Optional vault containing bottled hearthlight, tax ledgers, Duckets, and one epic-adjacent accessory. Three seals are found through Market, Lower Village, and Ice Cavern interactions; no random combination. | Frozen kingdom treasure/furniture plus Golden Palace containers only if density matches; Frost Prince and Noble inspector postgame. |
| `FR-13` Furnace Aqueduct | X / M | `FR-01` `[open inside]`, `FR-02`, `FR-06` `[open furnace]` | Subsurface hot-water route visible through grates; first visit from Thawyard reaches supplies, Rune Hall opens the far valve, then it becomes Gate-to-Hall shortcut. | Frostbound bridges/platforms and Steamforged pipes recolored only through approved derivative; Frozen Berserker maintenance crew. |
| `FR-14` Meltwater Sluice | X / S | `FR-03`, `FR-07` `[final lien voided]`, `FR-08` `[post-boss]` | Controlled slide/walkway that drains toward Market, opens from Throne Approach, and becomes the fast stabilized return path. Provide a normal walking route for accessibility. | Frozen kingdom water/bridge pieces and Snowy Village thaw edges; no resident may block landing anchors. |

#### Moonpetal Court — 14 rooms

First-visit graph spine: `MP-01 → MP-02 → MP-03 → MP-04 → MP-05`; the
Veracity Lantern exposes the first counterfeit vow and opens `MP-06`, whose
ambush permits `MP-07 → MP-08`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Supplied art and population |
| --- | --- | --- | --- | --- |
| `MP-01` Vermilion Gate Terrace | C / L | Tea House portal, `MP-02`, `MP-14` `[post-palace bridge]` | Preserve gate intro battle and return anchor. Use three layered shrine gates with pass-behind foregrounds and a clear central processional route; attendants replace inspectors after clear. | Sakura Temple shrine gates/floors/lanterns; 3 Samurai/Yokai guards after intro. |
| `MP-02` Blossom Court | C / L | `MP-01`, `MP-03`, `MP-09`, `MP-12` | Preserve Kitsune Empress meeting and vow tablet that unlocks Electrostatic Veracity Lantern research. Make this the resident hub with visible but unreachable Bell Walk above. | Sakura Temple buildings, framed gardens, seating, blossoms; 8-10 Samurai/Yokai attendants, witnesses, vendors by phase. |
| `MP-03` Lantern Arcade | C / M | `MP-02`, `MP-04`, `MP-11`, `MP-13` | Covered commercial/spiritual passage where genuine lanterns cast shadows and copied lanterns do not. Teach the visual language later used at the Garden Seal without requiring the invention yet. | Sakura Temple lanterns, service counters, food/cafe props; shrine maiden, blade dancer, 4 town visitors. |
| `MP-04` Mirror Garden Outer Walk | C / L | `MP-03`, `MP-05`, `MP-10` | Two-sided garden promenade around ponds; reflections show altered resident memories. Paths loop physically, while copied scenery is non-colliding only when visually translucent. | Sakura Temple ponds/bridges/plants with restrained Dreamy World reflection overlays; Beastfolk court visitors. |
| `MP-05` Counterfeit Vow Pavilion | C / M | `MP-04`, `MP-06` `[Veracity Lantern]` | Preserve Garden Seal interaction, specialist memory assist, first copied-vow dissolution, and Bell Walk route opening. Put the genuine/counterfeit pair at center with unambiguous light response. | Sakura Temple pavilion/building parts and framed gardens; Kitsune witness and Blossom Priestess after opening. |
| `MP-06` Bell Walk | C / L | `MP-05`, `MP-07` `[ambush cleared]`, `MP-13`, save lantern | Preserve fox-procession ambush, persistent save lantern/full restore, and prerequisite for Palace Seal. Bells create directional audio/navigation cues and stop ringing falsely after clear. | Sakura Temple gates/lanterns/stone paths with Dreamy cloud accents only beyond railings; Samurai/Yokai procession actors. |
| `MP-07` Moon Palace Approach | C / M | `MP-06`, `MP-08` `[ambush + Lantern]`, `MP-14` `[open bridge]` | Preserve final false-vow seal, full restore, and Moon Palace opening. Use a long reflecting pool to preview Enma; expose copied moon visually when Lantern is used. | Sakura Temple palace facade, ponds, bridge and moonlit flowers; Imperial Shogun/Spirit Priestess guards change allegiance. |
| `MP-08` Hall of the True Moon | C / L | `MP-07` | Dedicated Magistrate Enma arena; preserve Mirror of the True Moon reward, Kitsune recruitment completion, stabilization flags, boss-results return, and restored-memory resident state. | Sakura Temple interior/furniture with Royal Props throne accents; Enma first state, Kitsune court afterward. |
| `MP-09` Tea Garden of Unsaid Things | O / M | `MP-02`, `MP-13` `[garden latch]` | Social optional room with tea-order memory conversations; identify one inconsistent testimony to earn a spirit accessory. No combat and no copy of the main vow puzzle. | Sakura Temple food/cafe props, seating, framed gardens; Tea host, Samurai, Blossom Priestess, Rabbit Mage. |
| `MP-10` Koi Reflection Maze | O / L | `MP-04`, `MP-13` `[open moon gate]` | Pond-island route where real koi disturb reflections and counterfeit koi do not. Complete observation path for treasure and open Bell Passage loop; falling resets locally without damage. | Sakura Temple ponds/bridges/decorative garden tiles; Butterfly Witch and fox attendant. |
| `MP-11` Shrine Archive of First Drafts | O / M | `MP-03`, `MP-12` `[archive screen]` | Compare original and revised civic vows, obtain research notes, and learn Enma's editing sequence. Sliding archive screens create a compact route puzzle, not a code-entry UI. | Sakura Temple interior walls/furniture plus Magic Wizard Academy books only if normalized; Nature Oracle archivist. |
| `MP-12` Yokai Artisan Lane | O / L | `MP-02`, `MP-11` `[open screen]` | Workshops for masks, bells, blades, and lanterns; optional crafting material exchange and postgame Crimson Oni interaction. Residents animate at stations without blocking the lane. | Sakura Temple small buildings/service counters with Tokyo Nights street details; 6 Samurai/Yokai and selected Beastfolk artisans. |
| `MP-13` Covered Bell Passage | X / M | `MP-03`, `MP-06`, `MP-09` `[latch]`, `MP-10` `[moon gate]` | Roofed three-way loop with visible upper bell ropes. Optional rooms unlock their own entrances; critical traversal never depends on solving both. Correct roof/actor occlusion is mandatory. | Sakura Temple roof/building/railing pieces; 2 shrine attendants with bounded routes. |
| `MP-14` Servants' Moonbridge | X / S | `MP-01`, `MP-07` `[open from Palace]` | Hidden-in-plain-sight staff bridge opened from Palace Approach, then retained as Gate-to-Palace stabilized shortcut. Bridge reflection changes from duplicated to singular after boss. | Sakura Temple bridges/railings with Dreamy reflection plane; no moving NPC on transition cells. |

#### Empyreal Court — 16 rooms

First-visit graph spine: `EM-01 → EM-02 → EM-03 → EM-04 → EM-05`; the
Galvanic Counterweight opens `EM-06 → EM-07`, whose ambush permits
`EM-08 → EM-09`.

| ID / room | Class / size | Links and gate | Required gameplay and state | Supplied art and population |
| --- | --- | --- | --- | --- |
| `EM-01` Cloudstep Landing | C / L | Belfry portal, `EM-02`, `EM-16` `[post-tribunal ferry]` | Preserve landing intro battle and return anchor. Use a broad floating quay, cloud depth, safe arrival pad, and first view of the distant Tribunal suspended above the route. | Flying Islands ground/cloud/bridge pieces with Ancient Greek landing stairs; 3 Heroic guards after intro. |
| `EM-02` Petitioner's Rise | C / M | `EM-01`, `EM-03`, `EM-10` | Switchback marble stair through fee kiosks; introduce gravity liens by showing petitioners tethered to weighted benches. Open a second stair from Weather Terrace for return. | Ancient Greek stairs/roads/columns plus Roman civic props; Heroic petitioners and clerk schedules. |
| `EM-03` Garden of Appeals | C / L | `EM-02`, `EM-04`, `EM-10`, `EM-15` `[Counterweight]` | Preserve Archangel Commander meeting and Ordinance 9-G interaction that unlocks Galvanic Counterweight research. Make this the population hub and show sealed Aerie lift. | Ancient Greek fountains/olive trees/statues with Flying Islands vegetation; 8-10 Heroic/Arcane petitioners. |
| `EM-04` Forum of Measures | C / L | `EM-03`, `EM-05`, `EM-11`, `EM-13` | Civic plaza with calibrated floor mosaics and public scales. Route to Lift is obvious; optional Archive and Embassy exits are signed. State changes from repossession auction to public hearing. | Ancient Greek marble/market/columns plus Roman roads/stands; clerks, bailiffs, envoys. |
| `EM-05` Counterweight Lift Station | C / M | `EM-04`, `EM-06` `[Galvanic Counterweight]` | Preserve Aerie Seal, specialist weight assist, and exact lift-opening flag. Counterweight visibly grounds the platform and remains attached after use; no repeated fee dialogue on transit. | Ancient Greek mechanisms/columns with Cloud City lift accents; Arcane engineer and Quantum Mind observer. |
| `EM-06` Reliquary Causeway | C / L | `EM-05`, `EM-07`, `EM-15` `[open far gate]` | Multi-island bridge where gravity direction changes at marked blue/gold thresholds. Provide railings, landing shadows, and reset pads; never require blind movement over void. | Flying Islands bridges/ground/waterfalls plus Ancient Greek columns/ruins; Wind Bailiff patrol. |
| `EM-07` Reliquary Aerie | C / L | `EM-06`, `EM-08` `[ambush cleared]`, `EM-12`, `EM-14`, `EM-15` `[open gate]`, save fountain | Preserve repossession-detail ambush, save crystal/full restore, and prerequisite for Tribunal Seal. Reliquary displays preview optional vault reward and main Charter conflict. | Ancient Greek altars/statues/treasure with Flying Islands crystals; Heroic reliquary keepers after clear. |
| `EM-08` Tribunal Descent | C / M | `EM-07`, `EM-09` `[ambush + Counterweight]`, `EM-12` `[yard latch]` | Preserve final gravity seal, full restore, and Tribunal route opening. “Descent” visibly brings the court down to the party rather than teleporting it into place. | Flying Islands cloud platforms, Ancient Greek gates, Cloud City motion accents; Gravity Knights before seal, clerks after. |
| `EM-09` Seraph Tribunal | C / L | `EM-08`, `EM-16` `[post-ending ferry]` | Dedicated High Comptroller arena and ending stage; preserve Charter Aegis reward, Archangel recruitment, one-time ending transaction, results return, epilogue, credits, and postgame rematch state. | Ancient Greek tribunal shell with Roman forum floor and Golden Palace interior accents after density normalization; full court population after ending. |
| `EM-10` Weather Clerk's Terrace | O / M | `EM-02`, `EM-03` `[open stair]` | Redirect three licensed weather vanes to stop rain falling upward, earn a storm-resistant accessory, and open the upper stair back to Garden. No main-gate dependency. | Flying Islands clouds/waterfalls/plants with Ancient Greek instruments; Cyclone Wing and Stellar Oracle identities. |
| `EM-11` Archive of Lost Appeals | O / M | `EM-04`, `EM-15` `[archive balance]` | Shelved petitions change physical weight as they are read; balance three civic cases to open research-note cache and cloister exit. Text choices are evidence-based, not trial-and-error. | Ancient Greek furniture/pottery with Final Tower shelves only if scale-approved; Arcane scholar and Heroic clerk. |
| `EM-12` Wing Repossession Yard | O / L | `EM-07`, `EM-08` `[open yard latch]` | Rescue impounded wings through a spatial routing puzzle, fight optional Storm Repossessor elite, and open a loop to Tribunal Descent. Freed wings animate in background, not as collision hazards. | Flying Islands arches/rocks/plants plus Ancient Greek fences/weapons; 4 Heroic detainees and bailiff. |
| `EM-13` Ambassadors' Aerie | O / L | `EM-04` | Distinct embassy terraces for Dragonborn and celestial delegations, optional dialogue chain, and a formation-focused equipment reward. Architecture stays Greek/Empyreal; visitors do not replace the world kit. | Ancient Greek market/columns/statues plus Flying Islands dragon bones/vegetation; 4 Dragonborn and 3 Heroic/Arcane envoys. |
| `EM-14` Cloudbreak Reliquary Vault | O / M | `EM-07` `[three reliquary sigils]` | Highest-value optional room: collect sigils from Weather Terrace, Lost Appeals, and Repossession Yard, then align them for a unique gravity accessory. No random encounters. | Golden Palace containers/doors inside Ancient Greek marble shell; Reliquary keeper only. |
| `EM-15` Gravity Inversion Cloister | X / M | `EM-03` `[Counterweight]`, `EM-06` `[open gate]`, `EM-07`, `EM-11` `[archive balance]` | Four-edge cloister that teaches marked gravity changes in safe conditions and later becomes Garden-to-Aerie shortcut. Camera rotation is prohibited; actor orientation and shadows convey direction. | Ancient Greek colonnade plus Flying Islands floating ground and Cloud City effects; bounded Gravity Knight patrol before clear. |
| `EM-16` Public Cloud Ferry | X / S | `EM-01`, `EM-09` `[ending committed]` | Post-ending Landing-to-Tribunal fast travel with visible ferry arrival/departure, deterministic spawn anchors, and no charge. It also supports no-reward rematch access. | Flying Islands cloud platform/bridges with Ancient Greek landing markers; Sky Navigator ferryman. |

#### Existing-story compatibility bindings

The expansion must move existing contracts to the named rooms instead of
renaming flags or inventing parallel progression. The manifest validator and
scenario tests must bind at least the following:

| Existing contract | Locked room binding |
| --- | --- |
| Mansion foyer clear, clock examination, 4:44/13:13 dial, ledger, House-Key Fragment, Anchor Shard | `HM-02` clock and `HM-03` ledger; `HM-04` is the resulting opened passage |
| Mansion Archive save, Gallery ambush/hour hand/cache, Nursery ambush/minute hand/cache, respite, ballroom gate/boss | `HM-05`, `HM-06`, `HM-07`, `HM-08`, `HM-09` respectively |
| Asterion dock intro/Astronaut, medical ambush/Biocircuit/save, hydro ambush/oxygen restore, Mother Computer | `AS-01`, `AS-04`, `AS-05` + `AS-06`, `AS-08`; cargo assist remains `AS-09` |
| Primeval Grove intro, traffic clue/Caveman, Cave OS decode, Relay ambush/reset/save, Tyrant | `PV-01`, `PV-02` + `PV-03`, `PV-06`, `PV-07`, `PV-08` |
| Helios skybridge intro, Neon Viper/Ordinance, transit node, clinic ambush/node, Civic Sun | `HE-01`, `HE-03`, `HE-05`, `HE-06`, `HE-08`; both nodes gate `HE-07` |
| Frosthold gate intro, Frost Lich/heat rune, causeway seal, Rune Hall ambush/save, throne seal, Auditor | `FR-01`, `FR-03`, `FR-05`, `FR-06`, `FR-07`, `FR-08` |
| Moonpetal gate intro, Kitsune/vow tablet, Garden Seal, Bell ambush/save, Palace Seal, Enma | `MP-01`, `MP-02`, `MP-05`, `MP-06`, `MP-07`, `MP-08` |
| Empyreal landing intro, Archangel/Ordinance, Aerie Seal, Aerie ambush/save, Tribunal Seal, Comptroller/ending | `EM-01`, `EM-03`, `EM-05`, `EM-07`, `EM-08`, `EM-09` |

#### Room-manifest implementation contract

Do not hard-code 102 room definitions into another monolithic renderer. Add one
validated manifest entry per room and one authored scene/resource per playable
room. The exact storage format can be `.tres` resources or validated JSON, but
the runtime contract must expose these fields:

```text
room_id, universe_id, display_name, classification, size_class,
minimum_useful_cells, scene_path, camera_bounds, entry_anchors[],
connections[{target_room, target_anchor, gate_flag, gate_polarity}],
collision_resource, navigation_resource, encounter_policy,
scripted_encounters[], interactions[], treasures[], save_point,
recall_policy, music, ambience, visual_profile_ids[], population_ids[],
first_visit_variant, stabilized_variant, postgame_variant
```

- [ ] Store rooms beneath a predictable path such as
  `res://ben_rpg/world/rooms/<universe>/<room_id>.tscn`; shared props belong in
  reusable scenes, not copied room-local nodes.
- [ ] Require every connection to resolve to a real room and entry anchor. A
  bidirectional link needs a tested reverse edge unless explicitly marked
  one-way in the locked manifest.
- [ ] Load/draw only the active room and its declared vista/preload neighbors;
  102 rooms must not become 102 simultaneously active renderers, encounter
  directors, or NPC schedules.
- [ ] Keep story flags stable. Gate adapters translate existing flags into room
  connections; do not fork equivalent flags such as a second oxygen-restored or
  bell-walk-open state.
- [ ] Add save migration from each legacy universe cell/stage to the nearest
  safe entry anchor in its bound room. Never spawn a migrated save inside a
  wall, encounter trigger, moving NPC route, or unopened gate.
- [ ] Give each room its own collision/navigation ownership and generated route
  coverage data. Universe-wide invisible blockers are prohibited.
- [ ] Declare random-encounter policy per room: `none`, `step`, `zone`, or
  `scripted_only`, plus formation pool and cooldown. Safe, puzzle, boss, and
  population-heavy rooms default to `none` or `scripted_only`.
- [ ] Bind residents through the population registry by room ID and story
  phase. Room scenes may contain spawn anchors but not duplicate character
  definitions.
- [ ] Reference admitted visual-profile IDs only. Atlas headings, demonstration
  layouts, and neighboring sprites are removed during deterministic derivative
  generation, never hidden with ad hoc runtime clipping.
- [ ] Capture every room in each materially different state. The minimum set is
  first visit and stabilized; gated, boss, restoration, and postgame rooms need
  their additional declared variants.
- [ ] Generate a graph report showing critical path, optional branches, loops,
  gates, saves, returns, and unreachable nodes for every story-state fixture.

### 9.5 Recommended implementation order

#### A. Laboratory and town

- [ ] Finalize camera, player scale, doorway scale, collision, and Y-sorting.
- [ ] Ensure the laboratory reads as a real workplace instead of a large tiled showroom.
- [ ] Ensure the town supports fast repeat visits without feeling empty.
- [ ] Expand the hub into readable civic, facility, and residential blocks with
  at least two loops and one quick cross-town route.
- [ ] Populate work and leisure schedules from Cozy Village, Kingdom Citizens,
  and approved Steampunk identities; facilities must look staffed after they
  are built.

#### B. Haunted Mansion

- [ ] Deliver the locked 16-room budget: 9 critical, 4 optional, and 3
  connective/shortcut rooms.
- [ ] Expand foyer, archive, gallery, nursery, ballroom, and connecting passages.
- [ ] Add foreground walls, door frames, shelves, stairs, and chandeliers.
- [ ] Use loops/shortcuts appropriate to a puzzle mansion.
- [ ] Preserve the 4:44 clue chain and boss progression.
- [ ] Use this as the proof that crops, scale, collision, depth, and room size all work together.
- [ ] Add a sealed undercroft and at least one second-floor overlook or balcony
  without turning the critical route into an invisible-door hunt.
- [ ] Stage associated hunters, prisoners, spirits, and hostile silhouettes by
  story phase; keep suspense through sparse placement rather than empty maps.

#### C. Asterion Station

- [ ] Deliver the locked 14-room budget: 8 critical, 4 optional, and 2
  connective/shortcut rooms.
- [ ] Expand the dock into a real arrival bay.
- [ ] Give mess, hydroponics, medical, and control distinct footprints rather than the same 8x8 shell.
- [ ] Use hatches, pressure locks, oxygen routing, and windows as navigation landmarks.
- [ ] Add maintenance and observation branches that reconnect to the main deck
  and open a fast post-stabilization route.
- [ ] Populate crew, engineering, medical, and security roles from SCI-FI
  LEGENDS and Warfront Elite rather than repeating the Astronaut.

#### D. Primeval Expanse

- [ ] Deliver the locked 14-room budget: 8 critical, 4 optional, and 2
  connective/shortcut rooms.
- [ ] Build connected outdoor paths with canopy foreground layers.
- [ ] Separate settlement, ruins, nest, and caldera through terrain and traversal, not only props.
- [ ] Add elevation/bridge cues where source art supports them.
- [ ] Add a fungal cave or interior nest as a contrasting optional subarea and
  make canopy/ground routes reconnect visibly.
- [ ] Populate the borough and trails with Beastfolk and rotation-ready
  Enchanted Forest identities; reserve Dragonborn for the caldera/roost story.

#### E. Helios Arcology

- [ ] Deliver the locked 14-room budget: 8 critical, 4 optional, and 2
  connective/shortcut rooms.
- [ ] Break full authored quadrants into navigable foreground/background layers.
- [ ] Preserve city perspective while making routes wider and more legible.
- [ ] Distinguish market, transit, clinic, skybridge, and core through gameplay as well as scenery.
- [ ] Add one service-level shortcut and an optional recreation stack so the
  city has civilian life beyond its critical corridor.
- [ ] Populate vendors, commuters, technicians, officials, and patrols from the
  Cyberpunk roster; keep arena/sports rosters inside their authored district.

#### F. Frosthold Kingdom

- [ ] Deliver the locked 14-room budget: 8 critical, 4 optional, and 2
  connective/shortcut rooms.
- [ ] Expand gate, market, causeway, rune hall, and throne approach.
- [ ] Normalize castle, house, crystal, bridge, and character scale.
- [ ] Give the crystal causeway and rune hall real traversal identities.
- [ ] Add an ice-cave or lower-village branch and a visible thaw/restoration
  change after stabilization.
- [ ] Populate soldiers, hunters, merchants, clergy, and court roles from the
  Frozen Kingdom roster, with only thematically selected Arcane visitors.

#### G. Moonpetal Court

- [ ] Deliver the locked 14-room budget: 8 critical, 4 optional, and 2
  connective/shortcut rooms.
- [ ] Replace narrow processional strips with connected courtyards and gardens.
- [ ] Normalize gates, temple architecture, ponds, gardens, and characters.
- [ ] Add foreground gates and trees that characters can pass behind.
- [ ] Add a tea-garden loop and at least one interior or covered bell passage
  that reconnects to the processional route.
- [ ] Populate guards, attendants, shrine staff, witnesses, and garden visitors
  from the Samurai/Yokai roster and approved nature guests.

#### H. Empyreal Court

- [ ] Deliver the locked 16-room budget: 9 critical, 5 optional, and 2
  connective/shortcut rooms.
- [ ] Preserve the strongest existing composition while expanding terrace traversal.
- [ ] Add readable gravity routes, foreground columns, and platform connections.
- [ ] Avoid repeating the same small marble terrace five times.
- [ ] Add at least two optional terrace/aerie routes with previewed destinations
  and one shortcut back to Cloudstep Landing.
- [ ] Populate bailiffs, petitioners, clerks, envoys, and civic icons from the
  Heroic roster plus approved celestial/dragon envoys.

#### I. Optional annexes

- [ ] Do not begin Ashfall or Pelagic production until the Mansion and all six
  M4 universes meet their walkable-footprint and population targets at
  implementation state.
- [ ] If an annex is promoted into a full named universe, give it at least 14
  authored rooms under the same useful-space rules; a smaller side area remains
  an annex and is not counted among the 102 campaign-universe rooms.
- [ ] Reuse the campaign's anchor/return model while keeping annex progression
  optional and postgame-safe.
- [ ] Give each annex its own palette, population registry entries, bestiary
  slice, reward identity, and reason to revisit; a tileset showcase alone is
  not a level.

### 9.6 Level and population acceptance criteria

- [ ] A manifest test finds exactly 102 unique room IDs with the locked per-world
  and `C`/`O`/`X` totals; missing, duplicate, or unclassified IDs fail the build.
- [ ] Every declared non-one-way connection has a valid reverse edge and both
  entry anchors; every remote unlock names the edge it changes.
- [ ] Fresh, mid-puzzle, stabilized, and postgame graph fixtures prove intended
  boss reachability, optional-room reachability, return routes, and gate states.
- [ ] Every level is captured at gameplay scale and native scale.
- [ ] Every walkable cell matches visible ground.
- [ ] Every solid cell matches visible obstruction or intentional boundary.
- [ ] No route crosses black/gray void or unpainted scenery.
- [ ] No room is approved solely because a smoke test reaches its exit.
- [ ] A first-time player can identify the critical route without an invisible trigger hunt.
- [ ] Optional paths are visually signposted but not confused with the critical route.
- [ ] Backtracking time is measured and remains reasonable.
- [ ] Each main universe meets the Section 9.1 footprint, composition,
  traversal-time, optional-content, and population targets or records an
  approved exception supported by playtest evidence.
- [ ] A route-coverage report distinguishes useful walkable cells from
  unreachable filler and confirms every critical/optional destination is
  reachable with keyboard, controller, and click-to-move.
- [ ] Every resident uses an approved world assignment, visual profile, foot
  anchor, collision rule, and story-phase record.
- [ ] No resident blocks a transition or required interaction during a
  20-minute population/navigation soak.
- [ ] Associated SakPix packs meet their representation targets, and no generic
  placeholder remains where an approved associated character exists.
- [ ] Stabilization and postgame revisits visibly change at least one route,
  resident schedule, or environmental state in every main universe.
- [ ] Every room's admitted art resolves to its declared primary/supporting pack
  family, and no runtime crop contains a source-sheet heading, legend, demo
  composition, or neighboring sprite.
- [ ] A topology review rejects rooms that duplicate another room's walkable
  mask through translation, reflection, rotation, or cosmetic prop changes.
- [ ] At least 204 baseline captures exist—first-visit and stabilized for all
  102 rooms—plus separate captures for every additional boss, gate, restoration,
  or postgame variant declared by the manifest.

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

- The earlier five-room renderer proof remains useful evidence, but it does not
  satisfy the expanded Mansion milestone.
- All `HM-01` through `HM-16` scenes exist at their locked size classes and
  minimum useful-cell budgets, and their bidirectional connection graph matches
  Section 9.4.
- The 4:44 clock, ledger, archive save, hour-hand gallery, minute-hand nursery,
  and ballroom boss sequence remains intact across the enlarged graph.
- The Haunted Mansion, Crimson Gothic, and approved supporting Tilesets families
  are admitted through runtime profiles with heading-free crops and recorded
  provenance; no room references a raw source-library path.
- The locked resident roster uses the associated SakPix population profiles,
  eight-direction facing, route occupancy, and story-phase placement.
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

- Expansion admission complete: selected environment assets and SakPix
  characters have stable IDs, profiles, provenance, density decisions, and
  approved per-world contact sheets; runtime code has no staging-root paths.
- Population foundation complete: the data-driven registry, eight-direction
  facing, diagonal movement, schedules, story-phase placement, occupancy rules,
  and save/reload behavior pass focused tests.
- Asterion and Primeval meet the Section 9 size, topology, content-density, and
  associated-population targets.
- Helios and Frosthold meet the Section 9 size, topology, content-density, and
  associated-population targets.
- Moonpetal and Empyreal meet the Section 9 size, topology, content-density, and
  associated-population targets.
- Every core SakPix collection meets its representation target; every remaining
  collection has an approved annex/reserve/rejection disposition.
- Ending, recall, stabilized revisits, and postgame routes are verified after
  migration.
- Ashfall and Pelagic annexes enter implementation only through separately
  approved work packages after the Mansion and six M4 universes meet implementation
  state; they do not delay core-world fixes.

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
- [ ] Every main universe meets the Section 9 scale/content/population targets
  or has a recorded, playtest-supported exception approved by the reviewer.
- [ ] Associated SakPix collections visibly populate their assigned worlds, and
  no generic placeholder remains where an approved matching character exists.

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
- [ ] Route-coverage evidence proves that reported world size consists of useful
  reachable space rather than inaccessible scenery or stretched empty floor.
- [ ] Resident schedules, patrols, and story-phase relocations add life without
  blocking doors, transitions, anchors, puzzles, or treasure.

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
9. [x] Implement the earlier five-room Mansion renderer proof. This historical
   proof does not satisfy the locked `HM-01` through `HM-16` milestone.
10. [x] Implement the battle UI scale pass at the default 960x540 window.
11. [x] Implement browser title-card overflow fixes at 800x600 and 1280x720.
12. [ ] Run and record native-scale visual, keyboard/mouse, controller,
   save/reload, and provisional performance sign-off for the vertical slice.
13. [ ] Open a draft pull request or dispatch the workflow, then archive the
   first clean remote baseline for the exact tested SHA.
14. [x] Generate and review deterministic inventories for `assets/Tilesets`
   and `assets/EXPANSION`, including all 149 Tilesets dispositions, duplicate
   families, engine-demo exclusions, dimensions, checksums, license candidates,
   and the Section 9 world assignments.
15. [ ] Record pack-level provenance decisions for the first migration pair and
   preserve exact terms/credit evidence; do not infer that one CC0 file covers
   an unrelated neighboring pack.
16. [ ] Produce native-scale environment and SakPix contact sheets for Mansion,
   Asterion, and Primeval using their locked primary Tilesets kits; approve
   density, palette, perspective, character height, heading-free crops, and
   foot-anchor conversions.
17. [x] Add the population-registry schema and validation for stable identity,
   canonical home, eight directions, story phase, route occupancy, profile, and
   provenance before placing new residents by hand.
18. [x] Add a release-code check that rejects direct references to all three
   local source roots: `assets/Tilesets`, `assets/EXPANSION`, and the SakPix
   staging tree.
19. [ ] Write the Mansion, Asterion, and Primeval work-package records against
   their locked room IDs, exact connection graph, useful-cell totals,
   traversal-time target, population roster, asset/profile list,
   optional-content list, performance budget, migration anchors, and required
   state capture matrix.
20. [ ] Implement and accept the complete `HM-01` through `HM-16` Mansion graph
   only after items 14-19 establish its admitted art, population, provenance,
   and room contracts. M2 cannot close on the earlier five-room proof.

Only after every unchecked item in this batch is accepted should another
universe enter acceptance review. Inventory, licensing review, contact sheets,
zone graphs, and population-registry implementation may proceed as expansion
preproduction while those gates close, but unapproved staged assets must not
enter release maps. Existing M4 work remains exploratory evidence until then.

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
| M0 — Verification green | In progress | Local runtime and source-library asset contracts pass; isolated Godot save sentinel remains protected; draft PR #1 has active remote jobs | A clean remote browser/runtime-asset/Godot pass and a fresh all-smoke baseline are still required |
| M1 — Visual foundation | In progress | `FIELD_SCALE_BIBLE.md`, 368 visual profiles, runtime inventory/provenance generators, layered field registry, eight foreground scripts, camera rounding, and focused smoke tests exist | Vertical-slice profile coverage is not 100%; 162/185 static runtime textures are profiled; native-scale review and camera/resolution sign-off remain open |
| M2 — Mansion vertical slice | In progress; legacy proof only | A five-room Mansion layout expansion, foreground capture, collision/layout smoke coverage, and refreshed room captures exist | Implement and accept all `HM-01`-`HM-16` rooms, locked links, supplied Tilesets profiles, associated SakPix population, puzzle continuity, native-scale input, save/reload, and reviewer sign-off |
| M3 — Shared presentation | In progress | Battle profile coverage, battle accessibility tests, text scaling, persisted accessibility settings, field-layer/transition-soak tests, and an independent Empyreal ground renderer exist | Human readability and input sign-off remain open; shared field architecture is transitional rather than a complete replacement of the procedural renderer |
| M4 — Universe migration | Started early; pre-amendment prototypes | Each non-Mansion universe has an expanded 8x4 footprint/layout prototype; all six foreground implementations, including Helios, exist; refreshed captures and layout tests exist | The 8x4 prototypes do not satisfy the locked 14/16-room manifests. Build and accept every Section 9.4 room with admitted Tilesets/EXPANSION profiles and associated SakPix populations after M0/M2 gates; no universe has complete human sign-off |
| M5 — Polish/production | Started, not complete | 12-cycle field transition soak, performance diagnostic scene, browser overflow work, accessibility preferences, and shutdown-baseline tests exist | Multi-hour soak, declared performance targets, resolution/input matrix, shutdown ownership decision, and browser product decision remain open |
| M6 — Release candidate | Not started | Runtime provenance ledger and local CI configuration provide foundations | Licensing review, platform/signing decisions, external clean export, remote CI, and required archived playthroughs remain open |

### Fresh verification evidence

- `npm run validate:source-inventory`: pass on July 23, 2026. The deterministic
  ignored-source inventory matches the locked 149-pack Tilesets disposition
  register and records 155 packs / 69,017 files (149 Tilesets packs / 5,714
  files and six EXPANSION packs / 63,303 files), including 5,548 exact
  duplicate families. All 155 packs remain `review_required` for distribution;
  inventory evidence is not a license decision or runtime admission.
- `npm run check`: pass, 16/16 browser tests.
- `npm run validate:source-library`: pass. The approved library contains 21,018
  catalogued rasters with 0 errors and 0 warnings; all 51 NPC visuals are
  editor-ready. The locally synced, unreviewed `assets/EXPANSION/` staging tree
  is explicitly quarantined from the approved-library denominator and cannot be
  referenced by the curated catalog.
- `npm run validate:runtime-assets`: pass. The derived facade, runtime visual
  inventory, provenance ledger, visual manifest, and native-scale contact sheet
  are current.
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

At the time of this amendment, no further structural design work was expected.
Section 22 supersedes that statement with the later 102-room and full-Tilesets
requirements. M0 validation repair and M1/M2 acceptance remain quality gates.

---

## 22. Detailed universe and Tilesets amendment — July 22, 2026

This amendment supersedes the earlier generic 6-8-room and expansion-only
assumptions.

- The seven campaign universes now have a locked 102-room manifest: 16 Mansion,
  14 Asterion, 14 Primeval, 14 Helios, 14 Frosthold, 14 Moonpetal, and 16
  Empyreal.
- Every room has a stable ID, classification, size class, explicit links/gates,
  gameplay/state payload, primary art family, and population direction in
  Section 9.4.
- The existing story interactions and flags are bound to exact destination
  rooms so expansion cannot replace or duplicate the authored puzzles.
- `assets/Tilesets` is a primary source library: 149 packs, 5,715 files, 4,904
  images, and approximately 2.14 GB. Its root CC0 license evidence must be bound
  to admitted packs and derivatives in the provenance ledger.
- Representative primary sheets were visually inspected for Haunted Mansion,
  space-station, Jurassic/alien-jungle, cyberpunk/subway, Frozen/Frostbound,
  Sakura/Dreamy, Greek/Roman/Flying Islands, wasteland, underwater, Steamforge,
  Wild West, and town families. Their presentation headings and demo fragments
  require deterministic crops and may never appear at runtime.
- Known duplicate families are named in Section 9.3 and must collapse before
  catalog admission and export.
- The 25 SakPix collections retain explicit core-world or optional-address
  assignments; the enlarged rooms use the population registry rather than
  hand-duplicated NPC nodes.
- The existing five-room Mansion proof and six 8x4 universe prototypes are
  historical renderer/layout evidence only. This amendment marks none of the
  102-room manifest implemented or accepted.

The next content implementation claim must cite room IDs from Section 9.4 or
Section 23 and admitted profile IDs from the three source libraries. “Expanded”
without those two identifiers is not an auditable completion claim.

---

## 23. Full-location spatial completion amendment — July 22, 2026

This amendment closes the remaining unevenness identified after Section 22.
It is authoritative where it adds New Philadelphia, facility interiors,
optional addresses, exact spatial blueprints, and complete SakPix identity
bindings. It does not mark any of this content implemented.

### 23.1 Locked total location budget

| Location group | Critical | Optional | Connective | Hub/service | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| Seven core universes from Section 9.4 | 58 | 29 | 15 | 0 | **102** |
| New Philadelphia exterior/laboratory districts | 0 | 0 | 0 | 15 | **15** |
| Stable facility interiors | 0 | 0 | 0 | 11 | **11** |
| Ashfall Address | 7 | 3 | 2 | 0 | **12** |
| Pelagic Address | 7 | 3 | 2 | 0 | **12** |
| Steamforge Address | 7 | 3 | 2 | 0 | **12** |
| Frontier Address | 6 | 2 | 2 | 0 | **10** |
| Warfront Address | 6 | 2 | 2 | 0 | **10** |
| Liminal Address | 5 | 2 | 1 | 0 | **8** |
| **Complete planned location total** | **96** | **44** | **26** | **26** | **192** |

The five 10-12-room addresses and the eight-room Liminal Address are optional
campaigns, not padding required to finish the main ending. Each unlocks from a
post-stabilization town lead, uses separate flags and rewards, and may not
silently become a prerequisite for an existing core-world quest. Their maps and
populations can enter production only after the relevant source packs pass
Section 8 admission.

### 23.2 Exact coordinate, camera, collision, and placement system

All coordinates in this section are room-local movement cells with `(0,0)` at
the upper-left. One cell is exactly 48x48 world pixels. The listed dimensions
include the blocked perimeter. Camera bounds are exactly
`Rect2i(0, 0, width * 48, height * 48)` and may be reduced only by a documented
cinematic clamp. The player arrives two cells inward from the named port, facing
the center; followers occupy the next two clear cells perpendicular to travel.

Each blueprint exposes eight three-cell-wide ports in this order:
`Nw`, `Ne`, `E1`, `E2`, `Se`, `Sw`, `W2`, `W1`. A room's port-binding table
names the target reached from each used port. Unused ports are solid wall,
railing, cliff, or scenery and cannot remain invisible exits.

| Blueprint | Cells | Exact ports: `Nw; Ne; E1; E2; Se; Sw; W2; W1` |
| --- | ---: | --- |
| `S1` | 14x10 | `(4,1); (9,1); (12,3); (12,6); (9,8); (4,8); (1,6); (1,3)` |
| `S2` | 16x10 | `(5,1); (10,1); (14,3); (14,6); (10,8); (5,8); (1,6); (1,3)` |
| `S3` | 18x10 | `(6,1); (12,1); (16,3); (16,6); (12,8); (6,8); (1,6); (1,3)` |
| `M1` | 18x14 | `(6,1); (12,1); (16,4); (16,9); (12,12); (6,12); (1,9); (1,4)` |
| `M2` | 20x14 | `(6,1); (13,1); (18,4); (18,9); (13,12); (6,12); (1,9); (1,4)` |
| `M3` | 22x14 | `(7,1); (14,1); (20,4); (20,9); (14,12); (7,12); (1,9); (1,4)` |
| `M4` | 18x16 | `(6,1); (12,1); (16,5); (16,10); (12,14); (6,14); (1,10); (1,5)` |
| `L1` | 24x18 | `(8,1); (16,1); (22,6); (22,12); (16,16); (8,16); (1,12); (1,6)` |
| `L2` | 26x18 | `(8,1); (17,1); (24,6); (24,12); (17,16); (8,16); (1,12); (1,6)` |
| `L3` | 28x18 | `(9,1); (18,1); (26,6); (26,12); (18,16); (9,16); (1,12); (1,6)` |
| `L4` | 24x20 | `(8,1); (16,1); (22,6); (22,13); (16,18); (8,18); (1,13); (1,6)` |
| `H1` | 30x20 | `(10,1); (20,1); (28,6); (28,13); (20,18); (10,18); (1,13); (1,6)` |
| `H2` | 32x22 | `(10,1); (21,1); (30,7); (30,14); (21,20); (10,20); (1,14); (1,7)` |
| `I1` | 18x12 | `(6,1); (12,1); (16,4); (16,8); (12,10); (6,10); (1,8); (1,4)` |
| `I2` | 20x14 | `(6,1); (13,1); (18,4); (18,9); (13,12); (6,12); (1,9); (1,4)` |
| `I3` | 24x16 | `(8,1); (16,1); (22,5); (22,10); (16,14); (8,14); (1,10); (1,5)` |

#### Shared exact placement anchors

For a blueprint of width `w` and height `h`, the following integer-cell
formulas are part of the data contract and are evaluated once during validation:

- Population anchors: `P1=(floor(w/4),floor(h/3))`,
  `P2=(floor(w/2),floor(h/3))`, `P3=(floor(3w/4),floor(h/3))`,
  `P4=(floor(w/4),floor(2h/3))`, `P5=(floor(w/2),floor(2h/3))`,
  and `P6=(floor(3w/4),floor(2h/3))`.
- Treasure anchors: `Tnw=(3,3)`, `Tne=(w-4,3)`, `Tsw=(3,h-4)`, and
  `Tse=(w-4,h-4)`. A room row selects one; `none` means no treasure container.
- Interaction anchors: `Icenter=(floor(w/2),floor(h/2))`,
  `Inorth=(floor(w/2),3)`, `Ieast=(w-4,floor(h/2))`,
  `Isouth=(floor(w/2),h-4)`, and `Iwest=(3,floor(h/2))`.
- Zone `Za` is `Rect2i(3,3,w-6,h-6)`. `Zw` and `Ze` split `Za` at
  `floor(w/2)` with a two-cell neutral aisle. `Zboss` is `Za` minus a
  three-cell-deep arrival lane from the bound approach port. `Zsafe` is the
  five-cell radius around every arrival/save point and may never overlap an
  encounter trigger.

The perimeter is blocked except for bound ports. Every landmark or building
uses an authored collision polygon; its lower contact footprint is removed from
navigation and its upper pixels live in a foreground layer. Navigation must
retain two disjoint routes around a central landmark in `M`, `L`, and `H`
blueprints unless the room is explicitly a choke, puzzle, or boss arena.
Population routes may connect only `P` anchors and interaction/service anchors;
they may never reserve ports, `Zsafe`, treasure cells, or puzzle cells.

Each room manifest must store the selected blueprint, its resolved dimensions,
port bindings, collision-mask resource, navigation resource, encounter zone,
treasure anchor, interaction anchors, populated `P` anchors by story phase, and
the exact visual-profile IDs used at each landmark. A screenshot is not
evidence for any of these data fields.

### 23.3 New Philadelphia and laboratory — 15 locked locations

New Philadelphia is a connected authored hub, not one 32x28 construction
screen. Existing flags, facility jobs, movable construction choice, laboratory
inventions, resident state, and postgame free roam remain intact. No town
district uses random encounters. A story event may use `scripted_only` zones,
but ordinary routes, facility doors, and resident schedules remain safe.

| ID / location | Blueprint and exact port binding | Placement contract | Gameplay, supplied art, and population |
| --- | --- | --- | --- |
| `NP-01` Franklin Laboratory Main Floor | `H1`; `Ne→NP-02; Se→NP-04` | `none; Icenter` opening/workbench; `P1-P3` assistants; `P4-P6` visitor demonstrations | Preserve opening, party access, save/load arrival, and town exit. Use `Modern Laboratory Assets` floor/wall/door sheets and profiled machinery; player spawn remains in `Zsafe` with a clear two-route path to the exit. |
| `NP-02` Invention Annex | `I3`; `Nw→NP-01; Ne→NP-03` | `Tne` first research cache; `Icenter` invention bench; `P1-P4` researchers | Stable home for every existing and future invention recipe, preview model, materials ledger, and construction result. Use laboratory sheets 1-7 and approved Steampunk instruments; no portal or NPC route crosses the bench footprint. |
| `NP-03` Power and Records Basement | `M4`; `Nw→NP-02; E1→NP-05 [town_foundations_complete]; E2→LM-01 [postgame anomaly]` | `Tsw` emergency supplies; `Icenter` fault-line regulator; `P1-P2` technicians | Houses generator, save migration console, provenance-readable archive, and the post-founding service lift to Old-Town Market. Modern Laboratory auto-walls, Industrial Factory power, and bounded Steamforged pipe derivatives. |
| `NP-04` Founders Square | `H2`; `Nw→NP-01; E1→NP-06; E2→NP-07; W2→NP-05` | `none; Icenter` town notice/anchor monument; `P1-P6` rotating residents | Main orientation and quest handoff hub. Use `Modern World Overworld` roads, Medieval town square decorations, Cozy Spring seating/lights, and visible district signs. State changes: survey stakes → founding monument → seven anchor lights → postgame public Charter. |
| `NP-05` Old-Town Market | `L2`; `E1→NP-04; E2→NP-13; Se→NP-08; W1→NP-03 [foundations]` | `LOT-01, LOT-02`; `Tsw` rotating merchant cache; `P1-P6` vendors/residents | Cobblestone market with two build lots, stalls, blacksmith/tavern props, and a basement shortcut. Primary `Medieval village town` sheets 1, 8, 12-14, 17-19; Cozy Cafe/Kingdom Citizens support. |
| `NP-06` Civic Workshop Row | `L3`; `W1→NP-04; E1→NP-10; Se→NP-09` | `LOT-03, LOT-04`; `Tse` salvage bin; `Icenter` public repair board; `P1-P5` workers | Two construction lots beside shared workshops. Use Modern Construction, Modern Industrial Factory, Fantasy Structures, Environment Decor, and blacksmith props. Armory deliveries and invention-job workers route here without blocking district ports. |
| `NP-07` Anchor Promenade | `H1`; `W1→NP-04; E1→NP-12; Se→NP-11; Sw→NP-15` | `LOT-05, LOT-06`; `none`; `Icenter` anchor-status map; `P1-P6` delegates | Ceremonial route where anchored facilities visibly change weather/light. Modern World ground, Cozy Spring lamps/planters, Level Map display derivative, and architecture accents from each stabilized world; mixed visitors appear only after their home universe stabilizes. |
| `NP-08` Farm and Spring Terraces | `L3`; `Nw→NP-05; E1→NP-09; Se→NP-14` | `LOT-07`; `Tne` harvest basket; `Icenter` irrigation pump; `P1-P6` growers/families | Use all relevant `Cozy farming village` soil/crop/farmhouse/barn/tool/animal/orchard sheets and `Cozy Spring` water/flower/bridge/garden sheets. Crop state advances with town phase; no oversized facade replaces usable fields. |
| `NP-09` Riverside and Harbor Walk | `L2`; `Nw→NP-06; W1→NP-08; Se→NP-14; E2→PL-01 [Pelagic chart]` | `none; Tne` fishing reward; `Icenter` ferry board; `P1-P5` fishers/traders | Modern World shoreline plus Cozy Spring water/boardwalk and approved Pirate Harbor props at postgame only. Provides a calm loop and future Pelagic lead without becoming a mandatory port. |
| `NP-10` Clinic Gardens | `L1`; `W1→NP-06; E2→NP-11; Sw→NP-13` | `LOT-08`; `Tnw` herb cache; `Icenter` public recovery fountain; `P1-P5` patients/gardeners | Modern Pharmacy/Clinic support, Cozy Spring beds/plants, Magic Forest medicinal details, and readable seating. Clinic residents use bounded slow routes and never occupy facility doors. |
| `NP-11` South Commons | `L3`; `Nw→NP-07; W1→NP-10; E1→NP-12` | `LOT-09, LOT-10`; `none`; `Icenter` events stage; `P1-P6` residents/performers | Broad community green for founding supper, sport exhibitions, and stabilized-world festivals. Modern World ground, Cozy Spring furniture, Gaming Room event props, and removable festival dressing. |
| `NP-12` Transit and Service Yard | `L3`; `W1→NP-07; W2→NP-11; Se→NP-14; Sw→NP-15; Nw→SF-01 [salvage telemetry]; Ne→FT-01 [rail deed]` | `LOT-11`; `Tse` delivery cache; `Icenter` dispatch board; `P1-P5` drivers/mechanics | Modern Airport, Airplane, gas-station, construction, warehouse, and cargo derivatives. Holds service vehicles and dispatch without turning town into an airport map; portal facilities remain walk-in buildings. |
| `NP-13` Residential and Baker Lane | `M3`; `Ne→NP-05; E1→NP-10` | `none; Tsw` community recipe; `Icenter` neighborhood notice; `P1-P6` residents | Medieval/Cozy houses, ordinary Modern Interiors, bakery, flower boxes, mailboxes, and homey props. Morning/evening schedules give town residents real homes rather than leaving everyone at work. |
| `NP-14` Recreation Park | `L1`; `Nw→NP-08; Ne→NP-09; W1→NP-12` | `none; Tne` exhibition reward; `Icenter` recreation booking; `P1-P6` athletes/visitors | Park, arcade pavilion, gym court, and field exhibition space. Helios Ring/Football guests unlock after `HE-11`; `XModern Arcade` stays inside the pavilion and does not replace outdoor park art. |
| `NP-15` Embassy Green | `H1`; `Ne→NP-07; E1→NP-12; E2→AF-01 [reclamation lead]; Se→WF-01 [war ledger]` | `none; Icenter` Charter table; `P1-P6` delegations | Empty surveyed green before stabilization, then rotating universe embassies, and finally the postgame Charter gathering. Use New Philadelphia base terrain with small, profile-approved cultural pavilions; no visitor faction replaces the hub's visual identity. |

#### Eleven movable construction lots

The player may place any available facility in any empty lot. Therefore a lot
stores only exterior placement and the destination `facility_interior_id`; it
must not own facility story state. All lots use a 9x6-cell facade footprint,
retain a three-cell front apron, and expose the exact door cell below.

| Lot | District | Exact footprint | Exterior door |
| --- | --- | --- | --- |
| `LOT-01` | `NP-05` | `Rect2i(3,3,9,6)` | `(7,9)` |
| `LOT-02` | `NP-05` | `Rect2i(14,3,9,6)` | `(18,9)` |
| `LOT-03` | `NP-06` | `Rect2i(3,3,9,6)` | `(7,9)` |
| `LOT-04` | `NP-06` | `Rect2i(16,3,9,6)` | `(20,9)` |
| `LOT-05` | `NP-07` | `Rect2i(3,3,9,6)` | `(7,9)` |
| `LOT-06` | `NP-07` | `Rect2i(18,3,9,6)` | `(22,9)` |
| `LOT-07` | `NP-08` | `Rect2i(9,3,9,6)` | `(13,9)` |
| `LOT-08` | `NP-10` | `Rect2i(7,3,9,6)` | `(11,9)` |
| `LOT-09` | `NP-11` | `Rect2i(3,3,9,6)` | `(7,9)` |
| `LOT-10` | `NP-11` | `Rect2i(16,3,9,6)` | `(20,9)` |
| `LOT-11` | `NP-12` | `Rect2i(9,3,9,6)` | `(13,9)` |

### 23.4 Stable facility interiors — 11 locked locations

`LOT` below means the dynamically selected exterior lot. Returning from an
interior resolves that saved lot and its exterior door; moving a facility in
sandbox mode updates the exterior link without changing its stable interior ID,
jobs, residents, or universe portal state.

| ID / interior | Blueprint and exact ports | Placement and preserved contract | Supplied art and population |
| --- | --- | --- | --- |
| `FI-01` Café | `I2; Sw→LOT` | `Icenter` service counter; `Tne` pantry; `P1-P4` staff/guests; `none` encounters. Preserve morning service, Founders' Supper, Serving-Table Automaton, and Hearth Exchange. | Cafe Assets canonical derivative, Modern Restaurant food, Medieval tavern props; Cozy Café owner/baker and Kingdom tavern staff. |
| `FI-02` Library | `I3; Sw→LOT` | `Icenter` catalog desk; `Tne` restricted records; `P1-P5` staff/readers. Preserve catalog/echo jobs, bestiary records, Cataloging Engine, Mansion notes, and Tribunal Ledger rematch. | Library facade family, Magic Wizard Academy books, Medieval shelves, Final Tower archive accents; Cozy Librarian, Elder Scholar, Guild Receptionist. |
| `FI-03` Clinic | `I2; Sw→LOT` | `Icenter` treatment desk; `Tnw` medicine cabinet; `P1-P4` staff/patients; all beds outside routes. Preserve tonic rounds, emergency drill, Medical Kite, recovery, and save tutorial. | Modern Pharmacy/Laboratory/Interior sheets, Cozy Spring herbs; Shepherd Girl, Herbalist, combat-medical visitors after stabilization. |
| `FI-04` Armory | `I3; Sw→LOT` | `Icenter` forge/service; `Tse` locked stock; `P1-P5` smiths/customers. Preserve buy/sell, reforge, salvage and field-refit jobs, stock gates, and equipment previews. | Medieval blacksmith, Fantasy Structures, Factory/Industrial workbench derivatives; Cozy and Kingdom blacksmiths plus scheduled specialists. |
| `FI-05` Mansion Anchor Hall | `I2; Sw→LOT; Ne→HM-01` | `Icenter` anchor regulator; `Tnw` echo containment; `P1-P4` watch. Portal safe radius never overlaps service/job actors. Preserve Mansion jobs and all existing anchor flags. | Haunted Mansion exterior threshold inside New Philadelphia masonry; Crimson Hunters arrive after foyer and victory phases. |
| `FI-06` Observatory | `I3; Sw→LOT; Ne→AS-01` | `Icenter` telescope/fault map; `Tne` telemetry cache; `P1-P5` navigators. Preserve chart/salvage jobs and Asterion anchor progression. | Bright Cyberpunk coherent observatory facade, Space Station observation/consoles, Steampunk instruments; SCI-FI and Steampunk visitors by phase. |
| `FI-07` Trailhead Lodge | `I2; Sw→LOT; Ne→PV-01` | `Icenter` expedition board; `Tnw` provisions; `P1-P5` guides. Preserve foraging/fossil jobs, Telegraph boost, and Primeval anchor flags. | Medieval lodge, Cozy farming tools, Jurassic camp/fossil derivatives; Beastfolk/Dragonborn visitors only after their states unlock. |
| `FI-08` Afterlight Club | `I3; Sw→LOT; Ne→HE-01` | `Icenter` stage/console; `Tse` signal locker; `P1-P6` staff/performers. Preserve house-show/signal jobs and Helios portal; party floor leaves a two-cell circulation loop. | Cyberpunk/Bright Cyberpunk, Modern Bar & Nightclub canonical set, XModern Arcade accents; Cyberpunk, Ring, and Football guests by schedule. |
| `FI-09` Cold Storage | `I2; Sw→LOT; Ne→FR-01` | `Icenter` thermal ledger; `Tne` provisions; `P1-P4` workers. Preserve inventory/audit jobs, Coil boost, and Frosthold portal; warm/cold collision state is visual only. | Snowy Village interior/food/warm lights, Frozen Kingdom ice, Antarctic equipment; Frozen residents after gate/stabilization. |
| `FI-10` Tea House | `I3; Sw→LOT; Ne→MP-01` | `Icenter` tea service; `Tnw` memory ledger; `P1-P6` staff/delegates. Preserve service/audit jobs, Lantern boost, and Moonpetal portal; reflection effect cannot obscure doors. | Sakura food/cafe, furniture, counters, lanterns, Dreamy reflection layer; Samurai/Yokai and blossom visitors by phase. |
| `FI-11` Belfry | `I3; Sw→LOT; Ne→EM-01` | `Icenter` bell/weather instrument; `Tne` appeal records; `P1-P5` clerks/delegates. Preserve weather/gravity jobs, Counterweight boost, Empyreal portal, and postgame Charter signal. | Ancient Greek walls/columns/stairs/divine tiles, Flying Islands cloud windows, Steampunk mechanism subset; Heroic/Arcane delegations by phase. |

### 23.5 Ashfall Address — 12 rooms

Unlock lead: the stabilized Mansion undercroft and any two completed core
universes reveal an address whose inhabitants are rebuilding rather than
waiting to be rescued. Ashfall uses its own `ashfall_*` flags and never gates a
core quest.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `AF-01` Cinder Gate | C / `L2; E1→AF-02; Sw→AF-11; Nw→NP-15 portal` | `scripted_only Zw` arrival raid; `Icenter` air-quality beacon; `Tnw` filters; `P1-P3` survivor watch after clear | Ashlands, scorched desert, Wasteland warning/light sheets; Scrap Kid, Dust Hunter, and Iron Sentinel. |
| `AF-02` Scavenger Exchange | C / `H1; W1→AF-01; E1→AF-03; Se→AF-09` | `none` after first inspection; `Icenter` barter board; `Tse` one-time salvage; `P1-P6` traders | Wasteland survivor loot/barricades/cars, Post-Apocalypse props; Road King, Junker Mechanic, Desert Gunner, Thunder Rider. |
| `AF-03` Green Ruins Avenue | C / `L3; W1→AF-02; E1→AF-04; Se→AF-08` | `zone Zw/Ze` mutated patrols; `Icenter` reclamation switch; `Tne` rooftop cache; vegetation expands after victory | Green-Apocalyptic Ruins, Nuclear War Ruins, dead-tree and overgrowth sheets; Toxic Shaman and survivor scouts. |
| `AF-04` Polluted Causeway | C / `M3; W1→AF-03; E1→AF-05; Se→AF-10` | `zone Ze` toxic hazards; `Icenter` purifier routing; `Tsw` antidotes; purifier creates a safe central aisle | Polluted Wasteland, toxic barrels/crystals/hazard tiles, ruined roads; Sand Viper patrol and Bone Reaper apparition. |
| `AF-05` Abandoned Bunker Exterior | C / `L1; W1→AF-04; E1→AF-06; Sw→AF-11` | `scripted_only Za` defense line; `Icenter` blast-door power; `Tne` bunker key; cleared state opens parking/subway loop | Abandoned Nuclear Bunker exterior, Survival Shelter, chain-link defenses; Iron Sentinel and Infernal Prince envoy. |
| `AF-06` Continuity Bunker | C / `L3; W1→AF-05; E1→AF-07; Se→AF-12` | `zone Zw/Ze` malfunctioning defenses; `Icenter` continuity terminal; `Tsw` research notes; save at `P2` outside combat | Nuclear Bunker Interior, industrial doors/pipes/wiring, Dark Dimension terminals; Junker Mechanic and Blood Priest records. |
| `AF-07` Furnace of False Salvation | C / `L4; W1→AF-06` | `boss Zboss` Wasteland Emperor/Infernal Warlord pact; `Icenter` reactor choice; `Tne` fixed reclamation core after victory; no random encounters | Ashlands, Lava Cavern, infernal throne/fire, bunker reactor; Wasteland Emperor and Infernal Warlord first state, survivor council afterward. |
| `AF-08` Abandoned Supermarket | O / `L3; Nw→AF-03; E1→AF-09` | `zone Ze` scavenger formation; `Icenter` shelf-route inventory puzzle; `Tse` provisions; market becomes supply depot | Post-Apocalyptic Abandoned Supermarket derivatives only; Desert Gunner, Junker Mechanic, and survivor workers. |
| `AF-09` Recovery Farm | O / `L2; Nw→AF-02; W1→AF-08` | `none` after irrigation repair; `Icenter` pump; `Tne` harvest reward; `P1-P6` residents | Wasteland Survival Farm, Green-Apocalyptic plants, survivor light/loot sheets; Scrap Kid, Toxic Shaman, and recovery families. |
| `AF-10` Wasteland School | O / `M3; Nw→AF-04; E1→AF-12` | `scripted_only Ze` memory echo; `Icenter` classroom archive; `Tsw` civic manual; no random encounters after record recovered | Wasteland School and ruined-city interiors; Bone Reaper first state, children and Dust Hunter escort after clear. |
| `AF-11` Parking/Subway Bypass | X / `S3; Ne→AF-01; E1→AF-05` | `none`; `Icenter` gate crank; `none` treasure; opens from bunker side | Abandoned Parking Lot and Post-Apocalyptic Subway; Thunder Rider mechanic route, no blocking residents. |
| `AF-12` Bone-Service Tunnel | X / `M1; Nw→AF-06; W1→AF-10` | `scripted_only Ze` single infernal patrol; `Icenter` two-sided hatch; `Tse` anchor dust | Bunker service tunnel, undead objects, Dark Dimension edge; Doom Vanguard before boss, sealed/empty afterward. |

### 23.6 Pelagic Address — 12 rooms

Unlock lead: New Philadelphia's Riverside board receives a distress chart after
Asterion and Moonpetal stabilize. Surface, island, and underwater movement use
the same grid; diving transitions are authored doors/current lifts, not free
vertical swimming that bypasses collision.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `PL-01` Sunward Beach | C / `L2; E1→PL-02; Sw→PL-11; Nw→NP-09 portal` | `scripted_only Zw` shore threat; `Icenter` tide beacon; `Tne` beach supplies; `P1-P5` visitors after clear | Beach, Cozy Spring water, Survival Island; Lifeguard Captain, Tropical Surfer, Coconut Girl. |
| `PL-02` Pirate Harbor | C / `H1; W1→PL-01; E1→PL-03; Se→PL-08; Sw→PL-11` | `zone Ze` harbor raiders first state; `Icenter` harbor ledger; `Tse` cargo; populated safe hub after truce | Pirate harbor and Pirate Age; Beach Bar Hostess, Coastal Fisherwoman, Resort Adventurer, Atlantis Recruit envoy. |
| `PL-03` Stormglass Island | C / `L3; W1→PL-02; E1→PL-04; Se→PL-09` | `zone Zw/Ze` storm wildlife; `Icenter` weather mast; `Tnw` lightning charm | Survival Island, Underwater Ocean surface details, rainforest accents; Jet Ski Champion, Stormcaller Champion. |
| `PL-04` Continental Shelf Lift | C / `M4; W1→PL-03; E1→PL-05; Se→PL-12` | `scripted_only Za` pressure tutorial; `Icenter` dive platform; `none` treasure; surface-to-depth palette/audio state | Seabed, Underwater doors/platforms/glow lights, Cruise machinery; Atlantis Recruit and Tide Priestess attendants. |
| `PL-05` Living Reef Road | C / `L3; W1→PL-04; E1→PL-06; Se→PL-10` | `zone Zw/Ze` reef formations; `Icenter` current switch; `Tne` pearl cache | Underwater Ocean coral/kelp/fish/plants/rocks; Coral Huntress, Pearl Sentinel, Abyss Dancer. |
| `PL-06` Sunken City Gate | C / `L3; W1→PL-05; E1→PL-07; Sw→PL-10; Se→PL-12` | `scripted_only Ze` royal guard test; `Icenter` tide seal; `Tsw` city records; save at `P2` | Sunken Ruins walls/doors/gates/columns/statues plus Atlantis architecture; Royal Trident Knight, Ocean Vanguard, Crystal Guardian. |
| `PL-07` Abyssal Crown Chamber | C / `L4; W1→PL-06` | `boss Zboss` corrupted sea-dragon warden; `Icenter` crown/tide engine; `Tne` unique pressure charm after victory | Underwater magic/crystals/relics and Seabed deep structures; Sea Dragon Hunter and Crystal Blade Princess, full royal delegation after victory. |
| `PL-08` Moonwake Resort | O / `L2; Nw→PL-02; E1→PL-11` | `none`; `Icenter` social/cooking event; `Tse` hospitality reward; `P1-P6` beach roster | Beach, Luxury Cruise, cafe/food props; Volleyball Champion, Island Dancer, Travel Influencer, Beach Bar Hostess. |
| `PL-09` Pirate Wreck Labyrinth | O / `M3; Nw→PL-03; E1→PL-12` | `zone Ze` wreck defenders; `Icenter` mast/rope route; `Tsw` pirate equipment | Pirate Age ship pieces, Seabed wreck debris; Tropical Surfer and Coastal Fisherwoman guides. |
| `PL-10` Coral Reliquary | O / `L2; Nw→PL-05; E1→PL-06` | `scripted_only Za` relic guardian; `Icenter` three-shell alignment; `Tne` unique tide accessory | Underwater treasure/relic/magic/crystal sheets; Tide Priestess, Abyss Dancer, Pearl Sentinel. |
| `PL-11` Public Ferry Loop | X / `S3; Ne→PL-01; E1→PL-02; W1→PL-08` | `none`; `Icenter` ferry schedule; `none` treasure; fast surface return after harbor truce | Pirate Harbor docks, Luxury Cruise tender, Beach boardwalk; Jet Ski Champion ferrymaster. |
| `PL-12` Pressure Current | X / `M1; Nw→PL-04; E1→PL-06; W1→PL-09` | `none` after activation; `Icenter` current valve; `Tse` glow crystal; accessibility route walks on platforms | Underwater platforms, glow lights, foam/current effects; no moving resident on arrival or current cells. |

### 23.7 Steamforge Address — 12 rooms

Unlock lead: Observatory salvage telemetry and Armory field-refit work identify a
city whose public infrastructure is literally running out of pressure.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `SF-01` Airship Freight Dock | C / `L2; E1→SF-02; Sw→SF-11; Nw→NP-12 portal` | `scripted_only Zw` customs automatons; `Icenter` pressure manifest; `Tnw` parts; `P1-P4` crew after clear | Steamforged airship docks/platforms/crates, Steampunk city props; Airship Captain, Sky Navigator, Young Apprentice. |
| `SF-02` Ferrum Slums | C / `H1; W1→SF-01; E1→SF-03; Se→SF-09` | `zone Ze` protection detail first state; `Icenter` neighborhood boiler; `Tse` community fund; safe after repair | Ferrum Slums 1/2, Dieselpunk Houses, Dark Steel City; Steam Duchess, Gearblade Assassin, residents. |
| `SF-03` Junkyard Parliament | C / `L3; W1→SF-02; E1→SF-04; Se→SF-08` | `zone Zw/Ze` scrap constructs; `Icenter` voting crane; `Tne` gear cache | Ferrum Junkyard, Environment Decor scrap, Factory Monster support; Iron Baron, Clockwork Engineer, Junkyard Heroes. |
| `SF-04` Boiler Bridgeworks | C / `M4; W1→SF-03; E1→SF-05; Sw→SF-11; Se→SF-12` | `zone Ze` steam vents; `Icenter` valve-routing puzzle; `Tsw` pressure gloves; repaired state opens both shortcuts | Steamforged pipe/vent/platform/bridge/gear/boiler sheets; Steam Knight and Tesla Gunner patrol. |
| `SF-05` Civic Foundry | C / `L3; W1→SF-04; E1→SF-06; Se→SF-10` | `scripted_only Za` foreman challenge; `Icenter` smelter controls; `Tne` alloy reward; save at `P2` | Steamforged furnaces, gauges, workbenches, machinery; Clockwork Engineer, Arc Reactor Mage, workers. |
| `SF-06` Arc Reactor Laboratory | C / `L2; W1→SF-05; E1→SF-07; Sw→SF-12` | `zone Ze` electrical defenses; `Icenter` load-balancing invention use; `Tsw` research notes | Steamforged lab/electrical/pipes plus Modern Industrial instruments; Arc Reactor Mage and Young Apprentice. |
| `SF-07` Baron's Pressure Court | C / `L4; W1→SF-06` | `boss Zboss` Iron Baron pressure monopoly; `Icenter` public-pressure charter; `Tne` unique regulator after victory | Steampunk grand architecture, Golden Palace metal accents, Steamforged machinery; Iron Baron first state, full civic delegation afterward. |
| `SF-08` Factory Ruins | O / `L3; Nw→SF-03; E1→SF-11` | `zone Ze` factory monsters; `Icenter` salvage lift; `Tse` rare component | Factory Ruins, Futuristic War Ruins excluded unless separately admitted; Clockwork Huntress and Tesla Gunner. |
| `SF-09` Gear Market | O / `L2; Nw→SF-02; E1→SF-10` | `none` after neighborhood repair; `Icenter` component exchange; `Tne` vendor sample; `P1-P6` traders | Steampunk market/interior props, Ferrum slum details; Steam Duchess, Gearblade Assassin, Sky Navigator. |
| `SF-10` Duchess's Design House | O / `M3; Nw→SF-05; W1→SF-09` | `scripted_only Za` noncombat design puzzle; `Icenter` blueprint table; `Tsw` cosmetic/gear design | Dieselpunk Houses, Modern Office, Steampunk interiors; Steam Duchess, Clockwork Huntress. |
| `SF-11` Condensate Tram | X / `S3; Ne→SF-01; E1→SF-04; W1→SF-08` | `none`; `Icenter` tram lever; `none` treasure; activates after bridge repair | Steamforged platforms/bridges/steam and transit details; Sky Navigator conductor. |
| `SF-12` Service Pipeway | X / `M1; Nw→SF-04; E1→SF-06` | `scripted_only Ze` one maintenance hazard; `Icenter` bypass valve; `Tse` repair kit | Steamforged pipes/cables/hatches; no resident patrol crosses narrow arrival lanes. |

### 23.8 Frontier Address — 10 rooms

Unlock lead: Trailhead expeditions and New Philadelphia's farm board receive a
rail deed from a town caught between an exploitative mine and its own elected
marshal. `7._DYNAMITE_BILL` is excluded until `east.png` is supplied.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `FT-01` Fault-Line Railhead | C / `L1; E1→FT-02; Sw→FT-09; Nw→NP-12 portal` | `scripted_only Zw` rail ambush; `Icenter` timetable; `Tnw` supplies | Wild West rail/ground, Ranch station props; Dusty Kid, Prairie Ranger. |
| `FT-02` Blackwood Main Street | C / `H1; W1→FT-01; E1→FT-03; Se→FT-07` | `none` after first standoff; `Icenter` town board; `Tse` bounty ledger; `P1-P6` townsfolk | Wild West buildings/streets, Ranch town props; Sheriff Blackwood, Rose McGraw, Iron Marshal. |
| `FT-03` Open-Sky Ranch | C / `L3; W1→FT-02; E1→FT-04; Se→FT-08` | `zone Ze` rustlers; `Icenter` herd gate; `Tne` ranch gear; peaceful after herd rescued | Ranch Stuff derivatives, Farm and scorched-desert transitions; Bison Hunter, Prairie Ranger, Dusty Kid. |
| `FT-04` Red Mesa Canyon | C / `M4; W1→FT-03; E1→FT-05; Sw→FT-09; Se→FT-10` | `zone Zw/Ze` outlaw patrol; `Icenter` switchback gate; `Tsw` canyon cache | Wild West canyon, Desert Wasteland, scorched desert; Deadshot Jake and Outlaw Queen. |
| `FT-05` Royal Vein Mine | C / `L3; W1→FT-04; E1→FT-06; Sw→FT-10` | `zone Ze` mine defenses; `Icenter` lift/ore audit; `Tne` equipment material; save at `P2` | Wild West mine sheets, Ruined Dungeon/Ferrum support only through profiles; Gold Prospector and Texas King agents. |
| `FT-06` King's Claim Office | C / `L4; W1→FT-05` | `boss Zboss` Texas King claim enforcers; `Icenter` deed press; `Tne` public rail deed after victory | Wild West civic/office, Royal Props, Ranch details; Texas King first state, Sheriff/Iron Marshal council afterward. |
| `FT-07` Rose's Saloon | O / `M3; Nw→FT-02; E1→FT-09` | `scripted_only Za` conversation/card evidence challenge; `Icenter` bar table; `Tse` charm | Wild West saloon, Modern Bar density-normalized props; Rose McGraw, Deadshot Jake, traveling guests. |
| `FT-08` Prospector's Side Cavern | O / `L2; Nw→FT-03; E1→FT-10` | `zone Ze` cave wildlife; `Icenter` ore-layer puzzle; `Tsw` rare material | Wild West mine/cave and Ranch tools; Gold Prospector and Bison Hunter. |
| `FT-09` Rail Loop | X / `S3; Ne→FT-01; E1→FT-04; W1→FT-07` | `none` after switch thrown; `Icenter` rail switch; `none` treasure | Wild West rail assets; Iron Marshal patrol stays off arrival cells. |
| `FT-10` Smuggler Switchback | X / `M1; Nw→FT-04; E1→FT-05; W1→FT-08` | `scripted_only Ze` one outlaw formation; `Icenter` two-sided barricade; `Tse` contraband cache | Canyon/mine/barricade sheets; Outlaw Queen before settlement, empty after truce. |

### 23.9 Warfront Address — 10 rooms

Unlock lead: Asterion security archives and Empyreal's lost appeals expose a
rift that keeps replaying several wars as one administrative emergency. The
story objective is evacuation and ceasefire, not conquest.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `WF-01` Memorial Staging Ground | C / `L1; E1→WF-02; Sw→WF-09; Nw→NP-15 portal` | `scripted_only Zw` confused patrol; `Icenter` casualty register; `Tnw` field supplies | WWI staging, Medieval Army Camp, restrained memorial props; Rookie Recruit, Communications Officer. |
| `WF-02` First-Line Trenches | C / `L3; W1→WF-01; E1→WF-03; Se→WF-07` | `zone Zw/Ze` trench formations; `Icenter` signal routing; `Tne` field kit; cleared lanes stay safe | World War I Trench Warfare and WW1 Trench/Bunker; Squad Leader, Heavy Gunner, Combat Medic. |
| `WF-03` Command Bunker | C / `M4; W1→WF-02; E1→WF-04; Sw→WF-09` | `scripted_only Za` bunker defense; `Icenter` communications board; `Tsw` codes; save at `P2` | WW1 bunker, Great War houses, military interior profiles; Female Squad Commander, Communications Officer, Combat Engineer. |
| `WF-04` Forest No-Man's-Land | C / `L3; W1→WF-03; E1→WF-05; Se→WF-08` | `zone Zw/Ze` patrol avoidance; `Icenter` flare sequence; `Tne` reconnaissance cache | Forest Warzone and Medieval Battlefield layers kept as distinct time strata; Recon Scout, Sniper Specialist. |
| `WF-05` Collapsed City Corridor | C / `L3; W1→WF-04; E1→WF-06; Sw→WF-10` | `zone Ze` urban defense; `Icenter` civilian route clearing; `Tsw` equipment; evacuees appear after clear | WWI/WWII City Ruins and Post-Apocalyptic War Ruins only in marked temporal seams; Urban Assault Specialist, Combat Medic. |
| `WF-06` Ceasefire Operations Hall | C / `L4; W1→WF-05` | `boss Zboss` autonomous War Ledger; `Icenter` ceasefire transmission; `Tne` unique command accessory after victory | Command bunker/ruins shell with Asterion console derivative; entire Warfront squad assembles after victory. |
| `WF-07` Normandy Echo | O / `L2; Nw→WF-02; E1→WF-09` | `zone Ze` timed evacuation, not kill quota; `Icenter` landing signal; `Tse` rescue reward | Normandy Landing pack; Squad Leader, Combat Medic, Rookie Recruit. |
| `WF-08` Silent Submarine | O / `L2; Nw→WF-04; E1→WF-10` | `scripted_only Za` pressure/power puzzle; `Icenter` ballast controls; `Tsw` navigation gear | Modern Military Submarine; Demolitions Expert, Combat Engineer, Communications Officer. |
| `WF-09` Supply Rail Cut | X / `S3; Ne→WF-01; E1→WF-03; W1→WF-07` | `none` after clearance; `Icenter` supply switch; `none` treasure | Trench logistics/rail and Normandy supply props; Heavy Gunner quartermaster route. |
| `WF-10` Temporal Rubble Tunnel | X / `M1; Nw→WF-05; W1→WF-08` | `scripted_only Ze` one instability; `Icenter` era stabilizer; `Tse` research note | WWII/Futuristic ruin seam with explicit boundary effect; no NPC patrol on narrow route. |

### 23.10 Liminal Address — 8 rooms

Unlock lead: a postgame anomaly appears in the laboratory provenance console
after every core universe stabilizes. This address is intentionally lonely; it
does not borrow an unrelated SakPix population merely to fill screens.

| ID / room | Class, blueprint, and exact ports | Encounter, interaction, treasure, and state | Supplied art and population |
| --- | --- | --- | --- |
| `LM-01` Fluorescent Reception | C / `M2; E1→LM-02; Sw→LM-08; Nw→NP-03 console` | `none`; `Icenter` visitor log; `Tnw` emergency chalk; no ordinary residents | Backrooms `Level-0-1/2/3` derivatives; distant noninteractive silhouettes only. |
| `LM-02` Yellow Office Loop | C / `L2; W1→LM-01; E1→LM-03; Se→LM-06` | `scripted_only Za` spatial reset; `Icenter` three-sign orientation puzzle; `Tne` research note | Backrooms Level 0 sheets, strict repeated-wall variation rules; no population. |
| `LM-03` Concrete Maintenance Level | C / `M4; W1→LM-02; E1→LM-04; Sw→LM-08` | `zone Ze` environmental anomalies; `Icenter` breaker bank; `Tsw` battery | Backrooms Level 1 sheets; no SakPix actor duplicates. |
| `LM-04` Poolcore Threshold | C / `L3; W1→LM-03; E1→LM-05; Se→LM-07` | `scripted_only Za` water/reflection route; `Icenter` drain controls; `Tne` echo glass | Backrooms pool-core sheets plus Poolcore pack 1-9; water is bounded floor, not free-form swimming. |
| `LM-05` Exit Archive | C / `L4; W1→LM-04` | `boss Zboss` Null Index anomaly; `Icenter` provenance ledger; `Tne` cosmetic/no-stat anomaly reward; stable exit after victory | Backrooms Level 10/abstract sheets, Level Map UI derivative; no population before or after. |
| `LM-06` Level Ten Records | O / `M3; Nw→LM-02; E1→LM-08` | `scripted_only Ze` document sequence; `Icenter` impossible index; `Tse` lore-only archive | Backrooms Level 10 sheets; recorded voices only. |
| `LM-07` Silent Pool | O / `L2; Nw→LM-04; E1→LM-08` | `none`; `Icenter` reflection observation; `Tsw` one-time Ether; accessibility perimeter walkway | Poolcore sheets; no moving entities or surprise encounter. |
| `LM-08` Service Elevator | X / `S3; Ne→LM-01; E1→LM-03; W1→LM-06; W2→LM-07` | `none` after breakers; `Icenter` floor selector; `none` treasure; reliable return loop | Backrooms maintenance/elevator derivative; transition cells remain fully clear. |

### 23.11 Exact spatial matrix for all 102 core-universe rooms

This matrix completes the spatial fields that Section 9.4 intentionally left
at size-class level. Port bindings inherit the gate label and story condition
from the corresponding Section 9.4 row. The encounter policy below is the base
policy after any named one-time encounter; `scripted_only Za` retains that
authored encounter but disables random rolls. The treasure and population
anchors are exact cells after evaluation through Section 23.2.

| Room | Blueprint / exact dimensions | Exact port-to-target binding | Encounter zone; treasure; interaction; population anchors |
| --- | --- | --- | --- |
| `HM-01` | `M1` | `Nw→FI-05; Ne→HM-02` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-02` | `L2` | `Nw→HM-01; Ne→HM-03; E1→HM-04; E2→HM-10` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HM-03` | `M3` | `Nw→HM-02` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-04` | `S1` | `Nw→HM-02; Ne→HM-05; E1→HM-12` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `HM-05` | `M1` | `Nw→HM-04; Ne→HM-11; E1→HM-14; E2→HM-16` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-06` | `L2` | `Nw→HM-14; Ne→HM-15` | `scripted_only Za`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HM-07` | `M3` | `Nw→HM-15; Ne→HM-08; E1→HM-11` | `scripted_only Za`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-08` | `M4` | `Nw→HM-07; Ne→HM-09; E1→HM-13; E2→HM-16` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-09` | `L1` | `Nw→HM-08` | `boss Zboss`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HM-10` | `M2` | `Nw→HM-02; Ne→HM-15` | `scripted_only Za`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-11` | `M3` | `Nw→HM-05; Ne→HM-07; E1→HM-12` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-12` | `L4` | `Nw→HM-04; Ne→HM-11` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HM-13` | `M1` | `Nw→HM-14; Ne→HM-08` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-14` | `M2` | `Nw→HM-05; Ne→HM-06; E1→HM-13` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HM-15` | `S3` | `Nw→HM-06; Ne→HM-07; E1→HM-10` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `HM-16` | `M4` | `Nw→HM-05; Ne→HM-08` | `none`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-01` | `L1` | `Nw→FI-06; Ne→AS-02; E1→AS-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `AS-02` | `M2` | `Nw→AS-01; Ne→AS-03; E1→AS-09` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-03` | `M3` | `Nw→AS-02; Ne→AS-12; E1→AS-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-04` | `M4` | `Nw→AS-13; Ne→AS-12` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-05` | `M1` | `Nw→AS-13; Ne→AS-06; E1→AS-10` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-06` | `L2` | `Nw→AS-05; Ne→AS-07` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `AS-07` | `M3` | `Nw→AS-06; Ne→AS-08; E1→AS-10; E2→AS-13; Se→AS-14` | `boss Zboss`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-08` | `L4` | `Nw→AS-07; Ne→AS-11` | `boss Zboss`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `AS-09` | `M1` | `Nw→AS-02` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-10` | `L2` | `Nw→AS-05; Ne→AS-07` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `AS-11` | `M3` | `Nw→AS-13; Ne→AS-08` | `boss Zboss`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-12` | `M4` | `Nw→AS-03; Ne→AS-04` | `zone Zw/Ze`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-13` | `M1` | `Nw→AS-03; Ne→AS-04; E1→AS-05; E2→AS-07; Se→AS-11` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `AS-14` | `S2` | `Nw→AS-01; Ne→AS-07` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `PV-01` | `L1` | `Nw→FI-07; Ne→PV-02; E1→PV-13` | `boss Zboss`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-02` | `M2` | `Nw→PV-01; Ne→PV-03; E1→PV-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-03` | `L3` | `Nw→PV-02; Ne→PV-04; E1→PV-07; E2→PV-10; Se→PV-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-04` | `M4` | `Nw→PV-03; Ne→PV-05; E1→PV-11` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-05` | `L1` | `Nw→PV-04; Ne→PV-06; E1→PV-09; E2→PV-13` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-06` | `M2` | `Nw→PV-05` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-07` | `L3` | `Nw→PV-03; Ne→PV-08; E1→PV-11; E2→PV-14` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-08` | `L4` | `Nw→PV-07; Ne→PV-12; E1→PV-14` | `boss Zboss`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-09` | `M1` | `Nw→PV-05; Ne→PV-13` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-10` | `L2` | `Nw→PV-03` | `zone Zw/Ze`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-11` | `M3` | `Nw→PV-04; Ne→PV-07` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-12` | `L4` | `Nw→PV-08` | `scripted_only Za`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `PV-13` | `M1` | `Nw→PV-01; Ne→PV-02; E1→PV-05; E2→PV-09` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `PV-14` | `S2` | `Nw→PV-03; Ne→PV-07; E1→PV-08` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `HE-01` | `L1` | `Nw→FI-08; Ne→HE-02; E1→HE-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-02` | `M2` | `Nw→HE-01; Ne→HE-03; E1→HE-10` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-03` | `L3` | `Nw→HE-02; Ne→HE-11; E1→HE-12; E2→HE-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-04` | `L4` | `Nw→HE-13; Ne→HE-05; E1→HE-09` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-05` | `M1` | `Nw→HE-04` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-06` | `L2` | `Nw→HE-13; Ne→HE-07` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-07` | `M3` | `Nw→HE-06; Ne→HE-08; E1→HE-10; E2→HE-12; Se→HE-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-08` | `L4` | `Nw→HE-07` | `boss Zboss`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-09` | `L1` | `Nw→HE-04; Ne→HE-13` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-10` | `M2` | `Nw→HE-02; Ne→HE-07` | `zone Zw/Ze`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-11` | `L3` | `Nw→HE-03` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `HE-12` | `M4` | `Nw→HE-03; Ne→HE-07` | `zone Zw/Ze`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-13` | `M1` | `Nw→HE-03; Ne→HE-04; E1→HE-06; E2→HE-09` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `HE-14` | `S2` | `Nw→HE-01; Ne→HE-07` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `FR-01` | `L1` | `Nw→FI-09; Ne→FR-02; E1→FR-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-02` | `M2` | `Nw→FR-01; Ne→FR-03; E1→FR-09; E2→FR-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-03` | `L3` | `Nw→FR-02; Ne→FR-04; E1→FR-09; E2→FR-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-04` | `L4` | `Nw→FR-03; Ne→FR-05; E1→FR-10` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-05` | `M1` | `Nw→FR-04; Ne→FR-06` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-06` | `L2` | `Nw→FR-05; Ne→FR-07; E1→FR-11; E2→FR-13` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-07` | `M3` | `Nw→FR-06; Ne→FR-08; E1→FR-12; E2→FR-14` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-08` | `L4` | `Nw→FR-07; Ne→FR-14` | `boss Zboss`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-09` | `L1` | `Nw→FR-02; Ne→FR-03` | `none`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-10` | `L2` | `Nw→FR-04; Ne→FR-11` | `scripted_only Za`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `FR-11` | `M3` | `Nw→FR-10; Ne→FR-06` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-12` | `M4` | `Nw→FR-07` | `zone Zw/Ze`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-13` | `M1` | `Nw→FR-01; Ne→FR-02; E1→FR-06` | `none`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `FR-14` | `S2` | `Nw→FR-03; Ne→FR-07; E1→FR-08` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `MP-01` | `L1` | `Nw→FI-10; Ne→MP-02; E1→MP-14` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-02` | `L2` | `Nw→MP-01; Ne→MP-03; E1→MP-09; E2→MP-12` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-03` | `M3` | `Nw→MP-02; Ne→MP-04; E1→MP-11; E2→MP-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-04` | `L4` | `Nw→MP-03; Ne→MP-05; E1→MP-10` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-05` | `M1` | `Nw→MP-04; Ne→MP-06` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-06` | `L2` | `Nw→MP-05; Ne→MP-07; E1→MP-13` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-07` | `M3` | `Nw→MP-06; Ne→MP-08; E1→MP-14` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-08` | `L4` | `Nw→MP-07` | `boss Zboss`; `Tsw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-09` | `M1` | `Nw→MP-02; Ne→MP-13` | `none`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-10` | `L2` | `Nw→MP-04; Ne→MP-13` | `zone Zw/Ze`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-11` | `M3` | `Nw→MP-03; Ne→MP-12` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-12` | `L4` | `Nw→MP-02; Ne→MP-11` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `MP-13` | `M1` | `Nw→MP-03; Ne→MP-06; E1→MP-09; E2→MP-10` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `MP-14` | `S2` | `Nw→MP-01; Ne→MP-07` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |
| `EM-01` | `L1` | `Nw→FI-11; Ne→EM-02; E1→EM-16` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-02` | `M2` | `Nw→EM-01; Ne→EM-03; E1→EM-10` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-03` | `L3` | `Nw→EM-02; Ne→EM-04; E1→EM-10; E2→EM-15` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-04` | `L4` | `Nw→EM-03; Ne→EM-05; E1→EM-11; E2→EM-13` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-05` | `M1` | `Nw→EM-04; Ne→EM-06` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-06` | `L2` | `Nw→EM-05; Ne→EM-07; E1→EM-15` | `zone Zw/Ze`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-07` | `L3` | `Nw→EM-06; Ne→EM-08; E1→EM-12; E2→EM-14; Se→EM-15` | `scripted_only Za`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-08` | `M4` | `Nw→EM-07; Ne→EM-09; E1→EM-12` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-09` | `L1` | `Nw→EM-08; Ne→EM-16` | `boss Zboss`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-10` | `M2` | `Nw→EM-02; Ne→EM-03` | `zone Zw/Ze`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-11` | `M3` | `Nw→EM-04; Ne→EM-15` | `zone Zw/Ze`; `Tse`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-12` | `L4` | `Nw→EM-07; Ne→EM-08` | `scripted_only Za`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-13` | `L1` | `Nw→EM-04` | `zone Zw/Ze`; `Tnw`; `Icenter` plus Section 9.4 interaction anchors; `P1-P6` by roster phase |
| `EM-14` | `M2` | `Nw→EM-07` | `none`; `Tne`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-15` | `M3` | `Nw→EM-03; Ne→EM-06; E1→EM-07; E2→EM-11` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P4` by roster phase |
| `EM-16` | `S1` | `Nw→EM-01; Ne→EM-09` | `none`; `none`; `Icenter` plus Section 9.4 interaction anchors; `P1-P2` by roster phase |

### 23.12 Complete SakPix canonical-home and story-phase registry

This registry binds every one of the 267 supplied character folders. Exactly
258 identities have all eight required rotations and receive one canonical
home. Nine incomplete identities are explicitly quarantined. `F` means present
on first visit, `F!` means a bounded hostile or antagonist field role, `S`
means present after the location stabilizes or its local introduction clears,
and `P` means postgame. Suffixes `-A`, `-B`, and so on are mutually exclusive
schedule cohorts; no more than six listed identities occupy one room in the
same cohort. `P1`-`P6` and `Icenter` resolve to the exact cells in Section
23.2. A canonical home is the save/identity owner even when a later town
visitor schedule temporarily relocates that actor.

Raw folder names are retained so the generated population registry can compare
this table directly with the source tree. Display names may remove numbering
and underscores, but source identity keys may not.

| Source collection | Exact character folder | Canonical home | Phase, anchor, route, and function |
| --- | --- | --- | --- |
| `☢️ WASTELAND LEGENDS` | `1._SCRAP_KID_FREE` | `AF-01` | `S@P1`; P1↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `2._ROAD_KING` | `AF-02` | `S@P1`; P1↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `3._JUNKER_MECHANIC` | `AF-02` | `S@P2`; P2↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `4._DUST_HUNTER` | `AF-01` | `S@P2`; P2↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `5._BONE_REAPER` | `AF-04` | `F!@P1`; bounded hostile route; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `6._DESERT_GUNNER` | `AF-02` | `S@P3`; P3↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `7._THUNDER_RIDER` | `AF-11` | `S@P1`; P1↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `8._TOXIC_SHAMAN` | `AF-03` | `S@P1`; P1↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `9._IRON_SENTINEL` | `AF-05` | `S@P1`; P1↔Icenter schedule; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `10._SAND_VIPER` | `AF-04` | `F!@P2`; bounded hostile route; Ashfall survivor, raider, or civic actor |
| `☢️ WASTELAND LEGENDS` | `11._WASTELAND_EMPEROR` | `AF-07` | `F!-A@P1`; bounded hostile route; Ashfall survivor, raider, or civic actor |
| `🌴 SUMMER BEACH GIRLS` | `1._Lifeguard_Captain` | `PL-01` | `S@P1`; P1↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `2._Tropical_Surfer` | `PL-01` | `S@P2`; P2↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `3._Volleyball_Champion` | `PL-08` | `S@P1`; P1↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `4._Island_Dancer` | `PL-08` | `S@P2`; P2↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `5._Seashell_Collector` | `PL-01` | `S@P3`; P3↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `6._Beach_Bar_Hostess` | `PL-02` | `S@P1`; P1↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `7._Jet_Ski_Champion` | `PL-11` | `S@P1`; P1↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `8._Travel_Influencer` | `PL-08` | `S@P3`; P3↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `9._Coastal_Fisherwoman` | `PL-02` | `S@P2`; P2↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `10._Resort_Adventurer` | `PL-02` | `S@P3`; P3↔Icenter schedule; Pelagic surface resident or visitor |
| `🌴 SUMMER BEACH GIRLS` | `11._FREE_CHARACTER_Coconut_Girl` | `PL-01` | `S@P4`; P4↔Icenter schedule; Pelagic surface resident or visitor |
| `Arcane Magic & Witchcraft Characters Pack` | `1._Arcane_Grand_Wizard_Male` | `NP-02` | `P@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `2._Celestial_Witch_Female` | `EM-10` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `3._Fire_Battlemage_Male` | `AF-07` | `F!-A@P2`; bounded hostile route; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `4._Shadow_Sorceress_Female` | `HM-15` | `F!@P1`; bounded hostile route; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `5._Holy_Archmage_Male` | `EM-09` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `6._Frost_Enchantress_Female` | `FR-10` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `7._Necromancer_King_Male` | `AF-07` | `F!-A@P3`; bounded hostile route; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `8._Necromancer_King_2_Male` | `HM-12` | `F!-A@P1`; bounded hostile route; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `9._Nature_Priestess_Female` | `MP-09` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `10._Arcane_Spellblade_Male` | `EM-07` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `Arcane Magic & Witchcraft Characters Pack` | `11._Crimson_Magic_Queen_Female` | `HM-11` | `S@P1`; P1↔Icenter schedule; Arcane specialist, delegate, or antagonist |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `1._Atlantis_Recruit_FREE_CHARACTER` | `PL-04` | `F@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `2._Crystal_Blade_Princess` | `PL-07` | `S@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `3._Tide_Priestess` | `PL-06` | `S@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `4._Coral_Huntress` | `PL-05` | `S@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `5._Pearl_Sentinel` | `PL-05` | `S@P2`; P2↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `6._Abyss_Dancer` | `PL-05` | `S@P3`; P3↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `7._Royal_Trident_Knight` | `PL-06` | `F@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `8._Ocean_Vanguard` | `PL-06` | `F@P2`; P2↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `9._Sea_Dragon_Hunter` | `PL-07` | `S@P2`; P2↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `10._Crystal_Guardian` | `PL-06` | `S@P2`; P2↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `ATLANTIS ROYAL GUARD, Lost Kingdom Warriors Collection` | `11._Stormcaller_Champion` | `PL-03` | `F@P1`; P1↔Icenter schedule; Pelagic guard, priest, hunter, or royal resident |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `1._WOLF_RANGER_MALE` | `PV-01` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `2._LION_PALADIN_MALE` | `PV-03` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `3._BEAR_BERSERKER_MALE` | `PV-04` | `F@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `4._FOX_SHADOWBLADE_MALE` | `MP-12` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `5._TIGER_SAMURAI_MALE` | `MP-12` | `S@P2`; P2↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `6._CAT_ASSASSIN_FEMALE` | `MP-10` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `7._DEER_DRUID_FEMALE` | `PV-05` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `8._OWL_SORCERESS_FEMALE` | `PV-06` | `S@P1`; P1↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `9._RABBIT_ELEMENTAL_MAGE_FEMALE` | `MP-09` | `S@P2`; P2↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Beastfolk Legends — Fantasy Animal Warriors Characters Pack` | `10._SNOW_LEOPARD_HUNTRESS_FEMALE` | `FR-10` | `S@P2`; P2↔Icenter schedule; Associated resident, ranger, artisan, or visitor |
| `Cozy Village NPC Collection Vol.1` | `1._Village_Kid_FREE` | `NP-13` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `2._Village_Farmer` | `NP-08` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `3._Caf_Owner` | `FI-01` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `4._Village_Baker` | `NP-13` | `F@P2`; P2↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `5._Flower_Gardener` | `NP-10` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `6._Fisherman` | `NP-09` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `7._Village_Blacksmith` | `FI-04` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `8._Traveling_Merchant` | `NP-05` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `9._Librarian` | `FI-02` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `10._Village_Elder` | `NP-04` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Cozy Village NPC Collection Vol.1` | `11._Shepherd_Girl` | `FI-03` | `F@P1`; P1↔Icenter schedule; New Philadelphia founding resident |
| `Crimson Vampire Hunters Pack` | `1._Crimson_Vampire_Hunter_Male` | `HM-01` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `2._Holy_Exorcist_Nun_Female` | `HM-11` | `S@P2`; P2↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `3._Bloodborne_Hunter_Male` | `HM-14` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `4._Vampire_Slayer_Duchess_Female` | `HM-06` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `5._Cursed_Crossbow_Hunter_Male` | `HM-10` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `6._Moonlight_Vampire_Huntress_Female` | `HM-15` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `7._Black_Coffin_Executioner_Male` | `HM-12` | `F!-A@P2`; bounded hostile route; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `8._Crimson_Witch_Hunter_Female` | `HM-13` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `9._Holy_Knight_of_Dawn_Male` | `HM-08` | `S@P1`; P1↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Crimson Vampire Hunters Pack` | `10._Raven_Blood_Priestess_Female` | `HM-11` | `S@P3`; P3↔Icenter schedule; Mansion hunter, witness, or undercroft threat |
| `Cyberpunk Neon Fantasy Characters Pack` | `1._Cyberpunk_Street_Samurai_Male` | `HE-03` | `S@P1`; P1↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `2._Neon_Hacker_Girl_Female` | `HE-12` | `S@P1`; P1↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `3._Cyber_Mercenary_Male` | `HE-09` | `F!@P1`; bounded hostile route; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `4._Neon_Blade_Assassin_Female` | `HE-10` | `F!@P1`; bounded hostile route; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `5._Techno_Guardian_Male` | `HE-07` | `F!@P1`; bounded hostile route; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `6._Neon_Valkyrie_Female` | `HE-01` | `S@P1`; P1↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `7._Cyber_Ronin_Male` | `HE-04` | `S@P1`; P1↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `8._Hologram_Mage_Female` | `HE-12` | `S@P2`; P2↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `9._Cyber_Enforcer_Male` | `HE-02` | `F!@P1`; bounded hostile route; Helios resident, resistance member, or enforcer |
| `Cyberpunk Neon Fantasy Characters Pack` | `10._Neon_Street_Racer_Female` | `HE-13` | `S@P1`; P1↔Icenter schedule; Helios resident, resistance member, or enforcer |
| `Dark Fantasy Dungeon Heroes Pack` | `1._CURSED_CRYPT_KNIGHT_MALE` | `HM-12` | `F!-A@P3`; bounded hostile route; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `2._ASHEN_TORCHBEARER_MALE` | `HM-04` | `F@P1`; P1↔Icenter schedule; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `3._BLOODRUNE_EXECUTIONER_MALE` | `HM-12` | `F!-A@P4`; bounded hostile route; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `4._SHADOW_DUNGEON_ASSASSIN_MALE` | `HM-15` | `F!@P2`; bounded hostile route; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `5._ABYSSAL_NECROMANCER_MALE` | `HM-12` | `F!-A@P5`; bounded hostile route; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `6._CRIMSON_CATHEDRAL_PRIESTESS_FEMALE` | `HM-11` | `S@P4`; P4↔Icenter schedule; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `7._NIGHTSHADE_HUNTRESS_FEMALE` | `HM-10` | `F!@P1`; bounded hostile route; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `8._FORBIDDEN_ALCHEMIST_FEMALE` | `HM-13` | `S@P2`; P2↔Icenter schedule; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `9._RELIC_VALKYRIE_OF_THE_ABYSS_FEMALE` | `HM-12` | `F@P1`; P1↔Icenter schedule; Mansion captive, explorer, or hostile field actor |
| `Dark Fantasy Dungeon Heroes Pack` | `10._MOONLESS_SPELLWEAVER_FEMALE` | `HM-06` | `S@P2`; P2↔Icenter schedule; Mansion captive, explorer, or hostile field actor |
| `Dark Gothic Fantasy Characters Pack` | `dark_corrupted_female_knight_pixel` | `HM-15` | `F!@P3`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `dark_fantasy_gothic_knight_pixel` | `HM-01` | `S@P2`; P2↔Icenter schedule; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `dark_queen_pixel_art_gothic` | `HM-06` | `F!@P1`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `masterpiece_pixel_art_gothic_armored` | `HM-12` | `F!-A@P6`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `masterpiece_pixel_art_gothic_female` | `HM-13` | `S@P3`; P3↔Icenter schedule; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `pixel_art_demonic_gothic_warrior` | `HM-12` | `F!-B@P1`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `pixel_art_gothic_assassin_girl` | `HM-10` | `F!@P2`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `pixel_art_gothic_valkyrie_dark` | `HM-06` | `F!@P2`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `pixel_art_gothic_warrior_girl` | `HM-14` | `S@P2`; P2↔Icenter schedule; Mansion apparition or stabilized gothic resident |
| `Dark Gothic Fantasy Characters Pack` | `pixel_art_gothic_witch_dark` | `HM-15` | `F!@P4`; bounded hostile route; Mansion apparition or stabilized gothic resident |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `1._Young_Dragon_Squire_FREE` | `PV-12` | `S@P1`; P1↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `2._Dragon_Emperor` | `EM-13` | `S@P1`; P1↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `3._Dragon_Paladin` | `EM-13` | `S@P2`; P2↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `4._Dragon_Berserker` | `PV-08` | `F!@P1`; bounded hostile route; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `5._Dragon_Flame_Mage` | `PV-12` | `S@P2`; P2↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `6._Dragon_Huntress` | `PV-12` | `S@P3`; P3↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `7._Dragon_Assassin` | `PV-14` | `F!@P1`; bounded hostile route; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `8._Dragon_Priestess` | `PV-11` | `S@P1`; P1↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `9._Dragon_Guardian` | `PV-08` | `S@P1`; P1↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `10._Storm_Dragon_Warden` | `EM-10` | `S@P2`; P2↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `DRAGONBORN CHAMPIONS — LEGENDARY DRAGON KINGDOM HEROES` | `11._Dragon_Queen` | `EM-13` | `S@P3`; P3↔Icenter schedule; Primeval dragon resident or Empyreal envoy |
| `Eternal Samurai & Yokai Warriors Pack` | `1._Samurai_Warlord_Male` | `MP-01` | `S@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `2._Shrine_Maiden_Warrior_Female` | `MP-03` | `S@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `3._Ronin_Blade_Master_Male` | `MP-06` | `F@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `4._Kitsune_Assassin_Female` | `MP-10` | `F!@P1`; bounded hostile route; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `5._Imperial_Shogun_Male` | `MP-07` | `S@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `6._Moonlight_Samurai_Female` | `MP-13` | `S@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `7._Oni_Hunter_Male` | `MP-12` | `S@P3`; P3↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `8._Sakura_Blade_Dancer_Female` | `MP-03` | `S@P2`; P2↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `9._Dragon_Clan_Samurai_Male` | `MP-12` | `S@P4`; P4↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `Eternal Samurai & Yokai Warriors Pack` | `10._Spirit_Yokai_Priestess_Female` | `MP-05` | `S@P1`; P1↔Icenter schedule; Moonpetal guard, artisan, witness, or court resident |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `1._DUSTY_KID_FREE` | `FT-01` | `F@P1`; P1↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `2._SHERIFF_BLACKWOOD` | `FT-02` | `S@P1`; P1↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `3._DEADSHOT_JAKE` | `FT-04` | `F!@P1`; bounded hostile route; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `4._PRAIRIE_RANGER` | `FT-03` | `S@P1`; P1↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `5._GOLD_PROSPECTOR` | `FT-08` | `S@P1`; P1↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `6._ROSE_McGRAW` | `FT-07` | `S@P1`; P1↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `7._DYNAMITE_BILL` | **QUARANTINE** | missing east.png; no room, phase, route, or runtime population ID until repaired |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `8._BISON_HUNTER` | `FT-03` | `S@P2`; P2↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `9._OUTLAW_QUEEN` | `FT-04` | `F!@P2`; bounded hostile route; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `10._IRON_MARSHAL` | `FT-02` | `S@P2`; P2↔Icenter schedule; Frontier resident, outlaw, or law officer |
| `FRONTIER LEGENDS-Wild West Heroes Collection` | `11._TEXAS_KING` | `FT-06` | `F!@P1`; bounded hostile route; Frontier resident, outlaw, or law officer |
| `Frozen Kingdom Fantasy Characters Pack` | `1._Frozen_Kingdom_Ice_Knight_Male` | `FR-01` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `2._Frozen_Valkyrie_Female` | `FR-04` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `3._Frost_Assassin_Male` | `FR-10` | `F!@P1`; bounded hostile route; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `4._Ice_Witch_Queen_Female` | `FR-08` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `5._Glacier_Paladin_Male` | `FR-06` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `6._Snow_Huntress_Female` | `FR-10` | `S@P3`; P3↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `7._Frozen_Berserker_Male` | `FR-13` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `8._Crystal_Priestess_Female` | `FR-11` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `9._Frost_Prince_Male` | `FR-12` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `Frozen Kingdom Fantasy Characters Pack` | `10._Ice_Blade_Warrior_Female` | `FR-09` | `S@P1`; P1↔Icenter schedule; Frosthold citizen, court member, or hostile collector |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `1._Nova_Sentinel` | `EM-01` | `S@P1`; P1↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `2._Inferno_Blaze` | `HE-08` | `S@P1`; P1↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `3._Thunder_Volt` | `EM-10` | `S@P3`; P3↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `4._Frost_Guardian` | `FR-12` | `S@P2`; P2↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `5._Emerald_Titan` | `EM-03` | `S@P1`; P1↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `6._Shadow_Phantom` | `EM-15` | `F!@P1`; bounded hostile route; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `7._Cyclone_Wing` | `EM-10` | `S@P4`; P4↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `8._Solar_Knight` | `EM-09` | `S@P2`; P2↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `9._Quantum_Mind` | `EM-05` | `S@P1`; P1↔Icenter schedule; Empyreal delegate or associated civic champion |
| `HEROIC LEGENDS — ULTIMATE SUPER HEROES COLLECTION` | `10._Cosmic_Ranger` | `EM-13` | `S@P4`; P4↔Icenter schedule; Empyreal delegate or associated civic champion |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `1._Village_Blacksmith` | `FI-04` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `2._Traveling_Merchant` | `NP-05` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `3._Tavern_Keeper` | `FI-01` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `4._Royal_Guard` | `NP-04` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `5._Elder_Scholar` | `FI-02` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `6._Village_Baker` | `FI-01` | `F@P3`; P3↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `7._Herbalist` | `FI-03` | `F@P2`; P2↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `8._Tavern_Waitress` | `FI-01` | `F@P4`; P4↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `9._Noble_Lady` | `NP-15` | `S@P1`; P1↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Kingdom Citizens — Fantasy Townfolk & NPC Collection` | `10._Guild_Receptionist` | `FI-02` | `F@P3`; P3↔Icenter schedule; New Philadelphia worker, merchant, scholar, or delegate |
| `Legendary Infernal Kingdom Champions` | `1._DEMON_EMPEROR` | `AF-07` | `F!-A@P4`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `2._INFERNAL_WARLORD` | `AF-07` | `F!-A@P5`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `3._SUCCUBUS_QUEEN` | `AF-09` | `F!@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `4._BLOOD_PRIEST` | `AF-06` | `F!@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `5._HELL_KNIGHT` | `AF-05` | `F!@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `6._FLAME_SORCERER` | `AF-07` | `F!-A@P6`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `7._ABYSSAL_ASSASSIN` | `AF-12` | `F!@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `8._BONE_CHAMPION` | `AF-10` | `F!@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `9._INFERNAL_DRAGON_TAMER` | `AF-07` | `F!-B@P1`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `10._DOOM_VANGUARD` | `AF-12` | `F!@P2`; bounded hostile route; Ashfall infernal faction actor |
| `Legendary Infernal Kingdom Champions` | `11._Infernal_Prince_Free_Character` | `AF-05` | `S@P2`; P2↔Icenter schedule; Ashfall infernal faction actor |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `1._LOST_BOY_FREE` | `HM-07` | `F@P1`; P1↔Icenter schedule; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `2._THE_HARVESTER` | `HM-10` | `F!@P3`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `3._CRIMSON_BRIDE` | `HM-09` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `4._PORCELAIN_DOLL` | `HM-07` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `5._IRON_BUTCHER` | `HM-16` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `6._CANDLE_WITCH` | `HM-04` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `7._ASHEN_WOODSMAN` | `HM-10` | `F!@P4`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `8._MOONSTALKER` | `HM-15` | `F!@P5`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `9._GRAVE_KEEPER` | `HM-01` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `10._NOCTURNA` | `HM-13` | `F!@P1`; bounded hostile route; Mansion nightmare apparition |
| `NIGHTMARE SLASHERS Horror Killers Collection` | `11._THE_SILENT_JUDGE` | `HM-09` | `F!@P2`; bounded hostile route; Mansion nightmare apparition |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `1._Emerald_Forest_Ranger` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `2._Ancient_Antler_Druid` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `3._Moonleaf_Assassin` | `MP-10` | `S@P2`; P2↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `4._Wildfire_Beast_Hunter` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `5._Mushroom_Alchemist` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `6._Thornblade_Knight` | `PV-04` | `S@P1`; P1↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `7._Spirit_Wolf_Shaman` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `8._Blossom_Priestess` | `MP-02` | `S@P1`; P1↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `9._Butterfly_Witch` | `PV-09` | `S@P1`; P1↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `10._Lunar_Forest_Archer` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `11._Vineblade_Dancer` | `PV-04` | `S@P2`; P2↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `12._Fairy_Queen_Guardian` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `13._Nature_Oracle` | `MP-11` | `S@P1`; P1↔Icenter schedule; Primeval or Moonpetal nature resident |
| `Premium Enchanted Forest Pixel Art Characters for Fantasy RPGs, Roguelikes & Magical Adventures` | `14._Serpent_Forest_Enchantress` | **QUARANTINE** | all eight rotation PNGs absent; no room, phase, route, or runtime population ID until repaired |
| `Psychological Horror Dungeon Characters Pack` | `1._THE_CHAINED_EXECUTIONER_MALE` | `HM-04` | `F!@P2`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `2._THE_CANDLE_PRIESTESS_FEMALE` | `HM-11` | `F!@P1`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `3._THE_BONE_SURGEON_MALE` | `HM-12` | `F!-B@P2`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `4._THE_WEEPING_NUN_FEMALE` | `HM-11` | `F!@P2`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `5._THE_DUNGEON_JAILER_MALE` | `HM-12` | `F!-B@P3`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `6._THE_SPIDER_CULTIST_FEMALE` | `HM-12` | `F!-B@P4`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `7._THE_ASHEN_KNIGHT_MALE` | `HM-14` | `F!@P1`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `8._THE_MIRROR_WITCH_FEMALE` | `HM-15` | `F!@P6`; bounded hostile route; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `9._THE_MAD_PRISONER_MALE` | `HM-12` | `F@P2`; P2↔Icenter schedule; Mansion psychological apparition or captive |
| `Psychological Horror Dungeon Characters Pack` | `10._THE_BLOOD_ORACLE_FEMALE` | `HM-06` | `F!@P3`; bounded hostile route; Mansion psychological apparition or captive |
| `RING LEGENDS — World Boxing Heroes Collection` | `BRONX_BULL` | `HE-11` | `S-A@P1`; P1↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `CHAMPION_TITAN` | `HE-11` | `S-A@P2`; P2↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `CRIMSON_HAMMER` | `HE-11` | `S-A@P3`; P3↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `EL_TORNADO` | `HE-11` | `S-A@P4`; P4↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `IRON_FIST` | `HE-11` | `S-A@P5`; P5↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `KING_JAB` | `HE-11` | `S-A@P6`; P6↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `LIGHTNING_LEE` | `HE-11` | `S-B@P1`; P1↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `PHANTOM_JAB` | `HE-11` | `S-B@P2`; P2↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `ROOKIE_ROCKY_FREE_CHARACTER` | `HE-11` | `S-B@P3`; P3↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `SILVER_WOLF` | `HE-11` | `S-B@P4`; P4↔Icenter schedule; Helios recreation-stack boxing athlete |
| `RING LEGENDS — World Boxing Heroes Collection` | `STORM_BREAKER` | `HE-11` | `S-B@P5`; P5↔Icenter schedule; Helios recreation-stack boxing athlete |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `1._Galactic_Vanguard_Male` | `AS-01` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `2._Void_Ranger_Male` | `AS-03` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `3._Quantum_Engineer_Male` | `AS-06` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `4._Starborn_Mercenary_Male` | `AS-02` | `F!@P1`; bounded hostile route; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `5._Solar_Templar_Male` | `AS-07` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `6._Nova_Valkyrie_Female` | `AS-08` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `7._Stellar_Oracle_Female` | `AS-10` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `8._Eclipse_Sniper_Female` | `AS-10` | `F@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `9._Nebula_Mechanic_Female` | `AS-11` | `S@P1`; P1↔Icenter schedule; Asterion crew, specialist, or security actor |
| `SCI-FI LEGENDS — FUTURISTIC CHARACTERS PACK` | `10._Astral_Blade_Dancer_Female` | `AS-10` | `S@P2`; P2↔Icenter schedule; Asterion crew, specialist, or security actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `1._IRON_BARON_Male` | `SF-07` | `F!@P1`; bounded hostile route; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `2._STEAM_KNIGHT_Male` | `SF-04` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `3._CLOCKWORK_ENGINEER_Male` | `SF-03` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `4._AIRSHIP_CAPTAIN_Male` | `SF-01` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `5._TESLA_GUNNER_Male` | `SF-04` | `F@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `6._STEAM_DUCHESS_Female` | `SF-10` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `7._CLOCKWORK_HUNTRESS_Female` | `SF-08` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `8._GEARBLADE_ASSASSIN` | `SF-09` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `9._ARC_REACTOR_MAGE` | `SF-06` | `S@P1`; P1↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `10._Sky_Navigator` | `SF-01` | `S@P2`; P2↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `STEAMPUNK EMPIRE — CLOCKWORK HEROES COLLECTION` | `Young_Apprentice_Engineer_Free_Character` | `SF-06` | `S@P2`; P2↔Icenter schedule; Steamforge citizen, engineer, or ruling actor |
| `Warfront Elite Squad- Modern Military Operators Collection` | `1._SQUAD_LEADER` | `WF-02` | `F@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `2._HEAVY_GUNNER` | `WF-09` | `S@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `3._RECON_SCOUT` | `WF-04` | `F@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `4._COMBAT_MEDIC` | `WF-05` | `S@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `5._DEMOLITIONS_EXPERT` | `WF-08` | `F@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `6._FEMALE_SQUAD_COMMANDER` | `WF-03` | `S@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `7._SNIPER_SPECIALIST` | `WF-04` | `F@P2`; P2↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `8._COMMUNICATIONS_OFFICER` | `WF-03` | `S@P2`; P2↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `9._COMBAT_ENGINEER` | `WF-05` | `S@P2`; P2↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `10._URBAN_ASSAULT_SPECIALIST` | `WF-05` | `F@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `Warfront Elite Squad- Modern Military Operators Collection` | `11._FREE_CHARACTER_ROOKIE_RECRUIT` | `WF-01` | `F@P1`; P1↔Icenter schedule; Warfront operator or evacuation specialist |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `1._Rookie_Striker_FREE` | `HE-11` | `S-B@P6`; P6↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `2._Golden_Captain` | `HE-11` | `S-C@P1`; P1↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `3._Speed_Winger` | `HE-11` | `S-C@P2`; P2↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `4._Master_Playmaker` | `HE-11` | `S-C@P3`; P3↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `5._Iron_Goalkeeper` | `HE-11` | `S-C@P4`; P4↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `6._Defensive_Wall` | `HE-11` | `S-C@P5`; P5↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `7._Bicycle_Kick_Champion` | `HE-11` | `S-C@P6`; P6↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `8._International_Superstar` | `HE-11` | `S-D@P1`; P1↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `9._Power_Forward` | `HE-11` | `S-D@P2`; P2↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `10._Free_Kick_Specialist` | `HE-11` | `S-D@P3`; P3↔Icenter schedule; Helios recreation-stack football athlete |
| `WORLD CHAMPIONSHIP HEROES Football Stars Collection` | `11._Championship_MVP` | `HE-11` | `S-D@P4`; P4↔Icenter schedule; Helios recreation-stack football athlete |

#### Secondary visitor and relocation schedules

Canonical home does not forbid authored travel. These are the exact additional
schedules needed to make stabilized worlds feel inhabited without cloning an
identity. A scheduled visitor is removed from the canonical-home scene for the
same time block; save data stores one active room per identity.

| Schedule | Exact identities and destination anchors | Unlock / occupancy rule |
| --- | --- | --- |
| `VIS-ASTERION-RESTORE` | Warfront `1._SQUAD_LEADER→AS-07/P1`, `3._RECON_SCOUT→AS-10/P1`, `4._COMBAT_MEDIC→AS-04/P1`, `8._COMMUNICATIONS_OFFICER→AS-08/P1`, `9._COMBAT_ENGINEER→AS-11/P1`, `11._FREE_CHARACTER_ROOKIE_RECRUIT→AS-02/P1` | `asterion_station_restored` through Warfront unlock; six-person station recovery shift, then these identities relocate to their canonical `WF-*` homes |
| `VIS-FROST-RELIEF` | Kingdom `6._Village_Baker→FR-09/P3`, `7._Herbalist→FR-09/P4`, `9._Noble_Lady→FR-12/P2` | `frosthold_scenario_complete`; relief/delegation cohort only, never during the first-visit tax patrol |
| `VIS-EMP-FERRY` | Steampunk `10._Sky_Navigator→EM-16/P1` | `empyreal_scenario_complete`; ferryman is absent from `SF-01` during this shift |
| `VIS-STEAMFORGE-EXCHANGE` | Cozy `7._Village_Blacksmith→SF-05/P3`, Kingdom `1._Village_Blacksmith→SF-05/P4`, Arcane `1._Arcane_Grand_Wizard_Male→SF-06/P3` | Steamforge foundry restored; one rotating technical exchange cohort, removed from `FI-04`/`NP-02` while away |
| `VIS-FRONTIER-TRADE` | Cozy `8._Traveling_Merchant→FT-02/P3`, `2._Village_Farmer→FT-03/P4`, Kingdom `3._Tavern_Keeper→FT-07/P2` | Frontier main-street standoff cleared; trade cohort never occupies rail, ranch-gate, or saloon evidence cells |
| `VIS-TOWN-DELEGATES` | Crimson `1._Crimson_Vampire_Hunter_Male→NP-15/P1`, SCI-FI `3._Quantum_Engineer_Male→FI-06/P2`, Beastfolk `1._WOLF_RANGER_MALE→FI-07/P2`, Cyberpunk `2._Neon_Hacker_Girl_Female→FI-08/P2`, Frozen `8._Crystal_Priestess_Female→FI-09/P2`, Samurai `2._Shrine_Maiden_Warrior_Female→FI-10/P2`, Heroic `1._Nova_Sentinel→FI-11/P2` | Each delegate unlocks only after their home world stabilizes; the resident is absent from the canonical room during the town shift |

Population caps remain deliberate even when more identities exist:

| Location | Canonical supplied identities | Required active-state composition |
| --- | ---: | --- |
| New Philadelphia and facilities | 22 | 16-24 active across districts; delegates rotate rather than stacking in Founders Square |
| Mansion | 54 | 10-18 first-visit threats and 16-24 stabilized hunters/residents, spread across cohorts |
| Asterion | 10 plus Astronaut | 10-12 during derelict first visit; 16-20 after `VIS-ASTERION-RESTORE` |
| Primeval | 15 plus Caveman | 16-22 across borough, trails, nursery, and dragon areas |
| Helios | 33 plus Neon Viper | 18-24 active; Ring/Football cohorts make `HE-11` rotate instead of holding 22 athletes at once |
| Frosthold | 13 plus Frost Lich | 10-14 under hostile winter; 16-20 after relief visitors arrive |
| Moonpetal | 18 plus Kitsune Empress | 16-22 across court, market, gardens, and palace state |
| Empyreal | 15 plus Archangel | 16-20, including the postgame ferry shift |
| Ashfall / Pelagic / Steamforge | 24 / 22 / 11 | 16-22 / 16-22 / 11-14; Steamforge uses workers and exchange visitors rather than crowd filler |
| Frontier / Warfront / Liminal | 10 / 11 / 0 | 10-13 / 8-11 / 0; sparse Frontier/Warfront routes are intentional and Liminal remains uninhabited |

### 23.13 Sheet-level admission and room-binding rules

The disposition register in Section 9.3 is source coverage, not blanket runtime
admission. Every image beneath a `Core-P`, `Core-S`, or implemented `Annex`
pack receives exactly one generated sheet state:

- `USED(room_ids, profile_ids)`: directly cropped or tiled by named rooms.
- `DERIVATIVE_SOURCE(room_ids, derivative_ids)`: source for normalized,
  layered, masked, or animated runtime files.
- `PREVIEW_EXCLUDE`: title card, demo layout, catalog page, legend, or sample.
- `DUPLICATE_EXCLUDE(canonical_checksum)`: identical/near-identical alternate.
- `UNUSED_RESERVE(reason)`: valid art not used by the current 192 locations.
- `REJECTED(reason)`: technical, licensing, perspective, scale, or quality
  failure.

No file receives `admitted` or enters the runtime catalog without a nonempty
`room_ids` binding. Therefore every admitted sheet is traceable to a precise
location, while attractive unused art remains available without being copied
into release data.

#### Required first-pass sheet bindings for newly specified locations

| Location group | Required source sheets | Exact binding |
| --- | --- | --- |
| New Philadelphia laboratory | `Modern Laboratory Assets/1.png`-`7.png` and `Auto-tile-A4-walls-2.png`/`-3.png` | `NP-01` main floor/doors/machinery, `NP-02` invention stations/storage, `NP-03` walls/power/records; embedded catalog headings are excluded |
| New Philadelphia old town | `Medieval village town/1. Cobblestone`, `4. House wall`-`9. Wells`, `12. Street Props`-`20. Decorative village details` | `NP-04` square/signs, `NP-05` market/build lots, `NP-06` workshop props, `NP-13` houses/bakery; `Free demo!.png` is `PREVIEW_EXCLUDE` |
| New Philadelphia farm/spring | All 20 named `Cozy farming village` sheets and all 20 named `Cozy Spring Asset Pack` sheets | Soil/crops/barns/tools/animals/orchards to `NP-08`; water/bridges/flowers/gardens/lights to `NP-08`-`NP-10` and `NP-13`-`NP-14`; furniture enters interiors only through profiles |
| New Philadelphia modern districts | `Modern World Overworld/1.png`-`7.png` plus the specific Modern Airport, Construction, Gas Station, Interior, Office, Pharmacy, Restaurant, Subway, and Supermarket sheets named in Section 9.3 | Base roads/shoreline to `NP-04` and `NP-06`-`NP-15`; each specialist interior/prop pack is limited to the room named in Sections 23.3-23.4 |
| Ashfall | `Wasteland survivor kit/1. Cracked contrete` through `20. Special Hazard Tiles`, all 13 `Green-Apocalyptic Ruins/green` images, and the named bunker, nuclear, supermarket, farm, subway, school, parking, Ashlands, and infernal sources | Ground/gate `AF-01`; settlement `AF-02`/`AF-09`; overgrowth `AF-03`; toxicity `AF-04`; bunker `AF-05`-`AF-07`; supermarket `AF-08`; school `AF-10`; shortcuts `AF-11`/`AF-12` |
| Pelagic | `Underwater Ocean Depths/1. Ocean floor` through `20. Special magic tiles`, `Underwater World & Sunken Ruins/1.png`-`8.png`, admitted Seabed images, Beach, Pirate Harbor, Survival Island, and Cruise sheets | Surface `PL-01`-`PL-03`/`PL-08`/`PL-11`; descent `PL-04`; reef `PL-05`; city/royal rooms `PL-06`/`PL-07`/`PL-10`; wreck `PL-09`; current `PL-12` |
| Steamforge | `Steamforged industrial/1. Floor tiles` through `20. Airchip dock props`, `Steampunk Pixel Art/1.png`-`11.png`, Ferrum Junkyard/Slums, Dieselpunk Houses, Factory Ruins, and Dark Steel City | Dock `SF-01`; slums `SF-02`; junkyard `SF-03`; bridges/boilers `SF-04`; foundry/lab `SF-05`/`SF-06`; court `SF-07`; optional districts `SF-08`-`SF-10`; transit `SF-11`/`SF-12` |
| Frontier | Admitted `Wild West/B-1.png`-`B-13.png`, Ranch Stuff derivatives, Farm, scorched desert, and Desert Wasteland sheets | Rail/town `FT-01`/`FT-02`/`FT-09`; ranch `FT-03`; canyon `FT-04`/`FT-10`; mine `FT-05`/`FT-08`; claim office `FT-06`; saloon `FT-07`. The two `B-10/B-11` JPG copies require checksum comparison |
| Warfront | `World War I Trench Warfare/ww1/1.png`-`15.png` plus WW1 Trench/Bunker, WW1/WWII Ruins, Forest Warzone, Normandy, Great War Houses, and Submarine | Staging/trenches/bunker `WF-01`-`WF-03`; forest `WF-04`; city/command `WF-05`/`WF-06`; Normandy `WF-07`; submarine `WF-08`; logistics/temporal seams `WF-09`/`WF-10` |
| Liminal | `Backrooms/Level-0-1.png`-`Level-0-3.png`, `Level-1-1.png`/`level-1-2.png`, `Level-10-1.png`-`Level-10-3.png`, `pool core-1.png`/`-2.png`, and `Backrooms Poolcore/1.png`-`9.png` | Reception/office `LM-01`/`LM-02`; maintenance `LM-03`/`LM-08`; pool areas `LM-04`/`LM-07`; archive/records `LM-05`/`LM-06`; ambiguous `5.png` stays reserve until the contact sheet identifies it |

### 23.14 Required implementation records

The plan is now spatially complete, but implementation remains data-first. Each
of the 192 locations must produce these tracked records:

1. `<room_id>.room.json` or equivalent validated Godot resource containing the
   Section 9.4/23 semantic contract, blueprint, resolved dimensions, port/gate
   bindings, state variants, encounter policy, and roster references.
2. `<room_id>.layout.json` containing the exact terrain cell IDs, architecture
   placements, prop profile IDs, interaction cells, treasure cell, population
   anchors, foreground ownership, and collision-mask references.
3. `<room_id>.nav.json` containing walkable cells, blocked cells, arrival-safe
   cells, NPC route cells, and connected-component/shortest-path evidence.
4. One authored `.tscn` scene whose generated audit matches those three records;
   the scene is not allowed to invent untracked links or raw asset paths.
5. First-visit and stabilized native-scale captures. Boss, restoration,
   postgame, weather, construction, or puzzle-state variants add captures rather
   than replacing the two baseline images.

The layout file is the tile-by-tile authority. Section 23.2 supplies exact base
dimensions, ports, standard anchors, and zones; Sections 9.4 and 23.3-23.10
supply each room's unique landmark, obstacle, puzzle, encounter, treasure,
population, and state-change intent. A room is not implemented until the
tile-by-tile record and collision/navigation audits exist.

### 23.15 Acceptance criteria for complete location coverage

- [ ] Exactly 192 unique location IDs exist: 102 core-universe, 15 New
  Philadelphia, 11 facility interior, and 64 optional-address IDs.
- [ ] Core-universe class totals remain 58 critical, 29 optional, and 15
  connective; annex totals remain 38 critical, 15 optional, and 11 connective.
- [ ] Every room selects one valid blueprint, resolves to the exact cell/pixel
  dimensions in Section 23.2, binds no port twice, and leaves every unused port
  visibly/collision-solid.
- [ ] Every non-virtual graph edge is reciprocal under each relevant story
  fixture. `LOT` edges resolve to the saved construction lot, and all external
  portal pairs return to their named safe anchors.
- [ ] Every critical path is reachable in its intended state; optional-address
  flags are absent from all core-quest prerequisites and ending conditions.
- [ ] Every arrival, save, boss-return, and migrated-save cell belongs to
  `Zsafe`, has at least three legal follower cells, and cannot overlap collision,
  an NPC reservation, treasure, or encounter trigger.
- [ ] Navigation reports show all required ports and interactions in one
  connected component, plus the required second landmark route unless a room
  explicitly documents a choke/puzzle exception.
- [ ] All eleven facilities pass an 11x11 placement matrix: 121 build
  combinations enter the correct stable interior, return to the correct lot,
  retain jobs/portal state, and survive save/reload and sandbox relocation.
- [ ] The population registry contains exactly 267 source identities: 258
  unique complete identities with one canonical home and 9 quarantined
  identities with no runtime path. Every configured directional path exists and
  matches the source checksum.
- [ ] No room/cohort schedules more than six SakPix residents on its `P1-P6`
  anchors; no moving route enters a bound port, `Zsafe`, puzzle, treasure, or
  facility-door cell.
- [ ] Every admitted image has a room/profile binding and sheet state from
  Section 23.13. Zero raw source roots, title cards, headings, demos, duplicate
  wrappers, PSDs, or unrelated atlas neighbors appear at runtime.
- [ ] At least 384 baseline native-scale captures exist—first visit and
  stabilized for every location—plus every declared extra state. Capture names
  contain room ID, state, resolution, input mode, and tested commit SHA.
- [ ] Streaming holds only the active room, approved vista neighbors, and
  scheduled residents. A 192-location campaign must not instantiate every room,
  encounter controller, or population schedule simultaneously.
- [ ] Keyboard/mouse and controller traversals cover every port, interaction,
  treasure, facility, puzzle, boss return, shortcut, and recall path without an
  invisible blocker or unreachable anchor.

### 23.16 Mandatory pre-expansion architecture refactor gate

Do not begin bulk production of the 192 locations against the current campaign
world implementation. The room count, eleven movable facilities, and 267-source
population cannot be added safely by extending the existing hardcoded geometry
and procedural-rendering branches. Complete the refactor in this section first,
while preserving current campaign behavior and save compatibility.

The following static-audit snapshot establishes the starting risk. Counts are
diagnostic evidence, not arbitrary pass/fail limits; the exit criteria below are
based on responsibility and dependency direction.

| File | Audit snapshot | Expansion risk | Required disposition |
| --- | ---: | --- | --- |
| `game/ben_rpg/core/campaign_state.gd` | 4,041 lines; 200 functions; 40 constants | Immutable content definitions, mutable runtime state, save/load, party, inventory, equipment, quests, facilities, residents, progression, and economy still share one autoload surface | Hard blocker: extract validated content catalogs and bounded runtime services while retaining a compatibility facade |
| `game/ben_rpg/world/campaign_bootstrap.gd` | 2,627 lines; 111 functions; 210 constants; 159 direct `CampaignState` references | Owns startup, legacy universe coordinates, camera classification, collision/navigation, facilities, transitions, recruits, interactions, bosses, gates, sandbox hooks, and ending flow | Hard blocker: reduce to lifecycle orchestration and delegate all room-owned behavior |
| `game/ben_rpg/world/campaign_map_visual.gd` | 840 lines; 46 functions; 33 constants | One procedural renderer still owns laboratory, town, Mansion, Asterion, Primeval, Helios, Frosthold, Moonpetal, and legacy room composition | Hard blocker: freeze as a legacy migration adapter and replace it with authored room scenes |
| `game/ben_rpg/world/town_resident_manager.gd` | 364 lines; 18 functions; hardcoded `PROFILES` table | Four embedded identities cannot scale to the locked 267-source canonical-home/story-phase registry | Blocker before population production: make identity, schedule, phase, route, and occupancy data-driven |
| `game/ben_rpg/world/town_build_controller.gd` | 634 lines; 18 functions; 87 direct `CampaignState` references | Facility placement, input, encounter pressure, story objectives, and HUD presentation are coupled; `_update_hud()` is a large chapter-specific decision chain | Blocker before New Philadelphia and the 11-lot matrix: separate placement/domain logic from presentation and story guidance |
| `game/ben_rpg/ui/campaign_menu.gd` | 1,873 lines; 112 functions; 176 direct `CampaignState` references | Equipment, skills, inventory, bestiary, telemetry, settings, roster, quests, facilities, jobs, inventions, services, recall, and postgame presentation share one controller | Refactor before significant expansion-menu work; it does not block the first room-platform slice |
| `game/ben_rpg/world/sandbox_town_editor.gd` | 889 lines; 45 functions | Selection, placement, persistence, catalog UI, resident relocation, and rendering are concentrated in one editor controller | Refactor before district/sandbox expansion; it does not block the first room-platform slice |
| `game/ben_rpg/combat/campaign_battle.gd` and `campaign_combat_database.gd` | 1,117/929 lines | Battle presentation/orchestration and a large code-authored encounter catalog will become costly when optional addresses add encounters | Defer until encounter/bestiary production begins; current room streaming must preserve their existing contract |
| `game/ben_rpg/core/content_validator.gd` | 344 lines; 17 validator functions | Adding every new room, population, asset, facility, and graph rule directly would create another monolith | Keep as the validation facade; add focused validator modules behind it |

#### 23.16.1 Characterization and safety net before extraction

The audit found existing smoke coverage for `CampaignState` and the campaign
menu, but no test file directly names `campaign_bootstrap.gd`,
`campaign_map_visual.gd`, `town_resident_manager.gd`, or
`town_build_controller.gd`. Main-scene tests may exercise portions indirectly;
that is not sufficient evidence for responsibility-moving refactors. Add these
black-box fixtures before changing ownership:

- [ ] A legacy-room fixture records the current area ID, camera bounds/zoom,
  walkable component, interaction cells, boss gate, treasure, save point, and
  every bidirectional arrival/return pair for each existing room.
- [ ] A transition fixture proves that every current forward link returns to its
  declared source-safe cell under locked and unlocked story states.
- [ ] A navigation fixture compares visible floor, blocked scenery, dynamic
  gate overlays, facility footprints, and follower-safe arrival cells.
- [ ] An eleven-lot facility fixture records construction, collision, service or
  portal installation, stable interior entry, exact-lot return, relocation, and
  save/reload behavior.
- [ ] A population fixture records identity, source profile, story-phase
  presence, route reservations, dialogue, relocation, and persistence for the
  existing residents before the data source changes.
- [ ] A `CampaignState` contract fixture records the public calls and signals
  used by the bootstrap, menu, battle, facilities, quests, residents, and tests.
  Internal extraction may not require all callers to change in one patch.
- [ ] A migrated-save fixture covers the current save version, every existing
  universe gate, construction state, resident state, inventory/equipment,
  active quest, party/formation, ending, recall, and postgame state.
- [ ] The pre-refactor capture and all-smoke baseline is retained so visual,
  collision, input, or state regressions can be compared at each extraction.

#### 23.16.2 `CampaignState` content and runtime boundaries

Keep `CampaignState` as a temporary compatibility facade, but stop adding large
definition tables or unrelated domain operations to it. Extraction order:

1. Move `UNIVERSE_DEFINITIONS`, town overlays, universe save points, universe
   treasure caches, equipment/service/armory catalogs, facility definitions,
   inventions, expedition-tool contracts, facility upgrades, skill trees, and
   quest definitions into typed, validated catalogs/resources with stable IDs.
2. Preserve the current external query/mutation methods while redirecting them
   to the extracted catalogs. Existing saves must continue to serialize stable
   IDs rather than resource paths or display names.
3. Continue the existing `save_repository.gd`, `save_migrator.gd`,
   `quest_director.gd`, and `economy_ledger.gd` direction. Add bounded services
   only where a coherent mutable domain can be characterized independently:
   party/roster, inventory/equipment, facilities/jobs, residents/population,
   and campaign progression.
4. Do not split by line count alone. A service must own one state invariant,
   expose a small contract, emit domain-level changes, and remain serializable
   through the central save snapshot/migrator.
5. Add catalog cross-reference validation for every quest prerequisite/reward,
   facility/job/upgrade, invention cost, equipment/stock item, universe/room,
   treasure, encounter, character, and story flag before deleting the legacy
   constant table.

`CampaignState` passes this gate when no room geometry, raw asset path, room
population schedule, or large immutable content table must be added to it to
implement a new location, and the compatibility suite proves unchanged public
behavior and save/reload results.

#### 23.16.3 Room platform extraction from `campaign_bootstrap.gd`

`campaign_bootstrap.gd` must become the composition root: start/continue/sandbox
lifecycle, service construction, high-level signal wiring, campaign-ending
handoff, and no per-room implementation. Introduce these bounded components (the
exact filenames may change, but the responsibilities may not be recombined into
another monolith):

- `campaign_room_registry.gd`: resolves the stable room ID to validated room,
  layout, navigation, scene, state-variant, population, ambience, and capture
  records. It contains no live scene ownership.
- `campaign_room_streamer.gd`: owns only the active room, explicitly approved
  vista neighbors, and their scheduled residents; unloads the previous room and
  never instantiates the complete campaign graph.
- `campaign_transition_router.gd`: resolves bound ports, gate predicates,
  reciprocal destinations, safe arrivals, facility-lot portals, recall, and
  return context. Room scenes do not invent destination coordinates.
- `campaign_camera_controller.gd`: consumes manifest camera bounds, zoom policy,
  presentation profile, and active-room signal. It contains no universe-name
  `if/elif` chain or assumed `8x8` legacy offsets.
- `campaign_navigation_builder.gd`: consumes the room navigation record,
  collision mask, dynamic state overlays, gate changes, and facility footprints;
  it does not hand-author every universe inside one `_blocked_cells()` method.
- Room-owned feature nodes/installers: interactions, treasures, save points,
  encounter zones, bosses, gates, foreground ownership, weather, and resident
  anchors are instantiated from the active scene/manifest. Do not retain
  `_spawn_<world>_*`, `_create_<world>_transitions`, or
  `_update_<world>_gate` branches in the composition root.
- A narrow legacy adapter may translate the current five-room prototypes while
  rooms migrate, but new room IDs must use the manifest platform directly.

The bootstrap passes this gate when adding a room requires a scene plus validated
records—not new origin/size constants, camera branches, navigation loops,
transition constructors, interaction spawners, boss functions, or gate functions
in `campaign_bootstrap.gd`.

#### 23.16.4 Renderer retirement and authored-room ownership

Freeze `campaign_map_visual.gd`: bug fixes needed to preserve the legacy baseline
are allowed, but no new universe, room, prop family, draw branch, or expansion
asset is added there. Each migrated room scene owns these explicit layers:

1. ground/terrain;
2. architecture and below-actor props;
3. navigation/collision authority generated from the audited layout record;
4. interactions, treasures, encounters, saves, gates, and population anchors;
5. actors/residents;
6. above-actor foreground and weather/lighting overlays.

`campaign_primeval_ground.gd` is a useful small extraction experiment, but its
hardcoded five-room dictionary and procedural `_draw_room()` remain a legacy
adapter. Do not clone that pattern for the other universes or expand it into the
fourteen-room Primeval implementation. Migrate its approved profiles into the
same authored-scene/manifest path as every other room.

A migrated room may not be rendered simultaneously by its authored scene and
`campaign_map_visual.gd`. Remove the legacy call/path for that room after visual,
collision, transition, interaction, state, input, save/reload, and capture parity
passes. Delete the legacy renderer only after its last room has migrated.

#### 23.16.5 Population and New Philadelphia controller boundaries

Before activating the associated SakPix populations:

- Replace the hardcoded `town_resident_manager.gd` `PROFILES` table with the
  generated 267-source registry: 258 complete identities and nine quarantined
  identities with no runtime binding.
- Separate canonical identity/profile lookup, room/story-phase scheduling,
  route/anchor occupancy, runtime actor spawning, persistence, and dialogue.
  One source identity has one canonical runtime ID and home; phase changes move
  that identity rather than manufacturing unrelated copies.
- The scheduler consumes `population_ids[]` and the room's `P1-P6` anchors,
  reserves routes against ports/`Zsafe`/interaction/treasure/encounter cells,
  and loads only the active cohort. The spawner consumes the scheduled result
  and eight-direction profile; it does not choose story placement itself.
- Split `town_build_controller.gd` into facility lot/placement input and domain
  commands, an objective/story-guidance presenter, and an encounter-pressure
  presenter. The 11-lot model and stable facility interior router remain data,
  not an enlarged `_update_hud()` branch.
- Preserve the existing public build commands during the split so founding
  quests and current tests remain functional until the new `NP`/`FI` records
  replace their legacy callers deliberately.

#### 23.16.6 Refactors that may be deferred

Deferral is intentional sequencing, not permission to enlarge the files without
limit:

- `campaign_menu.gd` does not block the room-platform vertical slice. Before
  adding expansion-specific menu/service surfaces, split equipment, skills,
  inventory, bestiary, roster, quests, facilities/jobs/inventions, services,
  settings/telemetry, recall, and postgame into page presenters/controllers
  behind one menu shell.
- `sandbox_town_editor.gd` does not block the first authored room. Refactor its
  selection/placement, persistence, catalog presentation, resident relocation,
  and rendering before district editing or the complete 11-lot sandbox matrix.
- `campaign_battle.gd` and `campaign_combat_database.gd` retain their existing
  encounter contract during room-platform work. Before optional-address
  encounter production, separate battle flow/presentation and move encounter
  definitions into validated content records referenced by stable IDs.
- `content_validator.gd` remains the single validation entry point but delegates
  room graph/layout/navigation, asset/profile/provenance, population, facility,
  save, encounter, and catalog checks to focused modules. It may aggregate
  errors; it may not become the implementation site for every rule.

#### 23.16.7 Refactor acceptance and change isolation

- [ ] All characterization fixtures and the existing all-smoke suite pass before
  and after each ownership move.
- [ ] Current save files load without lost or duplicated state; save migration
  is explicit if the serialized schema changes.
- [ ] Existing founding, Mansion 4:44, universe gates, construction, residents,
  battle returns, ending, recall, and postgame behavior remain equivalent until
  their expanded manifests intentionally supersede them.
- [ ] `campaign_bootstrap.gd` contains no new per-universe geometry or behavior
  branch, and a manifest-only test room can be loaded without editing it.
- [ ] `campaign_map_visual.gd` receives no new location implementation; the
  manifest-only test room is fully visible and playable without it.
- [ ] `CampaignState` receives no new large content table, room geometry,
  population schedule, or raw asset path; stable catalog IDs round-trip through
  save/reload.
- [ ] A manifest-only test room proves streaming unload, camera bounds,
  navigation, reciprocal transitions, safe arrivals, feature installation,
  population cohort load/unload, and controller traversal.
- [ ] Refactor commits/changes remain scoped. Do not mix renderer experiments,
  plan edits, unrelated asset admission, gameplay rebalance, or bulk room
  production into the ownership-migration change being reviewed.

### 23.17 Implementation sequence

1. Freeze and record the current behavioral/capture baseline; add the Section
   23.16.1 characterization fixtures before moving responsibilities.
2. Add the validated room/layout/navigation/population schemas and their
   delegated cross-file validators.
3. Extract the Section 23.16.2 content catalogs behind the existing
   `CampaignState` API and pass save/contract parity.
4. Implement the room registry, streamer, transition router, camera controller,
   navigation builder, and room-owned feature contract from Section 23.16.3.
   Prove them with one manifest-only test room; do not start bulk room output.
5. Connect `FI-05` to one complete authored Mansion room as the architecture
   proof. Retire that room's procedural rendering and bootstrap branches only
   after visual, collision, transition, interaction, input, save/reload, and
   capture parity passes.
6. Generate the complete Tilesets sheet-state inventory and 267-identity SakPix
   registry; fail on the nine quarantined identities if any runtime reference
   appears. Implement the population scheduler/occupancy/spawner boundaries.
7. Split `town_build_controller.gd` and replace the resident profile table, then
   implement `NP-01`-`NP-15`, the 11-lot data model, and `FI-01`-`FI-04` before
   changing any existing founding quest.
8. Implement the remaining `HM-01`-`HM-16` graph as the full M2 vertical slice,
   including the old 4:44 sequence and save migration. Every converted room
   removes its matching legacy renderer/bootstrap ownership after acceptance.
9. Implement `FI-06`-`FI-11` and their associated core worlds in story order,
   one accepted universe at a time. Populate a world only after its
   collision/navigation and safe-anchor audits pass; then activate the exact
   roster rows and test every cohort transition.
10. Implement optional addresses independently in this order: Ashfall, Pelagic,
    Steamforge, Frontier, Warfront, Liminal. Before this step, complete the
    deferred battle/database refactor required by Section 23.16.6. Each address
    requires its own asset admission, graph fixtures, balance pass, and reviewer
    acceptance.
11. Complete the deferred campaign-menu and sandbox-editor decompositions before
    adding their expansion-specific surfaces or claiming the full district and
    11-lot sandbox workflows.
12. Run the full 192-location graph, 121-placement facility matrix,
    267-identity population audit, capture matrix, save migration, performance,
    input, and clean-export gates before any release-candidate claim.

### 23.18 Implementation status (2026-07-23)

- The shared manifest room runtime, navigation, streaming, reciprocal-transition,
  camera, feature-installation, and population-cohort platform is in place.
- Haunted Mansion `HM-01` through `HM-16`, Asterion `AS-01` through `AS-14`,
  Primeval `PV-01` through `PV-14`, Helios `HE-01` through `HE-14`, Frosthold
  `FR-01` through `FR-14`, Moonpetal `MP-01` through `MP-14`, and Empyreal
  `EM-01` through `EM-16` have authored room-scene contracts.
- Facility portals resolve from the room registry, while the active room runtime
  owns all internal reciprocal and state-gated ports. Bootstrap no longer
  constructs a complete global universe transition graph. Focused Asterion and
  Primeval scenario checks now assert these active-room ports and passed at
  commit `3b4a2274`.
- Scene-owned feature installation covers authored interactions, save points,
  treasure caches, boss contracts, and population cohorts; remaining legacy
  global feature nodes require a separate compatibility-fixture migration. The
  installer now shares its runtime save-point registration path (`62209428`).
- Focused smoke checks are run at room-slice boundaries and commits are pushed
  to the alignment branch. The Section 23.16.7 and release-gate checklists
  remain incomplete; this status must not be treated as a release claim.
- Later-universe layout, scenario, treasure, and Bulkhead Warden fixtures now
  resolve room-owned ports and interactions through the active streamer at
  commit `9703b526`. The seven legacy encounter controllers now live behind
  `CampaignEncounterRuntime`; their coordinate regions remain a compatibility
  adapter until individual rooms receive authored zones.
  Global recruit compatibility nodes remain separately owned migration work.
- Manifest navigation validation now checks all 102 room records for safe
  arrivals, follower space, connected required anchors, and declared
  navigation/collision IDs at commit `f55b0fcd`. `HM-01` through `HM-04` have
  explicit authored collision/useful-cell layouts; all other generated
  interiors remain a baseline contract, not an authored collision audit.
