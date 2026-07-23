extends Node

## Produces the 102-room manifest baseline at first visit and stabilized state,
## then every room-local gate, restoration, boss-result, and postgame variant
## declared by the registry. Output stays in the isolated user directory and is
## reviewer input only; it does not make a visual, input, or release claim.

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const GRAPH_REPORT := preload("res://ben_rpg/world/campaign_room_graph_report.gd")

const CAPTURE_ROOT := "user://core-manifest-baseline-captures"
const CAPTURE_STATES := [&"fresh", &"stabilized"]

var _capture_records: Array[Dictionary] = []


func _ready() -> void:
	_capture_all.call_deferred()


func _capture_all() -> void:
	if not REGISTRY.validate().is_empty():
		_fail("Core capture requires a valid room registry.")
		return
	var capture_tag := OS.get_environment("FFVI_CAPTURE_TAG").strip_edges()
	if capture_tag.is_empty():
		capture_tag = "unlabeled"
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_ROOT)) != OK:
		_fail("Could not create isolated core capture directory.")
		return
	for state_id in CAPTURE_STATES:
		if not await _capture_state(state_id, GRAPH_REPORT.story_state(state_id), capture_tag):
			return
	for variant in REGISTRY.capture_variants():
		if not await _capture_variant(variant, capture_tag):
			return
	if not _write_manifest(capture_tag):
		_fail("Could not write core capture manifest.")
		return
	print("CORE_MANIFEST_BASELINE_CAPTURE_OK captures=%d rooms=%d states=%d root=%s visual_review_only=true" % [_capture_records.size(), REGISTRY.room_ids().size(), CAPTURE_STATES.size(), ProjectSettings.globalize_path(CAPTURE_ROOT)])
	get_tree().quit(0)


func _capture_variant(variant: Dictionary, capture_tag: String) -> bool:
	var source_state := StringName(variant.get("sourceState", &"fresh"))
	var flags := GRAPH_REPORT.story_state(source_state)
	for raw_flag in (variant.get("setFlags", {}) as Dictionary):
		flags[StringName(raw_flag)] = bool((variant.get("setFlags", {}) as Dictionary)[raw_flag])
	return await _capture_state(
		StringName(variant.get("state", &"")),
		flags,
		capture_tag,
		[variant.get("roomId", &"")],
		variant,
	)


func _capture_state(state_id: StringName, flags: Dictionary, capture_tag: String, requested_room_ids: Array = [], variant: Dictionary = {}) -> bool:
	CampaignState.reset_new_game()
	# A capture is a camera/room review input, not a party-composition test. Keep
	# followers out of the staging cells so a follower cannot make _place_player
	# silently fall back to the lab spawn.
	CampaignState.party = [&"ben"]
	for flag in flags:
		CampaignState.story_flags[flag] = flags[flag]
	CampaignState.state_changed.emit()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle()
	var runtime: Node = main.get_node_or_null("Field/Map/CampaignWorld/ManifestRoomRuntime")
	if runtime == null:
		main.queue_free()
		_fail("Core capture could not find the manifest room runtime.")
		return false
	var room_ids: Array = requested_room_ids if not requested_room_ids.is_empty() else REGISTRY.room_ids()
	for raw_room_id in room_ids:
		var room_id := StringName(raw_room_id)
		runtime.call(&"activate", room_id)
		var definition := REGISTRY.room(room_id)
		var capture_cell := _capture_cell(room_id)
		if capture_cell == Vector2i.ZERO:
			main.queue_free()
			_fail("%s has no safe capture cell." % room_id)
			return false
		var target_cell: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + capture_cell
		var current_player_cell := GamepieceRegistry.get_cell(Player.gamepiece) if Player.gamepiece else Gameboard.INVALID_CELL
		if not Gameboard.pathfinder.has_cell(target_cell) and current_player_cell != target_cell:
			main.queue_free()
			_fail("%s capture cell %s is not live after activation." % [room_id, target_cell])
			return false
		main._place_player(target_cell)
		await get_tree().process_frame
		if Player.gamepiece == null or GamepieceRegistry.get_cell(Player.gamepiece) != target_cell:
			main.queue_free()
			_fail("%s capture placement did not remain at %s." % [room_id, target_cell])
			return false
		await _settle()
		var capture_path := "%s/%s-%s-native-%s.png" % [CAPTURE_ROOT, String(room_id).to_lower(), state_id, capture_tag]
		if not CAPTURE_GUARD.save_viewport_png(get_viewport(), capture_path, "Core manifest %s %s" % [room_id, state_id]):
			main.queue_free()
			get_tree().quit(1)
			return false
		_capture_records.append({
			"roomId": room_id,
			"state": state_id,
			"sourceState": StringName(variant.get("sourceState", state_id)),
			"captureKinds": variant.get("kinds", [&"baseline"]),
			"stateFlag": StringName(variant.get("flag", &"")),
			"path": capture_path,
			"resolution": get_viewport().get_visible_rect().size,
			"captureTag": capture_tag,
			"inputMode": "visual_review_only",
		})
	main.queue_free()
	await get_tree().process_frame
	return true


func _capture_cell(room_id: StringName) -> Vector2i:
	for port in REGISTRY.ports(room_id):
		var cell := ROUTER.safe_arrival_cell(room_id, StringName(port.get("id", &"")))
		if cell != Vector2i.ZERO:
			return cell
	return Vector2i.ZERO


func _settle() -> void:
	for _frame in range(4):
		await get_tree().process_frame


func _write_manifest(capture_tag: String) -> bool:
	var file := FileAccess.open("%s/capture-manifest-%s.json" % [CAPTURE_ROOT, capture_tag], FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"captureTag": capture_tag,
		"reviewStatus": "visual_review_only",
		"states": CAPTURE_STATES,
		"captures": _capture_records,
	}, "\t"))
	file.close()
	return true


func _fail(message: String) -> void:
	printerr("CORE_MANIFEST_BASELINE_CAPTURE_FAILED: " + message)
	get_tree().quit(1)
