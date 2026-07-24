class_name CampaignActionCatalog
extends RefCounted

## Stable combat-action content, separated from actor construction and battle
## presentation so future address content can reference validated action IDs.

static var DEFINITIONS := {
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


static func ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for action_id in DEFINITIONS.keys():
		ids.append(StringName(action_id))
	ids.sort()
	return ids


static func definition(action_id: StringName) -> Dictionary:
	var definition: Dictionary = (DEFINITIONS.get(action_id, {}) as Dictionary).duplicate(true)
	if definition.is_empty():
		return {}
	definition["id"] = action_id
	match StringName(definition.get("target", &"")):
		&"enemy":
			definition["relation"] = &"hostile"
			definition["selector"] = &"single"
		&"all_enemies":
			definition["relation"] = &"hostile"
			definition["selector"] = &"all"
		&"ally":
			definition["relation"] = &"ally"
			definition["selector"] = &"single"
		&"all_allies":
			definition["relation"] = &"ally"
			definition["selector"] = &"all"
		&"ko_ally":
			definition["relation"] = &"ally"
			definition["selector"] = &"ko_single"
		&"self":
			definition["relation"] = &"self"
			definition["selector"] = &"self"
		_:
			return {}
	definition["effects"] = [{"kind": StringName(definition.get("kind", &"")), "power": int(definition.get("power", 0))}]
	return definition


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for action_id in ids():
		var action := definition(action_id)
		if action.is_empty() or String(action.get("name", "")).is_empty():
			errors.append("%s must define a name and supported target." % action_id)
		elif StringName(action.get("kind", &"")) == &"":
			errors.append("%s must define a combat kind." % action_id)
	return PackedStringArray(errors)
