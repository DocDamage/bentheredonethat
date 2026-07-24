class_name CampaignAnnexRoomRuntime
extends Node2D

## Parallel runtime for approved annex rooms. It intentionally does not alter
## CampaignRoomRegistry's core-room count.

const REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
var _streamer: Node
var _navigation: GameboardLayer
var _active_room_id: StringName = &""

func configure(streamer: Node, navigation: GameboardLayer) -> void:
	_streamer = streamer
	_navigation = navigation

func active_room_id() -> StringName: return _active_room_id

func activate(room_id: StringName) -> bool:
	if not _navigation or not REGISTRY.is_runtime_admitted(room_id): return false
	var definition := REGISTRY.room(room_id)
	var previous := REGISTRY.room(_active_room_id)
	_apply_cells(previous, {})
	_active_room_id = room_id
	var walkable := {}
	for cell in (definition.get("navigation", {}) as Dictionary).get("walkableCells", []): walkable[cell] = true
	_apply_cells(definition, walkable)
	if _streamer: _streamer.call(&"activate_annex_room", room_id, definition)
	return true

func _apply_cells(definition: Dictionary, walkable: Dictionary) -> void:
	if definition.is_empty(): return
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var local := Vector2i(x, y)
			_navigation.set_cell(origin + local, 0, Vector2i(2, 2) if walkable.has(local) else Vector2i(1, 4), 0)
