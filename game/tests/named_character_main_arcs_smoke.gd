extends Node

const HORROR_INTERACTION := preload("res://ben_rpg/characters/horror_arc_interaction.gd")
const CATALOG := preload("res://ben_rpg/core/campaign_world_catalog.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	assert(CampaignState.REQUIRED_NAMED_CHARACTER_ARCS == CATALOG.REQUIRED_NAMED_CHARACTER_ARCS)
	assert(not CampaignState.REQUIRED_NAMED_CHARACTER_ARCS.has(&"rift_exhibition"), "Named characters must not be contracted as an exhibition trial.")
	var dracula := HORROR_INTERACTION.new()
	dracula.witness_id = "dracula"
	var monster := HORROR_INTERACTION.new()
	monster.witness_id = "frankenstein_monster"
	assert(not dracula.apply_interaction(false).is_empty(), "The Mansion witness must reject pre-boss access.")
	assert(not CampaignState.story_flags.get(&"dracula_mansion_met", false))
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	dracula.apply_interaction(false)
	monster.apply_interaction(false)
	assert(CampaignState.story_flags.get(&"dracula_mansion_met", false))
	assert(CampaignState.story_flags.get(&"frankenstein_mansion_met", false))
	assert(CampaignState.story_flags.get(&"horror_arc_mansion_briefed", false))
	assert(CampaignState.story_flags.get(&"horror_arc_ashfall_required", false))
	assert(StringName(CampaignState.quest_state(&"the_ashes_remember").get("status", &"locked")) == &"active")
	assert(ResourceLoader.exists("res://ben_rpg/characters/dracula_horror_arc_gamepiece.tscn"))
	assert(ResourceLoader.exists("res://ben_rpg/characters/frankenstein_horror_arc_gamepiece.tscn"))
	await _assert_live_mansion_witnesses()
	CampaignState.reset_new_game()
	print("NAMED_CHARACTER_MAIN_ARCS_SMOKE_OK mansion_ashfall=mandatory pelagic=cthulhu ashfall_empyreal=dark_mage witnesses=dracula+frankenstein")
	get_tree().quit(0)


func _assert_live_mansion_witnesses() -> void:
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	var main_scene := load("res://src/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	var world := main.get_node_or_null("Field/Map/CampaignWorld")
	assert(world and world.has_node("MansionDraculaWitness"), "Dracula must appear in the stabilized Mansion ballroom.")
	assert(world and world.has_node("MansionFrankensteinWitness"), "Frankenstein's Monster must appear in the stabilized Mansion ballroom.")
	main.queue_free()
	await get_tree().process_frame
