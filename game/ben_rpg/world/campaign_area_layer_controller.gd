class_name CampaignAreaLayerController
extends RefCounted

## Broadcasts the current area to independently authored render layers. Keeping
## this list outside bootstrap lets a room layer opt in without adding another
## universe-specific activation branch to campaign lifecycle code.

var _layers: Array[CanvasItem] = []


func register(layer: CanvasItem) -> void:
	if layer and layer not in _layers:
		_layers.append(layer)


func set_active_area(area: StringName) -> void:
	for layer in _layers:
		if is_instance_valid(layer) and layer.has_method(&"set_active_area"):
			layer.call(&"set_active_area", area)


func registered_layer_count() -> int:
	var live_layers := 0
	for layer in _layers:
		if is_instance_valid(layer):
			live_layers += 1
	return live_layers
