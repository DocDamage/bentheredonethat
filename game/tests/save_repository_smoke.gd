extends Node

const TEST_SAVE := "user://save_repository_smoke.json"
const SAVE_REPOSITORY := preload("res://ben_rpg/core/save_repository.gd")


func _ready() -> void:
	SAVE_REPOSITORY.cleanup(TEST_SAVE)
	CampaignState.reset_new_game()
	CampaignState.duckets = 71
	assert(CampaignState.save_game(TEST_SAVE) == OK, "The initial save should succeed")
	CampaignState.duckets = 133
	assert(CampaignState.save_game(TEST_SAVE) == OK, "The replacement save should succeed")
	var backup_path := ProjectSettings.globalize_path(TEST_SAVE + SAVE_REPOSITORY.BACKUP_SUFFIX)
	assert(FileAccess.file_exists(backup_path), "Replacing a save must retain a last-known-good backup")
	var primary_path := ProjectSettings.globalize_path(TEST_SAVE)
	var corrupt_file := FileAccess.open(primary_path, FileAccess.WRITE)
	assert(corrupt_file != null, "The test needs to corrupt only its isolated primary save")
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK, "A valid backup should recover a corrupt primary save")
	assert(CampaignState.duckets == 71, "Recovery must restore the complete previous transaction")
	var repaired: Variant = JSON.parse_string(FileAccess.get_file_as_string(primary_path))
	assert(repaired is Dictionary and int(repaired.get("duckets", -1)) == 71, "Recovery should repair the primary save")
	SAVE_REPOSITORY.cleanup(TEST_SAVE)
	print("SAVE_REPOSITORY_SMOKE_OK atomic=true backup=true recovery=true")
	get_tree().quit(0)
