class_name LocalTelemetryService
extends Node

## Optional local diagnostics for balance and playtest review.  Events are never
## sent over the network: opting in only appends JSONL to the player's user data.

signal event_recorded(event: Dictionary)

const DEFAULT_OUTPUT_PATH := "user://local_telemetry.jsonl"
const MAX_IN_MEMORY_EVENTS := 2048

var output_path := DEFAULT_OUTPUT_PATH
var session_id := ""
var events: Array[Dictionary] = []


func _ready() -> void:
	begin_session()


func begin_session() -> void:
	events.clear()
	session_id = "session_%d_%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]


func configure_output(path: String) -> void:
	output_path = path


func is_enabled() -> bool:
	return bool(SettingsRepository.value(&"telemetry", &"enabled", false))


func record(event_id: StringName, payload: Dictionary = {}) -> Dictionary:
	if event_id == &"" or not is_enabled():
		return {}
	var event := {
		"session_id": session_id,
		"timestamp": Time.get_unix_time_from_system(),
		"build": String(ProjectSettings.get_setting("application/config/version", "development")),
		"save_schema": CampaignState.SAVE_VERSION,
		"content_version": String(ProjectSettings.get_setting("application/config/version", "development")),
		"event_id": String(event_id),
		"chapter": String(CampaignState.current_economy_chapter()),
		"location": CampaignState.last_location,
		"world_state": CampaignState.telemetry_world_state(),
		"data": payload.duplicate(true),
	}
	events.append(event)
	if events.size() > MAX_IN_MEMORY_EVENTS:
		events.pop_front()
	_append_to_disk(event)
	event_recorded.emit(event.duplicate(true))
	return event.duplicate(true)


func summary() -> Dictionary:
	var by_event := {}
	var by_chapter := {}
	for event in events:
		var event_id := String(event.get("event_id", "unknown"))
		var chapter := String(event.get("chapter", "unknown"))
		by_event[event_id] = int(by_event.get(event_id, 0)) + 1
		by_chapter[chapter] = int(by_chapter.get(chapter, 0)) + 1
	return {
		"enabled": is_enabled(),
		"session_id": session_id,
		"events": events.size(),
		"by_event": by_event,
		"by_chapter": by_chapter,
		"output_path": output_path,
	}


func clear_output() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(output_path))


func _append_to_disk(event: Dictionary) -> void:
	var file := FileAccess.open(output_path, FileAccess.READ_WRITE)
	if not file:
		file = FileAccess.open(output_path, FileAccess.WRITE_READ)
	if not file:
		push_warning("Local telemetry could not open %s" % output_path)
		return
	file.seek_end()
	file.store_line(JSON.stringify(event))
	file.close()
