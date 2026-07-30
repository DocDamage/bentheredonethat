class_name UniverseTreasureInteraction
extends Interaction

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TREASURE_VISUAL_PROFILE: StringName = &"universe_treasure_chest"

@export var cache_id: StringName = &"primeval_ruins_plinth"
@export var area_id: StringName = &"primeval_ruins"

@onready var _marker: Sprite2D = $TreasureMarker
var _marker_origin_y := -38.0
var _elapsed := 0.0


func _ready() -> void:
	_marker.texture = VISUAL_PROFILE_REGISTRY.new().texture(TREASURE_VISUAL_PROFILE)
	_marker_origin_y = _marker.position.y
	if not CampaignState.state_changed.is_connected(_refresh_marker):
		CampaignState.state_changed.connect(_refresh_marker)
	_refresh_marker()


func _process(delta: float) -> void:
	if not _marker.visible:
		return
	_elapsed += delta
	_marker.position.y = _marker_origin_y + roundf(sin(_elapsed * 3.2) * 2.0)


func _execute() -> void:
	var timeline := DialogicTimeline.new()
	timeline.events = apply_interaction()
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended


func apply_interaction(save_after := true, rng: RandomNumberGenerator = null) -> Array[String]:
	var result := CampaignState.claim_universe_treasure(cache_id, rng)
	if not bool(result.get("claimed", false)):
		return ["%s has already been claimed. Ben finds only an impeccably filed receipt." % String(result.get("name", "The cache"))]
	var reward_names: Array[String] = []
	for drop in result.get("loot", []):
		var quantity := int(drop.get("quantity", 1))
		var display_name := String(drop.get("display_name", drop.get("base_name", "Unknown item")))
		reward_names.append("%d %s" % [quantity, display_name] if quantity > 1 else display_name)
	var reward_line := "Found %d Duckets" % int(result.get("duckets", 0))
	if not reward_names.is_empty():
		reward_line += ", " + ", ".join(reward_names)
	reward_line += "."
	if save_after:
		CampaignState.save_game()
	return [String(result.get("description", "Ben opens the cache.")), reward_line]


func _refresh_marker() -> void:
	var definition: Dictionary = CampaignState.UNIVERSE_TREASURE_CACHES.get(cache_id, {})
	_marker.visible = not definition.is_empty() and not bool(CampaignState.story_flags.get(definition.get("flag", &""), false))
