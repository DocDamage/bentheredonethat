extends Node2D

const GAMEPIECE_SCENE := preload("res://src/field/gamepieces/gamepiece.tscn")
const RESIDENT_ANIMATION := preload("res://ben_rpg/world/town_resident_animation.tscn")
const RESIDENT_CONTROLLER := preload("res://ben_rpg/world/town_resident_controller.gd")
const RESIDENT_INTERACTION := preload("res://ben_rpg/world/town_resident_interaction.tscn")
const RESIDENT_CATALOG := preload("res://ben_rpg/world/town_resident_catalog.gd")

var campaign: Node
var residents: Dictionary = {}
var destination_reservations: Dictionary = {}
var resident_reservations: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not CampaignState.state_changed.is_connected(_on_campaign_state_changed):
		CampaignState.state_changed.connect(_on_campaign_state_changed)
	sync_residents.call_deferred()


func sync_residents() -> void:
	for resident_id in RESIDENT_CATALOG.resident_ids():
		var unlocked := _resident_unlocked(StringName(resident_id))
		if unlocked and not residents.has(resident_id):
			_spawn_resident(StringName(resident_id))
		elif not unlocked and residents.has(resident_id):
			var entry: Dictionary = residents[resident_id]
			var gamepiece := entry.get("gamepiece") as Gamepiece
			if gamepiece:
				gamepiece.queue_free()
			release_reservation(StringName(resident_id))
			residents.erase(resident_id)


func activity_plan(resident_id: StringName, current_cell: Vector2i) -> Dictionary:
	var profile: Dictionary = RESIDENT_CATALOG.profile(resident_id)
	if profile.is_empty():
		return {"activity": &"home", "label": "AT HOME", "target": current_cell}
	var minute := int(CampaignState.town_time_minutes) % 1440
	var target_key := "home"
	var activity_id: StringName = &"resting"
	var label := "AT HOME"
	if minute >= 360 and minute < 480:
		target_key = "work"
		activity_id = &"opening"
		label = "OPENING • %s" % String(profile.get("role", "WORK"))
	elif minute >= 480 and minute < 720:
		target_key = "work"
		activity_id = &"working"
		label = String(profile.get("work_label", "WORKING"))
	elif minute >= 720 and minute < 780:
		target_key = "plaza"
		activity_id = &"lunch"
		label = "LUNCH AT THE PLAZA"
	elif minute >= 780 and minute < 1080:
		target_key = "work"
		activity_id = &"working"
		label = String(profile.get("work_label", "WORKING"))
	elif minute >= 1080 and minute < 1200:
		target_key = "errand"
		activity_id = &"errand"
		label = "RUNNING AN ERRAND"
	elif minute >= 1200 and minute < 1260:
		target_key = "plaza"
		activity_id = &"socializing"
		label = "EVENING IN THE PLAZA"
	var pose: StringName = &"rest"
	var task_index := -1
	if activity_id == &"working":
		var tasks: Array = profile.get("work_tasks", [])
		if not tasks.is_empty():
			task_index = (int(minute / 60) + abs(hash(resident_id))) % tasks.size()
			var task: Dictionary = tasks[task_index]
			label = String(task.get("label", label))
			pose = StringName(task.get("pose", &"craft"))
	elif activity_id in [&"opening", &"errand"]:
		pose = &"inspect"
	elif activity_id in [&"lunch", &"socializing"]:
		pose = &"social"
	var desired: Vector2i = _profile_target(profile, target_key, task_index)
	var target := reserve_activity_cell(resident_id, desired, current_cell)
	if target == Gameboard.INVALID_CELL:
		target = current_cell
	return {"activity": activity_id, "label": label, "target": target, "purpose": String(profile.get("role", "Resident")), "pose": pose, "task_index": task_index}


func reserve_activity_cell(resident_id: StringName, desired: Vector2i, current_cell: Vector2i) -> Vector2i:
	var existing: Vector2i = resident_reservations.get(resident_id, Gameboard.INVALID_CELL)
	if existing != Gameboard.INVALID_CELL and existing == desired and _cell_available_for_resident(existing, current_cell, resident_id):
		return existing
	release_reservation(resident_id)
	var target := find_open_activity_cell(desired, current_cell, resident_id)
	if target != Gameboard.INVALID_CELL:
		destination_reservations[target] = resident_id
		resident_reservations[resident_id] = target
	return target


func release_reservation(resident_id: StringName) -> void:
	var target: Vector2i = resident_reservations.get(resident_id, Gameboard.INVALID_CELL)
	if target != Gameboard.INVALID_CELL and StringName(destination_reservations.get(target, &"")) == resident_id:
		destination_reservations.erase(target)
	resident_reservations.erase(resident_id)


func find_open_activity_cell(desired: Vector2i, current_cell: Vector2i, resident_id: StringName) -> Vector2i:
	var candidates: Array[Vector2i] = [desired]
	for radius in range(1, 5):
		for offset in [Vector2i(radius, 0), Vector2i(0, radius), Vector2i(-radius, 0), Vector2i(0, -radius)]:
			candidates.append(desired + offset)
		for step in range(1, radius):
			candidates.append(desired + Vector2i(radius - step, step))
			candidates.append(desired + Vector2i(-radius + step, step))
			candidates.append(desired + Vector2i(radius - step, -step))
			candidates.append(desired + Vector2i(-radius + step, -step))
	for candidate in candidates:
		if _cell_available_for_resident(candidate, current_cell, resident_id):
			return candidate
	return Gameboard.INVALID_CELL


func _cell_available_for_resident(candidate: Vector2i, current_cell: Vector2i, resident_id: StringName) -> bool:
	if not _town_contains(candidate) or not Gameboard.pathfinder.has_cell(candidate):
		return false
	var reserved_by := StringName(destination_reservations.get(candidate, &""))
	if reserved_by != &"" and reserved_by != resident_id:
		return false
	var occupant := GamepieceRegistry.get_gamepiece(candidate)
	var own_gamepiece: Gamepiece = residents.get(resident_id, {}).get("gamepiece") as Gamepiece
	if occupant and occupant != own_gamepiece and candidate != current_cell:
		return false
	return candidate == current_cell or Gameboard.pathfinder.can_move_to(candidate)


func resident_at_cell(cell: Vector2i) -> Dictionary:
	for resident_id in residents.keys():
		var summary := resident_summary(StringName(resident_id))
		var gamepiece := summary.get("gamepiece") as Gamepiece
		if gamepiece and GamepieceRegistry.get_cell(gamepiece) == cell:
			return summary
	return {}


func resident_summary(resident_id: StringName) -> Dictionary:
	if not residents.has(resident_id):
		return {}
	var profile: Dictionary = RESIDENT_CATALOG.profile(resident_id)
	var entry: Dictionary = residents[resident_id]
	var gamepiece := entry.get("gamepiece") as Gamepiece
	var controller = entry.get("controller")
	return {
		"resident_id": resident_id,
		"name": String(profile.get("name", "Resident")),
		"role": String(profile.get("role", "Town resident")),
		"pack": &"Cozy Village NPC Collection Vol.1",
		"texture": RESIDENT_CATALOG.rotation_path(resident_id),
		"activity": StringName(controller.activity) if controller else &"home",
		"activity_label": String(controller.activity_label) if controller else "AT HOME",
		"pose": StringName(controller.activity_pose) if controller else &"rest",
		"target": controller.target_cell if controller else Gameboard.INVALID_CELL,
		"blocked_attempts": int(controller.blocked_attempts) if controller else 0,
		"yield_count": int(controller.yield_count) if controller else 0,
		"gamepiece": gamepiece,
	}


func relocate_resident(resident_id: StringName, cell: Vector2i) -> bool:
	if not CampaignState.sandbox_mode or not residents.has(resident_id) or not _town_contains(cell):
		return false
	var occupant := GamepieceRegistry.get_gamepiece(cell)
	var entry: Dictionary = residents[resident_id]
	var gamepiece := entry.get("gamepiece") as Gamepiece
	if not gamepiece or (occupant and occupant != gamepiece) or not Gameboard.pathfinder.has_cell(cell):
		return false
	if gamepiece.is_moving():
		gamepiece.stop()
	var old_cell := GamepieceRegistry.get_cell(gamepiece)
	if old_cell != cell and not GamepieceRegistry.move_gamepiece(gamepiece, cell):
		return false
	gamepiece.position = Gameboard.cell_to_pixel(cell)
	gamepiece.rest_position = gamepiece.position
	gamepiece.destination = Vector2.ZERO
	gamepiece.animation.play("idle")
	var controller = entry.get("controller")
	if controller:
		controller.force_replan()
	release_reservation(resident_id)
	record_resident_state(resident_id, cell, &"relocated", cell)
	return true


func restore_sandbox_layout_positions() -> void:
	if not CampaignState.sandbox_mode:
		return
	sync_residents()
	for resident_id in residents.keys():
		var saved := CampaignState.resident_state(StringName(resident_id))
		if saved.is_empty():
			continue
		var target := Vector2i(int(saved.get("x", -1)), int(saved.get("y", -1)))
		var entry: Dictionary = residents[resident_id]
		var gamepiece := entry.get("gamepiece") as Gamepiece
		if not gamepiece or not _town_contains(target) or not Gameboard.pathfinder.has_cell(target):
			continue
		var occupant := GamepieceRegistry.get_gamepiece(target)
		if occupant and occupant != gamepiece:
			continue
		if gamepiece.is_moving():
			gamepiece.stop()
		var current := GamepieceRegistry.get_cell(gamepiece)
		if current != target:
			GamepieceRegistry.move_gamepiece(gamepiece, target)
		gamepiece.position = Gameboard.cell_to_pixel(target)
		gamepiece.rest_position = gamepiece.position
		var controller = entry.get("controller")
		if controller:
			controller.force_replan()


func record_resident_state(resident_id: StringName, cell: Vector2i, activity: StringName, target: Vector2i) -> void:
	CampaignState.set_resident_state(resident_id, cell, activity, target)


func _spawn_resident(resident_id: StringName) -> void:
	var profile: Dictionary = RESIDENT_CATALOG.profile(resident_id)
	var saved: Dictionary = CampaignState.resident_state(resident_id)
	var home: Vector2i = profile.get("home", Vector2i.ZERO)
	var requested := Vector2i(int(saved.get("x", home.x)), int(saved.get("y", home.y)))
	var spawn_cell := find_open_activity_cell(requested, Gameboard.INVALID_CELL, resident_id)
	if spawn_cell == Gameboard.INVALID_CELL:
		return
	var gamepiece := GAMEPIECE_SCENE.instantiate() as Gamepiece
	gamepiece.name = "Resident%s" % String(resident_id).to_pascal_case()
	gamepiece.position = Gameboard.cell_to_pixel(spawn_cell)
	gamepiece.move_speed = 120.0 + float(abs(hash(resident_id)) % 4) * 6.0
	gamepiece.set_meta("resident_id", resident_id)
	var animation = RESIDENT_ANIMATION.instantiate()
	animation.configure(String(profile.get("name", "Resident")), "%s/%s" % [RESIDENT_CATALOG.ASSET_ROOT, String(profile.get("asset", ""))])
	gamepiece.get_node("PathFollow2D").add_child(animation)
	gamepiece.animation = animation
	var controller = RESIDENT_CONTROLLER.new()
	controller.name = "RoutineController"
	controller.manager = self
	controller.resident_id = resident_id
	gamepiece.add_child(controller)
	var interaction = RESIDENT_INTERACTION.instantiate()
	interaction.name = "ResidentInteraction"
	interaction.manager = self
	interaction.resident_id = resident_id
	gamepiece.add_child(interaction)
	add_child(gamepiece)
	residents[resident_id] = {"gamepiece": gamepiece, "controller": controller}
	record_resident_state(resident_id, spawn_cell, StringName(saved.get("activity", "home")), spawn_cell)


func _resident_unlocked(resident_id: StringName) -> bool:
	if CampaignState.sandbox_mode:
		return true
	var profile: Dictionary = RESIDENT_CATALOG.profile(resident_id)
	var facility := String(profile.get("facility", ""))
	if not facility.is_empty():
		return facility in CampaignState.built_facilities.values()
	if bool(profile.get("requires_foundations", false)):
		return bool(CampaignState.story_flags.get(&"town_foundations_complete", false))
	return false


func _profile_target(profile: Dictionary, target_key: String, task_index := -1) -> Vector2i:
	if target_key == "work":
		var facility := String(profile.get("facility", ""))
		if not facility.is_empty():
			for plot_index in CampaignState.built_facilities.keys():
				if CampaignState.built_facilities[plot_index] == facility:
					var plot: Rect2i = campaign.FACILITY_PLOTS[int(plot_index)]
					var door: Vector2i = campaign.TOWN_ORIGIN + Vector2i(plot.position.x + plot.size.x / 2, plot.end.y)
					# Work labels and poses can rotate without moving the resident onto
					# decorative facade edges. The authored entrance is the navigation-
					# validated service position for every facility task.
					return door
	return profile.get(target_key, profile.get("home", Vector2i.ZERO))


func resident_dialogue(resident_id: StringName) -> Array[String]:
	var summary := resident_summary(resident_id)
	if summary.is_empty():
		return ["The resident has already moved on."]
	var name := String(summary.get("name", "Resident"))
	var role := String(summary.get("role", "Town resident"))
	var activity_label := String(summary.get("activity_label", "AT HOME"))
	var lines: Array[String] = ["%s — %s" % [name.to_upper(), role], activity_label.capitalize() + "."]
	lines.append_array(RESIDENT_CATALOG.dialogue_lines(resident_id, CampaignState.library_record_summary(), CampaignState.postgame_rematch_available()))
	return lines


func _town_contains(cell: Vector2i) -> bool:
	if not campaign:
		return false
	return Rect2i(campaign.TOWN_ORIGIN + Vector2i.ONE, campaign.TOWN_SIZE - Vector2i(2, 2)).has_point(cell)


func _on_campaign_state_changed() -> void:
	sync_residents()
