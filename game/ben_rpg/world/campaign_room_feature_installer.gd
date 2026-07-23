class_name CampaignRoomFeatureInstaller
extends RefCounted

## Installs room-scoped contract nodes underneath an authored room scene. The
## scene chooses this installer; bootstrap never manufactures room features.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const POPULATION_SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const MANSION_SAVE_POINT := preload("res://ben_rpg/world/mansion_save_point.tscn")
const MANSION_CHAPTER_INTERACTION := preload("res://ben_rpg/world/mansion_chapter_interaction.tscn")
const MANSION_BOSS_INTERACTION := preload("res://ben_rpg/world/campaign_mansion_boss_interaction.tscn")


static func install(root: Node2D, room_id: StringName, definition: Dictionary) -> void:
	var interaction_layer := root.get_node_or_null("InteractionLayer") as Node2D
	var actors_layer := root.get_node_or_null("YSortedActorsAndProps") as Node2D
	if interaction_layer:
		var interaction := Node2D.new()
		interaction.name = "ManifestInteraction"
		interaction.set_meta(&"anchor", definition.get("interactionAnchor", &"Icenter"))
		interaction_layer.add_child(interaction)
		for feature_id in definition.get("featureIds", []):
			var feature := Node2D.new()
			feature.name = "Feature_%s" % String(feature_id)
			feature.set_meta(&"feature_id", StringName(feature_id))
			interaction.add_child(feature)
		for chapter_definition in definition.get("chapterInteractions", []):
			var chapter_interaction := MANSION_CHAPTER_INTERACTION.instantiate()
			chapter_interaction.name = String(chapter_definition.get("nodeName", "ManifestChapterInteraction"))
			chapter_interaction.set("interaction_kind", StringName(chapter_definition.get("kind", &"")))
			chapter_interaction.position = Vector2((chapter_definition.get("cell", Vector2i.ZERO) as Vector2i) * 48)
			interaction_layer.add_child(chapter_interaction)
		var boss_definition: Dictionary = definition.get("bossEncounter", {})
		if not boss_definition.is_empty():
			var boss_interaction := MANSION_BOSS_INTERACTION.instantiate()
			boss_interaction.name = String(boss_definition.get("nodeName", "ManifestBoss"))
			boss_interaction.set("encounter_id", StringName(boss_definition.get("encounterId", &"")))
			boss_interaction.set("defeated_flag", StringName(boss_definition.get("defeatedFlag", &"")))
			boss_interaction.position = Vector2((boss_definition.get("cell", Vector2i.ZERO) as Vector2i) * 48)
			interaction_layer.add_child(boss_interaction)
		var save_point_definition: Dictionary = definition.get("savePoint", {})
		if not save_point_definition.is_empty():
			var save_point := MANSION_SAVE_POINT.instantiate()
			var save_point_id := StringName(save_point_definition.get("id", &""))
			var anchor_cell: Vector2i = save_point_definition.get("cell", Vector2i.ZERO)
			save_point.name = String(save_point_definition.get("nodeName", "ManifestSavePoint"))
			save_point.set("save_point_id", save_point_id)
			save_point.set("anchor_name", String(save_point_definition.get("anchorName", "anchor")))
			save_point.position = Vector2(anchor_cell * 48)
			interaction_layer.add_child(save_point)
			var world_origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
			CampaignState.register_runtime_save_point(save_point_id, world_origin + anchor_cell)
		for port in ROOM_REGISTRY.ports(room_id):
			var route := TRANSITION_ROUTER.resolve(room_id, StringName(port.get("id", &"")))
			if route.is_empty():
				continue
			var arrival := Node2D.new()
			arrival.name = "SafeArrival_%s" % route["arrivalPort"]
			arrival.position = Vector2(route["arrivalCell"]) * 48.0
			interaction_layer.add_child(arrival)
	if actors_layer:
		var cohort := Node2D.new()
		cohort.name = "PopulationCohort"
		var population_schedule := POPULATION_SCHEDULER.schedule(room_id, definition)
		cohort.set_meta(&"population_ids", definition.get("populationIds", []))
		cohort.set_meta(&"population_anchors", definition.get("populationAnchors", []))
		cohort.set_meta(&"assignments", population_schedule.get("assignments", []))
		cohort.set_meta(&"unavailable_population_ids", population_schedule.get("unavailable", []))
		actors_layer.add_child(cohort)
