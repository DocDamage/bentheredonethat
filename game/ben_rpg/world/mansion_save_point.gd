class_name MansionSavePoint
extends Interaction


func _execute() -> void:
	var lines := activate_anchor()
	var timeline := DialogicTimeline.new()
	timeline.events = lines
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func activate_anchor(save_after := true) -> Array[String]:
	CampaignState.activate_save_point(&"mansion_archive")
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return [
		"Ben adjusts the archive clock until its pendulum matches the laboratory's reference frequency.",
		"The party's HP and MP are fully restored.",
		"Progress anchored. This clock now functions as a save point.",
	]
