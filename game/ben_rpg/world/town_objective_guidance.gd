class_name TownObjectiveGuidance
extends RefCounted

## World-specific objective priority rules.  Each method consumes immutable
## state and returns presentation data; TownBuildController applies it to HUD
## nodes and keeps responsibility for visibility and input mode.

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
