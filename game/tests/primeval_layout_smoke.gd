extends "res://tests/support/manifest_world_layout_smoke.gd"


func _world_name() -> String:
	return "Primeval"


func _room_ids() -> Array:
	return ROOM_REGISTRY.PRIMEVAL_ROOM_IDS


func _gate_label() -> String:
	return "decoded"
