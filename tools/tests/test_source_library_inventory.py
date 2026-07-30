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
    @staticmethod
    def _write_plan(root: Path, rows: list[tuple[str, str, str]]) -> None:
        lines = [
            "#### Complete `assets/Tilesets` disposition register",
            "| Top-level pack | Files / images | Disposition | Locked destination or reason |",
        ]
        lines.extend(f"| `{name}` | 1 / 1 | {disposition} | {destination} |" for name, disposition, destination in rows)
        lines.append("#### Required showcase-sheet bindings")
        (root / "FFVI_ALIGNMENT_COMPLETION_PLAN.md").write_text("\n".join(lines), encoding="utf-8")

    def test_inventory_records_dimensions_duplicates_and_demo_exclusions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            tilesets = root / "assets/Tilesets"
            expansion = root / "assets/EXPANSION"
            (tilesets / "Approved").mkdir(parents=True)
            (expansion / "Demo").mkdir(parents=True)
            self._write_plan(root, [("Approved", "Core-P", "Test world")])
            Image.new("RGBA", (16, 24), (255, 255, 255, 255)).save(tilesets / "Approved/tile.png")
            (expansion / "Demo/tile-copy.png").write_bytes((tilesets / "Approved/tile.png").read_bytes())
            (expansion / "Demo/game.exe").write_bytes(b"not executable")
            result = inventory.build(root, tilesets, expansion)
            self.assertEqual(result["summary"]["packs"], 2)
            self.assertEqual(result["summary"]["exactDuplicateFamilies"], 1)
            pack = result["libraries"][0]["packs"][0]
            self.assertEqual(pack["disposition"], "core_primary")
            self.assertEqual(pack["plannedDestination"], "Test world")
            self.assertEqual(pack["rasterDimensionCounts"], {"16x24": 1})
            demo_pack = result["libraries"][1]["packs"][0]
            self.assertIn("Demo/game.exe", demo_pack["engineDemoExclusions"])

    def test_inventory_rejects_unclassified_or_stale_tileset_registers(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            tilesets = root / "assets/Tilesets"
            expansion = root / "assets/EXPANSION"
            (tilesets / "Actual").mkdir(parents=True)
            expansion.mkdir(parents=True)
            self._write_plan(root, [("Stale", "Core-S", "Somewhere")])
            with self.assertRaisesRegex(ValueError, "does not match source library"):
                inventory.build(root, tilesets, expansion)


if __name__ == "__main__":
    unittest.main()
