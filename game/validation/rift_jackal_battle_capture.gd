extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.move_to_reserve(&"astronaut")
	CampaignState.add_to_party(&"rift_jackal")
	CampaignState.add_to_party(&"fighter")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	battle.begin(&"mansion_restless_portraits", 1776)
	for _frame in range(6):
		await get_tree().process_frame
	var jackal: Dictionary = battle.model.get_actor(&"rift_jackal")
	jackal["atb"] = 100.0
	battle._show_commands(&"rift_jackal")
	for _frame in range(3):
		await get_tree().process_frame
	if not _capture("rift-jackal-battle-idle.png"):
		return
	battle._play_actor_action(&"rift_jackal", &"rift_bite")
	await get_tree().create_timer(0.38).timeout
	if not _capture("rift-jackal-battle-attack.png"):
		return
	battle._play_actor_once(&"rift_jackal", &"hit")
	await get_tree().create_timer(0.38).timeout
	if not _capture("rift-jackal-battle-hit.png"):
		return
	battle._play_actor_loop(&"rift_jackal", &"victory")
	await get_tree().create_timer(0.38).timeout
	if not _capture("rift-jackal-battle-victory.png"):
		return
	print("RIFT_JACKAL_BATTLE_CAPTURE_OK supplied_slice=true states=idle+attack+hit+victory command_menu=true")
	get_tree().quit(0)


func _capture(file_name: String) -> bool:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result == OK:
		return true
	printerr("RIFT_JACKAL_BATTLE_CAPTURE_FAILED file=%s error=%d" % [file_name, result])
	get_tree().quit(1)
	return false
