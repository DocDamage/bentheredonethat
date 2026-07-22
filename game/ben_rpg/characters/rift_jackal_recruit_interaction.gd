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
		battle.begin(&"mansion_rift_jackal_trial")


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"rift_jackal", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false):
		events = ["Something large watches from the fault-line shimmer, but the Mansion's anchor is still too unstable to approach it."]
	elif not CampaignState.story_flags.get(&"rift_jackal_met", false):
		CampaignState.story_flags[&"rift_jackal_met"] = true
		CampaignState.discover_recruit(&"rift_jackal")
		_pending_trial = true
		events = [
			"The creature steps out of a tear in the wallpaper. It has a jackal's head, a soldier's coat, and absolutely no respect for load-bearing reality.",
			"BEN: I assume you are either an omen or an applicant.",
			"VELOCIRAPTOR: Rrrk.",
			"The Rift Jackal bows to the velociraptor, points at the party, and draws a claw across the air.",
			"Optional monster encounter: The Fault-Line Stray.",
		]
	elif not CampaignState.story_flags.get(&"rift_jackal_trial_complete", false):
		_pending_trial = true
		events = ["The Rift Jackal taps one claw against the floor. The employment test is still pending."]
	elif status == &"available":
		CampaignState.story_flags[&"rift_jackal_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"rift_jackal")
		var joined_party := CampaignState.add_to_party(&"rift_jackal")
		events = [
			"The Rift Jackal drops a splinter of the Mansion's broken threshold at Ben's feet.",
			"BEN: Excellent. Compensation is adventure, room, board, and an aggressively informal pension scheme.",
			"The Rift Jackal joined Franklin & Company permanently as a tracker and security specialist.",
			("The Rift Jackal joined the active party." if joined_party else "The active party is full, so the Rift Jackal reported to reserve."),
		]
	elif status == &"party":
		events = ["The Rift Jackal tests the air. Somewhere nearby, a doorway is lying about where it leads."]
	elif status == &"staffed":
		events = ["The Rift Jackal patrols the facility by scent, sound, and minor violations of geometry."]
	else:
		events = ["The Rift Jackal waits beside the Library, cataloguing impossible scents for later investigation."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
