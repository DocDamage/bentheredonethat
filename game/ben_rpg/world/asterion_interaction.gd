class_name AsterionInteraction
extends Interaction

@export var interaction_kind: StringName = &"medical_biocircuit"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"medical_biocircuit":
			events = _recover_biocircuit()
		&"hydroponics_console":
			events = _restart_hydroponics()
		&"cargo_cache":
			events = _open_cargo_cache()
		&"control_gate":
			events = _inspect_control_gate()
		&"save_beacon":
			events = _activate_save_beacon()
		_:
			events = ["The station console requests a form that has not existed for three centuries."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _recover_biocircuit() -> Array[String]:
	if not CampaignState.story_flags.get(&"asterion_medical_ambush_cleared", false):
		return ["The surgical cabinet is sealed while the medical robots classify Ben as an unauthorized historical contaminant."]
	if CampaignState.story_flags.get(&"asterion_biocircuit_found", false):
		return ["The cabinet is empty. Its label still reads: ORGANIC SYSTEMS — DO NOT WATER."]
	CampaignState.story_flags[&"asterion_biocircuit_found"] = true
	CampaignState.add_item(&"asterion_biocircuit", 1, false)
	return [
		"Ben extracts a living circuit from a refrigerated drawer. It pulses in time with the dead station's emergency lights.",
		"BEN: A vegetable persuaded to perform electrical engineering. I admire the efficiency.",
		"Quest item obtained: Asterion Biocircuit.",
	]


func _restart_hydroponics() -> Array[String]:
	if not CampaignState.story_flags.get(&"asterion_hydro_ambush_cleared", false):
		return ["Security drones are pruning everything that moves. The console will have to wait."]
	if CampaignState.story_flags.get(&"asterion_station_restored", false):
		return ["Hydroponics circulates clean air through the station. The control-deck lock reports: OXYGEN PRODUCTIVITY ACCEPTABLE."]
	if not CampaignState.story_flags.get(&"asterion_biocircuit_found", false):
		return ["The oxygen controller has an organic socket and a handwritten note: 'BIOCIRCUIT IN MEDICAL — unless Medical moved again.'"]
	CampaignState.consume_item(&"asterion_biocircuit", 1)
	CampaignState.story_flags[&"asterion_station_restored"] = true
	CampaignState.restore_party()
	return [
		"The biocircuit takes root in the controller. Vines flash blue as air floods the station's sealed decks.",
		"ASTRONAUT: Pressure stable. Control just unlocked—and the Mother Computer is filing an objection.",
		"The party's HP and MP are fully restored. Station Control is now accessible.",
	]


func _open_cargo_cache() -> Array[String]:
	var assist := CampaignState.claim_field_specialist_assist(&"asterion_cargo_override")
	if CampaignState.story_flags.get(&"asterion_cargo_opened", false):
		var revisited: Array[String] = ["The cargo locker now contains only a vacuum-rated coupon with no expiration date and no surviving retailer."]
		_append_assist(revisited, assist, "%s notices a sealed customs compartment behind the coupon rack.")
		return revisited
	if not bool(assist.get("available", false)):
		return [
			"The customs locker requests a certified orbital-navigation override. Ben's locksmithing is rejected for insufficient altitude.",
			CampaignState.field_specialist_hint(&"asterion_cargo_override"),
		]
	CampaignState.story_flags[&"asterion_cargo_opened"] = true
	CampaignState.add_item(&"tonic", 2, false)
	CampaignState.add_item(&"ether", 1, false)
	CampaignState.adjust_duckets(36, &"asterion_cache", &"asterion_medical", false)
	var events: Array[String] = [
		"%s's orbital credentials open the customs locker." % String(assist.get("name", "The specialist")),
		"Found 2 Tonics, a Leyden Ether, and 36 Duckets accepted by no known spaceport.",
	]
	_append_assist(events, assist, "%s notices a sealed customs compartment behind the coupon rack.")
	return events


func _append_assist(events: Array[String], assist: Dictionary, detail: String) -> void:
	if not bool(assist.get("granted", false)):
		return
	events.append(detail % String(assist.get("name", "A party specialist")))
	events.append(CampaignState.field_specialist_reward_text(assist))


func _inspect_control_gate() -> Array[String]:
	if CampaignState.story_flags.get(&"asterion_station_complete", false):
		return ["Station Control is quiet. The final shift has finally ended."]
	if not CampaignState.story_flags.get(&"asterion_station_restored", false):
		return ["CONTROL ACCESS DENIED: Current oxygen productivity is below mandatory overtime thresholds.", "BEN: We must repair Hydroponics before the station permits us to complain to management."]
	return ["CONTROL ACCESS GRANTED: Employee disciplinary hearing in progress.", "ASTRONAUT: That's us. Let's appeal directly to the motherboard."]


func _activate_save_beacon() -> Array[String]:
	CampaignState.activate_save_point(&"asterion_medical")
	return ["Ben tunes the emergency beacon to the laboratory's permanent frequency.", "The party's HP and MP are fully restored.", "Progress anchored at Asterion Medical."]
