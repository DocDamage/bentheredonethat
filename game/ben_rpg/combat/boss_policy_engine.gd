class_name BossPolicyEngine
extends RefCounted

## Pure, data-driven boss sequencing. Policies choose phase-aware actions,
## reserve telegraphed attacks for the next turn, and prevent immediate repeats.


static func initialize(policy: Dictionary) -> Dictionary:
	var phase := _phase_for(policy, 1.0)
	return {
		"phase_id": StringName(phase.get("id", "")),
		"phase_turns": 0,
		"last_action": StringName(),
		"pending_action": StringName(),
		"pending_telegraph": "",
	}


static func choose(policy: Dictionary, actor: Dictionary, runtime: Dictionary) -> Dictionary:
	var phase := _phase_for(policy, _hp_ratio(actor))
	var phase_id := StringName(phase.get("id", ""))
	var changed_phase := phase_id != StringName(runtime.get("phase_id", ""))
	if changed_phase:
		runtime["phase_id"] = phase_id
		runtime["phase_turns"] = 0
		runtime["pending_action"] = StringName()
		runtime["pending_telegraph"] = ""
	var pending_action := StringName(runtime.get("pending_action", ""))
	if pending_action != &"":
		runtime["pending_action"] = StringName()
		runtime["pending_telegraph"] = ""
		runtime["last_action"] = pending_action
		return {
			"action": pending_action,
			"phase_id": phase_id,
			"phase_label": String(phase.get("label", phase_id)),
			"phase_changed": changed_phase,
		}
	var actions: Array = phase.get("actions", [])
	if actions.is_empty():
		return {}
	var index := int(runtime.get("phase_turns", 0)) % actions.size()
	var entry: Dictionary = actions[index]
	var action_id := StringName(entry.get("action", ""))
	if actions.size() > 1 and action_id == StringName(runtime.get("last_action", "")):
		entry = actions[(index + 1) % actions.size()]
		action_id = StringName(entry.get("action", ""))
	runtime["phase_turns"] = int(runtime.get("phase_turns", 0)) + 1
	var telegraph := String(entry.get("telegraph", ""))
	if not telegraph.is_empty():
		runtime["pending_action"] = action_id
		runtime["pending_telegraph"] = telegraph
		return {
			"telegraph": telegraph,
			"phase_id": phase_id,
			"phase_label": String(phase.get("label", phase_id)),
			"phase_changed": changed_phase,
		}
	runtime["last_action"] = action_id
	return {
		"action": action_id,
		"phase_id": phase_id,
		"phase_label": String(phase.get("label", phase_id)),
		"phase_changed": changed_phase,
	}


static func phase_label(policy: Dictionary, actor: Dictionary) -> String:
	var phase := _phase_for(policy, _hp_ratio(actor))
	return String(phase.get("label", phase.get("id", "")))


static func pending_telegraph(runtime: Dictionary) -> String:
	return String(runtime.get("pending_telegraph", ""))


static func interrupt_pending_action(runtime: Dictionary) -> StringName:
	var interrupted := StringName(runtime.get("pending_action", ""))
	if interrupted == &"":
		return &""
	runtime["pending_action"] = StringName()
	runtime["pending_telegraph"] = ""
	return interrupted


static func _phase_for(policy: Dictionary, hp_ratio: float) -> Dictionary:
	var phases: Array = policy.get("phases", [])
	for raw_phase in phases:
		var phase: Dictionary = raw_phase
		if hp_ratio >= float(phase.get("minimum_hp_ratio", 0.0)):
			return phase
	return phases.back() if not phases.is_empty() else {}


static func _hp_ratio(actor: Dictionary) -> float:
	return float(actor.get("hp", 0)) / maxf(1.0, float(actor.get("max_hp", 1)))
