extends Interaction


func _execute() -> void:
	var status: StringName = CampaignState.recruit_status.get(&"fighter", &"undiscovered")
	var events: Array[String]
	if status == &"available":
		events = [
			"A fighter waits beside the new Café, red gloves already laced.",
			"FIGHTER: You built a clinic before opening a portal. That's more planning than most employers manage.",
			"BEN: I am assembling a company for unusually literal field work.",
			"FIGHTER: Permanent position? No wages? Dangerous missions?",
			"BEN: There will be adjacent-skill training and excellent access to experimental medicine.",
			"The Fighter joined Ben's roster as a martial-combat specialist.",
		]
	elif status == &"party":
		events = ["FIGHTER: Gloves are on. Point me toward the problem."]
	elif status == &"staffed":
		events = ["FIGHTER: The facility is covered. Change my assignment at the laboratory when you need me in the field."]
	else:
		events = ["FIGHTER: I'll be here when you need another set of gloves."]

	var timeline := DialogicTimeline.new()
	timeline.events = events
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	if status == &"available":
		CampaignState.hire_recruit(&"fighter")
		CampaignState.add_to_party(&"fighter")
		CampaignState.save_game()
