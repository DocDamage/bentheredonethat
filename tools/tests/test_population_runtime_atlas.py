"""Contracts for the tracked 258-identity population field atlas."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_population_runtime_atlas as atlas  # noqa: E402


ROOT = Path(__file__).resolve().parents[2]


class PopulationRuntimeAtlasTests(unittest.TestCase):
    def test_checked_in_atlas_has_unique_eight_direction_profiles(self) -> None:
        atlas_path = ROOT / "game/ben_rpg/population/generated/population_field_atlas.png"
        payload = json.loads((ROOT / "game/ben_rpg/population/generated/population_visual_profiles.json").read_text(encoding="utf-8"))
        atlas.validate(payload, atlas_path)
        self.assertEqual(len({profile["id"] for profile in payload["profiles"]}), 258)
        self.assertTrue(all(set(profile["directions"]) == set(atlas.DIRECTIONS) for profile in payload["profiles"]))

    def test_population_registry_binds_every_visual_profile_once(self) -> None:
        registry = json.loads((ROOT / "game/ben_rpg/population/generated/population_registry.json").read_text(encoding="utf-8"))
        runtime_ids = [identity["runtimeProfileId"] for identity in registry["identities"]]
        self.assertEqual(len(runtime_ids), 258)
        self.assertEqual(len(set(runtime_ids)), 258)
        self.assertNotIn(None, runtime_ids)


if __name__ == "__main__":
    unittest.main()
