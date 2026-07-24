extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	_test_battle_speed()
	_test_wait_mode()
	print("ATB_TIMING_SMOKE_OK speed=0.5_to_2.0 wait=enemy_pause active=continues")
	get_tree().quit()


func _new_model() -> AtbBattleModel:
	var model := AtbBattleModel.new()
	var fixture_party: Array[StringName] = [&"ben", &"fighter"]
	model.setup(&"mansion_foyer_intro", fixture_party, CampaignState.character_progress, 1776)
	for actor in model.actors:
		actor["atb"] = 0.0
	return model


func _test_battle_speed() -> void:
	var normal := _new_model()
	normal.configure_timing(1.0, false)
	normal.tick_atb(1.0)
	var normal_atb := float(normal.get_actor(&"ben")["atb"])
	var fast := _new_model()
	fast.configure_timing(2.0, false)
	fast.tick_atb(1.0)
	assert(is_equal_approx(float(fast.get_actor(&"ben")["atb"]), normal_atb * 2.0), "Battle speed should scale ATB progression deterministically")


func _test_wait_mode() -> void:
	var waiting := _new_model()
	var enemy: Dictionary = waiting.living("enemy")[0]
	waiting.configure_timing(1.0, true, true)
	waiting.tick_atb(1.0)
	assert(is_zero_approx(float(enemy["atb"])), "Wait mode should pause hostile gauges while command input is open")
	assert(float(waiting.get_actor(&"ben")["atb"]) > 0.0, "Wait mode should not freeze the ready party member")
	waiting.configure_timing(1.0, false, true)
	waiting.tick_atb(1.0)
	assert(float(enemy["atb"]) > 0.0, "Active mode should keep hostile gauges moving during command input")
