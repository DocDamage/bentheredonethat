class_name TownResidentCatalog
extends RefCounted

## Immutable legacy-town identities. Runtime occupancy, movement, persistence,
## and dialogue presentation stay outside this catalog so the current four
## residents can share the same path to the generated population registry.

const ASSET_ROOT := "res://game_assets/characters/NPCs/Cozy Village NPC Collection Vol.1"

const PROFILES := {
	&"cafe_owner": {
		"name": "Mara Bell", "role": "Café proprietor", "facility": "Cafe",
		"asset": "3._Caf_Owner", "home": Vector2i(40, 3), "work": Vector2i(44, 9),
		"plaza": Vector2i(49, 11), "errand": Vector2i(41, 15), "work_label": "PREPARING SERVICE",
		"work_tasks": [
			{"label": "GRINDING COFFEE", "station": -2, "pose": &"craft"},
			{"label": "SERVING THE COUNTER", "station": 0, "pose": &"serve"},
			{"label": "CHECKING THE PANTRY", "station": 2, "pose": &"inspect"},
		],
	},
	&"librarian": {
		"name": "Elias Quill", "role": "Town librarian", "facility": "Library",
		"asset": "9._Librarian", "home": Vector2i(64, 3), "work": Vector2i(57, 9),
		"plaza": Vector2i(51, 11), "errand": Vector2i(62, 15), "work_label": "CATALOGING BOOKS",
		"work_tasks": [
			{"label": "SHELVING FIELD REPORTS", "station": -2, "pose": &"inspect"},
			{"label": "CATALOGING MONSTERS", "station": 0, "pose": &"craft"},
			{"label": "DECODING A FAULT-LINE MAP", "station": 2, "pose": &"inspect"},
		],
	},
	&"farmer": {
		"name": "Ada Furrow", "role": "Town grower", "requires_foundations": true,
		"asset": "2._Village_Farmer", "home": Vector2i(39, 18), "work": Vector2i(43, 18),
		"plaza": Vector2i(49, 12), "errand": Vector2i(41, 12), "work_label": "TENDING CROPS",
		"work_tasks": [
			{"label": "WATERING THE EAST ROW", "station": -2, "pose": &"craft"},
			{"label": "TURNING COMPOST", "station": 0, "pose": &"craft"},
			{"label": "HARVESTING TOWN PRODUCE", "station": 2, "pose": &"inspect"},
		],
	},
	&"clinic_aide": {
		"name": "Nell Shepherd", "role": "Clinic aide", "facility": "Clinic",
		"asset": "11._Shepherd_Girl", "home": Vector2i(64, 18), "work": Vector2i(58, 17),
		"plaza": Vector2i(52, 12), "errand": Vector2i(61, 12), "work_label": "CHECKING SUPPLIES",
		"work_tasks": [
			{"label": "STERILIZING INSTRUMENTS", "station": -2, "pose": &"craft"},
			{"label": "PREPARING TONICS", "station": 0, "pose": &"serve"},
			{"label": "CHECKING RECOVERY COTS", "station": 2, "pose": &"inspect"},
		],
	},
}


static func profile(resident_id: StringName) -> Dictionary:
	return (PROFILES.get(resident_id, {}) as Dictionary).duplicate(true)


static func resident_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for resident_id in PROFILES:
		ids.append(StringName(resident_id))
	return ids


static func rotation_path(resident_id: StringName, direction: StringName = &"south") -> String:
	var value := profile(resident_id)
	var asset := String(value.get("asset", ""))
	return "%s/%s/rotations/%s.png" % [ASSET_ROOT, asset, direction]


static func dialogue_lines(resident_id: StringName, library_record: Dictionary = {}, postgame: bool = false) -> Array[String]:
	var lines: Array[String] = []
	match resident_id:
		&"cafe_owner":
			lines.append("MARA: A town runs on three things: safe roads, hot coffee, and someone remembering who still owes for pie.")
			if postgame:
				lines.append("MARA: Since the Court stopped taxing altitude, the pie rises exactly as much as it wants to.")
		&"librarian":
			lines.append("ELIAS: The field ledger currently lists %d of %d known species. Defeat one and I can add its habits and drops." % [library_record.get("bestiary_seen", 0), library_record.get("bestiary_total", 0)])
			if postgame:
				lines.append("ELIAS: The Tribunal Ledger offers a strictly recreational gravity hearing. I have marked it: NO DUPLICATE REWARDS.")
		&"farmer":
			lines.append("ADA: Facility work keeps progressing while you adventure. A specialist finishes faster; adjacent training improves the harvest.")
			if postgame:
				lines.append("ADA: The new fault-line lamps keep the east row warm. Apparently public gravity is good for tomatoes.")
		&"clinic_aide":
			lines.append("NELL: Save points restore the whole company. If everyone falls, we can still bring them home with one HP—dignity costs extra.")
			if postgame:
				lines.append("NELL: The Archangel volunteered at the Clinic. Their bedside manner is celestial, but their handwriting is terrible.")
	return lines


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if PROFILES.size() != 4:
		errors.append("Legacy resident catalog must preserve four stable identities.")
	for resident_id in resident_ids():
		var value := profile(resident_id)
		if String(value.get("name", "")).is_empty() or String(value.get("role", "")).is_empty() or String(value.get("asset", "")).is_empty():
			errors.append("Resident %s is missing identity data." % resident_id)
		if not value.has("home") or not value.has("work") or not value.has("plaza") or not value.has("errand"):
			errors.append("Resident %s is missing a routine target." % resident_id)
		if not ResourceLoader.exists(rotation_path(resident_id)):
			errors.append("Resident %s is missing its south rotation." % resident_id)
	return PackedStringArray(errors)
