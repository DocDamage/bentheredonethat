extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.5)
	CampaignState.reset_new_game()
	var main := (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var dialogue := main.get_node_or_null("UI/DialogueLayout")
	var dialogue_text := main.get_node_or_null("UI/DialogueLayout/BoxMargins/TextMargins/DialogueText") as RichTextLabel
	if not dialogue or not dialogue_text or dialogue_text.get_theme_font_size("normal_font_size") != 144:
		_fail("Dialogue rich text did not apply the 1.5x scale")
		return
	var speaker := main.get_node_or_null("UI/DialogueLayout/BoxMargins/TextMargins/DialogueText/Speaker/NameLabel") as Label
	if not speaker or speaker.get_theme_font_size("font_size") != 144:
		_fail("Dialogue speaker label did not apply the 1.5x scale")
		return
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.0)
	main.queue_free()
	await get_tree().process_frame
	print("DIALOGUE_TEXT_SCALE_SMOKE_OK rich_text+speaker=1.5x")
	get_tree().quit(0)


func _fail(message: String) -> void:
	SettingsRepository.set_value(&"accessibility", &"text_scale", 1.0)
	printerr("DIALOGUE_TEXT_SCALE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
