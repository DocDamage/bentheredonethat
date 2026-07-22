class_name TownResidentInteraction
extends Interaction

var manager
var resident_id: StringName = &""


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction() -> Array[String]:
	return manager.resident_dialogue(resident_id) if manager else ["No one answers."]
