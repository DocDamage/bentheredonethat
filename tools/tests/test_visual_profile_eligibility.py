"""Regression coverage for profile-level distribution eligibility."""

from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_godot_visual_manifest as manifest  # noqa: E402


class VisualProfileEligibilityTests(unittest.TestCase):
    def _root_with_profile(self, status: str) -> tuple[tempfile.TemporaryDirectory[str], Path, dict[str, object]]:
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        texture = root / "game/runtime.png"
        texture.parent.mkdir(parents=True)
        Image.new("RGBA", (1, 1), (255, 255, 255, 255)).save(texture)
        checksum = hashlib.sha256(texture.read_bytes()).hexdigest()
        golden = root / "golden.png"
        Image.new("RGBA", (1, 1), (255, 255, 255, 255)).save(golden)
        provenance = root / "game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json"
        provenance.parent.mkdir(parents=True)
        provenance.write_text(json.dumps({"assets": [{"path": "res://runtime.png", "distributionEligibility": status}]}), encoding="utf-8")
        raw = {
            "schemaVersion": 2,
            "profiles": [{
                "id": "test_profile",
                "kind": "tile",
                "source": {
                    "pack": "test",
                    "runtimeTexture": "game/runtime.png",
                    "sourceChecksum": checksum,
                    "sourceDensity": 1,
                    "region": [0, 0, 1, 1],
                    "alphaBounds": [0, 0, 1, 1],
                },
                "placement": {"footAnchor": [0, 0], "scaleClass": "tile", "collisionFootprint": "test"},
                "worldDrawSize": [1, 1],
                "licenseReference": "game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json",
                "cropApproval": "approved",
                "goldenCapture": "golden.png",
            }],
        }
        return temporary, root, raw

    def test_review_required_source_is_retained_in_manifest(self) -> None:
        temporary, root, raw = self._root_with_profile("review_required")
        with temporary:
            result = manifest.validate(root, raw)
        self.assertEqual(result["profiles"][0]["distributionEligibility"], "review_required")
        self.assertEqual(result["profiles"][0]["releaseVisualAcceptance"], "prototype_only")

    def test_review_required_source_cannot_receive_final_visual_acceptance(self) -> None:
        temporary, root, raw = self._root_with_profile("review_required")
        raw["profiles"][0]["releaseVisualAcceptance"] = "final_approved"
        with temporary:
            with self.assertRaisesRegex(ValueError, "cannot receive final visual acceptance"):
                manifest.validate(root, raw)

    def test_confirmed_source_can_receive_final_visual_acceptance(self) -> None:
        temporary, root, raw = self._root_with_profile("distribution_confirmed")
        raw["profiles"][0]["releaseVisualAcceptance"] = "final_approved"
        with temporary:
            result = manifest.validate(root, raw)
        self.assertEqual(result["profiles"][0]["releaseVisualAcceptance"], "final_approved")

    def test_rejected_source_cannot_generate_runtime_manifest(self) -> None:
        temporary, root, raw = self._root_with_profile("rejected")
        with temporary:
            with self.assertRaisesRegex(ValueError, "cannot use rejected source"):
                manifest.validate(root, raw)


if __name__ == "__main__":
    unittest.main()
