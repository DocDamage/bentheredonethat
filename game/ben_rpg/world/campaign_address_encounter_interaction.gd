class_name CampaignAddressEncounterInteraction
extends Interaction

const PROGRESSION := preload("res://ben_rpg/core/campaign_address_progression.gd")
const ENCOUNTERS := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")

var encounter_id: StringName = &""
var _battle: CampaignBattle


func configure(new_encounter_id: StringName) -> void:
	encounter_id = new_encounter_id
	set_meta(&"encounter_id", encounter_id)
	set_meta(&"runtime_enabled", true)
	queue_redraw()


func _execute() -> void:
	if encounter_id == &"" or bool(CampaignState.story_flags.get(StringName("%s_cleared" % encounter_id), false)):
		_show(["The route is stable. No hostile formation returns."])
		return
	_battle = get_tree().root.find_child("CampaignBattle", true, false) as CampaignBattle
	if not _battle or not _battle.begin(encounter_id):
		_show(["The address shudders, but the hostile formation cannot take shape yet."])
		return
	if not _battle.battle_finished.is_connected(_on_battle_finished):
		_battle.battle_finished.connect(_on_battle_finished, CONNECT_ONE_SHOT)


func apply_victory(save_after := true) -> bool:
	var contract := ENCOUNTERS.contract(encounter_id)
	if contract.is_empty() or not PROGRESSION.complete_encounter(encounter_id): return false
	if save_after: CampaignState.save_game()
	return true


func _on_battle_finished(victory: bool, finished_id: StringName) -> void:
	if victory and finished_id == encounter_id: apply_victory()


func _show(events: Array[String]) -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = events
	Dialogic.start_timeline(timeline)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color("d95d39"))
	draw_circle(Vector2.ZERO, 8.0, Color("ffd166"), false, 3.0)
