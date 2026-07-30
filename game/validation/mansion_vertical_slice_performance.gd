extends Node

## Windowed, machine-specific Phase 2 benchmark. The provisional limits match
## the Mansion review contract; results remain reviewer evidence, not portable
## minimum-spec certification.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const FRAME_SAMPLES_PER_ROOM := 30
const MAX_TRANSITION_MS := 2000.0
const MAX_FOCUSED_P95_MS := 33.3


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle(6)
	var runtime: Node = main.get_node_or_null("Field/Map/CampaignWorld/ManifestRoomRuntime")
	if runtime == null:
		_fail("Manifest room runtime is unavailable.")
		return
	var transitions: Dictionary = {}
	var intervals: Array[float] = []
	var focused_samples := 0
	for room_id in REGISTRY.MANSION_ROOM_IDS:
		var started := Time.get_ticks_usec()
		runtime.call(&"activate", room_id)
		var definition := REGISTRY.room(room_id)
		var local_cell := _safe_cell(room_id)
		var world_cell: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + local_cell
		main._place_player(world_cell)
		await _settle(3)
		if Player.gamepiece == null or GamepieceRegistry.get_cell(Player.gamepiece) != world_cell:
			_fail("%s benchmark placement failed." % room_id)
			return
		var transition_ms := float(Time.get_ticks_usec() - started) / 1000.0
		transitions[String(room_id)] = snappedf(transition_ms, 0.001)
		if transition_ms > MAX_TRANSITION_MS:
			_fail("%s transition %.3fms exceeds %.1fms." % [room_id, transition_ms, MAX_TRANSITION_MS])
			return
		var previous_tick := Time.get_ticks_usec()
		for _sample in range(FRAME_SAMPLES_PER_ROOM):
			await get_tree().process_frame
			if DisplayServer.window_is_focused():
				focused_samples += 1
			var current_tick := Time.get_ticks_usec()
			intervals.append(float(current_tick - previous_tick) / 1000.0)
			previous_tick = current_tick
	intervals.sort()
	var p95 := intervals[ceili(float(intervals.size()) * 0.95) - 1]
	if focused_samples == intervals.size() and p95 > MAX_FOCUSED_P95_MS:
		_fail("Focused p95 %.3fms exceeds %.1fms." % [p95, MAX_FOCUSED_P95_MS])
		return
	print("MANSION_VERTICAL_SLICE_PERFORMANCE_OK " + JSON.stringify({
		"engine": String(Engine.get_version_info().get("string", "unknown")),
		"renderer": RenderingServer.get_video_adapter_name(),
		"windowSize": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"rooms": REGISTRY.MANSION_ROOM_IDS.size(),
		"transitionMs": transitions,
		"frameIntervalMs": {"samples": intervals.size(), "focusedSamples": focused_samples, "p95": snappedf(p95, 0.001), "p99": snappedf(intervals[ceili(float(intervals.size()) * 0.99) - 1], 0.001), "max": snappedf(intervals.back(), 0.001)},
		"memoryBytes": {"static": int(Performance.get_monitor(Performance.MEMORY_STATIC)), "peak": int(Performance.get_monitor(Performance.MEMORY_STATIC_MAX))},
		"provisionalLimits": {"transitionMs": MAX_TRANSITION_MS, "focusedP95Ms": MAX_FOCUSED_P95_MS},
	}))
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _safe_cell(room_id: StringName) -> Vector2i:
	for port in REGISTRY.ports(room_id):
		var cell := ROUTER.safe_arrival_cell(room_id, StringName(port.get("id", &"")))
		if cell != Vector2i.ZERO:
			return cell
	return Vector2i.ZERO


func _settle(frames: int) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("MANSION_VERTICAL_SLICE_PERFORMANCE_FAILED: " + message)
	get_tree().quit(1)
