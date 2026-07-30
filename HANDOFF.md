# Franklin's Multiversal Township — Project Handoff

**Handoff date:** July 21, 2026  
**Workspace:** `C:\Users\dferr\OneDrive\Desktop\5.6 one prompt game`  
**Godot project:** `C:\Users\dferr\OneDrive\Desktop\5.6 one prompt game\game`  
**Engine:** bundled Godot 4.7.1  
**Current task state:** paused; the broad implementation goal is **not complete**.

## What this game is

Benjamin Franklin is founding New Philadelphia on an unstable multiversal fault line. The town begins largely empty. Ben constructs ordinary civic facilities as well as special anchor buildings; the interior of each anchor is a complete alternate universe with its own art pack, characters, monsters, missions, puzzles, loot, and story. The town is the safe hub. Ben's laboratory is invariant and can be reached from every universe.

The intended game is a conventional, mostly linear JRPG rather than a point-and-click adventure. It also retains a separate sandbox mode for building and editing the town.

## Non-negotiable design decisions

- Battles use a side-view Final Fantasy VI-style presentation: enemies on the left, party on the right, animated actors, command menus, and speed-based active-time gauges.
- Ben is playable but primarily supports the people he hires. The combat party is Ben plus up to four hires. His velociraptor is a separate autonomous companion, does not occupy a party slot, is present from the beginning, and is approximately small-dog-sized.
- Recruits usually join permanently; some may be temporary. Each has a fixed specialty and can train adjacent skills. A recruit can either adventure or staff a facility.
- Ben can assist some work and must invent solutions for certain jobs and scenario gates.
- Jobs and facility work continue over real time like an idle game. Specialty affects completion time and reward quality.
- Combat includes random encounters in fixed dangerous regions plus scripted encounters, bosses, EXP, Duckets, levels, six equipment slots, weapons, skill trees, equipment-granted abilities, items, drops, rarity tiers, randomized modifiers, elements, status effects, buffs, debuffs, and formations.
- The party loses only when all five regular party members are knocked out. Revived allies return with 1 HP. Defeat offers the last save point or town.
- Save points restore the party. Saving is permitted in town, at save points, and at authored events.
- A recall invention returns the party to town except during explicit scenario lockouts.
- The Haunted Mansion is the mandatory first universe. Ben starts with its blueprint and resources after establishing the founding facilities and recruiting the first permanent fighter.
- Ben chooses which universe a later anchor building connects to, subject to story discovery and progression.
- The town side of an anchor remains an ordinary usable facility.
- Town buildings may be freely relocated. They are not destroyed and relocation has no story penalty.
- Assets must remain separated by their original folder/pack. Atlas regions must be sliced on exact sprite boundaries. The editor catalog must display individual sprites and support sorting/filtering by pack; it must never present entire sprite sheets as placeable objects.
- Keyboard, click-to-move, D-pad, analog stick, and modern controllers must all work.
- Town editing must remain compact and not obscure the map. Authored and player-placed objects should be selectable and movable in sandbox mode.
- NPCs need purposeful schedules, valid paths, reservations, collision avoidance, and roles—not random roaming.
- New universes should become threatening while preserving the game's humor.
- Do not invent the definitive recruitable cast. The user is continuing to supply character assets. `Topdown Monsters Part 1` may provide additional monster recruits.
- Target campaign scope was initially about 20 hours, expandable toward a 36-hour cap. That duration has **not been demonstrated**.

## Current playable implementation

The main project README currently describes this playable path:

1. Opening in Ben's laboratory with the velociraptor already present.
2. Enter the initially sparse town.
3. Build the Cafe, Library, Clinic, and Armory.
4. Recruit the Fighter before dangerous encounters start.
5. Build and complete the five-room Haunted Mansion scenario.
6. Discover/build Asterion Station and Primeval Borough.
7. Build the Afterlight Club and complete Helios Arcology.
8. Build Cold Storage and complete Frosthold Kingdom.
9. Build the Tea House and complete Moonpetal Court.
10. Build the Belfry and complete Empyreal Court.

Implemented systems include:

- Five-person company headed by Ben plus the autonomous raptor.
- Side-view ATB combat, formations, character commands, elemental/status mechanics, EXP, Duckets, equipment, skill trees, field items, randomized rarity/modifier loot, defeat recovery, VFX, and SFX.
- Controller-ready company, inventory, equipment, skills, roster, formation, quest, bestiary, facility, construction, and service interfaces using supplied UI assets.
- Physical field movement using keyboard, controller, and mouse click-to-move.
- Follower train for active hires; followers replay Ben's path without becoming blocking pathfinding occupants.
- Town facilities, staffing, idle/offline jobs, specialist assists, facility inventions, shops/services, quests, save points, encounter pressure, Rift Wards, and recall.
- Purposeful resident routines for Mara, Elias, Ada, and Nell with schedules, destination reservations, yielding, and replanning.
- A separate sandbox save with compact object/terrain editing, authored-object relocation, blocking-footprint rebuilding, individual asset entries, and pack filters.
- Seven authored universes/scenarios currently represented in the project: Haunted Mansion, Asterion, Primeval, Helios, Frosthold, Moonpetal, and Empyreal.
- Four recruitable creatures from `Topdown Monsters Part 1`: Rift Jackal, Bulkhead Warden, Mossback Surveyor, and Cobalt Courier, in addition to story recruits already wired into scenarios.
- A persistent 38-entry bestiary.
- Save migration through version 18.

## Most recent work

The last work focused on the user's complaints about bad proportions, overlapping atlas cuts, sloppy layouts, and incorrect collision.

### Visual/layout corrections

- Replaced laboratory atlas strips with exact individual props and opened the center aisle.
- Rebuilt Haunted Mansion foyer, archive, gallery, ballroom, and nursery details to remove presentation-sheet fragments, duplicate crops, overlaps, and bad floor repetition.
- Cleaned Asterion room layouts and removed portholes that intersected the command bank.
- Corrected Frosthold's 4× pixel-density mismatch, diversified snow ground, cleaned lanes, improved the bridge/rune landing, and rescaled the boss.
- Reworked Moonpetal's main path into a continuous processional route and moved lanterns, trees, gardens, and bosses away from traversal lanes.
- Moved Primeval scenery out of the walkable band.
- Restricted Helios treasure visuals and all boss markers to their actual rooms so they do not bleed into adjacent stages.
- Kept the velociraptor at the requested small-dog scale.

### Collision corrections

- Laboratory machinery blocks its full visible footprint.
- The town laboratory roof and four authored trees block movement in campaign mode.
- Sandbox mode does not inherit ghost collision from authored town locations; relocated objects rebuild collision from their own catalog footprints.
- Dynamic facilities block their plots except at aligned doors.
- Frosthold, Moonpetal, and Empyreal scenario props and bosses now have explicit blocked cells while their intended approaches remain open.
- A dedicated collision smoke test checks representative blocked and clear cells.

Key files from this pass:

- `game/ben_rpg/world/campaign_map_visual.gd`
- `game/ben_rpg/world/campaign_bootstrap.gd`
- `game/ben_rpg/world/universe_treasure_interaction.gd`
- `game/validation/lab_visual_capture.gd`
- `game/tests/universe_treasure_smoke.gd`
- `game/tests/world_collision_footprints_smoke.gd`
- `game/tests/world_collision_footprints_smoke.tscn`
- `game/README.md`

## Verification status

The last recorded full headless run passed all **46/46 smoke tests** in approximately 158.5 seconds.

Important explicit passes included:

```text
FIELD_INPUT_SMOKE_OK click=(11, 9) controller=(10, 9) lab_to_town=(50, 8) town_to_lab=(10, 9)
WORLD_COLLISION_FOOTPRINTS_SMOKE_OK lab=full_machines town=roof+trees universes=props+bosses approaches=clear
FULL_SMOKE_SUITE_OK 46/46
```

The suite covers boot flow, field input, town construction/services/residents, sandbox object and terrain editing, combat, recruitment, roster/formations, jobs, quests, encounter pressure, all seven universe scenarios, save points, treasure caches, bestiary, supplied animations/UI/VFX/SFX, asset slicing, and authored collision footprints.

Visual captures are under `game/validation`. Recent inspection targets include:

- `laboratory-layout-rebuilt.png`
- `mansion-foyer-layout-pass.png`
- `mansion-nursery-layout-pass.png`
- `frosthold-snow-gate.png`
- `frosthold-frozen-market.png`
- `frosthold-rune-hall.png`
- `frosthold-ice-throne.png`
- `moonpetal-vermilion-gate.png`
- `moonpetal-blossom-court.png`
- `moonpetal-mirror-garden.png`
- `moonpetal-bell-walk.png`
- `moonpetal-moon-palace.png`

Godot still prints shutdown-only ObjectDB/resource leak warnings when some test/capture scenes exit. Functional runs return exit code 0, but the leak warnings have not been audited to root cause.

## Honest gaps and risks

1. **The full campaign goal is unfinished.** Seven five-room scenarios and many systems exist, but there is no evidence that this is a polished 20-hour campaign, much less the later 36-hour ceiling.
2. **Passing smoke tests is not a substitute for a human end-to-end playthrough.** A fresh-save campaign run has not been timed and audited for pacing, dead ends, balance, controller focus, save recovery, or narrative coherence.
3. **Depth sorting remains the biggest technical/art risk.** Recent changes align many collision footprints with visible props, but much of the world is drawn procedurally in `CampaignMapVisual`. This is not equivalent to a robust layered tilemap/Y-sorted prop architecture. The user's complaint about being able to walk “on” objects when Ben should pass behind them may still require real foreground/background occlusion zones or split sprites, not just blocked cells.
4. **Level art must be judged visually, not from code or tests.** The user has repeatedly rejected scenes with poor proportions, overlaps, sloppy prop placement, and invalid atlas cuts. Every new or modified room must be captured at actual gameplay scale and inspected before it is called finished.
5. **The supplied UI is integrated, but consistency needs a real playthrough audit.** Check every popup, focus state, tooltip, service, combat menu, editor rail, and resolution—not only representative smoke scenes.
6. **The definitive recruitable cast is pending user-supplied assets.** Preserve existing data-driven hooks, but do not fabricate final characters.
7. **The older `game/README_BEN_THERE_DONE_THAT.md` is a useful implementation log but is stale.** It reports 39 tests and earlier bestiary/content counts. Treat `game/README.md`, the test directory, and runtime state as newer authority.
8. **Godot MCP X is installed in `game/addons/godot_mcp_x`, but no callable MCP tool was exposed in the last Codex tool context.** The work used the bundled Godot CLI and validation capture scenes instead.

## Recommended next work, in order

1. Run a completely fresh New Adventure from title to the current ending using controller and keyboard/mouse. Record play time, every blocker, visual defect, focus trap, wrong collision, and unclear objective.
2. Build a campaign progression audit/state-machine test that proves opening → founding facilities → first Fighter → Haunted Mansion → Asterion → Primeval → Helios → Frosthold → Moonpetal → Empyreal, including recall, defeat, save reload, and recovery from every gate.
3. Replace the flattened collision/visual assumptions with an explicit field-rendering model:
   - ground layer;
   - lower prop/collision footprint;
   - actor Y-sort region;
   - upper/foreground occluder;
   - interaction anchor;
   - navigation footprint.
   Large props such as trees, buildings, shelves, counters, beds, pillars, and machines should be split when Ben can logically pass behind their upper portion.
4. Audit every authored map cell-by-cell against the source pack at native scale. Reject any crop that crosses atlas cell boundaries, includes neighboring pixels, contains a sheet label, or mixes incompatible source scales.
5. Expand story, dialogue, quests, dungeon structure, encounters, enemy behavior, jobs, cutscenes, puzzles, and optional discoveries until an actual timed playthrough reaches the requested campaign length.
6. Integrate newly supplied recruits only after their folders are stable; give each exact directional field frames, battle states, portrait crops, stats, specialty, adjacent skills, skill tree, equipment affinity, recruitment mission, and facility role.
7. Diagnose the ObjectDB/resource leak warnings after higher-impact gameplay and presentation defects are resolved.

## How to run

From `C:\Users\dferr\OneDrive\Desktop\5.6 one prompt game\game`:

```powershell
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --path . --editor
```

Run every smoke scene:

```powershell
$godotExe = '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe'
$testScenes = Get-ChildItem tests -Filter *_smoke.tscn | Sort-Object Name
foreach ($testScene in $testScenes) {
    $scenePath = 'res://tests/' + $testScene.Name
    & $godotExe --headless --path . --audio-driver Dummy --scene $scenePath
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Run a visual capture, for example:

```powershell
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --path . --rendering-method gl_compatibility --audio-driver Dummy --scene res://validation/moonpetal_visual_capture.tscn
```

## Primary orientation files

- `game/README.md` — newest concise implementation summary and run instructions.
- `game/README_BEN_THERE_DONE_THAT.md` — detailed historical implementation log; useful but partially stale.
- `game/project.godot` — project entry/configuration.
- `game/ben_rpg/` — project-specific gameplay, world, UI, campaign, combat, and data code.
- `game/game_assets/` — runtime assets preserved by original source pack.
- `game/tests/` — headless smoke coverage.
- `game/validation/` — capture scenes and rendered visual evidence.
- `assets/` — original user-supplied asset library outside the Godot import tree.

## Standard for the next agent

Do not claim a level, collision pass, or UI pass is finished solely because it compiles or a smoke test passes. Launch it, capture it at real gameplay scale, inspect the crop boundaries and proportions, traverse every side of major props, and confirm the intended foreground/background relationship. Preserve the user's pack organization and build the JRPG—not a point-and-click prototype.
