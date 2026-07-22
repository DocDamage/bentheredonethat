extends RefCounted

const PACK_ORDER := [
	&"Ranch Stuff",
	&"Modern World",
	&"Haunted Mansion",
	&"Modern Laboratory",
	&"Sci-Fi Spaceship",
]

const BRUSHES := {
	&"ranch_meadow": {
		"name": "Meadow Grass", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png",
		"region": Rect2(32, 32, 16, 16), "visual_profile": &"sandbox_ranch_meadow", "blocks": false,
	},
	&"ranch_light_grass": {
		"name": "Light Grass", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png",
		"region": Rect2(48, 32, 16, 16), "visual_profile": &"sandbox_ranch_light_grass", "blocks": false,
	},
	&"ranch_dirt": {
		"name": "Packed Dirt", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png",
		"region": Rect2(32, 64, 16, 16), "visual_profile": &"sandbox_ranch_dirt", "blocks": false,
	},
	&"ranch_farmland": {
		"name": "Tilled Field", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png",
		"region": Rect2(0, 176, 16, 16), "visual_profile": &"sandbox_ranch_farmland", "blocks": false,
	},
	&"ranch_snow": {
		"name": "Snow Cover", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/snow_01_16x16.png",
		"region": Rect2(32, 32, 16, 16), "visual_profile": &"sandbox_ranch_snow", "blocks": false,
	},
	&"ranch_water": {
		"name": "Shallow Water", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/water_01_16x16_5frames.png",
		"region": Rect2(0, 0, 16, 16), "visual_profile": &"sandbox_ranch_water", "blocks": true,
	},
	&"modern_grass": {
		"name": "Overworld Grass", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/1.png",
		"region": Rect2(900, 150, 48, 48), "visual_profile": &"sandbox_modern_grass", "blocks": false,
	},
	&"modern_dirt": {
		"name": "Overworld Dirt", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/1.png",
		"region": Rect2(1240, 150, 48, 48), "visual_profile": &"sandbox_modern_dirt", "blocks": false,
	},
	&"modern_cobble": {
		"name": "City Cobblestone", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/1.png",
		"region": Rect2(1432, 150, 48, 48), "visual_profile": &"sandbox_modern_cobble", "blocks": false,
	},
	&"modern_sand": {
		"name": "Beach Sand", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/1.png",
		"region": Rect2(650, 150, 48, 48), "visual_profile": &"sandbox_modern_sand", "blocks": false,
	},
	&"haunted_planks": {
		"name": "Haunted Floorboards", "pack": &"Haunted Mansion",
		"texture": "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png",
		"region": Rect2(96, 288, 48, 48), "visual_profile": &"sandbox_haunted_planks", "blocks": false,
	},
	&"haunted_stone": {
		"name": "Haunted Flagstone", "pack": &"Haunted Mansion",
		"texture": "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png",
		"region": Rect2(192, 192, 48, 48), "visual_profile": &"sandbox_haunted_stone", "blocks": false,
	},
	&"lab_white_panel": {
		"name": "White Laboratory Panel", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png",
		"region": Rect2(0, 0, 48, 48), "visual_profile": &"sandbox_lab_white_panel", "blocks": false,
	},
	&"lab_blue_panel": {
		"name": "Blue Laboratory Panel", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png",
		"region": Rect2(96, 192, 48, 48), "visual_profile": &"sandbox_lab_blue_panel", "blocks": false,
	},
	&"lab_green_panel": {
		"name": "Green Laboratory Panel", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png",
		"region": Rect2(192, 192, 48, 48), "visual_profile": &"sandbox_lab_green_panel", "blocks": false,
	},
	&"lab_steel_panel": {
		"name": "Steel Laboratory Panel", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png",
		"region": Rect2(288, 192, 48, 48), "visual_profile": &"sandbox_lab_steel_panel", "blocks": false,
	},
	&"scifi_blue_panel": {
		"name": "Blue Hull Panel", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png",
		"region": Rect2(0, 0, 48, 48), "visual_profile": &"sandbox_scifi_blue_panel", "blocks": false,
	},
	&"scifi_gray_panel": {
		"name": "Gray Hull Panel", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png",
		"region": Rect2(96, 0, 48, 48), "visual_profile": &"sandbox_scifi_gray_panel", "blocks": false,
	},
	&"scifi_steel_floor": {
		"name": "Steel Deck", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png",
		"region": Rect2(0, 384, 48, 48), "visual_profile": &"sandbox_scifi_steel_floor", "blocks": false,
	},
	&"scifi_grate": {
		"name": "Ventilated Grate", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png",
		"region": Rect2(0, 288, 48, 48), "visual_profile": &"sandbox_scifi_grate", "blocks": false,
	},
}


static func definition(brush_id: StringName) -> Dictionary:
	return BRUSHES.get(brush_id, {})


static func brushes_for_pack(pack_id: StringName) -> Array[StringName]:
	var results: Array[StringName] = []
	for brush_id in BRUSHES.keys():
		if StringName(BRUSHES[brush_id].get("pack", "")) == pack_id:
			results.append(StringName(brush_id))
	results.sort_custom(func(a: StringName, b: StringName) -> bool: return String(BRUSHES[a]["name"]) < String(BRUSHES[b]["name"]))
	return results
