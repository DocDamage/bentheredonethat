extends Node2D

## Review-only evidence for AF-01's required post-raid survivor-watch state.
## This deliberately does not admit the actors to the live streamer: their
## profile acceptance remains a separate reviewer decision.

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/ashfall_cinder_gate.tscn")
const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

const RESIDENTS := [

	{"actorId": &"af01_scrap_kid_field_actor", "profileId": &"af01_scrap_kid_south", "cell": Vector2i(6, 6)},
	{"actorId": &"af01_dust_hunter_field_actor", "profileId": &"af01_dust_hunter_south", "cell": Vector2i(13, 6)},
]


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"ashfall_cinder_gate_arrival_raid_cleared"] = true
	var room := ROOM_SCENE.instantiate() as Node2D
	if not room:
		_fail("AF-01 scene could not instantiate.")
		return
	add_child(room)
	var actor_layer := room.get_node_or_null("YSortedActorsAndProps") as Node2D
	if not actor_layer:
		_fail("AF-01 scene has no actor layer.")
		return
	var profiles := VISUAL_PROFILES.new()
	for resident in RESIDENTS:
		_install_resident(actor_layer, resident, profiles)
	var camera := Camera2D.new()
	camera.position = Vector2(500, 400)
	camera.zoom = Vector2(1.5, 1.5)
	add_child(camera)
	camera.make_current()
	for _frame in range(6):
		await get_tree().process_frame
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/af01-cinder-gate-scene-stabilized.png", "AF-01 Cinder Gate stabilized survivor-watch capture"):
		get_tree().quit(1)
		return
	print("AF01_CINDER_GATE_STABILIZED_CAPTURE_OK residents=2 anchors=P1,P2 review_required=true")
	CampaignState.reset_new_game()
	get_tree().quit(0)


func _install_resident(layer: Node2D, definition: Dictionary, profiles) -> void:
	var profile_id := StringName(definition.get("profileId", &""))
	var profile: Dictionary = profiles.get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var foot_anchor: Array = placement.get("footAnchor", [])
	if profile.is_empty() or foot_anchor.size() != 2:
		_fail("AF-01 capture profile is incomplete: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	if not texture:
		_fail("AF-01 capture profile has no texture: %s" % profile_id)
		return
	var sprite := Sprite2D.new()
	sprite.name = "ReviewActor_%s" % definition.get("actorId", &"")
	sprite.centered = false
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2((definition.get("cell", Vector2i.ZERO) as Vector2i) * 48) - Vector2(foot_anchor[0], foot_anchor[1])
	sprite.set_meta(&"visual_profile", profile_id)
	sprite.set_meta(&"review_only", true)
	layer.add_child(sprite)


func _fail(message: String) -> void:
	printerr("AF01_CINDER_GATE_STABILIZED_CAPTURE_FAILED: " + message)
	CampaignState.reset_new_game()
	get_tree().quit(1)
