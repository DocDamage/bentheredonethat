# Ben There, Done That

A browser-based, comedy slice-of-life proof of concept built around the supplied Ben Franklin, NPC, location, farm, music, and sound assets. Its expanded town now has fourteen destinations and a large rotating resident cast, and all 17 supplied Ben action sets are connected to travel, work, errands, rest, inventions, or special routines.

Ben's jobs grow out of things the historical Franklin actually did: printing and publishing, postal planning, civic organizing, diplomacy, electrical experiments, practical invention, almanac writing, stove design, and glass-armonica performance. The alternate-reality comedy stretches those skills into modern neighborhood problems without turning his days into unrelated odd jobs.

Every destination also has a replayable skill challenge using its own art: register the café printing press, wire a laboratory circuit, route a diplomatic supper, harvest by the almanac, organize carrier pigs, ground charged ghosts, or tune the glass armonica. Challenges work with keyboard, mouse/touch, and controller, and only consume a time slot when completed.

New Philadelphia is now a connected top-down overworld rather than a destination menu. Ben walks freely through its streets, paths, square, river crossings, and landscaped neighborhoods, then enters buildings by approaching their doors. Keyboard, touch, and controller movement share the same collision system; mouse or touch users can also click any walkable point and Ben will route around obstacles.

Residents follow job, home, errand, and social routines instead of roaming arbitrary paths. Their routes prefer roads, account for elevation and scenery, and replan or step aside when Ben or another resident blocks the way; hovering a resident shows their current purpose.

Each destination is also a continuous walkable micro-map built from the supplied art. The original café, laboratory, restaurant, farm, mansion, nightclub, and ranch are joined by the arcade, conservatory, sky house, guild hall, market, bathhouse, and clock station. Walking through a location changes the active scenery, resident, observations, and available work. Every area contains a free, one-time-per-timeline observation that connects the environment to Franklin's actual skills and can uncover odd keepsakes.

Franklin's 13 Virtues form the character-growth system. Every action, challenge, errand, nap, and observation practices a named Virtue. One rotates into focus each day; matching it earns bonus practice and extends Ben's focus streak. The full ledger is available in the notebook, and Virtue practice contributes to the Day 30 Civic Showcase without demanding a perfect schedule.

The first morning now acts as a short, skippable field guide. A live compass and clickable errand route lead from pickup to delivery, then get out of the way. Resident conversations advance three-step personal stories, and the arcade, conservatory, sky house, guild hall, market, bathhouse, and clock station each have their own actions, outcomes, rewards, and replayable challenge.

## Play

The simplest option is to open `index.html` in a modern browser. For more reliable audio and local asset loading, run a local server from this folder:

```powershell
python -m http.server 8080
```

Then open <http://localhost:8080>.

## Asset pipeline

All supplied art, character, music, and sound packs live beneath `assets/`, with each original pack and sub-pack preserved as its own folder. The editor hides that physical container and exposes the original hierarchy directly, so filtering still shows names such as `Cafe Assets / Patch 1`.

The editor lazy-loads `curated-asset-catalog.js` only when town or room editing is opened. The catalog is generated from the supplied art by a deterministic pipeline and currently covers all 6,765 browser-readable rasters, including 570 files safely unpacked from the five board-game archives. All 29 PSD/Aseprite masters are mapped to their supplied PNG/GIF equivalents, so none are silently omitted.

Rebuild and validate it with:

```powershell
python tools\build_curated_asset_catalog.py --extract-archives
python tools\validate_curated_asset_catalog.py --deep
node tools\validate_npc_asset_readiness.js
```

The pipeline reads exact Tiled/JSON metadata first, recognizes audited animation and RPG sheet layouts, preserves GIF timing, deduplicates identical files, and records compact atlas regions. A separate semantic gate verifies that all 51 runtime NPCs resolve to Ready standing, directional, or animated visuals. Preview art and uncertain/autotile material stay labeled as reference or review rather than being presented as safe cuts. Exact corrections and pack profiles live in `asset-pipeline-overrides.json`; editable-master mappings live in `asset-source-aliases.json`. See `ASSET_PIPELINE.md` for the full schema and CLI.

## Controls

- Keyboard: WASD or arrows walk in town and inside every destination. Approach a door and press E/Enter to enter; E observes inside; 1–4 performs the nearby actions. Shift slows Ben to a stroll. Space/Enter plays challenges; Escape closes; M toggles audio.
- Mouse/touch: click or tap walkable ground in town or indoors to move there, or select a building to route to its front door. Manual input cancels the route. Mobile also has persistent walking controls.
- Controller: modern standard-mapped Xbox, PlayStation, and Switch-style controllers are supported, with fallbacks for generic browser gamepads. D-pad or left stick explores, A/Cross confirms or routes to the selected building, X/Square observes, B/Circle closes, shoulder buttons change selection, and Menu opens help.
- Wayfinding: the objective compass follows the active errand. The two stops on the priority card are also buttons, so either destination can be marked manually.
- Notebook: resident cards begin with people Ben has met or who matter to the current errand. Search or choose **Everyone** for the full directory. Arrow keys, Home, and End move between notebook tabs.
- Town editor: choose **Edit Town** to drag every authored landmark, tree, nature prop, placed asset, and resident, or open Terrain Studio. The tools and build catalog begin collapsed and expand into docked edge panels so they do not cover the working map. NPCs support facing, collision, visibility, locking, static/face-player/wander behavior, dialogue, and persistent story progress. All terrain—including the authored river—can be painted, raised, lowered, smoothed, leveled, sampled, restored, or flood-filled. Maps—including scenery and placed NPCs—can be exported/imported as JSON, and Ctrl+Z/Ctrl+Y or the on-screen history buttons undo and redo changes.
- Room editor: choose **Edit Room** inside any destination to place interactive NPCs or assets, drag or nudge selections, resize props, change depth layers, toggle collision/visibility/locking, flip sprites, and undo or redo room-specific changes. The shared town/room build catalog stays docked on screen, preserves the original folder/pack hierarchy, can filter or sort by pack, and presents detected atlas regions and grid cells as individually cropped sprites instead of full sheets. It also includes search, visual categories, favorites, recent items, crop controls, and animation previews. Functional NPCs appear once with a south-facing preview while retaining every direction after placement.
- Found-a-Town mode: choose **Found Your Own Town** on the title screen to start with no buildings or residents. A deterministic seed controls clustered water, grass versus dirt, elevation, and tree density; destination buildings can then be placed or removed from the town editor.

Progress saves automatically in one of three browser-local slots. Expand **Save slots & backup** on the title screen to switch slots, export a complete JSON backup, import it later, or clear one slot. Backups include story progress plus town and room edits. A completed 30-day timeline rolls into another while preserving relationships, Virtue growth, inventions, cash, and inventory; location observations refresh for the new timeline.

## Checks

```powershell
npm run check
npm run validate:assets
```

`npm run check` verifies both JavaScript files and runs the dependency-free Node tests for destination outcomes, conversations, and waypoint selection. `npm run validate:assets` checks the full curated catalog and all runtime resident art.
