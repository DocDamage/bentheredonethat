extends Node

const CONTROLLER_SCRIPT := preload("res://ben_rpg/world/campaign_area_layer_controller.gd")


class TestLayer extends Node2D:
	var areas: Array[StringName] = []

	func set_active_area(area: StringName) -> void:
		areas.append(area)


func _ready() -> void:
	var controller = CONTROLLER_SCRIPT.new()
	var ground := TestLayer.new()
	var foreground := TestLayer.new()
	controller.register(ground)
	controller.register(foreground)
	controller.register(ground)
	assert(controller.registered_layer_count() == 2)
	controller.set_active_area(&"manifest:HE-03")
	assert(ground.areas == [&"manifest:HE-03"])
	assert(foreground.areas == [&"manifest:HE-03"])
	foreground.free()
	assert(controller.registered_layer_count() == 1)
	controller.set_active_area(&"town")
	assert(ground.areas == [&"manifest:HE-03", &"town"])
	ground.free()
	print("CAMPAIGN_AREA_LAYER_CONTROLLER_SMOKE_OK broadcasts=true deduplicated=true stale_safe=true")
	get_tree().quit()
