class_name CampaignEndingOverlay
extends CanvasLayer

signal finished

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"

var _page_index := 0
var _title: Label
var _body: Label
var _page_label: Label
var _advance_button: Button
var _pages: Array[Dictionary] = []


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	hide()


func present() -> void:
	_page_index = 0
	_pages = _ending_pages()
	_refresh_page()
	show()
	if _advance_button:
		_advance_button.grab_focus()


func advance() -> void:
	if _pages.is_empty():
		return
	if _page_index < _pages.size() - 1:
		_page_index += 1
		_refresh_page()
		return
	finished.emit()
	hide()
	queue_free()


func page_count() -> int:
	return _pages.size()


func _ending_pages() -> Array[Dictionary]:
	var civic_choice := "The Library keeps the Mansion's impossible records, so every future inventor can question a bad rule."
	if bool(CampaignState.story_flags.get(&"mansion_notes_circulated", false)):
		civic_choice = "The Café and Clinic turn the Mansion's recovered records into an evening safety watch for the whole town."
	return [
		{
			"title": "THE SKY IS NOT FOR SALE",
			"body": "The High Comptroller's final lien dissolves above Empyreal Court. Ben refuses to replace one authority with another: every universe keeps its own people, its own weather, and the right to decide what a door is for.\n\nLincoln writes the Tribunal's new charter in plain language: no world may be governed without a voice at the table. Gandhi secures its first clause of mercy: no frightened citizen can be made collateral for someone else's stability.\n\nThe Archangel Commander lowers their weapon—not in surrender, but in relief. The Tribunal's gravity is now public infrastructure, maintained by consent instead of decree.",
			"button": "READ THE CONSEQUENCES",
		},
		{
			"title": "NEW PHILADELPHIA ANSWERS",
			"body": "Back home, the fault-line lamps stop flickering like warnings and begin shining like invitations. Recruits, residents, and visitors share the plaza without anyone needing to pay a toll to stand upright.\n\n%s\n\nLincoln turns the expedition rules into civic promises. Gandhi opens the Clinic's night watch to every visitor, whether or not they have a world left to return to. Franklin & Company remains a company, but it is no longer a rescue operation. It is a promise to leave every door better than it was found." % civic_choice,
			"button": "VIEW CREDITS",
		},
		{
			"title": "FRANKLIN & COMPANY",
			"body": "BENJAMIN FRANKLIN — inventor, negotiator, and habitual breaker of impossible contracts\nABRAHAM LINCOLN — protector, civic leader, and keeper of the charter\nMAHATMA GANDHI — healer, de-escalator, and guardian of mercy\n\nTHE FIGHTER, ASTRONAUT, CAVEMAN, NEON VIPER, KITSUNE EMPRESS, FROST LICH EMPEROR, ARCHANGEL COMMANDER — the company that made every argument louder, kinder, and considerably stranger\n\nNEW PHILADELPHIA — a town built one practical kindness at a time\n\nTHANK YOU FOR PLAYING BEN THERE, DONE THAT.",
			"button": "OPEN THE POSTGAME",
		},
		{
			"title": "THE WORK CONTINUES",
			"body": "POSTGAME UNLOCKED\n\nYou are returning to New Philadelphia in free roam. Continue building facilities, hire and train the company, finish optional quests, and revisit every stabilized universe.\n\nThe Library's new Tribunal Ledger also offers a no-reward rematch with the High Comptroller whenever the party is ready. Your final save will be marked in town now.",
			"button": "BEGIN POSTGAME",
		},
	]


func _build_interface() -> void:
	var root := Control.new()
	root.name = "EndingInterface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.012, 0.03, 0.95)
	root.add_child(shade)
	for band_data in [
		[Rect2(0, 116, 1120, 6), Color(0.24, 0.86, 1.0, 0.28)],
		[Rect2(720, 910, 1200, 4), Color(1.0, 0.7, 0.28, 0.42)],
		[Rect2(0, 944, 780, 2), Color(0.72, 0.48, 1.0, 0.36)],
	]:
		var band := ColorRect.new()
		band.position = band_data[0].position
		band.size = band_data[0].size
		band.color = band_data[1]
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(band)

	var panel := PanelContainer.new()
	panel.position = Vector2(280, 152)
	panel.size = Vector2(1360, 760)
	panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 24)
	panel.add_child(layout)

	_page_label = Label.new()
	_page_label.name = "PageLabel"
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.add_theme_font_size_override("font_size", 24)
	_page_label.add_theme_color_override("font_color", Color(0.5, 0.88, 1.0))
	layout.add_child(_page_label)

	_title = Label.new()
	_title.name = "EndingTitle"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 52)
	_title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
	layout.add_child(_title)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 3)
	divider.color = Color(0.42, 0.82, 1.0, 0.6)
	layout.add_child(divider)

	_body = Label.new()
	_body.name = "EndingBody"
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size", 30)
	_body.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	layout.add_child(_body)

	_advance_button = Button.new()
	_advance_button.name = "EndingAdvance"
	_advance_button.custom_minimum_size = Vector2(0, 82)
	_advance_button.add_theme_font_size_override("font_size", 30)
	_advance_button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	_advance_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_advance_button.add_theme_stylebox_override("normal", _button_style())
	_advance_button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.9, 0.58)))
	_advance_button.add_theme_stylebox_override("focus", _button_style(Color(1.0, 0.9, 0.58)))
	_advance_button.add_theme_stylebox_override("pressed", _button_style(Color(0.62, 0.68, 0.78)))
	_advance_button.pressed.connect(advance)
	layout.add_child(_advance_button)


func _refresh_page() -> void:
	if _pages.is_empty():
		return
	var page := _pages[_page_index]
	_page_label.text = "EPILOGUE  %d / %d" % [_page_index + 1, _pages.size()]
	_title.text = String(page.get("title", ""))
	_body.text = String(page.get("body", ""))
	_advance_button.text = String(page.get("button", "CONTINUE"))


func _panel_style() -> StyleBoxTexture:
	var style := _framed_style()
	style.content_margin_left = 54
	style.content_margin_right = 54
	style.content_margin_top = 38
	style.content_margin_bottom = 38
	return style


func _button_style(tint := Color.WHITE) -> StyleBoxTexture:
	var style := _framed_style()
	style.modulate_color = tint
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style


func _framed_style() -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 7)
	return style
