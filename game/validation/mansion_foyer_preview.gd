extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(3, "Haunted Mansion")
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var player: Gamepiece = Player.gamepiece
	var cell := Vector2i(4, 38)
	player.position = Gameboard.cell_to_pixel(cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, cell)
	Camera.reset_position()
