class_name CampaignManifestEncounterDirector
extends EncounterDirector

const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const POPULATION_SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")

var room_id: StringName = &""
var _zone_cells: Dictionary = {}
var _formation_pool: Array[StringName] = []


func configure_manifest(room_definition: Dictionary, requested_room_id: StringName) -> void:
	room_id = requested_room_id
	origin = room_definition.get("worldOrigin", Vector2i.ZERO)
	size = room_definition.get("dimensions", Vector2i.ZERO)
	var contract: Dictionary = room_definition.get("encounterContract", {})
	universe_id = StringName("manifest:%s" % room_id)
	threshold_min = int(contract.get("thresholdMin", 11))
	threshold_max = int(contract.get("thresholdMax", 17))
	anti_repeat_depth = int(contract.get("antiRepeatDepth", 2))
	cooldown_steps_after_battle = int(contract.get("cooldownSteps", 8))
	for encounter_id in contract.get("formationPool", []):
		_formation_pool.append(StringName(encounter_id))
	var reserved := POPULATION_SCHEDULER.reserved_cells_for_room(room_id, room_definition)
	var walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(room_id).get("walkable", {})
	for cell in walkable:
		if not reserved.has(cell):
			_zone_cells[cell] = true


func is_danger_local_cell(local_cell: Vector2i) -> bool:
	return _zone_cells.has(local_cell)


func formation_pool() -> Array[StringName]:
	return _formation_pool.duplicate()


func _configure_region() -> void:
	# Configuration is injected by CampaignEncounterRuntime before this node enters
	# the scene tree. Keep this hook intentionally empty for the shared base.
	pass


func _is_danger_region(local: Vector2i) -> bool:
	return is_danger_local_cell(local)


func _random_encounter_options(_local: Vector2i) -> Array[StringName]:
	return formation_pool()
