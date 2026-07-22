extends Node

const CLUE_SCENE := preload("res://ben_rpg/world/mansion_clue_interaction.tscn")


func _ready() -> void:
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
	clock.apply_interaction(false)
	assert(CampaignState.story_flags.get(&"mansion_first_room_complete", false), "Returning with the ledger should solve the clock")
	assert(CampaignState.duckets == duckets_before + 30, "Puzzle reward should grant currency")
	assert(int(CampaignState.inventory.get(&"anchor_shard", 0)) == 1, "Puzzle should yield the multiversal anchor resource")
	assert(CampaignState.loot_inventory[-1]["rarity"] == "Rare", "Puzzle gear reward should retain rarity metadata")
	print("MANSION_PUZZLE_SMOKE_OK clues=clock>ledger>4:44 reward=anchor_shard+rare_key+30D")
	get_tree().quit(0)
