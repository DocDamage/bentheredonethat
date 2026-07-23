class_name CampaignEncounterRuntime
extends Node

## Compatibility owner for legacy universe encounter controllers. Bootstrap only
## composes this runtime with the battle service and encounter layer; the
## controller catalog, names, and future manifest-zone adapter live here.

const MANSION_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/mansion_encounter_controller.gd")
const ASTERION_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/asterion_encounter_controller.gd")
const PRIMEVAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/primeval_encounter_controller.gd")
const HELIOS_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/helios_encounter_controller.gd")
const FROSTHOLD_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/frosthold_encounter_controller.gd")
const MOONPETAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/moonpetal_encounter_controller.gd")
const EMPYREAL_ENCOUNTER_CONTROLLER := preload("res://ben_rpg/world/empyreal_encounter_controller.gd")

const LEGACY_CONTROLLER_SPECS := [
	{&"name": &"MansionEncounters", &"script": MANSION_ENCOUNTER_CONTROLLER},
	{&"name": &"AsterionEncounters", &"script": ASTERION_ENCOUNTER_CONTROLLER},
	{&"name": &"PrimevalEncounters", &"script": PRIMEVAL_ENCOUNTER_CONTROLLER},
	{&"name": &"HeliosEncounters", &"script": HELIOS_ENCOUNTER_CONTROLLER},
	{&"name": &"FrostholdEncounters", &"script": FROSTHOLD_ENCOUNTER_CONTROLLER},
	{&"name": &"MoonpetalEncounters", &"script": MOONPETAL_ENCOUNTER_CONTROLLER},
	{&"name": &"EmpyrealEncounters", &"script": EMPYREAL_ENCOUNTER_CONTROLLER},
]

var _legacy_controllers: Array[EncounterDirector] = []


func install_legacy_controllers(encounter_layer: Node, battle: CampaignBattle) -> void:
	if not encounter_layer or not battle:
		return
	clear_legacy_controllers()
	for specification in LEGACY_CONTROLLER_SPECS:
		var controller_script := specification.get(&"script") as GDScript
		var controller := controller_script.new() as EncounterDirector
		if not controller:
			push_error("Encounter runtime failed to create %s." % specification.get(&"name", "legacy controller"))
			continue
		controller.name = String(specification.get(&"name", "LegacyEncounters"))
		controller.battle = battle
		encounter_layer.add_child(controller)
		_legacy_controllers.append(controller)


func legacy_controller_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for controller in _legacy_controllers:
		if is_instance_valid(controller):
			names.append(StringName(controller.name))
	return names


func clear_legacy_controllers() -> void:
	for controller in _legacy_controllers:
		if is_instance_valid(controller):
			controller.queue_free()
	_legacy_controllers.clear()


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if LEGACY_CONTROLLER_SPECS.size() != 7:
		errors.append("Encounter runtime must preserve seven legacy universe controllers during migration.")
	var names: Dictionary = {}
	for specification in LEGACY_CONTROLLER_SPECS:
		var controller_name := StringName(specification.get(&"name", &""))
		if controller_name == &"" or names.has(controller_name):
			errors.append("Encounter runtime controller names must be unique and non-empty.")
		names[controller_name] = true
	return PackedStringArray(errors)
