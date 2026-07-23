class_name CampaignWorldCatalog
extends RefCounted

## Immutable world-selection and town-presentation content.  CampaignState
## keeps compatibility aliases while mutable anchors and story flags remain in
## its serialized runtime domain.

const UNIVERSE_DEFINITIONS := {
	&"haunted_mansion": {
		"name": "The House at 4:44", "building": "Haunted Mansion", "destination": &"haunted_mansion",
		"description": "A time-struck manor whose clocks remember a history that never happened.",
		"mandatory_first": true, "required_recruits": [&"fighter"], "required_flags": [], "anchor_flag": &"haunted_mansion_anchor_built",
	},
	&"asterion_station": {
		"name": "Asterion Station", "building": "Observatory", "destination": &"asterion_station",
		"description": "A derelict agricultural station still enforcing its final work shift.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [&"mansion_archive_boss_defeated"], "anchor_flag": &"asterion_anchor_built",
	},
	&"primeval_expanse": {
		"name": "Primeval Expanse", "building": "Trailhead Lodge", "destination": &"primeval_expanse",
		"description": "A Stone Age municipality trying to regulate dinosaurs with traffic signals and cave computers.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [&"asterion_station_complete"], "anchor_flag": &"primeval_anchor_built",
	},
	&"helios_arcology": {
		"name": "Helios Arcology", "building": "Afterlight Club", "destination": &"helios_arcology",
		"description": "A spotless sky city that outlawed night after deciding sleep was economically suspicious.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [&"asterion_station_complete"], "anchor_flag": &"helios_anchor_built",
	},
	&"frosthold_kingdom": {
		"name": "Frosthold Kingdom", "building": "Cold Storage", "destination": &"frosthold_kingdom",
		"description": "A frozen court where winter is permanent, heat is contraband, and the royal treasury has begun auditing body temperature.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [], "required_any_flags": [&"primeval_scenario_complete", &"helios_scenario_complete"], "anchor_flag": &"frosthold_anchor_built",
	},
	&"moonpetal_court": {
		"name": "Moonpetal Court", "building": "Tea House", "destination": &"moonpetal_court",
		"description": "A shrine-city trapped in a perfect festival night, where a smiling magistrate taxes memories and notarizes illusions.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [&"primeval_scenario_complete", &"helios_scenario_complete", &"frosthold_scenario_complete"], "anchor_flag": &"moonpetal_anchor_built",
	},
	&"empyreal_court": {
		"name": "Empyreal Court", "building": "Belfry", "destination": &"empyreal_court",
		"description": "A celestial republic where gravity, weather, and miracles have all acquired fees, forms, and armed enforcement.",
		"mandatory_first": false, "required_recruits": [], "required_flags": [&"moonpetal_scenario_complete"], "anchor_flag": &"empyreal_anchor_built",
	},
}

const TOWN_STATE_OVERLAYS := {
	&"survey": {"name": "Survey", "description": "Fresh stakes, quiet roads, and enough room for a company to become a town.", "tint": Color(0.24, 0.15, 0.05, 0.035), "accent": Color(0.96, 0.76, 0.30, 0.52)},
	&"founding": {"name": "Founding", "description": "The first civic block is lit; construction still has the stronger voice.", "tint": Color(0.08, 0.18, 0.07, 0.035), "accent": Color(0.58, 0.92, 0.42, 0.54)},
	&"early_anchors": {"name": "Early Anchors", "description": "The town has begun importing impossible weather, visitors, and practical optimism.", "tint": Color(0.05, 0.15, 0.22, 0.055), "accent": Color(0.35, 0.88, 1.0, 0.58)},
	&"multiversal": {"name": "Multiversal Town", "description": "Several stabilized worlds now leave visible traces in New Philadelphia's evening glow.", "tint": Color(0.16, 0.08, 0.24, 0.065), "accent": Color(0.82, 0.50, 1.0, 0.62)},
	&"finale": {"name": "Finale and Postgame", "description": "All anchors are steady. The town's shared lights now answer one another across worlds.", "tint": Color(0.22, 0.16, 0.03, 0.075), "accent": Color(1.0, 0.84, 0.36, 0.70)},
}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if UNIVERSE_DEFINITIONS.size() != 7:
		errors.append("World catalog must define all seven universe anchors.")
	for universe_id in UNIVERSE_DEFINITIONS:
		var definition: Dictionary = UNIVERSE_DEFINITIONS[universe_id]
		for key in ["name", "building", "destination", "description", "anchor_flag"]:
			if String(definition.get(key, "")).is_empty():
				errors.append("World catalog %s is missing %s." % [universe_id, key])
	if TOWN_STATE_OVERLAYS.size() != 5:
		errors.append("World catalog must retain five town-state overlays.")
	return PackedStringArray(errors)
