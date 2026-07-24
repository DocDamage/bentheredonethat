extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	_use_two_person_fixture()
	CampaignState.recruit_status[&"fighter"] = &"reserve"
	CampaignState.add_to_party(&"fighter")
	_add_recruit(&"caveman_test", "Caveman", "Recruitable Characters/caveman/Caveman")
	_add_recruit(&"oni_test", "Crimson Oni", "Recruitable Characters/crimson oni samurai")
	_add_recruit(&"viper_test", "Neon Viper", "Recruitable Characters/neon viper - cyberpunk female")
	if CampaignState.party.size() != 5 or CampaignState.formation_row_count(&"front") != 3 or CampaignState.formation_row_count(&"back") != 2:
		_fail("Campaign state did not produce the requested five-person 3+2 formation")
		return
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	if not battle.begin(&"mansion_restless_books", 1776):
		_fail("Full-party battle did not start")
		return
	await get_tree().process_frame
	if battle.model.actors.size() != 8 or battle._actor_nodes.size() != 8 or battle._status_nodes.size() != 8:
		_fail("Five adventurers, pet, and two enemies were not all represented")
		return
	var unique_ids := {}
	var unique_slots := {}
	for actor in battle.model.actors:
		var actor_id := StringName(actor.get("id", ""))
		if unique_ids.has(actor_id):
			_fail("A future recruit fell through to another character's combat identity")
			return
		unique_ids[actor_id] = true
		if actor.get("team") == "party" and actor_id != &"velociraptor":
			var visual: Control = battle._actor_nodes.get(actor_id)
			var slot := "%d:%d" % [int(visual.position.x), int(visual.position.y)]
			if unique_slots.has(slot) or visual.position.y < 0.0 or visual.position.y + visual.size.y > battle._stage.size.y:
				_fail("A full-party actor overlapped another slot or the command UI")
				return
			unique_slots[slot] = true
	for recruit_id in [&"caveman_test", &"oni_test", &"viper_test"]:
		var actor: Dictionary = battle.model.get_actor(recruit_id)
		if actor.is_empty() or not ResourceLoader.exists(String(actor.get("sprite_path", ""))):
			_fail("Recruit catalog asset_pack did not resolve a real directional battle sprite")
			return
	var pet_visual: Control = battle._actor_nodes.get(&"velociraptor")
	if not pet_visual or pet_visual.position.x <= battle._actor_nodes[&"ben"].position.x:
		_fail("Velociraptor did not receive its dedicated autonomous formation slot")
		return
	print("FULL_PARTY_BATTLE_SMOKE_OK party=5 rows=3+2 pet=dedicated actors=8 ids=unique catalog_sprites=true hud_rows=8")
	get_tree().quit(0)


func _add_recruit(recruit_id: StringName, display_name: String, asset_pack: String) -> void:
	CampaignState.recruit_catalog[recruit_id] = {
		"name": display_name,
		"specialty": "Formation test",
		"asset_pack": asset_pack,
		"work_specialties": [],
		"work_adjacent": [],
	}
	CampaignState.recruit_status[recruit_id] = &"reserve"
	CampaignState.ensure_character_progress(recruit_id, 155, 24)
	CampaignState.add_to_party(recruit_id)


func _use_two_person_fixture() -> void:
	# This smoke test needs three synthetic recruits to exercise distinct catalog sprites.
	# Keep that fixture explicit now that the authored opening party is a trio.
	CampaignState.party.assign([&"ben"])
	CampaignState.party_formation = {&"ben": &"back"}
	CampaignState.recruit_status[&"ben"] = &"party"
	CampaignState.recruit_status[&"lincoln"] = &"reserve"
	CampaignState.recruit_status[&"gandhi"] = &"reserve"


func _fail(message: String) -> void:
	printerr("FULL_PARTY_BATTLE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
