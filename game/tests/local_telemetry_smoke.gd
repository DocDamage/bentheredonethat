extends Node

const TEST_OUTPUT := "user://local_telemetry_smoke.jsonl"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	LocalTelemetry.configure_output(TEST_OUTPUT)
	LocalTelemetry.clear_output()
	LocalTelemetry.begin_session()
	SettingsRepository.set_value(&"telemetry", &"enabled", false)
	if not LocalTelemetry.record(&"disabled_probe", {"source": "smoke"}).is_empty():
		_fail("Disabled telemetry retained an event")
		return
	SettingsRepository.set_value(&"telemetry", &"enabled", true)
	CampaignState.adjust_duckets(40, &"telemetry_smoke", &"test", false)
	LocalTelemetry.record(&"battle_started", {"encounter": "telemetry_smoke"})
	var summary := LocalTelemetry.summary()
	if int(summary.get("events", 0)) != 2:
		_fail("Telemetry did not retain the expected opt-in events")
		return
	var by_event: Dictionary = summary.get("by_event", {})
	if int(by_event.get("economy_transaction", 0)) != 1 or int(by_event.get("battle_started", 0)) != 1:
		_fail("Telemetry summary omitted recorded event classes")
		return
	var first_event: Dictionary = LocalTelemetry.events[0]
	if String(first_event.get("build", "")) != "0.3.0-dev" or int(first_event.get("save_schema", 0)) != CampaignState.SAVE_VERSION:
		_fail("Telemetry event omitted build or save-schema context")
		return
	var world_state: Dictionary = first_event.get("world_state", {})
	if not world_state.has("anchors") or not world_state.has("stabilized_universes"):
		_fail("Telemetry event omitted local world-state context")
		return
	var file := FileAccess.open(TEST_OUTPUT, FileAccess.READ)
	if not file or file.get_as_text().split("\n", false).size() != 2:
		_fail("Telemetry JSONL output did not contain exactly two local events")
		return
	file.close()
	var balance := CampaignState.balance_report()
	if int((balance.get("economy", {}) as Dictionary).get("duckets_net", 0)) != 40:
		_fail("Balance report did not include the economy ledger")
		return
	if int((balance.get("telemetry", {}) as Dictionary).get("events", 0)) != 2:
		_fail("Balance report did not include telemetry summary")
		return
	SettingsRepository.set_value(&"telemetry", &"enabled", false)
	LocalTelemetry.clear_output()
	LocalTelemetry.configure_output(LocalTelemetry.DEFAULT_OUTPUT_PATH)
	print("LOCAL_TELEMETRY_SMOKE_OK opt_in=true local_jsonl=true balance_report=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	SettingsRepository.set_value(&"telemetry", &"enabled", false)
	LocalTelemetry.clear_output()
	LocalTelemetry.configure_output(LocalTelemetry.DEFAULT_OUTPUT_PATH)
	printerr("LOCAL_TELEMETRY_SMOKE_FAILED: " + message)
	get_tree().quit(1)
