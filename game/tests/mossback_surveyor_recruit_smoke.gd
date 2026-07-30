extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const TEST_SAVE := "user://mossback_surveyor_recruit_smoke.json"
const SLICE_ROOT := "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Mossback Surveyor"
const IDLE_FRAME := SLICE_ROOT + "/00_idle/frame_000.png"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.story_flags[&"primeval_anchor_built"] = true
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.story_flags[&"third_universe_stabilized"] = true
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")

	var slice_count := 0
	for folder in DirAccess.get_directories_at(SLICE_ROOT):
		for filename in DirAccess.get_files_at("%s/%s" % [SLICE_ROOT, folder]):
			if filename.ends_with(".png"):
				slice_count += 1
	if slice_count != 144 or not ResourceLoader.exists(IDLE_FRAME) or CampaignState.skill_tree(&"mossback_surveyor").size() != 4:
		_fail("The preserved ogre sheet was not separated into 144 exact frames with a fixed specialty tree (slices=%d resource=%s skills=%d)" % [slice_count, ResourceLoader.exists(IDLE_FRAME), CampaignState.skill_tree(&"mossback_surveyor").size()])
		return
	var recruit: Dictionary = CampaignState.recruit_catalog.get(&"mossback_surveyor", {})
	if String(recruit.get("asset_pack", "")) != "Topdown Monsters Part 1" or StringName(CampaignState.recruit_status.get(&"mossback_surveyor")) != &"undiscovered":
		_fail("The Mossback Surveyor was not registered as an undiscovered pack-separated recruit")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	if not world.has_node("RecruitableMossbackSurveyor"):
		_fail("The surveyor did not appear after Primeval Borough was stabilized")
		return
	var gamepiece: Gamepiece = world.get_node("RecruitableMossbackSurveyor")
	if gamepiece.animation == null or gamepiece.animation._sprite.scale.x > 0.8:
		_fail("The supplied monster was not animated at a sensible field scale")
		return
	var interaction = gamepiece.get_node("RecruitInteraction")
	var introduction: Array[String] = interaction.apply_interaction(false)
	if introduction.is_empty() or not CampaignState.story_flags.get(&"mossback_surveyor_met", false) or CampaignState.recruit_status.get(&"mossback_surveyor") != &"available":
		_fail("Meeting the surveyor did not reveal the hidden Green Audit")
		return
	if StringName(CampaignState.quest_state(&"the_green_audit").get("status", &"locked")) == &"locked":
		_fail("The hidden recruitment quest did not become visible when its information was discovered")
		return

	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	if not battle.begin(&"primeval_mossback_trial", 1776):
		_fail("The optional Green Audit battle would not start")
		return
	var enemy_animation := battle._actor_animation(&"mossback_surveyor_challenger_0")
	if not enemy_animation or enemy_animation.current_sequence != &"idle" or battle._play_actor_action(&"mossback_surveyor_challenger_0", &"mossback_pummel") <= 0.0 or enemy_animation.current_sequence != &"attack":
		_fail("The supplied monster frames did not drive idle and attack animation")
		return
	battle._play_actor_once(&"mossback_surveyor_challenger_0", &"hit")
	if enemy_animation.current_sequence != &"hit":
		_fail("The Surveyor did not expose its authored hit reaction")
		return
	battle._play_actor_loop(&"mossback_surveyor_challenger_0", &"idle")
	if int(CampaignState.bestiary_record(&"mossback_surveyor_challenger").get("seen", 0)) != 1:
		_fail("The recruitable species was not sighted in the bestiary")
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"mossback_surveyor_trial_complete", false) or int(CampaignState.bestiary_record(&"mossback_surveyor_challenger").get("defeated", 0)) != 1:
		_fail("Winning the Green Audit did not unlock recruitment and record the defeat")
		return

	interaction.apply_interaction(false)
	if CampaignState.recruit_status.get(&"mossback_surveyor") not in [&"party", &"reserve"]:
		_fail("The Mossback Surveyor did not become a permanent recruit")
		return
	var actor := CampaignCombatDatabase.party_actor(&"mossback_surveyor", CampaignState.character_progress[&"mossback_surveyor"])
	if &"mossback_pummel" not in actor.get("actions", []) or &"spore_receipt" not in actor.get("actions", []) or String(actor.get("sprite_path", "")) != IDLE_FRAME:
		_fail("The recruited monster lost its authored combat identity")
		return
	if PRESENTATION.effect_frames(&"spore_receipt").size() != 30 or PRESENTATION.action_sound(&"mossback_pummel").is_empty():
		_fail("The Surveyor's commands lack supplied VFX or SFX presentation")
		return
	var entry := CampaignCombatDatabase.bestiary_entry(&"mossback_surveyor_challenger")
	if not entry.get("recruitable", false) or String(entry.get("region", "")) != "Primeval Expanse":
		_fail("The bestiary does not identify the Surveyor as recruitable")
		return
	var loot := CampaignCombatDatabase.roll_loot(&"primeval_mossback_trial", RandomNumberGenerator.new())
	if loot.size() != 1 or StringName(loot[0].get("granted_action", &"")) != &"hearty_provisions":
		_fail("The Green Audit did not award its character-specific equipment ability")
		return

	if CampaignState.recruit_status.get(&"mossback_surveyor") == &"party":
		CampaignState.move_to_reserve(&"mossback_surveyor")
	if not CampaignState.assign_to_facility(&"mossback_surveyor", "Cafe"):
		_fail("The cultivation specialist could not staff a town facility")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The monster recruit state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.recruit_status.get(&"mossback_surveyor") != &"staffed":
		_fail("The Surveyor's facility role did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("MOSSBACK_SURVEYOR_RECRUIT_SMOKE_OK pack=preserved slices=144 scenario=green_audit field=animated battle=idle+attack+hit+victory+death bestiary=recruitable specialty=cultivation+logistics staffing=true save_load=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MOSSBACK_SURVEYOR_RECRUIT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
