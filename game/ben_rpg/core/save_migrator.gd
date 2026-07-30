class_name SaveMigrator
extends RefCounted

## CampaignState owns field defaults while this class owns the ordered version
## contract. Keeping the chain explicit makes future schema bumps auditable and
## prevents a load path from silently accepting a version with no migration.

const CURRENT_VERSION := 21
const FIRST_SUPPORTED_VERSION := 1
const MANIFEST_SAVE_LOCATION_MIGRATOR := preload("res://ben_rpg/world/campaign_manifest_save_location_migrator.gd")


static func can_migrate(version: int) -> bool:
	return version >= FIRST_SUPPORTED_VERSION and version <= CURRENT_VERSION


static func migrate(source: Dictionary) -> Dictionary:
	var source_version := int(source.get("version", 0))
	if not can_migrate(source_version):
		return {"ok": false, "error": ERR_FILE_CORRUPT, "source_version": source_version, "steps": PackedInt32Array()}
	var migrated := source.duplicate(true)
	var steps := PackedInt32Array()
	var version := source_version
	while version < CURRENT_VERSION:
		if not has_step(version):
			return {"ok": false, "error": ERR_FILE_CORRUPT, "source_version": source_version, "steps": steps}
		migrated = _apply_step(version, migrated)
		steps.append(version)
		version += 1
	migrated["version"] = CURRENT_VERSION
	return {"ok": true, "error": OK, "data": migrated, "source_version": source_version, "steps": steps}


static func has_step(version: int) -> bool:
	return version >= FIRST_SUPPORTED_VERSION and version < CURRENT_VERSION


static func _apply_step(version: int, payload: Dictionary) -> Dictionary:
	# All pre-v18 fields are normalized by CampaignState's typed deserializer.
	# These named boundaries intentionally remain here so any future migration
	# must be inserted into the sequence instead of becoming an implicit load
	# side effect scattered across the state facade.
	match version:
		1, 2, 3, 4, 5, 6, 7, 8, 9, 10:
			return payload
		11:
			# v11 introduced explicit universe anchors; CampaignState rebuilds them
			# from legacy facility placements after this migration completes.
			return payload
		12, 13, 14, 15, 16, 17, 18:
			return payload
		19:
			return MANIFEST_SAVE_LOCATION_MIGRATOR.migrate(payload)
		20:
			# The typed state facade adds Lincoln and Gandhi to existing campaigns
			# without replacing the player's active legacy formation.
			return payload
	return payload
