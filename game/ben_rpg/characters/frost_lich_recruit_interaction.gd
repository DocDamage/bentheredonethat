extends Interaction


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"frost_lich_emperor", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"frosthold_gate_cleared", false):
		events = ["A crowned figure watches the Snow Gate collectors from behind several layers of plausible deniability."]
	elif not CampaignState.story_flags.get(&"frost_lich_met", false):
		CampaignState.story_flags[&"frost_lich_met"] = true
		CampaignState.discover_recruit(&"frost_lich_emperor")
		events = [
			"FROST LICH EMPEROR: At last—foreigners whose body heat has not yet been itemized.",
			"BEN: Benjamin Franklin. Inventor, printer, and habitual opponent of unreasonable taxation.",
			"FROST LICH EMPEROR: Excellent. Read the rune on the Crystal Causeway. Then invent me a constitutional loophole.",
		]
	elif not CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
		events = ["FROST LICH EMPEROR: Warm both seals. The Whiteout Auditor keeps the original ledger at my stolen throne."]
	elif status == &"available":
		CampaignState.story_flags[&"frost_lich_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"frost_lich_emperor")
		var joined_party := CampaignState.add_to_party(&"frost_lich_emperor")
		events = [
			"FROST LICH EMPEROR: My throne is restored, my subjects are warm, and my calendar is suddenly empty.",
			"BEN: Franklin & Company could use an expert in cold sorcery and occult research.",
			"The Frost Lich Emperor joined Franklin & Company permanently.",
			("The Frost Lich Emperor joined the active party." if joined_party else "The active party is full, so the Frost Lich Emperor reported to reserve."),
		]
	elif status == &"party":
		events = ["FROST LICH EMPEROR: Point me toward the next tyrant. I have discovered an appetite for administrative reform."]
	elif status == &"staffed":
		events = ["FROST LICH EMPEROR: Cold Storage is orderly. I have frozen the forms in alphabetical sequence."]
	else:
		events = ["FROST LICH EMPEROR: I shall wait in the Frozen Market. The town's climate is distressingly moderate."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
