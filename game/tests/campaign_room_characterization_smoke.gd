extends Node

## Data-only baseline for responsibility-moving room refactors.  It captures
## every current manifest area's camera, navigable component, authored feature
## cells, gates, bosses, saves/treasures, and reciprocal transition arrivals.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const NAVIGATION := preload("res://ben_rpg/world/campaign_navigation_builder.gd")

const INTERACTION_KEYS := [
	&"chapterInteractions", &"asterionInteractions", &"primevalInteractions", &"heliosInteractions",
	&"frostholdInteractions", &"moonpetalInteractions", &"empyrealInteractions", &"universeTreasures",
]


func _ready() -> void:
	assert(REGISTRY.validate().is_empty() and ROUTER.validate().is_empty() and NAVIGATION.validate().is_empty())
	var transition_count := 0
	var interaction_count := 0
	var boss_count := 0
	var save_count := 0
	var treasure_count := 0
	var gate_count := 0
	for room_id in REGISTRY.room_ids():
		var definition := REGISTRY.room(room_id)
		var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
		assert(REGISTRY.is_authored_room(room_id) and ResourceLoader.exists(String(definition.get("scenePath", ""))))
		assert((definition.get("cameraBounds", Rect2i()) as Rect2i).size == dimensions * 48)
		var camera_zoom := definition.get("cameraZoom", Vector2.ONE) as Vector2
		assert(camera_zoom.x > 0.0 and camera_zoom.y > 0.0)
		var navigation := NAVIGATION.navigation_record(room_id, REGISTRY.enabled_port_ids(room_id, _unlocked_flags()))
		var walkable: Dictionary = navigation.get("walkable", {})
		assert(not walkable.is_empty())
		var safe_arrivals: Array = navigation.get("safeArrivals", [])
		assert(not safe_arrivals.is_empty())
		var component := NAVIGATION._connected_component(safe_arrivals[0], walkable)
		for arrival_cell in safe_arrivals:
			assert(component.has(arrival_cell), "%s safe arrivals must remain in one traversable component." % room_id)
		gate_count += (definition.get("portGates", {}) as Dictionary).size()
		if not (definition.get("bossEncounter", {}) as Dictionary).is_empty():
			boss_count += 1
			_assert_feature_cell(room_id, definition["bossEncounter"].get("cell", Vector2i.ZERO), dimensions, walkable)
		var save_point: Dictionary = definition.get("savePoint", {})
		if not save_point.is_empty():
			save_count += 1
			_assert_feature_cell(room_id, save_point.get("cell", Vector2i.ZERO), dimensions, walkable)
		for property_name in INTERACTION_KEYS:
			for feature in definition.get(property_name, []):
				interaction_count += 1
				_assert_feature_cell(room_id, feature.get("cell", Vector2i.ZERO), dimensions, walkable)
				if feature.has("savePointId"):
					save_count += 1
				if property_name == &"universeTreasures":
					treasure_count += 1
		for binding in REGISTRY.ports(room_id):
			var port_id := StringName(binding.get("id", &""))
			var destination_room_id := StringName(binding.get("destination", &""))
			if not REGISTRY.has_room(destination_room_id):
				continue
			transition_count += 1
			var route := ROUTER.resolve(room_id, port_id)
			assert(not route.is_empty())
			var arrival_port_id := StringName(route.get("arrivalPort", &""))
			var destination_navigation := NAVIGATION.navigation_record(destination_room_id, REGISTRY.enabled_port_ids(destination_room_id, _unlocked_flags()))
			var destination_walkable: Dictionary = destination_navigation.get("walkable", {})
			var arrival_cell := route.get("arrivalCell", Vector2i.ZERO) as Vector2i
			assert(destination_walkable.has(arrival_cell) and NAVIGATION._legal_follower_cells(arrival_cell, destination_walkable) >= 3)
			assert(StringName(REGISTRY.port(destination_room_id, arrival_port_id).get("destination", &"")) == room_id)
	assert(transition_count == 264 and boss_count == 6 and save_count > 0 and treasure_count > 0)
	print("CAMPAIGN_ROOM_CHARACTERIZATION_SMOKE_OK rooms=102 camera+zoom=true components=connected transitions=%d interactions=%d bosses=%d saves=%d treasures=%d gates=%d" % [transition_count, interaction_count, boss_count, save_count, treasure_count, gate_count])
	get_tree().quit()


func _unlocked_flags() -> Dictionary:
	var flags := {}
	for room_id in REGISTRY.room_ids():
		for flag in (REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
			if StringName(flag) != &"":
				flags[StringName(flag)] = true
	return flags


func _assert_feature_cell(room_id: StringName, cell: Vector2i, dimensions: Vector2i, walkable: Dictionary) -> void:
	assert(Rect2i(Vector2i.ZERO, dimensions).has_point(cell), "%s feature cell lies outside its room." % room_id)
	assert(walkable.has(cell), "%s feature cell must remain walkable." % room_id)
