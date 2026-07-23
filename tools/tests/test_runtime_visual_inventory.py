"""Regression coverage for the explicit unprofiled-visual migration ledger."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path


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


if __name__ == "__main__":
    unittest.main()
