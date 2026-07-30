class_name CampaignAreaPresence
extends RefCounted

## Classifies a field cell for HUD and controller presentation without owning
## navigation, camera limits, or area activation.  The bootstrap remains the
## composition root; callers can consume this small immutable snapshot instead
## of duplicating universe-bound checks.

static func snapshot(campaign: Node, cell: Vector2i) -> Dictionary:
	var mansion := Rect2i(campaign.MANSION_ORIGIN, campaign.MANSION_SIZE).has_point(cell)
	var mansion_room := 0
	if mansion:
		var local: Vector2i = cell - campaign.MANSION_ORIGIN
		if local.x >= 20:
			mansion_room = 5
		elif local.y >= 10 and local.x >= 10:
			mansion_room = 4
		elif local.y >= 10:
			mansion_room = 3
		elif local.x >= 10:
			mansion_room = 2
		else:
			mansion_room = 1
	return {
		&"town": Rect2i(campaign.TOWN_ORIGIN, campaign.TOWN_SIZE).has_point(cell),
		&"mansion": mansion,
		&"mansion_room": mansion_room,
		&"station": Rect2i(campaign.STATION_ORIGIN, campaign.STATION_SIZE).has_point(cell),
		&"primeval": Rect2i(campaign.PRIMEVAL_ORIGIN, campaign.PRIMEVAL_SIZE).has_point(cell),
		&"helios": Rect2i(campaign.HELIOS_ORIGIN, campaign.HELIOS_SIZE).has_point(cell),
		&"frosthold": Rect2i(campaign.FROSTHOLD_ORIGIN, campaign.FROSTHOLD_SIZE).has_point(cell),
		&"moonpetal": Rect2i(campaign.MOONPETAL_ORIGIN, campaign.MOONPETAL_SIZE).has_point(cell),
		&"empyreal": Rect2i(campaign.EMPYREAL_ORIGIN, campaign.EMPYREAL_SIZE).has_point(cell),
	}
