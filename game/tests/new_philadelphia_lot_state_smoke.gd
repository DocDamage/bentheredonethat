extends Node
const LOT_STATE := preload("res://ben_rpg/world/campaign_new_philadelphia_lot_state.gd")
func _ready() -> void:
	var state := LOT_STATE.new()
	assert(state.assign(&"LOT-01", &"facility_observatory_interior"))
	assert(state.facility_at(&"LOT-01") == &"facility_observatory_interior")
	assert(not state.assign(&"LOT-12", &"invalid"))
	var snapshot := state.snapshot()
	assert(state.clear(&"LOT-01") and state.facility_at(&"LOT-01") == &"")
	assert(state.restore(snapshot) and state.facility_at(&"LOT-01") == &"facility_observatory_interior")
	assert(not state.restore({"placements": {&"LOT-12": &"invalid"}}))
	print("NEW_PHILADELPHIA_LOT_STATE_SMOKE_OK lots=11 state=placement_only")
	get_tree().quit()
