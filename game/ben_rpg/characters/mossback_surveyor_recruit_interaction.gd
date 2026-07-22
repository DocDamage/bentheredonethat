extends Interaction

var battle: CampaignBattle
var _pending_trial := false


func _execute() -> void:
	_pending_trial = false
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	if _pending_trial and battle and not battle.active:
		battle.begin(&"primeval_mossback_trial")


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"mossback_surveyor", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"primeval_scenario_complete", false):
		events = ["A moss-covered survey stake vibrates in the soil, but its owner has not finished auditing the dinosaur emergency."]
	elif not CampaignState.story_flags.get(&"mossback_surveyor_met", false):
		CampaignState.story_flags[&"mossback_surveyor_met"] = true
		CampaignState.discover_recruit(&"mossback_surveyor")
		_pending_trial = true
		events = [
			"A broad green figure pulls itself out of the caldera soil, examines Ben's boots, and writes a violation on a bark tablet.",
			"MOSSBACK SURVEYOR: You stabilized traffic. Then you walked across protected moss without filing a lunch plan.",
			"BEN: I can explain the traffic, the moss, or the lunch. In which order would prevent a fine?",
			"MOSSBACK SURVEYOR: Field inspection. Five applicants, one unauthorized lizard, no appeals.",
			"Optional monster encounter: The Green Audit.",
		]
	elif not CampaignState.story_flags.get(&"mossback_surveyor_trial_complete", false):
		_pending_trial = true
		events = ["MOSSBACK SURVEYOR: Inspection remains open. Bring formation, appetite, and respect for load-bearing vegetables."]
	elif status == &"available":
		CampaignState.story_flags[&"mossback_surveyor_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"mossback_surveyor")
		var joined_party := CampaignState.add_to_party(&"mossback_surveyor")
		events = [
			"The Mossback Surveyor stamps Ben's employment ledger with a turnip cut precisely in half.",
			"MOSSBACK SURVEYOR: Town supply lines inefficient. Café pantry emotional. Farm rows disrespect drainage.",
			"BEN: You are hired before any of those conditions become a committee.",
			"The Mossback Surveyor joined Franklin & Company permanently as a cultivation and logistics specialist.",
			("The Surveyor joined the active party." if joined_party else "The active party is full, so the Surveyor reported to reserve."),
		]
	elif status == &"party":
		events = ["MOSSBACK SURVEYOR: Next universe receives a soil test, a supply route, and exactly one warning."]
	elif status == &"staffed":
		events = ["MOSSBACK SURVEYOR: Facility stores balanced. Spoilage cited. Lunch protected by ordinance."]
	else:
		events = ["The Mossback Surveyor waits near the Trailhead, revising New Philadelphia's definition of edible landscaping."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
