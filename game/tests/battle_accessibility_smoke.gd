extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", true)
	SettingsRepository.set_value(&"accessibility", &"reduce_flashes", true)
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle()
	var battle := main.get_node_or_null("CampaignBattle") as CampaignBattle
	if not battle or not battle.begin(&"mansion_foyer_intro", 10444):
		_fail("The accessible test battle did not begin")
		return
	await _settle(2)
	if not battle._reduce_motion() or not battle._reduce_flashes():
		_fail("The battle did not read persisted reduced-motion or flash preferences")
		return
	var target_id := StringName((battle.model.living("enemy")[0] as Dictionary).get("id", &""))
	var stage_children := battle._stage.get_child_count()
	await battle._animate_action_vfx(&"static_discharge", [{"target": target_id, "type": "damage"}])
	if battle._stage.get_child_count() != stage_children:
		_fail("Reduced flashes still created an action VFX overlay")
		return
	battle._leave_battle(false)
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	SettingsRepository.set_value(&"accessibility", &"reduce_flashes", false)
	main.queue_free()
	await get_tree().process_frame
	print("BATTLE_ACCESSIBILITY_SMOKE_OK reduce_motion=stable_feedback reduce_flashes=no_vfx_overlay")
	get_tree().quit(0)


func _settle(frames := 6) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	SettingsRepository.set_value(&"accessibility", &"reduce_flashes", false)
	printerr("BATTLE_ACCESSIBILITY_SMOKE_FAILED: " + message)
	get_tree().quit(1)
