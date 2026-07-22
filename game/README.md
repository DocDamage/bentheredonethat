# Franklin's Multiversal Township

A Godot 4.7 JRPG built from the GDQuest Open RPG starting template. Benjamin Franklin founds a town on an unstable multiversal fault line: ordinary town facilities support the settlement, while chosen buildings anchor complete universes containing exploration, puzzles, recruits, jobs, loot, and FFVI-inspired active-time battles.

## Current playable flow

- A real opening establishes Ben, his persistent velociraptor companion, his laboratory, and the empty town.
- Build the Cafe, Library, Clinic, and Armory; recruit the Fighter before dangerous encounters begin.
- Build the mandatory Haunted Mansion anchor and complete its five-room scenario.
- Discover and anchor Asterion Station, then Primeval Borough.
- Build the Afterlight Club and enter Helios Arcology: Skybridge, Market, Transit, Clinic, and Civic Core.
- Defeat the Civic Sun, stabilize the universe, and recruit Neon Viper permanently.
- Return to the stabilized transit platform for the hidden Undeliverable Parcel trial and recruit the Cobalt Courier.
- Build Cold Storage and enter Frosthold Kingdom: Snow Gate, Frozen Market, Crystal Causeway, Rune Hall, and Ice Throne.
- Invent the Thermal Arbitration Coil, repeal the kingdom's heat tax, defeat the Whiteout Auditor, and recruit the Frost Lich Emperor permanently.
- Build the Tea House and enter Moonpetal Court: Vermilion Gate, Blossom Court, Mirror Garden, Bell Walk, and Moon Palace.
- Invent the Electrostatic Veracity Lantern, expose the counterfeit memories, defeat Magistrate Enma, and recruit the Kitsune Empress permanently.
- Build the Belfry and enter Empyreal Court: Cloudstep Landing, Garden of Appeals, Forum of Measures, Reliquary Aerie, and Seraph Tribunal.
- Invent the Galvanic Counterweight, overturn heaven's gravity writ, defeat the High Comptroller of Gravity, and recruit the Archangel Commander permanently.
- Read the authored Empyreal epilogue and credits, then return to a free-roam New Philadelphia with a final save marker, resident reactions, unfinished optional content, and a no-reward Tribunal rematch.
- Return to town at will with Ben's invention except during authored lockouts.

The campaign supports a five-character party headed by Ben plus a separate autonomous, small-dog-sized raptor slot, speed-based ATB combat, formations, equipment, skill trees, elemental weaknesses, status effects, randomized loot modifiers and rarity tiers, EXP, duckets, save points, facility staffing, offline job progress, quests, and save migration through version 19. The fourth founding facility is a supplied-asset Armory with stock for all six equipment slots, later-universe stock unlocks, live comparisons against the selected character's equipped item, unique persistent purchases, protected equipped items, gear buyback, staffing discounts, and Armory assignments. Each of the seven authored universes now has a visible, reusable, pack-specific anchor that restores the party, records the retry location, persists its activation, and unlocks local party/formation management. Primeval, Helios, Frosthold, Moonpetal, and Empyreal also contain optional one-time treasure detours grounded on their local scenery; each awards Duckets, a field supply, and persistent universe-themed equipment with rolled rarity and modifiers. All fourteen currently playable combat actors use individual frames from their own supplied packs for idle motion, character-specific commands, hit reactions, victory, and defeat rather than static battle portraits.

Ben's four active hires now appear with him during exploration as a conventional JRPG follower train. Each recruit uses its authored directional field animation, retraces Ben's actual turns instead of cutting diagonally through scenery, updates immediately when the roster changes, and snaps safely after a universe transition or recall. Followers are presentation actors rather than pathfinding occupants, so they never block Ben, town residents, doors, click-to-move routes, or interactions. Ben can also use Tonics, Ether, and Phoenix Tonics from the supplied-asset field inventory, while the Cafe sells stackable Rift Wards that suppress random encounters for 40 dangerous steps without bypassing scripted battles.

Every authored combat species now feeds a persistent 38-entry Library bestiary. Starting an encounter records sightings; victory records defeat counts and observed drops. A supplied-asset, controller-ready BESTIARY page reveals each discovered monster's original artwork, universe, actions, statistics, elemental weaknesses/resistances, rewards, boss status, and recruitable status after it has been defeated. The Rift Jackal is the first true monster recruit: defeat its optional post-Mansion trial, hire it permanently, train its fixed tracking specialty, adventure with it, or staff it at a town facility. Stabilizing Asterion reveals the Bulkhead Warden and its Load-Bearing Interview; it becomes a durable engineering/security specialist, relocates peacefully beside the Armory after the trial, and can improve both Armory assignments and prices as staff. Primeval's Green Audit introduces the Mossback Surveyor, while stabilized Helios reveals the Cobalt Courier and its Undeliverable Parcel trial. These four pack recruits have fixed specialties, adjacent training, unique skill trees, character-restricted epic equipment, and permanent party/facility state.

## Controls

The field accepts keyboard, mouse click-to-move, and modern controllers. Menus and town-building flows expose controller navigation and direct keyboard shortcuts. The Franklin & Company OPTIONS page persists battle speed/mode, motion and flash reduction, text settings, audio levels, fullscreen, and controller preferences. The sandbox is a separate mode with terrain painting, pack filters and Ctrl+F text search, individual sprite/building pieces, authored-object relocation, 100-step undo/redo, copy/paste, Ctrl+click or middle-drag multiselect, batch move/flip/delete, and three validated layout slots (Ctrl+1–3 save; Shift+1–3 load). It rejects overlapping, out-of-bounds, altered-anchor, malformed, or route-stranding layouts before they can replace the active town.

Town residents follow role-driven daily schedules instead of roaming randomly. Mara, Elias, Ada, and Nell commute between valid town cells, rotate through job-specific work, take lunch, run errands, and return home. They reserve destinations to avoid crowding, yield and replan after repeated blockage, and describe their current work when spoken to. A compact activity plaque appears only when Ben approaches, keeping the wider map clear.

## Art construction rules

Source packs remain separated beneath `game_assets` by their original folder and pack. Runtime maps use explicit atlas regions rather than flattened sprite sheets. Complete authored rooms and coherent building islands are preferred; standalone props and signs are cropped on exact source boundaries. Presentation-sheet headings and catalog labels are never valid map art. New layouts use continuous ground planes, connected traversal paths, and complete scenery islands around those paths.

Empyreal Court uses individually cropped pieces under `game_assets/Tilesets/Ancient Greek Mythology/Sliced`, with its sky backdrop under `game_assets/Tilesets/Flying Islands/PNG/Sliced`. The Belfry is a composed facility facade rather than a scaled atlas sheet, and every Empyreal room uses a continuous walkable terrace with deliberately placed scenario props. `Topdown Monsters Part 1` remains intact as its own character pack; the Rift Jackal, Bulkhead Warden, Mossback Surveyor, and Cobalt Courier each have 144 exact 80×80 frames separated into 18 named animation folders beneath the pack's `Sliced` directory, so runtime scenes never display a full monster sheet.

The legacy layout-quality pass now gives Primeval distinct canopy, settlement, temple, nesting, and fire-shrine stages; gives Frosthold a gate approach, occupied market plaza, complete crystal bridge, rune nave, and throne approach; and adds aligned pressure hatches to Asterion. Boss actors are visible only inside their own stage so they cannot bleed into neighboring rooms. Navigation includes the painted bridge and aisle branches while retaining every scripted transition cell.

## Running

Open `project.godot` in Godot 4.7.1 and run the project. The bundled console executable can also launch it from this folder:

```powershell
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --path . --editor
```

## Verification

Automated scenes live in `tests`. The current suite contains 68 isolated smoke tests covering boot flow, movement, controllers, authored world collision footprints, collision-free field followers, town construction, conventional Armory buying/selling/comparisons, services, NPC routines, sandbox history/clipboard/box selection/batch move/search/validated layouts, all universe scenarios, the ending/postgame loop, quests, seven persistent save points, persistent exploration caches, roster management, jobs, encounter pressure, combat depth, save migration, persistent bestiary and monster recruitment, supplied character animation/UI/VFX/SFX, asset slicing, and a release-aware resource-load sweep.

Visual review scenes live in `validation`; they render town, field, and battle captures at the actual in-game scale so atlas bleed and bad proportions can be caught by inspection.

## Credits

The project began with [GDQuest's Godot Open RPG](https://github.com/gdquest-demos/godot-open-rpg). Third-party art, UI, VFX, and audio remain organized under their supplied pack folders; retain their original license files when distributing the game.
