extends Interaction


func _execute() -> void:
	var events: Array[String] = apply_interaction()
	var timeline := DialogicTimeline.new()
	timeline.events = events
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"astronaut", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"asterion_dock_cleared", false):
		events = ["ASTRONAUT: Helmet radio says the welcoming committee is still armed. Deal with the robots first."]
	elif not CampaignState.story_flags.get(&"asterion_astronaut_met", false):
		CampaignState.story_flags[&"asterion_astronaut_met"] = true
		CampaignState.discover_recruit(&"astronaut")
		events = [
			"The station's lone survivor lowers a well-used pulse pistol, but not very far.",
			"ASTRONAUT: I was salvaging Asterion when the Mother Computer promoted me to 'permanent night shift.'",
			"BEN: I recognize involuntary administration. It is among civilization's less charming inventions.",
			"ASTRONAUT: Restore oxygen, retire the computer, and I'll hear your employment pitch.",
		]
	elif not CampaignState.story_flags.get(&"asterion_station_complete", false):
		events = ["ASTRONAUT: Medical has the biocircuit. Hydroponics has the socket. Control has the machine that objects to both of us breathing."]
	elif status == &"available":
		CampaignState.hire_recruit(&"astronaut")
		var joined_party := CampaignState.add_to_party(&"astronaut")
		events = [
			"ASTRONAUT: A permanent company, unlimited adjacent-skill training, and a pet velociraptor?",
			"BEN: The velociraptor is not part of the benefits package. He has his own arrangement.",
			"The Astronaut joined Franklin & Company as a ranged-combat and navigation specialist.",
			("The Astronaut joined the active party." if joined_party else "The active party is full, so the Astronaut reported to reserve."),
		]
	elif status == &"party":
		events = ["ASTRONAUT: Route plotted. Sidearm charged. Try not to anchor us inside another bureaucracy."]
	elif status == &"staffed":
		events = ["ASTRONAUT: Observatory shift is stable. Put me back in the roster when you need a navigator."]
	else:
		events = ["ASTRONAUT: I'll wait at the town Observatory when you need me."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
