extends Node

const PRESENTATION := preload("res://ben_rpg/world/town_encounter_pressure_presentation.gd")


func _ready() -> void:
	assert(not PRESENTATION.describe({})[&"visible"])
	assert(PRESENTATION.describe({&"ward_steps": 9})[&"text"] == "RIFT WARD  •  9 SAFE STEPS")
	assert(PRESENTATION.describe({&"cooldown": 3})[&"icon"] == "dfgui_icon-shield.png")
	assert(PRESENTATION.describe({&"active": true, &"threshold": 10, &"steps": 3})[&"text"] == "ENCOUNTER PRESSURE  •  CALM")
	assert(PRESENTATION.describe({&"active": true, &"threshold": 10, &"steps": 5})[&"text"] == "ENCOUNTER PRESSURE  •  RISING")
	assert(PRESENTATION.describe({&"active": true, &"threshold": 10, &"steps": 9})[&"text"] == "ENCOUNTER PRESSURE  •  IMMINENT")
	print("TOWN_ENCOUNTER_PRESSURE_PRESENTATION_SMOKE_OK states=ward+grace+calm+rising+imminent")
	get_tree().quit()
