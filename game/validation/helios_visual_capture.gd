extends Node

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")

const OUTPUT_NAMES := [
	"helios-skybridge.png",
	"helios-market.png",
	"helios-transit.png",
	"helios-clinic.png",
	"helios-core.png",
]
const ROOM_CENTERS := [
	Vector2i(111, 38),
	Vector2i(121, 38),
	Vector2i(131, 38),
	Vector2i(121, 48),
	Vector2i(131, 48),
]

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.anchor_universe(3, &"haunted_mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.anchor_universe(4, &"asterion_station")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.anchor_universe(5, &"primeval_expanse")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.anchor_universe(6, &"helios_arcology")
	CampaignState.story_flags[&"helios_core_open"] = true
	CampaignState.story_flags[&"helios_skybridge_cleared"] = true
	CampaignState.story_flags[&"helios_clinic_ambush_cleared"] = true
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	main._place_player(main.TOWN_ORIGIN + Vector2i(3, 18))
	await _settle()
	if not _capture("town-afterlight-club.png"):
		get_tree().quit(1)
		return
	for index in range(ROOM_CENTERS.size()):
		main._place_player(ROOM_CENTERS[index])
		await _settle()
		if not _capture(OUTPUT_NAMES[index]):
			get_tree().quit(1)
			return
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	battle.begin(&"helios_civic_sun", 1776)
	await _settle()
	if not _capture("helios-civic-sun-battle.png"):
		get_tree().quit(1)
		return
	print("HELIOS_VISUAL_CAPTURE_OK images=7")
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(6):
		await get_tree().process_frame


func _capture(file_name: String) -> bool:
	return CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/%s" % file_name, "Helios visual capture")
