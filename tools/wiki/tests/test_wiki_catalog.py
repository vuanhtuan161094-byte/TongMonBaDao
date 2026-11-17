from __future__ import annotations

import copy
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "wiki"))
import build_wiki_catalog as builder


class WikiCatalogTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.catalog = builder.build_catalog(ROOT)

    def test_taxonomy_and_skill_ids_are_complete_and_unique(self) -> None:
        self.assertEqual(12, len(self.catalog["schools"]))
        self.assertEqual(36, len(self.catalog["branches"]))
        self.assertEqual(2196, self.catalog["counts"]["skillInputRecords"])
        self.assertEqual(2196, self.catalog["counts"]["skillIdsUnique"])
        self.assertEqual([], self.catalog["dataQuality"]["duplicateSkillIds"])
        self.assertEqual(420, self.catalog["counts"]["skillFamilies"])

    def test_source_sha_normalizes_text_line_endings(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            lf = Path(directory) / "source.gd"
            crlf = Path(directory) / "source-copy.gd"
            lf.write_bytes(b"line one\nline two\n")
            crlf.write_bytes(b"line one\r\nline two\r\n")
            self.assertEqual(builder.sha256(lf), builder.sha256(crlf))

    def test_source_sync_reports_first_structural_difference(self) -> None:
        difference = builder.first_difference({"a": [1, {"b": 2}]}, {"a": [1, {"b": 3}]})
        self.assertEqual(("$.a[1].b", 2, 3), difference)

    def test_json_serialization_and_numeric_formatting_do_not_change_projection_data(self) -> None:
        expected = {"schools": ["poison"], "count": 12, "zero": 0}
        actual = json.loads('{ "schools" : [ "poison" ], "count" : 12.0, "zero": 0.0 }')
        self.assertIsNone(builder.first_difference(expected, actual))
        self.assertEqual(("$.value", True, 1), builder.first_difference({"value": True}, {"value": 1}))

    def test_v63_is_not_reported_as_live(self) -> None:
        self.assertEqual(0, self.catalog["counts"]["v63Enabled"])
        self.assertTrue(all(skill["runtimeStatus"] == "GATED_OFF" for skill in self.catalog["skills"]))
        self.assertTrue(all(technique["runtimeStatus"] == "GATED_OFF" for technique in self.catalog["techniques"]))
        self.assertTrue(all(not technique["combatEffectsEnabled"] for technique in self.catalog["techniques"]))
        v63_gap = next(gap for gap in self.catalog["gaps"] if gap["id"] == "GAP-V63-OFF")
        self.assertEqual("STATUS_ONLY", v63_gap["severity"])
        self.assertEqual("EXPECTED_GATED_OFF_NO_FIX_REQUESTED", v63_gap["status"])

    def test_medicine_identity_does_not_claim_recipe_availability(self) -> None:
        self.assertEqual(476, len(self.catalog["medicine"]))
        self.assertEqual(8, self.catalog["counts"]["authoredMedicineRecipes"])
        self.assertEqual(2, self.catalog["counts"]["legacyMedicineRecipes"])
        self.assertEqual(10, self.catalog["counts"]["medicineRuntimeRecipeDefinitions"])
        self.assertTrue(any(item["craftability"] == "IDENTITY_ONLY_NO_AUTHORED_RECIPE" for item in self.catalog["medicine"]))

    def test_every_catalog_record_has_traceability_and_exact_source_hash(self) -> None:
        for collection in ("schools", "branches", "skills", "techniques", "realms", "medicine", "medicineRecipes", "equipmentRecipes", "resources"):
            for row in self.catalog[collection]:
                self.assertTrue(row["id"], f"missing ID in {collection}")
                self.assertTrue(row["sourcePath"], f"missing sourcePath in {collection}/{row.get('id')}")
                self.assertEqual(builder.sha256(ROOT / row["sourcePath"]), row["sourceSha"], row["sourcePath"])
                self.assertIn("runtimeStatus", row)
                self.assertIn("qaEvidence", row)
                self.assertIn("status", row["qaEvidence"])

    def test_ci_source_sha_override_is_validated(self) -> None:
        expected = "a" * 40
        with patch.dict(os.environ, {"TMB_WIKI_SOURCE_SHA": expected}):
            self.assertEqual(expected, builder.commit_sha(ROOT))
        with patch.dict(os.environ, {"TMB_WIKI_SOURCE_SHA": "not-a-sha"}):
            self.assertNotEqual("not-a-sha", builder.commit_sha(ROOT))

    def test_catalog_generation_is_deterministic(self) -> None:
        first = json.dumps(builder.build_catalog(ROOT), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        second = json.dumps(builder.build_catalog(ROOT), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        self.assertEqual(first, second)

    def test_invalid_schema_duplicate_id_and_source_hash_are_rejected(self) -> None:
        invalid = copy.deepcopy(self.catalog)
        invalid["schemaVersion"] = 99
        invalid["schools"].append(copy.deepcopy(invalid["schools"][0]))
        invalid["skills"][0]["sourceSha"] = "0" * 64
        errors = builder.validate_catalog(invalid, ROOT)
        self.assertTrue(any("schemaVersion" in error for error in errors))
        self.assertTrue(any("duplicate id" in error for error in errors))
        self.assertTrue(any("source SHA mismatch" in error for error in errors))

    def test_real_vfx_manifest_availability_is_not_invented(self) -> None:
        manifest_path = ROOT / "godot/data/presentation/v63_combat_vfx_manifest.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        self.assertEqual(0, len(manifest.get("asset_files", [])))
        self.assertEqual(0, self.catalog["vfx"][0]["assetFileCount"])
        self.assertEqual("NOT_CAPTURED", self.catalog["presentationManifest"]["renderCaptureStatus"])
        self.assertEqual("PENDING", self.catalog["presentationManifest"]["guiAcceptanceStatus"])

    def test_one_way_sync_targets_generated_files_only(self) -> None:
        source = (ROOT / "tools/wiki/build_wiki_catalog.py").read_text(encoding="utf-8")
        self.assertIn('root / "wiki/data/catalog.json"', source)
        self.assertIn('root / "docs/wiki/TMB_WIKI_SOURCE_AUDIT.md"', source)
        self.assertNotIn("SimulationState", source)
        self.assertNotIn("SaveService", source)

    def test_local_json_imports_are_versioned_non_overwriting_and_atomic(self) -> None:
        app = (ROOT / "wiki/app.js").read_text(encoding="utf-8")
        self.assertIn("schemaVersion:1", app)
        self.assertIn("if(known.has(row.localId)) continue;", app)
        self.assertIn("state.statusFilter==='GATED_OFF'?'selected':''", app)
        self.assertIn("function persistImportedBundles(updates)", app)
        self.assertIn("onlyKind==='changeRequests'&&!Array.isArray(data.changeRequests)", app)
        self.assertIn("onlyKind==='proposals'&&!Array.isArray(data.proposals)", app)
        self.assertIn("persistImportedBundles(updates)", app)


    def test_windows_launchers_resolve_user_installed_python(self) -> None:
        for name in ("OPEN_TANG_KINH_CAC.cmd", "SYNC_WIKI_SOURCE.cmd"):
            launcher = (ROOT / "tools/wiki" / name).read_text(encoding="utf-8")
            self.assertIn("%LOCALAPPDATA%\\Programs\\Python\\Python*", launcher)
            self.assertIn("goto UsePython", launcher)

    def test_dashboard_uses_short_tooltipped_labels_for_long_statuses(self) -> None:
        app = (ROOT / "wiki/app.js").read_text(encoding="utf-8")
        self.assertIn("NOT_IN_RELEASE_SCOPE_WHILE_GATE_OFF: 'Ngoài phạm vi<br>(gate OFF)'", app)
        self.assertIn("AUTHORITY_DIVERGENCE: 'Chờ quyết định'", app)
        self.assertIn('title="${esc(raw)}"', app)

    def test_dashboard_long_status_values_wrap_in_fixed_viewports(self) -> None:
        css = (ROOT / "wiki/styles.css").read_text(encoding="utf-8")
        self.assertRegex(css, r"\.system-num\{[^}]*overflow-wrap:anywhere")

    def test_local_server_never_attaches_to_an_existing_port(self) -> None:
        server = (ROOT / "tools/wiki/serve_wiki.py").read_text(encoding="utf-8")
        self.assertIn('HOST = "127.0.0.1"', server)
        self.assertIn("def bind_loopback(start_port: int)", server)
        self.assertIn("range(start_port, min(start_port + PORT_FALLBACK_COUNT, 65536))", server)
        self.assertIn('parser.add_argument("--no-open"', server)

if __name__ == "__main__":
    unittest.main(verbosity=2)

