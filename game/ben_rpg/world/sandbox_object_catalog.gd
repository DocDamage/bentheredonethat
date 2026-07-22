class_name SandboxObjectCatalog
extends RefCounted

const PACK_ORDER := [
	&"Modern World",
	&"Ranch Stuff",
	&"Haunted Mansion",
	&"Modern Laboratory",
	&"Sci-Fi Spaceship",
]

const ITEMS := {
	&"modern_blue_cottage": {
		"name": "Blue-Roof Cottage", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png",
		"region": Rect2(99, 0, 43, 48), "visual_profile": &"sandbox_modern_blue_cottage", "draw_size": Vector2(129, 144), "footprint": Vector2i(3, 3), "blocks": true,
	},
	&"modern_red_cottage": {
		"name": "Red-Roof Cottage", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png",
		"region": Rect2(144, 0, 48, 48), "visual_profile": &"sandbox_modern_red_cottage", "draw_size": Vector2(144, 144), "footprint": Vector2i(3, 3), "blocks": true,
	},
	&"modern_corner_shop": {
		"name": "Corner Shop", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png",
		"region": Rect2(672, 208, 96, 80), "visual_profile": &"town_cafe_facade", "draw_size": Vector2(192, 160), "footprint": Vector2i(4, 4), "blocks": true,
	},
	&"modern_clock_hall": {
		"name": "Clock Hall", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png",
		"region": Rect2(128, 288, 144, 112), "visual_profile": &"sandbox_modern_clock_hall", "draw_size": Vector2(288, 224), "footprint": Vector2i(6, 5), "blocks": true,
	},
	&"modern_warehouse": {
		"name": "Blue Warehouse", "pack": &"Modern World",
		"texture": "res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png",
		"region": Rect2(672, 5, 96, 91), "visual_profile": &"laboratory_exterior", "draw_size": Vector2(192, 182), "footprint": Vector2i(4, 2), "blocks": true,
	},
	&"ranch_house": {
		"name": "Ranch House", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/buildings/building_01_16x16.png",
		"region": Rect2(0, 0, 64, 64), "visual_profile": &"sandbox_ranch_house", "draw_size": Vector2(192, 192), "footprint": Vector2i(4, 4), "blocks": true,
	},
	&"ranch_oak": {
		"name": "Full-Grown Oak", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/tree_01_16x16.png",
		"region": Rect2(32, 0, 48, 64), "visual_profile": &"sandbox_ranch_oak", "draw_size": Vector2(144, 192), "footprint": Vector2i(3, 4), "blocks": true,
	},
	&"ranch_sapling": {
		"name": "Young Tree", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/tiles/tree_01_16x16.png",
		"region": Rect2(0, 0, 32, 48), "visual_profile": &"sandbox_ranch_sapling", "draw_size": Vector2(96, 144), "footprint": Vector2i(2, 3), "blocks": true,
	},
	&"ranch_cow": {
		"name": "Black Ranch Cow", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/animals/cows/cow_01/black/idle/cow_01_black_idle_down_32x32.png",
		"region": Rect2(0, 0, 32, 32), "visual_profile": &"sandbox_ranch_cow", "draw_size": Vector2(96, 96), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"ranch_cat": {
		"name": "Town Cat", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/animals/cats/cat_01/idle/cat_01_idle_down_16x20.png",
		"region": Rect2(0, 0, 16, 20), "visual_profile": &"sandbox_ranch_cat", "draw_size": Vector2(48, 60), "footprint": Vector2i.ONE, "blocks": false,
	},
	&"ranch_corn": {
		"name": "Mature Corn", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/crops/corn/growth_basic/corn_16x32_8frames.png",
		"region": Rect2(112, 0, 16, 32), "visual_profile": &"sandbox_ranch_corn", "draw_size": Vector2(48, 96), "footprint": Vector2i(1, 2), "blocks": false,
	},
	&"ranch_pumpkin": {
		"name": "Pumpkin Vine", "pack": &"Ranch Stuff",
		"texture": "res://game_assets/Tilesets/Ranch Stuff/assets/crops/pumpkin/growth_basic/pumpkin_16x16_7frames.png",
		"region": Rect2(96, 0, 16, 16), "visual_profile": &"sandbox_ranch_pumpkin", "draw_size": Vector2(48, 48), "footprint": Vector2i.ONE, "blocks": false,
	},
	&"haunted_facade": {
		"name": "Haunted House Facade", "pack": &"Haunted Mansion",
		"texture": "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/1.png",
		"region": Rect2(384, 0, 240, 160), "visual_profile": &"sandbox_haunted_facade", "draw_size": Vector2(240, 160), "footprint": Vector2i(5, 4), "blocks": true,
	},
	&"haunted_clock": {
		"name": "Grandfather Clock", "pack": &"Haunted Mansion",
		"texture": "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png",
		"region": Rect2(592, 268, 64, 118), "visual_profile": &"mansion_archive_cabinet", "draw_size": Vector2(64, 118), "footprint": Vector2i(2, 3), "blocks": true,
	},
	&"haunted_passage_door": {
		"name": "Servants' Passage Door", "pack": &"Haunted Mansion",
		"texture": "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/4.png",
		"region": Rect2(296, 672, 88, 96), "visual_profile": &"sandbox_haunted_passage_door", "draw_size": Vector2(88, 96), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"lab_workbench": {
		"name": "Laboratory Workbench", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/3.png",
		"region": Rect2(0, 192, 96, 96), "visual_profile": &"sandbox_lab_workbench", "draw_size": Vector2(96, 96), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"lab_computer": {
		"name": "Triple-Monitor Station", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/4.png",
		"region": Rect2(176, 384, 112, 112), "visual_profile": &"sandbox_lab_computer", "draw_size": Vector2(112, 112), "footprint": Vector2i(3, 3), "blocks": true,
	},
	&"lab_schedule": {
		"name": "Laboratory Schedule Board", "pack": &"Modern Laboratory",
		"texture": "res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/4.png",
		"region": Rect2(384, 384, 192, 112), "visual_profile": &"sandbox_lab_schedule", "draw_size": Vector2(192, 112), "footprint": Vector2i(4, 3), "blocks": true,
	},
	&"scifi_shuttle": {
		"name": "Exploration Shuttle", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/8.png",
		"region": Rect2(135, 3, 248, 89), "visual_profile": &"asterion_dock_hull", "draw_size": Vector2(248, 89), "footprint": Vector2i(6, 2), "blocks": true,
	},
	&"scifi_cargo_module": {
		"name": "Cargo Module", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/8.png",
		"region": Rect2(675, 105, 91, 81), "draw_size": Vector2(91, 81), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"scifi_ration_locker": {
		"name": "Ration Locker", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png",
		"region": Rect2(241, 0, 45, 96), "visual_profile": &"asterion_mess_banner", "draw_size": Vector2(45, 96), "footprint": Vector2i(1, 2), "blocks": true,
	},
	&"scifi_prep_locker": {
		"name": "Food Prep Locker", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png",
		"region": Rect2(289, 0, 46, 96), "draw_size": Vector2(46, 96), "footprint": Vector2i(1, 2), "blocks": true,
	},
	&"scifi_food_locker": {
		"name": "Cold Food Locker", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png",
		"region": Rect2(337, 0, 46, 96), "draw_size": Vector2(46, 96), "footprint": Vector2i(1, 2), "blocks": true,
	},
	&"scifi_mess_table": {
		"name": "Mess Hall Table", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png",
		"region": Rect2(2, 2, 93, 47), "draw_size": Vector2(93, 47), "footprint": Vector2i(2, 1), "blocks": true,
	},
	&"scifi_water_cooler": {
		"name": "Water Recycler", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png",
		"region": Rect2(537, 112, 31, 80), "draw_size": Vector2(31, 80), "footprint": Vector2i(1, 2), "blocks": true,
	},
	&"scifi_grow_rack": {
		"name": "Hydroponic Grow Rack", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/3.png",
		"region": Rect2(144, 59, 240, 85), "visual_profile": &"asterion_hydroponics_bed", "draw_size": Vector2(240, 85), "footprint": Vector2i(5, 2), "blocks": true,
	},
	&"scifi_seed_bed": {
		"name": "Hydroponic Seed Bed", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/3.png",
		"region": Rect2(0, 147, 96, 45), "draw_size": Vector2(96, 45), "footprint": Vector2i(2, 1), "blocks": true,
	},
	&"scifi_bio_pod": {
		"name": "Specimen Bio-Pod", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/3.png",
		"region": Rect2(686, 195, 69, 92), "draw_size": Vector2(69, 92), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"scifi_command_bank": {
		"name": "Command Console Bank", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/6.png",
		"region": Rect2(0, 0, 289, 143), "visual_profile": &"asterion_command_console", "draw_size": Vector2(289, 143), "footprint": Vector2i(7, 3), "blocks": true,
	},
	&"scifi_porthole": {
		"name": "Observation Porthole", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/6.png",
		"region": Rect2(5, 149, 87, 87), "draw_size": Vector2(87, 87), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"scifi_hologram_beacon": {
		"name": "Hologram Beacon", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/6.png",
		"region": Rect2(290, 21, 93, 116), "draw_size": Vector2(93, 116), "footprint": Vector2i(2, 3), "blocks": true,
	},
	&"scifi_med_bed": {
		"name": "Medical Bed", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/10.png",
		"region": Rect2(1, 10, 45, 86), "visual_profile": &"asterion_medical_station", "draw_size": Vector2(45, 86), "footprint": Vector2i(1, 2), "blocks": true,
	},
	&"scifi_med_scanner": {
		"name": "Medical Scanner", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/10.png",
		"region": Rect2(194, 124, 92, 62), "draw_size": Vector2(92, 62), "footprint": Vector2i(2, 2), "blocks": true,
	},
	&"scifi_drug_cabinet": {
		"name": "Pharmacy Cabinet", "pack": &"Sci-Fi Spaceship",
		"texture": "res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/10.png",
		"region": Rect2(531, 115, 42, 77), "draw_size": Vector2(42, 77), "footprint": Vector2i(1, 2), "blocks": true,
	},
}


static func definition(catalog_id: StringName) -> Dictionary:
	return ITEMS.get(catalog_id, {})


static func items_for_pack(pack_id: StringName) -> Array[StringName]:
	var results: Array[StringName] = []
	for catalog_id in ITEMS.keys():
		if StringName(ITEMS[catalog_id].get("pack", "")) == pack_id:
			results.append(StringName(catalog_id))
	results.sort_custom(func(a: StringName, b: StringName) -> bool: return String(ITEMS[a]["name"]) < String(ITEMS[b]["name"]))
	return results
