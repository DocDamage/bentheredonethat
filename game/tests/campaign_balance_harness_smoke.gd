extends Node

const BALANCE_HARNESS := preload("res://ben_rpg/core/campaign_balance_harness.gd")


func _ready() -> void:
	var report := BALANCE_HARNESS.run_suite(100)
	assert((report.get("source_errors", []) as Array).is_empty(), "Every required invention material needs two authored no-job sources")
	assert((report.get("failures", []) as Array).is_empty(), "Low, median, high, missed-treasure, no-job, and heavy-job routes must not softlock")
	assert(bool(report.get("passed", false)), "Balance harness must report a passing campaign route")
	var profiles: Dictionary = report.get("profiles", {})
	for profile_id in [&"low_combat", &"median_combat", &"high_combat", &"missed_treasure", &"no_job", &"heavy_job"]:
		var profile: Dictionary = profiles.get(profile_id, {})
		assert(int(profile.get("runs", 0)) == 100 and int(profile.get("passed", 0)) == 100, "%s did not finish all seeded runs" % profile_id)
		var chapters: Dictionary = profile.get("chapters", {})
		assert(chapters.has(&"primeval") and chapters.has(&"empyreal"), "%s omitted chapter balance metrics" % profile_id)
	print("CAMPAIGN_BALANCE_HARNESS_SMOKE_OK profiles=6 seeded_runs=600 no_job=true missed_treasure=true material_sources=two")
	get_tree().quit(0)
