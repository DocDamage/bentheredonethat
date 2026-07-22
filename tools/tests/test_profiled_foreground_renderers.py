"""Regression coverage for foreground renderers that have finished profile migration."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROFILE_PATH = ROOT / "game/ben_rpg/visual_assets/visual_profiles.json"
RENDERERS = [
    ROOT / "game/ben_rpg/world/campaign_asterion_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_frosthold_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_primeval_foreground.gd",
    ROOT / "game/ben_rpg/world/campaign_moonpetal_foreground.gd",
]


class ProfiledForegroundRendererTests(unittest.TestCase):
    def test_completed_renderers_use_only_registered_profiles(self) -> None:
        profile_ids = {profile["id"] for profile in json.loads(PROFILE_PATH.read_text(encoding="utf-8"))["profiles"]}
        for renderer_path in RENDERERS:
            source = renderer_path.read_text(encoding="utf-8")
            self.assertNotIn("func _prop(", source, renderer_path.name)
            used_ids = re.findall(r'_profile_prop\(&"([^"]+)"', source)
            self.assertTrue(used_ids, renderer_path.name)
            self.assertTrue(set(used_ids) <= profile_ids, renderer_path.name)


if __name__ == "__main__":
    unittest.main()
