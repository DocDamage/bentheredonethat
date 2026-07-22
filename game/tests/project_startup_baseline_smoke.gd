extends Node


func _ready() -> void:
	var expected_autoloads := [
		&"Camera",
		&"CombatEvents",
		&"FieldEvents",
		&"Gameboard",
		&"GamepieceRegistry",
		&"Music",
		&"Player",
		&"Transition",
		&"Dialogic",
		&"CampaignState",
		&"SettingsRepository",
		&"LocalTelemetry",
	]
	for autoload_name in expected_autoloads:
		if not get_node_or_null(NodePath("/root/" + String(autoload_name))):
			printerr("PROJECT_STARTUP_BASELINE_SMOKE_FAILED missing_autoload=" + String(autoload_name))
			get_tree().quit(1)
			return
	print("PROJECT_STARTUP_BASELINE_SMOKE_OK autoloads=12 scene=empty")
	get_tree().quit(0)
