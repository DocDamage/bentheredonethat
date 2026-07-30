extends Interaction

const TRIALS := {
	&"abe_lincoln": {
		"name": "Abraham Lincoln", "prerequisite": &"mansion_archive_boss_defeated", "encounter": &"rift_exhibition_lincoln_trial",
		"met": &"abe_lincoln_met", "trial_complete": &"abe_lincoln_trial_complete", "unlocked": &"abe_lincoln_recruit_unlocked",
		"intro": ["LINCOLN: A divided timeline cannot stand. Let us see whether your company can hold a formation together.", "BEN: A practical debate, then. I warn you that our velociraptor is a poor parliamentarian.", "Optional Rift Exhibition: The Union Line."],
		"retry": "LINCOLN: The field remains open. Assemble your company when you are ready.",
		"hire": "Abraham Lincoln joined Franklin & Company as a leader and logistics specialist.",
	},
	&"cthulhu": {
		"name": "Cthulhu", "prerequisite": &"asterion_station_complete", "encounter": &"rift_exhibition_cthulhu_trial",
		"met": &"cthulhu_met", "trial_complete": &"cthulhu_trial_complete", "unlocked": &"cthulhu_recruit_unlocked",
		"intro": ["A pressureless ocean opens above the plaza. Something ancient regards the company with unsettling professional interest.", "BEN: Tentacles are not disqualifying. Unscheduled apocalypse is.", "Optional Rift Exhibition: The Dreaming Deep."],
		"retry": "The stars are almost right. Fortunately, the exhibition schedule is flexible.",
		"hire": "Cthulhu joined Franklin & Company as an occult researcher and navigator.",
	},
	&"dark_mage": {
		"name": "Dark Mage", "prerequisite": &"moonpetal_scenario_complete", "encounter": &"rift_exhibition_dark_mage_trial",
		"met": &"dark_mage_met", "trial_complete": &"dark_mage_trial_complete", "unlocked": &"dark_mage_recruit_unlocked",
		"intro": ["DARK MAGE: Your laboratory leaks lightning into seven schools of magic. I have come to grade the eighth.", "BEN: At last, an academic review with honest robes.", "Optional Rift Exhibition: The Eighth Lesson."],
		"retry": "DARK MAGE: The examination remains incomplete. Bring sharper pencils and stronger wards.",
		"hire": "The Dark Mage joined Franklin & Company as an arcane researcher and inventor.",
	},
	&"dracula": {
		"name": "Dracula", "prerequisite": &"mansion_archive_boss_defeated", "encounter": &"rift_exhibition_dracula_trial",
		"met": &"dracula_met", "trial_complete": &"dracula_trial_complete", "unlocked": &"dracula_recruit_unlocked",
		"intro": ["DRACULA: Your haunted house has no master, your town has no night watch, and your hospitality is aggressively colonial.", "BEN: You may challenge the first two. The third is a period feature.", "Optional Rift Exhibition: Midnight Arbitration."],
		"retry": "DRACULA: Midnight is patient. Your formation may try again.",
		"hire": "Dracula joined Franklin & Company for night operations and diplomacy.",
	},
	&"frankenstein": {
		"name": "Frankenstein's Monster", "prerequisite": &"mansion_archive_boss_defeated", "encounter": &"rift_exhibition_frankenstein_trial",
		"met": &"frankenstein_met", "trial_complete": &"frankenstein_trial_complete", "unlocked": &"frankenstein_recruit_unlocked",
		"intro": ["The visitor studies Ben's coils, then gently corrects three dangerous connections with one enormous finger.", "BEN: Engineering competence and dramatic entrance. You understand our hiring rubric perfectly.", "Optional Rift Exhibition: Galvanic Second Opinion."],
		"retry": "The Monster points toward the grounded arena and waits for a safer load test.",
		"hire": "Frankenstein's Monster joined Franklin & Company as an engineer and frontline guardian.",
	},
	&"gandhi": {
		"name": "Mahatma Gandhi", "prerequisite": &"empyreal_scenario_complete", "encounter": &"rift_exhibition_gandhi_trial",
		"met": &"gandhi_met", "trial_complete": &"gandhi_trial_complete", "unlocked": &"gandhi_recruit_unlocked",
		"intro": ["GANDHI: Power that cannot be restrained is only another kind of prison. Show me that your company can prevail without losing its purpose.", "BEN: A trial of resolve, then—not conquest.", "Optional Rift Exhibition: The Unshakable March."],
		"retry": "GANDHI: Resolve is practiced more than once. The road remains before us.",
		"hire": "Mahatma Gandhi joined Franklin & Company as a diplomat and logistics specialist.",
	},
}

@export var recruit_id: StringName
var battle: CampaignBattle
var _pending_trial := false


func _execute() -> void:
	_pending_trial = false
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	var trial: Dictionary = TRIALS.get(recruit_id, {})
	if _pending_trial and battle and not battle.active and not trial.is_empty():
		battle.begin(StringName(trial.get("encounter", &"")))


func apply_interaction(save_after := true) -> Array[String]:
	var trial: Dictionary = TRIALS.get(recruit_id, {})
	if trial.is_empty():
		return ["This recruit's Rift Exhibition record is missing."]
	var status: StringName = CampaignState.recruit_status.get(recruit_id, &"undiscovered")
	var events: Array[String] = []
	if not CampaignState.story_flags.get(StringName(trial.get("prerequisite", &"")), false):
		events = ["The Rift Exhibition placard is blank. This visitor has not reached New Philadelphia yet."]
	elif not CampaignState.story_flags.get(StringName(trial.get("met", &"")), false):
		CampaignState.story_flags[StringName(trial.get("met", &""))] = true
		CampaignState.discover_recruit(recruit_id)
		_pending_trial = true
		for line in trial.get("intro", []):
			events.append(String(line))
	elif not CampaignState.story_flags.get(StringName(trial.get("trial_complete", &"")), false):
		_pending_trial = true
		events = [String(trial.get("retry", "The optional trial remains available."))]
	elif status == &"available":
		CampaignState.story_flags[StringName(trial.get("unlocked", &""))] = true
		CampaignState.hire_recruit(recruit_id)
		var joined_party := CampaignState.add_to_party(recruit_id)
		events = [
			String(trial.get("hire", "A new specialist joined Franklin & Company.")),
			("They joined the active party." if joined_party else "The active party is full, so they reported to reserve."),
		]
	elif status == &"party":
		events = ["%s is ready for the next expedition." % String(trial.get("name", "The recruit"))]
	elif status == &"staffed":
		events = ["%s is on facility duty and reports that the shift is proceeding normally." % String(trial.get("name", "The recruit"))]
	else:
		events = ["%s waits beside the Rift Exhibition for a place in the formation." % String(trial.get("name", "The recruit"))]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
