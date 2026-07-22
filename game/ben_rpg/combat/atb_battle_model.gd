class_name AtbBattleModel
extends RefCounted

const ATB_RATE := 0.82
const STATUS_SPEED_RATES := {&"slow": 0.62, &"shocked": 0.78}
const STATUS_LABELS := {&"poisoned": "POISON", &"slow": "SLOW", &"shocked": "SHOCK"}

var actors: Array[Dictionary] = []
var encounter_id: StringName
var encounter_data: Dictionary
var rng := RandomNumberGenerator.new()
var elapsed_time := 0.0
var escaped := false


func setup(new_encounter_id: StringName, party_ids: Array[StringName], progression: Dictionary, seed: int = 0) -> void:
	encounter_id = new_encounter_id
	encounter_data = CampaignCombatDatabase.encounter(encounter_id)
	actors.clear()
	escaped = false
	elapsed_time = 0.0
	if seed == 0:
		rng.randomize()
	else:
		rng.seed = seed
	for character_id in party_ids:
		actors.append(CampaignCombatDatabase.party_actor(character_id, progression.get(character_id, {})))
	actors.append(CampaignCombatDatabase.raptor_actor())
	var enemy_index := 0
	for enemy_id in encounter_data.get("enemies", []):
		actors.append(CampaignCombatDatabase.enemy_actor(StringName(enemy_id), enemy_index))
		enemy_index += 1
	for actor in actors:
		actor["atb"] = rng.randf_range(0.0, 16.0)


func tick_atb(delta: float) -> Array[StringName]:
	elapsed_time += delta
	var newly_ready: Array[StringName] = []
	for actor in actors:
		if not actor["alive"] or float(actor["atb"]) >= 100.0:
			continue
		var speed_rate := 1.0
		var statuses: Dictionary = actor.get("statuses", {})
		for status_id in STATUS_SPEED_RATES:
			if statuses.has(status_id):
				speed_rate *= float(STATUS_SPEED_RATES[status_id])
		var before := float(actor["atb"])
		actor["atb"] = minf(100.0, before + delta * float(actor["speed"]) * speed_rate * ATB_RATE)
		if before < 100.0 and float(actor["atb"]) >= 100.0:
			newly_ready.append(StringName(actor["id"]))
	return newly_ready


func get_actor(actor_id: StringName) -> Dictionary:
	for actor in actors:
		if StringName(actor["id"]) == actor_id:
			return actor
	return {}


func living(team: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for actor in actors:
		if actor["team"] == team and actor["alive"]:
			result.append(actor)
	return result


func valid_targets(actor_id: StringName, action_id: StringName) -> Array[Dictionary]:
	var actor := get_actor(actor_id)
	var action := CampaignCombatDatabase.action(action_id)
	if actor.is_empty() or action.is_empty():
		return []
	return _targets_for_contract(actor_id, action)


func resolve_action(actor_id: StringName, action_id: StringName, target_ids: Array[StringName]) -> Array[Dictionary]:
	var source := get_actor(actor_id)
	var action := CampaignCombatDatabase.action(action_id)
	var events: Array[Dictionary] = []
	if source.is_empty() or action.is_empty() or not source["alive"] or float(source["atb"]) < 99.9:
		return events
	var mp_cost := int(action.get("mp", 0))
	if int(source["mp"]) < mp_cost:
		return events
	var targets := _resolve_targets(actor_id, action, target_ids)
	if targets.is_empty():
		return events
	var item_id := StringName(action.get("item", &""))
	if item_id != &"" and not CampaignState.consume_item(item_id):
		return events
	source["mp"] = int(source["mp"]) - mp_cost
	if action["kind"] != "defend":
		source["guarding"] = false
	_update_attack_bonus(source)
	events.append({"type": "action", "source": actor_id, "action": action_id, "text": "%s uses %s!" % [source["display_name"], action["name"]]})
	match String(action["kind"]):
		"physical", "magic":
			for target in targets:
				_apply_damage(source, target, action, events)
				_apply_action_status(target, action, events)
		"heal", "item_heal":
			for target in targets:
				var amount := int(action["power"]) + (int(source["magic"]) / 2 if action["kind"] == "heal" else 0)
				var before := int(target["hp"])
				target["hp"] = mini(int(target["max_hp"]), before + amount)
				events.append({"type": "heal", "target": target["id"], "amount": int(target["hp"]) - before})
				_cleanse_statuses(target, action.get("cleanses", []), events)
		"item_mp":
			for target in targets:
				var before_mp := int(target["mp"])
				target["mp"] = mini(int(target["max_mp"]), before_mp + int(action["power"]))
				events.append({"type": "mp_restore", "target": target["id"], "amount": int(target["mp"]) - before_mp})
		"revive":
			for target in targets:
				var restored := maxi(1, int(round(float(target["max_hp"]) * float(action["power"]) / 100.0)))
				target["hp"] = restored
				target["alive"] = true
				target["atb"] = 0.0
				target["guarding"] = false
				target["statuses"] = {}
				events.append({"type": "revive", "target": target["id"], "amount": restored, "text": "%s returns to the fight!" % target["display_name"]})
		"cleanse":
			for target in targets:
				_cleanse_statuses(target, action.get("cleanses", []), events)
		"defend":
			source["guarding"] = true
			events.append({"type": "status", "target": actor_id, "text": "%s braces for impact." % source["display_name"]})
		"rally":
			for target in targets:
				target["attack_bonus"] = maxi(int(target["attack_bonus"]), int(action["power"]))
				target["attack_bonus_turns"] = 3
				events.append({"type": "status", "target": target["id"], "status": &"rally", "text": "%s is rallied." % target["display_name"]})
		"aegis":
			for target in targets:
				target["guarding"] = true
				events.append({"type": "status", "target": target["id"], "status": &"aegis", "text": "%s is protected by the Heavenly Aegis." % target["display_name"]})
		"delay":
			for target in targets:
				target["atb"] = maxf(0.0, float(target["atb"]) - float(action["power"]))
				events.append({"type": "delay", "target": target["id"], "amount": int(action["power"])})
		"damage_delay":
			for target in targets:
				_apply_damage(source, target, action, events)
				target["atb"] = maxf(0.0, float(target["atb"]) - float(action.get("delay", 0)))
				_apply_action_status(target, action, events)
		"escape":
			_attempt_escape(source, events)
	source["atb"] = 0.0
	source["turn_count"] = int(source.get("turn_count", 0)) + 1
	_tick_statuses_after_action(source, events)
	return events


func choose_ai_action(actor_id: StringName) -> Dictionary:
	var actor := get_actor(actor_id)
	if actor.is_empty() or not actor["alive"]:
		return {}
	var actions: Array = actor["actions"]
	if actions.is_empty():
		return {}
	var action_id := _choose_ai_action_id(actor, actions)
	var targets := valid_targets(actor_id, action_id)
	if targets.is_empty():
		return {}
	var target := _choose_ai_target(actor, action_id, targets)
	return {"actor": actor_id, "action": action_id, "targets": [StringName(target["id"])]}


func can_escape() -> bool:
	return not bool(encounter_data.get("scripted", false)) and not bool(encounter_data.get("boss", false))


func status_summary(actor_id: StringName) -> String:
	var actor := get_actor(actor_id)
	if actor.is_empty():
		return ""
	var labels: Array[String] = []
	var statuses: Dictionary = actor.get("statuses", {})
	for status_id in STATUS_LABELS:
		if statuses.has(status_id):
			labels.append(String(STATUS_LABELS[status_id]))
	if actor.get("guarding", false):
		labels.append("GUARD")
	if int(actor.get("attack_bonus_turns", 0)) > 0:
		labels.append("RALLY")
	return " ".join(labels)


func outcome() -> StringName:
	if escaped:
		return &"escape"
	if living("enemy").is_empty():
		return &"victory"
	for actor in living("party"):
		if actor.get("counts_for_defeat", true):
			return &"ongoing"
	return &"defeat"


func rewards() -> Dictionary:
	var experience := 0
	var duckets := 0
	for actor in actors:
		if actor["team"] == "enemy":
			experience += int(actor.get("experience", 0))
			duckets += int(actor.get("duckets", 0))
	return {"experience": experience, "duckets": duckets, "loot": CampaignCombatDatabase.roll_loot(encounter_id, rng)}


func sync_party_vitals() -> void:
	for actor in actors:
		if actor["team"] == "party" and actor["id"] != &"velociraptor":
			CampaignState.set_character_vitals(StringName(actor["id"]), int(actor["hp"]), int(actor["mp"]), int(actor["max_hp"]), int(actor["max_mp"]))


func _resolve_targets(actor_id: StringName, action: Dictionary, target_ids: Array[StringName]) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	var selector := StringName(action.get("selector", &""))
	if selector == &"all":
		return _targets_for_contract(actor_id, action)
	if selector == &"self":
		return [get_actor(actor_id)]
	var valid := _targets_for_contract(actor_id, action)
	for target_id in target_ids:
		var target := get_actor(target_id)
		if not target.is_empty() and target in valid:
			targets.append(target)
	return targets


func _targets_for_contract(actor_id: StringName, action: Dictionary) -> Array[Dictionary]:
	var actor := get_actor(actor_id)
	if actor.is_empty():
		return []
	var relation := StringName(action.get("relation", &""))
	var selector := StringName(action.get("selector", &""))
	if relation == &"hostile":
		return living("enemy" if actor["team"] == "party" else "party")
	if relation == &"ally" and selector != &"ko_single":
		return living(String(actor["team"]))
	if relation == &"ally" and selector == &"ko_single":
		var result: Array[Dictionary] = []
		for candidate in actors:
			if candidate["team"] == actor["team"] and not candidate["alive"] and candidate.get("counts_for_defeat", true):
				result.append(candidate)
		return result
	if relation == &"self":
		return [actor]
	return []


func _update_attack_bonus(source: Dictionary) -> void:
	if int(source["attack_bonus_turns"]) <= 0:
		return
	source["attack_bonus_turns"] = int(source["attack_bonus_turns"]) - 1
	if int(source["attack_bonus_turns"]) <= 0:
		source["attack_bonus"] = 0


func _apply_damage(source: Dictionary, target: Dictionary, action: Dictionary, events: Array[Dictionary]) -> void:
	var is_magic: bool = action["kind"] in ["magic", "damage_delay"]
	var offensive_stat := int(source["magic"]) if is_magic else int(source["attack"]) + int(source["attack_bonus"])
	var defensive_stat := int(target["spirit"]) if is_magic else int(target["defense"])
	var damage := maxi(1, offensive_stat + int(action["power"]) - defensive_stat / 2 + rng.randi_range(-3, 3))
	if not is_magic and source.get("team", "") == "party" and StringName(source.get("formation", "front")) == &"back":
		damage = maxi(1, int(round(damage * 0.75)))
	if not is_magic and target.get("team", "") == "party" and StringName(target.get("formation", "front")) == &"back":
		damage = maxi(1, int(round(damage * 0.75)))
	var critical := not is_magic and rng.randf() < float(action.get("critical_rate", 0.06))
	if critical:
		damage = maxi(1, int(round(damage * 1.75)))
	var element := StringName(action.get("element", &""))
	var rate := 1.0
	if element != &"":
		var element_rates: Dictionary = target.get("element_rates", {})
		rate = float(element_rates.get(element, 1.0))
		damage = 0 if rate <= 0.0 else maxi(1, int(round(float(damage) * rate)))
	if target["guarding"] and damage > 0:
		damage = maxi(1, damage / 2)
	target["hp"] = maxi(0, int(target["hp"]) - damage)
	var reaction := &""
	if rate >= 1.25:
		reaction = &"weak"
	elif rate <= 0.0:
		reaction = &"immune"
	elif rate < 0.9:
		reaction = &"resist"
	events.append({"type": "damage", "source": source["id"], "target": target["id"], "amount": damage, "element": element, "reaction": reaction, "critical": critical})
	if int(target["hp"]) <= 0:
		target["alive"] = false
		target["atb"] = 0.0
		target["statuses"] = {}
		events.append({"type": "ko", "target": target["id"], "text": "%s is knocked out." % target["display_name"]})


func _apply_action_status(target: Dictionary, action: Dictionary, events: Array[Dictionary]) -> void:
	var status_id := StringName(action.get("status", &""))
	if status_id == &"" or not target["alive"]:
		return
	var resistance: Dictionary = target.get("status_resist", {})
	var resist_rate := clampf(float(resistance.get(status_id, 0.0)), 0.0, 1.0)
	var chance := float(action.get("status_chance", 1.0)) * (1.0 - resist_rate)
	if rng.randf() > chance:
		return
	var durations := {&"poisoned": 5, &"slow": 4, &"shocked": 3}
	var statuses: Dictionary = target.get("statuses", {})
	statuses[status_id] = maxi(int(statuses.get(status_id, 0)), int(durations.get(status_id, 3)))
	target["statuses"] = statuses
	events.append({"type": "status", "target": target["id"], "status": status_id, "text": "%s is afflicted with %s." % [target["display_name"], STATUS_LABELS.get(status_id, String(status_id).to_upper())]})


func _cleanse_statuses(target: Dictionary, cleanses: Array, events: Array[Dictionary]) -> void:
	var statuses: Dictionary = target.get("statuses", {})
	var removed: Array[String] = []
	for raw_status in cleanses:
		var status_id := StringName(raw_status)
		if statuses.erase(status_id):
			removed.append(String(STATUS_LABELS.get(status_id, status_id)).capitalize())
	if removed.is_empty():
		events.append({"type": "status", "target": target["id"], "text": "%s has no matching ailments." % target["display_name"]})
	else:
		events.append({"type": "cleanse", "target": target["id"], "text": "%s recovers from %s." % [target["display_name"], ", ".join(removed)]})


func _tick_statuses_after_action(actor: Dictionary, events: Array[Dictionary]) -> void:
	var statuses: Dictionary = actor.get("statuses", {})
	if statuses.has(&"poisoned") and actor["alive"]:
		var poison_damage := maxi(1, int(ceil(float(actor["max_hp"]) * 0.08)))
		actor["hp"] = maxi(0, int(actor["hp"]) - poison_damage)
		events.append({"type": "status_damage", "target": actor["id"], "amount": poison_damage, "status": &"poisoned"})
		if int(actor["hp"]) <= 0:
			actor["alive"] = false
			actor["atb"] = 0.0
			actor["statuses"] = {}
			events.append({"type": "ko", "target": actor["id"], "text": "%s succumbs to poison." % actor["display_name"]})
			return
	var expired: Array[StringName] = []
	for raw_status in statuses.keys():
		var status_id := StringName(raw_status)
		statuses[status_id] = int(statuses[status_id]) - 1
		if int(statuses[status_id]) <= 0:
			expired.append(status_id)
	for status_id in expired:
		statuses.erase(status_id)
		events.append({"type": "cleanse", "target": actor["id"], "text": "%s is no longer affected by %s." % [actor["display_name"], STATUS_LABELS.get(status_id, String(status_id).to_upper())]})


func _attempt_escape(source: Dictionary, events: Array[Dictionary]) -> void:
	if not can_escape():
		events.append({"type": "escape_failed", "target": source["id"], "text": "The fault line seals this encounter. There is no escape."})
		return
	var party_speed := _average_speed(living("party"))
	var enemy_speed := _average_speed(living("enemy"))
	var chance := clampf(0.58 + (party_speed - enemy_speed) * 0.012, 0.25, 0.92)
	if rng.randf() <= chance:
		escaped = true
		events.append({"type": "escape", "target": source["id"], "text": "The company makes a strategic exit."})
	else:
		events.append({"type": "escape_failed", "target": source["id"], "text": "The escape route collapses. The battle continues."})


func _average_speed(group: Array[Dictionary]) -> float:
	if group.is_empty():
		return 0.0
	var total := 0.0
	for actor in group:
		total += float(actor["speed"])
	return total / float(group.size())


func _choose_ai_action_id(actor: Dictionary, actions: Array) -> StringName:
	if actor["id"] == &"velociraptor":
		var threats := living("enemy")
		for threat in threats:
			if float(threat["atb"]) >= 72.0:
				return &"raptor_distract"
		return &"raptor_pounce"
	if &"late_fee" in actions and int(actor.get("turn_count", 0)) % 3 == 2:
		return &"late_fee"
	if &"ink_blight" in actions:
		for target in living("party"):
			if not (target.get("statuses", {}) as Dictionary).has(&"poisoned") and rng.randf() < 0.68:
				return &"ink_blight"
	return StringName(actions[rng.randi_range(0, actions.size() - 1)])


func _choose_ai_target(actor: Dictionary, action_id: StringName, targets: Array[Dictionary]) -> Dictionary:
	if actor["id"] == &"velociraptor":
		if action_id == &"raptor_distract":
			var highest := targets[0]
			for candidate in targets:
				if float(candidate["atb"]) > float(highest["atb"]):
					highest = candidate
			return highest
		return _lowest_hp_target(targets)
	if action_id == &"ink_blight":
		var clean_targets: Array[Dictionary] = []
		for candidate in targets:
			if not (candidate.get("statuses", {}) as Dictionary).has(&"poisoned"):
				clean_targets.append(candidate)
		if not clean_targets.is_empty():
			return clean_targets[rng.randi_range(0, clean_targets.size() - 1)]
	if action_id in [&"steal_time", &"spectral_touch"]:
		var readiest := targets[0]
		for candidate in targets:
			if float(candidate["atb"]) > float(readiest["atb"]):
				readiest = candidate
		return readiest
	if action_id == &"hurl_volume":
		return _lowest_hp_target(targets)
	return targets[rng.randi_range(0, targets.size() - 1)]


func _lowest_hp_target(targets: Array[Dictionary]) -> Dictionary:
	var lowest := targets[0]
	for candidate in targets:
		var candidate_ratio := float(candidate["hp"]) / maxf(1.0, float(candidate["max_hp"]))
		var lowest_ratio := float(lowest["hp"]) / maxf(1.0, float(lowest["max_hp"]))
		if candidate_ratio < lowest_ratio:
			lowest = candidate
	return lowest
