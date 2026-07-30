class_name CampaignMapVisual
extends Node2D

const TILE := 48
const TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
const SANDBOX_VISUAL_RESOLVER := preload("res://ben_rpg/world/sandbox_visual_resolver.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TOWN_ORIGIN := Vector2i(36, 0)
const TOWN_SIZE := Vector2i(32, 28)
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
const FACILITY_PROFILE_IDS := {
	"Cafe": &"town_cafe_facade",
	"Library": &"town_library_facade",
	"Clinic": &"town_clinic_facade",
	"Armory": &"town_armory_facade",
	"Haunted Mansion": &"haunted_mansion_exterior",
	"Trailhead Lodge": &"town_trailhead_lodge_facade",
	"Cold Storage": &"town_cold_storage_facade",
	"Tea House": &"town_tea_house_facade",
}

var town_ground: Texture2D
var helios_structures: Texture2D
var nightclub_signs: Texture2D
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
	town_ground = visual_profiles.texture(&"town_grass_tile")
	helios_structures = visual_profiles.texture(&"helios_observatory_facade")
	nightclub_signs = visual_profiles.texture(&"afterlight_club_sign")
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


func profile_doorway_world_x(profile_id: StringName) -> float:
	# Doorway anchors live in source pixels; facades may draw at a larger world
	# size. Convert once here so every profile-backed facility aligns its painted
	# entrance with the functional plot doorway.
	var source: Rect2 = visual_profiles.region(profile_id)
	var size: Vector2 = visual_profiles.world_draw_size(profile_id)
	if source.size.x <= 0.0:
		return size.x * 0.5
	return visual_profiles.doorway(profile_id).x * size.x / source.size.x


func _draw() -> void:
	# An area transition owns the visible field. Rendering every universe into a
	# single canvas was needlessly expensive and also made an accidental camera
	# limit leak reveal neighbouring rooms. Each area function now opts in below.
	draw_town()


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
	var profile_id: StringName = FACILITY_PROFILE_IDS.get(facility_name, &"")
	if profile_id == &"":
		push_error("Missing facility visual profile: %s" % facility_name)
		return
	var texture: Texture2D = visual_profiles.texture(profile_id)
	var destination_size: Vector2 = visual_profiles.world_draw_size(profile_id)
	var door_x: float = profile_doorway_world_x(profile_id)
	var destination := Rect2(
		Vector2(roundf(plot.get_center().x - door_x), roundf(plot.end.y - destination_size.y - 8)),
		destination_size
	)
	profile_tile(profile_id, texture, destination.position)
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
	var profile_id := &"belfry_building"
	var facade: Texture2D = visual_profiles.texture(profile_id)
	var size: Vector2 = visual_profiles.world_draw_size(profile_id)
	var origin := Vector2(roundf(plot.get_center().x - size.x * 0.5), roundf(plot.end.y - size.y - 7))
	profile_tile(profile_id, facade, origin)


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
	var profile_id := &"helios_observatory_facade"
	var building_size: Vector2 = visual_profiles.world_draw_size(profile_id)
	var door_x: float = profile_doorway_world_x(profile_id)
	var building_origin := Vector2(
		roundf(plot.get_center().x - door_x),
		roundf(plot.end.y - building_size.y - 6)
	)
	profile_tile(profile_id, helios_structures, building_origin)


func _draw_afterlight_club_facility(plot: Rect2) -> void:
	# The Club uses one complete 93x94 cyberpunk building island at an exact 2x
	# scale. Its BAR roof sign is one complete sign from the nightclub pack,
	# reduced by exactly 1/2 so both packs share the town's pixel density.
	_draw_facility_foundation(plot)
	var building_profile := &"afterlight_club_facade"
	var building_size: Vector2 = visual_profiles.world_draw_size(building_profile)
	var door_x: float = profile_doorway_world_x(building_profile)
	var building_origin := Vector2(
		roundf(plot.get_center().x - door_x),
		roundf(plot.end.y - building_size.y - 6)
	)
	profile_tile(building_profile, helios_structures, building_origin)
	var sign_profile := &"afterlight_club_sign"
	var sign_size: Vector2 = visual_profiles.world_draw_size(sign_profile)
	var sign_origin := Vector2(
		roundf(plot.get_center().x - sign_size.x * 0.5),
		roundf(building_origin.y - 43)
	)
	profile_tile(sign_profile, nightclub_signs, sign_origin)


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
