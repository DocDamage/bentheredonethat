class_name HeliosInteraction
extends Interaction

@export var interaction_kind: StringName = &"ordinance_terminal"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"ordinance_terminal":
			events = _read_ordinance()
		&"transit_node":
			events = _disable_transit_node()
		&"clinic_node":
			events = _disable_clinic_node()
		&"save_beacon":
			CampaignState.activate_save_point(&"helios_clinic")
			events = ["The Afterlight beacon restores the party and records a route back to the laboratory."]
		_:
			events = ["The terminal politely refuses to acknowledge that night has ever existed."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _read_ordinance() -> Array[String]:
	if not CampaignState.story_flags.get(&"helios_viper_met", false):
		return ["ORDINANCE 24/7: NIGHT IS A LEGACY FEATURE. Questions may be submitted during daylight hours."]
	if CampaignState.story_flags.get(&"helios_curfew_clue_found", false):
		return ["The ordinance exposes two synchronized daylight nodes: Transit and Recovery Clinic."]
	CampaignState.story_flags[&"helios_curfew_clue_found"] = true
	return [
		"NEON VIPER: There. Transit and the Clinic keep the fake sun phase-locked.",
		"BEN: Then we need not destroy their sun. We merely introduce it to alternating current.",
		"The Nocturnal Phase Inverter can now be built in Ben's laboratory.",
	]


func _disable_transit_node() -> Array[String]:
	if &"night_phase_inverter" not in CampaignState.owned_inventions:
		return ["The Transit node rejects ordinary tools and one strongly worded letter from Ben."]
	if CampaignState.story_flags.get(&"helios_transit_node_disabled", false):
		var revisited: Array[String] = ["The Transit node is dark. The trains are experiencing their first evening delay."]
		_append_transit_assist(revisited)
		return revisited
	CampaignState.story_flags[&"helios_transit_node_disabled"] = true
	_update_core_access()
	var events: Array[String] = ["Ben inverts the node. Half the Arcology sees stars for the first time and immediately files noise complaints."]
	_append_transit_assist(events)
	return events


func _append_transit_assist(events: Array[String]) -> void:
	var assist := CampaignState.claim_field_specialist_assist(&"helios_transit_override")
	if bool(assist.get("granted", false)):
		events.append("%s reroutes the node's security discharge into two intact Leyden cells." % String(assist.get("name", "A party specialist")))
		events.append(CampaignState.field_specialist_reward_text(assist))
	elif not bool(assist.get("claimed", false)):
		events.append(CampaignState.field_specialist_hint(&"helios_transit_override"))


func _disable_clinic_node() -> Array[String]:
	if not CampaignState.story_flags.get(&"helios_clinic_ambush_cleared", false):
		return ["The Clinic's security units prescribe several uninterrupted rounds of combat."]
	if CampaignState.story_flags.get(&"helios_clinic_node_disabled", false):
		return ["The Clinic node remains dark. Patients are being advised to try sleep."]
	CampaignState.story_flags[&"helios_clinic_node_disabled"] = true
	CampaignState.restore_party()
	_update_core_access()
	return ["The second node powers down. The party is fully restored as the Clinic accidentally rediscovers rest."]


func _update_core_access() -> void:
	if CampaignState.story_flags.get(&"helios_transit_node_disabled", false) and CampaignState.story_flags.get(&"helios_clinic_node_disabled", false):
		CampaignState.story_flags[&"helios_core_open"] = true
