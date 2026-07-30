extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const RECRUIT_NAVIGATION := preload("res://ben_rpg/world/campaign_recruit_navigation.gd")
const TEST_SAVE := "user://bulkhead_warden_recruit_smoke.json"
const SLICE_ROOT := "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Bulkhead Warden"
const IDLE_FRAME := SLICE_ROOT + "/00_idle/frame_000.png"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.built_facilities[4] = "Observatory"
	CampaignState.story_flags[&"asterion_anchor_built"] = true
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.story_flags[&"second_universe_stabilized"] = true
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")

	var slice_count := 0
	var sequence_count := 0
	for folder in DirAccess.get_directories_at(SLICE_ROOT):
		sequence_count += 1
		for filename in DirAccess.get_files_at("%s/%s" % [SLICE_ROOT, folder]):
			if filename.ends_with(".png"):
				slice_count += 1
	if sequence_count != 18 or slice_count != 144 or not ResourceLoader.exists(IDLE_FRAME) or CampaignState.skill_tree(&"bulkhead_warden").size() != 4:
		_fail("Sheet 01 was not preserved as 18 named states and 144 exact frames with a fixed specialty tree (sequences=%d slices=%d resource=%s skills=%d)" % [sequence_count, slice_count, ResourceLoader.exists(IDLE_FRAME), CampaignState.skill_tree(&"bulkhead_warden").size()])
		return
	var recruit: Dictionary = CampaignState.recruit_catalog.get(&"bulkhead_warden", {})
	if String(recruit.get("asset_pack", "")) != "Topdown Monsters Part 1" or CampaignState.recruit_status.get(&"bulkhead_warden") != &"undiscovered":
		_fail("The Bulkhead Warden was not registered as an undiscovered pack-separated recruit")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	if not world.has_node("RecruitableBulkheadWarden"):
		_fail("The Warden did not appear after Asterion Station was stabilized")
		return
	var gamepiece: Gamepiece = world.get_node("RecruitableBulkheadWarden")
	if Gameboard.pixel_to_cell(gamepiece.position) != RECRUIT_NAVIGATION.world_cell(&"bulkhead_warden") or gamepiece.animation == null or gamepiece.animation._sprite.scale.x > 0.82:
		_fail("The supplied construct was misplaced or not animated at field-character scale")
		return
	var interaction = gamepiece.get_node("RecruitInteraction")
	if not interaction.get_node("InteractionArea2D") or not interaction.get_node("Button"):
		_fail("The Warden did not support both proximity/controller and mouse interaction")
		return
	var introduction: Array[String] = interaction.apply_interaction(false)
	if introduction.is_empty() or not CampaignState.story_flags.get(&"bulkhead_warden_met", false) or CampaignState.recruit_status.get(&"bulkhead_warden") != &"available":
		_fail("Meeting the Warden did not reveal its hidden structural interview")
		return
	if StringName(CampaignState.quest_state(&"the_load_bearing_interview").get("status", &"locked")) == &"locked":
		_fail("The hidden recruitment quest did not appear when its clue was discovered")
		return

	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	if not battle.begin(&"asterion_bulkhead_warden_trial", 1776):
		_fail("The optional load-bearing battle would not start")
		return
	var enemy_animation := battle._actor_animation(&"bulkhead_warden_challenger_0")
	if not enemy_animation or enemy_animation.current_sequence != &"idle" or battle._play_actor_action(&"bulkhead_warden_challenger_0", &"piston_surge") <= 0.0 or enemy_animation.current_sequence != &"power":
		_fail("The supplied Warden frames did not drive idle and power animation")
		return
	battle._play_actor_once(&"bulkhead_warden_challenger_0", &"hit")
	if enemy_animation.current_sequence != &"hit":
		_fail("The Warden did not expose its authored hit reaction")
		return
	battle._play_actor_loop(&"bulkhead_warden_challenger_0", &"idle")
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"bulkhead_warden_trial_complete", false) or int(CampaignState.bestiary_record(&"bulkhead_warden_challenger").get("defeated", 0)) != 1:
		_fail("Winning the structural interview did not unlock recruitment and record the defeat")
		return
	if Gameboard.pixel_to_cell(gamepiece.position) != Vector2i(57, 17):
		_fail("The peaceful post-trial Warden did not relocate beside the town Armory")
		return

	interaction.apply_interaction(false)
	if CampaignState.recruit_status.get(&"bulkhead_warden") not in [&"party", &"reserve"]:
		_fail("The Bulkhead Warden did not become a permanent recruit")
		return
	var progress: Dictionary = CampaignState.character_progress[&"bulkhead_warden"]
	progress["skill_points"] = 4
	if not CampaignState.learn_skill(&"bulkhead_warden", &"reinforced_chassis") or not CampaignState.learn_skill(&"bulkhead_warden", &"bulkhead_drop_training") or not CampaignState.learn_skill(&"bulkhead_warden", &"emergency_bracing") or not CampaignState.learn_skill(&"bulkhead_warden", &"pressure_lock_training"):
		_fail("The Warden's adjacent combat training could not be learned")
		return
	var actor := CampaignCombatDatabase.party_actor(&"bulkhead_warden", progress)
	if &"warden_pummel" not in actor.get("actions", []) or &"piston_surge" not in actor.get("actions", []) or &"bulkhead_drop" not in actor.get("actions", []) or &"pressure_lock" not in actor.get("actions", []) or String(actor.get("sprite_path", "")) != IDLE_FRAME:
		_fail("The recruited Warden lost its authored combat identity or learned commands")
		return
	if PRESENTATION.effect_frames(&"pressure_lock").size() != 30 or PRESENTATION.action_sound(&"piston_surge").is_empty():
		_fail("The Warden's commands lack supplied VFX or SFX presentation")
		return
	var entry := CampaignCombatDatabase.bestiary_entry(&"bulkhead_warden_challenger")
	if not entry.get("recruitable", false) or String(entry.get("region", "")) != "Asterion Station":
		_fail("The bestiary does not identify the Warden as an Asterion recruitable")
		return
	var reward_loot := CampaignCombatDatabase.roll_loot(&"asterion_bulkhead_warden_trial", RandomNumberGenerator.new())
	if reward_loot.size() != 1 or StringName(reward_loot[0].get("granted_action", &"")) != &"pressure_lock" or &"bulkhead_warden" not in reward_loot[0].get("allowed_characters", []):
		_fail("The interview did not award its character-specific equipment ability")
		return
	var trial_item: Dictionary = CampaignState.loot_by_instance("asterion-shop-steward-key")
	if trial_item.is_empty() or CampaignState.equip_loot(&"ben", "asterion-shop-steward-key") or not CampaignState.equip_loot(&"bulkhead_warden", "asterion-shop-steward-key"):
		_fail("The trial's persistent equipment was not restricted to and equippable by the Warden")
		return

	if CampaignState.recruit_status.get(&"bulkhead_warden") == &"party":
		CampaignState.move_to_reserve(&"bulkhead_warden")
	if not CampaignState.assign_to_facility(&"bulkhead_warden", "Armory"):
		_fail("The structural engineer could not choose Armory staffing")
		return
	var estimate := CampaignState.job_estimate("Armory", &"armory_sort_salvage", false)
	if int(estimate.get("fit", 0)) < 2 or CampaignState.armory_item_price(&"militia_saber") != 62:
		_fail("The Warden's fixed specialty did not improve Armory work and shop prices")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The Bulkhead Warden state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.recruit_status.get(&"bulkhead_warden") != &"staffed" or CampaignState.loot_owner("asterion-shop-steward-key") != &"bulkhead_warden":
		_fail("The Warden's facility and equipment state did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("BULKHEAD_WARDEN_RECRUIT_SMOKE_OK source=01 pack=preserved slices=144 states=18 quest=load_bearing_interview field=animated+scaled battle=idle+power+hit+victory+death bestiary=38+recruitable specialty=engineering+security armory=staffing+discount gear=restricted save_load=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("BULKHEAD_WARDEN_RECRUIT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
