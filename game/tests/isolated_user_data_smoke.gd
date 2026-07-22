extends Node

const SENTINEL_SAVE := "user://isolated_user_data_sentinel.json"


func _ready() -> void:
	var requested_home := OS.get_environment("GODOT_USER_HOME")
	assert(not requested_home.is_empty(), "The isolated runner must supply GODOT_USER_HOME")
	var actual_home := OS.get_user_data_dir()
	assert(actual_home.replace("\\", "/") == requested_home.replace("\\", "/"), "The runner must direct user:// into its disposable artifact directory")
	var sentinel_path := ProjectSettings.globalize_path(SENTINEL_SAVE)
	assert(sentinel_path.begins_with(actual_home), "user:// saves must resolve beneath Godot's current user-data directory")
	var file := FileAccess.open(SENTINEL_SAVE, FileAccess.WRITE)
	assert(file != null, "The isolated user-data directory must allow test saves")
	file.store_string("isolated")
	file.close()
	assert(FileAccess.file_exists(sentinel_path), "The isolated sentinel must remain inside the test artifact")
	print("ISOLATED_USER_DATA_SMOKE_OK requested=%s actual=%s" % [requested_home, actual_home])
	get_tree().quit(0)
