class_name TownBuildSelection
extends RefCounted

## Pure facility-build selection rules.  UI input and HUD presentation remain
## in TownBuildController; this component only derives deterministic choices
## from campaign state.

const FACILITY_ORDER := [&"Cafe", &"Library", &"Clinic", &"Armory"]


static func next_available_plot(current_plot: int, direction: int, plot_count: int, built_facilities: Dictionary) -> int:
	if plot_count <= 0:
		return 0
	for _attempt in range(plot_count):
		current_plot = wrapi(current_plot + direction, 0, plot_count)
		if not built_facilities.has(current_plot):
			return current_plot
	return current_plot


static func next_foundation_blueprint(built_facilities: Dictionary) -> String:
	for facility_name in FACILITY_ORDER:
		if facility_name not in built_facilities.values():
			return String(facility_name)
	return ""


static func founding_facility_count(built_facilities: Dictionary) -> int:
	var count := 0
	for facility_name in FACILITY_ORDER:
		if facility_name in built_facilities.values():
			count += 1
	return count
