class_name CampaignBattle
extends CanvasLayer

signal battle_finished(victory: bool, encounter_id: StringName)
signal return_to_town_requested

const MANSION_ATLAS := "res://game_assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png"
const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"
const UI_BUTTON := UI_ROOT + "/dfgui_button-empty.png"
const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")
const ACTOR_ANIMATION := preload("res://ben_rpg/combat/campaign_battle_actor_animation.gd")

var active := false
var suppress_persistence := false
var model := AtbBattleModel.new()
var _root: Control
var _stage: Control
var _backdrop_crop: AtlasTexture
var _message_label: Label
var _encounter_label: Label
var _command_panel: PanelContainer
var _command_header: Label
var _command_buttons: GridContainer
var _description_label: Label
var _target_panel: PanelContainer
var _target_buttons: VBoxContainer
var _status_list: VBoxContainer
var _results_panel: PanelContainer
var _results_content: VBoxContainer
var _actor_nodes := {}
var _status_nodes := {}
var _ready_players: Array[StringName] = []
var _pending_ai: Array[StringName] = []
var _command_actor: StringName = &""
var _chosen_action: StringName = &""
var _action_lock := false
var _field_node: CanvasItem
var _field_ui_node: CanvasItem
var _sfx_player: AudioStreamPlayer
var _frame_cache: Dictionary = {}
var _battle_instance_id := 0
var _result_applied_instance_id := -1
var _leave_applied_instance_id := -1


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not active or _action_lock or not _target_panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_target_panel.hide()
		_chosen_action = &""
		var first := _first_enabled_button(_command_buttons)
		if first:
			first.grab_focus()
		get_viewport().set_input_as_handled()


func begin(encounter_id: StringName, seed: int = 0) -> bool:
	if active or CampaignState.party.is_empty():
		return false
	_battle_instance_id += 1
	_result_applied_instance_id = -1
	_leave_applied_instance_id = -1
	active = true
	CampaignState.clear_encounter_pressure()
	model.setup(encounter_id, CampaignState.party, CampaignState.character_progress, seed)
	CampaignState.record_bestiary_sighting(encounter_id, _enemy_types_in_battle())
	var backdrop_path := String(model.encounter_data.get("backdrop_path", MANSION_ATLAS))
	if ResourceLoader.exists(backdrop_path):
		_backdrop_crop.atlas = load(backdrop_path)
	_backdrop_crop.region = model.encounter_data.get("backdrop_region", Rect2(0, 0, 384, 360))
	_ready_players.clear()
	_pending_ai.clear()
	_command_actor = &""
	_chosen_action = &""
	_action_lock = false
	_results_panel.hide()
	_command_panel.hide()
	_target_panel.hide()
	_build_actor_stage()
	_encounter_label.text = String(model.encounter_data.get("name", "Encounter"))
	var opening_message := "The fault line shudders. Something notices you."
	if String(encounter_id).begins_with("asterion_"):
		opening_message = "Asterion security begins its review."
	elif String(encounter_id).begins_with("primeval_"):
		opening_message = "Primeval Borough recognizes no pedestrian right-of-way."
	elif String(encounter_id).begins_with("helios_"):
		opening_message = "Helios security cites the party for unauthorized evening."
	elif String(encounter_id).begins_with("frosthold_"):
		opening_message = "Frosthold's treasury begins an involuntary thermal audit."
	elif String(encounter_id).begins_with("moonpetal_"):
		opening_message = "Moonpetal's magistrate requests an officially corrected version of your memory."
	elif String(encounter_id).begins_with("empyreal_"):
		opening_message = "Empyreal Court serves the party with a binding notice of gravity."
	_set_message(opening_message)
	# CampaignBattle is a direct child of the campaign root. Using the owner
	# relationship also keeps integration tests and instanced campaign scenes sane.
	var scene := get_parent()
	_field_node = scene.get_node_or_null("Field") as CanvasItem if scene else null
	_field_ui_node = scene.get_node_or_null("UI") as CanvasItem if scene else null
	if _field_node:
		_field_node.hide()
	if _field_ui_node:
		_field_ui_node.hide()
	FieldEvents.input_paused.emit(true)
	show()
	return true


func _process(delta: float) -> void:
	if not active or _results_panel.visible:
		return
	if not _action_lock:
		for actor_id in model.tick_atb(delta):
			var actor := model.get_actor(actor_id)
			if actor["autonomous"]:
				if actor_id not in _pending_ai:
					_pending_ai.append(actor_id)
			elif actor_id not in _ready_players:
				_ready_players.append(actor_id)
		if not _pending_ai.is_empty():
			var ai_id: StringName = _pending_ai.pop_front()
			var choice: Dictionary = model.choose_ai_action(ai_id)
			if not choice.is_empty():
				var ai_targets: Array[StringName] = []
				for target_id in choice["targets"]:
					ai_targets.append(StringName(target_id))
				_perform_action(StringName(choice["actor"]), StringName(choice["action"]), ai_targets)
		elif _command_actor == &"" and not _ready_players.is_empty():
			_show_commands(_ready_players.front())
	_update_status_display()


func _build_interface() -> void:
	_root = Control.new()
	_root.name = "BattleInterface"
	_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "BattleSfx"
	_root.add_child(_sfx_player)

	var backdrop := TextureRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_backdrop_crop = AtlasTexture.new()
	_backdrop_crop.atlas = load(MANSION_ATLAS)
	_backdrop_crop.region = Rect2(0, 0, 384, 360)
	backdrop.texture = _backdrop_crop
	_root.add_child(backdrop)
	var tint := ColorRect.new()
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.color = Color(0.025, 0.03, 0.065, 0.43)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(tint)

	_stage = Control.new()
	_stage.position = Vector2(0, 112)
	_stage.size = Vector2(1920, 650)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_stage)

	var title_panel := _panel(Rect2(42, 26, 1100, 76), Color(0.025, 0.035, 0.075, 0.94), Color(0.72, 0.61, 0.31))
	_root.add_child(title_panel)
	_encounter_label = Label.new()
	_encounter_label.add_theme_font_size_override("font_size", 40)
	_encounter_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.63))
	_encounter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_panel.add_child(_encounter_label)

	var active_label := Label.new()
	active_label.position = Vector2(1480, 38)
	active_label.size = Vector2(390, 48)
	active_label.text = "ACTIVE TIME  •  SPEED-BASED"
	active_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	active_label.add_theme_font_size_override("font_size", 29)
	active_label.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	_root.add_child(active_label)

	var message_panel := _panel(Rect2(220, 690, 1480, 62), Color(0.02, 0.025, 0.055, 0.95), Color(0.34, 0.5, 0.68))
	_root.add_child(message_panel)
	_message_label = Label.new()
	_message_label.add_theme_font_size_override("font_size", 30)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	message_panel.add_child(_message_label)

	_command_panel = _panel(Rect2(42, 772, 760, 270), Color(0.025, 0.035, 0.08, 0.97), Color(0.76, 0.63, 0.31))
	_root.add_child(_command_panel)
	var command_layout := HBoxContainer.new()
	command_layout.add_theme_constant_override("separation", 18)
	_command_panel.add_child(command_layout)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	command_layout.add_child(left)
	_command_header = Label.new()
	_command_header.add_theme_font_size_override("font_size", 34)
	_command_header.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	left.add_child(_command_header)
	_command_buttons = GridContainer.new()
	_command_buttons.columns = 2
	_command_buttons.add_theme_constant_override("h_separation", 7)
	_command_buttons.add_theme_constant_override("v_separation", 4)
	left.add_child(_command_buttons)
	_description_label = Label.new()
	_description_label.custom_minimum_size = Vector2(330, 0)
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.add_theme_font_size_override("font_size", 27)
	_description_label.add_theme_color_override("font_color", Color(0.76, 0.82, 0.9))
	command_layout.add_child(_description_label)

	_target_panel = _panel(Rect2(820, 772, 420, 270), Color(0.035, 0.04, 0.075, 0.98), Color(0.63, 0.48, 0.77))
	_root.add_child(_target_panel)
	_target_buttons = VBoxContainer.new()
	_target_panel.add_child(_target_buttons)

	var status_panel := _panel(Rect2(1260, 772, 610, 270), Color(0.025, 0.035, 0.075, 0.97), Color(0.34, 0.62, 0.75))
	_root.add_child(status_panel)
	_status_list = VBoxContainer.new()
	_status_list.add_theme_constant_override("separation", 1)
	status_panel.add_child(_status_list)

	_results_panel = _panel(Rect2(420, 190, 1080, 700), Color(0.018, 0.025, 0.055, 0.985), Color(0.92, 0.73, 0.27))
	_root.add_child(_results_panel)
	_results_content = VBoxContainer.new()
	_results_content.alignment = BoxContainer.ALIGNMENT_CENTER
	_results_content.add_theme_constant_override("separation", 18)
	_results_panel.add_child(_results_content)


func _build_actor_stage() -> void:
	for child in _stage.get_children():
		child.queue_free()
	for child in _status_list.get_children():
		child.queue_free()
	_actor_nodes.clear()
	_status_nodes.clear()
	var front: Array[Dictionary] = []
	var back: Array[Dictionary] = []
	var enemies: Array[Dictionary] = []
	var pet: Dictionary = {}
	for actor in model.actors:
		if actor["team"] != "party":
			enemies.append(actor)
		elif actor["id"] == &"velociraptor":
			pet = actor
		elif StringName(actor.get("formation", "front")) == &"back":
			back.append(actor)
		else:
			front.append(actor)
	for index in range(enemies.size()):
		_add_actor_visual(enemies[index], index, enemies.size())
	for index in range(front.size()):
		_add_actor_visual(front[index], index, front.size())
	for index in range(back.size()):
		_add_actor_visual(back[index], index, back.size())
	if not pet.is_empty():
		_add_actor_visual(pet, 0, 1)
	# Keep status order stable and include every combatant. The compact rows fit
	# the maximum five-person company, its autonomous pet, and two enemies.
	for actor in model.actors:
		var status := _create_status_row(actor)
		_status_list.add_child(status)
		_status_nodes[actor["id"]] = status


func _add_actor_visual(actor: Dictionary, index: int, row_count: int) -> void:
	var visual := _create_actor_visual(actor, index, row_count)
	_stage.add_child(visual)
	_actor_nodes[actor["id"]] = visual


func _create_actor_visual(actor: Dictionary, index: int, row_count: int) -> Control:
	var holder := Control.new()
	holder.name = String(actor["id"])
	if actor["team"] == "enemy":
		holder.size = Vector2(260, 370)
		var enemy_spacing := 340.0 if row_count <= 2 else 290.0
		var enemy_left := 300.0 if row_count == 1 else (110.0 if row_count == 2 else 35.0)
		holder.position = Vector2(enemy_left + index * enemy_spacing, 90.0 + float(index % 2) * 34.0)
		holder.set_meta("effect_anchor", Vector2(130, 145))
		holder.set_meta("vfx_size", 224.0)
	elif actor["id"] == &"velociraptor":
		holder.size = Vector2(180, 150)
		holder.position = Vector2(1660, 465)
		holder.set_meta("effect_anchor", Vector2(90, 58))
		holder.set_meta("vfx_size", 144.0)
	else:
		holder.size = Vector2(250, 180)
		var row := StringName(actor.get("formation", "front"))
		holder.position = Vector2(1390 if row == &"back" else 1070, _formation_slot_y(index, row_count))
		holder.set_meta("effect_anchor", Vector2(125, 72))
		holder.set_meta("vfx_size", 176.0)
	var sprite := ACTOR_ANIMATION.new() as CampaignBattleActorAnimation
	sprite.name = "Sprite"
	var actor_texture := load(String(actor["sprite_path"])) as Texture2D
	if actor.has("sprite_region"):
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = actor_texture
		atlas_texture.region = actor["sprite_region"]
		sprite.texture = atlas_texture
	else:
		sprite.texture = actor_texture
	if actor.has("battle_animations"):
		sprite.configure(actor["battle_animations"])
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if actor["team"] == "enemy":
		sprite.position = Vector2(0, 0)
		sprite.size = Vector2(260, 330)
	elif actor["id"] == &"velociraptor":
		sprite.position = Vector2(10, -28)
		sprite.size = Vector2(160, 160)
	else:
		# Directional character files include transparent rotation padding. A
		# square 250px well gives their opaque sprite a consistent JRPG scale.
		sprite.position = Vector2(0, -55)
		sprite.size = Vector2(250, 250)
	holder.add_child(sprite)
	var name_label := Label.new()
	name_label.position = Vector2(-35, 330 if actor["team"] == "enemy" else (122 if actor["id"] == &"velociraptor" else 145))
	name_label.size = Vector2(330 if actor["team"] == "enemy" else 320, 36)
	name_label.text = String(actor["display_name"])
	if actor["team"] == "party" and actor["id"] != &"velociraptor":
		name_label.text += "  •  %s" % String(actor.get("formation", "front")).to_upper()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 23)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.72) if actor["team"] == "party" else Color(1.0, 0.72, 0.78))
	holder.add_child(name_label)
	return holder


func _formation_slot_y(index: int, row_count: int) -> float:
	match row_count:
		1:
			return 220.0
		2:
			return 95.0 + index * 270.0
		_:
			return 20.0 + index * 210.0


func _create_status_row(actor: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = String(actor["id"])
	row.custom_minimum_size = Vector2(0, 29)
	row.add_theme_constant_override("separation", 5)
	var role_icon := TextureRect.new()
	role_icon.custom_minimum_size = Vector2(26, 26)
	role_icon.texture = load(UI_ROOT + ("/dfgui_icon-crown.png" if actor["team"] == "party" else "/dfgui_icon-monsterbook.png"))
	role_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	role_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(role_icon)
	var name_label := Label.new()
	name_label.name = "Name"
	name_label.custom_minimum_size = Vector2(128, 0)
	name_label.text = String(actor["display_name"])
	name_label.add_theme_font_size_override("font_size", 18)
	row.add_child(name_label)
	var hp := Label.new()
	hp.name = "HP"
	hp.custom_minimum_size = Vector2(105, 0)
	hp.add_theme_font_size_override("font_size", 17)
	row.add_child(hp)
	var mp := Label.new()
	mp.name = "MP"
	mp.custom_minimum_size = Vector2(60, 0)
	mp.add_theme_font_size_override("font_size", 17)
	row.add_child(mp)
	var status := Label.new()
	status.name = "Status"
	status.custom_minimum_size = Vector2(70, 0)
	status.add_theme_font_size_override("font_size", 14)
	status.add_theme_color_override("font_color", Color(0.96, 0.66, 0.35))
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(status)
	var atb := ProgressBar.new()
	atb.name = "ATB"
	atb.custom_minimum_size = Vector2(100, 17)
	atb.max_value = 100.0
	atb.show_percentage = false
	atb.add_theme_stylebox_override("background", _atlas_style(UI_PARTY_HUD, Rect2(57, 25, 147, 20), 7, 5))
	# The cyan gauge is a real bar segment from the supplied party HUD rather
	# than a generic flat rectangle laid over the kit's frame.
	var atb_fill := _atlas_style(UI_PARTY_HUD, Rect2(58, 86, 65, 7), 2, 2)
	atb.add_theme_stylebox_override("fill", atb_fill)
	row.add_child(atb)
	return row


func _update_status_display() -> void:
	for actor in model.actors:
		var row: HBoxContainer = _status_nodes.get(actor["id"])
		if not row:
			continue
		row.get_node("HP").text = "HP %d/%d" % [actor["hp"], actor["max_hp"]]
		row.get_node("MP").text = "MP %d" % actor["mp"]
		row.get_node("Status").text = model.status_summary(StringName(actor["id"]))
		row.get_node("ATB").value = actor["atb"]
		row.modulate = Color(0.48, 0.48, 0.52) if not actor["alive"] else Color.WHITE
		var visual: Control = _actor_nodes.get(actor["id"])
		if visual:
			visual.modulate = Color(0.32, 0.32, 0.38, 0.65) if not actor["alive"] else Color.WHITE


func _show_commands(actor_id: StringName) -> void:
	var actor := model.get_actor(actor_id)
	if actor.is_empty() or not actor["alive"]:
		_ready_players.erase(actor_id)
		return
	_command_actor = actor_id
	_command_header.text = "%s is ready" % actor["display_name"]
	_description_label.text = "Choose a command. Enemy gauges remain active."
	_clear_children(_command_buttons)
	for action_id in actor["actions"]:
		var data := CampaignCombatDatabase.action(StringName(action_id))
		var button := Button.new()
		button.text = String(data["name"])
		if data.has("mp"):
			button.text += "   %d MP" % data["mp"]
		var item_id := StringName(data.get("item", &""))
		if item_id != &"":
			button.text += "  ×%d" % int(CampaignState.inventory.get(item_id, 0))
		button.disabled = (
			int(actor["mp"]) < int(data.get("mp", 0))
			or (item_id != &"" and int(CampaignState.inventory.get(item_id, 0)) <= 0)
			or model.valid_targets(actor_id, StringName(action_id)).is_empty()
			or (action_id == &"escape" and not model.can_escape())
		)
		button.custom_minimum_size = Vector2(165, 37)
		button.add_theme_font_size_override("font_size", 23)
		_apply_button_skin(button, _action_icon(StringName(action_id)))
		button.focus_entered.connect(_on_action_focused.bind(StringName(action_id)))
		button.mouse_entered.connect(_on_action_focused.bind(StringName(action_id)))
		button.pressed.connect(_on_action_selected.bind(StringName(action_id)))
		_command_buttons.add_child(button)
	_command_panel.show()
	var first := _first_enabled_button(_command_buttons)
	if first:
		first.grab_focus()


func _on_action_focused(action_id: StringName) -> void:
	_description_label.text = String(CampaignCombatDatabase.action(action_id).get("description", ""))


func _on_action_selected(action_id: StringName) -> void:
	_chosen_action = action_id
	var action := CampaignCombatDatabase.action(action_id)
	if action["target"] in ["all_enemies", "all_allies", "self"]:
		var ids: Array[StringName] = []
		for actor in model.valid_targets(_command_actor, action_id):
			ids.append(StringName(actor["id"]))
		_commit_player_action(ids)
		return
	_clear_children(_target_buttons)
	var title := Label.new()
	title.text = "Choose target"
	title.add_theme_font_size_override("font_size", 31)
	title.add_theme_color_override("font_color", Color(0.88, 0.72, 1.0))
	_target_buttons.add_child(title)
	for actor in model.valid_targets(_command_actor, action_id):
		var button := Button.new()
		button.text = "%s  •  %d/%d HP" % [actor["display_name"], actor["hp"], actor["max_hp"]]
		button.custom_minimum_size.y = 42
		button.add_theme_font_size_override("font_size", 26)
		_apply_button_skin(button, UI_ROOT + "/dfgui_icon-sword.png")
		button.pressed.connect(_commit_player_action.bind([StringName(actor["id"])]))
		_target_buttons.add_child(button)
	_target_panel.show()
	if _target_buttons.get_child_count() > 1:
		(_target_buttons.get_child(1) as Button).grab_focus()


func _commit_player_action(target_ids: Array[StringName]) -> void:
	var actor_id := _command_actor
	var action_id := _chosen_action
	_ready_players.erase(actor_id)
	_command_actor = &""
	_chosen_action = &""
	_command_panel.hide()
	_target_panel.hide()
	_perform_action(actor_id, action_id, target_ids)


func _perform_action(actor_id: StringName, action_id: StringName, targets: Array[StringName]) -> void:
	if _action_lock:
		return
	_action_lock = true
	var events := model.resolve_action(actor_id, action_id, targets)
	if events.is_empty():
		_action_lock = false
		if actor_id not in _pending_ai and model.get_actor(actor_id).get("autonomous", false):
			_pending_ai.append(actor_id)
		return
	_set_message(String(events[0].get("text", "")))
	var source_node: Control = _actor_nodes.get(actor_id)
	var action_animation_duration := _play_actor_action(actor_id, action_id)
	if source_node:
		var start := source_node.position
		var direction := 44.0 if model.get_actor(actor_id)["team"] == "party" else -44.0
		var tween := create_tween()
		tween.tween_property(source_node, "position", start + Vector2(direction, 0), 0.11)
		tween.tween_property(source_node, "position", start, 0.13)
		await tween.finished
	if action_animation_duration > 0.24:
		await get_tree().create_timer(action_animation_duration - 0.24).timeout
	await _animate_action_vfx(action_id, events)
	for event in events:
		if event["type"] in ["damage", "heal", "delay", "mp_restore", "revive", "status_damage"]:
			if event["type"] in ["damage", "status_damage"]:
				_play_actor_once(StringName(event.get("target", &"")), &"hit")
			elif event["type"] == "revive":
				_play_actor_loop(StringName(event.get("target", &"")), &"idle")
			await _animate_effect(event)
		elif event["type"] in ["ko", "status", "cleanse", "escape", "escape_failed"]:
			if event["type"] == "ko":
				_play_actor_hold(StringName(event.get("target", &"")), &"death")
			_set_message(String(event["text"]))
			await get_tree().create_timer(0.28).timeout
	_update_status_display()
	var result := model.outcome()
	if result == &"victory":
		_show_victory()
	elif result == &"defeat":
		_show_defeat()
	elif result == &"escape":
		model.sync_party_vitals()
		await get_tree().create_timer(0.45).timeout
		_leave_battle(false)
	else:
		_action_lock = false


func _animate_effect(event: Dictionary) -> void:
	var target_node: Control = _actor_nodes.get(event["target"])
	if not target_node:
		return
	var amount := int(event.get("amount", 0))
	var label := Label.new()
	var effect_anchor: Vector2 = target_node.get_meta("effect_anchor", Vector2(100, 100))
	label.position = target_node.position + effect_anchor - Vector2(80, 35)
	label.size = Vector2(160, 70)
	match String(event["type"]):
		"heal", "revive":
			label.text = "+%d HP" % amount
		"mp_restore":
			label.text = "+%d MP" % amount
		"delay":
			label.text = "ATB -%d" % amount
		_:
			label.text = "-%d" % amount
	var reaction := StringName(event.get("reaction", &""))
	if reaction == &"weak":
		label.text += "  WEAK!"
	elif reaction == &"resist":
		label.text += "  RESIST"
	elif reaction == &"immune":
		label.text = "IMMUNE"
	if bool(event.get("critical", false)):
		label.text += "  CRITICAL!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 38)
	var effect_color := Color(1.0, 0.42, 0.38)
	if event["type"] in ["heal", "revive"]:
		effect_color = Color(0.45, 1.0, 0.62)
	elif event["type"] == "mp_restore":
		effect_color = Color(0.48, 0.82, 1.0)
	elif event["type"] == "delay":
		effect_color = Color(0.72, 0.58, 1.0)
	elif event["type"] == "status_damage":
		effect_color = Color(0.72, 0.9, 0.28)
	label.add_theme_color_override("font_color", effect_color)
	_stage.add_child(label)
	var original := target_node.position
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 65, 0.42)
	tween.tween_property(label, "modulate:a", 0.0, 0.42)
	if event["type"] in ["damage", "status_damage"]:
		tween.tween_property(target_node, "position:x", original.x + 15, 0.08)
	await tween.finished
	target_node.position = original
	label.queue_free()


func _show_victory() -> void:
	if not active or _result_applied_instance_id == _battle_instance_id:
		return
	_result_applied_instance_id = _battle_instance_id
	_action_lock = true
	_command_panel.hide()
	_target_panel.hide()
	model.sync_party_vitals()
	var reward := model.rewards()
	_play_stream(PRESENTATION.victory_sound())
	for actor in model.actors:
		if actor["team"] == "party" and actor["alive"]:
			_play_actor_loop(StringName(actor["id"]), &"victory")
		elif actor["team"] == "enemy":
			_play_actor_hold(StringName(actor["id"]), &"death")
	CampaignState.record_bestiary_victory(model.encounter_id, _enemy_types_in_battle(), reward["loot"])
	var levels := CampaignState.apply_battle_victory(reward["experience"], reward["duckets"], reward["loot"])
	if model.encounter_id == &"mansion_foyer_intro":
		CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	if not suppress_persistence:
		CampaignState.save_game()
	_clear_children(_results_content)
	_add_result_title("VICTORY", Color(1.0, 0.82, 0.3))
	_add_result_text("The party gained %d EXP and %d Duckets." % [reward["experience"], reward["duckets"]])
	for drop in reward["loot"]:
		_add_result_text("Loot: %s" % drop.get("display_name", "Unknown item"), Color.from_string(drop.get("rarity_color", "#d8d3c5"), Color.WHITE))
	for character_id in levels:
		_add_result_text("%s reached level %d!" % [CampaignState.recruit_catalog.get(character_id, {}).get("name", character_id), levels[character_id][-1]], Color(0.55, 0.9, 1.0))
	var continue_button := Button.new()
	continue_button.text = "Continue exploring"
	continue_button.custom_minimum_size = Vector2(420, 62)
	continue_button.add_theme_font_size_override("font_size", 25)
	_apply_button_skin(continue_button, UI_ROOT + "/dfgui_icon-chatbubble.png")
	continue_button.pressed.connect(_leave_battle.bind(true))
	_results_content.add_child(continue_button)
	_results_panel.show()
	continue_button.grab_focus()


func _show_defeat() -> void:
	_action_lock = true
	_command_panel.hide()
	_target_panel.hide()
	model.sync_party_vitals()
	for actor in model.actors:
		if actor["team"] == "party" and actor.get("counts_for_defeat", true):
			_play_actor_hold(StringName(actor["id"]), &"death")
	_clear_children(_results_content)
	_add_result_title("THE PARTY HAS FALLEN", Color(1.0, 0.36, 0.4))
	_add_result_text("The velociraptor cannot carry five unconscious adventurers. It has standards.")
	var load_button := Button.new()
	load_button.text = "Retry from last save"
	load_button.custom_minimum_size = Vector2(420, 62)
	load_button.add_theme_font_size_override("font_size", 25)
	_apply_button_skin(load_button, UI_ROOT + "/dfgui_icon-clock.png")
	load_button.pressed.connect(_retry_last_save)
	_results_content.add_child(load_button)
	var town_button := Button.new()
	town_button.text = "Return to town with 1 HP"
	town_button.custom_minimum_size = Vector2(420, 62)
	town_button.add_theme_font_size_override("font_size", 25)
	_apply_button_skin(town_button, UI_ROOT + "/dfgui_icon-chatbubble.png")
	town_button.pressed.connect(_return_to_town)
	_results_content.add_child(town_button)
	_results_panel.show()
	load_button.grab_focus()


func _retry_last_save() -> void:
	CampaignState.load_game()
	_leave_battle(false)


func _return_to_town() -> void:
	CampaignState.revive_party_at_one()
	return_to_town_requested.emit()
	_leave_battle(false)


func _leave_battle(victory: bool) -> void:
	if _leave_applied_instance_id == _battle_instance_id:
		return
	_leave_applied_instance_id = _battle_instance_id
	var finished_id := model.encounter_id
	active = false
	hide()
	if _field_node:
		_field_node.show()
	if _field_ui_node:
		_field_ui_node.show()
	FieldEvents.input_paused.emit(false)
	battle_finished.emit(victory, finished_id)


func debug_force_victory() -> void:
	for actor in model.actors:
		if actor["team"] == "enemy":
			actor["hp"] = 0
			actor["alive"] = false
	_show_victory()


func battle_instance_id() -> int:
	return _battle_instance_id


func _actor_animation(actor_id: StringName) -> CampaignBattleActorAnimation:
	var holder: Control = _actor_nodes.get(actor_id)
	if not holder:
		return null
	return holder.get_node_or_null("Sprite") as CampaignBattleActorAnimation


func _play_actor_action(actor_id: StringName, action_id: StringName) -> float:
	var actor := model.get_actor(actor_id)
	var animation_data: Dictionary = actor.get("battle_animations", {})
	var sequence := StringName((animation_data.get("actions", {}) as Dictionary).get(action_id, &""))
	return _play_actor_once(actor_id, sequence)


func _play_actor_once(actor_id: StringName, sequence: StringName) -> float:
	if sequence == &"":
		return 0.0
	var animation := _actor_animation(actor_id)
	return animation.play_once(sequence) if animation else 0.0


func _play_actor_loop(actor_id: StringName, sequence: StringName) -> void:
	var animation := _actor_animation(actor_id)
	if animation:
		animation.play_loop(sequence)


func _play_actor_hold(actor_id: StringName, sequence: StringName) -> void:
	var animation := _actor_animation(actor_id)
	if animation:
		animation.play_hold(sequence)


func _enemy_types_in_battle() -> Array[StringName]:
	var enemy_types: Array[StringName] = []
	for actor in model.actors:
		if String(actor.get("team", "")) != "enemy":
			continue
		var enemy_type := StringName(actor.get("enemy_type", &""))
		if enemy_type != &"":
			enemy_types.append(enemy_type)
	return enemy_types


func _add_result_title(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 52)
	label.add_theme_color_override("font_color", color)
	_results_content.add_child(label)


func _add_result_text(text: String, color := Color(0.9, 0.92, 1.0)) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", color)
	_results_content.add_child(label)


func _set_message(text: String) -> void:
	_message_label.text = text


func _panel(rect: Rect2, background: Color, border: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	# Use the supplied Dark RPG GUI's framed portrait well as a scalable
	# nine-patch. Its dark center and gold edge stay pixel-crisp at every panel
	# size, instead of falling back to generic Godot rectangles.
	var style := _atlas_style(UI_PARTY_HUD, Rect2(2, 2, 53, 53), 7, 7)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _atlas_style(path: String, region: Rect2, edge: float, content: float) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path)
	atlas.region = region
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.set_texture_margin(SIDE_LEFT, edge)
	style.set_texture_margin(SIDE_TOP, edge)
	style.set_texture_margin(SIDE_RIGHT, edge)
	style.set_texture_margin(SIDE_BOTTOM, edge)
	style.content_margin_left = content
	style.content_margin_top = content
	style.content_margin_right = content
	style.content_margin_bottom = content
	return style


func _texture_style(path: String, tint := Color.WHITE, horizontal_edge := 8.0, vertical_edge := 8.0) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	# UI_BUTTON is a 26px inventory icon well, not a scalable text button.
	# Reuse the kit's framed HUD well as a proper nine-patch instead.
	style.texture = atlas
	style.modulate_color = tint
	style.set_texture_margin(SIDE_LEFT, 7)
	style.set_texture_margin(SIDE_RIGHT, 7)
	style.set_texture_margin(SIDE_TOP, 7)
	style.set_texture_margin(SIDE_BOTTOM, 7)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _apply_button_skin(button: Button, icon_path := "") -> void:
	button.add_theme_stylebox_override("normal", _texture_style(UI_BUTTON))
	button.add_theme_stylebox_override("hover", _texture_style(UI_BUTTON, Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("focus", _texture_style(UI_BUTTON, Color(1.0, 0.9, 0.58)))
	button.add_theme_stylebox_override("pressed", _texture_style(UI_BUTTON, Color(0.62, 0.68, 0.78)))
	button.add_theme_stylebox_override("disabled", _texture_style(UI_BUTTON, Color(0.42, 0.45, 0.52, 0.75)))
	button.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.72, 0.28))
	if not icon_path.is_empty():
		button.icon = load(icon_path)
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 40)


func _action_icon(action_id: StringName) -> String:
	match action_id:
		&"attack", &"cane_tap", &"raptor_pounce", &"mossback_pummel":
			return UI_ROOT + "/dfgui_icon-sword.png"
		&"pummel":
			return UI_ROOT + "/dfgui_icon-axe.png"
		&"defend", &"rally":
			return UI_ROOT + "/dfgui_icon-shield.png"
		&"tonic", &"field_triage", &"ether", &"smelling_salts", &"phoenix_tonic", &"hearty_provisions":
			return UI_ROOT + "/dfgui_icon-cauldron.png"
		&"static_discharge", &"voltaic_cage", &"raptor_distract", &"spore_receipt", &"rooted_red_tape":
			return UI_ROOT + "/dfgui_icon-wand.png"
		&"escape":
			return UI_ROOT + "/dfgui_icon-clock.png"
		_:
			return UI_ROOT + "/dfgui_icon-skillbook.png"


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _first_enabled_button(container: Node) -> Button:
	for child in container.get_children():
		if child is Button and not child.disabled:
			return child
	return null


func _animate_action_vfx(action_id: StringName, events: Array[Dictionary]) -> void:
	var frame_paths := PRESENTATION.effect_frames(action_id)
	_play_stream(PRESENTATION.action_sound(action_id))
	if frame_paths.is_empty():
		return
	var target_ids: Array[StringName] = []
	for event in events:
		if event.has("target") and event["type"] in ["damage", "heal", "delay", "mp_restore", "revive", "status", "cleanse"]:
			var target_id := StringName(event["target"])
			if target_id not in target_ids:
				target_ids.append(target_id)
	var overlays: Array[TextureRect] = []
	for target_id in target_ids:
		var target_node: Control = _actor_nodes.get(target_id)
		if not target_node:
			continue
		var overlay := TextureRect.new()
		var effect_anchor: Vector2 = target_node.get_meta("effect_anchor", Vector2(100, 100))
		var vfx_size := float(target_node.get_meta("vfx_size", 224.0))
		overlay.position = target_node.position + effect_anchor - Vector2(vfx_size * 0.5, vfx_size * 0.5)
		overlay.size = Vector2(vfx_size, vfx_size)
		overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage.add_child(overlay)
		overlays.append(overlay)
	for frame_path in frame_paths:
		var texture: Texture2D = _frame_cache.get(frame_path)
		if not texture:
			texture = load(frame_path) as Texture2D
			_frame_cache[frame_path] = texture
		for overlay in overlays:
			overlay.texture = texture
		# The source pack is authored at 30 fps. Keeping that cadence preserves
		# readable impact frames instead of flashing through them in a few ticks.
		await get_tree().create_timer(1.0 / 30.0).timeout
	for overlay in overlays:
		overlay.queue_free()


func _play_stream(path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	_sfx_player.stream = load(path)
	_sfx_player.play()
