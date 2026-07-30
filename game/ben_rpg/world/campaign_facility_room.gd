class_name CampaignFacilityRoom
extends Node2D

const TILE := 48.0
var _definition: Dictionary = {}


func configure(record_definition: Dictionary) -> void:
	_definition = record_definition.duplicate(true)
	var room_id := StringName(_definition.get("id", &""))
	name = "AuthoredFacilityRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	set_meta(&"facility_name", _definition.get("facilityName", ""))
	set_meta(&"implementation_state", &"implemented")
	_install_contract_nodes()
	queue_redraw()


func room_record() -> Dictionary:
	return _definition.duplicate(true)


func _install_contract_nodes() -> void:
	var interaction_layer := get_node_or_null("InteractionLayer") as Node2D
	if interaction_layer:
		var interaction := Node2D.new()
		interaction.name = "FacilityInteraction_%s" % String(_definition.get("interactionId", &"center"))
		interaction.position = Vector2(_definition.get("interactionCell", Vector2i.ZERO)) * TILE
		interaction.set_meta(&"facility_name", _definition.get("facilityName", ""))
		interaction.set_meta(&"service_contracts", _definition.get("serviceContracts", []))
		interaction_layer.add_child(interaction)
	var actors := get_node_or_null("YSortedActorsAndProps") as Node2D
	if actors:
		for anchor_id in (_definition.get("populationAnchorCells", {}) as Dictionary):
			var marker := Node2D.new()
			marker.name = "PopulationAnchor_%s" % anchor_id
			marker.position = Vector2(_definition["populationAnchorCells"][anchor_id]) * TILE
			marker.set_meta(&"anchor_id", anchor_id)
			actors.add_child(marker)


func _draw() -> void:
	if _definition.is_empty():
		return
	var dimensions: Vector2i = _definition.get("dimensions", Vector2i.ZERO)
	var size := Vector2(dimensions) * TILE
	var facility_name := String(_definition.get("facilityName", ""))
	var hue := float(abs(facility_name.hash()) % 1000) / 1000.0
	var floor_color := Color.from_hsv(hue, 0.18, 0.34)
	var wall_color := Color.from_hsv(hue, 0.28, 0.20)
	draw_rect(Rect2(Vector2.ZERO, size), floor_color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, TILE)), wall_color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(TILE, size.y)), wall_color)
	draw_rect(Rect2(Vector2(size.x - TILE, 0), Vector2(TILE, size.y)), wall_color)
	draw_rect(Rect2(Vector2(0, size.y - TILE), Vector2(size.x, TILE)), wall_color)
	var center := Vector2(_definition.get("interactionCell", Vector2i.ZERO)) * TILE
	draw_rect(Rect2(center - Vector2(72, 36), Vector2(144, 72)), floor_color.lightened(0.28))
	draw_string(ThemeDB.fallback_font, center + Vector2(-70, 6), facility_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 140, 18, Color(0.96, 0.91, 0.72))
