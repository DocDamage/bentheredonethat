extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	assert(StringName(CampaignState.town_state_overlay().get("id", &"")) == &"survey", "A fresh campaign should start with the Survey town overlay.")
	for index in range(4):
		assert(CampaignState.build_facility(index, ["Cafe", "Library", "Clinic", "Armory"][index]), "The founding overlay fixture needs its civic facilities.")
	assert(StringName(CampaignState.town_state_overlay().get("id", &"")) == &"founding", "Four civic facilities should activate the Founding overlay.")
	CampaignState.mark_story_flag(&"haunted_mansion_scenario_complete")
	var early := CampaignState.town_state_overlay()
	assert(StringName(early.get("id", &"")) == &"early_anchors" and int(early.get("stabilized_universes", 0)) == 1, "The first stabilized anchor should activate the Early Anchors overlay.")
	CampaignState.mark_story_flag(&"asterion_station_complete")
	CampaignState.mark_story_flag(&"primeval_scenario_complete")
	assert(StringName(CampaignState.town_state_overlay().get("id", &"")) == &"multiversal", "Three stabilized worlds should activate the Multiversal Town overlay.")
	CampaignState.mark_story_flag(&"helios_scenario_complete")
	CampaignState.mark_story_flag(&"frosthold_scenario_complete")
	CampaignState.mark_story_flag(&"moonpetal_scenario_complete")
	CampaignState.mark_story_flag(&"empyreal_scenario_complete")
	var finale := CampaignState.town_state_overlay()
	assert(StringName(finale.get("id", &"")) == &"finale" and int(finale.get("stabilized_universes", 0)) == 7, "All stabilized anchors should activate the Finale/Postgame overlay.")
	print("TOWN_STATE_OVERLAY_SMOKE_OK states=survey+founding+early+multiversal+finale")
	get_tree().quit(0)
