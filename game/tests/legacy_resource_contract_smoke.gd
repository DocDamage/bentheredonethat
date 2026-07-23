extends Node


const ATLAS_PATHS := [
	"res://assets/items/key.atlastex",
	"res://assets/items/coin.atlastex",
	"res://assets/items/bomb.atlastex",
	"res://assets/items/wand_red.atlastex",
	"res://assets/items/wand_blue.atlastex",
	"res://assets/items/wand_green.atlastex",
	"res://overworld/characters/generic.atlastex",
	"res://overworld/characters/ghost.atlastex",
	"res://overworld/characters/gobot.atlastex",
	"res://overworld/characters/knight.atlastex",
	"res://overworld/characters/monk.atlastex",
	"res://overworld/characters/smith.atlastex",
	"res://overworld/characters/thief.atlastex",
	"res://overworld/characters/wizard.atlastex",
]


func _ready() -> void:
	for atlas_path in ATLAS_PATHS:
		var texture := load(atlas_path)
		if not texture is AtlasTexture or not texture.atlas:
			printerr("LEGACY_RESOURCE_CONTRACT_SMOKE_FAILED atlas=" + atlas_path)
			get_tree().quit(1)
			return
		if not ResourceLoader.exists(texture.atlas.resource_path):
			printerr("LEGACY_RESOURCE_CONTRACT_SMOKE_FAILED source=" + texture.atlas.resource_path)
			get_tree().quit(1)
			return
		print("LEGACY_RESOURCE_CONTRACT_ENTRY atlas=%s source=%s region=%s" % [atlas_path, texture.atlas.resource_path, texture.region])
	print("LEGACY_RESOURCE_CONTRACT_SMOKE_OK atlases=%d" % ATLAS_PATHS.size())
	get_tree().quit(0)
