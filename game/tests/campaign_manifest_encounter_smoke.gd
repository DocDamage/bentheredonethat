extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const DIRECTOR_SCRIPT := preload("res://ben_rpg/world/campaign_manifest_encounter_director.gd")


func _ready() -> void:
	var hm02 := REGISTRY.room(&"HM-02")
	var contract: Dictionary = hm02.get("encounterContract", {})
	assert(contract.get("policy", &"") == &"zone")
	assert((contract.get("formationPool", []) as Array).size() >= 2)
	assert(int(contract.get("cooldownSteps", 0)) == 8)
	var director := DIRECTOR_SCRIPT.new()
	director.configure_manifest(hm02, &"HM-02")
	assert(director.formation_pool().size() >= 2)
	assert(not director.is_danger_local_cell(Vector2i(8, 3)), "Safe arrivals must remain encounter-free.")
	assert(director.is_danger_local_cell(Vector2i(10, 7)), "Unreserved walkable interior must be a zone cell.")
	var scripted_only := REGISTRY.room(&"HM-06").get("encounterContract", {}) as Dictionary
	assert(scripted_only.get("policy", &"") == &"scripted_only")
	assert((scripted_only.get("formationPool", []) as Array).is_empty())
	print("CAMPAIGN_MANIFEST_ENCOUNTER_SMOKE_OK policy=zone+scripted_only pool=manifest cooldown=8 safe_arrival=excluded")
	get_tree().quit()
