extends Node

## Keeps battle-layout review out of res:// until a reviewer approves replacing
## the committed visual baselines. Run this scene windowed through the isolated
## runner; headless Godot intentionally has no viewport texture to capture.

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.move_to_reserve(&"astronaut")
	CampaignState.add_to_party(&"caveman")
	CampaignState.add_to_party(&"crimson_oni")
	CampaignState.add_to_party(&"neon_viper")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await _settle()
	if not battle.begin(&"mansion_restless_books", 1776):
		_fail("could not begin full-company encounter")
		return
	await _settle()
	if not _save("user://battle_readability_stage.png"):
		return
	var ben: Dictionary = battle.model.get_actor(&"ben")
	ben["atb"] = 100.0
	battle._show_commands(&"ben")
	await _settle()
	if not _save("user://battle_readability_ready.png"):
		return
	battle._on_action_selected(&"cane_tap")
	await _settle()
	if not _save("user://battle_readability_target.png"):
		return
	battle.queue_free()
	await get_tree().process_frame
	print("BATTLE_READABILITY_CAPTURE_OK images=3 viewport=960x540")
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(6):
		await get_tree().process_frame


func _save(path: String) -> bool:
	var viewport_texture := get_viewport().get_texture()
	if not viewport_texture:
		_fail("rendering texture unavailable; run windowed")
		return false
	if viewport_texture.get_image().save_png(path) != OK:
		_fail("could not write " + path)
		return false
	print("BATTLE_READABILITY_CAPTURE image=%s" % ProjectSettings.globalize_path(path))
	return true


func _fail(message: String) -> void:
	printerr("BATTLE_READABILITY_CAPTURE_FAILED: " + message)
	get_tree().quit(1)
