extends Node

## Verifies the production streamer never accumulates the complete manifest.
## Each authored-room activation must replace the previous root while retaining
## the runtime/streamer identity contract for every registered room.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	_unlock_all_manifest_gates()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	var runtime: Node = main.get_node_or_null("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node_or_null("Field/Map/CampaignWorld/RoomStreamer")
	if runtime == null or streamer == null:
		_fail("Live campaign did not expose the manifest runtime and room streamer.", main)
		return
	var previous_root_ref: WeakRef
	var replacements := 0
	for room_id in REGISTRY.room_ids():
		if not REGISTRY.is_authored_room(room_id):
			_fail("Manifest room %s has no authored streamable scene." % room_id, main)
			return
		runtime.call(&"activate", room_id)
		var active_root := streamer.call(&"active_root") as Node2D
		if StringName(runtime.call(&"active_room_id")) != room_id or StringName(streamer.call(&"active_room_id")) != room_id:
			_fail("%s did not synchronize runtime and streamer identities." % room_id, main)
			return
		if active_root == null or active_root.get_parent() != streamer or StringName(active_root.get_meta(&"room_id", &"")) != room_id:
			_fail("%s did not install its authored stream root." % room_id, main)
			return
		if streamer.get_child_count() != 1:
			_fail("%s left %d streamed roots loaded instead of one." % [room_id, streamer.get_child_count()], main)
			return
		if previous_root_ref != null:
			if previous_root_ref.get_ref() != null:
				_fail("%s left the previous authored root alive." % room_id, main)
				return
			replacements += 1
		previous_root_ref = weakref(active_root)
		await get_tree().process_frame
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	print("CAMPAIGN_MANIFEST_STREAMING_SMOKE_OK rooms=%d active_roots=1 replacements=%d complete_graph_loaded=false" % [REGISTRY.room_ids().size(), replacements])
	get_tree().quit(0)


func _unlock_all_manifest_gates() -> void:
	for room_id in REGISTRY.room_ids():
		for raw_flag in (REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
			CampaignState.story_flags[StringName(raw_flag)] = true
	CampaignState.state_changed.emit()


func _fail(message: String, main: Node = null) -> void:
	printerr("CAMPAIGN_MANIFEST_STREAMING_SMOKE_FAILED: " + message)
	if main:
		main.queue_free()
	get_tree().quit(1)
