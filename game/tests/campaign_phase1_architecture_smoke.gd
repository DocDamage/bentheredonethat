extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const POPULATION_SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")

const REQUIRED_COMPONENTS := [
	"res://ben_rpg/world/campaign_room_registry.gd",
	"res://ben_rpg/world/campaign_room_streamer.gd",
	"res://ben_rpg/world/campaign_transition_router.gd",
	"res://ben_rpg/world/campaign_camera_controller.gd",
	"res://ben_rpg/world/campaign_navigation_builder.gd",
	"res://ben_rpg/world/campaign_room_feature_installer.gd",
	"res://ben_rpg/world/campaign_encounter_runtime.gd",
	"res://ben_rpg/world/campaign_population_scheduler.gd",
	"res://ben_rpg/world/campaign_population_actor_factory.gd",
]


func _ready() -> void:
	for path in REQUIRED_COMPONENTS:
		assert(ResourceLoader.exists(path), "Phase 1 component is missing: %s" % path)
	assert(ROOM_REGISTRY.room_ids().size() == 102, "The production registry must retain exactly 102 core rooms.")
	assert(ROOM_REGISTRY.is_authored_room(&"TEST-01"), "The manifest-only architecture proof room must remain authored.")
	assert(POPULATION_SCHEDULER.validate().is_empty(), "The generated 258-identity registry must remain valid.")

	var bootstrap := FileAccess.get_file_as_string("res://ben_rpg/world/campaign_bootstrap.gd")
	var legacy_renderer := FileAccess.get_file_as_string("res://ben_rpg/world/campaign_map_visual.gd")
	for production_prefix in ["AF-", "PL-", "SF-", "FT-", "WF-", "LM-", "NP-"]:
		assert(not bootstrap.contains(production_prefix), "Expansion room %s entered the frozen bootstrap." % production_prefix)
		assert(not legacy_renderer.contains(production_prefix), "Expansion room %s entered the frozen legacy renderer." % production_prefix)
	assert(not bootstrap.contains("TEST-01"), "The manifest-only room must load without a bootstrap branch.")
	assert(not legacy_renderer.contains("TEST-01"), "The manifest-only room must render without the legacy adapter.")

	var state_source := FileAccess.get_file_as_string("res://ben_rpg/core/campaign_state.gd")
	assert(state_source.contains("const WORLD_CATALOG := preload"))
	assert(state_source.contains("const QUEST_DEFINITIONS := WORLD_CATALOG.QUEST_DEFINITIONS"))
	var residents := FileAccess.get_file_as_string("res://ben_rpg/world/town_resident_manager.gd")
	assert(not residents.contains("const PROFILES"), "Resident runtime must not own identity profiles.")
	assert(residents.contains("RESIDENT_CATALOG"), "Resident runtime must resolve identities through its catalog boundary.")
	var town_controller := FileAccess.get_file_as_string("res://ben_rpg/world/town_build_controller.gd")
	for boundary in ["BUILD_SELECTION", "PRESSURE_PRESENTATION", "OBJECTIVE_GUIDANCE"]:
		assert(town_controller.contains(boundary), "Town controller boundary is missing: %s" % boundary)

	print("CAMPAIGN_PHASE1_ARCHITECTURE_SMOKE_OK components=9 core_rooms=102 manifest_only=true frozen_bootstrap=true frozen_renderer=true population=258 town_boundaries=split")
	get_tree().quit()
