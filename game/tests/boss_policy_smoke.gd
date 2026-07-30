extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.duckets = 25
	CampaignState.add_item(&"anchor_shard", 1, false)
	assert(CampaignState.craft_invention(&"temporal_tuning_fork"), "The Mansion clock reward should craft a reusable time invention")
	var model := AtbBattleModel.new()
	var fixture_party: Array[StringName] = [&"ben", &"fighter"]
	model.setup(&"mansion_archive_boss", fixture_party, CampaignState.character_progress, 444)
	var boss: Dictionary = model.living("enemy")[0]
	var ben := model.get_actor(&"ben")
	var fighter := model.get_actor(&"fighter")
	var raptor := model.get_actor(&"velociraptor")
	assert(&"temporal_tuning" in ben["actions"], "The owned Temporal Tuning Fork should grant Ben its combat command")
	assert(model.status_summary(StringName(boss["id"])).contains("TICKING"), "The Mansion boss must begin in its ticking clock state")
	boss["atb"] = 100.0
	var opening_choice := model.choose_ai_action(StringName(boss["id"]))
	assert(opening_choice.get("action", &"") == &"spectral_touch", "The opening boss state should start with a readable normal attack")
	boss["atb"] = 100.0
	var telegraph_choice := model.choose_ai_action(StringName(boss["id"]))
	assert(telegraph_choice.has("telegraph") and String(telegraph_choice["telegraph"]).contains("Steal Time"), "The boss must telegraph Steal Time one turn before resolving it")
	assert(model.commit_boss_telegraph(StringName(boss["id"])), "A boss telegraph should consume its current turn")
	assert(model.status_summary(StringName(boss["id"])).contains("STEAL TIME!"), "The pending clock attack must be visible in the status HUD")
	ben["atb"] = 100.0
	var tuning_events := model.resolve_action(&"ben", &"temporal_tuning", [StringName(boss["id"])])
	assert(tuning_events.any(func(event: Dictionary) -> bool: return StringName(event.get("status", &"")) == &"time_tuned"), "Temporal Tuning must cancel the telegraphed attack")
	assert(not model.status_summary(StringName(boss["id"])).contains("STEAL TIME!"), "Canceled clock attacks must be removed from the status HUD")
	raptor["atb"] = 100.0
	boss["atb"] = 100.0
	model.resolve_action(&"velociraptor", &"raptor_distract", [StringName(boss["id"])])
	assert(float(boss["atb"]) <= 72.0, "ATB disruption should delay the boss's next clock turn")
	fighter["atb"] = 100.0
	model.resolve_action(&"fighter", &"defend", [&"fighter"])
	boss["atb"] = 100.0
	var guarded_events := model.resolve_action(StringName(boss["id"]), &"steal_time", [&"fighter"])
	var guarded_damage := 0
	for event in guarded_events:
		if event.get("type", "") == "damage":
			guarded_damage = int(event.get("amount", 0))
	assert(guarded_damage > 0 and guarded_damage <= 25, "Defend should remain a viable response to a clock strike")
	boss["hp"] = int(round(float(boss["max_hp"]) * 0.5))
	assert(model.status_summary(StringName(boss["id"])).contains("4:44 APPOINTMENT"), "The boss must expose its mid-fight 4:44 state")
	boss["hp"] = int(round(float(boss["max_hp"]) * 0.2))
	assert(model.status_summary(StringName(boss["id"])).contains("THIRTEENTH HOUR"), "The boss must expose its final thirteenth-hour state")
	print("BOSS_POLICY_SMOKE_OK states=ticking+appointment+thirteenth telegraph=visible counters=defend+delay+tuning invention=reusable")
	get_tree().quit(0)
