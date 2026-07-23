extends Node

const CATALOG := preload("res://ben_rpg/world/town_resident_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Town resident catalog validation failed with %d error(s)." % errors.size())
	assert(CATALOG.resident_ids() == [&"cafe_owner", &"librarian", &"farmer", &"clinic_aide"])
	assert(CATALOG.profile(&"cafe_owner").get("facility") == "Cafe")
	assert(CATALOG.profile(&"farmer").get("requires_foundations", false))
	assert(ResourceLoader.exists(CATALOG.rotation_path(&"clinic_aide")))
	var librarian_lines := CATALOG.dialogue_lines(&"librarian", {"bestiary_seen": 7, "bestiary_total": 51}, true)
	assert(librarian_lines.size() == 2 and librarian_lines[0].contains("7 of 51") and librarian_lines[1].contains("NO DUPLICATE REWARDS"))
	print("TOWN_RESIDENT_CATALOG_SMOKE_OK residents=4 routines=complete dialogue=preserved assets=resolved")
	get_tree().quit()
