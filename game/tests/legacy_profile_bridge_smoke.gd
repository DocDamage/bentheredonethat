extends Node

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const BATTLE_SCENES := {
	&"legacy_bear_battle_actor": preload("res://combat/battlers/bear/bear_anim.tscn"),
	&"legacy_bugcat_battle_actor": preload("res://combat/battlers/bugcat/bugcat_anim.tscn"),
	&"legacy_squirrel_battle_actor": preload("res://combat/battlers/squirrel/squirrel_anim.tscn"),
	&"legacy_wolf_battle_actor": preload("res://combat/battlers/wolf/wolf_anim.tscn"),
}
const FIELD_SCENES := {
	&"legacy_generic_field_actor": preload("res://overworld/characters/generic_character_gfx.tscn"),
	&"legacy_gobot_field_actor": preload("res://overworld/characters/gobot_gfx.tscn"),
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var profiles := VISUAL_PROFILE_REGISTRY.new()
	for profile_id in BATTLE_SCENES:
		var visual: BattlerAnim = BATTLE_SCENES[profile_id].instantiate() as BattlerAnim
		add_child(visual)
		await get_tree().process_frame
		var sprite := visual.get_node_or_null("Pivot/Sprite2D") as Sprite2D
		assert(sprite and sprite.texture == profiles.texture(profile_id), "Legacy battler sprite did not resolve its profile: %s" % profile_id)
		assert(visual.battler_icon == profiles.texture(profile_id), "Legacy battler icon did not resolve its profile: %s" % profile_id)
		visual.queue_free()
	for profile_id in FIELD_SCENES:
		var visual: Node = FIELD_SCENES[profile_id].instantiate()
		add_child(visual)
		await get_tree().process_frame
		var sprite := visual.get_node_or_null("Anchor/Sprite") as Sprite2D
		assert(sprite and sprite.texture == profiles.texture(profile_id), "Legacy field sprite did not resolve its profile: %s" % profile_id)
		visual.queue_free()
	await get_tree().process_frame
	print("LEGACY_PROFILE_BRIDGE_SMOKE_OK battle_profiles=%d field_profiles=%d registry=true" % [BATTLE_SCENES.size(), FIELD_SCENES.size()])
	get_tree().quit()
