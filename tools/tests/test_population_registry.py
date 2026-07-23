"""Contract coverage for the generated population registry."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_population_registry as registry  # noqa: E402


ROOT = Path(__file__).resolve().parents[2]


class PopulationRegistryTests(unittest.TestCase):
    def test_clean_checkout_registry_has_every_planned_identity(self) -> None:
        payload = registry.build(ROOT)
        self.assertEqual(len(payload["identities"]), 267)
        self.assertTrue(all(item["sourceRotationState"] == "unverified" for item in payload["identities"]))

    def test_checked_in_registry_is_clean_checkout_reproducible(self) -> None:
        actual = json.loads((ROOT / "game/ben_rpg/population/generated/population_registry.json").read_text(encoding="utf-8"))
        registry.validate(actual, source_verified=None)
        self.assertEqual(registry.plan_contract(actual), registry.plan_contract(registry.build(ROOT)))


if __name__ == "__main__":
    unittest.main()
