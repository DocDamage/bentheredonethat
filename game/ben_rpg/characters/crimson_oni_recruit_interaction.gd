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
		battle.begin(&"moonpetal_crimson_oni_trial")


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"crimson_oni", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false) or int(CampaignState.inventory.get(&"crimson_challenge_seal", 0)) <= 0:
		events = ["A blood-red moon mark remains dormant. Its challenger has not yet found this world."]
	elif not CampaignState.story_flags.get(&"crimson_oni_met", false):
		CampaignState.story_flags[&"crimson_oni_met"] = true
		CampaignState.discover_recruit(&"crimson_oni")
		_pending_trial = true
		events = [
			"CRIMSON ONI: Enma's seal names the strongest witness in Moonpetal. You carry it. Therefore, you are either strong or a thief.",
			"BEN: I have been called both, though never by a prospective employee.",
			"CRIMSON ONI: Survive my Blood Moon Trial. Then we shall discuss which of us is hiring the other.",
			"Optional boss encounter: Crimson Oni, Blood-Moon Challenger.",
		]
	elif not CampaignState.story_flags.get(&"crimson_oni_trial_complete", false):
		_pending_trial = true
		events = ["CRIMSON ONI: The seal remains answered. Draw your formation and begin the interview again."]
	elif status == &"available":
		CampaignState.story_flags[&"crimson_oni_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"crimson_oni")
		var joined_party := CampaignState.add_to_party(&"crimson_oni")
		events = [
			"CRIMSON ONI: You did not merely endure. Your ridiculous lizard attempted to flank the moon itself.",
			"BEN: Initiative is difficult to teach. Payroll avoidance is considerably easier.",
			"The Crimson Oni joined Franklin & Company permanently as a duelist and security specialist.",
			("The Crimson Oni joined the active party." if joined_party else "The active party is full, so the Crimson Oni reported to reserve."),
		]
	elif status == &"party":
		events = ["CRIMSON ONI: Choose the next impossible opponent. I have already signed the waiver in blood."]
	elif status == &"staffed":
		events = ["CRIMSON ONI: Facility security is quiet. The last intruder reconsidered several life choices."]
	else:
		events = ["CRIMSON ONI: I will wait beside the Tea House until the formation requires a sharper argument."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
