extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	SettingsRepository.set_value(&"accessibility", &"reduce_motion", false)
	SettingsRepository.set_value(&"accessibility", &"reduce_flashes", false)
	CampaignState.reset_new_game()
	CampaignState.recruit_status[&"fighter"] = &"reserve"
	CampaignState.add_to_party(&"fighter")
	for recruit_id in [&"scout", &"medic", &"scholar"]:
		CampaignState.recruit_catalog[recruit_id] = {"name": String(recruit_id).capitalize(), "specialty": "Formation test", "work_specialties": [], "work_adjacent": []}
		CampaignState.recruit_status[recruit_id] = &"reserve"
		CampaignState.ensure_character_progress(recruit_id, 140, 30)
		assert(CampaignState.add_to_party(recruit_id), "Full five-person company should enter battle")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	assert(battle.begin(&"mansion_foyer_intro", 1776), "Battle UI should open")
	await get_tree().process_frame
	assert(battle.visible and battle.model.actors.size() == 8, "Side-view UI should render five adventurers, the pet, and two enemies")
	assert(battle.get_node("BattleInterface").get_rect().size.x > 0.0, "Battle interface must fill a real viewport")
	assert(battle._actor_nodes.size() == 8 and battle._status_nodes.size() == 8, "Full-company stage or ATB status rows were truncated")
	var occupied_positions := {}
	for character_id in CampaignState.party:
		var actor_node: Control = battle._actor_nodes.get(character_id)
		assert(actor_node and actor_node.position.y >= 0.0 and actor_node.position.y + actor_node.size.y <= battle._stage.size.y, "A party actor overlaps the command UI")
		var position_key := "%d:%d" % [int(actor_node.position.x), int(actor_node.position.y)]
		assert(not occupied_positions.has(position_key), "Full-party formation stacked two actors in one slot")
		occupied_positions[position_key] = true
	assert(battle._actor_nodes[&"velociraptor"].position.x > battle._actor_nodes[&"ben"].position.x, "The pet needs its own formation position")
	var ben := battle.model.get_actor(&"ben")
	ben["atb"] = 100.0
	battle._show_commands(&"ben")
	assert(battle._actor_nodes[&"ben"].get_node("ReadyFrame").visible and battle._status_nodes[&"ben"].get_node("Ready").text == "READY", "The ready actor needs an explicit stage and HUD cue")
	assert(battle._command_buttons.columns == 2, "Expanded JRPG commands should use a compact two-column command grid")
	assert(battle._command_scroll and battle._command_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "A fully unlocked command list must scroll instead of clipping below the 960x540 battle UI")
	var phoenix_button := _button_containing(battle._command_buttons, "Phoenix Tonic")
	var escape_button := _button_containing(battle._command_buttons, "Escape")
	assert(phoenix_button and phoenix_button.disabled, "Revival should be unavailable while nobody is knocked out")
	assert(escape_button and escape_button.disabled, "The scripted foyer encounter should visibly seal escape")
	battle._on_action_selected(&"cane_tap")
	await get_tree().process_frame
	(battle._target_buttons.get_child(1) as Button).grab_focus()
	await get_tree().process_frame
	var target_marked := false
	for actor in battle.model.living("enemy"):
		target_marked = target_marked or battle._actor_nodes[actor["id"]].get_node("TargetFrame").visible
	assert(target_marked, "Choosing a target needs an explicit stage cue")
	battle._target_panel.hide()
	battle._chosen_action = &""
	battle._set_target_highlight(&"")
	var fighter := battle.model.get_actor(&"fighter")
	fighter["alive"] = false
	fighter["hp"] = 0
	battle._show_commands(&"ben")
	phoenix_button = _button_containing(battle._command_buttons, "Phoenix Tonic")
	assert(phoenix_button and not phoenix_button.disabled, "Phoenix Tonic should enable when a company member falls")
	var enemy: Dictionary = battle.model.living("enemy")[0]
	await battle._animate_action_vfx(&"static_discharge", [{"type": "damage", "target": enemy["id"]}])
	assert(battle._frame_cache.size() == 30 and battle._sfx_player.stream != null, "Battle UI should play the complete supplied VFX and SFX assets")
	var duckets_before_victory := CampaignState.duckets
	battle.debug_force_victory()
	var duckets_after_first_victory := CampaignState.duckets
	battle.debug_force_victory()
	await get_tree().process_frame
	assert(battle._results_panel.visible, "Victory rewards should replace the command UI")
	assert(duckets_after_first_victory > duckets_before_victory and CampaignState.duckets == duckets_after_first_victory, "Repeated victory signals must not duplicate battle rewards")
	print("CAMPAIGN_BATTLE_UI_SMOKE_OK actors=%d party=5+pet formation=3+2 slots=unique status=8 ready=stage+hud target=stage+list commands=grid items=contextual vfx=30frames sfx=true results=true" % battle.model.actors.size())
	get_tree().quit()


func _button_containing(container: Node, text: String) -> Button:
	for child in container.get_children():
		if child is Button and text in child.text:
			return child
	return null
