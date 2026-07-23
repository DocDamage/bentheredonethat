"""Keep unreviewed local expansion packs outside the curated asset contract."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.validate_curated_asset_catalog import Validator


class CuratedAssetQuarantineTests(unittest.TestCase):
    def test_expansion_tree_is_not_scanned_or_publishable(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            expansion = root / "assets" / "EXPANSION"
            expansion.mkdir(parents=True)
            (expansion / "unreviewed.png").write_bytes(b"not an image")
            validator = Validator(root, {"sources": []})
            validator.scan_files()
            self.assertEqual(validator.actual, {})
            self.assertIsNone(validator.path("assets/EXPANSION/unreviewed.png", "test"))
            self.assertTrue(any(issue.code == "ignored-path-exposed" for issue in validator.issues))

    def test_recruit_drop_is_not_scanned_or_publishable_before_terms_review(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            recruit = root / "assets" / "characters" / "Recruitable Characters" / "Abe_Lincoln"
            recruit.mkdir(parents=True)
            (recruit / "unreviewed.png").write_bytes(b"not an image")
            validator = Validator(root, {"sources": []})
            validator.scan_files()
            self.assertEqual(validator.actual, {})
            self.assertIsNone(validator.path("assets/characters/Recruitable Characters/Abe_Lincoln/unreviewed.png", "test"))
            self.assertTrue(any(issue.code == "ignored-path-exposed" for issue in validator.issues))


if __name__ == "__main__":
    unittest.main()
