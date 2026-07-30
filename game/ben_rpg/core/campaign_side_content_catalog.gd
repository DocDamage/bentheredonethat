class_name CampaignSideContentCatalog
extends RefCounted

## Campaign-wide optional content. Every reward path is explicitly one-shot;
## rematches are rewardless and no record is a prerequisite for a main quest.

const OPTIONAL_QUEST_IDS := [
	&"company_at_work", &"echoes_on_paper", &"the_mansions_second_opinion",
]

const RARE_EVENTS := {
	&"midnight_library_exchange": {
		"unlockFlag": &"mansion_archive_boss_defeated", "claimedFlag": &"rare_midnight_library_exchange_claimed",
		"reward": {"duckets": 0, "items": {&"research_notes": 1}}, "reaction": "Lincoln records the witness account while Gandhi keeps the late archive open without charge.",
	},
	&"clinic_dawn_watch": {
		"unlockFlag": &"helios_scenario_complete", "claimedFlag": &"rare_clinic_dawn_watch_claimed",
		"reward": {"duckets": 20, "items": {&"tonic": 1}}, "reaction": "Gandhi turns the first natural sunrise into a public clinic shift.",
	},
	&"tribunal_open_house": {
		"unlockFlag": &"postgame_unlocked", "claimedFlag": &"rare_tribunal_open_house_claimed",
		"reward": {"duckets": 0, "items": {&"anchor_dust": 1}}, "reaction": "Residents from every stabilized address annotate Lincoln's public Tribunal charter.",
	},
}

const REMATCHES := {
	&"high_comptroller": {"encounterId": &"empyreal_high_comptroller", "unlockFlag": &"postgame_unlocked", "rewards": false},
}

const POSTGAME_REACTIONS := {
	&"ben": "Every repaired address remains independent; Franklin & Company maintains doors only by invitation.",
	&"lincoln": "The Tribunal charter stays open to amendment by every represented world.",
	&"gandhi": "The Clinic's night watch welcomes visitors without demanding allegiance or payment.",
	&"residents": "Rotating home cohorts visit New Philadelphia without abandoning their canonical homes.",
}


static func claim_rare_event(event_id: StringName) -> Dictionary:
	var event: Dictionary = RARE_EVENTS.get(event_id, {})
	if event.is_empty() or not bool(CampaignState.story_flags.get(StringName(event.get("unlockFlag", &"")), false)):
		return {}
	var claimed_flag := StringName(event.get("claimedFlag", &""))
	if claimed_flag == &"" or bool(CampaignState.story_flags.get(claimed_flag, false)):
		return {}
	CampaignState.story_flags[claimed_flag] = true
	var reward: Dictionary = event.get("reward", {})
	var duckets := int(reward.get("duckets", 0))
	if duckets > 0:
		CampaignState.adjust_duckets(duckets, &"rare_event", event_id, false)
	for raw_item_id in (reward.get("items", {}) as Dictionary):
		CampaignState.add_item(StringName(raw_item_id), int(reward["items"][raw_item_id]), false, &"rare_event", event_id)
	CampaignState.state_changed.emit()
	return {"id": event_id, "reward": reward.duplicate(true), "reaction": event.get("reaction", "")}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for quest_id in OPTIONAL_QUEST_IDS:
		var quest: Dictionary = CampaignState.QUEST_DEFINITIONS.get(quest_id, {})
		if quest.is_empty() or StringName(quest.get("category", &"side")) == &"main":
			errors.append("Optional quest %s is missing or classified as main content." % quest_id)
	for event_id in RARE_EVENTS:
		var event: Dictionary = RARE_EVENTS[event_id]
		if StringName(event.get("unlockFlag", &"")) == &"" or StringName(event.get("claimedFlag", &"")) == &"":
			errors.append("Rare event %s lacks unlock/claim guards." % event_id)
		if not (event.get("reward", {}) as Dictionary).has("items"):
			errors.append("Rare event %s lacks an explicit reward contract." % event_id)
	for rematch_id in REMATCHES:
		var rematch: Dictionary = REMATCHES[rematch_id]
		if bool(rematch.get("rewards", true)) or not CampaignCombatDatabase.has_encounter(StringName(rematch.get("encounterId", &""))):
			errors.append("Rematch %s must use an authored encounter with rewards disabled." % rematch_id)
	if POSTGAME_REACTIONS.keys().size() != 4 or not POSTGAME_REACTIONS.has(&"lincoln") or not POSTGAME_REACTIONS.has(&"gandhi"):
		errors.append("Postgame reactions must cover the protagonist trio and resident population.")
	return PackedStringArray(errors)
