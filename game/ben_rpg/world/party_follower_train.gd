class_name PartyFollowerTrain
extends Node2D

const BASE_TRAIL_DISTANCE := 66.0
const FOLLOWER_SPACING := 52.0
const HISTORY_PADDING := 72.0
const TELEPORT_DISTANCE := 96.0
const HISTORY_SEED_STEP := 4

var leader: Gamepiece
var _roster: Array[StringName] = []
var _followers: Dictionary = {}
var _sequences: Dictionary = {}
var _directions: Dictionary = {}
var _history: Array[Vector2] = []
var _last_leader_position := Vector2.INF


func _ready() -> void:
	y_sort_enabled = true
	if not CampaignState.party_changed.is_connected(_sync_roster):
		CampaignState.party_changed.connect(_sync_roster)
	if not CampaignState.state_changed.is_connected(_sync_roster):
		CampaignState.state_changed.connect(_sync_roster)
	_sync_roster.call_deferred()


func _exit_tree() -> void:
	if CampaignState.party_changed.is_connected(_sync_roster):
		CampaignState.party_changed.disconnect(_sync_roster)
	if CampaignState.state_changed.is_connected(_sync_roster):
		CampaignState.state_changed.disconnect(_sync_roster)


func _process(_delta: float) -> void:
	if not is_instance_valid(leader):
		leader = Player.gamepiece
	if not is_instance_valid(leader):
		return
	_sync_roster()
	var current := _leader_position()
	if _history.is_empty() or _last_leader_position == Vector2.INF or current.distance_to(_last_leader_position) > TELEPORT_DISTANCE:
		_reset_history(current)
		_place_followers(true)
		return
	if current.distance_to(_last_leader_position) > 0.1:
		_history.append(current)
		_last_leader_position = current
		_trim_history()
	_place_followers(false)


func follower_ids() -> Array[StringName]:
	return _roster.duplicate()


func follower_animation(recruit_id: StringName) -> GamepieceAnimation:
	return _followers.get(recruit_id) as GamepieceAnimation


func reset_trail() -> void:
	if not is_instance_valid(leader):
		leader = Player.gamepiece
	if not is_instance_valid(leader):
		return
	_reset_history(_leader_position())
	_place_followers(true)


func _sync_roster() -> void:
	var desired: Array[StringName] = []
	for recruit_id in CampaignState.party:
		if recruit_id != &"ben":
			desired.append(recruit_id)
	if desired == _roster:
		return
	_roster = desired
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_followers.clear()
	_sequences.clear()
	_directions.clear()
	for recruit_id in _roster:
		var definition: Dictionary = CampaignState.recruit_catalog.get(recruit_id, {})
		var scene_path := String(definition.get("field_animation_scene", ""))
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			continue
		var packed := load(scene_path) as PackedScene
		var animation := packed.instantiate() as GamepieceAnimation
		if not animation:
			continue
		animation.name = "Follower_%s" % String(recruit_id).to_pascal_case()
		animation.set_meta("recruit_id", recruit_id)
		add_child(animation)
		_followers[recruit_id] = animation
		_sequences[recruit_id] = "idle"
		_directions[recruit_id] = Directions.Points.SOUTH
		animation.play("idle")
	if is_instance_valid(leader):
		_reset_history(_leader_position())
		_place_followers(true)


func _leader_position() -> Vector2:
	if leader.animation and is_instance_valid(leader.animation):
		return to_local(leader.animation.global_position)
	return to_local(leader.global_position)


func _reset_history(current: Vector2) -> void:
	_history.clear()
	var facing := Vector2(Directions.MAPPINGS.get(leader.direction, Vector2i.DOWN)).normalized()
	var maximum := _maximum_trail_distance() + HISTORY_PADDING
	var distance := int(ceil(maximum))
	while distance > 0:
		_history.append(current - facing * float(distance))
		distance -= HISTORY_SEED_STEP
	_history.append(current)
	_last_leader_position = current


func _trim_history() -> void:
	var maximum := _maximum_trail_distance() + HISTORY_PADDING
	var accumulated := 0.0
	var keep_from := 0
	for index in range(_history.size() - 1, 0, -1):
		accumulated += _history[index].distance_to(_history[index - 1])
		if accumulated >= maximum:
			keep_from = index - 1
			break
	if keep_from > 0:
		_history = _history.slice(keep_from)


func _maximum_trail_distance() -> float:
	return BASE_TRAIL_DISTANCE + maxf(0.0, float(_roster.size() - 1) * FOLLOWER_SPACING)


func _sample_trail(distance_back: float) -> Dictionary:
	if _history.is_empty():
		return {"position": Vector2.ZERO, "direction": Directions.Points.SOUTH}
	var remaining := distance_back
	for index in range(_history.size() - 1, 0, -1):
		var newer := _history[index]
		var older := _history[index - 1]
		var segment := newer - older
		var length := segment.length()
		if length <= 0.001:
			continue
		if remaining <= length:
			return {
				"position": newer.lerp(older, remaining / length),
				"direction": Directions.vector_to_direction(segment),
			}
		remaining -= length
	var oldest_direction := leader.direction if is_instance_valid(leader) else Directions.Points.SOUTH
	return {"position": _history[0], "direction": oldest_direction}


func _place_followers(force_idle: bool) -> void:
	for index in range(_roster.size()):
		var recruit_id := _roster[index]
		var animation := _followers.get(recruit_id) as GamepieceAnimation
		if not is_instance_valid(animation):
			continue
		var sample := _sample_trail(BASE_TRAIL_DISTANCE + float(index) * FOLLOWER_SPACING)
		var next_position: Vector2 = sample["position"]
		var moved := animation.position.distance_to(next_position) > 0.35 and not force_idle
		animation.position = next_position
		var next_direction := int(sample["direction"]) as Directions.Points
		if int(_directions.get(recruit_id, -1)) != next_direction:
			_directions[recruit_id] = next_direction
			animation.set_direction(next_direction)
		var next_sequence := "run" if moved else "idle"
		if String(_sequences.get(recruit_id, "")) != next_sequence:
			_sequences[recruit_id] = next_sequence
			animation.play(next_sequence)
