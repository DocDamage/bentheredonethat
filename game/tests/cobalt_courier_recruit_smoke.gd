extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const TEST_SAVE := "user://cobalt_courier_recruit_smoke.json"
const SLICE_ROOT := "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Cobalt Courier"
const IDLE_FRAME := SLICE_ROOT + "/00_idle/frame_000.png"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.built_facilities[3] = "Afterlight Club"
	CampaignState.story_flags[&"helios_anchor_built"] = true
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	CampaignState.story_flags[&"fourth_universe_stabilized"] = true
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")

	var slice_count := 0
	var sequence_count := 0
	for folder in DirAccess.get_directories_at(SLICE_ROOT):
		sequence_count += 1
		for filename in DirAccess.get_files_at("%s/%s" % [SLICE_ROOT, folder]):
			if filename.ends_with(".png"):
				slice_count += 1
	if sequence_count != 18 or slice_count != 144 or not ResourceLoader.exists(IDLE_FRAME) or CampaignState.skill_tree(&"cobalt_courier").size() != 4:
		_fail("Sheet 07 was not preserved as 18 named states and 144 exact frames with a fixed skill tree")
		return
	var recruit: Dictionary = CampaignState.recruit_catalog.get(&"cobalt_courier", {})
	if String(recruit.get("asset_pack", "")) != "Topdown Monsters Part 1" or CampaignState.recruit_status.get(&"cobalt_courier") != &"undiscovered":
		_fail("The Cobalt Courier was not registered as an undiscovered pack-separated recruit")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	if not world.has_node("RecruitableCobaltCourier"):
		_fail("The Courier did not appear after Helios Arcology was stabilized")
		return
	var gamepiece: Gamepiece = world.get_node("RecruitableCobaltCourier")
	if gamepiece.animation == null or gamepiece.animation._sprite.scale.x > 0.95:
		_fail("The supplied monster was not animated at field-character scale")
		return
	var interaction = gamepiece.get_node("RecruitInteraction")
	var introduction: Array[String] = interaction.apply_interaction(false)
	if introduction.is_empty() or not CampaignState.story_flags.get(&"cobalt_courier_met", false) or CampaignState.recruit_status.get(&"cobalt_courier") != &"available":
		_fail("Meeting the Courier did not reveal the hidden parcel quest")
		return
	if StringName(CampaignState.quest_state(&"the_undeliverable_parcel").get("status", &"locked")) == &"locked":
		_fail("The hidden recruitment quest did not appear when its clue was discovered")
		return

	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	if not battle.begin(&"helios_cobalt_courier_trial", 1776):
		_fail("The optional parcel-verification battle would not start")
		return
	var enemy_animation := battle._actor_animation(&"cobalt_courier_challenger_0")
	if not enemy_animation or enemy_animation.current_sequence != &"idle" or battle._play_actor_action(&"cobalt_courier_challenger_0", &"express_jolt") <= 0.0 or enemy_animation.current_sequence != &"power":
		_fail("The supplied Courier frames did not drive idle and power animation")
		return
	battle._play_actor_once(&"cobalt_courier_challenger_0", &"hit")
	if enemy_animation.current_sequence != &"hit":
		_fail("The Courier did not expose its authored hit reaction")
		return
	battle._play_actor_loop(&"cobalt_courier_challenger_0", &"idle")
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"cobalt_courier_trial_complete", false) or int(CampaignState.bestiary_record(&"cobalt_courier_challenger").get("defeated", 0)) != 1:
		_fail("Winning the parcel trial did not unlock recruitment and record the defeat")
		return

	interaction.apply_interaction(false)
	if CampaignState.recruit_status.get(&"cobalt_courier") not in [&"party", &"reserve"]:
		_fail("The Cobalt Courier did not become a permanent recruit")
		return
	var progress: Dictionary = CampaignState.character_progress[&"cobalt_courier"]
	progress["skill_points"] = 2
	if not CampaignState.learn_skill(&"cobalt_courier", &"night_route") or not CampaignState.learn_skill(&"cobalt_courier", &"priority_delivery_training"):
		_fail("The Courier's adjacent combat training could not be learned")
		return
	var actor := CampaignCombatDatabase.party_actor(&"cobalt_courier", progress)
	if &"cobalt_claw" not in actor.get("actions", []) or &"express_jolt" not in actor.get("actions", []) or &"priority_delivery" not in actor.get("actions", []) or String(actor.get("sprite_path", "")) != IDLE_FRAME:
		_fail("The recruited Courier lost its authored combat identity or learned command")
		return
	if PRESENTATION.effect_frames(&"priority_delivery").size() != 30 or PRESENTATION.action_sound(&"express_jolt").is_empty():
		_fail("The Courier's commands lack supplied VFX or SFX presentation")
		return
	var entry := CampaignCombatDatabase.bestiary_entry(&"cobalt_courier_challenger")
	if not entry.get("recruitable", false) or String(entry.get("region", "")) != "Helios Arcology":
		_fail("The bestiary does not identify the Courier as recruitable")
		return
	var loot := CampaignCombatDatabase.roll_loot(&"helios_cobalt_courier_trial", RandomNumberGenerator.new())
	if loot.size() != 1 or StringName(loot[0].get("granted_action", &"")) != &"priority_delivery" or &"cobalt_courier" not in loot[0].get("allowed_characters", []):
		_fail("The parcel trial did not award its character-specific equipment ability")
		return

	if CampaignState.recruit_status.get(&"cobalt_courier") == &"party":
		CampaignState.move_to_reserve(&"cobalt_courier")
	if not CampaignState.assign_to_facility(&"cobalt_courier", "Afterlight Club"):
		_fail("The navigation and logistics specialist could not staff a town facility")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The Cobalt Courier state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.recruit_status.get(&"cobalt_courier") != &"staffed":
		_fail("The Courier's facility role did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("COBALT_COURIER_RECRUIT_SMOKE_OK source=07 pack=preserved slices=144 states=18 quest=undeliverable_parcel field=animated battle=idle+power+hit+victory+death bestiary=38+recruitable specialty=navigation+logistics skill_tree=true staffing=true save_load=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("COBALT_COURIER_RECRUIT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
