class_name SaveRepository
extends RefCounted

## Small, side-effect-contained persistence helper. CampaignState remains the
## compatibility facade while save I/O moves behind this repository.

const BACKUP_SUFFIX := ".bak"
const TEMP_SUFFIX := ".writing"


static func write_json(path: String, payload: Dictionary) -> Error:
	return write_text(path, JSON.stringify(payload, "\t"))


static func write_text(path: String, text: String, preserve_backup := true) -> Error:
	var destination := _absolute_path(path)
	var directory_error := DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
	if directory_error != OK:
		return directory_error
	var temporary := destination + TEMP_SUFFIX
	var backup := destination + BACKUP_SUFFIX
	if preserve_backup and FileAccess.file_exists(destination):
		var backup_error := _copy_file(destination, backup)
		if backup_error != OK:
			return backup_error
	if FileAccess.file_exists(temporary):
		var stale_temp_error := DirAccess.remove_absolute(temporary)
		if stale_temp_error != OK:
			return stale_temp_error
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	file.close()
	var replacement_error := _replace_file(temporary, destination)
	if replacement_error == OK:
		return OK
	# If a platform cannot replace an existing file in one rename, retain the
	# previous complete save in .bak and repair it if the fallback fails.
	if not FileAccess.file_exists(destination):
		return replacement_error
	var remove_error := DirAccess.remove_absolute(destination)
	if remove_error != OK:
		return remove_error
	replacement_error = _replace_file(temporary, destination)
	if replacement_error == OK:
		return OK
	if preserve_backup and FileAccess.file_exists(backup):
		_copy_file(backup, destination)
	return replacement_error


static func read_text(path: String) -> Dictionary:
	var resolved := _absolute_path(path)
	if not FileAccess.file_exists(resolved):
		return {"ok": false, "error": ERR_FILE_NOT_FOUND, "path": path}
	var file := FileAccess.open(resolved, FileAccess.READ)
	if not file:
		return {"ok": false, "error": FileAccess.get_open_error(), "path": path}
	var text := file.get_as_text()
	file.close()
	return {"ok": true, "error": OK, "path": path, "text": text}


static func recovery_paths(path: String) -> PackedStringArray:
	return PackedStringArray([path + BACKUP_SUFFIX, path + TEMP_SUFFIX])


static func restore_primary(path: String, text: String) -> Error:
	# Do not turn a corrupt primary into the new backup during recovery.
	return write_text(path, text, false)


static func cleanup(path: String) -> void:
	for candidate in PackedStringArray([path, path + BACKUP_SUFFIX, path + TEMP_SUFFIX]):
		var absolute := _absolute_path(candidate)
		if FileAccess.file_exists(absolute):
			DirAccess.remove_absolute(absolute)


static func _copy_file(source: String, destination: String) -> Error:
	var source_file := FileAccess.open(source, FileAccess.READ)
	if not source_file:
		return FileAccess.get_open_error()
	var bytes := source_file.get_buffer(source_file.get_length())
	source_file.close()
	var destination_file := FileAccess.open(destination, FileAccess.WRITE)
	if not destination_file:
		return FileAccess.get_open_error()
	destination_file.store_buffer(bytes)
	destination_file.flush()
	destination_file.close()
	return OK


static func _replace_file(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(source, destination)


static func _absolute_path(path: String) -> String:
	return ProjectSettings.globalize_path(path)
