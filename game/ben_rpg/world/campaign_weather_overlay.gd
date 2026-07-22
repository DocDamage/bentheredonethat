class_name CampaignWeatherOverlay
extends Node2D

## Accessibility-aware environmental accents for the active campaign room.
##
## These are intentionally simple world-space marks rather than a screen-space
## particle system: they preserve the pixel-art presentation, remain stable at
## every camera zoom, and can be reduced or frozen by the persisted options.

const TILE := 48
const PARTICLES_PER_ROOM := 36
const AREA_CELLS := {
	&"mansion_foyer": Vector2i(0, 0),
	&"mansion_archive": Vector2i(10, 0),
	&"mansion_gallery": Vector2i(0, 10),
	&"mansion_nursery": Vector2i(10, 10),
	&"mansion_ballroom": Vector2i(20, 0),
	&"primeval_grove": Vector2i(0, 0),
	&"primeval_village": Vector2i(10, 0),
	&"primeval_ruins": Vector2i(20, 0),
	&"primeval_nest": Vector2i(10, 10),
	&"primeval_caldera": Vector2i(20, 10),
	&"frosthold_gate": Vector2i(0, 0),
	&"frosthold_market": Vector2i(10, 0),
	&"frosthold_causeway": Vector2i(20, 0),
	&"frosthold_rune_hall": Vector2i(10, 10),
	&"frosthold_throne": Vector2i(20, 10),
	&"moonpetal_gate": Vector2i(0, 0),
	&"moonpetal_court": Vector2i(10, 0),
	&"moonpetal_garden": Vector2i(20, 0),
	&"moonpetal_bell_walk": Vector2i(10, 10),
	&"moonpetal_palace": Vector2i(20, 10),
}
const WORLD_ORIGINS := {
	&"mansion": Vector2i(0, 32),
	&"primeval": Vector2i(72, 32),
	&"frosthold": Vector2i(144, 32),
	&"moonpetal": Vector2i(180, 32),
}

var active_area: StringName = &"lab"
var _phase := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not SettingsRepository.settings_changed.is_connected(_on_settings_changed):
		SettingsRepository.settings_changed.connect(_on_settings_changed)
	queue_redraw()


func _process(delta: float) -> void:
	if is_animated():
		_phase = fmod(_phase + delta * 0.55, 1.0)
		queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func visible_particle_count() -> int:
	if _weather_kind() == &"":
		return 0
	return roundi(PARTICLES_PER_ROOM * _weather_density())


func is_motion_reduced() -> bool:
	return bool(SettingsRepository.value(&"accessibility", &"reduce_motion", false))


func is_animated() -> bool:
	return visible_particle_count() > 0 and not is_motion_reduced()


func motion_phase() -> float:
	return _phase


func _on_settings_changed(_settings: Dictionary) -> void:
	queue_redraw()


func _weather_density() -> float:
	return clampf(float(SettingsRepository.value(&"accessibility", &"weather_density", 1.0)), 0.0, 1.0)


func _weather_kind() -> StringName:
	if active_area.begins_with("frosthold"):
		return &"snow"
	if active_area.begins_with("moonpetal"):
		return &"petal"
	if active_area.begins_with("primeval"):
		return &"mote"
	if active_area.begins_with("mansion"):
		return &"dust"
	return &""


func _room_origin() -> Vector2:
	var region := active_area.get_slice("_", 0)
	var world_cell: Vector2i = WORLD_ORIGINS.get(StringName(region), Vector2i.ZERO)
	var room_cell: Vector2i = AREA_CELLS.get(active_area, Vector2i.ZERO)
	return Vector2((world_cell + room_cell) * TILE)


func _draw() -> void:
	var kind := _weather_kind()
	var count := visible_particle_count()
	if kind == &"" or count == 0:
		return
	var origin := _room_origin()
	for index in count:
		var base := origin + Vector2(18 + posmod(index * 97, 438), 12 + posmod(index * 53, 438))
		var drift := Vector2.ZERO
		if not is_motion_reduced():
			var wave := _phase * TAU + float(index) * 0.73
			drift = Vector2(roundf(sin(wave) * 6.0), roundf(fmod(_phase * 90.0 + index * 17.0, 42.0)))
		var point := base + drift
		match kind:
			&"snow":
				draw_line(point, point + Vector2(-1, 4), Color(0.86, 0.95, 1.0, 0.76), 1.0, true)
			&"petal":
				draw_line(point, point + Vector2(2, 1), Color(1.0, 0.65, 0.8, 0.7), 1.0, true)
			&"mote":
				draw_circle(point, 1.0, Color(1.0, 0.8, 0.37, 0.6))
			&"dust":
				draw_circle(point, 1.0, Color(0.78, 0.7, 0.58, 0.46))
