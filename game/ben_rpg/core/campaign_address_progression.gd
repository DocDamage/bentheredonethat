class_name CampaignAddressProgression
extends RefCounted

## Save-backed Phase 5 progression and one-time reward transaction service.
## Optional/connective rooms never participate in the completion requirement.

const CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ENCOUNTERS := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const RETURN_ROOMS := {&"ashfall": &"NP-15", &"pelagic": &"NP-09", &"steamforge": &"NP-12", &"frontier": &"NP-12", &"warfront": &"NP-15", &"liminal": &"NP-03"}


static func can_enter(address_id: StringName, state = CampaignState) -> bool:
	var definition := CATALOG.address(address_id)
	if definition.is_empty(): return false
	for flag in definition.get("unlockFlags", []) as Array:
		if not bool(state.story_flags.get(StringName(flag), false)): return false
	return true


static func enter(address_id: StringName, state = CampaignState) -> bool:
	if not can_enter(address_id, state): return false
	var entered_flag := StringName("%s_address_entered" % String(address_id))
	if bool(state.story_flags.get(entered_flag, false)): return true
	state.story_flags[entered_flag] = true
	state.state_changed.emit()
	return true


static func complete_encounter(encounter_id: StringName, state = CampaignState) -> bool:
	var contract := ENCOUNTERS.contract(encounter_id)
	if contract.is_empty() or not bool(contract.get("runtimeEnabled", false)): return false
	var flag := StringName("%s_cleared" % String(encounter_id))
	if bool(state.story_flags.get(flag, false)): return false
	state.story_flags[flag] = true
	state.story_flags[StringName("%s_restored" % String(contract.get("roomId", "")).to_lower())] = true
	state.state_changed.emit()
	return true


static func can_resolve(address_id: StringName, state = CampaignState) -> bool:
	var definition := CATALOG.address(address_id)
	if definition.is_empty(): return false
	for room in definition.get("rooms", []) as Array:
		if StringName(room.get("class", &"")) != &"C": continue
		var encounter_id := StringName(room.get("encounterId", &""))
		if encounter_id != &"" and not bool(state.story_flags.get(StringName("%s_cleared" % encounter_id), false)):
			return false
	return true


static func resolve(address_id: StringName, state = CampaignState) -> bool:
	var definition := CATALOG.address(address_id)
	if definition.is_empty() or not can_resolve(address_id, state): return false
	var resolution_flag := StringName(definition.get("resolutionFlag", &""))
	var reward_flag := StringName("%s_reward_claimed" % String(resolution_flag))
	if bool(state.story_flags.get(resolution_flag, false)): return false
	# Commit marker and reward together. Both live in the normal save payload.
	state.story_flags[resolution_flag] = true
	state.story_flags[StringName("%s_population_restored" % String(address_id))] = true
	if not bool(state.story_flags.get(reward_flag, false)):
		var rewards: Dictionary = definition.get("rewards", {})
		state.adjust_duckets(int(rewards.get("duckets", 0)), &"address_resolution", address_id, false)
		for raw_item_id in (rewards.get("items", {}) as Dictionary):
			state.add_item(StringName(raw_item_id), int(rewards["items"][raw_item_id]), false, &"address_resolution", address_id)
		state.story_flags[reward_flag] = true
	state.state_changed.emit()
	return true


static func all_resolved(state = CampaignState) -> bool:
	for address_id in CATALOG.ADDRESS_ORDER:
		if not bool(state.story_flags.get(StringName(CATALOG.address(address_id).get("resolutionFlag", &"")), false)):
			return false
	return true


static func return_room(address_id: StringName) -> StringName:
	return StringName(RETURN_ROOMS.get(address_id, &""))


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if RETURN_ROOMS.size() != 6: errors.append("Every address needs a named New Philadelphia return room.")
	for address_id in CATALOG.ADDRESS_ORDER:
		var definition := CATALOG.address(address_id)
		if return_room(address_id) == &"" or (definition.get("rewards", {}) as Dictionary).is_empty(): errors.append("%s needs return and reward contracts." % address_id)
		for room in definition.get("rooms", []) as Array:
			if StringName(room.get("class", &"")) == &"C" and ENCOUNTERS.contract(StringName(room.get("encounterId", &""))).is_empty(): errors.append("%s critical room lacks its encounter." % room.get("id", &""))
	return PackedStringArray(errors)
