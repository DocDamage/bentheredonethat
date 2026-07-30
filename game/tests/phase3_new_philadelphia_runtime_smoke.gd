extends Node

const ANNEX := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const FACILITIES := preload("res://ben_rpg/world/campaign_facility_catalog.gd")
const NP := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const POPULATION := preload("res://ben_rpg/world/campaign_new_philadelphia_population_catalog.gd")
const SAVE_PATH := "user://phase3_new_philadelphia_runtime_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	assert(NP.validate().is_empty())
	assert(POPULATION.validate().is_empty())
	assert(FACILITIES.validate().is_empty())
	assert(ANNEX.validate().is_empty())
	assert(ANNEX.room_ids().size() == 27)
	for room_id in NP.ROOM_ORDER + FACILITIES.ROOM_ORDER:
		assert(ANNEX.is_runtime_admitted(room_id))
		assert(ResourceLoader.exists(String(ANNEX.room(room_id).get("scenePath", ""))))
	var combinations := 0
	for facility_index in range(FACILITIES.FACILITY_NAMES.size()):
		for lot_index in range(NP.LOT_DEFINITIONS.size()):
			CampaignState.reset_new_game()
			var facility_name: String = FACILITIES.FACILITY_NAMES[facility_index]
			assert(CampaignState.build_facility(lot_index, facility_name))
			var lot_id := StringName("LOT-%02d" % (lot_index + 1))
			assert(StringName(CampaignState.new_philadelphia_lot_placements.get(lot_id, &"")) == FACILITIES.ROOM_ORDER[facility_index])
			combinations += 1
	assert(combinations == 121)

	CampaignState.reset_new_game()
	for index in range(FACILITIES.FACILITY_NAMES.size()):
		assert(CampaignState.build_facility(index, FACILITIES.FACILITY_NAMES[index]))
	CampaignState.facility_assignments["Cafe"] = &"fighter"
	CampaignState.active_facility_jobs["Cafe"] = {"job_id": &"cafe_founders_supper", "remaining": 30}
	CampaignState.sandbox_mode = true
	assert(CampaignState.relocate_facility("Cafe", 10) == false) # occupied
	CampaignState.built_facilities.erase(10)
	CampaignState.new_philadelphia_lot_placements.erase(&"LOT-11")
	assert(CampaignState.relocate_facility("Cafe", 10))
	assert(CampaignState.facility_assignments.get("Cafe", &"") == &"fighter")
	assert((CampaignState.active_facility_jobs.get("Cafe", {}) as Dictionary).get("job_id", &"") == &"cafe_founders_supper")
	assert(CampaignState.save_game(SAVE_PATH) == OK)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(SAVE_PATH) == OK)
	assert(StringName(CampaignState.new_philadelphia_lot_placements.get(&"LOT-11", &"")) == &"FI-01")
	assert(CampaignState.facility_assignments.get("Cafe", &"") == &"fighter")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6): await get_tree().process_frame
	assert(main.enter_phase3_room(&"NP-12", &"W1"))
	await get_tree().process_frame
	var runtime := main.get_node("Field/Map/CampaignWorld/Phase3RoomRuntime")
	var streamer := main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	assert(runtime.active_room_id() == &"NP-12")
	assert(streamer.active_room_id() == &"NP-12")
	assert(streamer.active_root().position == Vector2(ANNEX.STAGING_ORIGIN * 48))
	var population_contract: Dictionary = streamer.active_root().get_meta(&"population_contract")
	assert(population_contract.get("townPhase", &"") == &"construction")
	assert((population_contract.get("assignments", []) as Array).size() <= 6)
	assert(streamer.active_root().get_node("YSortedActorsAndProps").get_child_count() >= (population_contract.get("assignments", []) as Array).size())
	assert(runtime.get_node_or_null("FacilityLot_LOT-11_FI-01") != null)
	assert(runtime.activate(&"FI-01"))
	await get_tree().process_frame
	assert(streamer.active_room_id() == &"FI-01")
	assert(streamer.active_root().get_meta(&"facility_name") == "Cafe")
	print("PHASE3_NEW_PHILADELPHIA_RUNTIME_SMOKE_OK rooms=15 facilities=11 combinations=121 save_reload=true jobs_preserved=true runtime_streamed=true")
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	get_tree().quit(0)
