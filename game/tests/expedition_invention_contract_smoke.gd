extends Node

const CLOCK_SCRIPT := preload("res://ben_rpg/world/mansion_clue_interaction.gd")
const CONTENT_VALIDATOR := preload("res://ben_rpg/core/content_validator.gd")


func _ready() -> void:
	CampaignState.setup_sandbox()
	var ben := CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	var contracts := CampaignState.EXPEDITION_TOOL_CONTRACTS
	assert(contracts.size() == 7, "The seven reusable world verbs must each have an expedition-tool contract.")
	for raw_invention_id in contracts:
		var invention_id := StringName(raw_invention_id)
		var contract: Dictionary = CampaignState.expedition_tool_contract(invention_id)
		assert(CampaignState.invention_category(invention_id) == &"expedition_tool", "%s should be classified as an expedition tool." % invention_id)
		assert(not String(contract.get("story_use", "")).is_empty() and not String(contract.get("optional_use", "")).is_empty() and not String(contract.get("town_use", "")).is_empty(), "%s must document story, optional, and town uses." % invention_id)
		var action_id := StringName(contract.get("battle_action", &""))
		assert(not CampaignCombatDatabase.action(action_id).is_empty(), "%s should have a valid combat action." % invention_id)
		assert(action_id in ben["actions"], "%s should grant Ben its combat action when owned." % invention_id)
		var job := _job_for(StringName(contract.get("town_job", &"")))
		assert(not job.is_empty(), "%s should name an existing town job." % invention_id)
		assert(CampaignState.job_supports_invention(String(job["facility"]), StringName(job["id"]), invention_id), "%s should accelerate its declared town job." % invention_id)
		var estimate: Dictionary
		if bool(job.get("ben_can_lead", false)):
			estimate = CampaignState.job_estimate(String(job["facility"]), StringName(job["id"]), true)
		else:
			CampaignState.facility_assignments[String(job["facility"])] = &"fighter"
			estimate = CampaignState.job_estimate(String(job["facility"]), StringName(job["id"]), true)
		assert(bool(estimate.get("allowed", false)) and bool(estimate.get("invention_active", false)), "%s should visibly improve its compatible town job." % invention_id)
		assert(invention_id in estimate.get("active_inventions", []), "%s should be named in the job's active invention readout." % invention_id)

	CampaignState.reset_new_game()
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	CampaignState.story_flags[&"mansion_clock_examined"] = true
	CampaignState.story_flags[&"mansion_ledger_found"] = true
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.owned_inventions.append(&"temporal_tuning_fork")
	var notes_before := int(CampaignState.inventory.get(&"research_notes", 0))
	var dust_before := int(CampaignState.inventory.get(&"anchor_dust", 0))
	var clock := CLOCK_SCRIPT.new() as MansionClueInteraction
	clock.clue_kind = &"clock"
	var secret_events := clock.set_clock_time(&"13:13", false)
	assert(CampaignState.story_flags.get(&"mansion_temporal_secret_found", false), "The Temporal Tuning Fork should unlock the Mansion's optional thirteenth-hour secret.")
	assert(int(CampaignState.inventory.get(&"research_notes", 0)) == notes_before + 1 and int(CampaignState.inventory.get(&"anchor_dust", 0)) == dust_before + 1, "The optional time secret should grant its authored field materials exactly once.")
	assert(secret_events.any(func(event: String) -> bool: return "Optional Mansion resonance" in event), "The time secret should identify its optional reward in-game.")
	clock.free()

	var errors := CONTENT_VALIDATOR.validate_all()
	assert(errors.is_empty(), "Expedition-tool validation failed: %s" % errors)
	print("EXPEDITION_INVENTION_CONTRACT_SMOKE_OK tools=7 uses=story+optional+battle+town temporal_secret=true")
	get_tree().quit(0)


func _job_for(job_id: StringName) -> Dictionary:
	for facility_name in CampaignState.FACILITY_DEFINITIONS:
		for raw_job in (CampaignState.FACILITY_DEFINITIONS[facility_name] as Dictionary).get("jobs", []):
			var job: Dictionary = raw_job.duplicate(true)
			if StringName(job.get("id", &"")) == job_id:
				job["facility"] = String(facility_name)
				return job
	return {}
