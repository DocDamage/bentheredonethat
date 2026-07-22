class_name MansionClueInteraction
extends Interaction

@export var clue_kind: StringName = &"clock"


func _execute() -> void:
	var events := apply_interaction()
	var timeline := DialogicTimeline.new()
	timeline.events = events
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after: bool = true) -> Array[String]:
	var events: Array[String] = []
	if not CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
		return ["A cold draft pushes Ben's hand away. Deal with the foyer's occupants first."]
	if clue_kind == &"bookcase":
		events = _inspect_bookcase()
	else:
		events = _inspect_clock()
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _inspect_bookcase() -> Array[String]:
	if not CampaignState.story_flags.get(&"mansion_clock_examined", false):
		return ["The bookcase contains household accounts, several bad poems, and no reason to read either yet."]
	if CampaignState.story_flags.get(&"mansion_ledger_found", false):
		return ["The ledger's final entry remains underlined: 'At 4:44, the west clock opened the servants' passage.'"]
	CampaignState.story_flags[&"mansion_ledger_found"] = true
	CampaignState.add_item(&"mansion_ledger", 1, false)
	return [
		"Ben pulls a household ledger from behind a false row of books.",
		"FIGHTER: Please tell me the answer isn't hidden in the bad poetry.",
		"BEN: Better. The final entry says the west clock opened a passage at precisely 4:44.",
		"Quest item obtained: Household Ledger.",
	]


func _inspect_clock() -> Array[String]:
	if not CampaignState.story_flags.get(&"mansion_clock_examined", false):
		CampaignState.story_flags[&"mansion_clock_examined"] = true
		return [
			"The grandfather clock is stopped at 12:01, but its pendulum is warm.",
			"BEN: The mechanism has thirteen hour notches. One of them is hiding from ordinary chronology.",
			"FIGHTER: So we punch the clock?",
			"BEN: We consult the household records. Then, if necessary, you may punch time.",
		]
	if not CampaignState.story_flags.get(&"mansion_ledger_found", false):
		return ["The clock has thirteen settings and no labels. The missing instruction must be somewhere in the foyer."]
	if CampaignState.story_flags.get(&"mansion_first_room_complete", false):
		return ["The clock holds at 4:44. A narrow servants' passage now waits beyond the foyer."]
	CampaignState.story_flags[&"mansion_clock_puzzle_solved"] = true
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.duckets += 30
	CampaignState.add_item(&"anchor_shard", 1, false)
	CampaignState.loot_inventory.append({
		"instance_id": "mansion-key-fragment",
		"id": &"house_key_fragment",
		"base_name": "House-Key Fragment",
		"display_name": "House-Key Fragment of Continuity",
		"slot": "charm",
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png",
		"rarity": "Rare",
		"rarity_color": "#58a6ff",
		"modifiers": [{"name": "of Continuity", "stat": "spirit", "value": 5}],
		"kind": "gear",
		"source_pack": "resources_items_artifacts_loot",
	})
	return [
		"Ben turns the thirteenth notch and sets the impossible dial to 4:44.",
		"The clock strikes once. Every other clock in the house answers from a different century.",
		"A brass fragment drops from the mechanism, still anchored to this reality.",
		"Obtained: Rare House-Key Fragment of Continuity, Anchor Shard, and 30 Duckets.",
	]
