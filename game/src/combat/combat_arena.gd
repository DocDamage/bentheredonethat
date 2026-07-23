## An arena is the editor-configured environment for a battle. It is a Control node that contains 
## the combat participants and details (such as background, foreground, music, etc.).
class_name CombatArena extends Control

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

## The music that will be automatically played during this combat instance.
@export var music: AudioStream
@export var background_visual_profile: StringName


func _ready() -> void:
	if background_visual_profile == &"":
		return
	var profiles := VISUAL_PROFILE_REGISTRY.new()
	if not profiles.has(background_visual_profile):
		push_error("Combat arena references missing visual profile: %s" % background_visual_profile)
		return
	var background := get_node_or_null("Background") as TextureRect
	if background:
		background.texture = profiles.texture(background_visual_profile)


## Retrieve the list of the combat participants, in [BattlerRoster] form.
func get_battler_roster() -> BattlerRoster:
	return $Battlers as BattlerRoster
