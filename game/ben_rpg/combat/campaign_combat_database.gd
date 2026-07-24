class_name CampaignCombatDatabase
extends RefCounted

const HORROR_PACK := "res://game_assets/monsters/cp45-f91_horror_and_nightmares/"
const SCI_FI_PACK := "res://game_assets/monsters/cp42-g31_sci_fi_entities/"
const VILLAIN_PACK := "res://game_assets/monsters/cp44-j31_villains/"
const YOKAI_PACK := "res://game_assets/monsters/cp41-a181_japanese_yokai_urban_legends/"
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const ENCOUNTER_CONTENT := preload("res://ben_rpg/combat/campaign_encounter_catalog.gd")
const ACTION_CONTENT := preload("res://ben_rpg/combat/campaign_action_catalog.gd")
const BESTIARY_CONTENT := preload("res://ben_rpg/combat/campaign_bestiary_catalog.gd")
const FALLBACK_PARTY_PROFILE := &"ben_battle_actor"
const RAPTOR_BATTLE_PROFILE := &"velociraptor_battle_actor"
const AUTHORED_BATTLE_ANIMATION_SOURCES := {
	&"ben": {
		"battle_animation_root": "res://game_assets/characters/Main Character/Ben_Franklin/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Fight_Stance_Idle/west", "frames": 8}, &"attack": {"folder": "Lead_Jab/west", "frames": 3}, &"power": {"folder": "Throw_Object/west", "frames": 7}, &"hit": {"folder": "Taking_Punch/west", "frames": 6}, &"victory": {"folder": "Angry_Stomp/west", "frames": 9}, &"death": {"folder": "Falling_Back_Death/west", "frames": 7}},
		"battle_action_sequences": {&"cane_tap": &"attack", &"static_discharge": &"power", &"voltaic_cage": &"power", &"field_triage": &"power"},
	},
	&"lincoln": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/Abe_Lincoln/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Fight_Stance_Idle/west", "frames": 8}, &"attack": {"folder": "Punch/west", "frames": 6}, &"power": {"folder": "Jumping/west", "frames": 8}, &"hit": {"folder": "Hit_Taking_Punch/west", "frames": 6}, &"victory": {"folder": "Running/west", "frames": 8}, &"death": {"folder": "Death/west", "frames": 13}},
		"battle_action_sequences": {&"attack": &"attack", &"rally": &"power"},
	},
	&"gandhi": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/Gandhi_Sprite/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle/west", "frames": 4}, &"attack": {"folder": "Punch/west", "frames": 6}, &"power": {"folder": "Throw_Object/west", "frames": 7}, &"hit": {"folder": "Taking_Damage_Hit/west", "frames": 7}, &"victory": {"folder": "Picking_Up/west", "frames": 5}, &"death": {"folder": "Death/west", "frames": 13}},
		"battle_action_sequences": {&"attack": &"attack", &"field_triage": &"power"},
	},
	&"fighter": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/Fighter/Fighter/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Fight_Stance_Idle/west", "frames": 8}, &"attack": {"folder": "Cross_Punch/west", "frames": 6}, &"power": {"folder": "Flying_Kick/west", "frames": 6}, &"hit": {"folder": "Taking_Punch/west", "frames": 6}, &"victory": {"folder": "Various_Angry_Animations/west", "frames": 9}, &"death": {"folder": "K.O._Knockout/west", "frames": 8}},
		"battle_action_sequences": {&"attack": &"attack", &"pummel": &"attack", &"cleave": &"power", &"rally": &"victory"},
	},
	&"astronaut": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/astronaut/Astronaut/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle/west", "frames": 4}, &"attack": {"folder": "Shooting/west", "frames": 11}, &"power": {"folder": "Punch/west", "frames": 6}, &"hit": {"folder": "Hit_Knocked_Back/west", "frames": 7}, &"victory": {"folder": "Floating/west", "frames": 11}, &"death": {"folder": "Death_Animation/west", "frames": 11}},
		"battle_action_sequences": {&"pulse_shot": &"attack", &"deadeye_shot": &"attack", &"ion_round": &"attack"},
	},
	&"caveman": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/caveman/Caveman/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Fight_Stance_Idle/west", "frames": 8}, &"attack": {"folder": "Swing_hammer_at_opponents_to_harm_them._Violent_an/west", "frames": 11}, &"power": {"folder": "Running_Jump/west", "frames": 8}, &"hit": {"folder": "Taking_Punch/west", "frames": 6}, &"victory": {"folder": "Getting_Up/west", "frames": 5}, &"death": {"folder": "Falling_Back_Death/west", "frames": 7}},
		"battle_action_sequences": {&"club_smash": &"attack", &"pummel": &"attack", &"mammoth_slam": &"power", &"primal_roar": &"victory"},
	},
	&"crimson_oni": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/crimson oni samurai/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle-caed6390/west", "frames": 4}, &"attack": {"folder": "ATTACK_01_Swift_Crescent_Slash-7e65ee4e/west", "frames": 9}, &"power": {"folder": "BLOOD_MOON_IAIJUTSU-1560d959/west", "frames": 9}, &"hit": {"folder": "DEMONIC_COUNTERSTANCE-bfea361b/west", "frames": 9}, &"victory": {"folder": "EPIC_GETTING_UP_RISE_OF_THE_FALLEN_ONI-27f74696/west", "frames": 8}, &"death": {"folder": "EPIC_DEATH_FALL_OF_THE_CRIMSON_LEGEND-897aef6a/west", "frames": 9}},
		"battle_action_sequences": {&"oni_crescent": &"attack", &"pummel": &"attack", &"blood_moon_cleave": &"power"},
	},
	&"kitsune_empress": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/kitsune empress/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle-5abb96ca/west", "frames": 4}, &"attack": {"folder": "Attack_01_Scarlet_Moon_Slash-5afc4b82/west-c47c8fb2", "frames": 9}, &"power": {"folder": "Special_Skill_Foxfire_Step-35a61cdc/west", "frames": 17}, &"hit": {"folder": "Parry_Fox_Mirror_Counter-1ee0ba82/west", "frames": 9}, &"victory": {"folder": "Rise_Animation_Rebirth_of_the_Crimson_Fox-2ec003ff/west", "frames": 13}, &"death": {"folder": "Death_Animation_Fallen_Empress-44de1ab4/west", "frames": 11}},
		"battle_action_sequences": {&"foxfire": &"power", &"nine_tail_judgment": &"power", &"field_triage": &"hit"},
	},
	&"neon_viper": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/neon viper - cyberpunk female/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle-13bc768a/west", "frames": 4}, &"attack": {"folder": "Cross_Punch-e9742923/west", "frames": 6}, &"power": {"folder": "Surprise_Uppercut-d1d84529/west", "frames": 7}, &"victory": {"folder": "Getting_Up-8fc67d8f/west", "frames": 5}, &"death": {"folder": "Falling_Back_Death-343d78dd/west", "frames": 7}},
		"battle_action_sequences": {&"viper_rush": &"attack", &"pulse_shot": &"attack", &"viper_uppercut": &"power"},
	},
	&"archangel_commander": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/Archangel Commander — Legendary Celestial Warrior Hero/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Hover_Idle-b43681f6/west", "frames": 11}, &"attack": {"folder": "Attack_01_Seraph_Strike-5305f2a5/west", "frames": 11}, &"power": {"folder": "Wings_of_Judgment-11c6cc32/west", "frames": 16}, &"hit": {"folder": "Angelic_Flinch-2ef47255/west", "frames": 9}, &"victory": {"folder": "Ascension_of_the_Seraph-ec9719be/west", "frames": 17}, &"death": {"folder": "Archangel_Commander_losing_strength_and_descending-59a28e2b/west", "frames": 15}},
		"battle_action_sequences": {&"seraph_strike": &"attack", &"heavenly_aegis": &"power", &"field_triage": &"power"},
	},
	&"frost_lich_emperor": {
		"battle_animation_root": "res://game_assets/characters/Recruitable Characters/💀 The Frost Lich King Emperor/animations", "battle_animation_fps": 12.0,
		"battle_animation_sequences": {&"idle": {"folder": "Hover_Idle-57c856d6/west", "frames": 11}, &"attack": {"folder": "Royal_Cleave-12225c29/west", "frames": 13}, &"power": {"folder": "Frost_Nova-60a6d642/west", "frames": 17}, &"hit": {"folder": "Soul_Stagger-debb3504/west", "frames": 9}, &"victory": {"folder": "Army_of_the_Dead-f28fb049/west", "frames": 17}, &"death": {"folder": "Death_Animation-0ad98e8c/west", "frames": 13}},
		"battle_action_sequences": {&"frost_nova": &"power", &"soul_reaper": &"attack"},
	},
	&"velociraptor": {
		"battle_animation_root": "res://game_assets/characters/Velociraptor/Tiny_Velociraptor/animations", "battle_animation_fps": 14.0,
		"battle_animation_sequences": {&"idle": {"folder": "Breathing_Idle/west", "frames": 4}, &"attack": {"folder": "Bite_Attack/west", "frames": 13}, &"power": {"folder": "Scratch/west", "frames": 7}, &"hit": {"folder": "Taking_Hit/west", "frames": 6}, &"victory": {"folder": "Two-Footed_Jump/west", "frames": 7}, &"death": {"folder": "Raptor_Death/west", "frames": 11}},
		"battle_action_sequences": {&"raptor_pounce": &"attack", &"raptor_distract": &"power"},
	},
}

const BESTIARY_ORDER := [
	&"schoolgirl_ghost", &"war_book", &"clock_mirror", &"composer_portrait", &"haunted_doll", &"clock_mirror_boss", &"rift_jackal_challenger",
	&"work_robot", &"sentry_drone", &"medical_robot", &"machine_commander", &"mother_computer", &"bulkhead_warden_challenger",
	&"primeval_raptor", &"stone_triceratops", &"municipal_spinosaur", &"commute_tyrant", &"mossback_surveyor_challenger",
	&"helios_mech", &"helios_assassin", &"helios_security", &"helios_gunner", &"civic_sun", &"cobalt_courier_challenger",
	&"frost_collector", &"frost_necromancer", &"ice_colossus", &"whiteout_auditor",
	&"memory_inspector", &"fox_attendant", &"vow_spider", &"magistrate_enma", &"crimson_oni_challenger",
	&"wind_bailiff", &"storm_repossessor", &"fallen_notary", &"gravity_knight", &"high_comptroller",
]
const BESTIARY_REGIONS := {
	&"schoolgirl_ghost": "Haunted Mansion", &"war_book": "Haunted Mansion", &"clock_mirror": "Haunted Mansion",
	&"composer_portrait": "Haunted Mansion", &"haunted_doll": "Haunted Mansion", &"clock_mirror_boss": "Haunted Mansion", &"rift_jackal_challenger": "Haunted Mansion",
	&"work_robot": "Asterion Station", &"sentry_drone": "Asterion Station", &"medical_robot": "Asterion Station",
	&"machine_commander": "Asterion Station", &"mother_computer": "Asterion Station", &"bulkhead_warden_challenger": "Asterion Station",
	&"primeval_raptor": "Primeval Expanse", &"stone_triceratops": "Primeval Expanse",
	&"municipal_spinosaur": "Primeval Expanse", &"commute_tyrant": "Primeval Expanse", &"mossback_surveyor_challenger": "Primeval Expanse",
	&"helios_mech": "Helios Arcology", &"helios_assassin": "Helios Arcology", &"helios_security": "Helios Arcology",
	&"helios_gunner": "Helios Arcology", &"civic_sun": "Helios Arcology", &"cobalt_courier_challenger": "Helios Arcology",
	&"frost_collector": "Frosthold Kingdom", &"frost_necromancer": "Frosthold Kingdom",
	&"ice_colossus": "Frosthold Kingdom", &"whiteout_auditor": "Frosthold Kingdom",
	&"memory_inspector": "Moonpetal Court", &"fox_attendant": "Moonpetal Court", &"vow_spider": "Moonpetal Court",
	&"magistrate_enma": "Moonpetal Court", &"crimson_oni_challenger": "Moonpetal Court",
	&"wind_bailiff": "Empyreal Court", &"storm_repossessor": "Empyreal Court",
	&"fallen_notary": "Empyreal Court", &"gravity_knight": "Empyreal Court", &"high_comptroller": "Empyreal Court",
}
const BESTIARY_BOSSES := [
	&"clock_mirror_boss", &"rift_jackal_challenger", &"mother_computer", &"bulkhead_warden_challenger", &"commute_tyrant", &"mossback_surveyor_challenger", &"civic_sun",
	&"cobalt_courier_challenger", &"whiteout_auditor", &"magistrate_enma", &"crimson_oni_challenger", &"high_comptroller",
]
const BESTIARY_RECRUITABLES := [&"rift_jackal_challenger", &"bulkhead_warden_challenger", &"mossback_surveyor_challenger", &"cobalt_courier_challenger", &"crimson_oni_challenger"]
# Ben's Static Discharge is available on every first visit. Other elemental
# specialties remain optional, so first-visit weaknesses must never require a
# later recruit, a skill purchase, or a particular anchor choice.
const FIRST_VISIT_AVAILABLE_ELEMENTS_BY_REGION := {
	"Haunted Mansion": [&"lightning"], "Asterion Station": [&"lightning"], "Primeval Expanse": [&"lightning"],
	"Helios Arcology": [&"lightning"], "Frosthold Kingdom": [&"lightning"], "Moonpetal Court": [&"lightning"], "Empyreal Court": [&"lightning"],
}


static func _action_catalog() -> Dictionary:
	return ACTION_CONTENT.DEFINITIONS.duplicate(true)


static func _retired_action_catalog_snapshot() -> Dictionary:
	var actions := {
		&"attack": {"name": "Attack", "kind": "physical", "power": 13, "target": "enemy", "critical_rate": 0.1, "description": "Strike one enemy. Physical attacks can critically hit."},
		&"cane_tap": {"name": "Cane Tap", "kind": "physical", "power": 7, "target": "enemy", "description": "Ben contributes a technically adequate blow."},
		&"static_discharge": {"name": "Static Discharge", "kind": "magic", "power": 18, "mp": 6, "target": "all_enemies", "element": &"lightning", "status": &"shocked", "status_chance": 0.25, "description": "Shock every enemy; lightning can exploit a weakness and may inflict Shock."},
		&"field_triage": {"name": "Field Triage", "kind": "heal", "power": 46, "mp": 5, "target": "ally", "cleanses": [&"poisoned"], "description": "Restore HP and remove Poison from one ally."},
		&"voltaic_cage": {"name": "Voltaic Cage", "kind": "magic", "power": 32, "mp": 10, "target": "all_enemies", "element": &"lightning", "status": &"shocked", "status_chance": 0.45, "description": "A trained condenser discharge exploits lightning weaknesses and may inflict Shock."},
		&"pummel": {"name": "Pummel", "kind": "physical", "power": 22, "mp": 3, "target": "enemy", "description": "A committed two-hit combination."},
		&"cleave": {"name": "Cleave", "kind": "physical", "power": 16, "mp": 6, "target": "all_enemies", "critical_rate": 0.06, "description": "A trained sweep strikes the entire enemy formation."},
		&"rally": {"name": "Rally", "kind": "rally", "power": 5, "mp": 4, "target": "all_allies", "description": "Raise the party's attack for three actions."},
		&"defend": {"name": "Defend", "kind": "defend", "power": 0, "target": "self", "description": "Halve incoming damage until the next action."},
		&"tonic": {"name": "Tonic", "kind": "item_heal", "power": 70, "target": "ally", "item": &"tonic", "description": "Restore 70 HP. Uses one Tonic."},
		&"ether": {"name": "Leyden Ether", "kind": "item_mp", "power": 24, "target": "ally", "item": &"ether", "description": "Restore 24 MP. Uses one Leyden Ether."},
		&"smelling_salts": {"name": "Smelling Salts", "kind": "cleanse", "target": "ally", "item": &"smelling_salts", "cleanses": [&"poisoned", &"slow", &"shocked"], "description": "Remove Poison, Slow, and Shock from one ally."},
		&"phoenix_tonic": {"name": "Phoenix Tonic", "kind": "revive", "power": 25, "target": "ko_ally", "item": &"phoenix_tonic", "description": "Revive one fallen company member with 25% HP."},
		&"escape": {"name": "Escape", "kind": "escape", "target": "self", "description": "Attempt to flee a random encounter. Scripted and boss battles cannot be escaped."},
		&"raptor_pounce": {"name": "Raptor Pounce", "kind": "physical", "power": 16, "target": "enemy", "description": "The velociraptor attacks on its own schedule."},
		&"raptor_distract": {"name": "Menacing Display", "kind": "delay", "power": 28, "target": "enemy", "description": "Reduce an enemy's ATB gauge."},
		&"spectral_touch": {"name": "Spectral Touch", "kind": "magic", "power": 13, "target": "enemy", "element": &"spectral", "status": &"slow", "status_chance": 0.4, "description": "Cold fingers pass through armor and may inflict Slow."},
		&"hurl_volume": {"name": "Hurl Volume", "kind": "physical", "power": 15, "target": "enemy", "description": "Knowledge is power, especially at high velocity."},
		&"ink_blight": {"name": "Ink Blight", "kind": "magic", "power": 10, "target": "enemy", "element": &"spectral", "status": &"poisoned", "status_chance": 0.7, "description": "Cursed ink harms and poisons one target."},
		&"steal_time": {"name": "Steal Time", "kind": "damage_delay", "power": 10, "delay": 24, "target": "enemy", "element": &"time", "status": &"slow", "status_chance": 0.55, "description": "The clock wounds a target, drains ATB, and may inflict Slow."},
		&"late_fee": {"name": "Late Fee", "kind": "magic", "power": 24, "target": "all_enemies", "element": &"spectral", "description": "The house collects spectral interest from the whole party."},
		&"temporal_tuning": {"name": "Temporal Tuning", "kind": "time_tune", "power": 55, "mp": 6, "target": "enemy", "element": &"time", "description": "Use the Temporal Tuning Fork to drain an enemy's ATB and cancel a telegraphed clock attack."},
		&"continuity_aegis": {"name": "Continuity Aegis", "kind": "aegis", "power": 0, "mp": 8, "target": "all_allies", "description": "Use the Continuity Kite to shield the formation until each ally acts again."},
		&"paleo_signal": {"name": "Paleo Signal", "kind": "delay", "power": 24, "mp": 6, "target": "all_enemies", "description": "Broadcast an ancient stop signal that reduces every enemy's ATB."},
		&"night_phase": {"name": "Night Phase", "kind": "aegis", "power": 0, "mp": 7, "target": "all_allies", "description": "Invert the formation into a brief, protective midnight phase."},
		&"thermal_rally": {"name": "Thermal Arbitration", "kind": "rally", "power": 7, "mp": 6, "target": "all_allies", "description": "Settle the party's thermal balance and raise its attack for three actions."},
		&"veracity_flash": {"name": "Veracity Flash", "kind": "magic", "power": 20, "mp": 8, "target": "all_enemies", "element": &"lightning", "status": &"shocked", "status_chance": 0.35, "description": "Expose every hostile falsehood with a lightning flash that may inflict Shock."},
		&"gravity_grounding": {"name": "Gravity Grounding", "kind": "delay", "power": 30, "mp": 8, "target": "all_enemies", "description": "Anchor the enemy formation to the floor and reduce every target's ATB."},
		&"unfinished_refrain": {"name": "Unfinished Refrain", "kind": "magic", "power": 17, "target": "all_enemies", "element": &"spectral", "status": &"slow", "status_chance": 0.32, "description": "A painted orchestra attacks the party and may inflict Slow."},
		&"splinter_needle": {"name": "Splinter Needle", "kind": "physical", "power": 18, "target": "enemy", "status": &"poisoned", "status_chance": 0.42, "description": "A toy needle strikes one target and may inflict Poison."},
		&"nursery_wail": {"name": "Nursery Wail", "kind": "damage_delay", "power": 12, "delay": 20, "target": "all_enemies", "element": &"spectral", "description": "A broken lullaby harms and delays the whole party."},
		&"borrowed_second": {"name": "Borrowed Second", "kind": "damage_delay", "power": 18, "delay": 35, "mp": 8, "target": "all_enemies", "element": &"time", "description": "The Anchored Chronometer damages and delays the enemy formation."},
		&"pulse_shot": {"name": "Pulse Shot", "kind": "physical", "power": 17, "target": "enemy", "critical_rate": 0.14, "description": "A precise ranged attack from the Astronaut's sidearm."},
		&"deadeye_shot": {"name": "Deadeye Shot", "kind": "physical", "power": 31, "mp": 5, "target": "enemy", "critical_rate": 0.3, "description": "A carefully placed shot with a high critical rate."},
		&"ion_round": {"name": "Ion Round", "kind": "magic", "power": 24, "mp": 7, "target": "enemy", "element": &"lightning", "status": &"shocked", "status_chance": 0.55, "description": "An electrified round built to disrupt machines."},
		&"club_smash": {"name": "Club Smash", "kind": "physical", "power": 19, "target": "enemy", "critical_rate": 0.12, "description": "The Caveman applies the oldest reliable technology."},
		&"primal_roar": {"name": "Primal Roar", "kind": "rally", "power": 4, "mp": 3, "target": "all_allies", "description": "Raise the formation's attack with prehistoric confidence."},
		&"mammoth_slam": {"name": "Mammoth Slam", "kind": "physical", "power": 32, "mp": 6, "target": "enemy", "critical_rate": 0.12, "description": "A crushing blow learned from much larger problems."},
		&"oni_crescent": {"name": "Crimson Crescent", "kind": "physical", "power": 21, "target": "enemy", "critical_rate": 0.2, "description": "A fast iaijutsu draw across one enemy."},
		&"blood_moon_cleave": {"name": "Blood-Moon Iaijutsu", "kind": "physical", "power": 24, "mp": 8, "target": "all_enemies", "critical_rate": 0.1, "description": "The Oni draws once and the whole enemy line notices."},
		&"rift_bite": {"name": "Rift Bite", "kind": "physical", "power": 22, "target": "enemy", "critical_rate": 0.18, "description": "A fast bite delivered from an inconvenient angle in space."},
		&"phase_scratch": {"name": "Phase Scratch", "kind": "magic", "power": 20, "mp": 4, "target": "enemy", "element": &"spectral", "status": &"slow", "status_chance": 0.3, "description": "A claw briefly exits ordinary geometry, bypassing armor and possibly inflicting Slow."},
		&"faultline_pounce": {"name": "Fault-Line Pounce", "kind": "damage_delay", "power": 30, "delay": 32, "mp": 7, "target": "enemy", "critical_rate": 0.25, "description": "Leap through a short-lived doorway, strike hard, and drain the target's ATB."},
		&"anchor_howl": {"name": "Anchor Howl", "kind": "rally", "power": 5, "mp": 6, "target": "all_allies", "description": "A fault-line howl steadies the formation and raises its attack."},
		&"mossback_pummel": {"name": "Boundary-Stake Pummel", "kind": "physical", "power": 23, "target": "enemy", "critical_rate": 0.12, "description": "A survey stake establishes a new boundary directly through one opponent."},
		&"spore_receipt": {"name": "Spore Receipt", "kind": "magic", "power": 17, "mp": 6, "target": "all_enemies", "element": &"nature", "status": &"poisoned", "status_chance": 0.34, "description": "Issue the enemy formation an itemized cloud of poisonous municipal spores."},
		&"rooted_red_tape": {"name": "Rooted Red Tape", "kind": "damage_delay", "power": 25, "delay": 32, "mp": 8, "target": "enemy", "element": &"nature", "status": &"slow", "status_chance": 0.55, "description": "Binding roots delay one target while the soil reviews its application."},
		&"hearty_provisions": {"name": "Hearty Provisions", "kind": "heal", "power": 34, "mp": 10, "target": "all_allies", "cleanses": [&"poisoned"], "description": "Restore the entire formation and remove Poison with aggressively nutritious field rations."},
		&"cobalt_claw": {"name": "Cobalt Claw", "kind": "physical", "power": 20, "target": "enemy", "critical_rate": 0.18, "description": "A courier's fast signature request, delivered with claws."},
		&"express_jolt": {"name": "Express Jolt", "kind": "magic", "power": 23, "mp": 5, "target": "enemy", "element": &"lightning", "status": &"shocked", "status_chance": 0.34, "description": "Deliver a concentrated lightning parcel that may inflict Shock."},
		&"priority_delivery": {"name": "Priority Delivery", "kind": "damage_delay", "power": 28, "delay": 34, "mp": 8, "target": "enemy", "element": &"lightning", "status": &"shocked", "status_chance": 0.42, "description": "Cross an impossible shortcut, strike, and remove part of the target's ATB before it can sign."},
		&"emergency_dispatch": {"name": "Emergency Dispatch", "kind": "heal", "power": 31, "mp": 10, "target": "all_allies", "cleanses": [&"shocked"], "description": "Restore the formation and remove Shock with medical parcels delivered slightly before they are needed."},
		&"warden_pummel": {"name": "Load Test", "kind": "physical", "power": 24, "target": "enemy", "critical_rate": 0.1, "description": "Apply a calibrated structural impact to one questionable support."},
		&"piston_surge": {"name": "Piston Surge", "kind": "magic", "power": 21, "mp": 5, "target": "enemy", "element": &"lightning", "status": &"shocked", "status_chance": 0.32, "description": "Vent an overcharged actuator through one target and possibly inflict Shock."},
		&"bulkhead_drop": {"name": "Bulkhead Drop", "kind": "physical", "power": 20, "mp": 8, "target": "all_enemies", "status": &"slow", "status_chance": 0.28, "description": "Become an emergency wall directly above the enemy formation."},
		&"pressure_lock": {"name": "Pressure Lock", "kind": "damage_delay", "power": 29, "delay": 36, "mp": 8, "target": "enemy", "element": &"lightning", "status": &"slow", "status_chance": 0.48, "description": "Seal one target inside a pneumatic inspection cycle and drain its ATB."},
		&"foxfire": {"name": "Foxfire", "kind": "magic", "power": 21, "mp": 5, "target": "enemy", "element": &"spectral", "status": &"slow", "status_chance": 0.25, "description": "Spectral flame pursues one enemy and may Slow it."},
		&"nine_tail_judgment": {"name": "Nine-Tailed Judgment", "kind": "magic", "power": 28, "mp": 10, "target": "all_enemies", "element": &"spectral", "status": &"slow", "status_chance": 0.35, "description": "Nine arcs of foxfire sweep the enemy formation."},
		&"viper_rush": {"name": "Viper Rush", "kind": "damage_delay", "power": 15, "delay": 28, "target": "enemy", "description": "A cybernetic rush damages one target and drains its ATB."},
		&"viper_uppercut": {"name": "Surprise Uppercut", "kind": "physical", "power": 30, "mp": 5, "target": "enemy", "critical_rate": 0.35, "description": "A concealed launcher turns an uppercut into a high-critical strike."},
		&"seraph_strike": {"name": "Seraph Strike", "kind": "magic", "power": 23, "mp": 5, "target": "enemy", "element": &"radiant", "description": "A radiant wingblade descends on one enemy."},
		&"heavenly_aegis": {"name": "Heavenly Aegis", "kind": "aegis", "power": 0, "mp": 6, "target": "all_allies", "description": "Shield the formation until each ally takes its next action."},
		&"frost_nova": {"name": "Frost Nova", "kind": "magic", "power": 24, "mp": 8, "target": "all_enemies", "element": &"frost", "status": &"slow", "status_chance": 0.45, "description": "Freezing sorcery strikes every enemy and may Slow them."},
		&"soul_reaper": {"name": "Soul Reaper", "kind": "magic", "power": 36, "mp": 11, "target": "enemy", "element": &"spectral", "description": "The Lich Emperor harvests a severe portion of one soul."},
		&"servo_strike": {"name": "Servo Strike", "kind": "physical", "power": 20, "target": "enemy", "description": "A machine-driven blow."},
		&"suppressive_burst": {"name": "Suppressive Burst", "kind": "physical", "power": 15, "target": "all_enemies", "status": &"slow", "status_chance": 0.24, "description": "A burst of fire pressures the whole party and may inflict Slow."},
		&"system_shock": {"name": "System Shock", "kind": "magic", "power": 20, "target": "enemy", "element": &"lightning", "status": &"shocked", "status_chance": 0.5, "description": "A hostile diagnostic pulse shocks one target."},
		&"mandatory_overtime": {"name": "Mandatory Overtime", "kind": "damage_delay", "power": 18, "delay": 30, "target": "all_enemies", "element": &"lightning", "status": &"slow", "status_chance": 0.4, "description": "The Mother Computer extends everyone's shift and delays the whole party."},
		&"prehistoric_bite": {"name": "Prehistoric Bite", "kind": "physical", "power": 22, "target": "enemy", "description": "Several million years of dentistry become immediately relevant."},
		&"tail_sweep": {"name": "Tail Sweep", "kind": "physical", "power": 16, "target": "all_enemies", "status": &"slow", "status_chance": 0.2, "description": "A heavy tail sweeps the party formation."},
		&"stampede": {"name": "Stampede", "kind": "physical", "power": 20, "target": "all_enemies", "description": "Municipal right-of-way is asserted by mass."},
		&"commuter_roar": {"name": "Commuter Roar", "kind": "damage_delay", "power": 18, "delay": 28, "target": "all_enemies", "status": &"slow", "status_chance": 0.36, "description": "The tyrant objects to delays by creating several more."},
		&"compliance_burst": {"name": "Compliance Burst", "kind": "physical", "power": 22, "target": "enemy", "status": &"slow", "status_chance": 0.35, "description": "A precision burst strongly recommends immediate cooperation."},
		&"daylight_lance": {"name": "Daylight Lance", "kind": "magic", "power": 25, "target": "enemy", "element": &"radiant", "status": &"shocked", "status_chance": 0.4, "description": "Concentrated municipal sunlight overloads one target."},
		&"permanent_noon": {"name": "Permanent Noon", "kind": "damage_delay", "power": 21, "delay": 32, "target": "all_enemies", "element": &"radiant", "status": &"slow", "status_chance": 0.42, "description": "The Civic Sun extends the workday across the entire formation."},
		&"cold_assessment": {"name": "Cold Assessment", "kind": "magic", "power": 28, "target": "enemy", "element": &"frost", "status": &"slow", "status_chance": 0.48, "description": "A collector estimates one target's taxable body heat."},
		&"lien_of_silence": {"name": "Lien of Silence", "kind": "damage_delay", "power": 23, "delay": 34, "target": "enemy", "element": &"spectral", "status": &"slow", "status_chance": 0.42, "description": "A spectral lien harms one target and freezes part of its ATB gauge."},
		&"absolute_audit": {"name": "Absolute Audit", "kind": "damage_delay", "power": 25, "delay": 28, "target": "all_enemies", "element": &"frost", "status": &"slow", "status_chance": 0.5, "description": "The Whiteout Auditor assesses the entire formation at absolute zero."},
		&"memory_stamp": {"name": "Memory Stamp", "kind": "magic", "power": 30, "target": "enemy", "element": &"spectral", "status": &"slow", "status_chance": 0.46, "description": "An inspector replaces one recollection with a slower, officially approved copy."},
		&"procession_waltz": {"name": "Procession Waltz", "kind": "damage_delay", "power": 24, "delay": 30, "target": "all_enemies", "element": &"spectral", "status": &"slow", "status_chance": 0.4, "description": "A fox wedding circles the entire formation and carries part of its ATB away."},
		&"final_testimony": {"name": "Final Testimony", "kind": "damage_delay", "power": 27, "delay": 32, "target": "all_enemies", "element": &"spectral", "status": &"slow", "status_chance": 0.52, "description": "Magistrate Enma declares the party's memories inadmissible and attacks the record itself."},
		&"gravity_writ": {"name": "Writ of Excess Weight", "kind": "damage_delay", "power": 29, "delay": 30, "target": "enemy", "element": &"radiant", "status": &"slow", "status_chance": 0.48, "description": "A celestial writ increases one target's legal and physical burden."},
		&"storm_decree": {"name": "Storm Decree", "kind": "magic", "power": 31, "target": "all_enemies", "element": &"lightning", "status": &"shocked", "status_chance": 0.38, "description": "Enforcement thunder strikes the whole formation."},
		&"foreclosure_of_flight": {"name": "Foreclosure of Flight", "kind": "damage_delay", "power": 30, "delay": 36, "target": "all_enemies", "element": &"radiant", "status": &"slow", "status_chance": 0.56, "description": "The Comptroller repossesses momentum from the entire party."},
	}
	return actions


static func action(action_id: StringName) -> Dictionary:
	return ACTION_CONTENT.definition(action_id)


static func action_ids() -> Array[StringName]:
	return ACTION_CONTENT.ids()


static func party_actor(character_id: StringName, progress: Dictionary) -> Dictionary:
	var recruit: Dictionary = CampaignState.recruit_catalog.get(character_id, {})
	# New catalog entries fall back to a reviewed profile, never a formatted raw
	# asset path. Established company entries declare their own profile metadata.
	var visual_profile := StringName(recruit.get("battle_profile", FALLBACK_PARTY_PROFILE))
	var visual_sprite := _visual_sprite(visual_profile)
	if visual_sprite.is_empty():
		return {}
	var level := int(progress.get("level", 1))
	var build := CampaignState.actor_build(character_id)
	var bonuses: Dictionary = build["bonuses"]
	var learned_actions: Array = build["actions"]
	if character_id == &"fighter":
		var fighter_actions: Array = [&"attack", &"pummel", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"]
		fighter_actions.append_array(learned_actions)
		var fighter := _actor(character_id, "Fighter", "party", 190 + (level - 1) * 22 + int(bonuses[&"max_hp"]), 18 + (level - 1) * 2 + int(bonuses[&"max_mp"]),
			32 + level * 4 + int(bonuses[&"attack"]), 24 + level * 3 + int(bonuses[&"defense"]), 8 + level + int(bonuses[&"magic"]), 13 + level * 2 + int(bonuses[&"spirit"]), 34 + level + int(bonuses[&"speed"]),
			String(visual_sprite["sprite_path"]), fighter_actions, progress)
		_apply_visual_sprite(fighter, visual_profile, visual_sprite)
		_apply_build_element_rates(fighter, build)
		fighter["formation"] = CampaignState.formation_for(character_id)
		_attach_authored_battle_animation(fighter, character_id)
		return fighter
	if character_id == &"astronaut":
		var astronaut_actions: Array = [&"pulse_shot", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"]
		astronaut_actions.append_array(learned_actions)
		var astronaut := _actor(character_id, "Astronaut", "party", 165 + (level - 1) * 18 + int(bonuses[&"max_hp"]), 24 + (level - 1) * 3 + int(bonuses[&"max_mp"]),
			29 + level * 3 + int(bonuses[&"attack"]), 21 + level * 2 + int(bonuses[&"defense"]), 17 + level * 2 + int(bonuses[&"magic"]), 18 + level * 2 + int(bonuses[&"spirit"]), 38 + level * 2 + int(bonuses[&"speed"]),
			String(visual_sprite["sprite_path"]), astronaut_actions, progress)
		_apply_visual_sprite(astronaut, visual_profile, visual_sprite)
		_apply_build_element_rates(astronaut, build)
		astronaut["formation"] = CampaignState.formation_for(character_id)
		_attach_authored_battle_animation(astronaut, character_id)
		return astronaut
	if character_id == &"ben":
		var ben_actions: Array = [&"cane_tap", &"static_discharge", &"field_triage", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"]
		for action_id in CampaignState.expedition_invention_actions():
			if action_id not in ben_actions:
				ben_actions.append(action_id)
		ben_actions.append_array(learned_actions)
		var ben := _actor(&"ben", "Benjamin Franklin", "party", 140 + (level - 1) * 14 + int(bonuses[&"max_hp"]), 36 + (level - 1) * 5 + int(bonuses[&"max_mp"]),
			14 + level * 2 + int(bonuses[&"attack"]), 17 + level * 2 + int(bonuses[&"defense"]), 29 + level * 3 + int(bonuses[&"magic"]), 24 + level * 2 + int(bonuses[&"spirit"]), 27 + level + int(bonuses[&"speed"]),
			String(visual_sprite["sprite_path"]), ben_actions, progress)
		_apply_visual_sprite(ben, visual_profile, visual_sprite)
		_apply_build_element_rates(ben, build)
		ben["formation"] = CampaignState.formation_for(&"ben")
		_attach_authored_battle_animation(ben, &"ben")
		return ben
	# Recruit folders can be added without changing this combat database. Catalog
	# metadata supplies identity and optional tuning; the battle image itself is
	# resolved from the reviewed party profile map above.
	var stats: Dictionary = recruit.get("combat_stats", {})
	var generic_actions: Array = recruit.get("combat_actions", [&"attack", &"defend", &"tonic", &"ether", &"smelling_salts", &"phoenix_tonic", &"escape"]).duplicate()
	for learned_action in learned_actions:
		if learned_action not in generic_actions:
			generic_actions.append(learned_action)
	var sprite_path := String(visual_sprite["sprite_path"])
	var generic := _actor(character_id, String(recruit.get("name", String(character_id).capitalize())), "party",
		int(stats.get("max_hp", 155)) + (level - 1) * int(stats.get("hp_growth", 18)) + int(bonuses[&"max_hp"]),
		int(stats.get("max_mp", 24)) + (level - 1) * int(stats.get("mp_growth", 3)) + int(bonuses[&"max_mp"]),
		int(stats.get("attack", 24)) + level * int(stats.get("attack_growth", 3)) + int(bonuses[&"attack"]),
		int(stats.get("defense", 20)) + level * int(stats.get("defense_growth", 2)) + int(bonuses[&"defense"]),
		int(stats.get("magic", 18)) + level * int(stats.get("magic_growth", 2)) + int(bonuses[&"magic"]),
		int(stats.get("spirit", 18)) + level * int(stats.get("spirit_growth", 2)) + int(bonuses[&"spirit"]),
		int(stats.get("speed", 30)) + level * int(stats.get("speed_growth", 1)) + int(bonuses[&"speed"]),
		sprite_path, generic_actions, progress)
	_apply_visual_sprite(generic, visual_profile, visual_sprite)
	_apply_build_element_rates(generic, build)
	generic["formation"] = CampaignState.formation_for(character_id)
	_attach_authored_battle_animation(generic, character_id, recruit)
	return generic


static func _apply_build_element_rates(actor: Dictionary, build: Dictionary) -> void:
	actor["element_rates"] = (build.get("element_rates", {}) as Dictionary).duplicate(true)


static func raptor_actor() -> Dictionary:
	var visual_profile := RAPTOR_BATTLE_PROFILE
	var visual_sprite := _visual_sprite(visual_profile)
	if visual_sprite.is_empty():
		return {}
	var actor := _actor(&"velociraptor", "Velociraptor", "party", 115, 0, 31, 16, 4, 12, 41,
		String(visual_sprite["sprite_path"]), [&"raptor_pounce", &"raptor_distract"], {})
	_apply_visual_sprite(actor, visual_profile, visual_sprite)
	actor["autonomous"] = true
	actor["counts_for_defeat"] = false
	actor["formation"] = &"pet"
	_attach_authored_battle_animation(actor, &"velociraptor")
	return actor


static func bestiary_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for enemy_id in BESTIARY_ORDER:
		result.append(StringName(enemy_id))
	return result


static func bestiary_entry(enemy_id: StringName) -> Dictionary:
	if enemy_id not in BESTIARY_ORDER:
		return {}
	var actor := enemy_actor(enemy_id, 0)
	return {
		"id": enemy_id,
		"name": String(actor.get("display_name", String(enemy_id).capitalize())),
		"region": String(BESTIARY_REGIONS.get(enemy_id, "Unknown Universe")),
		"boss": enemy_id in BESTIARY_BOSSES,
		"recruitable": enemy_id in BESTIARY_RECRUITABLES,
		"max_hp": int(actor.get("max_hp", 0)),
		"attack": int(actor.get("attack", 0)),
		"defense": int(actor.get("defense", 0)),
		"magic": int(actor.get("magic", 0)),
		"spirit": int(actor.get("spirit", 0)),
		"speed": int(actor.get("speed", 0)),
		"experience": int(actor.get("experience", 0)),
		"duckets": int(actor.get("duckets", 0)),
		"actions": actor.get("actions", []).duplicate(),
		"elements": actor.get("element_rates", {}).duplicate(true),
		"status_resist": actor.get("status_resist", {}).duplicate(true),
		"sprite_path": String(actor.get("sprite_path", "")),
		"sprite_region": actor.get("sprite_region", Rect2()),
	}


static func enemy_actor(enemy_id: StringName, index: int) -> Dictionary:
	var data := BESTIARY_CONTENT.definition(enemy_id)
	var sprite_path := String(data.get("sprite_path", String(data.get("pack", HORROR_PACK)) + String(data.get("sprite", "CP_F091_SchoolgirlGhost_01.png"))))
	var sprite_region := data.get("sprite_region", Rect2()) as Rect2
	var sprite_profile := StringName(data.get("sprite_profile", &""))
	if sprite_profile != &"":
		var visual_sprite := _visual_sprite(sprite_profile)
		if visual_sprite.is_empty():
			push_error("Enemy %s requires missing visual profile %s" % [enemy_id, sprite_profile])
			return {}
		sprite_path = String(visual_sprite["sprite_path"])
		sprite_region = visual_sprite["sprite_region"] as Rect2
	var actor := _actor(StringName("%s_%d" % [enemy_id, index]), data.get("name", "Unknown Horror"), "enemy",
		int(data.get("hp", 80)), 0, int(data.get("attack", 15)), int(data.get("defense", 10)),
		int(data.get("magic", 15)), int(data.get("spirit", 10)), int(data.get("speed", 20)),
		sprite_path, data.get("actions", [&"spectral_touch"]), {})
	if sprite_region.size != Vector2.ZERO:
		actor["sprite_region"] = sprite_region
	if sprite_profile != &"":
		actor["sprite_profile"] = sprite_profile
	actor["enemy_type"] = enemy_id
	actor["element_rates"] = data.get("elements", {}).duplicate(true)
	actor["status_resist"] = data.get("status_resist", {}).duplicate(true)
	actor["experience"] = int(data.get("exp", 10))
	actor["duckets"] = int(data.get("duckets", 5))
	actor["autonomous"] = true
	if data.has("battle_animation_root"):
		actor["battle_animations"] = _battle_animation_data(data)
	return actor


static func _visual_sprite(profile_id: StringName) -> Dictionary:
	if profile_id == &"":
		push_error("A battle actor requires an approved visual profile")
		return {}
	var registry = VISUAL_PROFILE_REGISTRY.new()
	if not registry.has(profile_id):
		push_error("Battle actor requires missing visual profile %s" % profile_id)
		return {}
	var sprite_path := registry.texture_path(profile_id)
	var sprite_region := registry.region(profile_id)
	if sprite_path.is_empty() or sprite_region.size == Vector2.ZERO:
		push_error("Battle actor profile %s did not resolve a usable texture region" % profile_id)
		return {}
	return {"sprite_path": sprite_path, "sprite_region": sprite_region}


static func _apply_visual_sprite(actor: Dictionary, profile_id: StringName, visual_sprite: Dictionary) -> void:
	actor["sprite_profile"] = profile_id
	actor["sprite_region"] = visual_sprite["sprite_region"]


static func _battle_animation_data(source: Dictionary) -> Dictionary:
	var root := String(source.get("battle_animation_root", ""))
	var sequences: Dictionary = {}
	for raw_sequence in (source.get("battle_animation_sequences", {}) as Dictionary).keys():
		var sequence := StringName(raw_sequence)
		var definition: Dictionary = source["battle_animation_sequences"][raw_sequence]
		var paths: Array[String] = []
		for frame in range(int(definition.get("frames", 0))):
			paths.append("%s/%s/frame_%03d.png" % [root, String(definition.get("folder", "")), frame])
		sequences[sequence] = paths
	return {"fps": float(source.get("battle_animation_fps", 8.0)), "sequences": sequences, "actions": (source.get("battle_action_sequences", {}) as Dictionary).duplicate(true)}


static func _attach_authored_battle_animation(actor: Dictionary, character_id: StringName, catalog_entry: Dictionary = {}) -> void:
	var source: Dictionary = catalog_entry if catalog_entry.has("battle_animation_root") else AUTHORED_BATTLE_ANIMATION_SOURCES.get(character_id, {})
	if not source.is_empty():
		actor["battle_animations"] = _battle_animation_data(source)


static func _retired_encounter_catalog_snapshot() -> Dictionary:
	var encounters := {
		&"mansion_foyer_intro": {"name": "A Bad First Impression", "enemies": [&"schoolgirl_ghost", &"war_book"], "backdrop_profile": &"mansion_foyer_battle_backdrop", "scripted": true},
		&"mansion_restless_books": {"name": "Restless Stacks", "enemies": [&"war_book", &"war_book"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
		&"mansion_lost_hours": {"name": "The House Keeps Strange Hours", "enemies": [&"schoolgirl_ghost", &"clock_mirror"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
		&"mansion_gallery_ambush": {"name": "The Portraits Object", "enemies": [&"composer_portrait", &"schoolgirl_ghost"], "backdrop_profile": &"mansion_gallery_battle_backdrop", "scripted": true},
		&"mansion_restless_portraits": {"name": "Restless Exhibition", "enemies": [&"composer_portrait", &"war_book"], "backdrop_profile": &"mansion_gallery_battle_backdrop"},
		&"mansion_nursery_ambush": {"name": "Children Should Be Seen and Feared", "enemies": [&"haunted_doll", &"haunted_doll"], "backdrop_profile": &"mansion_foyer_battle_backdrop", "scripted": true},
		&"mansion_doll_procession": {"name": "The Doll Procession", "enemies": [&"haunted_doll", &"schoolgirl_ghost"], "backdrop_profile": &"mansion_foyer_battle_backdrop"},
		&"mansion_last_dance": {"name": "The Last Dance", "enemies": [&"composer_portrait", &"clock_mirror"], "backdrop_profile": &"mansion_gallery_battle_backdrop"},
		&"mansion_archive_boss": {
			"name": "Your Appointment Was 250 Years Ago", "enemies": [&"clock_mirror_boss"], "backdrop_profile": &"mansion_gallery_battle_backdrop", "scripted": true, "boss": true,
			"boss_policy": {
				"id": &"mansion_clock_mirror",
				"phases": [
					{"id": &"ticking", "label": "TICKING", "minimum_hp_ratio": 0.67, "actions": [{"action": &"spectral_touch"}, {"action": &"steal_time", "telegraph": "TICKING: The mirror's hands climb toward your ready gauges. Steal Time is coming—Defend, delay it, or tune the clock."}]},
					{"id": &"appointment", "label": "4:44 APPOINTMENT", "minimum_hp_ratio": 0.34, "actions": [{"action": &"steal_time", "telegraph": "4:44 APPOINTMENT: The clock fixes on a single future. Steal Time is coming—Defend, delay it, or tune the clock."}, {"action": &"late_fee"}]},
					{"id": &"midnight", "label": "THIRTEENTH HOUR", "minimum_hp_ratio": 0.0, "actions": [{"action": &"late_fee"}, {"action": &"steal_time", "telegraph": "THIRTEENTH HOUR: The mirror tries to take tomorrow itself. Steal Time is coming—Defend, delay it, or tune the clock."}]},
				],
			},
		},
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
	}
	return encounters


static func _encounter_catalog() -> Dictionary:
	return ENCOUNTER_CONTENT.contracts()


static func encounter_ids() -> Array[StringName]:
	return ENCOUNTER_CONTENT.ids()


static func has_encounter(encounter_id: StringName) -> bool:
	return ENCOUNTER_CONTENT.has(encounter_id)


static func encounter(encounter_id: StringName) -> Dictionary:
	var definition := ENCOUNTER_CONTENT.definition(encounter_id)
	return definition if not definition.is_empty() else ENCOUNTER_CONTENT.definition(&"mansion_restless_books")


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


static func _actor(id: StringName, display_name: String, team: String, max_hp: int, max_mp: int,
		attack_value: int, defense_value: int, magic_value: int, spirit_value: int, speed_value: int,
		sprite_path: String, actor_actions: Array, progress: Dictionary) -> Dictionary:
	return {
		"id": id, "display_name": display_name, "team": team,
		"max_hp": max_hp, "hp": clampi(int(progress.get("hp", max_hp)), 0, max_hp),
		"max_mp": max_mp, "mp": clampi(int(progress.get("mp", max_mp)), 0, max_mp),
		"attack": attack_value, "defense": defense_value, "magic": magic_value, "spirit": spirit_value, "speed": speed_value,
		"sprite_path": sprite_path, "actions": actor_actions.duplicate(), "atb": 0.0, "guarding": false,
		"attack_bonus": 0, "attack_bonus_turns": 0, "alive": true, "autonomous": false, "counts_for_defeat": true,
		"statuses": {}, "element_rates": {}, "status_resist": {}, "turn_count": 0,
	}
