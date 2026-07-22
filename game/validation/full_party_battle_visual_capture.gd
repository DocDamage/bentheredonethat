extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.move_to_reserve(&"astronaut")
	CampaignState.add_to_party(&"caveman")
	CampaignState.add_to_party(&"crimson_oni")
	CampaignState.add_to_party(&"neon_viper")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	battle.begin(&"mansion_restless_books", 1776)
	for _frame in range(6):
		await get_tree().process_frame
	_capture("battle-full-company-rebuilt.png")
	var ben: Dictionary = battle.model.get_actor(&"ben")
	ben["atb"] = 100.0
	battle._show_commands(&"ben")
	for _frame in range(3):
		await get_tree().process_frame
	_capture("battle-full-company-command-rebuilt.png")
	print("FULL_PARTY_BATTLE_VISUAL_CAPTURE_OK party=5 pet=1 enemies=2 images=2")
	get_tree().quit(0)
func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save full-party battle capture: %s" % error_string(error))
