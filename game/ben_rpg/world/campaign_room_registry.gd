class_name CampaignRoomRegistry
extends RefCounted

## Data-only room graph for authored campaign areas.  The legacy five-room
## Mansion remains live until each room is migrated, but all new Mansion work
## must bind through these stable room ids rather than bootstrap coordinates.

const MANSION_ROOM_IDS := [
	&"HM-01", &"HM-02", &"HM-03", &"HM-04", &"HM-05", &"HM-06", &"HM-07", &"HM-08",
	&"HM-09", &"HM-10", &"HM-11", &"HM-12", &"HM-13", &"HM-14", &"HM-15", &"HM-16",
]
const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")

const ASTERION_ROOM_IDS := [
	&"AS-01", &"AS-02", &"AS-03", &"AS-04", &"AS-05", &"AS-06", &"AS-07", &"AS-08",
	&"AS-09", &"AS-10", &"AS-11", &"AS-12", &"AS-13", &"AS-14",
]

const PRIMEVAL_ROOM_IDS := [
	&"PV-01", &"PV-02", &"PV-03", &"PV-04", &"PV-05", &"PV-06", &"PV-07", &"PV-08",
	&"PV-09", &"PV-10", &"PV-11", &"PV-12", &"PV-13", &"PV-14",
]
const HELIOS_ROOM_IDS := [&"HE-01", &"HE-02", &"HE-03", &"HE-04", &"HE-05", &"HE-06", &"HE-07", &"HE-08", &"HE-09", &"HE-10", &"HE-11", &"HE-12", &"HE-13", &"HE-14"]
const FROSTHOLD_ROOM_IDS := [&"FR-01", &"FR-02", &"FR-03", &"FR-04", &"FR-05", &"FR-06", &"FR-07", &"FR-08", &"FR-09", &"FR-10", &"FR-11", &"FR-12", &"FR-13", &"FR-14"]
const MOONPETAL_ROOM_IDS := [&"MP-01", &"MP-02", &"MP-03", &"MP-04", &"MP-05", &"MP-06", &"MP-07", &"MP-08", &"MP-09", &"MP-10", &"MP-11", &"MP-12", &"MP-13", &"MP-14"]
const EMPYREAL_ROOM_IDS := [
	&"EM-01", &"EM-02", &"EM-03", &"EM-04", &"EM-05", &"EM-06", &"EM-07", &"EM-08",
	&"EM-09", &"EM-10", &"EM-11", &"EM-12", &"EM-13", &"EM-14", &"EM-15", &"EM-16",
]

## Facility portal records keep the town-facing name, entry room, and full
## manifest graph together. Bootstrap only supplies the constructed lot's door
## and return cells; new authored worlds require data here, not a new branch.
const FACILITY_PORTALS := {
	&"Haunted Mansion": {"prefix": "HauntedMansion", "entryRoomId": &"HM-01", "roomIds": MANSION_ROOM_IDS, "destinationId": &"haunted_mansion"},
	&"Observatory": {"prefix": "AsterionStation", "entryRoomId": &"AS-01", "roomIds": ASTERION_ROOM_IDS},
	&"Trailhead Lodge": {"prefix": "PrimevalExpanse", "entryRoomId": &"PV-01", "roomIds": PRIMEVAL_ROOM_IDS},
	&"Afterlight Club": {"prefix": "HeliosArcology", "entryRoomId": &"HE-01", "roomIds": HELIOS_ROOM_IDS},
	&"Cold Storage": {"prefix": "FrostholdKingdom", "entryRoomId": &"FR-01", "roomIds": FROSTHOLD_ROOM_IDS},
	&"Tea House": {"prefix": "MoonpetalCourt", "entryRoomId": &"MP-01", "roomIds": MOONPETAL_ROOM_IDS},
	&"Belfry": {"prefix": "EmpyrealCourt", "entryRoomId": &"EM-01", "roomIds": EMPYREAL_ROOM_IDS},
}

# Section 23.2 blueprint records. Coordinates are room-local movement cells;
# the camera contract is derived from these dimensions at 48 world pixels per
# cell. Keeping this matrix here prevents future rooms from inventing offsets in
# the bootstrap or renderer.
const BLUEPRINTS := {
	&"S1": {"dimensions": Vector2i(14, 10), "ports": {&"Nw": Vector2i(4, 1), &"Ne": Vector2i(9, 1), &"E1": Vector2i(12, 3), &"E2": Vector2i(12, 6), &"Se": Vector2i(9, 8), &"Sw": Vector2i(4, 8), &"W2": Vector2i(1, 6), &"W1": Vector2i(1, 3)}},
	&"S2": {"dimensions": Vector2i(16, 10), "ports": {&"Nw": Vector2i(5, 1), &"Ne": Vector2i(10, 1), &"E1": Vector2i(14, 3), &"E2": Vector2i(14, 6), &"Se": Vector2i(10, 8), &"Sw": Vector2i(5, 8), &"W2": Vector2i(1, 6), &"W1": Vector2i(1, 3)}},
	&"S3": {"dimensions": Vector2i(18, 10), "ports": {&"Nw": Vector2i(6, 1), &"Ne": Vector2i(12, 1), &"E1": Vector2i(16, 3), &"E2": Vector2i(16, 6), &"Se": Vector2i(12, 8), &"Sw": Vector2i(6, 8), &"W2": Vector2i(1, 6), &"W1": Vector2i(1, 3)}},
	&"M1": {"dimensions": Vector2i(18, 14), "ports": {&"Nw": Vector2i(6, 1), &"Ne": Vector2i(12, 1), &"E1": Vector2i(16, 4), &"E2": Vector2i(16, 9), &"Se": Vector2i(12, 12), &"Sw": Vector2i(6, 12), &"W2": Vector2i(1, 9), &"W1": Vector2i(1, 4)}},
	&"M2": {"dimensions": Vector2i(20, 14), "ports": {&"Nw": Vector2i(6, 1), &"Ne": Vector2i(13, 1), &"E1": Vector2i(18, 4), &"E2": Vector2i(18, 9), &"Se": Vector2i(13, 12), &"Sw": Vector2i(6, 12), &"W2": Vector2i(1, 9), &"W1": Vector2i(1, 4)}},
	&"M3": {"dimensions": Vector2i(22, 14), "ports": {&"Nw": Vector2i(7, 1), &"Ne": Vector2i(14, 1), &"E1": Vector2i(20, 4), &"E2": Vector2i(20, 9), &"Se": Vector2i(14, 12), &"Sw": Vector2i(7, 12), &"W2": Vector2i(1, 9), &"W1": Vector2i(1, 4)}},
	&"M4": {"dimensions": Vector2i(18, 16), "ports": {&"Nw": Vector2i(6, 1), &"Ne": Vector2i(12, 1), &"E1": Vector2i(16, 5), &"E2": Vector2i(16, 10), &"Se": Vector2i(12, 14), &"Sw": Vector2i(6, 14), &"W2": Vector2i(1, 10), &"W1": Vector2i(1, 5)}},
	&"L1": {"dimensions": Vector2i(24, 18), "ports": {&"Nw": Vector2i(8, 1), &"Ne": Vector2i(16, 1), &"E1": Vector2i(22, 6), &"E2": Vector2i(22, 12), &"Se": Vector2i(16, 16), &"Sw": Vector2i(8, 16), &"W2": Vector2i(1, 12), &"W1": Vector2i(1, 6)}},
	&"L2": {"dimensions": Vector2i(26, 18), "ports": {&"Nw": Vector2i(8, 1), &"Ne": Vector2i(17, 1), &"E1": Vector2i(24, 6), &"E2": Vector2i(24, 12), &"Se": Vector2i(17, 16), &"Sw": Vector2i(8, 16), &"W2": Vector2i(1, 12), &"W1": Vector2i(1, 6)}},
	&"L3": {"dimensions": Vector2i(28, 18), "ports": {&"Nw": Vector2i(9, 1), &"Ne": Vector2i(18, 1), &"E1": Vector2i(26, 6), &"E2": Vector2i(26, 12), &"Se": Vector2i(18, 16), &"Sw": Vector2i(9, 16), &"W2": Vector2i(1, 12), &"W1": Vector2i(1, 6)}},
	&"L4": {"dimensions": Vector2i(24, 20), "ports": {&"Nw": Vector2i(8, 1), &"Ne": Vector2i(16, 1), &"E1": Vector2i(22, 6), &"E2": Vector2i(22, 13), &"Se": Vector2i(16, 18), &"Sw": Vector2i(8, 18), &"W2": Vector2i(1, 13), &"W1": Vector2i(1, 6)}},
}

static var MANSION_ROOMS := {
	&"HM-01": _room(&"M1", &"zone", &"none", 4, [[&"Nw", &"FI-05"], [&"Ne", &"HM-02"]]),
	&"HM-02": _room(&"L2", &"zone", &"none", 6, [[&"Nw", &"HM-01"], [&"Ne", &"HM-03"], [&"E1", &"HM-04"], [&"E2", &"HM-10"]]),
	&"HM-03": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"HM-02"]]),
	&"HM-04": _room(&"S1", &"zone", &"none", 2, [[&"Nw", &"HM-02"], [&"Ne", &"HM-05"], [&"E1", &"HM-12"]]),
	&"HM-05": _room(&"M1", &"scripted_only", &"none", 4, [[&"Nw", &"HM-04"], [&"Ne", &"HM-11"], [&"E1", &"HM-14"], [&"E2", &"HM-16"]]),
	&"HM-06": _room(&"L2", &"scripted_only", &"Tne", 6, [[&"Nw", &"HM-14"], [&"Ne", &"HM-15"]]),
	&"HM-07": _room(&"M3", &"scripted_only", &"Tse", 4, [[&"Nw", &"HM-15"], [&"Ne", &"HM-08"], [&"E1", &"HM-11"]]),
	&"HM-08": _room(&"M4", &"none", &"none", 4, [[&"Nw", &"HM-07"], [&"Ne", &"HM-09"], [&"E1", &"HM-13"], [&"E2", &"HM-16"]]),
	&"HM-09": _room(&"L1", &"boss", &"none", 6, [[&"Nw", &"HM-08"]]),
	&"HM-10": _room(&"M2", &"scripted_only", &"Tne", 4, [[&"Nw", &"HM-02"], [&"Ne", &"HM-15"]]),
	&"HM-11": _room(&"M3", &"zone", &"Tse", 4, [[&"Nw", &"HM-05"], [&"Ne", &"HM-07"], [&"E1", &"HM-12"]]),
	&"HM-12": _room(&"L4", &"scripted_only", &"none", 6, [[&"Nw", &"HM-04"], [&"Ne", &"HM-11"]]),
	&"HM-13": _room(&"M1", &"zone", &"Tnw", 4, [[&"Nw", &"HM-14"], [&"Ne", &"HM-08"]]),
	&"HM-14": _room(&"M2", &"none", &"none", 4, [[&"Nw", &"HM-05"], [&"Ne", &"HM-06"], [&"E1", &"HM-13"]]),
	&"HM-15": _room(&"S3", &"none", &"none", 2, [[&"Nw", &"HM-06"], [&"Ne", &"HM-07"], [&"E1", &"HM-10"]]),
	&"HM-16": _room(&"M4", &"none", &"Tsw", 4, [[&"Nw", &"HM-05"], [&"Ne", &"HM-08"]]),
}

# The complete Asterion graph is registered before all of its scenes are
# authored.  Runtime navigation exposes only authored destinations, which lets
# early rooms carry their final reciprocal contracts without opening dead ends.
static var ASTERION_ROOMS := {
	&"AS-01": _room(&"L1", &"zone", &"none", 6, [[&"Nw", &"FI-06"], [&"Ne", &"AS-02"], [&"E1", &"AS-14"]]),
	&"AS-02": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"AS-01"], [&"Ne", &"AS-03"], [&"E1", &"AS-09"]]),
	&"AS-03": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"AS-02"], [&"Ne", &"AS-12"], [&"E1", &"AS-13"]]),
	&"AS-04": _room(&"M4", &"scripted_only", &"none", 4, [[&"Nw", &"AS-13"], [&"Ne", &"AS-12"]]),
	&"AS-05": _room(&"M1", &"scripted_only", &"none", 4, [[&"Nw", &"AS-13"], [&"Ne", &"AS-06"], [&"E1", &"AS-10"]]),
	&"AS-06": _room(&"L2", &"none", &"none", 6, [[&"Nw", &"AS-05"], [&"Ne", &"AS-07"]]),
	&"AS-07": _room(&"M3", &"boss", &"none", 4, [[&"Nw", &"AS-06"], [&"Ne", &"AS-08"], [&"E1", &"AS-10"], [&"E2", &"AS-13"], [&"Se", &"AS-14"]]),
	&"AS-08": _room(&"L4", &"boss", &"Tsw", 6, [[&"Nw", &"AS-07"], [&"Ne", &"AS-11"]]),
	&"AS-09": _room(&"M1", &"zone", &"Tnw", 4, [[&"Nw", &"AS-02"]]),
	&"AS-10": _room(&"L2", &"zone", &"none", 6, [[&"Nw", &"AS-05"], [&"Ne", &"AS-07"]]),
	&"AS-11": _room(&"M3", &"boss", &"Tse", 4, [[&"Nw", &"AS-13"], [&"Ne", &"AS-08"]]),
	&"AS-12": _room(&"M4", &"zone", &"Tsw", 4, [[&"Nw", &"AS-03"], [&"Ne", &"AS-04"]]),
	&"AS-13": _room(&"M1", &"none", &"none", 4, [[&"Nw", &"AS-03"], [&"Ne", &"AS-04"], [&"E1", &"AS-05"], [&"E2", &"AS-07"], [&"Se", &"AS-11"]]),
	&"AS-14": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"AS-01"], [&"Ne", &"AS-07"]]),
}

static var PRIMEVAL_ROOMS := {
	&"PV-01": _room(&"L1", &"boss", &"none", 6, [[&"Nw", &"FI-07"], [&"Ne", &"PV-02"], [&"E1", &"PV-13"]]),
	&"PV-02": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"PV-01"], [&"Ne", &"PV-03"], [&"E1", &"PV-13"]]),
	&"PV-03": _room(&"L3", &"zone", &"none", 6, [[&"Nw", &"PV-02"], [&"Ne", &"PV-04"], [&"E1", &"PV-07"], [&"E2", &"PV-10"], [&"Se", &"PV-14"]]),
	&"PV-04": _room(&"M4", &"zone", &"none", 4, [[&"Nw", &"PV-03"], [&"Ne", &"PV-05"], [&"E1", &"PV-11"]]),
	&"PV-05": _room(&"L1", &"zone", &"Tnw", 6, [[&"Nw", &"PV-04"], [&"Ne", &"PV-06"], [&"E1", &"PV-09"], [&"E2", &"PV-13"]]),
	&"PV-06": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"PV-05"]]),
	&"PV-07": _room(&"L3", &"scripted_only", &"none", 6, [[&"Nw", &"PV-03"], [&"Ne", &"PV-08"], [&"E1", &"PV-11"], [&"E2", &"PV-14"]]),
	&"PV-08": _room(&"L4", &"boss", &"Tsw", 6, [[&"Nw", &"PV-07"], [&"Ne", &"PV-12"], [&"E1", &"PV-14"]]),
	&"PV-09": _room(&"M1", &"zone", &"Tnw", 4, [[&"Nw", &"PV-05"], [&"Ne", &"PV-13"]]),
	&"PV-10": _room(&"L2", &"zone", &"Tne", 6, [[&"Nw", &"PV-03"]]),
	&"PV-11": _room(&"M3", &"zone", &"Tse", 4, [[&"Nw", &"PV-04"], [&"Ne", &"PV-07"]]),
	&"PV-12": _room(&"L4", &"scripted_only", &"Tsw", 6, [[&"Nw", &"PV-08"]]),
	&"PV-13": _room(&"M1", &"none", &"none", 4, [[&"Nw", &"PV-01"], [&"Ne", &"PV-02"], [&"E1", &"PV-05"], [&"E2", &"PV-09"]]),
	&"PV-14": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"PV-03"], [&"Ne", &"PV-07"], [&"E1", &"PV-08"]]),
}
static var HELIOS_ROOMS := {
	&"HE-01": _room(&"L1", &"zone", &"none", 6, [[&"Nw", &"FI-08"], [&"Ne", &"HE-02"], [&"E1", &"HE-14"]]), &"HE-02": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"HE-01"], [&"Ne", &"HE-03"], [&"E1", &"HE-10"]]), &"HE-03": _room(&"L3", &"zone", &"none", 6, [[&"Nw", &"HE-02"], [&"Ne", &"HE-11"], [&"E1", &"HE-12"], [&"E2", &"HE-13"]]), &"HE-04": _room(&"L4", &"zone", &"none", 6, [[&"Nw", &"HE-13"], [&"Ne", &"HE-05"], [&"E1", &"HE-09"]]), &"HE-05": _room(&"M1", &"zone", &"none", 4, [[&"Nw", &"HE-04"]]), &"HE-06": _room(&"L2", &"scripted_only", &"none", 6, [[&"Nw", &"HE-13"], [&"Ne", &"HE-07"]]), &"HE-07": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"HE-06"], [&"Ne", &"HE-08"], [&"E1", &"HE-10"], [&"E2", &"HE-12"], [&"Se", &"HE-14"]]), &"HE-08": _room(&"L4", &"boss", &"Tsw", 6, [[&"Nw", &"HE-07"]]), &"HE-09": _room(&"L1", &"zone", &"Tnw", 6, [[&"Nw", &"HE-04"], [&"Ne", &"HE-13"]]), &"HE-10": _room(&"M2", &"zone", &"Tne", 4, [[&"Nw", &"HE-02"], [&"Ne", &"HE-07"]]), &"HE-11": _room(&"L3", &"zone", &"Tse", 6, [[&"Nw", &"HE-03"]]), &"HE-12": _room(&"M4", &"zone", &"Tsw", 4, [[&"Nw", &"HE-03"], [&"Ne", &"HE-07"]]), &"HE-13": _room(&"M1", &"none", &"none", 4, [[&"Nw", &"HE-03"], [&"Ne", &"HE-04"], [&"E1", &"HE-06"], [&"E2", &"HE-09"]]), &"HE-14": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"HE-01"], [&"Ne", &"HE-07"]]),
}

# Locked 102-room manifest entries. These records are deliberately not yet
# scene-backed: they establish the validated graph contract without activating
# unreviewed derivatives, collision, or population in the live campaign.
static var FROSTHOLD_ROOMS := {
	&"FR-01": _room(&"L1", &"zone", &"none", 6, [[&"Nw", &"FI-09"], [&"Ne", &"FR-02"], [&"E1", &"FR-13"]]),
	&"FR-02": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"FR-01"], [&"Ne", &"FR-03"], [&"E1", &"FR-09"], [&"E2", &"FR-13"]]),
	&"FR-03": _room(&"L3", &"zone", &"none", 6, [[&"Nw", &"FR-02"], [&"Ne", &"FR-04"], [&"E1", &"FR-09"], [&"E2", &"FR-14"]]),
	&"FR-04": _room(&"L4", &"zone", &"none", 6, [[&"Nw", &"FR-03"], [&"Ne", &"FR-05"], [&"E1", &"FR-10"]]),
	&"FR-05": _room(&"M1", &"scripted_only", &"none", 4, [[&"Nw", &"FR-04"], [&"Ne", &"FR-06"]]),
	&"FR-06": _room(&"L2", &"scripted_only", &"none", 6, [[&"Nw", &"FR-05"], [&"Ne", &"FR-07"], [&"E1", &"FR-11"], [&"E2", &"FR-13"]]),
	&"FR-07": _room(&"M3", &"scripted_only", &"none", 4, [[&"Nw", &"FR-06"], [&"Ne", &"FR-08"], [&"E1", &"FR-12"], [&"E2", &"FR-14"]]),
	&"FR-08": _room(&"L4", &"boss", &"none", 6, [[&"Nw", &"FR-07"], [&"Ne", &"FR-14"]]),
	&"FR-09": _room(&"L1", &"none", &"Tne", 6, [[&"Nw", &"FR-02"], [&"Ne", &"FR-03"]]),
	&"FR-10": _room(&"L2", &"zone", &"Tnw", 6, [[&"Nw", &"FR-04"], [&"Ne", &"FR-11"]]),
	&"FR-11": _room(&"M3", &"scripted_only", &"Tse", 4, [[&"Nw", &"FR-10"], [&"Ne", &"FR-06"]]),
	&"FR-12": _room(&"M2", &"none", &"Tne", 4, [[&"Nw", &"FR-07"]]),
	&"FR-13": _room(&"M1", &"zone", &"none", 4, [[&"Nw", &"FR-01"], [&"Ne", &"FR-02"], [&"E1", &"FR-06"]]),
	&"FR-14": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"FR-03"], [&"Ne", &"FR-07"], [&"E1", &"FR-08"]]),
}

static var MOONPETAL_ROOMS := {
	&"MP-01": _room(&"L1", &"zone", &"none", 6, [[&"Nw", &"FI-10"], [&"Ne", &"MP-02"], [&"E1", &"MP-14"]]),
	&"MP-02": _room(&"L2", &"zone", &"none", 6, [[&"Nw", &"MP-01"], [&"Ne", &"MP-03"], [&"E1", &"MP-09"], [&"E2", &"MP-12"]]),
	&"MP-03": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"MP-02"], [&"Ne", &"MP-04"], [&"E1", &"MP-11"], [&"E2", &"MP-13"]]),
	&"MP-04": _room(&"L4", &"zone", &"none", 6, [[&"Nw", &"MP-03"], [&"Ne", &"MP-05"], [&"E1", &"MP-10"]]),
	&"MP-05": _room(&"M1", &"scripted_only", &"none", 4, [[&"Nw", &"MP-04"], [&"Ne", &"MP-06"]]),
	&"MP-06": _room(&"L2", &"scripted_only", &"none", 6, [[&"Nw", &"MP-05"], [&"Ne", &"MP-07"], [&"E1", &"MP-13"]]),
	&"MP-07": _room(&"M3", &"scripted_only", &"none", 4, [[&"Nw", &"MP-06"], [&"Ne", &"MP-08"], [&"E1", &"MP-14"]]),
	&"MP-08": _room(&"L4", &"boss", &"none", 6, [[&"Nw", &"MP-07"]]),
	&"MP-09": _room(&"M2", &"none", &"Tne", 4, [[&"Nw", &"MP-02"], [&"Ne", &"MP-13"]]),
	&"MP-10": _room(&"L2", &"none", &"Tnw", 6, [[&"Nw", &"MP-04"], [&"Ne", &"MP-13"]]),
	&"MP-11": _room(&"M1", &"none", &"Tse", 4, [[&"Nw", &"MP-03"], [&"Ne", &"MP-12"]]),
	&"MP-12": _room(&"L2", &"none", &"none", 6, [[&"Nw", &"MP-02"], [&"Ne", &"MP-11"]]),
	&"MP-13": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"MP-03"], [&"Ne", &"MP-06"], [&"E1", &"MP-09"], [&"E2", &"MP-10"]]),
	&"MP-14": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"MP-01"], [&"Ne", &"MP-07"]]),
}

static var EMPYREAL_ROOMS := {
	&"EM-01": _room(&"L1", &"zone", &"none", 6, [[&"Nw", &"FI-11"], [&"Ne", &"EM-02"], [&"E1", &"EM-16"]]),
	&"EM-02": _room(&"M2", &"zone", &"none", 4, [[&"Nw", &"EM-01"], [&"Ne", &"EM-03"], [&"E1", &"EM-10"]]),
	&"EM-03": _room(&"L3", &"zone", &"none", 6, [[&"Nw", &"EM-02"], [&"Ne", &"EM-04"], [&"E1", &"EM-10"], [&"E2", &"EM-15"]]),
	&"EM-04": _room(&"L4", &"zone", &"none", 6, [[&"Nw", &"EM-03"], [&"Ne", &"EM-05"], [&"E1", &"EM-11"], [&"E2", &"EM-13"]]),
	&"EM-05": _room(&"M1", &"scripted_only", &"none", 4, [[&"Nw", &"EM-04"], [&"Ne", &"EM-06"]]),
	&"EM-06": _room(&"L2", &"zone", &"none", 6, [[&"Nw", &"EM-05"], [&"Ne", &"EM-07"], [&"E1", &"EM-15"]]),
	&"EM-07": _room(&"L3", &"scripted_only", &"none", 6, [[&"Nw", &"EM-06"], [&"Ne", &"EM-08"], [&"E1", &"EM-12"], [&"E2", &"EM-14"], [&"Se", &"EM-15"]]),
	&"EM-08": _room(&"M2", &"scripted_only", &"none", 4, [[&"Nw", &"EM-07"], [&"Ne", &"EM-09"], [&"E1", &"EM-12"]]),
	&"EM-09": _room(&"L4", &"boss", &"none", 6, [[&"Nw", &"EM-08"], [&"Ne", &"EM-16"]]),
	&"EM-10": _room(&"M1", &"none", &"Tnw", 4, [[&"Nw", &"EM-02"], [&"Ne", &"EM-03"]]),
	&"EM-11": _room(&"M2", &"none", &"Tne", 4, [[&"Nw", &"EM-04"], [&"Ne", &"EM-15"]]),
	&"EM-12": _room(&"L2", &"zone", &"none", 6, [[&"Nw", &"EM-07"], [&"Ne", &"EM-08"]]),
	&"EM-13": _room(&"M1", &"none", &"Tse", 4, [[&"Nw", &"EM-04"]]),
	&"EM-14": _room(&"M2", &"none", &"none", 4, [[&"Nw", &"EM-07"]]),
	&"EM-15": _room(&"M3", &"zone", &"none", 4, [[&"Nw", &"EM-03"], [&"Ne", &"EM-06"], [&"E1", &"EM-07"], [&"E2", &"EM-11"]]),
	&"EM-16": _room(&"S2", &"none", &"none", 2, [[&"Nw", &"EM-01"], [&"Ne", &"EM-09"]]),
}

# This scene is deliberately a small, self-contained proof of the platform. It
# is not campaign content and is never reachable from a legacy region. Its two
# reciprocal ports exercise routing, safe arrival, camera bounds, navigation,
# feature installation, population scheduling, and streamer ownership without
# adding a bootstrap branch.
static var MANIFEST_TEST_ROOMS := {
	&"TEST-01": {
		"blueprint": &"S1",
		"dimensions": Vector2i(14, 10),
		"cameraBounds": FIELD_SCALE.camera_bounds_for_cells(Vector2i(14, 10)),
		"scenePath": "res://ben_rpg/world/rooms/manifest_test_room.tscn",
		"collisionMaskId": &"generated:manifest-test-room",
		"navigationId": &"generated:manifest-test-room",
		"portCells": {&"Nw": Vector2i(4, 1), &"Ne": Vector2i(9, 1)},
		"encounterPolicy": &"none",
		"treasureAnchor": &"none",
		"interactionAnchor": &"Icenter",
		"populationIds": [&"test-room-caretaker"],
		"populationAnchors": [&"P1"],
		"ports": [
			{&"id": &"Nw", &"destination": &"TEST-01", &"arrivalPort": &"Ne"},
			{&"id": &"Ne", &"destination": &"TEST-01", &"arrivalPort": &"Nw"},
		],
	},
}


static func _room(blueprint: StringName, encounter_policy: StringName, treasure_anchor: StringName, population_anchor_count: int, port_pairs: Array) -> Dictionary:
	var layout := blueprint_layout(blueprint)
	var dimensions: Vector2i = layout.get("dimensions", Vector2i.ZERO)
	var ports: Array[Dictionary] = []
	for pair in port_pairs:
		ports.append({"id": StringName(pair[0]), "destination": StringName(pair[1])})
	var population_anchors: Array[StringName] = []
	for anchor_index in range(population_anchor_count):
		population_anchors.append(StringName("P%d" % (anchor_index + 1)))
	var encounter_zones: Array[StringName] = []
	if encounter_policy == &"zone":
		encounter_zones = [&"Zw", &"Ze"]
	elif encounter_policy == &"scripted_only":
		encounter_zones = [&"Za"]
	elif encounter_policy == &"boss":
		encounter_zones = [&"Zboss"]
	return {
		"blueprint": blueprint,
		"dimensions": dimensions,
		"cameraBounds": FIELD_SCALE.camera_bounds_for_cells(dimensions),
		"portCells": layout.get("ports", {}).duplicate(true),
		"collisionMaskId": StringName("generated:%s-collision" % blueprint),
		"navigationId": StringName("generated:%s-navigation" % blueprint),
		"enabledPortIds": [],
		"encounterPolicy": encounter_policy,
		"encounterZones": encounter_zones,
		"treasureAnchor": treasure_anchor,
		"interactionAnchor": &"Icenter",
		"populationAnchorCount": population_anchor_count,
		"populationAnchors": population_anchors,
		"populationAnchorCells": _population_anchor_cells(dimensions, population_anchors),
		"visualProfileIds": _mansion_visual_profiles(blueprint),
		"ports": ports,
	}


static func blueprint_layout(blueprint: StringName) -> Dictionary:
	return (BLUEPRINTS.get(blueprint, {}) as Dictionary).duplicate(true)


static func _mansion_visual_profiles(blueprint: StringName) -> Array[StringName]:
	# These are the approved profiles currently admitted to the runtime. Expanded
	# room-specific profile records replace this compatibility palette as scenes
	# are authored; no raw source-library path is ever stored in a room record.
	if blueprint in [&"L1", &"L2", &"L4"]:
		return [&"mansion_interior_wall_0_0", &"mansion_plank_grain_0_0"]
	return [&"mansion_interior_wall_0_0", &"mansion_plank_grain_0_0"]


static func _population_anchor_cells(dimensions: Vector2i, anchors: Array[StringName]) -> Dictionary:
	var candidates := [
		Vector2i(floori(dimensions.x / 4.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 2.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(3.0 * dimensions.x / 4.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 4.0), floori(2.0 * dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 2.0), floori(2.0 * dimensions.y / 3.0)),
		Vector2i(floori(3.0 * dimensions.x / 4.0), floori(2.0 * dimensions.y / 3.0)),
	]
	var result: Dictionary = {}
	for index in range(anchors.size()):
		result[anchors[index]] = candidates[index]
	return result


static func has_room(room_id: StringName) -> bool:
	return MANSION_ROOMS.has(room_id) or ASTERION_ROOMS.has(room_id) or PRIMEVAL_ROOMS.has(room_id) or HELIOS_ROOMS.has(room_id) or FROSTHOLD_ROOMS.has(room_id) or MOONPETAL_ROOMS.has(room_id) or EMPYREAL_ROOMS.has(room_id) or MANIFEST_TEST_ROOMS.has(room_id)


static func facility_portal(facility_name: StringName) -> Dictionary:
	return (FACILITY_PORTALS.get(facility_name, {}) as Dictionary).duplicate(true)


static func facility_portals() -> Dictionary:
	return FACILITY_PORTALS.duplicate(true)


static func room(room_id: StringName) -> Dictionary:
	var source: Dictionary = MANSION_ROOMS if MANSION_ROOMS.has(room_id) else (ASTERION_ROOMS if ASTERION_ROOMS.has(room_id) else (PRIMEVAL_ROOMS if PRIMEVAL_ROOMS.has(room_id) else (HELIOS_ROOMS if HELIOS_ROOMS.has(room_id) else (FROSTHOLD_ROOMS if FROSTHOLD_ROOMS.has(room_id) else (MOONPETAL_ROOMS if MOONPETAL_ROOMS.has(room_id) else (EMPYREAL_ROOMS if EMPYREAL_ROOMS.has(room_id) else MANIFEST_TEST_ROOMS))))))
	var definition := (source.get(room_id, {}) as Dictionary).duplicate(true)
	if room_id == &"HE-01": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_afterlight_skybridge.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:he01-afterlight-skybridge-navigation","collisionMaskId":&"authored:he01-afterlight-skybridge-collision","navigationLayout":{"id":&"he01-afterlight-skybridge-v1","kind":&"authored","usefulCellRange":Vector2i(247,248),"walkableRects":[{"origin":Vector2i(6,1),"size":Vector2i(12,4)},{"origin":Vector2i(3,4),"size":Vector2i(18,10)},{"origin":Vector2i(20,5),"size":Vector2i(3,4)},{"origin":Vector2i(6,13),"size":Vector2i(12,3)}]}},true)
	elif room_id == &"HE-02": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_curfew_customs.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:he02-curfew-customs-navigation","collisionMaskId":&"authored:he02-curfew-customs-collision","navigationLayout":{"id":&"he02-curfew-customs-v1","kind":&"authored","usefulCellRange":Vector2i(150,150),"walkableRects":[{"origin":Vector2i(5,1),"size":Vector2i(10,4)},{"origin":Vector2i(3,4),"size":Vector2i(15,7)},{"origin":Vector2i(17,3),"size":Vector2i(2,4)},{"origin":Vector2i(5,10),"size":Vector2i(10,2)}]}},true)
	elif room_id == &"HE-03": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_public_market.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:he03-public-market-navigation","collisionMaskId":&"authored:he03-public-market-collision","navigationLayout":{"id":&"he03-public-market-v1","kind":&"authored","usefulCellRange":Vector2i(296,299),"walkableRects":[{"origin":Vector2i(8,1),"size":Vector2i(12,4)},{"origin":Vector2i(3,4),"size":Vector2i(22,10)},{"origin":Vector2i(24,5),"size":Vector2i(3,9)},{"origin":Vector2i(8,13),"size":Vector2i(12,3)}]},"heliosInteractions":[{"nodeName":"HeliosOrdinanceTerminal","kind":&"ordinance_terminal","cell":Vector2i(16,6)}],"universeTreasures":[{"nodeName":"HeliosMarketTreasure","cacheId":&"helios_market_terminal","cell":Vector2i(17,8)}]},true)
	elif room_id == &"HE-04": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_transit_concourse.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:he04-transit-concourse-navigation","collisionMaskId":&"authored:he04-transit-concourse-collision","navigationLayout":{"id":&"he04-transit-concourse-v1","kind":&"authored","usefulCellRange":Vector2i(250,300),"walkableRects":[{"origin":Vector2i(7,1),"size":Vector2i(11,4)},{"origin":Vector2i(3,4),"size":Vector2i(18,11)},{"origin":Vector2i(20,5),"size":Vector2i(3,4)},{"origin":Vector2i(7,14),"size":Vector2i(11,4)}]}},true)
	elif room_id == &"HE-05": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_transit_phase_substation.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw"],"navigationId":&"authored:he05-phase-substation-navigation","collisionMaskId":&"authored:he05-phase-substation-collision","navigationLayout":{"id":&"he05-phase-substation-v1","kind":&"authored","usefulCellRange":Vector2i(119,120),"walkableRects":[{"origin":Vector2i(5,1),"size":Vector2i(9,4)},{"origin":Vector2i(3,4),"size":Vector2i(12,7)},{"origin":Vector2i(5,10),"size":Vector2i(9,2)}]},"heliosInteractions":[{"nodeName":"HeliosTransitNode","kind":&"transit_node","cell":Vector2i(9,7)}]},true)
	elif room_id == &"HE-13": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_grid_junction.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:he13-grid-junction-navigation","collisionMaskId":&"authored:he13-grid-junction-collision","navigationLayout":{"id":&"he13-grid-junction-v1","kind":&"authored","usefulCellRange":Vector2i(143,145),"walkableRects":[{"origin":Vector2i(5,1),"size":Vector2i(9,4)},{"origin":Vector2i(3,4),"size":Vector2i(12,7)},{"origin":Vector2i(15,3),"size":Vector2i(2,8)},{"origin":Vector2i(5,10),"size":Vector2i(9,3)}]},"featureIds":[&"phase_inverter_route",&"night_grid_switch"]},true)
	elif room_id == &"HE-06": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_clinic.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:he06-recovery-clinic-navigation","collisionMaskId":&"authored:he06-recovery-clinic-collision","navigationLayout":{"id":&"he06-recovery-clinic-v1","kind":&"authored","usefulCellRange":Vector2i(247,248),"walkableRects":[{"origin":Vector2i(6,1),"size":Vector2i(12,4)},{"origin":Vector2i(3,4),"size":Vector2i(18,10)},{"origin":Vector2i(20,5),"size":Vector2i(3,4)},{"origin":Vector2i(6,13),"size":Vector2i(12,3)}]},"heliosInteractions":[{"nodeName":"HeliosSaveBeacon","kind":&"save_beacon","savePointId":&"helios_clinic","cell":Vector2i(8,10)},{"nodeName":"HeliosClinicNode","kind":&"clinic_node","cell":Vector2i(12,10)}]},true)
	elif room_id == &"HE-07": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_transit_exchange.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2",&"Se"],"navigationId":&"authored:he07-civic-core-approach-navigation","collisionMaskId":&"authored:he07-civic-core-approach-collision","navigationLayout":{"id":&"he07-civic-core-approach-v1","kind":&"authored","usefulCellRange":Vector2i(179,183),"walkableRects":[{"origin":Vector2i(6,1),"size":Vector2i(11,4)},{"origin":Vector2i(3,4),"size":Vector2i(17,7)},{"origin":Vector2i(19,3),"size":Vector2i(2,8)},{"origin":Vector2i(6,10),"size":Vector2i(11,3)}]},"featureIds":[&"transit_daylight_node",&"core_route"]},true)
	elif room_id == &"HE-08": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_solar_core.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw"],"navigationId":&"authored:he08-solar-core-navigation","collisionMaskId":&"authored:he08-solar-core-collision","navigationLayout":{"id":&"he08-solar-core-v1","kind":&"authored","usefulCellRange":Vector2i(262,265),"walkableRects":[{"origin":Vector2i(7,1),"size":Vector2i(11,4)},{"origin":Vector2i(3,4),"size":Vector2i(18,11)},{"origin":Vector2i(7,14),"size":Vector2i(11,4)}]},"featureIds":[&"civic_sun_boss",&"midnight_restore"]},true)
	elif room_id == &"HE-09": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_service_undercity.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:he09-service-undercity-navigation","collisionMaskId":&"authored:he09-service-undercity-collision","navigationLayout":{"id":&"he09-service-undercity-v1","kind":&"authored","usefulCellRange":Vector2i(258,258),"walkableRects":[{"origin":Vector2i(7,1),"size":Vector2i(12,4)},{"origin":Vector2i(3,4),"size":Vector2i(20,10)},{"origin":Vector2i(7,13),"size":Vector2i(12,3)}]}},true)
	elif room_id == &"HE-10": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_rooftop_night_garden.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:he10-rooftop-night-garden-navigation","collisionMaskId":&"authored:he10-rooftop-night-garden-collision","navigationLayout":{"id":&"he10-rooftop-night-garden-v1","kind":&"authored","usefulCellRange":Vector2i(147,147),"walkableRects":[{"origin":Vector2i(5,1),"size":Vector2i(9,4)},{"origin":Vector2i(3,4),"size":Vector2i(13,8)},{"origin":Vector2i(5,11),"size":Vector2i(9,3)}]}},true)
	elif room_id == &"HE-11": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_recreation_stack.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw"],"navigationId":&"authored:he11-recreation-stack-navigation","collisionMaskId":&"authored:he11-recreation-stack-collision","navigationLayout":{"id":&"he11-recreation-stack-v1","kind":&"authored","usefulCellRange":Vector2i(295,295),"walkableRects":[{"origin":Vector2i(8,1),"size":Vector2i(12,4)},{"origin":Vector2i(3,4),"size":Vector2i(22,10)},{"origin":Vector2i(24,5),"size":Vector2i(3,9)},{"origin":Vector2i(8,13),"size":Vector2i(12,3)}]}},true)
	elif room_id == &"HE-12": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_hologram_archive.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:he12-hologram-archive-navigation","collisionMaskId":&"authored:he12-hologram-archive-collision","navigationLayout":{"id":&"he12-hologram-archive-v1","kind":&"authored","usefulCellRange":Vector2i(148,149),"walkableRects":[{"origin":Vector2i(5,1),"size":Vector2i(9,4)},{"origin":Vector2i(3,4),"size":Vector2i(13,8)},{"origin":Vector2i(5,11),"size":Vector2i(9,3)}]}},true)
	elif room_id == &"HE-14": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_midnight_maintenance_lift.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:he14-midnight-maintenance-lift-navigation","collisionMaskId":&"authored:he14-midnight-maintenance-lift-collision","navigationLayout":{"id":&"he14-midnight-maintenance-lift-v1","kind":&"authored","usefulCellRange":Vector2i(71,72),"walkableRects":[{"origin":Vector2i(4,1),"size":Vector2i(8,3)},{"origin":Vector2i(2,3),"size":Vector2i(12,4)},{"origin":Vector2i(4,6),"size":Vector2i(8,2)}]}},true)
	elif room_id == &"FR-01": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_whitewind_snow_gate.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:fr01-whitewind-snow-gate-navigation","collisionMaskId":&"authored:fr01-whitewind-snow-gate-collision","navigationLayout":{"id":&"fr01-whitewind-snow-gate-v1","kind":&"authored","usefulCellRange":Vector2i(347,347),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(22,16)}]}},true)
	elif room_id == &"FR-02": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_refugee_thawyard.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:fr02-refugee-thawyard-navigation","collisionMaskId":&"authored:fr02-refugee-thawyard-collision","navigationLayout":{"id":&"fr02-refugee-thawyard-v1","kind":&"authored","usefulCellRange":Vector2i(212,212),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(18,12)}]}},true)
	elif room_id == &"FR-03": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_frozen_market.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:fr03-frozen-market-navigation","collisionMaskId":&"authored:fr03-frozen-market-collision","navigationLayout":{"id":&"fr03-frozen-market-v1","kind":&"authored","usefulCellRange":Vector2i(412,412),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(26,16)}]},"frostholdInteractions":[{"nodeName":"FrostholdHeatTaxRune","kind":&"heat_tax_rune","cell":Vector2i(16,6)}],"universeTreasures":[{"nodeName":"FrostholdMarketTreasure","cacheId":&"frosthold_heat_cache","cell":Vector2i(14,8)}]},true)
	elif room_id == &"FR-04": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_crystal_causeway_west.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:fr04-crystal-causeway-west-navigation","collisionMaskId":&"authored:fr04-crystal-causeway-west-collision","navigationLayout":{"id":&"fr04-crystal-causeway-west-v1","kind":&"authored","usefulCellRange":Vector2i(391,391),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(22,18)}]}},true)
	elif room_id == &"FR-05": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_first_thermal_lien.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:fr05-first-thermal-lien-navigation","collisionMaskId":&"authored:fr05-first-thermal-lien-collision","navigationLayout":{"id":&"fr05-first-thermal-lien-v1","kind":&"authored","usefulCellRange":Vector2i(186,186),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(16,12)}]},"frostholdInteractions":[{"nodeName":"FrostholdCausewaySeal","kind":&"causeway_seal","cell":Vector2i(9,8)}]},true)
	elif room_id == &"FR-06": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_lien_device_hall.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:fr06-lien-device-hall-navigation","collisionMaskId":&"authored:fr06-lien-device-hall-collision","navigationLayout":{"id":&"fr06-lien-device-hall-v1","kind":&"authored","usefulCellRange":Vector2i(380,380),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(24,16)}]},"frostholdInteractions":[{"nodeName":"FrostholdSaveBrazier","kind":&"save_brazier","savePointId":&"frosthold_rune_hall","cell":Vector2i(12,11)}]},true)
	elif room_id == &"FR-07": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_rune_throne_approach.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"navigationId":&"authored:fr07-rune-throne-approach-navigation","collisionMaskId":&"authored:fr07-rune-throne-approach-collision","navigationLayout":{"id":&"fr07-rune-throne-approach-v1","kind":&"authored","usefulCellRange":Vector2i(236,236),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(20,12)}]},"frostholdInteractions":[{"nodeName":"FrostholdThroneSeal","kind":&"throne_seal","cell":Vector2i(10,8)}]},true)
	elif room_id == &"FR-08": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_white_court_chamber.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:fr08-white-court-chamber-navigation","collisionMaskId":&"authored:fr08-white-court-chamber-collision","navigationLayout":{"id":&"fr08-white-court-chamber-v1","kind":&"authored","usefulCellRange":Vector2i(390,390),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(22,18)}]},"featureIds":[&"frosthold_white_court_boss"]},true)
	elif room_id == &"FR-09": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_lower_village_hearthline.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:fr09-lower-village-hearthline-navigation","collisionMaskId":&"authored:fr09-lower-village-hearthline-collision","navigationLayout":{"id":&"fr09-lower-village-hearthline-v1","kind":&"authored","usefulCellRange":Vector2i(346,346),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(22,16)}]},"featureIds":[&"hearthline_relief"]},true)
	elif room_id == &"FR-10": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_crystalice_forest.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:fr10-crystalice-forest-navigation","collisionMaskId":&"authored:fr10-crystalice-forest-collision","navigationLayout":{"id":&"fr10-crystalice-forest-v1","kind":&"authored","usefulCellRange":Vector2i(378,378),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(24,16)}]},"featureIds":[&"whiteout_safe_trail"]},true)
	elif room_id == &"FR-11": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_blueglass_ice_cavern.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne"],"navigationId":&"authored:fr11-blueglass-ice-cavern-navigation","collisionMaskId":&"authored:fr11-blueglass-ice-cavern-collision","navigationLayout":{"id":&"fr11-blueglass-ice-cavern-v1","kind":&"authored","usefulCellRange":Vector2i(234,234),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(20,12)}]},"featureIds":[&"reflection_latch"]},true)
	elif room_id == &"FR-12": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_treasury_collected_warmth.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw"],"navigationId":&"authored:fr12-treasury-collected-warmth-navigation","collisionMaskId":&"authored:fr12-treasury-collected-warmth-collision","navigationLayout":{"id":&"fr12-treasury-collected-warmth-v1","kind":&"authored","usefulCellRange":Vector2i(209,209),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(18,12)}]},"featureIds":[&"three_audit_seals"]},true)
	elif room_id == &"FR-13": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_furnace_aqueduct.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:fr13-furnace-aqueduct-navigation","collisionMaskId":&"authored:fr13-furnace-aqueduct-collision","navigationLayout":{"id":&"fr13-furnace-aqueduct-v1","kind":&"authored","usefulCellRange":Vector2i(187,187),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(16,12)}]},"featureIds":[&"furnace_shortcut"]},true)
	elif room_id == &"FR-14": definition.merge({"scenePath":"res://ben_rpg/world/rooms/frosthold_meltwater_sluice.tscn","worldOrigin":Vector2i(500,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"navigationId":&"authored:fr14-meltwater-sluice-navigation","collisionMaskId":&"authored:fr14-meltwater-sluice-collision","navigationLayout":{"id":&"fr14-meltwater-sluice-v1","kind":&"authored","usefulCellRange":Vector2i(107,107),"walkableRects":[{"origin":Vector2i(1,1),"size":Vector2i(14,8)}]},"featureIds":[&"accessible_return_walkway"]},true)
	elif room_id == &"MP-01": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_vermilion_gate_terrace.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"]},true)
	elif room_id == &"MP-02": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_blossom_court.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"moonpetalInteractions":[{"nodeName":"MoonpetalVowTablet","kind":&"vow_tablet","cell":Vector2i(16,6)}]},true)
	elif room_id == &"MP-03": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_lantern_arcade.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"]},true)
	elif room_id == &"MP-04": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_mirror_garden_outer_walk.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"universeTreasures":[{"nodeName":"MoonpetalGardenTreasure","cacheId":&"moonpetal_offering","cell":Vector2i(12,8)}]},true)
	elif room_id == &"MP-05": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_counterfeit_vow_pavilion.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"garden_seal"],"moonpetalInteractions":[{"nodeName":"MoonpetalGardenSeal","kind":&"garden_seal","cell":Vector2i(9,8)}]},true)
	elif room_id == &"MP-06": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_bell_walk.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"featureIds":[&"fox_procession_ambush"],"moonpetalInteractions":[{"nodeName":"MoonpetalSaveLantern","kind":&"save_lantern","savePointId":&"moonpetal_bell_walk","cell":Vector2i(8,11)}]},true)
	elif room_id == &"MP-07": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_moon_palace_approach.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E2"],"featureIds":[&"palace_seal"],"moonpetalInteractions":[{"nodeName":"MoonpetalPalaceSeal","kind":&"palace_seal","cell":Vector2i(10,8)}]},true)
	elif room_id == &"MP-08": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_hall_true_moon.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw"],"featureIds":[&"magistrate_enma_boss"]},true)
	elif room_id == &"MP-09": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_tea_garden_unsaid_things.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"tea_testimony"]},true)
	elif room_id == &"MP-10": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_koi_reflection_maze.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"koi_observation_path"]},true)
	elif room_id == &"MP-11": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_shrine_archive_first_drafts.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"archive_screen"]},true)
	elif room_id == &"MP-12": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_yokai_artisan_lane.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"artisan_exchange"]},true)
	elif room_id == &"MP-13": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_covered_bell_passage.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"featureIds":[&"roof_occlusion"]},true)
	elif room_id == &"MP-14": definition.merge({"scenePath":"res://ben_rpg/world/rooms/moonpetal_servants_moonbridge.tscn","worldOrigin":Vector2i(550,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"singular_reflection_bridge"]},true)
	elif room_id == &"EM-01": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_cloudstep_landing.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"]},true)
	elif room_id == &"EM-02": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_petitioners_rise.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"]},true)
	elif room_id == &"EM-03": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_garden_appeals.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"empyrealInteractions":[{"nodeName":"EmpyrealGravityOrdinance","kind":&"gravity_ordinance","cell":Vector2i(16,6)}],"universeTreasures":[{"nodeName":"EmpyrealGardenTreasure","cacheId":&"empyreal_tithe_basin","cell":Vector2i(14,8)}]},true)
	elif room_id == &"EM-04": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_forum_measures.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"]},true)
	elif room_id == &"EM-05": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_counterweight_lift_station.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"aerie_seal"],"empyrealInteractions":[{"nodeName":"EmpyrealAerieSeal","kind":&"aerie_seal","cell":Vector2i(9,8)}]},true)
	elif room_id == &"EM-06": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_reliquary_causeway.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"featureIds":[&"gravity_thresholds"]},true)
	elif room_id == &"EM-07": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_reliquary_aerie.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2",&"Se"],"featureIds":[&"repossession_ambush"],"empyrealInteractions":[{"nodeName":"EmpyrealSaveFountain","kind":&"save_fountain","savePointId":&"empyreal_aerie","cell":Vector2i(11,11)}]},true)
	elif room_id == &"EM-08": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_tribunal_descent.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"],"featureIds":[&"tribunal_seal"],"empyrealInteractions":[{"nodeName":"EmpyrealTribunalSeal","kind":&"tribunal_seal","cell":Vector2i(9,8)}]},true)
	elif room_id == &"EM-09": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_seraph_tribunal.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"high_comptroller_boss"]},true)
	elif room_id == &"EM-10": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_weather_clerks_terrace.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"weather_vanes"]},true)
	elif room_id == &"EM-11": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_archive_lost_appeals.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"archive_balance"]},true)
	elif room_id == &"EM-12": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_wing_repossession_yard.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"yard_latch"]},true)
	elif room_id == &"EM-13": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_ambassadors_aerie.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw"],"featureIds":[&"formation_reward"]},true)
	elif room_id == &"EM-14": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_cloudbreak_reliquary_vault.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw"],"featureIds":[&"three_reliquary_sigils"]},true)
	elif room_id == &"EM-15": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_gravity_inversion_cloister.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"featureIds":[&"safe_gravity_route"]},true)
	elif room_id == &"EM-16": definition.merge({"scenePath":"res://ben_rpg/world/rooms/empyreal_public_cloud_ferry.tscn","worldOrigin":Vector2i(600,0),"enabledPortIds":[&"Nw",&"Ne"],"featureIds":[&"postgame_cloud_ferry"]},true)
	elif room_id == &"PV-01":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_thunderfern_grove.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"E1": &"primeval_terminal_decoded"}, "navigationId": &"authored:pv01-thunderfern-grove-navigation", "collisionMaskId": &"authored:pv01-thunderfern-grove-collision", "navigationLayout": {"id": &"pv01-thunderfern-grove-v1", "kind": &"authored", "usefulCellRange": Vector2i(247, 248), "walkableRects": [{"origin": Vector2i(6, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(18, 10)}, {"origin": Vector2i(20, 5), "size": Vector2i(3, 4)}, {"origin": Vector2i(6, 13), "size": Vector2i(12, 3)}]}, "featureIds": [&"grove_intro_battle", &"looping_clearings", &"canopy_occlusion", &"tyrant_tracks"]}, true)
	elif room_id == &"PV-02":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_stone_signal_crossing.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "navigationId": &"authored:pv02-stone-signal-crossing-navigation", "collisionMaskId": &"authored:pv02-stone-signal-crossing-collision", "navigationLayout": {"id": &"pv02-stone-signal-crossing-v1", "kind": &"authored", "usefulCellRange": Vector2i(150, 150), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(10, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(15, 7)}, {"origin": Vector2i(17, 3), "size": Vector2i(2, 4)}, {"origin": Vector2i(5, 10), "size": Vector2i(10, 2)}]}, "featureIds": [&"traffic_totem", &"meteor_warning", &"pulsing_signal_stones"], "primevalInteractions": [{"nodeName": "PrimevalTrafficTotem", "kind": &"traffic_totem", "cell": Vector2i(10, 6)}]}, true)
	elif room_id == &"PV-03":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_borough.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2", &"Se"], "portGates": {&"E1": &"primeval_terminal_decoded", &"Se": &"primeval_caldera_open"}, "navigationId": &"authored:pv03-borough-navigation", "collisionMaskId": &"authored:pv03-borough-collision", "navigationLayout": {"id": &"pv03-borough-v1", "kind": &"authored", "usefulCellRange": Vector2i(296, 299), "walkableRects": [{"origin": Vector2i(8, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(22, 10)}, {"origin": Vector2i(24, 5), "size": Vector2i(3, 9)}, {"origin": Vector2i(8, 13), "size": Vector2i(12, 3)}]}, "featureIds": [&"caveman_meeting", &"population_hub", &"locked_relay_trail", &"green_traffic_state"]}, true)
	elif room_id == &"PV-04":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_canopy_causeway.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "navigationId": &"authored:pv04-canopy-causeway-navigation", "collisionMaskId": &"authored:pv04-canopy-causeway-collision", "navigationLayout": {"id": &"pv04-canopy-causeway-v1", "kind": &"authored", "usefulCellRange": Vector2i(150, 150), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(13, 8)}, {"origin": Vector2i(5, 11), "size": Vector2i(9, 3)}]}, "featureIds": [&"elevated_branches", &"foreground_leaves", &"territorial_dinosaur", &"ruins_rope_bridge"]}, true)
	elif room_id == &"PV-05":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_jungle_ruins_court.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"E2": &"primeval_terminal_decoded"}, "navigationId": &"authored:pv05-jungle-ruins-court-navigation", "collisionMaskId": &"authored:pv05-jungle-ruins-court-collision", "navigationLayout": {"id": &"pv05-jungle-ruins-court-v1", "kind": &"authored", "usefulCellRange": Vector2i(257, 258), "walkableRects": [{"origin": Vector2i(6, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(18, 10)}, {"origin": Vector2i(20, 5), "size": Vector2i(3, 9)}, {"origin": Vector2i(6, 13), "size": Vector2i(12, 3)}]}, "featureIds": [&"signal_glyph_hub", &"ruin_formation", &"specialist_supply_hollow", &"ruin_return_gate"], "universeTreasures": [{"nodeName": "PrimevalRuinsTreasure", "cacheId": &"primeval_ruins_plinth", "cell": Vector2i(13, 8)}]}, true)
	elif room_id == &"PV-06":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_cave_computer_vault.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "navigationId": &"authored:pv06-cave-computer-vault-navigation", "collisionMaskId": &"authored:pv06-cave-computer-vault-collision", "navigationLayout": {"id": &"pv06-cave-computer-vault-v1", "kind": &"authored", "usefulCellRange": Vector2i(144, 145), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(10, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(15, 7)}, {"origin": Vector2i(5, 10), "size": Vector2i(10, 2)}]}, "featureIds": [&"translator_requirement", &"cave_os", &"remote_relay_unlock", &"isolated_ancient_tech"], "primevalInteractions": [{"nodeName": "PrimevalCaveTerminal", "kind": &"cave_terminal", "cell": Vector2i(10, 7)}]}, true)
	elif room_id == &"PV-07":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_relay_nest.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"Nw": &"primeval_terminal_decoded", &"Ne": &"primeval_caldera_open"}, "navigationId": &"authored:pv07-relay-nest-navigation", "collisionMaskId": &"authored:pv07-relay-nest-collision", "navigationLayout": {"id": &"pv07-relay-nest-v1", "kind": &"authored", "usefulCellRange": Vector2i(296, 298), "walkableRects": [{"origin": Vector2i(8, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(22, 10)}, {"origin": Vector2i(24, 5), "size": Vector2i(3, 9)}, {"origin": Vector2i(8, 13), "size": Vector2i(12, 3)}]}, "featureIds": [&"dinosaur_attendant_ambush", &"egg_relay", &"all_green_borough_state"], "primevalInteractions": [{"nodeName": "PrimevalAnchorTotem", "kind": &"anchor_totem", "savePointId": &"primeval_nest", "cell": Vector2i(8, 10)}, {"nodeName": "PrimevalRelayNest", "kind": &"relay_nest", "cell": Vector2i(15, 8)}]}, true)
	elif room_id == &"PV-08":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_caldera_crown.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"Nw": &"primeval_caldera_open", &"Ne": &"primeval_scenario_complete", &"E1": &"primeval_caldera_open"}, "navigationId": &"authored:pv08-caldera-crown-navigation", "collisionMaskId": &"authored:pv08-caldera-crown-collision", "navigationLayout": {"id": &"pv08-caldera-crown-v1", "kind": &"authored", "usefulCellRange": Vector2i(262, 265), "walkableRects": [{"origin": Vector2i(7, 1), "size": Vector2i(11, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(18, 11)}, {"origin": Vector2i(7, 14), "size": Vector2i(11, 4)}]}, "featureIds": [&"caldera_vista", &"cooled_post_victory_route", &"mammoth_club_reward"], "bossEncounter": {"nodeName": "CommuteTyrant", "encounterId": &"primeval_commute_tyrant", "defeatedFlag": &"primeval_scenario_complete", "cell": Vector2i(12, 10)}}, true)
	elif room_id == &"PV-14":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_lava_tube_bypass.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"Ne": &"primeval_terminal_decoded", &"E1": &"primeval_caldera_open"}, "navigationId": &"authored:pv14-lava-tube-bypass-navigation", "collisionMaskId": &"authored:pv14-lava-tube-bypass-collision", "navigationLayout": {"id": &"pv14-lava-tube-bypass-v1", "kind": &"authored", "usefulCellRange": Vector2i(71, 72), "walkableRects": [{"origin": Vector2i(4, 1), "size": Vector2i(8, 3)}, {"origin": Vector2i(2, 3), "size": Vector2i(12, 4)}, {"origin": Vector2i(4, 6), "size": Vector2i(8, 2)}]}, "featureIds": [&"fossilized_service_tunnel", &"green_traffic_doors", &"stabilized_shortcut"]}, true)
	elif room_id == &"PV-09":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_luminous_fungal_hollow.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne"], "navigationId": &"authored:pv09-luminous-fungal-hollow-navigation", "collisionMaskId": &"authored:pv09-luminous-fungal-hollow-collision", "navigationLayout": {"id": &"pv09-luminous-fungal-hollow-v1", "kind": &"authored", "usefulCellRange": Vector2i(120, 120), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(12, 7)}, {"origin": Vector2i(5, 10), "size": Vector2i(9, 2)}]}, "featureIds": [&"light_spore_path", &"restorative_fungus_cache", &"optional_fungal_formation"]}, true)
	elif room_id == &"PV-10":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_fossil_survey_quarry.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "navigationId": &"authored:pv10-fossil-survey-quarry-navigation", "collisionMaskId": &"authored:pv10-fossil-survey-quarry-collision", "navigationLayout": {"id": &"pv10-fossil-survey-quarry-v1", "kind": &"authored", "usefulCellRange": Vector2i(259, 260), "walkableRects": [{"origin": Vector2i(7, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(20, 10)}, {"origin": Vector2i(7, 13), "size": Vector2i(12, 3)}]}, "featureIds": [&"three_fossil_eras", &"equipment_material_reward", &"mossback_trial"]}, true)
	elif room_id == &"PV-11":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_raptor_nursery.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne"], "portGates": {&"Ne": &"primeval_caldera_open"}, "navigationId": &"authored:pv11-raptor-nursery-navigation", "collisionMaskId": &"authored:pv11-raptor-nursery-collision", "navigationLayout": {"id": &"pv11-raptor-nursery-v1", "kind": &"authored", "usefulCellRange": Vector2i(162, 164), "walkableRects": [{"origin": Vector2i(6, 1), "size": Vector2i(11, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(17, 7)}, {"origin": Vector2i(5, 10), "size": Vector2i(12, 2)}]}, "featureIds": [&"egg_protection", &"nest_latch", &"calm_post_reset"]}, true)
	elif room_id == &"PV-12":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_storm_dragon_roost.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "portGates": {&"Nw": &"primeval_scenario_complete"}, "navigationId": &"authored:pv12-storm-dragon-roost-navigation", "collisionMaskId": &"authored:pv12-storm-dragon-roost-collision", "navigationLayout": {"id": &"pv12-storm-dragon-roost-v1", "kind": &"authored", "usefulCellRange": Vector2i(262, 265), "walkableRects": [{"origin": Vector2i(7, 1), "size": Vector2i(11, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(18, 11)}, {"origin": Vector2i(7, 14), "size": Vector2i(11, 4)}]}, "featureIds": [&"wind_rock_traversal", &"elite_dragon", &"lightning_charm"]}, true)
	elif room_id == &"PV-13":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_river_switchbacks.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"Nw": &"primeval_terminal_decoded", &"E1": &"primeval_terminal_decoded"}, "navigationId": &"authored:pv13-river-switchbacks-navigation", "collisionMaskId": &"authored:pv13-river-switchbacks-collision", "navigationLayout": {"id": &"pv13-river-switchbacks-v1", "kind": &"authored", "usefulCellRange": Vector2i(141, 141), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(12, 7)}, {"origin": Vector2i(15, 3), "size": Vector2i(2, 8)}, {"origin": Vector2i(5, 10), "size": Vector2i(9, 3)}]}, "featureIds": [&"stepping_stones", &"vine_return_cut", &"encounter_light_return"]}, true)
	elif room_id == &"AS-01":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_docking_collar.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"asterion_station_restored"},
			"navigationId": &"authored:as01-docking-collar-navigation", "collisionMaskId": &"authored:as01-docking-collar-collision",
			"navigationLayout": {
				"id": &"as01-docking-collar-v1", "kind": &"authored", "usefulCellRange": Vector2i(247, 248),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(12, 4)}, # pressure-door arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(18, 10)}, # cargo-loader cover and dock floor
					{"origin": Vector2i(20, 5), "size": Vector2i(3, 4)}, # restored tram-side apron
					{"origin": Vector2i(6, 13), "size": Vector2i(12, 3)}, # safe return pad
				],
			},
			"visualProfileIds": [&"asterion_dock_hull", &"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"dock_intro_battle", &"astronaut_meeting", &"pressure_door_staging", &"cargo_loader_cover", &"safe_return_pad"],
		}, true)
	elif room_id == &"AS-02":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_customs_cargo_intake.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"navigationId": &"authored:as02-customs-intake-navigation", "collisionMaskId": &"authored:as02-customs-intake-collision",
			"navigationLayout": {
				"id": &"as02-customs-intake-v1", "kind": &"authored", "usefulCellRange": Vector2i(150, 150),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(10, 4)}, # customs entry rails
					{"origin": Vector2i(3, 4), "size": Vector2i(15, 7)}, # inspection-booth and cargo-belt lanes
					{"origin": Vector2i(17, 3), "size": Vector2i(2, 4)}, # bonded-vault door apron
					{"origin": Vector2i(5, 10), "size": Vector2i(10, 2)}, # shift-record return lane
				],
			},
			"visualProfileIds": [&"asterion_station_architecture", &"asterion_dock_bulkhead"],
			"featureIds": [&"freight_lanes", &"inspection_booths", &"shift_records", &"locked_customs_vault", &"cargo_belt_loop"],
		}, true)
	elif room_id == &"AS-03":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_mess_deck.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"navigationId": &"authored:as03-mess-deck-navigation", "collisionMaskId": &"authored:as03-mess-deck-collision",
			"navigationLayout": {
				"id": &"as03-mess-deck-v1", "kind": &"authored", "usefulCellRange": Vector2i(169, 169),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(11, 4)}, # mess-door arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(17, 7)}, # tables, ration line, and emergency-light floor
					{"origin": Vector2i(19, 3), "size": Vector2i(2, 4)}, # pressure-lock junction apron
					{"origin": Vector2i(5, 10), "size": Vector2i(12, 2)}, # resident return aisle
				],
			},
			"visualProfileIds": [&"asterion_mess_banner", &"asterion_station_architecture"],
			"featureIds": [&"emergency_lighting", &"medical_hydro_logs", &"post_oxygen_residents"],
		}, true)
	elif room_id == &"AS-13":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_pressure_lock_junction.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2", &"Se"],
			"portGates": {&"E2": &"asterion_station_restored"},
			"navigationId": &"authored:as13-pressure-lock-junction-navigation", "collisionMaskId": &"authored:as13-pressure-lock-junction-collision",
			"navigationLayout": {"id": &"as13-pressure-lock-junction-v1", "kind": &"authored", "usefulCellRange": Vector2i(143, 145), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(12, 7)}, {"origin": Vector2i(15, 3), "size": Vector2i(2, 8)}, {"origin": Vector2i(5, 10), "size": Vector2i(9, 3)}]},
			"visualProfileIds": [&"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"colored_pipe_symbols", &"medical_hydro_split", &"doorway_exclusion_patrol"],
		}, true)
	elif room_id == &"AS-04":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_medical_triage.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_medical_ambush_cleared"},
			"navigationId": &"authored:as04-medical-triage-navigation", "collisionMaskId": &"authored:as04-medical-triage-collision",
			"navigationLayout": {
				"id": &"as04-medical-triage-v1", "kind": &"authored", "usefulCellRange": Vector2i(148, 149),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, # triage-door arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(13, 8)}, # scanner, biocircuit, and ambush floor
					{"origin": Vector2i(5, 11), "size": Vector2i(9, 3)}, # save-beacon recovery bay
				],
			},
			"visualProfileIds": [&"asterion_medical_station", &"asterion_medical_cabinet"],
			"featureIds": [&"medical_robot_ambush", &"biocircuit_drawer", &"patrol_safe_interactions"],
			"bossEncounter": {"nodeName": "MedicalRobotAmbush", "encounterId": &"asterion_medical_ambush", "defeatedFlag": &"asterion_medical_ambush_cleared", "cell": Vector2i(12, 8)},
			"asterionInteractions": [
				{"nodeName": "AsterionBiocircuit", "kind": &"medical_biocircuit", "cell": Vector2i(9, 6)},
				{"nodeName": "AsterionSaveBeacon", "kind": &"save_beacon", "savePointId": &"asterion_medical", "cell": Vector2i(7, 10)},
			],
		}, true)
	elif room_id == &"AS-05":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_hydroponics_outer_walk.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"navigationId": &"authored:as05-hydroponics-outer-walk-navigation", "collisionMaskId": &"authored:as05-hydroponics-outer-walk-collision",
			"navigationLayout": {
				"id": &"as05-hydroponics-outer-walk-v1", "kind": &"authored", "usefulCellRange": Vector2i(128, 128),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, # greenhouse door arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(12, 7)}, # two canopy lanes and drone floor
					{"origin": Vector2i(15, 3), "size": Vector2i(2, 4)}, # observation-ring threshold
					{"origin": Vector2i(5, 10), "size": Vector2i(9, 2)}, # oxygen-line return walk
				],
			},
			"visualProfileIds": [&"asterion_hydroponics_bed", &"asterion_hydro_control_bank"],
			"featureIds": [&"greenhouse_patrol", &"two_canopy_lanes", &"sealed_greenhouse", &"oxygen_line_terminus"],
			"bossEncounter": {"nodeName": "HydroponicsSecurityDrones", "encounterId": &"asterion_hydro_ambush", "defeatedFlag": &"asterion_hydro_ambush_cleared", "cell": Vector2i(10, 7)},
		}, true)
	elif room_id == &"AS-06":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_oxygen_biocircuit_core.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_restored"},
			"navigationId": &"authored:as06-oxygen-biocircuit-navigation", "collisionMaskId": &"authored:as06-oxygen-biocircuit-collision",
			"navigationLayout": {
				"id": &"as06-oxygen-biocircuit-v1", "kind": &"authored", "usefulCellRange": Vector2i(259, 260),
				"walkableRects": [
					{"origin": Vector2i(7, 1), "size": Vector2i(12, 4)}, # upper airlock arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(20, 10)}, # oxygen core and blue-state console floor
					{"origin": Vector2i(7, 13), "size": Vector2i(12, 3)}, # restored-core return apron
				],
			},
			"visualProfileIds": [&"asterion_hydro_control_bank", &"asterion_station_architecture"],
			"featureIds": [&"biocircuit_install", &"oxygen_restore", &"blue_state_switch", &"dock_tram_unlock"],
			"asterionInteractions": [{"nodeName": "AsterionHydroConsole", "kind": &"hydroponics_console", "cell": Vector2i(13, 8)}],
		}, true)
	elif room_id == &"AS-07":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_command_spine.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2", &"Se"],
			"portGates": {&"E1": &"asterion_station_restored", &"E2": &"asterion_station_restored", &"Se": &"asterion_station_restored"},
			"navigationId": &"authored:as07-command-spine-navigation", "collisionMaskId": &"authored:as07-command-spine-collision",
			"navigationLayout": {
				"id": &"as07-command-spine-v1", "kind": &"authored", "usefulCellRange": Vector2i(179, 183),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(11, 4)}, # security-checkpoint arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(17, 7)}, # command consoles and cover routes
					{"origin": Vector2i(19, 3), "size": Vector2i(2, 8)}, # restored pressure-lock side spine
					{"origin": Vector2i(6, 10), "size": Vector2i(11, 3)}, # tram and control return lane
				],
			},
			"visualProfileIds": [&"asterion_command_console", &"asterion_station_architecture"],
			"featureIds": [&"security_checkpoint", &"control_gate_message", &"mother_computer_windows", &"two_cover_routes"],
		}, true)
	elif room_id == &"AS-08":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_station_control.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_complete"},
			"navigationId": &"authored:as08-station-control-navigation", "collisionMaskId": &"authored:as08-station-control-collision",
			"navigationLayout": {
				"id": &"as08-station-control-v1", "kind": &"authored", "usefulCellRange": Vector2i(263, 264),
				"walkableRects": [
					{"origin": Vector2i(7, 1), "size": Vector2i(11, 4)}, # command-deck arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(18, 11)}, # Mother Computer arena and stabilized consoles
					{"origin": Vector2i(7, 14), "size": Vector2i(11, 4)}, # post-victory reward floor
				],
			},
			"visualProfileIds": [&"asterion_command_console", &"asterion_station_architecture"],
			"featureIds": [&"mother_computer_arena", &"ion_pistol_reward", &"astronaut_recruit_completion", &"stabilized_consoles"],
			"bossEncounter": {"nodeName": "AsterionMotherComputer", "encounterId": &"asterion_mother_computer", "defeatedFlag": &"asterion_station_complete", "cell": Vector2i(12, 9)},
		}, true)
	elif room_id == &"AS-09":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_bonded_customs_vault.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw"],
			"navigationId": &"authored:as09-bonded-customs-vault-navigation", "collisionMaskId": &"authored:as09-bonded-customs-vault-collision",
			"navigationLayout": {"id": &"as09-bonded-customs-vault-v1", "kind": &"authored", "usefulCellRange": Vector2i(119, 119), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(12, 7)}, {"origin": Vector2i(5, 10), "size": Vector2i(9, 2)}]},
			"visualProfileIds": [&"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"cargo_override", &"shelf_puzzle", &"contraband_gear_cache"],
			"asterionInteractions": [{"nodeName": "AsterionCargoCache", "kind": &"cargo_cache", "cell": Vector2i(9, 7)}],
		}, true)
	elif room_id == &"AS-10":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_observation_ring.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_restored"},
			"navigationId": &"authored:as10-observation-ring-navigation", "collisionMaskId": &"authored:as10-observation-ring-collision",
			"navigationLayout": {"id": &"as10-observation-ring-v1", "kind": &"authored", "usefulCellRange": Vector2i(259, 260), "walkableRects": [{"origin": Vector2i(7, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(20, 10)}, {"origin": Vector2i(7, 13), "size": Vector2i(12, 3)}]},
			"visualProfileIds": [&"asterion_dock_hull", &"asterion_command_console"],
			"featureIds": [&"curved_vista", &"shutter_controls", &"zero_pressure_optional_combat", &"empyreal_star_chart"],
		}, true)
	elif room_id == &"AS-11":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_structural_maintenance_bay.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Nw": &"asterion_station_complete", &"Ne": &"asterion_station_complete"},
			"navigationId": &"authored:as11-maintenance-bay-navigation", "collisionMaskId": &"authored:as11-maintenance-bay-collision",
			"navigationLayout": {"id": &"as11-maintenance-bay-v1", "kind": &"authored", "usefulCellRange": Vector2i(162, 164), "walkableRects": [{"origin": Vector2i(6, 1), "size": Vector2i(11, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(17, 7)}, {"origin": Vector2i(5, 10), "size": Vector2i(12, 2)}]},
			"visualProfileIds": [&"asterion_station_architecture", &"asterion_dock_bulkhead"],
			"featureIds": [&"load_bearing_switches", &"engineering_loot", &"two_sided_shortcut", &"bulkhead_warden_trial"],
			"bossEncounter": {"nodeName": "BulkheadWardenTrial", "encounterId": &"asterion_bulkhead_warden_trial", "defeatedFlag": &"bulkhead_warden_trial_complete", "cell": Vector2i(11, 7)},
		}, true)
	elif room_id == &"AS-12":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_cryosleep_berths.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_medical_ambush_cleared"},
			"navigationId": &"authored:as12-cryosleep-berths-navigation", "collisionMaskId": &"authored:as12-cryosleep-berths-collision",
			"navigationLayout": {"id": &"as12-cryosleep-berths-v1", "kind": &"authored", "usefulCellRange": Vector2i(148, 149), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(9, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(13, 8)}, {"origin": Vector2i(5, 11), "size": Vector2i(9, 3)}]},
			"visualProfileIds": [&"asterion_medical_station", &"asterion_station_architecture"],
			"featureIds": [&"identity_logs", &"pod_releases", &"medical_supply_cache", &"relocating_residents"],
		}, true)
	elif room_id == &"AS-14":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_service_tram.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_restored"},
			"navigationId": &"authored:as14-service-tram-navigation", "collisionMaskId": &"authored:as14-service-tram-collision",
			"navigationLayout": {"id": &"as14-service-tram-v1", "kind": &"authored", "usefulCellRange": Vector2i(71, 72), "walkableRects": [{"origin": Vector2i(4, 1), "size": Vector2i(8, 3)}, {"origin": Vector2i(2, 3), "size": Vector2i(12, 4)}, {"origin": Vector2i(4, 6), "size": Vector2i(8, 2)}]},
			"visualProfileIds": [&"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"tram_platform", &"stabilized_shortcut", &"saved_arrival_anchor"],
		}, true)
	elif room_id == &"HM-01":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_rain_gate.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm01-rain-gate-navigation",
			"collisionMaskId": &"authored:hm01-rain-gate-collision",
			"populationAnchorCells": {&"P1": Vector2i(6, 6), &"P2": Vector2i(12, 6), &"P3": Vector2i(6, 8), &"P4": Vector2i(12, 8)},
			"navigationLayout": {
				"id": &"hm01-rain-gate-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(90, 139),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(7, 1)}, # gate lintel
					{"origin": Vector2i(6, 2), "size": Vector2i(1, 7)}, # west facade edge
					{"origin": Vector2i(12, 2), "size": Vector2i(1, 7)}, # east facade edge
					{"origin": Vector2i(4, 3), "size": Vector2i(3, 3)}, # west entry terrace
					{"origin": Vector2i(12, 3), "size": Vector2i(3, 3)}, # east entry terrace
					{"origin": Vector2i(6, 6), "size": Vector2i(7, 3)}, # dry porch
					{"origin": Vector2i(1, 8), "size": Vector2i(16, 1)}, # wet stone crossway
					{"origin": Vector2i(2, 9), "size": Vector2i(14, 3)}, # rain forecourt
					{"origin": Vector2i(5, 12), "size": Vector2i(7, 1)}, # return-path lip
				],
			},
			"visualProfileIds": [&"haunted_mansion_exterior"],
		}, true)
	elif room_id == &"HM-02":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_foyer.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"],
			"portGates": {&"E1": &"mansion_first_room_complete"},
			"navigationId": &"authored:hm02-west-foyer-navigation",
			"collisionMaskId": &"authored:hm02-west-foyer-collision",
			"navigationLayout": {
				"id": &"hm02-west-foyer-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(214, 216),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(17, 4)}, # entry gallery and chandelier apron
					{"origin": Vector2i(4, 4), "size": Vector2i(17, 7)}, # central clock hall
					{"origin": Vector2i(20, 5), "size": Vector2i(3, 3)}, # 4:44 servants' wallpaper seam
					{"origin": Vector2i(5, 11), "size": Vector2i(18, 2)}, # south lounge and return route
					{"origin": Vector2i(22, 13), "size": Vector2i(1, 1)}, # conservatory departure landing
				],
			},
			"visualProfileIds": [&"mansion_foyer_clock", &"mansion_foyer_wall_tableau"],
		}, true)
	elif room_id == &"HM-03":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_study.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw"],
			"navigationId": &"authored:hm03-ledger-study-navigation",
			"collisionMaskId": &"authored:hm03-ledger-study-collision",
			"navigationLayout": {
				"id": &"hm03-ledger-study-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(134, 134),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(13, 4)}, # entry gallery between tall shelves
					{"origin": Vector2i(3, 4), "size": Vector2i(16, 6)}, # ledger floor and rotating-shelf sightline
				],
			},
			"visualProfileIds": [&"mansion_archive_shelving", &"mansion_archive_cabinet"],
			"featureIds": [&"false_book_row", &"household_ledger"],
		}, true)
	elif room_id == &"HM-04":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_clock_passage.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"mansion_temporal_secret_found"},
			"navigationId": &"authored:hm04-clock-passage-navigation",
			"collisionMaskId": &"authored:hm04-clock-passage-collision",
			"navigationLayout": {
				"id": &"hm04-clock-passage-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(60, 63),
				"walkableRects": [
					{"origin": Vector2i(3, 1), "size": Vector2i(8, 3)}, # clock threshold
					{"origin": Vector2i(2, 3), "size": Vector2i(10, 4)}, # pendulum timing corridor
					{"origin": Vector2i(4, 7), "size": Vector2i(6, 1)}, # wall-alcove recovery strip
				],
			},
			"visualProfileIds": [&"mansion_foyer_clock", &"mansion_foyer_passage_door"],
			"featureIds": [&"pendulum_blade_timing", &"clock_444_gate"],
		}, true)
	elif room_id == &"HM-05":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_archive.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"],
			"portGates": {&"E2": &"mansion_ballroom_open"},
			"navigationId": &"authored:hm05-servants-archive-navigation",
			"collisionMaskId": &"authored:hm05-servants-archive-collision",
			"navigationLayout": {
				"id": &"hm05-servants-archive-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(110, 112),
				"walkableRects": [
					{"origin": Vector2i(4, 1), "size": Vector2i(10, 4)}, # archive entry and cabinet apron
					{"origin": Vector2i(3, 4), "size": Vector2i(12, 6)}, # records aisles and anchor-clock floor
					{"origin": Vector2i(14, 3), "size": Vector2i(2, 7)}, # gallery and kitchen side vestibules
				],
			},
			"visualProfileIds": [&"mansion_archive_shelving", &"mansion_archive_cabinet", &"mansion_foyer_clock"],
			"featureIds": [&"servant_records", &"archive_retry_anchor"],
			"savePoint": {
				"id": &"mansion_archive",
				"nodeName": "ArchiveAnchorClock",
				"anchorName": "archive clock",
				"cell": Vector2i(9, 7),
			},
		}, true)
	elif room_id == &"HM-14":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_portrait_balcony.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"navigationId": &"authored:hm14-west-stair-navigation",
			"collisionMaskId": &"authored:hm14-west-stair-collision",
			"navigationLayout": {
				"id": &"hm14-west-stair-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(121, 122),
				"walkableRects": [
					{"origin": Vector2i(4, 1), "size": Vector2i(11, 4)}, # upper balcony arrival
					{"origin": Vector2i(3, 4), "size": Vector2i(14, 6)}, # stair landing and portrait overlook
					{"origin": Vector2i(16, 3), "size": Vector2i(2, 3)}, # attic side-vestibule and follower space
				],
			},
			"visualProfileIds": [&"mansion_gallery_left_portrait", &"mansion_gallery_right_portrait", &"mansion_gallery_stage_curtain"],
			"featureIds": [&"west_stair", &"portrait_balcony", &"gallery_return_banister"],
		}, true)
	elif room_id == &"HM-06":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_portrait_gallery.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm06-portrait-gallery-navigation",
			"collisionMaskId": &"authored:hm06-portrait-gallery-collision",
			"navigationLayout": {
				"id": &"hm06-portrait-gallery-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(207, 207),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(14, 4)}, # framed upper-gallery arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(19, 7)}, # portrait ambush floor and central stage
					{"origin": Vector2i(5, 11), "size": Vector2i(16, 2)}, # south viewing balcony
				],
			},
			"visualProfileIds": [&"mansion_gallery_left_portrait", &"mansion_gallery_right_portrait", &"mansion_gallery_upper_left_frame", &"mansion_gallery_upper_right_frame", &"mansion_gallery_stage_curtain"],
			"featureIds": [&"portrait_ambush", &"silver_hour_hand", &"false_bottom_cache", &"central_portrait", &"rotating_frame_sightline"],
			"chapterInteractions": [
				{"nodeName": "GalleryPortrait", "kind": &"gallery_portrait", "cell": Vector2i(13, 6)},
				{"nodeName": "GalleryCache", "kind": &"gallery_cache", "cell": Vector2i(4, 7)},
			],
		}, true)
	elif room_id == &"HM-15":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_mirror_corridor.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm15-mirror-link-navigation",
			"collisionMaskId": &"authored:hm15-mirror-link-collision",
			"navigationLayout": {
				"id": &"hm15-mirror-link-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(76, 77),
				"walkableRects": [
					{"origin": Vector2i(4, 1), "size": Vector2i(10, 3)}, # mirror threshold and north arrivals
					{"origin": Vector2i(2, 3), "size": Vector2i(14, 4)}, # reflected-service corridor
				],
			},
			"visualProfileIds": [&"mansion_gallery_lower_left_frame", &"mansion_gallery_lower_right_frame", &"mansion_foyer_wall_tableau"],
			"featureIds": [&"next_room_mirrors", &"false_reflection_encounter", &"reliable_reflection_loop"],
		}, true)
	elif room_id == &"HM-07":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_nursery.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm07-borrowed-years-navigation",
			"collisionMaskId": &"authored:hm07-borrowed-years-collision",
			"navigationLayout": {
				"id": &"hm07-borrowed-years-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(136, 136),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(12, 4)}, # nursery doorway and wall-panel apron
					{"origin": Vector2i(3, 4), "size": Vector2i(16, 6)}, # bed, music-box, and toy-chest floor
					{"origin": Vector2i(18, 3), "size": Vector2i(2, 3)}, # chapel-latch vestibule and follower space
				],
			},
			"visualProfileIds": [&"mansion_nursery_bed", &"mansion_nursery_music_box", &"mansion_nursery_left_wall_panel", &"mansion_nursery_right_wall_panel"],
			"featureIds": [&"doll_ambush", &"silver_hour_hand_socket", &"brass_minute_hand", &"toy_chest_cache", &"wooden_raptor"],
			"chapterInteractions": [
				{"nodeName": "NurseryMusicBox", "kind": &"nursery_music_box", "cell": Vector2i(12, 6)},
				{"nodeName": "NurseryCache", "kind": &"nursery_cache", "cell": Vector2i(16, 8)},
			],
		}, true)
	elif room_id == &"HM-08":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_ballroom_antechamber.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"],
			"portGates": {&"Ne": &"mansion_ballroom_open", &"E1": &"mansion_attic_latch_open", &"E2": &"mansion_ballroom_open"},
			"navigationId": &"authored:hm08-ballroom-antechamber-navigation",
			"collisionMaskId": &"authored:hm08-ballroom-antechamber-collision",
			"navigationLayout": {
				"id": &"hm08-ballroom-antechamber-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(121, 124),
				"walkableRects": [
					{"origin": Vector2i(4, 1), "size": Vector2i(10, 5)}, # chandelier threshold and ballroom lock
					{"origin": Vector2i(3, 5), "size": Vector2i(12, 6)}, # preparation floor and respite clock
					{"origin": Vector2i(14, 4), "size": Vector2i(2, 8)}, # attic and ballroom side vestibule
				],
			},
			"visualProfileIds": [&"mansion_ballroom_chandelier", &"mansion_ballroom_door_frame", &"mansion_foyer_clock"],
			"featureIds": [&"two_hand_ballroom_lock", &"ballroom_preparation_area", &"hand_socket_display"],
			"savePoint": {
				"id": &"mansion_ballroom_antechamber",
				"nodeName": "NurseryRespiteClock",
				"anchorName": "nursery respite clock",
				"cell": Vector2i(9, 8),
			},
			"chapterInteractions": [
				{"nodeName": "BallroomGate", "kind": &"ballroom_gate", "cell": Vector2i(12, 3)},
			],
		}, true)
	elif room_id == &"HM-09":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_ballroom.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw"],
			"navigationId": &"authored:hm09-grand-ballroom-navigation",
			"collisionMaskId": &"authored:hm09-grand-ballroom-collision",
			"navigationLayout": {
				"id": &"hm09-grand-ballroom-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(197, 197),
				"walkableRects": [
					{"origin": Vector2i(6, 1), "size": Vector2i(12, 4)}, # chandelier approach
					{"origin": Vector2i(3, 4), "size": Vector2i(18, 9)}, # Clock Mirror arena and results floor
				],
			},
			"visualProfileIds": [&"mansion_ballroom_chandelier", &"mansion_ballroom_door_frame", &"clock_mirror_battle_actor"],
			"featureIds": [&"clock_mirror_arena", &"results_return_anchor", &"stabilized_ballroom_lighting"],
			"bossEncounter": {"nodeName": "The444Appointment", "encounterId": &"mansion_archive_boss", "defeatedFlag": &"mansion_archive_boss_defeated", "cell": Vector2i(12, 9)},
		}, true)
	elif room_id == &"HM-10":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_conservatory.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm10-dead-conservatory-navigation",
			"collisionMaskId": &"authored:hm10-dead-conservatory-collision",
			"navigationLayout": {
				"id": &"hm10-dead-conservatory-v1",
				"kind": &"authored",
				"usefulCellRange": Vector2i(114, 114),
				"walkableRects": [
					{"origin": Vector2i(5, 1), "size": Vector2i(10, 4)}, # glass-house arrivals
					{"origin": Vector2i(3, 4), "size": Vector2i(14, 6)}, # branch paths and shutter return
				],
			},
			"visualProfileIds": [&"mansion_archive_wall_lit_tile", &"mansion_archive_wall_plain_tile", &"mansion_foyer_wall_tableau"],
			"featureIds": [&"cursed_tree_elite", &"herb_cache", &"inside_shutter_shortcut", &"impossible_black_rose"],
		}, true)
	elif room_id == &"HM-16":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_kitchen_lift.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm16-kitchen-lift-navigation", "collisionMaskId": &"authored:hm16-kitchen-lift-collision",
			"navigationLayout": {"id": &"hm16-kitchen-lift-v1", "kind": &"authored", "usefulCellRange": Vector2i(112, 112), "walkableRects": [{"origin": Vector2i(4, 1), "size": Vector2i(10, 5)}, {"origin": Vector2i(3, 5), "size": Vector2i(12, 6)}]},
			"visualProfileIds": [&"mansion_archive_cabinet", &"mansion_archive_shelving", &"mansion_foyer_passage_door"],
			"featureIds": [&"pantry_supplies", &"service_lift", &"stabilized_return_route"],
		}, true)
	elif room_id == &"HM-11":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_mourning_chapel.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"mansion_crypt_key_found"},
			"navigationId": &"authored:hm11-mourning-chapel-navigation", "collisionMaskId": &"authored:hm11-mourning-chapel-collision",
			"navigationLayout": {"id": &"hm11-mourning-chapel-v1", "kind": &"authored", "usefulCellRange": Vector2i(136, 136), "walkableRects": [{"origin": Vector2i(5, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(16, 6)}, {"origin": Vector2i(18, 3), "size": Vector2i(2, 3)}]},
			"visualProfileIds": [&"mansion_gallery_stage_curtain", &"mansion_gallery_upper_left_frame", &"mansion_gallery_upper_right_frame"],
			"featureIds": [&"stained_glass_alignment", &"anti_curse_accessory", &"nursery_latch"],
			"chapterInteractions": [{"nodeName": "ChapelGlass", "kind": &"chapel_alignment", "cell": Vector2i(11, 7)}],
		}, true)
	elif room_id == &"HM-12":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_undercroft.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"navigationId": &"authored:hm12-sealed-undercroft-navigation", "collisionMaskId": &"authored:hm12-sealed-undercroft-collision",
			"navigationLayout": {"id": &"hm12-sealed-undercroft-v1", "kind": &"authored", "usefulCellRange": Vector2i(216, 216), "walkableRects": [{"origin": Vector2i(6, 1), "size": Vector2i(12, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(18, 10)}]},
			"visualProfileIds": [&"mansion_archive_wall_plain_tile", &"mansion_archive_wall_lit_tile", &"mansion_gallery_stage_curtain"],
			"featureIds": [&"temporal_field_note", &"anchor_dust_payoff", &"infernal_elite", &"two_sided_exit"],
		}, true)
	elif room_id == &"HM-13":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_dollmaker_attic.tscn", "worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"], "portGates": {&"Ne": &"mansion_attic_latch_open"},
			"navigationId": &"authored:hm13-dollmaker-attic-navigation", "collisionMaskId": &"authored:hm13-dollmaker-attic-collision",
			"navigationLayout": {"id": &"hm13-dollmaker-attic-v1", "kind": &"authored", "usefulCellRange": Vector2i(101, 102), "walkableRects": [{"origin": Vector2i(4, 1), "size": Vector2i(10, 4)}, {"origin": Vector2i(3, 4), "size": Vector2i(12, 6)}]},
			"visualProfileIds": [&"mansion_nursery_bed", &"mansion_archive_shelving", &"mansion_nursery_music_box"],
			"featureIds": [&"vertical_clutter_maze", &"dollmaker_invoice", &"doll_resistant_charm", &"attic_stair"],
			"chapterInteractions": [{"nodeName": "AtticStair", "kind": &"attic_stair", "cell": Vector2i(9, 8)}],
		}, true)
	return definition


static func room_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for room_id in MANSION_ROOM_IDS:
		result.append(room_id)
	for room_id in ASTERION_ROOM_IDS:
		result.append(room_id)
	for room_id in PRIMEVAL_ROOM_IDS:
		result.append(room_id)
	for room_id in HELIOS_ROOM_IDS:
		result.append(room_id)
	for room_id in FROSTHOLD_ROOM_IDS:
		result.append(room_id)
	for room_id in MOONPETAL_ROOM_IDS:
		result.append(room_id)
	for room_id in EMPYREAL_ROOM_IDS:
		result.append(room_id)
	return result


static func ports(room_id: StringName) -> Array[Dictionary]:
	return room(room_id).get("ports", []) as Array[Dictionary]


static func port(room_id: StringName, port_id: StringName) -> Dictionary:
	for definition in ports(room_id):
		if StringName(definition.get("id", &"")) == port_id:
			return definition.duplicate(true)
	return {}


static func is_authored_room(room_id: StringName) -> bool:
	return not String(room(room_id).get("scenePath", "")).is_empty()


static func streamed_room_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for room_id in room_ids():
		var definition := room(room_id)
		if is_authored_room(room_id) and definition.has("worldOrigin"):
			result.append(room_id)
	return result


static func room_id_at_world_cell(cell: Vector2i) -> StringName:
	for room_id in streamed_room_ids():
		var definition := room(room_id)
		var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
		var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
		if Rect2i(origin, dimensions).has_point(cell):
			return room_id
	return &""


static func enabled_port_ids(room_id: StringName, story_flags: Dictionary = CampaignState.story_flags) -> Array[StringName]:
	var definition := room(room_id)
	var gates: Dictionary = definition.get("portGates", {})
	var result: Array[StringName] = []
	for port_id in definition.get("enabledPortIds", []):
		var normalized := StringName(port_id)
		var required_flag := StringName(gates.get(normalized, &""))
		if required_flag == &"" or bool(story_flags.get(required_flag, false)):
			result.append(normalized)
	return result


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if MANSION_ROOMS.size() != MANSION_ROOM_IDS.size():
		errors.append("Mansion room registry must define exactly %d rooms." % MANSION_ROOM_IDS.size())
	var seen: Dictionary = {}
	for room_id in room_ids():
		if seen.has(room_id) or not has_room(room_id):
			errors.append("Campaign registry is missing or duplicates %s." % room_id)
			continue
		seen[room_id] = true
		var definition := room(room_id)
		var blueprint := StringName(definition.get("blueprint", &""))
		if blueprint == &"" or blueprint_layout(blueprint).is_empty():
			errors.append("%s has no blueprint." % room_id)
			continue
		var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
		if dimensions != blueprint_layout(blueprint).get("dimensions", Vector2i.ZERO):
			errors.append("%s dimensions do not match %s." % [room_id, blueprint])
		if definition.get("cameraBounds", Rect2i()) != FIELD_SCALE.camera_bounds_for_cells(dimensions):
			errors.append("%s camera bounds do not match its resolved dimensions." % room_id)
		if StringName(definition.get("collisionMaskId", &"")) == &"" or StringName(definition.get("navigationId", &"")) == &"":
			errors.append("%s is missing collision or navigation records." % room_id)
		var population_anchors: Array = definition.get("populationAnchors", [])
		var population_cells: Dictionary = definition.get("populationAnchorCells", {})
		if population_anchors.size() != int(definition.get("populationAnchorCount", 0)) or population_cells.size() != population_anchors.size():
			errors.append("%s population anchor records do not match the manifest count." % room_id)
		var policy := StringName(definition.get("encounterPolicy", &""))
		if policy not in [&"none", &"zone", &"scripted_only", &"boss"]:
			errors.append("%s has invalid encounter policy %s." % [room_id, policy])
		var anchors := int(definition.get("populationAnchorCount", 0))
		if anchors < 1 or anchors > 6:
			errors.append("%s has invalid population anchor count %d." % [room_id, anchors])
		var port_ids: Dictionary = {}
		for port in ports(room_id):
			var port_id := StringName(port.get("id", &""))
			var destination := StringName(port.get("destination", &""))
			if port_id == &"" or port_ids.has(port_id):
				errors.append("%s has a missing or duplicate port id." % room_id)
			port_ids[port_id] = true
			if not (definition.get("portCells", {}) as Dictionary).has(port_id):
				errors.append("%s.%s has no blueprint port cell." % [room_id, port_id])
			if (destination.begins_with("HM-") or destination.begins_with("AS-") or destination.begins_with("PV-") or destination.begins_with("HE-") or destination.begins_with("FR-") or destination.begins_with("MP-") or destination.begins_with("EM-")) and not has_room(destination):
				errors.append("%s.%s targets unknown room %s." % [room_id, port_id, destination])
			elif not destination.begins_with("HM-") and not destination.begins_with("AS-") and not destination.begins_with("PV-") and not destination.begins_with("HE-") and not destination.begins_with("FR-") and not destination.begins_with("MP-") and not destination.begins_with("EM-") and destination not in [&"FI-05", &"FI-06", &"FI-07", &"FI-08", &"FI-09", &"FI-10", &"FI-11"]:
				errors.append("%s.%s targets undeclared external room %s." % [room_id, port_id, destination])
	if not _reachable(&"HM-01", &"HM-09"):
		errors.append("Mansion critical path cannot reach HM-09 from HM-01.")
	if _reachable_room_count(&"HM-01") != MANSION_ROOM_IDS.size():
		errors.append("Mansion room graph is not connected from HM-01.")
	if _reachable_room_count(&"AS-01") != ASTERION_ROOM_IDS.size():
		errors.append("Asterion room graph is not connected from AS-01.")
	if _reachable_room_count(&"PV-01") != PRIMEVAL_ROOM_IDS.size():
		errors.append("Primeval room graph is not connected from PV-01.")
	if _reachable_room_count(&"HE-01") != HELIOS_ROOM_IDS.size(): errors.append("Helios room graph is not connected from HE-01.")
	if _reachable_room_count(&"FR-01") != FROSTHOLD_ROOM_IDS.size(): errors.append("Frosthold room graph is not connected from FR-01.")
	if _reachable_room_count(&"MP-01") != MOONPETAL_ROOM_IDS.size(): errors.append("Moonpetal room graph is not connected from MP-01.")
	if _reachable_room_count(&"EM-01") != EMPYREAL_ROOM_IDS.size(): errors.append("Empyreal room graph is not connected from EM-01.")
	_validate_facility_portals(errors)
	_validate_manifest_test_rooms(errors)
	return PackedStringArray(errors)


static func _validate_facility_portals(errors: Array[String]) -> void:
	if FACILITY_PORTALS.size() != 7:
		errors.append("Manifest facility portal registry must define all seven authored worlds.")
	for facility_name in FACILITY_PORTALS:
		var portal: Dictionary = FACILITY_PORTALS[facility_name]
		var prefix := String(portal.get("prefix", ""))
		var entry_room_id := StringName(portal.get("entryRoomId", &""))
		var portal_room_ids: Array = portal.get("roomIds", [])
		if prefix == "" or entry_room_id == &"" or portal_room_ids.is_empty():
			errors.append("Facility %s has an incomplete manifest portal record." % facility_name)
			continue
		if entry_room_id not in portal_room_ids or not has_room(entry_room_id):
			errors.append("Facility %s entry room %s is not in its manifest graph." % [facility_name, entry_room_id])
		for room_id in portal_room_ids:
			if not has_room(room_id):
				errors.append("Facility %s references unknown room %s." % [facility_name, room_id])


static func _validate_manifest_test_rooms(errors: Array[String]) -> void:
	var definition := room(&"TEST-01")
	if not is_authored_room(&"TEST-01"):
		errors.append("Manifest test room must define an authored scene path.")
	if definition.get("dimensions", Vector2i.ZERO) != Vector2i(14, 10):
		errors.append("Manifest test room dimensions must match S1.")
	if definition.get("cameraBounds", Rect2i()) != FIELD_SCALE.camera_bounds_for_cells(Vector2i(14, 10)):
		errors.append("Manifest test room camera bounds must match its 48px cells.")
	for port_id in [&"Nw", &"Ne"]:
		var binding := port(&"TEST-01", port_id)
		if StringName(binding.get("destination", &"")) != &"TEST-01" or StringName(binding.get("arrivalPort", &"")) == &"":
			errors.append("Manifest test room %s port must have a reciprocal binding." % port_id)
	var hm01 := room(&"HM-01")
	if not is_authored_room(&"HM-01") or hm01.get("worldOrigin", Vector2i.ZERO) != Vector2i(300, 0):
		errors.append("HM-01 must declare its authored rain-gate scene and world origin.")
	if hm01.get("visualProfileIds", []) != [&"haunted_mansion_exterior"]:
		errors.append("HM-01 must reference the admitted Mansion exterior profile.")
	if StringName(hm01.get("navigationId", &"")) != &"authored:hm01-rain-gate-navigation" or StringName(hm01.get("collisionMaskId", &"")) != &"authored:hm01-rain-gate-collision":
		errors.append("HM-01 must own its authored rain-gate navigation and collision records.")
	var hm02 := room(&"HM-02")
	if StringName(hm02.get("navigationId", &"")) != &"authored:hm02-west-foyer-navigation" or StringName(hm02.get("collisionMaskId", &"")) != &"authored:hm02-west-foyer-collision":
		errors.append("HM-02 must own its authored west-foyer navigation and collision records.")
	var hm03 := room(&"HM-03")
	if StringName(hm03.get("navigationId", &"")) != &"authored:hm03-ledger-study-navigation" or StringName(hm03.get("collisionMaskId", &"")) != &"authored:hm03-ledger-study-collision":
		errors.append("HM-03 must own its authored ledger-study navigation and collision records.")
	var hm04 := room(&"HM-04")
	if StringName(hm04.get("navigationId", &"")) != &"authored:hm04-clock-passage-navigation" or StringName(hm04.get("collisionMaskId", &"")) != &"authored:hm04-clock-passage-collision":
		errors.append("HM-04 must own its authored clock-passage navigation and collision records.")
	var hm05 := room(&"HM-05")
	if StringName(hm05.get("navigationId", &"")) != &"authored:hm05-servants-archive-navigation" or StringName(hm05.get("collisionMaskId", &"")) != &"authored:hm05-servants-archive-collision":
		errors.append("HM-05 must own its authored archive navigation and collision records.")
	var hm06 := room(&"HM-06")
	if StringName(hm06.get("navigationId", &"")) != &"authored:hm06-portrait-gallery-navigation" or StringName(hm06.get("collisionMaskId", &"")) != &"authored:hm06-portrait-gallery-collision":
		errors.append("HM-06 must own its authored portrait-gallery navigation and collision records.")
	var hm07 := room(&"HM-07")
	if StringName(hm07.get("navigationId", &"")) != &"authored:hm07-borrowed-years-navigation" or StringName(hm07.get("collisionMaskId", &"")) != &"authored:hm07-borrowed-years-collision":
		errors.append("HM-07 must own its authored nursery navigation and collision records.")
	var hm08 := room(&"HM-08")
	if StringName(hm08.get("navigationId", &"")) != &"authored:hm08-ballroom-antechamber-navigation" or StringName(hm08.get("collisionMaskId", &"")) != &"authored:hm08-ballroom-antechamber-collision":
		errors.append("HM-08 must own its authored antechamber navigation and collision records.")
	var hm09 := room(&"HM-09")
	if StringName(hm09.get("navigationId", &"")) != &"authored:hm09-grand-ballroom-navigation" or StringName(hm09.get("collisionMaskId", &"")) != &"authored:hm09-grand-ballroom-collision":
		errors.append("HM-09 must own its authored ballroom navigation and collision records.")
	var hm10 := room(&"HM-10")
	if StringName(hm10.get("navigationId", &"")) != &"authored:hm10-dead-conservatory-navigation" or StringName(hm10.get("collisionMaskId", &"")) != &"authored:hm10-dead-conservatory-collision":
		errors.append("HM-10 must own its authored conservatory navigation and collision records.")
	var hm14 := room(&"HM-14")
	if StringName(hm14.get("navigationId", &"")) != &"authored:hm14-west-stair-navigation" or StringName(hm14.get("collisionMaskId", &"")) != &"authored:hm14-west-stair-collision":
		errors.append("HM-14 must own its authored west-stair navigation and collision records.")
	var hm15 := room(&"HM-15")
	if StringName(hm15.get("navigationId", &"")) != &"authored:hm15-mirror-link-navigation" or StringName(hm15.get("collisionMaskId", &"")) != &"authored:hm15-mirror-link-collision":
		errors.append("HM-15 must own its authored mirror-link navigation and collision records.")


static func _reachable(start: StringName, target: StringName) -> bool:
	return _reachable_ids(start).has(target)


static func _reachable_room_count(start: StringName) -> int:
	return _reachable_ids(start).size()


static func _reachable_ids(start: StringName) -> Dictionary:
	var visited: Dictionary = {}
	var pending: Array[StringName] = [start]
	while not pending.is_empty():
		var current: StringName = pending.pop_back()
		if visited.has(current) or not has_room(current):
			continue
		visited[current] = true
		for port in ports(current):
			var destination := StringName(port.get("destination", &""))
			if has_room(destination) and not visited.has(destination):
				pending.append(destination)
	return visited
