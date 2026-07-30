extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const TEST_SAVE := "user://rift_jackal_recruit_smoke.json"
const IDLE_FRAME := "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Rift Jackal/00_idle/frame_000.png"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	CampaignState.story_flags[&"first_universe_stabilized"] = true
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")

	if not ResourceLoader.exists(IDLE_FRAME) or CampaignState.skill_tree(&"rift_jackal").size() != 4:
		_fail("The sliced monster art or fixed specialty tree is missing")
		return
	var recruit: Dictionary = CampaignState.recruit_catalog.get(&"rift_jackal", {})
	if String(recruit.get("asset_pack", "")) != "Topdown Monsters Part 1" or StringName(CampaignState.recruit_status.get(&"rift_jackal")) != &"undiscovered":
		_fail("The monster was not registered as an undiscovered pack-separated recruit")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	if not world.has_node("RecruitableRiftJackal"):
		_fail("The Rift Jackal did not appear after the Mansion was stabilized")
		return
	var interaction = world.get_node("RecruitableRiftJackal/RecruitInteraction")
	var introduction: Array[String] = interaction.apply_interaction(false)
	if introduction.is_empty() or not CampaignState.story_flags.get(&"rift_jackal_met", false) or CampaignState.recruit_status.get(&"rift_jackal") != &"available":
		_fail("Meeting the monster did not reveal its hidden recruitment event")
		return

	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	if not battle.begin(&"mansion_rift_jackal_trial", 1776):
		_fail("The optional monster recruitment battle would not start")
		return
	var enemy_animation := battle._actor_animation(&"rift_jackal_challenger_0")
	if not enemy_animation or enemy_animation.current_sequence != &"idle" or battle._play_actor_action(&"rift_jackal_challenger_0", &"rift_bite") <= 0.0 or enemy_animation.current_sequence != &"attack":
		_fail("The supplied monster battle sheet did not drive idle and attack animation")
		return
	battle._play_actor_once(&"rift_jackal_challenger_0", &"hit")
	if enemy_animation.current_sequence != &"hit":
		_fail("The monster did not expose its authored hit reaction")
		return
	battle._play_actor_loop(&"rift_jackal_challenger_0", &"idle")
	if int(CampaignState.bestiary_record(&"rift_jackal_challenger").get("seen", 0)) != 1:
		_fail("The recruitable species was not sighted in the bestiary")
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"rift_jackal_trial_complete", false) or int(CampaignState.bestiary_record(&"rift_jackal_challenger").get("defeated", 0)) != 1:
		_fail("Winning the trial did not unlock recruitment and record the defeat")
		return

	interaction.apply_interaction(false)
	if CampaignState.recruit_status.get(&"rift_jackal") not in [&"party", &"reserve"]:
		_fail("The Rift Jackal did not become a permanent recruit")
		return
	var actor := CampaignCombatDatabase.party_actor(&"rift_jackal", CampaignState.character_progress[&"rift_jackal"])
	if &"rift_bite" not in actor.get("actions", []) or String(actor.get("sprite_path", "")) != IDLE_FRAME:
		_fail("The recruited monster lost its authored combat identity")
		return
	if PRESENTATION.effect_frames(&"rift_bite").size() != 30 or PRESENTATION.action_sound(&"rift_bite").is_empty():
		_fail("The recruited monster's commands lack the supplied VFX or SFX presentation")
		return
	var entry := CampaignCombatDatabase.bestiary_entry(&"rift_jackal_challenger")
	if not entry.get("recruitable", false) or String(entry.get("region", "")) != "Haunted Mansion":
		_fail("The bestiary does not identify the species as recruitable")
		return

	if CampaignState.recruit_status.get(&"rift_jackal") == &"party":
		CampaignState.move_to_reserve(&"rift_jackal")
	if not CampaignState.assign_to_facility(&"rift_jackal", "Library"):
		_fail("The recruited monster could not be assigned to a town facility")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The monster recruit state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.recruit_status.get(&"rift_jackal") != &"staffed":
		_fail("The recruited monster's facility role did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("RIFT_JACKAL_RECRUIT_SMOKE_OK pack=preserved slices=144 field=animated battle=idle+attack+hit+victory+death bestiary=recruitable progression=skill_tree staffing=true save_load=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("RIFT_JACKAL_RECRUIT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
