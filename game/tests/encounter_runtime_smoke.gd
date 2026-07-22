extends Node

const TEST_SAVE := "user://encounter_runtime_smoke.json"


class EncounterTestDirector extends EncounterDirector:
	func _configure_region() -> void:
		universe_id = &"encounter_runtime_test"
		threshold_min = 10
		threshold_max = 16

	func _random_encounter_options(_local: Vector2i) -> Array[StringName]:
		return [&"alpha", &"beta", &"gamma"]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var director := EncounterTestDirector.new()
	director._configure_region()
	director._rng.seed = 1337
	director._record_random_encounter(&"alpha")
	var first_choice := director._choose_random_encounter(Vector2i.ZERO)
	if first_choice == &"alpha":
		_fail("Anti-repeat bag selected the immediately previous formation")
		return
	director._record_random_encounter(first_choice)
	var second_choice := director._choose_random_encounter(Vector2i.ZERO)
	if second_choice in [&"alpha", first_choice]:
		_fail("Anti-repeat depth did not exclude both recent formations")
		return

	director._steps_in_danger = 7
	director._encounter_threshold = 15
	director._cooldown_steps = 3
	director._last_danger_cell = Vector2i(14, 9)
	director._persist_runtime()
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Encounter runtime could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Encounter runtime could not be loaded")
		return
	var restored := EncounterTestDirector.new()
	restored._configure_region()
	restored._restore_runtime()
	if restored._steps_in_danger != 7 or restored._encounter_threshold != 15 or restored._cooldown_steps != 3:
		_fail("Encounter pressure or cooldown did not persist")
		return
	if restored._last_danger_cell != Vector2i(14, 9) or restored._recent_formations.size() != 2:
		_fail("Encounter cell history or anti-repeat bag did not persist")
		return
	var restored_choice := restored._choose_random_encounter(Vector2i.ZERO)
	if restored_choice in restored._recent_formations:
		_fail("Restored anti-repeat bag allowed a duplicate formation")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("ENCOUNTER_RUNTIME_SMOKE_OK anti_repeat=2 pressure+cooldown=true reload_safe=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ENCOUNTER_RUNTIME_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
