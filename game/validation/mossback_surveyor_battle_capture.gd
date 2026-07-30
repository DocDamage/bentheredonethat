extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	for recruit_id in CampaignState.party.duplicate():
		if recruit_id != &"ben":
			CampaignState.move_to_reserve(StringName(recruit_id))
	CampaignState.add_to_party(&"mossback_surveyor")
	CampaignState.add_to_party(&"fighter")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	battle.begin(&"primeval_raptor_pack", 1776)
	for _frame in range(6):
		await get_tree().process_frame
	var surveyor: Dictionary = battle.model.get_actor(&"mossback_surveyor")
	surveyor["atb"] = 100.0
	battle._show_commands(&"mossback_surveyor")
	for _frame in range(3):
		await get_tree().process_frame
	_capture("mossback-surveyor-battle-idle.png")
	battle._play_actor_action(&"mossback_surveyor", &"mossback_pummel")
	await get_tree().create_timer(0.38).timeout
	_capture("mossback-surveyor-battle-attack.png")
	battle._play_actor_once(&"mossback_surveyor", &"power")
	await get_tree().create_timer(0.38).timeout
	_capture("mossback-surveyor-battle-power.png")
	battle._play_actor_loop(&"mossback_surveyor", &"victory")
	await get_tree().create_timer(0.38).timeout
	_capture("mossback-surveyor-battle-victory.png")
	print("MOSSBACK_SURVEYOR_BATTLE_CAPTURE_OK supplied_slice=true states=idle+attack+power+victory command_menu=true")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result != OK:
		printerr("MOSSBACK_SURVEYOR_BATTLE_CAPTURE_FAILED file=%s error=%d" % [file_name, result])
		get_tree().quit(1)
