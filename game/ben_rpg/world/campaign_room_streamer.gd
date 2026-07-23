class_name CampaignRoomStreamer
extends Node

## Owns the active room root while legacy field regions migrate.  New authored
## rooms will attach their visuals, collision, interactions, and actors below
## this root; compatibility rooms use the same hierarchy but continue to draw
## through the frozen legacy renderer until their parity gate passes.

signal active_room_changed(room_id: StringName, legacy_area: StringName)

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const LEGACY_MANSION_ROOM_IDS := {
	&"mansion_foyer": &"HM-01",
	&"mansion_archive": &"HM-02",
	&"mansion_gallery": &"HM-04",
	&"mansion_nursery": &"HM-05",
	&"mansion_ballroom": &"HM-09",
}

var _active_root: Node2D
var _active_room_id: StringName = &""
var _active_legacy_area: StringName = &""


func activate_legacy_mansion_area(area: StringName) -> void:
	var room_id := StringName(LEGACY_MANSION_ROOM_IDS.get(area, &""))
	if room_id == &"":
		deactivate()
		return
	if room_id == _active_room_id and area == _active_legacy_area:
		return
	deactivate()
	_activate_root(room_id, area, _create_room_root(room_id, area))


func activate_room(room_id: StringName) -> void:
	if not ROOM_REGISTRY.is_authored_room(room_id):
		deactivate()
		return
	if room_id == _active_room_id and _active_legacy_area == &"":
		return
	var definition := ROOM_REGISTRY.room(room_id)
	var scene_path := String(definition.get("scenePath", ""))
	var scene := load(scene_path) as PackedScene
	if not scene:
		deactivate()
		return
	deactivate()
	var root := scene.instantiate() as Node2D
	if not root:
		return
	if root.has_method(&"configure"):
		root.call(&"configure", room_id, definition)
	_activate_root(room_id, &"", root)


func deactivate() -> void:
	if not _active_root:
		return
	remove_child(_active_root)
	_active_root.free()
	_active_root = null
	_active_room_id = &""
	_active_legacy_area = &""


func active_room_id() -> StringName:
	return _active_room_id


func active_legacy_area() -> StringName:
	return _active_legacy_area


func active_root() -> Node2D:
	return _active_root


func _activate_root(room_id: StringName, legacy_area: StringName, root: Node2D) -> void:
	_active_room_id = room_id
	_active_legacy_area = legacy_area
	_active_root = root
	add_child(_active_root)
	active_room_changed.emit(room_id, legacy_area)


func _create_room_root(room_id: StringName, area: StringName) -> Node2D:
	var root := Node2D.new()
	root.name = "ActiveRoom_%s" % room_id
	root.set_meta(&"room_id", room_id)
	root.set_meta(&"legacy_area", area)
	_add_layer(root, "GroundLayer", -2)
	_add_layer(root, "LowDecorationLayer", -1)
	_add_layer(root, "NavigationAndCollision", 0)
	var actors := _add_layer(root, "YSortedActorsAndProps", 0)
	actors.y_sort_enabled = true
	_add_layer(root, "ForegroundLayer", 1)
	_add_layer(root, "InteractionLayer", 0)
	_add_layer(root, "EncounterLayer", 0)
	return root


func _add_layer(root: Node2D, layer_name: String, z_index: int) -> Node2D:
	var layer := Node2D.new()
	layer.name = layer_name
	layer.z_index = z_index
	root.add_child(layer)
	return layer


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if LEGACY_MANSION_ROOM_IDS.size() != 5:
		errors.append("Room streamer must map exactly five legacy Mansion areas during migration.")
	for legacy_area in LEGACY_MANSION_ROOM_IDS:
		var room_id := StringName(LEGACY_MANSION_ROOM_IDS[legacy_area])
		if not ROOM_REGISTRY.has_room(room_id):
			errors.append("Legacy room %s maps to unknown registry room %s." % [legacy_area, room_id])
	if not ROOM_REGISTRY.is_authored_room(&"TEST-01"):
		errors.append("Room streamer requires the manifest-only authored test room.")
	return PackedStringArray(errors)
