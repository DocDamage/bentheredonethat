# Ben There, Done That — Godot project

This is the primary game project. It is based on GDQuest's MIT-licensed
`godot-open-rpg` project at commit `19bd328fae9e4b534d3bb6db380a3d871d6ea58f`.

The upstream project supplies the field/gameboard, pathfinding, click movement,
keyboard and controller movement, dialogue, inventory, progression, transitions,
and turn-based combat architecture. Project-specific work lives under
`res://ben_rpg/` and source art remains grouped by its original pack under
`res://game_assets/`.

Open `project.godot` with the project-local Godot 4.7.1 executable. The bundled
Dialogic copy has a small 4.7.1 compatibility patch in four scripts; preserve
those changes when updating the upstream template.

## Current playable foundation

- Normal launch now opens a supplied-asset JRPG title screen with keyboard and
  controller focus. `New Adventure` resets campaign state and runs Ben's real
  laboratory opening; `Continue` displays and restores save location, play time,
  Duckets, company size, facilities, field position, and constructed world state.
- `Sandbox Workshop` is a separate non-story start in the empty town with Ben,
  Fighter, abundant Duckets/items, and every current laboratory invention. Its
  autosaves use `user://sandbox_slot.json`, so it cannot overwrite the campaign
  slot. `Quit Desktop` cleanly exits the application.
- Sandbox town editing stays on the map in a compact supplied-asset bottom rail
  instead of opening a map-covering window. The catalog currently exposes 35
  individually sliced objects grouped into Modern World, Ranch Stuff, Haunted
  Mansion, Modern Laboratory, and Sci-Fi Spaceship packs. Modern cottages and
  the town laboratory now use exact whole-sprite atlas cells at integer scale;
  the Sci-Fi pack adds 16 separately named props rather than exposing sheets.
  Keyboard, mouse, and controller users
  can filter packs, cycle exact sprite previews, place, select, move, flip, and
  remove objects; blocking footprints immediately rebuild navigation collision
  and every transform persists in the separate sandbox save. The authored town
  laboratory and trees are now instances in that same layer rather than painted
  scenery. The lab can be relocated but not destroyed, and its physical town
  doorway plus laboratory return destination follow its saved position.
- The same compact editor now has a terrain mode (`T` / controller `Select`).
  It exposes 20 individually sliced ground brushes while preserving the Ranch
  Stuff, Modern World, Haunted Mansion, Modern Laboratory, and Sci-Fi Spaceship
  pack filters.
  Click/confirm paints one cell, dragging paints continuously, and right-click/
  Delete restores the authored ground. Water and other blocking brushes update
  navigation immediately, while the editor rejects blocking paint beneath Ben,
  residents, facilities, transitions, or placed structures. Terrain overrides
  persist in the sandbox save alongside object and resident edits.
- Constructed town facilities now use exact, tightly cropped atlas cells and
  integer pixel scales. Per-building doorway anchors align the Café, Library,
  Clinic, Haunted Mansion, Observatory, and Trailhead Lodge art with their real
  interaction or transition cells. The town now uses native 48px grass,
  cobblestone roads, and stone entrance aprons from the same visual scale as its
  facades; the former flat orange road, mismatched 3x ground pixels, clipped
  school lawn, floating dish, and unseated building cutouts are gone.
- Universe destinations are now explicit persistent anchors rather than hidden
  side effects of facade names. The compact on-map construction rail shows the
  selected universe, its town shell, and its plot; up/down cycles every currently
  discovered unanchored destination as the catalog expands. The Haunted Mansion
  remains the sole mandatory first universe, while Asterion only becomes a
  selectable address after the Mansion's Anchor Core is recovered and Primeval
  Expanse appears only after Asterion is stabilized. Existing version-11 towns
  infer these bindings automatically when loaded.
- Side-view ATB battles now render the maximum company correctly: three front
  slots, two back slots, a dedicated autonomous velociraptor position, enemy
  formation space, and eight compact supplied-UI status rows. Recruit catalog
  entries resolve their own directional battle sprite, identity, optional base
  stats, and actions, so newly supplied recruit folders no longer become cloned
  Ben actors when added to the five-person party.
- The supplied Caveman, Crimson Oni, Kitsune Empress, Neon Viper, Archangel
  Commander, and Frost Lich Emperor packs are registered as distinct future
  recruits with eight-direction field art, bounded portrait crops, fixed
  specialties, adjacent work skills, four-node skill trees, individual stat
  growth, and signature battle commands backed by supplied VFX and SFX. They
  remain hidden in the story until their scenarios are authored, while Sandbox
  Workshop exposes all six as trained reserve characters for immediate testing.
- New Adventure now opens inside the visible laboratory rather than on an
  opaque text crawl. The supplied Dark RPG dialogue frame introduces the fault
  line, the building-as-universe premise, Ben's founding plan, and the first
  objective before handing over control in the same scene.
- The velociraptor is present from the first shot as a separate active field
  companion. It trails a full step behind Ben, circles around direction changes
  without crossing through him, and prowls with an independent run cycle while
  Ben is idle; it remains autonomous and slot-free in battle.
- JRPG grid movement through keyboard, click pathfinding, D-pad, and analog input.
- Physical laboratory door transition to the safe empty-town hub and back.
- In-map town construction mode (`B` / controller `Y`) for the founding Café,
  Library, and Clinic. Confirm with Enter/controller `A`; buildings update
  navigation collision as soon as they are placed.
- The founding plots now form a compact block around the central crossroads.
  Every town building uses one coherent source island and a fixed authored
  scale: the laboratory is the single warehouse crop, and the Haunted Mansion
  is one façade rather than several neighboring atlas buildings squeezed into
  the same footprint.
- The supplied Fighter appears purposefully at the Café after those facilities
  are complete and can be hired into Ben's persistent party/assignment state.
- The town now gains regular residents with fixed civic roles instead of
  aimless path loops. A café proprietor, librarian, grower, and clinic aide use
  the preserved Cozy Village NPC pack, follow a persistent morning/work/lunch/
  errand/evening/home schedule, route to the actual facility Ben built, reserve
  cells before moving, yield and replan around one another, and display their
  current activity. Sandbox editing pauses their routine and can select and
  persistently relocate each resident without allowing accidental deletion.
- The mandatory Haunted Mansion blueprint becomes the fourth build. Its cropped
  façade has a physical two-way door into a separately bounded foyer assembled
  from individual Haunted Mansion atlas regions. The room, spawn, collision,
  stopped clock, and exit now agree visually; no full sprite sheet is rendered.
  The room stays at the pack's native scale while a per-area camera zoom frames
  it, keeping Ben, ghosts, furniture, and collision in the same proportions.
- Field objectives, dialogue, construction prompts, company menus, combat
  panels, command icons, portrait rings, button states, status role icons, and
  ATB frames use the supplied Dark RPG GUI pack. Scalable controls use real HUD
  frame regions as nine-patches rather than stretching the pack's 26px empty
  inventory icon into generic-looking rectangles. The complete pack remains in
  its own folder rather than being flattened into miscellaneous UI.
- Fixed Mansion danger regions support one mandatory scripted encounter followed
  by conventional step-based random formations with a post-battle grace period.
- Every dangerous universe now reports its random-encounter pressure through a
  compact supplied-asset HUD gauge: calm, rising, and imminent states reflect
  the controller's real randomized threshold. The Café sells Rift Wards that
  suppress 40 dangerous steps (stacking to 120); their remaining duration is
  visible, persists through saves, and never cancels scripted or boss battles.
- Side-view active-time battles put enemies on the left and Ben's company on the
  right. Speed fills each visible ATB gauge independently. Ben uses support and
  invention commands, the Fighter uses martial skills, and the velociraptor acts
  autonomously without consuming one of the five party slots.
- Combat now includes conventional elemental weaknesses and resistances,
  critical hits, timed Poison/Slow/Shock ailments, visible status readouts,
  cleansing, MP recovery, KO-only revival, and context-sensitive item counts.
  Random encounters permit speed-based escape attempts while scripted and boss
  battles seal escape. Enemy AI targets vulnerable/readied party members and
  uses readable boss patterns; the velociraptor actively disrupts the enemy
  closest to taking a turn instead of choosing blindly.
- Attacks, lightning inventions, healing, revival, poison, spectral magic,
  support, and time magic play eight complete 30-frame animation families from
  the preserved `Alenia_VFX_Elements_Pack`, with matching supplied sounds from
  the separately preserved `RPG Sounds` pack. The two-column command grid and
  status display continue to use the Dark RPG GUI assets.
- Battles persist HP/MP, EXP, levels (cap 50), skill points, Duckets, consumables,
  rarity-tier gear drops, and randomized modifiers. Defeat offers the last save
  or a one-HP return to town; victory returns to the same field position.
- `Tab`, `I`, or controller `Start` opens the persistent Franklin & Company
  menu. It supports six equipment slots, supplied item/weapon icons, rarity and
  modifier details, equip/unequip operations, inventory ownership, character
  switching, and automatic keyboard/controller focus.
- The Inventory page is now a functional field-item menu rather than a read-only
  ledger. Portrait selection chooses the target; Tonics restore HP, Leyden Ether
  restores MP, Phoenix Tonic revives a knocked-out ally at 25 percent HP, and
  Rift Wards protect the full expedition. Buttons explain invalid targets and
  consume exactly one item while preserving the resulting vitals and ward time.
- Equipped modifiers now change the real ATB stats. Gear can grant battle
  commands (the Anchored Chronometer grants Borrowed Second), and each recruit
  has a fixed-specialty skill tree with prerequisites, passive bonuses, and
  learned actions. Skill trees reset freely only while the party is in Ben's lab.
- The Franklin & Company menu now includes town operations. `M` or controller
  `Select` opens it directly from town or the laboratory. A recruit can be in
  the adventuring party or staff one facility, never both; active work prevents
  pulling that recruit back into combat until it is collected or abandoned.
- Café, Library, and Clinic façades are now usable JRPG facilities rather than
  decorative construction rewards. Their authored doorway cells display small
  supplied-asset service markers and open a controller-ready service page. The
  Café sells combat supplies and buys only unequipped recovered gear; the Clinic
  revives and fully restores the active party before saving; the Library reports
  persistent quest/encounter/invention/recruit/universe records and archives a
  manual town save. Assigning a permanent recruit to that facility discounts
  direct services by 15 percent without interrupting offline assignments.
- Battles now populate a persistent 36-species Library bestiary. Encountering a
  formation records every visible species; victory adds defeat totals and actual
  observed spoils. The controller-ready BESTIARY page uses each monster's
  supplied artwork and reveals statistics, actions, elemental affinities,
  rewards, and boss classification after the first defeat.
- The “Open for Business” side quest teaches all three services in order and
  pays its rewards once. Purchases, gear sales, treatments, Library archives,
  staffing discounts, and quest progress all survive save/load.
- Café, Library, Clinic, and Haunted Mansion assignments continue from recorded
  timestamps while the game is closed. Fixed specialties shorten completion
  time and improve reward quality, while completed work grants Duckets, items,
  and EXP to the actual worker. Information-gated jobs stay hidden until the
  relevant Mansion discoveries are made.
- Ben can lead eligible menial/research jobs or assist a hired worker without
  leaving the playable party. His laboratory can build persistent facility
  inventions that speed work, improve quality, and unlock advanced assignments.
- Hired specialties now matter during exploration as well as facility work.
  Six authored universe fixtures query only the active party, recognize both
  signature recruits and compatible fixed/adjacent skills, and grant visible
  one-time shortcuts or recovery caches. Ben's invention remains the safe main
  route; missed assists can be claimed by revisiting with a later recruit. The
  Astronaut alone can open Asterion's optional customs cache, while cross-role
  combinations such as Mossback surveying Primeval infrastructure also work.
  Reserve and staffed characters do not silently solve field tasks, and every
  assist ledger entry and reward survives save/load.
- The campaign now has a persistent quest model instead of HUD-only objective
  strings. The opening, town founding, first hire, first anchor, foyer battle,
  4:44 clue chain, archive save point, and Clock Mirror victory advance real
  ordered quest steps and pay one-time Ducket/item rewards.
- `J` opens the supplied-asset Quest Journal directly; controller users reach it
  through the Start menu. Main, side, completed, and discovered hidden quests
  show their giver, story description, checklist, progress, and rewards. Any
  active quest can be tracked onto the field HUD.
- Town foundations reveal a staffing side quest. The hidden “Echoes on Paper”
  quest remains absent until the household ledger exposes the relevant Mansion
  information, then connects Ben's Cataloging Engine to Library idle work.
- `R` opens the controller-navigable Roster page. Ben remains fixed in the leader
  slot, four hires can fill the remaining active slots, and the autonomous
  velociraptor consumes no party capacity. Recruits can be ordered, moved to
  reserve, recalled from idle duty, or placed in front/back rows from town, the
  laboratory, and activated save points.
- Formation now affects the real ATB model and battle presentation. Front-row
  characters deal and receive full physical damage; back-row characters deal
  and receive 25 percent less physical damage while magic/support stay intact.
  Battles visibly arrange the company in separate front/back columns.
- Scenario party restrictions are enforced at both the roster and world levels.
  Fighter cannot leave the party after the Haunted Mansion scenario begins, and
  the Mansion doorway returns an invalid party to town with a clear explanation.
- The first Mansion room now has a JRPG clue chain: inspect its impossible clock,
  find the 4:44 ledger entry in the bookcase, then return for a rare House-Key
  Fragment, an Anchor Shard, and Duckets.
- Solving 4:44 now opens a five-room first-universe chapter: foyer, servants'
  archive, portrait gallery, nursery, and final ballroom. Each is a separate
  native-scale stage with room-specific camera limits, authored walkable floors,
  impassable inter-room void, and two-way doors that work with directional,
  controller, and click-to-move navigation.
- The archive clock is a real save point that restores the full party. Scripted
  gallery and nursery ambushes introduce supplied portrait and doll monsters;
  their investigations recover the Silver Hour Hand and Brass Minute Hand.
  Both hands unlock the ballroom's 4:44 appointment, while optional caches grant
  supplies, Duckets, and a fixed rare accessory exactly once.
- The ballroom's visible Haunted Clock Mirror begins the scripted ATB boss fight.
  Room-specific random formations use the gallery, doll, book, ghost, and clock
  enemies. Victory grants an Epic Anchored Chronometer, a Multiversal Anchor
  Core, and marks the first universe stabilized.
- Stabilizing the first universe now starts the main quest “A Portable Way Home.”
  In Ben's laboratory, the unique Anchor Core can be installed in a persistent
  Continuity Kite from the Haunted Mansion facility page. The normal campaign
  menu gains a supplied-asset RECALL page, opened directly with `K` or controller
  L3, which returns the active party from an unrestricted universe to New
  Philadelphia without restoring HP or MP. Scenarios can temporarily suppress
  recall with an authored explanation; successful arrival records usage,
  advances the quest, and autosaves in town.
- The Mansion victory also reveals the second buildable anchor. A fifth town
  plot accepts an Observatory built from one coherent Modern World industrial
  facade and one whole supplied satellite-dish island, both kept on exact sprite
  bounds instead of tiling interior wall fragments into an exterior box. Its
  doorway anchors Asterion Station while the town side remains an ordinary
  staffable facility.
- Asterion is a five-stage conventional JRPG scenario: Docking, Mess/Cargo,
  Hydroponics, Medical, and Station Control. Each room now uses measured whole
  prop islands at native resolution, renders only the occupied stage, and frames
  the complete 8x8 room at 1.25x. Mission fixtures occupy the blocked back-wall
  interaction rows while the four-row player floor stays clear. An organic
  biocircuit puzzle gates the oxygen loop and the Control route. Scripted and
  random ATB encounters use the supplied 30-monster sci-fi pack, culminating in
  the Mother Computer boss and an Epic Asterion Ion Pistol drop.
- The supplied 64px Astronaut has directional field animation, a battle actor,
  stats, equipment, skill-tree actions, formation support, and a scenario-backed
  permanent recruitment. After the final shift, the player can adventure with
  the Astronaut, keep them in reserve, or staff the Observatory for navigation
  and research work.
- A sixth construction plot now accepts the Trailhead Lodge, a whole Stone Age
  hut island rendered at exact 2x scale. Its physical doorway anchors Primeval
  Expanse while the town-side Lodge remains a normal staffable facility with
  foraging and fossil-survey assignments.
- Primeval Expanse is a five-stage field scenario: Grove, Borough, Jungle Ruins,
  Relay Nest, and Caldera. Every room uses a complete authored 384px landscape
  instead of repeating arbitrary tile fragments. Trees, traffic signals, huts,
  ruins, nests, and altar pieces are measured individual atlas islands; the
  Jurassic pack is reduced by an exact half-scale with nearest filtering, and
  navigation opens only the visible trails rather than decorative scenery.
- Ben must survive the Grove, meet the Caveman municipal maintainer, interpret a
  stone traffic signal, invent the Paleo-Linguistic Telegraph in his laboratory,
  decode the cave computer, defend and reset the Relay Nest, then defeat the
  Tyrant of the Morning Commute. The two information gates update collision and
  two-way transitions immediately and the Relay Nest doubles as a full restore
  and save point.
- Primeval random, scripted, and boss encounters crop individual raptors,
  triceratops, spinosaurs, and the tyrannosaur from the supplied dinosaur atlas;
  no battle displays the full sheet. Victories award conventional EXP and
  Duckets, rarity-tier gear with randomized modifiers, and an Epic
  Meteor-Tempered Mammoth Club from the boss.
- The supplied Caveman now has directional idle/run field animation, fixed
  survival and brute-force specialties, ATB stats and commands, formation and
  equipment support, a skill tree, permanent post-scenario recruitment, and the
  choice between active adventuring, reserve, or staffing the Trailhead Lodge.
- Versioned campaign saves preserve Duckets, construction, story flags, bestiary
  sightings, defeat counts, observed drops, roster
  status, five-person party membership, character progression, loot, inventory,
  staffing, active offline jobs, completed-job counts, inventions, quest steps,
  one-time quest rewards, tracked objectives, party order, formation rows, play
  time, town clock, resident positions/activities, save timestamp, last field
  cell, named location, and sandbox terrain overrides. Version-1 through
  version-19 saves remain loadable, and archived version-18 saves migrate through
  the explicit v18-to-v19 boundary when next saved.
- Per-area camera limits keep the laboratory and town framed without showing
  another area or large editor windows.

## Godot MCP X

The exact `kobolingfeng/godot-mcp-x` addon is installed and enabled. The local
server was built with Node and is registered at the workspace root in
`.mcp.json`. It provides live Godot 4.7.1 scene inspection, runtime screenshots,
input, assertions, editor errors, and hot reload.

## Smoke tests

There are 67 isolated smoke scenes. Run these with the bundled console
executable from this directory:

```powershell
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/field_input_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/anchor_recall_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/boot_flow_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/town_build_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/town_services_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/campaign_state_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/haunted_mansion_anchor_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/atb_battle_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/jrpg_combat_depth_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/campaign_battle_ui_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/campaign_menu_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/facility_jobs_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/facility_menu_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/quest_progression_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/quest_journal_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/roster_formation_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/roster_menu_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/mansion_encounter_integration_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/mansion_puzzle_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/mansion_scenario_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/asterion_scenario_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/primeval_scenario_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/field_specialist_assist_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/field_inventory_encounter_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/sandbox_editor_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/town_resident_smoke.tscn'
& '..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . 'res://tests/sandbox_terrain_smoke.tscn'
```
