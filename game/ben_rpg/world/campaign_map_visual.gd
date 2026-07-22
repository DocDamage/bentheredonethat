class_name CampaignMapVisual
extends Node2D

const TILE := 48
const TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
const SANDBOX_VISUAL_RESOLVER := preload("res://ben_rpg/world/sandbox_visual_resolver.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TOWN_ORIGIN := Vector2i(36, 0)
const LAB_SIZE := Vector2i(20, 12)
const TOWN_SIZE := Vector2i(32, 28)
const MANSION_ORIGIN := Vector2i(0, 32)
const MANSION_SIZE := Vector2i(28, 18)
const STATION_ORIGIN := Vector2i(36, 32)
const STATION_SIZE := Vector2i(28, 18)
const PRIMEVAL_ORIGIN := Vector2i(72, 32)
const PRIMEVAL_SIZE := Vector2i(28, 18)
const HELIOS_ORIGIN := Vector2i(108, 32)
const HELIOS_SIZE := Vector2i(28, 18)
const FROSTHOLD_ORIGIN := Vector2i(144, 32)
const FROSTHOLD_SIZE := Vector2i(28, 18)
const MOONPETAL_ORIGIN := Vector2i(180, 32)
const MOONPETAL_SIZE := Vector2i(28, 18)
const EMPYREAL_ORIGIN := Vector2i(216, 32)
const EMPYREAL_SIZE := Vector2i(28, 18)
const MANSION_ARCHIVE_OFFSET := Vector2i(10, 0)
const MANSION_GALLERY_OFFSET := Vector2i(0, 10)
const MANSION_NURSERY_OFFSET := Vector2i(10, 10)
const MANSION_BALLROOM_OFFSET := Vector2i(20, 5)
const MANSION_INTERIOR_WALL_PROFILES := [
	[&"mansion_interior_wall_0_0", &"mansion_interior_wall_1_0", &"mansion_interior_wall_2_0", &"mansion_interior_wall_3_0"],
	[&"mansion_interior_wall_0_1", &"mansion_interior_wall_1_1", &"mansion_interior_wall_2_1", &"mansion_interior_wall_3_1"],
]
const MANSION_NURSERY_WALL_PROFILES := [
	[&"mansion_nursery_wall_0_0", &"mansion_nursery_wall_1_0", &"mansion_nursery_wall_2_0", &"mansion_nursery_wall_3_0", &"mansion_nursery_wall_4_0", &"mansion_nursery_wall_5_0", &"mansion_nursery_wall_6_0", &"mansion_nursery_wall_7_0"],
	[&"mansion_nursery_wall_0_1", &"mansion_nursery_wall_1_1", &"mansion_nursery_wall_2_1", &"mansion_nursery_wall_3_1", &"mansion_nursery_wall_4_1", &"mansion_nursery_wall_5_1", &"mansion_nursery_wall_6_1", &"mansion_nursery_wall_7_1"],
]
const MANSION_PLANK_GRAIN_PROFILES := [
	[&"mansion_plank_grain_0_0", &"mansion_plank_grain_1_0"],
	[&"mansion_plank_grain_0_1", &"mansion_plank_grain_1_1"],
	[&"mansion_plank_grain_0_2", &"mansion_plank_grain_1_2"],
	[&"mansion_plank_grain_0_3", &"mansion_plank_grain_1_3"],
]
const FACILITY_PLOTS := [
	Rect2i(7, 5, 5, 4),
	Rect2i(18, 5, 5, 4),
	Rect2i(7, 13, 5, 4),
	Rect2i(16, 12, 9, 5),
	Rect2i(25, 13, 7, 4),
	Rect2i(25, 5, 5, 4),
	Rect2i(1, 13, 5, 4),
	Rect2i(1, 4, 5, 5),
	Rect2i(16, 20, 5, 5),
	Rect2i(25, 20, 5, 5),
	Rect2i(7, 20, 5, 5),
]
const FACILITY_CROPS := {
	"Cafe": Rect2(672, 208, 96, 80),
	# This is the complete clock-school facade inside the authored town sample.
	# Its facade proper begins at x=141 and ends at x=242; the wider connected
	# component also contains foliage from the showcase scene. The previous x=144
	# crop removed the left cornice, while the later component-wide crop exposed
	# narrow tree/lawn strips on both sides. These are the actual facade bounds.
	"Library": Rect2(141, 290, 102, 96),
	"Clinic": Rect2(288, 300, 96, 84),
	# Complete two-bay civic workshop facade with its roof, crest, and doors.
	"Armory": Rect2(576, 304, 96, 80),
	"Trailhead Lodge": Rect2(387, 2, 90, 92),
	"Cold Storage": Rect2(29, 198, 182, 240),
	"Tea House": Rect2(572, 802, 220, 165),
}
const FACILITY_PROFILE_IDS := {
	"Cafe": &"town_cafe_facade",
	"Clinic": &"town_clinic_facade",
	"Armory": &"town_armory_facade",
	"Trailhead Lodge": &"town_trailhead_lodge_facade",
	"Cold Storage": &"town_cold_storage_facade",
	"Tea House": &"town_tea_house_facade",
}
const FACILITY_SCALES := {
	"Cafe": 2.0,
	"Library": 2.0,
	"Clinic": 2.0,
	"Armory": 2.0,
	"Haunted Mansion": 1.0,
	"Observatory": 2.0,
	"Trailhead Lodge": 2.0,
	"Afterlight Club": 2.0,
	"Cold Storage": 1.0,
	"Tea House": 1.0,
	"Belfry": 1.0,
}
# Horizontal doorway anchors measured within each exact source crop. Aligning
# these—not the sprite's bounding-box center—to the functional plot doorway
# keeps interaction, collision, and the painted entrance in the same place.
const FACILITY_DOOR_X := {
	"Cafe": 48.0,
	"Library": 52.0,
	"Clinic": 48.0,
	"Armory": 48.0,
	"Haunted Mansion": 72.0,
	"Observatory": 45.0,
	"Trailhead Lodge": 45.0,
	"Afterlight Club": 47.0,
	"Cold Storage": 91.0,
	"Tea House": 110.0,
	"Belfry": 112.0,
}
const HAUNTED_EXTERIOR_CROP := Rect2(384, 0, 240, 160)

var lab_wall: Texture2D
var lab_utility: Texture2D
var lab_props: Texture2D
var lab_doors: Texture2D
var town_ground: Texture2D
var town_structures: Texture2D
var library_facade: Texture2D
var haunted_exterior: Texture2D
var haunted_interior: Texture2D
var haunted_storage: Texture2D
var haunted_bedroom: Texture2D
var station_architecture: Texture2D
var primeval_ground: Texture2D
var primeval_structures: Texture2D
var helios_city: Texture2D
var helios_services: Texture2D
var helios_structures: Texture2D
var nightclub_signs: Texture2D
var frozen_ground: Texture2D
var frozen_houses: Texture2D
var sakura_temple: Texture2D
var sakura_paths: Texture2D
var empyreal_floor: Texture2D
var empyreal_columns: Texture2D
var empyreal_doors: Texture2D
var empyreal_trees: Texture2D
var empyreal_statues: Texture2D
var empyreal_altars: Texture2D
var empyreal_magic: Texture2D
var empyreal_clouds: Texture2D
var empyreal_islands: Texture2D
var empyreal_slices: Dictionary = {}
var built_facilities: Dictionary = {}
var build_mode := false
var selected_plot := 0
var active_area: StringName = &"lab"
var _terrain_texture_cache: Dictionary = {}
var _sandbox_visuals = SANDBOX_VISUAL_RESOLVER.new()
var visual_profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual_profiles = VISUAL_PROFILE_REGISTRY.new()
	# Laboratory profiles are the source-of-truth for both approved crop metadata
	# and runtime asset paths. The individual room draw calls can now migrate
	# one crop at a time without reintroducing path literals here.
	lab_wall = visual_profiles.texture(&"laboratory_floor_tile")
	lab_utility = visual_profiles.texture(&"laboratory_utility_bank")
	lab_props = visual_profiles.texture(&"laboratory_analysis_station")
	lab_doors = visual_profiles.texture(&"laboratory_exit_doors")
	town_ground = visual_profiles.texture(&"town_grass_tile")
	town_structures = visual_profiles.texture(&"town_cafe_facade")
	library_facade = _slice_sample_facade(town_structures, FACILITY_CROPS["Library"])
	haunted_exterior = visual_profiles.texture(&"haunted_mansion_exterior")
	haunted_interior = visual_profiles.texture(&"mansion_archive_cabinet")
	haunted_bedroom = visual_profiles.texture(&"mansion_nursery_bed")
	haunted_storage = visual_profiles.texture(&"mansion_archive_shelving")
	station_architecture = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png")
	primeval_ground = visual_profiles.texture(&"primeval_ground_quadrant")
	primeval_structures = visual_profiles.texture(&"primeval_village_dwelling")
	helios_city = visual_profiles.texture(&"helios_skybridge_quadrant")
	helios_services = visual_profiles.texture(&"helios_market_quadrant")
	helios_structures = visual_profiles.texture(&"helios_observatory_facade")
	nightclub_signs = visual_profiles.texture(&"afterlight_club_sign")
	frozen_ground = visual_profiles.texture(&"frosthold_snow_ground_tile")
	frozen_houses = visual_profiles.texture(&"frosthold_market_house")
	sakura_temple = visual_profiles.texture(&"moonpetal_court_temple")
	sakura_paths = visual_profiles.texture(&"moonpetal_processional_path")
	empyreal_clouds = visual_profiles.texture(&"empyreal_sky_cloud_bank")
	for slice_name in ["marble_plain", "marble_cracked", "marble_silver", "marble_gold", "marble_gold_quarter", "pediment_door", "tribunal_gate", "blue_balustrade", "winged_statue", "horse_statue", "griffin_statue", "justice_statue", "music_statue", "silver_olive_tree", "golden_olive_tree", "appeal_fountain", "ordinance_book", "reliquary_portal", "gravity_crystal", "tribunal_orrery", "celestial_flame", "plain_column", "blue_column", "flower_offering", "fruit_offering", "crystal_altar", "lotus_altar", "belfry_facade", "belfry_building"]:
		empyreal_slices[slice_name] = load("res://game_assets/Tilesets/Ancient Greek Mythology/Sliced/%s.png" % slice_name)
	if not CampaignState.town_terrain_changed.is_connected(_on_town_terrain_changed):
		CampaignState.town_terrain_changed.connect(_on_town_terrain_changed)
	if not CampaignState.state_changed.is_connected(_on_campaign_state_changed):
		CampaignState.state_changed.connect(_on_campaign_state_changed)
	queue_redraw()


func tile(texture: Texture2D, source: Rect2, destination: Rect2) -> void:
	if texture:
		draw_texture_rect_region(texture, destination, source)


func profile_tile(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not visual_profiles or not visual_profiles.has(profile_id):
		push_error("Missing approved visual profile: %s" % profile_id)
		return
	var source: Rect2 = visual_profiles.region(profile_id)
	var size: Vector2 = visual_profiles.world_draw_size(profile_id)
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	tile(texture, source, Rect2(position, size))


func _slice_sample_facade(texture: Texture2D, source: Rect2) -> Texture2D:
	# Some authored showcase maps paint their buildings directly onto a lawn.
	# Extract the measured facade and remove only that pack's narrow lawn-color
	# range in memory. This preserves the actual facade/hedges while preventing a
	# rectangular sample-map seam from being stamped over the town's own grass.
	var image := texture.get_image().get_region(Rect2i(source))
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var is_sample_lawn := (
				pixel.a > 0.0
				and pixel.r >= 0.45 and pixel.r <= 0.60
				and pixel.g >= 0.68 and pixel.g <= 0.82
				and pixel.b >= 0.25 and pixel.b <= 0.48
				and pixel.g - pixel.r >= 0.14
			)
			if is_sample_lawn:
				pixel.a = 0.0
				image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)


func _draw() -> void:
	# An area transition owns the visible field. Rendering every universe into a
	# single canvas was needlessly expensive and also made an accidental camera
	# limit leak reveal neighbouring rooms. Each area function now opts in below.
	draw_laboratory()
	draw_town()
	draw_haunted_mansion()
	draw_asterion_station()
	draw_primeval_expanse()
	draw_helios_arcology()
	draw_frosthold_kingdom()
	draw_moonpetal_court()
	draw_empyreal_court()


func draw_laboratory() -> void:
	if active_area != &"lab":
		return
	for y in range(LAB_SIZE.y):
		for x in range(LAB_SIZE.x):
			var floor_profile: StringName = &"laboratory_wall_tile" if y <= 2 else &"laboratory_floor_tile"
			profile_tile(floor_profile, lab_wall, Vector2(x * TILE, y * TILE))
	# Rear-wall architecture remains in two coherent banks: a labeled observation
	# bay and one complete ventilation run. The floor equipment below is cut into
	# individual alpha islands; the previous 336px/384px row crops reproduced the
	# atlas's presentation rows and made unrelated benches touch edge-to-edge.
	profile_tile(&"laboratory_utility_bank", lab_utility, Vector2(TILE, TILE))
	profile_tile(&"laboratory_ventilation_run", lab_utility, Vector2(11 * TILE, 0))
	# West analysis bank: three distinct stations with breathing room.
	profile_tile(&"laboratory_analysis_station", lab_props, Vector2(48, 190))
	profile_tile(&"laboratory_west_terminal", lab_props, Vector2(166, 198))
	profile_tile(&"laboratory_west_spectrometer", lab_props, Vector2(282, 198))
	# East fabrication bank mirrors the footprint without duplicating the art.
	profile_tile(&"laboratory_east_fabricator", lab_props, Vector2(528, 198))
	profile_tile(&"laboratory_east_reactor", lab_props, Vector2(646, 198))
	profile_tile(&"laboratory_east_calibrator", lab_props, Vector2(764, 198))
	# Two contained fume hoods define the lower work alcoves. They stay entirely
	# outside the central invention aisle and no longer include neighbouring atlas
	# stools, cabinets, or blank presentation cells.
	profile_tile(&"laboratory_west_storage", lab_props, Vector2(48, 384))
	profile_tile(&"laboratory_center_storage", lab_props, Vector2(190, 384))
	profile_tile(&"laboratory_east_generator", lab_props, Vector2(676, 350))
	profile_tile(&"laboratory_east_coolant", lab_props, Vector2(790, 350))
	# A coherent double-door crop marks the physical exit at the bottom wall.
	profile_tile(&"laboratory_exit_doors", lab_doors, Vector2(9 * TILE, 10 * TILE))


func draw_town() -> void:
	if active_area != &"town":
		return
	var offset := Vector2(TOWN_ORIGIN * TILE)
	for y in range(TOWN_SIZE.y):
		for x in range(TOWN_SIZE.x):
			var road := x == 14 or y == 10
			# Both samples are native 48px world tiles from the same pack as the town
			# facades. This avoids the former 3x Ranch pixels and flat orange roads.
			var terrain_profile: StringName = &"town_road_tile" if road else &"town_grass_tile"
			profile_tile(terrain_profile, town_ground, offset + Vector2(x, y) * TILE)
	_draw_terrain_overrides()
	if not CampaignState.sandbox_mode:
		_draw_facility_approaches(offset)
	# Campaign mode keeps its authored construction plots here. The laboratory
	# façade and landmark trees are now independently rendered in ForegroundLayer
	# so actors can pass behind them; sandbox owns its editable town objects.
	# These are deliberately empty construction sites, integrated into the map
	# instead of editor windows that cover it.
	if not CampaignState.sandbox_mode:
		for plot_index in range(FACILITY_PLOTS.size()):
			var cell_plot: Rect2i = FACILITY_PLOTS[plot_index]
			var plot := Rect2(
				offset + Vector2(cell_plot.position) * TILE,
				Vector2(cell_plot.size) * TILE
			)
			if built_facilities.has(plot_index):
				_draw_facility(plot, built_facilities[plot_index])
			else:
				var border := Color(1.0, 0.92, 0.45, 0.95) if build_mode and selected_plot == plot_index else Color(0.92, 0.81, 0.47, 0.65)
				draw_rect(plot, Color(0.96, 0.83, 0.45, 0.12 if build_mode and selected_plot == plot_index else 0.07), true)
				draw_dashed_line(plot.position, plot.position + Vector2(plot.size.x, 0), border, 3.0 if build_mode and selected_plot == plot_index else 2.0, 10.0)
				draw_dashed_line(plot.position + Vector2(0, plot.size.y), plot.end, border, 3.0 if build_mode and selected_plot == plot_index else 2.0, 10.0)
				draw_dashed_line(plot.position, plot.position + Vector2(0, plot.size.y), border, 3.0 if build_mode and selected_plot == plot_index else 2.0, 10.0)
				draw_dashed_line(plot.position + Vector2(plot.size.x, 0), plot.end, border, 3.0 if build_mode and selected_plot == plot_index else 2.0, 10.0)
		_draw_town_state_overlay(offset)


func _draw_terrain_overrides() -> void:
	for cell in CampaignState.town_terrain_cells():
		var brush_id := CampaignState.town_terrain_at(cell)
		var definition: Dictionary = TERRAIN_CATALOG.definition(brush_id)
		if definition.is_empty():
			continue
		var texture_path := _sandbox_visuals.texture_path(definition)
		if not ResourceLoader.exists(texture_path):
			continue
		if not _terrain_texture_cache.has(texture_path):
			_terrain_texture_cache[texture_path] = load(texture_path)
		var texture := _terrain_texture_cache[texture_path] as Texture2D
		var source: Rect2 = _sandbox_visuals.region(definition, texture)
		tile(texture, source, Rect2(Vector2(cell * TILE), Vector2(TILE, TILE)))


func _on_town_terrain_changed() -> void:
	queue_redraw()


func _on_campaign_state_changed() -> void:
	queue_redraw()


func _draw_town_state_overlay(offset: Vector2) -> void:
	var overlay := CampaignState.town_state_overlay()
	var tint := overlay.get("tint", Color.TRANSPARENT) as Color
	if tint.a > 0.0:
		draw_rect(Rect2(offset, Vector2(TOWN_SIZE) * TILE), tint, true)
	var accent := overlay.get("accent", Color.WHITE) as Color
	var stabilized := int(overlay.get("stabilized_universes", 0))
	var lights := maxi(1, stabilized + 1)
	var positions := [Vector2i(4, 3), Vector2i(28, 4), Vector2i(4, 23), Vector2i(28, 23), Vector2i(14, 18), Vector2i(14, 3), Vector2i(14, 25)]
	for index in range(mini(lights, positions.size())):
		var point := offset + (Vector2(positions[index]) + Vector2(0.5, 0.5)) * TILE
		draw_circle(point, 12.0, Color(accent, 0.16))
		draw_circle(point, 4.0, accent)
	if StringName(overlay.get("id", &"")) == &"finale":
		var center := offset + (Vector2(14.5, 10.5)) * TILE
		draw_arc(center, 42.0, 0.0, TAU, 32, Color(accent, 0.76), 2.0, true)


func _draw_facility_approaches(offset: Vector2) -> void:
	if built_facilities.is_empty():
		return
	var has_southern_facility := false
	var deep_south_min_x := TOWN_SIZE.x
	var deep_south_max_x := -1
	for plot_key in built_facilities.keys():
		var plot: Rect2i = FACILITY_PLOTS[int(plot_key)]
		var door_x := plot.position.x + int(plot.size.x / 2)
		if plot.position.y < 10:
			# Northern plots face the original east-west road.
			for y in range(plot.end.y - 1, 11):
				profile_tile(&"town_road_tile", town_ground, offset + Vector2(door_x, y) * TILE)
		else:
			has_southern_facility = true
			if plot.position.y >= 20:
				# Later town expansion uses a short second lane below the original
				# neighborhood, keeping the Tea House's south-facing doorway clear.
				for y in range(plot.end.y - 1, 27):
					profile_tile(&"town_road_tile", town_ground, offset + Vector2(door_x, y) * TILE)
				deep_south_min_x = mini(deep_south_min_x, door_x)
				deep_south_max_x = maxi(deep_south_max_x, door_x)
				continue
			# Southern buildings meet a shared lane below their front doors.
			for y in range(plot.end.y - 1, 19):
				profile_tile(&"town_road_tile", town_ground, offset + Vector2(door_x, y) * TILE)
	if has_southern_facility:
		for x in range(1, 31):
			profile_tile(&"town_road_tile", town_ground, offset + Vector2(x, 18) * TILE)
	if deep_south_max_x >= 0:
		# Connect whichever deep-south plots were chosen instead of assuming two
		# fixed plot indexes. This also serves the new southwest construction site.
		for x in range(maxi(1, deep_south_min_x - 2), mini(TOWN_SIZE.x - 1, deep_south_max_x + 3)):
			profile_tile(&"town_road_tile", town_ground, offset + Vector2(x, 26) * TILE)


func _draw_facility(plot: Rect2, facility_name: String) -> void:
	# Each entry is one coherent alpha island. In particular, the Mansion used
	# to draw the first 624 pixels of its atlas, which combined three separate
	# facades and then shrank them to fit a plot.
	if facility_name == "Observatory":
		_draw_observatory_facility(plot)
		return
	if facility_name == "Afterlight Club":
		_draw_afterlight_club_facility(plot)
		return
	if facility_name == "Belfry":
		_draw_belfry_facility(plot)
		return
	_draw_facility_foundation(plot)
	var source: Rect2 = HAUNTED_EXTERIOR_CROP if facility_name == "Haunted Mansion" else FACILITY_CROPS[facility_name]
	var texture := haunted_exterior if facility_name == "Haunted Mansion" else (primeval_structures if facility_name == "Trailhead Lodge" else (frozen_houses if facility_name == "Cold Storage" else (sakura_temple if facility_name == "Tea House" else town_structures)))
	if facility_name == "Library" and library_facade:
		texture = library_facade
		source = Rect2(Vector2.ZERO, library_facade.get_size())
	var authored_scale: float = FACILITY_SCALES.get(facility_name, 1.0)
	var destination_size: Vector2 = source.size * authored_scale
	var door_x: float = float(FACILITY_DOOR_X.get(facility_name, source.size.x * 0.5)) * authored_scale
	var profile_id: StringName = FACILITY_PROFILE_IDS.get(facility_name, &"")
	if profile_id != &"":
		texture = visual_profiles.texture(profile_id)
		source = visual_profiles.region(profile_id)
		destination_size = visual_profiles.world_draw_size(profile_id)
		door_x = visual_profiles.doorway(profile_id).x
	elif facility_name == "Haunted Mansion":
		source = visual_profiles.region(&"haunted_mansion_exterior")
		destination_size = visual_profiles.world_draw_size(&"haunted_mansion_exterior")
		door_x = visual_profiles.doorway(&"haunted_mansion_exterior").x
	var destination := Rect2(
		Vector2(roundf(plot.get_center().x - door_x), roundf(plot.end.y - destination_size.y - 8)),
		destination_size
	)
	tile(texture, source, destination)
	if facility_name == "Cafe" and CampaignState.facility_has_upgrade("Cafe", &"cafe_hearth_exchange"):
		# The installed hearth is readable from the field: a warm service awning
		# and two window lights travel with the building when it is relocated.
		var awning := Rect2(destination.position + Vector2(20, destination.size.y - 42), Vector2(destination.size.x - 40, 12))
		draw_rect(awning, Color(0.86, 0.39, 0.16, 0.96), true)
		draw_circle(awning.position + Vector2(18, 20), 6.0, Color(1.0, 0.78, 0.32, 0.92))
		draw_circle(awning.end - Vector2(18, -20), 6.0, Color(1.0, 0.78, 0.32, 0.92))


func _draw_belfry_facility(plot: Rect2) -> void:
	# This pre-sliced facility is a coherent temple front assembled once from the
	# Greek pack's matching wall, column, doorway, and beacon pieces. Runtime draws
	# one individual sprite; it does not balance a giant atlas crop on the grass.
	_draw_facility_foundation(plot)
	var facade := empyreal_slices.get("belfry_building") as Texture2D
	var size := facade.get_size()
	var origin := Vector2(roundf(plot.get_center().x - size.x * 0.5), roundf(plot.end.y - size.y - 7))
	tile(facade, Rect2(Vector2.ZERO, size), Rect2(origin, size))


func _draw_facility_foundation(plot: Rect2) -> void:
	# A compact stone apron seats every facade into the world and gives its door
	# a readable landing. It is built from complete native tiles and remains
	# inside the construction plot, so no clipped scenery bleeds into its neighbor.
	var apron_y := plot.end.y - TILE
	for x in range(1, maxi(2, int(plot.size.x / TILE) - 1)):
		profile_tile(&"town_foundation_stone_tile", town_ground, plot.position + Vector2(x * TILE, apron_y - plot.position.y))


func _draw_observatory_facility(plot: Rect2) -> void:
	# Use one complete futuristic facade from the Bright Cyberpunk pack. The old
	# Observatory was a modern garage with an unrelated spaceship-interior dish
	# perched on top; even with correct individual crops it still read as two
	# loosely stacked props instead of a building. This 91x94 alpha island already
	# contains its roof, curved observation windows, walls, and centered entrance.
	_draw_facility_foundation(plot)
	var building_source := Rect2(483, 2, 91, 94)
	var building_scale: float = FACILITY_SCALES["Observatory"]
	var building_size := building_source.size * building_scale
	var door_x: float = FACILITY_DOOR_X["Observatory"] * building_scale
	var building_origin := Vector2(
		roundf(plot.get_center().x - door_x),
		roundf(plot.end.y - building_size.y - 6)
	)
	tile(helios_structures, building_source, Rect2(building_origin, building_size))


func _draw_afterlight_club_facility(plot: Rect2) -> void:
	# The Club uses one complete 93x94 cyberpunk building island at an exact 2x
	# scale. Its BAR roof sign is one complete sign from the nightclub pack,
	# reduced by exactly 1/2 so both packs share the town's pixel density.
	_draw_facility_foundation(plot)
	var building_source := Rect2(386, 2, 93, 94)
	var building_scale: float = FACILITY_SCALES["Afterlight Club"]
	var building_size := building_source.size * building_scale
	var door_x: float = FACILITY_DOOR_X["Afterlight Club"] * building_scale
	var building_origin := Vector2(
		roundf(plot.get_center().x - door_x),
		roundf(plot.end.y - building_size.y - 6)
	)
	tile(helios_structures, building_source, Rect2(building_origin, building_size))
	var sign_source := Rect2(480, 96, 48, 56)
	var sign_size := sign_source.size
	var sign_origin := Vector2(
		roundf(plot.get_center().x - sign_size.x * 0.5),
		roundf(building_origin.y - 43)
	)
	tile(nightclub_signs, sign_source, Rect2(sign_origin, sign_size))


func set_build_state(is_active: bool, plot_index: int) -> void:
	build_mode = is_active
	selected_plot = plot_index
	queue_redraw()


func set_facility(plot_index: int, facility_name: String) -> void:
	built_facilities[plot_index] = facility_name
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func get_plot_at_canvas_position(canvas_position: Vector2) -> int:
	var local_position := get_global_transform_with_canvas().affine_inverse() * canvas_position
	var town_local := local_position - Vector2(TOWN_ORIGIN * TILE)
	for plot_index in range(FACILITY_PLOTS.size()):
		var cell_plot: Rect2i = FACILITY_PLOTS[plot_index]
		var pixel_plot := Rect2(Vector2(cell_plot.position) * TILE, Vector2(cell_plot.size) * TILE)
		if pixel_plot.has_point(town_local):
			return plot_index
	return -1


func draw_haunted_mansion() -> void:
	if not active_area.begins_with("mansion"):
		return
	var offset := Vector2(MANSION_ORIGIN * TILE)
	var room_offsets := {
		&"mansion_foyer": Vector2i.ZERO,
		&"mansion_archive": MANSION_ARCHIVE_OFFSET,
		&"mansion_gallery": MANSION_GALLERY_OFFSET,
		&"mansion_nursery": MANSION_NURSERY_OFFSET,
		&"mansion_ballroom": MANSION_BALLROOM_OFFSET,
	}
	var active_room_offset := offset + Vector2(room_offsets.get(active_area, Vector2i.ZERO) * TILE)
	draw_rect(Rect2(active_room_offset, Vector2(8 * TILE, 8 * TILE)), Color(0.025, 0.021, 0.028), true)
	match active_area:
		&"mansion_foyer": _draw_mansion_foyer(offset)
		&"mansion_archive": _draw_mansion_archive(offset)
		&"mansion_gallery": _draw_mansion_gallery(offset)
		&"mansion_nursery": _draw_mansion_nursery(offset)
		&"mansion_ballroom": _draw_mansion_ballroom(offset)


func _draw_mansion_foyer(room_offset: Vector2) -> void:
	_draw_mansion_room_shell(room_offset, false)
	profile_tile(&"mansion_foyer_clock", haunted_interior, room_offset + Vector2(20, 18))
	profile_tile(&"mansion_foyer_wall_tableau", haunted_interior, room_offset + Vector2(100, 26))
	profile_tile(&"mansion_archive_cabinet", haunted_interior, room_offset + Vector2(216, 74))
	draw_rect(Rect2(room_offset + Vector2(3 * TILE, 7 * TILE), Vector2(2 * TILE, TILE)), Color(0.36, 0.24, 0.16, 0.32), true)


func _draw_mansion_archive(offset: Vector2) -> void:
	var room_offset := offset + Vector2(MANSION_ARCHIVE_OFFSET * TILE)
	for y in range(4):
		for x in range(8):
			var profile_id: StringName = &"mansion_archive_wall_lit_tile" if (x + y) % 3 == 0 else &"mansion_archive_wall_plain_tile"
			profile_tile(profile_id, haunted_interior, room_offset + Vector2(x, y) * TILE)
	_draw_mansion_plank_floor(room_offset)


func _draw_mansion_gallery(offset: Vector2) -> void:
	var room_offset := offset + Vector2(MANSION_GALLERY_OFFSET * TILE)
	_draw_mansion_room_shell(room_offset, false)


func _draw_mansion_nursery(offset: Vector2) -> void:
	var room_offset := offset + Vector2(MANSION_NURSERY_OFFSET * TILE)
	_draw_mansion_room_shell(room_offset, true)
	profile_tile(&"mansion_nursery_left_wall_panel", haunted_bedroom, room_offset + Vector2(1, 2))
	profile_tile(&"mansion_nursery_right_wall_panel", haunted_bedroom, room_offset + Vector2(193, 2))


func _draw_mansion_ballroom(offset: Vector2) -> void:
	var room_offset := offset + Vector2(MANSION_BALLROOM_OFFSET * TILE)
	_draw_mansion_room_shell(room_offset, false)


func draw_primeval_expanse() -> void:
	if not active_area.begins_with("primeval"):
		return
	var offset := Vector2(PRIMEVAL_ORIGIN * TILE)
	draw_rect(Rect2(offset, Vector2(PRIMEVAL_SIZE * TILE)), Color(0.025, 0.055, 0.018), true)
	var room_definitions := {
		&"primeval_grove": [Vector2i(0, 0), &"grove"],
		&"primeval_village": [Vector2i(10, 0), &"village"],
		&"primeval_ruins": [Vector2i(20, 0), &"ruins"],
		&"primeval_nest": [Vector2i(10, 10), &"nest"],
		&"primeval_caldera": [Vector2i(20, 10), &"caldera"],
	}
	if room_definitions.has(active_area):
		var definition: Array = room_definitions[active_area]
		_draw_primeval_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in room_definitions.values():
		_draw_primeval_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_primeval_room(room_offset: Vector2, room_kind: StringName) -> void:
	# Start from one continuous authored landscape, then compose scenery as a
	# perimeter and destination rather than three objects in a showroom row. The
	# ruins and caldera use the pack's desert half; the living stages retain the
	# grass-and-trail half. All five still preserve the lower traversable band.
	_draw_primeval_room_backdrop(room_offset)
	var ground_source := Rect2(0, 0, 384, 384)
	if room_kind == &"ruins" or room_kind == &"caldera":
		ground_source = Rect2(384, 0, 384, 384)
	tile(primeval_ground, ground_source, Rect2(room_offset, Vector2(384, 384)))
	if room_kind == &"nest":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.02, 0.12, 0.03, 0.16), true)
	elif room_kind == &"caldera":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.28, 0.045, 0.018, 0.30), true)


func _draw_primeval_room_backdrop(room_offset: Vector2) -> void:
	# The first Primeval room begins at the universe edge. Extend its unwalkable
	# jungle understory around the authored ground instead of exposing black
	# engine canvas beyond the camera frame.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.015, 0.075, 0.025), true)
	for x in range(0, int(bounds.size.x), TILE * 2):
		var canopy_y := bounds.position.y + 42.0 + float((x / TILE) % 3) * 18.0
		draw_circle(Vector2(bounds.position.x + x + 36, canopy_y), 38.0, Color(0.045, 0.19, 0.055, 0.62))


func draw_helios_arcology() -> void:
	if not active_area.begins_with("helios"):
		return
	var offset := Vector2(HELIOS_ORIGIN * TILE)
	draw_rect(Rect2(offset, Vector2(HELIOS_SIZE * TILE)), Color(0.28, 0.40, 0.52), true)
	var room_definitions := {
		&"helios_skybridge": [Vector2i(0, 0), &"skybridge"],
		&"helios_market": [Vector2i(10, 0), &"market"],
		&"helios_transit": [Vector2i(20, 0), &"transit"],
		&"helios_clinic": [Vector2i(10, 10), &"clinic"],
		&"helios_core": [Vector2i(20, 10), &"core"],
	}
	if room_definitions.has(active_area):
		var definition: Array = room_definitions[active_area]
		_draw_helios_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in room_definitions.values():
		_draw_helios_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_helios_room(room_offset: Vector2, room_kind: StringName) -> void:
	# Each stage is one untouched 384x384 authored map quadrant. Roads, stairs,
	# counters, walls, and landscaping therefore retain the perspective and
	# proportions designed by the artist; nothing here is assembled from loose
	# decorative atlas fragments.
	_draw_helios_room_backdrop(room_offset)
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.48, 0.60, 0.69), true)
	var texture := helios_city
	var source := Rect2(384, 0, 384, 384)
	match room_kind:
		&"skybridge":
			source = Rect2(384, 0, 384, 384)
		&"market":
			texture = helios_services
			source = Rect2(384, 0, 384, 384)
		&"transit":
			source = Rect2(0, 0, 384, 384)
		&"clinic":
			texture = helios_services
			source = Rect2(384, 384, 384, 384)
		&"core":
			source = Rect2(384, 384, 384, 384)
	tile(texture, source, Rect2(room_offset, Vector2(384, 384)))
	if room_kind == &"core":
		# The core's late-story artificial midnight is a restrained lighting pass,
		# not a replacement texture or a pile of unrelated props.
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.04, 0.08, 0.20, 0.22), true)


func _draw_helios_room_backdrop(room_offset: Vector2) -> void:
	# Helios's authored city quadrants are intentionally compact. The 960x540
	# camera can see beyond their 384px edges, which previously exposed the
	# engine's neutral gray canvas and made the city feel like a cut-out. This is
	# an environmental sky/structural continuation, not a replacement for the
	# approved opaque district panel or an unsafe attempt to split it by color.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	var sky := Color(0.19, 0.32, 0.45)
	draw_rect(bounds, sky, true)
	# Broad atmospheric strata keep the continuation calm behind the detailed
	# authored panel while making the elevated-arcology setting readable.
	draw_rect(Rect2(bounds.position + Vector2(0, 88), Vector2(bounds.size.x, 8)), Color(0.42, 0.70, 0.82, 0.22), true)
	draw_rect(Rect2(bounds.position + Vector2(0, 452), Vector2(bounds.size.x, 12)), Color(0.08, 0.16, 0.25, 0.42), true)
	for x in range(0, int(bounds.size.x), TILE * 3):
		var tower_height := 112.0 + float((x / TILE) % 3) * 56.0
		var tower := Rect2(bounds.position + Vector2(x + 20, bounds.size.y - tower_height), Vector2(104, tower_height))
		draw_rect(tower, Color(0.13, 0.24, 0.36, 0.56), true)
		draw_line(Vector2(tower.position.x + 10, tower.position.y + 18), Vector2(tower.position.x + 10, tower.end.y - 12), Color(0.48, 0.82, 0.94, 0.30), 2.0)


func draw_frosthold_kingdom() -> void:
	if not active_area.begins_with("frosthold"):
		return
	var offset := Vector2(FROSTHOLD_ORIGIN * TILE)
	draw_rect(Rect2(offset, Vector2(FROSTHOLD_SIZE * TILE)), Color(0.025, 0.09, 0.18), true)
	var room_definitions := {
		&"frosthold_gate": [Vector2i(0, 0), &"gate"],
		&"frosthold_market": [Vector2i(10, 0), &"market"],
		&"frosthold_causeway": [Vector2i(20, 0), &"causeway"],
		&"frosthold_rune_hall": [Vector2i(10, 10), &"rune_hall"],
		&"frosthold_throne": [Vector2i(20, 10), &"throne"],
	}
	if room_definitions.has(active_area):
		var definition: Array = room_definitions[active_area]
		_draw_frosthold_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in room_definitions.values():
		_draw_frosthold_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_frosthold_room(room_offset: Vector2, room_kind: StringName) -> void:
	# Each stage gets its own intact snow/ice material, then architecture is massed
	# into an entrance, plaza, bridge, hall, or throne approach. The earlier pass
	# reused one white square and exchanged three objects, which made five rooms
	# feel like five catalog cards.
	_draw_frosthold_room_backdrop(room_offset)
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.07, 0.18, 0.32), true)
	var ground_source := Rect2(72, 198, 192, 192)
	match room_kind:
		&"market": ground_source = Rect2(336, 198, 192, 192)
		&"causeway": ground_source = Rect2(870, 451, 192, 192)
		&"rune_hall": ground_source = Rect2(604, 451, 192, 192)
		&"throne": ground_source = Rect2(1138, 702, 192, 192)
	_draw_frosthold_ground(room_offset, ground_source)


func _draw_frosthold_room_backdrop(room_offset: Vector2) -> void:
	# Frosthold's outer rooms sit on the edge of the larger universe container.
	# Continue the cold, non-navigable snowfield behind their approved architecture
	# so the gate and throne paths never frame against Godot's gray canvas.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.035, 0.12, 0.23), true)
	for x in range(0, int(bounds.size.x), TILE * 2):
		var drift_y := bounds.position.y + 40.0 + float((x / TILE) % 4) * 26.0
		draw_line(Vector2(bounds.position.x + x + 12, drift_y), Vector2(bounds.position.x + x + 72, drift_y), Color(0.58, 0.80, 0.96, 0.20), 2.0)


func _draw_frosthold_ground(room_offset: Vector2, showcase_tile: Rect2) -> void:
	# Ground and props come from the same 2x-density pack. The previous code blew
	# one 192px showcase tile up to 384px while shrinking every building to 50%, a
	# fourfold pixel-density mismatch. Sample only the borderless interior at the
	# same 0.5 scale as the scenery, one 48px movement cell at a time.
	# Eight different showcase tiles supply subtly different borderless interiors.
	# Varying the source tile—not sliding four crops around one tile—prevents the
	# noisy 48px wallpaper pattern visible in the first density-corrected pass.
	var plain_tiles := [
		Vector2(72, 198), Vector2(336, 198), Vector2(600, 198), Vector2(864, 198),
		Vector2(72, 451), Vector2(336, 451), Vector2(600, 451), Vector2(864, 451),
	]
	var room_seed := int(showcase_tile.position.x / 100.0 + showcase_tile.position.y / 100.0)
	for y in range(8):
		for x in range(8):
			var tile_origin: Vector2 = plain_tiles[(x * 3 + y * 5 + room_seed) % plain_tiles.size()]
			var source := Rect2(tile_origin + Vector2(48, 48), Vector2(96, 96))
			tile(frozen_ground, source, Rect2(room_offset + Vector2(x, y) * TILE, Vector2(TILE, TILE)))


func draw_moonpetal_court() -> void:
	if not active_area.begins_with("moonpetal"):
		return
	var offset := Vector2(MOONPETAL_ORIGIN * TILE)
	draw_rect(Rect2(offset, Vector2(MOONPETAL_SIZE * TILE)), Color(0.055, 0.025, 0.095), true)
	var room_definitions := {
		&"moonpetal_gate": [Vector2i(0, 0), &"gate"],
		&"moonpetal_court": [Vector2i(10, 0), &"court"],
		&"moonpetal_garden": [Vector2i(20, 0), &"garden"],
		&"moonpetal_bell_walk": [Vector2i(10, 10), &"bell_walk"],
		&"moonpetal_palace": [Vector2i(20, 10), &"palace"],
	}
	if room_definitions.has(active_area):
		var definition: Array = room_definitions[active_area]
		_draw_moonpetal_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in room_definitions.values():
		_draw_moonpetal_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_moonpetal_room(room_offset: Vector2, room_kind: StringName) -> void:
	# These are authored JRPG spaces, not catalog thumbnails. Each room has one
	# continuous ground plane and one connected processional path. Complete alpha
	# islands define its architecture and edge scenery; nothing is assembled from
	# roof fragments or repeated presentation cards, and every crop begins below
	# the source sheet's headings and category labels.
	_draw_moonpetal_room_backdrop(room_offset)
	var ground_color := Color(0.16, 0.20, 0.12)
	match room_kind:
		&"gate": ground_color = Color(0.20, 0.16, 0.11)
		&"garden": ground_color = Color(0.10, 0.20, 0.18)
		&"bell_walk": ground_color = Color(0.13, 0.15, 0.16)
		&"palace": ground_color = Color(0.18, 0.12, 0.17)
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.045, 0.025, 0.065), true)
	draw_rect(Rect2(room_offset + Vector2(10, 10), Vector2(364, 364)), ground_color, true)
	# Rotate the authored horizontal stone island into a narrow processional lane.
	# At the pack's 0.5 world scale it connects the rear entrance to the lower
	# walkable field without becoming a giant horizontal display plinth.
	_draw_moonpetal_processional_path(room_offset)
	# Tall gates, trees, temples, lanterns, and garden islands render from
	# CampaignMoonpetalForeground so actors can pass behind their upper portions.


func _draw_moonpetal_room_backdrop(room_offset: Vector2) -> void:
	# The court's entry room borders the universe edge. Continue the night-garden
	# palette behind the square playfield while keeping the extension explicitly
	# non-navigable, rather than allowing a gray canvas to frame the gate.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.055, 0.022, 0.085), true)
	for x in range(0, int(bounds.size.x), TILE * 3):
		draw_circle(Vector2(bounds.position.x + x + 48, bounds.position.y + 74), 28.0, Color(0.23, 0.14, 0.30, 0.42))


func _draw_moonpetal_processional_path(room_offset: Vector2) -> void:
	# The source island is 306x114. Drawn at half density and rotated clockwise it
	# becomes a 57x153 path. The transform origin is placed on its upper-right
	# corner because a clockwise rotation extends the destination to the left.
	draw_set_transform(room_offset + Vector2(220, 174), PI * 0.5)
	tile(sakura_paths, Rect2(54, 686, 306, 114), Rect2(Vector2.ZERO, Vector2(153, 57)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_empyreal_court() -> void:
	# These source sheets are deliberately high-detail. Do not composite five
	# off-screen rooms while the player is in town or another universe.
	if not active_area.begins_with("empyreal"):
		return
	var offset := Vector2(EMPYREAL_ORIGIN * TILE)
	var rooms := {
		&"empyreal_landing": [Vector2i(0, 0), &"landing"],
		&"empyreal_garden": [Vector2i(10, 0), &"garden"],
		&"empyreal_forum": [Vector2i(20, 0), &"forum"],
		&"empyreal_aerie": [Vector2i(10, 10), &"aerie"],
		&"empyreal_tribunal": [Vector2i(20, 10), &"tribunal"],
	}
	if rooms.has(active_area):
		var definition: Array = rooms[active_area]
		_draw_empyreal_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in rooms.values():
		_draw_empyreal_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_empyreal_room(room_offset: Vector2, room_kind: StringName) -> void:
	# The Greek pack's showcased floor squares contain a 2x2 set of character-scale
	# tiles. Draw each complete square at 96px—not the former 192px—so its internal
	# grout lands on the game's 48px movement grid. This is now a real terrace with
	# eight-cell proportions instead of two giant catalog samples beneath Ben.
	# The sky extends well beyond the walkable terrace, filling the widescreen
	# camera instead of exposing gray canvas on either side of an 8x8 room.
	# A 384px terrace is shorter than the gameplay camera. Extend the sky above
	# and below the authored platform instead of exposing the renderer's neutral
	# canvas at the bottom of the screen.
	draw_rect(Rect2(room_offset - Vector2(384, 96), Vector2(1152, 576)), Color(0.18, 0.44, 0.72), true)
	for cloud_x in [-424, -40, 344]:
		tile(empyreal_clouds, Rect2(0, 0, 464, 208), Rect2(room_offset + Vector2(cloud_x, 12), Vector2(464, 208)))
	var floor_name: String = String({&"landing": "marble_plain", &"garden": "marble_plain", &"forum": "marble_gold_quarter", &"aerie": "marble_cracked", &"tribunal": "marble_gold_quarter"}.get(room_kind, "marble_plain"))
	for y in range(3):
		for x in range(4):
			_empyreal_tile_slice(floor_name, Rect2(room_offset + Vector2(x * 96, 144 + y * 96), Vector2(96, 96)))
	# One continuous rear balustrade establishes a shared perspective line. Props
	# sit on that line or overlap the terrace; none float as a disconnected row.
	for x in range(0, 384, 96):
		_empyreal_tile_slice("blue_balustrade", Rect2(room_offset + Vector2(x, 124), Vector2(96, 37)))
	if room_kind == &"landing":
		draw_rect(Rect2(room_offset + Vector2(145, 176), Vector2(94, 4)), Color(0.32, 0.19, 0.08, 0.65), true)


func _empyreal_prop(texture: Texture2D, source: Rect2, destination_position: Vector2, scale: float, flip_h := false) -> void:
	var size := source.size * scale
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	tile(texture, source, destination)


func _empyreal_tile_slice(slice_name: String, destination: Rect2) -> void:
	var texture := empyreal_slices.get(slice_name) as Texture2D
	if texture:
		tile(texture, Rect2(Vector2.ZERO, texture.get_size()), destination)


func _empyreal_prop_slice(slice_name: String, destination_position: Vector2, flip_h := false) -> void:
	var texture := empyreal_slices.get(slice_name) as Texture2D
	if not texture:
		return
	var size := texture.get_size()
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	tile(texture, Rect2(Vector2.ZERO, size), destination)


func draw_asterion_station() -> void:
	if not active_area.begins_with("station"):
		return
	var offset := Vector2(STATION_ORIGIN * TILE)
	draw_rect(Rect2(offset, Vector2(STATION_SIZE * TILE)), Color(0.015, 0.025, 0.055), true)
	# At the room-framing camera scale, neighboring rooms would otherwise show as
	# disconnected furniture floating in the surrounding void. Only the room the
	# player occupies is rendered while inside the station.
	var room_definitions := {
		&"station_dock": [Vector2i(0, 0), &"dock"],
		&"station_mess": [Vector2i(10, 0), &"mess"],
		&"station_hydro": [Vector2i(20, 0), &"hydro"],
		&"station_medical": [Vector2i(10, 10), &"medical"],
		&"station_control": [Vector2i(20, 10), &"control"],
	}
	if room_definitions.has(active_area):
		var definition: Array = room_definitions[active_area]
		var room_offset := offset + Vector2(definition[0] * TILE)
		_draw_station_room_backdrop(room_offset)
		_draw_station_room(room_offset, definition[1])
		return
	for definition in room_definitions.values():
		_draw_station_room(offset + Vector2(definition[0] * TILE), definition[1])


func _draw_station_room_backdrop(room_offset: Vector2) -> void:
	# An 8x8 interior is smaller than the 960x540 gameplay camera. Without a
	# local hull pass, the camera exposed Godot's default gray canvas at the room
	# edges, which reads as an unfinished void rather than exterior station space.
	# This is intentionally non-navigable—the navigation layer opens only the
	# painted 8x4 floor—but it gives every room an authored outer boundary.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.008, 0.018, 0.043), true)
	var seam_color := Color(0.10, 0.21, 0.34, 0.38)
	for x in range(0, 21):
		var line_x := bounds.position.x + x * TILE
		draw_line(Vector2(line_x, bounds.position.y), Vector2(line_x, bounds.end.y), seam_color, 2.0)
	for y in range(0, 13):
		var line_y := bounds.position.y + y * TILE
		draw_line(Vector2(bounds.position.x, line_y), Vector2(bounds.end.x, line_y), seam_color, 2.0)


func _draw_station_room(room_offset: Vector2, room_kind: StringName) -> void:
	# Every room is an 8x8 native 48px stage. Wall and floor materials are sampled
	# on their authored grid. All furniture below uses measured opaque bounds for
	# one complete prop; no rectangle crosses into a neighboring atlas object.
	for y in range(8):
		for x in range(8):
			var source := Rect2((x % 2) * 48, (y % 2) * 48, 48, 48)
			if y >= 4:
				source = Rect2((x % 2) * 48, 384 + (y % 2) * 48, 48, 48)
			tile(station_architecture, source, Rect2(room_offset + Vector2(x, y) * TILE, Vector2(TILE, TILE)))
	# A hard baseboard makes the blocked wall area and open floor legible.
	draw_rect(Rect2(room_offset + Vector2(0, 190), Vector2(384, 4)), Color(0.08, 0.16, 0.24, 0.9), true)


func _draw_mansion_room_shell(room_offset: Vector2, bedroom_wall: bool) -> void:
	for y in range(4):
		for x in range(8):
			if bedroom_wall:
				var nursery_profile_id: StringName = MANSION_NURSERY_WALL_PROFILES[y % 2][x % 8]
				profile_tile(nursery_profile_id, haunted_bedroom, room_offset + Vector2(x, y) * TILE)
			else:
				var profile_id: StringName = MANSION_INTERIOR_WALL_PROFILES[y % 2][x % 4]
				profile_tile(profile_id, haunted_interior, room_offset + Vector2(x, y) * TILE)
	_draw_mansion_plank_floor(room_offset)


func _draw_mansion_plank_floor(room_offset: Vector2) -> void:
	# The source showcase has only a 96x96 unobstructed floor fragment. Repeating
	# it produced identical cracks and black seams every two movement cells. Build
	# one continuous staggered board floor instead, using the pack's wood palette.
	var floor_top := 192
	var floor_height := 192
	draw_rect(Rect2(room_offset + Vector2(0, floor_top), Vector2(384, floor_height)), Color("4a342b"), true)
	var board_colors := [Color("543d32"), Color("594034"), Color("4e382f"), Color("5d4437")]
	var board_height := 16
	var board_width := 64
	for row in range(int(floor_height / board_height)):
		var y := floor_top + row * board_height
		var first_x := -32 if row % 2 == 1 else 0
		var board_index := 0
		for board_x in range(first_x, 384, board_width):
			var left := maxi(board_x, 0)
			var right := mini(board_x + board_width, 384)
			if right <= left:
				continue
			var color: Color = board_colors[(row * 2 + board_index) % board_colors.size()]
			var destination := Rect2(room_offset + Vector2(left, y), Vector2(right - left, board_height))
			draw_rect(destination, color, true)
			# Reuse narrow native-resolution grain strips from the clean lower-right
			# portion of the pack's wood floor. Each strip is an approved profile, so
			# this procedural tiling does not reintroduce anonymous atlas rectangles.
			for grain_x in range(left, right, 32):
				var grain_row := (row * 3 + board_index) % 4
				var grain_column := (row + board_index + int((grain_x - left) / 32.0)) % 2
				var grain_profile: StringName = MANSION_PLANK_GRAIN_PROFILES[grain_row][grain_column]
				profile_tile(grain_profile, haunted_interior, room_offset + Vector2(grain_x, y))
			draw_line(room_offset + Vector2(left, y), room_offset + Vector2(right, y), Color("2a1c19"), 2.0)
			if left > 0:
				draw_line(room_offset + Vector2(left, y), room_offset + Vector2(left, y + board_height), Color("34231e"), 1.0)
			# Short deterministic grain strokes keep the floor textured without
			# repeating a conspicuous crack pattern from the showcase panel.
			var grain_x := left + 7 + ((row * 11 + board_index * 17) % 18)
			var grain_end := mini(grain_x + 16 + ((row + board_index) % 15), right - 5)
			if grain_end > grain_x:
				draw_line(room_offset + Vector2(grain_x, y + 5), room_offset + Vector2(grain_end, y + 5), Color("3b2923"), 1.0)
			if (row + board_index) % 2 == 0:
				var second_x := maxi(left + 5, right - 27)
				draw_line(room_offset + Vector2(second_x, y + 11), room_offset + Vector2(right - 7, y + 11), Color("6a4d3f"), 1.0)
			board_index += 1
	# A restrained threshold line visually joins the wall and floor without the
	# repeated torn-board ridge that the sampled atlas fragment introduced.
	draw_rect(Rect2(room_offset + Vector2(0, floor_top - 4), Vector2(384, 6)), Color("2d201c"), true)
