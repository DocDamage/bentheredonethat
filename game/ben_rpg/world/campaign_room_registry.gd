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


static func room(room_id: StringName) -> Dictionary:
	var source: Dictionary = MANSION_ROOMS if MANSION_ROOMS.has(room_id) else (ASTERION_ROOMS if ASTERION_ROOMS.has(room_id) else (PRIMEVAL_ROOMS if PRIMEVAL_ROOMS.has(room_id) else (HELIOS_ROOMS if HELIOS_ROOMS.has(room_id) else (FROSTHOLD_ROOMS if FROSTHOLD_ROOMS.has(room_id) else (MOONPETAL_ROOMS if MOONPETAL_ROOMS.has(room_id) else (EMPYREAL_ROOMS if EMPYREAL_ROOMS.has(room_id) else MANIFEST_TEST_ROOMS))))))
	var definition := (source.get(room_id, {}) as Dictionary).duplicate(true)
	if room_id == &"HE-01": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_afterlight_skybridge.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"]},true)
	elif room_id == &"HE-02": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_curfew_customs.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1"]},true)
	elif room_id == &"HE-03": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_public_market.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"]},true)
	elif room_id == &"HE-13": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_grid_junction.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2"],"featureIds":[&"phase_inverter_route",&"night_grid_switch"]},true)
	elif room_id == &"HE-06": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_clinic.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne"]},true)
	elif room_id == &"HE-07": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_transit_exchange.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw",&"Ne",&"E1",&"E2",&"Se"],"featureIds":[&"transit_daylight_node",&"core_route"]},true)
	elif room_id == &"HE-08": definition.merge({"scenePath":"res://ben_rpg/world/rooms/helios_solar_core.tscn","worldOrigin":Vector2i(450,0),"enabledPortIds":[&"Nw"],"featureIds":[&"civic_sun_boss",&"midnight_restore"]},true)
	elif room_id == &"PV-01":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_thunderfern_grove.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"E1": &"primeval_terminal_decoded"}, "featureIds": [&"grove_intro_battle", &"looping_clearings", &"canopy_occlusion", &"tyrant_tracks"]}, true)
	elif room_id == &"PV-02":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_stone_signal_crossing.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "featureIds": [&"traffic_totem", &"meteor_warning", &"pulsing_signal_stones"], "primevalInteractions": [{"nodeName": "PrimevalTrafficTotem", "kind": &"traffic_totem", "cell": Vector2i(10, 6)}]}, true)
	elif room_id == &"PV-03":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_borough.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2", &"Se"], "portGates": {&"E1": &"primeval_terminal_decoded", &"Se": &"primeval_caldera_open"}, "featureIds": [&"caveman_meeting", &"population_hub", &"locked_relay_trail", &"green_traffic_state"]}, true)
	elif room_id == &"PV-04":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_canopy_causeway.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "featureIds": [&"elevated_branches", &"foreground_leaves", &"territorial_dinosaur", &"ruins_rope_bridge"]}, true)
	elif room_id == &"PV-05":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_jungle_ruins_court.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"E2": &"primeval_terminal_decoded"}, "featureIds": [&"signal_glyph_hub", &"ruin_formation", &"specialist_supply_hollow", &"ruin_return_gate"]}, true)
	elif room_id == &"PV-06":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_cave_computer_vault.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "featureIds": [&"translator_requirement", &"cave_os", &"remote_relay_unlock", &"isolated_ancient_tech"], "primevalInteractions": [{"nodeName": "PrimevalCaveTerminal", "kind": &"cave_terminal", "cell": Vector2i(10, 7)}]}, true)
	elif room_id == &"PV-07":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_relay_nest.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"Nw": &"primeval_terminal_decoded", &"Ne": &"primeval_caldera_open"}, "featureIds": [&"dinosaur_attendant_ambush", &"egg_relay", &"all_green_borough_state"], "primevalInteractions": [{"nodeName": "PrimevalAnchorTotem", "kind": &"anchor_totem", "savePointId": &"primeval_nest", "cell": Vector2i(8, 10)}, {"nodeName": "PrimevalRelayNest", "kind": &"relay_nest", "cell": Vector2i(15, 8)}]}, true)
	elif room_id == &"PV-08":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_caldera_crown.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"Nw": &"primeval_caldera_open", &"Ne": &"primeval_scenario_complete", &"E1": &"primeval_caldera_open"}, "featureIds": [&"caldera_vista", &"cooled_post_victory_route", &"mammoth_club_reward"], "bossEncounter": {"nodeName": "CommuteTyrant", "encounterId": &"primeval_commute_tyrant", "defeatedFlag": &"primeval_scenario_complete", "cell": Vector2i(12, 10)}}, true)
	elif room_id == &"PV-14":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_lava_tube_bypass.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1"], "portGates": {&"Ne": &"primeval_terminal_decoded", &"E1": &"primeval_caldera_open"}, "featureIds": [&"fossilized_service_tunnel", &"green_traffic_doors", &"stabilized_shortcut"]}, true)
	elif room_id == &"PV-09":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_luminous_fungal_hollow.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne"], "featureIds": [&"light_spore_path", &"restorative_fungus_cache", &"optional_fungal_formation"]}, true)
	elif room_id == &"PV-10":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_fossil_survey_quarry.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "featureIds": [&"three_fossil_eras", &"equipment_material_reward", &"mossback_trial"]}, true)
	elif room_id == &"PV-11":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_raptor_nursery.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne"], "portGates": {&"Ne": &"primeval_caldera_open"}, "featureIds": [&"egg_protection", &"nest_latch", &"calm_post_reset"]}, true)
	elif room_id == &"PV-12":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_storm_dragon_roost.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw"], "portGates": {&"Nw": &"primeval_scenario_complete"}, "featureIds": [&"wind_rock_traversal", &"elite_dragon", &"lightning_charm"]}, true)
	elif room_id == &"PV-13":
		definition.merge({"scenePath": "res://ben_rpg/world/rooms/primeval_river_switchbacks.tscn", "worldOrigin": Vector2i(400, 0), "enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"], "portGates": {&"Nw": &"primeval_terminal_decoded", &"E1": &"primeval_terminal_decoded"}, "featureIds": [&"stepping_stones", &"vine_return_cut", &"encounter_light_return"]}, true)
	elif room_id == &"AS-01":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_docking_collar.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"asterion_station_restored"},
			"visualProfileIds": [&"asterion_dock_hull", &"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"dock_intro_battle", &"astronaut_meeting", &"pressure_door_staging", &"cargo_loader_cover", &"safe_return_pad"],
		}, true)
	elif room_id == &"AS-02":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_customs_cargo_intake.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"visualProfileIds": [&"asterion_station_architecture", &"asterion_dock_bulkhead"],
			"featureIds": [&"freight_lanes", &"inspection_booths", &"shift_records", &"locked_customs_vault", &"cargo_belt_loop"],
		}, true)
	elif room_id == &"AS-03":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_mess_deck.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"visualProfileIds": [&"asterion_mess_banner", &"asterion_station_architecture"],
			"featureIds": [&"emergency_lighting", &"medical_hydro_logs", &"post_oxygen_residents"],
		}, true)
	elif room_id == &"AS-13":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_pressure_lock_junction.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2", &"Se"],
			"portGates": {&"E2": &"asterion_station_restored"},
			"visualProfileIds": [&"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"colored_pipe_symbols", &"medical_hydro_split", &"doorway_exclusion_patrol"],
		}, true)
	elif room_id == &"AS-04":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_medical_triage.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_medical_ambush_cleared"},
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
			"visualProfileIds": [&"asterion_command_console", &"asterion_station_architecture"],
			"featureIds": [&"security_checkpoint", &"control_gate_message", &"mother_computer_windows", &"two_cover_routes"],
		}, true)
	elif room_id == &"AS-08":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_station_control.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_complete"},
			"visualProfileIds": [&"asterion_command_console", &"asterion_station_architecture"],
			"featureIds": [&"mother_computer_arena", &"ion_pistol_reward", &"astronaut_recruit_completion", &"stabilized_consoles"],
			"bossEncounter": {"nodeName": "AsterionMotherComputer", "encounterId": &"asterion_mother_computer", "defeatedFlag": &"asterion_station_complete", "cell": Vector2i(12, 9)},
		}, true)
	elif room_id == &"AS-09":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_bonded_customs_vault.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw"],
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
			"visualProfileIds": [&"asterion_dock_hull", &"asterion_command_console"],
			"featureIds": [&"curved_vista", &"shutter_controls", &"zero_pressure_optional_combat", &"empyreal_star_chart"],
		}, true)
	elif room_id == &"AS-11":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_structural_maintenance_bay.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Nw": &"asterion_station_complete", &"Ne": &"asterion_station_complete"},
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
			"visualProfileIds": [&"asterion_medical_station", &"asterion_station_architecture"],
			"featureIds": [&"identity_logs", &"pod_releases", &"medical_supply_cache", &"relocating_residents"],
		}, true)
	elif room_id == &"AS-14":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/asterion_service_tram.tscn",
			"worldOrigin": Vector2i(350, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"portGates": {&"Ne": &"asterion_station_restored"},
			"visualProfileIds": [&"asterion_dock_bulkhead", &"asterion_station_architecture"],
			"featureIds": [&"tram_platform", &"stabilized_shortcut", &"saved_arrival_anchor"],
		}, true)
	elif room_id == &"HM-01":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_rain_gate.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"visualProfileIds": [&"haunted_mansion_exterior"],
		}, true)
	elif room_id == &"HM-02":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_foyer.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"],
			"portGates": {&"E1": &"mansion_first_room_complete"},
			"visualProfileIds": [&"mansion_foyer_clock", &"mansion_foyer_wall_tableau"],
		}, true)
	elif room_id == &"HM-03":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_study.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw"],
			"visualProfileIds": [&"mansion_archive_shelving", &"mansion_archive_cabinet"],
			"featureIds": [&"false_book_row", &"household_ledger"],
		}, true)
	elif room_id == &"HM-04":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_clock_passage.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"mansion_temporal_secret_found"},
			"visualProfileIds": [&"mansion_foyer_clock", &"mansion_foyer_passage_door"],
			"featureIds": [&"pendulum_blade_timing", &"clock_444_gate"],
		}, true)
	elif room_id == &"HM-05":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_archive.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1", &"E2"],
			"portGates": {&"E2": &"mansion_ballroom_open"},
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
			"visualProfileIds": [&"mansion_gallery_left_portrait", &"mansion_gallery_right_portrait", &"mansion_gallery_stage_curtain"],
			"featureIds": [&"west_stair", &"portrait_balcony", &"gallery_return_banister"],
		}, true)
	elif room_id == &"HM-06":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_portrait_gallery.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
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
			"visualProfileIds": [&"mansion_gallery_lower_left_frame", &"mansion_gallery_lower_right_frame", &"mansion_foyer_wall_tableau"],
			"featureIds": [&"next_room_mirrors", &"false_reflection_encounter", &"reliable_reflection_loop"],
		}, true)
	elif room_id == &"HM-07":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_nursery.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
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
			"visualProfileIds": [&"mansion_ballroom_chandelier", &"mansion_ballroom_door_frame", &"clock_mirror_battle_actor"],
			"featureIds": [&"clock_mirror_arena", &"results_return_anchor", &"stabilized_ballroom_lighting"],
			"bossEncounter": {"nodeName": "The444Appointment", "encounterId": &"mansion_archive_boss", "defeatedFlag": &"mansion_archive_boss_defeated", "cell": Vector2i(12, 9)},
		}, true)
	elif room_id == &"HM-10":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_conservatory.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"visualProfileIds": [&"mansion_archive_wall_lit_tile", &"mansion_archive_wall_plain_tile", &"mansion_foyer_wall_tableau"],
			"featureIds": [&"cursed_tree_elite", &"herb_cache", &"inside_shutter_shortcut", &"impossible_black_rose"],
		}, true)
	elif room_id == &"HM-16":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_kitchen_lift.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"visualProfileIds": [&"mansion_archive_cabinet", &"mansion_archive_shelving", &"mansion_foyer_passage_door"],
			"featureIds": [&"pantry_supplies", &"service_lift", &"stabilized_return_route"],
		}, true)
	elif room_id == &"HM-11":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_mourning_chapel.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne", &"E1"],
			"portGates": {&"E1": &"mansion_crypt_key_found"},
			"visualProfileIds": [&"mansion_gallery_stage_curtain", &"mansion_gallery_upper_left_frame", &"mansion_gallery_upper_right_frame"],
			"featureIds": [&"stained_glass_alignment", &"anti_curse_accessory", &"nursery_latch"],
			"chapterInteractions": [{"nodeName": "ChapelGlass", "kind": &"chapel_alignment", "cell": Vector2i(11, 7)}],
		}, true)
	elif room_id == &"HM-12":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_undercroft.tscn",
			"worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"],
			"visualProfileIds": [&"mansion_archive_wall_plain_tile", &"mansion_archive_wall_lit_tile", &"mansion_gallery_stage_curtain"],
			"featureIds": [&"temporal_field_note", &"anchor_dust_payoff", &"infernal_elite", &"two_sided_exit"],
		}, true)
	elif room_id == &"HM-13":
		definition.merge({
			"scenePath": "res://ben_rpg/world/rooms/haunted_mansion_dollmaker_attic.tscn", "worldOrigin": Vector2i(300, 0),
			"enabledPortIds": [&"Nw", &"Ne"], "portGates": {&"Ne": &"mansion_attic_latch_open"},
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
	_validate_manifest_test_rooms(errors)
	return PackedStringArray(errors)


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
