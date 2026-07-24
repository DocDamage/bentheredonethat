extends Node

signal state_changed
signal facility_built(plot_index: int, facility_name: String)
signal recruit_status_changed(recruit_id: StringName, status: StringName)
signal facility_job_ready(facility_name: String, job_id: StringName)
signal quest_advanced(quest_id: StringName, step_index: int)
signal quest_completed(quest_id: StringName)
signal party_changed
signal town_objects_changed
signal town_terrain_changed
signal universe_anchored(plot_index: int, universe_id: StringName)
signal encounter_pressure_changed(data: Dictionary)

const SAVE_VERSION := 21
const DEFAULT_SAVE_PATH := "user://save_slot_1.json"
const SANDBOX_SAVE_PATH := "user://sandbox_slot.json"
const SAVE_REPOSITORY := preload("res://ben_rpg/core/save_repository.gd")
const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")
const QUEST_DIRECTOR := preload("res://ben_rpg/core/quest_director.gd")
const ECONOMY_LEDGER := preload("res://ben_rpg/core/economy_ledger.gd")
const WORLD_CATALOG := preload("res://ben_rpg/core/campaign_world_catalog.gd")
const SANDBOX_OBJECT_CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")
const SANDBOX_TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
const SANDBOX_LAYOUT_SLOT_VERSION := 1
const SANDBOX_LAYOUT_SLOT_COUNT := 3
const SANDBOX_LAYOUT_SLOT_PATH := "user://sandbox_layout_slot_%d.json"
const SANDBOX_TOWN_INTERIOR := Rect2i(Vector2i(37, 1), Vector2i(30, 26))
const SANDBOX_AUTHORED_OBJECTS := [
	{"instance_id": "sandbox_town_lab", "catalog_id": &"modern_warehouse", "cell": Vector2i(48, 5), "role": &"town_lab", "protected": true},
	{"instance_id": "sandbox_tree_northwest", "catalog_id": &"ranch_sapling", "cell": Vector2i(37, 1), "role": &"town_tree"},
	{"instance_id": "sandbox_tree_northeast", "catalog_id": &"ranch_oak", "cell": Vector2i(62, 1), "role": &"town_tree", "flipped": true},
	{"instance_id": "sandbox_tree_southwest", "catalog_id": &"ranch_oak", "cell": Vector2i(37, 17), "role": &"town_tree", "flipped": true},
	{"instance_id": "sandbox_tree_southeast", "catalog_id": &"ranch_sapling", "cell": Vector2i(63, 17), "role": &"town_tree"},
]
const PARTY_LIMIT := 5
const CORE_PROTAGONIST_IDS := [&"ben", &"lincoln", &"gandhi"]
const FORMATION_ROW_LIMIT := 3
const FORMATION_ROWS := [&"front", &"back"]
const SCENARIO_PARTY_REQUIREMENTS := {&"haunted_mansion": [&"fighter"]}
const RESERVE_EXPERIENCE_RATIO := 0.78
const MAX_HIRED_LEVEL_GAP := 2
const NEW_HIRE_LEVEL_GAP := 1
const FIELD_SPECIALIST_TASKS := {
	&"asterion_cargo_override": {
		"preferred_recruits": [&"astronaut"], "preferred_skills": [&"Navigation"],
		"duckets": 24, "items": {&"ether": 1, &"research_notes": 1},
		"label": "Asterion customs override",
	},
	&"primeval_relay_survey": {
		"preferred_recruits": [&"caveman", &"mossback_surveyor", &"astronaut"],
		"preferred_skills": [&"Farming", &"Navigation", &"Athletics"],
		"duckets": 0, "items": {&"provisions": 2, &"research_notes": 1},
		"label": "Primeval relay survey",
	},
	&"helios_transit_override": {
		"preferred_recruits": [&"neon_viper", &"cobalt_courier", &"astronaut", &"rift_jackal"],
		"preferred_skills": [&"Engineering", &"Security"],
		"duckets": 18, "items": {&"ether": 2},
		"label": "Helios transit override",
	},
	&"frosthold_thermal_counsel": {
		"preferred_recruits": [&"frost_lich_emperor", &"neon_viper"],
		"preferred_skills": [&"Occult", &"Engineering"],
		"duckets": 0, "items": {&"anchor_dust": 1, &"tonic": 1},
		"label": "Frosthold thermal counsel",
	},
	&"moonpetal_memory_audit": {
		"preferred_recruits": [&"kitsune_empress", &"frost_lich_emperor"],
		"preferred_skills": [&"Occult", &"Diplomacy"],
		"duckets": 0, "items": {&"research_notes": 1, &"anchor_dust": 1},
		"label": "Moonpetal memory audit",
	},
	&"empyreal_weight_appeal": {
		"preferred_recruits": [&"archangel_commander", &"kitsune_empress"],
		"preferred_skills": [&"Diplomacy", &"Security"],
		"duckets": 48, "items": {&"phoenix_tonic": 1},
		"label": "Empyreal weight appeal",
	},
}
const UNIVERSE_DEFINITIONS := WORLD_CATALOG.UNIVERSE_DEFINITIONS
const TOWN_STATE_OVERLAYS := WORLD_CATALOG.TOWN_STATE_OVERLAYS
# Every scenario anchor uses this single source of truth for saving, recovery,
# retry metadata, and roster access. Cells are absolute gameboard cells so a
# future room rearrangement cannot silently leave the menu checking an old prop.
const UNIVERSE_SAVE_POINTS := WORLD_CATALOG.UNIVERSE_SAVE_POINTS

# Active authored rooms may place a compatibility save-point ID at a streamed
# coordinate. This is session-owned placement data, not save content: the
# stable ID and its activation flag remain the serialized contract.
var _runtime_save_point_cells: Dictionary = {}
const UNIVERSE_TREASURE_CACHES := WORLD_CATALOG.UNIVERSE_TREASURE_CACHES
const EQUIPMENT_SLOTS := WORLD_CATALOG.EQUIPMENT_SLOTS
const EQUIPMENT_AFFINITIES := WORLD_CATALOG.EQUIPMENT_AFFINITIES
const JOB_QUALITY_NAMES := WORLD_CATALOG.JOB_QUALITY_NAMES
const SERVICE_ITEM_CATALOG := WORLD_CATALOG.SERVICE_ITEM_CATALOG
const SERVICE_STOCK := WORLD_CATALOG.SERVICE_STOCK
const ARMORY_REFORGE_BASE_DUCKET_COST := WORLD_CATALOG.ARMORY_REFORGE_BASE_DUCKET_COST
const ARMORY_REFORGE_ANCHOR_DUST_COST := WORLD_CATALOG.ARMORY_REFORGE_ANCHOR_DUST_COST
const ARMORY_STOCK := WORLD_CATALOG.ARMORY_STOCK
const FACILITY_DEFINITIONS := WORLD_CATALOG.FACILITY_DEFINITIONS
const INVENTION_DEFINITIONS := WORLD_CATALOG.INVENTION_DEFINITIONS
const EXPEDITION_TOOL_CONTRACTS := WORLD_CATALOG.EXPEDITION_TOOL_CONTRACTS
const FACILITY_UPGRADE_DEFINITIONS := WORLD_CATALOG.FACILITY_UPGRADE_DEFINITIONS
const SKILL_TREES := WORLD_CATALOG.SKILL_TREES
const QUEST_DEFINITIONS := WORLD_CATALOG.QUEST_DEFINITIONS
const REQUIRED_NAMED_CHARACTER_ARCS := WORLD_CATALOG.REQUIRED_NAMED_CHARACTER_ARCS
var sandbox_mode := false
var play_time_seconds := 0.0
var save_timestamp := 0
var last_save_cell := Vector2i(10, 9)
var last_location := "Laboratory"
var last_manifest_room_id: StringName = &""
var town_time_minutes := 7.0 * 60.0
var resident_states: Dictionary = {}
var town_terrain: Dictionary = {}
var town_objects: Array[Dictionary] = []
var next_town_object_id := 1
var duckets := 0
var built_facilities: Dictionary = {}
var universe_anchors: Dictionary = {}
var story_flags: Dictionary = {}
var bestiary_records: Dictionary = {}
var inventory: Dictionary = {&"tonic": 3, &"ether": 1, &"smelling_salts": 2, &"phoenix_tonic": 1}
var encounter_ward_steps := 0
var encounter_pressure: Dictionary = {"active": false, "universe_id": &"", "steps": 0, "threshold": 1, "ward_steps": 0, "suppressed": false, "cooldown": 0}
var loot_inventory: Array[Dictionary] = []
var character_progress: Dictionary = {}
var party: Array[StringName] = [&"ben"]
var party_formation: Dictionary = {&"ben": &"back"}
var recruit_status: Dictionary = {
	&"ben": &"party", &"fighter": &"undiscovered", &"astronaut": &"undiscovered",
	&"caveman": &"undiscovered", &"crimson_oni": &"undiscovered", &"rift_jackal": &"undiscovered", &"mossback_surveyor": &"undiscovered", &"cobalt_courier": &"undiscovered", &"bulkhead_warden": &"undiscovered", &"kitsune_empress": &"undiscovered",
	&"neon_viper": &"undiscovered", &"archangel_commander": &"undiscovered", &"frost_lich_emperor": &"undiscovered",
}
var facility_assignments: Dictionary = {}
var active_facility_jobs: Dictionary = {}
var completed_facility_jobs: Dictionary = {}
var owned_inventions: Array[StringName] = []
var facility_upgrades: Dictionary = {}
var expedition_meal_charges := 0
var equipment_loadouts: Dictionary = {}
var economy_transactions: Array[Dictionary] = []
var encounter_director_states: Dictionary = {}
var quest_states: Dictionary = {}
var quest_events: Dictionary = {}
var tracked_quest: StringName = &""
var _job_clock_accumulator := 0.0
var _syncing_quests := false
var _play_session_running := false

var recruit_catalog: Dictionary = {
	&"ben": {
		"name": "Benjamin Franklin",
		"battle_profile": &"ben_battle_actor", "portrait_profile": &"ben_company_portrait",
		"specialty": "Inventor and support",
		"adjacent_skills": ["Diplomacy", "Research", "Logistics"],
		"work_specialties": [&"Invention", &"Research"],
		"work_adjacent": [&"Diplomacy", &"Logistics", &"Medicine"],
		"asset_pack": "Main Character/Ben_Franklin",
	},
	&"lincoln": {
		"name": "Abraham Lincoln",
		"battle_profile": &"lincoln_battle_actor", "portrait_profile": &"lincoln_company_portrait",
		"specialty": "Protection, resolve, and civic leadership",
		"adjacent_skills": ["Security", "Diplomacy", "Logistics"],
		"work_specialties": [&"Security", &"Diplomacy"],
		"work_adjacent": [&"Logistics", &"Research", &"Athletics"],
		"asset_pack": "Recruitable Characters/Abe_Lincoln",
		"field_animation_scene": "res://ben_rpg/characters/abe_lincoln_field_animation.tscn",
		"combat_actions": [&"rally", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 205, "max_mp": 24, "attack": 27, "defense": 32, "magic": 15, "spirit": 26, "speed": 27, "hp_growth": 23, "mp_growth": 3, "attack_growth": 3, "defense_growth": 4, "magic_growth": 2, "spirit_growth": 3, "speed_growth": 1},
	},
	&"gandhi": {
		"name": "Mahatma Gandhi",
		"battle_profile": &"gandhi_battle_actor", "portrait_profile": &"gandhi_company_portrait",
		"specialty": "Recovery, de-escalation, and nonlethal control",
		"adjacent_skills": ["Medicine", "Diplomacy", "Research"],
		"work_specialties": [&"Medicine", &"Diplomacy"],
		"work_adjacent": [&"Research", &"Logistics", &"Occult"],
		"asset_pack": "Recruitable Characters/Gandhi_Sprite",
		"field_animation_scene": "res://ben_rpg/characters/gandhi_field_animation.tscn",
		"combat_actions": [&"field_triage", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 164, "max_mp": 52, "attack": 14, "defense": 20, "magic": 31, "spirit": 35, "speed": 31, "hp_growth": 16, "mp_growth": 6, "attack_growth": 2, "defense_growth": 2, "magic_growth": 4, "spirit_growth": 4, "speed_growth": 2},
	},
	&"fighter": {
		"name": "Fighter",
		"battle_profile": &"fighter_battle_actor", "portrait_profile": &"fighter_company_portrait",
		"specialty": "Martial combat",
		"adjacent_skills": ["Security", "Athletics"],
		"work_specialties": [&"Combat", &"Security"],
		"work_adjacent": [&"Athletics", &"Logistics"],
		"asset_pack": "Recruitable Characters/Fighter/Fighter",
		"field_animation_scene": "res://ben_rpg/characters/fighter_field_animation.tscn",
	},
	&"astronaut": {
		"name": "Astronaut",
		"battle_profile": &"astronaut_battle_actor", "portrait_profile": &"astronaut_company_portrait",
		"specialty": "Ranged combat and navigation",
		"adjacent_skills": ["Security", "Engineering"],
		"work_specialties": [&"Navigation", &"Combat"],
		"work_adjacent": [&"Security", &"Engineering", &"Research"],
		"asset_pack": "Recruitable Characters/astronaut/Astronaut",
		"field_animation_scene": "res://ben_rpg/characters/astronaut_field_animation.tscn",
	},
	&"caveman": {
		"name": "Caveman", "specialty": "Survival and brute force",
		"battle_profile": &"caveman_battle_actor", "portrait_profile": &"caveman_battle_actor",
		"adjacent_skills": ["Athletics", "Farming", "Logistics"],
		"work_specialties": [&"Athletics", &"Farming"], "work_adjacent": [&"Security", &"Logistics"],
		"asset_pack": "Recruitable Characters/caveman/Caveman", "field_animation_scene": "res://ben_rpg/characters/caveman_field_animation.tscn", "portrait_region": Rect2(20, 21, 49, 50),
		"combat_actions": [&"club_smash", &"pummel", &"defend", &"tonic", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 220, "max_mp": 10, "attack": 35, "defense": 27, "magic": 6, "spirit": 12, "speed": 24, "hp_growth": 25, "mp_growth": 1, "attack_growth": 4, "defense_growth": 3, "magic_growth": 1, "spirit_growth": 1, "speed_growth": 1},
		"recruitment_flag": &"caveman_recruit_unlocked",
	},
	&"crimson_oni": {
		"name": "Crimson Oni", "specialty": "Dueling and security",
		"battle_profile": &"crimson_oni_challenger_battle_actor", "portrait_profile": &"crimson_oni_challenger_battle_actor",
		"adjacent_skills": ["Athletics", "Occult"],
		"work_specialties": [&"Combat", &"Security"], "work_adjacent": [&"Athletics", &"Occult"],
		"asset_pack": "Recruitable Characters/crimson oni samurai", "field_animation_scene": "res://ben_rpg/characters/crimson_oni_field_animation.tscn", "portrait_region": Rect2(46, 43, 95, 101),
		"combat_actions": [&"oni_crescent", &"pummel", &"defend", &"tonic", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 195, "max_mp": 22, "attack": 34, "defense": 24, "magic": 13, "spirit": 16, "speed": 36, "hp_growth": 21, "mp_growth": 2, "attack_growth": 4, "defense_growth": 3, "magic_growth": 1, "spirit_growth": 2, "speed_growth": 2},
		"recruitment_flag": &"crimson_oni_recruit_unlocked",
	},
	&"rift_jackal": {
		"name": "Rift Jackal", "specialty": "Tracking and threshold security",
		"battle_profile": &"rift_jackal_battle_actor", "portrait_profile": &"rift_jackal_battle_actor",
		"adjacent_skills": ["Occult", "Navigation", "Athletics"],
		"work_specialties": [&"Security", &"Navigation"], "work_adjacent": [&"Occult", &"Athletics", &"Logistics"],
		"asset_pack": "Topdown Monsters Part 1", "field_animation_scene": "res://ben_rpg/characters/rift_jackal_field_animation.tscn", "portrait_path": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Rift Jackal/00_idle/frame_000.png",
		"battle_animation_root": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Rift Jackal",
		"battle_animation_fps": 8.0,
		"battle_animation_sequences": {
			&"idle": {"folder": "00_idle", "frames": 6}, &"attack": {"folder": "05_attack", "frames": 6},
			&"hit": {"folder": "06_hit", "frames": 6}, &"power": {"folder": "07_blast_attack_1", "frames": 6},
			&"victory": {"folder": "02_victory", "frames": 8}, &"death": {"folder": "12_death_1", "frames": 8},
		},
		"battle_action_sequences": {&"rift_bite": &"attack", &"phase_scratch": &"power", &"faultline_pounce": &"attack", &"anchor_howl": &"power"},
		"combat_actions": [&"rift_bite", &"phase_scratch", &"defend", &"tonic", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 185, "max_mp": 20, "attack": 32, "defense": 23, "magic": 18, "spirit": 19, "speed": 42, "hp_growth": 20, "mp_growth": 2, "attack_growth": 4, "defense_growth": 3, "magic_growth": 2, "spirit_growth": 2, "speed_growth": 3},
		"recruitment_flag": &"rift_jackal_recruit_unlocked",
	},
	&"mossback_surveyor": {
		"name": "Mossback Surveyor", "specialty": "Cultivation and supply logistics",
		"battle_profile": &"mossback_surveyor_battle_actor", "portrait_profile": &"mossback_surveyor_battle_actor",
		"adjacent_skills": ["Medicine", "Research", "Athletics"],
		"work_specialties": [&"Farming", &"Logistics"], "work_adjacent": [&"Medicine", &"Research", &"Athletics"],
		"asset_pack": "Topdown Monsters Part 1", "field_animation_scene": "res://ben_rpg/characters/mossback_surveyor_field_animation.tscn", "portrait_path": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Mossback Surveyor/00_idle/frame_000.png",
		"battle_animation_root": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Mossback Surveyor",
		"battle_animation_fps": 8.0,
		"battle_animation_sequences": {
			&"idle": {"folder": "00_idle", "frames": 6}, &"attack": {"folder": "05_attack", "frames": 6},
			&"hit": {"folder": "06_hit", "frames": 6}, &"power": {"folder": "08_blast_attack_2", "frames": 6},
			&"victory": {"folder": "02_victory", "frames": 8}, &"death": {"folder": "12_death_1", "frames": 8},
		},
		"battle_action_sequences": {&"mossback_pummel": &"attack", &"spore_receipt": &"power", &"rooted_red_tape": &"power", &"hearty_provisions": &"victory"},
		"combat_actions": [&"mossback_pummel", &"spore_receipt", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 210, "max_mp": 32, "attack": 29, "defense": 31, "magic": 22, "spirit": 28, "speed": 21, "hp_growth": 24, "mp_growth": 4, "attack_growth": 3, "defense_growth": 4, "magic_growth": 2, "spirit_growth": 3, "speed_growth": 1},
		"recruitment_flag": &"mossback_surveyor_recruit_unlocked",
	},
	&"cobalt_courier": {
		"name": "Cobalt Courier", "specialty": "Navigation and rift logistics",
		"battle_profile": &"cobalt_courier_battle_actor", "portrait_profile": &"cobalt_courier_battle_actor",
		"adjacent_skills": ["Engineering", "Security", "Diplomacy"],
		"work_specialties": [&"Navigation", &"Logistics"], "work_adjacent": [&"Engineering", &"Security", &"Diplomacy"],
		"asset_pack": "Topdown Monsters Part 1", "field_animation_scene": "res://ben_rpg/characters/cobalt_courier_field_animation.tscn", "portrait_path": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Cobalt Courier/00_idle/frame_000.png",
		"battle_animation_root": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Cobalt Courier",
		"battle_animation_fps": 8.0,
		"battle_animation_sequences": {
			&"idle": {"folder": "00_idle", "frames": 6}, &"attack": {"folder": "05_attack", "frames": 6},
			&"hit": {"folder": "06_hit", "frames": 6}, &"power": {"folder": "08_blast_attack_2", "frames": 6},
			&"victory": {"folder": "02_victory", "frames": 8}, &"death": {"folder": "12_death_1", "frames": 8},
		},
		"battle_action_sequences": {&"cobalt_claw": &"attack", &"express_jolt": &"power", &"priority_delivery": &"attack", &"emergency_dispatch": &"victory"},
		"combat_actions": [&"cobalt_claw", &"express_jolt", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 178, "max_mp": 34, "attack": 27, "defense": 22, "magic": 29, "spirit": 23, "speed": 46, "hp_growth": 18, "mp_growth": 4, "attack_growth": 3, "defense_growth": 2, "magic_growth": 4, "spirit_growth": 3, "speed_growth": 3},
		"recruitment_flag": &"cobalt_courier_recruit_unlocked",
	},
	&"bulkhead_warden": {
		"name": "Bulkhead Warden", "specialty": "Structural engineering and security",
		"battle_profile": &"bulkhead_warden_battle_actor", "portrait_profile": &"bulkhead_warden_battle_actor",
		"adjacent_skills": ["Logistics", "Research", "Athletics"],
		"work_specialties": [&"Engineering", &"Security"], "work_adjacent": [&"Logistics", &"Research", &"Athletics"],
		"asset_pack": "Topdown Monsters Part 1", "field_animation_scene": "res://ben_rpg/characters/bulkhead_warden_field_animation.tscn", "portrait_path": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Bulkhead Warden/00_idle/frame_000.png",
		"battle_animation_root": "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Bulkhead Warden",
		"battle_animation_fps": 8.0,
		"battle_animation_sequences": {
			&"idle": {"folder": "00_idle", "frames": 6}, &"attack": {"folder": "05_attack", "frames": 6},
			&"hit": {"folder": "06_hit", "frames": 6}, &"power": {"folder": "08_blast_attack_2", "frames": 6},
			&"victory": {"folder": "02_victory", "frames": 8}, &"death": {"folder": "12_death_1", "frames": 8},
		},
		"battle_action_sequences": {&"warden_pummel": &"attack", &"piston_surge": &"power", &"bulkhead_drop": &"power", &"pressure_lock": &"attack"},
		"combat_actions": [&"warden_pummel", &"piston_surge", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 235, "max_mp": 22, "attack": 34, "defense": 38, "magic": 14, "spirit": 25, "speed": 20, "hp_growth": 27, "mp_growth": 2, "attack_growth": 4, "defense_growth": 5, "magic_growth": 1, "spirit_growth": 3, "speed_growth": 1},
		"recruitment_flag": &"bulkhead_warden_recruit_unlocked",
	},
	&"kitsune_empress": {
		"name": "Kitsune Empress", "specialty": "Illusion and diplomacy",
		"battle_profile": &"kitsune_empress_battle_actor", "portrait_profile": &"kitsune_empress_battle_actor",
		"adjacent_skills": ["Occult", "Research"],
		"work_specialties": [&"Diplomacy", &"Occult"], "work_adjacent": [&"Research", &"Medicine"],
		"asset_pack": "Recruitable Characters/kitsune empress", "field_animation_scene": "res://ben_rpg/characters/kitsune_field_animation.tscn", "portrait_region": Rect2(34, 36, 85, 84),
		"combat_actions": [&"foxfire", &"field_triage", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 150, "max_mp": 46, "attack": 15, "defense": 18, "magic": 34, "spirit": 28, "speed": 38, "hp_growth": 15, "mp_growth": 6, "attack_growth": 1, "defense_growth": 2, "magic_growth": 4, "spirit_growth": 3, "speed_growth": 2},
		"recruitment_flag": &"kitsune_empress_recruit_unlocked",
	},
	&"neon_viper": {
		"name": "Neon Viper", "specialty": "Infiltration and engineering",
		"battle_profile": &"neon_viper_battle_actor", "portrait_profile": &"neon_viper_battle_actor",
		"adjacent_skills": ["Security", "Navigation"],
		"work_specialties": [&"Engineering", &"Security"], "work_adjacent": [&"Navigation", &"Logistics"],
		"asset_pack": "Recruitable Characters/neon viper - cyberpunk female", "field_animation_scene": "res://ben_rpg/characters/neon_viper_field_animation.tscn", "portrait_region": Rect2(44, 28, 39, 72),
		"combat_actions": [&"viper_rush", &"pulse_shot", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 165, "max_mp": 28, "attack": 28, "defense": 21, "magic": 19, "spirit": 18, "speed": 44, "hp_growth": 17, "mp_growth": 3, "attack_growth": 3, "defense_growth": 2, "magic_growth": 2, "spirit_growth": 2, "speed_growth": 3},
		"recruitment_flag": &"neon_viper_recruit_unlocked",
	},
	&"archangel_commander": {
		"name": "Archangel Commander", "specialty": "Protection and medicine",
		"battle_profile": &"archangel_commander_battle_actor", "portrait_profile": &"archangel_commander_battle_actor",
		"adjacent_skills": ["Diplomacy", "Occult"],
		"work_specialties": [&"Medicine", &"Security"], "work_adjacent": [&"Diplomacy", &"Occult"],
		"asset_pack": "Recruitable Characters/Archangel Commander — Legendary Celestial Warrior Hero", "field_animation_scene": "res://ben_rpg/characters/archangel_field_animation.tscn", "portrait_region": Rect2(28, 30, 70, 68),
		"combat_actions": [&"seraph_strike", &"field_triage", &"rally", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 205, "max_mp": 40, "attack": 29, "defense": 31, "magic": 26, "spirit": 34, "speed": 29, "hp_growth": 22, "mp_growth": 5, "attack_growth": 3, "defense_growth": 4, "magic_growth": 3, "spirit_growth": 4, "speed_growth": 1},
		"recruitment_flag": &"archangel_commander_recruit_unlocked",
	},
	&"frost_lich_emperor": {
		"name": "Frost Lich Emperor", "specialty": "Cold sorcery and occult research",
		"battle_profile": &"frost_lich_emperor_battle_actor", "portrait_profile": &"frost_lich_emperor_battle_actor",
		"adjacent_skills": ["Research", "Invention"],
		"work_specialties": [&"Occult", &"Research"], "work_adjacent": [&"Invention", &"Diplomacy"],
		"asset_pack": "Recruitable Characters/💀 The Frost Lich King Emperor", "field_animation_scene": "res://ben_rpg/characters/frost_lich_field_animation.tscn", "portrait_region": Rect2(28, 28, 67, 68),
		"combat_actions": [&"frost_nova", &"borrowed_second", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"],
		"combat_stats": {"max_hp": 145, "max_mp": 58, "attack": 13, "defense": 20, "magic": 40, "spirit": 32, "speed": 26, "hp_growth": 14, "mp_growth": 7, "attack_growth": 1, "defense_growth": 2, "magic_growth": 5, "spirit_growth": 4, "speed_growth": 1},
		"recruitment_flag": &"frost_lich_recruit_unlocked",
	},
}


func _ready() -> void:
	_ensure_default_progress()
	_initialize_quest_states()
	if not state_changed.is_connected(_on_internal_state_changed):
		state_changed.connect(_on_internal_state_changed)
	refresh_facility_jobs()


func _process(delta: float) -> void:
	if _play_session_running:
		play_time_seconds += delta
		town_time_minutes = fmod(town_time_minutes + delta, 1440.0)
	_job_clock_accumulator += delta
	if _job_clock_accumulator >= 1.0:
		_job_clock_accumulator = 0.0
		refresh_facility_jobs()


func reset_new_game() -> void:
	sandbox_mode = false
	_runtime_save_point_cells.clear()
	play_time_seconds = 0.0
	save_timestamp = 0
	last_save_cell = Vector2i(10, 9)
	last_location = "Laboratory"
	last_manifest_room_id = &""
	town_time_minutes = 7.0 * 60.0
	resident_states.clear()
	town_terrain.clear()
	town_objects.clear()
	next_town_object_id = 1
	_play_session_running = false
	duckets = 0
	built_facilities.clear()
	universe_anchors.clear()
	story_flags.clear()
	bestiary_records.clear()
	inventory = {&"tonic": 3, &"ether": 1, &"smelling_salts": 2, &"phoenix_tonic": 1}
	encounter_ward_steps = 0
	encounter_pressure = {"active": false, "universe_id": &"", "steps": 0, "threshold": 1, "ward_steps": 0, "suppressed": false, "cooldown": 0}
	loot_inventory.clear()
	character_progress.clear()
	party.assign(CORE_PROTAGONIST_IDS)
	party_formation = {&"ben": &"back", &"lincoln": &"front", &"gandhi": &"back"}
	_reset_recruit_statuses()
	facility_assignments.clear()
	active_facility_jobs.clear()
	completed_facility_jobs.clear()
	owned_inventions.clear()
	facility_upgrades.clear()
	expedition_meal_charges = 0
	equipment_loadouts.clear()
	economy_transactions.clear()
	encounter_director_states.clear()
	quest_states.clear()
	quest_events.clear()
	tracked_quest = &""
	_job_clock_accumulator = 0.0
	_ensure_default_progress()
	_initialize_quest_states()
	town_objects_changed.emit()
	town_terrain_changed.emit()
	encounter_pressure_changed.emit(encounter_pressure.duplicate(true))
	state_changed.emit()


func campaign_ending_state() -> Dictionary:
	var scenario_complete := bool(story_flags.get(&"empyreal_scenario_complete", false))
	var result_committed := bool(story_flags.get(&"ending_result_committed", false))
	var credits_seen := bool(story_flags.get(&"ending_credits_seen", false))
	var postgame_unlocked := bool(story_flags.get(&"postgame_unlocked", false))
	return {
		"eligible": scenario_complete,
		"result_committed": result_committed,
		"credits_seen": credits_seen,
		"postgame_unlocked": postgame_unlocked,
		"needs_presentation": scenario_complete and result_committed and not credits_seen,
		"final_save_marked": bool(story_flags.get(&"ending_final_save_marker", false)),
	}


func commit_campaign_ending_result() -> bool:
	# The High Comptroller can only pay out its authored conclusion once. This
	# marker is deliberately separate from the credits acknowledgement so a save
	# made after the battle but before the player reads the epilogue resumes it.
	if not bool(story_flags.get(&"empyreal_scenario_complete", false)):
		return false
	if bool(story_flags.get(&"ending_result_committed", false)):
		return false
	story_flags[&"ending_result_committed"] = true
	story_flags[&"seventh_universe_stabilized"] = true
	LocalTelemetry.record(&"campaign_ending_committed", {"chapter": &"postgame"})
	state_changed.emit()
	return true


func complete_campaign_ending(town_cell: Vector2i) -> bool:
	# This is the final save transaction. It cannot be replayed by reopening the
	# credits or by loading a save created after the final battle.
	if not bool(story_flags.get(&"ending_result_committed", false)):
		return false
	if bool(story_flags.get(&"ending_credits_seen", false)):
		return false
	story_flags[&"ending_credits_seen"] = true
	story_flags[&"postgame_unlocked"] = true
	story_flags[&"ending_final_save_marker"] = true
	last_save_cell = town_cell
	last_location = _location_name_for_cell(town_cell)
	last_manifest_room_id = &""
	LocalTelemetry.record(&"campaign_postgame_unlocked", {"location": last_location})
	state_changed.emit()
	return true


func postgame_rematch_available() -> bool:
	return bool(campaign_ending_state().get("postgame_unlocked", false))


func begin_play_session() -> void:
	_play_session_running = true


func pause_play_session() -> void:
	_play_session_running = false


func setup_sandbox(start_cell := Vector2i(50, 8)) -> void:
	reset_new_game()
	sandbox_mode = true
	town_time_minutes = 8.0 * 60.0
	_ensure_sandbox_authored_objects()
	duckets = 999999
	inventory = {
		&"tonic": 99, &"ether": 99, &"smelling_salts": 99, &"phoenix_tonic": 99,
		&"provisions": 99, &"rift_ward": 99, &"research_notes": 99,
		&"anchor_shard": 99, &"anchor_dust": 99, &"ectoplasm": 99,
	}
	party.assign([&"ben", &"fighter", &"astronaut"])
	party_formation = {&"ben": &"back", &"fighter": &"front", &"astronaut": &"back"}
	_reset_recruit_statuses()
	for recruit_id in recruit_catalog.keys():
		recruit_status[StringName(recruit_id)] = &"reserve"
	for recruit_id in party:
		recruit_status[recruit_id] = &"party"
	owned_inventions.clear()
	for invention_id in INVENTION_DEFINITIONS.keys():
		owned_inventions.append(StringName(invention_id))
	story_flags = {
		&"opening_complete": true,
		&"town_entered": true,
		&"sandbox_unlocked": true,
	}
	bestiary_records.clear()
	for enemy_id in CampaignCombatDatabase.bestiary_ids():
		bestiary_records[enemy_id] = {
			"seen": 1, "defeated": 1, "encounters": 1,
			"first_encounter": &"sandbox_workshop", "drops": [],
		}
	for raw_character_id in recruit_catalog.keys():
		var character_id := StringName(raw_character_id)
		var progress: Dictionary = character_progress[character_id]
		progress["level"] = 50
		progress["skill_points"] = 99
	last_save_cell = start_cell
	last_location = _location_name_for_cell(start_cell)
	last_manifest_room_id = &""
	_initialize_quest_states()
	party_changed.emit()
	state_changed.emit()


func place_town_object(catalog_id: StringName, cell: Vector2i, flipped := false) -> String:
	if not sandbox_mode or catalog_id == &"":
		return ""
	var instance_id := "town_object_%d" % next_town_object_id
	next_town_object_id += 1
	town_objects.append({
		"instance_id": instance_id,
		"catalog_id": catalog_id,
		"x": cell.x,
		"y": cell.y,
		"flipped": flipped,
	})
	town_objects_changed.emit()
	state_changed.emit()
	return instance_id


func move_town_object(instance_id: String, cell: Vector2i) -> bool:
	if not sandbox_mode:
		return false
	var placed := town_object(instance_id)
	if placed.is_empty():
		return false
	placed["x"] = cell.x
	placed["y"] = cell.y
	town_objects_changed.emit()
	state_changed.emit()
	return true


func flip_town_object(instance_id: String) -> bool:
	if not sandbox_mode:
		return false
	var placed := town_object(instance_id)
	if placed.is_empty():
		return false
	placed["flipped"] = not bool(placed.get("flipped", false))
	town_objects_changed.emit()
	state_changed.emit()
	return true


func remove_town_object(instance_id: String) -> bool:
	if not sandbox_mode:
		return false
	for index in range(town_objects.size()):
		if String(town_objects[index].get("instance_id", "")) == instance_id:
			if bool(town_objects[index].get("protected", false)):
				return false
			town_objects.remove_at(index)
			town_objects_changed.emit()
			state_changed.emit()
			return true
	return false


func town_object(instance_id: String) -> Dictionary:
	for placed in town_objects:
		if String(placed.get("instance_id", "")) == instance_id:
			return placed
	return {}


func town_object_with_role(role: StringName) -> Dictionary:
	for placed in town_objects:
		if StringName(placed.get("role", "")) == role:
			return placed
	return {}


func paint_town_terrain(cell: Vector2i, brush_id: StringName) -> bool:
	if not sandbox_mode or brush_id == &"":
		return false
	town_terrain[_terrain_cell_key(cell)] = brush_id
	town_terrain_changed.emit()
	state_changed.emit()
	return true


func clear_town_terrain(cell: Vector2i) -> bool:
	if not sandbox_mode:
		return false
	var key := _terrain_cell_key(cell)
	if not town_terrain.has(key):
		return false
	town_terrain.erase(key)
	town_terrain_changed.emit()
	state_changed.emit()
	return true


func sandbox_layout_snapshot() -> Dictionary:
	if not sandbox_mode:
		return {}
	return {
		"town_objects": town_objects.duplicate(true),
		"town_terrain": town_terrain.duplicate(true),
		"resident_states": resident_states.duplicate(true),
		"next_town_object_id": next_town_object_id,
	}


func restore_sandbox_layout(snapshot: Dictionary) -> bool:
	# Editor history is deliberately restricted to the sandbox document. It may
	# never rewrite campaign facilities, anchors, currency, quests, or recruits.
	if not sandbox_mode or snapshot.is_empty():
		return false
	var saved_objects: Array = snapshot.get("town_objects", [])
	var saved_terrain: Dictionary = snapshot.get("town_terrain", {})
	var saved_residents: Dictionary = snapshot.get("resident_states", {})
	var restored_objects: Array[Dictionary] = []
	for raw_object in saved_objects:
		if not raw_object is Dictionary:
			return false
		var restored_object: Dictionary = (raw_object as Dictionary).duplicate(true)
		restored_object["catalog_id"] = StringName(restored_object.get("catalog_id", ""))
		restored_object["x"] = int(restored_object.get("x", 0))
		restored_object["y"] = int(restored_object.get("y", 0))
		if restored_object.has("role"):
			restored_object["role"] = StringName(restored_object.get("role", ""))
		restored_objects.append(restored_object)
	var restored_terrain := {}
	for terrain_key in saved_terrain:
		restored_terrain[String(terrain_key)] = StringName(saved_terrain[terrain_key])
	var restored_residents := {}
	for resident_id in saved_residents:
		var raw_state: Variant = saved_residents[resident_id]
		if not raw_state is Dictionary:
			return false
		var restored_state: Dictionary = (raw_state as Dictionary).duplicate(true)
		for coordinate_key in ["x", "y", "target_x", "target_y"]:
			if restored_state.has(coordinate_key):
				restored_state[coordinate_key] = int(restored_state.get(coordinate_key, 0))
		if restored_state.has("activity"):
			restored_state["activity"] = StringName(restored_state.get("activity", ""))
		restored_residents[StringName(resident_id)] = restored_state
	town_objects = restored_objects
	town_terrain = restored_terrain
	resident_states = restored_residents
	next_town_object_id = maxi(1, int(snapshot.get("next_town_object_id", town_objects.size() + 1)))
	town_objects_changed.emit()
	town_terrain_changed.emit()
	state_changed.emit()
	return true


func sandbox_layout_slot_path(slot_id: int) -> String:
	return SANDBOX_LAYOUT_SLOT_PATH % clampi(slot_id, 1, SANDBOX_LAYOUT_SLOT_COUNT)


func sandbox_layout_slot_exists(slot_id: int) -> bool:
	if slot_id < 1 or slot_id > SANDBOX_LAYOUT_SLOT_COUNT:
		return false
	return FileAccess.file_exists(sandbox_layout_slot_path(slot_id))


func save_sandbox_layout_slot(slot_id: int) -> Error:
	if not sandbox_mode or slot_id < 1 or slot_id > SANDBOX_LAYOUT_SLOT_COUNT:
		return ERR_INVALID_PARAMETER
	return SAVE_REPOSITORY.write_json(sandbox_layout_slot_path(slot_id), {
		"version": SANDBOX_LAYOUT_SLOT_VERSION,
		"slot_id": slot_id,
		"layout": sandbox_layout_snapshot(),
	})


func load_sandbox_layout_slot(slot_id: int) -> Dictionary:
	if not sandbox_mode or slot_id < 1 or slot_id > SANDBOX_LAYOUT_SLOT_COUNT:
		return {"loaded": false, "reason": "invalid_slot"}
	var path := sandbox_layout_slot_path(slot_id)
	var candidates := PackedStringArray([path])
	for recovery_path in SAVE_REPOSITORY.recovery_paths(path):
		candidates.append(recovery_path)
	for index in candidates.size():
		var candidate := candidates[index]
		var text_result := SAVE_REPOSITORY.read_text(candidate)
		if not bool(text_result.get("ok", false)):
			continue
		var parser := JSON.new()
		if parser.parse(String(text_result.get("text", ""))) != OK or not parser.data is Dictionary:
			continue
		var payload: Dictionary = parser.data
		var raw_layout: Variant = payload.get("layout", {})
		if not raw_layout is Dictionary:
			continue
		var layout: Dictionary = raw_layout
		if int(payload.get("version", 0)) != SANDBOX_LAYOUT_SLOT_VERSION or not _sandbox_layout_payload_valid(layout):
			continue
		if not restore_sandbox_layout(layout):
			return {"loaded": false, "reason": "restore_failed"}
		if index > 0:
			SAVE_REPOSITORY.restore_primary(path, String(text_result.get("text", "")))
		return {"loaded": true, "slot_id": slot_id, "recovered": index > 0}
	return {"loaded": false, "reason": "missing_or_invalid"}


func _sandbox_layout_payload_valid(layout: Dictionary) -> bool:
	var raw_objects: Variant = layout.get("town_objects", [])
	var raw_terrain: Variant = layout.get("town_terrain", {})
	var raw_residents: Variant = layout.get("resident_states", {})
	if not raw_objects is Array or not raw_terrain is Dictionary or not raw_residents is Dictionary:
		return false
	var objects: Array = raw_objects
	var terrain: Dictionary = raw_terrain
	var residents: Dictionary = raw_residents
	if objects.is_empty() or int(layout.get("next_town_object_id", 0)) < 1:
		return false
	var instance_ids := {}
	var occupied_cells := {}
	var largest_generated_id := 0
	var required_protected_ids := {}
	var protected_definitions := {}
	for authored in SANDBOX_AUTHORED_OBJECTS:
		if bool(authored.get("protected", false)):
			var protected_id := String(authored.get("instance_id", ""))
			required_protected_ids[protected_id] = true
			protected_definitions[protected_id] = authored
	for raw_object in objects:
		if not raw_object is Dictionary:
			return false
		var placed: Dictionary = raw_object
		var instance_id := String(placed.get("instance_id", ""))
		var catalog_id := StringName(placed.get("catalog_id", ""))
		if instance_id.is_empty() or instance_ids.has(instance_id) or SANDBOX_OBJECT_CATALOG.definition(catalog_id).is_empty():
			return false
		instance_ids[instance_id] = true
		if instance_id.begins_with("town_object_"):
			var generated_suffix := instance_id.trim_prefix("town_object_")
			if not generated_suffix.is_valid_int():
				return false
			largest_generated_id = maxi(largest_generated_id, int(generated_suffix))
		var footprint: Vector2i = SANDBOX_OBJECT_CATALOG.definition(catalog_id).get("footprint", Vector2i.ONE)
		var rect := Rect2i(Vector2i(int(placed.get("x", -999)), int(placed.get("y", -999))), footprint)
		if not SANDBOX_TOWN_INTERIOR.encloses(rect):
			return false
		if protected_definitions.has(instance_id):
			var authored: Dictionary = protected_definitions[instance_id]
			if not bool(placed.get("protected", false)) \
					or StringName(authored.get("catalog_id", "")) != catalog_id \
					or StringName(authored.get("role", "")) != StringName(placed.get("role", "")):
				return false
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				var occupied_cell := Vector2i(x, y)
				if occupied_cells.has(occupied_cell):
					return false
				occupied_cells[occupied_cell] = true
	for protected_id in required_protected_ids:
		if not instance_ids.has(protected_id):
			return false
	if int(layout.get("next_town_object_id", 0)) <= largest_generated_id:
		return false
	for terrain_key in terrain.keys():
		var parts := String(terrain_key).split(",")
		if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
			return false
		var cell := Vector2i(int(parts[0]), int(parts[1]))
		if not SANDBOX_TOWN_INTERIOR.has_point(cell) or SANDBOX_TERRAIN_CATALOG.definition(StringName(terrain[terrain_key])).is_empty():
			return false
	var resident_cells := {}
	for resident_id in residents.keys():
		if String(resident_id).is_empty():
			return false
		var state: Variant = residents[resident_id]
		if not state is Dictionary:
			return false
		var resident_cell := Vector2i(int(state.get("x", -999)), int(state.get("y", -999)))
		if not SANDBOX_TOWN_INTERIOR.has_point(resident_cell) or occupied_cells.has(resident_cell) or resident_cells.has(resident_cell):
			return false
		resident_cells[resident_cell] = true
	return true


func town_terrain_at(cell: Vector2i) -> StringName:
	return StringName(town_terrain.get(_terrain_cell_key(cell), ""))


func town_terrain_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for key in town_terrain.keys():
		var parts := String(key).split(",")
		if parts.size() == 2:
			cells.append(Vector2i(int(parts[0]), int(parts[1])))
	return cells


func _terrain_cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func set_resident_state(resident_id: StringName, cell: Vector2i, activity: StringName, target := Gameboard.INVALID_CELL) -> void:
	resident_states[resident_id] = {
		"x": cell.x,
		"y": cell.y,
		"activity": activity,
		"target_x": target.x,
		"target_y": target.y,
	}


func resident_state(resident_id: StringName) -> Dictionary:
	return resident_states.get(resident_id, {})


func _ensure_sandbox_authored_objects() -> void:
	for authored in SANDBOX_AUTHORED_OBJECTS:
		var instance_id := String(authored.get("instance_id", ""))
		if not town_object(instance_id).is_empty():
			continue
		var cell: Vector2i = authored.get("cell", Vector2i.ZERO)
		town_objects.append({
			"instance_id": instance_id,
			"catalog_id": StringName(authored.get("catalog_id", "")),
			"x": cell.x,
			"y": cell.y,
			"flipped": bool(authored.get("flipped", false)),
			"role": StringName(authored.get("role", "")),
			"protected": bool(authored.get("protected", false)),
		})
	town_objects_changed.emit()


func _ensure_default_progress() -> void:
	for raw_character_id in recruit_catalog.keys():
		var character_id := StringName(raw_character_id)
		var defaults := _default_vitals(character_id)
		ensure_character_progress(character_id, defaults.x, defaults.y)


func _reset_recruit_statuses() -> void:
	recruit_status.clear()
	for raw_recruit_id in recruit_catalog.keys():
		var recruit_id := StringName(raw_recruit_id)
		recruit_status[recruit_id] = &"party" if recruit_id in CORE_PROTAGONIST_IDS else &"undiscovered"


func ensure_character_progress(character_id: StringName, max_hp: int, max_mp: int) -> Dictionary:
	if not character_progress.has(character_id):
		character_progress[character_id] = {
			"level": 1, "exp": 0, "hp": max_hp, "mp": max_mp,
			"skill_points": 0, "learned_skills": [], "equipment": {},
		}
	var progress: Dictionary = character_progress[character_id]
	if not progress.has("skill_points"):
		progress["skill_points"] = 0
	if not progress.has("learned_skills"):
		progress["learned_skills"] = []
	if not progress.has("equipment"):
		progress["equipment"] = {}
	return progress


func skill_tree(character_id: StringName) -> Array:
	return SKILL_TREES.get(character_id, []).duplicate(true)


func learn_skill(character_id: StringName, skill_id: StringName) -> bool:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var learned: Array = progress["learned_skills"]
	if skill_id in learned:
		return false
	var skill := _skill_definition(character_id, skill_id)
	if skill.is_empty() or int(progress["skill_points"]) < int(skill.get("cost", 1)):
		return false
	for requirement in skill.get("requires", []):
		if StringName(requirement) not in learned:
			return false
	progress["skill_points"] = int(progress["skill_points"]) - int(skill.get("cost", 1))
	learned.append(skill_id)
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func reset_skill_tree(character_id: StringName) -> bool:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var learned: Array = progress["learned_skills"]
	if learned.is_empty():
		return false
	var refund := 0
	for skill_id in learned:
		refund += int(_skill_definition(character_id, StringName(skill_id)).get("cost", 0))
	progress["skill_points"] = int(progress["skill_points"]) + refund
	learned.clear()
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func equip_loot(character_id: StringName, instance_id: String) -> bool:
	var item := loot_by_instance(instance_id)
	var slot := StringName(item.get("slot", ""))
	if item.is_empty() or slot not in EQUIPMENT_SLOTS or not item_is_compatible_with_character(character_id, item):
		return false
	for other_id in character_progress.keys():
		var other_progress: Dictionary = character_progress[other_id]
		var other_equipment: Dictionary = other_progress.get("equipment", {})
		for other_slot in other_equipment.keys():
			if String(other_equipment[other_slot]) == instance_id:
				other_equipment.erase(other_slot)
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	progress["equipment"][slot] = instance_id
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func unequip_slot(character_id: StringName, slot: StringName) -> bool:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	if not progress["equipment"].has(slot):
		return false
	progress["equipment"].erase(slot)
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func unequip_all_inactive(character_id: StringName) -> bool:
	if StringName(recruit_status.get(character_id, &"undiscovered")) not in [&"reserve", &"staffed"]:
		return false
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	if progress.get("equipment", {}).is_empty():
		return false
	progress["equipment"].clear()
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func equipment_affinities_for(character_id: StringName) -> Array[StringName]:
	var results: Array[StringName] = []
	for raw_affinity in EQUIPMENT_AFFINITIES.get(character_id, [&"field"]):
		results.append(StringName(raw_affinity))
	return results


func item_is_compatible_with_character(character_id: StringName, item: Dictionary) -> bool:
	if not recruit_catalog.has(character_id) or item.is_empty():
		return false
	var allowed: Array = item.get("allowed_characters", [])
	if not allowed.is_empty() and character_id not in allowed and String(character_id) not in allowed:
		return false
	var required_affinities: Array = item.get("required_affinities", [])
	if required_affinities.is_empty():
		return true
	var affinities := equipment_affinities_for(character_id)
	for raw_affinity in required_affinities:
		if StringName(raw_affinity) in affinities:
			return true
	return false


func save_equipment_loadout(character_id: StringName, loadout_name: String) -> bool:
	var normalized_name := loadout_name.strip_edges().left(24)
	if normalized_name.is_empty() or not character_progress.has(character_id):
		return false
	var equipment: Dictionary = character_progress[character_id].get("equipment", {})
	if equipment.is_empty():
		return false
	if not equipment_loadouts.has(character_id):
		equipment_loadouts[character_id] = {}
	equipment_loadouts[character_id][normalized_name] = equipment.duplicate(true)
	state_changed.emit()
	return true


func equipment_loadouts_for(character_id: StringName) -> Dictionary:
	return equipment_loadouts.get(character_id, {}).duplicate(true)


func apply_equipment_loadout(character_id: StringName, loadout_name: String) -> bool:
	if not equipment_loadouts.has(character_id) or not equipment_loadouts[character_id].has(loadout_name):
		return false
	var requested: Dictionary = equipment_loadouts[character_id][loadout_name]
	var restored := {}
	for raw_slot in requested.keys():
		var slot := StringName(raw_slot)
		var instance_id := String(requested[raw_slot])
		var item := loot_by_instance(instance_id)
		if slot not in EQUIPMENT_SLOTS or item.is_empty() or StringName(item.get("slot", "")) != slot:
			return false
		if not item_is_compatible_with_character(character_id, item):
			return false
		restored[slot] = instance_id
	for other_id in character_progress.keys():
		var other_equipment: Dictionary = character_progress[other_id].get("equipment", {})
		for slot in other_equipment.keys():
			if String(other_equipment[slot]) in restored.values():
				other_equipment.erase(slot)
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	progress["equipment"] = restored
	_clamp_character_vitals(character_id)
	state_changed.emit()
	return true


func loot_by_instance(instance_id: String) -> Dictionary:
	for item in loot_inventory:
		if String(item.get("instance_id", "")) == instance_id:
			return item
	return {}


func equipped_loot(character_id: StringName) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var progress: Dictionary = character_progress.get(character_id, {})
	var equipment: Dictionary = progress.get("equipment", {})
	for slot in EQUIPMENT_SLOTS:
		var item := loot_by_instance(String(equipment.get(slot, "")))
		if not item.is_empty():
			results.append(item)
	return results


func actor_build(character_id: StringName) -> Dictionary:
	var bonuses := {&"max_hp": 0, &"max_mp": 0, &"attack": 0, &"defense": 0, &"magic": 0, &"spirit": 0, &"speed": 0}
	var actions: Array[StringName] = []
	var element_rates: Dictionary = {}
	var progress: Dictionary = character_progress.get(character_id, {})
	for skill_id in progress.get("learned_skills", []):
		var skill := _skill_definition(character_id, StringName(skill_id))
		for stat in skill.get("bonuses", {}).keys():
			bonuses[StringName(stat)] = int(bonuses.get(StringName(stat), 0)) + int(skill["bonuses"][stat])
		var action_id := StringName(skill.get("action", ""))
		if action_id != &"" and action_id not in actions:
			actions.append(action_id)
	for item in equipped_loot(character_id):
		for modifier in item.get("modifiers", []):
			var stat := StringName(modifier.get("stat", ""))
			if bonuses.has(stat):
				bonuses[stat] = int(bonuses[stat]) + int(modifier.get("value", 0))
		var granted_action := StringName(item.get("granted_action", ""))
		if granted_action != &"" and granted_action not in actions:
			actions.append(granted_action)
		for raw_element in (item.get("element_rates", {}) as Dictionary):
			var element := StringName(raw_element)
			var rate := clampf(float(item["element_rates"][raw_element]), 0.25, 1.0)
			element_rates[element] = maxf(0.25, float(element_rates.get(element, 1.0)) * rate)
	return {"bonuses": bonuses, "actions": actions, "element_rates": element_rates}


func _skill_definition(character_id: StringName, skill_id: StringName) -> Dictionary:
	for skill in SKILL_TREES.get(character_id, []):
		if StringName(skill.get("id", "")) == skill_id:
			return skill
	return {}


func experience_for_next_level(level: int) -> int:
	return 50 + (level - 1) * (level - 1) * 35


func grant_experience(character_id: StringName, amount: int) -> Array[int]:
	var defaults := _default_vitals(character_id)
	var progress: Dictionary = ensure_character_progress(character_id, defaults.x, defaults.y)
	progress["exp"] = int(progress.get("exp", 0)) + maxi(amount, 0)
	var gained_levels: Array[int] = []
	while int(progress["level"]) < 50 and int(progress["exp"]) >= experience_for_next_level(int(progress["level"])):
		progress["exp"] = int(progress["exp"]) - experience_for_next_level(int(progress["level"]))
		progress["level"] = int(progress["level"]) + 1
		progress["skill_points"] = int(progress.get("skill_points", 0)) + 1
		gained_levels.append(int(progress["level"]))
	return gained_levels


func active_party_median_level() -> int:
	var levels: Array[int] = []
	for character_id in party:
		var defaults := _default_vitals(character_id)
		var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
		levels.append(int(progress.get("level", 1)))
	if levels.is_empty():
		return 1
	levels.sort()
	var upper_index := levels.size() / 2
	if levels.size() % 2 == 1:
		return levels[upper_index]
	return int(round((float(levels[upper_index - 1]) + float(levels[upper_index])) / 2.0))


func progression_chapter_floor() -> int:
	var stabilized := 0
	for flag in [&"first_universe_stabilized", &"second_universe_stabilized", &"third_universe_stabilized", &"fourth_universe_stabilized", &"fifth_universe_stabilized", &"sixth_universe_stabilized", &"seventh_universe_stabilized"]:
		if bool(story_flags.get(flag, false)):
			stabilized += 1
	return clampi(1 + stabilized * 3, 1, 35)


func grant_expedition_experience(experience: int) -> Dictionary:
	var level_ups := {}
	for character_id in party:
		var levels := grant_experience(character_id, experience)
		if not levels.is_empty():
			level_ups[character_id] = levels
	for raw_character_id in recruit_status.keys():
		var character_id := StringName(raw_character_id)
		if character_id in party:
			continue
		var status := StringName(recruit_status[character_id])
		if status == &"reserve":
			grant_experience(character_id, int(round(float(experience) * RESERVE_EXPERIENCE_RATIO)))
		elif status == &"staffed":
			grant_experience(character_id, _rested_catch_up_experience(character_id, experience))
	_enforce_hired_progression_floor()
	return level_ups


func _rested_catch_up_experience(character_id: StringName, reference_experience: int) -> int:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var level_gap := maxi(0, active_party_median_level() - int(progress.get("level", 1)))
	if level_gap <= 0:
		return 0
	return int(ceil(float(reference_experience) * minf(0.5, 0.25 * float(level_gap))))


func _enforce_hired_progression_floor() -> void:
	var target_level := maxi(progression_chapter_floor(), active_party_median_level() - MAX_HIRED_LEVEL_GAP)
	for raw_character_id in recruit_status.keys():
		var character_id := StringName(raw_character_id)
		if StringName(recruit_status[character_id]) in [&"reserve", &"staffed"]:
			_raise_character_to_level(character_id, target_level)


func _raise_character_to_level(character_id: StringName, target_level: int) -> bool:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var current_level := int(progress.get("level", 1))
	if target_level <= current_level:
		return false
	var applied_level := clampi(target_level, current_level, 50)
	progress["level"] = applied_level
	progress["skill_points"] = int(progress.get("skill_points", 0)) + applied_level - current_level
	var maximums := _maximum_vitals(character_id)
	progress["hp"] = maximums.x
	progress["mp"] = maximums.y
	return true


func apply_battle_victory(experience: int, earned_duckets: int, loot: Array[Dictionary]) -> Dictionary:
	var awarded_experience := experience
	if expedition_meal_charges > 0:
		awarded_experience = int(ceil(float(experience) * 1.2))
		expedition_meal_charges -= 1
	var level_ups := grant_expedition_experience(awarded_experience)
	adjust_duckets(maxi(earned_duckets, 0), &"battle_victory", &"encounter", false)
	add_loot_drops(loot, false, &"battle_victory", &"encounter")
	story_flags[&"won_first_battle"] = true
	LocalTelemetry.record(&"battle_victory", {
		"experience": awarded_experience,
		"duckets": maxi(earned_duckets, 0),
		"loot_count": loot.size(),
		"level_up_count": level_ups.size(),
	})
	state_changed.emit()
	return level_ups


func add_loot_drops(loot: Array[Dictionary], notify := true, reason_id: StringName = &"loot_drop", source_context: StringName = &"") -> void:
	for drop in loot:
		if drop.get("kind", "gear") == "consumable":
			add_item(StringName(drop.get("id", "tonic")), int(drop.get("quantity", 1)), false, reason_id, source_context)
		else:
			loot_inventory.append(drop.duplicate(true))
	if notify:
		state_changed.emit()


func claim_universe_treasure(cache_id: StringName, rng: RandomNumberGenerator = null) -> Dictionary:
	var definition: Dictionary = UNIVERSE_TREASURE_CACHES.get(cache_id, {})
	if definition.is_empty():
		return {"claimed": false, "reason": "unknown"}
	var flag: StringName = definition["flag"]
	if bool(story_flags.get(flag, false)):
		return {"claimed": false, "reason": "already_claimed", "name": definition["name"]}
	var roller := rng
	if not roller:
		roller = RandomNumberGenerator.new()
		roller.seed = hash(String(cache_id)) ^ Time.get_ticks_usec()
	var loot: Array[Dictionary] = CampaignCombatDatabase.roll_loot(definition["loot_encounter"], roller)
	var earned_duckets := int(definition.get("duckets", 0))
	story_flags[flag] = true
	adjust_duckets(earned_duckets, &"universe_treasure", cache_id, false)
	add_loot_drops(loot, false, &"universe_treasure", cache_id)
	state_changed.emit()
	return {
		"claimed": true, "name": definition["name"],
		"description": definition["description"], "duckets": earned_duckets,
		"loot": loot,
	}


func record_bestiary_sighting(encounter_id: StringName, enemy_types: Array[StringName]) -> void:
	if enemy_types.is_empty():
		return
	var encounter_counts := {}
	for enemy_id in enemy_types:
		if enemy_id == &"":
			continue
		encounter_counts[enemy_id] = int(encounter_counts.get(enemy_id, 0)) + 1
	for enemy_id in encounter_counts.keys():
		var record: Dictionary = bestiary_records.get(enemy_id, {
			"seen": 0, "defeated": 0, "encounters": 0,
			"first_encounter": encounter_id, "drops": [],
		})
		record["seen"] = int(record.get("seen", 0)) + int(encounter_counts[enemy_id])
		record["encounters"] = int(record.get("encounters", 0)) + 1
		if StringName(record.get("first_encounter", &"")) == &"":
			record["first_encounter"] = encounter_id
		bestiary_records[StringName(enemy_id)] = record
	state_changed.emit()


func record_bestiary_victory(encounter_id: StringName, enemy_types: Array[StringName], loot: Array[Dictionary]) -> void:
	if enemy_types.is_empty():
		return
	var defeat_counts := {}
	for enemy_id in enemy_types:
		if enemy_id == &"":
			continue
		defeat_counts[enemy_id] = int(defeat_counts.get(enemy_id, 0)) + 1
	for enemy_id in defeat_counts.keys():
		var record: Dictionary = bestiary_records.get(enemy_id, {
			"seen": int(defeat_counts[enemy_id]), "defeated": 0, "encounters": 1,
			"first_encounter": encounter_id, "drops": [],
		})
		record["defeated"] = int(record.get("defeated", 0)) + int(defeat_counts[enemy_id])
		var known_drops: Array = record.get("drops", [])
		for raw_drop in loot:
			var drop: Dictionary = raw_drop
			var drop_id := StringName(drop.get("id", ""))
			if drop_id == &"":
				continue
			var already_known := false
			for known_drop in known_drops:
				if StringName(known_drop.get("id", "")) == drop_id:
					already_known = true
					break
			if not already_known:
				known_drops.append({
					"id": drop_id,
					"name": String(drop.get("display_name", drop.get("base_name", String(drop_id).capitalize()))),
					"rarity": String(drop.get("rarity", "Common")),
					"kind": String(drop.get("kind", "gear")),
				})
		record["drops"] = known_drops
		bestiary_records[StringName(enemy_id)] = record
	state_changed.emit()


func bestiary_record(enemy_id: StringName) -> Dictionary:
	return bestiary_records.get(enemy_id, {}).duplicate(true)


func discovered_bestiary_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for enemy_id in CampaignCombatDatabase.bestiary_ids():
		if int(bestiary_records.get(enemy_id, {}).get("seen", 0)) > 0:
			result.append(enemy_id)
	return result


func bestiary_summary() -> Dictionary:
	var discovered := discovered_bestiary_ids()
	var defeated_species := 0
	var total_defeated := 0
	var bosses_defeated := 0
	for enemy_id in discovered:
		var record: Dictionary = bestiary_records.get(enemy_id, {})
		var defeated := int(record.get("defeated", 0))
		total_defeated += defeated
		if defeated > 0:
			defeated_species += 1
			if bool(CampaignCombatDatabase.bestiary_entry(enemy_id).get("boss", false)):
				bosses_defeated += 1
	return {
		"species_seen": discovered.size(),
		"species_total": CampaignCombatDatabase.bestiary_ids().size(),
		"species_defeated": defeated_species,
		"total_defeated": total_defeated,
		"bosses_defeated": bosses_defeated,
	}


func add_item(item_id: StringName, quantity := 1, notify := true, reason_id: StringName = &"item_grant", source_context: StringName = &"") -> void:
	var previous := int(inventory.get(item_id, 0))
	inventory[item_id] = maxi(0, previous + quantity)
	var applied := int(inventory[item_id]) - previous
	if applied != 0:
		record_economy_transaction(reason_id, item_id, applied, source_context)
	if notify:
		state_changed.emit()


func adjust_duckets(delta: int, reason_id: StringName, source_context: StringName = &"", notify := true) -> bool:
	if delta == 0:
		return true
	if duckets + delta < 0:
		return false
	duckets += delta
	record_economy_transaction(reason_id, &"duckets", delta, source_context)
	if notify:
		state_changed.emit()
	return true


func record_economy_transaction(reason_id: StringName, currency_or_item: StringName, delta: int, source_context: StringName = &"") -> Dictionary:
	var entry := ECONOMY_LEDGER.record(
		economy_transactions,
		reason_id,
		current_economy_chapter(),
		currency_or_item,
		delta,
		source_context,
		_unix_time()
	)
	if not entry.is_empty():
		LocalTelemetry.record(&"economy_transaction", entry)
	return entry


func current_economy_chapter() -> StringName:
	var chapter_states := [
		[&"empyreal_scenario_complete", &"postgame"],
		[&"empyreal_anchor_built", &"empyreal"],
		[&"moonpetal_scenario_complete", &"empyreal"],
		[&"moonpetal_anchor_built", &"moonpetal"],
		[&"frosthold_scenario_complete", &"moonpetal"],
		[&"frosthold_anchor_built", &"frosthold"],
		[&"helios_scenario_complete", &"frosthold"],
		[&"helios_anchor_built", &"helios"],
		[&"primeval_scenario_complete", &"helios"],
		[&"primeval_anchor_built", &"primeval"],
		[&"asterion_station_complete", &"primeval"],
		[&"asterion_anchor_built", &"asterion"],
		[&"mansion_archive_boss_defeated", &"asterion"],
		[&"haunted_mansion_anchor_built", &"mansion"],
	]
	for state in chapter_states:
		if bool(story_flags.get(state[0], false)):
			return state[1]
	return &"founding"


func economy_report() -> Dictionary:
	return ECONOMY_LEDGER.report(economy_transactions, duckets)


func balance_report() -> Dictionary:
	var active_levels := {}
	var inactive_levels := {}
	for raw_character_id in recruit_status.keys():
		var character_id := StringName(raw_character_id)
		var status := StringName(recruit_status.get(character_id, &"undiscovered"))
		if status not in [&"party", &"reserve", &"staffed"]:
			continue
		var progress: Dictionary = character_progress.get(character_id, {})
		var level := int(progress.get("level", 1))
		if status == &"party":
			active_levels[character_id] = level
		else:
			inactive_levels[character_id] = level
	var inactive_values: Array[int] = []
	for level in inactive_levels.values():
		inactive_values.append(int(level))
	inactive_values.sort()
	var inactive_median := 0
	if not inactive_values.is_empty():
		var upper_index := inactive_values.size() / 2
		inactive_median = inactive_values[upper_index] if inactive_values.size() % 2 == 1 else int(round((float(inactive_values[upper_index - 1]) + float(inactive_values[upper_index])) / 2.0))
	var active_median := active_party_median_level()
	return {
		"chapter": current_economy_chapter(),
		"active_party_median_level": active_median,
		"active_party_levels": active_levels,
		"inactive_levels": inactive_levels,
		"inactive_median_level": inactive_median,
		"reserve_level_gap": maxi(0, active_median - inactive_median) if inactive_median > 0 else 0,
		"economy": economy_report(),
		"telemetry": LocalTelemetry.summary(),
	}


func telemetry_world_state() -> Dictionary:
	var stabilized_universes := 0
	for flag in [&"first_universe_stabilized", &"second_universe_stabilized", &"third_universe_stabilized", &"fourth_universe_stabilized", &"fifth_universe_stabilized", &"sixth_universe_stabilized", &"seventh_universe_stabilized"]:
		if bool(story_flags.get(flag, false)):
			stabilized_universes += 1
	return {
		"sandbox": sandbox_mode,
		"anchors": universe_anchors.size(),
		"facilities": built_facilities.size(),
		"stabilized_universes": stabilized_universes,
	}


func encounter_director_state(universe_id: StringName) -> Dictionary:
	return encounter_director_states.get(universe_id, {}).duplicate(true)


func store_encounter_director_state(universe_id: StringName, runtime: Dictionary) -> void:
	if universe_id == &"":
		return
	var recent: Array[StringName] = []
	for encounter_id in runtime.get("recent_formations", []):
		recent.append(StringName(encounter_id))
	var last_cell: Vector2i = runtime.get("last_danger_cell", Vector2i(-1, -1))
	encounter_director_states[universe_id] = {
		"steps_in_danger": maxi(0, int(runtime.get("steps_in_danger", 0))),
		"encounter_threshold": maxi(1, int(runtime.get("encounter_threshold", 1))),
		"cooldown_steps": maxi(0, int(runtime.get("cooldown_steps", 0))),
		"recent_formations": recent,
		"last_danger_cell": [last_cell.x, last_cell.y],
		"rng_state": int(runtime.get("rng_state", 0)),
	}


func consume_item(item_id: StringName, quantity := 1, reason_id: StringName = &"item_consumed", source_context: StringName = &"") -> bool:
	var current := int(inventory.get(item_id, 0))
	if quantity <= 0 or current < quantity:
		return false
	inventory[item_id] = current - quantity
	record_economy_transaction(reason_id, item_id, -quantity, source_context)
	state_changed.emit()
	return true


func field_item_definition(item_id: StringName) -> Dictionary:
	return SERVICE_ITEM_CATALOG.get(item_id, {}).duplicate(true)


func field_item_use_preview(item_id: StringName, target_id: StringName = &"") -> Dictionary:
	var definition := field_item_definition(item_id)
	var quantity := int(inventory.get(item_id, 0))
	var result := {
		"usable": false, "item_id": item_id, "target_id": target_id,
		"name": String(definition.get("name", String(item_id).replace("_", " ").capitalize())),
		"quantity": quantity, "reason": "This item is not usable from the field inventory.",
	}
	if quantity <= 0:
		result["reason"] = "None remaining."
		return result
	if item_id == &"rift_ward":
		result["usable"] = encounter_ward_steps < 120
		result["reason"] = "Suppress 40 dangerous steps • %d currently protected" % encounter_ward_steps if bool(result["usable"]) else "Rift Ward protection is already at its 120-step maximum."
		return result
	if target_id not in party:
		result["reason"] = "Choose an active party member."
		return result
	var maximums := _maximum_vitals(target_id)
	var defaults := _default_vitals(target_id)
	var progress := ensure_character_progress(target_id, defaults.x, defaults.y)
	var hp := int(progress.get("hp", maximums.x))
	var mp := int(progress.get("mp", maximums.y))
	match item_id:
		&"tonic":
			result["usable"] = hp > 0 and hp < maximums.x
			result["reason"] = "Restore up to 70 HP • %d/%d HP" % [hp, maximums.x] if bool(result["usable"]) else ("Cannot restore a knocked-out ally." if hp <= 0 else "HP is already full.")
		&"ether":
			result["usable"] = hp > 0 and mp < maximums.y
			result["reason"] = "Restore up to 24 MP • %d/%d MP" % [mp, maximums.y] if bool(result["usable"]) else ("Cannot restore a knocked-out ally." if hp <= 0 else "MP is already full.")
		&"phoenix_tonic":
			result["usable"] = hp <= 0
			result["reason"] = "Revive with 25%% HP • currently knocked out" if bool(result["usable"]) else "Use only on a knocked-out ally."
		&"smelling_salts":
			result["reason"] = "Battle ailments end after combat; use this from the battle Item command."
		&"provisions":
			result["reason"] = "Assignment material for facilities and specialist work."
	return result


func use_field_item(item_id: StringName, target_id: StringName = &"") -> Dictionary:
	var preview := field_item_use_preview(item_id, target_id)
	if not bool(preview.get("usable", false)):
		return preview
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	var message := ""
	if item_id == &"rift_ward":
		var before := encounter_ward_steps
		encounter_ward_steps = mini(120, encounter_ward_steps + 40)
		message = "Rift Ward activated. %d dangerous steps are protected." % (encounter_ward_steps - before)
		encounter_pressure["ward_steps"] = encounter_ward_steps
		encounter_pressure_changed.emit(encounter_pressure.duplicate(true))
	else:
		var maximums := _maximum_vitals(target_id)
		var defaults := _default_vitals(target_id)
		var progress := ensure_character_progress(target_id, defaults.x, defaults.y)
		var target_name := String(recruit_catalog.get(target_id, {}).get("name", String(target_id)))
		match item_id:
			&"tonic":
				var before_hp := int(progress.get("hp", maximums.x))
				progress["hp"] = mini(maximums.x, before_hp + 70)
				message = "%s recovered %d HP." % [target_name, int(progress["hp"]) - before_hp]
			&"ether":
				var before_mp := int(progress.get("mp", maximums.y))
				progress["mp"] = mini(maximums.y, before_mp + 24)
				message = "%s recovered %d MP." % [target_name, int(progress["mp"]) - before_mp]
			&"phoenix_tonic":
				progress["hp"] = maxi(1, int(ceil(float(maximums.x) * 0.25)))
				message = "%s revived with %d HP." % [target_name, int(progress["hp"])]
	story_flags[&"field_items_used"] = int(story_flags.get(&"field_items_used", 0)) + 1
	if item_id == &"rift_ward":
		story_flags[&"rift_wards_used"] = int(story_flags.get(&"rift_wards_used", 0)) + 1
	preview["usable"] = true
	preview["used"] = true
	preview["message"] = message
	preview["quantity"] = int(inventory.get(item_id, 0))
	state_changed.emit()
	return preview


func report_encounter_pressure(universe_id: StringName, steps: int, threshold: int, in_danger := true, cooldown := 0, suppressed := false) -> void:
	var next := {
		"active": in_danger or cooldown > 0,
		"universe_id": universe_id,
		"steps": clampi(steps, 0, maxi(1, threshold)),
		"threshold": maxi(1, threshold),
		"ward_steps": encounter_ward_steps,
		"suppressed": suppressed,
		"cooldown": maxi(0, cooldown),
	}
	if next == encounter_pressure:
		return
	encounter_pressure = next
	encounter_pressure_changed.emit(encounter_pressure.duplicate(true))


func clear_encounter_pressure(universe_id: StringName = &"") -> void:
	if universe_id != &"" and StringName(encounter_pressure.get("universe_id", &"")) not in [&"", universe_id]:
		return
	var next := {"active": false, "universe_id": &"", "steps": 0, "threshold": 1, "ward_steps": encounter_ward_steps, "suppressed": false, "cooldown": 0}
	if next == encounter_pressure:
		return
	encounter_pressure = next
	encounter_pressure_changed.emit(encounter_pressure.duplicate(true))


func consume_encounter_ward_step(universe_id: StringName) -> bool:
	if encounter_ward_steps <= 0:
		return false
	encounter_ward_steps -= 1
	story_flags[&"rift_ward_steps_prevented"] = int(story_flags.get(&"rift_ward_steps_prevented", 0)) + 1
	report_encounter_pressure(universe_id, 0, 1, true, 0, true)
	return true


func set_character_vitals(character_id: StringName, hp: int, mp: int, max_hp: int, max_mp: int) -> void:
	var progress := ensure_character_progress(character_id, max_hp, max_mp)
	progress["hp"] = clampi(hp, 0, max_hp)
	progress["mp"] = clampi(mp, 0, max_mp)


func restore_party() -> void:
	for character_id in party:
		var defaults := _default_vitals(character_id)
		var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
		var maximums := _maximum_vitals(character_id)
		progress["hp"] = maximums.x
		progress["mp"] = maximums.y
	state_changed.emit()


func activate_save_point(save_point_id: StringName) -> bool:
	var definition: Dictionary = UNIVERSE_SAVE_POINTS.get(save_point_id, {})
	if definition.is_empty():
		return false
	restore_party()
	story_flags[definition["flag"]] = true
	return true


func register_runtime_save_point(save_point_id: StringName, cell: Vector2i) -> void:
	_runtime_save_point_cells[save_point_id] = cell


func unregister_runtime_save_point(save_point_id: StringName) -> void:
	_runtime_save_point_cells.erase(save_point_id)


func activated_save_point_near(cell: Vector2i, radius := 2) -> Dictionary:
	var closest: Dictionary = {}
	var closest_distance := radius + 1
	for save_point_id in UNIVERSE_SAVE_POINTS:
		var definition: Dictionary = UNIVERSE_SAVE_POINTS[save_point_id]
		if not bool(story_flags.get(definition["flag"], false)):
			continue
		if bool(definition.get("streamed", false)) and not _runtime_save_point_cells.has(save_point_id):
			continue
		var anchor_cell: Vector2i = _runtime_save_point_cells.get(save_point_id, definition["cell"])
		var distance: int = abs(cell.x - anchor_cell.x) + abs(cell.y - anchor_cell.y)
		if distance <= radius and distance < closest_distance:
			var result := definition.duplicate(true)
			result["id"] = save_point_id
			result["cell"] = anchor_cell
			closest = result
			closest_distance = distance
	return closest


func revive_party_at_one() -> void:
	for character_id in party:
		var defaults := _default_vitals(character_id)
		var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
		progress["hp"] = maxi(1, int(progress.get("hp", 0)))
	state_changed.emit()


func _default_vitals(character_id: StringName) -> Vector2i:
	if character_id == &"fighter":
		return Vector2i(190, 18)
	if character_id == &"astronaut":
		return Vector2i(165, 24)
	var stats: Dictionary = recruit_catalog.get(character_id, {}).get("combat_stats", {})
	if not stats.is_empty():
		return Vector2i(int(stats.get("max_hp", 140)), int(stats.get("max_mp", 36)))
	return Vector2i(140, 36)


func _maximum_vitals(character_id: StringName) -> Vector2i:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var level := int(progress.get("level", 1))
	var bonuses: Dictionary = actor_build(character_id)["bonuses"]
	var stats: Dictionary = recruit_catalog.get(character_id, {}).get("combat_stats", {})
	var hp_growth := int(stats.get("hp_growth", 22 if character_id == &"fighter" else (18 if character_id == &"astronaut" else 14)))
	var mp_growth := int(stats.get("mp_growth", 2 if character_id == &"fighter" else (3 if character_id == &"astronaut" else 5)))
	return Vector2i(defaults.x + (level - 1) * hp_growth + int(bonuses[&"max_hp"]), defaults.y + (level - 1) * mp_growth + int(bonuses[&"max_mp"]))


func _clamp_character_vitals(character_id: StringName) -> void:
	var defaults := _default_vitals(character_id)
	var progress := ensure_character_progress(character_id, defaults.x, defaults.y)
	var maximums := _maximum_vitals(character_id)
	progress["hp"] = clampi(int(progress.get("hp", maximums.x)), 0, maximums.x)
	progress["mp"] = clampi(int(progress.get("mp", maximums.y)), 0, maximums.y)


func quest_definition(quest_id: StringName) -> Dictionary:
	return QUEST_DEFINITIONS.get(quest_id, {}).duplicate(true)


func quest_state(quest_id: StringName) -> Dictionary:
	return quest_states.get(quest_id, {}).duplicate(true)


func quest_choices(quest_id: StringName) -> Array[Dictionary]:
	var definition: Dictionary = QUEST_DEFINITIONS.get(quest_id, {})
	var runtime: Dictionary = quest_states.get(quest_id, {})
	if definition.is_empty() or runtime.is_empty():
		return []
	var selected_choice_id := StringName(runtime.get("choice_id", &""))
	var results: Array[Dictionary] = []
	for raw_choice in definition.get("choices", []):
		var choice: Dictionary = raw_choice.duplicate(true)
		choice["selected"] = StringName(choice.get("id", &"")) == selected_choice_id
		results.append(choice)
	return results


func select_quest_choice(quest_id: StringName, choice_id: StringName) -> bool:
	var definition: Dictionary = QUEST_DEFINITIONS.get(quest_id, {})
	var runtime: Dictionary = quest_states.get(quest_id, {})
	if definition.is_empty() or StringName(runtime.get("status", &"locked")) != &"active" or StringName(runtime.get("choice_id", &"")) != &"":
		return false
	var selected: Dictionary = {}
	for raw_choice in definition.get("choices", []):
		var choice: Dictionary = raw_choice
		if StringName(choice.get("id", &"")) == choice_id:
			selected = choice
			break
	if selected.is_empty():
		return false
	runtime["choice_id"] = choice_id
	runtime["choice_outcome"] = String(selected.get("outcome", ""))
	if not bool(runtime.get("choice_reward_claimed", false)):
		_grant_quest_rewards(selected.get("rewards", {}), &"quest_choice_reward", quest_id)
		runtime["choice_reward_claimed"] = true
	for raw_flag in (selected.get("story_flags", {}) as Dictionary):
		story_flags[StringName(raw_flag)] = selected["story_flags"][raw_flag]
	quest_events[StringName("quest_choice_%s" % quest_id)] = choice_id
	state_changed.emit()
	return true


func available_quest_objectives(quest_id: StringName) -> Array[Dictionary]:
	return QUEST_DIRECTOR.available_objectives(QUEST_DEFINITIONS.get(quest_id, {}), quest_states.get(quest_id, {}))


func visible_quests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for quest_id in QUEST_DEFINITIONS.keys():
		var runtime: Dictionary = quest_states.get(quest_id, {})
		if runtime.is_empty() or StringName(runtime.get("status", "locked")) == &"locked":
			continue
		var entry: Dictionary = QUEST_DEFINITIONS[quest_id].duplicate(true)
		entry["id"] = StringName(quest_id)
		entry["state"] = runtime.duplicate(true)
		results.append(entry)
	return results


func set_tracked_quest(quest_id: StringName) -> bool:
	var runtime: Dictionary = quest_states.get(quest_id, {})
	if runtime.is_empty() or StringName(runtime.get("status", "locked")) == &"locked":
		return false
	if tracked_quest == quest_id:
		return true
	tracked_quest = quest_id
	state_changed.emit()
	return true


func tracked_objective() -> Dictionary:
	var definition: Dictionary = QUEST_DEFINITIONS.get(tracked_quest, {})
	var runtime: Dictionary = quest_states.get(tracked_quest, {})
	if definition.is_empty() or runtime.is_empty():
		return {}
	var steps: Array = definition.get("steps", [])
	var step_index := int(runtime.get("step", 0))
	var status := StringName(runtime.get("status", "locked"))
	var objective := "Quest complete."
	var active_tree_objectives: Array[Dictionary] = QUEST_DIRECTOR.available_objectives(definition, runtime)
	if status == &"active" and not active_tree_objectives.is_empty():
		objective = String(active_tree_objectives[0].get("text", "Continue the quest."))
	elif status == &"active" and step_index < steps.size():
		objective = String(steps[step_index].get("text", "Continue the quest."))
	return {
		"id": tracked_quest,
		"title": definition.get("title", tracked_quest),
		"objective": objective,
		"icon": definition.get("icon", "dfgui_icon-info.png"),
		"category": definition.get("category", &"side"),
		"status": status,
		"step": step_index,
		"total_steps": steps.size(),
		"objective_tree": active_tree_objectives,
	}


func mark_story_flag(flag: StringName, value := true) -> bool:
	if story_flags.get(flag, false) == value:
		return false
	story_flags[flag] = value
	state_changed.emit()
	return true


func record_quest_event(event_id: StringName, value: Variant = true) -> void:
	quest_events[event_id] = value
	state_changed.emit()


func sync_quests(notify := true) -> bool:
	if _syncing_quests:
		return false
	_syncing_quests = true
	var changed := false
	for _pass in range(QUEST_DEFINITIONS.size() + 1):
		var pass_changed := false
		for quest_id in QUEST_DEFINITIONS.keys():
			var definition: Dictionary = QUEST_DEFINITIONS[quest_id]
			var runtime: Dictionary = quest_states[quest_id]
			if StringName(runtime.get("status", "locked")) == &"locked" and _quest_unlock_requirements_met(definition):
				runtime["status"] = &"active"
				runtime["discovered"] = true
				pass_changed = true
				changed = true
			if StringName(runtime.get("status", "locked")) != &"active":
				continue
			var steps: Array = definition.get("steps", [])
			while int(runtime.get("step", 0)) < steps.size() and _quest_condition_met(steps[int(runtime["step"])].get("condition", {})):
				runtime["step"] = int(runtime.get("step", 0)) + 1
				pass_changed = true
				changed = true
				quest_advanced.emit(StringName(quest_id), int(runtime["step"]))
			var tree_result := QUEST_DIRECTOR.synchronize(definition, runtime, Callable(self, "_quest_condition_met"))
			if bool(tree_result.get("changed", false)):
				pass_changed = true
				changed = true
			var tree_is_complete: bool = definition.get("objectives", []).is_empty() or bool(tree_result.get("complete", false))
			if int(runtime.get("step", 0)) >= steps.size() and tree_is_complete:
				runtime["status"] = &"complete"
				runtime["completed_at"] = _unix_time()
				if not bool(runtime.get("reward_claimed", false)):
					_grant_quest_rewards(definition.get("rewards", {}), &"quest_reward", StringName(quest_id))
					runtime["reward_claimed"] = true
				quest_completed.emit(StringName(quest_id))
				pass_changed = true
				changed = true
		if not pass_changed:
			break
	var tracked_runtime: Dictionary = quest_states.get(tracked_quest, {})
	if tracked_quest == &"" or tracked_runtime.is_empty() or StringName(tracked_runtime.get("status", "")) == &"complete":
		var next_tracked := _next_active_quest()
		if next_tracked != tracked_quest:
			tracked_quest = next_tracked
			changed = true
	_syncing_quests = false
	if changed and notify:
		state_changed.emit()
	return changed


func _initialize_quest_states() -> void:
	for quest_id in QUEST_DEFINITIONS.keys():
		if not quest_states.has(quest_id):
			quest_states[quest_id] = {"status": &"locked", "step": 0, "discovered": false, "reward_claimed": false, "completed_at": 0, "objective_states": {}, "choice_id": &"", "choice_outcome": "", "choice_reward_claimed": false}
		else:
			var runtime: Dictionary = quest_states[quest_id]
			runtime["status"] = StringName(runtime.get("status", "locked"))
			runtime["step"] = int(runtime.get("step", 0))
			runtime["discovered"] = bool(runtime.get("discovered", false))
			runtime["reward_claimed"] = bool(runtime.get("reward_claimed", false))
			runtime["objective_states"] = runtime.get("objective_states", {})
			runtime["choice_id"] = StringName(runtime.get("choice_id", &""))
			runtime["choice_outcome"] = String(runtime.get("choice_outcome", ""))
			runtime["choice_reward_claimed"] = bool(runtime.get("choice_reward_claimed", false))
	if tracked_quest == &"":
		tracked_quest = &"a_fault_in_reality"
	sync_quests(false)


func _quest_unlock_requirements_met(definition: Dictionary) -> bool:
	if bool(definition.get("starts_active", false)):
		return true
	for required_quest in definition.get("requires_quests", []):
		if StringName(quest_states.get(StringName(required_quest), {}).get("status", "locked")) != &"complete":
			return false
	var any_required_quests: Array = definition.get("requires_any_quests", [])
	if not any_required_quests.is_empty():
		var any_quest_complete := false
		for required_quest in any_required_quests:
			if StringName(quest_states.get(StringName(required_quest), {}).get("status", "locked")) == &"complete":
				any_quest_complete = true
				break
		if not any_quest_complete:
			return false
	for required_flag in definition.get("requires_flags", []):
		if not bool(story_flags.get(StringName(required_flag), false)):
			return false
	return true


func _quest_condition_met(condition: Dictionary) -> bool:
	var condition_type := StringName(condition.get("type", ""))
	var condition_id: Variant = condition.get("id", "")
	match condition_type:
		&"all":
			for nested_condition in condition.get("conditions", []):
				if not _quest_condition_met(nested_condition):
					return false
			return true
		&"any":
			for nested_condition in condition.get("conditions", []):
				if _quest_condition_met(nested_condition):
					return true
			return false
		&"event":
			if not quest_events.has(StringName(condition_id)):
				return false
			return quest_events[StringName(condition_id)] == condition.get("equals", true)
		&"story_flag":
			return bool(story_flags.get(StringName(condition_id), false))
		&"facility_built":
			return String(condition_id) in built_facilities.values()
		&"recruit_hired":
			return StringName(recruit_status.get(StringName(condition_id), &"undiscovered")) not in [&"undiscovered", &"available"]
		&"party_has":
			return StringName(condition_id) in party
		&"facility_assignment_count":
			return facility_assignments.size() >= int(condition.get("amount", 1))
		&"completed_job_count":
			var total := 0
			for count in completed_facility_jobs.values():
				total += int(count)
			return total >= int(condition.get("amount", 1))
		&"invention_owned":
			return StringName(condition_id) in owned_inventions
		&"job_completed":
			return int(completed_facility_jobs.get(StringName(condition_id), 0)) > 0
		&"choice_selected":
			var choice_quest_id := StringName(condition.get("quest_id", condition_id))
			var selected_choice_id := StringName(quest_states.get(choice_quest_id, {}).get("choice_id", &""))
			var expected_choice_id := StringName(condition.get("choice_id", &""))
			return selected_choice_id != &"" and (expected_choice_id == &"" or selected_choice_id == expected_choice_id)
	return false


func _grant_quest_rewards(rewards: Dictionary, reason: StringName = &"quest_reward", source_id: StringName = &"quest") -> void:
	adjust_duckets(int(rewards.get("duckets", 0)), reason, source_id, false)
	for item_id in rewards.get("items", {}).keys():
		var normalized_id := StringName(item_id)
		add_item(normalized_id, int(rewards["items"][item_id]), false, reason, source_id)
	var party_experience := int(rewards.get("party_experience", 0))
	if party_experience > 0:
		grant_expedition_experience(party_experience)


func _next_active_quest() -> StringName:
	for category in [&"main", &"side", &"hidden"]:
		for quest_id in QUEST_DEFINITIONS.keys():
			if StringName(QUEST_DEFINITIONS[quest_id].get("category", "side")) == category and StringName(quest_states[quest_id].get("status", "locked")) == &"active":
				return StringName(quest_id)
	return &""


func _on_internal_state_changed() -> void:
	sync_quests(false)


func facility_definition(facility_name: String) -> Dictionary:
	return FACILITY_DEFINITIONS.get(facility_name, {}).duplicate(true)


func visible_facility_upgrades(facility_name: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for upgrade_id in FACILITY_UPGRADE_DEFINITIONS:
		var definition: Dictionary = FACILITY_UPGRADE_DEFINITIONS[upgrade_id]
		if String(definition.get("facility", "")) == facility_name and _requirements_met(definition):
			var result := definition.duplicate(true)
			result["id"] = StringName(upgrade_id)
			results.append(result)
	return results


func facility_has_upgrade(facility_name: String, upgrade_id: StringName = &"") -> bool:
	var owned: Array = facility_upgrades.get(facility_name, [])
	if upgrade_id == &"":
		return not owned.is_empty()
	return upgrade_id in owned


func facility_upgrade_availability(upgrade_id: StringName) -> Dictionary:
	var definition: Dictionary = FACILITY_UPGRADE_DEFINITIONS.get(upgrade_id, {})
	if definition.is_empty():
		return {"allowed": false, "reason": "Unknown facility upgrade."}
	var facility_name := String(definition.get("facility", ""))
	if facility_name not in built_facilities.values():
		return {"allowed": false, "reason": "Build %s first." % facility_name}
	if facility_has_upgrade(facility_name, upgrade_id):
		return {"allowed": false, "reason": "Already upgraded."}
	if not _requirements_met(definition):
		return {"allowed": false, "reason": "The relevant discovery has not been made."}
	if duckets < int(definition.get("duckets", 0)):
		return {"allowed": false, "reason": "Not enough Duckets."}
	for item_id in definition.get("items", {}).keys():
		if int(inventory.get(StringName(item_id), 0)) < int(definition["items"][item_id]):
			return {"allowed": false, "reason": "Missing %s." % String(item_id).replace("_", " ").capitalize()}
	return {"allowed": true, "reason": "Ready to upgrade."}


func upgrade_facility(upgrade_id: StringName) -> bool:
	if not bool(facility_upgrade_availability(upgrade_id).get("allowed", false)):
		return false
	var definition: Dictionary = FACILITY_UPGRADE_DEFINITIONS[upgrade_id]
	var facility_name := String(definition["facility"])
	adjust_duckets(-int(definition.get("duckets", 0)), &"facility_upgrade", upgrade_id, false)
	for item_id in definition.get("items", {}).keys():
		consume_item(StringName(item_id), int(definition["items"][item_id]), &"facility_upgrade", upgrade_id)
	if not facility_upgrades.has(facility_name):
		facility_upgrades[facility_name] = []
	facility_upgrades[facility_name].append(upgrade_id)
	story_flags[StringName("facility_%s_upgraded" % facility_name.to_snake_case())] = true
	state_changed.emit()
	return true


func facility_upgrade_modifiers(facility_name: String) -> Dictionary:
	var result := {"service_discount": 0.0, "job_duration_multiplier": 1.0, "job_quality_bonus": 0}
	for upgrade_id in facility_upgrades.get(facility_name, []):
		var definition: Dictionary = FACILITY_UPGRADE_DEFINITIONS.get(StringName(upgrade_id), {})
		result["service_discount"] = float(result["service_discount"]) + float(definition.get("service_discount", 0.0))
		result["job_duration_multiplier"] = float(result["job_duration_multiplier"]) * float(definition.get("job_duration_multiplier", 1.0))
		result["job_quality_bonus"] = int(result["job_quality_bonus"]) + int(definition.get("job_quality_bonus", 0))
	return result


func visible_facility_jobs(facility_name: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for job in FACILITY_DEFINITIONS.get(facility_name, {}).get("jobs", []):
		if _requirements_met(job):
			results.append(job.duplicate(true))
	return results


func facility_job_definition(facility_name: String, job_id: StringName) -> Dictionary:
	for job in FACILITY_DEFINITIONS.get(facility_name, {}).get("jobs", []):
		if StringName(job.get("id", "")) == job_id:
			return job.duplicate(true)
	return {}


func visible_inventions(facility_name: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for invention_id in INVENTION_DEFINITIONS.keys():
		var definition: Dictionary = INVENTION_DEFINITIONS[invention_id]
		if String(definition.get("facility", "")) == facility_name and _requirements_met(definition):
			var result := definition.duplicate(true)
			result["id"] = StringName(invention_id)
			results.append(result)
	return results


func invention_category(invention_id: StringName) -> StringName:
	return &"expedition_tool" if EXPEDITION_TOOL_CONTRACTS.has(invention_id) else &"facility_upgrade"


func expedition_tool_contract(invention_id: StringName) -> Dictionary:
	return EXPEDITION_TOOL_CONTRACTS.get(invention_id, {}).duplicate(true)


func expedition_invention_actions() -> Array[StringName]:
	var actions: Array[StringName] = []
	for invention_id in owned_inventions:
		var contract := expedition_tool_contract(invention_id)
		var action_id := StringName(contract.get("battle_action", &""))
		if action_id != &"" and action_id not in actions:
			actions.append(action_id)
	return actions


func job_supports_invention(facility_name: String, job_id: StringName, invention_id: StringName) -> bool:
	var job := facility_job_definition(facility_name, job_id)
	if StringName(job.get("boost_invention", &"")) == invention_id:
		return true
	for raw_invention_id in job.get("boost_inventions", []):
		if StringName(raw_invention_id) == invention_id:
			return true
	return false


func facility_worker(facility_name: String) -> StringName:
	return StringName(facility_assignments.get(facility_name, ""))


func service_stock(facility_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_item_id in SERVICE_STOCK.get(facility_name, []):
		var item_id := StringName(raw_item_id)
		var entry: Dictionary = SERVICE_ITEM_CATALOG.get(item_id, {}).duplicate(true)
		if entry.is_empty():
			continue
		entry["id"] = item_id
		entry["price"] = service_item_price(facility_name, item_id)
		result.append(entry)
	return result


func service_discount(facility_name: String) -> float:
	return minf(0.30, (0.15 if facility_worker(facility_name) != &"" else 0.0) + float(facility_upgrade_modifiers(facility_name).get("service_discount", 0.0)))


func cafe_expedition_meal_cost() -> int:
	return maxi(1, int(ceil(14.0 * (1.0 - service_discount("Cafe")))))


func prepare_cafe_expedition_meal() -> bool:
	if not facility_has_upgrade("Cafe", &"cafe_hearth_exchange") or expedition_meal_charges > 0:
		return false
	var cost := cafe_expedition_meal_cost()
	if duckets < cost:
		return false
	adjust_duckets(-cost, &"cafe_expedition_meal", &"Cafe", false)
	expedition_meal_charges = 1
	state_changed.emit()
	return true


func service_item_price(facility_name: String, item_id: StringName) -> int:
	if item_id not in SERVICE_STOCK.get(facility_name, []):
		return 0
	var base_price := int(SERVICE_ITEM_CATALOG.get(item_id, {}).get("price", 0))
	return maxi(1, int(ceil(float(base_price) * (1.0 - service_discount(facility_name)))))


func purchase_service_item(facility_name: String, item_id: StringName, quantity := 1) -> bool:
	quantity = maxi(1, quantity)
	var unit_price := service_item_price(facility_name, item_id)
	var total := unit_price * quantity
	if unit_price <= 0 or duckets < total:
		return false
	adjust_duckets(-total, &"service_purchase", StringName(facility_name), false)
	add_item(item_id, quantity, false, &"service_purchase", StringName(facility_name))
	story_flags[&"town_service_purchase_made"] = true
	story_flags[&"town_service_purchase_count"] = int(story_flags.get(&"town_service_purchase_count", 0)) + quantity
	state_changed.emit()
	return true


func armory_stock() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for stock_id in ARMORY_STOCK:
		var entry: Dictionary = ARMORY_STOCK[stock_id]
		if not _requirements_met(entry):
			continue
		var available := entry.duplicate(true)
		available["stock_id"] = stock_id
		available["price"] = armory_item_price(StringName(stock_id))
		result.append(available)
	return result


func armory_item_price(stock_id: StringName) -> int:
	var entry: Dictionary = ARMORY_STOCK.get(stock_id, {})
	if entry.is_empty() or not _requirements_met(entry):
		return 0
	return maxi(1, int(ceil(float(entry.get("price", 0)) * (1.0 - service_discount("Armory")))))


func purchase_armory_item(stock_id: StringName) -> Dictionary:
	var definition: Dictionary = ARMORY_STOCK.get(stock_id, {})
	var price := armory_item_price(stock_id)
	if definition.is_empty() or price <= 0 or duckets < price or "Armory" not in built_facilities.values():
		return {}
	adjust_duckets(-price, &"armory_purchase", stock_id, false)
	var purchase_count := int(story_flags.get(&"armory_purchase_count", 0)) + 1
	story_flags[&"armory_purchase_count"] = purchase_count
	story_flags[&"armory_purchase_made"] = true
	var item := definition.duplicate(true)
	item.erase("price")
	item.erase("requires_flags")
	item["instance_id"] = "armory-%s-%d" % [String(stock_id), purchase_count]
	item["display_name"] = String(item.get("base_name", stock_id))
	item["kind"] = "gear"
	item["source_pack"] = "armory"
	loot_inventory.append(item)
	state_changed.emit()
	return item.duplicate(true)


func gear_stat_totals(item: Dictionary) -> Dictionary:
	var totals := {}
	for modifier in item.get("modifiers", []):
		var stat := StringName(modifier.get("stat", ""))
		if stat != &"":
			totals[stat] = int(totals.get(stat, 0)) + int(modifier.get("value", 0))
	return totals


func gear_comparison(item: Dictionary, character_id: StringName) -> Dictionary:
	var slot := StringName(item.get("slot", ""))
	var progress: Dictionary = character_progress.get(character_id, {})
	var equipped_id := String(progress.get("equipment", {}).get(slot, ""))
	var current := loot_by_instance(equipped_id)
	var candidate_totals := gear_stat_totals(item)
	var current_totals := gear_stat_totals(current)
	var comparison := {}
	for stat in [&"attack", &"defense", &"magic", &"spirit", &"speed", &"max_hp", &"max_mp"]:
		var delta := int(candidate_totals.get(stat, 0)) - int(current_totals.get(stat, 0))
		if delta != 0:
			comparison[stat] = delta
	return comparison


func loot_owner(instance_id: String) -> StringName:
	for character_id in character_progress.keys():
		for equipped_id in character_progress[character_id].get("equipment", {}).values():
			if String(equipped_id) == instance_id:
				return StringName(character_id)
	return &""


func loot_sell_value(instance_id: String) -> int:
	var item := loot_by_instance(instance_id)
	if item.is_empty():
		return 0
	var rarity_values := {"Common": 12, "Uncommon": 24, "Rare": 50, "Epic": 100}
	var value := int(rarity_values.get(String(item.get("rarity", "Common")), 8))
	for modifier in item.get("modifiers", []):
		value += maxi(0, int(modifier.get("value", 0))) * 2
	for raw_element in (item.get("element_rates", {}) as Dictionary):
		value += maxi(0, int(round((1.0 - float(item["element_rates"][raw_element])) * 20.0)))
	return value


func sell_loot(instance_id: String) -> int:
	if loot_owner(instance_id) != &"":
		return 0
	var value := loot_sell_value(instance_id)
	if value <= 0:
		return 0
	for index in range(loot_inventory.size()):
		if String(loot_inventory[index].get("instance_id", "")) == instance_id:
			loot_inventory.remove_at(index)
			adjust_duckets(value, &"armory_sale", StringName(instance_id), false)
			story_flags[&"town_gear_sold_count"] = int(story_flags.get(&"town_gear_sold_count", 0)) + 1
			state_changed.emit()
			return value
	return 0


func can_salvage_loot(instance_id: String) -> bool:
	var item := loot_by_instance(instance_id)
	return not item.is_empty() and loot_owner(instance_id) == &"" and not _protected_gear(item)


func salvage_rewards(item: Dictionary) -> Dictionary:
	if item.is_empty() or _protected_gear(item):
		return {}
	var rewards := {&"anchor_dust": 1}
	var rarity := String(item.get("rarity", "Common"))
	if rarity in ["Uncommon", "Rare", "Epic"]:
		rewards[&"research_notes"] = 1
	if rarity == "Epic":
		rewards[&"anchor_dust"] = 2
	return rewards


func salvage_loot(instance_id: String) -> Dictionary:
	if not can_salvage_loot(instance_id):
		return {}
	var item := loot_by_instance(instance_id)
	var rewards := salvage_rewards(item)
	if rewards.is_empty():
		return {}
	for index in range(loot_inventory.size()):
		if String(loot_inventory[index].get("instance_id", "")) == instance_id:
			loot_inventory.remove_at(index)
			break
	for item_id in rewards:
		add_item(StringName(item_id), int(rewards[item_id]), false, &"armory_salvage", StringName(instance_id))
	story_flags[&"armory_salvage_count"] = int(story_flags.get(&"armory_salvage_count", 0)) + 1
	state_changed.emit()
	return {"item": item.duplicate(true), "rewards": rewards.duplicate(true)}


func armory_reforge_cost(instance_id: String) -> int:
	if not can_reforge_loot(instance_id):
		return 0
	return maxi(1, int(ceil(float(ARMORY_REFORGE_BASE_DUCKET_COST) * (1.0 - service_discount("Armory")))))


func can_reforge_loot(instance_id: String) -> bool:
	var item := loot_by_instance(instance_id)
	return not item.is_empty() and loot_owner(instance_id) == &"" and not _protected_gear(item) and not item.get("modifiers", []).is_empty() and not item.has("reforged_modifier_index")


func reforge_loot(instance_id: String, modifier_index: int) -> Dictionary:
	var cost := armory_reforge_cost(instance_id)
	if cost <= 0 or duckets < cost or int(inventory.get(&"anchor_dust", 0)) < ARMORY_REFORGE_ANCHOR_DUST_COST:
		return {}
	for index in range(loot_inventory.size()):
		var item: Dictionary = loot_inventory[index]
		if String(item.get("instance_id", "")) != instance_id:
			continue
		var modifiers: Array = item.get("modifiers", [])
		if modifier_index < 0 or modifier_index >= modifiers.size():
			return {}
		var modifier: Dictionary = modifiers[modifier_index].duplicate(true)
		var bonus := maxi(1, int(ceil(float(maxi(1, int(modifier.get("value", 0)))) * 0.35)))
		modifier["value"] = int(modifier.get("value", 0)) + bonus
		modifier["name"] = "%s Reforged" % String(modifier.get("name", ""))
		modifiers[modifier_index] = modifier
		item["modifiers"] = modifiers
		item["reforged_modifier_index"] = modifier_index
		item["reforge_bonus"] = bonus
		if not String(item.get("display_name", "")).begins_with("Refined "):
			item["display_name"] = "Refined %s" % String(item.get("display_name", item.get("base_name", "Gear")))
		loot_inventory[index] = item
		adjust_duckets(-cost, &"armory_reforge", StringName(instance_id), false)
		consume_item(&"anchor_dust", ARMORY_REFORGE_ANCHOR_DUST_COST, &"armory_reforge", StringName(instance_id))
		story_flags[&"armory_reforge_count"] = int(story_flags.get(&"armory_reforge_count", 0)) + 1
		state_changed.emit()
		return {"item": item.duplicate(true), "cost": cost, "anchor_dust": ARMORY_REFORGE_ANCHOR_DUST_COST, "modifier_index": modifier_index, "bonus": bonus}
	return {}


func _protected_gear(item: Dictionary) -> bool:
	return bool(item.get("unique", false)) or not String(item.get("unique_id", "")).is_empty()


func clinic_service_cost() -> int:
	return maxi(1, int(ceil(20.0 * (1.0 - service_discount("Clinic")))))


func use_clinic_service() -> bool:
	var cost := clinic_service_cost()
	if duckets < cost:
		return false
	adjust_duckets(-cost, &"clinic_treatment", &"Clinic", false)
	restore_party()
	story_flags[&"clinic_treatment_used"] = true
	story_flags[&"clinic_visit_count"] = int(story_flags.get(&"clinic_visit_count", 0)) + 1
	state_changed.emit()
	return true


func library_record_summary() -> Dictionary:
	var visible_count := 0
	var completed_count := 0
	var known_recruits := 0
	for quest_id in quest_states.keys():
		var status := StringName(quest_states[quest_id].get("status", &"locked"))
		if status != &"locked":
			visible_count += 1
		if status == &"complete":
			completed_count += 1
	for recruit_id in recruit_status.keys():
		if recruit_id != &"ben" and StringName(recruit_status[recruit_id]) != &"undiscovered":
			known_recruits += 1
	var stabilized_universes := int(bool(story_flags.get(&"first_universe_stabilized", false))) + int(bool(story_flags.get(&"second_universe_stabilized", false))) + int(bool(story_flags.get(&"third_universe_stabilized", false))) + int(bool(story_flags.get(&"fourth_universe_stabilized", false))) + int(bool(story_flags.get(&"fifth_universe_stabilized", false))) + int(bool(story_flags.get(&"sixth_universe_stabilized", false))) + int(bool(story_flags.get(&"seventh_universe_stabilized", false)))
	var bestiary := bestiary_summary()
	return {
		"quests_discovered": visible_count,
		"quests_completed": completed_count,
		"mansion_encounters": int(story_flags.get(&"mansion_encounter_count", 0)),
		"universes_stabilized": stabilized_universes,
		"inventions": owned_inventions.size(),
		"recruits": known_recruits,
		"bestiary_seen": int(bestiary.get("species_seen", 0)),
		"bestiary_total": int(bestiary.get("species_total", 0)),
		"monsters_defeated": int(bestiary.get("total_defeated", 0)),
	}


func worker_facility(recruit_id: StringName) -> String:
	for facility_name in facility_assignments.keys():
		if StringName(facility_assignments[facility_name]) == recruit_id:
			return String(facility_name)
	return ""


func facility_job_status(facility_name: String) -> Dictionary:
	return active_facility_jobs.get(facility_name, {}).duplicate(true)


func job_estimate(facility_name: String, job_id: StringName, ben_assist := false) -> Dictionary:
	var job := facility_job_definition(facility_name, job_id)
	if job.is_empty():
		return {}
	var worker_id := facility_worker(facility_name)
	if worker_id == &"" and ben_assist and bool(job.get("ben_can_lead", false)):
		worker_id = &"ben"
	if worker_id == &"":
		return {"allowed": false, "reason": "Assign a recruit, or have Ben lead eligible work."}
	if ben_assist and worker_id != &"ben" and not bool(job.get("ben_can_assist", false)):
		return {"allowed": false, "reason": "Ben cannot assist this assignment."}
	var required_invention := StringName(job.get("required_invention", ""))
	if required_invention != &"" and required_invention not in owned_inventions:
		return {"allowed": false, "reason": "Invent %s first." % INVENTION_DEFINITIONS.get(required_invention, {}).get("name", required_invention)}
	if bool(job.get("one_time", false)) and int(completed_facility_jobs.get(job_id, 0)) > 0:
		return {"allowed": false, "reason": "This assignment is already complete."}
	var fit := _worker_job_fit(worker_id, job)
	var duration_multiplier := 1.0 - float(fit) * 0.18
	var quality := 1 + fit
	var upgrade_modifiers := facility_upgrade_modifiers(facility_name)
	duration_multiplier *= float(upgrade_modifiers.get("job_duration_multiplier", 1.0))
	quality += int(upgrade_modifiers.get("job_quality_bonus", 0))
	if ben_assist and worker_id != &"ben":
		duration_multiplier *= 0.88
		quality += 1
	var active_inventions: Array[StringName] = []
	var boost_invention := StringName(job.get("boost_invention", ""))
	if boost_invention != &"" and boost_invention in owned_inventions:
		active_inventions.append(boost_invention)
	for raw_boost_invention in job.get("boost_inventions", []):
		var boost_id := StringName(raw_boost_invention)
		if boost_id != &"" and boost_id in owned_inventions and boost_id not in active_inventions:
			active_inventions.append(boost_id)
	var invention_active := not active_inventions.is_empty()
	if invention_active:
		duration_multiplier *= 0.82
		quality += 1
	quality = clampi(quality, 0, JOB_QUALITY_NAMES.size() - 1)
	return {
		"allowed": true,
		"worker_id": worker_id,
		"fit": fit,
		"duration_seconds": maxi(30, int(round(float(job.get("duration_seconds", 60)) * duration_multiplier))),
		"quality": quality,
		"quality_name": JOB_QUALITY_NAMES[quality],
		"ben_assist": ben_assist,
		"invention_active": invention_active,
		"active_inventions": active_inventions,
	}


func start_facility_job(facility_name: String, job_id: StringName, ben_assist := false, now_at := -1) -> bool:
	if facility_name not in built_facilities.values() or active_facility_jobs.has(facility_name):
		return false
	var visible := false
	for job in visible_facility_jobs(facility_name):
		if StringName(job.get("id", "")) == job_id:
			visible = true
			break
	if not visible:
		return false
	var estimate := job_estimate(facility_name, job_id, ben_assist)
	if not bool(estimate.get("allowed", false)):
		return false
	var started_at := _unix_time() if now_at < 0 else now_at
	active_facility_jobs[facility_name] = {
		"job_id": job_id,
		"worker_id": estimate["worker_id"],
		"ben_assist": ben_assist,
		"invention_active": estimate["invention_active"],
		"quality": estimate["quality"],
		"quality_name": estimate["quality_name"],
		"duration_seconds": estimate["duration_seconds"],
		"started_at": started_at,
		"finishes_at": started_at + int(estimate["duration_seconds"]),
		"status": &"running",
	}
	state_changed.emit()
	return true


func refresh_facility_jobs(now_at := -1) -> bool:
	var now := _unix_time() if now_at < 0 else now_at
	var changed := false
	for facility_name in active_facility_jobs.keys():
		var active: Dictionary = active_facility_jobs[facility_name]
		if StringName(active.get("status", "running")) == &"running" and now >= int(active.get("finishes_at", now + 1)):
			active["status"] = &"ready"
			changed = true
			facility_job_ready.emit(String(facility_name), StringName(active.get("job_id", "")))
	if changed:
		state_changed.emit()
	return changed


func collect_facility_job(facility_name: String, now_at := -1) -> Dictionary:
	refresh_facility_jobs(now_at)
	var active: Dictionary = active_facility_jobs.get(facility_name, {})
	if active.is_empty() or StringName(active.get("status", "")) != &"ready":
		return {}
	var job_id := StringName(active.get("job_id", ""))
	var job := facility_job_definition(facility_name, job_id)
	if job.is_empty():
		return {}
	var quality := int(active.get("quality", 1))
	var earned_duckets := int(round(float(job.get("duckets", 0)) * (1.0 + maxf(0.0, float(quality - 1)) * 0.2)))
	adjust_duckets(earned_duckets, &"facility_job", job_id, false)
	var earned_items := {}
	for item_id in job.get("items", {}).keys():
		var quantity := int(job["items"][item_id]) + maxi(0, (quality - 1) / 2)
		add_item(StringName(item_id), quantity, false, &"facility_job", job_id)
		earned_items[StringName(item_id)] = quantity
	var earned_experience := int(job.get("experience", 0)) + maxi(0, quality - 1) * 5
	var worker_id := StringName(active.get("worker_id", ""))
	var level_ups: Array[int] = []
	if worker_id != &"":
		var rested_experience := _rested_catch_up_experience(worker_id, earned_experience)
		level_ups = grant_experience(worker_id, earned_experience + rested_experience)
		_enforce_hired_progression_floor()
	completed_facility_jobs[job_id] = int(completed_facility_jobs.get(job_id, 0)) + 1
	var completion_flag := StringName(job.get("completion_flag", ""))
	if completion_flag != &"":
		story_flags[completion_flag] = true
	active_facility_jobs.erase(facility_name)
	state_changed.emit()
	return {
		"facility": facility_name,
		"job_id": job_id,
		"job_name": job.get("name", job_id),
		"worker_id": worker_id,
		"quality": quality,
		"quality_name": active.get("quality_name", JOB_QUALITY_NAMES[quality]),
		"duckets": earned_duckets,
		"items": earned_items,
		"experience": earned_experience,
		"level_ups": level_ups,
	}


func cancel_facility_job(facility_name: String) -> bool:
	if not active_facility_jobs.has(facility_name):
		return false
	active_facility_jobs.erase(facility_name)
	state_changed.emit()
	return true


func invention_availability(invention_id: StringName) -> Dictionary:
	var definition: Dictionary = INVENTION_DEFINITIONS.get(invention_id, {})
	if definition.is_empty():
		return {"allowed": false, "reason": "Unknown invention."}
	if invention_id in owned_inventions:
		return {"allowed": false, "reason": "Already invented."}
	if not _requirements_met(definition):
		return {"allowed": false, "reason": "The relevant discovery has not been made."}
	if int(definition.get("duckets", 0)) > duckets:
		return {"allowed": false, "reason": "Not enough Duckets."}
	for item_id in definition.get("items", {}).keys():
		if int(inventory.get(StringName(item_id), 0)) < int(definition["items"][item_id]):
			return {"allowed": false, "reason": "Missing %s." % String(item_id).replace("_", " ").capitalize()}
	return {"allowed": true, "reason": "Ready to invent."}


func craft_invention(invention_id: StringName) -> bool:
	if not bool(invention_availability(invention_id).get("allowed", false)):
		return false
	var definition: Dictionary = INVENTION_DEFINITIONS[invention_id]
	adjust_duckets(-int(definition.get("duckets", 0)), &"invention_craft", invention_id, false)
	for item_id in definition.get("items", {}).keys():
		consume_item(StringName(item_id), int(definition["items"][item_id]), &"invention_craft", invention_id)
	owned_inventions.append(invention_id)
	state_changed.emit()
	return true


func release_facility_worker(facility_name: String) -> bool:
	if active_facility_jobs.has(facility_name):
		return false
	var recruit_id := facility_worker(facility_name)
	if recruit_id == &"":
		return false
	facility_assignments.erase(facility_name)
	recruit_status[recruit_id] = &"reserve"
	recruit_status_changed.emit(recruit_id, &"reserve")
	state_changed.emit()
	return true


func _worker_job_fit(worker_id: StringName, job: Dictionary) -> int:
	var recruit: Dictionary = recruit_catalog.get(worker_id, {})
	var primary: Array = recruit.get("work_specialties", [])
	var adjacent: Array = recruit.get("work_adjacent", [])
	var fit := 0
	for skill in job.get("preferred_skills", []):
		var skill_id := StringName(skill)
		if skill_id in primary:
			fit = maxi(fit, 2)
		elif skill_id in adjacent:
			fit = maxi(fit, 1)
	return fit


func _requirements_met(definition: Dictionary) -> bool:
	for flag in definition.get("requires_flags", []):
		if not bool(story_flags.get(StringName(flag), false)):
			return false
	return true


func _unix_time() -> int:
	return int(Time.get_unix_time_from_system())


func universe_definition(universe_id: StringName) -> Dictionary:
	return UNIVERSE_DEFINITIONS.get(universe_id, {}).duplicate(true)


func anchored_universe_at(plot_index: int) -> StringName:
	return StringName(universe_anchors.get(plot_index, &""))


func stabilized_universe_count() -> int:
	var total := 0
	for flag in [&"haunted_mansion_scenario_complete", &"asterion_station_complete", &"primeval_scenario_complete", &"helios_scenario_complete", &"frosthold_scenario_complete", &"moonpetal_scenario_complete", &"empyreal_scenario_complete"]:
		if bool(story_flags.get(flag, false)):
			total += 1
	return total


func town_state_overlay() -> Dictionary:
	var state_id: StringName = &"survey"
	var stabilized := stabilized_universe_count()
	if stabilized >= 7 or bool(story_flags.get(&"empyreal_scenario_complete", false)):
		state_id = &"finale"
	elif stabilized >= 3:
		state_id = &"multiversal"
	elif stabilized >= 1:
		state_id = &"early_anchors"
	elif built_facilities.size() >= 4:
		state_id = &"founding"
	var overlay: Dictionary = TOWN_STATE_OVERLAYS[state_id].duplicate(true)
	overlay["id"] = state_id
	overlay["stabilized_universes"] = stabilized
	return overlay


func available_universe_anchors() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for raw_universe_id in UNIVERSE_DEFINITIONS.keys():
		var universe_id := StringName(raw_universe_id)
		if not _universe_anchor_requirements_met(universe_id):
			continue
		var entry: Dictionary = UNIVERSE_DEFINITIONS[universe_id].duplicate(true)
		entry["id"] = universe_id
		available.append(entry)
	return available


func anchor_universe(plot_index: int, universe_id: StringName) -> bool:
	if not _universe_anchor_requirements_met(universe_id):
		return false
	var definition: Dictionary = UNIVERSE_DEFINITIONS[universe_id]
	return build_facility(plot_index, String(definition.get("building", "")), universe_id)


func _universe_anchor_requirements_met(universe_id: StringName) -> bool:
	var definition: Dictionary = UNIVERSE_DEFINITIONS.get(universe_id, {})
	if definition.is_empty() or universe_id in universe_anchors.values():
		return false
	var building := String(definition.get("building", ""))
	if building.is_empty() or building in built_facilities.values():
		return false
	for raw_flag in definition.get("required_flags", []):
		if not bool(story_flags.get(StringName(raw_flag), false)):
			return false
	var any_flags: Array = definition.get("required_any_flags", [])
	if not any_flags.is_empty():
		var any_flag_met := false
		for raw_flag in any_flags:
			if bool(story_flags.get(StringName(raw_flag), false)):
				any_flag_met = true
				break
		if not any_flag_met:
			return false
	for raw_recruit_id in definition.get("required_recruits", []):
		var recruit_id := StringName(raw_recruit_id)
		if StringName(recruit_status.get(recruit_id, &"undiscovered")) in [&"undiscovered", &"available"]:
			return false
	return true


func build_facility(plot_index: int, facility_name: String, universe_id: StringName = &"") -> bool:
	if built_facilities.has(plot_index) or facility_name in built_facilities.values():
		return false
	if universe_id != &"":
		var universe: Dictionary = UNIVERSE_DEFINITIONS.get(universe_id, {})
		if universe.is_empty() or String(universe.get("building", "")) != facility_name or universe_id in universe_anchors.values():
			return false
	else:
		# Version-11 callers and focused tests built the two authored anchors by
		# facade name. Preserve that API while recording the explicit destination.
		for raw_universe_id in UNIVERSE_DEFINITIONS.keys():
			if String(UNIVERSE_DEFINITIONS[raw_universe_id].get("building", "")) == facility_name:
				universe_id = StringName(raw_universe_id)
				break
	built_facilities[plot_index] = facility_name
	if universe_id != &"":
		universe_anchors[plot_index] = universe_id
		var anchor_flag := StringName(UNIVERSE_DEFINITIONS[universe_id].get("anchor_flag", &""))
		if anchor_flag != &"":
			story_flags[anchor_flag] = true
	if built_facilities.size() >= 3:
		story_flags[&"town_foundations_complete"] = true
		discover_recruit(&"fighter")
	facility_built.emit(plot_index, facility_name)
	if universe_id != &"":
		universe_anchored.emit(plot_index, universe_id)
	state_changed.emit()
	return true


func discover_recruit(recruit_id: StringName) -> bool:
	if not recruit_catalog.has(recruit_id) or recruit_status.get(recruit_id, &"undiscovered") != &"undiscovered":
		return false
	recruit_status[recruit_id] = &"available"
	recruit_status_changed.emit(recruit_id, &"available")
	state_changed.emit()
	return true


func hire_recruit(recruit_id: StringName) -> bool:
	if recruit_status.get(recruit_id, &"undiscovered") != &"available":
		return false
	recruit_status[recruit_id] = &"reserve"
	_raise_character_to_level(recruit_id, maxi(progression_chapter_floor(), active_party_median_level() - NEW_HIRE_LEVEL_GAP))
	recruit_status_changed.emit(recruit_id, &"reserve")
	state_changed.emit()
	return true


func destination_party_requirements(destination_id: StringName) -> Array[StringName]:
	var results: Array[StringName] = []
	for recruit_id in SCENARIO_PARTY_REQUIREMENTS.get(destination_id, []):
		results.append(StringName(recruit_id))
	return results


func missing_destination_party_members(destination_id: StringName) -> Array[StringName]:
	var missing: Array[StringName] = []
	for recruit_id in destination_party_requirements(destination_id):
		if recruit_id not in party:
			missing.append(recruit_id)
	return missing


func active_party_has(recruit_id: StringName) -> bool:
	return recruit_id in party


func active_party_members_with_skill(skill: StringName, include_adjacent := true) -> Array[StringName]:
	var matches: Array[StringName] = []
	for recruit_id in party:
		if recruit_id == &"ben":
			continue
		var recruit: Dictionary = recruit_catalog.get(recruit_id, {})
		if skill in recruit.get("work_specialties", []):
			matches.append(recruit_id)
		elif include_adjacent and skill in recruit.get("work_adjacent", []):
			matches.append(recruit_id)
	return matches


func field_specialist_result(task_id: StringName) -> Dictionary:
	var definition: Dictionary = FIELD_SPECIALIST_TASKS.get(task_id, {})
	if definition.is_empty():
		return {"available": false, "task_id": task_id, "reason": &"unknown_task"}
	for raw_recruit_id in definition.get("preferred_recruits", []):
		var recruit_id := StringName(raw_recruit_id)
		if active_party_has(recruit_id):
			return _field_specialist_result(task_id, recruit_id, &"signature", 3)
	for raw_skill in definition.get("preferred_skills", []):
		var skill := StringName(raw_skill)
		for recruit_id in active_party_members_with_skill(skill, false):
			return _field_specialist_result(task_id, recruit_id, &"specialty", 2, skill)
	for raw_skill in definition.get("preferred_skills", []):
		var skill := StringName(raw_skill)
		for recruit_id in active_party_members_with_skill(skill, true):
			var recruit: Dictionary = recruit_catalog.get(recruit_id, {})
			if skill in recruit.get("work_adjacent", []):
				return _field_specialist_result(task_id, recruit_id, &"adjacent", 1, skill)
	return {
		"available": false,
		"task_id": task_id,
		"label": String(definition.get("label", "Specialist task")),
		"claimed": bool(story_flags.get(_field_specialist_flag(task_id), false)),
		"reason": &"no_active_specialist",
	}


func claim_field_specialist_assist(task_id: StringName) -> Dictionary:
	var result := field_specialist_result(task_id)
	result["granted"] = false
	if not bool(result.get("available", false)):
		return result
	var claimed_flag := _field_specialist_flag(task_id)
	if bool(story_flags.get(claimed_flag, false)):
		result["claimed"] = true
		return result
	var definition: Dictionary = FIELD_SPECIALIST_TASKS.get(task_id, {})
	var earned_duckets := int(definition.get("duckets", 0))
	adjust_duckets(earned_duckets, &"field_specialist_assist", task_id, false)
	var earned_items: Dictionary = definition.get("items", {}).duplicate(true)
	for raw_item_id in earned_items.keys():
		add_item(StringName(raw_item_id), int(earned_items[raw_item_id]), false, &"field_specialist_assist", task_id)
	story_flags[claimed_flag] = true
	story_flags[&"field_specialist_assist_count"] = int(story_flags.get(&"field_specialist_assist_count", 0)) + 1
	var recruit_id := StringName(result.get("recruit_id", &""))
	if recruit_id != &"":
		var recruit_flag := StringName("field_assists_%s" % String(recruit_id))
		story_flags[recruit_flag] = int(story_flags.get(recruit_flag, 0)) + 1
	result["claimed"] = true
	result["granted"] = true
	result["duckets"] = earned_duckets
	result["items"] = earned_items
	return result


func field_specialist_reward_text(result: Dictionary) -> String:
	if not bool(result.get("granted", false)):
		return ""
	var rewards: Array[String] = []
	var earned_duckets := int(result.get("duckets", 0))
	if earned_duckets > 0:
		rewards.append("%d Duckets" % earned_duckets)
	for raw_item_id in result.get("items", {}).keys():
		var quantity := int(result["items"][raw_item_id])
		var item_name := String(raw_item_id).replace("_", " ").capitalize()
		rewards.append("%d %s" % [quantity, item_name] if quantity != 1 else item_name)
	return "Specialist assist — %s recovered %s." % [String(result.get("name", "A party member")), ", ".join(rewards)]


func field_specialist_hint(task_id: StringName) -> String:
	var definition: Dictionary = FIELD_SPECIALIST_TASKS.get(task_id, {})
	if definition.is_empty() or bool(story_flags.get(_field_specialist_flag(task_id), false)):
		return ""
	var names: Array[String] = []
	for raw_recruit_id in definition.get("preferred_recruits", []):
		var recruit: Dictionary = recruit_catalog.get(StringName(raw_recruit_id), {})
		var recruit_name := String(recruit.get("name", ""))
		if not recruit_name.is_empty():
			names.append(recruit_name)
	return "Party note: return with %s active to perform a specialist assist." % ", ".join(names)


func _field_specialist_result(task_id: StringName, recruit_id: StringName, match_kind: StringName, quality: int, skill: StringName = &"") -> Dictionary:
	var definition: Dictionary = FIELD_SPECIALIST_TASKS.get(task_id, {})
	return {
		"available": true,
		"task_id": task_id,
		"label": String(definition.get("label", "Specialist task")),
		"recruit_id": recruit_id,
		"name": String(recruit_catalog.get(recruit_id, {}).get("name", String(recruit_id))),
		"match_kind": match_kind,
		"skill": skill,
		"quality": quality,
		"claimed": bool(story_flags.get(_field_specialist_flag(task_id), false)),
	}


func _field_specialist_flag(task_id: StringName) -> StringName:
	return StringName("field_assist_%s_claimed" % String(task_id))


func active_required_party_members() -> Array[StringName]:
	if bool(story_flags.get(&"mansion_entered", false)) and not bool(story_flags.get(&"haunted_mansion_scenario_complete", false)):
		return destination_party_requirements(&"haunted_mansion")
	return []


func can_remove_from_party(recruit_id: StringName) -> bool:
	return recruit_id != &"ben" and recruit_id in party and recruit_id not in active_required_party_members()


func formation_for(recruit_id: StringName) -> StringName:
	return StringName(party_formation.get(recruit_id, &"back" if recruit_id == &"ben" else &"front"))


func formation_row_count(row: StringName, exclude_id: StringName = &"") -> int:
	var count := 0
	for recruit_id in party:
		if recruit_id != exclude_id and formation_for(recruit_id) == row:
			count += 1
	return count


func set_party_formation(recruit_id: StringName, row: StringName) -> bool:
	if recruit_id not in party or row not in FORMATION_ROWS or formation_for(recruit_id) == row:
		return false
	if formation_row_count(row, recruit_id) >= FORMATION_ROW_LIMIT:
		return false
	party_formation[recruit_id] = row
	party_changed.emit()
	state_changed.emit()
	return true


func move_party_member(recruit_id: StringName, direction: int) -> bool:
	if recruit_id == &"ben" or recruit_id not in party or direction == 0:
		return false
	var old_index := party.find(recruit_id)
	var new_index := clampi(old_index + signi(direction), 1, party.size() - 1)
	if old_index == new_index:
		return false
	var swap_id := party[new_index]
	party[new_index] = recruit_id
	party[old_index] = swap_id
	party_changed.emit()
	state_changed.emit()
	return true


func _ensure_party_formation(recruit_id: StringName) -> void:
	var preferred := formation_for(recruit_id)
	if formation_row_count(preferred, recruit_id) >= FORMATION_ROW_LIMIT:
		preferred = &"back" if preferred == &"front" else &"front"
	if formation_row_count(preferred, recruit_id) >= FORMATION_ROW_LIMIT:
		preferred = &"front"
	party_formation[recruit_id] = preferred


func add_to_party(recruit_id: StringName) -> bool:
	if recruit_id in party or party.size() >= PARTY_LIMIT:
		return false
	if recruit_status.get(recruit_id, &"undiscovered") not in [&"reserve", &"staffed"]:
		return false
	var staffed_at := worker_facility(recruit_id)
	if not staffed_at.is_empty() and active_facility_jobs.has(staffed_at):
		return false
	_remove_assignment(recruit_id)
	party.append(recruit_id)
	_ensure_party_formation(recruit_id)
	recruit_status[recruit_id] = &"party"
	recruit_status_changed.emit(recruit_id, &"party")
	party_changed.emit()
	state_changed.emit()
	return true


func move_to_reserve(recruit_id: StringName) -> bool:
	if not can_remove_from_party(recruit_id):
		return false
	party.erase(recruit_id)
	recruit_status[recruit_id] = &"reserve"
	recruit_status_changed.emit(recruit_id, &"reserve")
	party_changed.emit()
	state_changed.emit()
	return true


func assign_to_facility(recruit_id: StringName, facility_name: String) -> bool:
	if recruit_id == &"ben" or recruit_status.get(recruit_id, &"undiscovered") not in [&"party", &"reserve", &"staffed"]:
		return false
	if facility_name not in built_facilities.values():
		return false
	if recruit_id in party and not can_remove_from_party(recruit_id):
		return false
	if active_facility_jobs.has(facility_name):
		return false
	var current_worker := facility_worker(facility_name)
	if current_worker != &"" and current_worker != recruit_id:
		return false
	var old_facility := worker_facility(recruit_id)
	if not old_facility.is_empty() and active_facility_jobs.has(old_facility):
		return false
	party.erase(recruit_id)
	_remove_assignment(recruit_id)
	facility_assignments[facility_name] = recruit_id
	recruit_status[recruit_id] = &"staffed"
	recruit_status_changed.emit(recruit_id, &"staffed")
	party_changed.emit()
	state_changed.emit()
	return true


func _remove_assignment(recruit_id: StringName) -> void:
	for facility_name in facility_assignments.keys():
		if facility_assignments[facility_name] == recruit_id:
			facility_assignments.erase(facility_name)
			return


func save_game(path := "") -> Error:
	var resolved_path := path
	if resolved_path.is_empty():
		resolved_path = SANDBOX_SAVE_PATH if sandbox_mode else DEFAULT_SAVE_PATH
	_capture_field_position()
	save_timestamp = _unix_time()
	return SAVE_REPOSITORY.write_json(resolved_path, _serialize())


func load_game(path := DEFAULT_SAVE_PATH) -> Error:
	var read_result := _read_valid_save_payload(path)
	if not bool(read_result.get("valid", false)):
		return int(read_result.get("error", ERR_FILE_CORRUPT))
	if bool(read_result.get("recovered", false)):
		var repair_error := SAVE_REPOSITORY.restore_primary(path, String(read_result.get("text", "")))
		if repair_error != OK:
			push_warning("Recovered a campaign save from backup, but could not repair the primary file: %s" % error_string(repair_error))
	_deserialize(read_result.get("data", {}), int(read_result.get("source_version", SAVE_VERSION)))
	refresh_facility_jobs()
	state_changed.emit()
	return OK


func has_save(path := DEFAULT_SAVE_PATH) -> bool:
	return bool(read_save_summary(path).get("valid", false))


func read_save_summary(path := DEFAULT_SAVE_PATH) -> Dictionary:
	var read_result := _read_valid_save_payload(path)
	if not bool(read_result.get("valid", false)):
		return {"valid": false, "error": int(read_result.get("error", ERR_FILE_CORRUPT))}
	var parsed: Dictionary = read_result.get("data", {})
	var version := int(parsed.get("version", 0))
	var cell_data: Array = parsed.get("last_save_cell", [10, 9])
	var cell := Vector2i(10, 9)
	if cell_data.size() >= 2:
		cell = Vector2i(int(cell_data[0]), int(cell_data[1]))
	return {
		"valid": true,
		"version": version,
		"sandbox_mode": bool(parsed.get("sandbox_mode", false)),
		"duckets": int(parsed.get("duckets", 0)),
		"facilities": (parsed.get("built_facilities", {}) as Dictionary).size(),
		"party_size": (parsed.get("party", []) as Array).size(),
		"play_time_seconds": float(parsed.get("play_time_seconds", 0.0)),
		"save_timestamp": int(parsed.get("save_timestamp", 0)),
		"last_save_cell": cell,
		"location": String(parsed.get("last_location", _location_name_for_cell(cell))),
		"recovered_from_backup": bool(read_result.get("recovered", false)),
	}


func _read_valid_save_payload(path: String) -> Dictionary:
	var candidates: PackedStringArray = PackedStringArray([path])
	for recovery_path in SAVE_REPOSITORY.recovery_paths(path):
		candidates.append(recovery_path)
	var first_error := ERR_FILE_NOT_FOUND
	for index in candidates.size():
		var candidate := candidates[index]
		var text_result: Dictionary = SAVE_REPOSITORY.read_text(candidate)
		if not bool(text_result.get("ok", false)):
			if index == 0:
				first_error = int(text_result.get("error", ERR_FILE_NOT_FOUND))
			continue
		var parser := JSON.new()
		if parser.parse(String(text_result.get("text", ""))) != OK:
			if index == 0:
				first_error = ERR_FILE_CORRUPT
			continue
		var parsed: Variant = parser.data
		if parsed is Dictionary:
			var migration: Dictionary = SAVE_MIGRATOR.migrate(parsed)
			if not bool(migration.get("ok", false)):
				if index == 0:
					first_error = int(migration.get("error", ERR_FILE_CORRUPT))
				continue
			return {
				"valid": true,
				"error": OK,
				"data": migration.get("data", {}),
				"text": String(text_result.get("text", "")),
				"recovered": index > 0,
				"source_path": candidate,
				"source_version": int(migration.get("source_version", SAVE_VERSION)),
			}
		if index == 0:
			first_error = ERR_FILE_CORRUPT
	return {"valid": false, "error": first_error}


func format_play_time(seconds := -1.0) -> String:
	var total := int(play_time_seconds if seconds < 0.0 else seconds)
	var hours := total / 3600
	var minutes := (total % 3600) / 60
	var remaining_seconds := total % 60
	return "%02d:%02d:%02d" % [hours, minutes, remaining_seconds]


func _capture_field_position() -> void:
	if not Player.gamepiece:
		return
	var cell := GamepieceRegistry.get_cell(Player.gamepiece)
	if cell == Gameboard.INVALID_CELL:
		cell = Gameboard.pixel_to_cell(Player.gamepiece.position)
	if cell == Gameboard.INVALID_CELL:
		return
	last_save_cell = cell
	last_location = _location_name_for_cell(cell)


func set_last_manifest_room(room_id: StringName) -> void:
	last_manifest_room_id = room_id


func _location_name_for_cell(cell: Vector2i) -> String:
	if Rect2i(Vector2i(216, 32), Vector2i(28, 18)).has_point(cell):
		var empyreal_local := cell - Vector2i(216, 32)
		if empyreal_local.y >= 10 and empyreal_local.x >= 20:
			return "Empyreal Court — Seraph Tribunal"
		if empyreal_local.y >= 10:
			return "Empyreal Court — Reliquary Aerie"
		if empyreal_local.x >= 20:
			return "Empyreal Court — Forum of Measures"
		return "Empyreal Court — Garden of Appeals" if empyreal_local.x >= 10 else "Empyreal Court — Cloudstep Landing"
	if Rect2i(Vector2i(180, 32), Vector2i(28, 18)).has_point(cell):
		var moonpetal_local := cell - Vector2i(180, 32)
		if moonpetal_local.y >= 10 and moonpetal_local.x >= 20:
			return "Moonpetal Court — Moon Palace"
		if moonpetal_local.y >= 10:
			return "Moonpetal Court — Bell Walk"
		if moonpetal_local.x >= 20:
			return "Moonpetal Court — Mirror Garden"
		return "Moonpetal Court — Blossom Court" if moonpetal_local.x >= 10 else "Moonpetal Court — Vermilion Gate"
	if Rect2i(Vector2i(144, 32), Vector2i(28, 18)).has_point(cell):
		var frosthold_local := cell - Vector2i(144, 32)
		if frosthold_local.y >= 10 and frosthold_local.x >= 20:
			return "Frosthold Kingdom — Ice Throne"
		if frosthold_local.y >= 10:
			return "Frosthold Kingdom — Rune Hall"
		if frosthold_local.x >= 20:
			return "Frosthold Kingdom — Crystal Causeway"
		return "Frosthold Kingdom — Frozen Market" if frosthold_local.x >= 10 else "Frosthold Kingdom — Snow Gate"
	if Rect2i(Vector2i(108, 32), Vector2i(28, 18)).has_point(cell):
		var helios_local := cell - Vector2i(108, 32)
		if helios_local.y >= 10 and helios_local.x >= 20:
			return "Helios Arcology — Solar Core"
		if helios_local.y >= 10:
			return "Helios Arcology — Recovery Clinic"
		if helios_local.x >= 20:
			return "Helios Arcology — Transit Exchange"
		return "Helios Arcology — Public Market" if helios_local.x >= 10 else "Helios Arcology — Skybridge"
	if Rect2i(Vector2i(72, 32), Vector2i(28, 18)).has_point(cell):
		var primeval_local := cell - Vector2i(72, 32)
		if primeval_local.y >= 10 and primeval_local.x >= 20:
			return "Primeval Expanse — Caldera"
		if primeval_local.y >= 10:
			return "Primeval Expanse — Relay Nest"
		if primeval_local.x >= 20:
			return "Primeval Expanse — Jungle Ruins"
		return "Primeval Expanse — Borough" if primeval_local.x >= 10 else "Primeval Expanse — Grove"
	if Rect2i(Vector2i(36, 32), Vector2i(28, 18)).has_point(cell):
		var station_local := cell - Vector2i(36, 32)
		if station_local.y >= 10 and station_local.x >= 20:
			return "Asterion Station — Control"
		if station_local.y >= 10:
			return "Asterion Station — Medical"
		if station_local.x >= 20:
			return "Asterion Station — Hydroponics"
		return "Asterion Station — Mess Deck" if station_local.x >= 10 else "Asterion Station — Docking"
	if cell.y >= 32:
		var local := cell - Vector2i(0, 32)
		if local.x >= 20:
			return "Haunted Mansion — Ballroom"
		if local.y >= 10 and local.x >= 10:
			return "Haunted Mansion — Nursery"
		if local.y >= 10:
			return "Haunted Mansion — Portrait Gallery"
		return "Haunted Mansion — Archive" if local.x >= 10 else "Haunted Mansion — Foyer"
	if cell.x >= 36:
		return "New Philadelphia"
	return "Laboratory"


func _serialize() -> Dictionary:
	return {
		"version": SAVE_VERSION, "sandbox_mode": sandbox_mode, "duckets": duckets, "economy_transactions": economy_transactions,
		"play_time_seconds": play_time_seconds, "save_timestamp": save_timestamp,
		"last_save_cell": [last_save_cell.x, last_save_cell.y], "last_location": last_location, "last_manifest_room_id": String(last_manifest_room_id),
		"town_time_minutes": town_time_minutes, "resident_states": resident_states,
		"town_terrain": town_terrain,
		"town_objects": town_objects, "next_town_object_id": next_town_object_id,
		"built_facilities": built_facilities, "universe_anchors": universe_anchors, "story_flags": story_flags,
		"bestiary_records": bestiary_records, "inventory": inventory, "encounter_ward_steps": encounter_ward_steps, "encounter_director_states": encounter_director_states,
		"loot_inventory": loot_inventory, "character_progress": character_progress,
		"party": Array(party), "party_formation": party_formation, "recruit_status": recruit_status, "facility_assignments": facility_assignments,
		"active_facility_jobs": active_facility_jobs, "completed_facility_jobs": completed_facility_jobs,
		"owned_inventions": Array(owned_inventions), "facility_upgrades": facility_upgrades, "expedition_meal_charges": expedition_meal_charges, "equipment_loadouts": equipment_loadouts,
		"quest_states": quest_states, "quest_events": quest_events, "tracked_quest": tracked_quest,
	}


func _deserialize(data: Dictionary, source_version_override := -1) -> void:
	var source_version := source_version_override if source_version_override >= 1 else int(data.get("version", 1))
	sandbox_mode = bool(data.get("sandbox_mode", false))
	play_time_seconds = float(data.get("play_time_seconds", 0.0))
	save_timestamp = int(data.get("save_timestamp", 0))
	var saved_cell: Array = data.get("last_save_cell", [10, 9])
	last_save_cell = Vector2i(10, 9)
	if saved_cell.size() >= 2:
		last_save_cell = Vector2i(int(saved_cell[0]), int(saved_cell[1]))
	last_location = String(data.get("last_location", _location_name_for_cell(last_save_cell)))
	last_manifest_room_id = StringName(data.get("last_manifest_room_id", ""))
	town_time_minutes = fmod(float(data.get("town_time_minutes", 7.0 * 60.0)), 1440.0)
	resident_states.clear()
	for resident_id in data.get("resident_states", {}).keys():
		var resident_source: Dictionary = data.resident_states[resident_id]
		resident_states[StringName(resident_id)] = {
			"x": int(resident_source.get("x", 0)),
			"y": int(resident_source.get("y", 0)),
			"activity": StringName(resident_source.get("activity", "home")),
			"target_x": int(resident_source.get("target_x", 0)),
			"target_y": int(resident_source.get("target_y", 0)),
		}
	town_terrain.clear()
	for terrain_key in data.get("town_terrain", {}).keys():
		town_terrain[String(terrain_key)] = StringName(data.town_terrain[terrain_key])
	town_objects.clear()
	for source in data.get("town_objects", []):
		if source is Dictionary:
			town_objects.append({
				"instance_id": String(source.get("instance_id", "")),
				"catalog_id": StringName(source.get("catalog_id", "")),
				"x": int(source.get("x", 0)),
				"y": int(source.get("y", 0)),
				"flipped": bool(source.get("flipped", false)),
				"role": StringName(source.get("role", "")),
				"protected": bool(source.get("protected", false)),
			})
	if sandbox_mode and source_version < 8:
		_ensure_sandbox_authored_objects()
	next_town_object_id = maxi(1, int(data.get("next_town_object_id", town_objects.size() + 1)))
	_play_session_running = false
	duckets = int(data.get("duckets", 0))
	economy_transactions = ECONOMY_LEDGER.normalize_entries(data.get("economy_transactions", []))
	built_facilities = _integer_key_dictionary(data.get("built_facilities", {}))
	universe_anchors = _integer_key_dictionary(data.get("universe_anchors", {}))
	for plot_index in universe_anchors.keys():
		universe_anchors[plot_index] = StringName(universe_anchors[plot_index])
	story_flags = data.get("story_flags", {})
	_migrate_legacy_universe_anchors()
	bestiary_records.clear()
	for enemy_id in data.get("bestiary_records", {}).keys():
		var source_record: Dictionary = data.bestiary_records[enemy_id]
		var normalized_drops: Array[Dictionary] = []
		for raw_drop in source_record.get("drops", []):
			if raw_drop is Dictionary:
				var normalized_drop: Dictionary = raw_drop.duplicate(true)
				normalized_drop["id"] = StringName(normalized_drop.get("id", ""))
				normalized_drops.append(normalized_drop)
		bestiary_records[StringName(enemy_id)] = {
			"seen": int(source_record.get("seen", 0)),
			"defeated": int(source_record.get("defeated", 0)),
			"encounters": int(source_record.get("encounters", 0)),
			"first_encounter": StringName(source_record.get("first_encounter", "")),
			"drops": normalized_drops,
		}
	inventory = data.get("inventory", {"tonic": 3, "ether": 1, "smelling_salts": 2, "phoenix_tonic": 1})
	encounter_ward_steps = clampi(int(data.get("encounter_ward_steps", 0)), 0, 120)
	encounter_pressure = {"active": false, "universe_id": &"", "steps": 0, "threshold": 1, "ward_steps": encounter_ward_steps, "suppressed": false, "cooldown": 0}
	encounter_director_states.clear()
	for raw_universe_id in data.get("encounter_director_states", {}).keys():
		var raw_runtime: Dictionary = data.encounter_director_states[raw_universe_id]
		var raw_cell: Array = raw_runtime.get("last_danger_cell", [-1, -1])
		var last_cell := Vector2i(-1, -1)
		if raw_cell.size() >= 2:
			last_cell = Vector2i(int(raw_cell[0]), int(raw_cell[1]))
		store_encounter_director_state(StringName(raw_universe_id), {
			"steps_in_danger": int(raw_runtime.get("steps_in_danger", 0)),
			"encounter_threshold": int(raw_runtime.get("encounter_threshold", 1)),
			"cooldown_steps": int(raw_runtime.get("cooldown_steps", 0)),
			"recent_formations": raw_runtime.get("recent_formations", []),
			"last_danger_cell": last_cell,
			"rng_state": int(raw_runtime.get("rng_state", 0)),
		})
	loot_inventory.clear()
	for loot in data.get("loot_inventory", []):
		if loot is Dictionary:
			loot_inventory.append(loot)
	character_progress.clear()
	for character_id in data.get("character_progress", {}).keys():
		var progress: Dictionary = data.character_progress[character_id]
		var normalized_skills: Array[StringName] = []
		for skill_id in progress.get("learned_skills", []):
			normalized_skills.append(StringName(skill_id))
		progress["learned_skills"] = normalized_skills
		var normalized_equipment := {}
		for slot in progress.get("equipment", {}).keys():
			normalized_equipment[StringName(slot)] = String(progress["equipment"][slot])
		progress["equipment"] = normalized_equipment
		character_progress[StringName(character_id)] = progress
	party.clear()
	for recruit_id in data.get("party", ["ben"]):
		party.append(StringName(recruit_id))
	party_formation.clear()
	for recruit_id in data.get("party_formation", {}).keys():
		party_formation[StringName(recruit_id)] = StringName(data.party_formation[recruit_id])
	for recruit_id in party:
		_ensure_party_formation(recruit_id)
	recruit_status.clear()
	for recruit_id in data.get("recruit_status", {}).keys():
		recruit_status[StringName(recruit_id)] = StringName(data.recruit_status[recruit_id])
	for raw_recruit_id in recruit_catalog.keys():
		var recruit_id := StringName(raw_recruit_id)
		if not recruit_status.has(recruit_id):
			recruit_status[recruit_id] = &"party" if recruit_id == &"ben" else (&"reserve" if recruit_id in CORE_PROTAGONIST_IDS else &"undiscovered")
	facility_assignments.clear()
	for facility_name in data.get("facility_assignments", {}).keys():
		facility_assignments[String(facility_name)] = StringName(data.facility_assignments[facility_name])
	active_facility_jobs.clear()
	for facility_name in data.get("active_facility_jobs", {}).keys():
		var active: Dictionary = data.active_facility_jobs[facility_name]
		active["job_id"] = StringName(active.get("job_id", ""))
		active["worker_id"] = StringName(active.get("worker_id", ""))
		active["status"] = StringName(active.get("status", "running"))
		active_facility_jobs[String(facility_name)] = active
	completed_facility_jobs.clear()
	for job_id in data.get("completed_facility_jobs", {}).keys():
		completed_facility_jobs[StringName(job_id)] = int(data.completed_facility_jobs[job_id])
	owned_inventions.clear()
	for invention_id in data.get("owned_inventions", []):
		owned_inventions.append(StringName(invention_id))
	facility_upgrades.clear()
	for facility_name in data.get("facility_upgrades", {}).keys():
		var upgrades: Array[StringName] = []
		for upgrade_id in data.facility_upgrades[facility_name]:
			if FACILITY_UPGRADE_DEFINITIONS.has(StringName(upgrade_id)):
				upgrades.append(StringName(upgrade_id))
		if not upgrades.is_empty():
			facility_upgrades[String(facility_name)] = upgrades
	expedition_meal_charges = clampi(int(data.get("expedition_meal_charges", 0)), 0, 1)
	equipment_loadouts.clear()
	for raw_character_id in data.get("equipment_loadouts", {}).keys():
		var character_id := StringName(raw_character_id)
		var saved_loadouts: Dictionary = data.equipment_loadouts[raw_character_id]
		for raw_name in saved_loadouts.keys():
			var saved_equipment: Dictionary = saved_loadouts[raw_name]
			var normalized_equipment := {}
			for raw_slot in saved_equipment.keys():
				var slot := StringName(raw_slot)
				if slot in EQUIPMENT_SLOTS:
					normalized_equipment[slot] = String(saved_equipment[raw_slot])
			if not normalized_equipment.is_empty():
				if not equipment_loadouts.has(character_id): equipment_loadouts[character_id] = {}
				equipment_loadouts[character_id][String(raw_name).left(24)] = normalized_equipment
	quest_states.clear()
	for quest_id in data.get("quest_states", {}).keys():
		var runtime: Dictionary = data.quest_states[quest_id]
		runtime["status"] = StringName(runtime.get("status", "locked"))
		quest_states[StringName(quest_id)] = runtime
	quest_events.clear()
	for event_id in data.get("quest_events", {}).keys():
		quest_events[StringName(event_id)] = data.quest_events[event_id]
	tracked_quest = StringName(data.get("tracked_quest", ""))
	_ensure_default_progress()
	_initialize_quest_states()
	if not sandbox_mode:
		_ensure_core_protagonist_availability()


func _ensure_core_protagonist_availability() -> void:
	# v21 establishes the opening trio as durable campaign identities. Existing
	# saves retain their current formation, while any newly introduced protagonist
	# is made available in reserve rather than silently displacing a full party.
	for recruit_id in CORE_PROTAGONIST_IDS:
		if recruit_id in party:
			recruit_status[recruit_id] = &"party"
		elif recruit_status.get(recruit_id, &"undiscovered") in [&"undiscovered", &"staffed"]:
			_remove_assignment(recruit_id)
			recruit_status[recruit_id] = &"reserve"


func _migrate_legacy_universe_anchors() -> void:
	# Save versions through 11 only stored the facade. Recover its destination so
	# old campaigns gain the same explicit anchor model without rebuilding town.
	for plot_index in built_facilities.keys():
		if universe_anchors.has(plot_index):
			continue
		var facility_name := String(built_facilities[plot_index])
		for raw_universe_id in UNIVERSE_DEFINITIONS.keys():
			var definition: Dictionary = UNIVERSE_DEFINITIONS[raw_universe_id]
			if String(definition.get("building", "")) != facility_name:
				continue
			var universe_id := StringName(raw_universe_id)
			universe_anchors[plot_index] = universe_id
			break
	for raw_universe_id in universe_anchors.values():
		var universe_id := StringName(raw_universe_id)
		var definition: Dictionary = UNIVERSE_DEFINITIONS.get(universe_id, {})
		var anchor_flag := StringName(definition.get("anchor_flag", &""))
		if anchor_flag != &"":
			story_flags[anchor_flag] = true


func _integer_key_dictionary(source: Dictionary) -> Dictionary:
	var result := {}
	for key in source.keys():
		result[int(key)] = source[key]
	return result
