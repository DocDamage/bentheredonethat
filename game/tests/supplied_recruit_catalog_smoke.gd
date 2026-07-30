extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const TEST_SAVE := "user://supplied_recruit_catalog_smoke.json"
const SUPPLIED_RECRUITS := [&"caveman", &"crimson_oni", &"kitsune_empress", &"neon_viper", &"archangel_commander", &"frost_lich_emperor"]
const STARTING_ACTIONS := {
	&"caveman": &"club_smash",
	&"crimson_oni": &"oni_crescent",
	&"kitsune_empress": &"foxfire",
	&"neon_viper": &"viper_rush",
	&"archangel_commander": &"seraph_strike",
	&"frost_lich_emperor": &"frost_nova",
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	if CampaignState.recruit_catalog.size() < 9:
		_fail("The complete supplied cast was not registered")
		return
	for recruit_id in SUPPLIED_RECRUITS:
		var recruit: Dictionary = CampaignState.recruit_catalog.get(recruit_id, {})
		if recruit.is_empty() or StringName(CampaignState.recruit_status.get(recruit_id, &"")) != &"undiscovered":
			_fail("Supplied recruit was missing or prematurely discovered: %s" % recruit_id)
			return
		var asset_root := "res://game_assets/characters/%s/rotations" % String(recruit.get("asset_pack", ""))
		for direction in ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]:
			if not ResourceLoader.exists("%s/%s.png" % [asset_root, direction]):
				_fail("%s is missing the %s directional sprite" % [recruit_id, direction])
				return
		var south_texture := load("%s/south.png" % asset_root) as Texture2D
		var portrait_region: Rect2 = recruit.get("portrait_region", Rect2())
		if south_texture == null or portrait_region.size.x <= 0.0 or portrait_region.size.y <= 0.0 or portrait_region.position.x < 0.0 or portrait_region.position.y < 0.0 or portrait_region.end.x > south_texture.get_width() or portrait_region.end.y > south_texture.get_height():
			_fail("%s portrait crop falls outside its supplied south-facing sprite" % recruit_id)
			return
		if CampaignState.skill_tree(recruit_id).size() != 4 or CampaignState.character_progress.get(recruit_id, {}).is_empty():
			_fail("%s did not receive a fixed specialty tree and progression record" % recruit_id)
			return
		var actor := CampaignCombatDatabase.party_actor(recruit_id, CampaignState.character_progress[recruit_id])
		var action_id: StringName = STARTING_ACTIONS[recruit_id]
		if actor.get("id") != recruit_id or action_id not in actor.get("actions", []) or CampaignCombatDatabase.action(action_id).is_empty():
			_fail("%s did not retain its identity and unique starting command" % recruit_id)
			return
		if PRESENTATION.effect_frames(action_id).size() != 30 or PRESENTATION.action_sound(action_id).is_empty():
			_fail("%s starting command lacks supplied VFX or SFX presentation" % recruit_id)
			return

	CampaignState.setup_sandbox(Vector2i(50, 8))
	for recruit_id in SUPPLIED_RECRUITS:
		if CampaignState.recruit_status.get(recruit_id) != &"reserve" or int(CampaignState.character_progress[recruit_id].get("level", 0)) != 50:
			_fail("Sandbox did not expose %s as a trained reserve recruit" % recruit_id)
			return
	CampaignState.move_to_reserve(&"astronaut")
	for recruit_id in [&"caveman", &"crimson_oni", &"kitsune_empress"]:
		if not CampaignState.add_to_party(recruit_id):
			_fail("Sandbox could not fill the five-person party with supplied recruits")
			return
	var model := AtbBattleModel.new()
	model.setup(&"mansion_restless_books", CampaignState.party, CampaignState.character_progress, 1776)
	for recruit_id in [&"caveman", &"crimson_oni", &"kitsune_empress"]:
		if model.get_actor(recruit_id).is_empty():
			_fail("Full-party battle lost supplied recruit identity: %s" % recruit_id)
			return
	CampaignState.build_facility(0, "Cafe")
	if not CampaignState.assign_to_facility(&"neon_viper", "Cafe"):
		_fail("A supplied reserve recruit could not choose facility staffing")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Expanded recruit catalog state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.recruit_status.get(&"neon_viper") != &"staffed":
		_fail("Supplied recruit party/facility status did not survive save/load")
		return
	if &"caveman" not in CampaignState.party or &"crimson_oni" not in CampaignState.party or &"kitsune_empress" not in CampaignState.party:
		_fail("Expanded five-person party did not survive save/load")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("SUPPLIED_RECRUIT_CATALOG_SMOKE_OK recruits=6 rotations=8 portrait_crops=valid specialties=fixed skill_trees=4 unique_actions=true sandbox=reserve party=5 staffing=true save_load=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("SUPPLIED_RECRUIT_CATALOG_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
