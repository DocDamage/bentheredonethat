"""Regression coverage for the explicit unprofiled-visual migration ledger."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path
import json


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_godot_visual_inventory as inventory  # noqa: E402


class RuntimeVisualInventoryTests(unittest.TestCase):
    def test_unprofiled_sources_have_a_migration_classification(self) -> None:
        root = Path(__file__).resolve().parents[2]
        result = inventory.build(root)
        unprofiled = [entry for entry in result["assets"] if not entry["profileIds"]]
        self.assertTrue(unprofiled)
        self.assertTrue(all(entry.get("unprofiledClassification") in inventory.UNPROFILED_CLASSIFICATIONS for entry in unprofiled))
        self.assertEqual(
            len(unprofiled),
            sum(result["stats"]["unprofiledByClassification"].values()),
        )
        self.assertEqual(result["stats"]["profileRequiredUnprofiledAssetSources"], 10)
        self.assertEqual(result["stats"]["thirdPartyDependencyVisualSources"], 11)
        self.assertEqual(result["stats"]["profileRequiredAssetSources"], 172)
        self.assertEqual(result["stats"]["profileRequiredProfiledAssetSources"], 162)

    def test_known_gap_classes_route_to_their_correct_migration_stream(self) -> None:
        self.assertEqual(
            inventory.unprofiled_classification("res://addons/dialogic/Modules/Clear/clear_textbox.svg"),
            "third_party_addon_ui",
        )
        self.assertEqual(
            inventory.unprofiled_classification("res://game_assets/characters/%s/rotations/west.png"),
            "dynamic_template_visual",
        )
        self.assertEqual(
            inventory.unprofiled_classification("res://combat/battlers/bear/bear.png"),
            "legacy_compatibility_visual",
        )

    def test_company_fallbacks_resolve_through_registered_profile_ids(self) -> None:
        root = Path(__file__).resolve().parents[2]
        combat_source = (root / "game/ben_rpg/combat/campaign_combat_database.gd").read_text(encoding="utf-8")
        menu_source = (root / "game/ben_rpg/ui/campaign_menu.gd").read_text(encoding="utf-8")
        catalog_source = (root / "game/ben_rpg/core/campaign_state.gd").read_text(encoding="utf-8")
        profile_ids = {
            profile["id"]
            for profile in json.loads((root / "game/ben_rpg/visual_assets/visual_profiles.json").read_text(encoding="utf-8"))["profiles"]
        }
        expected = {
            "ben_company_portrait", "fighter_company_portrait", "astronaut_company_portrait",
            "caveman_battle_actor", "crimson_oni_challenger_battle_actor", "rift_jackal_battle_actor",
            "mossback_surveyor_battle_actor", "cobalt_courier_battle_actor", "bulkhead_warden_battle_actor",
            "kitsune_empress_battle_actor", "neon_viper_battle_actor", "archangel_commander_battle_actor",
            "frost_lich_emperor_battle_actor",
        }
        self.assertTrue(expected <= profile_ids)
        self.assertNotIn("%s/rotations/west.png", combat_source)
        self.assertNotIn("%s/rotations/south.png", menu_source)
        self.assertNotIn("PARTY_BATTLE_PROFILES", combat_source)
        self.assertNotIn("CHARACTER_PORTRAIT_PROFILES", menu_source)
        for profile_id in expected:
            self.assertIn(profile_id, catalog_source)


if __name__ == "__main__":
    unittest.main()
