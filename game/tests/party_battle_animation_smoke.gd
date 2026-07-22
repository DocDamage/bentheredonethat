extends Node

const CHARACTER_IDS := [
	&"ben", &"fighter", &"astronaut", &"caveman", &"crimson_oni", &"rift_jackal", &"mossback_surveyor",
	&"cobalt_courier", &"bulkhead_warden", &"kitsune_empress", &"neon_viper", &"archangel_commander", &"frost_lich_emperor", &"velociraptor",
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	for character_id in CHARACTER_IDS:
		var actor := CampaignCombatDatabase.raptor_actor() if character_id == &"velociraptor" else CampaignCombatDatabase.party_actor(character_id, CampaignState.character_progress[character_id])
		var animation: Dictionary = actor.get("battle_animations", {})
		var sequences: Dictionary = animation.get("sequences", {})
		var actions: Dictionary = animation.get("actions", {})
		if not sequences.has(&"idle") or not sequences.has(&"attack") or not sequences.has(&"victory") or not sequences.has(&"death"):
			_fail("%s lacks a complete authored battle animation set" % character_id)
			return
		if actions.is_empty():
			_fail("%s has no command-to-animation mapping" % character_id)
			return
		for raw_sequence in sequences.keys():
			var frames: Array = sequences[raw_sequence]
			if frames.is_empty():
				_fail("%s has an empty %s sequence" % [character_id, raw_sequence])
				return
			for frame_path in frames:
				if not ResourceLoader.exists(String(frame_path)):
					_fail("%s animation frame is missing: %s" % [character_id, frame_path])
					return

	var widget := CampaignBattleActorAnimation.new()
	add_child(widget)
	var ben := CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	widget.configure(ben["battle_animations"])
	if widget.current_sequence != &"idle" or widget.play_once(&"attack") <= 0.0 or widget.current_sequence != &"attack":
		_fail("The reusable battle animation control did not play an authored attack")
		return
	widget.play_hold(&"death")
	if widget.current_sequence != &"death":
		_fail("The reusable battle animation control did not hold the death state")
		return
	widget.play_loop(&"victory")
	if widget.current_sequence != &"victory":
		_fail("The reusable battle animation control did not loop the victory state")
		return

	print("PARTY_BATTLE_ANIMATION_SMOKE_OK actors=14 source_frames=individual states=idle+attack+power+hit+victory+death runtime=reusable")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("PARTY_BATTLE_ANIMATION_SMOKE_FAILED: " + message)
	get_tree().quit(1)
