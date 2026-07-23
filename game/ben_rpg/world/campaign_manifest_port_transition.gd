class_name CampaignManifestPortTransition
extends AreaTransition

## The destination remains manifest data. This transition only performs the
## presentation blackout and asks the room runtime to replace the active room.

var room_runtime: Node
var destination_room_id: StringName = &""
var _transitioning := false

signal transition_finished


func _on_area_entered(area: Area2D) -> void:
	## A path that ends exactly on a streamed port can report the collision after
	## the Gamepiece's arrived signal. AreaTransition's stock implementation is
	## intentionally conservative about that case, but a manifest port is
	## unloaded after a successful handoff and can safely own it. Preserve the
	## standard blackout/movement sequence while accepting either callback order.
	if _transitioning or Cutscene.is_cutscene_in_progress() or not area.owner is Gamepiece:
		return
	_transitioning = true
	await super._on_area_entered(area)
	transition_finished.emit()


func _on_blackout() -> void:
	if not room_runtime or destination_room_id == &"":
		return
	if not _transitioning:
		## Focused contract fixtures invoke this hook directly to verify manifest
		## routing without presenting a field transition. Keep that supported.
		room_runtime.call_deferred(&"activate", destination_room_id)
		return
	if not transition_finished.is_connected(_activate_destination_room):
		## Replacing the room here would free this port while AreaTransition is
		## still awaiting its screen-clear sequence, leaving field input paused.
		## Activate only after the inherited transition has restored the field.
		transition_finished.connect(_activate_destination_room, CONNECT_ONE_SHOT)


func _activate_destination_room() -> void:
	if is_instance_valid(room_runtime) and destination_room_id != &"":
		room_runtime.call_deferred(&"activate", destination_room_id)
