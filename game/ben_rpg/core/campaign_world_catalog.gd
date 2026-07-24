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


const UNIVERSE_SAVE_POINTS := {
	&"mansion_archive": {"name": "Archive Anchor Clock", "cell": Vector2i(309, 7), "flag": &"mansion_archive_save_found", "streamed": true},
	&"mansion_ballroom_antechamber": {"name": "Nursery Respite Clock", "cell": Vector2i(309, 8), "flag": &"mansion_ballroom_respite_found", "streamed": true},
	&"asterion_medical": {"name": "Asterion Medical Beacon", "cell": Vector2i(357, 10), "flag": &"asterion_save_found", "streamed": true},
	&"primeval_nest": {"name": "Relay Nest Anchor Totem", "cell": Vector2i(408, 10), "flag": &"primeval_save_found", "streamed": true},
	&"helios_clinic": {"name": "Afterlight Clinic Beacon", "cell": Vector2i(458, 10), "flag": &"helios_save_found", "streamed": true},
	&"frosthold_rune_hall": {"name": "Rune Hall Save Brazier", "cell": Vector2i(512, 11), "flag": &"frosthold_save_found", "streamed": true},
	&"moonpetal_bell_walk": {"name": "Bell Walk Memory Lantern", "cell": Vector2i(558, 11), "flag": &"moonpetal_save_found", "streamed": true},
	&"empyreal_aerie": {"name": "Aerie Anchor Crystal", "cell": Vector2i(611, 11), "flag": &"empyreal_save_found", "streamed": true},
}

const UNIVERSE_TREASURE_CACHES := {
	&"primeval_ruins_plinth": {
		"name": "Misfiled Fossil Plinth", "flag": &"primeval_ruins_treasure_claimed",
		"loot_encounter": &"primeval_grove_intro", "duckets": 28,
		"description": "Ben rotates the plinth's municipal seal. A fossilized field kit rises from the stone with a citation attached.",
	},
	&"helios_market_terminal": {
		"name": "Unclaimed Property Terminal", "flag": &"helios_market_treasure_claimed",
		"loot_encounter": &"helios_skybridge_intro", "duckets": 46,
		"description": "The terminal recognizes Ben as the oldest unresolved customer complaint and releases an unclaimed equipment parcel.",
	},
	&"frosthold_heat_cache": {
		"name": "Seized Heat Cache", "flag": &"frosthold_market_treasure_claimed",
		"loot_encounter": &"frosthold_gate_intro", "duckets": 54,
		"description": "Ben finds a confiscated supply case beneath the market brazier. Its contents are charged with unlawful warmth.",
	},
	&"moonpetal_offering": {
		"name": "Unremembered Offering", "flag": &"moonpetal_garden_treasure_claimed",
		"loot_encounter": &"moonpetal_gate_intro", "duckets": 62,
		"description": "The garden offering bears Ben's name in handwriting he has not used yet. The magistrate forgot to inventory it.",
	},
	&"empyreal_tithe_basin": {
		"name": "Misallocated Tithe Basin", "flag": &"empyreal_garden_treasure_claimed",
		"loot_encounter": &"empyreal_landing_intro", "duckets": 76,
		"description": "Ben appeals the fountain's ownership ledger. It refunds an equipment tithe plus several centuries of negligible interest.",
	},
}

const EQUIPMENT_SLOTS := [&"weapon", &"head", &"body", &"hands", &"accessory", &"charm"]

const EQUIPMENT_AFFINITIES := {
	&"ben": [&"field", &"martial", &"technical", &"occult", &"frontline", &"scout", &"radiant"],
	&"lincoln": [&"field", &"martial", &"frontline", &"radiant"],
	&"gandhi": [&"field", &"occult", &"scout", &"radiant"],
	&"fighter": [&"field", &"martial", &"frontline"],
	&"astronaut": [&"field", &"technical", &"scout"],
	&"caveman": [&"field", &"martial", &"frontline"],
	&"crimson_oni": [&"field", &"martial", &"frontline"],
	&"rift_jackal": [&"field", &"martial", &"occult", &"scout"],
	&"mossback_surveyor": [&"field", &"frontline"],
	&"cobalt_courier": [&"field", &"martial", &"technical", &"scout"],
	&"bulkhead_warden": [&"field", &"martial", &"technical", &"frontline"],
	&"kitsune_empress": [&"field", &"occult", &"scout"],
	&"neon_viper": [&"field", &"technical", &"scout"],
	&"archangel_commander": [&"field", &"occult", &"frontline", &"radiant"],
	&"frost_lich_emperor": [&"field", &"technical", &"occult"],
}

const JOB_QUALITY_NAMES := ["Routine", "Competent", "Excellent", "Masterwork", "Legendary"]

const SERVICE_ITEM_CATALOG := {
	&"tonic": {"name": "Tonic", "price": 18, "icon": "dfgui_icon-cauldron.png", "description": "Restores 70 HP to one ally in battle."},
	&"ether": {"name": "Leyden Ether", "price": 32, "icon": "dfgui_icon-wand.png", "description": "Restores 24 MP to one ally in battle."},
	&"smelling_salts": {"name": "Smelling Salts", "price": 24, "icon": "dfgui_icon-pouch.png", "description": "Removes Poison, Slow, and Shock."},
	&"phoenix_tonic": {"name": "Phoenix Tonic", "price": 58, "icon": "dfgui_icon-goblet.png", "description": "Revives one fallen company member with 25% HP."},
	&"provisions": {"name": "Expedition Provisions", "price": 14, "icon": "dfgui_icon-food.png", "description": "Facility material used for meals and longer assignments."},
	&"rift_ward": {"name": "Rift Ward", "price": 36, "icon": "dfgui_icon-pouch.png", "description": "Suppresses random encounters for 40 dangerous steps. Scripted battles remain active."},
}

const SERVICE_STOCK := {
	"Cafe": [&"tonic", &"ether", &"provisions", &"rift_ward"],
	"Clinic": [&"tonic", &"smelling_salts", &"phoenix_tonic"],
}

const ARMORY_REFORGE_BASE_DUCKET_COST := 48

const ARMORY_REFORGE_ANCHOR_DUST_COST := 1

const ARMORY_STOCK := {
	&"militia_saber": {
		"id": &"militia_saber", "base_name": "Militia Saber", "slot": &"weapon", "price": 72,
		"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png", "icon_profile": &"item_iron_weapon_1",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Readiness", "stat": "attack", "value": 4}],
	},
	&"copper_watch_cap": {
		"id": &"copper_watch_cap", "base_name": "Copper Watch Cap", "slot": &"head", "price": 56,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Copper/Copper_Helmet1.png", "icon_profile": &"item_copper_helmet_1",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Vigilance", "stat": "defense", "value": 3}, {"name": "of Good Sense", "stat": "spirit", "value": 1}],
	},
	&"copper_field_coat": {
		"id": &"copper_field_coat", "base_name": "Copper Field Coat", "slot": &"body", "price": 88,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Copper/Copper_Chestplate1.png", "icon_profile": &"item_copper_chestplate_1",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Shelter", "stat": "defense", "value": 5}, {"name": "of Vigor", "stat": "max_hp", "value": 15}],
	},
	&"copper_work_gloves": {
		"id": &"copper_work_gloves", "base_name": "Copper Work Gloves", "slot": &"hands", "price": 58,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Copper/Copper_Gloves1.png", "icon_profile": &"item_copper_gloves_1",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Grip", "stat": "attack", "value": 2}, {"name": "of Bracing", "stat": "defense", "value": 2}],
	},
	&"watchmakers_lens": {
		"id": &"watchmakers_lens", "base_name": "Watchmaker's Field Lens", "slot": &"accessory", "price": 64,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png", "icon_profile": &"item_artifact_15",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Calibration", "stat": "magic", "value": 2}, {"name": "of Timing", "stat": "speed", "value": 2}], "required_affinities": [&"technical"],
	},
	&"anchor_knot": {
		"id": &"anchor_knot", "base_name": "Braided Anchor Knot", "slot": &"charm", "price": 66,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png", "icon_profile": &"item_artifact_42",
		"rarity": "Common", "rarity_color": "#d8d3c5", "modifiers": [{"name": "of Continuity", "stat": "spirit", "value": 3}, {"name": "of Charge", "stat": "max_mp", "value": 6}], "required_affinities": [&"occult"],
	},
	&"tempered_saber": {
		"id": &"tempered_saber", "base_name": "Tempered Fault-Line Saber", "slot": &"weapon", "price": 148,
		"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon8.png", "icon_profile": &"item_iron_weapon_8",
		"rarity": "Uncommon", "rarity_color": "#62d67b", "modifiers": [{"name": "of Tempering", "stat": "attack", "value": 7}, {"name": "of Quick Draw", "stat": "speed", "value": 2}],
		"required_affinities": [&"martial"], "requires_flags": [&"mansion_archive_boss_defeated"],
	},
	&"timekeeper_charm": {
		"id": &"timekeeper_charm", "base_name": "Timekeeper's Safety Charm", "slot": &"charm", "price": 142,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png", "icon_profile": &"item_artifact_42",
		"rarity": "Uncommon", "rarity_color": "#62d67b", "modifiers": [{"name": "of Punctuality", "stat": "spirit", "value": 5}, {"name": "of Preparedness", "stat": "speed", "value": 1}],
		"element_rates": {&"time": 0.75}, "required_affinities": [&"occult"], "requires_flags": [&"mansion_archive_boss_defeated"],
	},
	&"vacuum_plate": {
		"id": &"vacuum_plate", "base_name": "Asterion Vacuum Plate", "slot": &"body", "price": 184,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Chestplate1.png", "icon_profile": &"item_iron_chestplate_1",
		"rarity": "Uncommon", "rarity_color": "#62d67b", "modifiers": [{"name": "of Pressure", "stat": "defense", "value": 8}, {"name": "of Reserve Air", "stat": "max_hp", "value": 24}],
		"required_affinities": [&"frontline"], "requires_flags": [&"asterion_station_complete"],
	},
	&"grounded_signal_lens": {
		"id": &"grounded_signal_lens", "base_name": "Grounded Signal Lens", "slot": &"accessory", "price": 188,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png", "icon_profile": &"item_artifact_15",
		"rarity": "Uncommon", "rarity_color": "#62d67b", "modifiers": [{"name": "of Diagnostics", "stat": "magic", "value": 5}, {"name": "of Isolation", "stat": "spirit", "value": 3}],
		"element_rates": {&"lightning": 0.75}, "required_affinities": [&"technical"], "requires_flags": [&"asterion_station_complete"],
	},
	&"caldera_field_gloves": {
		"id": &"caldera_field_gloves", "base_name": "Caldera Field Gloves", "slot": &"hands", "price": 212,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Gloves5.png", "icon_profile": &"item_iron_gloves_5",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of the Hunt", "stat": "attack", "value": 5}, {"name": "of Sure Footing", "stat": "speed", "value": 3}],
		"element_rates": {&"nature": 0.75}, "required_affinities": [&"martial"], "requires_flags": [&"primeval_scenario_complete"],
	},
	&"paleo_signal_lens": {
		"id": &"paleo_signal_lens", "base_name": "Paleo Signal Lens", "slot": &"accessory", "price": 206,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon9.png", "icon_profile": &"item_artifact_9",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of Translation", "stat": "magic", "value": 6}, {"name": "of Bedrock", "stat": "defense", "value": 4}],
		"element_rates": {&"spectral": 0.8}, "required_affinities": [&"technical"], "requires_flags": [&"primeval_scenario_complete"],
	},
	&"noonshade_visored_cap": {
		"id": &"noonshade_visored_cap", "base_name": "Noonshade Visored Cap", "slot": &"head", "price": 246,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Helmet5.png", "icon_profile": &"item_iron_helmet_5",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of the Night Shift", "stat": "defense", "value": 5}, {"name": "of Escape Routes", "stat": "speed", "value": 4}],
		"element_rates": {&"radiant": 0.75}, "required_affinities": [&"scout"], "requires_flags": [&"helios_scenario_complete"],
	},
	&"afterlight_coil": {
		"id": &"afterlight_coil", "base_name": "Afterlight Discharge Coil", "slot": &"charm", "price": 238,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png", "icon_profile": &"item_artifact_42",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of Countercurrent", "stat": "magic", "value": 5}, {"name": "of Nerve", "stat": "spirit", "value": 5}],
		"element_rates": {&"lightning": 0.7}, "required_affinities": [&"technical"], "requires_flags": [&"helios_scenario_complete"],
	},
	&"thermal_arbitration_coat": {
		"id": &"thermal_arbitration_coat", "base_name": "Thermal Arbitration Coat", "slot": &"body", "price": 278,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Chestplate5.png", "icon_profile": &"item_iron_chestplate_5",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of Insulation", "stat": "defense", "value": 9}, {"name": "of Warm Rations", "stat": "max_hp", "value": 28}],
		"element_rates": {&"frost": 0.7}, "required_affinities": [&"frontline"], "requires_flags": [&"frosthold_scenario_complete"],
	},
	&"winter_ledger_locket": {
		"id": &"winter_ledger_locket", "base_name": "Winter Ledger Locket", "slot": &"accessory", "price": 266,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png", "icon_profile": &"item_artifact_15",
		"rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"name": "of Forbearance", "stat": "spirit", "value": 7}, {"name": "of Reserves", "stat": "max_mp", "value": 10}],
		"element_rates": {&"spectral": 0.75}, "required_affinities": [&"occult"], "requires_flags": [&"frosthold_scenario_complete"],
	},
	&"veracity_lantern_locket": {
		"id": &"veracity_lantern_locket", "base_name": "Veracity Lantern Locket", "slot": &"accessory", "price": 308,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png", "icon_profile": &"item_artifact_15",
		"rarity": "Epic", "rarity_color": "#bd77ff", "modifiers": [{"name": "of Witness", "stat": "magic", "value": 8}, {"name": "of the Record", "stat": "spirit", "value": 4}],
		"element_rates": {&"spectral": 0.7}, "required_affinities": [&"occult"], "requires_flags": [&"moonpetal_scenario_complete"],
	},
	&"moonpetal_courier_gloves": {
		"id": &"moonpetal_courier_gloves", "base_name": "Moonpetal Courier Gloves", "slot": &"hands", "price": 296,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Gloves9.png", "icon_profile": &"item_iron_gloves_9",
		"rarity": "Epic", "rarity_color": "#bd77ff", "modifiers": [{"name": "of the Procession", "stat": "attack", "value": 7}, {"name": "of Swift Recall", "stat": "speed", "value": 4}],
		"element_rates": {&"time": 0.75}, "required_affinities": [&"scout"], "requires_flags": [&"moonpetal_scenario_complete"],
	},
	&"galvanic_counterweight": {
		"id": &"galvanic_counterweight", "base_name": "Galvanic Counterweight", "slot": &"charm", "price": 348,
		"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png", "icon_profile": &"item_artifact_42",
		"rarity": "Epic", "rarity_color": "#bd77ff", "modifiers": [{"name": "of Grounding", "stat": "defense", "value": 9}, {"name": "of Ballast", "stat": "max_hp", "value": 30}],
		"element_rates": {&"lightning": 0.7}, "required_affinities": [&"technical"], "requires_flags": [&"empyreal_scenario_complete"],
	},
	&"aerie_ward_helm": {
		"id": &"aerie_ward_helm", "base_name": "Aerie Ward Helm", "slot": &"head", "price": 336,
		"icon": "res://game_assets/items/armory/Singles/Armor_Singles/Iron/Iron_Helmet8.png", "icon_profile": &"item_iron_helmet_8",
		"rarity": "Epic", "rarity_color": "#bd77ff", "modifiers": [{"name": "of Appeals", "stat": "spirit", "value": 8}, {"name": "of Flight", "stat": "speed", "value": 4}],
		"element_rates": {&"radiant": 0.7}, "required_affinities": [&"radiant"], "requires_flags": [&"empyreal_scenario_complete"],
	},
}

const FACILITY_DEFINITIONS := {
	"Cafe": {
		"description": "Feeds the town, hosts visitors, and turns hospitality into steady Duckets.",
		"icon": "dfgui_icon-food.png",
		"jobs": [
			{"id": &"cafe_morning_service", "name": "Open the Morning Service", "description": "Run breakfast for settlers and curious interdimensional guests.", "duration_seconds": 300, "duckets": 18, "experience": 14, "items": {}, "preferred_skills": [&"Logistics", &"Diplomacy"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"serving_automaton"},
			{"id": &"cafe_founders_supper", "name": "Host the Founders' Supper", "description": "A longer, higher-stakes service with better company pay.", "duration_seconds": 900, "duckets": 48, "experience": 34, "items": {&"provisions": 1}, "preferred_skills": [&"Diplomacy", &"Security"], "ben_can_lead": false, "ben_can_assist": true, "boost_invention": &"serving_automaton"},
		],
	},
	"Library": {
		"description": "Turns discoveries into useful research, blueprints, and multiversal leads.",
		"icon": "dfgui_icon-redbook.png",
		"jobs": [
			{"id": &"library_catalog_records", "name": "Catalog Fault-Line Records", "description": "Sort field notes into usable research for Ben's laboratory.", "duration_seconds": 480, "duckets": 22, "experience": 18, "items": {&"research_notes": 1}, "preferred_skills": [&"Research", &"Logistics"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"cataloging_engine"},
			{"id": &"library_decode_echoes", "name": "Decode Mansion Echoes", "description": "Cross-reference the haunted household's impossible records.", "duration_seconds": 1200, "duckets": 62, "experience": 45, "items": {&"anchor_dust": 1}, "preferred_skills": [&"Research", &"Occult"], "ben_can_lead": true, "ben_can_assist": true, "required_invention": &"cataloging_engine", "requires_flags": [&"mansion_first_room_complete"]},
		],
	},
	"Clinic": {
		"description": "Restores residents, prepares supplies, and supports longer expeditions.",
		"icon": "dfgui_icon-cauldron.png",
		"jobs": [
			{"id": &"clinic_tonic_rounds", "name": "Prepare Tonic Rounds", "description": "Brew and bottle field medicine for the company inventory.", "duration_seconds": 600, "duckets": 16, "experience": 20, "items": {&"tonic": 2}, "preferred_skills": [&"Medicine", &"Logistics"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"medical_kite"},
			{"id": &"clinic_emergency_drill", "name": "Run an Emergency Drill", "description": "Train the town to respond when visitors bring trouble home.", "duration_seconds": 1200, "duckets": 55, "experience": 42, "items": {&"tonic": 1}, "preferred_skills": [&"Medicine", &"Security"], "ben_can_lead": false, "ben_can_assist": true, "boost_invention": &"medical_kite"},
		],
	},
	"Armory": {
		"description": "Outfits expeditions, buys recovered equipment, and turns multiversal salvage into dependable field gear.",
		"icon": "dfgui_icon-sword.png",
		"jobs": [
			{"id": &"armory_sort_salvage", "name": "Sort Recovered Salvage", "description": "Inspect bent weapons, impossible buckles, and armor that remembers a different owner.", "duration_seconds": 600, "duckets": 32, "experience": 24, "items": {&"anchor_dust": 1}, "preferred_skills": [&"Engineering", &"Logistics"], "ben_can_lead": true, "ben_can_assist": true},
			{"id": &"armory_field_refit", "name": "Run a Company Field Refit", "description": "Repair expedition equipment and document which pieces continue violating ordinary metallurgy.", "duration_seconds": 1200, "duckets": 78, "experience": 50, "items": {&"research_notes": 1}, "preferred_skills": [&"Engineering", &"Security"], "ben_can_lead": false, "ben_can_assist": true, "requires_flags": [&"mansion_foyer_cleared"]},
		],
	},
	"Haunted Mansion": {
		"description": "The anchored universe doubles as an observatory for supernatural echoes.",
		"icon": "dfgui_icon-monsterbook.png",
		"jobs": [
			{"id": &"mansion_echo_watch", "name": "Keep the Echo Watch", "description": "Monitor displaced spirits before they wander into town.", "duration_seconds": 900, "duckets": 58, "experience": 44, "items": {&"ectoplasm": 1}, "preferred_skills": [&"Security", &"Occult"], "ben_can_lead": false, "ben_can_assist": true, "boost_invention": &"echo_snare", "boost_inventions": [&"echo_snare", &"temporal_tuning_fork"], "requires_flags": [&"mansion_foyer_cleared"]},
			{"id": &"mansion_anchor_calibration", "name": "Calibrate the Anchor Core", "description": "Use Ben's regulator to harvest a stable trace of the universe.", "duration_seconds": 1800, "duckets": 90, "experience": 65, "items": {&"anchor_dust": 2}, "preferred_skills": [&"Research", &"Occult"], "ben_can_lead": true, "ben_can_assist": true, "required_invention": &"anchor_regulator", "boost_inventions": [&"anchor_regulator", &"continuity_kite"], "requires_flags": [&"mansion_archive_boss_defeated"]},
		],
	},
	"Observatory": {
		"description": "Maps stable universes and monitors the town's second anchor: Asterion Station.",
		"icon": "dfgui_icon-wand.png",
		"jobs": [
			{"id": &"observatory_chart_faults", "name": "Chart the Fault Line", "description": "Compare Asterion telemetry with Ben's laboratory instruments.", "duration_seconds": 900, "duckets": 64, "experience": 48, "items": {&"research_notes": 1}, "preferred_skills": [&"Research", &"Navigation"], "ben_can_lead": true, "ben_can_assist": true, "requires_flags": [&"asterion_station_restored"]},
			{"id": &"observatory_salvage_signals", "name": "Trace Salvage Signals", "description": "Locate useful debris without reopening the station's automated security net.", "duration_seconds": 1500, "duckets": 105, "experience": 70, "items": {&"anchor_dust": 1}, "preferred_skills": [&"Navigation", &"Security"], "ben_can_lead": false, "ben_can_assist": true, "requires_flags": [&"asterion_station_complete"]},
		],
	},
	"Trailhead Lodge": {
		"description": "Supplies expeditions and monitors the town's Primeval Expanse anchor.",
		"icon": "dfgui_icon-shovel.png",
		"jobs": [
			{"id": &"primeval_foraging_run", "name": "Run a Primeval Foraging Route", "description": "Gather useful plants while respecting the municipal dinosaur crossing signs.", "duration_seconds": 900, "duckets": 72, "experience": 52, "items": {&"provisions": 2}, "preferred_skills": [&"Farming", &"Athletics"], "ben_can_lead": false, "ben_can_assist": true, "requires_flags": [&"primeval_grove_cleared"]},
			{"id": &"primeval_fossil_survey", "name": "Survey Impossible Fossils", "description": "Catalog machine parts fossilized several million years before their invention.", "duration_seconds": 1500, "duckets": 112, "experience": 76, "items": {&"research_notes": 2}, "preferred_skills": [&"Research", &"Athletics"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"paleo_translator", "requires_flags": [&"primeval_terminal_decoded"]},
		],
	},
	"Afterlight Club": {
		"description": "Runs the town's night shift and monitors the Helios Arcology anchor after sunset.",
		"icon": "dfgui_icon-lightning.png",
		"jobs": [
			{"id": &"afterlight_house_show", "name": "Run the Afterlight House Show", "description": "Keep the floor, stage, and interdimensional guest list moving in the same direction.", "duration_seconds": 900, "duckets": 86, "experience": 58, "items": {&"provisions": 1}, "preferred_skills": [&"Diplomacy", &"Logistics"], "ben_can_lead": false, "ben_can_assist": true, "requires_flags": [&"helios_skybridge_cleared"]},
			{"id": &"afterlight_signal_run", "name": "Trace the Midnight Signal", "description": "Relay Neon Viper's stolen telemetry through the Club without waking Helios security.", "duration_seconds": 1500, "duckets": 125, "experience": 82, "items": {&"research_notes": 2}, "preferred_skills": [&"Engineering", &"Security"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"night_phase_inverter", "requires_flags": [&"helios_transit_node_disabled"]},
		],
	},
	"Cold Storage": {
		"description": "Preserves town supplies and monitors the Frosthold Kingdom anchor without thawing either one.",
		"icon": "dfgui_icon-cauldron.png",
		"jobs": [
			{"id": &"cold_storage_inventory", "name": "Inventory the Deep Freeze", "description": "Rotate provisions before an extradimensional winter turns their labels into historical documents.", "duration_seconds": 900, "duckets": 92, "experience": 62, "items": {&"provisions": 2}, "preferred_skills": [&"Logistics", &"Research"], "ben_can_lead": true, "ben_can_assist": true, "requires_flags": [&"frosthold_gate_cleared"]},
			{"id": &"cold_storage_permafrost_audit", "name": "Audit the Permafrost", "description": "Measure the anchor's thermal debt and recover useful residue before the royal accountants do.", "duration_seconds": 1500, "duckets": 138, "experience": 88, "items": {&"anchor_dust": 2}, "preferred_skills": [&"Occult", &"Engineering"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"thermal_arbitration_coil", "requires_flags": [&"frosthold_rune_clue_found"]},
		],
	},
	"Tea House": {
		"description": "Serves the town, hosts diplomatic visitors, and monitors the Moonpetal Court anchor over properly steeped tea.",
		"icon": "dfgui_icon-goblet.png",
		"jobs": [
			{"id": &"tea_house_service", "name": "Host the Moonpetal Service", "description": "Serve residents and visitors while keeping genuine memories separate from decorative anecdotes.", "duration_seconds": 900, "duckets": 104, "experience": 68, "items": {&"provisions": 1}, "preferred_skills": [&"Diplomacy", &"Logistics"], "ben_can_lead": false, "ben_can_assist": true, "requires_flags": [&"moonpetal_gate_cleared"]},
			{"id": &"tea_house_memory_audit", "name": "Audit the Memory Ledger", "description": "Compare recovered shrine vows under Ben's calibrated lantern and bottle the harmless echoes.", "duration_seconds": 1500, "duckets": 152, "experience": 96, "items": {&"research_notes": 2, &"anchor_dust": 1}, "preferred_skills": [&"Occult", &"Research"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"veracity_lantern", "requires_flags": [&"moonpetal_vow_clue_found"]},
		],
	},
	"Belfry": {
		"description": "Keeps the town clock, relays weather warnings, and monitors the Empyreal Court anchor without accepting divine processing fees.",
		"icon": "dfgui_icon-crown.png",
		"jobs": [
			{"id": &"belfry_weather_watch", "name": "Keep the Weather Watch", "description": "Track unauthorized thunderheads before celestial auditors invoice the town for precipitation.", "duration_seconds": 900, "duckets": 116, "experience": 74, "items": {&"research_notes": 1}, "preferred_skills": [&"Navigation", &"Research"], "ben_can_lead": true, "ben_can_assist": true, "requires_flags": [&"empyreal_landing_cleared"]},
			{"id": &"belfry_gravity_appeals", "name": "Review Gravity Appeals", "description": "Help residents dispute sudden changes in personal weight, direction, and legal altitude.", "duration_seconds": 1500, "duckets": 168, "experience": 104, "items": {&"anchor_dust": 2}, "preferred_skills": [&"Diplomacy", &"Engineering"], "ben_can_lead": true, "ben_can_assist": true, "boost_invention": &"galvanic_counterweight", "requires_flags": [&"empyreal_gravity_clue_found"]},
		],
	},
}

const INVENTION_DEFINITIONS := {
	&"serving_automaton": {"name": "Serving-Table Automaton", "facility": "Cafe", "description": "Cuts service time and raises reward quality.", "duckets": 25, "items": {}, "icon": "dfgui_icon-crafthammer.png"},
	&"cataloging_engine": {"name": "Electrostatic Cataloging Engine", "facility": "Library", "description": "Boosts research work and unlocks mansion decoding.", "duckets": 35, "items": {&"research_notes": 1}, "icon": "dfgui_icon-skillbook.png"},
	&"medical_kite": {"name": "Pneumatic Medical Kite", "facility": "Clinic", "description": "Carries supplies through the ward without collisions.", "duckets": 35, "items": {&"tonic": 1}, "icon": "dfgui_icon-cauldron.png"},
	&"echo_snare": {"name": "Harmonic Echo Snare", "facility": "Haunted Mansion", "description": "Improves supernatural work after the foyer is secured.", "duckets": 60, "items": {&"anchor_shard": 1}, "icon": "dfgui_icon-wand.png", "requires_flags": [&"mansion_foyer_cleared"]},
	&"temporal_tuning_fork": {"name": "Temporal Tuning Fork", "facility": "Haunted Mansion", "description": "Turns Mansion clock resonance into a reusable battle command that cancels a telegraphed Steal Time attack and delays its source.", "duckets": 25, "items": {&"anchor_shard": 1}, "icon": "dfgui_icon-clock.png", "requires_flags": [&"mansion_first_room_complete"]},
	&"anchor_regulator": {"name": "Portable Anchor Regulator", "facility": "Haunted Mansion", "description": "Required to safely calibrate the captured Anchor Core.", "duckets": 80, "items": {&"anchor_dust": 1}, "icon": "dfgui_icon-craftanvil.png", "requires_flags": [&"mansion_archive_boss_defeated"]},
	&"continuity_kite": {"name": "Continuity Kite", "facility": "Haunted Mansion", "description": "Installs the captured Anchor Core in a portable homing invention. Opens a safe route back to New Philadelphia from any unrestricted universe.", "duckets": 0, "items": {&"anchor_core": 1}, "icon": "dfgui_icon-wand.png", "requires_flags": [&"mansion_archive_boss_defeated"]},
	&"paleo_translator": {"name": "Paleo-Linguistic Telegraph", "facility": "Trailhead Lodge", "description": "Lets Ben exchange electrical signals with a cave computer whose operating system predates language.", "duckets": 85, "items": {&"research_notes": 1, &"anchor_dust": 1}, "icon": "dfgui_icon-wand.png", "requires_flags": [&"primeval_traffic_clue_found"]},
	&"night_phase_inverter": {"name": "Nocturnal Phase Inverter", "facility": "Afterlight Club", "description": "Convinces Helios infrastructure that midnight is a legitimate municipal service.", "duckets": 110, "items": {&"research_notes": 1, &"anchor_dust": 1}, "icon": "dfgui_icon-lightning.png", "requires_flags": [&"helios_curfew_clue_found"]},
	&"thermal_arbitration_coil": {"name": "Thermal Arbitration Coil", "facility": "Cold Storage", "description": "Produces a legally defensible pocket of warmth inside Frosthold's regulated winter.", "duckets": 135, "items": {&"research_notes": 2, &"anchor_dust": 1}, "icon": "dfgui_icon-cauldron.png", "requires_flags": [&"frosthold_rune_clue_found"]},
	&"veracity_lantern": {"name": "Electrostatic Veracity Lantern", "facility": "Tea House", "description": "Makes copied memories cast the wrong shadow, allowing Moonpetal's genuine vows to be separated from official counterfeits.", "duckets": 155, "items": {&"research_notes": 2, &"anchor_dust": 2}, "icon": "dfgui_icon-wand.png", "requires_flags": [&"moonpetal_vow_clue_found"]},
	&"galvanic_counterweight": {"name": "Galvanic Counterweight", "facility": "Belfry", "description": "Pins local gravity to Franklin & Company's copper standard, allowing the party to cross Empyreal lifts without paying by the pound.", "duckets": 180, "items": {&"research_notes": 2, &"anchor_dust": 2}, "icon": "dfgui_icon-lightning.png", "requires_flags": [&"empyreal_gravity_clue_found"]},
}

const EXPEDITION_TOOL_CONTRACTS := {
	&"temporal_tuning_fork": {"story_use": "Counter the Mansion boss's 4:44 telegraph as an alternate story solution.", "optional_use": "Return to the solved clock and set 13:13 to recover a temporal field note.", "battle_action": &"temporal_tuning", "town_job": &"mansion_echo_watch", "town_use": "Accelerates the Mansion Echo Watch after stabilization."},
	&"continuity_kite": {"story_use": "Prove the recovered Anchor Core can route the party home.", "optional_use": "Recall from any unrestricted universe instead of retracing the full route.", "battle_action": &"continuity_aegis", "town_job": &"mansion_anchor_calibration", "town_use": "Stabilizes Anchor Core calibration work at the Mansion."},
	&"paleo_translator": {"story_use": "Decode the Primeval cave computer and open the relay route.", "optional_use": "Revisit the decoded terminal for the optional Primeval relay survey.", "battle_action": &"paleo_signal", "town_job": &"primeval_fossil_survey", "town_use": "Improves the Trailhead's fossil-survey assignment."},
	&"night_phase_inverter": {"story_use": "Disable Helios daylight nodes and restore the route to the Solar Core.", "optional_use": "Revisit Transit for its optional midnight-signal specialist route.", "battle_action": &"night_phase", "town_job": &"afterlight_signal_run", "town_use": "Improves the Afterlight signal-run assignment."},
	&"thermal_arbitration_coil": {"story_use": "Open Frosthold's two thermal seals.", "optional_use": "Revisit the Causeway for an optional thermal-counsel route.", "battle_action": &"thermal_rally", "town_job": &"cold_storage_permafrost_audit", "town_use": "Improves the Cold Storage permafrost audit."},
	&"veracity_lantern": {"story_use": "Expose Moonpetal's false vows and open the Moon Palace.", "optional_use": "Revisit the Mirror Garden for an optional memory-audit route.", "battle_action": &"veracity_flash", "town_job": &"tea_house_memory_audit", "town_use": "Improves the Tea House memory audit."},
	&"galvanic_counterweight": {"story_use": "Ground Empyreal's gravity seals and lower the Seraph Tribunal.", "optional_use": "Revisit the Aerie for an optional weight-appeal route.", "battle_action": &"gravity_grounding", "town_job": &"belfry_gravity_appeals", "town_use": "Improves the Belfry's gravity-appeals assignment."},
}

const FACILITY_UPGRADE_DEFINITIONS := {
	&"cafe_hearth_exchange": {
		"name": "Hearth Exchange", "facility": "Cafe",
		"description": "Adds a warm dispatch counter: Café services cost less, work finishes faster, and Ben can pack one meal that boosts the next expedition victory.",
		"duckets": 55, "items": {&"provisions": 2}, "icon": "dfgui_icon-food.png",
		"requires_flags": [&"mansion_first_room_complete"],
		"service_discount": 0.05, "job_duration_multiplier": 0.90, "job_quality_bonus": 1,
		"field_benefit": "Pack one Expedition Meal at the Café; the next battle victory grants 20% more experience.",
	},
}

const SKILL_TREES := {
	&"ben": [
		{"id": &"efficient_capacitor", "name": "Efficient Capacitor", "cost": 1, "description": "+4 Magic.", "bonuses": {&"magic": 4}, "requires": []},
		{"id": &"voltaic_cage_training", "name": "Voltaic Cage", "cost": 1, "description": "Unlock a stronger all-target electrical invention.", "action": &"voltaic_cage", "requires": [&"efficient_capacitor"]},
		{"id": &"field_engineering", "name": "Field Engineering", "cost": 1, "description": "+5 Spirit.", "bonuses": {&"spirit": 5}, "requires": []},
		{"id": &"triage_protocol", "name": "Triage Protocol", "cost": 1, "description": "+10 maximum MP.", "bonuses": {&"max_mp": 10}, "requires": [&"field_engineering"]},
	],
	&"lincoln": [
		{"id": &"charter_guard", "name": "Charter Guard", "cost": 1, "description": "+6 Defense while holding the line.", "bonuses": {&"defense": 6}, "requires": []},
		{"id": &"civic_resolve", "name": "Civic Resolve", "cost": 1, "description": "+24 maximum HP when protecting the company.", "bonuses": {&"max_hp": 24}, "requires": [&"charter_guard"]},
		{"id": &"public_address", "name": "Public Address", "cost": 1, "description": "+5 Spirit for formation-wide leadership.", "bonuses": {&"spirit": 5}, "requires": []},
		{"id": &"steady_standard", "name": "Steady Standard", "cost": 1, "description": "+4 Speed after issuing a rally.", "bonuses": {&"speed": 4}, "requires": [&"public_address"]},
	],
	&"gandhi": [
		{"id": &"mercy_practice", "name": "Mercy Practice", "cost": 1, "description": "+6 Spirit for recovery and de-escalation.", "bonuses": {&"spirit": 6}, "requires": []},
		{"id": &"field_medicine", "name": "Field Medicine", "cost": 1, "description": "+12 maximum MP for sustained triage.", "bonuses": {&"max_mp": 12}, "requires": [&"mercy_practice"]},
		{"id": &"patient_step", "name": "Patient Step", "cost": 1, "description": "+5 Speed while directing nonlethal control.", "bonuses": {&"speed": 5}, "requires": []},
		{"id": &"quiet_courage", "name": "Quiet Courage", "cost": 1, "description": "+18 maximum HP when standing with the wounded.", "bonuses": {&"max_hp": 18}, "requires": [&"patient_step"]},
	],
	&"fighter": [
		{"id": &"rally_training", "name": "Rally Training", "cost": 1, "description": "Unlock Rally for the entire formation.", "action": &"rally", "requires": []},
		{"id": &"cleave_training", "name": "Cleaving Form", "cost": 1, "description": "Unlock Cleave against every enemy.", "action": &"cleave", "requires": [&"rally_training"]},
		{"id": &"iron_body", "name": "Iron Body", "cost": 1, "description": "+5 Defense.", "bonuses": {&"defense": 5}, "requires": []},
		{"id": &"heavy_hands", "name": "Heavy Hands", "cost": 1, "description": "+5 Attack.", "bonuses": {&"attack": 5}, "requires": [&"iron_body"]},
	],
	&"astronaut": [
		{"id": &"deadeye_training", "name": "Vacuum Deadeye", "cost": 1, "description": "Unlocks Deadeye Shot.", "action": &"deadeye_shot", "requires": []},
		{"id": &"ion_round_training", "name": "Ion Round", "cost": 1, "description": "Unlocks an electrical shot that can Shock machines.", "action": &"ion_round", "requires": [&"deadeye_training"]},
		{"id": &"pressure_suit", "name": "Pressure Suit", "cost": 1, "description": "+5 Defense.", "bonuses": {&"defense": 5}, "requires": []},
		{"id": &"zero_g_reflexes", "name": "Zero-G Reflexes", "cost": 1, "description": "+6 Speed.", "bonuses": {&"speed": 6}, "requires": [&"pressure_suit"]},
	],
	&"caveman": [
		{"id": &"primal_roar_training", "name": "Primal Roar", "cost": 1, "description": "Unlock a formation-wide attack rally.", "action": &"primal_roar", "requires": []},
		{"id": &"mammoth_slam_training", "name": "Mammoth Slam", "cost": 1, "description": "Unlock a crushing single-target blow.", "action": &"mammoth_slam", "requires": [&"primal_roar_training"]},
		{"id": &"stone_hide", "name": "Stone Hide", "cost": 1, "description": "+6 Defense.", "bonuses": {&"defense": 6}, "requires": []},
		{"id": &"hunter_endurance", "name": "Hunter Endurance", "cost": 1, "description": "+28 maximum HP.", "bonuses": {&"max_hp": 28}, "requires": [&"stone_hide"]},
	],
	&"crimson_oni": [
		{"id": &"crescent_form", "name": "Crimson Focus", "cost": 1, "description": "+4 Attack.", "bonuses": {&"attack": 4}, "requires": []},
		{"id": &"blood_moon_form", "name": "Blood-Moon Iaijutsu", "cost": 1, "description": "Unlock an all-enemy execution draw.", "action": &"blood_moon_cleave", "requires": [&"crescent_form"]},
		{"id": &"demon_guard", "name": "Demon Guard", "cost": 1, "description": "+5 Defense.", "bonuses": {&"defense": 5}, "requires": []},
		{"id": &"phantom_step", "name": "Phantom Step", "cost": 1, "description": "+7 Speed.", "bonuses": {&"speed": 7}, "requires": [&"demon_guard"]},
	],
	&"rift_jackal": [
		{"id": &"threshold_scent", "name": "Threshold Scent", "cost": 1, "description": "+5 Speed.", "bonuses": {&"speed": 5}, "requires": []},
		{"id": &"faultline_pounce_training", "name": "Fault-Line Pounce", "cost": 1, "description": "Unlock a high-critical strike that delays its target.", "action": &"faultline_pounce", "requires": [&"threshold_scent"]},
		{"id": &"rift_hide", "name": "Rift Hide", "cost": 1, "description": "+6 Defense.", "bonuses": {&"defense": 6}, "requires": []},
		{"id": &"anchor_howl_training", "name": "Anchor Howl", "cost": 1, "description": "Unlock a howl that rallies the whole formation.", "action": &"anchor_howl", "requires": [&"rift_hide"]},
	],
	&"mossback_surveyor": [
		{"id": &"soil_sense", "name": "Soil Sense", "cost": 1, "description": "+5 Spirit.", "bonuses": {&"spirit": 5}, "requires": []},
		{"id": &"rooted_red_tape_training", "name": "Rooted Red Tape", "cost": 1, "description": "Unlock a binding root attack that drains ATB and may Slow.", "action": &"rooted_red_tape", "requires": [&"soil_sense"]},
		{"id": &"supply_lines", "name": "Supply Lines", "cost": 1, "description": "+6 Defense.", "bonuses": {&"defense": 6}, "requires": []},
		{"id": &"hearty_provisions_training", "name": "Hearty Provisions", "cost": 1, "description": "Unlock a formation-wide restorative meal.", "action": &"hearty_provisions", "requires": [&"supply_lines"]},
	],
	&"cobalt_courier": [
		{"id": &"night_route", "name": "Night Route", "cost": 1, "description": "+5 Speed.", "bonuses": {&"speed": 5}, "requires": []},
		{"id": &"priority_delivery_training", "name": "Priority Delivery", "cost": 1, "description": "Unlock a lightning-fast strike that delays its target and may inflict Shock.", "action": &"priority_delivery", "requires": [&"night_route"]},
		{"id": &"insulated_satchel", "name": "Insulated Satchel", "cost": 1, "description": "+6 Spirit.", "bonuses": {&"spirit": 6}, "requires": []},
		{"id": &"emergency_dispatch_training", "name": "Emergency Dispatch", "cost": 1, "description": "Unlock a formation-wide restorative delivery.", "action": &"emergency_dispatch", "requires": [&"insulated_satchel"]},
	],
	&"bulkhead_warden": [
		{"id": &"reinforced_chassis", "name": "Reinforced Chassis", "cost": 1, "description": "+6 Defense.", "bonuses": {&"defense": 6}, "requires": []},
		{"id": &"bulkhead_drop_training", "name": "Bulkhead Drop", "cost": 1, "description": "Unlock a crushing formation-wide impact.", "action": &"bulkhead_drop", "requires": [&"reinforced_chassis"]},
		{"id": &"emergency_bracing", "name": "Emergency Bracing", "cost": 1, "description": "+32 maximum HP.", "bonuses": {&"max_hp": 32}, "requires": []},
		{"id": &"pressure_lock_training", "name": "Pressure Lock", "cost": 1, "description": "Unlock a pneumatic strike that drains ATB and may inflict Slow.", "action": &"pressure_lock", "requires": [&"emergency_bracing"]},
	],
	&"kitsune_empress": [
		{"id": &"foxfire_lesson", "name": "Foxfire Mastery", "cost": 1, "description": "+4 Magic.", "bonuses": {&"magic": 4}, "requires": []},
		{"id": &"nine_tail_lesson", "name": "Nine-Tailed Judgment", "cost": 1, "description": "Unlock foxfire against the enemy formation.", "action": &"nine_tail_judgment", "requires": [&"foxfire_lesson"]},
		{"id": &"courtly_glamour", "name": "Courtly Glamour", "cost": 1, "description": "+5 Spirit.", "bonuses": {&"spirit": 5}, "requires": []},
		{"id": &"moonlit_reflexes", "name": "Moonlit Reflexes", "cost": 1, "description": "+6 Speed.", "bonuses": {&"speed": 6}, "requires": [&"courtly_glamour"]},
	],
	&"neon_viper": [
		{"id": &"viper_rush_training", "name": "Viper Reflex", "cost": 1, "description": "+4 Speed.", "bonuses": {&"speed": 4}, "requires": []},
		{"id": &"uppercut_training", "name": "Surprise Uppercut", "cost": 1, "description": "Unlock a high-critical close-range attack.", "action": &"viper_uppercut", "requires": [&"viper_rush_training"]},
		{"id": &"neural_accelerator", "name": "Neural Accelerator", "cost": 1, "description": "+8 Speed.", "bonuses": {&"speed": 8}, "requires": []},
		{"id": &"subdermal_armor", "name": "Subdermal Armor", "cost": 1, "description": "+5 Defense.", "bonuses": {&"defense": 5}, "requires": [&"neural_accelerator"]},
	],
	&"archangel_commander": [
		{"id": &"seraph_strike_training", "name": "Seraphic Focus", "cost": 1, "description": "+4 Spirit.", "bonuses": {&"spirit": 4}, "requires": []},
		{"id": &"heavenly_aegis_training", "name": "Heavenly Aegis", "cost": 1, "description": "Unlock a formation-wide protective rally.", "action": &"heavenly_aegis", "requires": [&"seraph_strike_training"]},
		{"id": &"celestial_plate", "name": "Celestial Plate", "cost": 1, "description": "+7 Defense.", "bonuses": {&"defense": 7}, "requires": []},
		{"id": &"healing_light", "name": "Healing Light", "cost": 1, "description": "+7 Spirit.", "bonuses": {&"spirit": 7}, "requires": [&"celestial_plate"]},
	],
	&"frost_lich_emperor": [
		{"id": &"frost_nova_training", "name": "Permafrost", "cost": 1, "description": "+4 Magic.", "bonuses": {&"magic": 4}, "requires": []},
		{"id": &"soul_reaper_training", "name": "Soul Reaper", "cost": 1, "description": "Unlock a severe spectral strike.", "action": &"soul_reaper", "requires": [&"frost_nova_training"]},
		{"id": &"frozen_soul", "name": "Frozen Soul", "cost": 1, "description": "+7 Magic.", "bonuses": {&"magic": 7}, "requires": []},
		{"id": &"throne_of_damned", "name": "Throne of the Damned", "cost": 1, "description": "+12 maximum MP.", "bonuses": {&"max_mp": 12}, "requires": [&"frozen_soul"]},
	],
}

const QUEST_DEFINITIONS := {
	&"a_fault_in_reality": {
		"title": "A Fault in Reality", "category": &"main", "giver": "Benjamin Franklin", "icon": "dfgui_icon-crown.png",
		"description": "Ben's laboratory has landed beside an empty settlement on an unstable fault line of the multiverse. Establish a safe town before opening any impossible doors.",
		"starts_active": true,
		"steps": [
			{"text": "Hear Ben's plan in the laboratory.", "condition": {"type": &"story_flag", "id": &"opening_complete"}},
			{"text": "Leave the laboratory and survey the empty town.", "condition": {"type": &"story_flag", "id": &"town_entered"}},
			{"text": "Build the Café.", "condition": {"type": &"facility_built", "id": "Cafe"}},
			{"text": "Build the Library.", "condition": {"type": &"facility_built", "id": "Library"}},
			{"text": "Build the Clinic.", "condition": {"type": &"facility_built", "id": "Clinic"}},
			{"text": "Build the Armory.", "condition": {"type": &"facility_built", "id": "Armory"}},
		],
		"rewards": {"duckets": 40, "items": {&"tonic": 1}},
	},
	&"first_hire": {
		"title": "Franklin & Company's First Hire", "category": &"main", "giver": "Benjamin Franklin", "icon": "dfgui_icon-shield.png",
		"description": "A multiversal expedition needs somebody who can solve problems that refuse diplomacy. A Fighter is waiting beside the new Café.",
		"requires_quests": [&"a_fault_in_reality"],
		"steps": [
			{"text": "Speak with the Fighter beside the Café.", "condition": {"type": &"recruit_hired", "id": &"fighter"}},
			{"text": "Place the Fighter in Ben's active party.", "condition": {"type": &"party_has", "id": &"fighter"}},
		],
		"rewards": {"duckets": 25, "items": {&"tonic": 2}},
	},
	&"first_anchor": {
		"title": "The First Anchor", "category": &"main", "giver": "Benjamin Franklin", "icon": "dfgui_icon-crafthammer.png",
		"description": "The safe town is ready. Use the supplied Haunted Mansion blueprint to choose and anchor the first universe.",
		"requires_quests": [&"first_hire"],
		"steps": [
			{"text": "Build the Haunted Mansion in the remaining plot.", "condition": {"type": &"facility_built", "id": "Haunted Mansion"}},
			{"text": "Enter the Haunted Mansion's anchored universe.", "condition": {"type": &"story_flag", "id": &"mansion_entered"}},
		],
		"rewards": {"duckets": 50, "items": {}},
	},
	&"the_house_keeps_time": {
		"title": "The House Keeps Time", "category": &"main", "giver": "The Haunted Mansion", "icon": "dfgui_icon-clock.png",
		"description": "Every clock in the Mansion disagrees with history. Secure the house, discover its missing hour, and stabilize the universe behind its front door.",
		"requires_quests": [&"first_anchor"],
		"steps": [
			{"text": "Defeat the Mansion's foyer occupants.", "condition": {"type": &"story_flag", "id": &"mansion_foyer_cleared"}},
			{"text": "Examine the stopped grandfather clock.", "condition": {"type": &"story_flag", "id": &"mansion_clock_examined"}},
			{"text": "Search the bookcase for the household records.", "condition": {"type": &"story_flag", "id": &"mansion_ledger_found"}},
			{"text": "Return to the clock and set the recorded hour: 4:44.", "condition": {"type": &"story_flag", "id": &"mansion_first_room_complete"}},
			{"text": "Activate the archive's Anchor Clock save point.", "condition": {"type": &"story_flag", "id": &"mansion_archive_save_found"}},
			{"text": "Survive the portrait gallery's reception.", "condition": {"type": &"story_flag", "id": &"mansion_gallery_ambush_cleared"}},
			{"text": "Recover the Silver Hour Hand from the central portrait.", "condition": {"type": &"story_flag", "id": &"mansion_hour_hand_found"}},
			{"text": "Break the nursery's doll procession.", "condition": {"type": &"story_flag", "id": &"mansion_nursery_ambush_cleared"}},
			{"text": "Fit the Hour Hand into the music box and recover the Brass Minute Hand.", "condition": {"type": &"story_flag", "id": &"mansion_minute_hand_found"}},
			{"text": "Set the ballroom lock to 4:44 and keep the appointment.", "condition": {"type": &"story_flag", "id": &"mansion_ballroom_open"}},
			{"text": "Defeat the Haunted Clock Mirror at the 4:44 appointment.", "condition": {"type": &"story_flag", "id": &"mansion_archive_boss_defeated"}},
		],
		"objectives": [
			{"id": &"secure_foyer", "text": "Defeat the Mansion's foyer occupants.", "condition": {"type": &"story_flag", "id": &"mansion_foyer_cleared"}},
			{"id": &"read_the_house", "text": "Pair the stopped clock with the household ledger.", "requires": [&"secure_foyer"], "condition": {"type": &"all", "conditions": [{"type": &"story_flag", "id": &"mansion_clock_examined"}, {"type": &"story_flag", "id": &"mansion_ledger_found"}]}},

			{"id": &"tune_the_clock", "text": "Set the Mansion clock to the recorded hour: 4:44.", "requires": [&"read_the_house"], "condition": {"type": &"any", "conditions": [{"type": &"event", "id": &"mansion_clock_setting", "equals": &"04:44"}, {"type": &"story_flag", "id": &"mansion_first_room_complete"}]}},
			{"id": &"prepare_archive", "text": "Activate the archive Anchor Clock and unlock both wings.", "requires": [&"tune_the_clock"], "condition": {"type": &"all", "conditions": [{"type": &"story_flag", "id": &"mansion_archive_save_found"}, {"type": &"story_flag", "id": &"mansion_ballroom_open"}]}},
			{"id": &"gallery_hand", "text": "Recover the Silver Hour Hand from the portrait gallery.", "requires": [&"tune_the_clock"], "condition": {"type": &"all", "conditions": [{"type": &"story_flag", "id": &"mansion_gallery_ambush_cleared"}, {"type": &"story_flag", "id": &"mansion_hour_hand_found"}]}},
			{"id": &"nursery_hand", "text": "Recover the Brass Minute Hand from the nursery music box.", "requires": [&"tune_the_clock"], "condition": {"type": &"all", "conditions": [{"type": &"story_flag", "id": &"mansion_nursery_ambush_cleared"}, {"type": &"story_flag", "id": &"mansion_minute_hand_found"}]}},
			{"id": &"keep_appointment", "text": "Defeat the Haunted Clock Mirror at the 4:44 appointment.", "requires": [&"prepare_archive", &"gallery_hand", &"nursery_hand"], "condition": {"type": &"story_flag", "id": &"mansion_archive_boss_defeated"}},
		],
		"rewards": {"duckets": 200, "items": {&"tonic": 3, &"anchor_dust": 1}},
	},
	&"a_portable_way_home": {
		"title": "A Portable Way Home", "category": &"main", "giver": "Benjamin Franklin", "icon": "dfgui_icon-wand.png",
		"description": "The first Anchor Core can do more than stabilize a doorway. Ben intends to turn it into a reliable escape route for every future expedition.",
		"requires_quests": [&"the_house_keeps_time"],
		"steps": [
			{"text": "Return to Ben's laboratory and build the Continuity Kite from the recovered Anchor Core.", "condition": {"type": &"invention_owned", "id": &"continuity_kite"}},
			{"text": "Test the Continuity Kite from inside the Haunted Mansion.", "condition": {"type": &"story_flag", "id": &"continuity_kite_used"}},
		],
		"rewards": {"duckets": 75, "items": {&"ether": 1}},
	},
	&"the_ashes_remember": {
		"title": "The Ashes Remember", "category": &"main", "giver": "Dracula and Frankenstein's Monster", "icon": "dfgui_icon-clock.png",
		"description": "The Mansion's surviving witnesses have identified the next tear: Ashfall, a burned address where the house's missing history is still being rewritten. Their route is mandatory Franklin & Company business, not an exhibition trial.",
		"requires_flags": [&"horror_arc_mansion_briefed"],
		"steps": [
			{"text": "Hear Dracula and Frankenstein's Monster's account in the stabilized Mansion ballroom.", "condition": {"type": &"story_flag", "id": &"horror_arc_mansion_briefed"}},
			{"text": "Follow the mandatory horror route into the Ashfall address.", "condition": {"type": &"story_flag", "id": &"ashfall_address_entered"}},
		],
		"rewards": {"duckets": 0, "items": {}},
	},
	&"a_second_door": {
		"title": "A Second Door", "category": &"main", "giver": "Benjamin Franklin", "icon": "dfgui_icon-wand.png",
		"description": "The stabilized Mansion revealed another address on the fault line. Build a town Observatory and choose Asterion Station as its anchored universe.",
		"requires_quests": [&"the_house_keeps_time"],
		"steps": [
			{"text": "Build the Observatory and anchor Asterion Station.", "condition": {"type": &"facility_built", "id": "Observatory"}},
			{"text": "Enter Asterion Station through the Observatory.", "condition": {"type": &"story_flag", "id": &"asterion_entered"}},
		],
		"rewards": {"duckets": 80, "items": {&"ether": 2, &"research_notes": 1, &"anchor_dust": 1}},
	},
	&"the_last_shift": {
		"title": "The Last Shift", "category": &"main", "giver": "Asterion Station", "icon": "dfgui_icon-skillbook.png",
		"description": "A derelict agricultural station is still enforcing a work schedule centuries after its crew vanished. Find the surviving Astronaut, restore life support, and dismiss the machine running the final shift.",
		"requires_quests": [&"a_second_door"],
		"steps": [
			{"text": "Survive Asterion's docking-bay security check.", "condition": {"type": &"story_flag", "id": &"asterion_dock_cleared"}},
			{"text": "Speak with the stranded Astronaut.", "condition": {"type": &"story_flag", "id": &"asterion_astronaut_met"}},
			{"text": "Recover the biocircuit from Medical.", "condition": {"type": &"story_flag", "id": &"asterion_biocircuit_found"}},
			{"text": "Restart the hydroponics oxygen loop.", "condition": {"type": &"story_flag", "id": &"asterion_station_restored"}},
			{"text": "Defeat the Mother Computer in Station Control.", "condition": {"type": &"story_flag", "id": &"asterion_station_complete"}},
			{"text": "Recruit the Astronaut into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"astronaut"}},
		],
		"rewards": {"duckets": 240, "items": {&"phoenix_tonic": 1}, "party_experience": 120},
	},
	&"the_oldest_address": {
		"title": "The Oldest Address", "category": &"main", "giver": "Asterion Navigation Archive", "icon": "dfgui_icon-shovel.png",
		"description": "Asterion's charts identify a universe that developed traffic law before written language. Choose the Primeval Expanse and give it a Trailhead Lodge in town.",
		"requires_quests": [&"the_last_shift"],
		"steps": [
			{"text": "Build the Trailhead Lodge and anchor the Primeval Expanse.", "condition": {"type": &"facility_built", "id": "Trailhead Lodge"}},
			{"text": "Enter the Primeval Expanse through the Lodge.", "condition": {"type": &"story_flag", "id": &"primeval_entered"}},
		],
		"rewards": {"duckets": 110, "items": {&"tonic": 2, &"research_notes": 1}},
	},
	&"municipal_extinction": {
		"title": "Municipal Extinction", "category": &"main", "giver": "Primeval Borough", "icon": "dfgui_icon-monsterbook.png",
		"description": "A stone traffic network has mistaken a meteor siren for rush-hour control. Help the local Caveman interpret his own infrastructure before every dinosaur reports to the same intersection.",

		"requires_quests": [&"the_oldest_address"],
		"steps": [
			{"text": "Survive the Primeval Grove's welcoming committee.", "condition": {"type": &"story_flag", "id": &"primeval_grove_cleared"}},
			{"text": "Meet the Caveman maintaining Primeval Borough.", "condition": {"type": &"story_flag", "id": &"primeval_caveman_met"}},
			{"text": "Read the stone traffic totem in the Grove.", "condition": {"type": &"story_flag", "id": &"primeval_traffic_clue_found"}},
			{"text": "Build the Paleo-Linguistic Telegraph in Ben's laboratory.", "condition": {"type": &"invention_owned", "id": &"paleo_translator"}},
			{"text": "Decode the cave computer in the Ruins.", "condition": {"type": &"story_flag", "id": &"primeval_terminal_decoded"}},
			{"text": "Defend the relay nest from its dinosaur attendants.", "condition": {"type": &"story_flag", "id": &"primeval_nest_ambush_cleared"}},
			{"text": "Reset the meteor siren at the relay nest.", "condition": {"type": &"story_flag", "id": &"primeval_caldera_open"}},
			{"text": "Defeat the Tyrant of the Morning Commute.", "condition": {"type": &"story_flag", "id": &"primeval_scenario_complete"}},
			{"text": "Recruit the Caveman into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"caveman"}},
		],
		"rewards": {"duckets": 320, "items": {&"phoenix_tonic": 1, &"research_notes": 1, &"anchor_dust": 2}, "party_experience": 180},
	},
	&"a_brighter_night": {
		"title": "A Brighter Night", "category": &"main", "giver": "Asterion Navigation Archive", "icon": "dfgui_icon-lightning.png",
		"description": "Asterion's recovered navigation archive identifies a city where the sun never sets. Anchor Helios Arcology through a proper night establishment; Primeval's cave computer can explain the connection later.",
		"requires_quests": [&"the_last_shift"],
		"steps": [
			{"text": "Build the Afterlight Club and anchor Helios Arcology.", "condition": {"type": &"facility_built", "id": "Afterlight Club"}},
			{"text": "Enter Helios Arcology through the Club.", "condition": {"type": &"story_flag", "id": &"helios_entered"}},
		],
		"rewards": {"duckets": 140, "items": {&"ether": 2, &"research_notes": 1, &"anchor_dust": 1}},
	},
	&"mandatory_daylight": {
		"title": "Mandatory Daylight", "category": &"main", "giver": "Neon Viper", "icon": "dfgui_icon-wand.png",
		"description": "Helios replaced its night cycle with a productivity ordinance. Help Neon Viper disable the daylight network and return one honest midnight to the city.",
		"requires_quests": [&"a_brighter_night"],
		"steps": [
			{"text": "Survive the Skybridge compliance inspection.", "condition": {"type": &"story_flag", "id": &"helios_skybridge_cleared"}},
			{"text": "Find Neon Viper in the Public Market.", "condition": {"type": &"story_flag", "id": &"helios_viper_met"}},
			{"text": "Read the mandatory-daylight ordinance.", "condition": {"type": &"story_flag", "id": &"helios_curfew_clue_found"}},
			{"text": "Build the Nocturnal Phase Inverter in Ben's laboratory.", "condition": {"type": &"invention_owned", "id": &"night_phase_inverter"}},
			{"text": "Disable the Transit Exchange daylight node.", "condition": {"type": &"story_flag", "id": &"helios_transit_node_disabled"}},
			{"text": "Break the Recovery Clinic security ambush.", "condition": {"type": &"story_flag", "id": &"helios_clinic_ambush_cleared"}},
			{"text": "Disable the Recovery Clinic daylight node.", "condition": {"type": &"story_flag", "id": &"helios_clinic_node_disabled"}},
			{"text": "Open the Solar Core after both nodes go dark.", "condition": {"type": &"story_flag", "id": &"helios_core_open"}},
			{"text": "Defeat the Civic Sun at the Solar Core.", "condition": {"type": &"story_flag", "id": &"helios_scenario_complete"}},
			{"text": "Recruit Neon Viper into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"neon_viper"}},
		],
		"rewards": {"duckets": 420, "items": {&"phoenix_tonic": 1, &"research_notes": 1, &"anchor_dust": 2}, "party_experience": 240},
	},
	&"a_colder_address": {
		"title": "A Colder Address", "category": &"main", "giver": "Helios Midnight Anchor", "icon": "dfgui_icon-cauldron.png",
		"description": "The restored Helios night cycle reveals a signal that is colder than empty space and considerably more bureaucratic. Build Cold Storage and anchor Frosthold Kingdom.",
		"requires_any_quests": [&"municipal_extinction", &"mandatory_daylight"],
		"steps": [
			{"text": "Build Cold Storage and anchor Frosthold Kingdom.", "condition": {"type": &"facility_built", "id": "Cold Storage"}},
			{"text": "Enter Frosthold Kingdom through Cold Storage.", "condition": {"type": &"story_flag", "id": &"frosthold_entered"}},
		],
		"rewards": {"duckets": 175, "items": {&"tonic": 2, &"research_notes": 2, &"anchor_dust": 1}},
	},
	&"the_frozen_ledger": {
		"title": "The Frozen Ledger", "category": &"main", "giver": "Frost Lich Emperor", "icon": "dfgui_icon-crown.png",
		"description": "Frosthold's treasury has classified body heat as taxable luxury property. Help its deposed Lich Emperor void the law before the kingdom's Whiteout Auditor collects every living soul.",

		"requires_quests": [&"a_colder_address"],
		"steps": [
			{"text": "Break the Snow Gate's collection patrol.", "condition": {"type": &"story_flag", "id": &"frosthold_gate_cleared"}},
			{"text": "Find the Frost Lich Emperor in the frozen market.", "condition": {"type": &"story_flag", "id": &"frost_lich_met"}},
			{"text": "Read the royal heat-tax rune.", "condition": {"type": &"story_flag", "id": &"frosthold_rune_clue_found"}},
			{"text": "Build the Thermal Arbitration Coil in Ben's laboratory.", "condition": {"type": &"invention_owned", "id": &"thermal_arbitration_coil"}},
			{"text": "Warm the first seal on the Crystal Causeway.", "condition": {"type": &"story_flag", "id": &"frosthold_causeway_seal_open"}},
			{"text": "Defeat the Rune Hall collection detail.", "condition": {"type": &"story_flag", "id": &"frosthold_rune_ambush_cleared"}},
			{"text": "Warm the second seal and open the Ice Throne.", "condition": {"type": &"story_flag", "id": &"frosthold_throne_open"}},
			{"text": "Defeat the Whiteout Auditor at the Ice Throne.", "condition": {"type": &"story_flag", "id": &"frosthold_scenario_complete"}},
			{"text": "Recruit the Frost Lich Emperor into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"frost_lich_emperor"}},
		],
		"rewards": {"duckets": 520, "items": {&"phoenix_tonic": 2, &"research_notes": 1, &"anchor_dust": 3}, "party_experience": 300},
	},
	&"tea_beyond_winter": {
		"title": "Tea Beyond Winter", "category": &"main", "giver": "Frosthold Repeal Office", "icon": "dfgui_icon-goblet.png",
		"description": "A recovered tax receipt bears a cherry blossom seal and records a warm evening that Frosthold never had. Build a Tea House and anchor the impossible address.",
		"requires_quests": [&"the_frozen_ledger", &"municipal_extinction", &"mandatory_daylight"],
		"steps": [
			{"text": "Build the Tea House and anchor Moonpetal Court.", "condition": {"type": &"facility_built", "id": "Tea House"}},
			{"text": "Enter Moonpetal Court through the Tea House.", "condition": {"type": &"story_flag", "id": &"moonpetal_entered"}},
		],
		"rewards": {"duckets": 210, "items": {&"ether": 2, &"research_notes": 2, &"anchor_dust": 1}},
	},
	&"the_counterfeit_moon": {
		"title": "The Counterfeit Moon", "category": &"main", "giver": "Kitsune Empress", "icon": "dfgui_icon-wand.png",
		"description": "Magistrate Enma has replaced Moonpetal's citizens' memories with immaculate official copies. Help the Kitsune Empress prove which vows are real before the court's perfect festival becomes permanent.",
		"requires_quests": [&"tea_beyond_winter"],
		"steps": [
			{"text": "Break the Vermilion Gate inspection patrol.", "condition": {"type": &"story_flag", "id": &"moonpetal_gate_cleared"}},
			{"text": "Find the Kitsune Empress in Blossom Court.", "condition": {"type": &"story_flag", "id": &"kitsune_empress_met"}},
			{"text": "Read the duplicated vow at the Mirror Garden.", "condition": {"type": &"story_flag", "id": &"moonpetal_vow_clue_found"}},
			{"text": "Build the Electrostatic Veracity Lantern in Ben's laboratory.", "condition": {"type": &"invention_owned", "id": &"veracity_lantern"}},
			{"text": "Expose the first false vow and open the Bell Walk.", "condition": {"type": &"story_flag", "id": &"moonpetal_bell_walk_open"}},
			{"text": "Defeat the Bell Walk wedding procession.", "condition": {"type": &"story_flag", "id": &"moonpetal_bell_ambush_cleared"}},
			{"text": "Expose the final false vow and open the Moon Palace.", "condition": {"type": &"story_flag", "id": &"moonpetal_palace_open"}},
			{"text": "Defeat Magistrate Enma at the Moon Palace.", "condition": {"type": &"story_flag", "id": &"moonpetal_scenario_complete"}},
			{"text": "Recruit the Kitsune Empress into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"kitsune_empress"}},
		],
		"rewards": {"duckets": 610, "items": {&"phoenix_tonic": 2, &"research_notes": 1, &"anchor_dust": 3}, "party_experience": 360},
	},
	&"bells_above_the_clouds": {
		"title": "Bells Above the Clouds", "category": &"main", "giver": "Moonpetal Memory Ledger", "icon": "dfgui_icon-crown.png",
		"description": "The restored Moonpetal ledger records a bell whose sound falls upward. Build a Belfry and anchor the celestial address above the fault line.",
		"requires_quests": [&"the_counterfeit_moon"],
		"steps": [
			{"text": "Build the Belfry and anchor Empyreal Court.", "condition": {"type": &"facility_built", "id": "Belfry"}},
			{"text": "Enter Empyreal Court through the Belfry.", "condition": {"type": &"story_flag", "id": &"empyreal_entered"}},
		],
		"rewards": {"duckets": 245, "items": {&"ether": 2, &"research_notes": 2, &"anchor_dust": 1}},
	},
	&"the_weight_of_heaven": {
		"title": "The Weight of Heaven", "category": &"main", "giver": "Archangel Commander", "icon": "dfgui_icon-lightning.png",
		"description": "Empyreal Court has privatized gravity and begun repossessing flight from anyone behind on their miracle fees. Help the Archangel Commander overturn the ordinance at the Seraph Tribunal.",
		"requires_quests": [&"bells_above_the_clouds"],

		"steps": [
			{"text": "Defeat the Cloudstep weigh-station patrol.", "condition": {"type": &"story_flag", "id": &"empyreal_landing_cleared"}},
			{"text": "Meet the Archangel Commander in the Garden of Appeals.", "condition": {"type": &"story_flag", "id": &"archangel_commander_met"}},
			{"text": "Read the gravity ordinance in the Forum of Measures.", "condition": {"type": &"story_flag", "id": &"empyreal_gravity_clue_found"}},
			{"text": "Build the Galvanic Counterweight in Ben's laboratory.", "condition": {"type": &"invention_owned", "id": &"galvanic_counterweight"}},
			{"text": "Rebalance the first gravity seal and open the Reliquary Aerie.", "condition": {"type": &"story_flag", "id": &"empyreal_aerie_open"}},
			{"text": "Defeat the Reliquary repossession detail.", "condition": {"type": &"story_flag", "id": &"empyreal_aerie_ambush_cleared"}},
			{"text": "Rebalance the final seal and open the Seraph Tribunal.", "condition": {"type": &"story_flag", "id": &"empyreal_tribunal_open"}},
			{"text": "Defeat the High Comptroller of Gravity.", "condition": {"type": &"story_flag", "id": &"empyreal_scenario_complete"}},
			{"text": "Recruit the Archangel Commander into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"archangel_commander"}},
		],
		"rewards": {"duckets": 720, "items": {&"phoenix_tonic": 2, &"anchor_dust": 4}, "party_experience": 430},
	},
	&"the_blood_moon_clause": {
		"title": "The Blood Moon Clause", "category": &"hidden", "giver": "Crimson Challenge Seal", "icon": "dfgui_icon-sword.png",
		"description": "Magistrate Enma's private seal has summoned a Crimson Oni to the Bell Walk. The creature treats combat as an employment interview and refuses all conventional paperwork.",
		"hidden": true, "requires_flags": [&"crimson_oni_met"],
		"steps": [
			{"text": "Answer the Crimson Challenge Seal at the Bell Walk.", "condition": {"type": &"story_flag", "id": &"crimson_oni_met"}},
			{"text": "Defeat the Crimson Oni in the Blood Moon Trial.", "condition": {"type": &"story_flag", "id": &"crimson_oni_trial_complete"}},
			{"text": "Recruit the Crimson Oni into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"crimson_oni"}},
		],
		"rewards": {"duckets": 420, "items": {&"phoenix_tonic": 1, &"anchor_dust": 2}, "party_experience": 260},
	},
	&"the_fault_line_stray": {
		"title": "The Fault-Line Stray", "category": &"hidden", "giver": "A Scent Behind the Wallpaper", "icon": "dfgui_icon-monsterbook.png",
		"description": "Stabilizing the Haunted Mansion exposed a creature that can smell false doorways. It appears to regard combat as the only trustworthy introduction.",
		"hidden": true, "requires_flags": [&"rift_jackal_met"],
		"steps": [
			{"text": "Find the creature in the stabilized Haunted Mansion.", "condition": {"type": &"story_flag", "id": &"rift_jackal_met"}},
			{"text": "Defeat the Rift Jackal without collapsing the threshold.", "condition": {"type": &"story_flag", "id": &"rift_jackal_trial_complete"}},
			{"text": "Recruit the Rift Jackal into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"rift_jackal"}},
		],
		"rewards": {"duckets": 260, "items": {&"anchor_dust": 2, &"tonic": 2}, "party_experience": 180},
	},
	&"the_green_audit": {
		"title": "The Green Audit", "category": &"hidden", "giver": "An Unauthorized Survey Stake", "icon": "dfgui_icon-monsterbook.png",
		"description": "After the Primeval traffic crisis, a Mossback Surveyor begins auditing Franklin's use of soil, roads, and edible municipal property. It accepts combat as a legally binding site inspection.",
		"hidden": true, "requires_flags": [&"mossback_surveyor_met"],
		"steps": [
			{"text": "Find the surveyor in the stabilized Primeval Borough.", "condition": {"type": &"story_flag", "id": &"mossback_surveyor_met"}},
			{"text": "Pass the Mossback Surveyor's field inspection.", "condition": {"type": &"story_flag", "id": &"mossback_surveyor_trial_complete"}},
			{"text": "Recruit the Mossback Surveyor into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"mossback_surveyor"}},
		],
		"rewards": {"duckets": 330, "items": {&"provisions": 3, &"anchor_dust": 1}, "party_experience": 225},
	},
	&"the_undeliverable_parcel": {
		"title": "The Undeliverable Parcel", "category": &"hidden", "giver": "A Stamp from Yesterday", "icon": "dfgui_icon-monsterbook.png",
		"description": "With Helios's permanent day shift broken, a Cobalt Courier has resumed a delivery addressed to New Philadelphia before the town existed. Company policy requires combat verification before the recipient may sign.",
		"hidden": true, "requires_flags": [&"cobalt_courier_met"],
		"steps": [
			{"text": "Find the courier at the stabilized Helios transit platform.", "condition": {"type": &"story_flag", "id": &"cobalt_courier_met"}},
			{"text": "Complete the courier's combat verification.", "condition": {"type": &"story_flag", "id": &"cobalt_courier_trial_complete"}},
			{"text": "Recruit the Cobalt Courier into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"cobalt_courier"}},
		],

		"rewards": {"duckets": 390, "items": {&"ether": 2, &"research_notes": 2}, "party_experience": 250},
	},
	&"the_load_bearing_interview": {
		"title": "The Load-Bearing Interview", "category": &"hidden", "giver": "Asterion Maintenance Plate", "icon": "dfgui_icon-monsterbook.png",
		"description": "Asterion's last acting shop steward refuses to leave the station until a prospective employer survives a regulation structural interview.",
		"hidden": true, "requires_flags": [&"bulkhead_warden_met"],
		"steps": [
			{"text": "Find the dormant construct in stabilized Asterion Station Control.", "condition": {"type": &"story_flag", "id": &"bulkhead_warden_met"}},
			{"text": "Complete the Bulkhead Warden's load-bearing interview.", "condition": {"type": &"story_flag", "id": &"bulkhead_warden_trial_complete"}},
			{"text": "Recruit the Bulkhead Warden into Franklin & Company.", "condition": {"type": &"recruit_hired", "id": &"bulkhead_warden"}},
		],
		"rewards": {"duckets": 300, "items": {&"research_notes": 2, &"anchor_dust": 1}, "party_experience": 210},
	},
	&"company_at_work": {
		"title": "Company at Work", "category": &"side", "giver": "Franklin & Company Ledger", "icon": "dfgui_icon-pouch.png",
		"description": "An expedition company needs revenue between adventures. Assign a permanent hire to town work and collect the finished result.",
		"requires_flags": [&"town_foundations_complete"],
		"steps": [
			{"text": "Assign a recruit to any town facility.", "condition": {"type": &"facility_assignment_count", "amount": 1}},
			{"text": "Collect one completed facility assignment.", "condition": {"type": &"completed_job_count", "amount": 1}},
		],
		"rewards": {"duckets": 60, "items": {&"research_notes": 1}},
	},
	&"open_for_business": {
		"title": "Open for Business", "category": &"side", "giver": "New Philadelphia Service Ledger", "icon": "dfgui_icon-food.png",
		"description": "A town is more than a set of roofs. Test the direct services at each founding facility and make certain adventurers can actually use them.",
		"requires_flags": [&"town_foundations_complete"],
		"steps": [
			{"text": "Purchase one expedition supply from the Café counter.", "condition": {"type": &"story_flag", "id": &"town_service_purchase_made"}},
			{"text": "Use the Clinic's full-party treatment service.", "condition": {"type": &"story_flag", "id": &"clinic_treatment_used"}},
			{"text": "Archive the company's field records at the Library.", "condition": {"type": &"story_flag", "id": &"library_records_archived"}},
		],
		"rewards": {"duckets": 50, "items": {&"tonic": 1, &"provisions": 1}},
	},
	&"echoes_on_paper": {
		"title": "Echoes on Paper", "category": &"hidden", "giver": "Household Ledger", "icon": "dfgui_icon-redbook.png",
		"description": "The recovered ledger describes contradictions the ordinary Library cannot index. Ben will need a better machine—and somebody must decode the echoes.",
		"hidden": true, "requires_flags": [&"mansion_first_room_complete"],
		"steps": [
			{"text": "Invent the Electrostatic Cataloging Engine in Ben's lab.", "condition": {"type": &"invention_owned", "id": &"cataloging_engine"}},
			{"text": "Complete the Library assignment: Decode Mansion Echoes.", "condition": {"type": &"job_completed", "id": &"library_decode_echoes"}},
		],
		"rewards": {"duckets": 100, "items": {&"anchor_dust": 2}},
	},
	&"the_mansions_second_opinion": {
		"title": "The Mansion's Second Opinion", "category": &"side", "giver": "The Solved Clock", "icon": "dfgui_icon-clock.png",
		"description": "The household records leave Ben with one practical decision: preserve their resonance for research or turn it into immediate public safety supplies. Either choice is permanent, visible in the journal, and never blocks the campaign.",
		"requires_flags": [&"mansion_first_room_complete"],
		"steps": [
			{"text": "Choose how Franklin & Company will use the Mansion's recovered field notes.", "condition": {"type": &"choice_selected", "quest_id": &"the_mansions_second_opinion"}},
		],
		"choices": [
			{"id": &"archive", "name": "Archive the Resonance", "description": "Send the notes to the Library so future inventions have a better paper trail.", "outcome": "The Library preserves the Mansion's contradictory field notes for Ben's next laboratory project.", "rewards": {"duckets": 10, "items": {&"research_notes": 2, &"anchor_dust": 1}}, "story_flags": {&"mansion_notes_archived": true}},
			{"id": &"circulate", "name": "Fund the Watch", "description": "Convert the notes into immediate supplies and an evening safety fund for New Philadelphia.", "outcome": "The Café and Clinic circulate the notes as a practical evening-watch program for residents.", "rewards": {"duckets": 55, "items": {&"tonic": 2, &"provisions": 1}}, "story_flags": {&"mansion_notes_circulated": true}},
		],

		"rewards": {"duckets": 20, "items": {}},
	},
}

# These are campaign obligations, deliberately separate from RECRUIT_CATALOG
# and optional content.  A stage can be introduced before its destination is
# authored, but must never be represented as a trial, postgame, or menu unlock.
const REQUIRED_NAMED_CHARACTER_ARCS := {
	&"mansion_ashfall_horror": {
		"characters": [&"dracula", &"frankenstein_monster"],
		"stages": [
			{"destination": &"haunted_mansion", "required_flag": &"horror_arc_mansion_briefed"},
			{"destination": &"ashfall", "required_flag": &"ashfall_address_entered"},
		],
	},
	&"pelagic_depths": {
		"characters": [&"cthulhu"],
		"stages": [{"destination": &"pelagic", "required_flag": &"pelagic_depths_entered"}],
	},
	&"ashfall_empyreal_magic": {
		"characters": [&"dark_mage"],
		"stages": [
			{"destination": &"ashfall", "required_flag": &"ashfall_magic_conflict_started"},
			{"destination": &"empyreal", "required_flag": &"empyreal_magic_conflict_resolved"},
		],
	},
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
	if UNIVERSE_SAVE_POINTS.size() != 8 or not UNIVERSE_SAVE_POINTS.has(&"mansion_archive"):
		errors.append("World catalog must retain all universe save points.")
	if UNIVERSE_TREASURE_CACHES.size() != 5 or not UNIVERSE_TREASURE_CACHES.has(&"primeval_ruins_plinth"):
		errors.append("World catalog must retain all universe treasure caches.")
	if EQUIPMENT_SLOTS.size() != 6 or EQUIPMENT_AFFINITIES.size() != 15:
		errors.append("World catalog must retain equipment slots and affinities.")
	if SERVICE_ITEM_CATALOG.size() != 6 or SERVICE_STOCK.size() != 2 or ARMORY_STOCK.is_empty():
		errors.append("World catalog must retain service and armory stock.")
	if FACILITY_DEFINITIONS.size() != 11 or INVENTION_DEFINITIONS.size() != 12:
		errors.append("World catalog must retain facility and invention definitions.")
	if EXPEDITION_TOOL_CONTRACTS.size() != 7 or FACILITY_UPGRADE_DEFINITIONS.is_empty():
		errors.append("World catalog must retain expedition tools and facility upgrades.")
	if SKILL_TREES.size() != 15 or QUEST_DEFINITIONS.is_empty():
		errors.append("World catalog must retain skills and quest definitions.")
	if REQUIRED_NAMED_CHARACTER_ARCS.size() != 3:
		errors.append("World catalog must retain the three required named-character main arcs.")
	for arc_id in REQUIRED_NAMED_CHARACTER_ARCS:
		var arc: Dictionary = REQUIRED_NAMED_CHARACTER_ARCS[arc_id]
		if (arc.get("characters", []) as Array).is_empty() or (arc.get("stages", []) as Array).is_empty():
			errors.append("Named-character arc %s needs characters and mandatory stages." % arc_id)
	return PackedStringArray(errors)
