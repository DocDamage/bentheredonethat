extends Cutscene

@export var timeline: DialogicTimeline


func _execute() -> void:
	if "--smoke-field" in OS.get_cmdline_user_args() or "--smoke-town" in OS.get_cmdline_user_args():
		$Background/ColorRect.hide()
		queue_free.call_deferred()
		return
	# The opening happens in the actual laboratory. The old opaque black card hid
	# Ben, the velociraptor, and every supplied environment asset until the entire
	# prologue was over, which made New Adventure feel like a detached text crawl.
	$Background/ColorRect.color = Color(0.004, 0.009, 0.025, 0.22)
	$Background/ColorRect.show()
	Camera.zoom = Vector2(1.12, 1.12)
	if Player.gamepiece:
		# Face the player during the introduction; this also keeps the pet's first
		# trailing cell stable instead of asking it to cross through Ben on frame one.
		Player.gamepiece.direction = Directions.Points.SOUTH
	
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	CampaignState.mark_story_flag(&"opening_complete")
	
	await Transition.cover()
	$Background/ColorRect.hide()
	Camera.zoom = Vector2.ONE
	
	await Transition.clear(2.0)
	CampaignState.save_game()
	
	queue_free.call_deferred()
