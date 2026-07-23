extends Node

const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var migrated_mansion := SAVE_MIGRATOR.migrate({"version": 19, "last_save_cell": [0, 32]})
	assert(bool(migrated_mansion.get("ok", false)))
	assert(StringName(migrated_mansion["data"].get("last_manifest_room_id", "")) == &"HM-01")
	assert(migrated_mansion["data"].get("last_save_cell", []) == [306, 3])
	var migrated_asterion := SAVE_MIGRATOR.migrate({"version": 19, "last_save_cell": [46, 32]})
	assert(bool(migrated_asterion.get("ok", false)))
	assert(StringName(migrated_asterion["data"].get("last_manifest_room_id", "")) == &"AS-03")
	assert(migrated_asterion["data"].get("last_save_cell", []) == [357, 3])
	var town_save := SAVE_MIGRATOR.migrate({"version": 19, "last_save_cell": [50, 8]})
	assert(StringName(town_save["data"].get("last_manifest_room_id", "")) == &"")
	CampaignState.reset_new_game()
	var definition := ROOM_REGISTRY.room(&"HM-06")
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	CampaignState.last_manifest_room_id = &"HM-06"
	CampaignState.last_save_cell = origin + TRANSITION_ROUTER.safe_arrival_cell(&"HM-06", &"Nw")
	var payload := CampaignState.call(&"_serialize") as Dictionary
	CampaignState.reset_new_game()
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	CampaignState.call(&"_deserialize", payload, 20)
	assert(CampaignState.last_manifest_room_id == &"HM-06")
	assert(CampaignState.last_save_cell == origin + Vector2i(8, 3))
	main._restore_campaign_state()
	main._restore_saved_manifest_room()
	main._place_player(CampaignState.last_save_cell)
	for _frame in range(2):
		await get_tree().process_frame
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	assert(runtime.call(&"active_room_id") == &"HM-06")
	assert(streamer.call(&"active_room_id") == &"HM-06")
	assert(main._camera_area == "manifest:HM-06")
	assert(Gameboard.pixel_to_cell(Player.gamepiece.position) == CampaignState.last_save_cell)
	main.queue_free()
	await get_tree().process_frame
	print("CAMPAIGN_MANIFEST_SAVE_CONTEXT_SMOKE_OK legacy=HM01+AS03 persisted_room=HM06 restore=streamed town=unchanged")
	get_tree().quit()
