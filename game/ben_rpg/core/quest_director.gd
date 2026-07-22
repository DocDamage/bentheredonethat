class_name QuestDirector
extends RefCounted

## Objective-tree evaluator. It records completed node ids independently from
## legacy linear step indices so existing saves and callers stay compatible.


static func synchronize(definition: Dictionary, runtime: Dictionary, condition_met: Callable) -> Dictionary:
	var nodes: Array = definition.get("objectives", [])
	if nodes.is_empty():
		return {"changed": false, "complete": false}
	var completed: Dictionary = runtime.get("objective_states", {})
	var changed := false
	for _pass in range(nodes.size() + 1):
		var pass_changed := false
		for raw_node in nodes:
			var node: Dictionary = raw_node
			var node_id := StringName(node.get("id", ""))
			if node_id == &"" or bool(completed.get(node_id, false)) or not _requirements_met(node, completed):
				continue
			if condition_met.call(node.get("condition", {})):
				completed[node_id] = true
				pass_changed = true
				changed = true
		if not pass_changed:
			break
	runtime["objective_states"] = completed
	return {"changed": changed, "complete": _all_complete(nodes, completed)}


static func available_objectives(definition: Dictionary, runtime: Dictionary) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var completed: Dictionary = runtime.get("objective_states", {})
	for raw_node in definition.get("objectives", []):
		var node: Dictionary = raw_node
		var node_id := StringName(node.get("id", ""))
		if node_id != &"" and not bool(completed.get(node_id, false)) and _requirements_met(node, completed):
			results.append(node.duplicate(true))
	return results


static func _requirements_met(node: Dictionary, completed: Dictionary) -> bool:
	for raw_requirement in node.get("requires", []):
		if not bool(completed.get(StringName(raw_requirement), false)):
			return false
	return true


static func _all_complete(nodes: Array, completed: Dictionary) -> bool:
	for raw_node in nodes:
		var node: Dictionary = raw_node
		var node_id := StringName(node.get("id", ""))
		if node_id == &"" or not bool(completed.get(node_id, false)):
			return false
	return true
