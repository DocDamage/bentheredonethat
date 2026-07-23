class_name MansionChapterInteraction
extends Interaction

@export var interaction_kind: StringName = &"gallery_portrait"


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after: bool = true) -> Array[String]:
	var events: Array[String]
	match interaction_kind:
		&"gallery_portrait":
			events = _inspect_gallery_portrait()
		&"gallery_cache":
			events = _open_gallery_cache()
		&"nursery_music_box":
			events = _inspect_nursery_music_box()
		&"nursery_cache":
			events = _open_nursery_cache()
		&"ballroom_gate":
			events = _open_ballroom_gate()
		&"chapel_alignment":
			events = _align_chapel_glass()
		&"attic_stair":
			events = _lower_attic_stair()
		_:
			events = ["The Mansion declines to explain this particular impossibility."]
	CampaignState.state_changed.emit()
	if save_after:
		CampaignState.save_game()
	return events


func _inspect_gallery_portrait() -> Array[String]:
	if not CampaignState.story_flags.get(&"mansion_gallery_ambush_cleared", false):
		return ["Every portrait turns to watch the approaching spirits. Ben cannot examine the frames while their owners are objecting."]
	if CampaignState.story_flags.get(&"mansion_hour_hand_found", false):
		return ["The central portrait still points accusingly toward the nursery. Its painted clock is missing both hands."]
	CampaignState.story_flags[&"mansion_gallery_portrait_read"] = true
	CampaignState.story_flags[&"mansion_hour_hand_found"] = true
	CampaignState.add_item(&"silver_hour_hand", 1, false)
	return [
		"The oldest portrait depicts this room at 4:44—except one silver clock hand projects beyond the paint.",
		"BEN: An object painted before it was manufactured. Efficient, if hostile to bookkeeping.",
		"FIGHTER: Can I pull it out?",
		"The Fighter does. Somewhere upstairs, a child's music box begins to play.",
		"Quest item obtained: Silver Hour Hand.",
	]


func _open_gallery_cache() -> Array[String]:
	if CampaignState.story_flags.get(&"mansion_gallery_cache_opened", false):
		return ["The false-bottom cabinet is empty except for a note reading: 'Dust remains property of the house.'"]
	if not CampaignState.story_flags.get(&"mansion_gallery_ambush_cleared", false):
		return ["A cabinet rattles behind the apparitions. Whatever is inside can wait until the room stops attacking."]
	CampaignState.story_flags[&"mansion_gallery_cache_opened"] = true
	CampaignState.add_item(&"ether", 2, false)
	CampaignState.add_item(&"smelling_salts", 1, false)
	CampaignState.adjust_duckets(24, &"mansion_room_treasure", &"mansion_archive", false)
	return ["Ben opens a false-bottom cabinet.", "Found 2 Leyden Ethers, Smelling Salts, and 24 Duckets."]


func _inspect_nursery_music_box() -> Array[String]:
	if not CampaignState.story_flags.get(&"mansion_nursery_ambush_cleared", false):
		return ["The music box plays faster as the dolls advance. This is less a clue than a declaration of hostilities."]
	if not CampaignState.story_flags.get(&"mansion_hour_hand_found", false):
		return ["The music box has an hour-shaped socket. The missing part must be hidden in an earlier room."]
	if CampaignState.story_flags.get(&"mansion_minute_hand_found", false):
		return ["The music box rests at 4:44. Its lullaby now ends with four deliberate notes, then four more."]
	CampaignState.story_flags[&"mansion_music_box_clue_found"] = true
	CampaignState.story_flags[&"mansion_minute_hand_found"] = true
	CampaignState.add_item(&"brass_minute_hand", 1, false)
	return [
		"The Silver Hour Hand fits the music box. Its melody rewinds, and a brass minute hand rises from the cylinder.",
		"BEN: The house divided its appointment between memory and childhood. Dramatic, but mechanically sound.",
		"The far doors answer with four knocks, pause, then answer with four more.",
		"Quest item obtained: Brass Minute Hand.",
	]


func _open_nursery_cache() -> Array[String]:
	if CampaignState.story_flags.get(&"mansion_nursery_cache_opened", false):
		return ["The toy chest contains no further medicine, only a wooden velociraptor of questionable anatomical accuracy."]
	if not CampaignState.story_flags.get(&"mansion_nursery_ambush_cleared", false):
		return ["The toy chest is locked by a doll currently trying to bite the Fighter."]
	CampaignState.story_flags[&"mansion_nursery_cache_opened"] = true
	CampaignState.add_item(&"phoenix_tonic", 1, false)
	CampaignState.add_item(&"tonic", 2, false)
	CampaignState.loot_inventory.append({
		"instance_id": "mansion-nursery-locket",
		"id": &"nursery_locket",
		"base_name": "Nursery Locket",
		"display_name": "Rare Nursery Locket of Wakefulness",
		"slot": "accessory",
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
		"rarity": "Rare",
		"rarity_color": "#58a6ff",
		"modifiers": [{"name": "of Wakefulness", "stat": "spirit", "value": 5}, {"name": "of Celerity", "stat": "speed", "value": 3}],
		"kind": "gear",
		"source_pack": "resources_items_artifacts_loot",
	})
	return ["The toy chest contains supplies preserved outside ordinary time.", "Found 2 Tonics, a Phoenix Tonic, and a Rare Nursery Locket of Wakefulness."]


func _open_ballroom_gate() -> Array[String]:
	if CampaignState.story_flags.get(&"mansion_ballroom_open", false):
		return ["Both clock hands remain fixed in the ballroom lock at 4:44. The appointment waits beyond."]
	if not CampaignState.story_flags.get(&"mansion_hour_hand_found", false) or not CampaignState.story_flags.get(&"mansion_minute_hand_found", false):
		return ["The ballroom lock has two empty clock-hand sockets. The Mansion has hidden one answer in memory and another in childhood."]
	CampaignState.story_flags[&"mansion_ballroom_open"] = true
	return [
		"Ben places the Silver Hour Hand and Brass Minute Hand into the ballroom lock.",
		"The hands turn to 4:44. The double doors open onto a room that has been waiting since 1776.",
		"BEN: Our host is punctual. Let us disappoint it professionally.",
	]


func _align_chapel_glass() -> Array[String]:
	if CampaignState.story_flags.get(&"mansion_crypt_key_found", false):
		return ["The chapel glass remains aligned. The crypt key is already warm in Ben's pocket."]
	if not CampaignState.story_flags.get(&"mansion_temporal_secret_found", false):
		return ["The stained glass rejects ordinary time. The thirteenth resonance must be solved at the foyer clock first."]
	CampaignState.story_flags[&"mansion_crypt_key_found"] = true
	CampaignState.loot_inventory.append({
		"instance_id": "mansion-chapel-ward", "id": &"chapel_ward_charm", "base_name": "Chapel Ward Charm",
		"display_name": "Fixed Chapel Ward Charm", "slot": "accessory", "rarity": "Rare", "rarity_color": "#58a6ff",
		"modifiers": [{"name": "of Warding", "stat": "spirit", "value": 4}], "kind": "gear", "source_pack": "Haunted Mansion",
	})
	return ["The thirteenth chime aligns the chapel glass. A ward charm and the undercroft's crypt key slide from the altar.", "Crypt Key obtained; the sealed undercroft entrance opens."]


func _lower_attic_stair() -> Array[String]:
	if CampaignState.story_flags.get(&"mansion_attic_latch_open", false): return ["The attic stair remains lowered over the Antechamber."]
	CampaignState.story_flags[&"mansion_attic_latch_open"] = true
	CampaignState.add_item(&"anchor_dust", 1, false)
	return ["Ben lowers the attic stair and finds the Dollmaker's invoice tucked under its catch.", "The stair now gives the Antechamber a permanent return route."]
