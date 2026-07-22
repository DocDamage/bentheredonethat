"""Regression coverage for foreground renderers that have finished profile migration."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROFILE_PATH = ROOT / "game/ben_rpg/visual_assets/visual_profiles.json"
MAP_VISUAL = ROOT / "game/ben_rpg/world/campaign_map_visual.gd"
RENDERERS = [
    ROOT / "game/ben_rpg/world/campaign_asterion_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_empyreal_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_frosthold_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_mansion_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_primeval_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_moonpetal_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_town_foreground.gd",
]


class ProfiledForegroundRendererTests(unittest.TestCase):
    def test_completed_renderers_use_only_registered_profiles(self) -> None:
        profile_ids = {profile["id"] for profile in json.loads(PROFILE_PATH.read_text(encoding="utf-8"))["profiles"]}
        for renderer_path in RENDERERS:
            source = renderer_path.read_text(encoding="utf-8")
            self.assertNotIn("func _prop(", source, renderer_path.name)
            used_ids = re.findall(r'_profile_(?:prop|tile)\(&"([^"]+)"', source)
            self.assertTrue(used_ids, renderer_path.name)
            self.assertTrue(set(used_ids) <= profile_ids, renderer_path.name)

    def test_profiled_map_shells_do_not_restore_raw_atlas_slices(self) -> None:
        source = MAP_VISUAL.read_text(encoding="utf-8")
        self.assertNotIn("empyreal_slices", source)
        self.assertNotIn("func draw_empyreal_court", source)
        self.assertNotIn('load("res://game_assets/Tilesets/Ancient Greek Mythology/Sliced/', source)
        self.assertNotIn("Rect2(54, 686, 306, 114)", source)
        self.assertNotIn("plain_tiles", source)
        self.assertNotIn("showcase_tile", source)
        profile_ids = {profile["id"] for profile in json.loads(PROFILE_PATH.read_text(encoding="utf-8"))["profiles"]}
        used_ids = re.findall(r'profile_tile\(&"(empyreal_[^"]+)"', source)
        self.assertTrue(used_ids)
        self.assertTrue(set(used_ids) <= profile_ids)


if __name__ == "__main__":
    unittest.main()
