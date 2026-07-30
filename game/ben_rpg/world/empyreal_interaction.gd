class_name EmpyrealInteraction
extends Interaction

@export var interaction_kind: StringName = &"gravity_ordinance"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"gravity_ordinance":
			events = _read_gravity_ordinance()
		&"aerie_seal":
			events = _rebalance_aerie_seal()
		&"tribunal_seal":
			events = _rebalance_tribunal_seal()
		&"save_fountain":
			CampaignState.activate_save_point(&"empyreal_aerie")
			events = ["The Aerie crystal records the route, restores the party, and stamps the expedition RECEIVED IN GOOD ORDER."]
		_:
			events = ["A marble plaque insists that falling is a subscription service."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _read_gravity_ordinance() -> Array[String]:
	if not CampaignState.story_flags.get(&"archangel_commander_met", false):
		return ["ORDINANCE 9-G: All weight, lift, descent, and hovering remain property of the Empyreal Treasury."]
	if CampaignState.story_flags.get(&"empyreal_gravity_clue_found", false):
		return ["The ordinance meters gravity through a celestial current. Ben's copper standard could provide a stubbornly terrestrial counterweight."]
	CampaignState.story_flags[&"empyreal_gravity_clue_found"] = true
	return [
		"ARCHANGEL COMMANDER: The Comptroller has made every wing a debtor and every falling stone a customer.",
		"BEN: Gravity is too useful a public service to leave entirely to management.",
		"The Galvanic Counterweight can now be built in Ben's laboratory.",
	]


func _rebalance_aerie_seal() -> Array[String]:
	if &"galvanic_counterweight" not in CampaignState.owned_inventions:
		return ["The lift demands a certified weight, a divine signature, and three fees payable while airborne."]
	if CampaignState.story_flags.get(&"empyreal_aerie_open", false):
		var revisited: Array[String] = ["The Counterweight holds the Reliquary route level with Pennsylvania."]
		_append_weight_assist(revisited)
		return revisited
	CampaignState.story_flags[&"empyreal_aerie_open"] = true
	var events: Array[String] = ["Ben clips the Galvanic Counterweight to the seal. The lift remembers that down is a direction, not a premium feature. The Reliquary Aerie opens."]
	_append_weight_assist(events)
	return events


func _append_weight_assist(events: Array[String]) -> void:
	var assist := CampaignState.claim_field_specialist_assist(&"empyreal_weight_appeal")
	if bool(assist.get("granted", false)):
		events.append("%s files a counter-appeal and recovers the party's confiscated emergency fund." % String(assist.get("name", "A party specialist")))
		events.append(CampaignState.field_specialist_reward_text(assist))
	elif not bool(assist.get("claimed", false)):
		events.append(CampaignState.field_specialist_hint(&"empyreal_weight_appeal"))


func _rebalance_tribunal_seal() -> Array[String]:
	if not CampaignState.story_flags.get(&"empyreal_aerie_ambush_cleared", false):
		return ["The final seal is guarded by a repossession detail carrying nets labeled FOR WINGS."]
	if &"galvanic_counterweight" not in CampaignState.owned_inventions:
		return ["The tribunal route requires Ben's Galvanic Counterweight."]
	if CampaignState.story_flags.get(&"empyreal_tribunal_open", false):
		return ["The Seraph Tribunal remains open. Thunder is filling out an incident report."]
	CampaignState.story_flags[&"empyreal_tribunal_open"] = true
	CampaignState.restore_party()
	return ["The Counterweight grounds the last divine lien. The Seraph Tribunal descends into reach, and the party is restored."]
