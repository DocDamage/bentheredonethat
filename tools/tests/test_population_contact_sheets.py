"""Regression coverage for local SakPix contact-sheet generation."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_population_contact_sheets as sheets  # noqa: E402


class PopulationContactSheetTests(unittest.TestCase):
    def _identity(self, root: Path, collection: str, folder: str, missing: set[str] | None = None) -> None:
        missing = missing or set()
        rotations = root / collection / folder / "rotations"
        rotations.mkdir(parents=True)
        for index, direction in enumerate(sheets.DIRECTIONS):
            if direction not in missing:
                Image.new("RGBA", (3 + index, 5 + index), (index * 20, 80, 160, 255)).save(rotations / f"{direction}.png")

    def test_collection_preserves_native_frames_and_quarantines_incomplete_identities(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self._identity(root, "Test Collection", "complete")
            self._identity(root, "Test Collection", "incomplete", {"east"})
            payload, record = sheets.render_collection("Test Collection", sorted((root / "Test Collection").iterdir()))
            self.assertEqual(record["completeIdentityCount"], 1)
            self.assertEqual(record["quarantined"], [{"folder": "incomplete", "missingRotations": ["east"]}])
            with Image.open(__import__("io").BytesIO(payload)) as sheet:
                self.assertEqual(sheet.size, (248 + 8 * (10 + 16) + 8, 42 + (12 + 16) + 8))

    def test_manifest_is_deterministic_and_contains_review_only_contract(self) -> None:
        rendered = {"Example": (b"png", {"collection": "Example", "completeIdentityCount": 1, "quarantinedIdentityCount": 0, "quarantined": [], "nativeFrameMaximum": [12, 12]})}
        first = sheets.manifest_for(rendered)
        second = sheets.manifest_for(rendered)
        self.assertEqual(first, second)
        manifest = json.loads(first)
        self.assertEqual(manifest["purpose"], "local_review_only")
        self.assertEqual(manifest["sharedFieldGridPixels"], 48)
        self.assertEqual(manifest["collections"][0]["sheet"], "01-example-d029f87e3d.png")


if __name__ == "__main__":
    unittest.main()
