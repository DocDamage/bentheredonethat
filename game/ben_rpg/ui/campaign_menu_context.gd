class_name CampaignMenuContext
extends RefCounted

const ANNEX_REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")


static func at_laboratory(player: Gamepiece) -> bool:
	if not player: return false
	var cell := Gameboard.pixel_to_cell(player.position)
	if Rect2i(Vector2i.ZERO, Vector2i(20, 12)).has_point(cell): return true
	var np01 := ANNEX_REGISTRY.room(&"NP-01")
	return Rect2i(np01.get("worldOrigin", Vector2i.ZERO), np01.get("dimensions", Vector2i.ZERO)).has_point(cell)


static func at_management_location(player: Gamepiece) -> bool:
	if not player: return false
	if at_laboratory(player): return true
	var cell := Gameboard.pixel_to_cell(player.position)
	if Rect2i(Vector2i(36, 0), Vector2i(32, 22)).has_point(cell): return true
	for room_id in [&"NP-04", &"NP-05", &"NP-06", &"NP-07", &"NP-11", &"NP-12"]:
		var definition := ANNEX_REGISTRY.room(room_id)
		if Rect2i(definition.get("worldOrigin", Vector2i.ZERO), definition.get("dimensions", Vector2i.ZERO)).has_point(cell): return true
	return false


static func built_facility_names() -> Array[String]:
	var plot_indexes: Array = CampaignState.built_facilities.keys()
	plot_indexes.sort()
	var results: Array[String] = []
	for plot_index in plot_indexes:
		var facility_name := String(CampaignState.built_facilities[plot_index])
		if not CampaignState.facility_definition(facility_name).is_empty(): results.append(facility_name)
	return results
