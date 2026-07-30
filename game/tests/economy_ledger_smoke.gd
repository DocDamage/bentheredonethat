extends Node

const TEST_SAVE := "user://economy_ledger_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(3, "Armory")
	CampaignState.duckets = 300
	var starting_duckets := CampaignState.duckets

	if not CampaignState.purchase_service_item("Cafe", &"tonic"):
		_fail("Service purchase was unavailable for ledger coverage")
		return
	var gear := CampaignState.purchase_armory_item(&"militia_saber")
	if gear.is_empty():
		_fail("Armory purchase was unavailable for ledger coverage")
		return
	if CampaignState.sell_loot(String(gear.get("instance_id", ""))) <= 0:
		_fail("Armory sale was unavailable for ledger coverage")
		return
	if not CampaignState.craft_invention(&"serving_automaton"):
		_fail("Invention craft was unavailable for ledger coverage")
		return
	CampaignState.apply_battle_victory(18, 31, [{"kind": "consumable", "id": &"ether", "quantity": 2}])

	var report := CampaignState.economy_report()
	var reasons: Dictionary = report.get("by_reason", {})
	for reason_id in [&"service_purchase", &"armory_purchase", &"armory_sale", &"invention_craft", &"battle_victory"]:
		if not reasons.has(reason_id):
			_fail("Missing economy receipt for %s" % reason_id)
			return
	if int(report.get("duckets_net", 0)) != CampaignState.duckets - starting_duckets:
		_fail("Ledger net did not reconcile with the live Ducket balance")
		return
	var item_net: Dictionary = report.get("item_net", {})
	if int(item_net.get(&"tonic", 0)) < 1 or int(item_net.get(&"ether", 0)) < 2:
		_fail("Item receipts did not retain service and battle sources")
		return
	if int(report.get("transactions", 0)) < 7:
		_fail("Ledger did not retain the expected currency and item receipts")
		return

	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Ledger state could not be saved")
		return
	var expected_report := CampaignState.economy_report()
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Ledger state could not be loaded")
		return
	var restored := CampaignState.economy_report()
	if int(restored.get("transactions", 0)) != int(expected_report.get("transactions", 0)) or int(restored.get("duckets_net", 0)) != int(expected_report.get("duckets_net", 0)):
		_fail("Ledger receipt history did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("ECONOMY_LEDGER_SMOKE_OK receipts=currency+items report=reconciled persistence=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ECONOMY_LEDGER_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
