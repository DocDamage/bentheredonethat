class_name MansionClueInteraction
extends Interaction

@export var clue_kind: StringName = &"clock"

const CLOCK_DIAL_SETTINGS := [&"12:01", &"01:13", &"02:22", &"03:13", &"04:44", &"05:05", &"06:06", &"07:07", &"08:08", &"09:09", &"10:10", &"11:11", &"13:13"]


func _execute() -> void:
	if clue_kind == &"clock" and _can_set_clock():
		_show_clock_dial()
		return
	var events := apply_interaction()
	_show_events(events)


func _show_events(events: Array[String]) -> void:
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
	var current_setting := String(CampaignState.story_flags.get(&"mansion_clock_time", "12:01"))
	return ["The clock currently reads %s. The ledger's underlined appointment gives Ben a specific time to set on the dial." % current_setting]


func set_clock_time(setting: StringName, save_after: bool = true) -> Array[String]:
	if not _can_set_clock():
		return ["The clock's dial is still missing its written instruction."]
	if setting not in CLOCK_DIAL_SETTINGS:
		return ["That setting does not exist on the clock's impossible dial."]
	CampaignState.story_flags[&"mansion_clock_time"] = setting
	var events: Array[String]
	if setting != &"04:44":
		events = ["Ben sets the dial to %s. The pendulum recoils, and a different room answers with one disapproving knock. The servants' passage remains closed." % setting]
	else:
		events = _complete_clock_puzzle()
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _can_set_clock() -> bool:
	return CampaignState.story_flags.get(&"mansion_foyer_cleared", false) \
		and CampaignState.story_flags.get(&"mansion_clock_examined", false) \
		and CampaignState.story_flags.get(&"mansion_ledger_found", false) \
		and not CampaignState.story_flags.get(&"mansion_first_room_complete", false)


func _show_clock_dial() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "THE CLOCK AT 4:44"
	dialog.dialog_text = "Choose one of the thirteen impossible settings. The household ledger records the servants' passage appointment."
	dialog.exclusive = true
	dialog.min_size = Vector2i(620, 420)
	var choices := GridContainer.new()
	choices.columns = 4
	choices.add_theme_constant_override("h_separation", 10)
	choices.add_theme_constant_override("v_separation", 10)
	dialog.add_child(choices)
	for setting in CLOCK_DIAL_SETTINGS:
		var button := Button.new()
		button.text = String(setting)
		button.custom_minimum_size = Vector2(118, 46)
		button.pressed.connect(_select_clock_setting.bind(setting, dialog))
		choices.add_child(button)
	get_tree().root.add_child(dialog)
	dialog.popup_centered()


func _select_clock_setting(setting: StringName, dialog: AcceptDialog) -> void:
	var events := set_clock_time(setting)
	dialog.queue_free()
	_show_events(events)


func _complete_clock_puzzle() -> Array[String]:
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
