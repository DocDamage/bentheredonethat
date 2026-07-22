extends Node

const TEST_SAVE := "user://campaign_ending_smoke.json"
const ENDING_OVERLAY := preload("res://ben_rpg/ui/campaign_ending_overlay.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"empyreal_scenario_complete"] = true
	assert(CampaignState.commit_campaign_ending_result(), "Empyreal victory should commit one authored ending transaction.")
	assert(not CampaignState.commit_campaign_ending_result(), "The ending transaction must be idempotent.")
	var ending := CampaignState.campaign_ending_state()
	assert(bool(ending.get("needs_presentation", false)), "A saved final-boss victory should resume at the epilogue until the credits are seen.")

	var overlay := ENDING_OVERLAY.new()
	get_tree().root.add_child(overlay)
	await get_tree().process_frame
	overlay.present()
	assert(overlay.visible and overlay.page_count() == 4, "The ending must present a four-page authored epilogue and credits sequence.")
	for _page in range(4):
		overlay.advance()
	await get_tree().process_frame
	assert(not is_instance_valid(overlay), "The final credits action should yield control to the postgame transition.")

	assert(CampaignState.complete_campaign_ending(Vector2i(50, 8)), "Completing credits should create the one-time postgame save marker.")
	assert(not CampaignState.complete_campaign_ending(Vector2i(50, 8)), "Reloading or reopening credits must not replay the final transaction.")
	ending = CampaignState.campaign_ending_state()
	assert(bool(ending.get("credits_seen", false)) and bool(ending.get("postgame_unlocked", false)) and bool(ending.get("final_save_marked", false)), "Credits, postgame, and final-save state should all be persisted together.")
	assert(CampaignState.last_save_cell == Vector2i(50, 8) and CampaignState.last_location == "New Philadelphia", "Postgame should return the final save to the town free-roam location.")

	var rematch_model := AtbBattleModel.new()
	rematch_model.setup(&"empyreal_high_comptroller", CampaignState.party, CampaignState.character_progress, 7)
	var rematch_rewards := rematch_model.rewards()
	assert(int(rematch_rewards.get("experience", -1)) == 0 and int(rematch_rewards.get("duckets", -1)) == 0 and (rematch_rewards.get("loot", []) as Array).is_empty(), "Postgame Tribunal rematches must not repeat finale rewards.")

	assert(CampaignState.save_game(TEST_SAVE) == OK, "The completed ending state should save.")
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK, "The completed ending state should reload.")
	ending = CampaignState.campaign_ending_state()
	assert(bool(ending.get("postgame_unlocked", false)) and bool(ending.get("final_save_marked", false)) and not bool(ending.get("needs_presentation", false)), "A loaded postgame save should remain in free roam without replaying credits.")
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	print("CAMPAIGN_ENDING_SMOKE_OK ending=authored credits=true final_save=true free_roam=true rematch_rewards=false")
	get_tree().quit(0)
