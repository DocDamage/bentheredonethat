extends "res://tests/support/manifest_world_layout_smoke.gd"


func _world_name() -> String:
	return "Moonpetal"


func _room_ids() -> Array:
	return ROOM_REGISTRY.MOONPETAL_ROOM_IDS


func _gate_label() -> String:
	return "lantern"
