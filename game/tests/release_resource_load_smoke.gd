extends Node

## Loads every shipped script, scene, and serialized resource from source. The
## exclusions mirror the tracked Windows release preset so this catches missing
## imports or compile errors that are outside the ordinary scenario smoke paths.

const LOADABLE_EXTENSIONS := ["gd", "tscn", "tres", "res", "dch", "dtl"]
const EXCLUDED_PREFIXES := [
	"res://addons/godot_mcp_x/",
	"res://addons/dialogic/Editor/",
	"res://addons/dialogic/Modules/StyleEditor/",
	"res://addons/dialogic/Modules/Variable/variables_editor/",
	"res://tests/",
	"res://validation/",
]
const EXCLUDED_FILES := [
	"res://addons/dialogic/Modules/Glossary/glossary_editor.gd",
	"res://addons/dialogic/Modules/Glossary/glossary_editor.tscn",
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var paths: Array[String] = []
	_collect_paths("res://", paths)
	paths.sort()
	var loaded_count := 0
	var by_extension: Dictionary = {}
	var failures: Array[String] = []
	for path in paths:
		if _is_excluded(path):
			continue
		var extension := path.get_extension().to_lower()
		if not LOADABLE_EXTENSIONS.has(extension):
			continue
		var resource := ResourceLoader.load(path)
		if resource == null:
			failures.append(path)
			continue
		loaded_count += 1
		by_extension[extension] = int(by_extension.get(extension, 0)) + 1
	if not failures.is_empty():
		printerr("RELEASE_RESOURCE_LOAD_SMOKE_FAILED paths=" + ", ".join(failures))
		get_tree().quit(1)
		return
	print("RELEASE_RESOURCE_LOAD_SMOKE_OK resources=%d scripts=%d scenes=%d serialized=%d dialogue=%d" % [
		loaded_count,
		int(by_extension.get("gd", 0)),
		int(by_extension.get("tscn", 0)),
		int(by_extension.get("tres", 0)) + int(by_extension.get("res", 0)),
		int(by_extension.get("dch", 0)) + int(by_extension.get("dtl", 0)),
	])
	get_tree().quit(0)


func _collect_paths(directory_path: String, paths: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		push_error("Could not enumerate release resources at " + directory_path)
		return
	for file_name in DirAccess.get_files_at(directory_path):
		paths.append(directory_path.path_join(file_name))
	for child_name in DirAccess.get_directories_at(directory_path):
		_collect_paths(directory_path.path_join(child_name), paths)


func _is_excluded(path: String) -> bool:
	if EXCLUDED_FILES.has(path):
		return true
	for prefix in EXCLUDED_PREFIXES:
		if path.begins_with(prefix):
			return true
	return false
