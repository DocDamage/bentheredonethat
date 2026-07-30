class_name TownObjectiveGuidance
extends RefCounted

## World-specific objective priority rules.  Each method consumes immutable
## state and returns presentation data; TownBuildController applies it to HUD
## nodes and keeps responsibility for visibility and input mode.

static func mansion(story_flags: Dictionary, room: int) -> String:
	if story_flags.get(&"mansion_archive_boss_defeated", false): return "UNIVERSE STABILIZED  •  Return to town with the Multiversal Anchor Core."
	if room == 5: return "THE 4:44 APPOINTMENT  •  Defeat the reflection that has been waiting since 1776."
	if not story_flags.get(&"mansion_ballroom_open", false) and story_flags.get(&"mansion_minute_hand_found", false): return "THE BALLROOM LOCK  •  Place both recovered clock hands into the final door."
	if room == 4 and story_flags.get(&"mansion_nursery_ambush_cleared", false): return "THE BROKEN LULLABY  •  Fit the Silver Hour Hand into the nursery music box."
	if room == 4: return "THE DOLL PROCESSION  •  Secure the nursery before examining its music box."
	if room == 3 and story_flags.get(&"mansion_gallery_ambush_cleared", false): return "A PAINTED HOUR  •  Search the central portrait for the first clock hand."
	if room == 3: return "THE PORTRAITS OBJECT  •  Survive the gallery's hostile reception."
	if room == 2 and story_flags.get(&"mansion_archive_save_found", false): return "THE LOWER GALLERY  •  Follow the house's impossible records beyond the archive."
	if room == 2: return "A CLOCK THAT REMEMBERS  •  Calibrate the archive clock to restore and save."
	if story_flags.get(&"mansion_first_room_complete", false): return "SERVANTS' PASSAGE  •  The 4:44 mechanism opened the west door."
	if story_flags.get(&"mansion_ledger_found", false): return "4:44  •  Return to the stopped clock and set the hour recorded in the ledger."
	if story_flags.get(&"mansion_clock_examined", false): return "THE MISSING HOUR  •  Search the dust-covered bookcase for the household ledger."
	if story_flags.get(&"mansion_foyer_cleared", false): return "THE HOUSE KEEPS TIME  •  Examine the stopped grandfather clock."
	return "HAUNTED MANSION  •  Cross the first arch. Stay alert: active-time encounters await."

static func asterion(story_flags: Dictionary) -> String:
	if story_flags.get(&"asterion_station_complete", false):
		return "SHIFT ENDED  •  Speak with the Astronaut and offer a permanent place in Franklin & Company."
	if story_flags.get(&"asterion_station_restored", false):
		return "STATION CONTROL  •  Oxygen is stable. Appeal the final shift directly to the Mother Computer."
	if story_flags.get(&"asterion_biocircuit_found", false):
		return "THE OXYGEN LOOP  •  Install the recovered biocircuit in Hydroponics."
	if story_flags.get(&"asterion_astronaut_met", false):
		return "THE LAST SHIFT  •  Search Medical for the organic circuit that controls life support."
	if story_flags.get(&"asterion_dock_cleared", false):
		return "ONE SURVIVOR  •  Speak with the armed Astronaut in Docking."
	return "ASTERION STATION  •  Survive the docking bay's automated security check."


static func primeval(story_flags: Dictionary, owned_inventions: Array) -> String:
	if story_flags.get(&"primeval_scenario_complete", false):
		return "COMMUTE ENDED  •  Return to the Village and offer the Caveman a permanent company position."
	if story_flags.get(&"primeval_caldera_open", false):
		return "MORNING COMMUTE  •  Enter the caldera and stop the tyrant answering the meteor siren."
	if story_flags.get(&"primeval_nest_ambush_cleared", false):
		return "RELAY NEST  •  Reset the egg-shaped meteor relay and restore the party."
	if story_flags.get(&"primeval_terminal_decoded", false):
		return "NEST ATTENDANTS  •  Follow the decoded route and defend the relay nest."
	if &"paleo_translator" in owned_inventions:
		return "CAVE COMPUTER  •  Use Ben's Telegraph on the terminal in the jungle Ruins."
	if story_flags.get(&"primeval_traffic_clue_found", false):
		return "PALEO-LINGUISTICS  •  Recall to the laboratory and invent the Telegraph."
	if story_flags.get(&"primeval_grove_cleared", false):
		return "PRIMEVAL BOROUGH  •  Meet its maintainer, then inspect the stone traffic signal."
	return "PRIMEVAL EXPANSE  •  Survive the Grove's unlicensed welcoming committee."


static func helios(story_flags: Dictionary, owned_inventions: Array) -> String:
	if story_flags.get(&"helios_scenario_complete", false): return "MIDNIGHT RESTORED  •  Return to the Market and offer Neon Viper a permanent company position."
	if story_flags.get(&"helios_core_open", false): return "SOLAR CORE  •  Enter the daylight plant and shut down the Civic Sun."
	if story_flags.get(&"helios_clinic_node_disabled", false): return "TWO DARK NODES  •  The Solar Core route is open from Transit."
	if story_flags.get(&"helios_clinic_ambush_cleared", false): return "RECOVERY CLINIC  •  Disable the second daylight node."
	if story_flags.get(&"helios_transit_node_disabled", false): return "RECOVERY CLINIC  •  Cross from the Market and find the second daylight node."
	if &"night_phase_inverter" in owned_inventions: return "TRANSIT EXCHANGE  •  Use Ben's Phase Inverter on the first daylight node."
	if story_flags.get(&"helios_curfew_clue_found", false): return "LEGALIZE MIDNIGHT  •  Recall to the laboratory and build the Nocturnal Phase Inverter."
	if story_flags.get(&"helios_viper_met", false): return "MANDATORY DAYLIGHT  •  Read the ordinance terminal in the Public Market."
	if story_flags.get(&"helios_skybridge_cleared", false): return "PUBLIC MARKET  •  Find the saboteur called Neon Viper."
	return "HELIOS ARCOLOGY  •  Survive the Skybridge compliance inspection."


static func frosthold(story_flags: Dictionary, owned_inventions: Array) -> String:
	if story_flags.get(&"frosthold_scenario_complete", false): return "ROYAL AUDIT VOIDED  •  Return to the Market and offer the Frost Lich Emperor a permanent company position."
	if story_flags.get(&"frosthold_throne_open", false): return "ICE THRONE  •  Enter the treasury court and stop the Whiteout Auditor."
	if story_flags.get(&"frosthold_rune_ambush_cleared", false): return "SECOND SEAL  •  Use the Coil on the Rune Hall seal and open the Ice Throne."
	if story_flags.get(&"frosthold_causeway_seal_open", false): return "RUNE HALL  •  Cross the opened seal and face the royal collection detail."
	if &"thermal_arbitration_coil" in owned_inventions: return "CRYSTAL CAUSEWAY  •  Use Ben's Coil to warm the first royal seal."
	if story_flags.get(&"frosthold_rune_clue_found", false): return "THERMAL ARBITRATION  •  Recall to the laboratory and build Ben's Coil."
	if story_flags.get(&"frost_lich_met", false): return "HEAT TAX  •  Read the royal rune at the Crystal Causeway."
	if story_flags.get(&"frosthold_gate_cleared", false): return "FROZEN MARKET  •  Find Frosthold's deposed Lich Emperor."
	return "FROSTHOLD KINGDOM  •  Break the Snow Gate's collection patrol."


static func moonpetal(story_flags: Dictionary, owned_inventions: Array) -> String:
	if story_flags.get(&"moonpetal_scenario_complete", false): return "FALSE MOON DISMISSED  •  Return to Blossom Court and offer the Kitsune Empress a permanent company position."
	if story_flags.get(&"moonpetal_palace_open", false): return "MOON PALACE  •  Confront Magistrate Enma and end the official counterfeit night."
	if story_flags.get(&"moonpetal_bell_ambush_cleared", false): return "FINAL FALSE VOW  •  Use the Lantern at Bell Walk and open the Moon Palace."
	if story_flags.get(&"moonpetal_bell_walk_open", false): return "BELL WALK  •  Face the wedding procession guarding the final vow."
	if &"veracity_lantern" in owned_inventions: return "MIRROR GARDEN  •  Use Ben's Lantern to expose the first counterfeit vow."
	if story_flags.get(&"moonpetal_vow_clue_found", false): return "VERACITY BY ELECTRICITY  •  Recall to the laboratory and build Ben's Lantern."
	if story_flags.get(&"kitsune_empress_met", false): return "MIRROR GARDEN  •  Read the duplicated vow beneath the reflected moon."
	if story_flags.get(&"moonpetal_gate_cleared", false): return "BLOSSOM COURT  •  Find the Kitsune Empress behind the endless festival."
	return "MOONPETAL COURT  •  Break the Vermilion Gate's memory inspection."


static func empyreal(story_flags: Dictionary, owned_inventions: Array) -> String:
	if story_flags.get(&"empyreal_scenario_complete", false): return "HEAVEN GROUNDED  •  Return to the Garden and offer the Archangel Commander a permanent company position."
	if story_flags.get(&"empyreal_tribunal_open", false): return "SERAPH TRIBUNAL  •  Confront the High Comptroller of Gravity."
	if story_flags.get(&"empyreal_aerie_ambush_cleared", false): return "FINAL GRAVITY SEAL  •  Use the Counterweight in the Reliquary Aerie."
	if story_flags.get(&"empyreal_aerie_open", false): return "RELIQUARY AERIE  •  Stop the wing-repossession detail."
	if &"galvanic_counterweight" in owned_inventions: return "FIRST GRAVITY SEAL  •  Use Ben's Counterweight in the Forum."
	if story_flags.get(&"empyreal_gravity_clue_found", false): return "A TERRESTRIAL STANDARD  •  Recall to the laboratory and build the Galvanic Counterweight."
	if story_flags.get(&"archangel_commander_met", false): return "FORUM OF MEASURES  •  Read Ordinance 9-G."
	if story_flags.get(&"empyreal_landing_cleared", false): return "GARDEN OF APPEALS  •  Find the Archangel Commander."
	return "EMPYREAL COURT  •  Defeat the Cloudstep weigh-station patrol."
