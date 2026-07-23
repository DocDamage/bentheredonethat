extends Node

const NAVIGATION := preload("res://ben_rpg/world/campaign_facility_navigation.gd")
const TOWN_ORIGIN := Vector2i(36, 0)
const PLOTS: Array[Rect2i] = [
	Rect2i(7, 5, 5, 4), Rect2i(18, 5, 5, 4), Rect2i(7, 13, 5, 4),
	Rect2i(16, 12, 9, 5), Rect2i(25, 13, 7, 4), Rect2i(25, 5, 5, 4),
	Rect2i(1, 13, 5, 4), Rect2i(1, 4, 5, 5), Rect2i(16, 20, 5, 5),
	Rect2i(25, 20, 5, 5), Rect2i(7, 20, 5, 5),
]


func _ready() -> void:
	var all_facilities := {}
	var blocked_count := 0
	for plot_index in range(PLOTS.size()):
		all_facilities[plot_index] = "fixture"
		var plot := PLOTS[plot_index]
		var door := NAVIGATION.door_cell(TOWN_ORIGIN, plot)
		var returned := NAVIGATION.return_cell(TOWN_ORIGIN, plot)
		var blocked := NAVIGATION.blocked_cells(TOWN_ORIGIN, plot)
		if door in blocked or returned in blocked or blocked.size() != plot.size.x * plot.size.y - 1:
			_fail("lot %d did not preserve its exact doorway footprint" % (plot_index + 1))
			return
		blocked_count += blocked.size()
	var access := NAVIGATION.access_cells(TOWN_ORIGIN, PLOTS, all_facilities)
	if access.size() != PLOTS.size() * 2:
		_fail("facility access policy did not retain every door and return cell")
		return
	if NAVIGATION.access_cells(TOWN_ORIGIN, PLOTS, {-1: "bad", 99: "bad"}).size() != 0:
		_fail("facility access policy accepted an invalid plot index")
		return
	print("CAMPAIGN_FACILITY_NAVIGATION_SMOKE_OK lots=11 blocked=%d access=22 invalid_indices=ignored" % blocked_count)
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_FACILITY_NAVIGATION_SMOKE_FAILED: " + message)
	get_tree().quit(1)
