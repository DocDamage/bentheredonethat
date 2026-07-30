# Complete Stage Asset Audit

Audit date: 2026-07-23

This report inventories the environment/stage libraries in the workspace and distinguishes source assets from assets that are actually used by the Godot game.

## Summary

| Library/state | Count | Meaning |
|---|---:|---|
| Canonical source packs in `assets/Tilesets` | 149 packs | Main stage/environment source library |
| Runtime-admitted packs in `game/game_assets/Tilesets` | 20 packs | Packs currently copied into the Godot runtime tree |
| Runtime packs with at least one approved visual profile | 14 packs | Packs actually referenced by game presentation data |
| Runtime-admitted but completely unwired | 6 packs | Copied during the interrupted pass; not yet playable |
| Canonical packs still absent from runtime | 129 packs | The full canonical set missed by the previous implementation |
| Mirrored packs in `assets/EXPANSION/stages` | 31 packs | Same names, image counts, and image byte totals as their canonical copies |
| HoriHori background images | 704 images | Additional stage/background candidates across five packs |
| HoriHori layered `Back` variants | 39 images | Twelve three-layer variants plus shared material |
| SakPix expansion environment packs | 5 packs / 99 images | Additional unique stage packs |
| RPG Maker TilesetAssembly sheets | 197 images | Additional stage assembly source sheets |

Before the interrupted pass, the runtime tree contained the same 14 profiled packs listed below. Six source sheets were then copied into six new runtime folders, but no visual profiles or playable stages were completed. Those six are therefore **not counted as implemented stages**.

## Runtime packs with approved profile references

1. `Ancient Greek Mythology` — Empyreal Court architecture and battle stages.
2. `Bright Cyberpunk Pixel Art Tileset Pack` — Helios Arcology architecture and battle stages.
3. `Dark RPG GUI Kit - Pixel Art Asset Pack` — treasure-chest art only; not a stage.
4. `Flying Islands` — Empyreal sky overlay only.
5. `Frozen kingdom` — Frosthold architecture and battle stage.
6. `Haunted Mansion Pixel Art Tileset Pack` — Mansion rooms, props, and battle stages.
7. `Jurassic world` — Primeval set dressing and battle actors.
8. `Modern Bar & Nightclub Pixel Art Tileset Pack` — Afterlight sign only.
9. `Modern Laboratory Pixel Art Tileset Pack` — Franklin laboratory and sandbox pieces.
10. `Modern World Overworld Pixel Tileset` — New Philadelphia town and sandbox pieces.
11. `Ranch Stuff` — town and sandbox terrain/props.
12. `Sakura Temple Asset Pack` — Moonpetal Court architecture and battle stages.
13. `Sci-Fi Spaceship Interior Tileset Pack` — Asterion Station rooms and battle stages.
14. `Stone Age Modern Life Pixel Art Tileset Pack` — Primeval ground, buildings, and battle stage.

## Runtime-admitted but unwired

These six folders were copied during the interrupted implementation attempt. They currently have zero visual profiles and zero playable map or encounter references.

1. `Abandoned Hospital Tileset`
2. `Crimson Gothic Castle`
3. `Desert arabian nights`
4. `Magic wizard academy`
5. `Underwater Ocean Depths`
6. `World War I Trench Warfare Tileset`

## Canonical packs missed completely

These 129 source packs exist under `assets/Tilesets` but are absent from the runtime asset tree.

1. `Abandoned Nuclear Bunker Pixel Art Tileset`
2. `Airplane Interior & Exterior Pixel Art Tileset Pack`
3. `Alien Jungle Tileset`
4. `Antarctic Research Station Pixel Tileset`
5. `Ashlands Tileset`
6. `Asteroid Base Pixel Art Tileset`
7. `Backrooms Pixel Art Tileset`
8. `Backrooms Poolcore Pixel Art Tileset`
9. `Beach Tileset`
10. `belly of the monster`
11. `Cafe Assets`
12. `Cloud City Tileset`
13. `Cozy Cafe Asset Pack`
14. `Cozy farming village`
15. `Cozy Spring Asset Pack`
16. `Crystalice Forest`
17. `cursed land`
18. `Cyberpunk City Tileset`
19. `Cyberpunk Pixel Art`
20. `Cyberpunk Pixel Art Asset Pack`
21. `Dark Dimension Tileset`
22. `Dark Gothic City Pixel Art Tileset Pack`
23. `Dark Steel City Tileset`
24. `Desert Wasteland Pixel Tileset`
25. `Dieselpunk Houses`
26. `Dreamy World Pixel Art Tileset Pack`
27. `Dungeon Asset Pack`
28. `Elven Forest Asset Pack`
29. `Environment Decor`
30. `Factory Monster Pack 1`
31. `Factory Ruins Pixel Art Tileset Pack`
32. `fairy forest`
33. `Fantasy Forest RPG Maker Tileset`
34. `Fantasy Houses Tileset`
35. `Fantasy Structures & Props - Pixel Art Asset Pack`
36. `Farm Assets`
37. `Farm Tileset - Pixel Art`
38. `Ferrum Junkyard 1`
39. `Ferrum Junkyard Heroes`
40. `Ferrum Tileset Dieselpunk Slums 1`
41. `Ferrum Tileset; Dieselpunk Slums 2`
42. `Final Tower`
43. `Forest Warzone Pixel Art Tileset Pack`
44. `Forest Wilderness Pixel Art Tileset Pack`
45. `Frostbound viking village`
46. `fungus cave`
47. `Futuristic War Ruins Pixel Art Tileset Pack`
48. `Gaming room interiors`
49. `GOLDEN PALACE`
50. `Great War RPG Maker Houses`
51. `Green-Apocalyptic Ruins Tileset`
52. `Haunted Mansion`
53. `ICE CAVERN`
54. `Infected Spaceship Interior Horror Tileset Pack`
55. `Jungle Tileset`
56. `Lava Cavern`
57. `Level Map Assets Pixel Art`
58. `Luxury Cruise Ship Pixel Art Tileset Pack`
59. `Magic Forest Asset Pack`
60. `Mars Base Tileset`
61. `Medieval Army Camp Tileset Pack`
62. `Medieval Battlefield & Ruins Pixel Art Tileset Pack`
63. `Medieval Castle Fantasy - Pixel Art Tileset`
64. `Medieval Fantasy Dungeon & Prison Pixel Art Tileset Pack`
65. `Medieval Fantasy Town Pixel Art Tileset Pack`
66. `Medieval Plague Town Tileset`
67. `Medieval Siege & Castle Tileset`
68. `Medieval village town`
69. `Modern Airport Pixel Art Tileset Pack`
70. `Modern Arcade Game Center Pixel Art Tileset Pack`
71. `Modern Bar & Nightclub`
72. `Modern Construction Site Pixel Art Tileset Pack`
73. `Modern Gas Station Pixel Art Tileset Pack`
74. `Modern Gym Fitness Center Pixel Art Tileset Pack`
75. `Modern Industrial Factory Pixel Art Tileset Pack`
76. `Modern Interior Pixel Art Tileset`
77. `Modern Laboratory Assets`
78. `Modern Military Submarine Pixel Art Tileset Pack`
79. `Modern Office Interior Tileset`
80. `Modern Pharmacy Pixel Art Tileset Pack`
81. `Modern Prison Pixel Art Tileset Pack`
82. `Modern Restaurant`
83. `Modern Restaurant Pixel Art Tileset Pack`
84. `Modern Subway Station Tileset Pack`
85. `Modern Waste Management Plant Pixel Art Tileset Pack`
86. `Monder Interiors`
87. `Moon Base pixel art Tileset`
88. `Normandy Landing Pixel Art Tileset Pack`
89. `Nuclear Bunker Interior Pixel Art Tileset`
90. `Nuclear War Ruins Tileset`
91. `Pirate Age Pixel Tileset Pack`
92. `Pirate harbor`
93. `Post-Apocalypse Pixel Art`
94. `Post-Apocalyptic Abandoned Supermarket Tileset`
95. `Post-Apocalyptic Polluted Wasteland Pixel Art Tileset Pack`
96. `Post-Apocalyptic Subway Station Tileset Pack`
97. `Post-Apocalyptic War Ruins Tileset`
98. `Post-Apocalyptic Wasteland Survival Farm Tileset`
99. `Post-Apocalyptic Zombie City Tileset`
100. `Psychological Horror Dungeon`
101. `Rainforest Survival Pixel Art Tileset Pack`
102. `Roman Empire Pixel Art Tileset`
103. `Royal Props collection`
104. `Ruined Dungeon`
105. `Scifi space station`
106. `scorched desert`
107. `Seabed`
108. `Snowy Village Pixel Art Asset Pack`
109. `Space Station Interior Tileset`
110. `Steamforged industrial`
111. `Steampunk Pixel Art Tileset`
112. `Supermarket Tileset`
113. `Survival Island Pixel Art Tileset`
114. `Survival Shelter Tileset`
115. `Time Fantasy winter`
116. `Tokyo Nights`
117. `undead land objects`
118. `Underwater World & Sunken Ruins Pixel Art Tileset`
119. `Viking Age Pixel Art Tileset Pack`
120. `Volcanic`
121. `Wasteland Abandoned Parking Lot Pixel Art Tileset Pack`
122. `Wasteland School Pixel Art Tileset`
123. `Wasteland survivor kit`
124. `Wild West Pixel Art Tileset`
125. `WW1 Ruins Pixel Art Tileset Pack`
126. `WW1 Trench & Bunker Pixel Art Tileset Pack`
127. `WWII City Ruins Pixel Art Tileset Pack`
128. `XModern Arcade`
129. `Zombie apocalypse`

## Expansion `stages` mirror

The following 31 folders under `assets/EXPANSION/stages` duplicate canonical pack names. Each mirror has the same image count and total image byte size as its same-named folder under `assets/Tilesets`. They should not be counted twice when choosing unique stages.

1. `Ancient Greek Mythology`
2. `Ashlands Tileset`
3. `Beach Tileset`
4. `belly of the monster`
5. `Cloud City Tileset`
6. `Crimson Gothic Castle`
7. `Crystalice Forest`
8. `cursed land`
9. `Cyberpunk Pixel Art`
10. `Dark Dimension Tileset`
11. `Dungeon Asset Pack`
12. `fairy forest`
13. `Final Tower`
14. `Flying Islands`
15. `fungus cave`
16. `GOLDEN PALACE`
17. `ICE CAVERN`
18. `Jungle Tileset`
19. `Lava Cavern`
20. `Level Map Assets Pixel Art`
21. `Magic Forest Asset Pack`
22. `Post-Apocalypse Pixel Art`
23. `Psychological Horror Dungeon`
24. `Royal Props collection`
25. `Ruined Dungeon`
26. `Sakura Temple Asset Pack`
27. `scorched desert`
28. `Seabed`
29. `Time Fantasy winter`
30. `undead land objects`
31. `XModern Arcade`

## Additional expansion stage libraries

These are outside the 149-pack canonical library and were also missed by the prior implementation.

### HoriHori backgrounds

- Pack 1: 150 background images.
- Pack 2: 50 background images.
- Pack 3: 73 background images.
- Pack 4: 300 background images.
- Pack 5: 131 background images.
- Layered `Back` variants: 39 images across twelve numbered variants.

### More stages and NPCs

- `Abusive Prison Tileset Pack`: 8 tilesets and 100 battlebacks.
- `Galacti-Chron - Sci-Fi Worlds Pack - Kelvana Prime`: 11 tilesets and 1 battleback.
- `Galacti-Chrons Interstellar Society Pack`: 31 tilesets and 6 battlebacks.
- `Galacti-Chrons Sci-Fi Warehouse Pack`: 12 tilesets and 6 battlebacks.
- `finalbossblues/FutureFantasy`: 30 source tilesets represented in three RPG Maker scale/export variants.
- `finalbossblues/tf_steampunk`: 14 source tilesets represented in three RPG Maker scale/export variants.
- `more stages and npcs/tilesets`: 20 additional images.
- `Winlu Fantasy Overworld`: 6 tileset images.
- `Valley of Ruin`: one ZIP archive plus its text file; the archive is not unpacked.
- `Demo` and `Package`: 26 additional loose images requiring content review before they can be classified as unique stages.

### SakPix expansion

- `Abandoned Asylum — Horror Pixel Art Asset Pack`: 20 images.
- `Cozy Café Interiors-Pixel Art Asset Pack`: 20 images.
- `Cozy Farming Village Asset Pack`: 20 images.
- `Frontier Legends Wild West Pixel Art Asset Pack`: 20 images.
- `Minimalist Interiors — Minimalist Pixel Art Asset Pack`: 19 images.

### Other stage-capable source groups

- `RPGMAKERASSETS/TilesetAssembly`: 197 PNG assembly sheets.
- `SciGo/Starter Tiles - Platformer`: seven environment themes (`BasicGreen`, `DarkCastle`, `Fire`, `Ice`, `OutsideHouse`, `Swamp`, plus the base set), 179 images total.
- `SciGo/Grass`, `SciGo/Water`, and `SciGo/Trees`: four modular environment images.

## Audit conclusion

The previous six-stage proposal was not a complete pass through the supplied
material. It sampled six packs while overlooking 129 canonical packs and
several separate expansion-stage libraries. The corrected completion plan uses
this inventory as the admission ledger for a 192-location main campaign,
including six mandatory address campaigns beyond the seven core universes.
Every unique, licensable, technically eligible environment pack must receive a
main-game room/profile binding; exact duplicates, non-runtime payloads, and
rejected sources remain audit exclusions rather than extra stages. No admitted
stage family may be labeled optional or left as an unwired runtime copy.
