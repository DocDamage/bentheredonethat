class_name CampaignMansionPacing
extends RefCounted

## Authored traversal/read/combat budgets for the opening-through-Mansion slice.
## These are production targets for playtest comparison, not a substitute for
## recorded human runs.
const SLICE_MINUTES := [
	{"id": &"opening", "min": 10, "target": 12, "max": 15},
	{"id": &"franklin_laboratory", "min": 8, "target": 10, "max": 12},
	{"id": &"HM-01", "min": 4, "target": 5, "max": 6},
	{"id": &"HM-02", "min": 8, "target": 10, "max": 13},
	{"id": &"HM-03", "min": 5, "target": 7, "max": 9},
	{"id": &"HM-04", "min": 5, "target": 7, "max": 9},
	{"id": &"HM-05", "min": 7, "target": 8, "max": 10},
	{"id": &"HM-14", "min": 4, "target": 5, "max": 6},
	{"id": &"HM-06", "min": 8, "target": 11, "max": 14},
	{"id": &"HM-15", "min": 3, "target": 4, "max": 5},
	{"id": &"HM-07", "min": 8, "target": 11, "max": 14},
	{"id": &"HM-08", "min": 5, "target": 7, "max": 9},
	{"id": &"HM-09", "min": 15, "target": 20, "max": 28},
]

const OPTIONAL_ROOM_IDS := [&"HM-10", &"HM-11", &"HM-12", &"HM-13", &"HM-16"]


static func totals() -> Dictionary:
	var result := {"min": 0, "target": 0, "max": 0}
	for segment in SLICE_MINUTES:
		for key in result:
			result[key] = int(result[key]) + int(segment[key])
	return result


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for segment in SLICE_MINUTES:
		var segment_id := StringName(segment.get("id", &""))
		if segment_id == &"" or seen.has(segment_id):
			errors.append("Mansion pacing segments need unique IDs.")
		seen[segment_id] = true
		if int(segment.get("min", 0)) <= 0 or int(segment.get("min", 0)) > int(segment.get("target", 0)) or int(segment.get("target", 0)) > int(segment.get("max", 0)):
			errors.append("Mansion pacing segment %s has an invalid range." % segment_id)
	var summary := totals()
	if int(summary["min"]) != 90 or int(summary["max"]) != 150:
		errors.append("Opening-through-Mansion pacing must retain the 90-150 minute product target.")
	for required_id in [&"opening", &"franklin_laboratory", &"HM-01", &"HM-02", &"HM-03", &"HM-04", &"HM-05", &"HM-14", &"HM-06", &"HM-15", &"HM-07", &"HM-08", &"HM-09"]:
		if not seen.has(required_id):
			errors.append("Mansion pacing omits %s." % required_id)
	return PackedStringArray(errors)
