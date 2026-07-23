class_name CampaignFieldScale
extends RefCounted

## Canonical field-space contract shared by the campaign room graph, renderers,
## and field camera.  Source art is normalized before it reaches this boundary;
## this class deliberately does not make an arbitrary source crop look valid.

const MOVEMENT_CELL_PIXELS := 48
const LOGICAL_VIEWPORT_PIXELS := Vector2i(1920, 1080)
const DEFAULT_WINDOW_PIXELS := Vector2i(960, 540)
const FIELD_CHARACTER_VISIBLE_HEIGHT := Vector2i(42, 72)

const SOURCE_DENSITY_SCALES := {
	16: 3.0,
	24: 2.0,
	48: 1.0,
	96: 0.5,
}


static func world_size_for_cells(cells: Vector2i) -> Vector2i:
	return cells * MOVEMENT_CELL_PIXELS


static func camera_bounds_for_cells(cells: Vector2i, origin: Vector2i = Vector2i.ZERO) -> Rect2i:
	return Rect2i(origin, world_size_for_cells(cells))


static func source_density_scale(source_tile_pixels: int) -> float:
	return float(SOURCE_DENSITY_SCALES.get(source_tile_pixels, 0.0))


static func is_supported_source_density(source_tile_pixels: int) -> bool:
	return SOURCE_DENSITY_SCALES.has(source_tile_pixels)


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
