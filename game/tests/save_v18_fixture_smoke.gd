extends Node

const FIXTURE := "res://tests/fixtures/save_v18_baseline.json"
const TEST_SAVE := "user://save_v18_baseline.json"


func _ready() -> void:
	var fixture_text := FileAccess.get_file_as_string(FIXTURE)
	assert(not fixture_text.is_empty(), "The archived version-18 fixture must be readable")
	var fixture_copy := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	assert(fixture_copy != null, "The isolated test run must accept requested fixture saves")
	fixture_copy.store_string(fixture_text)
	fixture_copy.close()
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK, "The version-18 fixture must load")
	assert(CampaignState.duckets == 73 and CampaignState.built_facilities.size() == 3, "The fixture's mutable state must survive migration")
	assert(CampaignState.save_game(TEST_SAVE) == OK, "The loaded fixture must save through the atomic repository")
	var summary := CampaignState.read_save_summary(TEST_SAVE)
	assert(bool(summary.get("valid", false)) and int(summary.get("version", 0)) == CampaignState.SAVE_VERSION, "Saving a loaded fixture must upgrade it to the current schema")
	print("SAVE_V18_FIXTURE_SMOKE_OK migration=v18_to_v%d save_repository=true facilities=3" % CampaignState.SAVE_VERSION)
	get_tree().quit(0)
