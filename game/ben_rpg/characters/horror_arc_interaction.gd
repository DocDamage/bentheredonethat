extends Interaction

@export_enum("dracula", "frankenstein_monster") var witness_id := "dracula"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var flag := &"dracula_mansion_met" if witness_id == "dracula" else &"frankenstein_mansion_met"
	var events: Array[String] = []
	if not CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false):
		return ["The ballroom's witnesses cannot be reached until the 4:44 appointment is kept."]
	if not CampaignState.story_flags.get(flag, false):
		CampaignState.story_flags[flag] = true
		if witness_id == "dracula":
			events = [
			"DRACULA: You have loosened this house's hour. Its smoke is drifting toward a city that has already burned.",
			"LINCOLN: Then its survivors deserve an answer, not another sealed door.",
			"DRACULA: Ashfall keeps the names this Mansion tried to erase. I can lead you to the first wound.",
		]
		else:
			events = [
			"FRANKENSTEIN'S MONSTER: The fire ahead remembers every body it took. It must not be left alone with that memory.",
			"GANDHI: We will go where the suffering is, and we will not make a spectacle of it.",
			"BEN: Then Ashfall is an obligation of this company, not a diversion.",
		]
	else:
		events = ["DRACULA: Ashfall waits beyond the fault line. Its history will not heal by being filed away."] if witness_id == "dracula" else ["FRANKENSTEIN'S MONSTER: When the Ashfall door opens, I will meet you where the fire remembers."]
	if CampaignState.story_flags.get(&"dracula_mansion_met", false) and CampaignState.story_flags.get(&"frankenstein_mansion_met", false):
		CampaignState.story_flags[&"horror_arc_mansion_briefed"] = true
		CampaignState.story_flags[&"horror_arc_ashfall_required"] = true
		if events.size() > 0:
			events.append("The Mansion-to-Ashfall horror route is now recorded as mandatory main-campaign work.")
	CampaignState.sync_quests(false)
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
