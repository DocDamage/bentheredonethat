import json
import unittest
from pathlib import Path

from tools.build_release_asset_provenance import ROOT, build


class ReleaseCandidateContractTests(unittest.TestCase):
    def setUp(self):
        self.contract = json.loads((ROOT / "game/ben_rpg/release/release_contract.json").read_text(encoding="utf-8"))

    def test_locked_scope_and_release_decisions(self):
        lock = self.contract["contentLock"]
        self.assertEqual(lock["coreLocations"] + lock["annexLocations"], lock["locations"])
        self.assertEqual(lock["locations"], 192)
        self.assertEqual(lock["facilityPlacements"], 121)
        self.assertEqual(lock["populationIdentities"], 258)
        self.assertGreaterEqual(lock["baselineCaptures"], lock["locations"] * 2)
        product = self.contract["product"]
        self.assertEqual(product["platforms"], ["windows-x86_64"])
        self.assertTrue(product["publisher"] and product["shippingVersion"])
        self.assertTrue(self.contract["signing"]["signedPublicReleaseRequired"])

    def test_project_and_export_metadata_match_contract(self):
        version = self.contract["product"]["shippingVersion"]
        project = (ROOT / "game/project.godot").read_text(encoding="utf-8")
        export = (ROOT / "game/export_presets.cfg").read_text(encoding="utf-8")
        self.assertIn(f'config/version="{version}"', project)
        self.assertIn(f'application/product_version="{version}"', export)
        self.assertIn(f'application/file_version="{version}.0"', export)
        self.assertIn(f'application/company_name="{self.contract["product"]["publisher"]}"', export)

    def test_release_provenance_is_complete_and_reproducible(self):
        generated = json.loads((ROOT / "game/ben_rpg/release/generated/release_asset_provenance.json").read_text(encoding="utf-8"))
        self.assertEqual(generated, build())
        self.assertEqual(set(generated["summary"]["byCategory"]), {"addon", "audio", "dynamic_resource", "font", "notice", "shader"})
        self.assertTrue(all(entry["distributionEligibility"] == "distribution_confirmed" for entry in generated["assets"]))
        self.assertTrue(all(entry["licenseEvidence"] for entry in generated["assets"]))

if __name__ == "__main__":
    unittest.main()
