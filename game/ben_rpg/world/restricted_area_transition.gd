class_name RestrictedAreaTransition
extends AreaTransition

var destination_id: StringName = &""
var required_members: Array[StringName] = []
var waiver_story_flag: StringName = &""
var denied_return_coordinates := Vector2.ZERO


func requirements_met() -> bool:
	if waiver_story_flag != &"" and bool(CampaignState.story_flags.get(waiver_story_flag, false)):
		return true
	for recruit_id in required_members:
		if recruit_id not in CampaignState.party:
			return false
	return true


func missing_member_names() -> Array[String]:
	var names: Array[String] = []
	for recruit_id in required_members:
		if recruit_id not in CampaignState.party:
			names.append(String(CampaignState.recruit_catalog.get(recruit_id, {}).get("name", recruit_id)))
	return names


func _on_area_entered(area: Area2D) -> void:
	if requirements_met():
		await super._on_area_entered(area)
		return
	await get_tree().process_frame
	var gamepiece := area.owner as Gamepiece
	if not gamepiece:
		return
	_is_cutscene_in_progress = true
	gamepiece.stop()
	gamepiece.position = denied_return_coordinates
	gamepiece.rest_position = denied_return_coordinates
	GamepieceRegistry.move_gamepiece(gamepiece, Gameboard.pixel_to_cell(denied_return_coordinates))
	Camera.reset_position()
	var timeline := DialogicTimeline.new()
	timeline.events = [
		"The anchored doorway shudders and returns Ben to the town side.",
		"BEN: This scenario is refusing the current formation. Required: %s." % ", ".join(missing_member_names()),
		"Return the required recruit from reserve or facility duty through Franklin & Company's Roster.",
	]
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	_is_cutscene_in_progress = false
