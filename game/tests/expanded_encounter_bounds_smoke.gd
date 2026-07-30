extends Node

const CONTROLLERS := {
	"mansion": preload("res://ben_rpg/world/mansion_encounter_controller.gd"),
	"asterion": preload("res://ben_rpg/world/asterion_encounter_controller.gd"),
	"primeval": preload("res://ben_rpg/world/primeval_encounter_controller.gd"),
	"helios": preload("res://ben_rpg/world/helios_encounter_controller.gd"),
	"frosthold": preload("res://ben_rpg/world/frosthold_encounter_controller.gd"),
	"moonpetal": preload("res://ben_rpg/world/moonpetal_encounter_controller.gd"),
	"empyreal": preload("res://ben_rpg/world/empyreal_encounter_controller.gd"),
}


func _ready() -> void:
	CampaignState.reset_new_game()
	for controller_name in CONTROLLERS:
		var controller = CONTROLLERS[controller_name].new()
		# (17, 7) is the new outer-right corner of the shared second room. It was
		# outside every previous six-by-three danger strip.
		if not controller._is_danger_region(Vector2i(17, 7)):
			printerr("EXPANDED_ENCOUNTER_BOUNDS_SMOKE_FAILED danger=" + controller_name)
			get_tree().quit(1)
			return
	for controller_name in CONTROLLERS:
		var controller = CONTROLLERS[controller_name].new()
		if controller._scripted_encounter(Vector2i(7, 5)) == &"":
			printerr("EXPANDED_ENCOUNTER_BOUNDS_SMOKE_FAILED scripted=" + controller_name)
			get_tree().quit(1)
			return
	print("EXPANDED_ENCOUNTER_BOUNDS_SMOKE_OK universes=7 footprint=8x4 edge_cells=active")
	get_tree().quit(0)
