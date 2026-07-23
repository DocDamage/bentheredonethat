class_name CampaignFieldScale
extends RefCounted

## Canonical field-space contract shared by the campaign room graph, renderers,
## and field camera.  Source art is normalized before it reaches this boundary;
## this class deliberately does not make an arbitrary source crop look valid.

const MOVEMENT_CELL_PIXELS := 48
const LOGICAL_VIEWPORT_PIXELS := Vector2i(1920, 1080)
const DEFAULT_WINDOW_PIXELS := Vector2i(960, 540)
const FIELD_CHARACTER_VISIBLE_HEIGHT := Vector2i(42, 72)

## Field composition uses character height rather than raw source dimensions.
## These are review ranges, not automatic art-direction approval: a profile may
## fit its range and still be rejected for silhouette, perspective, or palette.
const FIELD_SEMANTIC_SIZE_RANGES := {
	&"doorway": Vector2i(36, 96),
	&"single_story_facade": Vector2i(96, 240),
	&"multi_story_facade": Vector2i(192, 432),
	&"tree": Vector2i(96, 336),
	&"counter": Vector2i(36, 72),
	&"bed": Vector2i(72, 144),
	&"chair": Vector2i(30, 72),
	&"treasure": Vector2i(30, 72),
	&"boss": Vector2i(96, 288),
}

const SOURCE_DENSITY_SCALES := {
	16: 3.0,
	24: 2.0,
	48: 1.0,
	96: 0.5,
}

## The only render scales admitted to new field profiles. Half scale supports
## 96px sources; integer scales support the 16/24/48px sources. Odd source
## dimensions are rounded once to their nearest final world pixel.
const APPROVED_FIELD_RENDER_SCALES := [0.5, 1.0, 2.0, 3.0]


static func world_size_for_cells(cells: Vector2i) -> Vector2i:
	return cells * MOVEMENT_CELL_PIXELS


static func camera_bounds_for_cells(cells: Vector2i, origin: Vector2i = Vector2i.ZERO) -> Rect2i:
	return Rect2i(origin, world_size_for_cells(cells))


static func source_density_scale(source_tile_pixels: int) -> float:
	return float(SOURCE_DENSITY_SCALES.get(source_tile_pixels, 0.0))


static func is_supported_source_density(source_tile_pixels: int) -> bool:
	return SOURCE_DENSITY_SCALES.has(source_tile_pixels)


static func semantic_size_range(semantic_id: StringName) -> Vector2i:
	return FIELD_SEMANTIC_SIZE_RANGES.get(semantic_id, Vector2i.ZERO)


static func is_visible_height_in_range(height: float) -> bool:
	return height >= FIELD_CHARACTER_VISIBLE_HEIGHT.x and height <= FIELD_CHARACTER_VISIBLE_HEIGHT.y


static func is_semantic_height_in_range(semantic_id: StringName, height: float) -> bool:
	var range := semantic_size_range(semantic_id)
	return range != Vector2i.ZERO and height >= range.x and height <= range.y


static func is_approved_field_render_scale(scale: float) -> bool:
	for approved_scale in APPROVED_FIELD_RENDER_SCALES:
		if is_equal_approx(scale, approved_scale):
			return true
	return false


static func matching_field_render_scale(source_size: Vector2i, world_draw_size: Vector2i) -> float:
	if source_size.x <= 0 or source_size.y <= 0 or world_draw_size.x <= 0 or world_draw_size.y <= 0:
		return 0.0
	for approved_scale in APPROVED_FIELD_RENDER_SCALES:
		if world_draw_size == Vector2i(roundi(source_size.x * approved_scale), roundi(source_size.y * approved_scale)):
			return approved_scale
	return 0.0


static func scaled_anchor(source_anchor: Vector2, render_scale: float) -> Vector2:
	return snap_to_world_pixels(source_anchor * render_scale)


static func is_pixel_aligned(world_position: Vector2) -> bool:
	return is_equal_approx(world_position.x, roundf(world_position.x)) and is_equal_approx(world_position.y, roundf(world_position.y))


static func snap_to_world_pixels(world_position: Vector2) -> Vector2:
	return world_position.round()


static func camera_frame(extents: Rect2i, cell_size: Vector2i, viewport_size: Vector2, global_scale: Vector2, current_position: Vector2) -> Dictionary:
	## Reproduces the field camera's limit/centering math without a live viewport.
	## Limits are global canvas coordinates; the returned position stays in world
	## coordinates and changes only on axes locked by a room smaller than view.
	if cell_size.x <= 0 or cell_size.y <= 0 or global_scale.x <= 0.0 or global_scale.y <= 0.0:
		return {}
	var boundary_left := extents.position.x * cell_size.x
	var boundary_top := extents.position.y * cell_size.y
	var boundary_right := extents.end.x * cell_size.x
	var boundary_bottom := extents.end.y * cell_size.y
	var viewport_world := viewport_size / global_scale
	var position := current_position
	var locked_x := boundary_right - boundary_left < viewport_world.x
	var locked_y := boundary_bottom - boundary_top < viewport_world.y
	var limit_left: int
	var limit_right: int
	var limit_top: int
	var limit_bottom: int
	if locked_x:
		position.x = (extents.position.x + extents.size.x / 2.0) * cell_size.x
		limit_left = int((position.x - viewport_world.x * 0.5) * global_scale.x)
		limit_right = int((position.x + viewport_world.x * 0.5) * global_scale.x)
	else:
		limit_left = int(boundary_left * global_scale.x)
		limit_right = int(boundary_right * global_scale.x)
	if locked_y:
		position.y = (extents.position.y + extents.size.y / 2.0) * cell_size.y
		limit_top = int((position.y - viewport_world.y * 0.5) * global_scale.y)
		limit_bottom = int((position.y + viewport_world.y * 0.5) * global_scale.y)
	else:
		limit_top = int(boundary_top * global_scale.y)
		limit_bottom = int(boundary_bottom * global_scale.y)
	return {
		"position": snap_to_world_pixels(position),
		"limits": Rect2i(limit_left, limit_top, limit_right - limit_left, limit_bottom - limit_top),
		"lockedX": locked_x,
		"lockedY": locked_y,
	}
