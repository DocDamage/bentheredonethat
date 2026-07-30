class_name CampaignAddressRoom
extends Node2D

## Shared renderer for authored Phase 5 room records. The scene owns every
## runtime layer while chapter-specific content remains in validated data.

var _record: Dictionary = {}
const ENCOUNTER_INTERACTION := preload("res://ben_rpg/world/campaign_address_encounter_interaction.tscn")


func configure(record_definition: Dictionary) -> void:
	_record = record_definition.duplicate(true)
	var room_id := StringName(_record.get("id", &""))
	name = "AuthoredAddressRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	set_meta(&"address_id", _record.get("addressId", &""))
	set_meta(&"runtime_enabled", true)
	set_meta(&"implementation_state", &"implemented")
	var navigation: Dictionary = _record.get("navigation", {})
	var collision := get_node_or_null("NavigationAndCollision")
	if collision and collision.has_method(&"configure"):
		collision.call(&"configure", navigation)
	_install_population((_record.get("layout", {}) as Dictionary))
	_install_features((_record.get("layout", {}) as Dictionary))
	_install_encounter(_record.get("gameplay", {}), (_record.get("layout", {}) as Dictionary))
	queue_redraw()


func room_record() -> Dictionary:
	return _record.duplicate(true)


func _install_population(layout: Dictionary) -> void:
	var layer := get_node_or_null("YSortedActorsAndProps") as Node2D
	if not layer: return
	for assignment in layout.get("populationContracts", []) as Array:
		var marker := Node2D.new()
		marker.name = "AddressPopulation_%s" % assignment.get("cohortId", &"resident")
		marker.position = Vector2(assignment.get("cell", Vector2i.ZERO)) * 48.0
		marker.set_meta(&"cohort_id", assignment.get("cohortId", &""))
		marker.set_meta(&"phase", assignment.get("phase", &"first_visit"))
		layer.add_child(marker)


func _install_features(layout: Dictionary) -> void:
	var layer := get_node_or_null("InteractionLayer") as Node2D
	if not layer: return
	for feature in layout.get("featureContracts", []) as Array:
		var marker := Node2D.new()
		marker.name = "AddressFeature_%s" % feature.get("id", &"objective")
		marker.position = Vector2(feature.get("cell", Vector2i.ZERO)) * 48.0
		marker.set_meta(&"feature_id", feature.get("id", &""))
		marker.set_meta(&"runtime_state", feature.get("runtimeState", &"implemented"))
		layer.add_child(marker)


func _install_encounter(gameplay: Dictionary, layout: Dictionary) -> void:
	var encounter_id := StringName(gameplay.get("encounterId", &""))
	if encounter_id == &"": return
	var layer := get_node_or_null("EncounterLayer") as Node2D
	if not layer: return
	var interaction := ENCOUNTER_INTERACTION.instantiate()
	interaction.name = "AddressEncounter_%s" % encounter_id
	interaction.position = Vector2((layout.get("featureContracts", []) as Array)[0].get("cell", Vector2i.ZERO)) * 48.0
	interaction.call(&"configure", encounter_id)
	layer.add_child(interaction)


func _draw() -> void:
	var layout: Dictionary = _record.get("layout", {})
	var dimensions: Vector2i = layout.get("dimensions", Vector2i.ZERO)
	if dimensions == Vector2i.ZERO: return
	var color: Color = layout.get("themeColor", Color("555555"))
	var size := Vector2(dimensions) * 48.0
	draw_rect(Rect2(Vector2.ZERO, size), color)
	draw_rect(Rect2(Vector2(48, 48), size - Vector2(96, 96)), color.lightened(0.12), false, 4.0)
	for y in range(2, dimensions.y - 2, 3):
		draw_line(Vector2(96, y * 48), Vector2(size.x - 96, y * 48), color.lightened(0.06), 2.0)
