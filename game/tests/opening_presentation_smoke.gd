extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	# Loading the authored scene proves the shipped New Adventure path contains
	# the in-world opening and campaign-skinned dialogue layout without starting
	# Dialogic during headless teardown (Dialogic 2.0-alpha access-violates when a
	# live timeline and RenderingServer are destroyed in the same test frame).
	var main: Node = load("res://src/main.tscn").instantiate()
	var opening = main.get_node_or_null("Field/OpeningCutscene")
	var veil := main.get_node_or_null("Field/OpeningCutscene/Background/ColorRect") as ColorRect
	var dialogue := main.get_node_or_null("UI/DialogueLayout") as Control
	if not opening or not veil or not dialogue:
		_fail("The shipped main scene is missing its opening or dialogue layout")
		return
	if veil.color.a > 0.3 or veil.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("The opening still contains an opaque or input-blocking field cover")
		return
	if not opening.timeline or dialogue.get_script().resource_path != "res://src/field/ui/dialogue_window.gd":
		_fail("The opening is not wired to the campaign-skinned supplied dialogue UI")
		return
	var timeline_file := FileAccess.open("res://overworld/maps/opening_cutscene.dtl", FileAccess.READ)
	var timeline_text := timeline_file.get_as_text() if timeline_file else ""
	if "Every house we raise" not in timeline_text or "founding New Philadelphia" not in timeline_text:
		_fail("The opening timeline does not establish the multiverse and founding premise")
		return
	main.free()

	# Exercise the real field animation independently: the pet must remain a full
	# trailing step away and continue prowling while Ben is idle.
	var animation := load("res://ben_rpg/characters/ben_field_animation.tscn").instantiate() as BenFieldAnimation
	add_child(animation)
	await get_tree().process_frame
	animation.set_direction(Directions.Points.SOUTH)
	animation.play("idle")
	for _frame in range(24):
		await get_tree().process_frame
	var ben_sprite := animation.get_node("Anchor/Sprite") as Sprite2D
	var raptor := animation.get_node("Anchor/Raptor") as Sprite2D
	if not raptor.texture or raptor.position.distance_to(ben_sprite.position) < 42.0:
		_fail("The velociraptor is still composited into Ben instead of trailing him")
		return
	var start_position := raptor.position
	var start_frame: int = animation._raptor_frame
	# Advance a fixed amount of simulated time. Counting rendered frames made
	# this assertion depend on host speed: a fast headless run could render all
	# 30 frames before either the patrol motion or five-fps sprite cycle advanced.
	# Use 0.8 seconds so the six-frame cycle cannot wrap to its starting frame.
	for _frame in range(24):
		animation._process(1.0 / 30.0)
	if raptor.position.distance_to(start_position) < 0.2 or animation._raptor_frame == start_frame:
		_fail("The idle velociraptor did not prowl or animate independently")
		return
	print("OPENING_PRESENTATION_SMOKE_OK field_visible=true supplied_dialogue=true premise=multiverse+town pet_trail>=42 pet_idle=animated")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("OPENING_PRESENTATION_SMOKE_FAILED: " + message)
	get_tree().quit(1)
