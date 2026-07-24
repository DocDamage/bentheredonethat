class_name CampaignEncounterRewardCatalog
extends RefCounted

## Encounter reward production is content-owned. The combat database keeps a
## compatibility facade so battle and campaign callers retain their API.

const FIXED_REWARD_ENCOUNTERS := [
	&"mansion_archive_boss",
	&"mansion_rift_jackal_trial",
	&"asterion_mother_computer",
	&"asterion_bulkhead_warden_trial",
	&"primeval_commute_tyrant",
	&"primeval_mossback_trial",
	&"helios_civic_sun",
	&"helios_cobalt_courier_trial",
	&"frosthold_whiteout_auditor",
	&"moonpetal_crimson_oni_trial",
	&"moonpetal_magistrate_enma",
	&"empyreal_high_comptroller",
]

static func roll_loot(encounter_id: StringName, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if encounter_id == &"mansion_rift_jackal_trial":
		results.append({
			"instance_id": "mansion-threshold-collar", "id": &"threshold_collar", "base_name": "Threshold Collar",
			"display_name": "Epic Threshold Collar of the Impossible Scent", "slot": "accessory",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of the Impossible Scent", "stat": "speed", "value": 10}, {"name": "of Stable Footing", "stat": "defense", "value": 8}],
			"granted_action": &"faultline_pounce", "allowed_characters": [&"rift_jackal"], "kind": "gear", "source_pack": "Topdown Monsters Part 1",
		})
		return results
	if encounter_id == &"asterion_bulkhead_warden_trial":
		results.append({
			"instance_id": "asterion-shop-steward-key", "id": &"shop_steward_master_key", "base_name": "Shop Steward Master Key",
			"display_name": "Epic Shop Steward Master Key of Load-Bearing Authority", "slot": "charm",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Load-Bearing Authority", "stat": "defense", "value": 13}, {"name": "of Redundant Hinges", "stat": "max_hp", "value": 36}],
			"granted_action": &"pressure_lock", "allowed_characters": [&"bulkhead_warden"], "kind": "gear", "source_pack": "Topdown Monsters Part 1",
		})
		return results
	if encounter_id == &"primeval_mossback_trial":
		results.append({
			"instance_id": "primeval-surveyors-satchel", "id": &"surveyors_seed_satchel", "base_name": "Surveyor's Seed-Satchel",
			"display_name": "Epic Surveyor's Seed-Satchel of Perpetual Lunch", "slot": "charm",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Perpetual Lunch", "stat": "spirit", "value": 11}, {"name": "of Deep Roots", "stat": "defense", "value": 9}],
			"granted_action": &"hearty_provisions", "allowed_characters": [&"mossback_surveyor"], "kind": "gear", "source_pack": "Topdown Monsters Part 1",
		})
		return results
	if encounter_id == &"helios_cobalt_courier_trial":
		results.append({
			"instance_id": "helios-impossible-dispatch-bag", "id": &"impossible_dispatch_bag", "base_name": "Impossible Dispatch Bag",
			"display_name": "Epic Impossible Dispatch Bag of Yesterday's Thunder", "slot": "charm",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Yesterday's Thunder", "stat": "magic", "value": 12}, {"name": "of the Shortcut", "stat": "speed", "value": 11}],
			"granted_action": &"priority_delivery", "allowed_characters": [&"cobalt_courier"], "kind": "gear", "source_pack": "Topdown Monsters Part 1",
		})
		return results
	if encounter_id == &"empyreal_high_comptroller":
		results.append({
			"instance_id": "empyreal-charter-aegis", "id": &"charter_aegis", "base_name": "Aegis of Public Gravity",
			"display_name": "Epic Aegis of Public Gravity of Unmortgaged Wings", "slot": "charm",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Unmortgaged Wings", "stat": "speed", "value": 13}, {"name": "of the Charter", "stat": "spirit", "value": 14}],
			"granted_action": &"heavenly_aegis", "kind": "gear", "source_pack": "Ancient Greek Mythology",
		})
		results.append({"id": &"empyreal_anchor_core", "display_name": "Empyreal Gravity Anchor", "quantity": 1, "kind": "consumable", "source_pack": "Ancient Greek Mythology"})
		return results
	if String(encounter_id).begins_with("empyreal_"):
		if encounter_id == &"empyreal_landing_intro" or rng.randf() <= 0.68:
			var bases := [
				{"id": &"bailiff_spear", "name": "Bailiff's Wing-Spear", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"court_cuirass", "name": "Court Cuirass", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"gravity_seal", "name": "Gravity Seal", "slot": "accessory", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png"},
			]
			var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
			var roll := rng.randi_range(1, 100)
			var rarity := "Common" if roll <= 44 else ("Uncommon" if roll <= 75 else ("Rare" if roll <= 93 else "Epic"))
			var colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Tailwind", "stat": "speed", "value": rng.randi_range(5, 12)},
				{"name": "of the Charter", "stat": "spirit", "value": rng.randi_range(5, 12)},
				{"name": "of Counterweight", "stat": "defense", "value": rng.randi_range(5, 11)},
				{"name": "of Thunder", "stat": "magic", "value": rng.randi_range(5, 12)},
			]
			pool.shuffle()
			var modifiers: Array[Dictionary] = [pool[0]]
			if rarity in ["Rare", "Epic"]:
				modifiers.append(pool[1])
			results.append({"instance_id": "empyreal-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()], "id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]], "slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": colors[rarity], "modifiers": modifiers, "kind": "gear", "source_pack": "Ancient Greek Mythology"})
		if encounter_id == &"empyreal_landing_intro" or rng.randf() <= 0.64:
			results.append({"id": &"ether", "display_name": "Leyden Ether", "quantity": 1, "kind": "consumable", "source_pack": "Ancient Greek Mythology"})
		return results
	if encounter_id == &"moonpetal_crimson_oni_trial":
		results.append({
			"instance_id": "moonpetal-crimson-oath-sheath", "id": &"crimson_oath_sheath", "base_name": "Crimson Oath Sheath",
			"display_name": "Epic Crimson Oath Sheath of the Blood Moon", "slot": "weapon",
			"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of the Blood Moon", "stat": "attack", "value": 14}, {"name": "of Phantom Steps", "stat": "speed", "value": 12}],
			"granted_action": &"blood_moon_cleave", "allowed_characters": [&"crimson_oni"], "kind": "gear", "source_pack": "crimson oni samurai",
		})
		return results
	if encounter_id == &"moonpetal_magistrate_enma":
		results.append({
			"instance_id": "moonpetal-true-moon-mirror", "id": &"true_moon_mirror", "base_name": "Mirror of the True Moon",
			"display_name": "Epic Mirror of the True Moon of Nine Honest Shadows", "slot": "accessory",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Nine Honest Shadows", "stat": "magic", "value": 13}, {"name": "of Testimony", "stat": "spirit", "value": 11}],
			"granted_action": &"nine_tail_judgment", "kind": "gear", "source_pack": "Sakura Temple Asset Pack",
		})
		results.append({"id": &"moonpetal_anchor_core", "display_name": "Moonpetal Memory Anchor", "quantity": 1, "kind": "consumable", "source_pack": "Sakura Temple Asset Pack"})
		results.append({"id": &"crimson_challenge_seal", "display_name": "Crimson Challenge Seal", "quantity": 1, "kind": "consumable", "source_pack": "crimson oni samurai"})
		return results
	if String(encounter_id).begins_with("moonpetal_"):
		if encounter_id == &"moonpetal_gate_intro" or rng.randf() <= 0.66:
			var bases := [
				{"id": &"festival_fan", "name": "Festival War Fan", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"vow_silk", "name": "Vow-Silk Robe", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"lantern_charm", "name": "Veracity Lantern Charm", "slot": "charm", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png"},
			]
			var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
			var roll := rng.randi_range(1, 100)
			var rarity := "Common" if roll <= 46 else ("Uncommon" if roll <= 77 else ("Rare" if roll <= 94 else "Epic"))
			var colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Foxfire", "stat": "magic", "value": rng.randi_range(5, 11)},
				{"name": "of the Procession", "stat": "speed", "value": rng.randi_range(4, 10)},
				{"name": "of True Memory", "stat": "spirit", "value": rng.randi_range(5, 11)},
				{"name": "of Nine Shadows", "stat": "defense", "value": rng.randi_range(4, 10)},
			]
			pool.shuffle()
			var modifiers: Array[Dictionary] = [pool[0]]
			if rarity in ["Rare", "Epic"]:
				modifiers.append(pool[1])
			results.append({"instance_id": "moonpetal-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()], "id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]], "slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": colors[rarity], "modifiers": modifiers, "kind": "gear", "source_pack": "Sakura Temple Asset Pack"})
		if encounter_id == &"moonpetal_gate_intro" or rng.randf() <= 0.62:
			results.append({"id": &"smelling_salts", "display_name": "Smelling Salts", "quantity": 1, "kind": "consumable", "source_pack": "Sakura Temple Asset Pack"})
		return results
	if encounter_id == &"frosthold_whiteout_auditor":
		results.append({
			"instance_id": "frosthold-repealed-crown", "id": &"repealed_winter_crown", "base_name": "Crown of Repealed Winter",
			"display_name": "Epic Crown of Repealed Winter of Sovereign Warmth", "slot": "head",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon18.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Sovereign Warmth", "stat": "magic", "value": 12}, {"name": "of Repeal", "stat": "spirit", "value": 10}],
			"granted_action": &"frost_nova", "kind": "gear", "source_pack": "Frozen Kingdom – Top-Down Pixel Art Asset Pack",
		})
		results.append({"id": &"frosthold_anchor_core", "display_name": "Frosthold Thermal Anchor", "quantity": 1, "kind": "consumable", "source_pack": "Frozen Kingdom – Top-Down Pixel Art Asset Pack"})
		return results
	if String(encounter_id).begins_with("frosthold_"):
		if encounter_id == &"frosthold_gate_intro" or rng.randf() <= 0.64:
			var bases := [
				{"id": &"icebrand", "name": "Icebrand", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"collector_mail", "name": "Collector Mail", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"rune_charm", "name": "Thermal Exemption Rune", "slot": "charm", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png"},
			]
			var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
			var roll := rng.randi_range(1, 100)
			var rarity := "Common" if roll <= 48 else ("Uncommon" if roll <= 78 else ("Rare" if roll <= 94 else "Epic"))
			var colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Permafrost", "stat": "magic", "value": rng.randi_range(4, 10)},
				{"name": "of the Collector", "stat": "defense", "value": rng.randi_range(4, 10)},
				{"name": "of Thawing", "stat": "speed", "value": rng.randi_range(3, 9)},
				{"name": "of Royal Repeal", "stat": "spirit", "value": rng.randi_range(4, 10)},
			]
			pool.shuffle()
			var modifiers: Array[Dictionary] = [pool[0]]
			if rarity in ["Rare", "Epic"]:
				modifiers.append(pool[1])
			results.append({"instance_id": "frosthold-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()], "id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]], "slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": colors[rarity], "modifiers": modifiers, "kind": "gear", "source_pack": "Frozen Kingdom – Top-Down Pixel Art Asset Pack"})
		if encounter_id == &"frosthold_gate_intro" or rng.randf() <= 0.6:
			results.append({"id": &"ether", "display_name": "Leyden Ether", "quantity": 1, "kind": "consumable", "source_pack": "Frozen Kingdom – Top-Down Pixel Art Asset Pack"})
		return results
	if encounter_id == &"helios_civic_sun":
		results.append({
			"instance_id": "helios-midnight-capacitor", "id": &"midnight_capacitor", "base_name": "Midnight Capacitor",
			"display_name": "Epic Midnight Capacitor of Unscheduled Darkness", "slot": "accessory",
			"icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Unscheduled Darkness", "stat": "speed", "value": 10}, {"name": "of Phase Inversion", "stat": "magic", "value": 9}],
			"granted_action": &"viper_uppercut", "kind": "gear", "source_pack": "Bright Cyberpunk Pixel Art Tileset Pack",
		})
		results.append({"id": &"helios_anchor_core", "display_name": "Helios Midnight Anchor", "quantity": 1, "kind": "consumable", "source_pack": "Bright Cyberpunk Pixel Art Tileset Pack"})
		return results
	if String(encounter_id).begins_with("helios_"):
		if encounter_id == &"helios_skybridge_intro" or rng.randf() <= 0.62:
			var bases := [
				{"id": &"pulse_sidearm", "name": "Pulse Sidearm", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"arcology_jacket", "name": "Arcology Jacket", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"curfew_visor", "name": "Curfew Visor", "slot": "head", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon9.png"},
			]
			var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
			var roll := rng.randi_range(1, 100)
			var rarity := "Common" if roll <= 50 else ("Uncommon" if roll <= 80 else ("Rare" if roll <= 95 else "Epic"))
			var colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Midnight", "stat": "speed", "value": rng.randi_range(3, 8)},
				{"name": "of Overcharge", "stat": "attack", "value": rng.randi_range(4, 9)},
				{"name": "of Neon", "stat": "magic", "value": rng.randi_range(4, 9)},
				{"name": "of Insulation", "stat": "defense", "value": rng.randi_range(4, 9)},
			]
			pool.shuffle()
			var modifiers: Array[Dictionary] = [pool[0]]
			if rarity in ["Rare", "Epic"]:
				modifiers.append(pool[1])
			results.append({"instance_id": "helios-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()], "id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]], "slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": colors[rarity], "modifiers": modifiers, "kind": "gear", "source_pack": "Bright Cyberpunk Pixel Art Tileset Pack"})
		if encounter_id == &"helios_skybridge_intro" or rng.randf() <= 0.58:
			results.append({"id": &"ether", "display_name": "Leyden Ether", "quantity": 1, "kind": "consumable", "source_pack": "Bright Cyberpunk Pixel Art Tileset Pack"})
		return results
	if encounter_id == &"primeval_commute_tyrant":
		results.append({
			"instance_id": "primeval-mammoth-club", "id": &"meteor_mammoth_club", "base_name": "Meteor-Tempered Mammoth Club",
			"display_name": "Epic Meteor-Tempered Mammoth Club of Right-of-Way", "slot": "weapon",
			"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Right-of-Way", "stat": "attack", "value": 11}, {"name": "of Bedrock", "stat": "defense", "value": 7}],
			"granted_action": &"mammoth_slam", "kind": "gear", "source_pack": "Jurassic World Pixel Art Megapack",
		})
		results.append({"id": &"primeval_anchor_core", "display_name": "Fossilized Anchor Core", "quantity": 1, "kind": "consumable", "source_pack": "Jurassic World Pixel Art Megapack"})
		return results
	if String(encounter_id).begins_with("primeval_"):
		if encounter_id == &"primeval_grove_intro" or rng.randf() <= 0.6:
			var bases := [
				{"id": &"bone_club", "name": "Bone Club", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"hide_vest", "name": "Thick Hide Vest", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"fossil_charm", "name": "Impossible Fossil", "slot": "charm", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png"},
			]
			var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
			var rarity_roll := rng.randi_range(1, 100)
			var rarity := "Common" if rarity_roll <= 52 else ("Uncommon" if rarity_roll <= 82 else ("Rare" if rarity_roll <= 96 else "Epic"))
			var rarity_colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Bedrock", "stat": "defense", "value": rng.randi_range(3, 8)},
				{"name": "of the Hunt", "stat": "attack", "value": rng.randi_range(3, 8)},
				{"name": "of Stampeding", "stat": "max_hp", "value": rng.randi_range(12, 28)},
				{"name": "of Quick Claws", "stat": "speed", "value": rng.randi_range(2, 7)},
			]
			pool.shuffle()
			var modifier_count := 2 if rarity in ["Rare", "Epic"] else 1
			var modifiers: Array[Dictionary] = []
			for i in range(modifier_count):
				modifiers.append(pool[i])
			results.append({
				"instance_id": "primeval-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()],
				"id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]],
				"slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": rarity_colors[rarity],
				"modifiers": modifiers, "kind": "gear", "source_pack": "Jurassic World Pixel Art Megapack",
			})
		if encounter_id == &"primeval_grove_intro" or rng.randf() <= 0.55:
			results.append({"id": &"tonic", "display_name": "Tonic", "quantity": 1, "kind": "consumable", "source_pack": "Stone Age Modern Life Pixel Art Tileset Pack"})
		return results
	if encounter_id == &"asterion_mother_computer":
		results.append({
			"instance_id": "asterion-ion-pistol", "id": &"ion_pistol", "base_name": "Asterion Ion Pistol",
			"display_name": "Epic Asterion Ion Pistol of Unscheduled Leave", "slot": "weapon",
			"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Unscheduled Leave", "stat": "attack", "value": 9}, {"name": "of Celerity", "stat": "speed", "value": 6}],
			"granted_action": &"ion_round", "kind": "gear", "source_pack": "Sci-Fi Spaceship Interior Tileset Pack",
		})
		results.append({"id": &"anchor_lattice", "display_name": "Asterion Anchor Lattice", "quantity": 1, "kind": "consumable", "source_pack": "Sci-Fi Spaceship Interior Tileset Pack"})
		return results
	if String(encounter_id).begins_with("asterion_"):
		if encounter_id == &"asterion_dock_intro" or rng.randf() <= 0.58:
			var station_bases := [
				{"id": &"ceramic_sidearm", "name": "Ceramic Sidearm", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
				{"id": &"vacuum_harness", "name": "Vacuum Harness", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
				{"id": &"navigation_lens", "name": "Navigation Lens", "slot": "head", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon9.png"},
				{"id": &"pressure_gloves", "name": "Pressure Gloves", "slot": "hands", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon31.png"},
				{"id": &"signal_charm", "name": "Signal Charm", "slot": "charm", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png"},
			]
			var base: Dictionary = station_bases[rng.randi_range(0, station_bases.size() - 1)]
			var rarity_roll := rng.randi_range(1, 100)
			var rarity := "Common" if rarity_roll <= 55 else ("Uncommon" if rarity_roll <= 84 else ("Rare" if rarity_roll <= 97 else "Epic"))
			var rarity_colors := {"Common": "#d8d3c5", "Uncommon": "#62d67b", "Rare": "#58a6ff", "Epic": "#bd77ff"}
			var pool := [
				{"name": "of Thrust", "stat": "attack", "value": rng.randi_range(3, 7)},
				{"name": "of Vacuum", "stat": "defense", "value": rng.randi_range(3, 7)},
				{"name": "of Orbit", "stat": "speed", "value": rng.randi_range(2, 6)},
				{"name": "of Ionization", "stat": "magic", "value": rng.randi_range(3, 7)},
				{"name": "of Pressure", "stat": "max_hp", "value": rng.randi_range(10, 22)},
			]
			pool.shuffle()
			var modifier_count := 2 if rarity in ["Rare", "Epic"] else 1
			var modifiers: Array[Dictionary] = []
			for i in range(modifier_count):
				modifiers.append(pool[i])
			results.append({
				"instance_id": "asterion-%d-%d" % [Time.get_unix_time_from_system(), rng.randi()],
				"id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]],
				"slot": base["slot"], "icon": base["icon"], "rarity": rarity, "rarity_color": rarity_colors[rarity],
				"modifiers": modifiers, "kind": "gear", "source_pack": "Sci-Fi Spaceship Interior Tileset Pack",
			})
		if encounter_id == &"asterion_dock_intro" or rng.randf() <= 0.62:
			var supply: Dictionary = [{"id": &"tonic", "name": "Tonic"}, {"id": &"ether", "name": "Leyden Ether"}, {"id": &"smelling_salts", "name": "Smelling Salts"}][rng.randi_range(0, 2)]
			results.append({"id": supply["id"], "display_name": supply["name"], "quantity": 1, "kind": "consumable", "source_pack": "Sci-Fi Spaceship Interior Tileset Pack"})
		return results
	if encounter_id == &"mansion_archive_boss":
		results.append({
			"instance_id": "mansion-chronometer",
			"id": &"anchored_chronometer", "base_name": "Anchored Chronometer",
			"display_name": "Epic Anchored Chronometer of Borrowed Time",
			"slot": "accessory", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png",
			"rarity": "Epic", "rarity_color": "#bd77ff",
			"modifiers": [{"name": "of Borrowed Time", "stat": "speed", "value": 7}, {"name": "of Continuity", "stat": "spirit", "value": 6}],
			"granted_action": &"borrowed_second",
			"kind": "gear", "source_pack": "resources_items_artifacts_loot",
		})
		results.append({"id": &"anchor_core", "display_name": "Multiversal Anchor Core", "quantity": 1, "kind": "consumable", "source_pack": "Haunted Mansion Pixel Art Tileset Pack"})
		return results
	if encounter_id == &"mansion_foyer_intro" or rng.randf() <= 0.55:
		var rarities := [
			{"name": "Common", "color": "#d8d3c5", "weight": 58},
			{"name": "Uncommon", "color": "#62d67b", "weight": 28},
			{"name": "Rare", "color": "#58a6ff", "weight": 11},
			{"name": "Epic", "color": "#bd77ff", "weight": 3},
		]
		var roll := rng.randi_range(1, 100)
		var running := 0
		var rarity: Dictionary = rarities[0]
		for candidate in rarities:
			running += int(candidate["weight"])
			if roll <= running:
				rarity = candidate
				break
		var bases := [
			{"id": &"iron_saber", "name": "Iron Saber", "slot": "weapon", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"},
			{"id": &"mourning_cap", "name": "Mourning Cap", "slot": "head", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon9.png"},
			{"id": &"dusty_waistcoat", "name": "Dusty Waistcoat", "slot": "body", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png"},
			{"id": &"silver_locket", "name": "Silver Locket", "slot": "accessory", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png"},
			{"id": &"moth_eaten_gloves", "name": "Moth-Eaten Gloves", "slot": "hands", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon31.png"},
			{"id": &"house_key_fragment", "name": "House-Key Fragment", "slot": "charm", "icon": "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png"},
		]
		var base: Dictionary = bases[rng.randi_range(0, bases.size() - 1)]
		var modifier_count := 1 if rarity["name"] in ["Common", "Uncommon"] else 2
		var pool := [
			{"name": "of Force", "stat": "attack", "value": rng.randi_range(2, 6)},
			{"name": "of Celerity", "stat": "speed", "value": rng.randi_range(2, 5)},
			{"name": "of Resolve", "stat": "defense", "value": rng.randi_range(2, 6)},
			{"name": "of Sparks", "stat": "magic", "value": rng.randi_range(2, 6)},
			{"name": "of Vigor", "stat": "max_hp", "value": rng.randi_range(8, 18)},
		]
		pool.shuffle()
		var modifiers: Array[Dictionary] = []
		for i in range(modifier_count):
			modifiers.append(pool[i])
		results.append({
			"instance_id": "%s-%d" % [Time.get_unix_time_from_system(), rng.randi()],
			"id": base["id"], "base_name": base["name"], "display_name": "%s %s" % [base["name"], modifiers[0]["name"]],
			"slot": base["slot"], "icon": base["icon"], "rarity": rarity["name"], "rarity_color": rarity["color"],
			"modifiers": modifiers, "kind": "gear", "source_pack": "resources_items_artifacts_loot",
		})
	if encounter_id == &"mansion_foyer_intro":
		results.append({"id": &"smelling_salts", "display_name": "Smelling Salts", "quantity": 1, "kind": "consumable", "source_pack": "resources_items_artifacts_loot"})
	elif rng.randf() <= 0.65:
		var consumables := [
			{"id": &"tonic", "display_name": "Tonic"},
			{"id": &"ether", "display_name": "Leyden Ether"},
			{"id": &"smelling_salts", "display_name": "Smelling Salts"},
			{"id": &"phoenix_tonic", "display_name": "Phoenix Tonic"},
		]
		var supply: Dictionary = consumables[rng.randi_range(0, consumables.size() - 1)]
		results.append({"id": supply["id"], "display_name": supply["display_name"], "quantity": 1, "kind": "consumable", "source_pack": "resources_items_artifacts_loot"})
	return results


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var seen := {}
	for encounter_id in FIXED_REWARD_ENCOUNTERS:
		if encounter_id in seen:
			errors.append("%s is declared more than once." % encounter_id)
			continue
		seen[encounter_id] = true
		var rng := RandomNumberGenerator.new()
		rng.seed = 20260723
		var drops := roll_loot(encounter_id, rng)
		if drops.is_empty():
			errors.append("%s must produce its fixed reward." % encounter_id)
			continue
		for drop in drops:
			if StringName(drop.get("id", &"")) == &"" or String(drop.get("kind", "")).is_empty():
				errors.append("%s produced an invalid reward record." % encounter_id)
	return PackedStringArray(errors)
