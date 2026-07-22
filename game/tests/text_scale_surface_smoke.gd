extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.5)
	var title := (load("res://ben_rpg/ui/campaign_title_screen.tscn") as PackedScene).instantiate() as CampaignTitleScreen
	title.suppress_quit = true
	get_tree().root.add_child(title)
	await get_tree().process_frame
	if not _has_scaled_text(title):
		_fail("Title did not apply the text-scale preference")
		return
	title.queue_free()

	var battle := (load("res://ben_rpg/combat/campaign_battle.tscn") as PackedScene).instantiate() as CampaignBattle
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	if not _has_scaled_text(battle):
		_fail("Battle did not apply the text-scale preference")
		return
	battle.queue_free()
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.0)
	await get_tree().process_frame
	print("TEXT_SCALE_SURFACE_SMOKE_OK title+battle=font_overrides_scaled")
	get_tree().quit(0)


func _has_scaled_text(surface: Node) -> bool:
	for node in surface.find_children("*", "Control", true, false):
		if node is Label or node is Button or node is LineEdit:
			if node.has_meta("campaign_base_font_size") and node.get_theme_font_size("font_size") > int(node.get_meta("campaign_base_font_size")):
				return true
	return false


func _fail(message: String) -> void:
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.0)
	printerr("TEXT_SCALE_SURFACE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
