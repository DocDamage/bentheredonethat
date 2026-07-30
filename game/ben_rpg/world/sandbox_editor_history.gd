class_name SandboxEditorHistory
extends RefCounted

const LIMIT := 100
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []


func record(before: Dictionary, after: Dictionary) -> bool:
	if before.is_empty() or before == after: return false
	undo_stack.append({"before": before.duplicate(true), "after": after.duplicate(true)})
	if undo_stack.size() > LIMIT: undo_stack.pop_front()
	redo_stack.clear()
	return true


func take_undo() -> Dictionary:
	if undo_stack.is_empty(): return {}
	var command: Dictionary = undo_stack.pop_back()
	redo_stack.append(command)
	return command.get("before", {}).duplicate(true)


func take_redo() -> Dictionary:
	if redo_stack.is_empty(): return {}
	var command: Dictionary = redo_stack.pop_back()
	undo_stack.append(command)
	return command.get("after", {}).duplicate(true)


func counts() -> Vector2i: return Vector2i(undo_stack.size(), redo_stack.size())
