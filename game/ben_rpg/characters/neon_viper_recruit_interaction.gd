extends Interaction


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"neon_viper", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"helios_skybridge_cleared", false):
		events = ["A figure in neon watches the Skybridge inspection from a safely deniable distance."]
	elif not CampaignState.story_flags.get(&"helios_viper_met", false):
		CampaignState.story_flags[&"helios_viper_met"] = true
		CampaignState.discover_recruit(&"neon_viper")
		events = [
			"NEON VIPER: You fought the daylight patrol in broad daylight. Subtle.",
			"BEN: I have never found daylight especially conducive to secrecy.",
			"NEON VIPER: Read the ordinance terminal. Help me return midnight, then we can discuss employment.",
		]
	elif not CampaignState.story_flags.get(&"helios_scenario_complete", false):
		events = ["NEON VIPER: Two nodes. Transit and Clinic. Then the Civic Sun loses its audience."]
	elif status == &"available":
		CampaignState.story_flags[&"neon_viper_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"neon_viper")
		var joined_party := CampaignState.add_to_party(&"neon_viper")
		events = [
			"NEON VIPER: Your company offers impossible doors, a laboratory, and no wages?",
			"BEN: We do offer unusually flexible scheduling.",
			"Neon Viper joined Franklin & Company as an infiltration and engineering specialist.",
			("Neon Viper joined the active party." if joined_party else "The active party is full, so Neon Viper reported to reserve."),
		]
	elif status == &"party":
		events = ["NEON VIPER: Point me at the next locked system. Or the next person who designed one."]
	elif status == &"staffed":
		events = ["NEON VIPER: The Afterlight signal is clean. The guest list is not."]
	else:
		events = ["NEON VIPER: I'll keep a back door open from the Afterlight Club."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events

