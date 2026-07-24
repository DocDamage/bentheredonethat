class_name CampaignAddressRoomCollision
extends Node2D

## Builds native physics shapes from one authored address-room navigation
## record. The owning scene remains responsible for when the room may stream;
## this node must not infer ports, encounters, or story state.

const CELL_SIZE := Vector2(48, 48)

var _navigation: Dictionary = {}
var _blocked_cells: Dictionary = {}


func configure(navigation: Dictionary) -> void:
	_navigation = navigation.duplicate(true)
	_blocked_cells.clear()
	for child in get_children():
		child.queue_free()
	for raw_cell in _navigation.get("blockedCells", []):
		var cell: Vector2i = raw_cell
		_blocked_cells[cell] = true
		_add_blocked_cell(cell)
	set_meta(&"collision_mask_id", _navigation.get("collisionMaskId", &""))
	set_meta(&"blocked_cell_count", _blocked_cells.size())


func blocked_cell_count() -> int:
	return _blocked_cells.size()


func blocks_cell(cell: Vector2i) -> bool:
	return _blocked_cells.has(cell)


func _add_blocked_cell(cell: Vector2i) -> void:
	var body := StaticBody2D.new()
	body.name = "BlockedCell_%d_%d" % [cell.x, cell.y]
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = Vector2(cell) * CELL_SIZE + CELL_SIZE * 0.5
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = CELL_SIZE
	shape.shape = rectangle
	body.add_child(shape)
	add_child(body)
