extends Node

const SELECTION := preload("res://ben_rpg/world/town_build_selection.gd")


func _ready() -> void:
	assert(SELECTION.next_foundation_blueprint({}) == "Cafe")
	assert(SELECTION.next_foundation_blueprint({0: "Cafe", 1: "Library", 2: "Clinic"}) == "Armory")
	assert(SELECTION.next_foundation_blueprint({0: "Cafe", 1: "Library", 2: "Clinic", 3: "Armory"}).is_empty())
	assert(SELECTION.founding_facility_count({0: "Cafe", 8: "Armory", 10: "Tea House"}) == 2)
	assert(SELECTION.next_available_plot(0, 1, 4, {1: "Cafe", 2: "Library"}) == 3)
	assert(SELECTION.next_available_plot(0, -1, 4, {3: "Cafe", 2: "Library"}) == 1)
	assert(SELECTION.next_available_plot(0, 1, 3, {0: "Cafe", 1: "Library", 2: "Clinic"}) == 0)
	print("TOWN_BUILD_SELECTION_SMOKE_OK blueprint_order=4 plot_traversal=wrap")
	get_tree().quit()
