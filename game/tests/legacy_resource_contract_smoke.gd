extends Node


const ATLAS_PATHS := [
	"res://assets/items/key.tres",
	"res://assets/items/coin.tres",
	"res://assets/items/bomb.tres",
	"res://assets/items/wand_red.tres",
	"res://assets/items/wand_blue.tres",
	"res://assets/items/wand_green.tres",
	"res://overworld/characters/generic.tres",
	"res://overworld/characters/ghost.tres",
	"res://overworld/characters/gobot.tres",
	"res://overworld/characters/knight.tres",
	"res://overworld/characters/monk.tres",
	"res://overworld/characters/smith.tres",
	"res://overworld/characters/thief.tres",
	"res://overworld/characters/wizard.tres",
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
