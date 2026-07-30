extends Node

const CLUE_SCENE := preload("res://ben_rpg/world/mansion_clue_interaction.tscn")
const TEST_SAVE := "user://mansion_clock_puzzle_smoke.json"


func _ready() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	var clock := CLUE_SCENE.instantiate() as MansionClueInteraction
	clock.clue_kind = &"clock"
	var bookcase := CLUE_SCENE.instantiate() as MansionClueInteraction
	bookcase.clue_kind = &"bookcase"
	add_child(clock)
	add_child(bookcase)
	var first_clock := clock.apply_interaction(false)
	assert(CampaignState.story_flags.get(&"mansion_clock_examined", false), "Clock should reveal that a written clue is required")
	assert("thirteen" in first_clock[1], "The first clue should establish the impossible clock mechanism")
	bookcase.apply_interaction(false)
	assert(CampaignState.story_flags.get(&"mansion_ledger_found", false), "Bookcase should reveal the 4:44 ledger entry")
	var duckets_before := CampaignState.duckets
	var wrong_setting := clock.set_clock_time(&"03:13", false)
	assert(not CampaignState.story_flags.get(&"mansion_first_room_complete", false), "A wrong clock setting must not auto-solve the passage")
	assert("03:13" in wrong_setting[0], "Wrong clock settings should report specific state feedback")
	assert(CampaignState.save_game(TEST_SAVE) == OK, "An unsolved clock setting should save")
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK, "An unsolved clock setting should reload")
	assert(CampaignState.story_flags.get(&"mansion_clock_time", "") == "03:13" and not CampaignState.story_flags.get(&"mansion_first_room_complete", false), "Clock state must survive save/load without solving the passage")
	clock.set_clock_time(&"04:44", false)
	assert(CampaignState.story_flags.get(&"mansion_first_room_complete", false), "Selecting the ledger's 4:44 time should solve the clock")
	assert(CampaignState.duckets == duckets_before + 30, "Puzzle reward should grant currency")
	assert(int(CampaignState.inventory.get(&"anchor_shard", 0)) == 1, "Puzzle should yield the multiversal anchor resource")
	assert(CampaignState.loot_inventory[-1]["rarity"] == "Rare", "Puzzle gear reward should retain rarity metadata")
	CampaignState.SAVE_REPOSITORY.cleanup(TEST_SAVE)
	print("MANSION_PUZZLE_SMOKE_OK clues=clock>ledger>4:44 reward=anchor_shard+rare_key+30D")
	get_tree().quit(0)
