extends Node

const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	assert(FIELD_SCALE.MOVEMENT_CELL_PIXELS == 48)
	assert(FIELD_SCALE.LOGICAL_VIEWPORT_PIXELS == Vector2i(1920, 1080))
	assert(FIELD_SCALE.DEFAULT_WINDOW_PIXELS == Vector2i(960, 540))
	assert(FIELD_SCALE.world_size_for_cells(Vector2i(14, 10)) == Vector2i(672, 480))
	assert(FIELD_SCALE.camera_bounds_for_cells(Vector2i(26, 18)) == Rect2i(0, 0, 1248, 864))
	for source_density in [16, 24, 48, 96]:
		assert(FIELD_SCALE.is_supported_source_density(source_density))
		assert(FIELD_SCALE.source_density_scale(source_density) * source_density == FIELD_SCALE.MOVEMENT_CELL_PIXELS)
	assert(not FIELD_SCALE.is_supported_source_density(32))
	assert(FIELD_SCALE.source_density_scale(32) == 0.0)
	assert(FIELD_SCALE.snap_to_world_pixels(Vector2(19.4, -8.6)) == Vector2(19, -9))
	assert(FIELD_SCALE.is_pixel_aligned(Vector2(19, -9)))
	assert(not FIELD_SCALE.is_pixel_aligned(Vector2(19.2, -9)))
	var foyer := ROOM_REGISTRY.room(&"HM-02")
	assert(foyer.get("cameraBounds") == FIELD_SCALE.camera_bounds_for_cells(Vector2i(26, 18)))
	print("CAMPAIGN_FIELD_SCALE_SMOKE_OK cell=48 viewport=1920x1080 densities=16,24,48,96 camera=pixel_snapped")
	get_tree().quit()
