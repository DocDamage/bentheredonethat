class_name MansionSavePoint
extends Interaction

@export var save_point_id: StringName = &"mansion_archive"
@export var anchor_name := "archive clock"


func _execute() -> void:
	var lines := activate_anchor()
	var timeline := DialogicTimeline.new()
	timeline.events = lines
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func activate_anchor(save_after := true) -> Array[String]:
	if not CampaignState.activate_save_point(save_point_id):
		return ["The Mansion's anchor has not found a stable place in this room yet."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return [
		"Ben adjusts the %s until its pendulum matches the laboratory's reference frequency." % anchor_name,
		"The party's HP and MP are fully restored.",
		"Progress anchored. This clock now functions as a save point and retry point.",
	]
