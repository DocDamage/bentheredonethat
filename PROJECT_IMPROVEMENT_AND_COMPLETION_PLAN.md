# Franklin's Multiversal Township
## Comprehensive Improvement and Completion Plan

**Plan version:** 1.0  
**Date:** July 21, 2026  
**Godot project:** `game/`  
**Engine:** Godot 4.7.1  
**Current save schema:** version 18  
**Status:** planning document; no implementation work is authorized or implied by this file

---

## Quick navigation

- [Purpose, constraints, baseline, and executive decisions](#1-purpose-and-authority)
- [Safety and incremental architecture](#6-safety-source-control-and-baseline-work)
- [Sprite, atlas, scale, and rendering plan](#8-visual-asset-pipeline)
- [Town, laboratory, buildings, and scenery](#11-laboratory-town-buildings-and-overworld-scenery)
- [Universe-wide design standard](#12-universe-design-standard)
- [Haunted Mansion](#13-haunted-mansion)
- [Asterion Station](#14-asterion-station)
- [Primeval Expanse](#15-primeval-expanse)
- [Helios Arcology](#16-helios-arcology)
- [Frosthold Kingdom](#17-frosthold-kingdom)
- [Moonpetal Court](#18-moonpetal-court)
- [Empyreal Court](#19-empyreal-court)
- [Combat, encounters, progression, and economy](#20-combat-redesign)
- [Facilities, inventions, quests, saves, and sandbox](#24-facilities-and-jobs)
- [Parallax supply brief](#30-parallax-and-environmental-motion-asset-brief)
- [Verification, roadmap, risks, and definition of done](#32-verification-matrix)

## Audit conclusion

The supplied art is sufficient to establish seven distinctive worlds, but the current runtime pipeline prevents it from looking cohesive. The highest-return sequence is:

1. Protect saves and establish source control.
2. Lock one integer pixel canvas.
3. Reuse the existing asset catalog to repair crops, density, pivots, and animation metadata.
4. Introduce real ground, Y-sort, upper-occluder, lighting, weather, and parallax layers.
5. Enlarge rooms and migrate universes into independent authored scenes.
6. Prove the architecture and the deeper mechanics in Town, Lab, and Mansion.
7. Rebuild the other universes in pairs.
8. Finish story, ending, optional content, accessibility, balance, export, and release QA.

Adding more props before steps 2–5 would increase collision and clutter without solving the underlying visual problem.

---

## 1. Purpose and authority

This document converts the July 21 full-project audit into an implementation-ready plan for improving and finishing Franklin's Multiversal Township. It expands the visual, sprite, level, mechanical, architectural, testing, production, and release recommendations into ordered work with dependencies and measurable exit criteria.

This plan supersedes only the **Recommended next work** ordering in `HANDOFF.md`. It does not supersede the game's non-negotiable design decisions, existing asset-license obligations, or the requirement that newly supplied recruits remain user-approved.

This was produced from a read-only review of:

- The current Godot source and project configuration.
- The root asset pipeline and catalogs.
- All seven universe implementations.
- Town, laboratory, buildings, facilities, battle presentation, and sandbox code.
- The 46 existing smoke-test scenes.
- The 340 existing validation images among roughly 800 validation files.
- Supplied sprite sheets and the crop regions used by runtime code.

It was not produced from a newly completed human end-to-end playthrough. A recorded fresh-save playthrough remains the first production milestone.

---

## 2. Design constraints that remain fixed

The following requirements must survive every refactor:

- Combat remains a side-view, Final Fantasy VI-inspired, speed-based ATB system.
- The regular combat party is Ben plus up to four hires.
- The velociraptor remains autonomous, small-dog-sized, present from the beginning, separate from the five regular party slots, and irrelevant to the regular-party defeat condition.
- Recruits have fixed specialties, can train adjacent skills, and may either adventure or staff facilities.
- Facility jobs continue in real/offline time, but no required campaign step may force the player to wait in real time.
- The Haunted Mansion remains the mandatory first universe.
- Later anchor choice must become meaningful while respecting discovery and progression requirements.
- The town-facing side of every anchor remains an ordinary usable facility.
- Town buildings remain freely relocatable without story punishment.
- Original asset packs remain separated and traceable. Full sprite sheets never become placeable editor objects.
- Keyboard, mouse click-to-move, D-pad, analog stick, and modern controllers remain supported.
- Sandbox editing remains separate from campaign progression and does not cover the playable map with permanent UI.
- NPCs retain purposeful roles, schedules, valid routes, reservations, collision avoidance, and contextual dialogue.
- The game remains a mostly linear conventional JRPG, not a point-and-click adventure.
- The definitive recruitable cast must not be invented ahead of user-supplied assets.
- The target remains approximately 20 meaningful hours, expandable toward a 36-hour completionist ceiling. Duration must be demonstrated, not claimed.

---

## 3. Current baseline

### 3.1 What already exists

- Opening, laboratory, town founding, four founding facilities, Fighter recruitment, seven universes, and current chapter progression.
- Ben, up to four hires, autonomous raptor, follower train, roster and formation management.
- ATB battles, equipment, six gear slots, skills, elements, status effects, random modifiers, rarity, drops, EXP, Duckets, defeat recovery, VFX, and SFX.
- Facility staffing, real/offline jobs, services, inventions, quests, save points, bestiary, encounter pressure, recall, and Rift Wards.
- Four scheduled town residents with reservations and replanning.
- Separate sandbox save, terrain painting, individual asset catalog, and authored-object relocation.
- Save migration through version 18.
- Forty-six smoke tests and a large validation-capture corpus.

### 3.2 The main structural risks

Several core scripts now carry too many responsibilities:

| Script | Approximate size | Current responsibility concentration |
|---|---:|---|
| `campaign_state.gd` | 2,660 lines | Mutable save state, immutable catalogs, progression, inventory, jobs, quests, facilities, encounters, recruitment, migration helpers |
| `campaign_bootstrap.gd` | 2,150 lines | Global coordinates, every universe layout, transitions, collisions, actors, interactions, and camera setup |
| `campaign_menu.gd` | 1,270 lines | Nearly every menu page, focus behavior, inventory, roster, skills, facilities, quests, and bestiary |
| `campaign_map_visual.gd` | 1,050 lines | Town, laboratory, every universe ground and prop drawing, raw atlas regions, building scale, and scenery |
| `campaign_battle.gd` | 800 lines | Battle flow, input, layout, presentation, effects, result handling, and scene transitions |
| `campaign_combat_database.gd` | 760 lines | Actors, enemies, actions, gear, animation definitions, and battle backdrops |

The answer is not a single rewrite. Use an incremental strangler migration: preserve current public calls, place typed services behind them, migrate one vertical slice, keep tests passing, and only then delete obsolete code.

### 3.3 Production risks

- The workspace is not currently a Git repository.
- The active project resides under OneDrive, which can lock or partially synchronize imported/generated files.
- Existing test and capture scenes can write normal Godot user data unless launched with an isolated user-data directory.
- The current save is a single non-atomic file without a last-known-good backup workflow.
- Some tests produce shutdown-only ObjectDB/resource-leak warnings.
- No complete fresh-save campaign playthrough has demonstrated duration, pacing, recovery, balance, or ending quality.
- Export configuration, release target, licensing inventory, and distribution checklist are incomplete.

---

## 4. Executive decisions

These decisions should be made before expanding content.

### 4.1 Pixel canvas

Preferred target:

- Canonical field canvas: **960 × 540**.
- Integer display scaling only.
- Camera zoom: `1.0` for ordinary field areas.
- Pixel-snapped camera and actor transforms.
- No `1.25` camera zoom and no fractional visual scaling for prepared gameplay sprites.

Because the inherited UI was authored around 1920 × 1080, Milestone 0 should compare two short prototypes:

1. A true 960 × 540 internal canvas with UI placed in its own scalable CanvasLayer.
2. A 1920 × 1080 internal canvas where all world art is an exact 2× nearest-neighbor presentation.

Choose one before requesting final parallax. The first is preferred because it makes world pixels, screen pixels, captures, and asset specifications agree directly. If migration cost makes the second necessary, all art and camera transforms must remain exact integer multiples.

### 4.2 World areas

Do not preserve the current 8 × 8 room template as the final format.

- A single-screen authored area should be approximately 20 × 11 cells on the 48-pixel grid.
- Larger exploration areas may be 24 × 14, 30 × 18, or another deliberate size with bounded camera travel.
- Main paths must be at least two cells wide; major entries and boss approaches should be three cells wide.
- Visible open floor must be navigable. Invisible blocking should be replaced by walls, rails, cliffs, water, furniture, shadows, or another legible boundary.
- Each universe should become its own authored scene or set of area scenes rather than occupying hard-coded coordinates inside one global map.
- Transitions should resolve through `area_id` and `spawn_id`, never another room's absolute global cell.

### 4.3 Asset authority

Do not create a second unrelated asset inventory. The existing root pipeline documented in `ASSET_PIPELINE.md` and its curated catalog should become the shared source registry.

Extend it to emit a Godot-consumable runtime manifest containing:

- Source pack, path, checksum, crop, alpha bounds, and density.
- Prepared runtime output when normalization or masking is required.
- Scale class, pivot, collision, shadow, interaction, doorway, portrait, and battle metadata.
- Animation sequences and declared facing fallbacks.
- License/provenance reference.

Clean standalone crops may continue referencing an atlas region. Generate a derived PNG only when the asset needs masking, pixel-density conversion, split upper/lower layers, shared animation-frame alignment, or another transformation that a rectangle cannot represent safely.

### 4.4 Quality vertical slice

Town, laboratory, Haunted Mansion, its battle stage, its time mechanic, one upgraded facility, and its post-stabilization town change will be the final-quality vertical slice. Nothing in later universes should be rebuilt to final quality until this slice proves:

- The resolution and pixel-density rules.
- The layered rendering and collision model.
- The new area-scene architecture.
- The shared encounter and boss-policy systems.
- The quest, invention, save, and facility contracts.
- The parallax import and capture workflow.
- Keyboard, mouse, and controller completion.

---

## 5. Priority definitions

| Priority | Meaning |
|---|---|
| P0 | Correctness, save safety, visibly broken crops/scales, or architecture that blocks all later work |
| P1 | Required for the Town/Mansion quality vertical slice |
| P2 | Required before bulk universe rebuilding |
| P3 | Campaign depth, optional content, polish, accessibility, and ship readiness |

Work may be visually attractive and still fail a milestone if its P0 dependencies are unresolved.

---

## 6. Safety, source control, and baseline work

### 6.1 Test isolation

Create one repository-owned launcher for tests and captures.

- Generate a unique temporary `GODOT_USER_HOME` inside a validated test-output directory.
- Refuse to run if the resolved test user-data directory equals the production Godot user-data path.
- Copy fixture saves into the isolated directory only when a test requests them.
- Preserve logs and failed fixture data as artifacts.
- Clean temporary data through an explicit, path-validated operation.
- Never run the current all-tests loop directly against normal user data.

Exit criteria:

- All 46 current smoke tests pass through the wrapper.
- A sentinel production save checksum remains unchanged before and after the suite.
- Capture scenes cannot modify campaign or sandbox saves.

### 6.2 Source control

Initialize Git before implementation begins.

- Commit current source, project settings, scripts, tests, manifests, documentation, and necessary generated runtime assets.
- Ignore Godot import cache, transient logs, temporary saves, captures not selected as golden references, and other reproducible build output.
- Review `.mcp.json` and every local configuration before the first commit; never commit tokens, credentials, machine-specific secrets, or private endpoints. Provide sanitized example configuration where needed.
- Use Git LFS or an equivalent deliberate binary policy for large source/editable art when a remote is selected.
- Tag the audited pre-refactor baseline.
- Prefer moving the active working copy out of OneDrive after Git and backup are established, or at minimum exclude volatile Godot/import directories from synchronization.

### 6.3 Recorded baseline

Run one isolated fresh New Adventure using both controller and keyboard/mouse.

Record:

- Time per chapter and universe.
- Encounters, victories, escapes, defeats, rests, and recalls.
- Party level, reserve level, Duckets, inventory, and equipment at every anchor.
- Every unclear objective, focus trap, collision mismatch, visual defect, bad crop, wrong scale, and dead end.
- Every instance where the player must consult source knowledge rather than in-game information.
- Every save/reload and retry location.
- Every job started, completed, cancelled, and collected.

Archive the baseline save, telemetry, and screenshots before changing persistent schemas.

---

## 7. Incremental code architecture

### 7.1 Keep public facades while extracting responsibilities

Keep `CampaignState` as the public autoload during migration so current scenes, UI, saves, and tests remain callable. Move behavior behind it gradually:

| New module | Responsibility |
|---|---|
| `ContentCatalog` | Immutable universe, facility, job, invention, quest, recruit, action, enemy, equipment, and item definitions |
| `CampaignSaveData` | Normalized mutable state only; no disk I/O |
| `SaveRepository` | Atomic disk I/O, backups, slot metadata, corruption recovery |
| `SaveMigrator` | Ordered `v18 → v19 → ...` transformations with fixtures |
| `CombatRules` | Pure action/effect/target/status/row calculations |
| `BattleAI` | Weighted enemy policies, cooldowns, conditions, boss states |
| `BattleResultService` | Exactly-once rewards, vitals, bestiary, quests, world events, and allowed autosave |
| `EncounterDirector` | One subscriber for all danger regions, pressure, wards, anti-repeat bags, field events, and formations |
| `UniverseStateDirector` | Typed persistent phase, mechanic state, shortcuts, secrets, stabilization, and revisit state |
| `QuestDirector` | Objective trees, typed events, choices, hints, idempotent rewards |
| `FacilitySystem` | Construction, upgrades, services, staffing, and relocation-safe facility state |
| `JobSystem` | Inputs, timing, worker quality, offline completion, cancellation, and rewards |
| `ProgressionSystem` | Levels, skills, reserve catch-up, recruit floors, and raptor bond |
| `EconomyLedger` | Reason-coded Ducket/item transactions and balance reporting |
| `SettingsRepository` | Input, audio, battle, display, accessibility, and telemetry preferences |

First move immutable definitions, then pure rules, then stateful services. Delete old code only after parity tests prove every caller uses the new path.

### 7.2 Data validation

Add a startup/headless validator that rejects:

- Duplicate or empty IDs.
- Missing item, action, actor, enemy, facility, quest, universe, or scene references.
- Quest/invention dependency cycles.
- Unreachable required conditions.
- Rewards using nonexistent items.
- Actions with invalid relation or target selectors.
- Hostile damage actions aimed at the same team unless explicitly marked friendly fire.
- Weaknesses unavailable in the chapter where the enemy first appears.
- Required recipes whose materials have no immediate authored source.
- Missing save defaults or migration handlers.
- Animation counts that disagree with files on disk.
- Runtime visual profiles with missing sources, pivots, or prepared outputs.

### 7.3 World scene migration

Replace global absolute world coordinates with a reusable area contract:

```gdscript
class_name AreaDefinition
extends Resource

@export var area_id: StringName
@export var universe_id: StringName
@export var scene: PackedScene
@export var spawn_points: Dictionary
@export var encounter_region_ids: Array[StringName]
@export var parallax_profile_id: StringName
@export var battle_stage_id: StringName
@export var world_state_variants: Array[StringName]
```

Each authored area scene should own:

```text
AreaRoot
├── Parallax
├── Ground
├── GroundDecals
├── BehindStructures
├── YSortedWorld
├── UpperOccluders
├── LightingAndWeather
├── Navigation
├── Collision
├── SpawnPoints
├── Transitions
├── Interactions
└── AreaStateController
```

Save data stores `area_id`, `spawn_id` or safe local position, facing, and typed universe state. It must not store scene node paths.

### 7.4 UI and battle separation

- Split `campaign_menu.gd` into page controllers with one shared focus/navigation shell.
- Keep UI state in view models rather than reading and mutating arbitrary global dictionaries from each page.
- Separate `campaign_battle.gd` into battle session/controller, command UI, actor presentation, VFX/audio presentation, and result transition.
- Keep `atb_battle_model.gd` deterministic and free of scene-tree assumptions.
- Give every battle a unique instance ID so repeated signals cannot grant rewards more than once.

---

## 8. Visual asset pipeline

### 8.1 Source and derived assets

Never modify vendor assets under `game/game_assets/`.

Use the existing curated asset catalog as the source registry and add a Godot export stage. A runtime profile may reference:

1. A clean atlas region directly.
2. A deterministic derived texture when it needs masking, normalization, density conversion, frame alignment, or split layers.

Recommended derived location:

```text
game/ben_rpg/visual_assets/generated/<pack>/<asset_id>/
```

The generated directory should mirror pack ownership and record the source checksum. Generated runtime assets should be committed so release builds do not depend on a developer-only image tool.

### 8.2 Runtime visual profile

The runtime needs one typed profile instead of duplicated scale literals, frame counts, and regions in many scripts.

```yaml
id: moonpetal_gate_left
kind: prop
source:
  pack: Sakura Temple
  texture: path/to/Shrine Gates.png
  region: [176, 401, 126, 160]
  alpha_bounds: [176, 401, 126, 160]
  checksum: ...
  expected_components: 1
  crop_gutter: [1, 1, 1, 1]
prepared:
  texture: generated/Sakura_Temple/moonpetal_gate_left.png
  size: [63, 80]
  world_draw_size: [63, 80]
  density_conversion: 0.5
placement:
  foot_anchor: [31, 75]
  visual_center: [31, 40]
  footprint_cells: [2, 1]
  collision_bounds: [4, 66, 55, 12]
  interaction_anchor: [31, 70]
  render_layer: ysort
  split_y: 54
  upper_texture: generated/Sakura_Temple/moonpetal_gate_left_upper.png
presentation:
  size_class: structure
  shadow_size: [52, 12]
  shadow_opacity: 0.24
review:
  crop_approved: true
  gameplay_scale_approved: true
  source_license_id: sakura-temple-license
```

Actor profiles additionally need:

- Shared frame canvas and bottom-center foot anchor.
- Sequence name, folder, frame count, FPS, loop, and action mapping.
- Available facings and explicit fallback per missing facing.
- Per-facing visual offset only when normalization cannot remove source asymmetry.
- Hover offset separate from ground/sort anchor.
- Field, portrait, and battle presentation profiles.
- Contact-shadow size and VFX/status/damage-number anchors.

### 8.3 Normalization workflow

1. Import current catalog metadata and inventory every runtime region.
2. Determine each pack's authored tile density from ground cells and supplied metadata.
3. Measure alpha bounds and connected components.
4. Select the intended component with a deliberate one- or two-source-pixel gutter.
5. Review disconnected components before removing them; do not automatically erase intentional particles, shadows, weapon trails, or foliage.
6. Normalize animation frames to one canvas and foot anchor.
7. Apply nearest-neighbor density conversion exactly once.
8. Split tall assets into base/body and upper/foreground layers when needed.
9. Save the prepared result at intended world size.
10. Render prepared assets at `scale = Vector2.ONE`.
11. Generate contact sheets and in-engine comparison captures.
12. Replace the runtime call site only after visual approval.

### 8.4 Source-density standard

| Authored source convention | World conversion |
|---|---:|
| 16-pixel tile art | 3× nearest conversion to 48 world pixels |
| 24-pixel tile art | 2× nearest conversion |
| 48-pixel tile art | 1× native |
| 96-pixel tile art | 0.5× nearest conversion |
| Unknown/showcase sheet | Measure and approve before use |

Buildings must not become landmarks by magnifying their raster pixels. Compose a larger building or give it a larger footprint while preserving the pack's visible pixel density.

### 8.5 Field scale bible

Ben's current approximate 55-pixel opaque height is the reference.

| Semantic class | Target opaque height |
|---|---:|
| Tiny animal | 20–32 px |
| Standard animal / small companion | 34–48 px |
| Short humanoid | 44–50 px |
| Standard adult | 52–58 px |
| Tall or armored adult | 58–64 px |
| Large construct or ogre | 64–72 px |
| Humanoid field boss | 72–96 px |
| Colossal/wide field marker | 80–120 px high and up to 192 px wide |

Immediate normalization targets:

| Actor | Current approximate height | Target |
|---|---:|---:|
| Ben | 55 px | Reference; preserve |
| Fighter | 62 px | Preserve as tall human or reduce slightly after lineup review |
| Astronaut | 53 px | Preserve height; bake current fractional scale |
| Caveman | 42 px | 52–56 px |
| Crimson Oni | 51 px | Preserve height; bake normalization |
| Kitsune | 43 px | 48–54 px |
| Neon Viper | 51 px | Preserve |
| Archangel | 54 px | Preserve body and explicit hover |
| Frost Lich | 48 px | 50–56 px body plus hover |
| Bulkhead Warden | 43 px | 64–72 px |
| Cobalt Courier | 48 px | 52–56 px |
| Mossback Surveyor | 33 px | 64–72 px |
| Rift Jackal | 44 px | Preserve height; repair ground contact |
| Velociraptor | 25 px | Preserve requested small-dog presentation |

All frames of one actor must keep their ground anchor within one pixel. Different actors standing on the same cell must keep their foot line within two pixels unless an explicit hover or slope rule applies.

### 8.6 Town resident normalization

The shared resident scale currently leaves them roughly 64–71 pixels tall beside 55-pixel Ben. Move scale and anchor into each resident profile.

Temporary starting values before scale-1 prepared sprites:

| Resident | Temporary scale |
|---|---:|
| Café owner | 1.34 |
| Librarian | 1.25 |
| Farmer | 1.20 |
| Shepherd / clinic aide | 1.20 |

Final town-resident height variance should be no more than six pixels unless a character is deliberately short or tall.

### 8.7 Portraits

- Target opaque occupancy: 70–85% of frame height and 65–85% of width.
- Give the Astronaut a tight padded portrait rather than the entire mostly empty 64 × 64 canvas.
- Add explicit portraits for Rift Jackal, Mossback Surveyor, Cobalt Courier, and Bulkhead Warden.
- Keep portrait crops independent from field frames.
- Test portraits in actual menu frames, including focus, disabled, KO, and selected states.

### 8.8 Battle scale

Use bottom anchoring and semantic classes instead of fitting every enemy into one centered box.

| Class | Target height at 960 × 540 presentation | Equivalent on retained 1920 × 1080 logical canvas |
|---|---:|---:|
| Party humanoid | 58–65 px | 115–130 px |
| Party animal | 35–52 px | 70–105 px |
| Standard enemy | 95–120 px | 190–240 px |
| Elite enemy | 115–140 px | 230–280 px |
| Humanoid boss | 135–165 px | 270–330 px |
| Wide/colossal boss | 110–150 px high, up to 220 px wide | 220–300 px high, up to 440 px wide |

A wide boss must not look smaller than a minor humanoid merely because aspect-fit is based on source-canvas width. Each profile needs target opaque height, maximum width, baseline, shadow, status anchor, and VFX anchor.

### 8.9 Animation and facing

- Replace duplicated six-frame literals for the four Topdown Monsters recruits with the validated eight source frames.
- Crimson Oni and Neon Viper require an explicit north solution instead of silently using west/east running art.
- Kitsune and Archangel require a north-facing solution rather than the south pose.
- Frost Lich requires a north-facing solution rather than west.
- If a true directional run does not exist, use the correct authored facing with a restrained step/bob animation. Never show sideways locomotion as north.
- Align Kitsune and Frost Lich east/west canvases so changing direction does not move the actor sideways.
- Give every follower and NPC a manifest-driven contact shadow.

### 8.10 Confirmed crop-repair inventory

Coordinates below are measured starting points, not permission to skip visual review. The final crop must include a deliberate transparent gutter and pass alpha/component lint.

| Priority | Asset | Current problem | Measured correction or required action |
|---|---|---|---|
| P0 | Ranch young tree | `Rect2(0,0,32,48)` contains the upper portion while the intended alpha begins lower | Start around `Rect2(0,32,32,32)` |
| P0 | Sandbox lab workbench | Top 26 pixels lost | Reuse corrected map crop around `Rect2(1,166,95,122)` |
| P0 | Sandbox triple-monitor station | Bottom chair/leg pixels lost | Start around `Rect2(180,389,108,115)` |
| P0 | Sandbox schedule station | Bottom eight pixels lost | Start around `Rect2(386,387,190,117)` |
| P0 | Sandbox Clock Hall | Includes lawn, tree strips, and sample-map contamination | Use the corrected facade near `Rect2(141,290,102,96)` plus reviewed lawn mask |
| P0 | Primeval tree A | Roughly 31 pixels cut from the left | Start around `Rect2(478,450,123,175)` |
| P0 | Primeval tree B | Roughly 32 pixels cut from the left | Start around `Rect2(633,447,135,178)` |
| P0 | Primeval shrub | Joins halves of two neighboring shrubs | Select one complete shrub near `Rect2(1063,659,96,89)` or `Rect2(1187,660,90,86)` |
| P0 | Primeval campfire | Right flame edge cut | Start around `Rect2(509,205,37,34)` |
| P1 | Primeval edge structures | Union crops trim tops/sides and combine components | Rebuild as individual props; approximate source groups are `(1,387)–(189,478)` and `(194,389)–(381,475)` |
| P1 | Primeval ruins | First clips right/bottom; second clips left/bottom | Start around `Rect2(53,199,124,133)` and `Rect2(607,206,101,128)` |
| P0 | Moonpetal second tree | Loses left side and includes neighboring blossoms | Start around `Rect2(303,549,212,254)` |
| P0 | Moonpetal shrine gates | Paved bases lose roughly 18–21 pixels | Start around `Rect2(176,401,126,160)` and `Rect2(327,402,125,158)` |
| P0 | Moonpetal palace/temple | Bottom ten pixels clipped | Use the component around `(48,586)–(350,767)` with gutter |
| P0 | Moonpetal garden A | Left/top clipped | Use the component around `(350,488)–(544,663)` |
| P0 | Moonpetal garden B | Right 23 pixels clipped | Use the component around `(585,496)–(785,660)` |
| P1 | Frosthold frozen tree | Top and left clipped | Use component around `(1165,174)–(1309,426)` |
| P1 | Frosthold bridge | Both sides and top trimmed | Use component around `(40,172)–(223,388)` |
| P1 | Frosthold market prop | Left side clipped | Use component around `(1075,475)–(1200,631)` |
| P0 | Asterion hatch | Bottom three pixels lost | Start around `Rect2(9,200,78,81)` |
| P0 | Asterion dock ship | Current dock reads as disconnected spacecraft fragments | Reinspect the entire source assembly and use one complete verified shuttle silhouette or author a larger bay that fits it |
| P0 | Mansion Archive props | Large regions cross into neighboring crate/shelf groups | Replace slab crops with individual shelves, crates, and furniture |
| P0 | Mansion Nursery bays | Presentation bays include wall and furniture together, creating a seam | Rebuild wall separately and place independently cropped beds/furniture |
| P1 | Battle backdrops | Arbitrary square/top-down atlas crops are aspect-covered into 16:9 | Replace with authored layered battle stages |

Moonpetal must also stop mixing `0.5` and `1.0` scale from the same high-density pack. Normalize the pack once, then create larger landmarks through composition and footprint rather than doubling raster pixels.

### 8.11 Asset-lint gates

Fail validation when:

- A crop is outside source bounds or uses fractional coordinates.
- Opaque pixels touch an edge without an explicit exemption.
- A single-object crop contains more connected components than declared.
- A component is truncated by the selected region.
- A generated output checksum is stale.
- Animation frame count differs from files on disk.
- Sequence frame canvases differ.
- The foot anchor moves more than one pixel across frames/facings.
- A facing is missing without a declared fallback.
- A gameplay sprite uses nonuniform scale.
- A prepared gameplay sprite uses runtime scale other than `(1,1)`.
- Pixel-art filtering or mipmaps are enabled.
- Camera/world transforms produce fractional final pixel positions.

### 8.12 Golden visual scenes

Create deterministic QA scenes for:

1. Every field actor in four facings beside Ben and a 48-pixel grid.
2. Every idle/run sequence.
3. Every town resident beside Ben.
4. Every field boss beside Ben.
5. Every prop with pivot, footprint, collision, and split line shown.
6. An actor walking in front of and behind every tall-prop class.
7. Every building with doorway, entrance cell, service point, and NPC activity sockets.
8. Every portrait inside the actual menu frame.
9. Every battle actor in shared size-class holders.
10. Every layered battle backdrop.

Capture the selected shipping canvas and its exact 2× presentation. A golden-image change requires human review and an intentional baseline update.

---

## 9. Rendering, collision, and camera architecture

### 9.1 Layer stack

```text
WorldVisualRoot
├── ParallaxBackground
│   ├── Sky
│   ├── FarSilhouette
│   └── FarWeather
├── Ground
│   ├── BaseTiles
│   ├── GroundDecals
│   └── UnderfootEffects
├── BehindStructures
├── YSortedWorld
│   ├── WorldProp2D
│   ├── BuildingFacade
│   ├── Ben
│   ├── Followers
│   ├── NPCs
│   └── FieldBosses
├── UpperOccluders
│   ├── Canopies
│   ├── GateLintels
│   ├── RoofFronts
│   └── ForegroundFoliage
├── LightingAndWeather
├── InteractionAffordances
└── HUD
```

### 9.2 World prop contract

Every placeable/authored object should have a ground-contact root:

```text
WorldProp2D
├── ContactShadow
├── Body
├── UpperOverlay (optional)
├── CollisionShape2D
├── InteractionAnchor
└── ActivitySockets (optional)
```

Rules:

- Rugs, runes, bridge decks, paths, puddles, scorch marks, tracks, and cracks are ground decals.
- Trees, cabinets, stalls, statues, machinery, furniture, and actor bodies are Y-sorted by their ground contact.
- Canopies, gate tops, roof lips, chandeliers, arch fronts, and close foliage are upper occluders.
- Buildings sort from their door/facade baseline, never their texture center.
- Tall mixed-behavior props use a profile split line or separately authored lower/upper textures.
- Collision describes the occupied base, not the complete silhouette.
- Interaction anchors remain reachable from at least one valid adjacent cell.
- When a large roof/canopy hides Ben, use an optional pixel-dither or opacity fade without exposing inaccessible interior art.

### 9.3 Camera rules

- Ordinary field zoom is `1.0`.
- Camera position is snapped to the final pixel grid after smoothing.
- If smoothing cannot remain pixel-stable, remove it or quantize it.
- Room bounds never expose gray canvas, black void, neighboring rooms, or unpainted space.
- Boss intro pans and shakes move in integer pixels.
- Camera shake, flashes, weather, and parallax can be reduced through accessibility settings.
- Capture mode can hide dialogue/UI and freeze deterministic weather for visual QA.

### 9.4 Navigation and scenery

- Main travel lanes: minimum two cells.
- Door aprons and major intersections: minimum three cells where the full follower train gathers.
- No unexplained blocked patch larger than a small decorative footprint.
- Every blocked region receives a visible boundary.
- Followers replay Ben's route, but layouts must still avoid repeated visual stacking at one-cell turns.
- Prop collision, navigation obstacle, rendered footprint, and selection footprint derive from one profile.

---

## 10. Shared room and prop-placement standard

Every authored room must contain:

- One primary landmark.
- Two or three supporting prop clusters.
- At least one small storytelling vignette.
- One visually legible main route.
- At least one optional observation, interaction, or secret.
- At least one animated detail: light, monitor, fog, foliage, flame, water, machinery, weather, or inhabitants.
- A deliberate pre-completion and post-completion difference.

Composition rules:

- Put the highest prop density at edges, functional work zones, and landmarks.
- Keep the central travel band quieter and higher contrast.
- Group related objects: crate beside delivery door, chair beside table, cable connected to machine, tools beside workbench.
- Avoid evenly spaced catalog rows and random confetti placement.
- Use large/medium/small rhythm: one landmark, two to four medium clusters, six to twelve small accents.
- Preserve intentional negative space around doors, save points, boss arenas, and dialogue staging.
- No unmotivated empty open patch larger than roughly 4 × 4 cells in a finished single-screen room.
- An interacted prop changes visibly: opened chest, lit terminal, moving clock, rerouted cable, ringing bell, thawed brazier.
- Interaction icons support the art; they do not replace it.
- Lighting should reinforce hierarchy without making collision boundaries unreadable.

Underused supplied-asset opportunities:

| Area | Asset families that should be brought into the authored scenery pass |
|---|---|
| Town | Modern World trees, street furniture, corners/shoulders, signs, carts, service clutter, construction pieces |
| Laboratory | Lockers, waste/emergency pieces, chemical carts, bottles, specimen trays, cables, stools, service cabinets |
| Mansion | Individual furniture, portraits, drapes, toys, instruments, architectural trim, candles, debris |
| Asterion | Complete ship/airlock components, tables, seating, carts, medical dividers, hydro equipment, cables, hazard markings |
| Primeval | Camp tools, fences, bones, cliffs, plants, warning signs, tracks, hides, carts, rock transitions |
| Helios | Loose architecture, furniture, vehicles, stalls, signs, plants, transit pieces, glass/lighting overlays |
| Frosthold | Snow fences, camp/market props, footprints, particles, pillars, monuments, braziers, Arctic decoration |
| Moonpetal | Bridges, flowers, furniture, food/service props, planters, rocks, walls, water edges, bells |
| Empyreal | Pottery, crates, seating, banners, shields, ruins, stairs, plants, braziers, island-edge pieces |

Room completion requires:

- Native-scale screenshot review.
- Full traversal around every side of major props.
- Follower, NPC, and boss staging review.
- Pre/post state capture.
- Save/reload in every partial puzzle state.
- Controller and click-to-move route completion.

---

## 11. Laboratory, town, buildings, and overworld scenery

### 11.1 Laboratory

Divide the current perimeter arrangement into four readable work zones:

| Zone | Function | Props and motion |
|---|---|---|
| West analysis | Bestiary, samples, research, universe evidence | Specimen trays, microscopes, bottles, notes, filing cabinet, animated monitors |
| Central invention bench | Crafting and visible project progress | Main bench, coils, tools, prototype silhouette, cable runs, task light |
| East fabrication | Equipment, repair, raptor gear, physical builds | Tool cabinets, parts bins, hoist, stools, scrap, sparking/working machine |
| South utilities and hazardous storage | Power, waste, emergency systems | Lockers, waste bins, chemical cart, eyewash, hazard signs, vents, shutoff panel |

Additional improvements:

- Keep a two- to three-cell central circulation loop.
- Make the town exit immediately visible through framing, floor markings, and lighting.
- Add floor wear beneath stools and benches rather than leaving every tile pristine.
- Give the raptor a small bed/nook, bowl, training marker, and occasional animation.
- Add a trophy/bestiary wall whose displays update after universes and bosses.
- Put the expedition map, formation prep, raptor policy, respec, and invention bench in visible physical locations.
- Replace generic floating service menus with interaction at those locations, while retaining controller shortcuts after discovery.

State progression:

- Opening: dim, partly offline, shipping crates, incomplete coils, fewer displays.
- Town founded: stable lighting, cleared crates, central bench operational.
- Each stabilized universe: one trophy, sample, imported prop, and invention display.
- Finale: all systems active, accumulated evidence wall, final expedition staging.

Exit gate:

- Every work zone reads without labels.
- No prop resembles a cropped catalog row.
- No interaction point shares a collision footprint with another.
- The route supports Ben, raptor, and four visible followers.

### 11.2 Town structure

Replace the sterile cross-road composition with a civic plaza and three connected districts:

| District | Buildings | Visual identity |
|---|---|---|
| Civic north | Laboratory, Library, Clinic | Stone walks, formal lamps, hedges, noticeboards, fountain/Franklin experiment landmark |
| Commerce center | Café, Armory, Afterlight Club | Wider street, awnings, deliveries, signs, seating, evening activity |
| Frontier/specialist south | Observatory, Trailhead, Cold Storage, Tea House, Belfry, anchors | Mixed terrain, gardens, service yards, trails, ceremonial approaches |

Town scenery kit:

- Curbs, shoulders, crossings, road corners, secondary paths, drainage, puddles, and worn wheel tracks.
- Benches, lamps, signposts, mailboxes, bins, planters, hitching posts, carts, crates, barrels, fencing, gates, and property boundaries.
- Modern World trees and street assets calibrated to the same density instead of relying on four oversized Ranch trees.
- Construction crews, deliveries, seated citizens, queues, couriers, children, and workers using scheduled activity sockets.
- Weather and time overlays: chimney smoke, cloud shadows, window lights, rain/snow/petals imported from stabilized universes.

Town progression should be visible in five broad states:

1. **Survey:** dirt plots, stakes, lumber, incomplete roads, few residents.
2. **Founding:** four civic facilities operational, construction debris moving outward.
3. **Early anchors:** first imported materials and unusual visitors.
4. **Multiversal town:** cross-world props, mixed residents, upgraded services, stronger evening identity.
5. **Finale/postgame:** stabilized weather, celebration/ceremony, all anchors active, postgame visitors and rematches.

The three-district arrangement is the authored/default town composition, not a placement restriction. The player may relocate buildings freely. Expand the town beyond its current 32 × 28 cells if the default districts, readable paths, and activity yards cannot fit without crowding.

Each completed universe must add at least:

- One exterior prop family.
- One weather/lighting or ambient effect.
- One resident/dialogue update.
- One service, job, quest, or shop update.
- One visible change at its anchor building.

### 11.3 Building scale and relocation contract

Calibrate buildings by door, step, and human scale. The current Trailhead reads oversized while the Observatory doorway reads undersized.

Each facility definition needs:

```yaml
facility_id: library
visual_profile: town_library_operational
footprint_cells: [5, 4]
door_anchor: [2, 3]
entrance_cells: [[2, 4], [2, 5]]
service_anchor: [2, 2]
staff_socket: [3, 3]
visitor_sockets: [[1, 4], [4, 4]]
yard_sockets: [bench, sign, delivery, vegetation]
collision_profile: library_base
upper_occluder_profile: library_roof
interior_area_id: library_interior
states: [foundation, operational, upgraded]
```

Relocation rules:

- Building story state, worker, active job, upgrade, and interior remain unchanged.
- Door, service, sign, yard props, NPC activity sockets, collision, and upper occluder move as one unit.
- Validate map bounds, overlap, entrance reachability, spawn access, and required roads before committing.
- An invalid move explains the problem and restores the exact prior position.
- Placement has no adjacency bonus or progression penalty at launch.
- A disconnected building can show a warning/path preview, but the player is never punished with lost progress.

### 11.4 Construction and upgrade visuals

Every building has:

- Foundation: stakes, materials, workers, partial wall/floor, no service.
- Operational: complete facade, sign, door, core service props.
- Upgraded: distinct roof/sign/yard detail, new service equipment, stronger light/activity.

Upgrading must change the service and appearance, not merely increase a hidden multiplier.

### 11.5 Building-by-building exterior and function

| Facility | Exterior/yard improvements | Direct gameplay identity |
|---|---|---|
| Café | Two outdoor tables, awning, chalkboard, planters, delivery crates, evening lanterns | Expedition meals, rumors, recruit conversations, imported ingredients |
| Library | Steps, book return, map window, noticeboard, reading bench, hedges | Research projects, weakness/secret/evidence reveal, bestiary |
| Clinic | Clean apron, herb garden, waiting bench, supply cart, lit medical sign | One-expedition treatment, resistance preparation, injury recovery |
| Armory | Forge chimney, coal and wood, target dummy, weapon rack, delivery yard | Buy/sell, salvage, reforge, loadouts, deterministic resistance gear |
| Haunted Mansion anchor | Wrought fence, dead garden, leaves, gravestones, fog, gated approach | Containment, rematches, time trials |
| Observatory | Telescope/dome silhouette, antenna, panels, cable cabinets, night glow | Forecasts, destination intelligence, route/shortcut information |
| Trailhead Lodge | Trail signs, fire ring, timber, survey table, tracks, specimen crates | Foraging, hunts, Primeval preparation |
| Afterlight Club | Neon sign, queue rails, reflected light, posters, rooftop units, service alley | Night contracts, initiative prep, social events |
| Cold Storage | Icehouse door, frost vents, insulated crates, handcart, provisions, condensation | Frost salvage refinement, thermal preparation, preservation |
| Tea House | Pond edge, small bridge, lantern path, tea tables, planting, garden fence | Bonds, diplomacy, tea preparations, memory work |
| Belfry | Tall bell silhouette, formal steps, banners, braziers, ceremonial court | Wind/weather control, landing selection, town events |

### 11.6 Facility interiors and schedules

Each facility needs a compact interior or dedicated service room. It should contain:

- One service focal point.
- A visible operator station.
- A staffed-recruit variation.
- At least two visitor/activity sockets.
- A storage/display area that changes with upgrades.
- An after-hours bell, terminal, drop box, or alternate access method for essential services.

NPC schedules should include work, meal, errand, social, and home phases. Offscreen schedules may simulate destinations without instantiating every actor, but entering the area must place them at a valid reserved socket. Essential services remain accessible when schedules fail or operators are elsewhere.

---

## 12. Universe design standard

Every universe must implement the same high-level campaign loop without copying the same room graph:

```text
Arrive and read the world's problem
    ↓
Explore a distinctive topology and learn a reusable world rule
    ↓
Recover evidence/material/knowledge
    ↓
Use a facility, invention, specialist, or preparation choice
    ↓
Return through a changed route or optional shortcut
    ↓
Fight a boss whose rules derive from the environment
    ↓
Stabilization changes the world, anchor, town, services, jobs, and revisit content
```

Global content floor per universe:

- A unique topology and objective rhythm.
- One reusable signature mechanic.
- One genuine noncombat puzzle.
- One optional specialist shortcut with a quality-dependent outcome.
- Two optional spaces, secrets, or meaningful detours.
- One safe-versus-risky route choice.
- One environment-linked boss counter.
- Persistent pre- and post-stabilization states.
- At least six weighted normal formations assembled from four or more enemy roles.
- One rare/elite encounter.
- Two noncombat field events.
- Two scripted battles in addition to the boss.
- One save point before the commitment/boss stretch.
- Clearly warned and minimal recall lockout.
- Save/reload support for every partial puzzle state.
- Post-stabilization revisit content.

The main route cannot depend on random loot, real-time waiting, color alone, or a specific optional recruit.

---

## 13. Haunted Mansion

### 13.1 World identity and state

Pre-state:

- Moonlit, low saturation, stopped clocks, unstable light, closed curtains, dust and fog.
- Rooms shift among two or three time states.
- Portraits, doors, props, and encounters change consistently with time.

Post-state:

- Clocks move, some curtains open, warm lamps return, and the repaired route becomes visible.
- Ghosts may remain as ambient residents or optional encounters.
- Containment work, rematches, and a time trial become available through the Mansion facility.

Add a short exterior forecourt before the foyer. It establishes scale, weather, fence, graveyard, and approach and provides the Mansion's strongest parallax opportunity.

### 13.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Forecourt | Wrought gate, graveyard, dead garden, leaves, crooked trees, porch, lit/black windows, branch foreground | Introduces clock instability through repeated lightning/time cues; optional grave clue | House reads as a landmark; no floating facade; complete parallax stack |
| Foyer | Entrance rug, side table, umbrella stand, portraits, clock, chandelier shadow, banister edge, cobwebs, side-door architecture | Clock is the primary interactive; room visibly changes with selected time | Clock, bookcase, doors, and exit visible together; no camera crop |
| Archive | Individual shelves and crates, two short aisles, research table, papers, rolling ladder, candle pool | Hidden passage changes with time; at least one clue can be reached in two states | Save clock has clear approach; no slab/presentation-sheet crops |
| Gallery | Staggered portraits, sculpture plinths, bench, fallen frame, torn drapes, moonlight | Investigated portrait physically changes; gaze/order supplies one independent 4:44 clue | Relevant portrait is distinct before interaction without generic icon |
| Nursery | Separate wall, independent beds, toy chest, dolls, blocks, rocking horse, music box, drawings, curtain movement | Music-box pattern supplies another clue; time state changes toy/footprint positions | No seam through room; music box is focal; route remains readable |
| Ballroom | Scuffed circular floor, chandeliers as upper occluders, columns, sofas, curtains, instruments, service tables | Boss arena; clock state changes phase and available counters | Reads as ballroom without boss; boss never covers unrelated props |

### 13.3 Mansion mechanic

- Replace automatic flag completion with a player-set clock or dial.
- At least two independent environmental clue chains imply 4:44.
- Wrong input produces specific state feedback, not a generic failure.
- Hint escalation first identifies the missing room/evidence, then the relationship, and only finally the answer.
- Time changes are reversible and cannot trap the player.
- At least one shortcut, encounter table, portrait arrangement, and door link changes by time.
- The time-tuning invention remains useful for a secret, boss counter, Mansion service, and later optional interaction.

### 13.4 Mansion boss

- At least three clock-linked behavior states.
- A visible/audio telegraph for `Steal Time`.
- Defend, ATB disruption, and time tuning are all viable counters.
- No phase may indefinitely deny turns.
- Boss state and room clock state must survive save/reload where saving is allowed.

Acceptance targets:

- Blind players solve the core clock puzzle in a median of 15 minutes or less.
- Repeatedly clicking interactions cannot auto-solve it.
- Boss has at least two viable counters and three readable states.
- Opening through Mansion stabilization forms a coherent 90–150 minute vertical slice.

---

## 14. Asterion Station

### 14.1 World identity and state

Pre-state:

- Emergency-red strips, flickering displays, leaking pipes, loose cargo, failed hydroponics, limited oxygen/power.

Post-state:

- Stable cyan/green lighting, powered doors, organized cargo, recovered plants, traffic outside viewports, and active crew terminals.

### 14.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Dock | One complete verified shuttle, airlock, gantry, hazard stripes, fuel hose, pallets, tools, cargo markings, space opening | Power choice can enable cargo lift, dock seal, or navigation data | Shuttle is one silhouette with obvious docking direction |
| Mess | Two table clusters, chairs, serving counter, trays, vending, waste return, lockers, crew notices | Optional crew logs and meal/rest preparation; state reflects oxygen/power | Reads as communal room rather than cabinets on an empty floor |
| Hydroponics | Parallel grow aisles, irrigation, drains, mist, lamps, tools, diseased/restored crops | Powering it creates a safe route/resource but leaves another consumer offline | Console visibly connects to machinery; plants have failed/restored variants |
| Medical | Treatment bays, curtains, scanner, cabinets, emergency cart, floor markings | Medical power provides prep/recovery and changes encounter consequence | Beds are complete silhouettes; save beacon cannot be mistaken for clutter |
| Control | Raised command bank, side consoles, cable trenches, warning lights, panoramic viewport | Final allocation and Mother Computer confrontation | Boss integrates with wall/system; focal point reads before battle |

### 14.3 Power and oxygen mechanic

- Four consumers: Medical, Hydroponics, Cargo/Dock, and Control.
- Only two are initially powered.
- At least two valid restoration orders.
- Console diagram, door lights, room lights, props, hazards, and journal all agree.
- Choice changes route, encounter table, optional reward, and crew/environment state.
- Restoring all systems eventually remains possible; initial order must not permanently erase content.
- Oxygen or exposure never drains while the player reads dialogue, menus, or cutscenes.
- Astronaut or approved specialist opens a repair/navigation alternative whose quality changes route or result, not merely cache quantity.

### 14.4 Mother Computer

- Three targetable modules or logical states tied to powered systems.
- Module isolation/destruction creates an observable tradeoff.
- Boss telegraphs system actions and queries the generic environment state.
- No boss-only conditional code belongs in the battle UI.

Acceptance:

- Player can explain the current allocation without opening the journal.
- Every legal order remains completable.
- Power state survives reload.
- Boss mechanics change visibly based on the player's system decisions.

---

## 15. Primeval Expanse

### 15.1 World identity and state

Pre-state:

- Dense overgrowth, blocked trails, active herd traffic, and absurd municipal signs intruding on wilderness.

Post-state:

- Repaired signals, safer fires, villagers traveling between areas, visible wildlife routes, and ambient rather than purely hostile creatures.

### 15.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Grove | Dense upper/side canopy, roots, ferns, mushrooms, rocks, insects, bones, tracks, light shafts | First visible herd route and signal/totem introduction | Two-cell trail is framed by ecology rather than floating in lawn |
| Village | Believable dwelling yards, fences, fire ring, hides, tools, food storage, carts, seating, workers | Translator/specialist conversations and optional preparation | Settlement reads as lived-in place, not a top row of huts |
| Ruins | Connected walls, collapsed stone, vines, fossils, road markings, cliff/water edge, cache alcove | Signals redirect a route; translator exposes lore and boss counter | Idol has processional approach; no empty tan rectangle |
| Nest | Varied nests/eggs, shells, prints, broken fence, abandoned survey gear, defensive foliage | Risk route with rare encounter/reward; herd state changes access | Habitat reads as ecology, not one oversized inventory icon |
| Caldera | Volcanic rock, ash, cracks, cliff ring, fumaroles, embers, charred plants, bones, smoke | Dedicated boss arena using lanes/signals | Visually escalates beyond Ruins; no unexplained water corner |

### 15.3 Herd and signal mechanic

- At least three signal/totem nodes redirect visible herd routes and open/close paths.
- Safe jungle and risky roadway both reach the objective.
- Risky route has higher pressure, rare rewards, or faster travel.
- Tracks, nests, sound, and animation teach ecology before punishment.
- The translator works on at least three devices: lore, route, and boss counter.
- All legal signal combinations remain recoverable.
- No herd collision can softlock an entrance, save point, or player position.

### 15.4 Boss

- Charges are lane-based and telegraphed for at least one full decision window.
- Signals, rows, Guard, and preparation create openings.
- Caveman/approved specialist improves interpretation or foraging but is not mandatory.

Acceptance:

- Blind players can predict at least one route change from scenery alone.
- Both safe and risky paths remain valid.
- Boss charge always has an available response.

---

## 16. Helios Arcology

### 16.1 World identity and state

Do not retain untouched showcase quadrants as final maps. Recompose the world from individual architecture, furniture, signs, vehicles, plants, and service pieces so navigation and perspective agree.

Pre-state:

- Oppressive permanent noon, overexposed whites, compulsory signage, heavy patrols, and nonstop traffic.

Post-state:

- Restored day/night rhythm, lower glare, varied shop lighting, disabled propaganda, visible nightlife, and changed transit.

### 16.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Skybridge | Wide glass crossing, rails, supports, seating, planters, signs, skyline and traffic below | Introduces light/shadow routes and a first grid node | Drop and bridge boundary unmistakable; no invisible walls |
| Market | Actual stalls/fronts, delivery carts, bins, vending, shoppers, awnings, central aisle | Power state changes vendors, patrols, secret shop, and shortcut | Treasure belongs to a storefront, not an atlas edge |
| Transit | Platforms, turnstiles, route board, benches, rail/tube, vehicle, commuters | Train links change with day/night/power state | Entry, platform, and destination identifiable at a glance |
| Clinic | Reception, waiting, treatment bays, recovery garden, screens, cabinets | Safer route/preparation versus faster exposed route | Save point and treatment equipment remain distinct |
| Civic Core | Concentric platform, power conduits, regulators, barriers, artificial sun source | Final grid manipulation and boss arena | Lighting changes during battle; room is not generic stairs/planters |

### 16.3 Day/night/power mechanic

- State changes at least three districts in lighting, doors/trains, encounters/patrols, residents, and secrets.
- Use icon, text, shape, and audio as well as color.
- Light path is faster, higher pressure, or more rewarding.
- Shadow path is safer, non-twitch, and controller-friendly.
- No required timing-stealth section.
- The phase inverter toggles multiple nodes and also has battle/preparation and facility use.
- Switching cannot strand the player or invalidate their occupied cell.

### 16.4 Civic Sun

- At least three shield/overcharge states tied to grid nodes or adds.
- Pre-boss research clearly reveals the relationship.
- Every shield state has a currently available counter.
- Lighting and UI telegraph overcharge without relying on hue alone.

Acceptance:

- Every district confirms state visibly and textually.
- Alternate node order remains supported.
- Boss shield can never become permanently invulnerable.

---

## 17. Frosthold Kingdom

### 17.1 World identity and state

Pre-state:

- Blue-white exposure, blowing snow, shuttered stalls, unlit braziers, buried routes.

Post-state:

- Amber windows, open market, controlled blue flame, clearer paths, resident tracks, flags, and reduced storm.

Create a terrain grammar instead of repeating one interior sample:

- Packed snow.
- Deep drift.
- Ice.
- Cobble.
- Cracked ice.
- Footprints/tracks.
- Warm/thawed transition.
- Cliff, river, or abyss edge.

### 17.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Snow Gate | Extended walls, open/closed gate, banks, fences, flags, guard shelters, tracks, icicles | First warmth refuge and route choice | Route visibly passes through architecture |
| Frozen Market | Goods, crates, barrels, rugs, awnings, carts, merchants, food steam, braziers | Warm hub; optional supplies and specialist route | Feels inhabited and warm against exterior snow |
| Crystal Causeway | Ice river/abyss, cracked edge, ropes/rails, crystal reflections, clear landings | Optional thaw changes bridge safety/encounters | No navy void; entry and exit are legible |
| Rune Hall | Interior nave, columns, wall runes, banners, altar, ice pillars, blue light | Rune/thermal puzzle and alternate boss preparation | Silhouette differs completely from Snow Gate |
| Ice Throne | Raised dais, actual throne, side stairs, banners, statues, shattered ice | Dedicated boss arena | Room still communicates kingship after boss disappears |

### 17.3 Warmth and thaw mechanic

- Use explicit Warm, Chilled, and Freezing states.
- Exposure affects encounter pressure and starting ATB/initiative, not continuous lethal HP loss.
- Dialogue, pause, and menu time do not advance exposure.
- Warm refuges are always within a tested traversal allowance.
- Player may thaw an optional path while another refreezes.
- Critical path can never permanently lock.
- Footprints, steam, particles, icon/text, and terrain state communicate temperature without color alone.

### 17.4 Whiteout Auditor

- Frost armor thaws, storm state reforms it, and braziers/thermal preparation create openings.
- At least two thermal solutions are available.
- Do not use inventory weight as a punitive temperature mechanic.

Acceptance:

- A minimum-gear, no-job party can reach every required objective.
- Brazier state survives reload.
- Dragon does not cover throne, doorway, or phase indicators.

---

## 18. Moonpetal Court

### 18.1 World identity and state

Normalize every source from the Sakura pack to one density. Widen processional lanes to at least 96 world pixels.

Pre-state:

- Muted palette, still water, sparse petals, repeated ceremonial geometry, counterfeit/official memory.

Post-state:

- Richer color, ringing bells, moving water, open screens, populated court, true objects restored, continuous petals.

### 18.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Vermilion Gate | Boundary walls/fences, moss, flowers, guardian stones, signboard, broad approach | First official/true-state discrepancy | Gate belongs to a compound rather than floating on fill |
| Blossom Court | Veranda, steps, seating, banners, lantern rhythm, attendants, gardens | Evidence conversations and state-dependent access | Temple door correctly human-scaled |
| Mirror Garden | Real pond shoreline, bridge, stepping stones, reflection, reeds, shrubs, rocks, offerings | Reflection/evidence puzzle and grounded cache | Water connects to terrain rather than a framed card |
| Bell Walk | Actual bells, frames, ropes, lantern cadence, walls, tablets, mist | Bell/order clue and state toggle shortcut | Recognizable bell route, not two isolated gates |
| Moon Palace | Expanded forecourt, connected walls/gardens, wide avenue, raised judgment dais | Evidence decision and boss arena | Ben/followers never overlap boss on arrival |

### 18.3 Memory-state and evidence mechanic

- The Veracity Lantern toggles `official memory` and `true night`.
- At least three areas change props, routes, clues, or residents.
- State uses icon, audio, silhouette, text, and color.
- Evidence contains at least three claims plus corroborating clues.
- Wrong answer raises pressure, starts an alternate encounter, or loses an optional reward; it never corrupts or locks the main story.
- Hint escalation identifies missing evidence before revealing the conclusion.
- Specialist quality may provide extra evidence or a peaceful alternative.
- Toggling state safely relocates Ben if collision changes around the occupied cell.

### 18.4 Magistrate Enma

- Boss creates readable duplicates.
- Lantern or Examine marks the genuine target.
- Clones obey consistent rules.
- Identity never reshuffles without a telegraph.

Acceptance:

- Puzzle has one demonstrably supported answer.
- All acquired clues appear in the journal.
- Every state toggle is safe after reload.

---

## 19. Empyreal Court

### 19.1 World identity and state

Empyreal has the strongest current visual baseline. Preserve its clarity while adding depth, motion, prop density, island silhouettes, and tribunal identity.

Pre-state:

- Rigid symmetry, static repeated clouds, bright bureaucratic gold, sealed gates, unstable gravity.

Post-state:

- Multiple cloud depths, warmer gardens, open lifts, looser banners, visitors, stable islands, changed particle direction.

### 19.2 Room plan

| Room | Art, props, and architecture | Mechanic and staging | Completion gate |
|---|---|---|---|
| Cloudstep Landing | Island edges, drop shadows, arrival stairs, gravity lift, banners, tribute luggage, guards | First gravity plane and safe state demonstration | Door is not sole landmark; falling edge is clear |
| Garden of Appeals | Seating, amphoras, petitions, flower beds, shade, animated fountain | Weighted lift and optional petition route | Trees/fountain form usable plaza |
| Forum of Measures | Debate benches, scroll racks, crates, measurement marks, banners, speaker circle | Multiple gravity/weight choices | Reads as civic forum, not rear-wall prop row |
| Reliquary Aerie | Broken marble, wind streamers, altar debris, suspended relics, dangerous edge | Optional vertical shortcut and gravity crystal | Crystal and portal have different silhouettes/purposes |
| Seraph Tribunal | Stepped court seating, railings, banners, witness dais, floor seal, braziers | Final boss and ending transaction | Remains a tribunal after boss disappears |

### 19.3 Gravity mechanic

- At least three gravity zones or planes.
- Weighted lifts, wind bridges, and two vertical shortcuts.
- Counterweight anchors rooms or objects; equipment weight is never punitive.
- State uses particles, prop lean, shadows, icon/text, and audio.
- If a state change invalidates the current cell, move the player to a declared safe neighbor before applying collision.
- Every configuration is recoverable after reload.

### 19.4 High Comptroller and ending

- Grounded, airborne, and gravity-shift phases use generic row/ATB/environment effects.
- Every forced row change has a preparation or recovery action.
- Stabilization commits exactly once.
- Trigger authored epilogue, credits, post-ending town state, final save marker, free roam, and rematch access.
- Ending rewards and flags cannot repeat on reload.

Acceptance:

- No off-map or invalid-cell load.
- Controller navigation works through vertical/gravity routes.
- Ending always triggers once and can be safely reloaded afterward.

---

## 20. Combat redesign

### 20.1 Correctness before expansion

Replace overloaded target strings with explicit relation and selector:

```yaml
action_id: heavenly_aegis
kind: support
relation: same_team
selector: all
costs:
  mp: 6
effects:
  - type: buff
    stat: defense
    magnitude: 20
    duration_actions: 3
  - type: buff
    stat: resistance
    magnitude: 15
    duration_actions: 3
tags: [holy, protective]
```

Supported relation:

- `opponent`
- `same_team`
- `self`

Supported selector:

- `single`
- `all`
- `row`
- `lowest_hp`
- `highest_atb`
- `ko`

Actions are ordered effects: damage, heal, revive, buff, debuff, status, cleanse, ATB change, row move, environment change. One target resolver is the only authority.

Required fixes:

- Reject enemy damage aimed at its own team unless explicitly friendly fire.
- Reject invalid KO/alive target combinations.
- Do not spend MP/items when a command has no valid target.
- Emit explicit applied, resisted, immune, missed, no-effect, and invalid events.
- Standardize revival to exactly 1 HP where the design requires it.
- Make Heavenly Aegis protective rather than another attack rally.
- Validate action descriptions against effects.

### 20.2 Exactly-once results

A battle result contains:

```yaml
battle_instance_id: uuid
encounter_id: frosthold_whiteout_auditor
outcome: victory
rewards: ...
party_vitals: ...
world_events: ...
resume_destination: ...
```

Commit once:

- Party vitals.
- EXP and Duckets.
- Loot.
- Bestiary sightings/defeats/drops.
- Quest events.
- World flags and stabilization.
- Allowed autosave.

World controllers observe the committed result. They never independently grant rewards, resolve victory, or save.

### 20.3 ATB usability

- Add Active and Wait modes.
- Add battle-speed setting.
- In Wait mode, hostile gauges pause while command/target menus are open.
- In Active mode, current gauge behavior continues.
- Result screens and cutscenes always freeze resolution.
- Cancelling a target returns to the same ready actor without losing the gauge.
- Display clear ready state and telegraphed enemy actions; an optional compact upcoming-ready strip may be tested.
- Provide screen-shake, flash, and animation-speed accessibility options.

### 20.4 Formation depth

- Add a zero- or low-cost Row command.
- Validate front/back capacity.
- Give enemies formation rows.
- Tag actions as melee, ranged, row, piercing, interceptable, or environment.
- Back row is a tactical sidegrade, not a universal penalty.
- Ranged actions ignore the outgoing back-row physical penalty.
- Add Protect/Intercept and row/line effects.
- Universe mechanics alter rows/airborne state through generic effects, never universe-specific battle UI code.

### 20.5 Enemy AI and bosses

Normal policy:

```yaml
- action: shock_baton
  condition: target_not_shocked
  weight: 3
  cooldown: 1
  target_policy: highest_atb
  no_repeat: 1
```

Boss policy requires:

- At least three behavior states.
- Visible telegraph and counter window.
- Cooldowns and no-repeat controls.
- Environment queries.
- Adds/modules/interrupt windows where appropriate.
- A consequence the player can understand.

Solo bosses gain depth through phases, extra turns, modules, adds, and counter windows—not HP inflation alone.

### 20.6 Weakness and information policy

- Add Examine or research-derived previews before defeat.
- Every first-visit weakness must be available through a party action, equipment-granted action, item, invention, or environment.
- Remove or retime Frost/Radiant weaknesses that require recruits obtained later.
- Add Fire access before any first-visit Fire weakness.
- Boss resistance may reduce a status but must not silently erase a recruit's entire role.
- Telegraph important immunity and state changes in text/icon form.

### 20.7 Raptor depth

Keep the raptor autonomous, but allow one preselected policy at town/save points:

- **Harass:** damage and ATB disruption.
- **Guard Ben:** intercept/support.
- **Scavenge/Support:** utility, item conservation, minor recovery.

Raptor bond/level follows party progression. It does not occupy a party slot, accept direct battle commands, or count toward defeat.

### 20.8 Combat acceptance

- Seeded tests cover every action and target matrix.
- Every boss has at least three states and two viable counters.
- At least three viable party compositions clear each boss in simulations.
- One unavoidable normal-enemy action never removes more than 60% of a level-appropriate full-health party.
- Normal encounter median target: 45–90 seconds.
- Boss median target: 4–8 minutes.
- No reward, quest, or victory transaction can commit twice.

---

## 21. Encounter system

Replace the seven near-duplicate universe controllers with one `EncounterDirector`.

### 21.1 Region data

```yaml
region_id: primeval_risky_road
universe_id: primeval
area_id: primeval_grove
cells_or_polygon: ...
required_states: [herd_east]
excluded_states: [stabilized]
threshold_range: [10, 15]
cooldown_steps: 8
pressure_modifiers:
  specialist: -2
  risky_route: 3
anti_repeat_depth: 2
formations:
  - id: raptors_and_scout
    weight: 4
  - id: herbivore_wall
    weight: 3
rare_slot: primeval_green_audit
field_events: [lost_cart, fossil_signal]
```

### 21.2 Deterministic trigger order

1. Transition/save/cutscene guard.
2. Scripted story trigger.
3. Cooldown.
4. Safe/danger-region check.
5. Ward/environment suppression.
6. Pressure increment.
7. Weighted formation or field event.

One step triggers at most one event.

### 21.3 Pressure and wards

- Only arriving in a new danger cell increments pressure.
- Standing, bumping, menus, dialogue, and cutscenes do not.
- Rift Ward suppresses a fixed number of danger steps; define whether accumulated pressure pauses or decays and show it.
- Each universe adds two world-specific pressure controls, such as a safe route, environment state, or specialist.
- Each universe has a deliberate high-risk route with a real reward.
- Save pressure and anti-repeat bag outside restorative save points.
- Save-point rest may explicitly reset them.
- Prevent reload reroll exploits.

### 21.4 Formation content

Per universe:

- At least six normal formations from four or more enemy roles.
- One rare/elite.
- Two field events.
- Two scripted fights.
- One boss.
- State-dependent inclusion/exclusion.
- No immediate identical formation when another choice exists.

Direct-route target cadence is approximately one meaningful battle every two to four traversal minutes, tuned from telemetry rather than one global step constant.

### 21.5 Encounter acceptance

- Every reachable danger cell maps to a valid table.
- Safe cells never roll.
- Story triggers always win priority.
- Ward decrement, cooldown, pressure, exit/reentry, and save/reload are deterministic.
- No formation references unavailable enemies/actions.
- Completion flags match their exact encounter instance.
- Identical consecutive random formations are zero when alternatives exist.

---

## 22. Progression, roles, skills, and equipment

### 22.1 Level and skill curve

Recommended launch curve:

- Story ending around level 30–35.
- Level cap 50 reserved for completionist content and rematches.
- Approximately 10–12 meaningful nodes per approved character/role.
- Three branches: core role, specialization, party support.
- Escalating costs totaling roughly 24–30 points.
- By credits, afford one full branch plus part of another—not the whole tree around level five.
- Avoid filler nodes that only add tiny percentages.
- Keep respec transparent and accessible: free in early Lab chapters or a clear Ducket fee later.

### 22.2 Reserve and staffed catch-up

- Hired non-staffed reserves receive 75–80% battle/quest XP.
- Staff receive job XP plus rested catch-up.
- A released reserve/staff member should remain within two levels of active-party median.
- New hires enter at max(chapter floor, party median minus one).
- Real-time jobs are never the only way to make a recruit usable.
- Removing a staffed character previews party/formation consequences and preserves job progress according to the cancellation policy.

### 22.3 Role completeness

Every approved recruit/role needs:

- A repeatable basic action.
- A resource-spending payoff.
- A defensive or utility action.
- At least one party synergy.
- A fixed specialty and meaningful adjacent training.
- A distinct facility benefit.
- A recruitment mission demonstrating the role.

### 22.4 Equipment

- Keep six equipment slots.
- Define affinities by role; not everyone wears everything.
- Add deterministic universe sidegrades and resistance equipment to the Armory each chapter.
- Random loot adds excitement but is never the sole boss counter.
- Add saved loadouts, compare, unequip-all from reserve/staffed actors, salvage, and one-modifier reforge.
- Protect equipped and unique items.
- Do not add more rarity tiers or currencies until current modifiers are balanced.
- Maintain an element-availability matrix by chapter and possible anchor order.

Acceptance:

- XP fixtures validate every level through 50.
- Skill spend/respec cannot produce illegal state.
- Active/reserve median gap stays at or below two under representative play.
- No item instance is equipped twice.
- Minimum three simulated party compositions can beat every boss.

---

## 23. Economy and resource design

### 23.1 Ledger

Every transaction records:

```yaml
reason_id: armory_purchase
chapter: frosthold
currency_or_item: duckets
delta: -120
source_context: armory_resistance_boots
```

Report earned, spent, and held per chapter, plus item source/sink ratios and earliest/latest gate affordability.

### 23.2 Main-path guarantees

- Every required invention material has at least two immediate authored sources before its gate.
- One may be a challenge; neither may be a real-time job.
- Main story succeeds in low-combat, median, high-combat, missed-treasure, and no-job simulations.
- Unique/key materials cannot be sold or accidentally consumed before required use unless guaranteed replacements exist.
- Use existing Duckets and components; do not proliferate currencies.

### 23.3 Resource sinks

Provisions need repeatable uses:

- Expedition meal/preparation.
- Optional job catalyst.
- Quality-scaled specialist assist.
- Facility event or town celebration.

Research notes need:

- Required invention use.
- Optional research/weakness/secret reveal.
- Skill or service upgrades.
- Multiple authored sources so missed treasure cannot block progress.

### 23.4 Balance bands

Initial tuning targets:

- Required story/invention spending uses roughly 35–50% of guaranteed chapter income.
- Reasonable store/consumable upgrades use another 20–35%.
- Median player retains a 15–25% emergency buffer.
- Higher-combat play creates broader build choice, not unlimited purchasing.

Ship gates:

- No negative inventory.
- No duplicated unique reward.
- No unrecoverable required-item spend.
- No required waiting or random drop.
- No Ducket softlock in simulated paths.
- At least two meaningful later-Armory purchases per chapter.

---

## 24. Facilities and jobs

### 24.1 Facility state

Every facility persists:

- Placement and visual state.
- Foundation/operational/upgraded stage.
- Staff member.
- Active and completed jobs.
- Direct-service state.
- Interior state.
- Story/universe link.
- Visitor schedule state.

Relocation remains cosmetic and cannot alter progression.

### 24.2 Worker quality

Current maximum-match logic collapses important choices. Add all relevant matches:

- Preferred specialty match: +2 each.
- Adjacent skill match: +1 each.
- Signature recruit/facility match: +1.
- Ben lead/assist and invention modifiers shown separately.

Map the total to:

- Routine.
- Competent.
- Skilled.
- Expert.
- Master.

Routine starts at zero and must be reachable.

Job preview shows:

- Inputs and whether they are reserved/consumed.
- Output range.
- Duration and exact estimated finish.
- Worker fit and each contributing skill.
- Quality tier.
- Ben effect.
- Invention effect.
- Cancellation/refund behavior.

### 24.3 Ben and offline time

- Only one Ben-led or Ben-assisted job globally.
- Ben cannot simultaneously adventure and physically assist unless a job explicitly supports remote oversight.
- Cancelling returns unconsumed inputs.
- Completed jobs remain collectible offline.
- Negative clock changes and implausible jumps are flagged/clamped without deleting legitimate progress.
- No main objective is “wait 15 minutes.”

### 24.4 Quality outcomes

Quality must alter:

- Duration.
- Base output.
- Bonus output table.
- XP.
- Optional field information or quest outcome where authored.

Specialist assists use calculated quality for route, dialogue, and reward differences. They do not all resolve to the same fixed cache.

### 24.5 Facility/job acceptance

- Double-Ben assignment is rejected.
- Two matching skills outperform one.
- All five quality tiers can occur.
- Offline completion and cancellation/refund are deterministic.
- Relocation with active worker/job preserves state.
- Operator absence never blocks an essential service.
- Upgrade, active job, placement, worker, and interior survive save migration.

---

## 25. Inventions

Split inventions into:

- `expedition_tool`
- `facility_upgrade`

### 25.1 Four-use expedition-tool contract

Every expedition tool needs:

1. Required or alternate story interaction.
2. Optional route, secret, or lore use.
3. Battle or expedition-preparation effect.
4. Visible town/facility use after stabilization.

Reusable world verbs:

- Clock/time tuning.
- Power routing.
- Translation/signals.
- Phase inversion.
- Thermal arbitration.
- Truth illumination.
- Gravity anchoring.

The UI should show a concise tool effect and compatible nearby interaction—not silently consume it as a key.

### 25.2 Facility-upgrade contract

Every facility upgrade needs:

- Unique service improvement.
- Job modifier.
- Visible prop or building-state change.
- Side-quest or field benefit.

### 25.3 Crafting rules

- Confirm and reserve required ingredients.
- Explain all currently available sources.
- Craft at physical Lab/facility benches except explicit portable recipes.
- Prevent duplicate ownership.
- Migrate current owned IDs into durable tool state.
- Validate that low-combat/no-job play can afford every required recipe.

---

## 26. Quests, objectives, recruitment, and narrative

### 26.1 Objective model

Replace linear polled step indices with objective trees:

```yaml
quest_id: moonpetal_false_vow
required:
  all:
    - event: evidence_acquired
      id: bell_inscription
    - any:
        - event: evidence_acquired
          id: mirror_reflection
        - event: specialist_result
          quality_at_least: skilled
optional:
  - event: evidence_acquired
    id: attendant_testimony
outcomes:
  true_vow:
    rewards: ...
  mistaken_vow:
    alternate_encounter: ...
```

Support conditions for:

- Location/area state.
- Evidence sets.
- Interaction state.
- Encounter result.
- Optional objective.
- Job or specialist quality.
- Facility upgrade.
- Inventory/counter.
- Player choice.

Events and rewards require unique transaction IDs. Reload or repeated synchronization cannot grant them twice.

### 26.2 Journal

Show:

- Current objective.
- Required and optional subobjectives.
- Relevant universe/facility.
- Map hint with selectable spoiler level.
- Why a step is blocked.
- Collected clues/evidence.
- Choice outcome after commitment.

Main quests have no hidden permanent deadlines or missables.

### 26.3 Per-universe narrative content floor

- Two noncombat optional objectives.
- One recruit/specialist payoff not based only on a combat trial.
- One choice changing route, dialogue, or reward without blocking the ending.
- Post-stabilization follow-up.
- Pre/post dialogue for anchor workers and town residents.
- At least one humor beat and one escalating-threat beat.

Recruitment may use rescue, negotiation, evidence, invention, favor/job, or battle. Do not force a character merely to open one cache. Required-party warnings appear before travel.

### 26.4 Campaign ending

Empyreal stabilization must lead to:

- Authored resolution scene.
- Town consequences and resident/recruit reactions.
- Credits.
- Post-ending save marker.
- Free-roam town state.
- Rematches and unfinished optional content.
- Clear indication of what changed and what remains.

---

## 27. Save, retry, defeat, and migration

### 27.1 Atomic repository

Save flow:

1. Serialize to a temporary file.
2. Flush and close.
3. Parse and validate the temporary file.
4. Rotate the previous valid file to `.bak`.
5. Replace the active file.
6. Update slot metadata only after success.

Never overwrite the last valid copy with corrupt data. Quarantine malformed files and offer backup recovery with a clear message.

Recommended slot structure:

- Three campaign slots plus autosave.
- Three named sandbox layouts.
- Campaign and sandbox physically and logically isolated.

### 27.2 Ordered migration

Implement `v18 → v19 → ...` functions with archived fixture saves.

New persisted data includes:

- Typed universe states.
- Objective trees/outcomes.
- Facility upgrades.
- Raptor policy/bond.
- Encounter bag and pressure.
- Visual/area transition IDs where needed.
- Settings and accessibility preferences in their appropriate repository.

Unknown IDs receive safe defaults or quarantine; they never crash or silently erase unrelated progress.

### 27.3 Save points and retry

- Saving remains restricted to town, activated save points, and authored events.
- No mid-battle save.
- Save point restores party, records exact area/spawn/local position/facing, and saves atomically.
- Retry loads the snapshot and rebuilds world state once.
- Town defeat revives every regular party member at exactly 1 HP, clears battle-only state, moves once, and cannot invoke victory/completion callbacks.
- Recall and defeat destinations are typed area/spawn IDs.

### 27.4 Save acceptance

Test:

- Malformed, truncated, empty, and forward-version saves.
- Interrupted temporary write.
- Backup recovery.
- Every archived version-18 fixture.
- Unknown content IDs.
- Retry in each universe.
- Save after every partial puzzle state.
- Duplicate reward prevention.
- Campaign/sandbox separation.
- Offline job time after backward and large-forward clock changes.

---

## 28. Sandbox completion

Use Godot `UndoRedo` command objects for:

- Place.
- Move.
- Delete.
- Rotate/flip where supported.
- Terrain paint/fill.
- Resident/activity placement.
- Batch selection changes.

Improvements:

- Undo/redo.
- Copy/paste and duplicate.
- Box select/move.
- Brush size and fill.
- Search, filters, favorites, pack, category, and footprint.
- Clear collision/footprint/door preview.
- Protected-anchor relocation within legal zones.
- Named layout slots with thumbnails.
- Import/export only after schema validation.
- Autosave after a committed command/debounce, not every cursor movement.

Validation before commit:

- Map bounds.
- Object collision.
- Lab/entry/spawn/portal/service-door access.
- Required road/path reachability.
- Resident navigation.
- Protected anchors cannot be deleted.

Invalid operations explain why and preserve the exact prior state.

Sandbox ship gate:

- A 100-action undo/redo round trip produces a byte-equivalent layout.
- Save/load preserves collision, rotation, order, and authored-object state.
- Required routes remain reachable.
- Malformed layout cannot overwrite a valid one.
- Sandbox never changes campaign story, rewards, or facility state.

---

## 29. UI, input, audio, and accessibility

### 29.1 UI

- Split large menu pages into focused controllers while preserving one shared visual/focus language.
- Add consistent selected, focused, disabled, unavailable, and destructive states.
- Every blocked action explains why.
- Provide readable comparison for equipment, job quality, facility staffing, invention recipes, and quest gates.
- Keep controller focus deterministic after list changes, purchases, equips, party swaps, and popups.
- Add capture/screenshot mode that hides HUD and dialogue.

### 29.2 Input

Test all gameplay with:

- Keyboard.
- Mouse click-to-move.
- D-pad.
- Analog stick.
- Modern Xbox-style controller.
- Modern PlayStation-style controller where available.

Add remapping, dead-zone settings, vibration toggle, and consistent cancel/confirm behavior.

### 29.3 Accessibility

- Text speed and optional instant text.
- UI/text scale presets.
- Active/Wait battle mode and battle speed.
- Reduce screen shake.
- Reduce flashes.
- Status and world-state cues using icon/text/shape, not color alone.
- Separate master, music, ambience, SFX, and UI volume.
- Pause exposure/oxygen/timed mechanics in menus and dialogue.
- Clear save slot, backup, corruption, and recovery messaging.

### 29.4 Audio

Each universe needs:

- Exploration theme/state variants or layered stems.
- Ambient loop.
- Signature mechanic sound.
- Safe/save-point cue.
- Boss phase telegraph.
- Stabilization cue.
- Town import/anchor ambience.

Mixing rules:

- Dialogue and important telegraphs duck ambience/music slightly.
- Repeated environmental loops randomize interval/variant.
- No important mechanic communicates through audio alone.
- Audio state changes with the same typed universe state as visuals.

---

## 30. Parallax and environmental-motion asset brief

### 30.1 Important dependency

Do not commission final-size parallax until the pixel-canvas decision in Milestone 0 is locked.

Preferred delivery basis:

- Physical/gameplay composition: **960 × 540**.
- Non-looping overscanned plate: **1152 × 648**.
- Seamless horizontal strip: **1920 × 540** where practical, providing two screen widths.
- RGBA PNG for every layer needing transparency.
- Opaque PNG is acceptable for the deepest sky.

If the project retains a 1920 × 1080 internal canvas, import these layers at exact 2× nearest-neighbor presentation or request exact doubled exports. Do not mix pixel density inside one set.

### 30.2 Standard layer package

| Suffix | Content | Typical camera ratio |
|---|---|---:|
| `_sky` | Gradient, deep sky, starfield, or static atmospheric field | 0.00 |
| `_far` | Mountains, skyline, treeline, distant architecture | 0.08–0.12 |
| `_mid` | Roofs, canopy, station structures, islands, traffic depth | 0.20–0.30 |
| `_near` | Branches, cables, signs, close cloud/fog banks | 0.45–0.60 |
| `_fg` | Optional close edge pieces that may cross in front | 0.80–0.90 |
| `_weather` | Rain, snow, petals, steam, smoke, motes, traffic | Screen-space or about 0.65 |

Final values must be pixel-snapped and adjusted per area. Fast foreground motion should remain subtle enough to avoid motion sickness.

### 30.3 Delivery rules

- Looping strips must match perfectly on left/right edges.
- State variants use identical dimensions, origin, horizon, and island/building geometry.
- Keep the center gameplay/battle zone lower contrast and less busy than frame edges.
- Do not bake playable floors, doors, puzzle clues, collision, signs the player must read, or interactable objects into parallax.
- Separate particles from scenery so density and accessibility can be adjusted.
- Provide at least 10% overscan for non-looping pans.
- Avoid gradients/dither patterns that reveal a seam.
- Keep source/editable files where possible and supply flattened PNG exports.
- Document intended loop axis, speed, opacity, blend mode, frame rate, and state suffix.
- Use integer frame/canvas coordinates; no half-pixel origin.

Suggested naming:

```text
<world>_<area-or-shared>_<state>_<layer>.png

asterion_shared_emergency_sky.png
asterion_shared_emergency_far.png
asterion_shared_emergency_mid.png
asterion_shared_emergency_near.png
asterion_shared_emergency_weather.png
```

### 30.4 Town and ordinary interiors

Do not apply full horizontal scrolling parallax to ordinary top-down town streets or compact interiors; it fights the projection.

Use:

- Masked window views.
- Moving cloud shadows.
- Weather particles.
- Foreground tree canopies and utility wires.
- Distant skyline visible only at map edges/overlooks.
- Chimney smoke and roof-level silhouettes.
- Chapter/state overlays.

Laboratory windows need a masked rift sky, slow cloud strip, occasional lightning frame, and state variants as the lab stabilizes.

### 30.5 Requested sets

| World | Layers to supply | Required variants and use |
|---|---|---|
| Town | Distant colonial skyline/fault shimmer; roof/chimney layer; smoke/cloud shadows; edge foliage/wires | Survey, founded, multiversal, finale; day/evening/night where supported |
| Mansion | Moonlit sky; storm clouds; dead treeline/roof silhouette; fence/graveyard; near branches; two fog strips | Haunted/dark and stabilized/warm-window; strongest use in forecourt and windows |
| Asterion | Starfield; nebula/planet limb; orbital structures; traffic/debris; hull/cable/steam foreground | Emergency red and restored cyan; Dock, Control windows, battle stage |
| Primeval | Sky haze; volcano ridge; jungle canopy; near ferns/vines; smoke and bird/insect silhouettes | Green daylight and orange ash/caldera; Grove edge, Ruins overlook, Caldera, battle |
| Helios | Noon/night sky; tower skyline; mid-rise buildings; two traffic strips; glass reflection/sign layer | Noon powered/dark, artificial midnight powered/dark, restored dusk |
| Frosthold | Polar sky; aurora; two mountain depths; castle silhouette; blowing snow; near ice/snow | Severe whiteout, normal cold, restored clear/warm |
| Moonpetal | Moon gradient; mountains; distant roofs; cherry canopy; near branch corners; petals; low mist | Official-memory muted and true-night/restored saturated |
| Empyreal | Deep sky; far thin clouds; mid cumulus; lower cloud sea; island silhouettes; near wisps; cloud shadows | Rigid/pre-stabilization and released/post-state; gravity particle directions |

### 30.6 Empyreal motion target

Starting physical-speed targets:

- Far thin clouds: approximately 2 pixels/second.
- Mid cumulus: approximately 4 pixels/second.
- Lower cloud sea: approximately 8 pixels/second.
- Near wisps: approximately 12 pixels/second.
- Banners and motes: local animation driven by gravity state.

The supplied Flying Islands pack can seed clouds, rocks, bridges, waterfalls, and island fragments, but all pieces still require the shared density, layer, and loop review.

### 30.7 Battle stages

Replace square top-down atlas crops with 16:9 side-view stages.

Each universe supplies:

- Far sky.
- Mid environment silhouette.
- Quiet combat floor with declared `battle_floor_y`.
- Foreground vignette/occluder.
- State variant tied to universe mechanic.

Battle-stage rules:

- Party and enemy feet share stable baselines.
- Central actor/VFX area stays readable.
- Foreground never covers command/status UI.
- Stage state may respond to boss/environment effects through generic layer toggles.
- No aspect-cover crop discards 40–44% of the source.

### 30.8 Parallax acceptance

- No seam is visible during a two-screen loop.
- No layer uses fractional final positions.
- State swaps preserve horizon and do not jump.
- Weather density obeys accessibility settings.
- Collision and required clues remain in world-space layers.
- Every set is reviewed at native gameplay scale and during camera movement.
- Parallax does not reduce route, actor, enemy, VFX, or UI readability.

### 30.9 Recommended supply order

Do not request all finished sets simultaneously.

1. **Mansion forecourt and Mansion battle stage:** validates exterior top-down framing, fog, foreground branches, state variants, and side-view battle composition.
2. **Asterion Dock/Control and battle stage:** validates viewport masking, stars, traffic, emissive powered/unpowered variants.
3. **Primeval Grove/Caldera and battle stage:** validates organic canopy, smoke, birds, foreground leaves, and two palettes.
4. **Helios shared skyline:** the most state-heavy set; requires day/night/powered/dark consistency.
5. **Frosthold Causeway and battle stage:** validates aurora, multi-depth mountains, snow, and visibility controls.
6. **Moonpetal Garden/Palace and battle stage:** validates reflections, petals, mist, and official/true-state alignment.
7. **Empyreal shared cloud/island set:** validates the final three-speed cloud architecture and gravity-state particles.
8. **Town chapter overlays:** author after universe sets so imported motifs can be reused consistently.

For each delivery, provide:

- A flattened composite preview.
- Individual named layers.
- A version with safe-area/grid overlay for review.
- State variants aligned on the same canvas.
- Loop/motion notes.
- Editable source where available.
- Confirmation of source pack/license and whether new pixels are original or derived.

---

## 31. Local telemetry and balance harness

Telemetry is debug-only/local by default. A release build keeps it off unless the player explicitly opts in. Do not collect network identity, raw input, or personally identifying information.

Recommended JSONL event fields:

- Build, save-schema, and content version.
- Random/anonymized session ID.
- Chapter, universe, area, and world state.
- Event ID and reason.
- Numeric/string values needed for analysis.

Record:

- Session, universe, room, and objective time.
- Puzzle attempts, hints, toggles, and final answer.
- Encounter pressure, Ward state, formation, repeat history, rare/event selection.
- Party composition, levels, equipment, rows, actions, targets, damage, healing, overheal, resistance, KO, revive, escape, result, and duration.
- Boss state, telegraph, counter used, and phase duration.
- XP, skill, equipment, and loadout changes.
- Every economy transaction.
- Job start, worker fit, quality, finish, cancel, and collection.
- Invention and facility-service use.
- Quest branch, optional objective, and reward transaction.
- Save, load, migration, recovery, and error.
- Sandbox invalid action, undo, and redo.

Reports per chapter:

- Play time and backtracking distance.
- Battles per traversal minute.
- Formation-repeat rate.
- Victory, escape, defeat, boss attempts, and battle duration.
- Action usage and party contribution.
- Item consumption and HP/MP entering bosses.
- Level and equipment distribution.
- Duckets earned, spent, held, and missed-treasure effect.
- Earliest/latest required-material acquisition.
- Job utilization.
- Puzzle solve time, hint usage, and hard stalls.
- Optional discovery rate.
- Save/load failures and recovery.

Initial tuning alarms, not automatic proof of fun:

- Normal encounter median: 45–90 seconds.
- Boss median: 4–8 minutes.
- First-attempt boss clear: approximately 45–70%.
- Meaningful direct-route encounter: every two to four traversal minutes.
- Puzzle median: 5–15 minutes.
- Hard stall after available hint: under 25%.
- Active/reserve level gap: two or less.
- Median Ducket buffer after required spend: 15–25%.

Automated balance runs:

- 100–500 seeded simulations per formation and representative party template.
- Main-path state-machine traversal.
- Low/median/high-combat economy.
- Minimum-resource and missed-treasure path.
- No-job path.
- Heavy-job/offline path.
- Save/reload fuzz fixtures.

---

## 32. Verification matrix

### 32.1 Automated

- Existing 46 smoke tests through isolated user data.
- Content/data validator.
- Atlas, pixel-density, animation, and visual-profile lint.
- Action/target matrix.
- Reward idempotence.
- Boss phase and telegraph transitions.
- Encounter-region and anti-repeat properties.
- Quest dependency/state graph.
- Economy and required-material simulations.
- Level/skill/reserve catch-up fixtures.
- Facility/job quality and offline timing.
- Save atomicity, backup, migration, and recovery.
- Sandbox undo/redo and reachability.
- Clean-project resource-load test.

### 32.2 Human playtests

- Internal mechanical sweep.
- At least three blind first-time chapter tests per universe before content lock.
- Full keyboard/mouse playthrough.
- Full modern-controller playthrough.
- Minimum-combat/no-job playthrough.
- Heavy-job/offline playthrough.
- Migrated-version-18 save playthrough.
- Save corruption/recovery exercise.
- Color-independent and reduced-motion comprehension pass.

### 32.3 Resolution/input matrix

At minimum test:

- 960 × 540 reference.
- 1280 × 720.
- 1920 × 1080.
- Windowed/fullscreen transitions.
- Letterbox/aspect handling on wider displays.
- Keyboard, mouse, D-pad, analog stick, controller hot-plug.

No menu, popup, portrait, status, or battle label may clip. Pixel art must remain integer-scaled or deliberately letterboxed.

### 32.4 Visual review

Every completed area requires:

- Clean capture without dialogue/HUD obstruction.
- Pre/post state capture.
- Collision/footprint debug capture.
- Actor/follower/NPC scale review.
- Tall-prop front/behind traversal.
- Door and transition traversal.
- Parallax-in-motion review.
- Battle-stage review if applicable.

Smoke tests alone cannot close a visual task.

---

## 33. Implementation roadmap

### Dependency flow

```mermaid
flowchart LR
    M0["M0: Baseline and design lock"] --> M1["M1: Stability foundation"]
    M1 --> V1["Visual asset and render foundation"]
    V1 --> M2["M2: Town/Lab/Mansion vertical slice"]
    M2 --> M3["M3: Shared campaign systems"]
    M3 --> M4A["M4A: Asterion + Primeval"]
    M4A --> M4B["M4B: Helios + Frosthold"]
    M4B --> M4C["M4C: Moonpetal + Empyreal + Ending"]
    M4C --> M5["M5: Town life, side content, sandbox"]
    M5 --> M6["M6: Balance, polish, release"]
```

### M0 — Baseline and design lock

Deliver:

- Git baseline and safe working-copy decision.
- Isolated test/capture wrapper.
- Archived version-18 fixture and 46-test baseline.
- Recorded fresh-save run and telemetry baseline.
- Pixel-canvas comparison and final decision.
- Final data contracts for actions, bosses, encounters, universes, quests, jobs, inventions, economy, and saves.
- Campaign duration/content budget.
- Supported resolutions/controllers and minimum hardware target.

Gate:

- No unresolved product choice that changes persistent schemas or final art dimensions.
- Production save remains unchanged by tests.

### M1 — Stability foundation

Deliver:

- Content validator.
- Explicit action relation/selector/effects.
- Correct hostile targeting and revive contract.
- Exactly-once battle result.
- One retry/return flow.
- Atomic SaveRepository, backup, migration chain, and settings repository.
- Fix Heavenly Aegis and all first-run element-availability errors.
- Resolve earlier victory fan-out, retry, and save-safety blockers.

Gate:

- Existing suite plus target, reward, retry, migration, corruption, and isolation tests pass.
- One victory grants one result, one transition, and at most one autosave.

### Visual foundation

Deliver:

- Godot output from existing curated asset pipeline.
- Runtime visual profiles.
- P0 crop repairs.
- Actor/NPC/boss/portrait normalization.
- Frame-count/facing corrections.
- Scale-1 prepared gameplay sprites.
- Layered world root, `WorldProp2D`, building contract, Y-sort, upper occluders.
- Pixel-stable camera and golden visual scenes.

Gate:

- 100% of currently referenced gameplay visuals have profiles.
- Zero known clipped/neighbor-bleeding P0 crops.
- Actor feet align to target.
- Representative trees, gates, furniture, buildings, and bridges pass front/behind tests.
- No visible single-pixel shimmer in one-tile movement captures.

### M2 — Town/Lab/Mansion proof of quality and fun

Deliver:

- Rebuilt town districts and construction states.
- Rebuilt laboratory zones.
- Relocation-safe buildings and one complete facility interior/upgrade.
- Mansion forecourt and enlarged authored rooms.
- Real clock/time mechanic.
- Shared EncounterDirector.
- Boss-policy engine.
- Quest objective tree.
- Reusable time invention.
- Reserve catch-up.
- Active/Wait.
- Mansion battle stage and parallax.
- Post-stabilization Mansion/town changes.

Gate:

- Opening through stabilized Mansion is a coherent 90–150 minute slice.
- Blind players understand and solve the core puzzle.
- Keyboard/mouse and controller both complete it.
- Every allowed save/reload boundary preserves state.
- Boss has three readable states and two viable counters.
- Art/collision/camera/parallax meet final standard.

### M3 — Shared campaign systems

Deliver:

- Skill/progression redesign.
- Equipment affinity, deterministic sidegrades, salvage, reforge, and loadouts.
- Economy ledger and simulations.
- Facility upgrades/services.
- Job quality and offline rules.
- Four-use inventions.
- Quest choices/reward variants.
- Real later-anchor selection.
- Town state-overlay system.
- Debug telemetry and balance reports.

Gate:

- No main-path timer/RNG dependency.
- Low/median/high-combat paths reach every gate.
- Reserve level spread and currency budgets meet targets.
- Building relocation never changes progression.
- Two discovered later universes can be valid choices where intended.

### M4A — Asterion and Primeval

Deliver final:

- Unique topology.
- Signature mechanic.
- Enlarged/layered rooms.
- Props, pre/post states, battle stages, parallax.
- Boss policies.
- Encounters, quests, specialists, secrets, town imports.

Gate:

- Power and herd states survive every save/reload combination.
- Blind comprehension test passes.
- World-global gate passes.

### M4B — Helios and Frosthold

Same deliverables and gates, plus:

- State lighting and thermal readability without color dependence.
- No required timing stealth.
- No exposure during menus/dialogue.
- No world-state collision stranding.

### M4C — Moonpetal, Empyreal, and ending

Same deliverables and gates, plus:

- Evidence state and gravity configuration recovery.
- Ending, credits, final save marker, post-ending town, free roam, and rematches.
- Ending/result transaction fires exactly once.

### M5 — Side content, town life, and sandbox

Deliver:

- Approved recruit arcs and noncombat alternatives.
- Post-stabilization quests and rare events.
- Remaining facility interiors/upgrades.
- Expanded resident schedules/dialogue/activity population.
- Sandbox undo/redo, copy, multiselect, search, filters, safe placement, slots.

Gate:

- Optional content cannot hard-lock the campaign.
- Residents path safely.
- Sandbox cannot delete/strand required anchors, spawns, or service doors.

### M6 — Balance, polish, and release

Deliver:

- Full campaign balance and duration pass.
- Accessibility/settings.
- Final UI, audio, visual, collision, and performance review.
- Resource-leak investigation.
- Export presets and clean release build.
- License inventory, credits, and attribution.
- Release checklist and archived gold saves.

Gate:

- All project-completion criteria below pass.

---

## 34. Content-duration budget

Do not reach the target through walking, encounter inflation, or idle waits.

Suggested meaningful-time budget:

| Content | Main-path target |
|---|---:|
| Opening, founding facilities, Fighter recruitment | 1.5–2 hours |
| Mansion vertical slice/chapter | 2–2.5 hours |
| Six later universes | 1.5–2 hours each |
| Town returns, facility use, recruit/story interludes | 3–4 hours distributed |
| Finale and epilogue | 1–1.5 hours |

This produces roughly 16.5–22 hours depending on play style. Optional recruit trials, secrets, rematches, facility arcs, sandbox, and completionist content may extend it, but total completionist time should remain under the 36-hour ceiling.

Meaningful time means new decision, story, mechanic, encounter composition, exploration discovery, or character/facility development.

---

## 35. Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| Big-bang rewrite of state/world code | Broad regression and stalled content | Strangler migration, public facades, parity tests, one vertical slice |
| Area-scene migration breaks old saves | Lost position/progression | Typed area/spawn migration, archived v18 fixtures, safe fallback spawn |
| More props reduce walkability | Collision frustration | Enlarge rooms first; density at edges; two-cell routes; traversal review |
| Mixed pack density persists | Incoherent pixel art and shimmer | Shared catalog, manifest density, derived normalization, blocking lint |
| New parallax is sized before canvas lock | Expensive redraw | M0 canvas decision before final delivery |
| Facility relocation breaks schedules/doors | Progress or NPC path failure | Socket-based facility contract and pre-commit reachability validation |
| Mechanics expansion exceeds content capacity | Unfinished campaign | Prove systems in Mansion; reuse generic effects/services; enforce content floor |
| Idle economy blocks story | Player softlock | Two immediate authored sources per required material; simulation gates |
| Optional recruit assets remain unsettled | Rework | Balance against role templates and bind only approved supplied assets |
| Tests overwrite live saves | Data loss | Isolated launcher, sentinel checksum, refusal guard |
| OneDrive locks/import churn | Corrupt or inconsistent worktree | Git, local active copy or exclusions, reproducible generated assets |
| Licensing/export discovered late | Release blocker | Inventory license/provenance in asset manifest from M0 onward |
| Smoke tests hide visual/playability defects | False completion | Automated + real traversal + capture + telemetry + save/reload sign-off |

---

## 36. Project definition of done

### Content

- Fresh New Adventure reaches an authored ending, credits, and post-ending free roam.
- Town, Lab, all seven worlds, facilities, inventions, approved recruit arcs, quests, and town transformations are complete.
- Timed median main path is approximately 20 meaningful hours.
- Completionist play remains no more than 36 hours.

### Reliability

- Zero known progression hardlocks.
- Zero invalid hostile targets.
- Zero duplicate reward/result transactions.
- Zero known save-loss cases.
- Recall, defeat, retry, migration, backup recovery, and partial puzzle loads are proven.
- No required timer, random drop, optional recruit, or job gate.

### Presentation

- Every room is reviewed at native gameplay scale.
- Zero known clipped or neighboring atlas contamination.
- Consistent density, pivots, scale classes, collisions, and occlusion.
- Every tall prop passes front/behind traversal.
- Every universe has pre/post state, battle stage, ambient motion, and town consequence.
- No important cue relies only on color or sound.

### UX and accessibility

- All menu/focus/controller paths pass at supported resolutions.
- Remappable controls, volume categories, text speed/scale, Active/Wait, battle speed, flash/shake reduction, and clear save recovery are available.
- Keyboard/mouse and modern-controller full playthroughs complete.

### QA

- Current and new automated suites pass from a clean checkout.
- At least two fresh-save end-to-end runs and one migrated-save run are archived.
- Every world-state configuration, party/staff combination, allowed anchor order, defeat, recall, and save boundary is tested.
- ObjectDB/resource warnings are fixed or documented with evidence of no growth over a multi-hour run.

### Performance and release

- Sustained target frame rate on declared minimum hardware.
- Stable memory over a multi-hour session.
- Bounded load/save times.
- Release export starts without editor, test, or MCP dependencies.
- No missing imports/resources.
- Complete licenses, credits, and third-party attribution.

### Sign-off rule

A task or level closes only after:

1. Automated gate.
2. Real traversal/playtest.
3. Native-scale visual capture.
4. Telemetry/balance review where applicable.
5. Save/reload verification.

A smoke-test pass alone is never sufficient.

---

## 37. First implementation batch

When implementation is authorized, the first batch should contain only:

1. Initialize Git and tag the baseline.
2. Add the isolated test/capture launcher and sentinel-save test.
3. Archive the version-18 fixture and current 46-test result.
4. Run the recorded fresh-save baseline.
5. Lock the 960 × 540 versus exact-2× 1920 × 1080 decision.
6. Add the shared visual-profile schema by extending the existing asset pipeline.
7. Repair the P0 crops and generate golden sprite/prop/building contact sheets.
8. Normalize Ben, residents, Caveman, Kitsune, Bulkhead Warden, Mossback, portraits, and Topdown Monsters frame counts.
9. Introduce the layered world root and one representative tree, gate, building, bridge, and interior-prop occlusion test.
10. Implement atomic save/backup and exactly-once battle results before rebuilding content.

Do not begin final parallax production or rebuild all seven universes during this batch.

---

## 38. Reference files

- `HANDOFF.md` — historical project handoff and non-negotiable design decisions.
- `ASSET_PIPELINE.md` — existing curated source-asset pipeline.
- `game/README.md` — current playable implementation summary.
- `game/project.godot` — display, input, import, and runtime configuration.
- `game/ben_rpg/core/campaign_state.gd` — current campaign-state monolith and save schema.
- `game/ben_rpg/world/campaign_bootstrap.gd` — current global world construction and room topology.
- `game/ben_rpg/world/campaign_map_visual.gd` — current raw atlas regions and procedural visual composition.
- `game/ben_rpg/world/sandbox_object_catalog.gd` — sandbox crops and scale.
- `game/ben_rpg/world/party_follower_train.gd` — follower positioning.
- `game/ben_rpg/world/town_resident_manager.gd` — resident profiles/schedules.
- `game/ben_rpg/world/town_resident_animation.gd` — current shared resident scale.
- `game/ben_rpg/combat/atb_battle_model.gd` — deterministic battle rules target.
- `game/ben_rpg/combat/campaign_battle.gd` — current battle controller/presentation.
- `game/ben_rpg/combat/campaign_combat_database.gd` — current combat definitions and backdrop regions.
- `game/tests/` — current smoke tests.
- `game/validation/` — visual capture scenes and images.

---

## 39. Audit evidence map

| Finding | Primary evidence |
|---|---|
| Mixed viewport/root/camera scaling | `game/project.godot:125-130`, `game/src/main.tscn:316-317`, `campaign_bootstrap.gd:718-731` |
| All universes share one hard-coded global coordinate field | `campaign_bootstrap.gd:3-150` |
| Later worlds repeat the same compact graph and narrow bands | Transition constants near `campaign_bootstrap.gd:41-146` and blocked-cell construction around `campaign_bootstrap.gd:1406` |
| Facility scales vary by raw pack rather than semantic size | `campaign_map_visual.gd:55-67` |
| Flat procedural visual composition and raw regions | `campaign_map_visual.gd`, especially the world-specific drawing sections |
| Primeval, Frosthold, Moonpetal, and Asterion crop defects | `campaign_map_visual.gd:633-893` and `campaign_map_visual.gd:1044-1060` |
| Sandbox crop defects | `sandbox_object_catalog.gd:28-101` |
| Follower baseline lacks per-actor foot compensation | `party_follower_train.gd:161-178` |
| All residents share one scale/offset | `town_resident_animation.gd:22-25` |
| Resident profiles lack visual scale/pivot metadata | `town_resident_manager.gd:8-49` |
| Battle backdrops aspect-cover square/top-down regions | `campaign_battle.gd:147-155` and backdrop definitions in `campaign_combat_database.gd` |
| All enemies fit one centered holder | `campaign_battle.gd:280-339` |
| Heavenly Aegis is an attack rally despite protective description/tree | `campaign_state.gd:407` and `campaign_combat_database.gd:154` |
| Topdown Monsters frame-count literals are duplicated/stale | Field animation scripts, `campaign_combat_database.gd:291-308`, `campaign_state.gd:820-877` |
| Encounter logic is duplicated by universe | `game/ben_rpg/world/*_encounter_controller.gd` |
| Jobs, inventions, skills, quests, recruit definitions, and economy share one monolith | `campaign_state.gd` |
| Existing source catalog can seed the Godot manifest | `ASSET_PIPELINE.md`, `asset-manifest.js`, `curated-asset-catalog.js`, and override/alias files |
| Current automated baseline | 46 `game/tests/*_smoke.tscn` scenes |
| Current visual evidence corpus | 340 images under `game/validation/` |
