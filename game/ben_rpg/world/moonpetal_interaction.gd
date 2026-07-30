class_name MoonpetalInteraction
extends Interaction

@export var interaction_kind: StringName = &"vow_tablet"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"vow_tablet":
			events = _read_vow_tablet()
		&"garden_seal":
			events = _expose_garden_seal()
		&"palace_seal":
			events = _expose_palace_seal()
		&"save_lantern":
			CampaignState.activate_save_point(&"moonpetal_bell_walk")
			events = ["A stone lantern records the route and restores the party. Its flame remembers only what actually happened."]
		_:
			events = ["The reflected moon signs the same name twice."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _read_vow_tablet() -> Array[String]:
	if not CampaignState.story_flags.get(&"kitsune_empress_met", false):
		return ["OFFICIAL VOW: I HAVE ALWAYS REMEMBERED EXACTLY WHAT THE MAGISTRATE REMEMBERS FOR ME."]
	if CampaignState.story_flags.get(&"moonpetal_vow_clue_found", false):
		return ["The copied inscription reflects moonlight but casts no shadow beneath Ben's static-charged spectacles."]
	CampaignState.story_flags[&"moonpetal_vow_clue_found"] = true
	return [
		"KITSUNE EMPRESS: The words are perfect. That is how we know they are false.",
		"BEN: A charged lantern will make duplicated ink discharge half a heartbeat early.",
		"The Electrostatic Veracity Lantern can now be built in Ben's laboratory.",
	]


func _expose_garden_seal() -> Array[String]:
	if &"veracity_lantern" not in CampaignState.owned_inventions:
		return ["The first vow produces two identical reflections. Ordinary light cannot identify the counterfeit."]
	if CampaignState.story_flags.get(&"moonpetal_bell_walk_open", false):
		var revisited: Array[String] = ["Only the genuine vow remains. The Bell Walk route is open."]
		_append_memory_assist(revisited)
		return revisited
	CampaignState.story_flags[&"moonpetal_bell_walk_open"] = true
	var events: Array[String] = ["Ben's Lantern charges the copied memory. It flashes pink, apologizes in legal language, and dissolves. The Bell Walk opens."]
	_append_memory_assist(events)
	return events


func _append_memory_assist(events: Array[String]) -> void:
	var assist := CampaignState.claim_field_specialist_assist(&"moonpetal_memory_audit")
	if bool(assist.get("granted", false)):
		events.append("%s separates a genuine memory echo from the counterfeit before it evaporates." % String(assist.get("name", "A party specialist")))
		events.append(CampaignState.field_specialist_reward_text(assist))
	elif not bool(assist.get("claimed", false)):
		events.append(CampaignState.field_specialist_hint(&"moonpetal_memory_audit"))


func _expose_palace_seal() -> Array[String]:
	if not CampaignState.story_flags.get(&"moonpetal_bell_ambush_cleared", false):
		return ["A fox wedding procession circles the final vow. They appear committed to the ceremony and to violence."]
	if &"veracity_lantern" not in CampaignState.owned_inventions:
		return ["The final vow requires Ben's Electrostatic Veracity Lantern."]
	if CampaignState.story_flags.get(&"moonpetal_palace_open", false):
		return ["The Moon Palace remains open. Magistrate Enma is audibly revising his testimony."]
	CampaignState.story_flags[&"moonpetal_palace_open"] = true
	CampaignState.restore_party()
	return ["The Lantern exposes the last false vow. The counterfeit moon goes dark, the Moon Palace opens, and the party is restored."]
