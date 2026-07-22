extends Node

const TEST_SAVE := "user://quest_choice_smoke.json"
const QUEST_ID := &"the_mansions_second_opinion"


func _ready() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	CampaignState.reset_new_game()
	CampaignState.mark_story_flag(&"mansion_first_room_complete")
	var choices := CampaignState.quest_choices(QUEST_ID)
	assert(choices.size() == 2, "The Mansion follow-up should present two explicit, non-blocking outcomes.")
	var duckets_before := CampaignState.duckets
	var notes_before := int(CampaignState.inventory.get(&"research_notes", 0))
	var dust_before := int(CampaignState.inventory.get(&"anchor_dust", 0))
	assert(CampaignState.select_quest_choice(QUEST_ID, &"archive"), "The archive outcome should be selectable once.")
	assert(not CampaignState.select_quest_choice(QUEST_ID, &"circulate"), "A committed quest choice must not be changed or rewarded twice.")
	var runtime := CampaignState.quest_state(QUEST_ID)
	assert(StringName(runtime.get("choice_id", &"")) == &"archive" and String(runtime.get("choice_outcome", "")).contains("Library"), "The committed outcome should persist in the quest state.")
	assert(CampaignState.story_flags.get(&"mansion_notes_archived", false) and not CampaignState.story_flags.get(&"mansion_notes_circulated", false), "The archive choice should record only its own narrative consequence.")
	assert(CampaignState.duckets == duckets_before + 30, "Choice and quest-completion Ducket rewards should both be granted exactly once.")
	assert(int(CampaignState.inventory.get(&"research_notes", 0)) == notes_before + 2 and int(CampaignState.inventory.get(&"anchor_dust", 0)) == dust_before + 1, "The archive variant should grant its authored research materials.")
	assert(StringName(CampaignState.quest_state(QUEST_ID).get("status", &"")) == &"complete", "Selecting the outcome should complete the resolved side quest.")
	assert(CampaignState.save_game(TEST_SAVE) == OK, "A committed quest choice should save.")
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK, "A committed quest choice should load.")
	runtime = CampaignState.quest_state(QUEST_ID)
	assert(StringName(runtime.get("choice_id", &"")) == &"archive" and bool(runtime.get("choice_reward_claimed", false)), "Quest choice state and one-time reward marker should survive reload.")
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	print("QUEST_CHOICE_SMOKE_OK choice=archive variant_rewards=true outcome=persisted idempotent=true")
	get_tree().quit(0)
