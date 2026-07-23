class_name CampaignMansionLegacyAdapter
extends RefCounted

## Temporary bridge for the five-room procedural Mansion proof.  It owns the
## legacy cell-to-area and camera rectangles so CampaignBootstrap can stop
## growing Mansion-specific geometry while the HM-01..HM-16 manifest migrates
## one authored room at a time.

const ORIGIN := Vector2i(0, 32)
const SIZE := Vector2i(28, 18)
const AREA_BOUNDS := {
	&"mansion_foyer": Rect2i(ORIGIN, Vector2i(8, 8)),
	&"mansion_archive": Rect2i(ORIGIN + Vector2i(10, 0), Vector2i(8, 8)),
	&"mansion_gallery": Rect2i(ORIGIN + Vector2i(0, 10), Vector2i(8, 8)),
	&"mansion_nursery": Rect2i(ORIGIN + Vector2i(10, 10), Vector2i(8, 8)),
	&"mansion_ballroom": Rect2i(ORIGIN + Vector2i(20, 5), Vector2i(8, 8)),
}


static func passage_gate_cell() -> Vector2i:
	return ORIGIN + Vector2i(6, 4)


static func ballroom_gate_cell() -> Vector2i:
	return ORIGIN + Vector2i(16, 14)


static func passage_transition_definitions() -> Array[Dictionary]:
	return [
		{&"name": "MansionServantsPassage", &"from": passage_gate_cell(), &"to": ORIGIN + Vector2i(12, 5)},
		{&"name": "MansionServantsPassageReturn", &"from": ORIGIN + Vector2i(11, 4), &"to": ORIGIN + Vector2i(5, 5)},
		{&"name": "MansionArchiveToGallery", &"from": ORIGIN + Vector2i(14, 6), &"to": ORIGIN + Vector2i(4, 15)},
		{&"name": "MansionGalleryToArchive", &"from": ORIGIN + Vector2i(4, 16), &"to": ORIGIN + Vector2i(14, 5)},
		{&"name": "MansionGalleryToNursery", &"from": ORIGIN + Vector2i(6, 14), &"to": ORIGIN + Vector2i(12, 15)},
		{&"name": "MansionNurseryToGallery", &"from": ORIGIN + Vector2i(11, 14), &"to": ORIGIN + Vector2i(5, 15)},
		{&"name": "MansionFoyerServiceShortcut", &"from": ORIGIN + Vector2i(1, 6), &"to": ORIGIN + Vector2i(1, 16)},
		{&"name": "MansionGalleryServiceShortcut", &"from": ORIGIN + Vector2i(1, 16), &"to": ORIGIN + Vector2i(1, 6)},
	]


static func ballroom_transition_definitions() -> Array[Dictionary]:
	return [
		{&"name": "MansionNurseryToBallroom", &"from": ballroom_gate_cell(), &"to": ORIGIN + Vector2i(22, 10)},
		{&"name": "MansionBallroomToNursery", &"from": ORIGIN + Vector2i(21, 10), &"to": ORIGIN + Vector2i(15, 15)},
	]


static func contains(cell: Vector2i) -> bool:
	return Rect2i(ORIGIN, SIZE).has_point(cell)


static func area_for_cell(cell: Vector2i) -> StringName:
	if not contains(cell):
		return &""
	var local := cell - ORIGIN
	# Preserve the old five-stage topology exactly while it is a compatibility
	# adapter. New HM ids must use the registry/streamer path instead.
	if local.x >= 20:
		return &"mansion_ballroom"
	if local.y >= 10 and local.x >= 10:
		return &"mansion_nursery"
	if local.y >= 10:
		return &"mansion_gallery"
	if local.x >= 10:
		return &"mansion_archive"
	return &"mansion_foyer"


static func has_area(area: StringName) -> bool:
	return AREA_BOUNDS.has(area)


static func bounds_for_area(area: StringName) -> Rect2i:
	return AREA_BOUNDS.get(area, Rect2i()) as Rect2i


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if AREA_BOUNDS.size() != 5:
		errors.append("Legacy Mansion adapter must retain exactly five compatibility areas.")
	for area in AREA_BOUNDS:
		var bounds: Rect2i = bounds_for_area(area)
		if bounds.size != Vector2i(8, 8) or not Rect2i(ORIGIN, SIZE).encloses(bounds):
			errors.append("Legacy Mansion area %s has invalid camera bounds." % area)
	if area_for_cell(ORIGIN + Vector2i(4, 6)) != &"mansion_foyer":
		errors.append("Legacy Mansion foyer spawn no longer resolves to the foyer.")
	if area_for_cell(ORIGIN + Vector2i(24, 10)) != &"mansion_ballroom":
		errors.append("Legacy Mansion ballroom cell no longer resolves to the ballroom.")
	_validate_transition_definitions(errors, passage_transition_definitions(), 8, "passage")
	_validate_transition_definitions(errors, ballroom_transition_definitions(), 2, "ballroom")
	return PackedStringArray(errors)


static func _validate_transition_definitions(errors: Array[String], definitions: Array[Dictionary], expected_count: int, label: String) -> void:
	if definitions.size() != expected_count:
		errors.append("Legacy Mansion %s transition count is %d; expected %d." % [label, definitions.size(), expected_count])
	var names: Dictionary = {}
	for definition in definitions:
		var transition_name: String = String(definition.get(&"name", ""))
		var source_cell: Variant = definition.get(&"from")
		var arrival_cell: Variant = definition.get(&"to")
		if transition_name.is_empty() or names.has(transition_name):
			errors.append("Legacy Mansion %s transitions must have unique names." % label)
		else:
			names[transition_name] = true
		if not source_cell is Vector2i or not contains(source_cell):
			errors.append("Legacy Mansion %s transition %s has an invalid source cell." % [label, transition_name])
		if not arrival_cell is Vector2i or not contains(arrival_cell):
			errors.append("Legacy Mansion %s transition %s has an invalid arrival cell." % [label, transition_name])
