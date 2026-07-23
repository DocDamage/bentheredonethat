extends Node

## Produces reviewer-input captures for every active Mansion manifest room in
## its declared first-visit, stabilized, and postgame states.  Files are kept
## under the isolated user directory, never in the runtime asset tree.  This
## proves that a rendered capture was produced; it is not visual acceptance.

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

const CAPTURE_ROOT := "user://m2-mansion-manifest-captures"
const STATE_PROFILES := {
	&"first_visit": {},
	&"stabilized": {
		&"mansion_first_room_complete": true,
		&"mansion_temporal_secret_found": true,
		&"mansion_crypt_key_found": true,
		&"mansion_attic_latch_open": true,
		&"mansion_ballroom_open": true,
		&"mansion_archive_boss_defeated": true,
	},
	&"postgame": {
		&"mansion_first_room_complete": true,
		&"mansion_temporal_secret_found": true,
		&"mansion_crypt_key_found": true,
		&"mansion_attic_latch_open": true,
		&"mansion_ballroom_open": true,
		&"mansion_archive_boss_defeated": true,
		&"postgame_unlocked": true,
	},
}

var _capture_records: Array[Dictionary] = []


func _ready() -> void:
	_capture_all.call_deferred()


func _capture_all() -> void:
	if not REGISTRY.validate().is_empty():
		_fail("Mansion capture requires a valid room registry.")
		return
	var capture_tag := OS.get_environment("FFVI_CAPTURE_TAG").strip_edges()
	if capture_tag.is_empty():
		capture_tag = "unlabeled"
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_ROOT)) != OK:
		_fail("Could not create isolated Mansion capture directory.")
		return
	for state_id in STATE_PROFILES:
		if not await _capture_state(state_id, STATE_PROFILES[state_id], capture_tag):
			return
	if not _write_manifest(capture_tag):
		_fail("Could not write Mansion capture manifest.")
		return
	print("MANSION_MANIFEST_STATE_CAPTURE_OK captures=%d rooms=%d states=%d root=%s visual_review_only=true" % [_capture_records.size(), REGISTRY.MANSION_ROOM_IDS.size(), STATE_PROFILES.size(), ProjectSettings.globalize_path(CAPTURE_ROOT)])
	get_tree().quit(0)


func _capture_state(state_id: StringName, flags: Dictionary, capture_tag: String) -> bool:
	CampaignState.reset_new_game()
	for plot_index in range(3):
		if not CampaignState.build_facility(plot_index, ["Cafe", "Library", "Clinic"][plot_index]):
			_fail("Could not prepare %s state facilities." % state_id)
			return false
	if not CampaignState.build_facility(3, "Haunted Mansion"):
		_fail("Could not prepare Mansion facility for %s captures." % state_id)
		return false
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
		_fail("Mansion capture could not find the manifest room runtime.")
		return false
	for room_id in REGISTRY.MANSION_ROOM_IDS:
		runtime.call(&"activate", room_id)
		var definition := REGISTRY.room(room_id)
		var capture_cell := _capture_cell(room_id)
		if capture_cell == Vector2i.ZERO:
			main.queue_free()
			_fail("%s has no safe capture cell." % room_id)
			return false
		var world_cell: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + capture_cell
		main._place_player(world_cell)
		await _settle()
		var file_name := "%s-%s-native-%s.png" % [String(room_id).to_lower(), state_id, capture_tag]
		var capture_path := "%s/%s" % [CAPTURE_ROOT, file_name]
		if not CAPTURE_GUARD.save_viewport_png(get_viewport(), capture_path, "Mansion manifest %s %s" % [room_id, state_id]):
			main.queue_free()
			get_tree().quit(1)
			return false
		_capture_records.append({
			"roomId": room_id,
			"state": state_id,
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
		var port_id := StringName(port.get("id", &""))
		var cell := ROUTER.safe_arrival_cell(room_id, port_id)
		if cell != Vector2i.ZERO:
			return cell
	return Vector2i.ZERO


func _settle() -> void:
	for _frame in range(5):
		await get_tree().process_frame


func _write_manifest(capture_tag: String) -> bool:
	var manifest_path := "%s/capture-manifest-%s.json" % [CAPTURE_ROOT, capture_tag]
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"captureTag": capture_tag,
		"reviewStatus": "visual_review_only",
		"states": STATE_PROFILES.keys(),
		"captures": _capture_records,
	}, "\t"))
	file.close()
	return true


func _fail(message: String) -> void:
	printerr("MANSION_MANIFEST_STATE_CAPTURE_FAILED: " + message)
	get_tree().quit(1)
