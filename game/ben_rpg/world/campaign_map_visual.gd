class_name CampaignMapVisual
extends Node2D

const TILE := 48
const TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
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
const LAB_EXTERIOR_CROP := Rect2(672, 5, 96, 91)
const LAB_EXTERIOR_DRAW_SIZE := Vector2(192, 182)
const HAUNTED_EXTERIOR_CROP := Rect2(384, 0, 240, 160)

var lab_wall: Texture2D
var lab_utility: Texture2D
var lab_props: Texture2D
var lab_doors: Texture2D
var ground: Texture2D
var town_ground: Texture2D
var trees: Texture2D
var town_structures: Texture2D
var library_facade: Texture2D
var haunted_exterior: Texture2D
var haunted_interior: Texture2D
var haunted_storage: Texture2D
var haunted_bedroom: Texture2D
var station_architecture: Texture2D
var station_mess: Texture2D
var station_hydro: Texture2D
var station_command: Texture2D
var station_general: Texture2D
var station_exterior: Texture2D
var station_medical: Texture2D
var primeval_ground: Texture2D
var primeval_structures: Texture2D
var primeval_props: Texture2D
var primeval_trees: Texture2D
var primeval_ruins: Texture2D
var primeval_nests: Texture2D
var helios_city: Texture2D
var helios_services: Texture2D
var helios_structures: Texture2D
var nightclub_signs: Texture2D
var frozen_ground: Texture2D
var frozen_houses: Texture2D
var frozen_castle: Texture2D
var frozen_crystals: Texture2D
var frozen_ruins: Texture2D
var frozen_runes: Texture2D
var frozen_trees: Texture2D
var frozen_bridges: Texture2D
var frozen_market: Texture2D
var frozen_torches: Texture2D
var sakura_floor: Texture2D
var sakura_temple: Texture2D
var sakura_trees: Texture2D
var sakura_gates: Texture2D
var sakura_gardens: Texture2D
var sakura_water: Texture2D
var sakura_lanterns: Texture2D
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


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lab_wall = load("res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png")
	lab_utility = load("res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/2.png")
	lab_props = load("res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/3.png")
	lab_doors = load("res://game_assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/4.png")
	ground = load("res://game_assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png")
	town_ground = load("res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/2.png")
	trees = load("res://game_assets/Tilesets/Ranch Stuff/assets/tiles/tree_01_16x16.png")
	town_structures = load("res://game_assets/Tilesets/Modern World Overworld Pixel Tileset/3.png")
	library_facade = _slice_sample_facade(town_structures, FACILITY_CROPS["Library"])
	haunted_exterior = load("res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/1.png")
	haunted_interior = load("res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png")
	haunted_bedroom = load("res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/3.png")
	haunted_storage = load("res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/4.png")
	station_architecture = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/1.png")
	station_mess = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/2.png")
	station_hydro = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/3.png")
	station_command = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/6.png")
	station_general = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/7.png")
	station_exterior = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/8.png")
	station_medical = load("res://game_assets/Tilesets/Sci-Fi Spaceship Interior Tileset Pack/10.png")
	primeval_ground = load("res://game_assets/Tilesets/Stone Age Modern Life Pixel Art Tileset Pack/9.png")
	primeval_structures = load("res://game_assets/Tilesets/Stone Age Modern Life Pixel Art Tileset Pack/1.png")
	primeval_props = load("res://game_assets/Tilesets/Stone Age Modern Life Pixel Art Tileset Pack/7.png")
	primeval_trees = load("res://game_assets/Tilesets/Jurassic world/Jurassic World Pixel Art Megapack/7. Tropical trees and ferns.png")
	primeval_ruins = load("res://game_assets/Tilesets/Jurassic world/Jurassic World Pixel Art Megapack/19. Modular jungle ruins.png")
	primeval_nests = load("res://game_assets/Tilesets/Jurassic world/Jurassic World Pixel Art Megapack/11. Dinosaur nests and eggs.png")
	helios_city = load("res://game_assets/Tilesets/Bright Cyberpunk Pixel Art Tileset Pack/1.png")
	helios_services = load("res://game_assets/Tilesets/Bright Cyberpunk Pixel Art Tileset Pack/5.png")
	helios_structures = load("res://game_assets/Tilesets/Bright Cyberpunk Pixel Art Tileset Pack/3.png")
	nightclub_signs = load("res://game_assets/Tilesets/Modern Bar & Nightclub Pixel Art Tileset Pack/4.png")
	frozen_ground = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/1. Snow ground tiles.png")
	frozen_houses = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/7. Nordic wooden houses.png")
	frozen_castle = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/5. Ice castle walls.png")
	frozen_crystals = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/9. Crystal formations.png")
	frozen_ruins = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/13. Frozen ruins.png")
	frozen_runes = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/14. Magical runes.png")
	frozen_trees = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/10. Frozen Trees and pines.png")
	frozen_bridges = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/8. Icy bridges.png")
	frozen_market = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/16. Frozen market stalls.png")
	frozen_torches = load("res://game_assets/Tilesets/Frozen kingdom/Frozen Kingdom – Top-Down Pixel Art Asset Pack/12. Torches and blue flames.png")
	sakura_floor = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Floor tiles.png")
	sakura_temple = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/temple building parts.png")
	sakura_trees = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Sakura trees.png")
	sakura_gates = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Shrine Gates.png")
	sakura_gardens = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Decorative framed garden tiles.png")
	sakura_water = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Water and ponds.png")
	sakura_lanterns = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Lanterns and lights.png")
	sakura_paths = load("res://game_assets/Tilesets/Sakura Temple Asset Pack/Stone patchs and walkways.png")
	empyreal_clouds = load("res://game_assets/Tilesets/Flying Islands/PNG/Sliced/sky_clouds.png")
	for slice_name in ["marble_plain", "marble_cracked", "marble_silver", "marble_gold", "marble_gold_quarter", "pediment_door", "tribunal_gate", "blue_balustrade", "winged_statue", "horse_statue", "griffin_statue", "justice_statue", "music_statue", "silver_olive_tree", "golden_olive_tree", "appeal_fountain", "ordinance_book", "reliquary_portal", "gravity_crystal", "tribunal_orrery", "celestial_flame", "plain_column", "blue_column", "flower_offering", "fruit_offering", "crystal_altar", "lotus_altar", "belfry_facade", "belfry_building"]:
		empyreal_slices[slice_name] = load("res://game_assets/Tilesets/Ancient Greek Mythology/Sliced/%s.png" % slice_name)
	if not CampaignState.town_terrain_changed.is_connected(_on_town_terrain_changed):
		CampaignState.town_terrain_changed.connect(_on_town_terrain_changed)
	queue_redraw()


func tile(texture: Texture2D, source: Rect2, destination: Rect2) -> void:
	if texture:
		draw_texture_rect_region(texture, destination, source)


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
	for y in range(LAB_SIZE.y):
		for x in range(LAB_SIZE.x):
			var source := Rect2(192, 0, 48, 48) if y <= 2 else Rect2(0, 0, 48, 48)
			tile(lab_wall, source, Rect2(x * TILE, y * TILE, TILE, TILE))
	# Rear-wall architecture remains in two coherent banks: a labeled observation
	# bay and one complete ventilation run. The floor equipment below is cut into
	# individual alpha islands; the previous 336px/384px row crops reproduced the
	# atlas's presentation rows and made unrelated benches touch edge-to-edge.
	tile(lab_utility, Rect2(192, 0, 192, 96), Rect2(TILE, TILE, 192, 96))
	tile(lab_utility, Rect2(384, 0, 384, 192), Rect2(11 * TILE, 0, 384, 192))
	# West analysis bank: three distinct stations with breathing room.
	tile(lab_props, Rect2(1, 166, 95, 122), Rect2(Vector2(48, 190), Vector2(95, 122)))
	tile(lab_props, Rect2(145, 166, 95, 73), Rect2(Vector2(166, 198), Vector2(95, 73)))
	tile(lab_props, Rect2(289, 166, 95, 73), Rect2(Vector2(282, 198), Vector2(95, 73)))
	# East fabrication bank mirrors the footprint without duplicating the art.
	tile(lab_props, Rect2(385, 166, 95, 73), Rect2(Vector2(528, 198), Vector2(95, 73)))
	tile(lab_props, Rect2(481, 166, 95, 73), Rect2(Vector2(646, 198), Vector2(95, 73)))
	tile(lab_props, Rect2(577, 166, 95, 73), Rect2(Vector2(764, 198), Vector2(95, 73)))
	# Two contained fume hoods define the lower work alcoves. They stay entirely
	# outside the central invention aisle and no longer include neighbouring atlas
	# stools, cabinets, or blank presentation cells.
	tile(lab_props, Rect2(2, 384, 93, 96), Rect2(Vector2(48, 384), Vector2(93, 96)))
	tile(lab_props, Rect2(146, 384, 93, 96), Rect2(Vector2(190, 384), Vector2(93, 96)))
	tile(lab_props, Rect2(386, 384, 93, 141), Rect2(Vector2(676, 350), Vector2(93, 141)))
	tile(lab_props, Rect2(482, 384, 93, 141), Rect2(Vector2(790, 350), Vector2(93, 141)))
	# A coherent double-door crop marks the physical exit at the bottom wall.
	tile(lab_doors, Rect2(0, 0, 96, 96), Rect2(9 * TILE, 10 * TILE, 96, 96))


func draw_town() -> void:
	var offset := Vector2(TOWN_ORIGIN * TILE)
	for y in range(TOWN_SIZE.y):
		for x in range(TOWN_SIZE.x):
			var road := x == 14 or y == 10
			# Both samples are native 48px world tiles from the same pack as the town
			# facades. This avoids the former 3x Ranch pixels and flat orange roads.
			var source := Rect2(600, 48, 48, 48) if road else Rect2(336, 96, 48, 48)
			tile(town_ground, source, Rect2(offset + Vector2(x, y) * TILE, Vector2(TILE, TILE)))
	_draw_terrain_overrides()
	if not CampaignState.sandbox_mode:
		_draw_facility_approaches(offset)
	# Campaign mode keeps its authored laboratory and construction plots. Sandbox
	# mode represents the laboratory and trees as persistent editor objects, so
	# they can be selected and relocated instead of being baked into this layer.
	if not CampaignState.sandbox_mode:
		# The source atlas places three industrial buildings side by side. Crop only
		# the blue warehouse's authored 96px cell, then enlarge at an exact 2x scale.
		var lab_size := LAB_EXTERIOR_DRAW_SIZE
		var lab_center_x := offset.x + 14 * TILE
		var lab_destination := Rect2(
			Vector2(lab_center_x - lab_size.x * 0.5, offset.y + 7 * TILE - lab_size.y),
			lab_size
		)
		draw_rect(Rect2(lab_destination.position + Vector2(7, lab_destination.size.y - 14), Vector2(lab_destination.size.x - 14, 18)), Color(0.04, 0.07, 0.04, 0.28), true)
		tile(town_structures, LAB_EXTERIOR_CROP, lab_destination)
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
		for entry in [[2, 2, false], [29, 3, true], [3, 20, true], [30, 20, false]]:
			var source := Rect2(32, 0, 48, 64) if entry[2] else Rect2(0, 0, 32, 48)
			var size := Vector2(96, 128) if entry[2] else Vector2(64, 96)
			var center := offset + Vector2(entry[0], entry[1]) * TILE
			tile(trees, source, Rect2(center - Vector2(size.x * 0.5, size.y * 0.75), size))


func _draw_terrain_overrides() -> void:
	for cell in CampaignState.town_terrain_cells():
		var brush_id := CampaignState.town_terrain_at(cell)
		var definition: Dictionary = TERRAIN_CATALOG.definition(brush_id)
		if definition.is_empty():
			continue
		var texture_path := String(definition.get("texture", ""))
		if not ResourceLoader.exists(texture_path):
			continue
		if not _terrain_texture_cache.has(texture_path):
			_terrain_texture_cache[texture_path] = load(texture_path)
		var texture := _terrain_texture_cache[texture_path] as Texture2D
		var source: Rect2 = definition.get("region", Rect2(Vector2.ZERO, texture.get_size()))
		tile(texture, source, Rect2(Vector2(cell * TILE), Vector2(TILE, TILE)))


func _on_town_terrain_changed() -> void:
	queue_redraw()


func _draw_facility_approaches(offset: Vector2) -> void:
	if built_facilities.is_empty():
		return
	var road_source := Rect2(600, 48, 48, 48)
	var has_southern_facility := false
	var deep_south_min_x := TOWN_SIZE.x
	var deep_south_max_x := -1
	for plot_key in built_facilities.keys():
		var plot: Rect2i = FACILITY_PLOTS[int(plot_key)]
		var door_x := plot.position.x + int(plot.size.x / 2)
		if plot.position.y < 10:
			# Northern plots face the original east-west road.
			for y in range(plot.end.y - 1, 11):
				tile(town_ground, road_source, Rect2(offset + Vector2(door_x, y) * TILE, Vector2(TILE, TILE)))
		else:
			has_southern_facility = true
			if plot.position.y >= 20:
				# Later town expansion uses a short second lane below the original
				# neighborhood, keeping the Tea House's south-facing doorway clear.
				for y in range(plot.end.y - 1, 27):
					tile(town_ground, road_source, Rect2(offset + Vector2(door_x, y) * TILE, Vector2(TILE, TILE)))
				deep_south_min_x = mini(deep_south_min_x, door_x)
				deep_south_max_x = maxi(deep_south_max_x, door_x)
				continue
			# Southern buildings meet a shared lane below their front doors.
			for y in range(plot.end.y - 1, 19):
				tile(town_ground, road_source, Rect2(offset + Vector2(door_x, y) * TILE, Vector2(TILE, TILE)))
	if has_southern_facility:
		for x in range(1, 31):
			tile(town_ground, road_source, Rect2(offset + Vector2(x, 18) * TILE, Vector2(TILE, TILE)))
	if deep_south_max_x >= 0:
		# Connect whichever deep-south plots were chosen instead of assuming two
		# fixed plot indexes. This also serves the new southwest construction site.
		for x in range(maxi(1, deep_south_min_x - 2), mini(TOWN_SIZE.x - 1, deep_south_max_x + 3)):
			tile(town_ground, road_source, Rect2(offset + Vector2(x, 26) * TILE, Vector2(TILE, TILE)))


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
	var destination := Rect2(
		Vector2(roundf(plot.get_center().x - door_x), roundf(plot.end.y - destination_size.y - 8)),
		destination_size
	)
	tile(texture, source, destination)


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
	var stone_source := Rect2(600, 96, 48, 48)
	var apron_y := plot.end.y - TILE
	for x in range(1, maxi(2, int(plot.size.x / TILE) - 1)):
		tile(town_ground, stone_source, Rect2(plot.position + Vector2(x * TILE, apron_y - plot.position.y), Vector2(TILE, TILE)))


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
	var offset := Vector2(MANSION_ORIGIN * TILE)
	var mansion_rect := Rect2(offset, Vector2(MANSION_SIZE * TILE))
	draw_rect(mansion_rect, Color(0.025, 0.021, 0.028), true)
	# The old foyer was a full showcase panel with a ghost, mixed wood/stone floor,
	# wardrobe, shelf, and door baked together. Build one clean room shell, then
	# place only complete transparent furniture islands at native scale.
	_draw_mansion_room_shell(offset, false)
	tile(haunted_interior, Rect2(392, 2, 80, 95), Rect2(offset + Vector2(20, 18), Vector2(80, 95)))
	tile(haunted_interior, Rect2(388, 110, 184, 83), Rect2(offset + Vector2(100, 26), Vector2(184, 83)))
	# The stopped clock's authored island sits within the staircase grouping but
	# this measured crop contains only the clock. (584,105) is a chandelier.
	# Seat the clock's base on the wall/floor threshold. Its old y=116 placement
	# extended almost a full movement cell into the walkable floor.
	tile(haunted_interior, Rect2(592, 268, 64, 118), Rect2(offset + Vector2(216, 74), Vector2(64, 118)))
	draw_rect(Rect2(offset + Vector2(3 * TILE, 7 * TILE), Vector2(2 * TILE, TILE)), Color(0.36, 0.24, 0.16, 0.32), true)

	# The servants' archive is authored from repeatable clean wall/floor patches,
	# then furnished with isolated alpha crops from pack 4. It is not another
	# precomposed atlas panel, so props can become independent game objects later.
	var archive_offset := offset + Vector2(MANSION_ARCHIVE_OFFSET * TILE)
	for y in range(4):
		for x in range(8):
			var source := Rect2(0, 0, 48, 48)
			if (x + y) % 3 == 0:
				source = Rect2(48, 0, 48, 48)
			tile(haunted_interior, source, Rect2(archive_offset + Vector2(x, y) * TILE, Vector2(TILE, TILE)))
	_draw_mansion_plank_floor(archive_offset)
	# Storage fixtures are individual atlas islands, placed at their native size.
	tile(haunted_storage, Rect2(0, 0, 190, 180), Rect2(archive_offset + Vector2(0, 0), Vector2(190, 180)))
	tile(haunted_storage, Rect2(190, 0, 190, 176), Rect2(archive_offset + Vector2(4 * TILE, 0), Vector2(190, 176)))
	# Do not stamp smaller crops taken from those same crate islands over the floor.
	# That duplicated the upper-left crates and produced visibly intersecting boxes.
	# Matching passage doors sit on the room edges at a character-relative size.
	# Their former 88x96 placement covered the clock puzzle and read as a giant
	# foreground prop instead of architecture.
	var passage_size := Vector2(66, 72)
	tile(haunted_storage, Rect2(296, 672, 88, 96), Rect2(offset + Vector2(6.6, 2.65) * TILE, passage_size))
	tile(haunted_storage, Rect2(296, 672, 88, 96), Rect2(archive_offset + Vector2(0.05, 2.65) * TILE, passage_size))
	# A second clock is the scenario's save/restore anchor.
	tile(haunted_interior, Rect2(592, 268, 64, 118), Rect2(archive_offset + Vector2(2.35, 1.55) * TILE, Vector2(64, 118)))

	# The atlas's lower-left 384px panel is a material sampler, not one authored
	# room: it contains wood, cracked stone, blood, and broken-wall examples in
	# adjoining quadrants. Build a consistent shell and furnish it with isolated
	# sprites instead of presenting those sampler boundaries as overlapping tiles.
	var gallery_offset := offset + Vector2(MANSION_GALLERY_OFFSET * TILE)
	_draw_mansion_room_shell(gallery_offset, false)
	# Two intact bookcases frame four separately cut family portraits. None of
	# these regions crosses into its neighbour on the storage atlas.
	tile(haunted_storage, Rect2(194, 5, 91, 137), Rect2(gallery_offset + Vector2(18, 14), Vector2(91, 137)))
	tile(haunted_storage, Rect2(291, 5, 91, 137), Rect2(gallery_offset + Vector2(275, 14), Vector2(91, 137)))
	tile(haunted_storage, Rect2(681, 386, 37, 43), Rect2(gallery_offset + Vector2(126, 44), Vector2(37, 43)))
	tile(haunted_storage, Rect2(721, 386, 46, 43), Rect2(gallery_offset + Vector2(210, 44), Vector2(46, 43)))
	tile(haunted_storage, Rect2(678, 440, 36, 41), Rect2(gallery_offset + Vector2(128, 99), Vector2(36, 41)))
	tile(haunted_storage, Rect2(726, 431, 37, 50), Rect2(gallery_offset + Vector2(214, 93), Vector2(37, 50)))
	# One complete horizontal rug anchors the investigation area without covering
	# either doorway or being cut by the room material seams.
	tile(haunted_interior, Rect2(423, 679, 210, 82), Rect2(gallery_offset + Vector2(87, 221), Vector2(210, 82)))

	# Bedroom sheet 3 contains props on transparency, so the nursery gets a
	# clean native-grid shell first and only isolated furniture is layered over it.
	var nursery_offset := offset + Vector2(MANSION_NURSERY_OFFSET * TILE)
	_draw_mansion_room_shell(nursery_offset, true)
	# These two 190px authored bedroom bays were previously placed only 180px
	# apart, creating a real 10px overlap through the bedposts and wall dressing.
	# Preserve their source-sheet two-pixel gutter in the room as well.
	tile(haunted_bedroom, Rect2(0, 0, 190, 190), Rect2(nursery_offset + Vector2(1, 2), Vector2(190, 190)))
	tile(haunted_bedroom, Rect2(192, 0, 190, 190), Rect2(nursery_offset + Vector2(193, 2), Vector2(190, 190)))
	tile(haunted_storage, Rect2(583, 69, 46, 66), Rect2(nursery_offset + Vector2(5.85, 2.35) * TILE, Vector2(46, 66)))
	tile(haunted_bedroom, Rect2(579, 302, 56, 78), Rect2(nursery_offset + Vector2(1.1, 2.15) * TILE, Vector2(56, 78)))

	# The final room uses the same architectural material language, but furniture
	# from the foyer sheet makes it read as a ballroom rather than another bedroom.
	var ballroom_offset := offset + Vector2(MANSION_BALLROOM_OFFSET * TILE)
	_draw_mansion_room_shell(ballroom_offset, false)
	# The old 250px crop crossed from a chandelier into the neighbouring couch,
	# moving two unrelated sprites as one slab. These are their exact alpha-island
	# bounds, arranged symmetrically around the intact settee.
	tile(haunted_interior, Rect2(575, 9, 191, 88), Rect2(ballroom_offset + Vector2(97, 22), Vector2(191, 88)))
	tile(haunted_interior, Rect2(490, 12, 76, 77), Rect2(ballroom_offset + Vector2(17, 40), Vector2(76, 77)))
	tile(haunted_interior, Rect2(490, 12, 76, 77), Rect2(ballroom_offset + Vector2(291, 40), Vector2(76, 77)))
	# Keep the center floor open for the scenario boss. A rug under its marker made
	# the two silhouettes read as another pair of intersecting atlas crops.


func draw_primeval_expanse() -> void:
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
	var ground_source := Rect2(0, 0, 384, 384)
	if room_kind == &"ruins" or room_kind == &"caldera":
		ground_source = Rect2(384, 0, 384, 384)
	tile(primeval_ground, ground_source, Rect2(room_offset, Vector2(384, 384)))
	if room_kind == &"nest":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.02, 0.12, 0.03, 0.16), true)
	elif room_kind == &"caldera":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.28, 0.045, 0.018, 0.30), true)
	# Jurassic art is authored at twice the field pixel density. Every Jurassic
	# island below is reduced by exactly 1/2 with nearest filtering.
	match room_kind:
		&"grove":
			# A dense canopy frames a municipal trailhead and leaves a deliberate
			# opening through the center instead of scattering three palms in grass.
			_primeval_prop(primeval_trees, Rect2(40, 447, 134, 178), room_offset + Vector2(-8, 20), 0.5)
			_primeval_prop(primeval_trees, Rect2(196, 453, 121, 172), room_offset + Vector2(58, 14), 0.5)
			_primeval_prop(primeval_trees, Rect2(509, 451, 132, 176), room_offset + Vector2(258, 16), 0.5)
			_primeval_prop(primeval_trees, Rect2(665, 450, 132, 176), room_offset + Vector2(325, 20), 0.5)
			_primeval_prop(primeval_trees, Rect2(49, 665, 105, 80), room_offset + Vector2(14, 152), 0.5)
			_primeval_prop(primeval_trees, Rect2(1125, 664, 108, 82), room_offset + Vector2(320, 152), 0.5)
			_primeval_prop(primeval_props, Rect2(689, 4, 65, 190), room_offset + Vector2(176, 74), 0.5)
		&"village":
			# Two dwellings and a shared awning create a small settlement around a
			# central hearth; the edges remain inhabited without blocking the route.
			_primeval_prop(primeval_structures, Rect2(387, 2, 90, 92), room_offset + Vector2(24, 36))
			_primeval_prop(primeval_structures, Rect2(483, 1, 90, 95), room_offset + Vector2(270, 32))
			_primeval_prop(primeval_structures, Rect2(203, 197, 170, 88), room_offset + Vector2(107, 62), 1.0)
			_primeval_prop(primeval_structures, Rect2(491, 190, 50, 50), room_offset + Vector2(167, 142), 1.0)
			_primeval_prop(primeval_structures, Rect2(7, 394, 178, 90), room_offset + Vector2(-8, 132), 0.65)
			_primeval_prop(primeval_structures, Rect2(195, 394, 180, 90), room_offset + Vector2(280, 132), 0.65)
		&"ruins":
			# A single temple forecourt: idol at the rear, broken walls forming its
			# shoulders, and two approach stones defining the playable aisle.
			_primeval_prop(primeval_ruins, Rect2(1315, 504, 155, 167), room_offset + Vector2(153, 20), 0.5)
			_primeval_prop(primeval_ruins, Rect2(48, 197, 124, 132), room_offset + Vector2(34, 42), 0.5)
			_primeval_prop(primeval_ruins, Rect2(608, 197, 125, 132), room_offset + Vector2(288, 42), 0.5)
			_primeval_prop(primeval_ruins, Rect2(53, 380, 121, 104), room_offset + Vector2(36, 139), 0.5)
			_primeval_prop(primeval_ruins, Rect2(803, 380, 143, 103), room_offset + Vector2(276, 139), 0.5)
		&"nest":
			# The clutch sits inside a vegetation bowl, with empty nests pushed to
			# the edges so the composition reads as habitat rather than inventory.
			_primeval_prop(primeval_trees, Rect2(40, 447, 134, 178), room_offset + Vector2(8, 26), 0.5)
			_primeval_prop(primeval_trees, Rect2(665, 450, 132, 176), room_offset + Vector2(310, 28), 0.5)
			_primeval_prop(primeval_nests, Rect2(15, 265, 176, 153), room_offset + Vector2(148, 54), 0.5)
			_primeval_prop(primeval_nests, Rect2(19, 454, 170, 134), room_offset + Vector2(14, 124), 0.5)
			_primeval_prop(primeval_nests, Rect2(391, 448, 172, 142), room_offset + Vector2(286, 120), 0.5)
			_primeval_prop(primeval_trees, Rect2(49, 665, 105, 80), room_offset + Vector2(74, 146), 0.5)
			_primeval_prop(primeval_trees, Rect2(1125, 664, 108, 82), room_offset + Vector2(270, 146), 0.5)
			# Complete stone traffic totem, half-scale like the rest of Primeval.
			# Its base is centered on the actual Anchor Totem interaction cell.
			_primeval_prop(primeval_props, Rect2(689, 4, 65, 190), room_offset + Vector2(104, 73), 0.5)
		&"caldera":
			# The caldera is a ruined fire shrine built from actual pack islands. A
			# previous vector trapezoid looked like a temporary editor placeholder.
			_primeval_prop(primeval_ruins, Rect2(548, 520, 180, 145), room_offset + Vector2(147, 18), 0.5)
			_primeval_prop(primeval_ruins, Rect2(48, 197, 124, 132), room_offset + Vector2(30, 38), 0.5)
			_primeval_prop(primeval_ruins, Rect2(608, 197, 125, 132), room_offset + Vector2(292, 38), 0.5)
			_primeval_prop(primeval_ruins, Rect2(367, 712, 99, 123), room_offset + Vector2(168, 86), 0.5)
			_primeval_prop(primeval_ruins, Rect2(48, 879, 100, 104), room_offset + Vector2(48, 132), 0.5)
			_primeval_prop(primeval_ruins, Rect2(997, 888, 128, 96), room_offset + Vector2(274, 136), 0.5)


func _primeval_prop(texture: Texture2D, source: Rect2, destination_position: Vector2, scale_factor := 1.0) -> void:
	var size := source.size * scale_factor
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	tile(texture, source, Rect2(position, size))


func draw_helios_arcology() -> void:
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


func draw_frosthold_kingdom() -> void:
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
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.07, 0.18, 0.32), true)
	var ground_source := Rect2(72, 198, 192, 192)
	match room_kind:
		&"market": ground_source = Rect2(336, 198, 192, 192)
		&"causeway": ground_source = Rect2(870, 451, 192, 192)
		&"rune_hall": ground_source = Rect2(604, 451, 192, 192)
		&"throne": ground_source = Rect2(1138, 702, 192, 192)
	_draw_frosthold_ground(room_offset, ground_source)
	match room_kind:
		&"gate":
			_frosthold_prop(frozen_trees, Rect2(795, 184, 187, 260), room_offset + Vector2(-8, 32))
			_frosthold_prop(frozen_trees, Rect2(1180, 184, 184, 260), room_offset + Vector2(300, 34))
			_frosthold_prop(frozen_castle, Rect2(933, 734, 347, 224), room_offset + Vector2(105, 24))
			_frosthold_prop(frozen_ruins, Rect2(39, 172, 165, 178), room_offset + Vector2(22, 103))
			_frosthold_prop(frozen_ruins, Rect2(228, 172, 164, 178), room_offset + Vector2(280, 103))
			_frosthold_prop(frozen_torches, Rect2(77, 170, 94, 205), room_offset + Vector2(120, 89))
			_frosthold_prop(frozen_torches, Rect2(246, 170, 94, 205), room_offset + Vector2(220, 89))
		&"market":
			# A street, not three identical houses: two trading stalls face a warm
			# communal brazier while homes close the rear of the plaza.
			_frosthold_prop(frozen_houses, Rect2(29, 198, 182, 240), room_offset + Vector2(-8, 12))
			_frosthold_prop(frozen_houses, Rect2(478, 183, 202, 255), room_offset + Vector2(290, 8))
			_frosthold_prop(frozen_market, Rect2(65, 202, 205, 233), room_offset + Vector2(44, 72))
			_frosthold_prop(frozen_market, Rect2(326, 202, 201, 233), room_offset + Vector2(238, 72))
			_frosthold_prop(frozen_market, Rect2(1082, 460, 126, 194), room_offset + Vector2(160, 92))
		&"causeway":
			# A complete bridge provides the focal route; crystals form banks rather
			# than decorative bookends floating on an empty snow tile.
			_frosthold_prop(frozen_crystals, Rect2(59, 170, 168, 242), room_offset + Vector2(10, 36))
			_frosthold_prop(frozen_crystals, Rect2(286, 176, 184, 230), room_offset + Vector2(286, 40))
			_frosthold_prop(frozen_bridges, Rect2(45, 174, 170, 215), room_offset + Vector2(149, 20))
			_frosthold_prop(frozen_bridges, Rect2(280, 174, 170, 215), room_offset + Vector2(149, 122))
			# Tuck the rune under the final bridge lip so the route has a visible
			# landing instead of ending in a strip of bare snow.
			_frosthold_prop(frozen_runes, Rect2(61, 736, 127, 128), room_offset + Vector2(160, 226))
		&"rune_hall":
			_frosthold_prop(frozen_castle, Rect2(728, 741, 172, 217), room_offset + Vector2(26, 28))
			_frosthold_prop(frozen_castle, Rect2(933, 734, 347, 224), room_offset + Vector2(105, 22))
			_frosthold_prop(frozen_castle, Rect2(728, 741, 172, 217), room_offset + Vector2(270, 28))
			_frosthold_prop(frozen_torches, Rect2(77, 170, 94, 205), room_offset + Vector2(76, 90))
			_frosthold_prop(frozen_torches, Rect2(246, 170, 94, 205), room_offset + Vector2(262, 90))
			_frosthold_prop(frozen_runes, Rect2(237, 736, 129, 128), room_offset + Vector2(104, 232))
			_frosthold_prop(frozen_runes, Rect2(414, 736, 127, 128), room_offset + Vector2(216, 232))
		&"throne":
			_frosthold_prop(frozen_castle, Rect2(41, 718, 105, 242), room_offset + Vector2(34, 28))
			_frosthold_prop(frozen_castle, Rect2(175, 718, 106, 242), room_offset + Vector2(298, 28))
			_frosthold_prop(frozen_castle, Rect2(933, 734, 347, 224), room_offset + Vector2(105, 34))
			# Leave a proper boss-sized silhouette between the braziers.
			_frosthold_prop(frozen_torches, Rect2(77, 170, 94, 205), room_offset + Vector2(78, 90))
			_frosthold_prop(frozen_torches, Rect2(246, 170, 94, 205), room_offset + Vector2(270, 90))
			_frosthold_prop(frozen_runes, Rect2(1320, 736, 128, 128), room_offset + Vector2(160, 238))


func _frosthold_prop(texture: Texture2D, source: Rect2, destination_position: Vector2, flip_h := false) -> void:
	var size := source.size * 0.5
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	tile(texture, source, destination)


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
	match room_kind:
		&"gate":
			_moonpetal_prop(sakura_gates, Rect2(16, 145, 145, 170), room_offset + Vector2(120, 20), 1.0)
			_moonpetal_prop(sakura_lanterns, Rect2(37, 331, 115, 145), room_offset + Vector2(2, 115), 0.5)
			_moonpetal_prop(sakura_lanterns, Rect2(164, 331, 114, 145), room_offset + Vector2(325, 115), 0.5)
		&"court":
			_moonpetal_prop(sakura_temple, Rect2(40, 158, 372, 258), room_offset + Vector2(99, 18), 0.5)
			_moonpetal_prop(sakura_trees, Rect2(55, 548, 255, 250), room_offset + Vector2(8, 66), 0.5)
			_moonpetal_prop(sakura_trees, Rect2(326, 548, 245, 250), room_offset + Vector2(238, 66), 0.5)
		&"garden":
			_moonpetal_prop(sakura_water, Rect2(246, 148, 264, 150), room_offset + Vector2(60, 24), 1.0)
			_moonpetal_prop(sakura_gardens, Rect2(68, 133, 184, 174), room_offset + Vector2(14, 99), 0.5)
			_moonpetal_prop(sakura_gardens, Rect2(681, 133, 184, 174), room_offset + Vector2(277, 99), 0.5)
		&"bell_walk":
			_moonpetal_prop(sakura_gates, Rect2(170, 398, 140, 142), room_offset + Vector2(40, 42), 1.0)
			_moonpetal_prop(sakura_gates, Rect2(321, 398, 140, 142), room_offset + Vector2(204, 42), 1.0)
			_moonpetal_prop(sakura_lanterns, Rect2(37, 331, 115, 145), room_offset + Vector2(2, 115), 0.5)
			_moonpetal_prop(sakura_lanterns, Rect2(164, 331, 114, 145), room_offset + Vector2(325, 115), 0.5)
		&"palace":
			_moonpetal_prop(sakura_temple, Rect2(42, 580, 318, 177), room_offset + Vector2(33, 18), 1.0)
			_moonpetal_prop(sakura_gardens, Rect2(368, 496, 187, 181), room_offset + Vector2(18, 196), 0.5)
			_moonpetal_prop(sakura_gardens, Rect2(575, 496, 187, 181), room_offset + Vector2(273, 196), 0.5)


func _moonpetal_prop(texture: Texture2D, source: Rect2, destination_position: Vector2, scale: float) -> void:
	var size := source.size * scale
	tile(texture, source, Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size))


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
	draw_rect(Rect2(room_offset - Vector2(384, 0), Vector2(1152, 384)), Color(0.18, 0.44, 0.72), true)
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
	match room_kind:
		&"landing":
			_empyreal_prop_slice("pediment_door", room_offset + Vector2(132, 4))
			_empyreal_prop_slice("winged_statue", room_offset + Vector2(22, 38))
			_empyreal_prop_slice("winged_statue", room_offset + Vector2(268, 38), true)
			draw_rect(Rect2(room_offset + Vector2(145, 176), Vector2(94, 4)), Color(0.32, 0.19, 0.08, 0.65), true)
		&"garden":
			_empyreal_prop_slice("silver_olive_tree", room_offset + Vector2(5, 31))
			_empyreal_prop_slice("golden_olive_tree", room_offset + Vector2(278, 31))
			_empyreal_prop_slice("appeal_fountain", room_offset + Vector2(141, 34))
			# Four low offerings make the fountain a plaza rather than a lone prop.
			_empyreal_prop_slice("flower_offering", room_offset + Vector2(76, 190))
			_empyreal_prop_slice("fruit_offering", room_offset + Vector2(247, 190))
		&"forum":
			_empyreal_prop_slice("plain_column", room_offset + Vector2(34, 11))
			_empyreal_prop_slice("blue_column", room_offset + Vector2(302, 11))
			_empyreal_prop_slice("ordinance_book", room_offset + Vector2(138, 65))
			_empyreal_prop_slice("horse_statue", room_offset + Vector2(58, 84))
			_empyreal_prop_slice("griffin_statue", room_offset + Vector2(267, 82))
		&"aerie":
			_empyreal_prop_slice("reliquary_portal", room_offset + Vector2(137, 11))
			_empyreal_prop_slice("crystal_altar", room_offset + Vector2(41, 101))
			_empyreal_prop_slice("lotus_altar", room_offset + Vector2(267, 101))
			_empyreal_prop_slice("gravity_crystal", room_offset + Vector2(167, 178))
		&"tribunal":
			_empyreal_prop_slice("tribunal_gate", room_offset + Vector2(111, 4))
			_empyreal_prop_slice("justice_statue", room_offset + Vector2(40, 38))
			_empyreal_prop_slice("music_statue", room_offset + Vector2(304, 38))
			_empyreal_prop_slice("tribunal_orrery", room_offset + Vector2(32, 187))


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
		_draw_station_room(offset + Vector2(definition[0] * TILE), definition[1])
		return
	for definition in room_definitions.values():
		_draw_station_room(offset + Vector2(definition[0] * TILE), definition[1])


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
	match room_kind:
		&"dock":
			# One complete shuttle and an actual side hatch make this a docking bay,
			# not a ship sprite flanked by unrelated storage thumbnails.
			_station_prop(station_exterior, Rect2(135, 3, 248, 89), room_offset + Vector2(68, 12))
			_station_prop(station_exterior, Rect2(2, 98, 94, 94), room_offset + Vector2(2, 92))
			_station_prop(station_architecture, Rect2(7, 200, 80, 78), room_offset + Vector2(297, 108))
		&"mess":
			# Opposing pressure hatches frame a real connecting mess hall. The cargo
			# cache and serving table sit inside the room instead of covering exits.
			_station_prop(station_architecture, Rect2(7, 200, 80, 78), room_offset + Vector2(7, 108))
			_station_prop(station_architecture, Rect2(7, 200, 80, 78), room_offset + Vector2(297, 108))
			_station_prop(station_mess, Rect2(241, 0, 45, 96), room_offset + Vector2(117, 10))
			_station_prop(station_mess, Rect2(289, 0, 46, 96), room_offset + Vector2(164, 10))
			_station_prop(station_mess, Rect2(337, 0, 46, 96), room_offset + Vector2(212, 10))
			_station_prop(station_exterior, Rect2(675, 105, 91, 81), room_offset + Vector2(76, 104))
			_station_prop(station_mess, Rect2(98, 4, 93, 45), room_offset + Vector2(214, 136))
		&"hydro":
			# The return hatch opens onto a continuous bank of grow equipment; this
			# reads as a working room rather than four isolated plant sprites.
			_station_prop(station_architecture, Rect2(7, 200, 80, 78), room_offset + Vector2(7, 108))
			_station_prop(station_hydro, Rect2(144, 59, 240, 85), room_offset + Vector2(72, 16))
			_station_prop(station_hydro, Rect2(0, 147, 96, 45), room_offset + Vector2(100, 132))
			# This complete status terminal occupies the authored console interaction.
			_station_prop(station_hydro, Rect2(686, 195, 69, 92), room_offset + Vector2(304, 86))
		&"medical":
			# Two individual beds, a complete scanner, and a complete drug cabinet.
			_station_prop(station_medical, Rect2(1, 10, 45, 86), room_offset + Vector2(14, 12))
			_station_prop(station_medical, Rect2(145, 10, 45, 86), room_offset + Vector2(70, 12))
			_station_prop(station_medical, Rect2(194, 124, 92, 62), room_offset + Vector2(108, 116))
			_station_prop(station_medical, Rect2(531, 115, 42, 77), room_offset + Vector2(224, 101))
			# A whole holographic beacon sits exactly at the room's save interaction.
			_station_prop(station_command, Rect2(290, 21, 93, 116), room_offset + Vector2(286, 62))
		&"control":
			# One complete three-seat command bank anchors the rear wall. The former
			# side portholes occupied x=3..90 and x=294..381 while this bank occupies
			# x=48..337, visibly drawing both sprites through one another. The bank
			# already contains a complete coherent command-room silhouette, so keep it
			# alone and leave the playable lower half clean.
			_station_prop(station_command, Rect2(0, 0, 289, 143), room_offset + Vector2(48, 18))


func _station_prop(texture: Texture2D, source: Rect2, destination_position: Vector2) -> void:
	# Props remain pixel-for-pixel with the source pack. Rounded placement prevents
	# sub-pixel shimmer while the 2x room camera keeps the native art readable.
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	tile(texture, source, Rect2(position, source.size))


func _draw_mansion_room_shell(room_offset: Vector2, bedroom_wall: bool) -> void:
	for y in range(4):
		for x in range(8):
			var source := Rect2(0, 0, 48, 48)
			var texture := haunted_bedroom if bedroom_wall else haunted_interior
			if bedroom_wall:
				source = Rect2((x % 8) * 48, (y % 2) * 48, 48, 48)
			else:
				source = Rect2((x % 4) * 48, (y % 2) * 48, 48, 48)
			tile(texture, source, Rect2(room_offset + Vector2(x, y) * TILE, Vector2(TILE, TILE)))
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
			# portion of the pack's wood floor. Shuffling 16px strips keeps its actual
			# pixel texture without stamping the same 96px crack cluster everywhere.
			var source_x := 96 + ((row + board_index) % 2) * 32
			var source_y := 320 + ((row * 3 + board_index) % 4) * 16
			tile(haunted_interior, Rect2(source_x, source_y, right - left, board_height), destination)
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
