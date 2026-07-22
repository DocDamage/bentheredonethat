class_name CampaignBattleActorAnimation
extends TextureRect

var current_sequence: StringName = &""
var _sequences: Dictionary = {}
var _texture_cache: Dictionary = {}
var _fps := 8.0
var _frame := 0
var _elapsed := 0.0
var _loop := true
var _hold_last := false


func configure(data: Dictionary) -> void:
	_sequences = data.get("sequences", {}).duplicate(true)
	_fps = maxf(1.0, float(data.get("fps", 8.0)))
	if _sequences.has(&"idle"):
		play_loop(&"idle")


func has_sequence(sequence: StringName) -> bool:
	return _sequences.has(sequence) and not (_sequences[sequence] as Array).is_empty()


func play_once(sequence: StringName) -> float:
	if not has_sequence(sequence):
		return 0.0
	_start(sequence, false, false)
	return float((_sequences[sequence] as Array).size()) / _fps


func play_loop(sequence: StringName) -> void:
	if has_sequence(sequence):
		_start(sequence, true, false)


func play_hold(sequence: StringName) -> void:
	if has_sequence(sequence):
		_start(sequence, false, true)


func _start(sequence: StringName, should_loop: bool, should_hold: bool) -> void:
	current_sequence = sequence
	_loop = should_loop
	_hold_last = should_hold
	_frame = 0
	_elapsed = 0.0
	_apply_frame()


func _process(delta: float) -> void:
	if current_sequence == &"" or not has_sequence(current_sequence):
		return
	_elapsed += delta
	var frames := _sequences[current_sequence] as Array
	var next_frame := int(_elapsed * _fps)
	if _loop:
		next_frame %= frames.size()
	elif next_frame >= frames.size():
		if _hold_last:
			next_frame = frames.size() - 1
		else:
			play_loop(&"idle")
			return
	if next_frame != _frame:
		_frame = next_frame
		_apply_frame()


func _apply_frame() -> void:
	if not has_sequence(current_sequence):
		return
	var frames := _sequences[current_sequence] as Array
	var path := String(frames[clampi(_frame, 0, frames.size() - 1)])
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	texture = _texture_cache[path]
