class_name CampaignTitleScreen
extends CanvasLayer

signal mode_selected(mode: StringName)

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"
const BEN_PORTRAIT := "res://game_assets/characters/Main Character/Ben_Franklin/rotations/south.png"

@export var save_path := CampaignState.DEFAULT_SAVE_PATH

var campaign: Node
var suppress_quit := false
var _continue_button: Button
var _save_detail: Label
var _status_label: Label
var _first_focus: Button


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	CampaignState.pause_play_session()
	FieldEvents.input_paused.emit(true)
	_refresh_continue()
	if _first_focus:
		_first_focus.grab_focus()


func choose_mode(mode: StringName) -> bool:
	_status_label.text = ""
	var accepted := false
	match mode:
		&"new":
			accepted = campaign != null and campaign.start_new_campaign()
		&"continue":
			accepted = campaign != null and campaign.continue_campaign(save_path)
			if not accepted:
				_status_label.text = "That save could not be loaded. The file was left untouched."
				_refresh_continue()
		&"sandbox":
			accepted = campaign != null and campaign.start_sandbox_campaign()
		&"quit":
			if suppress_quit:
				_status_label.text = "Quit is disabled in this validation session."
				return false
			get_tree().quit()
			accepted = true
	if accepted:
		mode_selected.emit(mode)
	return accepted


func _build_interface() -> void:
	var root := Control.new()
	root.name = "TitleInterface"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.012, 0.028, 0.92)
	root.add_child(shade)

	# Subtle fault-line bands let the laboratory remain visible without making
	# the title screen look like a disconnected menu scene.
	for data in [
		[Rect2(0, 112, 1110, 6), Color(0.2, 0.82, 1.0, 0.22)],
		[Rect2(0, 126, 920, 2), Color(0.95, 0.66, 0.22, 0.5)],
		[Rect2(820, 910, 1100, 4), Color(0.54, 0.24, 0.9, 0.28)],
	]:
		var band := ColorRect.new()
		band.position = data[0].position
		band.size = data[0].size
		band.color = data[1]
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(band)

	var crest := TextureRect.new()
	crest.position = Vector2(142, 150)
	crest.size = Vector2(84, 84)
	crest.texture = load(UI_ROOT + "/dfgui_icon-crown.png")
	crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(crest)

	var title := Label.new()
	title.position = Vector2(238, 144)
	title.size = Vector2(770, 100)
	title.text = "BEN THERE, DONE THAT"
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	title.add_theme_color_override("font_shadow_color", Color(0.05, 0.02, 0.0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 5)
	title.add_theme_constant_override("shadow_offset_y", 5)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(246, 232)
	subtitle.size = Vector2(720, 72)
	subtitle.text = "A FRANKLIN & COMPANY MULTIVERSAL RPG"
	subtitle.add_theme_font_size_override("font_size", 30)
	subtitle.add_theme_color_override("font_color", Color(0.52, 0.88, 1.0))
	root.add_child(subtitle)

	var portrait_well := Control.new()
	portrait_well.position = Vector2(260, 360)
	portrait_well.size = Vector2(360, 360)
	root.add_child(portrait_well)
	var frame := TextureRect.new()
	frame.position = Vector2(6, 6)
	frame.size = Vector2(348, 348)
	frame.texture = load(UI_ROOT + "/dfgui_portraitframe2.png")
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_well.add_child(frame)
	var ben_atlas := AtlasTexture.new()
	ben_atlas.atlas = load(BEN_PORTRAIT)
	ben_atlas.region = Rect2(20, 15, 48, 58)
	var ben := TextureRect.new()
	ben.position = Vector2(92, 72)
	ben.size = Vector2(176, 220)
	ben.texture = ben_atlas
	ben.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ben.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_well.add_child(ben)

	var premise := Label.new()
	premise.position = Vector2(120, 760)
	premise.size = Vector2(820, 150)
	premise.text = "FOUND A TOWN.  HIRE THE IMPOSSIBLE.\nBUILD DOORS INTO OTHER UNIVERSES."
	premise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	premise.add_theme_font_size_override("font_size", 34)
	premise.add_theme_color_override("font_color", Color(0.91, 0.93, 1.0))
	root.add_child(premise)

	var menu_panel := PanelContainer.new()
	menu_panel.position = Vector2(1060, 150)
	menu_panel.size = Vector2(700, 770)
	menu_panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(menu_panel)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 18)
	menu_panel.add_child(menu)

	var menu_heading := Label.new()
	menu_heading.text = "THE FAULT LINE AWAITS"
	menu_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_heading.add_theme_font_size_override("font_size", 39)
	menu_heading.add_theme_color_override("font_color", Color(1.0, 0.86, 0.47))
	menu.add_child(menu_heading)

	_save_detail = Label.new()
	_save_detail.custom_minimum_size = Vector2(0, 126)
	_save_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_detail.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_save_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_detail.add_theme_font_size_override("font_size", 27)
	_save_detail.add_theme_color_override("font_color", Color(0.66, 0.79, 0.92))
	menu.add_child(_save_detail)

	var new_button := _title_button("NEW ADVENTURE", UI_ROOT + "/dfgui_icon-crown.png", &"new")
	menu.add_child(new_button)
	_first_focus = new_button
	_continue_button = _title_button("CONTINUE", UI_ROOT + "/dfgui_icon-clock.png", &"continue")
	menu.add_child(_continue_button)
	var sandbox := _title_button("SANDBOX WORKSHOP", UI_ROOT + "/dfgui_icon-crafthammer.png", &"sandbox")
	menu.add_child(sandbox)
	var quit := _title_button("QUIT DESKTOP", UI_ROOT + "/dfgui_icon-settings.png", &"quit")
	menu.add_child(quit)

	_status_label = Label.new()
	_status_label.custom_minimum_size.y = 62
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_font_size_override("font_size", 25)
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	menu.add_child(_status_label)

	var help := Label.new()
	help.position = Vector2(0, 1008)
	help.size = Vector2(1920, 48)
	help.text = "D-PAD / ARROWS: CHOOSE     •     A / ENTER: CONFIRM     •     ANY MODERN CONTROLLER SUPPORTED"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_theme_font_size_override("font_size", 25)
	help.add_theme_color_override("font_color", Color(0.55, 0.67, 0.82))
	root.add_child(help)


func _refresh_continue() -> void:
	var summary := CampaignState.read_save_summary(save_path)
	var valid := bool(summary.get("valid", false))
	_continue_button.disabled = not valid
	_continue_button.focus_mode = Control.FOCUS_ALL if valid else Control.FOCUS_NONE
	if not valid:
		_save_detail.text = "NO CAMPAIGN SAVE FOUND\nNew Adventure begins in Ben's laboratory."
		return
	_save_detail.text = "%s\nPLAY TIME  %s     •     %d DUCKETS\n%d FACILITIES     •     %d COMPANY MEMBERS" % [
		String(summary.get("location", "Unknown")),
		CampaignState.format_play_time(float(summary.get("play_time_seconds", 0.0))),
		int(summary.get("duckets", 0)),
		int(summary.get("facilities", 0)),
		int(summary.get("party_size", 1)),
	]


func _title_button(text: String, icon_path: String, mode: StringName) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 88)
	button.add_theme_font_size_override("font_size", 32)
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _button_style())
	button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("focus", _button_style(Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.62, 0.68, 0.78)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.4, 0.43, 0.5, 0.72)))
	button.icon = load(icon_path)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 50)
	button.pressed.connect(choose_mode.bind(mode))
	return button


func _panel_style() -> StyleBoxTexture:
	var style := _framed_style()
	style.content_margin_left = 34
	style.content_margin_right = 34
	style.content_margin_top = 30
	style.content_margin_bottom = 30
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
