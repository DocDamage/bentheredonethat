extends Node2D

const CONTENT_VALIDATOR := preload("res://ben_rpg/core/content_validator.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48
const LAB_SIZE := Vector2i(20, 12)
const TOWN_ORIGIN := Vector2i(36, 0)
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
const STATION_SPAWN := STATION_ORIGIN + Vector2i(4, 6)
const STATION_EXIT := STATION_ORIGIN + Vector2i(4, 7)
const MANSION_SPAWN := MANSION_ORIGIN + Vector2i(4, 6)
const MANSION_EXIT := MANSION_ORIGIN + Vector2i(4, 7)
const STATION_DOCK_TO_MESS := STATION_ORIGIN + Vector2i(6, 4)
const STATION_MESS_FROM_DOCK := STATION_ORIGIN + Vector2i(11, 5)
const STATION_MESS_RETURN := STATION_ORIGIN + Vector2i(11, 4)
const STATION_DOCK_FROM_MESS := STATION_ORIGIN + Vector2i(5, 5)
const STATION_MESS_TO_HYDRO := STATION_ORIGIN + Vector2i(16, 4)
const STATION_HYDRO_FROM_MESS := STATION_ORIGIN + Vector2i(21, 5)
const STATION_HYDRO_RETURN := STATION_ORIGIN + Vector2i(21, 4)
const STATION_MESS_FROM_HYDRO := STATION_ORIGIN + Vector2i(15, 5)
const STATION_MESS_TO_MEDICAL := STATION_ORIGIN + Vector2i(14, 6)
const STATION_MEDICAL_FROM_MESS := STATION_ORIGIN + Vector2i(14, 15)
const STATION_MEDICAL_RETURN := STATION_ORIGIN + Vector2i(14, 14)
const STATION_MESS_FROM_MEDICAL := STATION_ORIGIN + Vector2i(14, 5)
const STATION_HYDRO_TO_CONTROL := STATION_ORIGIN + Vector2i(24, 6)
const STATION_CONTROL_FROM_HYDRO := STATION_ORIGIN + Vector2i(24, 15)
const STATION_CONTROL_RETURN := STATION_ORIGIN + Vector2i(24, 14)
const STATION_HYDRO_FROM_CONTROL := STATION_ORIGIN + Vector2i(24, 5)
# Once life support is restored, a maintenance lift links the return dock to
# Medical. This turns the initially linear oxygen route into a usable loop.
const STATION_DOCK_SERVICE_SHORTCUT := STATION_ORIGIN + Vector2i(1, 6)
const STATION_MEDICAL_SERVICE_SHORTCUT := STATION_ORIGIN + Vector2i(11, 16)
const PRIMEVAL_SPAWN := PRIMEVAL_ORIGIN + Vector2i(4, 6)
const PRIMEVAL_EXIT := PRIMEVAL_ORIGIN + Vector2i(4, 7)
const PRIMEVAL_GROVE_TO_VILLAGE := PRIMEVAL_ORIGIN + Vector2i(6, 4)
const PRIMEVAL_VILLAGE_FROM_GROVE := PRIMEVAL_ORIGIN + Vector2i(11, 5)
const PRIMEVAL_VILLAGE_RETURN := PRIMEVAL_ORIGIN + Vector2i(11, 4)
const PRIMEVAL_GROVE_FROM_VILLAGE := PRIMEVAL_ORIGIN + Vector2i(5, 5)
const PRIMEVAL_VILLAGE_TO_RUINS := PRIMEVAL_ORIGIN + Vector2i(16, 4)
const PRIMEVAL_RUINS_FROM_VILLAGE := PRIMEVAL_ORIGIN + Vector2i(21, 5)
const PRIMEVAL_RUINS_RETURN := PRIMEVAL_ORIGIN + Vector2i(21, 4)
const PRIMEVAL_VILLAGE_FROM_RUINS := PRIMEVAL_ORIGIN + Vector2i(15, 5)
const PRIMEVAL_VILLAGE_TO_NEST := PRIMEVAL_ORIGIN + Vector2i(14, 6)
const PRIMEVAL_NEST_FROM_VILLAGE := PRIMEVAL_ORIGIN + Vector2i(14, 15)
const PRIMEVAL_NEST_RETURN := PRIMEVAL_ORIGIN + Vector2i(14, 14)
const PRIMEVAL_VILLAGE_FROM_NEST := PRIMEVAL_ORIGIN + Vector2i(14, 5)
const PRIMEVAL_RUINS_TO_CALDERA := PRIMEVAL_ORIGIN + Vector2i(24, 6)
const PRIMEVAL_CALDERA_FROM_RUINS := PRIMEVAL_ORIGIN + Vector2i(24, 15)
const PRIMEVAL_CALDERA_RETURN := PRIMEVAL_ORIGIN + Vector2i(24, 14)
const PRIMEVAL_RUINS_FROM_CALDERA := PRIMEVAL_ORIGIN + Vector2i(24, 5)
# Decoding the relay reveals a canopy trail that turns the Nest detour into a
# return loop instead of a dead-end trip back through the Village gate.
const PRIMEVAL_GROVE_CANOPY_SHORTCUT := PRIMEVAL_ORIGIN + Vector2i(1, 6)
const PRIMEVAL_NEST_CANOPY_SHORTCUT := PRIMEVAL_ORIGIN + Vector2i(11, 16)
const HELIOS_SPAWN := HELIOS_ORIGIN + Vector2i(4, 6)
const HELIOS_EXIT := HELIOS_ORIGIN + Vector2i(4, 7)
const HELIOS_SKYBRIDGE_TO_MARKET := HELIOS_ORIGIN + Vector2i(6, 4)
const HELIOS_MARKET_FROM_SKYBRIDGE := HELIOS_ORIGIN + Vector2i(11, 5)
const HELIOS_MARKET_RETURN := HELIOS_ORIGIN + Vector2i(11, 4)
const HELIOS_SKYBRIDGE_FROM_MARKET := HELIOS_ORIGIN + Vector2i(5, 5)
const HELIOS_MARKET_TO_TRANSIT := HELIOS_ORIGIN + Vector2i(16, 4)
const HELIOS_TRANSIT_FROM_MARKET := HELIOS_ORIGIN + Vector2i(21, 5)
const HELIOS_TRANSIT_RETURN := HELIOS_ORIGIN + Vector2i(21, 4)
const HELIOS_MARKET_FROM_TRANSIT := HELIOS_ORIGIN + Vector2i(15, 5)
const HELIOS_MARKET_TO_CLINIC := HELIOS_ORIGIN + Vector2i(14, 6)
const HELIOS_CLINIC_FROM_MARKET := HELIOS_ORIGIN + Vector2i(14, 15)
const HELIOS_CLINIC_RETURN := HELIOS_ORIGIN + Vector2i(14, 14)
const HELIOS_MARKET_FROM_CLINIC := HELIOS_ORIGIN + Vector2i(14, 5)
const HELIOS_TRANSIT_TO_CORE := HELIOS_ORIGIN + Vector2i(24, 6)
const HELIOS_CORE_FROM_TRANSIT := HELIOS_ORIGIN + Vector2i(24, 15)
const HELIOS_CORE_RETURN := HELIOS_ORIGIN + Vector2i(24, 14)
const HELIOS_TRANSIT_FROM_CORE := HELIOS_ORIGIN + Vector2i(24, 5)
const FROSTHOLD_SPAWN := FROSTHOLD_ORIGIN + Vector2i(4, 6)
const FROSTHOLD_EXIT := FROSTHOLD_ORIGIN + Vector2i(4, 7)
const FROSTHOLD_GATE_TO_MARKET := FROSTHOLD_ORIGIN + Vector2i(6, 4)
const FROSTHOLD_MARKET_FROM_GATE := FROSTHOLD_ORIGIN + Vector2i(11, 5)
const FROSTHOLD_MARKET_RETURN := FROSTHOLD_ORIGIN + Vector2i(11, 4)
const FROSTHOLD_GATE_FROM_MARKET := FROSTHOLD_ORIGIN + Vector2i(5, 5)
const FROSTHOLD_MARKET_TO_CAUSEWAY := FROSTHOLD_ORIGIN + Vector2i(16, 4)
const FROSTHOLD_CAUSEWAY_FROM_MARKET := FROSTHOLD_ORIGIN + Vector2i(21, 5)
const FROSTHOLD_CAUSEWAY_RETURN := FROSTHOLD_ORIGIN + Vector2i(21, 4)
const FROSTHOLD_MARKET_FROM_CAUSEWAY := FROSTHOLD_ORIGIN + Vector2i(15, 5)
const FROSTHOLD_MARKET_TO_RUNE_HALL := FROSTHOLD_ORIGIN + Vector2i(14, 6)
const FROSTHOLD_RUNE_HALL_FROM_MARKET := FROSTHOLD_ORIGIN + Vector2i(14, 15)
const FROSTHOLD_RUNE_HALL_RETURN := FROSTHOLD_ORIGIN + Vector2i(14, 14)
const FROSTHOLD_MARKET_FROM_RUNE_HALL := FROSTHOLD_ORIGIN + Vector2i(14, 5)
const FROSTHOLD_CAUSEWAY_TO_THRONE := FROSTHOLD_ORIGIN + Vector2i(24, 6)
const FROSTHOLD_THRONE_FROM_CAUSEWAY := FROSTHOLD_ORIGIN + Vector2i(24, 15)
const FROSTHOLD_THRONE_RETURN := FROSTHOLD_ORIGIN + Vector2i(24, 14)
const FROSTHOLD_CAUSEWAY_FROM_THRONE := FROSTHOLD_ORIGIN + Vector2i(24, 5)
const MOONPETAL_SPAWN := MOONPETAL_ORIGIN + Vector2i(4, 6)
const MOONPETAL_EXIT := MOONPETAL_ORIGIN + Vector2i(4, 7)
const MOONPETAL_GATE_TO_COURT := MOONPETAL_ORIGIN + Vector2i(6, 4)
const MOONPETAL_COURT_FROM_GATE := MOONPETAL_ORIGIN + Vector2i(11, 5)
const MOONPETAL_COURT_RETURN := MOONPETAL_ORIGIN + Vector2i(11, 4)
const MOONPETAL_GATE_FROM_COURT := MOONPETAL_ORIGIN + Vector2i(5, 5)
const MOONPETAL_COURT_TO_GARDEN := MOONPETAL_ORIGIN + Vector2i(16, 4)
const MOONPETAL_GARDEN_FROM_COURT := MOONPETAL_ORIGIN + Vector2i(21, 5)
const MOONPETAL_GARDEN_RETURN := MOONPETAL_ORIGIN + Vector2i(21, 4)
const MOONPETAL_COURT_FROM_GARDEN := MOONPETAL_ORIGIN + Vector2i(15, 5)
const MOONPETAL_COURT_TO_BELL_WALK := MOONPETAL_ORIGIN + Vector2i(14, 6)
const MOONPETAL_BELL_WALK_FROM_COURT := MOONPETAL_ORIGIN + Vector2i(14, 15)
const MOONPETAL_BELL_WALK_RETURN := MOONPETAL_ORIGIN + Vector2i(14, 14)
const MOONPETAL_COURT_FROM_BELL_WALK := MOONPETAL_ORIGIN + Vector2i(14, 5)
const MOONPETAL_GARDEN_TO_PALACE := MOONPETAL_ORIGIN + Vector2i(24, 6)
const MOONPETAL_PALACE_FROM_GARDEN := MOONPETAL_ORIGIN + Vector2i(24, 15)
const MOONPETAL_PALACE_RETURN := MOONPETAL_ORIGIN + Vector2i(24, 14)
const MOONPETAL_GARDEN_FROM_PALACE := MOONPETAL_ORIGIN + Vector2i(24, 5)
const EMPYREAL_SPAWN := EMPYREAL_ORIGIN + Vector2i(4, 6)
const EMPYREAL_EXIT := EMPYREAL_ORIGIN + Vector2i(4, 7)
const EMPYREAL_LANDING_TO_GARDEN := EMPYREAL_ORIGIN + Vector2i(6, 4)
const EMPYREAL_GARDEN_FROM_LANDING := EMPYREAL_ORIGIN + Vector2i(11, 5)
const EMPYREAL_GARDEN_RETURN := EMPYREAL_ORIGIN + Vector2i(11, 4)
const EMPYREAL_LANDING_FROM_GARDEN := EMPYREAL_ORIGIN + Vector2i(5, 5)
const EMPYREAL_GARDEN_TO_FORUM := EMPYREAL_ORIGIN + Vector2i(16, 4)
const EMPYREAL_FORUM_FROM_GARDEN := EMPYREAL_ORIGIN + Vector2i(21, 5)
const EMPYREAL_FORUM_RETURN := EMPYREAL_ORIGIN + Vector2i(21, 4)
const EMPYREAL_GARDEN_FROM_FORUM := EMPYREAL_ORIGIN + Vector2i(15, 5)
const EMPYREAL_GARDEN_TO_AERIE := EMPYREAL_ORIGIN + Vector2i(14, 6)
const EMPYREAL_AERIE_FROM_GARDEN := EMPYREAL_ORIGIN + Vector2i(14, 15)
const EMPYREAL_AERIE_RETURN := EMPYREAL_ORIGIN + Vector2i(14, 14)
const EMPYREAL_GARDEN_FROM_AERIE := EMPYREAL_ORIGIN + Vector2i(14, 5)
const EMPYREAL_FORUM_TO_TRIBUNAL := EMPYREAL_ORIGIN + Vector2i(24, 6)
const EMPYREAL_TRIBUNAL_FROM_FORUM := EMPYREAL_ORIGIN + Vector2i(24, 15)
const EMPYREAL_TRIBUNAL_RETURN := EMPYREAL_ORIGIN + Vector2i(24, 14)
const EMPYREAL_FORUM_FROM_TRIBUNAL := EMPYREAL_ORIGIN + Vector2i(24, 5)
const LAB_SPAWN := Vector2i(10, 9)
const LAB_EXIT := Vector2i(10, 10)
const TOWN_LAB_DOOR := TOWN_ORIGIN + Vector2i(14, 7)
const TOWN_ARRIVAL := TOWN_ORIGIN + Vector2i(14, 8)

const VISUAL_SCRIPT := preload("res://ben_rpg/world/campaign_map_visual.gd")
const MANSION_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_mansion_foreground.gd")
const TOWN_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_town_foreground.gd")
const ASTERION_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_asterion_foreground.gd")
const MOONPETAL_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_moonpetal_foreground.gd")
const EMPYREAL_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_empyreal_foreground.gd")
const EMPYREAL_GROUND_SCRIPT := preload("res://ben_rpg/world/campaign_empyreal_ground.gd")
const FROSTHOLD_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_frosthold_foreground.gd")
const PRIMEVAL_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_primeval_foreground.gd")
const HELIOS_FOREGROUND_SCRIPT := preload("res://ben_rpg/world/campaign_helios_foreground.gd")
const MANSION_LEGACY_ADAPTER := preload("res://ben_rpg/world/campaign_mansion_legacy_adapter.gd")
const ROOM_STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const ROOM_RUNTIME_SCRIPT := preload("res://ben_rpg/world/campaign_room_runtime.gd")
const WEATHER_OVERLAY_SCRIPT := preload("res://ben_rpg/world/campaign_weather_overlay.gd")
const AREA_TRANSITION := preload("res://src/field/cutscenes/templates/area_transitions/area_transition.tscn")
const RESTRICTED_AREA_TRANSITION := preload("res://ben_rpg/world/restricted_area_transition.tscn")
const TOWN_BUILD_CONTROLLER := preload("res://ben_rpg/world/town_build_controller.gd")
const FIGHTER_GAMEPIECE := preload("res://ben_rpg/characters/fighter_gamepiece.tscn")
const CAMPAIGN_BATTLE := preload("res://ben_rpg/combat/campaign_battle.tscn")
const MANSION_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/mansion_encounter_controller.gd")
const MANSION_CLUE := preload("res://ben_rpg/world/mansion_clue_interaction.tscn")
const MANSION_CHAPTER_INTERACTION := preload("res://ben_rpg/world/mansion_chapter_interaction.tscn")
const MANSION_SAVE_POINT := preload("res://ben_rpg/world/mansion_save_point.tscn")
const ASTERION_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/asterion_encounter_controller.gd")
const ASTERION_INTERACTION := preload("res://ben_rpg/world/asterion_interaction.tscn")
const ASTRONAUT_GAMEPIECE := preload("res://ben_rpg/characters/astronaut_gamepiece.tscn")
const PRIMEVAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/primeval_encounter_controller.gd")
const PRIMEVAL_INTERACTION := preload("res://ben_rpg/world/primeval_interaction.tscn")
const CAVEMAN_GAMEPIECE := preload("res://ben_rpg/characters/caveman_gamepiece.tscn")
const HELIOS_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/helios_encounter_controller.gd")
const HELIOS_INTERACTION := preload("res://ben_rpg/world/helios_interaction.tscn")
const NEON_VIPER_GAMEPIECE := preload("res://ben_rpg/characters/neon_viper_gamepiece.tscn")
const FROST_LICH_GAMEPIECE := preload("res://ben_rpg/characters/frost_lich_gamepiece.tscn")
const FROSTHOLD_INTERACTION := preload("res://ben_rpg/world/frosthold_interaction.tscn")
const FROSTHOLD_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/frosthold_encounter_controller.gd")
const KITSUNE_GAMEPIECE := preload("res://ben_rpg/characters/kitsune_gamepiece.tscn")
const CRIMSON_ONI_GAMEPIECE := preload("res://ben_rpg/characters/crimson_oni_gamepiece.tscn")
const RIFT_JACKAL_GAMEPIECE := preload("res://ben_rpg/characters/rift_jackal_gamepiece.tscn")
const MOSSBACK_SURVEYOR_GAMEPIECE := preload("res://ben_rpg/characters/mossback_surveyor_gamepiece.tscn")
const COBALT_COURIER_GAMEPIECE := preload("res://ben_rpg/characters/cobalt_courier_gamepiece.tscn")
const BULKHEAD_WARDEN_GAMEPIECE := preload("res://ben_rpg/characters/bulkhead_warden_gamepiece.tscn")
const MOONPETAL_INTERACTION := preload("res://ben_rpg/world/moonpetal_interaction.tscn")
const MOONPETAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/moonpetal_encounter_controller.gd")
const ARCHANGEL_GAMEPIECE := preload("res://ben_rpg/characters/archangel_gamepiece.tscn")
const EMPYREAL_INTERACTION := preload("res://ben_rpg/world/empyreal_interaction.tscn")
const EMPYREAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/empyreal_encounter_controller.gd")
const UNIVERSE_TREASURE_INTERACTION := preload("res://ben_rpg/world/universe_treasure_interaction.tscn")
const CAMPAIGN_MENU := preload("res://ben_rpg/ui/campaign_menu.tscn")
const CAMPAIGN_TITLE_SCREEN := preload("res://ben_rpg/ui/campaign_title_screen.tscn")
const CAMPAIGN_ENDING_OVERLAY := preload("res://ben_rpg/ui/campaign_ending_overlay.gd")
const SANDBOX_OBJECTS_SCRIPT := preload("res://ben_rpg/world/sandbox_town_objects.gd")
const SANDBOX_EDITOR_SCRIPT := preload("res://ben_rpg/world/sandbox_town_editor.gd")
const SANDBOX_OBJECT_CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")
const SANDBOX_TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
const TOWN_RESIDENT_MANAGER_SCRIPT := preload("res://ben_rpg/world/town_resident_manager.gd")
const PARTY_FOLLOWER_TRAIN_SCRIPT := preload("res://ben_rpg/world/party_follower_train.gd")
const TOWN_FACILITY_INTERACTION := preload("res://ben_rpg/world/town_facility_interaction.tscn")
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

var _camera_area := ""
var _navigation: GameboardLayer
var _visual: CampaignMapVisual
var _visual_profiles := VISUAL_PROFILE_REGISTRY.new()
var _room_streamer: Node
var _room_runtime: Node
var _empyreal_ground
var _mansion_foreground
var _town_foreground
var _asterion_foreground
var _moonpetal_foreground
var _empyreal_foreground
var _frosthold_foreground
var _primeval_foreground
var _helios_foreground
var _weather_overlay
var _battle: CampaignBattle
var _mansion_boss_marker: Sprite2D
var _station_boss_marker: Sprite2D
var _primeval_boss_marker: Sprite2D
var _helios_boss_marker: Sprite2D
var _frosthold_boss_marker: Sprite2D
var _moonpetal_boss_marker: Sprite2D
var _empyreal_boss_marker: Sprite2D
var _campaign_menu: CanvasLayer
var _title_screen
var _ending_overlay
var _ending_presentation_queued := false
var _opening_cutscene: Cutscene
var campaign_save_path := CampaignState.DEFAULT_SAVE_PATH
var _sandbox_objects
var _sandbox_editor
var _resident_manager
var _party_followers: PartyFollowerTrain


func _enter_tree() -> void:
	_ensure_campaign_input()
	var field := get_node("Field")
	# Hold the opening until the player explicitly chooses New Adventure. Tests
	# and preview scenes null this export before entering the tree, which keeps
	# their existing direct-to-field behavior.
	if field.opening_cutscene:
		_opening_cutscene = field.opening_cutscene
		field.opening_cutscene = null
	if not CampaignState.recruit_status_changed.is_connected(_on_recruit_status_changed):
		CampaignState.recruit_status_changed.connect(_on_recruit_status_changed)
	var map: Node2D = get_node("Field/Map")
	# Remove the template's demonstration content before those children enter the
	# tree. The RPG systems and UI remain; only the stock world is replaced.
	for area_name in ["Town", "House", "Forest"]:
		var area := map.get_node_or_null(area_name)
		if area:
			map.remove_child(area)
			area.queue_free()

	Gameboard.properties = map.gameboard_properties
	var player: Gamepiece = get_node("Field/Map/Player")
	var start_cell := TOWN_ARRIVAL if "--smoke-town" in OS.get_cmdline_user_args() else LAB_SPAWN
	player.position = Gameboard.cell_to_pixel(start_cell)
	player.move_speed = 210.0
	_party_followers = PARTY_FOLLOWER_TRAIN_SCRIPT.new() as PartyFollowerTrain
	_party_followers.name = "ActivePartyFollowers"
	_party_followers.leader = player
	map.add_child(_party_followers)

	var world := Node2D.new()
	world.name = "CampaignWorld"
	world.y_sort_enabled = true
	map.add_child(world)
	_room_streamer = ROOM_STREAMER_SCRIPT.new()
	_room_streamer.name = "RoomStreamer"
	world.add_child(_room_streamer)
	# Keep the campaign's established public nodes reachable while beginning the
	# renderer migration with real canvas layers.  Future map migrations can move
	# interactions into these groups without changing the world root again.
	var ground_layer := Node2D.new()
	ground_layer.name = "GroundLayer"
	ground_layer.z_index = -2
	world.add_child(ground_layer)
	var low_decoration_layer := Node2D.new()
	low_decoration_layer.name = "LowDecorationLayer"
	low_decoration_layer.z_index = -1
	world.add_child(low_decoration_layer)
	var navigation_layer := Node2D.new()
	navigation_layer.name = "NavigationAndCollision"
	world.add_child(navigation_layer)
	var actors_layer := Node2D.new()
	actors_layer.name = "YSortedActorsAndProps"
	actors_layer.y_sort_enabled = true
	world.add_child(actors_layer)
	var foreground_layer := Node2D.new()
	foreground_layer.name = "ForegroundLayer"
	foreground_layer.z_index = 1
	world.add_child(foreground_layer)
	var interaction_layer := Node2D.new()
	interaction_layer.name = "InteractionLayer"
	world.add_child(interaction_layer)
	var encounter_layer := Node2D.new()
	encounter_layer.name = "EncounterLayer"
	world.add_child(encounter_layer)
	_visual = VISUAL_SCRIPT.new()
	_visual.name = "Visuals"
	ground_layer.add_child(_visual)
	_empyreal_ground = EMPYREAL_GROUND_SCRIPT.new()
	_empyreal_ground.name = "EmpyrealGround"
	ground_layer.add_child(_empyreal_ground)
	_sandbox_objects = SANDBOX_OBJECTS_SCRIPT.new()
	_sandbox_objects.name = "SandboxTownObjects"
	low_decoration_layer.add_child(_sandbox_objects)
	_navigation = _create_navigation_layer()
	navigation_layer.add_child(_navigation)
	_room_runtime = ROOM_RUNTIME_SCRIPT.new()
	_room_runtime.name = "ManifestRoomRuntime"
	_room_runtime.call(&"configure", _room_streamer, _navigation)
	world.add_child(_room_runtime)
	_resident_manager = TOWN_RESIDENT_MANAGER_SCRIPT.new()
	_resident_manager.name = "TownResidents"
	_resident_manager.campaign = self
	actors_layer.add_child(_resident_manager)
	_mansion_foreground = MANSION_FOREGROUND_SCRIPT.new()
	_mansion_foreground.name = "MansionForeground"
	foreground_layer.add_child(_mansion_foreground)
	_town_foreground = TOWN_FOREGROUND_SCRIPT.new()
	_town_foreground.name = "TownForeground"
	foreground_layer.add_child(_town_foreground)
	_asterion_foreground = ASTERION_FOREGROUND_SCRIPT.new()
	_asterion_foreground.name = "AsterionForeground"
	foreground_layer.add_child(_asterion_foreground)
	_moonpetal_foreground = MOONPETAL_FOREGROUND_SCRIPT.new()
	_moonpetal_foreground.name = "MoonpetalForeground"
	foreground_layer.add_child(_moonpetal_foreground)
	_empyreal_foreground = EMPYREAL_FOREGROUND_SCRIPT.new()
	_empyreal_foreground.name = "EmpyrealForeground"
	foreground_layer.add_child(_empyreal_foreground)
	_frosthold_foreground = FROSTHOLD_FOREGROUND_SCRIPT.new()
	_frosthold_foreground.name = "FrostholdForeground"
	foreground_layer.add_child(_frosthold_foreground)
	_primeval_foreground = PRIMEVAL_FOREGROUND_SCRIPT.new()
	_primeval_foreground.name = "PrimevalForeground"
	foreground_layer.add_child(_primeval_foreground)
	_helios_foreground = HELIOS_FOREGROUND_SCRIPT.new()
	_helios_foreground.name = "HeliosForeground"
	foreground_layer.add_child(_helios_foreground)
	_weather_overlay = WEATHER_OVERLAY_SCRIPT.new()
	_weather_overlay.name = "WeatherOverlay"
	_weather_overlay.z_index = 2
	foreground_layer.add_child(_weather_overlay)
	world.add_child(_create_transition("LaboratoryExit", LAB_EXIT, TOWN_ARRIVAL))
	world.add_child(_create_transition("TownLaboratoryDoor", TOWN_LAB_DOOR, LAB_SPAWN))
	var build_controller := TOWN_BUILD_CONTROLLER.new()
	build_controller.name = "TownBuildController"
	build_controller.campaign = self
	build_controller.visual = _visual
	world.add_child(build_controller)
	_battle = CAMPAIGN_BATTLE.instantiate() as CampaignBattle
	_battle.name = "CampaignBattle"
	_battle.battle_finished.connect(_on_campaign_battle_finished)
	add_child(_battle)
	_campaign_menu = CAMPAIGN_MENU.instantiate() as CanvasLayer
	_campaign_menu.name = "CampaignMenu"
	_campaign_menu.campaign = self
	add_child(_campaign_menu)
	_sandbox_editor = SANDBOX_EDITOR_SCRIPT.new()
	_sandbox_editor.name = "SandboxTownEditor"
	_sandbox_editor.campaign = self
	_sandbox_editor.renderer = _sandbox_objects
	add_child(_sandbox_editor)
	var encounter_controller := MANSION_ENCOUNTER_CONTROLLER.new() as MansionEncounterController
	encounter_controller.name = "MansionEncounters"
	encounter_controller.battle = _battle
	encounter_layer.add_child(encounter_controller)
	var station_encounters := ASTERION_ENCOUNTER_CONTROLLER.new() as AsterionEncounterController
	station_encounters.name = "AsterionEncounters"
	station_encounters.battle = _battle
	encounter_layer.add_child(station_encounters)
	var primeval_encounters := PRIMEVAL_ENCOUNTER_CONTROLLER.new() as PrimevalEncounterController
	primeval_encounters.name = "PrimevalEncounters"
	primeval_encounters.battle = _battle
	encounter_layer.add_child(primeval_encounters)
	var helios_encounters := HELIOS_ENCOUNTER_CONTROLLER.new() as HeliosEncounterController
	helios_encounters.name = "HeliosEncounters"
	helios_encounters.battle = _battle
	encounter_layer.add_child(helios_encounters)
	var frosthold_encounters := FROSTHOLD_ENCOUNTER_CONTROLLER.new() as FrostholdEncounterController
	frosthold_encounters.name = "FrostholdEncounters"
	frosthold_encounters.battle = _battle
	encounter_layer.add_child(frosthold_encounters)
	var moonpetal_encounters := MOONPETAL_ENCOUNTER_CONTROLLER.new() as MoonpetalEncounterController
	moonpetal_encounters.name = "MoonpetalEncounters"
	moonpetal_encounters.battle = _battle
	encounter_layer.add_child(moonpetal_encounters)
	var empyreal_encounters := EMPYREAL_ENCOUNTER_CONTROLLER.new() as EmpyrealEncounterController
	empyreal_encounters.name = "EmpyrealEncounters"
	empyreal_encounters.battle = _battle
	encounter_layer.add_child(empyreal_encounters)
	_spawn_mansion_clues(world)
	_spawn_mansion_chapter_interactions(world)
	_spawn_mansion_save_point(world)
	_spawn_mansion_boss_marker(world)
	_spawn_asterion_interactions(world)
	_spawn_asterion_boss_marker(world)
	_spawn_primeval_interactions(world)
	_spawn_primeval_boss_marker(world)
	_spawn_helios_interactions(world)
	_spawn_helios_boss_marker(world)
	_spawn_frosthold_interactions(world)
	_spawn_frosthold_boss_marker(world)
	_spawn_moonpetal_interactions(world)
	_spawn_moonpetal_boss_marker(world)
	_spawn_empyreal_interactions(world)
	_spawn_universe_treasure_caches(world)
	_spawn_empyreal_boss_marker(world)
	if not CampaignState.state_changed.is_connected(_on_campaign_state_changed):
		CampaignState.state_changed.connect(_on_campaign_state_changed)

	# The stock cursor art is 16px. Hide only its visual tile while retaining its
	# click/touch hit testing, which now uses the 48px Gameboard properties.
	var cursor := get_node_or_null("Field/Map/Overlay/Cursor") as CanvasItem
	if cursor:
		cursor.self_modulate.a = 0.0
	var destination := get_node_or_null("Field/Map/Overlay/PlayerPathDestinationMarker") as Sprite2D
	if destination:
		destination.scale = Vector2(3, 3)


func _ready() -> void:
	if OS.is_debug_build():
		var content_errors := CONTENT_VALIDATOR.validate_all()
		assert(content_errors.is_empty(), "Content validation failed at startup:\n%s" % "\n".join(content_errors))
	_restore_campaign_state()
	_spawn_available_recruits()
	_update_camera_limits(true)
	_queue_campaign_ending_if_needed()
	if _opening_cutscene and not _is_smoke_launch():
		_show_title_screen.call_deferred()
	else:
		CampaignState.begin_play_session()


func _process(_delta: float) -> void:
	_update_camera_limits()


func start_new_campaign() -> bool:
	CampaignState.reset_new_game()
	_place_player(LAB_SPAWN)
	_dismiss_title_screen()
	if _opening_cutscene and is_instance_valid(_opening_cutscene):
		_opening_cutscene.run.call_deferred()
	return true


func continue_campaign(path := CampaignState.DEFAULT_SAVE_PATH) -> bool:
	if CampaignState.load_game(path) != OK:
		return false
	_restore_campaign_state()
	_spawn_available_recruits()
	_on_campaign_state_changed()
	_place_player(CampaignState.last_save_cell)
	_dismiss_title_screen()
	_queue_campaign_ending_if_needed()
	return true


func start_sandbox_campaign() -> bool:
	CampaignState.setup_sandbox(TOWN_ARRIVAL)
	_spawn_available_recruits()
	_place_player(TOWN_ARRIVAL)
	_dismiss_title_screen()
	return true


func _show_title_screen() -> void:
	if _title_screen:
		return
	_title_screen = CAMPAIGN_TITLE_SCREEN.instantiate()
	_title_screen.name = "CampaignTitleScreen"
	_title_screen.campaign = self
	_title_screen.save_path = campaign_save_path
	add_child(_title_screen)
	if _campaign_menu:
		_campaign_menu.hide()
		_campaign_menu.process_mode = Node.PROCESS_MODE_DISABLED
	var field_hud := get_node_or_null("Field/Map/CampaignWorld/TownBuildController") as CanvasLayer
	if field_hud:
		field_hud.hide()
	var template_ui := get_node_or_null("UI") as CanvasLayer
	if template_ui:
		template_ui.hide()


func _dismiss_title_screen() -> void:
	if _title_screen:
		_title_screen.queue_free()
		_title_screen = null
	if _campaign_menu:
		_campaign_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	var field_hud := get_node_or_null("Field/Map/CampaignWorld/TownBuildController") as CanvasLayer
	if field_hud:
		field_hud.show()
	var template_ui := get_node_or_null("UI") as CanvasLayer
	if template_ui:
		template_ui.show()
	FieldEvents.input_paused.emit(false)
	CampaignState.begin_play_session()
	_update_camera_limits(true)


func _place_player(requested_cell: Vector2i) -> void:
	var player := Player.gamepiece
	if not player:
		return
	# Clear an active Path2D curve before an explicit teleport. Calling stop on an
	# idle gamepiece would move it to its cleared destination (Vector2.ZERO).
	if player.is_moving():
		player.stop()
	var destination := requested_cell
	if not Gameboard.pathfinder.has_cell(destination) or GamepieceRegistry.get_gamepiece(destination):
		destination = LAB_SPAWN
	var current := GamepieceRegistry.get_cell(player)
	if current != destination:
		GamepieceRegistry.move_gamepiece(player, destination)
	player.position = Gameboard.cell_to_pixel(destination)
	player.rest_position = player.position
	_camera_area = ""
	_update_camera_limits(true)
	Camera.reset_position()
	if _party_followers:
		_party_followers.reset_trail()


func anchor_recall_availability() -> Dictionary:
	if &"continuity_kite" not in CampaignState.owned_inventions:
		return {"allowed": false, "reason": "Build the Continuity Kite in Ben's laboratory first."}
	if _battle and _battle.active:
		return {"allowed": false, "reason": "The Kite cannot open a route during battle."}
	if Cutscene.is_cutscene_in_progress():
		return {"allowed": false, "reason": "The current event must finish before Ben can recall the party."}
	if bool(CampaignState.story_flags.get(&"anchor_recall_suppressed", false)):
		return {"allowed": false, "reason": String(CampaignState.story_flags.get(&"anchor_recall_lock_reason", "This scenario is disrupting the route to town."))}
	var player := Player.gamepiece
	if not player:
		return {"allowed": false, "reason": "No active field party was found."}
	var cell := Gameboard.pixel_to_cell(player.position)
	if Rect2i(Vector2i.ZERO, LAB_SIZE).has_point(cell):
		return {"allowed": false, "reason": "Ben is already in his laboratory."}
	if Rect2i(TOWN_ORIGIN, TOWN_SIZE).has_point(cell):
		return {"allowed": false, "reason": "The party is already in New Philadelphia."}
	return {"allowed": true, "reason": "Route stable. HP and MP will not be restored."}


func anchor_recall_to_town() -> bool:
	if not bool(anchor_recall_availability().get("allowed", false)):
		return false
	var player := Player.gamepiece
	if player.is_moving():
		player.stop()
	_place_player(TOWN_ARRIVAL)
	CampaignState.story_flags[&"continuity_kite_used"] = true
	CampaignState.story_flags[&"continuity_kite_use_count"] = int(CampaignState.story_flags.get(&"continuity_kite_use_count", 0)) + 1
	CampaignState.state_changed.emit()
	CampaignState.save_game(campaign_save_path)
	return true


func postgame_rematch_availability() -> Dictionary:
	if not CampaignState.postgame_rematch_available():
		return {"allowed": false, "reason": "Finish the Empyreal epilogue to unlock Tribunal rematches."}
	if _battle and _battle.active:
		return {"allowed": false, "reason": "The Tribunal cannot file a second hearing during an active battle."}
	if Cutscene.is_cutscene_in_progress():
		return {"allowed": false, "reason": "Finish the current event before opening the Tribunal Ledger."}
	var player := Player.gamepiece
	if not player or not Rect2i(TOWN_ORIGIN, TOWN_SIZE).has_point(Gameboard.pixel_to_cell(player.position)):
		return {"allowed": false, "reason": "Visit New Philadelphia to open the Library's Tribunal Ledger."}
	return {"allowed": true, "reason": "No campaign rewards are repeated."}


func begin_postgame_rematch() -> bool:
	if not bool(postgame_rematch_availability().get("allowed", false)):
		return false
	CampaignState.story_flags[&"postgame_rematch_started"] = int(CampaignState.story_flags.get(&"postgame_rematch_started", 0)) + 1
	CampaignState.state_changed.emit()
	return _battle.begin(&"empyreal_high_comptroller")


func _on_campaign_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if victory and encounter_id == &"empyreal_high_comptroller":
		_queue_campaign_ending_if_needed()


func _queue_campaign_ending_if_needed() -> void:
	if _is_smoke_launch() or _ending_presentation_queued or is_instance_valid(_ending_overlay):
		return
	if not bool(CampaignState.campaign_ending_state().get("needs_presentation", false)):
		return
	_ending_presentation_queued = true
	_present_campaign_ending.call_deferred()


func _present_campaign_ending() -> void:
	_ending_presentation_queued = false
	if _is_smoke_launch() or is_instance_valid(_ending_overlay) or (_battle and _battle.active):
		return
	if not bool(CampaignState.campaign_ending_state().get("needs_presentation", false)):
		return
	_ending_overlay = CAMPAIGN_ENDING_OVERLAY.new()
	_ending_overlay.name = "CampaignEndingOverlay"
	_ending_overlay.finished.connect(_finish_campaign_ending)
	add_child(_ending_overlay)
	FieldEvents.input_paused.emit(true)
	_ending_overlay.present()


func _finish_campaign_ending() -> void:
	var finalized := CampaignState.complete_campaign_ending(TOWN_ARRIVAL)
	if finalized:
		_place_player(TOWN_ARRIVAL)
		CampaignState.save_game(campaign_save_path)
	_ending_overlay = null
	FieldEvents.input_paused.emit(false)


func _is_smoke_launch() -> bool:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--smoke-"):
			return true
	return false


func _update_camera_limits(force := false) -> void:
	var gamepiece := Player.gamepiece
	if not gamepiece:
		return
	var current_cell := Gameboard.pixel_to_cell(gamepiece.position)
	var area := "lab"
	var manifest_room_id := StringName(_room_runtime.call(&"room_at_cell", current_cell)) if _room_runtime else &""
	if manifest_room_id == &"":
		manifest_room_id = ROOM_REGISTRY.room_id_at_world_cell(current_cell)
		if manifest_room_id != &"" and _room_runtime:
			_room_runtime.call(&"activate", manifest_room_id)
	if manifest_room_id != &"":
		area = "manifest:%s" % manifest_room_id
	elif Rect2i(EMPYREAL_ORIGIN, EMPYREAL_SIZE).has_point(current_cell):
		var empyreal_local := current_cell - EMPYREAL_ORIGIN
		if empyreal_local.y >= 10 and empyreal_local.x >= 20:
			area = "empyreal_tribunal"
		elif empyreal_local.y >= 10:
			area = "empyreal_aerie"
		elif empyreal_local.x >= 20:
			area = "empyreal_forum"
		elif empyreal_local.x >= 10:
			area = "empyreal_garden"
		else:
			area = "empyreal_landing"
	elif Rect2i(MOONPETAL_ORIGIN, MOONPETAL_SIZE).has_point(current_cell):
		var moonpetal_local := current_cell - MOONPETAL_ORIGIN
		if moonpetal_local.y >= 10 and moonpetal_local.x >= 20:
			area = "moonpetal_palace"
		elif moonpetal_local.y >= 10:
			area = "moonpetal_bell_walk"
		elif moonpetal_local.x >= 20:
			area = "moonpetal_garden"
		elif moonpetal_local.x >= 10:
			area = "moonpetal_court"
		else:
			area = "moonpetal_gate"
	elif Rect2i(FROSTHOLD_ORIGIN, FROSTHOLD_SIZE).has_point(current_cell):
		var frosthold_local := current_cell - FROSTHOLD_ORIGIN
		if frosthold_local.y >= 10 and frosthold_local.x >= 20:
			area = "frosthold_throne"
		elif frosthold_local.y >= 10:
			area = "frosthold_rune_hall"
		elif frosthold_local.x >= 20:
			area = "frosthold_causeway"
		elif frosthold_local.x >= 10:
			area = "frosthold_market"
		else:
			area = "frosthold_gate"
	elif Rect2i(HELIOS_ORIGIN, HELIOS_SIZE).has_point(current_cell):
		var helios_local := current_cell - HELIOS_ORIGIN
		if helios_local.y >= 10 and helios_local.x >= 20:
			area = "helios_core"
		elif helios_local.y >= 10:
			area = "helios_clinic"
		elif helios_local.x >= 20:
			area = "helios_transit"
		elif helios_local.x >= 10:
			area = "helios_market"
		else:
			area = "helios_skybridge"
	elif Rect2i(STATION_ORIGIN, STATION_SIZE).has_point(current_cell):
		var station_local := current_cell - STATION_ORIGIN
		if station_local.y >= 10 and station_local.x >= 20:
			area = "station_control"
		elif station_local.y >= 10:
			area = "station_medical"
		elif station_local.x >= 20:
			area = "station_hydro"
		elif station_local.x >= 10:
			area = "station_mess"
		else:
			area = "station_dock"
	elif Rect2i(PRIMEVAL_ORIGIN, PRIMEVAL_SIZE).has_point(current_cell):
		var primeval_local := current_cell - PRIMEVAL_ORIGIN
		if primeval_local.y >= 10 and primeval_local.x >= 20:
			area = "primeval_caldera"
		elif primeval_local.y >= 10:
			area = "primeval_nest"
		elif primeval_local.x >= 20:
			area = "primeval_ruins"
		elif primeval_local.x >= 10:
			area = "primeval_village"
		else:
			area = "primeval_grove"
	elif Rect2i(MANSION_ORIGIN, MANSION_SIZE).has_point(current_cell):
		area = String(MANSION_LEGACY_ADAPTER.area_for_cell(current_cell))
	elif current_cell.x >= TOWN_ORIGIN.x:
		area = "town"
	if not force and area == _camera_area:
		return
	_camera_area = area
	if _room_streamer:
		if manifest_room_id != &"":
			_room_streamer.call(&"activate_room", manifest_room_id)
		else:
			_room_streamer.call(&"activate_legacy_mansion_area", StringName(area))
	_sync_boss_marker_visibility(area)
	if _visual:
		_visual.set_active_area(StringName(area))
	if _empyreal_ground:
		_empyreal_ground.set_active_area(StringName(area))
	if _mansion_foreground:
		_mansion_foreground.set_active_area(StringName(area))
	if _town_foreground:
		_town_foreground.set_active_area(StringName(area))
	if _asterion_foreground:
		_asterion_foreground.set_active_area(StringName(area))
	if _moonpetal_foreground:
		_moonpetal_foreground.set_active_area(StringName(area))
	if _empyreal_foreground:
		_empyreal_foreground.set_active_area(StringName(area))
	if _frosthold_foreground:
		_frosthold_foreground.set_active_area(StringName(area))
	if _primeval_foreground:
		_primeval_foreground.set_active_area(StringName(area))
	if _helios_foreground:
		_helios_foreground.set_active_area(StringName(area))
	if _weather_overlay:
		_weather_overlay.set_active_area(StringName(area))
	if area == "town":
		CampaignState.mark_story_flag(&"town_entered")
	elif area.begins_with("mansion") or manifest_room_id.begins_with("HM-"):
		CampaignState.mark_story_flag(&"mansion_entered")
	elif area.begins_with("station") or manifest_room_id.begins_with("AS-"):
		CampaignState.mark_story_flag(&"asterion_entered")
	elif area.begins_with("primeval") or manifest_room_id.begins_with("PV-"):
		CampaignState.mark_story_flag(&"primeval_entered")
	elif area.begins_with("helios"):
		CampaignState.mark_story_flag(&"helios_entered")
	elif area.begins_with("frosthold"):
		CampaignState.mark_story_flag(&"frosthold_entered")
	elif area.begins_with("moonpetal"):
		CampaignState.mark_story_flag(&"moonpetal_entered")
	elif area.begins_with("empyreal"):
		CampaignState.mark_story_flag(&"empyreal_entered")
	var origin := Vector2i.ZERO
	var size := LAB_SIZE
	if manifest_room_id != &"":
		var manifest_definition := ROOM_REGISTRY.room(manifest_room_id)
		origin = manifest_definition.get("worldOrigin", Vector2i.ZERO)
		size = manifest_definition.get("dimensions", Vector2i.ZERO)
	elif area == "town":
		origin = TOWN_ORIGIN
		size = TOWN_SIZE
	elif MANSION_LEGACY_ADAPTER.has_area(StringName(area)):
		var mansion_bounds: Rect2i = MANSION_LEGACY_ADAPTER.bounds_for_area(StringName(area))
		origin = mansion_bounds.position
		size = mansion_bounds.size
	elif area == "station_dock":
		origin = STATION_ORIGIN
		size = Vector2i(8, 8)
	elif area == "station_mess":
		origin = STATION_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "station_hydro":
		origin = STATION_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "station_medical":
		origin = STATION_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "station_control":
		origin = STATION_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	elif area == "primeval_grove":
		origin = PRIMEVAL_ORIGIN
		size = Vector2i(8, 8)
	elif area == "primeval_village":
		origin = PRIMEVAL_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "primeval_ruins":
		origin = PRIMEVAL_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "primeval_nest":
		origin = PRIMEVAL_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "primeval_caldera":
		origin = PRIMEVAL_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	elif area == "helios_skybridge":
		origin = HELIOS_ORIGIN
		size = Vector2i(8, 8)
	elif area == "helios_market":
		origin = HELIOS_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "helios_transit":
		origin = HELIOS_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "helios_clinic":
		origin = HELIOS_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "helios_core":
		origin = HELIOS_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	elif area == "frosthold_gate":
		origin = FROSTHOLD_ORIGIN
		size = Vector2i(8, 8)
	elif area == "frosthold_market":
		origin = FROSTHOLD_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "frosthold_causeway":
		origin = FROSTHOLD_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "frosthold_rune_hall":
		origin = FROSTHOLD_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "frosthold_throne":
		origin = FROSTHOLD_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	elif area == "moonpetal_gate":
		origin = MOONPETAL_ORIGIN
		size = Vector2i(8, 8)
	elif area == "moonpetal_court":
		origin = MOONPETAL_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "moonpetal_garden":
		origin = MOONPETAL_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "moonpetal_bell_walk":
		origin = MOONPETAL_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "moonpetal_palace":
		origin = MOONPETAL_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	elif area == "empyreal_landing":
		origin = EMPYREAL_ORIGIN
		size = Vector2i(8, 8)
	elif area == "empyreal_garden":
		origin = EMPYREAL_ORIGIN + Vector2i(10, 0)
		size = Vector2i(8, 8)
	elif area == "empyreal_forum":
		origin = EMPYREAL_ORIGIN + Vector2i(20, 0)
		size = Vector2i(8, 8)
	elif area == "empyreal_aerie":
		origin = EMPYREAL_ORIGIN + Vector2i(10, 10)
		size = Vector2i(8, 8)
	elif area == "empyreal_tribunal":
		origin = EMPYREAL_ORIGIN + Vector2i(20, 10)
		size = Vector2i(8, 8)
	# The authored foyer is only eight cells wide. Frame it as an interior room
	# so the adjacent archive and empty canvas never leak into the same shot.
	# Camera zoom scales Ben and the environment together; atlas crops themselves
	# remain at their native 48px proportions.
	# An 8x8 room is 384px tall. At the old 2x zoom it became 768px tall in a
	# 540px window, permanently cropping the back wall and its authored props.
	# 1.25x frames the complete 480px room while keeping native pixel art crisp.
	Camera.zoom = Vector2.ONE if manifest_room_id != &"" else (Vector2(1.25, 1.25) if area.begins_with("station") or area.begins_with("primeval") or area.begins_with("helios") or area.begins_with("frosthold") or area.begins_with("moonpetal") or area.begins_with("empyreal") else (Vector2(2.0, 2.0) if area.begins_with("mansion") else Vector2.ONE))
	# Main is deliberately scaled to preserve OpenRPG's 1920x1080 UI while
	# presenting these 48px field tiles at one output pixel per source pixel.
	# Camera2D limits use global canvas coordinates, so include that scale.
	Camera.limit_left = int(origin.x * TILE * global_scale.x)
	Camera.limit_top = int(origin.y * TILE * global_scale.y)
	Camera.limit_right = int((origin.x + size.x) * TILE * global_scale.x)
	Camera.limit_bottom = int((origin.y + size.y) * TILE * global_scale.y)
	Camera.position = gamepiece.global_position
	Camera.reset_smoothing()


func build_facility(plot_index: int, facility_name: String, universe_id: StringName = &"") -> bool:
	if plot_index < 0 or plot_index >= FACILITY_PLOTS.size():
		return false
	var built := CampaignState.anchor_universe(plot_index, universe_id) if universe_id != &"" else CampaignState.build_facility(plot_index, facility_name)
	if _visual.built_facilities.has(plot_index) or not built:
		return false
	_apply_facility(plot_index, facility_name)
	return true


func _apply_facility(plot_index: int, facility_name: String) -> void:
	_visual.set_facility(plot_index, facility_name)
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var newly_blocked: Array[Vector2i] = []
	for y in range(plot.position.y, plot.end.y):
		for x in range(plot.position.x, plot.end.x):
			var local_cell := Vector2i(x, y)
			# Keep a front-door approach tile open at the bottom center.
			if local_cell == Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1):
				continue
			var global_cell := TOWN_ORIGIN + local_cell
			_navigation.set_cell(global_cell, 0, Vector2i(1, 4), 0)
			newly_blocked.append(global_cell)
	# Runtime-created TileMapLayer changes may batch their notification until a
	# later physics tick. Announce collision immediately so path queries made by
	# the player in this frame cannot route through the new building.
	var no_cleared_cells: Array[Vector2i] = []
	_navigation.cells_changed.emit(no_cleared_cells, newly_blocked)
	if facility_name == "Haunted Mansion":
		_create_mansion_transitions(plot_index)
	elif facility_name == "Observatory":
		_create_asterion_transitions(plot_index)
	elif facility_name == "Trailhead Lodge":
		_create_primeval_transitions(plot_index)
	elif facility_name == "Afterlight Club":
		_create_helios_transitions(plot_index)
	elif facility_name == "Cold Storage":
		_create_frosthold_transitions(plot_index)
	elif facility_name == "Tea House":
		_create_moonpetal_transitions(plot_index)
	elif facility_name == "Belfry":
		_create_empyreal_transitions(plot_index)
	else:
		_ensure_facility_service(plot_index, facility_name)


func _ensure_facility_service(plot_index: int, facility_name: String) -> void:
	if facility_name not in ["Cafe", "Library", "Clinic", "Armory"]:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world:
		return
	var node_name := "%sService" % facility_name
	var service := world.get_node_or_null(node_name) as TownFacilityInteraction
	if not service:
		service = TOWN_FACILITY_INTERACTION.instantiate() as TownFacilityInteraction
		service.name = node_name
		service.facility_name = facility_name
		service.menu = _campaign_menu
		world.add_child(service)
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	service.position = Gameboard.cell_to_pixel(TOWN_ORIGIN + local_door)


func _restore_campaign_state() -> void:
	for plot_index in CampaignState.built_facilities.keys():
		_apply_facility(int(plot_index), CampaignState.built_facilities[plot_index])
	_update_mansion_passage()
	_update_mansion_ballroom_gate()
	_update_asterion_control_gate()
	_update_primeval_nest_gate()
	_update_primeval_caldera_gate()
	_update_primeval_canopy_shortcut()
	_update_helios_clinic_gate()
	_update_helios_core_gate()
	_update_frosthold_rune_hall_gate()
	_update_frosthold_throne_gate()
	_update_moonpetal_bell_walk_gate()
	_update_moonpetal_palace_gate()
	_update_empyreal_aerie_gate()
	_update_empyreal_tribunal_gate()
	refresh_sandbox_object_collision()
	if _sandbox_objects:
		_sandbox_objects.queue_redraw()
	if _resident_manager:
		_resident_manager.sync_residents()


func refresh_sandbox_object_collision() -> void:
	if not _navigation:
		return
	var blocked := _blocked_cells()
	for plot_index in CampaignState.built_facilities.keys():
		var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
		for y in range(plot.position.y, plot.end.y):
			for x in range(plot.position.x, plot.end.x):
				var local_cell := Vector2i(x, y)
				if local_cell == Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1):
					continue
				blocked[TOWN_ORIGIN + local_cell] = true
	for placed in CampaignState.town_objects:
		var definition := SANDBOX_OBJECT_CATALOG.definition(StringName(placed.get("catalog_id", "")))
		if not bool(definition.get("blocks", true)):
			continue
		var footprint: Vector2i = definition.get("footprint", Vector2i.ONE)
		var origin := Vector2i(int(placed.get("x", 0)), int(placed.get("y", 0)))
		for y in range(footprint.y):
			for x in range(footprint.x):
				blocked[origin + Vector2i(x, y)] = true
	for cell in CampaignState.town_terrain_cells():
		var terrain_definition: Dictionary = SANDBOX_TERRAIN_CATALOG.definition(CampaignState.town_terrain_at(cell))
		if bool(terrain_definition.get("blocks", false)):
			blocked[cell] = true
	var cleared_cells: Array[Vector2i] = []
	var blocked_cells: Array[Vector2i] = []
	for y in range(TOWN_SIZE.y):
		for x in range(TOWN_SIZE.x):
			var cell := TOWN_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			_navigation.set_cell(cell, 0, Vector2i(1, 4) if is_blocked else Vector2i(2, 2), 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	_navigation.cells_changed.emit(cleared_cells, blocked_cells)
	_sync_sandbox_authored_entities()


func _sync_sandbox_authored_entities() -> void:
	if not CampaignState.sandbox_mode:
		return
	var laboratory := CampaignState.town_object_with_role(&"town_lab")
	if laboratory.is_empty():
		return
	var lab_origin := Vector2i(int(laboratory.get("x", TOWN_LAB_DOOR.x - 2)), int(laboratory.get("y", TOWN_LAB_DOOR.y - 2)))
	var lab_definition: Dictionary = SANDBOX_OBJECT_CATALOG.definition(StringName(laboratory.get("catalog_id", &"modern_warehouse")))
	var lab_footprint: Vector2i = lab_definition.get("footprint", Vector2i(4, 2))
	var door_cell := lab_origin + Vector2i(int(lab_footprint.x / 2), lab_footprint.y)
	var arrival_cell := door_cell + Vector2i.DOWN
	var town_door := get_node_or_null("Field/Map/CampaignWorld/TownLaboratoryDoor") as AreaTransition
	if town_door:
		town_door.position = Gameboard.cell_to_pixel(door_cell)
	var lab_exit := get_node_or_null("Field/Map/CampaignWorld/LaboratoryExit") as AreaTransition
	if lab_exit:
		lab_exit.arrival_coordinates = Gameboard.cell_to_pixel(arrival_cell)


func sandbox_resident_at_cell(cell: Vector2i) -> Dictionary:
	return _resident_manager.resident_at_cell(cell) if _resident_manager else {}


func sandbox_resident_summary(resident_id: StringName) -> Dictionary:
	return _resident_manager.resident_summary(resident_id) if _resident_manager else {}


func relocate_sandbox_resident(resident_id: StringName, cell: Vector2i) -> bool:
	return _resident_manager.relocate_resident(resident_id, cell) if _resident_manager else false


func restore_sandbox_layout() -> void:
	refresh_sandbox_object_collision()
	if _resident_manager:
		_resident_manager.restore_sandbox_layout_positions()


func sandbox_required_routes_reachable() -> bool:
	# Sandbox edits may change scenery freely, but must never isolate the lab or a
	# constructed service from the town arrival route. Ignore moving actors while
	# checking topology: only static collision should reject an edit.
	if not CampaignState.sandbox_mode or not Gameboard.pathfinder.has_cell(TOWN_ARRIVAL):
		return true
	var required_cells: Array[Vector2i] = []
	var laboratory := CampaignState.town_object_with_role(&"town_lab")
	if laboratory.is_empty():
		return false
	var lab_definition: Dictionary = SANDBOX_OBJECT_CATALOG.definition(StringName(laboratory.get("catalog_id", "")))
	if lab_definition.is_empty():
		return false
	var lab_footprint: Vector2i = lab_definition.get("footprint", Vector2i(4, 2))
	var lab_origin := Vector2i(int(laboratory.get("x", 0)), int(laboratory.get("y", 0)))
	required_cells.append(lab_origin + Vector2i(int(lab_footprint.x / 2), lab_footprint.y))
	for plot_index in CampaignState.built_facilities.keys():
		var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
		required_cells.append(TOWN_ORIGIN + Vector2i(plot.position.x + int(plot.size.x / 2), plot.end.y - 1))
	for target in required_cells:
		if not Gameboard.pathfinder.has_cell(target):
			return false
		if Gameboard.pathfinder.get_path_to_cell(TOWN_ARRIVAL, target, Pathfinder.FLAG_ALLOW_ALL_OCCUPANTS).is_empty():
			return false
	return true


func _on_recruit_status_changed(recruit_id: StringName, status: StringName) -> void:
	if recruit_id == &"fighter":
		if status == &"party":
			var fighter := get_node_or_null("Field/Map/CampaignWorld/RecruitableFighter")
			if fighter:
				fighter.queue_free()
		else:
			_spawn_fighter()
	elif recruit_id == &"astronaut":
		if status in [&"party", &"reserve", &"staffed"]:
			var astronaut := get_node_or_null("Field/Map/CampaignWorld/RecruitableAstronaut")
			if astronaut:
				astronaut.queue_free()
		else:
			_spawn_astronaut()
	elif recruit_id == &"caveman":
		if status in [&"party", &"reserve", &"staffed"]:
			var caveman := get_node_or_null("Field/Map/CampaignWorld/RecruitableCaveman")
			if caveman:
				caveman.queue_free()
		else:
			_spawn_caveman()
	elif recruit_id == &"neon_viper":
		if status in [&"party", &"reserve", &"staffed"]:
			var viper := get_node_or_null("Field/Map/CampaignWorld/RecruitableNeonViper")
			if viper:
				viper.queue_free()
		else:
			_spawn_neon_viper()
	elif recruit_id == &"frost_lich_emperor":
		if status in [&"party", &"reserve", &"staffed"]:
			var lich := get_node_or_null("Field/Map/CampaignWorld/RecruitableFrostLich")
			if lich:
				lich.queue_free()
		else:
			_spawn_frost_lich()
	elif recruit_id == &"kitsune_empress":
		if status in [&"party", &"reserve", &"staffed"]:
			var kitsune := get_node_or_null("Field/Map/CampaignWorld/RecruitableKitsune")
			if kitsune:
				kitsune.queue_free()
		else:
			_spawn_kitsune()
	elif recruit_id == &"crimson_oni":
		if status in [&"party", &"reserve", &"staffed"]:
			var oni := get_node_or_null("Field/Map/CampaignWorld/RecruitableCrimsonOni")
			if oni:
				oni.queue_free()
		else:
			_spawn_crimson_oni()
	elif recruit_id == &"rift_jackal":
		if status in [&"party", &"reserve", &"staffed"]:
			var jackal := get_node_or_null("Field/Map/CampaignWorld/RecruitableRiftJackal")
			if jackal:
				jackal.queue_free()
		else:
			_spawn_rift_jackal()
	elif recruit_id == &"mossback_surveyor":
		if status in [&"party", &"reserve", &"staffed"]:
			var surveyor := get_node_or_null("Field/Map/CampaignWorld/RecruitableMossbackSurveyor")
			if surveyor:
				surveyor.queue_free()
		else:
			_spawn_mossback_surveyor()
	elif recruit_id == &"cobalt_courier":
		if status in [&"party", &"reserve", &"staffed"]:
			var courier := get_node_or_null("Field/Map/CampaignWorld/RecruitableCobaltCourier")
			if courier:
				courier.queue_free()
		else:
			_spawn_cobalt_courier()
	elif recruit_id == &"bulkhead_warden":
		if status in [&"party", &"reserve", &"staffed"]:
			var warden := get_node_or_null("Field/Map/CampaignWorld/RecruitableBulkheadWarden")
			if warden:
				warden.queue_free()
		else:
			_spawn_bulkhead_warden()
	elif recruit_id == &"archangel_commander":
		if status in [&"party", &"reserve", &"staffed"]:
			var archangel := get_node_or_null("Field/Map/CampaignWorld/RecruitableArchangel")
			if archangel:
				archangel.queue_free()
		else:
			_spawn_archangel()


func _spawn_available_recruits() -> void:
	var status: StringName = CampaignState.recruit_status.get(&"fighter", &"undiscovered")
	if status not in [&"undiscovered", &"party"]:
		_spawn_fighter()
	var astronaut_status: StringName = CampaignState.recruit_status.get(&"astronaut", &"undiscovered")
	if CampaignState.story_flags.get(&"asterion_anchor_built", false) and astronaut_status in [&"undiscovered", &"available"]:
		_spawn_astronaut()
	var caveman_status: StringName = CampaignState.recruit_status.get(&"caveman", &"undiscovered")
	if CampaignState.story_flags.get(&"primeval_anchor_built", false) and caveman_status in [&"undiscovered", &"available"]:
		_spawn_caveman()
	var viper_status: StringName = CampaignState.recruit_status.get(&"neon_viper", &"undiscovered")
	if CampaignState.story_flags.get(&"helios_anchor_built", false) and viper_status in [&"undiscovered", &"available"]:
		_spawn_neon_viper()
	var lich_status: StringName = CampaignState.recruit_status.get(&"frost_lich_emperor", &"undiscovered")
	if CampaignState.story_flags.get(&"frosthold_anchor_built", false) and lich_status in [&"undiscovered", &"available"]:
		_spawn_frost_lich()
	var kitsune_status: StringName = CampaignState.recruit_status.get(&"kitsune_empress", &"undiscovered")
	if CampaignState.story_flags.get(&"moonpetal_anchor_built", false) and kitsune_status in [&"undiscovered", &"available"]:
		_spawn_kitsune()
	var oni_status: StringName = CampaignState.recruit_status.get(&"crimson_oni", &"undiscovered")
	if CampaignState.story_flags.get(&"moonpetal_scenario_complete", false) and int(CampaignState.inventory.get(&"crimson_challenge_seal", 0)) > 0 and oni_status in [&"undiscovered", &"available"]:
		_spawn_crimson_oni()
	var jackal_status: StringName = CampaignState.recruit_status.get(&"rift_jackal", &"undiscovered")
	if CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false) and jackal_status in [&"undiscovered", &"available"]:
		_spawn_rift_jackal()
	var mossback_status: StringName = CampaignState.recruit_status.get(&"mossback_surveyor", &"undiscovered")
	if CampaignState.story_flags.get(&"primeval_scenario_complete", false) and mossback_status in [&"undiscovered", &"available"]:
		_spawn_mossback_surveyor()
	var courier_status: StringName = CampaignState.recruit_status.get(&"cobalt_courier", &"undiscovered")
	if CampaignState.story_flags.get(&"helios_scenario_complete", false) and courier_status in [&"undiscovered", &"available"]:
		_spawn_cobalt_courier()
	var warden_status: StringName = CampaignState.recruit_status.get(&"bulkhead_warden", &"undiscovered")
	if CampaignState.story_flags.get(&"asterion_station_complete", false) and warden_status in [&"undiscovered", &"available"]:
		_spawn_bulkhead_warden()
	var archangel_status: StringName = CampaignState.recruit_status.get(&"archangel_commander", &"undiscovered")
	if CampaignState.story_flags.get(&"empyreal_anchor_built", false) and archangel_status in [&"undiscovered", &"available"]:
		_spawn_archangel()


func _spawn_fighter() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableFighter"):
		return
	var cafe_plot := 0
	for plot_index in CampaignState.built_facilities.keys():
		if CampaignState.built_facilities[plot_index] == "Cafe":
			cafe_plot = int(plot_index)
			break
	var plot: Rect2i = FACILITY_PLOTS[cafe_plot]
	var local_spawn := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y + 1)
	var fighter := FIGHTER_GAMEPIECE.instantiate() as Gamepiece
	fighter.name = "RecruitableFighter"
	fighter.position = Gameboard.cell_to_pixel(TOWN_ORIGIN + local_spawn)
	world.add_child(fighter)


func _create_mansion_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("HauntedMansionEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	var entry_room := ROOM_REGISTRY.room(&"HM-01")
	var entry_origin: Vector2i = entry_room.get("worldOrigin", MANSION_ORIGIN)
	var entry_port: Vector2i = (entry_room.get("portCells", {}) as Dictionary).get(&"Nw", Vector2i.ZERO)
	var entry_arrival := entry_origin + TRANSITION_ROUTER.safe_arrival_cell(&"HM-01", &"Nw")
	world.add_child(_create_restricted_transition("HauntedMansionEntrance", town_door, entry_arrival, town_return, &"haunted_mansion"))
	world.add_child(_create_transition("HauntedMansionExit", entry_origin + entry_port, town_return))


func _create_asterion_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("AsterionStationEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	var entry_room := ROOM_REGISTRY.room(&"AS-01")
	var entry_origin: Vector2i = entry_room.get("worldOrigin", STATION_ORIGIN)
	var entry_port: Vector2i = (entry_room.get("portCells", {}) as Dictionary).get(&"Nw", Vector2i.ZERO)
	var entry_arrival := entry_origin + TRANSITION_ROUTER.safe_arrival_cell(&"AS-01", &"Nw")
	world.add_child(_create_transition("AsterionStationEntrance", town_door, entry_arrival))
	world.add_child(_create_transition("AsterionStationExit", entry_origin + entry_port, town_return))
	# These authored station rooms still use their established physical layout.
	# Keep its links live while the complete 14-room graph remains a validated
	# manifest contract rather than exposing unbuilt destinations.
	world.add_child(_create_transition("StationDockToMess", STATION_DOCK_TO_MESS, STATION_MESS_FROM_DOCK))
	world.add_child(_create_transition("StationMessToDock", STATION_MESS_RETURN, STATION_DOCK_FROM_MESS))
	world.add_child(_create_transition("StationMessToHydro", STATION_MESS_TO_HYDRO, STATION_HYDRO_FROM_MESS))
	world.add_child(_create_transition("StationHydroToMess", STATION_HYDRO_RETURN, STATION_MESS_FROM_HYDRO))
	world.add_child(_create_transition("StationMessToMedical", STATION_MESS_TO_MEDICAL, STATION_MEDICAL_FROM_MESS))
	world.add_child(_create_transition("StationMedicalToMess", STATION_MEDICAL_RETURN, STATION_MESS_FROM_MEDICAL))
	_spawn_astronaut()


func _create_primeval_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("PrimevalExpanseEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	var entry_room := ROOM_REGISTRY.room(&"PV-01")
	var entry_origin: Vector2i = entry_room.get("worldOrigin", PRIMEVAL_ORIGIN)
	var entry_port: Vector2i = (entry_room.get("portCells", {}) as Dictionary).get(&"Nw", Vector2i.ZERO)
	world.add_child(_create_transition("PrimevalExpanseEntrance", town_door, entry_origin + TRANSITION_ROUTER.safe_arrival_cell(&"PV-01", &"Nw")))
	world.add_child(_create_transition("PrimevalExpanseExit", entry_origin + entry_port, town_return))
	# Preserve navigation through the five authored Primeval rooms until the
	# remaining manifest rooms have their own approved scene implementations.
	world.add_child(_create_transition("PrimevalGroveToVillage", PRIMEVAL_GROVE_TO_VILLAGE, PRIMEVAL_VILLAGE_FROM_GROVE))
	world.add_child(_create_transition("PrimevalVillageToGrove", PRIMEVAL_VILLAGE_RETURN, PRIMEVAL_GROVE_FROM_VILLAGE))
	world.add_child(_create_transition("PrimevalVillageToRuins", PRIMEVAL_VILLAGE_TO_RUINS, PRIMEVAL_RUINS_FROM_VILLAGE))
	world.add_child(_create_transition("PrimevalRuinsToVillage", PRIMEVAL_RUINS_RETURN, PRIMEVAL_VILLAGE_FROM_RUINS))


func _create_helios_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("HeliosArcologyEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	world.add_child(_create_transition("HeliosArcologyEntrance", town_door, HELIOS_SPAWN))
	world.add_child(_create_transition("HeliosArcologyExit", HELIOS_EXIT, town_return))
	world.add_child(_create_transition("HeliosSkybridgeToMarket", HELIOS_SKYBRIDGE_TO_MARKET, HELIOS_MARKET_FROM_SKYBRIDGE))
	world.add_child(_create_transition("HeliosMarketToSkybridge", HELIOS_MARKET_RETURN, HELIOS_SKYBRIDGE_FROM_MARKET))
	world.add_child(_create_transition("HeliosMarketToTransit", HELIOS_MARKET_TO_TRANSIT, HELIOS_TRANSIT_FROM_MARKET))
	world.add_child(_create_transition("HeliosTransitToMarket", HELIOS_TRANSIT_RETURN, HELIOS_MARKET_FROM_TRANSIT))
	_spawn_neon_viper()
	_update_helios_clinic_gate()
	_update_helios_core_gate()


func _create_frosthold_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("FrostholdKingdomEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	world.add_child(_create_transition("FrostholdKingdomEntrance", town_door, FROSTHOLD_SPAWN))
	world.add_child(_create_transition("FrostholdKingdomExit", FROSTHOLD_EXIT, town_return))
	world.add_child(_create_transition("FrostholdGateToMarket", FROSTHOLD_GATE_TO_MARKET, FROSTHOLD_MARKET_FROM_GATE))
	world.add_child(_create_transition("FrostholdMarketToGate", FROSTHOLD_MARKET_RETURN, FROSTHOLD_GATE_FROM_MARKET))
	world.add_child(_create_transition("FrostholdMarketToCauseway", FROSTHOLD_MARKET_TO_CAUSEWAY, FROSTHOLD_CAUSEWAY_FROM_MARKET))
	world.add_child(_create_transition("FrostholdCausewayToMarket", FROSTHOLD_CAUSEWAY_RETURN, FROSTHOLD_MARKET_FROM_CAUSEWAY))
	_spawn_frost_lich()
	_update_frosthold_rune_hall_gate()
	_update_frosthold_throne_gate()


func _create_moonpetal_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("MoonpetalCourtEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	world.add_child(_create_transition("MoonpetalCourtEntrance", town_door, MOONPETAL_SPAWN))
	world.add_child(_create_transition("MoonpetalCourtExit", MOONPETAL_EXIT, town_return))
	world.add_child(_create_transition("MoonpetalGateToCourt", MOONPETAL_GATE_TO_COURT, MOONPETAL_COURT_FROM_GATE))
	world.add_child(_create_transition("MoonpetalCourtToGate", MOONPETAL_COURT_RETURN, MOONPETAL_GATE_FROM_COURT))
	world.add_child(_create_transition("MoonpetalCourtToGarden", MOONPETAL_COURT_TO_GARDEN, MOONPETAL_GARDEN_FROM_COURT))
	world.add_child(_create_transition("MoonpetalGardenToCourt", MOONPETAL_GARDEN_RETURN, MOONPETAL_COURT_FROM_GARDEN))
	_spawn_kitsune()
	_update_moonpetal_bell_walk_gate()
	_update_moonpetal_palace_gate()


func _create_empyreal_transitions(plot_index: int) -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("EmpyrealCourtEntrance"):
		return
	var plot: Rect2i = FACILITY_PLOTS[plot_index]
	var local_door := Vector2i(plot.position.x + plot.size.x / 2, plot.end.y - 1)
	var town_door := TOWN_ORIGIN + local_door
	var town_return := TOWN_ORIGIN + Vector2i(local_door.x, plot.end.y)
	world.add_child(_create_transition("EmpyrealCourtEntrance", town_door, EMPYREAL_SPAWN))
	world.add_child(_create_transition("EmpyrealCourtExit", EMPYREAL_EXIT, town_return))
	world.add_child(_create_transition("EmpyrealLandingToGarden", EMPYREAL_LANDING_TO_GARDEN, EMPYREAL_GARDEN_FROM_LANDING))
	world.add_child(_create_transition("EmpyrealGardenToLanding", EMPYREAL_GARDEN_RETURN, EMPYREAL_LANDING_FROM_GARDEN))
	world.add_child(_create_transition("EmpyrealGardenToForum", EMPYREAL_GARDEN_TO_FORUM, EMPYREAL_FORUM_FROM_GARDEN))
	world.add_child(_create_transition("EmpyrealForumToGarden", EMPYREAL_FORUM_RETURN, EMPYREAL_GARDEN_FROM_FORUM))
	_spawn_archangel()
	_update_empyreal_aerie_gate()
	_update_empyreal_tribunal_gate()


func _ensure_campaign_input() -> void:
	if not InputMap.has_action("town_build_mode"):
		InputMap.add_action("town_build_mode")
	var has_key := false
	var has_controller := false
	for input_event in InputMap.action_get_events("town_build_mode"):
		has_key = has_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_B)
		has_controller = has_controller or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_Y)
	if not has_key:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = KEY_B
		InputMap.action_add_event("town_build_mode", key_event)
	if not has_controller:
		var controller_event := InputEventJoypadButton.new()
		controller_event.button_index = JOY_BUTTON_Y
		InputMap.action_add_event("town_build_mode", controller_event)
	_ensure_joy_button("interact", JOY_BUTTON_A)
	_ensure_joy_button("back", JOY_BUTTON_B)
	# Godot Controls consume the standard UI actions, while field interactions
	# use interact/back. Bind both pairs so A/B work consistently in every menu.
	_ensure_joy_button("ui_accept", JOY_BUTTON_A)
	_ensure_joy_button("ui_cancel", JOY_BUTTON_B)
	_ensure_campaign_menu_input()
	_ensure_facility_management_input()
	_ensure_quest_journal_input()
	_ensure_roster_input()
	_ensure_anchor_recall_input()


func _ensure_joy_button(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for input_event in InputMap.action_get_events(action):
		if input_event is InputEventJoypadButton and input_event.button_index == button:
			return
	var controller_event := InputEventJoypadButton.new()
	controller_event.button_index = button
	InputMap.action_add_event(action, controller_event)


func _ensure_campaign_menu_input() -> void:
	if not InputMap.has_action("campaign_menu"):
		InputMap.add_action("campaign_menu")
	var has_tab := false
	var has_inventory_key := false
	var has_start := false
	for input_event in InputMap.action_get_events("campaign_menu"):
		has_tab = has_tab or (input_event is InputEventKey and input_event.physical_keycode == KEY_TAB)
		has_inventory_key = has_inventory_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_I)
		has_start = has_start or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_START)
	for keycode in ([KEY_TAB] if not has_tab else []) + ([KEY_I] if not has_inventory_key else []):
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		InputMap.action_add_event("campaign_menu", key_event)
	if not has_start:
		var controller_event := InputEventJoypadButton.new()
		controller_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event("campaign_menu", controller_event)


func _ensure_facility_management_input() -> void:
	if not InputMap.has_action("facility_management"):
		InputMap.add_action("facility_management")
	var has_key := false
	var has_controller := false
	for input_event in InputMap.action_get_events("facility_management"):
		has_key = has_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_M)
		has_controller = has_controller or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_BACK)
	if not has_key:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = KEY_M
		InputMap.action_add_event("facility_management", key_event)
	if not has_controller:
		var controller_event := InputEventJoypadButton.new()
		controller_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event("facility_management", controller_event)


func _ensure_quest_journal_input() -> void:
	if not InputMap.has_action("quest_journal"):
		InputMap.add_action("quest_journal")
	for input_event in InputMap.action_get_events("quest_journal"):
		if input_event is InputEventKey and input_event.physical_keycode == KEY_J:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = KEY_J
	InputMap.action_add_event("quest_journal", key_event)


func _ensure_roster_input() -> void:
	if not InputMap.has_action("roster_menu"):
		InputMap.add_action("roster_menu")
	for input_event in InputMap.action_get_events("roster_menu"):
		if input_event is InputEventKey and input_event.physical_keycode == KEY_R:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = KEY_R
	InputMap.action_add_event("roster_menu", key_event)


func _ensure_anchor_recall_input() -> void:
	if not InputMap.has_action("anchor_recall"):
		InputMap.add_action("anchor_recall")
	var has_key := false
	var has_controller := false
	for input_event in InputMap.action_get_events("anchor_recall"):
		has_key = has_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_K)
		has_controller = has_controller or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_LEFT_STICK)
	if not has_key:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = KEY_K
		InputMap.action_add_event("anchor_recall", key_event)
	if not has_controller:
		var controller_event := InputEventJoypadButton.new()
		controller_event.button_index = JOY_BUTTON_LEFT_STICK
		InputMap.action_add_event("anchor_recall", controller_event)


func _create_navigation_layer() -> GameboardLayer:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	tile_set.add_custom_data_layer(0)
	tile_set.set_custom_data_layer_name(0, GameboardLayer.BLOCKED_CELL_DATA_LAYER)
	tile_set.set_custom_data_layer_type(0, TYPE_BOOL)

	var atlas := TileSetAtlasSource.new()
	atlas.texture = _visual_profiles.texture(&"sandbox_ranch_dirt")
	atlas.texture_region_size = Vector2i(16, 16)
	var clear_tile := Vector2i(2, 2)
	var blocked_tile := Vector2i(1, 4)
	atlas.create_tile(clear_tile)
	atlas.create_tile(blocked_tile)
	tile_set.add_source(atlas, 0)
	atlas.get_tile_data(clear_tile, 0).set_custom_data(GameboardLayer.BLOCKED_CELL_DATA_LAYER, false)
	atlas.get_tile_data(blocked_tile, 0).set_custom_data(GameboardLayer.BLOCKED_CELL_DATA_LAYER, true)

	var layer := GameboardLayer.new()
	layer.name = "CampaignNavigation"
	layer.tile_set = tile_set
	layer.visible = false
	var blocked := _blocked_cells()
	var cleared_cells: Array[Vector2i] = []
	var blocked_cells: Array[Vector2i] = []
	for y in range(LAB_SIZE.y):
		for x in range(LAB_SIZE.x):
			var cell := Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(TOWN_SIZE.y):
		for x in range(TOWN_SIZE.x):
			var cell := TOWN_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(MANSION_SIZE.y):
		for x in range(MANSION_SIZE.x):
			var cell := MANSION_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(STATION_SIZE.y):
		for x in range(STATION_SIZE.x):
			var cell := STATION_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(PRIMEVAL_SIZE.y):
		for x in range(PRIMEVAL_SIZE.x):
			var cell := PRIMEVAL_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(HELIOS_SIZE.y):
		for x in range(HELIOS_SIZE.x):
			var cell := HELIOS_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(FROSTHOLD_SIZE.y):
		for x in range(FROSTHOLD_SIZE.x):
			var cell := FROSTHOLD_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(MOONPETAL_SIZE.y):
		for x in range(MOONPETAL_SIZE.x):
			var cell := MOONPETAL_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for y in range(EMPYREAL_SIZE.y):
		for x in range(EMPYREAL_SIZE.x):
			var cell := EMPYREAL_ORIGIN + Vector2i(x, y)
			var is_blocked := blocked.has(cell)
			layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
			(blocked_cells if is_blocked else cleared_cells).append(cell)
	for room_id in ROOM_REGISTRY.streamed_room_ids():
		var definition := ROOM_REGISTRY.room(room_id)
		var room_origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
		var navigation_record := NAVIGATION_BUILDER.navigation_record(room_id)
		var room_dimensions: Vector2i = navigation_record.get("dimensions", Vector2i.ZERO)
		var walkable: Dictionary = navigation_record.get("walkable", {})
		for y in range(room_dimensions.y):
			for x in range(room_dimensions.x):
				var cell := room_origin + Vector2i(x, y)
				var is_blocked := not walkable.has(Vector2i(x, y))
				layer.set_cell(cell, 0, blocked_tile if is_blocked else clear_tile, 0)
				(blocked_cells if is_blocked else cleared_cells).append(cell)
	# Programmatic TileMap cells are populated before the node's _ready(), so its
	# automatic update can precede Gameboard's signal registration. Re-announce
	# the initial state immediately after registration to build the path graph.
	layer.ready.connect(
		func() -> void: layer.cells_changed.emit(cleared_cells, blocked_cells),
		CONNECT_ONE_SHOT
	)
	return layer


func _profiled_texture(profile_id: StringName) -> Texture2D:
	if not _visual_profiles.has(profile_id):
		push_error("Campaign marker references missing visual profile: %s" % profile_id)
		return null
	var source_texture := _visual_profiles.texture(profile_id)
	if not source_texture:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = _visual_profiles.region(profile_id)
	return atlas


func _blocked_cells() -> Dictionary:
	var blocked := {}
	_add_boundaries(blocked, Vector2i.ZERO, LAB_SIZE)
	for x in range(LAB_SIZE.x):
		blocked[Vector2i(x, 1)] = true
		blocked[Vector2i(x, 2)] = true
	# Match the complete analysis/fabrication benches, including their upper
	# counter row. Previously row 3 remained walkable through the worktops.
	for x in range(1, 8):
		for y in range(3, 6):
			blocked[Vector2i(x, y)] = true
	for x in range(11, 19):
		for y in range(3, 6):
			blocked[Vector2i(x, y)] = true
	for x in range(1, 6):
		for y in range(7, 10):
			blocked[Vector2i(x, y)] = true
	for x in range(14, 19):
		for y in range(7, 10):
			blocked[Vector2i(x, y)] = true
	blocked.erase(LAB_EXIT)

	_add_boundaries(blocked, TOWN_ORIGIN, TOWN_SIZE)
	if not CampaignState.sandbox_mode:
		# The enlarged warehouse facade spans four cells from roof through doorway.
		# Blocking only its lower two rows let the party walk across the roof.
		for y in range(3, 7):
			for x in range(12, 16):
				blocked[TOWN_ORIGIN + Vector2i(x, y)] = true
		# Authored town trees are background scenery, not traversable grass. Cover
		# the same cells as each visible canopy/trunk island. In sandbox mode these
		# are movable catalog objects, whose relocated footprints are handled below.
		_block_rect(blocked, TOWN_ORIGIN + Vector2i(1, 1), Vector2i(2, 2))
		_block_rect(blocked, TOWN_ORIGIN + Vector2i(28, 1), Vector2i(3, 3))
		_block_rect(blocked, TOWN_ORIGIN + Vector2i(2, 18), Vector2i(3, 3))
		_block_rect(blocked, TOWN_ORIGIN + Vector2i(29, 19), Vector2i(2, 2))
	blocked.erase(TOWN_LAB_DOOR)

	# Mansion rooms are isolated camera-sized stages. Begin with the entire
	# 28x18 scenario void blocked and explicitly open only authored floor cells;
	# point-and-click pathfinding can therefore never route through visual gaps.
	# The room shells render a four-cell-deep floor across their full width. The
	# former 6×3 lanes left visible planks unnavigable and made every room feel
	# like a narrow encounter stage instead of a place to investigate.
	for y in range(MANSION_SIZE.y):
		for x in range(MANSION_SIZE.x):
			blocked[MANSION_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, MANSION_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, MANSION_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, MANSION_ORIGIN + Vector2i(0, 14), Vector2i(8, 4))
	_open_rect(blocked, MANSION_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, MANSION_ORIGIN + Vector2i(20, 9), Vector2i(8, 4))
	# Furniture footprints remain solid while their neighboring interaction cells
	# stay reachable.
	blocked[MANSION_ORIGIN + Vector2i(10, 5)] = true
	blocked[MANSION_ORIGIN + Vector2i(16, 5)] = true
	blocked[MANSION_ORIGIN + Vector2i(24, 9)] = true
	if not CampaignState.story_flags.get(&"mansion_first_room_complete", false):
		blocked[MANSION_LEGACY_ADAPTER.passage_gate_cell()] = true
	if not CampaignState.story_flags.get(&"mansion_ballroom_open", false):
		blocked[MANSION_LEGACY_ADAPTER.ballroom_gate_cell()] = true
	blocked.erase(MANSION_EXIT)

	# Asterion's painted rooms visibly expose an eight-wide, four-cell-deep floor.
	# The former 6x3 encounter lanes made the arrival bay, mess, hydroponics,
	# medical bay, and control room feel like the same narrow corridor.
	for y in range(STATION_SIZE.y):
		for x in range(STATION_SIZE.x):
			blocked[STATION_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, STATION_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, STATION_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, STATION_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, STATION_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, STATION_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	if not CampaignState.story_flags.get(&"asterion_station_restored", false):
		blocked[STATION_HYDRO_TO_CONTROL] = true
	blocked.erase(STATION_EXIT)

	# Primeval's complete terrain quadrants expose an eight-wide, four-cell-deep
	# lower trail. The former 6x3 strips turned every biome into the same corridor
	# despite their distinct settlement, ruins, nest, and caldera compositions.
	for y in range(PRIMEVAL_SIZE.y):
		for x in range(PRIMEVAL_SIZE.x):
			blocked[PRIMEVAL_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	# The desert ruins have a visible central temple approach. Let the party walk
	# up that aisle instead of colliding with an invisible horizontal strip.
	_open_rect(blocked, PRIMEVAL_ORIGIN + Vector2i(23, 1), Vector2i(2, 4))
	if not CampaignState.story_flags.get(&"primeval_terminal_decoded", false):
		blocked[PRIMEVAL_VILLAGE_TO_NEST] = true
	if not CampaignState.story_flags.get(&"primeval_caldera_open", false):
		blocked[PRIMEVAL_RUINS_TO_CALDERA] = true
	blocked.erase(PRIMEVAL_EXIT)

	# Helios uses complete authored city quadrants as five distinct districts.
	# Eight-by-four floor footprints give every district room for its landmarks,
	# side terminals, and a route around the central approach without making the
	# painted roofs, counters, or landscaping traversable.
	for y in range(HELIOS_SIZE.y):
		for x in range(HELIOS_SIZE.x):
			blocked[HELIOS_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, HELIOS_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, HELIOS_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, HELIOS_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, HELIOS_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, HELIOS_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	if &"night_phase_inverter" not in CampaignState.owned_inventions:
		blocked[HELIOS_MARKET_TO_CLINIC] = true
	if not CampaignState.story_flags.get(&"helios_core_open", false):
		blocked[HELIOS_TRANSIT_TO_CORE] = true
	blocked.erase(HELIOS_EXIT)

	# Frosthold's gate, market, causeway, rune hall, and throne approach each get
	# a full eight-by-four snow or stone floor footprint. The painted approaches
	# below extend those footprints where a gate aisle or bridge visibly calls for
	# it; houses, walls, crystals, and ruins remain solid scenery.
	for y in range(FROSTHOLD_SIZE.y):
		for x in range(FROSTHOLD_SIZE.x):
			blocked[FROSTHOLD_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	# Open the actual painted approaches: gate aisle, two-section crystal bridge,
	# rune-hall nave, and one side of the occupied throne approach. These branches
	# make the rooms play differently while keeping every existing transition cell.
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(3, 2), Vector2i(2, 3))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(23, 1), Vector2i(2, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(13, 11), Vector2i(2, 4))
	_open_rect(blocked, FROSTHOLD_ORIGIN + Vector2i(23, 11), Vector2i(1, 4))
	# The boss visibly occupies this tile until the throne encounter resolves.
	if not CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
		blocked[FROSTHOLD_ORIGIN + Vector2i(24, 13)] = true
	# Save braziers and caches are solid props; interactions remain reachable from
	# neighboring clear cells.
	blocked[FROSTHOLD_ORIGIN + Vector2i(12, 15)] = true
	blocked[FROSTHOLD_ORIGIN + Vector2i(14, 4)] = true
	if not CampaignState.story_flags.get(&"frosthold_causeway_seal_open", false):
		blocked[FROSTHOLD_MARKET_TO_RUNE_HALL] = true
	if not CampaignState.story_flags.get(&"frosthold_throne_open", false):
		blocked[FROSTHOLD_CAUSEWAY_TO_THRONE] = true
	blocked.erase(FROSTHOLD_EXIT)

	# Moonpetal's gate, court, garden, bell walk, and palace each have an eight by
	# four courtyard floor. Temples, trees, ponds, gates, and garden islands remain
	# scenery with collision matching their visible composition.
	for y in range(MOONPETAL_SIZE.y):
		for x in range(MOONPETAL_SIZE.x):
			blocked[MOONPETAL_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, MOONPETAL_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, MOONPETAL_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, MOONPETAL_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, MOONPETAL_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, MOONPETAL_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	# The palace's framed gardens flank the narrow stone avenue. Their old cells
	# were open, allowing Ben to stand on the blossom bed and raked-stone frame.
	_block_rect(blocked, MOONPETAL_ORIGIN + Vector2i(21, 14), Vector2i(2, 2))
	_block_rect(blocked, MOONPETAL_ORIGIN + Vector2i(25, 14), Vector2i(2, 2))
	blocked[MOONPETAL_ORIGIN + Vector2i(11, 15)] = true
	if not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
		blocked[MOONPETAL_ORIGIN + Vector2i(24, 14)] = true
	if not CampaignState.story_flags.get(&"moonpetal_bell_walk_open", false):
		blocked[MOONPETAL_COURT_TO_BELL_WALK] = true
	if not CampaignState.story_flags.get(&"moonpetal_palace_open", false):
		blocked[MOONPETAL_GARDEN_TO_PALACE] = true
	blocked.erase(MOONPETAL_EXIT)

	# Empyreal's floating terraces use full eight-by-four marble floors, with the
	# two visible gravity routes retained as connections between the lower and
	# upper terraces. Offerings, crystals, and the orrery keep their base-cell
	# collision instead of becoming invisible pass-through scenery.
	for y in range(EMPYREAL_SIZE.y):
		for x in range(EMPYREAL_SIZE.x):
			blocked[EMPYREAL_ORIGIN + Vector2i(x, y)] = true
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(0, 4), Vector2i(8, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(10, 4), Vector2i(8, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(20, 4), Vector2i(8, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(10, 14), Vector2i(8, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(20, 14), Vector2i(8, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(13, 11), Vector2i(2, 4))
	_open_rect(blocked, EMPYREAL_ORIGIN + Vector2i(23, 11), Vector2i(2, 4))
	# Low offerings, the Aerie anchor crystal, and the Tribunal orrery occupy the
	# terrace surface and therefore need base-cell collision.
	blocked[EMPYREAL_ORIGIN + Vector2i(12, 4)] = true
	blocked[EMPYREAL_ORIGIN + Vector2i(15, 4)] = true
	blocked[EMPYREAL_ORIGIN + Vector2i(14, 15)] = true
	blocked[EMPYREAL_ORIGIN + Vector2i(21, 14)] = true
	blocked[EMPYREAL_ORIGIN + Vector2i(22, 14)] = true
	if not CampaignState.story_flags.get(&"empyreal_aerie_open", false):
		blocked[EMPYREAL_GARDEN_TO_AERIE] = true
	if not CampaignState.story_flags.get(&"empyreal_tribunal_open", false):
		blocked[EMPYREAL_FORUM_TO_TRIBUNAL] = true
	if not CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
		blocked[EMPYREAL_ORIGIN + Vector2i(24, 13)] = true
	blocked.erase(EMPYREAL_EXIT)
	return blocked


func _open_rect(blocked: Dictionary, origin: Vector2i, size: Vector2i) -> void:
	for y in range(size.y):
		for x in range(size.x):
			blocked.erase(origin + Vector2i(x, y))


func _block_rect(blocked: Dictionary, origin: Vector2i, size: Vector2i) -> void:
	for y in range(size.y):
		for x in range(size.x):
			blocked[origin + Vector2i(x, y)] = true


func _spawn_mansion_clues(world: Node2D) -> void:
	var bookcase := MANSION_CLUE.instantiate() as MansionClueInteraction
	bookcase.name = "HauntedBookcase"
	bookcase.clue_kind = &"bookcase"
	bookcase.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + Vector2i(2, 3))
	world.add_child(bookcase)
	var clock := MANSION_CLUE.instantiate() as MansionClueInteraction
	clock.name = "StoppedClock"
	clock.clue_kind = &"clock"
	clock.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + Vector2i(5, 3))
	world.add_child(clock)


func _spawn_mansion_chapter_interactions(world: Node2D) -> void:
	_add_mansion_interaction(world, "GalleryPortrait", &"gallery_portrait", Vector2i(4, 13))
	_add_mansion_interaction(world, "GalleryCache", &"gallery_cache", Vector2i(1, 13))
	_add_mansion_interaction(world, "NurseryMusicBox", &"nursery_music_box", Vector2i(16, 13))
	_add_mansion_interaction(world, "NurseryCache", &"nursery_cache", Vector2i(11, 13))
	_add_mansion_interaction(world, "BallroomGate", &"ballroom_gate", Vector2i(16, 14))


func _add_mansion_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = MANSION_CHAPTER_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_mansion_save_point(world: Node2D) -> void:
	var archive_anchor := MANSION_SAVE_POINT.instantiate() as MansionSavePoint
	archive_anchor.name = "ArchiveAnchorClock"
	archive_anchor.save_point_id = &"mansion_archive"
	archive_anchor.anchor_name = "archive clock"
	archive_anchor.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + Vector2i(12, 3))
	world.add_child(archive_anchor)
	# The nursery's quiet antechamber is deliberately placed after the clue
	# encounter and before the ballroom gate. It gives a player one low-pressure
	# recovery, save, and party-management point before the 4:44 appointment.
	var ballroom_respite := MANSION_SAVE_POINT.instantiate() as MansionSavePoint
	ballroom_respite.name = "NurseryRespiteClock"
	ballroom_respite.save_point_id = &"mansion_ballroom_antechamber"
	ballroom_respite.anchor_name = "nursery respite clock"
	ballroom_respite.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + Vector2i(13, 17))
	world.add_child(ballroom_respite)


func _spawn_mansion_boss_marker(world: Node2D) -> void:
	_mansion_boss_marker = Sprite2D.new()
	_mansion_boss_marker.name = "The444Appointment"
	_mansion_boss_marker.texture = _profiled_texture(&"clock_mirror_battle_actor")
	_mansion_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Stand the marker on the open floor rather than over the rear-wall furniture.
	_mansion_boss_marker.position = Gameboard.cell_to_pixel(MANSION_ORIGIN + Vector2i(24, 9))
	_mansion_boss_marker.scale = Vector2(0.32, 0.32)
	_mansion_boss_marker.visible = not CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false)
	world.add_child(_mansion_boss_marker)


func _spawn_asterion_interactions(world: Node2D) -> void:
	_add_asterion_interaction(world, "AsterionCargoCache", &"cargo_cache", Vector2i(12, 3))
	_add_asterion_interaction(world, "AsterionBiocircuit", &"medical_biocircuit", Vector2i(12, 13))
	_add_asterion_interaction(world, "AsterionSaveBeacon", &"save_beacon", Vector2i(16, 13))
	_add_asterion_interaction(world, "AsterionHydroConsole", &"hydroponics_console", Vector2i(26, 3))
	_add_asterion_interaction(world, "AsterionControlGate", &"control_gate", Vector2i(24, 13))


func _add_asterion_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = ASTERION_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(STATION_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_astronaut() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableAstronaut") or not CampaignState.story_flags.get(&"asterion_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"astronaut", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var astronaut := ASTRONAUT_GAMEPIECE.instantiate() as Gamepiece
	astronaut.name = "RecruitableAstronaut"
	astronaut.position = Gameboard.cell_to_pixel(STATION_ORIGIN + Vector2i(2, 5))
	world.add_child(astronaut)


func _spawn_caveman() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableCaveman") or not CampaignState.story_flags.get(&"primeval_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"caveman", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var caveman := CAVEMAN_GAMEPIECE.instantiate() as Gamepiece
	caveman.name = "RecruitableCaveman"
	caveman.position = Gameboard.cell_to_pixel(PRIMEVAL_ORIGIN + Vector2i(12, 5))
	world.add_child(caveman)


func _spawn_neon_viper() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableNeonViper") or not CampaignState.story_flags.get(&"helios_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"neon_viper", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var viper := NEON_VIPER_GAMEPIECE.instantiate() as Gamepiece
	viper.name = "RecruitableNeonViper"
	viper.position = Gameboard.cell_to_pixel(HELIOS_ORIGIN + Vector2i(12, 5))
	world.add_child(viper)


func _spawn_frost_lich() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableFrostLich") or not CampaignState.story_flags.get(&"frosthold_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"frost_lich_emperor", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var lich := FROST_LICH_GAMEPIECE.instantiate() as Gamepiece
	lich.name = "RecruitableFrostLich"
	lich.position = Gameboard.cell_to_pixel(FROSTHOLD_ORIGIN + Vector2i(12, 5))
	world.add_child(lich)


func _spawn_kitsune() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableKitsune") or not CampaignState.story_flags.get(&"moonpetal_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"kitsune_empress", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var kitsune := KITSUNE_GAMEPIECE.instantiate() as Gamepiece
	kitsune.name = "RecruitableKitsune"
	kitsune.position = Gameboard.cell_to_pixel(MOONPETAL_ORIGIN + Vector2i(12, 5))
	world.add_child(kitsune)


func _spawn_crimson_oni() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world:
		return
	if not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false) or int(CampaignState.inventory.get(&"crimson_challenge_seal", 0)) <= 0:
		return
	var status: StringName = CampaignState.recruit_status.get(&"crimson_oni", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var spawn_cell := MOONPETAL_ORIGIN + Vector2i(14, 13)
	# After the trial, the Oni crosses into Ben's safe universe as a prospective
	# resident and waits beside the town-side Tea House instead of remaining an
	# unexplained combatant in Moonpetal.
	if CampaignState.story_flags.get(&"crimson_oni_trial_complete", false):
		for plot_index in CampaignState.built_facilities.keys():
			if String(CampaignState.built_facilities[plot_index]) != "Tea House":
				continue
			var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
			spawn_cell = TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2 - 1, plot.end.y)
			break
	var existing := world.get_node_or_null("RecruitableCrimsonOni") as Gamepiece
	if existing:
		existing.position = Gameboard.cell_to_pixel(spawn_cell)
		existing.rest_position = existing.position
		return
	var oni := CRIMSON_ONI_GAMEPIECE.instantiate() as Gamepiece
	oni.name = "RecruitableCrimsonOni"
	oni.position = Gameboard.cell_to_pixel(spawn_cell)
	var interaction = oni.get_node_or_null("RecruitInteraction")
	if interaction:
		interaction.battle = _battle
	world.add_child(oni)


func _spawn_rift_jackal() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or not CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"rift_jackal", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var spawn_cell := MANSION_ORIGIN + Vector2i(23, 11)
	# Once the trial is won, the monster becomes a peaceful town resident and
	# waits beside the Library, whose catalog is the closest thing Ben has to a
	# multiversal scent archive.
	if CampaignState.story_flags.get(&"rift_jackal_trial_complete", false):
		spawn_cell = TOWN_ARRIVAL + Vector2i(4, 2)
		for plot_index in CampaignState.built_facilities.keys():
			if String(CampaignState.built_facilities[plot_index]) != "Library":
				continue
			var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
			spawn_cell = TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2 - 1, plot.end.y)
			break
	var existing := world.get_node_or_null("RecruitableRiftJackal") as Gamepiece
	if existing:
		existing.position = Gameboard.cell_to_pixel(spawn_cell)
		existing.rest_position = existing.position
		return
	var jackal := RIFT_JACKAL_GAMEPIECE.instantiate() as Gamepiece
	jackal.name = "RecruitableRiftJackal"
	jackal.position = Gameboard.cell_to_pixel(spawn_cell)
	var interaction = jackal.get_node_or_null("RecruitInteraction")
	if interaction:
		interaction.battle = _battle
	world.add_child(jackal)


func _spawn_mossback_surveyor() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or not CampaignState.story_flags.get(&"primeval_scenario_complete", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"mossback_surveyor", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var spawn_cell := PRIMEVAL_ORIGIN + Vector2i(22, 15)
	# Passing the audit turns the monster into a resident. It waits near the
	# Trailhead Lodge, where its farming and supply expertise has practical use.
	if CampaignState.story_flags.get(&"mossback_surveyor_trial_complete", false):
		spawn_cell = TOWN_ARRIVAL + Vector2i(-4, 3)
		for plot_index in CampaignState.built_facilities.keys():
			if String(CampaignState.built_facilities[plot_index]) != "Trailhead Lodge":
				continue
			var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
			spawn_cell = TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2 + 1, plot.end.y)
			break
	var existing := world.get_node_or_null("RecruitableMossbackSurveyor") as Gamepiece
	if existing:
		existing.position = Gameboard.cell_to_pixel(spawn_cell)
		existing.rest_position = existing.position
		return
	var surveyor := MOSSBACK_SURVEYOR_GAMEPIECE.instantiate() as Gamepiece
	surveyor.name = "RecruitableMossbackSurveyor"
	surveyor.position = Gameboard.cell_to_pixel(spawn_cell)
	var interaction = surveyor.get_node_or_null("RecruitInteraction")
	if interaction:
		interaction.battle = _battle
	world.add_child(surveyor)


func _spawn_cobalt_courier() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or not CampaignState.story_flags.get(&"helios_scenario_complete", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"cobalt_courier", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var spawn_cell := HELIOS_ORIGIN + Vector2i(22, 5)
	# Once its combat-verification clause is satisfied, the Courier starts a
	# town delivery route beside the Afterlight Club.
	if CampaignState.story_flags.get(&"cobalt_courier_trial_complete", false):
		spawn_cell = TOWN_ARRIVAL + Vector2i(5, 3)
		for plot_index in CampaignState.built_facilities.keys():
			if String(CampaignState.built_facilities[plot_index]) != "Afterlight Club":
				continue
			var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
			spawn_cell = TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2 + 1, plot.end.y)
			break
	var existing := world.get_node_or_null("RecruitableCobaltCourier") as Gamepiece
	if existing:
		existing.position = Gameboard.cell_to_pixel(spawn_cell)
		existing.rest_position = existing.position
		return
	var courier := COBALT_COURIER_GAMEPIECE.instantiate() as Gamepiece
	courier.name = "RecruitableCobaltCourier"
	courier.position = Gameboard.cell_to_pixel(spawn_cell)
	var interaction = courier.get_node_or_null("RecruitInteraction")
	if interaction:
		interaction.battle = _battle
	world.add_child(courier)


func _spawn_bulkhead_warden() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or not CampaignState.story_flags.get(&"asterion_station_complete", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"bulkhead_warden", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var spawn_cell := STATION_ORIGIN + Vector2i(22, 15)
	# After the structural interview, the Warden relocates peacefully to the
	# Armory. It remains a normal recruit interaction, never a town threat.
	if CampaignState.story_flags.get(&"bulkhead_warden_trial_complete", false):
		spawn_cell = TOWN_ARRIVAL + Vector2i(5, 2)
		for plot_index in CampaignState.built_facilities.keys():
			if String(CampaignState.built_facilities[plot_index]) != "Armory":
				continue
			var plot: Rect2i = FACILITY_PLOTS[int(plot_index)]
			spawn_cell = TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2 + 1, plot.end.y)
			break
	var existing := world.get_node_or_null("RecruitableBulkheadWarden") as Gamepiece
	if existing:
		existing.position = Gameboard.cell_to_pixel(spawn_cell)
		existing.rest_position = existing.position
		return
	var warden := BULKHEAD_WARDEN_GAMEPIECE.instantiate() as Gamepiece
	warden.name = "RecruitableBulkheadWarden"
	warden.position = Gameboard.cell_to_pixel(spawn_cell)
	var interaction = warden.get_node_or_null("RecruitInteraction")
	if interaction:
		interaction.battle = _battle
	world.add_child(warden)


func _spawn_archangel() -> void:
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("RecruitableArchangel") or not CampaignState.story_flags.get(&"empyreal_anchor_built", false):
		return
	var status: StringName = CampaignState.recruit_status.get(&"archangel_commander", &"undiscovered")
	if status not in [&"undiscovered", &"available"]:
		return
	var archangel := ARCHANGEL_GAMEPIECE.instantiate() as Gamepiece
	archangel.name = "RecruitableArchangel"
	archangel.position = Gameboard.cell_to_pixel(EMPYREAL_ORIGIN + Vector2i(12, 5))
	world.add_child(archangel)


func _spawn_asterion_boss_marker(world: Node2D) -> void:
	_station_boss_marker = Sprite2D.new()
	_station_boss_marker.name = "AsterionMotherComputer"
	_station_boss_marker.texture = _profiled_texture(&"mother_computer_battle_actor")
	_station_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_station_boss_marker.position = Gameboard.cell_to_pixel(STATION_ORIGIN + Vector2i(24, 13)) + Vector2(0, 18)
	_station_boss_marker.scale = Vector2(0.24, 0.24)
	_station_boss_marker.visible = CampaignState.story_flags.get(&"asterion_anchor_built", false) and not CampaignState.story_flags.get(&"asterion_station_complete", false)
	world.add_child(_station_boss_marker)


func _spawn_primeval_interactions(world: Node2D) -> void:
	_add_primeval_interaction(world, "PrimevalTrafficTotem", &"traffic_totem", Vector2i(3, 3))
	_add_primeval_interaction(world, "PrimevalCaveTerminal", &"cave_terminal", Vector2i(24, 3))
	_add_primeval_interaction(world, "PrimevalAnchorTotem", &"anchor_totem", Vector2i(12, 13))
	_add_primeval_interaction(world, "PrimevalRelayNest", &"relay_nest", Vector2i(16, 13))


func _add_primeval_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = PRIMEVAL_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(PRIMEVAL_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_primeval_boss_marker(world: Node2D) -> void:
	_primeval_boss_marker = Sprite2D.new()
	_primeval_boss_marker.name = "TyrantOfTheMorningCommute"
	_primeval_boss_marker.texture = _profiled_texture(&"commute_tyrant_battle_actor")
	_primeval_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_primeval_boss_marker.position = Gameboard.cell_to_pixel(PRIMEVAL_ORIGIN + Vector2i(24, 13)) + Vector2(0, 18)
	_primeval_boss_marker.scale = Vector2(0.28, 0.28)
	_primeval_boss_marker.visible = CampaignState.story_flags.get(&"primeval_caldera_open", false) and not CampaignState.story_flags.get(&"primeval_scenario_complete", false)
	world.add_child(_primeval_boss_marker)


func _spawn_helios_interactions(world: Node2D) -> void:
	_add_helios_interaction(world, "HeliosOrdinanceTerminal", &"ordinance_terminal", Vector2i(16, 3))
	_add_helios_interaction(world, "HeliosTransitNode", &"transit_node", Vector2i(24, 3))
	# The supplied clinic quadrant has a complete circular beacon at this cell.
	_add_helios_interaction(world, "HeliosSaveBeacon", &"save_beacon", Vector2i(14, 13))
	_add_helios_interaction(world, "HeliosClinicNode", &"clinic_node", Vector2i(16, 13))


func _add_helios_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = HELIOS_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(HELIOS_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_helios_boss_marker(world: Node2D) -> void:
	_helios_boss_marker = Sprite2D.new()
	_helios_boss_marker.name = "CivicSun"
	_helios_boss_marker.texture = _profiled_texture(&"civic_sun_battle_actor")
	_helios_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_helios_boss_marker.position = Gameboard.cell_to_pixel(HELIOS_ORIGIN + Vector2i(24, 13)) + Vector2(0, 18)
	_helios_boss_marker.scale = Vector2(0.24, 0.24)
	_helios_boss_marker.visible = CampaignState.story_flags.get(&"helios_core_open", false) and not CampaignState.story_flags.get(&"helios_scenario_complete", false)
	world.add_child(_helios_boss_marker)


func _spawn_frosthold_interactions(world: Node2D) -> void:
	_add_frosthold_interaction(world, "FrostholdHeatTaxRune", &"heat_tax_rune", Vector2i(22, 3))
	_add_frosthold_interaction(world, "FrostholdCausewaySeal", &"causeway_seal", Vector2i(26, 3))
	# Interact at the base of the left blue brazier, not in the middle of its flame.
	_add_frosthold_interaction(world, "FrostholdSaveBrazier", &"save_brazier", Vector2i(12, 15))
	_add_frosthold_interaction(world, "FrostholdThroneSeal", &"throne_seal", Vector2i(16, 13))


func _add_frosthold_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = FROSTHOLD_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(FROSTHOLD_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_frosthold_boss_marker(world: Node2D) -> void:
	_frosthold_boss_marker = Sprite2D.new()
	_frosthold_boss_marker.name = "WhiteoutAuditor"
	_frosthold_boss_marker.texture = _profiled_texture(&"whiteout_auditor_battle_actor")
	_frosthold_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# The field marker should read as the three-headed boss, not a tiny pile of
	# pixels. The throne-room braziers are spaced to frame this silhouette.
	_frosthold_boss_marker.position = Gameboard.cell_to_pixel(FROSTHOLD_ORIGIN + Vector2i(24, 13)) + Vector2(-24, 4)
	_frosthold_boss_marker.scale = Vector2(0.34, 0.34)
	_frosthold_boss_marker.visible = CampaignState.story_flags.get(&"frosthold_throne_open", false) and not CampaignState.story_flags.get(&"frosthold_scenario_complete", false)
	world.add_child(_frosthold_boss_marker)


func _spawn_moonpetal_interactions(world: Node2D) -> void:
	_add_moonpetal_interaction(world, "MoonpetalVowTablet", &"vow_tablet", Vector2i(22, 3))
	_add_moonpetal_interaction(world, "MoonpetalGardenSeal", &"garden_seal", Vector2i(26, 3))
	# Ground the hotspot at the supplied lantern's base.
	_add_moonpetal_interaction(world, "MoonpetalSaveLantern", &"save_lantern", Vector2i(11, 15))
	_add_moonpetal_interaction(world, "MoonpetalPalaceSeal", &"palace_seal", Vector2i(16, 13))


func _add_moonpetal_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = MOONPETAL_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(MOONPETAL_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_moonpetal_boss_marker(world: Node2D) -> void:
	_moonpetal_boss_marker = Sprite2D.new()
	_moonpetal_boss_marker.name = "MagistrateEnma"
	_moonpetal_boss_marker.texture = _profiled_texture(&"magistrate_enma_battle_actor")
	_moonpetal_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Present Enma at a readable boss scale on the processional lane, fully below
	# the palace threshold and above the player's arrival tile.
	_moonpetal_boss_marker.position = Gameboard.cell_to_pixel(MOONPETAL_ORIGIN + Vector2i(24, 14)) + Vector2(0, 16)
	_moonpetal_boss_marker.scale = Vector2(0.32, 0.32)
	_moonpetal_boss_marker.visible = CampaignState.story_flags.get(&"moonpetal_palace_open", false) and not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false)
	world.add_child(_moonpetal_boss_marker)


func _spawn_empyreal_interactions(world: Node2D) -> void:
	_add_empyreal_interaction(world, "EmpyrealGravityOrdinance", &"gravity_ordinance", Vector2i(22, 3))
	_add_empyreal_interaction(world, "EmpyrealAerieSeal", &"aerie_seal", Vector2i(16, 3))
	# The Aerie's complete gravity crystal is its local anchor; the garden fountain
	# is in a different room and must not own an invisible remote interaction.
	_add_empyreal_interaction(world, "EmpyrealSaveFountain", &"save_fountain", Vector2i(14, 15))
	_add_empyreal_interaction(world, "EmpyrealTribunalSeal", &"tribunal_seal", Vector2i(16, 13))


func _add_empyreal_interaction(world: Node2D, node_name: String, kind: StringName, local_cell: Vector2i) -> void:
	var interaction = EMPYREAL_INTERACTION.instantiate()
	interaction.name = node_name
	interaction.interaction_kind = kind
	interaction.position = Gameboard.cell_to_pixel(EMPYREAL_ORIGIN + local_cell)
	world.add_child(interaction)


func _spawn_universe_treasure_caches(world: Node2D) -> void:
	# Each hotspot is grounded on a complete prop already authored into that
	# universe: rune plinth, market terminal, brazier, offering, and fountain.
	_add_universe_treasure(world, "PrimevalRuinsTreasure", &"primeval_ruins_plinth", &"primeval_ruins", PRIMEVAL_ORIGIN + Vector2i(26, 3))
	_add_universe_treasure(world, "HeliosMarketTreasure", &"helios_market_terminal", &"helios_market", HELIOS_ORIGIN + Vector2i(17, 6))
	_add_universe_treasure(world, "FrostholdMarketTreasure", &"frosthold_heat_cache", &"frosthold_market", FROSTHOLD_ORIGIN + Vector2i(14, 4))
	_add_universe_treasure(world, "MoonpetalGardenTreasure", &"moonpetal_offering", &"moonpetal_garden", MOONPETAL_ORIGIN + Vector2i(21, 3))
	_add_universe_treasure(world, "EmpyrealGardenTreasure", &"empyreal_tithe_basin", &"empyreal_garden", EMPYREAL_ORIGIN + Vector2i(14, 3))


func _add_universe_treasure(world: Node2D, node_name: String, cache_id: StringName, area_id: StringName, cell: Vector2i) -> void:
	var interaction := UNIVERSE_TREASURE_INTERACTION.instantiate() as UniverseTreasureInteraction
	interaction.name = node_name
	interaction.cache_id = cache_id
	interaction.area_id = area_id
	interaction.position = Gameboard.cell_to_pixel(cell)
	world.add_child(interaction)
	interaction.add_to_group(&"universe_treasure_cache")


func _spawn_empyreal_boss_marker(world: Node2D) -> void:
	_empyreal_boss_marker = Sprite2D.new()
	_empyreal_boss_marker.name = "HighComptrollerOfGravity"
	_empyreal_boss_marker.texture = _profiled_texture(&"high_comptroller_battle_actor")
	_empyreal_boss_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_empyreal_boss_marker.position = Gameboard.cell_to_pixel(EMPYREAL_ORIGIN + Vector2i(24, 13)) + Vector2(0, 18)
	_empyreal_boss_marker.scale = Vector2(0.25, 0.25)
	_empyreal_boss_marker.visible = false
	world.add_child(_empyreal_boss_marker)


func _on_campaign_state_changed() -> void:
	_update_mansion_passage()
	_update_mansion_ballroom_gate()
	_update_asterion_control_gate()
	_update_primeval_nest_gate()
	_update_primeval_caldera_gate()
	_update_primeval_canopy_shortcut()
	_update_helios_clinic_gate()
	_update_helios_core_gate()
	_update_frosthold_rune_hall_gate()
	_update_frosthold_throne_gate()
	_update_moonpetal_bell_walk_gate()
	_update_moonpetal_palace_gate()
	_update_empyreal_aerie_gate()
	_update_empyreal_tribunal_gate()
	if _visual:
		_visual.queue_redraw()
	_sync_sandbox_authored_entities()
	_spawn_crimson_oni()
	_spawn_rift_jackal()
	_spawn_mossback_surveyor()
	_spawn_cobalt_courier()
	_spawn_bulkhead_warden()
	_sync_boss_marker_visibility(_camera_area)
	_queue_campaign_ending_if_needed()


func _sync_boss_marker_visibility(area: String) -> void:
	# Boss sprites are world nodes rather than part of CampaignMapVisual. Without
	# area gating they bled through the camera into adjacent isolated stages (the
	# 4:44 mirror appeared in the Archive, for example), making a coherent room
	# look like a pile of unrelated props.
	if _mansion_boss_marker:
		_mansion_boss_marker.visible = area == "mansion_ballroom" and not CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false)
	if _station_boss_marker:
		_station_boss_marker.visible = area == "station_control" and CampaignState.story_flags.get(&"asterion_anchor_built", false) and not CampaignState.story_flags.get(&"asterion_station_complete", false)
	if _primeval_boss_marker:
		_primeval_boss_marker.visible = area == "primeval_caldera" and CampaignState.story_flags.get(&"primeval_caldera_open", false) and not CampaignState.story_flags.get(&"primeval_scenario_complete", false)
	if _helios_boss_marker:
		_helios_boss_marker.visible = area == "helios_core" and CampaignState.story_flags.get(&"helios_core_open", false) and not CampaignState.story_flags.get(&"helios_scenario_complete", false)
	if _frosthold_boss_marker:
		_frosthold_boss_marker.visible = area == "frosthold_throne" and CampaignState.story_flags.get(&"frosthold_throne_open", false) and not CampaignState.story_flags.get(&"frosthold_scenario_complete", false)
	if _moonpetal_boss_marker:
		_moonpetal_boss_marker.visible = area == "moonpetal_palace" and CampaignState.story_flags.get(&"moonpetal_palace_open", false) and not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false)
	if _empyreal_boss_marker:
		_empyreal_boss_marker.visible = area == "empyreal_tribunal" and CampaignState.story_flags.get(&"empyreal_tribunal_open", false) and not CampaignState.story_flags.get(&"empyreal_scenario_complete", false)
	# Treasure markers are also world nodes. Gate them to their authored room so
	# adjacent stages cannot show a chest floating in the surrounding void.
	for cache in get_tree().get_nodes_in_group(&"universe_treasure_cache"):
		if cache is UniverseTreasureInteraction:
			cache.visible = String(cache.area_id) == area


func _update_primeval_nest_gate() -> void:
	_update_primeval_gate(
		PRIMEVAL_VILLAGE_TO_NEST,
		&"primeval_terminal_decoded",
		"PrimevalVillageToNest",
		PRIMEVAL_NEST_FROM_VILLAGE,
		"PrimevalNestToVillage",
		PRIMEVAL_NEST_RETURN,
		PRIMEVAL_VILLAGE_FROM_NEST
	)


func _update_primeval_caldera_gate() -> void:
	_update_primeval_gate(
		PRIMEVAL_RUINS_TO_CALDERA,
		&"primeval_caldera_open",
		"PrimevalRuinsToCaldera",
		PRIMEVAL_CALDERA_FROM_RUINS,
		"PrimevalCalderaToRuins",
		PRIMEVAL_CALDERA_RETURN,
		PRIMEVAL_RUINS_FROM_CALDERA
	)


func _update_primeval_canopy_shortcut() -> void:
	if not CampaignState.story_flags.get(&"primeval_terminal_decoded", false):
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("PrimevalGroveCanopyShortcut") or not CampaignState.story_flags.get(&"primeval_anchor_built", false):
		return
	world.add_child(_create_transition("PrimevalGroveCanopyShortcut", PRIMEVAL_GROVE_CANOPY_SHORTCUT, PRIMEVAL_NEST_CANOPY_SHORTCUT))
	world.add_child(_create_transition("PrimevalNestCanopyShortcut", PRIMEVAL_NEST_CANOPY_SHORTCUT, PRIMEVAL_GROVE_CANOPY_SHORTCUT))


func _update_primeval_gate(cell: Vector2i, flag: StringName, forward_name: String, forward_arrival: Vector2i, return_name: String, return_cell: Vector2i, return_arrival: Vector2i) -> void:
	if not _navigation:
		return
	var is_open := bool(CampaignState.story_flags.get(flag, false))
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	_navigation.set_cell(cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node(forward_name) or not CampaignState.story_flags.get(&"primeval_anchor_built", false):
		return
	world.add_child(_create_transition(forward_name, cell, forward_arrival))
	world.add_child(_create_transition(return_name, return_cell, return_arrival))


func _update_helios_clinic_gate() -> void:
	var is_open := &"night_phase_inverter" in CampaignState.owned_inventions
	_update_helios_gate(
		HELIOS_MARKET_TO_CLINIC, is_open,
		"HeliosMarketToClinic", HELIOS_CLINIC_FROM_MARKET,
		"HeliosClinicToMarket", HELIOS_CLINIC_RETURN, HELIOS_MARKET_FROM_CLINIC
	)


func _update_helios_core_gate() -> void:
	_update_helios_gate(
		HELIOS_TRANSIT_TO_CORE, bool(CampaignState.story_flags.get(&"helios_core_open", false)),
		"HeliosTransitToCore", HELIOS_CORE_FROM_TRANSIT,
		"HeliosCoreToTransit", HELIOS_CORE_RETURN, HELIOS_TRANSIT_FROM_CORE
	)


func _update_helios_gate(cell: Vector2i, is_open: bool, forward_name: String, forward_arrival: Vector2i, return_name: String, return_cell: Vector2i, return_arrival: Vector2i) -> void:
	if not _navigation:
		return
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	_navigation.set_cell(cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node(forward_name) or not CampaignState.story_flags.get(&"helios_anchor_built", false):
		return
	world.add_child(_create_transition(forward_name, cell, forward_arrival))
	world.add_child(_create_transition(return_name, return_cell, return_arrival))


func _update_frosthold_rune_hall_gate() -> void:
	_update_frosthold_gate(
		FROSTHOLD_MARKET_TO_RUNE_HALL,
		bool(CampaignState.story_flags.get(&"frosthold_causeway_seal_open", false)),
		"FrostholdMarketToRuneHall", FROSTHOLD_RUNE_HALL_FROM_MARKET,
		"FrostholdRuneHallToMarket", FROSTHOLD_RUNE_HALL_RETURN, FROSTHOLD_MARKET_FROM_RUNE_HALL
	)


func _update_frosthold_throne_gate() -> void:
	_update_frosthold_gate(
		FROSTHOLD_CAUSEWAY_TO_THRONE,
		bool(CampaignState.story_flags.get(&"frosthold_throne_open", false)),
		"FrostholdCausewayToThrone", FROSTHOLD_THRONE_FROM_CAUSEWAY,
		"FrostholdThroneToCauseway", FROSTHOLD_THRONE_RETURN, FROSTHOLD_CAUSEWAY_FROM_THRONE
	)


func _update_frosthold_gate(cell: Vector2i, is_open: bool, forward_name: String, forward_arrival: Vector2i, return_name: String, return_cell: Vector2i, return_arrival: Vector2i) -> void:
	if not _navigation:
		return
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	_navigation.set_cell(cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node(forward_name) or not CampaignState.story_flags.get(&"frosthold_anchor_built", false):
		return
	world.add_child(_create_transition(forward_name, cell, forward_arrival))
	world.add_child(_create_transition(return_name, return_cell, return_arrival))


func _update_moonpetal_bell_walk_gate() -> void:
	_update_moonpetal_gate(
		MOONPETAL_COURT_TO_BELL_WALK,
		bool(CampaignState.story_flags.get(&"moonpetal_bell_walk_open", false)),
		"MoonpetalCourtToBellWalk", MOONPETAL_BELL_WALK_FROM_COURT,
		"MoonpetalBellWalkToCourt", MOONPETAL_BELL_WALK_RETURN, MOONPETAL_COURT_FROM_BELL_WALK
	)


func _update_moonpetal_palace_gate() -> void:
	_update_moonpetal_gate(
		MOONPETAL_GARDEN_TO_PALACE,
		bool(CampaignState.story_flags.get(&"moonpetal_palace_open", false)),
		"MoonpetalGardenToPalace", MOONPETAL_PALACE_FROM_GARDEN,
		"MoonpetalPalaceToGarden", MOONPETAL_PALACE_RETURN, MOONPETAL_GARDEN_FROM_PALACE
	)


func _update_moonpetal_gate(cell: Vector2i, is_open: bool, forward_name: String, forward_arrival: Vector2i, return_name: String, return_cell: Vector2i, return_arrival: Vector2i) -> void:
	if not _navigation:
		return
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	_navigation.set_cell(cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node(forward_name) or not CampaignState.story_flags.get(&"moonpetal_anchor_built", false):
		return
	world.add_child(_create_transition(forward_name, cell, forward_arrival))
	world.add_child(_create_transition(return_name, return_cell, return_arrival))


func _update_empyreal_aerie_gate() -> void:
	_update_empyreal_gate(
		EMPYREAL_GARDEN_TO_AERIE,
		bool(CampaignState.story_flags.get(&"empyreal_aerie_open", false)),
		"EmpyrealGardenToAerie", EMPYREAL_AERIE_FROM_GARDEN,
		"EmpyrealAerieToGarden", EMPYREAL_AERIE_RETURN, EMPYREAL_GARDEN_FROM_AERIE
	)


func _update_empyreal_tribunal_gate() -> void:
	_update_empyreal_gate(
		EMPYREAL_FORUM_TO_TRIBUNAL,
		bool(CampaignState.story_flags.get(&"empyreal_tribunal_open", false)),
		"EmpyrealForumToTribunal", EMPYREAL_TRIBUNAL_FROM_FORUM,
		"EmpyrealTribunalToForum", EMPYREAL_TRIBUNAL_RETURN, EMPYREAL_FORUM_FROM_TRIBUNAL
	)


func _update_empyreal_gate(cell: Vector2i, is_open: bool, forward_name: String, forward_arrival: Vector2i, return_name: String, return_cell: Vector2i, return_arrival: Vector2i) -> void:
	if not _navigation:
		return
	_navigation.set_cell(cell, 0, Vector2i(2, 2) if is_open else Vector2i(1, 4), 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node(forward_name) or not CampaignState.story_flags.get(&"empyreal_anchor_built", false):
		return
	world.add_child(_create_transition(forward_name, cell, forward_arrival))
	world.add_child(_create_transition(return_name, return_cell, return_arrival))


func _update_asterion_control_gate() -> void:
	if not _navigation:
		return
	var is_open := bool(CampaignState.story_flags.get(&"asterion_station_restored", false))
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	_navigation.set_cell(STATION_HYDRO_TO_CONTROL, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(STATION_HYDRO_TO_CONTROL)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("StationHydroToControl") or not CampaignState.story_flags.get(&"asterion_anchor_built", false):
		return
	world.add_child(_create_transition("StationHydroToControl", STATION_HYDRO_TO_CONTROL, STATION_CONTROL_FROM_HYDRO))
	world.add_child(_create_transition("StationControlToHydro", STATION_CONTROL_RETURN, STATION_HYDRO_FROM_CONTROL))
	# The restored maintenance lift is a regular service route rather than an
	# invisible return trigger: both endpoints sit on painted, expanded floors.
	world.add_child(_create_transition("StationDockServiceShortcut", STATION_DOCK_SERVICE_SHORTCUT, STATION_MEDICAL_SERVICE_SHORTCUT))
	world.add_child(_create_transition("StationMedicalServiceShortcut", STATION_MEDICAL_SERVICE_SHORTCUT, STATION_DOCK_SERVICE_SHORTCUT))


func _update_mansion_passage() -> void:
	if not _navigation:
		return
	var is_open: bool = bool(CampaignState.story_flags.get(&"mansion_first_room_complete", false))
	var atlas_cell: Vector2i = Vector2i(2, 2) if is_open else Vector2i(1, 4)
	var gate_cell := MANSION_LEGACY_ADAPTER.passage_gate_cell()
	_navigation.set_cell(gate_cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(gate_cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("MansionServantsPassage"):
		return
	_add_mansion_transitions(world, MANSION_LEGACY_ADAPTER.passage_transition_definitions())


func _update_mansion_ballroom_gate() -> void:
	if not _navigation:
		return
	var is_open := bool(CampaignState.story_flags.get(&"mansion_ballroom_open", false))
	var atlas_cell := Vector2i(2, 2) if is_open else Vector2i(1, 4)
	var gate_cell := MANSION_LEGACY_ADAPTER.ballroom_gate_cell()
	_navigation.set_cell(gate_cell, 0, atlas_cell, 0)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	(cleared if is_open else blocked).append(gate_cell)
	_navigation.cells_changed.emit(cleared, blocked)
	if not is_open:
		return
	var world := get_node_or_null("Field/Map/CampaignWorld")
	if not world or world.has_node("MansionNurseryToBallroom"):
		return
	_add_mansion_transitions(world, MANSION_LEGACY_ADAPTER.ballroom_transition_definitions())


func _add_mansion_transitions(world: Node, definitions: Array[Dictionary]) -> void:
	for definition in definitions:
		var transition_name: String = String(definition[&"name"])
		var source_cell: Vector2i = definition[&"from"]
		var arrival_cell: Vector2i = definition[&"to"]
		world.add_child(_create_transition(transition_name, source_cell, arrival_cell))


func _add_boundaries(blocked: Dictionary, origin: Vector2i, size: Vector2i) -> void:
	for x in range(size.x):
		blocked[origin + Vector2i(x, 0)] = true
		blocked[origin + Vector2i(x, size.y - 1)] = true
	for y in range(size.y):
		blocked[origin + Vector2i(0, y)] = true
		blocked[origin + Vector2i(size.x - 1, y)] = true


func _create_transition(node_name: String, cell: Vector2i, arrival: Vector2i) -> AreaTransition:
	var transition := AREA_TRANSITION.instantiate() as AreaTransition
	transition.name = node_name
	transition.position = Gameboard.cell_to_pixel(cell)
	transition.arrival_coordinates = Gameboard.cell_to_pixel(arrival)
	return transition


func _create_restricted_transition(node_name: String, cell: Vector2i, arrival: Vector2i, denied_return: Vector2i, destination_id: StringName):
	var transition = RESTRICTED_AREA_TRANSITION.instantiate()
	transition.name = node_name
	transition.position = Gameboard.cell_to_pixel(cell)
	transition.arrival_coordinates = Gameboard.cell_to_pixel(arrival)
	transition.denied_return_coordinates = Gameboard.cell_to_pixel(denied_return)
	transition.destination_id = destination_id
	transition.required_members = CampaignState.destination_party_requirements(destination_id)
	transition.waiver_story_flag = &"haunted_mansion_scenario_complete"
	return transition
