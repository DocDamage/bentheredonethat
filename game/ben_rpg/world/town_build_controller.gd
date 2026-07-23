extends CanvasLayer

const FACILITY_ORDER := ["Cafe", "Library", "Clinic", "Armory"]
const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"
const AREA_PRESENCE := preload("res://ben_rpg/world/campaign_area_presence.gd")

var campaign: Node
var visual: CampaignMapVisual
var is_active := false
var selected_plot := 0
var selected_anchor_index := 0
var built_count := 0
var _objective_panel: PanelContainer
var _objective_label: Label
var _objective_icon: TextureRect
var _danger_panel: PanelContainer
var _danger_icon: TextureRect
var _danger_label: Label
var _danger_bar: ProgressBar
var _build_panel: PanelContainer
var _build_label: Label
var _was_in_town := false
var _was_in_mansion := false
var _was_in_station := false
var _was_in_primeval := false
var _was_in_helios := false
var _was_in_frosthold := false
var _was_in_moonpetal := false
var _was_in_empyreal := false
var _mansion_room := 0
var _hud_suppressed := false


func _ready() -> void:
	layer = 20
	built_count = CampaignState.built_facilities.size()
	if not CampaignState.state_changed.is_connected(_update_hud):
		CampaignState.state_changed.connect(_update_hud)
	if not CampaignState.encounter_pressure_changed.is_connected(_update_encounter_pressure):
		CampaignState.encounter_pressure_changed.connect(_update_encounter_pressure)
	_create_hud()
	_update_hud()


func _process(_delta: float) -> void:
	var suppress_hud := Cutscene.is_cutscene_in_progress()
	if suppress_hud != _hud_suppressed:
		_hud_suppressed = suppress_hud
		if suppress_hud:
			_objective_panel.hide()
			_build_panel.hide()
			_danger_panel.hide()
		else:
			_objective_panel.show()
			_update_hud()
	if suppress_hud:
		return
	var gamepiece := Player.gamepiece
	if not gamepiece:
		return
	var current_cell := Gameboard.pixel_to_cell(gamepiece.position)
	var area := AREA_PRESENCE.snapshot(campaign, current_cell)
	var is_in_town: bool = area[&"town"]
	var is_in_mansion: bool = area[&"mansion"]
	var is_in_station: bool = area[&"station"]
	var is_in_primeval: bool = area[&"primeval"]
	var is_in_helios: bool = area[&"helios"]
	var is_in_frosthold: bool = area[&"frosthold"]
	var is_in_moonpetal: bool = area[&"moonpetal"]
	var is_in_empyreal: bool = area[&"empyreal"]
	var mansion_room: int = area[&"mansion_room"]
	if is_in_town != _was_in_town or is_in_mansion != _was_in_mansion or is_in_station != _was_in_station or is_in_primeval != _was_in_primeval or is_in_helios != _was_in_helios or is_in_frosthold != _was_in_frosthold or is_in_moonpetal != _was_in_moonpetal or is_in_empyreal != _was_in_empyreal or mansion_room != _mansion_room:
		_was_in_town = is_in_town
		_was_in_mansion = is_in_mansion
		_was_in_station = is_in_station
		_was_in_primeval = is_in_primeval
		_was_in_helios = is_in_helios
		_was_in_frosthold = is_in_frosthold
		_was_in_moonpetal = is_in_moonpetal
		_was_in_empyreal = is_in_empyreal
		_mansion_room = mansion_room
		if not is_in_town and is_active:
			_set_active(false)
		_update_hud()


func _input(event: InputEvent) -> void:
	if CampaignState.sandbox_mode:
		return
	if event.is_action_pressed("town_build_mode"):
		if _was_in_town and not _current_blueprint().is_empty():
			_set_active(not is_active)
			get_viewport().set_input_as_handled()
		return
	if not is_active:
		return

	if event.is_action_pressed("back") or event.is_action_pressed("ui_cancel"):
		_set_active(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		_select_next_plot(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_select_next_plot(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_select_next_anchor(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_select_next_anchor(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_build_selected()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var plot_index := visual.get_plot_at_canvas_position(event.position)
		if plot_index >= 0 and not visual.built_facilities.has(plot_index):
			selected_plot = plot_index
			visual.set_build_state(true, selected_plot)
			_update_hud()
			if event.double_click:
				_build_selected()
		get_viewport().set_input_as_handled()


func _select_next_plot(direction: int) -> void:
	for _attempt in range(visual.FACILITY_PLOTS.size()):
		selected_plot = wrapi(selected_plot + direction, 0, visual.FACILITY_PLOTS.size())
		if not visual.built_facilities.has(selected_plot):
			break
	visual.set_build_state(true, selected_plot)
	_update_hud()


func _select_next_anchor(direction: int) -> void:
	var choices := CampaignState.available_universe_anchors()
	if choices.size() <= 1:
		return
	selected_anchor_index = wrapi(selected_anchor_index + direction, 0, choices.size())
	_update_hud()


func _build_selected() -> void:
	var facility_name := _current_blueprint()
	if facility_name.is_empty() or visual.built_facilities.has(selected_plot):
		return
	var anchor := _selected_anchor_definition()
	var universe_id := StringName(anchor.get("id", &"")) if _next_foundation_blueprint().is_empty() else &""
	if campaign.build_facility(selected_plot, facility_name, universe_id):
		# CampaignState emits synchronously while building; derive the count from
		# authoritative state instead of incrementing it a second time.
		built_count = CampaignState.built_facilities.size()
		if _current_blueprint().is_empty():
			_set_active(false)
		else:
			_select_next_plot(1)
		_update_hud()


func _set_active(value: bool) -> void:
	is_active = value
	if value and visual.built_facilities.has(selected_plot):
		_select_next_plot(1)
	FieldEvents.input_paused.emit(value)
	visual.set_build_state(value, selected_plot)
	_update_hud()


func _create_hud() -> void:
	_objective_panel = PanelContainer.new()
	_objective_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_objective_panel.offset_left = 32
	_objective_panel.offset_top = 28
	_objective_panel.offset_right = 930
	_objective_panel.offset_bottom = 102
	_objective_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_objective_panel.add_theme_stylebox_override("panel", _panel_style())
	var objective_row := HBoxContainer.new()
	objective_row.add_theme_constant_override("separation", 14)
	_objective_panel.add_child(objective_row)
	_objective_icon = TextureRect.new()
	_objective_icon.custom_minimum_size = Vector2(46, 46)
	_objective_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_objective_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_objective_icon.texture = load(UI_ROOT + "/dfgui_icon-info.png")
	objective_row.add_child(_objective_icon)
	_objective_label = Label.new()
	_objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_objective_label.add_theme_font_size_override("font_size", 30)
	_objective_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.75))
	_objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_row.add_child(_objective_label)
	add_child(_objective_panel)

	_danger_panel = PanelContainer.new()
	_danger_panel.name = "EncounterPressurePanel"
	_danger_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_danger_panel.offset_left = 1320
	_danger_panel.offset_top = 28
	_danger_panel.offset_right = 1888
	_danger_panel.offset_bottom = 116
	_danger_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_danger_panel.add_theme_stylebox_override("panel", _panel_style())
	var danger_row := HBoxContainer.new()
	danger_row.add_theme_constant_override("separation", 12)
	_danger_panel.add_child(danger_row)
	_danger_icon = TextureRect.new()
	_danger_icon.custom_minimum_size = Vector2(44, 44)
	_danger_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_danger_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_danger_icon.texture = load(UI_ROOT + "/dfgui_icon-monsterbook.png")
	danger_row.add_child(_danger_icon)
	var danger_stack := VBoxContainer.new()
	danger_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	danger_stack.add_theme_constant_override("separation", 4)
	danger_row.add_child(danger_stack)
	_danger_label = Label.new()
	_danger_label.name = "PressureLabel"
	_danger_label.add_theme_font_size_override("font_size", 23)
	_danger_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))
	danger_stack.add_child(_danger_label)
	_danger_bar = ProgressBar.new()
	_danger_bar.name = "PressureBar"
	_danger_bar.custom_minimum_size = Vector2(410, 17)
	_danger_bar.show_percentage = false
	_danger_bar.add_theme_stylebox_override("background", _bar_style(Rect2(57, 25, 147, 20), 7))
	_danger_bar.add_theme_stylebox_override("fill", _bar_style(Rect2(58, 86, 65, 7), 2))
	danger_stack.add_child(_danger_bar)
	add_child(_danger_panel)

	_build_panel = PanelContainer.new()
	_build_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_panel.offset_left = 390
	_build_panel.offset_top = 936
	_build_panel.offset_right = 1530
	_build_panel.offset_bottom = 1048
	_build_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_panel.add_theme_stylebox_override("panel", _panel_style())
	var build_row := HBoxContainer.new()
	build_row.add_theme_constant_override("separation", 14)
	_build_panel.add_child(build_row)
	var build_icon := TextureRect.new()
	build_icon.custom_minimum_size = Vector2(52, 52)
	build_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	build_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	build_icon.texture = load(UI_ROOT + "/dfgui_icon-crafthammer.png")
	build_row.add_child(build_icon)
	_build_label = Label.new()
	_build_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build_label.add_theme_font_size_override("font_size", 30)
	_build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_build_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	build_row.add_child(_build_label)
	add_child(_build_panel)


func _panel_style() -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 7)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _bar_style(region: Rect2, margin: float) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = region
	var style := StyleBoxTexture.new()
	style.texture = atlas
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, margin)
	return style


func _update_encounter_pressure(data: Dictionary) -> void:
	if not _danger_panel or _hud_suppressed:
		return
	var ward_steps := int(data.get("ward_steps", CampaignState.encounter_ward_steps))
	var cooldown := int(data.get("cooldown", 0))
	var active := bool(data.get("active", false))
	if ward_steps > 0:
		_danger_panel.show()
		_danger_icon.texture = load(UI_ROOT + "/dfgui_icon-pouch.png")
		_danger_label.text = "RIFT WARD  •  %d SAFE STEPS" % ward_steps
		_danger_label.add_theme_color_override("font_color", Color(0.5, 0.96, 1.0))
		_danger_bar.max_value = 120
		_danger_bar.value = ward_steps
		return
	if cooldown > 0:
		_danger_panel.show()
		_danger_icon.texture = load(UI_ROOT + "/dfgui_icon-shield.png")
		_danger_label.text = "ENCOUNTER GRACE  •  %d STEPS" % cooldown
		_danger_label.add_theme_color_override("font_color", Color(0.58, 0.94, 0.72))
		_danger_bar.max_value = 8
		_danger_bar.value = cooldown
		return
	if not active:
		_danger_panel.hide()
		return
	var threshold := maxi(1, int(data.get("threshold", 1)))
	var steps := clampi(int(data.get("steps", 0)), 0, threshold)
	var ratio := float(steps) / float(threshold)
	var state := "CALM" if ratio < 0.35 else ("RISING" if ratio < 0.72 else "IMMINENT")
	_danger_panel.show()
	_danger_icon.texture = load(UI_ROOT + "/dfgui_icon-monsterbook.png")
	_danger_label.text = "ENCOUNTER PRESSURE  •  %s" % state
	_danger_label.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0) if ratio < 0.35 else (Color(1.0, 0.8, 0.42) if ratio < 0.72 else Color(1.0, 0.42, 0.38)))
	_danger_bar.max_value = threshold
	_danger_bar.value = steps


func _update_hud() -> void:
	if _hud_suppressed:
		return
	built_count = CampaignState.built_facilities.size()
	_update_encounter_pressure(CampaignState.encounter_pressure)
	if CampaignState.sandbox_mode:
		_objective_icon.texture = load(UI_ROOT + "/dfgui_icon-crafthammer.png")
		_objective_label.text = "SANDBOX WORKSHOP  •  Edit terrain, pack objects, protected facilities, and resident positions in-map."
		_build_panel.show()
		_build_label.text = "B / controller Y: workshop  •  T / Select inside workshop: terrain ↔ objects"
		return
	_objective_icon.texture = load(UI_ROOT + ("/dfgui_icon-clock.png" if _was_in_mansion else ("/dfgui_icon-skillbook.png" if _was_in_station or _was_in_primeval or _was_in_helios or _was_in_frosthold or _was_in_moonpetal or _was_in_empyreal else ("/dfgui_icon-crafthammer.png" if _was_in_town else "/dfgui_icon-info.png"))))
	if _was_in_mansion:
		if CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false):
			_set_objective("UNIVERSE STABILIZED  •  Return to town with the Multiversal Anchor Core.")
		elif _mansion_room == 5:
			_set_objective("THE 4:44 APPOINTMENT  •  Defeat the reflection that has been waiting since 1776.")
		elif not CampaignState.story_flags.get(&"mansion_ballroom_open", false) and CampaignState.story_flags.get(&"mansion_minute_hand_found", false):
			_set_objective("THE BALLROOM LOCK  •  Place both recovered clock hands into the final door.")
		elif _mansion_room == 4 and CampaignState.story_flags.get(&"mansion_nursery_ambush_cleared", false):
			_set_objective("THE BROKEN LULLABY  •  Fit the Silver Hour Hand into the nursery music box.")
		elif _mansion_room == 4:
			_set_objective("THE DOLL PROCESSION  •  Secure the nursery before examining its music box.")
		elif _mansion_room == 3 and CampaignState.story_flags.get(&"mansion_gallery_ambush_cleared", false):
			_set_objective("A PAINTED HOUR  •  Search the central portrait for the first clock hand.")
		elif _mansion_room == 3:
			_set_objective("THE PORTRAITS OBJECT  •  Survive the gallery's hostile reception.")
		elif _mansion_room == 2 and CampaignState.story_flags.get(&"mansion_archive_save_found", false):
			_set_objective("THE LOWER GALLERY  •  Follow the house's impossible records beyond the archive.")
		elif _mansion_room == 2:
			_set_objective("A CLOCK THAT REMEMBERS  •  Calibrate the archive clock to restore and save.")
		elif CampaignState.story_flags.get(&"mansion_first_room_complete", false):
			_set_objective("SERVANTS' PASSAGE  •  The 4:44 mechanism opened the west door.")
		elif CampaignState.story_flags.get(&"mansion_ledger_found", false):
			_set_objective("4:44  •  Return to the stopped clock and set the hour recorded in the ledger.")
		elif CampaignState.story_flags.get(&"mansion_clock_examined", false):
			_set_objective("THE MISSING HOUR  •  Search the dust-covered bookcase for the household ledger.")
		elif CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
			_set_objective("THE HOUSE KEEPS TIME  •  Examine the stopped grandfather clock.")
		else:
			_set_objective("HAUNTED MANSION  •  Cross the first arch. Stay alert: active-time encounters await.")
		_build_panel.hide()
		return
	if _was_in_station:
		if CampaignState.story_flags.get(&"asterion_station_complete", false):
			_set_objective("SHIFT ENDED  •  Speak with the Astronaut and offer a permanent place in Franklin & Company.", true)
		elif CampaignState.story_flags.get(&"asterion_station_restored", false):
			_set_objective("STATION CONTROL  •  Oxygen is stable. Appeal the final shift directly to the Mother Computer.", true)
		elif CampaignState.story_flags.get(&"asterion_biocircuit_found", false):
			_set_objective("THE OXYGEN LOOP  •  Install the recovered biocircuit in Hydroponics.", true)
		elif CampaignState.story_flags.get(&"asterion_astronaut_met", false):
			_set_objective("THE LAST SHIFT  •  Search Medical for the organic circuit that controls life support.", true)
		elif CampaignState.story_flags.get(&"asterion_dock_cleared", false):
			_set_objective("ONE SURVIVOR  •  Speak with the armed Astronaut in Docking.", true)
		else:
			_set_objective("ASTERION STATION  •  Survive the docking bay's automated security check.", true)
		_build_panel.hide()
		return
	if _was_in_primeval:
		if CampaignState.story_flags.get(&"primeval_scenario_complete", false):
			_set_objective("COMMUTE ENDED  •  Return to the Village and offer the Caveman a permanent company position.", true)
		elif CampaignState.story_flags.get(&"primeval_caldera_open", false):
			_set_objective("MORNING COMMUTE  •  Enter the caldera and stop the tyrant answering the meteor siren.", true)
		elif CampaignState.story_flags.get(&"primeval_nest_ambush_cleared", false):
			_set_objective("RELAY NEST  •  Reset the egg-shaped meteor relay and restore the party.", true)
		elif CampaignState.story_flags.get(&"primeval_terminal_decoded", false):
			_set_objective("NEST ATTENDANTS  •  Follow the decoded route and defend the relay nest.", true)
		elif &"paleo_translator" in CampaignState.owned_inventions:
			_set_objective("CAVE COMPUTER  •  Use Ben's Telegraph on the terminal in the jungle Ruins.", true)
		elif CampaignState.story_flags.get(&"primeval_traffic_clue_found", false):
			_set_objective("PALEO-LINGUISTICS  •  Recall to the laboratory and invent the Telegraph.", true)
		elif CampaignState.story_flags.get(&"primeval_grove_cleared", false):
			_set_objective("PRIMEVAL BOROUGH  •  Meet its maintainer, then inspect the stone traffic signal.", true)
		else:
			_set_objective("PRIMEVAL EXPANSE  •  Survive the Grove's unlicensed welcoming committee.", true)
		_build_panel.hide()
		return
	if _was_in_helios:
		if CampaignState.story_flags.get(&"helios_scenario_complete", false):
			_set_objective("MIDNIGHT RESTORED  •  Return to the Market and offer Neon Viper a permanent company position.", true)
		elif CampaignState.story_flags.get(&"helios_core_open", false):
			_set_objective("SOLAR CORE  •  Enter the daylight plant and shut down the Civic Sun.", true)
		elif CampaignState.story_flags.get(&"helios_clinic_node_disabled", false):
			_set_objective("TWO DARK NODES  •  The Solar Core route is open from Transit.", true)
		elif CampaignState.story_flags.get(&"helios_clinic_ambush_cleared", false):
			_set_objective("RECOVERY CLINIC  •  Disable the second daylight node.", true)
		elif CampaignState.story_flags.get(&"helios_transit_node_disabled", false):
			_set_objective("RECOVERY CLINIC  •  Cross from the Market and find the second daylight node.", true)
		elif &"night_phase_inverter" in CampaignState.owned_inventions:
			_set_objective("TRANSIT EXCHANGE  •  Use Ben's Phase Inverter on the first daylight node.", true)
		elif CampaignState.story_flags.get(&"helios_curfew_clue_found", false):
			_set_objective("LEGALIZE MIDNIGHT  •  Recall to the laboratory and build the Nocturnal Phase Inverter.", true)
		elif CampaignState.story_flags.get(&"helios_viper_met", false):
			_set_objective("MANDATORY DAYLIGHT  •  Read the ordinance terminal in the Public Market.", true)
		elif CampaignState.story_flags.get(&"helios_skybridge_cleared", false):
			_set_objective("PUBLIC MARKET  •  Find the saboteur called Neon Viper.", true)
		else:
			_set_objective("HELIOS ARCOLOGY  •  Survive the Skybridge compliance inspection.", true)
		_build_panel.hide()
		return
	if _was_in_frosthold:
		if CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
			_set_objective("ROYAL AUDIT VOIDED  •  Return to the Market and offer the Frost Lich Emperor a permanent company position.", true)
		elif CampaignState.story_flags.get(&"frosthold_throne_open", false):
			_set_objective("ICE THRONE  •  Enter the treasury court and stop the Whiteout Auditor.", true)
		elif CampaignState.story_flags.get(&"frosthold_rune_ambush_cleared", false):
			_set_objective("SECOND SEAL  •  Use the Coil on the Rune Hall seal and open the Ice Throne.", true)
		elif CampaignState.story_flags.get(&"frosthold_causeway_seal_open", false):
			_set_objective("RUNE HALL  •  Cross the opened seal and face the royal collection detail.", true)
		elif &"thermal_arbitration_coil" in CampaignState.owned_inventions:
			_set_objective("CRYSTAL CAUSEWAY  •  Use Ben's Coil to warm the first royal seal.", true)
		elif CampaignState.story_flags.get(&"frosthold_rune_clue_found", false):
			_set_objective("THERMAL ARBITRATION  •  Recall to the laboratory and build Ben's Coil.", true)
		elif CampaignState.story_flags.get(&"frost_lich_met", false):
			_set_objective("HEAT TAX  •  Read the royal rune at the Crystal Causeway.", true)
		elif CampaignState.story_flags.get(&"frosthold_gate_cleared", false):
			_set_objective("FROZEN MARKET  •  Find Frosthold's deposed Lich Emperor.", true)
		else:
			_set_objective("FROSTHOLD KINGDOM  •  Break the Snow Gate's collection patrol.", true)
		_build_panel.hide()
		return
	if _was_in_moonpetal:
		if CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
			_set_objective("FALSE MOON DISMISSED  •  Return to Blossom Court and offer the Kitsune Empress a permanent company position.", true)
		elif CampaignState.story_flags.get(&"moonpetal_palace_open", false):
			_set_objective("MOON PALACE  •  Confront Magistrate Enma and end the official counterfeit night.", true)
		elif CampaignState.story_flags.get(&"moonpetal_bell_ambush_cleared", false):
			_set_objective("FINAL FALSE VOW  •  Use the Lantern at Bell Walk and open the Moon Palace.", true)
		elif CampaignState.story_flags.get(&"moonpetal_bell_walk_open", false):
			_set_objective("BELL WALK  •  Face the wedding procession guarding the final vow.", true)
		elif &"veracity_lantern" in CampaignState.owned_inventions:
			_set_objective("MIRROR GARDEN  •  Use Ben's Lantern to expose the first counterfeit vow.", true)
		elif CampaignState.story_flags.get(&"moonpetal_vow_clue_found", false):
			_set_objective("VERACITY BY ELECTRICITY  •  Recall to the laboratory and build Ben's Lantern.", true)
		elif CampaignState.story_flags.get(&"kitsune_empress_met", false):
			_set_objective("MIRROR GARDEN  •  Read the duplicated vow beneath the reflected moon.", true)
		elif CampaignState.story_flags.get(&"moonpetal_gate_cleared", false):
			_set_objective("BLOSSOM COURT  •  Find the Kitsune Empress behind the endless festival.", true)
		else:
			_set_objective("MOONPETAL COURT  •  Break the Vermilion Gate's memory inspection.", true)
		_build_panel.hide()
		return
	if _was_in_empyreal:
		if CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
			_set_objective("HEAVEN GROUNDED  •  Return to the Garden and offer the Archangel Commander a permanent company position.", true)
		elif CampaignState.story_flags.get(&"empyreal_tribunal_open", false):
			_set_objective("SERAPH TRIBUNAL  •  Confront the High Comptroller of Gravity.", true)
		elif CampaignState.story_flags.get(&"empyreal_aerie_ambush_cleared", false):
			_set_objective("FINAL GRAVITY SEAL  •  Use the Counterweight in the Reliquary Aerie.", true)
		elif CampaignState.story_flags.get(&"empyreal_aerie_open", false):
			_set_objective("RELIQUARY AERIE  •  Stop the wing-repossession detail.", true)
		elif &"galvanic_counterweight" in CampaignState.owned_inventions:
			_set_objective("FIRST GRAVITY SEAL  •  Use Ben's Counterweight in the Forum.", true)
		elif CampaignState.story_flags.get(&"empyreal_gravity_clue_found", false):
			_set_objective("A TERRESTRIAL STANDARD  •  Recall to the laboratory and build the Galvanic Counterweight.", true)
		elif CampaignState.story_flags.get(&"archangel_commander_met", false):
			_set_objective("FORUM OF MEASURES  •  Read Ordinance 9-G.", true)
		elif CampaignState.story_flags.get(&"empyreal_landing_cleared", false):
			_set_objective("GARDEN OF APPEALS  •  Find the Archangel Commander.", true)
		else:
			_set_objective("EMPYREAL COURT  •  Defeat the Cloudstep weigh-station patrol.", true)
		_build_panel.hide()
		return
	if _next_foundation_blueprint().is_empty():
		var fighter_status: StringName = CampaignState.recruit_status.get(&"fighter", &"undiscovered")
		if fighter_status == &"available":
			_set_objective("FIRST HIRE  •  A fighter is waiting beside the Café. Speak with him before opening a universe.")
			_build_panel.show()
			_build_label.text = "M / controller Select: manage facilities • Ben can lead eligible work"
		elif not CampaignState.story_flags.get(&"haunted_mansion_anchor_built", false):
			_set_objective("FIRST ANCHOR  •  Build the supplied Haunted Mansion blueprint in the remaining town plot.")
			_build_panel.show()
			if is_active:
				_build_label.text = _anchor_build_prompt()
			else:
				_build_label.text = "Press B or controller Y to place the mandatory first universe anchor"
		elif CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false) and not CampaignState.story_flags.get(&"asterion_anchor_built", false):
			_set_objective("A SECOND DOOR  •  Build the Observatory and anchor Asterion Station in the new plot.")
			_build_panel.show()
			if is_active:
				_build_label.text = _anchor_build_prompt()
			else:
				_build_label.text = "Press B or controller Y to choose a universe and its town plot"
		elif CampaignState.story_flags.get(&"asterion_anchor_built", false) and not CampaignState.story_flags.get(&"asterion_station_complete", false):
			_set_objective("ASTERION STATION  •  Enter through the Observatory and investigate its final shift.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		elif CampaignState.story_flags.get(&"asterion_station_complete", false) and not CampaignState.available_universe_anchors().is_empty():
			var discovered_names: Array[String] = []
			for anchor in CampaignState.available_universe_anchors():
				discovered_names.append(String(anchor.get("name", "Unknown Universe")))
			_set_objective("CHOOSE THE NEXT ANCHOR  •  %s" % " or ".join(discovered_names))
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to compare discovered universes and choose a town plot"
		elif CampaignState.story_flags.get(&"asterion_station_complete", false) and not CampaignState.story_flags.get(&"primeval_anchor_built", false):
			_set_objective("THE OLDEST ADDRESS  •  Build the Trailhead Lodge and anchor the Primeval Expanse.")
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to anchor the next discovered universe"
		elif CampaignState.story_flags.get(&"primeval_anchor_built", false) and not CampaignState.story_flags.get(&"primeval_scenario_complete", false):
			_set_objective("PRIMEVAL EXPANSE  •  Enter through the Trailhead Lodge and investigate its impossible traffic system.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		elif CampaignState.story_flags.get(&"primeval_scenario_complete", false) and not CampaignState.story_flags.get(&"helios_anchor_built", false):
			_set_objective("A BRIGHTER NIGHT  •  Build the Afterlight Club and anchor Helios Arcology.")
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to anchor the next discovered universe"
		elif CampaignState.story_flags.get(&"helios_anchor_built", false) and not CampaignState.story_flags.get(&"helios_scenario_complete", false):
			_set_objective("HELIOS ARCOLOGY  •  Enter through the Afterlight Club and investigate its mandatory daylight ordinance.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		elif CampaignState.story_flags.get(&"helios_scenario_complete", false) and not CampaignState.story_flags.get(&"frosthold_anchor_built", false):
			_set_objective("A COLDER ADDRESS  •  Build Cold Storage and anchor Frosthold Kingdom.")
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to anchor the next discovered universe"
		elif CampaignState.story_flags.get(&"frosthold_anchor_built", false) and not CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
			_set_objective("FROSTHOLD KINGDOM  •  Enter through Cold Storage and investigate the royal heat tax.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		elif CampaignState.story_flags.get(&"frosthold_scenario_complete", false) and not CampaignState.story_flags.get(&"moonpetal_anchor_built", false):
			_set_objective("TEA BEYOND WINTER  •  Build the Tea House and anchor Moonpetal Court.")
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to anchor the next discovered universe"
		elif CampaignState.story_flags.get(&"moonpetal_anchor_built", false) and not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
			_set_objective("MOONPETAL COURT  •  Enter through the Tea House and investigate the memory tax.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		elif CampaignState.story_flags.get(&"moonpetal_scenario_complete", false) and not CampaignState.story_flags.get(&"empyreal_anchor_built", false):
			_set_objective("BELLS ABOVE THE CLOUDS  •  Build the Belfry and anchor Empyreal Court.")
			_build_panel.show()
			_build_label.text = _anchor_build_prompt() if is_active else "Press B or controller Y to anchor the next discovered universe"
		elif CampaignState.story_flags.get(&"empyreal_anchor_built", false) and not CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
			_set_objective("EMPYREAL COURT  •  Enter through the Belfry and investigate the gravity ordinance.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
		else:
			_set_objective("THE FIRST DOOR  •  Enter the Haunted Mansion. The town side remains safe.")
			_build_panel.show()
			_build_label.text = "M / controller Select: staff facilities, run idle jobs, and collect rewards"
	elif _was_in_town:
		_set_objective("FOUNDING NEW PHILADELPHIA  •  Build Café, Library, Clinic, Armory  (%d/4)" % _founding_facility_count())
		_build_panel.show()
		if is_active:
			_build_label.text = "BUILD: %s  •  Plot %d  •  ←/→ choose  •  A/Enter build  •  B/Esc close" % [_next_foundation_blueprint(), selected_plot + 1]
		else:
			_build_label.text = "Press B or controller Y to enter town construction mode"
	else:
		_set_objective("A FAULT IN REALITY  •  Leave the laboratory and survey the empty town.")
		_build_panel.hide()


func _set_objective(fallback: String, prefer_fallback := false) -> void:
	if prefer_fallback:
		_objective_label.text = fallback
		return
	var tracked := CampaignState.tracked_objective()
	if tracked.is_empty():
		_objective_label.text = fallback
		return
	_objective_label.text = "%s  •  %s" % [String(tracked.get("title", "Quest")).to_upper(), tracked.get("objective", fallback)]
	var icon_path := UI_ROOT + "/" + String(tracked.get("icon", "dfgui_icon-info.png"))
	if ResourceLoader.exists(icon_path):
		_objective_icon.texture = load(icon_path)


func _current_blueprint() -> String:
	var founding_blueprint := _next_foundation_blueprint()
	if not founding_blueprint.is_empty():
		return founding_blueprint
	return String(_selected_anchor_definition().get("building", ""))


func _next_foundation_blueprint() -> String:
	for facility_name in FACILITY_ORDER:
		if facility_name not in CampaignState.built_facilities.values():
			return facility_name
	return ""


func _founding_facility_count() -> int:
	var count := 0
	for facility_name in FACILITY_ORDER:
		if facility_name in CampaignState.built_facilities.values():
			count += 1
	return count


func _selected_anchor_definition() -> Dictionary:
	var choices := CampaignState.available_universe_anchors()
	if choices.is_empty():
		selected_anchor_index = 0
		return {}
	selected_anchor_index = clampi(selected_anchor_index, 0, choices.size() - 1)
	return choices[selected_anchor_index]


func _anchor_build_prompt() -> String:
	var anchor := _selected_anchor_definition()
	if anchor.is_empty():
		return "No stable universe addresses are currently available."
	var choice_hint := "↑/↓ universe  •  " if CampaignState.available_universe_anchors().size() > 1 else ""
	return "ANCHOR: %s  •  SHELL: %s  •  Plot %d  •  %s←/→ plot  •  A/Enter build" % [
		String(anchor.get("name", "Unknown Universe")), String(anchor.get("building", "Building")), selected_plot + 1, choice_hint,
	]
