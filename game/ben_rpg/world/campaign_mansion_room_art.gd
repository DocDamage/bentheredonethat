class_name CampaignMansionRoomArt
extends RefCounted

## Shared Haunted Mansion interior treatment. Every tile comes from the
## checksum-validated visual profile registry, so authored rooms retain the
## pack's texture density and palette instead of falling back to color blocks.

const CELL := 48
const WALL_ROWS := 4


static func draw_interior(canvas: CanvasItem, dimensions: Vector2i, profiles, style: StringName = &"hall") -> void:
	if dimensions == Vector2i.ZERO or profiles == null:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(dimensions * CELL))
	canvas.draw_rect(bounds, Color("100d14"), true)
	_draw_wall(canvas, dimensions, profiles, style)
	_draw_floor(canvas, dimensions, profiles, style)
	canvas.draw_line(Vector2(0, WALL_ROWS * CELL), Vector2(dimensions.x * CELL, WALL_ROWS * CELL), Color("171015"), 7.0)
	canvas.draw_line(Vector2(0, WALL_ROWS * CELL + 6), Vector2(dimensions.x * CELL, WALL_ROWS * CELL + 6), Color("8b665a"), 2.0)
	canvas.draw_rect(bounds, Color("5d4652"), false, 3.0)


static func _draw_wall(canvas: CanvasItem, dimensions: Vector2i, profiles, style: StringName) -> void:
	var nursery := style == &"nursery"
	var columns := 8 if nursery else 4
	for y in range(mini(WALL_ROWS, dimensions.y)):
		for x in range(dimensions.x):
			var profile_id := StringName("mansion_%swall_%d_%d" % ["nursery_" if nursery else "interior_", x % columns, y % 2])
			_draw_profile(canvas, profiles, profile_id, Vector2(x * CELL, y * CELL), _wall_tint(style))


static func _draw_floor(canvas: CanvasItem, dimensions: Vector2i, profiles, style: StringName) -> void:
	var floor_start := mini(WALL_ROWS, dimensions.y) * CELL
	var floor_profile := &"sandbox_haunted_stone" if style in [&"crypt", &"conservatory"] else &"sandbox_haunted_planks"
	var tint := Color("89909d") if style == &"crypt" else Color("a7b49f") if style == &"conservatory" else Color.WHITE
	for y in range(floor_start, dimensions.y * CELL, CELL):
		for x in range(0, dimensions.x * CELL, CELL):
			_draw_profile(canvas, profiles, floor_profile, Vector2(x, y), tint)
	# A restrained vignette keeps the playable center legible without obscuring
	# pixel detail or introducing a post-process blur.
	canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(CELL, dimensions.y * CELL)), Color(0.04, 0.025, 0.05, 0.55), true)
	canvas.draw_rect(Rect2(Vector2((dimensions.x - 1) * CELL, 0), Vector2(CELL, dimensions.y * CELL)), Color(0.04, 0.025, 0.05, 0.55), true)


static func _wall_tint(style: StringName) -> Color:
	match style:
		&"nursery": return Color("b9a9af")
		&"crypt": return Color("8d8b9c")
		&"conservatory": return Color("9aaf99")
		&"ballroom": return Color("b6949f")
		_: return Color.WHITE


static func _draw_profile(canvas: CanvasItem, profiles, profile_id: StringName, position: Vector2, tint: Color) -> void:
	if not profiles.has(profile_id):
		return
	var texture := profiles.texture(profile_id) as Texture2D
	if texture:
		canvas.draw_texture_rect_region(texture, Rect2(position, profiles.world_draw_size(profile_id)), profiles.region(profile_id), tint)
