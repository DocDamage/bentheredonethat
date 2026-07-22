extends Node

signal settings_changed(settings: Dictionary)

const SETTINGS_VERSION := 1
const DEFAULT_SETTINGS_PATH := "user://settings.json"
const SAVE_REPOSITORY := preload("res://ben_rpg/core/save_repository.gd")

var settings: Dictionary = default_settings()


func _ready() -> void:
	load_from_disk()


static func default_settings() -> Dictionary:
	return {
		"version": SETTINGS_VERSION,
		"audio": {"master_volume": 1.0, "music_volume": 0.8, "sfx_volume": 0.8},
		"display": {"fullscreen": false, "pixel_scale": 1},
		"battle": {"atb_speed": 1.0, "auto_advance_results": false},
		"accessibility": {"text_speed": 1.0, "reduce_motion": false, "reduce_flashes": false, "weather_density": 1.0},
		"input": {"deadzone": 0.5, "vibration": true},
		"telemetry": {"enabled": false},
	}


func load_from_disk(path := DEFAULT_SETTINGS_PATH) -> Dictionary:
	var result := read_settings(path)
	settings = result.get("settings", default_settings()).duplicate(true)
	settings_changed.emit(settings.duplicate(true))
	return result


func save_to_disk(path := DEFAULT_SETTINGS_PATH) -> Error:
	settings = normalize(settings)
	return SAVE_REPOSITORY.write_json(path, settings)


func set_value(section: StringName, key: StringName, value: Variant) -> void:
	var section_values: Dictionary = settings.get(section, {}).duplicate(true)
	section_values[key] = value
	settings[section] = section_values
	settings = normalize(settings)
	settings_changed.emit(settings.duplicate(true))


func value(section: StringName, key: StringName, fallback: Variant = null) -> Variant:
	return (settings.get(section, {}) as Dictionary).get(key, fallback)


static func read_settings(path := DEFAULT_SETTINGS_PATH) -> Dictionary:
	var candidates: PackedStringArray = PackedStringArray([path])
	for recovery_path in SAVE_REPOSITORY.recovery_paths(path):
		candidates.append(recovery_path)
	var first_error := ERR_FILE_NOT_FOUND
	for index in candidates.size():
		var candidate := candidates[index]
		var text_result: Dictionary = SAVE_REPOSITORY.read_text(candidate)
		if not bool(text_result.get("ok", false)):
			if index == 0:
				first_error = int(text_result.get("error", ERR_FILE_NOT_FOUND))
			continue
		var parser := JSON.new()
		if parser.parse(String(text_result.get("text", ""))) != OK or not parser.data is Dictionary:
			if index == 0:
				first_error = ERR_FILE_CORRUPT
			continue
		var source: Dictionary = parser.data
		if int(source.get("version", 0)) < 1 or int(source.get("version", 0)) > SETTINGS_VERSION:
			if index == 0:
				first_error = ERR_FILE_CORRUPT
			continue
		var normalized := normalize(source)
		var recovered := index > 0
		if recovered:
			var repair_error := SAVE_REPOSITORY.restore_primary(path, String(text_result.get("text", "")))
			if repair_error != OK:
				push_warning("Recovered settings from backup, but could not repair the primary file: %s" % error_string(repair_error))
		return {"ok": true, "error": OK, "settings": normalized, "recovered": recovered}
	return {"ok": false, "error": first_error, "settings": default_settings(), "recovered": false}


static func normalize(source: Dictionary) -> Dictionary:
	var normalized := default_settings()
	var audio: Dictionary = source.get("audio", {})
	normalized["audio"] = {
		"master_volume": clampf(float(audio.get("master_volume", 1.0)), 0.0, 1.0),
		"music_volume": clampf(float(audio.get("music_volume", 0.8)), 0.0, 1.0),
		"sfx_volume": clampf(float(audio.get("sfx_volume", 0.8)), 0.0, 1.0),
	}
	var display: Dictionary = source.get("display", {})
	normalized["display"] = {
		"fullscreen": bool(display.get("fullscreen", false)),
		"pixel_scale": clampi(int(display.get("pixel_scale", 1)), 1, 4),
	}
	var battle: Dictionary = source.get("battle", {})
	normalized["battle"] = {
		"atb_speed": clampf(float(battle.get("atb_speed", 1.0)), 0.5, 2.0),
		"auto_advance_results": bool(battle.get("auto_advance_results", false)),
	}
	var accessibility: Dictionary = source.get("accessibility", {})
	normalized["accessibility"] = {
		"text_speed": clampf(float(accessibility.get("text_speed", 1.0)), 0.25, 4.0),
		"reduce_motion": bool(accessibility.get("reduce_motion", false)),
		"reduce_flashes": bool(accessibility.get("reduce_flashes", false)),
		"weather_density": clampf(float(accessibility.get("weather_density", 1.0)), 0.0, 1.0),
	}
	var input: Dictionary = source.get("input", {})
	normalized["input"] = {
		"deadzone": clampf(float(input.get("deadzone", 0.5)), 0.0, 1.0),
		"vibration": bool(input.get("vibration", true)),
	}
	var telemetry: Dictionary = source.get("telemetry", {})
	normalized["telemetry"] = {"enabled": bool(telemetry.get("enabled", false))}
	return normalized
