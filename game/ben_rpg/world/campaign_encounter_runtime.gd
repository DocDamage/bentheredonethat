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
const MANIFEST_ENCOUNTER_DIRECTOR := preload("res://ben_rpg/world/campaign_manifest_encounter_director.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

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
var _encounter_layer: Node
var _battle: CampaignBattle
var _manifest_controller: EncounterDirector


func install_legacy_controllers(encounter_layer: Node, battle: CampaignBattle) -> void:
	if not encounter_layer or not battle:
		return
	clear_legacy_controllers()
	_encounter_layer = encounter_layer
	_battle = battle
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


func bind_room_runtime(room_runtime: Node) -> void:
	if room_runtime and not room_runtime.active_room_changed.is_connected(_on_active_manifest_room_changed):
		room_runtime.active_room_changed.connect(_on_active_manifest_room_changed)


func manifest_controller() -> EncounterDirector:
	return _manifest_controller


func _on_active_manifest_room_changed(room_id: StringName) -> void:
	if _manifest_controller and is_instance_valid(_manifest_controller):
		_manifest_controller.queue_free()
	_manifest_controller = null
	if not _encounter_layer or not _battle:
		return
	var definition := ROOM_REGISTRY.room(room_id)
	var contract: Dictionary = definition.get("encounterContract", {})
	if StringName(contract.get("policy", &"none")) != &"zone" or (contract.get("formationPool", []) as Array).is_empty():
		return
	_manifest_controller = MANIFEST_ENCOUNTER_DIRECTOR.new() as EncounterDirector
	_manifest_controller.name = "ManifestEncounters_%s" % room_id
	_manifest_controller.battle = _battle
	_manifest_controller.call(&"configure_manifest", definition, room_id)
	_encounter_layer.add_child(_manifest_controller)


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
