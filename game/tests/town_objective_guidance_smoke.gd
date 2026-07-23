extends Node

const GUIDANCE := preload("res://ben_rpg/world/town_objective_guidance.gd")


func _ready() -> void:
	assert(GUIDANCE.asterion({}) == "ASTERION STATION  •  Survive the docking bay's automated security check.")
	assert(GUIDANCE.asterion({&"asterion_dock_cleared": true}) == "ONE SURVIVOR  •  Speak with the armed Astronaut in Docking.")
	assert(GUIDANCE.asterion({&"asterion_astronaut_met": true}) == "THE LAST SHIFT  •  Search Medical for the organic circuit that controls life support.")
	assert(GUIDANCE.asterion({&"asterion_biocircuit_found": true}) == "THE OXYGEN LOOP  •  Install the recovered biocircuit in Hydroponics.")
	assert(GUIDANCE.asterion({&"asterion_station_restored": true}) == "STATION CONTROL  •  Oxygen is stable. Appeal the final shift directly to the Mother Computer.")
	assert(GUIDANCE.asterion({&"asterion_station_complete": true, &"asterion_station_restored": true}) == "SHIFT ENDED  •  Speak with the Astronaut and offer a permanent place in Franklin & Company.")
	assert(GUIDANCE.primeval({}, []) == "PRIMEVAL EXPANSE  •  Survive the Grove's unlicensed welcoming committee.")
	assert(GUIDANCE.primeval({&"primeval_traffic_clue_found": true}, []) == "PALEO-LINGUISTICS  •  Recall to the laboratory and invent the Telegraph.")
	assert(GUIDANCE.primeval({&"primeval_terminal_decoded": true}, [&"paleo_translator"]) == "NEST ATTENDANTS  •  Follow the decoded route and defend the relay nest.")
	assert(GUIDANCE.primeval({&"primeval_scenario_complete": true, &"primeval_caldera_open": true}, []) == "COMMUTE ENDED  •  Return to the Village and offer the Caveman a permanent company position.")
	assert(GUIDANCE.helios({&"helios_curfew_clue_found": true}, []) == "LEGALIZE MIDNIGHT  •  Recall to the laboratory and build the Nocturnal Phase Inverter.")
	assert(GUIDANCE.helios({&"helios_scenario_complete": true}, []) == "MIDNIGHT RESTORED  •  Return to the Market and offer Neon Viper a permanent company position.")
	assert(GUIDANCE.frosthold({&"frosthold_causeway_seal_open": true}, []) == "RUNE HALL  •  Cross the opened seal and face the royal collection detail.")
	assert(GUIDANCE.moonpetal({&"moonpetal_bell_walk_open": true}, []) == "BELL WALK  •  Face the wedding procession guarding the final vow.")
	assert(GUIDANCE.empyreal({&"empyreal_aerie_open": true}, []) == "RELIQUARY AERIE  •  Stop the wing-repossession detail.")
	print("TOWN_OBJECTIVE_GUIDANCE_SMOKE_OK worlds=6 priority=complete")
	get_tree().quit()
