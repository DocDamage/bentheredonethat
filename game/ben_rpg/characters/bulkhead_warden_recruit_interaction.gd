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
		battle.begin(&"asterion_bulkhead_warden_trial")


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"bulkhead_warden", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"asterion_station_complete", false):
		events = ["A dormant bulkhead construct blocks the maintenance alcove. Its inspection lamp is dark, but pointedly so."]
	elif not CampaignState.story_flags.get(&"bulkhead_warden_met", false):
		CampaignState.story_flags[&"bulkhead_warden_met"] = true
		CampaignState.discover_recruit(&"bulkhead_warden")
		_pending_trial = true
		events = [
			"The construct's red inspection lamp opens. A brass plate reads BULKHEAD WARDEN — DOOR, WALL, AND ACTING SHOP STEWARD.",
			"BULKHEAD WARDEN: Station management is absent. By regulation, the nearest employer must demonstrate structural competence.",
			"BEN: I have founded a town directly atop a multiversal fault line. My competence is therefore either extraordinary or inadmissible.",
			"The velociraptor kicks one armored ankle and immediately pretends it was checking the rivets.",
			"Optional monster encounter: The Load-Bearing Interview.",
		]
	elif not CampaignState.story_flags.get(&"bulkhead_warden_trial_complete", false):
		_pending_trial = true
		events = ["BULKHEAD WARDEN: Structural interview remains incomplete. Please strike the load-bearing employee until morale improves."]
	elif status == &"available":
		CampaignState.story_flags[&"bulkhead_warden_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"bulkhead_warden")
		var joined_party := CampaignState.add_to_party(&"bulkhead_warden")
		events = [
			"The Bulkhead Warden stamps Ben's blueprints APPROVED WITH CONCERN in letters deep enough to dent the clipboard.",
			"BULKHEAD WARDEN: New Philadelphia meets the minimum requirement of continuing to exist while inspected.",
			"BEN: Excellent. You are now Superintendent of Things That Must Not Suddenly Become Doorways.",
			"The Bulkhead Warden joined Franklin & Company permanently as an engineering and security specialist.",
			("The Warden joined the active party." if joined_party else "The active party is full, so the Warden reported to reserve."),
		]
	elif status == &"party":
		events = ["BULKHEAD WARDEN: Formation load distributed. Catastrophic buckling remains within acceptable limits."]
	elif status == &"staffed":
		events = ["BULKHEAD WARDEN: Facility inspection active. Three shelves have been promoted to structural walls."]
	else:
		events = ["The Bulkhead Warden waits beside the Armory, judging every hinge in town by standards last revised in another universe."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
