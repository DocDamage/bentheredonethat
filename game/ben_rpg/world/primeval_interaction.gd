class_name PrimevalInteraction
extends Interaction

@export var interaction_kind: StringName = &"traffic_totem"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"traffic_totem":
			events = _inspect_traffic_totem()
		&"cave_terminal":
			events = _decode_cave_terminal()
		&"relay_nest":
			events = _reset_relay_nest()
		&"anchor_totem":
			events = _activate_anchor_totem()
		_:
			events = ["The stone device predates both instructions and liability waivers."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _inspect_traffic_totem() -> Array[String]:
	if not CampaignState.story_flags.get(&"primeval_grove_cleared", false):
		return ["The carved signal keeps changing while hungry reptiles occupy the intersection."]
	if CampaignState.story_flags.get(&"primeval_traffic_clue_found", false):
		return ["The stone signal repeats three pulses: METEOR WARNING MISROUTED TO TRAFFIC CONTROL."]
	CampaignState.story_flags[&"primeval_traffic_clue_found"] = true
	return [
		"Ben studies a traffic signal carved before written language. Its red stone pulses in a repeating electrical cadence.",
		"BEN: This is not regulating traffic. It is receiving a warning from somewhere beneath the Ruins.",
		"A Paleo-Linguistic Telegraph can now be invented at the laboratory.",
	]


func _decode_cave_terminal() -> Array[String]:
	if CampaignState.story_flags.get(&"primeval_terminal_decoded", false):
		var revisited: Array[String] = ["CAVE OS: METEOR SIREN ROUTED TO RELAY NEST. USER PRIVILEGES: VERY OLD."]
		_append_specialist_survey(revisited)
		return revisited
	if &"paleo_translator" not in CampaignState.owned_inventions:
		return ["The cave computer answers every input with sparks and a deeply judgmental stone face.", "Ben needs the Paleo-Linguistic Telegraph from his laboratory."]
	CampaignState.story_flags[&"primeval_terminal_decoded"] = true
	var events: Array[String] = [
		"The Telegraph converts the terminal's electrical grunts into eighteenth-century punctuation.",
		"CAVE OS: METEOR SIREN HAS BEEN MISIDENTIFIED AS MORNING COMMUTE CONTROL FOR 11,402 YEARS.",
		"The route to the relay nest is open.",
	]
	_append_specialist_survey(events)
	return events


func _append_specialist_survey(events: Array[String]) -> void:
	var assist := CampaignState.claim_field_specialist_assist(&"primeval_relay_survey")
	if bool(assist.get("granted", false)):
		events.append("%s reads the fossilized service paths and finds an untouched municipal supply hollow." % String(assist.get("name", "A party specialist")))
		events.append(CampaignState.field_specialist_reward_text(assist))
	elif not bool(assist.get("claimed", false)):
		events.append(CampaignState.field_specialist_hint(&"primeval_relay_survey"))


func _reset_relay_nest() -> Array[String]:
	if not CampaignState.story_flags.get(&"primeval_terminal_decoded", false):
		return ["The egg-shaped relay has no readable controls. The Ruins terminal may explain it."]
	if not CampaignState.story_flags.get(&"primeval_nest_ambush_cleared", false):
		return ["The relay's dinosaur attendants object to unlicensed municipal maintenance."]
	if CampaignState.story_flags.get(&"primeval_caldera_open", false):
		return ["The relay now points toward the caldera. The meteor siren is still calling its largest commuter."]
	CampaignState.story_flags[&"primeval_caldera_open"] = true
	CampaignState.restore_party()
	return [
		"Ben reverses the relay polarity. Every traffic signal in Primeval Borough turns green at once.",
		"A tremendous roar answers from the caldera.",
		"The party is fully restored. The caldera route is open.",
	]


func _activate_anchor_totem() -> Array[String]:
	CampaignState.activate_save_point(&"primeval_nest")
	return ["Ben tunes the carved anchor to the laboratory's permanent frequency.", "The party's HP and MP are fully restored.", "Progress anchored at the Relay Nest."]
