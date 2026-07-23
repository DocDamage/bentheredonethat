class_name CampaignManifestPortTransition
extends AreaTransition

## The destination remains manifest data. This transition only performs the
## presentation blackout and asks the room runtime to replace the active room.

var room_runtime: Node
var destination_room_id: StringName = &""


func _on_blackout() -> void:
	if room_runtime and destination_room_id != &"":
		room_runtime.call_deferred(&"activate", destination_room_id)
