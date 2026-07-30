extends Interaction

var battle: CampaignBattle
var _pending_trial := false


func _execute() -> void:
	_pending_trial = false
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	if _pending_trial and battle and not battle.active:
		battle.begin(&"helios_cobalt_courier_trial")


func apply_interaction(save_after := true) -> Array[String]:
	var status: StringName = CampaignState.recruit_status.get(&"cobalt_courier", &"undiscovered")
	var events: Array[String]
	if not CampaignState.story_flags.get(&"helios_scenario_complete", false):
		events = ["A blue delivery stamp flickers on the transit platform. Its courier is still trapped somewhere in Helios's permanent day shift."]
	elif not CampaignState.story_flags.get(&"cobalt_courier_met", false):
		CampaignState.story_flags[&"cobalt_courier_met"] = true
		CampaignState.discover_recruit(&"cobalt_courier")
		_pending_trial = true
		events = [
			"A cobalt-furred courier steps out of a dead ticket gate carrying a parcel addressed to NEW PHILADELPHIA, YESTERDAY.",
			"COBALT COURIER: Delivery requires recipient signature, route verification, and one honorable ambush.",
			"BEN: I can provide two signatures and an extremely disputable definition of honorable.",
			"The velociraptor sniffs the parcel. It contains six batteries, a sandwich, and a thunderstorm that has been folded twice.",
			"Optional monster encounter: The Undeliverable Parcel.",
		]
	elif not CampaignState.story_flags.get(&"cobalt_courier_trial_complete", false):
		_pending_trial = true
		events = ["COBALT COURIER: Parcel remains unsigned. Combat verification window remains aggressively open."]
	elif status == &"available":
		CampaignState.story_flags[&"cobalt_courier_recruit_unlocked"] = true
		CampaignState.hire_recruit(&"cobalt_courier")
		var joined_party := CampaignState.add_to_party(&"cobalt_courier")
		events = [
			"The Cobalt Courier produces a receipt longer than the Helios transit line and stamps it DELIVERED, PROBABLY.",
			"COBALT COURIER: Your town has no postal code, stable century, or defensible street numbering. I accept the route.",
			"BEN: Splendid. You are now Director of Deliveries We Have Not Invented Yet.",
			"The Cobalt Courier joined Franklin & Company permanently as a navigation and logistics specialist.",
			("The Courier joined the active party." if joined_party else "The active party is full, so the Courier reported to reserve."),
		]
	elif status == &"party":
		events = ["COBALT COURIER: Route plotted. Threats may sign for their consequences at the next stop."]
	elif status == &"staffed":
		events = ["COBALT COURIER: Facility deliveries synchronized. Lunch arrived three minutes before it was ordered."]
	else:
		events = ["The Cobalt Courier waits beside the Afterlight Club, sorting mail by universe, urgency, and likelihood of biting."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events
