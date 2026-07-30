extends Node

const ADAPTER := preload("res://ben_rpg/world/campaign_mansion_legacy_adapter.gd")


func _ready() -> void:
	var errors := ADAPTER.validate()
	for error in errors:
		push_error(error)
	assert(errors.is_empty(), "Legacy Mansion adapter validation failed with %d error(s)." % errors.size())
	assert(ADAPTER.area_for_cell(Vector2i(0, 32)) == &"mansion_foyer")
	assert(ADAPTER.area_for_cell(Vector2i(26, 43)) == &"mansion_ballroom")
	assert(ADAPTER.passage_gate_cell() == Vector2i(6, 36))
	assert(ADAPTER.ballroom_gate_cell() == Vector2i(16, 46))
	assert(ADAPTER.passage_transition_definitions().size() == 8)
	assert(ADAPTER.ballroom_transition_definitions().size() == 2)
	print("CAMPAIGN_MANSION_LEGACY_ADAPTER_SMOKE_OK areas=5 camera_bounds=8x8 transitions=10")
	get_tree().quit()
