class_name EconomyLedger
extends RefCounted

## Durable, append-only accounting helpers for campaign economy mutations.
## CampaignState owns the saved transaction array; this small service keeps the
## receipt format and report calculations independent of UI and game scenes.

const MAX_RECORDS := 512


static func record(entries: Array[Dictionary], reason_id: StringName, chapter: StringName, currency_or_item: StringName, delta: int, source_context: StringName = &"", timestamp := 0) -> Dictionary:
	if delta == 0:
		return {}
	var entry := {
		"reason_id": reason_id,
		"chapter": chapter,
		"currency_or_item": currency_or_item,
		"delta": delta,
		"source_context": source_context,
		"timestamp": timestamp,
	}
	entries.append(entry)
	if entries.size() > MAX_RECORDS:
		entries.pop_front()
	return entry.duplicate(true)


static func normalize_entries(raw_entries: Array) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for raw_entry in raw_entries:
		if not raw_entry is Dictionary:
			continue
		var delta := int(raw_entry.get("delta", 0))
		if delta == 0:
			continue
		normalized.append({
			"reason_id": StringName(raw_entry.get("reason_id", "legacy")),
			"chapter": StringName(raw_entry.get("chapter", "unknown")),
			"currency_or_item": StringName(raw_entry.get("currency_or_item", "duckets")),
			"delta": delta,
			"source_context": StringName(raw_entry.get("source_context", "")),
			"timestamp": int(raw_entry.get("timestamp", 0)),
		})
	if normalized.size() > MAX_RECORDS:
		normalized = normalized.slice(normalized.size() - MAX_RECORDS)
	return normalized


static func report(entries: Array[Dictionary], current_duckets: int) -> Dictionary:
	var earned := 0
	var spent := 0
	var by_chapter := {}
	var by_reason := {}
	var item_sources := {}
	for entry in entries:
		var currency_or_item := StringName(entry.get("currency_or_item", &"duckets"))
		var delta := int(entry.get("delta", 0))
		var chapter := StringName(entry.get("chapter", &"unknown"))
		var reason := StringName(entry.get("reason_id", &"legacy"))
		if currency_or_item == &"duckets":
			if delta > 0:
				earned += delta
			else:
				spent += -delta
		if not by_chapter.has(chapter):
			by_chapter[chapter] = {"earned": 0, "spent": 0, "net": 0}
		if currency_or_item == &"duckets":
			var chapter_total: Dictionary = by_chapter[chapter]
			chapter_total["earned"] = int(chapter_total["earned"]) + maxi(delta, 0)
			chapter_total["spent"] = int(chapter_total["spent"]) + maxi(-delta, 0)
			chapter_total["net"] = int(chapter_total["net"]) + delta
		if not by_reason.has(reason):
			by_reason[reason] = {"count": 0, "duckets": 0, "items": {}}
		var reason_total: Dictionary = by_reason[reason]
		reason_total["count"] = int(reason_total["count"]) + 1
		if currency_or_item == &"duckets":
			reason_total["duckets"] = int(reason_total["duckets"]) + delta
		else:
			var reason_items: Dictionary = reason_total["items"]
			reason_items[currency_or_item] = int(reason_items.get(currency_or_item, 0)) + delta
			item_sources[currency_or_item] = int(item_sources.get(currency_or_item, 0)) + delta
	return {
		"transactions": entries.size(),
		"duckets_earned": earned,
		"duckets_spent": spent,
		"duckets_net": earned - spent,
		"duckets_held": current_duckets,
		"by_chapter": by_chapter,
		"by_reason": by_reason,
		"item_net": item_sources,
	}
