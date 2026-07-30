"""Regression tests for the release/source-library boundary."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import validate_release_source_references as validator  # noqa: E402


class ReleaseSourceReferenceTests(unittest.TestCase):
    def test_runtime_game_assets_are_allowed(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "game/ben_rpg/world/area.gd"
            path.parent.mkdir(parents=True)
            path.write_text('const TILE = "res://game_assets/Tilesets/Approved/ground.png"\n', encoding="utf-8")
            self.assertEqual(validator.violations(root), [])

    def test_staging_roots_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "game/ben_rpg/world/area.gd"
            path.parent.mkdir(parents=True)
            path.write_text('const TILE = "../assets/EXPANSION/candidate.png"\n', encoding="utf-8")
            self.assertEqual(len(validator.violations(root)), 1)

    def test_unreviewed_recruit_drop_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "game/ben_rpg/world/area.gd"
            path.parent.mkdir(parents=True)
            path.write_text('const ACTOR = "../assets/characters/Recruitable Characters/Abe_Lincoln/rotations/south.png"\n', encoding="utf-8")
            self.assertEqual(len(validator.violations(root)), 1)

    def test_derived_metadata_can_record_its_source_provenance(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "game/ben_rpg/visual_assets/derived/ashfall_prop.metadata.json"
            path.parent.mkdir(parents=True)
            path.write_text('{"source": {"path": "assets/Tilesets/Ashlands Tileset/1x/source.png"}}\n', encoding="utf-8")
            self.assertEqual(validator.violations(root), [])

    def test_other_visual_json_cannot_point_to_staging(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "game/ben_rpg/visual_assets/visual_profiles.json"
            path.parent.mkdir(parents=True)
            path.write_text('{"runtimeTexture": "assets/Tilesets/Ashlands Tileset/1x/source.png"}\n', encoding="utf-8")
            self.assertEqual(len(validator.violations(root)), 1)


if __name__ == "__main__":
    unittest.main()
