"""Regression coverage for local-only vertical-slice review-sheet generation."""

from __future__ import annotations

import io
import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_vertical_slice_contact_sheets as sheets  # noqa: E402


class VerticalSliceContactSheetTests(unittest.TestCase):
    def test_build_records_native_environment_and_eight_direction_population_sources(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            environment = root / "assets/Tilesets/Test Pack/source.png"
            environment.parent.mkdir(parents=True)
            Image.new("RGBA", (3, 2), (10, 20, 30, 255)).save(environment)
            source_root = root / "assets/characters/SakPix"
            rotations = source_root / "Test Collection/Identity/rotations"
            rotations.mkdir(parents=True)
            for direction in sheets.DIRECTIONS:
                Image.new("RGBA", (2, 3), (40, 50, 60, 255)).save(rotations / f"{direction}.png")
            registry = root / "game/ben_rpg/population/generated/population_registry.json"
            registry.parent.mkdir(parents=True)
            registry.write_text(json.dumps({"identities": [{
                "id": "sakpix:test", "canonicalHome": "HM-01",
                "sourceIdentity": {"collection": "Test Collection", "folder": "Identity"},
            }]}), encoding="utf-8")
            config = root / "config.json"
            config.write_text(json.dumps({"schemaVersion": 1, "worlds": [{
                "id": "mansion", "roomPrefix": "HM-", "environmentSourceGlobs": ["assets/Tilesets/Test Pack/*.png"],
            }]}), encoding="utf-8")

            expected, manifest = sheets.build(root, source_root, config)

            self.assertEqual(set(expected), {"mansion-environment.png", "mansion-population.png", "vertical_slice_contact_sheets.json"})
            self.assertEqual(manifest["worlds"][0]["environmentSources"][0]["dimensions"], [3, 2])
            self.assertEqual(len(manifest["worlds"][0]["populationIdentities"][0]["rotations"]), 8)
            with Image.open(io.BytesIO(expected["mansion-environment.png"])) as rendered:
                self.assertGreaterEqual(rendered.width, 3)
                self.assertGreaterEqual(rendered.height, 2)


if __name__ == "__main__":
    unittest.main()
