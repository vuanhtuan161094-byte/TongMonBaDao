from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1] / "tools"
sys.path.insert(0, str(TOOLS))
import validate_catalog  # noqa: E402

REPO = Path(__file__).resolve().parents[4]


class CharacterCatalogTests(unittest.TestCase):
    def test_real_catalog_and_assets_validate(self) -> None:
        self.assertEqual([], validate_catalog.validate_catalog(REPO))

    def test_candidate_cannot_claim_animation_or_runtime(self) -> None:
        catalog_path = REPO / validate_catalog.REPO_RELATIVE_CATALOG
        data = json.loads(catalog_path.read_text(encoding="utf-8"))
        data["candidates"][0]["clips"]["walk"] = "VERIFIED"
        with tempfile.TemporaryDirectory() as temporary:
            temp_catalog = Path(temporary) / "catalog.json"
            temp_catalog.write_text(json.dumps(data), encoding="utf-8")
            errors = validate_catalog.validate_catalog(REPO, temp_catalog)
        self.assertTrue(any("authored clip" in error for error in errors))

    def test_bad_hash_is_rejected(self) -> None:
        catalog_path = REPO / validate_catalog.REPO_RELATIVE_CATALOG
        data = json.loads(catalog_path.read_text(encoding="utf-8"))
        data["candidates"][0]["sha256"] = "0" * 64
        with tempfile.TemporaryDirectory() as temporary:
            temp_catalog = Path(temporary) / "catalog.json"
            temp_catalog.write_text(json.dumps(data), encoding="utf-8")
            errors = validate_catalog.validate_catalog(REPO, temp_catalog)
        self.assertTrue(any("SHA-256 mismatch" in error for error in errors))

    def test_missing_locked_master_stays_blocked(self) -> None:
        catalog_path = REPO / validate_catalog.REPO_RELATIVE_CATALOG
        data = json.loads(catalog_path.read_text(encoding="utf-8"))
        self.assertEqual("BLOCKED_SOURCE_ART", data["approved_poison_identity"]["status"])
        self.assertIsNone(data["approved_poison_identity"]["actual_source_path"])

    def test_duplicate_ids_are_rejected(self) -> None:
        catalog_path = REPO / validate_catalog.REPO_RELATIVE_CATALOG
        data = json.loads(catalog_path.read_text(encoding="utf-8"))
        duplicate = copy.deepcopy(data["candidates"][0])
        data["candidates"].append(duplicate)
        with tempfile.TemporaryDirectory() as temporary:
            temp_catalog = Path(temporary) / "catalog.json"
            temp_catalog.write_text(json.dumps(data), encoding="utf-8")
            errors = validate_catalog.validate_catalog(REPO, temp_catalog)
        self.assertTrue(any("duplicate candidate id" in error for error in errors))


    def test_source_a_matrix_keeps_unknown_roles_unassigned(self) -> None:
        matrix_path = REPO / "godot/labs/character_family/source_a_asset_matrix.json"
        matrix = json.loads(matrix_path.read_text(encoding="utf-8"))
        rows = matrix["source_a_actor_packages"]
        self.assertEqual(7, len(rows))
        by_id = {row["asset_id"]: row for row in rows}
        self.assertEqual("BODY_RIG_ROLE_UNKNOWN", by_id["body_1120402"]["classification"])
        self.assertEqual("MONSTER", by_id["v5_sa_monster_1113031_1"]["classification"])
        self.assertEqual("BOSS_SLOT_CANDIDATE", by_id["v5_sa_boss_410041_1"]["classification"])
        self.assertTrue(all(row["runtime_identity"] == "NOT_ASSERTED" for row in rows))

if __name__ == "__main__":
    unittest.main(verbosity=2)

