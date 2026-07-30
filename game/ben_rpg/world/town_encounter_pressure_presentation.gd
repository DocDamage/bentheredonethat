class_name TownEncounterPressurePresentation
extends RefCounted

## Converts encounter-pressure state into presentation data.  It deliberately
## contains no UI nodes or CampaignState mutation, allowing the HUD controller
## to stay responsible only for applying the resulting display contract.

static func describe(data: Dictionary, fallback_ward_steps: int = 0) -> Dictionary:
	var ward_steps := int(data.get("ward_steps", fallback_ward_steps))
	var cooldown := int(data.get("cooldown", 0))
	var active := bool(data.get("active", false))
	if ward_steps > 0:
		return {&"visible": true, &"icon": "dfgui_icon-pouch.png", &"text": "RIFT WARD  •  %d SAFE STEPS" % ward_steps, &"color": Color(0.5, 0.96, 1.0), &"maximum": 120, &"value": ward_steps}
	if cooldown > 0:
		return {&"visible": true, &"icon": "dfgui_icon-shield.png", &"text": "ENCOUNTER GRACE  •  %d STEPS" % cooldown, &"color": Color(0.58, 0.94, 0.72), &"maximum": 8, &"value": cooldown}
	if not active:
		return {&"visible": false}
	var threshold := maxi(1, int(data.get("threshold", 1)))
	var steps := clampi(int(data.get("steps", 0)), 0, threshold)
	var ratio := float(steps) / float(threshold)
	var state := "CALM" if ratio < 0.35 else ("RISING" if ratio < 0.72 else "IMMINENT")
	var color := Color(0.72, 0.9, 1.0) if ratio < 0.35 else (Color(1.0, 0.8, 0.42) if ratio < 0.72 else Color(1.0, 0.42, 0.38))
	return {&"visible": true, &"icon": "dfgui_icon-monsterbook.png", &"text": "ENCOUNTER PRESSURE  •  %s" % state, &"color": color, &"maximum": threshold, &"value": steps}
