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
	# Small blueprints are narrower than the 960x540 presentation viewport. A
	# deep neutral surround keeps the room reading as an intentional stage rather
	# than exposing the engine's gray clear color around it.
	canvas.draw_rect(Rect2(Vector2(-8 * CELL, -8 * CELL), Vector2((dimensions.x + 16) * CELL, (dimensions.y + 16) * CELL)), Color("09070d"), true)
	canvas.draw_rect(bounds, Color("100d14"), true)
	_draw_wall(canvas, dimensions, profiles, style)
	_draw_floor(canvas, dimensions, profiles, style)
	_draw_architectural_depth(canvas, dimensions, style)
	_draw_floor_composition(canvas, dimensions, style)
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
	# Wainscot, bays, and cornices break the atlas repeat into readable rooms.
	var wall_width := dimensions.x * CELL
	canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(wall_width, 13)), Color("161018"), true)
	canvas.draw_rect(Rect2(Vector2(0, 13), Vector2(wall_width, 5)), Color("755462"), true)
	canvas.draw_rect(Rect2(Vector2(0, 3 * CELL - 8), Vector2(wall_width, CELL + 8)), Color(0.12, 0.075, 0.11, 0.46), true)
	canvas.draw_line(Vector2(0, 3 * CELL - 8), Vector2(wall_width, 3 * CELL - 8), Color("98717c"), 3.0)
	for x in range(2, dimensions.x - 1, 4):
		var px := float(x * CELL)
		canvas.draw_rect(Rect2(Vector2(px - 5, 18), Vector2(10, 3 * CELL - 24)), Color("2b1b28"), true)
		canvas.draw_line(Vector2(px - 7, 18), Vector2(px - 7, 3 * CELL - 6), Color("76505f"), 2.0)
		canvas.draw_line(Vector2(px + 7, 18), Vector2(px + 7, 3 * CELL - 6), Color("140e16"), 2.0)
		_draw_sconce(canvas, Vector2(px, 92), style)


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


static func _draw_architectural_depth(canvas: CanvasItem, dimensions: Vector2i, style: StringName) -> void:
	var width := dimensions.x * CELL
	var height := dimensions.y * CELL
	canvas.draw_rect(Rect2(Vector2(0, WALL_ROWS * CELL + 8), Vector2(width, 14)), Color(0.025, 0.018, 0.028, 0.72), true)
	canvas.draw_line(Vector2(CELL, height - CELL), Vector2(width - CELL, height - CELL), Color(0.12, 0.07, 0.08, 0.72), 8.0)
	# Side alcoves visually compress broad rooms and create foreground-like depth
	# without changing their validated navigation cells.
	if dimensions.x >= 18:
		for side in [0, 1]:
			var left := 0.0 if side == 0 else width - 2.0 * CELL
			canvas.draw_rect(Rect2(Vector2(left, 2 * CELL), Vector2(2 * CELL, height - 2 * CELL)), Color(0.035, 0.022, 0.04, 0.56), true)
			var edge_x := 2.0 * CELL if side == 0 else width - 2.0 * CELL
			canvas.draw_line(Vector2(edge_x, 2 * CELL), Vector2(edge_x, height), Color("513746"), 4.0)


static func _draw_floor_composition(canvas: CanvasItem, dimensions: Vector2i, style: StringName) -> void:
	if dimensions.y <= WALL_ROWS + 3:
		return
	var floor_top := float((WALL_ROWS + 1) * CELL)
	var room_width := float(dimensions.x * CELL)
	var floor_bottom := float((dimensions.y - 1) * CELL)
	var margin_x := float(2 * CELL if dimensions.x < 20 else 3 * CELL)
	var available_height := floor_bottom - floor_top
	var rug_height := minf(3.0 * CELL, available_height - 20.0)
	var rug_top := floor_top + (available_height - rug_height) * 0.48
	var rug := Rect2(Vector2(margin_x, rug_top), Vector2(room_width - margin_x * 2.0, rug_height))
	var palette: Array[Color] = [Color("432331"), Color("a06a65"), Color("d0a06e")]
	match style:
		&"nursery": palette = [Color("493645"), Color("a58492"), Color("d1b3ae")]
		&"ballroom": palette = [Color("522636"), Color("c18a72"), Color("e2bd79")]
		&"crypt": palette = [Color("252638"), Color("666b83"), Color("a5a8b9")]
		&"conservatory": palette = [Color("24382e"), Color("658267"), Color("b1b978")]
	canvas.draw_rect(rug, palette[0], true)
	canvas.draw_rect(Rect2(rug.position + Vector2(12, 12), rug.size - Vector2(24, 24)), Color(0.03, 0.02, 0.03, 0.16), true)
	canvas.draw_rect(rug, palette[1], false, 6.0)
	canvas.draw_rect(rug.grow(-13), Color(palette[2], 0.78), false, 2.0)
	# Sparse diamonds give the eye scale and direction while preserving a clear
	# walkable corridor through the center.
	var motif_y := rug.position.y + rug.size.y * 0.5
	for motif_x in range(int(rug.position.x + CELL), int(rug.end.x - CELL), 2 * CELL):
		var center := Vector2(motif_x, motif_y)
		var points := PackedVector2Array([center + Vector2(0, -10), center + Vector2(16, 0), center + Vector2(0, 10), center + Vector2(-16, 0)])
		canvas.draw_colored_polygon(points, Color(palette[2], 0.34))
	for end_x in [rug.position.x + 18.0, rug.end.x - 18.0]:
		for fringe_y in range(int(rug.position.y + 12), int(rug.end.y - 8), 18):
			canvas.draw_line(Vector2(end_x, fringe_y), Vector2(end_x + (8 if end_x < room_width * 0.5 else -8), fringe_y), Color(palette[2], 0.42), 2.0)
	canvas.draw_line(Vector2(room_width * 0.5, rug.position.y + 18), Vector2(room_width * 0.5, rug.end.y - 18), Color(palette[1], 0.25), 2.0)


static func _draw_sconce(canvas: CanvasItem, position: Vector2, style: StringName) -> void:
	var glow := Color(0.48, 0.34, 0.22, 0.13) if style != &"crypt" else Color(0.35, 0.4, 0.55, 0.1)
	canvas.draw_circle(position, 31.0, glow)
	canvas.draw_line(position + Vector2(0, 8), position + Vector2(0, 22), Color("31212a"), 4.0)
	canvas.draw_circle(position, 6.0, Color("d8aa69") if style != &"crypt" else Color("9aa9c2"))


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
