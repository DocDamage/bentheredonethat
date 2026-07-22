extends Interaction


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"archangel_commander", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"empyreal_landing_cleared", false):
		events = ["A winged commander watches the weigh-station patrol repossess a cloud."]
	elif not CampaignState.story_flags.get(&"archangel_commander_met", false):
		CampaignState.story_flags[&"archangel_commander_met"] = true
		CampaignState.discover_recruit(&"archangel_commander")
		events = [
			"ARCHANGEL COMMANDER: The High Comptroller has mortgaged the sky. Every wingbeat now incurs compound interest.",
			"BEN: I have opposed worse taxes, though few were levied vertically.",
			"ARCHANGEL COMMANDER: Read Ordinance 9-G in the Forum. Give its gravity a standard outside the Court's control.",
		]
	elif not CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
		events = ["ARCHANGEL COMMANDER: Ground both gravity seals. The High Comptroller keeps Heaven's original charter inside the Tribunal."]
	elif status == &"available":
		CampaignState.story_flags[&"archangel_commander_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"archangel_commander")
		var joined_party := CampaignState.add_to_party(&"archangel_commander")
		events = [
			"ARCHANGEL COMMANDER: Heaven has its charter back. Franklin & Company appears to need a field commander with air superiority.",
			"BEN: The position also includes occasional library duty and no wages whatsoever.",
			"The Archangel Commander joined Franklin & Company permanently.",
			("The Archangel Commander joined the active party." if joined_party else "The active party is full, so the Archangel Commander reported to reserve."),
		]
	elif status == &"party":
		events = ["ARCHANGEL COMMANDER: Formation ready. Gravity is optional; discipline is not."]
	elif status == &"staffed":
		events = ["ARCHANGEL COMMANDER: The Belfry watch is secure. Two storms have submitted corrected paperwork."]
	else:
		events = ["ARCHANGEL COMMANDER: I will hold the Garden until the company has room."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
