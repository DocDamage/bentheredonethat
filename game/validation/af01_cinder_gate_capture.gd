extends Node2D

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const DEAD_TREE_PATH := "res://ben_rpg/visual_assets/derived/ashfall_cinder_gate_dead_tree.png"


func _ready() -> void:
	_capture.call_deferred()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("201719"), true)
	draw_rect(Rect2(0, 365, 960, 175), Color("55413b"), true)
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 408), Vector2(x + 28, 408), Color("806052"), 3.0)
		draw_line(Vector2(x + 18, 456), Vector2(x + 42, 456), Color("35262a"), 2.0)
	draw_line(Vector2(0, 365), Vector2(960, 365), Color("bf744f"), 4.0)


func _capture() -> void:
	var title := Label.new()
	title.text = "ASHFALL  •  CINDER GATE"
	title.position = Vector2(48, 42)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("ffd6a0"))
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Prototype prop-scale capture  •  visual review required"
	subtitle.position = Vector2(50, 88)
	subtitle.add_theme_font_size_override("font_size", 19)
	subtitle.add_theme_color_override("font_color", Color("d9a889"))
	add_child(subtitle)
	var image := Image.load_from_file(DEAD_TREE_PATH)
	if not image:
		push_error("AF-01 prototype source could not load: %s" % DEAD_TREE_PATH)
		get_tree().quit(1)
		return
	var tree := Sprite2D.new()
	tree.texture = ImageTexture.create_from_image(image)
	tree.centered = false
	tree.scale = Vector2(3.0, 3.0)
	tree.position = Vector2(384, 228)
	tree.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(tree)
	var beacon := Label.new()
	beacon.text = "AIR-QUALITY BEACON"
	beacon.position = Vector2(552, 410)
	beacon.add_theme_font_size_override("font_size", 18)
	beacon.add_theme_color_override("font_color", Color("ffd06f"))
	add_child(beacon)
	for _frame in range(4):
		await get_tree().process_frame
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/af01-cinder-gate-prototype.png", "AF-01 Cinder Gate prototype capture"):
		get_tree().quit(1)
		return
	print("AF01_CINDER_GATE_CAPTURE_OK path=res://validation/af01-cinder-gate-prototype.png visual_review_only=true")
	get_tree().quit(0)
