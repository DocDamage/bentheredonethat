extends Interaction


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"caveman", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"primeval_grove_cleared", false):
		events = ["CAVEMAN: Intersection closed. Lizards have right of way. Lizards always claim right of way."]
	elif not CampaignState.story_flags.get(&"primeval_caveman_met", false):
		CampaignState.story_flags[&"primeval_caveman_met"] = true
		CampaignState.discover_recruit(&"caveman")
		events = [
			"A municipal maintainer studies Ben, the velociraptor, and a stone clipboard in that order.",
			"CAVEMAN: I keep traffic moving. Sky alarm makes dinosaurs commute to one place. Bad planning.",
			"BEN: At last, a public servant who summarizes the problem before forming a committee.",
			"CAVEMAN: Fix sky alarm. Then talk job.",
		]
	elif not CampaignState.story_flags.get(&"primeval_scenario_complete", false):
		events = ["CAVEMAN: Read signal. Wake cave computer. Reset egg relay. Hit anything that rejects permit."]
	elif status == &"available":
		CampaignState.story_flags[&"caveman_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"caveman")
		var joined_party := CampaignState.add_to_party(&"caveman")
		events = [
			"CAVEMAN: Town has roads? Farms? Problems solved by club?",
			"BEN: In varying proportions, yes.",
			"The Caveman joined Franklin & Company as a survival and brute-force specialist.",
			("The Caveman joined the active party." if joined_party else "The active party is full, so the Caveman reported to reserve."),
		]
	elif status == &"party":
		events = ["CAVEMAN: Club ready. Traffic law optional outside borough."]
	elif status == &"staffed":
		events = ["CAVEMAN: Trailhead shift good. Fewer dinosaurs ignore signs now."]
	else:
		events = ["CAVEMAN: Find me at Trailhead when company needs old solutions."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
