class_name CampaignEncounterCatalog
extends RefCounted

## Battle formation content is intentionally separate from actor construction,
## reward rolls, and battle presentation. Existing callers retain the combat
## database facade while mandatory-address records can depend on this stable
## content authority directly.

const ADDRESS_CONTENT_PATH := "res://ben_rpg/combat/campaign_address_encounter_catalog.gd"

static var CORE_CONTRACTS := {
	&"mansion_foyer_intro": {"name": "A Bad First Impression", "enemies": [&"schoolgirl_ghost", &"war_book"], "backdrop_profile": &"mansion_foyer_battle_backdrop", "scripted": true},
	&"mansion_restless_books": {"name": "Restless Stacks", "enemies": [&"war_book", &"war_book"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
	&"mansion_lost_hours": {"name": "The House Keeps Strange Hours", "enemies": [&"schoolgirl_ghost", &"clock_mirror"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
	&"mansion_gallery_ambush": {"name": "The Portraits Object", "enemies": [&"composer_portrait", &"schoolgirl_ghost"], "backdrop_profile": &"mansion_gallery_battle_backdrop", "scripted": true},
	&"mansion_restless_portraits": {"name": "Restless Exhibition", "enemies": [&"composer_portrait", &"war_book"], "backdrop_profile": &"mansion_gallery_battle_backdrop"},
	&"mansion_nursery_ambush": {"name": "Children Should Be Seen and Feared", "enemies": [&"haunted_doll", &"haunted_doll"], "backdrop_profile": &"mansion_foyer_battle_backdrop", "scripted": true},
	&"mansion_doll_procession": {"name": "The Doll Procession", "enemies": [&"haunted_doll", &"schoolgirl_ghost"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
	&"mansion_last_dance": {"name": "The Last Dance", "enemies": [&"composer_portrait", &"clock_mirror"], "backdrop_profile": &"mansion_gallery_battle_backdrop"},
	&"mansion_archive_boss": {"name": "Your Appointment Was 250 Years Ago", "enemies": [&"clock_mirror_boss"], "backdrop_profile": &"mansion_gallery_battle_backdrop", "scripted": true, "boss": true, "boss_policy": {"id": &"mansion_clock_mirror", "phases": [{"id": &"ticking", "label": "TICKING", "minimum_hp_ratio": 0.67, "actions": [{"action": &"spectral_touch"}, {"action": &"steal_time", "telegraph": "TICKING: The mirror's hands climb toward your ready gauges. Steal Time is coming—Defend, delay it, or tune the clock."}]}, {"id": &"appointment", "label": "4:44 APPOINTMENT", "minimum_hp_ratio": 0.34, "actions": [{"action": &"steal_time", "telegraph": "4:44 APPOINTMENT: The clock fixes on a single future. Steal Time is coming—Defend, delay it, or tune the clock."}, {"action": &"late_fee"}]}, {"id": &"midnight", "label": "THIRTEENTH HOUR", "minimum_hp_ratio": 0.0, "actions": [{"action": &"late_fee"}, {"action": &"steal_time", "telegraph": "THIRTEENTH HOUR: The mirror tries to take tomorrow itself. Steal Time is coming—Defend, delay it, or tune the clock."}]}]}},
	&"mansion_rift_jackal_trial": {"name": "The Fault-Line Stray", "enemies": [&"rift_jackal_challenger"], "backdrop_profile": &"mansion_gallery_battle_backdrop", "scripted": true, "boss": true},
	&"asterion_dock_intro": {"name": "Please Present Crew Identification", "enemies": [&"sentry_drone", &"work_robot"], "backdrop_profile": &"asterion_dock_battle_backdrop", "scripted": true},
	&"asterion_maintenance_detail": {"name": "Unscheduled Maintenance", "enemies": [&"work_robot", &"work_robot"], "backdrop_profile": &"asterion_dock_battle_backdrop"},
	&"asterion_greenhouse_patrol": {"name": "Hostile Horticulture Department", "enemies": [&"sentry_drone", &"work_robot"], "backdrop_profile": &"asterion_hydro_battle_backdrop"},
	&"asterion_medical_ambush": {"name": "Mandatory Preventive Care", "enemies": [&"medical_robot", &"sentry_drone"], "backdrop_profile": &"asterion_medical_battle_backdrop", "scripted": true},
	&"asterion_medical_patrol": {"name": "Second Opinion", "enemies": [&"medical_robot", &"work_robot"], "backdrop_profile": &"asterion_medical_battle_backdrop"},
	&"asterion_hydro_ambush": {"name": "Productivity Pruning", "enemies": [&"sentry_drone", &"sentry_drone"], "backdrop_profile": &"asterion_hydro_battle_backdrop", "scripted": true},
	&"asterion_command_patrol": {"name": "Management Escort", "enemies": [&"machine_commander", &"sentry_drone"], "backdrop_profile": &"asterion_command_battle_backdrop"},
	&"asterion_mother_computer": {"name": "The Final Shift Review", "enemies": [&"mother_computer"], "backdrop_profile": &"asterion_command_battle_backdrop", "scripted": true, "boss": true},
	&"asterion_bulkhead_warden_trial": {"name": "The Load-Bearing Interview", "enemies": [&"bulkhead_warden_challenger"], "backdrop_profile": &"asterion_command_battle_backdrop", "scripted": true, "boss": true},
	&"primeval_grove_intro": {"name": "Local Right-of-Way Dispute", "enemies": [&"primeval_raptor", &"primeval_raptor"], "backdrop_profile": &"primeval_ground_battle_backdrop", "scripted": true},
	&"primeval_raptor_pack": {"name": "Unlicensed Traffic", "enemies": [&"primeval_raptor", &"primeval_raptor"], "backdrop_profile": &"primeval_ground_battle_backdrop"},
	&"primeval_heavy_herd": {"name": "Right-of-Way Hearing", "enemies": [&"stone_triceratops"], "backdrop_profile": &"primeval_ground_battle_backdrop"},
	&"primeval_nest_ambush": {"name": "Relay Nest Attendants", "enemies": [&"municipal_spinosaur", &"primeval_raptor"], "backdrop_profile": &"primeval_ground_battle_backdrop", "scripted": true},
	&"primeval_nest_patrol": {"name": "Protective Parents Association", "enemies": [&"primeval_raptor", &"stone_triceratops"], "backdrop_profile": &"primeval_ground_battle_backdrop"},
	&"primeval_caldera_patrol": {"name": "Caldera Express Lane", "enemies": [&"municipal_spinosaur", &"primeval_raptor"], "backdrop_profile": &"primeval_ground_battle_backdrop"},
	&"primeval_commute_tyrant": {"name": "The Morning Commute", "enemies": [&"commute_tyrant"], "backdrop_profile": &"primeval_ground_battle_backdrop", "scripted": true, "boss": true},
	&"primeval_mossback_trial": {"name": "The Green Audit", "enemies": [&"mossback_surveyor_challenger"], "backdrop_profile": &"primeval_ground_battle_backdrop", "scripted": true, "boss": true},
	&"helios_skybridge_intro": {"name": "Skybridge Compliance Inspection", "enemies": [&"helios_mech", &"helios_assassin"], "backdrop_profile": &"helios_skybridge_battle_backdrop", "scripted": true},
	&"helios_market_patrol": {"name": "Authorized Shopping Hours", "enemies": [&"helios_assassin", &"helios_mech"], "backdrop_profile": &"helios_market_battle_backdrop"},
	&"helios_transit_patrol": {"name": "Proof of Fare and Wakefulness", "enemies": [&"helios_gunner", &"helios_mech"], "backdrop_profile": &"helios_transit_battle_backdrop"},
	&"helios_clinic_ambush": {"name": "Mandatory Rest Prevention", "enemies": [&"helios_security", &"helios_assassin"], "backdrop_profile": &"helios_clinic_battle_backdrop", "scripted": true},
	&"helios_clinic_patrol": {"name": "Second Opinion Denied", "enemies": [&"helios_security", &"helios_mech"], "backdrop_profile": &"helios_clinic_battle_backdrop"},
	&"helios_civic_sun": {"name": "The Last Mandatory Day", "enemies": [&"civic_sun"], "backdrop_profile": &"helios_civic_sun_battle_backdrop", "scripted": true, "boss": true},
	&"helios_cobalt_courier_trial": {"name": "The Undeliverable Parcel", "enemies": [&"cobalt_courier_challenger"], "backdrop_profile": &"helios_transit_battle_backdrop", "scripted": true, "boss": true},
	&"frosthold_gate_intro": {"name": "Declaration of Body Heat", "enemies": [&"frost_collector", &"frost_necromancer"], "backdrop_profile": &"frosthold_snow_battle_backdrop", "scripted": true},
	&"frosthold_market_patrol": {"name": "Unscheduled Thermal Inspection", "enemies": [&"frost_collector", &"frost_collector"], "backdrop_profile": &"frosthold_snow_battle_backdrop"},
	&"frosthold_causeway_patrol": {"name": "Crystal Asset Seizure", "enemies": [&"ice_colossus", &"frost_necromancer"], "backdrop_profile": &"frosthold_snow_battle_backdrop"},
	&"frosthold_rune_ambush": {"name": "The Collection Detail", "enemies": [&"frost_collector", &"ice_colossus"], "backdrop_profile": &"frosthold_snow_battle_backdrop", "scripted": true},
	&"frosthold_rune_patrol": {"name": "Penalty and Interest", "enemies": [&"frost_necromancer", &"frost_collector"], "backdrop_profile": &"frosthold_snow_battle_backdrop"},
	&"frosthold_whiteout_auditor": {"name": "The Final Thermal Audit", "enemies": [&"whiteout_auditor"], "backdrop_profile": &"frosthold_snow_battle_backdrop", "scripted": true, "boss": true},
	&"moonpetal_gate_intro": {"name": "Please State Your Original Memory", "enemies": [&"memory_inspector", &"fox_attendant"], "backdrop_profile": &"moonpetal_gate_battle_backdrop", "scripted": true},
	&"moonpetal_court_patrol": {"name": "Official Festival Recollection", "enemies": [&"memory_inspector", &"memory_inspector"], "backdrop_profile": &"moonpetal_court_battle_backdrop"},
	&"moonpetal_garden_patrol": {"name": "Reflections With Credentials", "enemies": [&"vow_spider", &"memory_inspector"], "backdrop_profile": &"moonpetal_garden_battle_backdrop"},
	&"moonpetal_bell_ambush": {"name": "A Wedding Nobody Remembers", "enemies": [&"fox_attendant", &"vow_spider"], "backdrop_profile": &"moonpetal_bell_battle_backdrop", "scripted": true},
	&"moonpetal_bell_patrol": {"name": "The Procession Repeats", "enemies": [&"fox_attendant", &"memory_inspector"], "backdrop_profile": &"moonpetal_bell_battle_backdrop"},
	&"moonpetal_magistrate_enma": {"name": "The Counterfeit Moon Hearing", "enemies": [&"magistrate_enma"], "backdrop_profile": &"moonpetal_palace_battle_backdrop", "scripted": true, "boss": true},
	&"moonpetal_crimson_oni_trial": {"name": "The Blood Moon Employment Interview", "enemies": [&"crimson_oni_challenger"], "backdrop_profile": &"moonpetal_bell_battle_backdrop", "scripted": true, "boss": true},
	&"empyreal_landing_intro": {"name": "Declaration of Personal Gravity", "enemies": [&"wind_bailiff", &"storm_repossessor"], "backdrop_profile": &"empyreal_landing_battle_backdrop", "scripted": true},
	&"empyreal_garden_patrol": {"name": "Appeal Denied in Advance", "enemies": [&"wind_bailiff", &"wind_bailiff"], "backdrop_profile": &"empyreal_garden_battle_backdrop"},
	&"empyreal_forum_patrol": {"name": "Ordinance Enforcement", "enemies": [&"fallen_notary", &"storm_repossessor"], "backdrop_profile": &"empyreal_forum_battle_backdrop"},
	&"empyreal_aerie_ambush": {"name": "Wing Repossession Detail", "enemies": [&"gravity_knight", &"wind_bailiff"], "backdrop_profile": &"empyreal_aerie_battle_backdrop", "scripted": true},
	&"empyreal_aerie_patrol": {"name": "Reliquary Asset Seizure", "enemies": [&"fallen_notary", &"gravity_knight"], "backdrop_profile": &"empyreal_upper_aerie_battle_backdrop"},
	&"empyreal_high_comptroller": {"name": "The Final Gravity Hearing", "enemies": [&"high_comptroller"], "backdrop_profile": &"empyreal_tribunal_battle_backdrop", "scripted": true, "boss": true},
	&"ashfall_cinder_gate_arrival_raid": {"name": "Cinder Gate Arrival Raid", "enemies": [&"ashfall_raider", &"ashfall_raider"], "backdrop_profile": &"ashfall_cinder_gate_battle_backdrop", "scripted": true},
}


static func ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for encounter_id in CORE_CONTRACTS.keys():
		ids.append(StringName(encounter_id))
	var address_content = load(ADDRESS_CONTENT_PATH)
	for encounter_id in address_content.CONTRACTS.keys():
		if encounter_id not in ids: ids.append(StringName(encounter_id))
	ids.sort()
	return ids


static func has(encounter_id: StringName) -> bool:
	if CORE_CONTRACTS.has(encounter_id): return true
	var address_content = load(ADDRESS_CONTENT_PATH)
	return address_content.CONTRACTS.has(encounter_id)


static func contracts() -> Dictionary:
	return CORE_CONTRACTS.duplicate(true)


static func definition(encounter_id: StringName) -> Dictionary:
	if CORE_CONTRACTS.has(encounter_id): return (CORE_CONTRACTS.get(encounter_id, {}) as Dictionary).duplicate(true)
	var address_content = load(ADDRESS_CONTENT_PATH)
	return address_content.battle_definition(encounter_id)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for encounter_id in ids():
		var contract := definition(encounter_id)
		if String(contract.get("name", "")).is_empty() or (contract.get("enemies", []) as Array).is_empty():
			errors.append("%s must define a name and enemy formation." % encounter_id)
		if StringName(contract.get("backdrop_profile", &"")) == &"":
			errors.append("%s must reference a battle backdrop profile." % encounter_id)
		var policy: Dictionary = contract.get("boss_policy", {})
		if not policy.is_empty() and (StringName(policy.get("id", &"")) == &"" or (policy.get("phases", []) as Array).is_empty()):
			errors.append("%s boss policy must have an id and phases." % encounter_id)
	return PackedStringArray(errors)
