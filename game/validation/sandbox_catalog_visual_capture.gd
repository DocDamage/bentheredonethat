extends Node

const CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 12))
	CampaignState.town_objects.clear()
	CampaignState.place_town_object(&"modern_warehouse", Vector2i(47, 4))
	CampaignState.place_town_object(&"modern_blue_cottage", Vector2i(41, 9))
	CampaignState.place_town_object(&"modern_red_cottage", Vector2i(45, 9))
	CampaignState.place_town_object(&"scifi_command_bank", Vector2i(49, 9))
	CampaignState.place_town_object(&"scifi_bio_pod", Vector2i(57, 10))
	CampaignState.place_town_object(&"scifi_grow_rack", Vector2i(43, 14))
	CampaignState.place_town_object(&"scifi_shuttle", Vector2i(50, 14))
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(12):
		await get_tree().process_frame
	main._place_player(Vector2i(51, 12))
	var editor := main.get_node("SandboxTownEditor")
	editor.suppress_persistence = true
	editor._set_active(true)
	editor.pack_index = CATALOG.PACK_ORDER.find(&"Sci-Fi Spaceship")
	var scifi_items: Array[StringName] = CATALOG.items_for_pack(&"Sci-Fi Spaceship")
	editor.item_index = scifi_items.find(&"scifi_bio_pod")
	editor.cursor_cell = Vector2i(57, 10)
	editor._refresh_hud()
	editor._sync_renderer()
	for _frame in range(8):
		await get_tree().process_frame
	_capture("sandbox-catalog-slices-rebuilt.png")
	editor._set_active(false)
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	CampaignState.town_objects.clear()
	CampaignState.place_town_object(&"modern_blue_cottage", Vector2i(40, 8))
	CampaignState.place_town_object(&"modern_red_cottage", Vector2i(44, 8))
	CampaignState.place_town_object(&"modern_warehouse", Vector2i(48, 8))
	CampaignState.place_town_object(&"scifi_bio_pod", Vector2i(54, 8))
	CampaignState.place_town_object(&"scifi_med_scanner", Vector2i(57, 8))
	CampaignState.place_town_object(&"scifi_grow_rack", Vector2i(40, 14))
	CampaignState.place_town_object(&"scifi_shuttle", Vector2i(47, 14))
	CampaignState.place_town_object(&"scifi_cargo_module", Vector2i(54, 14))
	main.refresh_sandbox_object_collision()
	main._place_player(Vector2i(50, 12))
	for _frame in range(8):
		await get_tree().process_frame
	_capture("sandbox-building-placement-rebuilt.png")
	print("SANDBOX_CATALOG_VISUAL_CAPTURE_OK packs=%d items=%d images=2" % [CATALOG.PACK_ORDER.size(), CATALOG.ITEMS.size()])
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save sandbox catalog capture: %s" % error_string(error))
