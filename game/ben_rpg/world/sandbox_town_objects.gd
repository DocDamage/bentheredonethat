class_name SandboxTownObjects
extends Node2D

const TILE := 48
const CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")
const TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")

var editor_active := false
var editor_mode: StringName = &"objects"
var cursor_cell := Vector2i(50, 8)
var cursor_catalog_id: StringName = &"modern_blue_cottage"
var cursor_valid := false
var selected_instance_id := ""


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not CampaignState.town_objects_changed.is_connected(_on_objects_changed):
		CampaignState.town_objects_changed.connect(_on_objects_changed)
	queue_redraw()


func set_editor_state(active: bool, cell: Vector2i, catalog_id: StringName, valid: bool, selected_id := "", mode: StringName = &"objects") -> void:
	editor_active = active
	editor_mode = mode
	cursor_cell = cell
	cursor_catalog_id = catalog_id
	cursor_valid = valid
	selected_instance_id = selected_id
	queue_redraw()


func object_at_cell(cell: Vector2i) -> Dictionary:
	for index in range(CampaignState.town_objects.size() - 1, -1, -1):
		var placed: Dictionary = CampaignState.town_objects[index]
		if placed_cell_rect(placed).has_point(cell):
			return placed
	return {}


func placed_cell_rect(placed: Dictionary) -> Rect2i:
	var definition := CATALOG.definition(StringName(placed.get("catalog_id", "")))
	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE)
	return Rect2i(Vector2i(int(placed.get("x", 0)), int(placed.get("y", 0))), footprint)


func _draw() -> void:
	var ordered := CampaignState.town_objects.duplicate()
	ordered.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			var a_rect := placed_cell_rect(a)
			var b_rect := placed_cell_rect(b)
			return a_rect.end.y < b_rect.end.y
	)
	for placed in ordered:
		_draw_placed_object(placed)
	if editor_active:
		var definition := TERRAIN_CATALOG.definition(cursor_catalog_id) if editor_mode == &"terrain" else CATALOG.definition(cursor_catalog_id)
		if editor_mode == &"objects" and not selected_instance_id.is_empty():
			var selected := CampaignState.town_object(selected_instance_id)
			if not selected.is_empty():
				definition = CATALOG.definition(StringName(selected.get("catalog_id", "")))
		var footprint: Vector2i = definition.get("footprint", Vector2i.ONE)
		var rect := Rect2(Vector2(cursor_cell * TILE), Vector2(footprint * TILE))
		if editor_mode == &"terrain" and not definition.is_empty():
			var texture_path := String(definition.get("texture", ""))
			if ResourceLoader.exists(texture_path):
				var texture := load(texture_path) as Texture2D
				var region: Rect2 = definition.get("region", Rect2(Vector2.ZERO, texture.get_size()))
				draw_texture_rect_region(texture, rect, region, Color(1, 1, 1, 0.72))
		var color := Color(0.35, 1.0, 0.72, 0.95) if cursor_valid else Color(1.0, 0.28, 0.32, 0.95)
		draw_rect(rect, Color(color, 0.15), true)
		draw_rect(rect, color, false, 4.0)


func _draw_placed_object(placed: Dictionary) -> void:
	var catalog_id := StringName(placed.get("catalog_id", ""))
	var definition := CATALOG.definition(catalog_id)
	if definition.is_empty():
		return
	var texture_path := String(definition.get("texture", ""))
	if not ResourceLoader.exists(texture_path):
		return
	var texture := load(texture_path) as Texture2D
	var region: Rect2 = definition.get("region", Rect2(Vector2.ZERO, texture.get_size()))
	var draw_size: Vector2 = definition.get("draw_size", region.size)
	var cell_rect := placed_cell_rect(placed)
	var footprint_rect := Rect2(Vector2(cell_rect.position * TILE), Vector2(cell_rect.size * TILE))
	var destination := Rect2(
		Vector2(footprint_rect.get_center().x - draw_size.x * 0.5, footprint_rect.end.y - draw_size.y),
		draw_size
	)
	if bool(placed.get("flipped", false)):
		draw_set_transform(Vector2(destination.end.x, destination.position.y), 0.0, Vector2(-1, 1))
		draw_texture_rect_region(texture, Rect2(Vector2.ZERO, destination.size), region)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect_region(texture, destination, region)
	if String(placed.get("instance_id", "")) == selected_instance_id:
		draw_rect(footprint_rect, Color(1.0, 0.83, 0.32, 0.95), false, 4.0)


func _on_objects_changed() -> void:
	queue_redraw()
