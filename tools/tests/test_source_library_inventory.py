"""Focused contracts for curator source-library inventory generation."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_source_library_inventory as inventory  # noqa: E402


class SourceLibraryInventoryTests(unittest.TestCase):
    def test_inventory_records_dimensions_duplicates_and_demo_exclusions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            tilesets = root / "assets/Tilesets"
            expansion = root / "assets/EXPANSION"
            (tilesets / "Approved").mkdir(parents=True)
            (expansion / "Demo").mkdir(parents=True)
            Image.new("RGBA", (16, 24), (255, 255, 255, 255)).save(tilesets / "Approved/tile.png")
            (expansion / "Demo/tile-copy.png").write_bytes((tilesets / "Approved/tile.png").read_bytes())
            (expansion / "Demo/game.exe").write_bytes(b"not executable")
            result = inventory.build(root, tilesets, expansion)
            self.assertEqual(result["summary"]["packs"], 2)
            self.assertEqual(result["summary"]["exactDuplicateFamilies"], 1)
            pack = result["libraries"][0]["packs"][0]
            self.assertEqual(pack["rasterDimensionCounts"], {"16x24": 1})
            demo_pack = result["libraries"][1]["packs"][0]
            self.assertIn("Demo/game.exe", demo_pack["engineDemoExclusions"])


if __name__ == "__main__":
    unittest.main()
