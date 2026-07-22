extends Node

## Confirms the persisted environmental accessibility options drive the field
## overlay, including a static alternative for reduced motion.

func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	SettingsRepository.set_value(&"accessibility", &"weather_density", 1.0)
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle()
	var overlay: Variant = main.get_node_or_null("Field/Map/CampaignWorld/ForegroundLayer/WeatherOverlay")
	if not overlay:
		_fail("The campaign field weather overlay was not created")
		return
	overlay.set_active_area(&"frosthold_gate")
	if overlay.visible_particle_count() != 36 or not overlay.is_animated():
		_fail("Full-density Frosthold weather did not animate")
		return
	var first_phase: float = float(overlay.motion_phase())
	await _settle(3)
	if is_equal_approx(first_phase, overlay.motion_phase()):
		_fail("Enabled field weather did not advance")
		return
	SettingsRepository.set_value(&"accessibility", &"weather_density", 0.0)
	await get_tree().process_frame
	if overlay.visible_particle_count() != 0 or overlay.is_animated():
		_fail("Zero weather density did not hide the field weather")
		return
	SettingsRepository.set_value(&"accessibility", &"weather_density", 0.5)
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", true)
	await get_tree().process_frame
	var frozen_phase: float = float(overlay.motion_phase())
	await _settle(3)
	if overlay.visible_particle_count() != 18 or not overlay.is_motion_reduced() or overlay.is_animated() or not is_equal_approx(frozen_phase, float(overlay.motion_phase())):
		_fail("Reduced motion did not retain static half-density weather")
		return
	SettingsRepository.set_value(&"accessibility", &"weather_density", 1.0)
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	main.queue_free()
	await get_tree().process_frame
	print("WEATHER_ACCESSIBILITY_SMOKE_OK density=off-half-full reduce_motion=static")
	get_tree().quit(0)


func _settle(frames := 6) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	SettingsRepository.set_value(&"accessibility", &"weather_density", 1.0)
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	printerr("WEATHER_ACCESSIBILITY_SMOKE_FAILED: " + message)
	get_tree().quit(1)
