extends DialogicNode_StyleLayer

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"


func _ready():
	super._ready()
	_apply_campaign_skin()
	
	Dialogic.timeline_started.connect(func(): show())
	Dialogic.timeline_ended.connect(func(): hide())
	hide()


func _apply_campaign_skin() -> void:
	var margins := get_node_or_null("BoxMargins") as MarginContainer
	var old_back := get_node_or_null("BoxMargins/BoxBack") as ColorRect
	if not margins:
		return
	if old_back:
		old_back.color = Color(0.015, 0.022, 0.05, 0.97)
	var frame := NinePatchRect.new()
	frame.name = "DarkRpgFrame"
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	frame.texture = atlas
	frame.patch_margin_left = 7
	frame.patch_margin_top = 7
	frame.patch_margin_right = 7
	frame.patch_margin_bottom = 7
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margins.add_child(frame)
	# Keep the dark BoxBack behind the decorative frame; text and choices remain
	# above it. Placing the frame first let the opaque back cover the supplied art.
	margins.move_child(frame, 1)
	var choices := get_node_or_null("BoxMargins/Choices")
	if choices:
		for child in choices.get_children():
			if child is Button:
				_skin_choice(child)


func _skin_choice(button: Button) -> void:
	for state in ["normal", "hover", "focus", "pressed"]:
		var style := StyleBoxTexture.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = load(UI_PARTY_HUD)
		atlas.region = Rect2(2, 2, 53, 53)
		style.texture = atlas
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			style.set_texture_margin(side, 7)
		style.modulate_color = Color(1.0, 0.9, 0.6) if state in ["hover", "focus"] else Color.WHITE
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
