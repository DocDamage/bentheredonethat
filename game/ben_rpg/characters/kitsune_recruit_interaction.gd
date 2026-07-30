extends Interaction


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"kitsune_empress", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"moonpetal_gate_cleared", false):
		events = ["A nine-tailed sovereign watches the inspectors stamp identical memories into identical forms."]
	elif not CampaignState.story_flags.get(&"kitsune_empress_met", false):
		CampaignState.story_flags[&"kitsune_empress_met"] = true
		CampaignState.discover_recruit(&"kitsune_empress")
		events = [
			"KITSUNE EMPRESS: Magistrate Enma replaced my people's vows with flawless copies. He calls the originals clerical errors.",
			"BEN: Counterfeits generally dislike electricity, scrutiny, and newspapers. I can provide all three.",
			"KITSUNE EMPRESS: Read the duplicated vow in the Mirror Garden. Give its false moon a machine-made shadow.",
		]
	elif not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
		events = ["KITSUNE EMPRESS: Expose both false vows. Enma keeps the original memory ledger inside the Moon Palace."]
	elif status == &"available":
		CampaignState.story_flags[&"kitsune_empress_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"kitsune_empress")
		var joined_party := CampaignState.add_to_party(&"kitsune_empress")
		events = [
			"KITSUNE EMPRESS: Moonpetal remembers itself again. I would like to see which of your worlds still require persuasion.",
			"BEN: Franklin & Company has openings for illusion, diplomacy, and tactful foxfire.",
			"The Kitsune Empress joined Franklin & Company permanently.",
			("The Kitsune Empress joined the active party." if joined_party else "The active party is full, so the Kitsune Empress reported to reserve."),
		]
	elif status == &"party":
		events = ["KITSUNE EMPRESS: A true promise casts one shadow. Let us inspect the next universe."]
	elif status == &"staffed":
		events = ["KITSUNE EMPRESS: The Tea House is calm. Three diplomats have confessed before the water boiled."]
	else:
		events = ["KITSUNE EMPRESS: I shall wait in Blossom Court until the company has room."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
