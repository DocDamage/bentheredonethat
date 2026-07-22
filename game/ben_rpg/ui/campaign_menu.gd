class_name CampaignMenu
extends CanvasLayer

signal menu_closed

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"
const UI_BUTTON := UI_ROOT + "/dfgui_button-empty.png"
const CHARACTER_PORTRAITS := {
	&"ben": "res://game_assets/characters/Main Character/Ben_Franklin/rotations/south.png",
	&"fighter": "res://game_assets/characters/Recruitable Characters/Fighter/Fighter/rotations/south.png",
	&"astronaut": "res://game_assets/characters/Recruitable Characters/astronaut/Astronaut/rotations/south.png",
}
const CHARACTER_PORTRAIT_REGIONS := {
	&"ben": Rect2(20, 15, 48, 58),
	&"fighter": Rect2(30, 24, 62, 76),
	&"astronaut": Rect2(0, 0, 64, 64),
}

var campaign: Node
var suppress_persistence := false
var management_location_override := -1
var selected_character: StringName = &"ben"
var selected_tab := &"equipment"
var selected_slot := &"weapon"
var selected_facility := ""
var selected_service := ""
var selected_quest: StringName = &""
var selected_enemy: StringName = &""
var _last_facility_result: Dictionary = {}
var _last_service_message := ""
var _last_inventory_message := ""
var _root: Control
var _character_buttons: HBoxContainer
var _tab_buttons: HBoxContainer
var _portrait: TextureRect
var _profile_name: Label
var _stats: Label
var _content: VBoxContainer
var _header_currency: Label
var _first_focus: Button
var _active_job_timer: Label


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	CampaignState.state_changed.connect(_on_state_changed)
	hide()


func _process(_delta: float) -> void:
	# Poll the toggle while processing ALWAYS. A focused Control can consume
	# joypad/keyboard events before _unhandled_input, but it cannot swallow the
	# action state, so Start/Tab remains reliable inside every menu page.
	if Input.is_action_just_pressed("campaign_menu"):
		if visible:
			close_menu()
		elif not Cutscene.is_cutscene_in_progress() and not _battle_is_active():
			open_menu()
	elif InputMap.has_action("facility_management") and Input.is_action_just_pressed("facility_management") and not _sandbox_editor_active():
		if visible:
			if selected_tab == &"facilities":
				close_menu()
			else:
				_select_tab(&"facilities")
		elif _at_company_management_location() and not Cutscene.is_cutscene_in_progress() and not _battle_is_active():
			open_menu(&"facilities")
	elif InputMap.has_action("quest_journal") and Input.is_action_just_pressed("quest_journal"):
		if visible:
			if selected_tab == &"quests":
				close_menu()
			else:
				_select_tab(&"quests")
		elif not Cutscene.is_cutscene_in_progress() and not _battle_is_active():
			open_menu(&"quests")
	elif InputMap.has_action("roster_menu") and Input.is_action_just_pressed("roster_menu"):
		if visible:
			if selected_tab == &"roster":
				close_menu()
			else:
				_select_tab(&"roster")
		elif not Cutscene.is_cutscene_in_progress() and not _battle_is_active():
			open_menu(&"roster")
	elif InputMap.has_action("anchor_recall") and Input.is_action_just_pressed("anchor_recall"):
		if visible:
			if selected_tab == &"recall":
				close_menu()
			else:
				_select_tab(&"recall")
		elif not Cutscene.is_cutscene_in_progress() and not _battle_is_active():
			open_menu(&"recall")
	if visible and selected_tab == &"facilities":
		_update_active_job_timer()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("back") or event.is_action_pressed("ui_cancel")):
		close_menu()
		get_viewport().set_input_as_handled()


func open_menu(initial_tab: StringName = &"") -> void:
	if CampaignState.party.is_empty():
		return
	if initial_tab in [&"equipment", &"skills", &"inventory", &"facilities", &"quests", &"bestiary", &"roster", &"recall", &"services"]:
		selected_tab = initial_tab
	if selected_character not in CampaignState.party:
		selected_character = CampaignState.party[0]
	FieldEvents.input_paused.emit(true)
	show()
	_refresh()
	if _first_focus:
		_first_focus.grab_focus()


func close_menu() -> void:
	var was_visible := visible
	hide()
	FieldEvents.input_paused.emit(false)
	if was_visible:
		menu_closed.emit()


func open_service(facility_name: String) -> void:
	if facility_name not in _built_facility_names() or facility_name not in ["Cafe", "Library", "Clinic", "Armory"]:
		return
	selected_service = facility_name
	_last_service_message = ""
	open_menu(&"services")


func _battle_is_active() -> bool:
	var battle := campaign.get_node_or_null("CampaignBattle") if campaign else null
	return battle != null and battle.active


func _sandbox_editor_active() -> bool:
	var editor = campaign.get_node_or_null("SandboxTownEditor") if campaign else null
	return editor != null and bool(editor.active)


func _build_interface() -> void:
	_root = Control.new()
	_root.name = "CompanyMenu"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.012, 0.025, 0.92)
	_root.add_child(shade)

	var panel := PanelContainer.new()
	panel.position = Vector2(110, 58)
	panel.size = Vector2(1700, 964)
	panel.add_theme_stylebox_override("panel", _panel_style())
	_root.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 70
	layout.add_child(header)
	var crest := TextureRect.new()
	crest.custom_minimum_size = Vector2(58, 58)
	crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crest.texture = load(UI_ROOT + "/dfgui_icon-crown.png")
	header.add_child(crest)
	var title := Label.new()
	title.text = "FRANKLIN & COMPANY"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)
	_header_currency = Label.new()
	_header_currency.custom_minimum_size.x = 420
	_header_currency.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_header_currency.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_header_currency.add_theme_font_size_override("font_size", 28)
	header.add_child(_header_currency)

	_character_buttons = HBoxContainer.new()
	_character_buttons.add_theme_constant_override("separation", 10)
	layout.add_child(_character_buttons)
	_tab_buttons = HBoxContainer.new()
	_tab_buttons.add_theme_constant_override("separation", 10)
	layout.add_child(_tab_buttons)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	layout.add_child(body)
	var profile_panel := PanelContainer.new()
	profile_panel.custom_minimum_size = Vector2(430, 0)
	profile_panel.add_theme_stylebox_override("panel", _panel_style())
	body.add_child(profile_panel)
	var profile := VBoxContainer.new()
	profile.alignment = BoxContainer.ALIGNMENT_CENTER
	profile.add_theme_constant_override("separation", 12)
	profile_panel.add_child(profile)
	_profile_name = Label.new()
	_profile_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_profile_name.add_theme_font_size_override("font_size", 34)
	_profile_name.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
	profile.add_child(_profile_name)
	var portrait_well := Control.new()
	portrait_well.custom_minimum_size = Vector2(300, 300)
	profile.add_child(portrait_well)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(78, 56)
	_portrait.size = Vector2(144, 188)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_well.add_child(_portrait)
	# Display the supplied 116px ornamental portrait frame at an exact 2x
	# scale. Previously the character floated in a generic empty 300px box.
	var portrait_frame := TextureRect.new()
	portrait_frame.position = Vector2(34, 34)
	portrait_frame.size = Vector2(232, 232)
	portrait_frame.texture = load(UI_ROOT + "/dfgui_portraitframe2.png")
	portrait_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_well.add_child(portrait_frame)
	portrait_well.move_child(portrait_frame, 0)
	_stats = Label.new()
	_stats.add_theme_font_size_override("font_size", 25)
	_stats.add_theme_color_override("font_color", Color(0.87, 0.91, 1.0))
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile.add_child(_stats)

	var content_panel := PanelContainer.new()
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.add_theme_stylebox_override("panel", _panel_style())
	body.add_child(content_panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_panel.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 9)
	scroll.add_child(_content)

	var footer := Label.new()
	footer.text = "Tab / Start: close   •   K / L3: recall   •   J: journal   •   R: roster   •   M / Select: facilities   •   D-pad / arrows: navigate   •   A / Enter: confirm   •   B / Esc: back"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 22)
	footer.add_theme_color_override("font_color", Color(0.62, 0.72, 0.84))
	layout.add_child(footer)


func _refresh() -> void:
	_first_focus = null
	_active_job_timer = null
	if selected_character not in CampaignState.party and not CampaignState.party.is_empty():
		selected_character = CampaignState.party[0]
	_header_currency.text = "%d DUCKETS\n%s" % [CampaignState.duckets, "LABORATORY — FREE RESETS" if _at_laboratory() else "FIELD LOADOUT"]
	_refresh_character_buttons()
	_refresh_tabs()
	_refresh_profile()
	_clear_children(_content)
	match selected_tab:
		&"services":
			_build_service_page()
		&"recall":
			_build_recall_page()
		&"roster":
			_build_roster_page()
		&"quests":
			_build_quest_page()
		&"bestiary":
			_build_bestiary_page()
		&"facilities":
			_build_facilities_page()
		&"skills":
			_build_skill_page()
		&"inventory":
			_build_inventory_page()
		_:
			_build_equipment_page()


func _refresh_character_buttons() -> void:
	_clear_children(_character_buttons)
	for character_id in CampaignState.party:
		var progress: Dictionary = CampaignState.character_progress.get(character_id, {})
		var button := Button.new()
		button.text = "%s   LV %d" % [CampaignState.recruit_catalog.get(character_id, {}).get("name", character_id), int(progress.get("level", 1))]
		button.custom_minimum_size = Vector2(330, 54)
		button.button_pressed = character_id == selected_character
		_apply_button_skin(button, UI_ROOT + "/dfgui_portraitframe.png")
		button.pressed.connect(_select_character.bind(character_id))
		_character_buttons.add_child(button)


func _refresh_tabs() -> void:
	_clear_children(_tab_buttons)
	var tabs := [
		[&"equipment", "EQUIPMENT", "/dfgui_icon-helmet.png"],
		[&"skills", "SKILL TREE", "/dfgui_icon-skillbook.png"],
		[&"inventory", "INVENTORY", "/dfgui_icon-chest.png"],
		[&"facilities", "FACILITIES", "/dfgui_icon-crafthammer.png"],
		[&"quests", "QUESTS", "/dfgui_icon-redbook.png"],
		[&"bestiary", "BESTIARY", "/dfgui_icon-monsterbook.png"],
		[&"roster", "ROSTER", "/dfgui_icon-shield.png"],
		[&"recall", "RECALL", "/dfgui_icon-wand.png"],
	]
	if selected_tab == &"services" and not selected_service.is_empty():
		var service_icon := String(CampaignState.facility_definition(selected_service).get("icon", "dfgui_icon-info.png"))
		tabs.append([&"services", selected_service.to_upper(), "/" + service_icon])
	for data in tabs:
		var button := Button.new()
		button.text = data[1]
		button.name = "%sTab" % String(data[0]).capitalize()
		button.custom_minimum_size = Vector2(156, 56)
		_apply_button_skin(button, UI_ROOT + data[2])
		button.pressed.connect(_select_tab.bind(StringName(data[0])))
		_tab_buttons.add_child(button)
		if StringName(data[0]) == selected_tab:
			button.add_theme_color_override("font_color", Color(0.5, 0.92, 1.0))
		if not _first_focus:
			_first_focus = button


func _refresh_profile() -> void:
	var progress: Dictionary = CampaignState.character_progress.get(selected_character, {})
	var actor := CampaignCombatDatabase.party_actor(selected_character, progress)
	_profile_name.text = String(actor.get("display_name", selected_character))
	var recruit: Dictionary = CampaignState.recruit_catalog.get(selected_character, {})
	var asset_pack := String(recruit.get("asset_pack", "Main Character/Ben_Franklin"))
	var portrait_path := String(CHARACTER_PORTRAITS.get(selected_character, recruit.get("portrait_path", "res://game_assets/characters/%s/rotations/south.png" % asset_pack)))
	if not ResourceLoader.exists(portrait_path):
		portrait_path = CHARACTER_PORTRAITS[&"ben"]
	var portrait_texture := load(portrait_path) as Texture2D
	var portrait_atlas := AtlasTexture.new()
	portrait_atlas.atlas = portrait_texture
	portrait_atlas.region = CHARACTER_PORTRAIT_REGIONS.get(selected_character, recruit.get("portrait_region", Rect2(Vector2.ZERO, portrait_texture.get_size())))
	_portrait.texture = portrait_atlas
	_stats.text = "LEVEL %d     EXP %d\nHP %d / %d     MP %d / %d\nATK %d   DEF %d\nMAG %d   SPR %d   SPD %d\nSKILL POINTS  %d" % [
		int(progress.get("level", 1)), int(progress.get("exp", 0)), int(progress.get("hp", actor["max_hp"])), actor["max_hp"],
		int(progress.get("mp", actor["max_mp"])), actor["max_mp"], actor["attack"], actor["defense"], actor["magic"], actor["spirit"], actor["speed"], int(progress.get("skill_points", 0)),
	]


func _build_equipment_page() -> void:
	_add_heading("SIX-SLOT LOADOUT", UI_ROOT + "/dfgui_icon-helmet.png")
	var progress: Dictionary = CampaignState.character_progress[selected_character]
	var equipment: Dictionary = progress.get("equipment", {})
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 8)
	_content.add_child(slots)
	for slot in CampaignState.EQUIPMENT_SLOTS:
		var item := CampaignState.loot_by_instance(String(equipment.get(slot, "")))
		var button := Button.new()
		button.text = "%s\n%s" % [String(slot).to_upper(), item.get("display_name", "— EMPTY —")]
		button.custom_minimum_size = Vector2(185, 82)
		button.tooltip_text = _item_details(item)
		_apply_button_skin(button, String(item.get("icon", UI_ROOT + "/dfgui_button-empty.png")))
		button.pressed.connect(_select_slot.bind(slot))
		slots.add_child(button)
		if slot == selected_slot:
			button.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))

	_add_subheading("AVAILABLE FOR %s" % String(selected_slot).to_upper())
	var equipped_id := String(equipment.get(selected_slot, ""))
	if not equipped_id.is_empty():
		var remove := Button.new()
		remove.text = "UNEQUIP CURRENT ITEM"
		remove.custom_minimum_size.y = 52
		_apply_button_skin(remove, UI_ROOT + "/dfgui_icon-wardrobe.png")
		remove.pressed.connect(_unequip_selected)
		_content.add_child(remove)
	var candidates := 0
	for item in CampaignState.loot_inventory:
		if StringName(item.get("slot", "")) != selected_slot:
			continue
		var allowed: Array = item.get("allowed_characters", [])
		if not allowed.is_empty() and selected_character not in allowed and String(selected_character) not in allowed:
			continue
		candidates += 1
		var button := Button.new()
		button.text = "%s   •   %s" % [item.get("display_name", "Unknown item"), _modifier_summary(item)]
		button.custom_minimum_size.y = 58
		button.tooltip_text = _item_details(item)
		_apply_button_skin(button, String(item.get("icon", UI_ROOT + "/dfgui_icon-pouch.png")))
		button.disabled = String(item.get("instance_id", "")) == equipped_id
		button.pressed.connect(_equip_item.bind(String(item.get("instance_id", ""))))
		_content.add_child(button)
	if candidates == 0:
		_add_notice("No %s gear has been recovered yet." % selected_slot, Color(0.68, 0.72, 0.8))


func _build_skill_page() -> void:
	var progress: Dictionary = CampaignState.character_progress[selected_character]
	var learned: Array = progress.get("learned_skills", [])
	_add_heading("%s SPECIALTY TREE   •   %d SP" % [CampaignState.recruit_catalog[selected_character]["specialty"].to_upper(), int(progress.get("skill_points", 0))], UI_ROOT + "/dfgui_icon-skillbook.png")
	for skill in CampaignState.skill_tree(selected_character):
		var skill_id := StringName(skill["id"])
		var is_learned := skill_id in learned
		var requirements_met := true
		for requirement in skill.get("requires", []):
			requirements_met = requirements_met and StringName(requirement) in learned
		var button := Button.new()
		button.text = "%s   %s\n%s" % ["◆" if is_learned else "◇", skill["name"], skill["description"]]
		button.custom_minimum_size.y = 76
		button.disabled = is_learned or not requirements_met or int(progress.get("skill_points", 0)) < int(skill.get("cost", 1))
		button.tooltip_text = "Cost: %d SP%s" % [int(skill.get("cost", 1)), "   Requires: " + ", ".join(skill.get("requires", [])) if not skill.get("requires", []).is_empty() else ""]
		_apply_button_skin(button, UI_ROOT + ("/dfgui_icon-wand.png" if selected_character == &"ben" else "/dfgui_icon-sword.png"))
		button.pressed.connect(_learn_skill.bind(skill_id))
		_content.add_child(button)
	var reset := Button.new()
	reset.text = "RESET SPECIALTY TREE — FREE AT BEN'S LABORATORY" if _at_laboratory() else "RESET LOCKED — RETURN TO BEN'S LABORATORY"
	reset.custom_minimum_size.y = 58
	reset.disabled = not _at_laboratory() or learned.is_empty()
	_apply_button_skin(reset, UI_ROOT + "/dfgui_icon-crafthammer.png")
	reset.pressed.connect(_reset_skills)
	_content.add_child(reset)


func _build_inventory_page() -> void:
	_add_heading("COMPANY INVENTORY", UI_ROOT + "/dfgui_icon-chest.png")
	var target_name := String(CampaignState.recruit_catalog.get(selected_character, {}).get("name", String(selected_character)))
	_add_subheading("FIELD ITEMS • TARGET: %s" % target_name.to_upper())
	_add_notice("Choose an active character from the portrait row, then use a restorative below. Rift Wards protect the whole expedition; scripted encounters ignore them.", Color(0.76, 0.84, 0.98))
	if not _last_inventory_message.is_empty():
		_add_notice(_last_inventory_message, Color(0.54, 1.0, 0.68))
	var field_item_ids: Array[StringName] = [&"tonic", &"ether", &"phoenix_tonic", &"smelling_salts", &"rift_ward", &"provisions"]
	for item_id in field_item_ids:
		var quantity := int(CampaignState.inventory.get(item_id, 0))
		if quantity <= 0 and item_id not in [&"tonic", &"ether", &"phoenix_tonic", &"rift_ward"]:
			continue
		var definition := CampaignState.field_item_definition(item_id)
		var preview := CampaignState.field_item_use_preview(item_id, selected_character)
		var button := Button.new()
		button.name = "UseField%s" % String(item_id).to_pascal_case()
		button.text = "%s   ×%d\n%s" % [String(definition.get("name", String(item_id).replace("_", " ").capitalize())), quantity, String(preview.get("reason", definition.get("description", "")))]
		button.custom_minimum_size.y = 70
		button.disabled = not bool(preview.get("usable", false))
		button.tooltip_text = String(definition.get("description", preview.get("reason", "")))
		_apply_button_skin(button, UI_ROOT + "/" + String(definition.get("icon", "dfgui_icon-pouch.png")))
		button.pressed.connect(_use_field_inventory_item.bind(item_id))
		_content.add_child(button)
	_add_subheading("KEY ITEMS & MATERIALS")
	for raw_item_id in CampaignState.inventory.keys():
		var item_id := StringName(raw_item_id)
		if item_id in field_item_ids:
			continue
		_add_notice("%s   ×%d" % [String(item_id).replace("_", " ").capitalize(), int(CampaignState.inventory[raw_item_id])], Color(0.88, 0.91, 1.0))
	_add_subheading("EQUIPMENT  •  %d ITEMS" % CampaignState.loot_inventory.size())
	if CampaignState.loot_inventory.is_empty():
		_add_notice("No equipment recovered.", Color(0.68, 0.72, 0.8))
	for item in CampaignState.loot_inventory:
		var owner := _item_owner(String(item.get("instance_id", "")))
		var row := HBoxContainer.new()
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(54, 54)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var icon_path := String(item.get("icon", ""))
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
		row.add_child(icon)
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = "%s\n%s%s" % [item.get("display_name", "Unknown item"), _modifier_summary(item), "   •   Equipped: " + owner if not owner.is_empty() else ""]
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color.from_string(item.get("rarity_color", "#d8d3c5"), Color.WHITE))
		row.add_child(label)
		_content.add_child(row)


func _build_bestiary_page() -> void:
	_add_heading("LIBRARY BESTIARY", UI_ROOT + "/dfgui_icon-monsterbook.png")
	if not CampaignState.sandbox_mode and "Library" not in _built_facility_names():
		_add_notice("Build the Library to turn Ben's battle notes into a searchable monster record.", Color(1.0, 0.72, 0.4))
		return
	var summary := CampaignState.bestiary_summary()
	_add_notice("SPECIES RECORDED  %d / %d     •     SPECIES DEFEATED  %d     •     TOTAL DEFEATED  %d     •     BOSSES  %d" % [
		int(summary.get("species_seen", 0)), int(summary.get("species_total", 0)), int(summary.get("species_defeated", 0)),
		int(summary.get("total_defeated", 0)), int(summary.get("bosses_defeated", 0)),
	], Color(0.55, 0.92, 1.0))
	var discovered := CampaignState.discovered_bestiary_ids()
	if discovered.is_empty():
		_add_notice("No hostile species have been recorded. Enter a dangerous universe and survive an encounter to begin the ledger.", Color(0.68, 0.72, 0.8))
		return
	if selected_enemy not in discovered:
		selected_enemy = discovered[0]
	_build_bestiary_detail(selected_enemy)
	_add_subheading("RECORDED SPECIES")
	var catalog_grid := GridContainer.new()
	catalog_grid.columns = 2
	catalog_grid.add_theme_constant_override("h_separation", 8)
	catalog_grid.add_theme_constant_override("v_separation", 7)
	_content.add_child(catalog_grid)
	for enemy_id in discovered:
		var entry := CampaignCombatDatabase.bestiary_entry(enemy_id)
		var record := CampaignState.bestiary_record(enemy_id)
		var button := Button.new()
		button.name = "Bestiary_%s" % enemy_id
		button.text = "%s%s\n%s • SEEN %d • DEFEATED %d" % [
			"★ " if bool(entry.get("boss", false)) else "", String(entry.get("name", enemy_id)).to_upper(),
			entry.get("region", "Unknown"), int(record.get("seen", 0)), int(record.get("defeated", 0)),
		]
		button.custom_minimum_size = Vector2(520, 68)
		button.tooltip_text = "Open this species record."
		_apply_button_skin(button, UI_ROOT + ("/dfgui_icon-crown.png" if bool(entry.get("boss", false)) else "/dfgui_icon-monsterbook.png"))
		button.pressed.connect(_select_bestiary_enemy.bind(enemy_id))
		if enemy_id == selected_enemy:
			button.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))
		catalog_grid.add_child(button)


func _build_bestiary_detail(enemy_id: StringName) -> void:
	var entry := CampaignCombatDatabase.bestiary_entry(enemy_id)
	var record := CampaignState.bestiary_record(enemy_id)
	var defeated := int(record.get("defeated", 0))
	var panel := PanelContainer.new()
	panel.name = "BestiaryDetail"
	panel.add_theme_stylebox_override("panel", _panel_style())
	_content.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)
	var portrait := TextureRect.new()
	portrait.name = "BestiaryPortrait"
	portrait.custom_minimum_size = Vector2(220, 190)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.texture = _bestiary_texture(entry)
	row.add_child(portrait)
	var details := Label.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_font_size_override("font_size", 23)
	details.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	var title := "%s%s%s\n%s\nSEEN %d • DEFEATED %d • FORMATIONS %d" % [
		"★ BOSS • " if bool(entry.get("boss", false)) else "", "RECRUITABLE • " if bool(entry.get("recruitable", false)) else "",
		String(entry.get("name", enemy_id)).to_upper(), entry.get("region", "Unknown Universe"),
		int(record.get("seen", 0)), defeated, int(record.get("encounters", 0)),
	]
	if defeated <= 0:
		details.text = title + "\n\nCombat analysis incomplete. Defeat this species once to reveal statistics, actions, affinities, and rewards."
	else:
		details.text = title + "\n\nHP %d   ATK %d   DEF %d   MAG %d   SPR %d   SPD %d\nACTIONS • %s\nAFFINITIES • %s\nBASE REWARD • %d EXP / %d DUCKETS\nOBSERVED SPOILS • %s" % [
			int(entry.get("max_hp", 0)), int(entry.get("attack", 0)), int(entry.get("defense", 0)), int(entry.get("magic", 0)), int(entry.get("spirit", 0)), int(entry.get("speed", 0)),
			_bestiary_action_text(entry.get("actions", [])), _bestiary_affinity_text(entry.get("elements", {})),
			int(entry.get("experience", 0)), int(entry.get("duckets", 0)), _bestiary_drop_text(record.get("drops", [])),
		]
	row.add_child(details)


func _bestiary_texture(entry: Dictionary) -> Texture2D:
	var path := String(entry.get("sprite_path", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return load(UI_ROOT + "/dfgui_icon-monsterbook.png") as Texture2D
	var source := load(path) as Texture2D
	var region: Rect2 = entry.get("sprite_region", Rect2())
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		return source
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas


func _bestiary_action_text(actions: Array) -> String:
	var names: Array[String] = []
	for action_id in actions:
		var action := CampaignCombatDatabase.action(StringName(action_id))
		names.append(String(action.get("name", String(action_id).capitalize())))
	return ", ".join(names) if not names.is_empty() else "None recorded"


func _bestiary_affinity_text(elements: Dictionary) -> String:
	var notes: Array[String] = []
	for element_id in elements.keys():
		var rate := float(elements[element_id])
		if rate > 1.0:
			notes.append("WEAK %s ×%.2f" % [String(element_id).to_upper(), rate])
		elif rate < 1.0:
			notes.append("RESIST %s ×%.2f" % [String(element_id).to_upper(), rate])
	return " • ".join(notes) if not notes.is_empty() else "No unusual elemental response"


func _bestiary_drop_text(drops: Array) -> String:
	var names: Array[String] = []
	for drop in drops:
		names.append("%s [%s]" % [drop.get("name", "Unknown"), drop.get("rarity", "Common")])
	return ", ".join(names) if not names.is_empty() else "No drop observed yet"


func _build_roster_page() -> void:
	_add_heading("COMPANY ROSTER • %d / %d ACTIVE" % [CampaignState.party.size(), CampaignState.PARTY_LIMIT], UI_ROOT + "/dfgui_icon-shield.png")
	_add_notice("Ben occupies the leader slot. Four permanent hires may adventure with him; the velociraptor acts independently and consumes no slot.", Color(0.78, 0.84, 0.96))
	_add_notice("FRONT: full physical damage dealt and received • BACK: 25% less physical damage dealt and received • Magic and support are unchanged.", Color(0.55, 0.92, 1.0))
	if not _at_roster_edit_location():
		_add_notice("Roster changes are locked here. Return to town, Ben's laboratory, or an activated save point.", Color(1.0, 0.7, 0.4))
	var mansion_requirements := CampaignState.destination_party_requirements(&"haunted_mansion")
	if not CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false):
		var requirement_names: Array[String] = []
		for recruit_id in mansion_requirements:
			requirement_names.append(String(CampaignState.recruit_catalog.get(recruit_id, {}).get("name", recruit_id)))
		_add_notice("SCENARIO RESTRICTION • Haunted Mansion requires: %s. Its door rejects an invalid party." % ", ".join(requirement_names), Color(1.0, 0.84, 0.42))

	_add_subheading("ACTIVE FORMATION • FRONT %d/3 • BACK %d/3" % [CampaignState.formation_row_count(&"front"), CampaignState.formation_row_count(&"back")])
	for index in range(CampaignState.party.size()):
		_add_roster_member_card(CampaignState.party[index], index)
	_add_notice("VELOCIRAPTOR • Autonomous companion • Shadow-like support • Does not count toward defeat or party capacity.", Color(0.62, 0.92, 0.66))

	_add_subheading("RESERVE & FACILITY STAFF")
	var reserve_count := 0
	for recruit_id in CampaignState.recruit_catalog.keys():
		if recruit_id in CampaignState.party or recruit_id == &"ben":
			continue
		var status := StringName(CampaignState.recruit_status.get(recruit_id, &"undiscovered"))
		if status == &"undiscovered":
			continue
		reserve_count += 1
		var recruit: Dictionary = CampaignState.recruit_catalog[recruit_id]
		var facility := CampaignState.worker_facility(StringName(recruit_id))
		var active_job := CampaignState.facility_job_status(facility) if not facility.is_empty() else {}
		var button := Button.new()
		button.text = "%s • %s\n%s" % [
			String(recruit.get("name", recruit_id)).to_upper(), String(recruit.get("specialty", "")),
			("STAFFED: %s%s" % [facility, " • WORK IN PROGRESS" if not active_job.is_empty() else ""]) if status == &"staffed" else ("AVAILABLE TO HIRE IN TOWN" if status == &"available" else "RESERVE • READY FOR PARTY"),
		]
		button.custom_minimum_size.y = 68
		button.disabled = not _at_roster_edit_location() or status == &"available" or CampaignState.party.size() >= CampaignState.PARTY_LIMIT or not active_job.is_empty()
		button.tooltip_text = "Finish or abandon facility work first." if not active_job.is_empty() else ("Speak with this recruit in town first." if status == &"available" else "Add this recruit to the active party.")
		_apply_button_skin(button, UI_ROOT + "/dfgui_icon-wardrobe.png")
		button.pressed.connect(_recall_to_party.bind(StringName(recruit_id)))
		_content.add_child(button)
	if reserve_count == 0:
		_add_notice("No discovered recruits are waiting in reserve or on facility duty.", Color(0.68, 0.72, 0.8))


func _add_roster_member_card(recruit_id: StringName, index: int) -> void:
	var recruit: Dictionary = CampaignState.recruit_catalog.get(recruit_id, {})
	var progress: Dictionary = CampaignState.character_progress.get(recruit_id, {})
	var row_name := CampaignState.formation_for(recruit_id)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	_content.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = "SLOT %d • %s • LV %d\n%s • %s ROW%s" % [
		index + 1, recruit.get("name", recruit_id), int(progress.get("level", 1)), recruit.get("specialty", ""), String(row_name).to_upper(), " • FIXED LEADER" if recruit_id == &"ben" else "",
	]
	label.add_theme_font_size_override("font_size", 23)
	label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5))
	row.add_child(label)
	for move_data in [[-1, "↑"], [1, "↓"]]:
		var move := Button.new()
		move.text = move_data[1]
		move.custom_minimum_size = Vector2(52, 50)
		move.disabled = recruit_id == &"ben" or not _at_roster_edit_location() or (index == 1 and int(move_data[0]) < 0) or (index == CampaignState.party.size() - 1 and int(move_data[0]) > 0)
		_apply_button_skin(move)
		move.pressed.connect(_move_roster_member.bind(recruit_id, int(move_data[0])))
		row.add_child(move)
	var other_row := &"back" if row_name == &"front" else &"front"
	var formation := Button.new()
	formation.text = "TO %s" % String(other_row).to_upper()
	formation.custom_minimum_size = Vector2(135, 50)
	formation.disabled = not _at_roster_edit_location() or CampaignState.formation_row_count(other_row, recruit_id) >= CampaignState.FORMATION_ROW_LIMIT
	formation.tooltip_text = "Each row holds at most three adventurers."
	_apply_button_skin(formation, UI_ROOT + ("/dfgui_icon-shield.png" if other_row == &"front" else "/dfgui_icon-wand.png"))
	formation.pressed.connect(_set_roster_formation.bind(recruit_id, other_row))
	row.add_child(formation)
	var reserve := Button.new()
	reserve.text = "RESERVE"
	reserve.custom_minimum_size = Vector2(125, 50)
	reserve.disabled = not _at_roster_edit_location() or not CampaignState.can_remove_from_party(recruit_id)
	reserve.tooltip_text = "This recruit is required by the active scenario." if recruit_id in CampaignState.active_required_party_members() else "Move this recruit out of the active party."
	_apply_button_skin(reserve, UI_ROOT + "/dfgui_icon-wardrobe.png")
	reserve.pressed.connect(_move_roster_to_reserve.bind(recruit_id))
	row.add_child(reserve)


func _build_quest_page() -> void:
	var quests := CampaignState.visible_quests()
	_add_heading("QUEST JOURNAL", UI_ROOT + "/dfgui_icon-redbook.png")
	_add_notice("Main scenarios, town work, and discovered hidden jobs are recorded here. Track any active quest to place its current step on the field HUD.", Color(0.78, 0.84, 0.96))
	if quests.is_empty():
		_add_notice("No quests have been discovered.", Color(0.68, 0.72, 0.8))
		return
	var visible_ids: Array[StringName] = []
	for quest in quests:
		visible_ids.append(StringName(quest.get("id", "")))
	if selected_quest not in visible_ids:
		selected_quest = CampaignState.tracked_quest if CampaignState.tracked_quest in visible_ids else visible_ids[0]

	_add_subheading("COMPANY LEDGER")
	for quest in quests:
		var quest_id := StringName(quest.get("id", ""))
		var runtime: Dictionary = quest.get("state", {})
		var step := int(runtime.get("step", 0))
		var objective_tree: Array = quest.get("objectives", [])
		var total: int = objective_tree.size() if not objective_tree.is_empty() else quest.get("steps", []).size()
		var completed_objectives := 0
		for completed in (runtime.get("objective_states", {}) as Dictionary).values():
			if bool(completed):
				completed_objectives += 1
		var status := StringName(runtime.get("status", "active"))
		var category := String(quest.get("category", "side")).to_upper()
		var button := Button.new()
		button.text = "%s  [%s]  %s\n%s" % [
			"◆" if CampaignState.tracked_quest == quest_id else ("✓" if status == &"complete" else "◇"),
			category, quest.get("title", quest_id),
			"COMPLETE" if status == &"complete" else ("OBJECTIVES %d / %d" % [completed_objectives, total] if not objective_tree.is_empty() else "STEP %d / %d" % [mini(step + 1, total), total]),
		]
		button.custom_minimum_size.y = 68
		button.tooltip_text = String(quest.get("description", ""))
		_apply_button_skin(button, UI_ROOT + "/" + String(quest.get("icon", "dfgui_icon-info.png")))
		button.pressed.connect(_select_quest.bind(quest_id))
		if quest_id == selected_quest:
			button.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))
		_content.add_child(button)

	var definition := CampaignState.quest_definition(selected_quest)
	var runtime := CampaignState.quest_state(selected_quest)
	_add_subheading(String(definition.get("title", selected_quest)).to_upper())
	_add_notice("Giver: %s • %s" % [definition.get("giver", "Unknown"), String(definition.get("category", "side")).to_upper()], Color(1.0, 0.84, 0.42))
	_add_notice(String(definition.get("description", "")), Color(0.86, 0.89, 0.98))
	var is_complete := StringName(runtime.get("status", "active")) == &"complete"
	var objective_tree: Array = definition.get("objectives", [])
	if not objective_tree.is_empty():
		var completed_states: Dictionary = runtime.get("objective_states", {})
		var active_nodes := CampaignState.available_quest_objectives(selected_quest)
		var active_ids: Array[StringName] = []
		for active_node in active_nodes:
			active_ids.append(StringName(active_node.get("id", "")))
		for objective_definition in objective_tree:
			var objective_id := StringName(objective_definition.get("id", ""))
			var is_done := bool(completed_states.get(objective_id, false))
			var is_active := objective_id in active_ids and not is_complete
			var marker := "✓" if is_done else ("▶" if is_active else "◇")
			var color := Color(0.48, 1.0, 0.62) if is_done else (Color(1.0, 0.86, 0.48) if is_active else Color(0.62, 0.68, 0.78))
			_add_notice("%s  %s" % [marker, objective_definition.get("text", "Continue the quest.")], color)
	else:
		var current_step := int(runtime.get("step", 0))
		for index in range(definition.get("steps", []).size()):
			var step_definition: Dictionary = definition["steps"][index]
			var marker := "✓" if index < current_step else ("▶" if index == current_step and not is_complete else "◇")
			var color := Color(0.48, 1.0, 0.62) if index < current_step else (Color(1.0, 0.86, 0.48) if index == current_step and not is_complete else Color(0.62, 0.68, 0.78))
			_add_notice("%s  %s" % [marker, step_definition.get("text", "Continue the quest.")], color)
	var rewards: Dictionary = definition.get("rewards", {})
	_add_notice("REWARDS • %d Duckets%s" % [int(rewards.get("duckets", 0)), _reward_item_text(rewards.get("items", {}))], Color(0.55, 0.92, 1.0))
	var track := Button.new()
	track.text = "TRACKED ON FIELD HUD" if CampaignState.tracked_quest == selected_quest else "TRACK THIS QUEST ON FIELD HUD"
	track.custom_minimum_size.y = 54
	track.disabled = is_complete or CampaignState.tracked_quest == selected_quest
	_apply_button_skin(track, UI_ROOT + "/dfgui_icon-info.png")
	track.pressed.connect(_track_selected_quest)
	_content.add_child(track)


func _build_facilities_page() -> void:
	var facilities := _built_facility_names()
	_add_heading("TOWN OPERATIONS", UI_ROOT + "/dfgui_icon-crafthammer.png")
	if facilities.is_empty():
		_add_notice("Build the Café, Library, and Clinic before assigning company work.", Color(0.68, 0.72, 0.8))
		return
	if selected_facility not in facilities:
		selected_facility = facilities[0]
	var facility_tabs := HBoxContainer.new()
	facility_tabs.add_theme_constant_override("separation", 8)
	_content.add_child(facility_tabs)
	for facility_name in facilities:
		var definition: Dictionary = CampaignState.facility_definition(facility_name)
		var active := CampaignState.facility_job_status(facility_name)
		var button := Button.new()
		button.text = "%s%s" % [facility_name.to_upper(), "  ◆" if StringName(active.get("status", "")) == &"ready" else ("  ◇" if not active.is_empty() else "")]
		button.custom_minimum_size = Vector2(245, 56)
		_apply_button_skin(button, UI_ROOT + "/" + String(definition.get("icon", "dfgui_icon-info.png")))
		button.pressed.connect(_select_facility.bind(facility_name))
		if facility_name == selected_facility:
			button.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))
		facility_tabs.add_child(button)
		if not _first_focus:
			_first_focus = button

	var definition := CampaignState.facility_definition(selected_facility)
	_add_subheading(selected_facility.to_upper())
	_add_notice(String(definition.get("description", "")), Color(0.84, 0.88, 0.98))
	if not _at_company_management_location():
		_add_notice("Remote ledger: collect completed work here. Return to town or the laboratory to change staff, start work, or invent.", Color(1.0, 0.72, 0.42))
	if not _last_facility_result.is_empty() and String(_last_facility_result.get("facility", "")) == selected_facility:
		_add_notice("COLLECTED: %s • %s • +%d Duckets • +%d EXP%s" % [
			_last_facility_result.get("job_name", "Assignment"), _last_facility_result.get("quality_name", "Routine"),
			int(_last_facility_result.get("duckets", 0)), int(_last_facility_result.get("experience", 0)),
			_reward_item_text(_last_facility_result.get("items", {})),
		], Color(0.5, 1.0, 0.68))

	_build_staffing_section()
	_build_active_job_section()
	_build_available_jobs_section()
	_build_invention_section()


func _build_staffing_section() -> void:
	_add_subheading("STAFFING • PARTY OR FACILITY, NEVER BOTH")
	var worker_id := CampaignState.facility_worker(selected_facility)
	if worker_id != &"":
		var recruit: Dictionary = CampaignState.recruit_catalog.get(worker_id, {})
		_add_notice("Assigned: %s • %s" % [recruit.get("name", worker_id), recruit.get("specialty", "No specialty")], Color(0.55, 0.92, 1.0))
		var release := Button.new()
		release.text = "RETURN %s TO RESERVE" % String(recruit.get("name", worker_id)).to_upper()
		release.custom_minimum_size.y = 50
		release.disabled = not _at_company_management_location() or not CampaignState.facility_job_status(selected_facility).is_empty()
		release.tooltip_text = "Finish or abandon active work before changing staff." if not CampaignState.facility_job_status(selected_facility).is_empty() else "Make this recruit available for the adventuring party."
		_apply_button_skin(release, UI_ROOT + "/dfgui_icon-wardrobe.png")
		release.pressed.connect(_release_facility_worker)
		_content.add_child(release)
	else:
		_add_notice("No recruit assigned. Ben can personally lead eligible assignments; other work needs a permanent hire.", Color(0.72, 0.76, 0.86))

	for recruit_id in CampaignState.recruit_catalog.keys():
		if recruit_id == &"ben" or recruit_id == worker_id:
			continue
		var status := StringName(CampaignState.recruit_status.get(recruit_id, &"undiscovered"))
		if status not in [&"party", &"reserve", &"staffed"]:
			continue
		var other_facility := CampaignState.worker_facility(recruit_id)
		if not other_facility.is_empty():
			continue
		var recruit: Dictionary = CampaignState.recruit_catalog[recruit_id]
		var button := Button.new()
		button.text = "ASSIGN %s • %s%s" % [String(recruit.get("name", recruit_id)).to_upper(), String(recruit.get("specialty", "")), " • LEAVES PARTY" if status == &"party" else ""]
		button.custom_minimum_size.y = 52
		button.disabled = worker_id != &"" or not _at_company_management_location()
		_apply_button_skin(button, UI_ROOT + "/dfgui_icon-shield.png")
		button.pressed.connect(_assign_facility_worker.bind(StringName(recruit_id)))
		_content.add_child(button)


func _build_active_job_section() -> void:
	var active := CampaignState.facility_job_status(selected_facility)
	if active.is_empty():
		return
	var job := CampaignState.facility_job_definition(selected_facility, StringName(active.get("job_id", "")))
	_add_subheading("ACTIVE ASSIGNMENT")
	var worker_id := StringName(active.get("worker_id", ""))
	var worker_name: String = String(CampaignState.recruit_catalog.get(worker_id, {}).get("name", worker_id))
	_add_notice("%s • %s quality • Worker: %s%s" % [
		job.get("name", "Assignment"), active.get("quality_name", "Routine"), worker_name,
		" + Ben" if bool(active.get("ben_assist", false)) and worker_id != &"ben" else "",
	], Color(1.0, 0.84, 0.42))
	_active_job_timer = Label.new()
	_active_job_timer.add_theme_font_size_override("font_size", 30)
	_active_job_timer.add_theme_color_override("font_color", Color(0.5, 0.92, 1.0))
	_content.add_child(_active_job_timer)
	_update_active_job_timer()
	if StringName(active.get("status", "")) == &"ready":
		var collect := Button.new()
		collect.text = "COLLECT COMPLETED WORK"
		collect.custom_minimum_size.y = 58
		_apply_button_skin(collect, UI_ROOT + "/dfgui_icon-pouch.png")
		collect.pressed.connect(_collect_facility_job)
		_content.add_child(collect)
	else:
		var cancel := Button.new()
		cancel.text = "ABANDON ASSIGNMENT • NO REWARD"
		cancel.custom_minimum_size.y = 48
		cancel.disabled = not _at_company_management_location()
		_apply_button_skin(cancel, UI_ROOT + "/dfgui_icon-info.png")
		cancel.pressed.connect(_cancel_facility_job)
		_content.add_child(cancel)


func _build_available_jobs_section() -> void:
	if not CampaignState.facility_job_status(selected_facility).is_empty():
		return
	_add_subheading("AVAILABLE ASSIGNMENTS")
	var jobs := CampaignState.visible_facility_jobs(selected_facility)
	if jobs.is_empty():
		_add_notice("No assignments have been discovered for this facility yet.", Color(0.68, 0.72, 0.8))
		return
	for job in jobs:
		var job_id := StringName(job.get("id", ""))
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _panel_style())
		_content.add_child(card)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 6)
		card.add_child(column)
		var title := Label.new()
		title.text = "%s • %s • %s" % [job.get("name", job_id), _format_duration(int(job.get("duration_seconds", 0))), _job_reward_text(job)]
		title.add_theme_font_size_override("font_size", 27)
		title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
		column.add_child(title)
		var description := Label.new()
		description.text = "%s\nBest specialties: %s" % [job.get("description", ""), ", ".join(job.get("preferred_skills", []))]
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_theme_font_size_override("font_size", 22)
		description.add_theme_color_override("font_color", Color(0.82, 0.86, 0.94))
		column.add_child(description)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 8)
		column.add_child(actions)
		var standard := CampaignState.job_estimate(selected_facility, job_id, false)
		var start := Button.new()
		start.text = "START • %s • %s" % [_format_duration(int(standard.get("duration_seconds", job.get("duration_seconds", 0)))), standard.get("quality_name", "Needs worker")]
		start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start.custom_minimum_size.y = 52
		start.disabled = not _at_company_management_location() or not bool(standard.get("allowed", false))
		start.tooltip_text = String(standard.get("reason", "Assign without Ben's assistance."))
		_apply_button_skin(start, UI_ROOT + "/dfgui_icon-clock.png")
		start.pressed.connect(_start_facility_job.bind(job_id, false))
		actions.add_child(start)
		if bool(job.get("ben_can_assist", false)) or bool(job.get("ben_can_lead", false)):
			var assisted := CampaignState.job_estimate(selected_facility, job_id, true)
			var ben := Button.new()
			ben.text = "%s • %s • %s" % ["BEN LEADS" if CampaignState.facility_worker(selected_facility) == &"" else "+ BEN ASSISTS", _format_duration(int(assisted.get("duration_seconds", job.get("duration_seconds", 0)))), assisted.get("quality_name", "Unavailable")]
			ben.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			ben.custom_minimum_size.y = 52
			ben.disabled = not _at_company_management_location() or not bool(assisted.get("allowed", false))
			ben.tooltip_text = String(assisted.get("reason", "Ben improves completion time and reward quality."))
			_apply_button_skin(ben, UI_ROOT + "/dfgui_icon-wand.png")
			ben.pressed.connect(_start_facility_job.bind(job_id, true))
			actions.add_child(ben)


func _build_invention_section() -> void:
	_add_subheading("FACILITY INVENTIONS • BUILT ONLY IN BEN'S LAB")
	var inventions := CampaignState.visible_inventions(selected_facility)
	if inventions.is_empty():
		_add_notice("No relevant invention blueprint has been discovered.", Color(0.68, 0.72, 0.8))
		return
	for invention in inventions:
		var invention_id := StringName(invention.get("id", ""))
		var owned := invention_id in CampaignState.owned_inventions
		var availability := CampaignState.invention_availability(invention_id)
		var button := Button.new()
		button.text = "%s %s\n%s • %s" % ["◆" if owned else "◇", invention.get("name", invention_id), invention.get("description", ""), "OWNED" if owned else _invention_cost_text(invention)]
		button.custom_minimum_size.y = 72
		button.disabled = owned or not _at_laboratory() or not bool(availability.get("allowed", false))
		button.tooltip_text = "Already installed." if owned else ("Return to Ben's laboratory." if not _at_laboratory() else String(availability.get("reason", "")))
		_apply_button_skin(button, UI_ROOT + "/" + String(invention.get("icon", "dfgui_icon-crafthammer.png")))
		button.pressed.connect(_craft_invention.bind(invention_id))
		_content.add_child(button)


func _build_service_page() -> void:
	var definition := CampaignState.facility_definition(selected_service)
	var icon_path := UI_ROOT + "/" + String(definition.get("icon", "dfgui_icon-info.png"))
	_add_heading("%s SERVICES" % selected_service.to_upper(), icon_path)
	var worker_id := CampaignState.facility_worker(selected_service)
	if worker_id != &"":
		var worker_name := String(CampaignState.recruit_catalog.get(worker_id, {}).get("name", worker_id))
		_add_notice("STAFFED BY %s • Direct services cost 15%% less. Idle assignments remain available from the Facilities page." % worker_name.to_upper(), Color(0.54, 0.96, 0.66))
	else:
		_add_notice("UNSTAFFED • Ben can still use the facility, but direct services are charged at their normal rate.", Color(1.0, 0.74, 0.4))
	if not _last_service_message.is_empty():
		_add_notice(_last_service_message, Color(0.5, 0.92, 1.0))
	match selected_service:
		"Cafe":
			_build_service_stock("Cafe", "EXPEDITION COUNTER")
		"Clinic":
			_build_clinic_service()
			_build_service_stock("Clinic", "MEDICAL COUNTER")
		"Library":
			_build_library_service()
		"Armory":
			_build_armory_stock()
			_build_gear_buyback()


func _build_armory_stock() -> void:
	var character_name := String(CampaignState.recruit_catalog.get(selected_character, {}).get("name", selected_character))
	_add_subheading("COMPANY OUTFITTING • %s" % character_name.to_upper())
	for item in CampaignState.armory_stock():
		var stock_id := StringName(item.get("stock_id", ""))
		var price := int(item.get("price", 0))
		var comparison := _gear_comparison_summary(item)
		var button := Button.new()
		button.name = "BuyGear_%s" % stock_id
		button.text = "BUY %s • %d D\n%s%s" % [item.get("base_name", stock_id), price, _modifier_summary(item), "   •   " + comparison if not comparison.is_empty() else ""]
		button.custom_minimum_size.y = 80
		button.disabled = CampaignState.duckets < price
		button.tooltip_text = "Not enough Duckets." if button.disabled else "%s\nCompared with %s's equipped %s." % [_item_details(item), character_name, String(item.get("slot", "gear"))]
		_apply_button_skin(button, String(item.get("icon", UI_ROOT + "/dfgui_icon-sword.png")))
		button.pressed.connect(_buy_armory_item.bind(stock_id))
		_content.add_child(button)


func _build_service_stock(facility_name: String, heading: String) -> void:
	_add_subheading(heading)
	for item in CampaignState.service_stock(facility_name):
		var item_id := StringName(item.get("id", ""))
		var price := int(item.get("price", 0))
		var button := Button.new()
		button.name = "Buy_%s" % item_id
		button.text = "BUY %s • %d D\n%s • OWNED ×%d" % [item.get("name", item_id), price, item.get("description", ""), int(CampaignState.inventory.get(item_id, 0))]
		button.custom_minimum_size.y = 76
		button.disabled = CampaignState.duckets < price
		button.tooltip_text = "Not enough Duckets." if button.disabled else "Purchase one."
		_apply_button_skin(button, UI_ROOT + "/" + String(item.get("icon", "dfgui_icon-pouch.png")))
		button.pressed.connect(_buy_service_item.bind(facility_name, item_id))
		_content.add_child(button)


func _build_gear_buyback() -> void:
	_add_subheading("SELL RECOVERED EQUIPMENT")
	if CampaignState.loot_inventory.is_empty():
		_add_notice("No recovered equipment is available to sell.", Color(0.68, 0.72, 0.8))
		return
	for item in CampaignState.loot_inventory:
		var instance_id := String(item.get("instance_id", ""))
		var owner_id := CampaignState.loot_owner(instance_id)
		var value := CampaignState.loot_sell_value(instance_id)
		var button := Button.new()
		button.name = "Sell_%s" % instance_id
		button.text = "SELL • %s • %d D%s" % [item.get("display_name", "Recovered Gear"), value, " • EQUIPPED BY " + String(CampaignState.recruit_catalog.get(owner_id, {}).get("name", owner_id)).to_upper() if owner_id != &"" else ""]
		button.custom_minimum_size.y = 60
		button.disabled = owner_id != &""
		button.tooltip_text = "Unequip this item before selling it." if button.disabled else _item_details(item)
		_apply_button_skin(button, String(item.get("icon", UI_ROOT + "/dfgui_icon-pouch.png")))
		button.pressed.connect(_sell_service_loot.bind(instance_id))
		_content.add_child(button)


func _build_clinic_service() -> void:
	_add_subheading("PARTY TREATMENT")
	var cost := CampaignState.clinic_service_cost()
	var treatment := Button.new()
	treatment.name = "ClinicFullTreatment"
	treatment.text = "FULL TREATMENT • %d D\nRevive every fallen member, restore the active party's HP and MP, and save progress." % cost
	treatment.custom_minimum_size.y = 88
	treatment.disabled = CampaignState.duckets < cost
	treatment.tooltip_text = "Not enough Duckets." if treatment.disabled else "The Clinic restores and anchors the full active party."
	_apply_button_skin(treatment, UI_ROOT + "/dfgui_icon-cauldron.png")
	treatment.pressed.connect(_use_clinic_treatment)
	_content.add_child(treatment)


func _build_library_service() -> void:
	_add_subheading("FRANKLIN & COMPANY RECORDS")
	var records := CampaignState.library_record_summary()
	_add_notice("QUESTS  %d discovered / %d completed     •     UNIVERSES STABILIZED  %d\nBESTIARY  %d / %d species     •     MONSTERS DEFEATED  %d\nMANSION ENCOUNTERS  %d     •     INVENTIONS  %d     •     DISCOVERED HIRES  %d" % [
		int(records.get("quests_discovered", 0)), int(records.get("quests_completed", 0)), int(records.get("universes_stabilized", 0)),
		int(records.get("bestiary_seen", 0)), int(records.get("bestiary_total", 0)), int(records.get("monsters_defeated", 0)),
		int(records.get("mansion_encounters", 0)), int(records.get("inventions", 0)), int(records.get("recruits", 0)),
	], Color(0.82, 0.88, 1.0))
	var tracked := CampaignState.tracked_objective()
	if not tracked.is_empty():
		_add_notice("TRACKED • %s\n%s" % [String(tracked.get("title", "Quest")).to_upper(), tracked.get("objective", "")], Color(1.0, 0.86, 0.48))
	var archive := Button.new()
	archive.name = "LibraryArchiveSave"
	archive.text = "ARCHIVE FIELD RECORDS\nSave the current party, construction, quest, and facility state."
	archive.custom_minimum_size.y = 82
	_apply_button_skin(archive, UI_ROOT + "/dfgui_icon-redbook.png")
	archive.pressed.connect(_archive_library_records)
	_content.add_child(archive)


func _build_recall_page() -> void:
	_add_heading("CONTINUITY KITE", UI_ROOT + "/dfgui_icon-wand.png")
	_add_notice("Ben's recovered Anchor Core pulls the active party back to New Philadelphia without restoring HP or MP. Scripted scenarios can temporarily interfere with the route.", Color(0.78, 0.84, 0.96))
	var owned := &"continuity_kite" in CampaignState.owned_inventions
	if not owned:
		_add_subheading("INVENTION NOT YET INSTALLED")
		_add_notice("Defeat the Haunted Mansion's 4:44 appointment, recover its Anchor Core, then build the Continuity Kite from the Haunted Mansion facility page while standing in Ben's laboratory.", Color(1.0, 0.72, 0.38))
	else:
		_add_subheading("ANCHOR ROUTE • NEW PHILADELPHIA")
	var availability: Dictionary = campaign.anchor_recall_availability() if campaign and campaign.has_method("anchor_recall_availability") else {"allowed": false, "reason": "The route controller is unavailable."}
	var recall := Button.new()
	recall.name = "ContinuityKiteRecall"
	recall.text = "RECALL ACTIVE PARTY TO TOWN\n%s" % String(availability.get("reason", ""))
	recall.custom_minimum_size.y = 96
	recall.disabled = not bool(availability.get("allowed", false))
	recall.tooltip_text = String(availability.get("reason", ""))
	_apply_button_skin(recall, UI_ROOT + "/dfgui_icon-wand.png")
	recall.pressed.connect(_use_anchor_recall)
	_content.add_child(recall)
	if owned:
		_add_notice("Direct shortcut: K on keyboard or L3 on a standard modern controller opens this page from the field.", Color(0.58, 0.9, 0.72))


func _select_character(character_id: StringName) -> void:
	selected_character = character_id
	_refresh()


func _select_tab(tab: StringName) -> void:
	selected_tab = tab
	_refresh()


func _select_facility(facility_name: String) -> void:
	selected_facility = facility_name
	_refresh()


func _select_quest(quest_id: StringName) -> void:
	selected_quest = quest_id
	_refresh()


func _select_bestiary_enemy(enemy_id: StringName) -> void:
	selected_enemy = enemy_id
	_refresh()


func _track_selected_quest() -> void:
	if CampaignState.set_tracked_quest(selected_quest):
		_save_changes()
	_refresh()


func _move_roster_member(recruit_id: StringName, direction: int) -> void:
	if _at_roster_edit_location() and CampaignState.move_party_member(recruit_id, direction):
		_save_changes()
	_refresh()


func _set_roster_formation(recruit_id: StringName, row: StringName) -> void:
	if _at_roster_edit_location() and CampaignState.set_party_formation(recruit_id, row):
		_save_changes()
	_refresh()


func _move_roster_to_reserve(recruit_id: StringName) -> void:
	if _at_roster_edit_location() and CampaignState.move_to_reserve(recruit_id):
		_save_changes()
	_refresh()


func _recall_to_party(recruit_id: StringName) -> void:
	if _at_roster_edit_location() and CampaignState.add_to_party(recruit_id):
		_save_changes()
	_refresh()


func _select_slot(slot: StringName) -> void:
	selected_slot = slot
	_refresh()


func _equip_item(instance_id: String) -> void:
	if CampaignState.equip_loot(selected_character, instance_id):
		_save_changes()
	_refresh()


func _unequip_selected() -> void:
	if CampaignState.unequip_slot(selected_character, selected_slot):
		_save_changes()
	_refresh()


func _learn_skill(skill_id: StringName) -> void:
	if CampaignState.learn_skill(selected_character, skill_id):
		_save_changes()
	_refresh()


func _reset_skills() -> void:
	if _at_laboratory() and CampaignState.reset_skill_tree(selected_character):
		_save_changes()
	_refresh()


func _assign_facility_worker(recruit_id: StringName) -> void:
	if _at_company_management_location() and CampaignState.assign_to_facility(recruit_id, selected_facility):
		_save_changes()
	_refresh()


func _release_facility_worker() -> void:
	if _at_company_management_location() and CampaignState.release_facility_worker(selected_facility):
		_save_changes()
	_refresh()


func _start_facility_job(job_id: StringName, ben_assist: bool) -> void:
	if _at_company_management_location() and CampaignState.start_facility_job(selected_facility, job_id, ben_assist):
		_last_facility_result.clear()
		_save_changes()
	_refresh()


func _collect_facility_job() -> void:
	var result := CampaignState.collect_facility_job(selected_facility)
	if not result.is_empty():
		_last_facility_result = result
		_save_changes()
	_refresh()


func _cancel_facility_job() -> void:
	if _at_company_management_location() and CampaignState.cancel_facility_job(selected_facility):
		_save_changes()
	_refresh()


func _craft_invention(invention_id: StringName) -> void:
	if _at_laboratory() and CampaignState.craft_invention(invention_id):
		_save_changes()
		_refresh()


func _use_field_inventory_item(item_id: StringName) -> void:
	var result := CampaignState.use_field_item(item_id, selected_character)
	_last_inventory_message = String(result.get("message", result.get("reason", "The item could not be used.")))
	if bool(result.get("used", false)):
		_save_changes()
	_refresh()


func _buy_service_item(facility_name: String, item_id: StringName) -> void:
	var price := CampaignState.service_item_price(facility_name, item_id)
	if CampaignState.purchase_service_item(facility_name, item_id):
		_last_service_message = "Purchased %s for %d Duckets." % [String(item_id).replace("_", " ").capitalize(), price]
		_save_changes()
		_refresh()


func _buy_armory_item(stock_id: StringName) -> void:
	var price := CampaignState.armory_item_price(stock_id)
	var item := CampaignState.purchase_armory_item(stock_id)
	if not item.is_empty():
		_last_service_message = "Purchased %s for %d Duckets. It is now available from Equipment." % [item.get("display_name", stock_id), price]
		_save_changes()
		_refresh()


func _sell_service_loot(instance_id: String) -> void:
	var item := CampaignState.loot_by_instance(instance_id).duplicate(true)
	var value := CampaignState.sell_loot(instance_id)
	if value > 0:
		_last_service_message = "Sold %s for %d Duckets." % [item.get("display_name", "recovered gear"), value]
		_save_changes()
	_refresh()


func _use_clinic_treatment() -> void:
	var cost := CampaignState.clinic_service_cost()
	if CampaignState.use_clinic_service():
		_last_service_message = "Treatment complete. The active party was restored and progress was saved for %d Duckets." % cost
		_save_changes()
	_refresh()


func _archive_library_records() -> void:
	CampaignState.story_flags[&"library_records_archived"] = true
	CampaignState.story_flags[&"library_archive_count"] = int(CampaignState.story_flags.get(&"library_archive_count", 0)) + 1
	CampaignState.state_changed.emit()
	_last_service_message = "Field records archived. Progress saved in the Library ledger."
	_save_changes()
	_refresh()


func _at_laboratory() -> bool:
	if not Player.gamepiece:
		return false
	return Rect2i(Vector2i.ZERO, Vector2i(20, 12)).has_point(Gameboard.pixel_to_cell(Player.gamepiece.position))


func _at_company_management_location() -> bool:
	if management_location_override >= 0:
		return management_location_override == 1
	if not Player.gamepiece:
		return false
	var cell := Gameboard.pixel_to_cell(Player.gamepiece.position)
	return Rect2i(Vector2i.ZERO, Vector2i(20, 12)).has_point(cell) or Rect2i(Vector2i(36, 0), Vector2i(32, 22)).has_point(cell)


func _at_roster_edit_location() -> bool:
	if _at_company_management_location():
		return true
	if management_location_override >= 0 or not Player.gamepiece:
		return false
	var cell := Gameboard.pixel_to_cell(Player.gamepiece.position)
	return not CampaignState.activated_save_point_near(cell).is_empty()


func _built_facility_names() -> Array[String]:
	var plot_indexes: Array = CampaignState.built_facilities.keys()
	plot_indexes.sort()
	var results: Array[String] = []
	for plot_index in plot_indexes:
		var facility_name := String(CampaignState.built_facilities[plot_index])
		if not CampaignState.facility_definition(facility_name).is_empty():
			results.append(facility_name)
	return results


func _update_active_job_timer() -> void:
	if not _active_job_timer or selected_facility.is_empty():
		return
	var active := CampaignState.facility_job_status(selected_facility)
	if active.is_empty():
		_active_job_timer.text = ""
		return
	if StringName(active.get("status", "")) == &"ready":
		_active_job_timer.text = "READY TO COLLECT • Rewards wait safely while you adventure."
		_active_job_timer.add_theme_color_override("font_color", Color(0.48, 1.0, 0.62))
	else:
		var remaining := maxi(0, int(active.get("finishes_at", 0)) - int(Time.get_unix_time_from_system()))
		_active_job_timer.text = "TIME REMAINING  %s • Progress continues while the game is closed." % _format_duration(remaining)


func _format_duration(seconds: int) -> String:
	seconds = maxi(0, seconds)
	var hours := seconds / 3600
	var minutes := (seconds % 3600) / 60
	var remainder := seconds % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	return "%02d:%02d" % [minutes, remainder]


func _job_reward_text(job: Dictionary) -> String:
	return "%d D • %d EXP%s" % [int(job.get("duckets", 0)), int(job.get("experience", 0)), _reward_item_text(job.get("items", {}))]


func _reward_item_text(items: Dictionary) -> String:
	var parts: Array[String] = []
	for item_id in items.keys():
		parts.append("%s ×%d" % [String(item_id).replace("_", " ").capitalize(), int(items[item_id])])
	return " • " + ", ".join(parts) if not parts.is_empty() else ""


func _invention_cost_text(invention: Dictionary) -> String:
	var cost := "%d Duckets" % int(invention.get("duckets", 0))
	var ingredients: Array[String] = []
	for item_id in invention.get("items", {}).keys():
		ingredients.append("%s ×%d" % [String(item_id).replace("_", " ").capitalize(), int(invention["items"][item_id])])
	return cost + (" + " + ", ".join(ingredients) if not ingredients.is_empty() else "")


func _item_owner(instance_id: String) -> String:
	for character_id in CampaignState.character_progress.keys():
		for equipped_id in CampaignState.character_progress[character_id].get("equipment", {}).values():
			if String(equipped_id) == instance_id:
				return String(CampaignState.recruit_catalog.get(character_id, {}).get("name", character_id))
	return ""


func _modifier_summary(item: Dictionary) -> String:
	var parts: Array[String] = []
	for modifier in item.get("modifiers", []):
		parts.append("%s +%d" % [String(modifier.get("stat", "")).to_upper(), int(modifier.get("value", 0))])
	if item.get("granted_action", &"") != &"":
		parts.append("ABILITY: %s" % String(item["granted_action"]).replace("_", " ").to_upper())
	return "   ".join(parts)


func _gear_comparison_summary(item: Dictionary) -> String:
	var comparison := CampaignState.gear_comparison(item, selected_character)
	if comparison.is_empty():
		return "SAME TOTAL BONUSES"
	var labels := {&"attack": "ATK", &"defense": "DEF", &"magic": "MAG", &"spirit": "SPR", &"speed": "SPD", &"max_hp": "HP", &"max_mp": "MP"}
	var parts: Array[String] = []
	for stat in [&"attack", &"defense", &"magic", &"spirit", &"speed", &"max_hp", &"max_mp"]:
		if comparison.has(stat):
			var delta := int(comparison[stat])
			parts.append("%s %s%d" % [labels[stat], "+" if delta > 0 else "", delta])
	return "VS EQUIPPED: " + "   ".join(parts)


func _item_details(item: Dictionary) -> String:
	if item.is_empty():
		return "Empty equipment slot"
	return "%s\n%s\nPack: %s" % [item.get("display_name", "Unknown item"), _modifier_summary(item), item.get("source_pack", "Unknown")]


func _add_heading(text: String, icon_path: String) -> void:
	var row := HBoxContainer.new()
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(54, 54)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(icon_path)
	row.add_child(icon)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.42))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	_content.add_child(row)


func _add_subheading(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	_content.add_child(label)


func _add_notice(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", color)
	_content.add_child(label)


func _panel_style() -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 7)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style


func _button_style(tint := Color.WHITE) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	# The old implementation stretched dfgui_button-empty.png, a 26px square
	# icon well, across every long text button. Use the HUD kit's actual framed
	# well as a nine-patch so its corners and gold edge keep their proportions.
	style.texture = atlas
	style.modulate_color = tint
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 7)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style


func _apply_button_skin(button: Button, icon_path := "") -> void:
	button.add_theme_stylebox_override("normal", _button_style())
	button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("focus", _button_style(Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.62, 0.68, 0.78)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.42, 0.45, 0.52, 0.75)))
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		button.icon = load(icon_path)
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 42)


func _on_state_changed() -> void:
	if visible:
		_refresh()


func _use_anchor_recall() -> void:
	close_menu()
	if not campaign or not campaign.has_method("anchor_recall_to_town") or not campaign.anchor_recall_to_town():
		open_menu(&"recall")


func _save_changes() -> void:
	if not suppress_persistence:
		CampaignState.save_game()


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
