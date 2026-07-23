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
