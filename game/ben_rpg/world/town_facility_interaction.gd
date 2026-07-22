class_name TownFacilityInteraction
extends Interaction

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"

@export var facility_name := "Cafe"
var menu: CampaignMenu


func _ready() -> void:
	super._ready()
	var definition := CampaignState.facility_definition(facility_name)
	var icon_path := UI_ROOT + "/" + String(definition.get("icon", "dfgui_icon-info.png"))
	if ResourceLoader.exists(icon_path):
		$ServiceMarker.texture = load(icon_path)
	$ServiceLabel.text = "%s • INTERACT" % facility_name.to_upper()


func _execute() -> void:
	if not menu:
		return
	menu.open_service(facility_name)
	if not menu.visible:
		return
	await menu.menu_closed
