extends Node

const PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const SANDBOX_OBJECT_CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")
const SANDBOX_TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")


func _ready() -> void:
	var registry = PROFILE_REGISTRY.new()
	for profile_id in [
		&"laboratory_exterior",
		&"town_library_facade",
		&"town_ranch_tree_small",
		&"town_ranch_tree_tall",
		&"town_clinic_facade",
		&"town_armory_facade",
		&"town_trailhead_lodge_facade",
		&"town_cold_storage_facade",
		&"town_tea_house_facade",
		&"town_grass_tile",
		&"town_road_tile", &"town_foundation_stone_tile",
		&"haunted_mansion_exterior",
		&"moonpetal_vermilion_gate",
		&"moonpetal_court_temple",
		&"moonpetal_court_tree_canopy",
		&"moonpetal_mirror_pond",
		&"moonpetal_framed_garden_island",
		&"moonpetal_gate_lantern",
		&"frosthold_gate_tree",
		&"frosthold_gate_tree_right",
		&"frosthold_gate_castle",
		&"frosthold_gate_ruin",
		&"frosthold_gate_ruin_right", &"frosthold_gate_torch_right",
		&"frosthold_blue_torch",
		&"frosthold_market_house",
		&"frosthold_market_house_right", &"frosthold_market_stall_right", &"frosthold_market_supply_stall",
		&"frosthold_market_stall",
		&"frosthold_causeway_crystal_bank",
		&"frosthold_causeway_crystal_bank_right", &"frosthold_causeway_bridge_lower",
		&"frosthold_causeway_bridge",
		&"frosthold_causeway_rune",
		&"frosthold_hall_side_arch", &"frosthold_hall_central_arch",
		&"frosthold_throne_left_column", &"frosthold_throne_right_column",
		&"frosthold_hall_torch_left", &"frosthold_hall_rune_left", &"frosthold_hall_rune_right", &"frosthold_throne_rune",
		&"frosthold_snow_ground_tile",
		&"asterion_station_architecture",
		&"asterion_station_wall_0_0", &"asterion_station_wall_1_0",
		&"asterion_station_wall_0_1", &"asterion_station_wall_1_1",
		&"asterion_station_floor_0_0", &"asterion_station_floor_1_0",
		&"asterion_station_floor_0_1", &"asterion_station_floor_1_1",
		&"asterion_mess_banner",
		&"asterion_hydroponics_bed",
		&"asterion_command_console",
		&"asterion_dock_hull",
		&"asterion_medical_station",
		&"primeval_village_dwelling",
		&"primeval_anchor_totem",
		&"primeval_grove_canopy",
		&"primeval_grove_canopy_mid_left", &"primeval_grove_canopy_mid", &"primeval_grove_canopy_right",
		&"primeval_grove_fern_left", &"primeval_grove_fern_right",
		&"primeval_ruin_forecourt",
		&"primeval_relay_nest",
		&"primeval_ground_quadrant",
		&"helios_skybridge_quadrant",
		&"helios_market_quadrant",
		&"helios_observatory_facade",
		&"afterlight_club_facade",
		&"afterlight_club_sign",
		&"belfry_building",
		&"mansion_archive_shelving",
		&"mansion_archive_cabinet",
		&"mansion_nursery_bed",
		&"mansion_foyer_battle_backdrop",
		&"battle_ui_action_description", &"battle_ui_action_button", &"battle_ui_action_button_disabled", &"battle_ui_action_button_focused", &"battle_ui_action_button_pressed", &"battle_ui_selection_arrow",
		&"battle_ui_battler_hud", &"battle_ui_energy_point", &"battle_ui_energy_fill", &"battle_ui_life_bar", &"battle_ui_life_fill",
		&"ben_company_portrait", &"fighter_company_portrait", &"astronaut_company_portrait",
		&"interaction_emote_empty", &"interaction_emote_combat", &"interaction_emote_exclamation", &"interaction_emote_question",
		&"sandbox_ranch_meadow", &"sandbox_ranch_light_grass", &"sandbox_ranch_dirt", &"sandbox_ranch_farmland", &"sandbox_ranch_snow", &"sandbox_ranch_water",
		&"sandbox_modern_grass", &"sandbox_modern_dirt", &"sandbox_modern_cobble", &"sandbox_modern_sand",
		&"sandbox_haunted_planks", &"sandbox_haunted_stone",
		&"sandbox_lab_white_panel", &"sandbox_lab_blue_panel", &"sandbox_lab_green_panel", &"sandbox_lab_steel_panel",
		&"sandbox_scifi_blue_panel", &"sandbox_scifi_gray_panel", &"sandbox_scifi_steel_floor", &"sandbox_scifi_grate",
		&"sandbox_ranch_house", &"sandbox_ranch_cow", &"sandbox_ranch_cat", &"sandbox_ranch_corn", &"sandbox_ranch_pumpkin",
		&"universe_treasure_chest",
		&"mansion_gallery_battle_backdrop",
		&"asterion_dock_battle_backdrop",
		&"asterion_hydro_battle_backdrop",
		&"asterion_medical_battle_backdrop",
		&"asterion_command_battle_backdrop",
		&"moonpetal_processional_path",
		&"empyreal_sky_cloud_bank",
		&"laboratory_floor_tile",
		&"laboratory_utility_bank",
		&"laboratory_analysis_station",
		&"laboratory_exit_doors",
		&"laboratory_wall_tile", &"laboratory_ventilation_run",
		&"laboratory_west_terminal", &"laboratory_west_spectrometer",
		&"laboratory_east_fabricator", &"laboratory_east_reactor", &"laboratory_east_calibrator",
		&"laboratory_west_storage", &"laboratory_center_storage",
		&"laboratory_east_generator", &"laboratory_east_coolant",
		&"rift_jackal_battle_actor",
		&"bulkhead_warden_battle_actor",
		&"mossback_surveyor_battle_actor",
		&"cobalt_courier_battle_actor",
		&"primeval_raptor_battle_actor",
		&"stone_triceratops_battle_actor",
		&"municipal_spinosaur_battle_actor",
		&"commute_tyrant_battle_actor",
		&"schoolgirl_ghost_battle_actor",
		&"war_book_battle_actor",
		&"clock_mirror_battle_actor",
		&"composer_portrait_battle_actor",
		&"haunted_doll_battle_actor",
		&"work_robot_battle_actor", &"sentry_drone_battle_actor", &"medical_robot_battle_actor", &"machine_commander_battle_actor", &"mother_computer_battle_actor",
		&"helios_mech_battle_actor", &"helios_assassin_battle_actor", &"helios_security_battle_actor", &"helios_gunner_battle_actor", &"civic_sun_battle_actor",
		&"frost_collector_battle_actor", &"frost_necromancer_battle_actor", &"ice_colossus_battle_actor", &"whiteout_auditor_battle_actor",
		&"wind_bailiff_battle_actor", &"storm_repossessor_battle_actor", &"fallen_notary_battle_actor", &"gravity_knight_battle_actor", &"high_comptroller_battle_actor",
		&"memory_inspector_battle_actor", &"fox_attendant_battle_actor", &"vow_spider_battle_actor", &"magistrate_enma_battle_actor", &"crimson_oni_challenger_battle_actor",
	]:
		if not registry.has(profile_id) or registry.region(profile_id).size == Vector2.ZERO or registry.world_draw_size(profile_id) == Vector2.ZERO:
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED profile=" + profile_id)
			get_tree().quit(1)
			return
		var runtime_texture_path := registry.texture_path(profile_id)
		if not runtime_texture_path.begins_with("res://") or not ResourceLoader.exists(runtime_texture_path) or not registry.texture(profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED runtime_texture=" + profile_id)
			get_tree().quit(1)
			return
	for brush_id in SANDBOX_TERRAIN_CATALOG.BRUSHES:
		var brush: Dictionary = SANDBOX_TERRAIN_CATALOG.BRUSHES[brush_id]
		var profile_id := StringName(brush.get("visual_profile", &""))
		if profile_id == &"" or not registry.has(profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED sandbox_terrain_profile=" + brush_id)
			get_tree().quit(1)
			return
		if String(brush.get("texture", "")) != registry.texture_path(profile_id) or brush.get("region", Rect2()) != registry.region(profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED sandbox_terrain_resolution=" + brush_id)
			get_tree().quit(1)
			return
	for object_id in SANDBOX_OBJECT_CATALOG.ITEMS:
		var object_definition: Dictionary = SANDBOX_OBJECT_CATALOG.ITEMS[object_id]
		var object_profile_id := StringName(object_definition.get("visual_profile", &""))
		if object_profile_id == &"":
			continue
		if not registry.has(object_profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED sandbox_object_profile=" + object_id)
			get_tree().quit(1)
			return
		if String(object_definition.get("texture", "")) != registry.texture_path(object_profile_id) or object_definition.get("region", Rect2()) != registry.region(object_profile_id) or object_definition.get("draw_size", Vector2.ZERO) != registry.world_draw_size(object_profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED sandbox_object_resolution=" + object_id)
			get_tree().quit(1)
			return
	if registry.doorway(&"haunted_mansion_exterior").x != 72.0:
		printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED mansion_doorway")
		get_tree().quit(1)
		return
	for stock_id in CampaignState.ARMORY_STOCK:
		var stock: Dictionary = CampaignState.ARMORY_STOCK[stock_id]
		var icon_profile := StringName(stock.get("icon_profile", &""))
		if icon_profile == &"" or not registry.has(icon_profile) or String(stock.get("icon", "")) != registry.texture_path(icon_profile):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED armory_icon=" + stock_id)
			get_tree().quit(1)
			return
	for enemy_id in CampaignCombatDatabase.BESTIARY_ORDER:
		var catalog_actor := CampaignCombatDatabase.enemy_actor(enemy_id, 0)
		var catalog_profile := StringName(catalog_actor.get("sprite_profile", &""))
		if catalog_profile == &"" or not registry.has(catalog_profile):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED unprofiled_enemy=" + enemy_id)
			get_tree().quit(1)
			return
		if String(catalog_actor.get("sprite_path", "")) != registry.texture_path(catalog_profile) or catalog_actor.get("sprite_region", Rect2()) != registry.region(catalog_profile):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED enemy_resolution=" + enemy_id)
			get_tree().quit(1)
			return
	CampaignState.reset_new_game()
	if CampaignCombatDatabase.PARTY_BATTLE_PROFILES.size() != CampaignState.recruit_catalog.size() + 1:
		printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED party_profile_count")
		get_tree().quit(1)
		return
	for character_id in CampaignCombatDatabase.PARTY_BATTLE_PROFILES:
		var party_profile := StringName(CampaignCombatDatabase.PARTY_BATTLE_PROFILES[character_id])
		var party_actor := CampaignCombatDatabase.raptor_actor() if character_id == &"velociraptor" else CampaignCombatDatabase.party_actor(character_id, CampaignState.character_progress[character_id])
		if party_profile == &"" or not registry.has(party_profile) or StringName(party_actor.get("sprite_profile", &"")) != party_profile:
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED unprofiled_party_actor=" + character_id)
			get_tree().quit(1)
			return
		if String(party_actor.get("sprite_path", "")) != registry.texture_path(party_profile) or party_actor.get("sprite_region", Rect2()) != registry.region(party_profile):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED party_resolution=" + character_id)
			get_tree().quit(1)
			return
	for case_data in [
		[&"rift_jackal_challenger", &"rift_jackal_battle_actor"],
		[&"bulkhead_warden_challenger", &"bulkhead_warden_battle_actor"],
		[&"mossback_surveyor_challenger", &"mossback_surveyor_battle_actor"],
		[&"cobalt_courier_challenger", &"cobalt_courier_battle_actor"],
		[&"primeval_raptor", &"primeval_raptor_battle_actor"],
		[&"stone_triceratops", &"stone_triceratops_battle_actor"],
		[&"municipal_spinosaur", &"municipal_spinosaur_battle_actor"],
		[&"commute_tyrant", &"commute_tyrant_battle_actor"],
		[&"schoolgirl_ghost", &"schoolgirl_ghost_battle_actor"],
		[&"war_book", &"war_book_battle_actor"],
		[&"clock_mirror", &"clock_mirror_battle_actor"],
		[&"composer_portrait", &"composer_portrait_battle_actor"],
		[&"haunted_doll", &"haunted_doll_battle_actor"],
		[&"work_robot", &"work_robot_battle_actor"], [ &"sentry_drone", &"sentry_drone_battle_actor"], [ &"medical_robot", &"medical_robot_battle_actor"], [ &"machine_commander", &"machine_commander_battle_actor"], [ &"mother_computer", &"mother_computer_battle_actor"],
		[&"helios_mech", &"helios_mech_battle_actor"], [ &"helios_assassin", &"helios_assassin_battle_actor"], [ &"helios_security", &"helios_security_battle_actor"], [ &"helios_gunner", &"helios_gunner_battle_actor"], [ &"civic_sun", &"civic_sun_battle_actor"],
		[&"frost_collector", &"frost_collector_battle_actor"], [ &"frost_necromancer", &"frost_necromancer_battle_actor"], [ &"ice_colossus", &"ice_colossus_battle_actor"], [ &"whiteout_auditor", &"whiteout_auditor_battle_actor"],
		[&"wind_bailiff", &"wind_bailiff_battle_actor"], [ &"storm_repossessor", &"storm_repossessor_battle_actor"], [ &"fallen_notary", &"fallen_notary_battle_actor"], [ &"gravity_knight", &"gravity_knight_battle_actor"], [ &"high_comptroller", &"high_comptroller_battle_actor"],
		[&"memory_inspector", &"memory_inspector_battle_actor"], [ &"fox_attendant", &"fox_attendant_battle_actor"], [ &"vow_spider", &"vow_spider_battle_actor"], [ &"magistrate_enma", &"magistrate_enma_battle_actor"], [ &"crimson_oni_challenger", &"crimson_oni_challenger_battle_actor"],
	]:
		var enemy_id: StringName = case_data[0]
		var profile_id: StringName = case_data[1]
		var actor := CampaignCombatDatabase.enemy_actor(enemy_id, 0)
		if StringName(actor.get("sprite_profile", &"")) != profile_id or String(actor.get("sprite_path", "")) != registry.texture_path(profile_id) or actor.get("sprite_region", Rect2()) != registry.region(profile_id):
			printerr("VISUAL_PROFILE_REGISTRY_SMOKE_FAILED battle_actor=" + enemy_id)
			get_tree().quit(1)
			return
	print("VISUAL_PROFILE_REGISTRY_SMOKE_OK profiles=%d catalog_enemies=%d party_actors=%d armory_icons=%d runtime=manifest ids+textures+combat_profiles=stable" % [registry.profile_count(), CampaignCombatDatabase.BESTIARY_ORDER.size(), CampaignCombatDatabase.PARTY_BATTLE_PROFILES.size(), CampaignState.ARMORY_STOCK.size()])
	get_tree().quit(0)
