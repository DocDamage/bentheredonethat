extends GamepieceController

var manager
var resident_id: StringName = &""
var activity: StringName = &"home"
var activity_label := "AT HOME"
var activity_pose: StringName = &"rest"
var target_cell := Gameboard.INVALID_CELL
var blocked_attempts := 0
var yield_count := 0
var _routine_key := ""
var _think_delay := 0.0


func _ready() -> void:
	super._ready()
	_think_delay = 0.08 + float(abs(hash(resident_id)) % 7) * 0.035
	set_process(true)


func _process(delta: float) -> void:
	if not is_active or not manager or not _gamepiece or not is_instance_valid(_gamepiece):
		return
	_think_delay -= delta
	if _think_delay > 0.0 or _gamepiece.is_moving():
		return
	_think_delay = 0.45 + float(abs(hash(resident_id)) % 5) * 0.08
	var current_cell := GamepieceRegistry.get_cell(_gamepiece)
	if current_cell == Gameboard.INVALID_CELL:
		return
	var plan: Dictionary = manager.activity_plan(resident_id, current_cell)
	var desired_target: Vector2i = plan.get("target", current_cell)
	var plan_activity := StringName(plan.get("activity", "home"))
	var plan_key := "%s:%s:%s" % [plan_activity, desired_target.x, desired_target.y]
	if plan_key != _routine_key:
		_routine_key = plan_key
		target_cell = desired_target
		blocked_attempts = 0
	if current_cell == target_cell:
		_set_activity(plan_activity, String(plan.get("label", "AT HOME")), StringName(plan.get("pose", &"rest")))
		manager.record_resident_state(resident_id, current_cell, activity, target_cell)
		return
	_plan_route(current_cell, plan_activity, String(plan.get("label", "TASK")), StringName(plan.get("pose", &"rest")))


func force_replan() -> void:
	move_path.clear()
	if manager:
		manager.release_reservation(resident_id)
	_routine_key = ""
	target_cell = Gameboard.INVALID_CELL
	_think_delay = 0.0


func _on_gamepiece_arrived() -> void:
	# The template controller discards the remainder of every path after one
	# cell, which made residents run a fresh town-wide A* search at every step.
	# Keep following the validated commute until it ends or the next cell becomes
	# occupied; _process then yields and replans only when genuinely necessary.
	if not move_path.is_empty() and is_active:
		if _move_to_next_waypoint() > 0.0:
			return
	move_path.clear()


func _plan_route(current_cell: Vector2i, destination_activity: StringName, label: String, pose: StringName) -> void:
	if target_cell == Gameboard.INVALID_CELL or not Gameboard.pathfinder.has_cell(target_cell):
		blocked_attempts += 1
		_set_activity(&"waiting", "WAITING • ROUTE CLOSED", &"rest")
		_recover_if_stalled()
		return
	var path: Array[Vector2i] = Gameboard.pathfinder.get_path_to_cell(current_cell, target_cell)
	if path.is_empty():
		var alternate: Vector2i = manager.find_open_activity_cell(target_cell, current_cell, resident_id)
		if alternate != Gameboard.INVALID_CELL and alternate != target_cell:
			target_cell = alternate
			path = Gameboard.pathfinder.get_path_to_cell(current_cell, target_cell)
	if path.is_empty():
		blocked_attempts += 1
		_think_delay = minf(2.5, 0.35 + blocked_attempts * 0.2)
		_set_activity(&"waiting", "WAITING • YIELDING", &"rest")
		_recover_if_stalled()
		return
	blocked_attempts = 0
	activity = destination_activity
	activity_label = "WALKING • %s" % label
	activity_pose = pose
	_set_animation_activity(activity_label, &"walk")
	manager.record_resident_state(resident_id, current_cell, &"commuting", target_cell)
	move_path = path.duplicate()


func _recover_if_stalled() -> void:
	if blocked_attempts < 3:
		return
	yield_count += 1
	blocked_attempts = 0
	manager.release_reservation(resident_id)
	move_path.clear()
	_routine_key = ""
	target_cell = Gameboard.INVALID_CELL
	_think_delay = 0.8 + float(abs(hash(resident_id)) % 5) * 0.12


func _set_activity(value: StringName, label: String, pose: StringName) -> void:
	activity = value
	activity_label = label
	activity_pose = pose
	_set_animation_activity(label, pose)


func _set_animation_activity(label: String, pose: StringName) -> void:
	if _gamepiece.animation and _gamepiece.animation.has_method("set_activity"):
		_gamepiece.animation.set_activity(label, pose)
