extends Interaction

## Field dialogue for mandatory protagonists. This path can never discover,
## trial, unlock, hire, or remove Lincoln/Gandhi from the core campaign roster.

@export var protagonist_id: StringName


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)


func apply_interaction() -> Array[String]:
	if protagonist_id not in [&"lincoln", &"gandhi"]:
		return ["This protagonist record is unavailable."]
	var postgame := bool(CampaignState.story_flags.get(&"postgame_unlocked", false))
	var empyreal := bool(CampaignState.story_flags.get(&"empyreal_scenario_complete", false))
	if protagonist_id == &"lincoln":
		if postgame:
			return ["LINCOLN: A charter matters only if the people living under it can revise it. New Philadelphia should keep listening."]
		if empyreal:
			return ["LINCOLN: We have the evidence. Now the Tribunal must hear the people whose worlds it weighed without consent."]
		return ["LINCOLN: Keep the route open and the formation together. No address gets left outside the argument."]
	if postgame:
		return ["GANDHI: A repaired door is an invitation, not an obligation. Let every world choose how near it wishes to remain."]
	if empyreal:
		return ["GANDHI: Victory will mean little unless restraint survives it. We go to the Tribunal to end coercion, not inherit it."]
	return ["GANDHI: A path that avoids needless harm is still a path forward. We should look for it before drawing a weapon."]
