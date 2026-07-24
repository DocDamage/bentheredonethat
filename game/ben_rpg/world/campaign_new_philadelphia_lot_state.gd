class_name CampaignNewPhiladelphiaLotState
extends RefCounted

## Owns only mutable exterior placement. Facility story, inventory, quests, and
## interiors remain with the destination facility; this prevents a movable lot
## from becoming a second facility-state authority.

const CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
var _placements: Dictionary = {}


func assign(lot_id: StringName, facility_interior_id: StringName) -> bool:
	if CATALOG.lot(lot_id).is_empty() or facility_interior_id == &"":
		return false
	_placements[lot_id] = facility_interior_id
	return true


func clear(lot_id: StringName) -> bool:
	if CATALOG.lot(lot_id).is_empty():
		return false
	_placements.erase(lot_id)
	return true


func facility_at(lot_id: StringName) -> StringName:
	return StringName(_placements.get(lot_id, &""))


func snapshot() -> Dictionary:
	return {"placements": _placements.duplicate(true)}


func restore(snapshot_definition: Dictionary) -> bool:
	var placements: Dictionary = snapshot_definition.get("placements", {})
	var restored: Dictionary = {}
	for raw_lot_id in placements:
		var lot_id := StringName(raw_lot_id)
		var facility_id := StringName(placements[raw_lot_id])
		if CATALOG.lot(lot_id).is_empty() or facility_id == &"":
			return false
		restored[lot_id] = facility_id
	_placements = restored
	return true
