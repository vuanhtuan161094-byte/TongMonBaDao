from __future__ import annotations

import csv
import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "wiki"))
import build_skill_progress_v2 as builder


class SkillProgressV2Tests(unittest.TestCase):
    def make_root(self, temporary: Path) -> Path:
        root = temporary
        (root / "wiki/data").mkdir(parents=True)
        skill_id = "tmb.skill.fist.test.active_01.human"
        catalog = {
            "schemaVersion": 1, "sourceCommitSha": "a" * 40,
            "counts": {"branches": 1},
            "schools": [{"id": "fist", "name": "Quyền Tu"}],
            "branches": [{"id": "tmb.branch.fist.ba_quyen", "schoolId": "fist", "name": "Bá Quyền"}],
            "skills": [{
                "id": skill_id, "familyId": "tmb.skill.fist.test", "name": "Test Skill",
                "schoolId": "fist", "schoolName": "Quyền Tu", "branchId": "",
                "generation": "human", "slot": "active", "animationKey": "anim_test",
                "vfxKey": "vfx_test", "sourcePath": "godot/data/combat/test.json",
                "sourceSha": "b" * 64, "version": 1, "runtimeStatus": "GATED_OFF",
                "targetLimit": 1,
            }],
            "gaps": [{"id": f"GAP-{n}", "title": f"Gap {n}", "status": "PENDING"} for n in range(10)],
        }
        (root / "wiki/data/catalog.json").write_text(json.dumps(catalog), encoding="utf-8")
        ledger = root / "docs/operations/vfx_school_ledgers"
        ledger.mkdir(parents=True)
        fields = ["skill_id","family_id","school","branch","slot","tier","name_vi",
                  "vfx_key_declared","effect_declared","shape_declared","target_limit_declared",
                  "visual_work_class","lab_visual_status","owner_gate","live_integration"]
        with (ledger / "01_test.csv").open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields)
            writer.writeheader()
            writer.writerow({
                "skill_id": skill_id, "family_id": "tmb.skill.fist.test", "school": "fist",
                "branch": "ba_quyen", "slot": "active", "tier": "human", "name_vi": "Test Skill",
                "vfx_key_declared": "vfx_test", "effect_declared": "mark",
                "shape_declared": "single_target", "target_limit_declared": "1",
                "visual_work_class": "CAST_MASTER", "lab_visual_status": "TECH_PASS_REPORTED",
                "owner_gate": "OWNER_VISUAL_PROVISIONAL", "live_integration": "HOLD_V63_OFF",
            })
        packet_dir = root / "docs/operations/vfx_packets"
        packet_dir.mkdir(parents=True)
        (root / "godot/labs/test").mkdir(parents=True)
        (root / "godot/labs/test/scene.tscn").write_text("[gd_scene]", encoding="utf-8")
        packet = {
            "packet_id": "TEST_PACKET", "skill_id": skill_id, "revision": "R1",
            "scene_path": "godot/labs/test/scene.tscn",
            "master_files": ["godot/labs/test/scene.tscn"],
            "gate_status": "ART_PENDING",
        }
        (packet_dir / "TEST.json").write_text(json.dumps(packet), encoding="utf-8")
        test_dir = root / "godot/tests/simulation"
        test_dir.mkdir(parents=True)
        (test_dir / "vfx_test_contract_test.gd").write_text(f'const SKILL = "{skill_id}"\n', encoding="utf-8")
        (root / "godot/src/simulation/combat").mkdir(parents=True)
        (root / "godot/src/simulation/combat/v63_feature_gates.gd").write_text("const DEFAULT_FLAGS := {}\n", encoding="utf-8")
        (root / "godot/data/combat").mkdir(parents=True)
        (root / "godot/data/combat/v63_content_registry.json").write_text('{"enabled":false}', encoding="utf-8")
        return root

    def test_status_axes_do_not_collapse_technical_and_owner_approval(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            row = builder.build_progress(root, strict=False)["skills"][0]
            self.assertEqual("GATED_OFF", row["runtime"]["status"])
            self.assertFalse(row["runtime"]["active"])
            self.assertEqual("TECH_PASS_REPORTED", row["vfx"]["technicalStatus"])
            self.assertEqual("PROVISIONAL_NOT_FINAL", row["vfx"]["ownerStatus"])
            self.assertEqual("UNKNOWN_NO_SKILL_ID_MAPPING", row["animation"]["status"])
            self.assertEqual("TEST_SOURCE_ID_MATCH_NOT_EXECUTED", row["qa"]["status"])
            self.assertEqual("SOURCE_ID_MATCH_NOT_EXECUTED", row["qa"]["tests"][0]["status"])
            self.assertEqual("HOLD_V63_OFF", row["vfx"]["liveIntegration"])
            self.assertEqual("TECH_FAIL_REPORTED", builder.tech_state("GODOT_V4_TECH_FAIL"))

    def test_direct_packet_links_and_asset_availability_are_traceable(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            row = builder.build_progress(root, strict=False)["skills"][0]
            refs = row["vfx"]["packets"][0]["refs"]
            self.assertTrue(any(ref["kind"] == "scene" and ref["exists"] for ref in refs))
            self.assertEqual("TEST_PACKET", row["vfx"]["packets"][0]["packetId"])
            self.assertTrue(row["traceability"]["packetPaths"])

    def test_repeat_build_is_deterministic_and_preserves_ten_gaps(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            first = builder.build_progress(root, strict=False)
            second = builder.build_progress(root, strict=False)
            self.assertEqual(json.dumps(first, sort_keys=True), json.dumps(second, sort_keys=True))
            self.assertEqual(2, first["schemaVersion"])
            self.assertEqual(10, len(first["gapRegister"]))

    def test_ledger_row_count_counts_rows_not_csv_fields(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            result = builder.build_progress(root, strict=False)
            self.assertEqual(1, result["summary"]["vfxLedgerRows"])
            self.assertEqual(1, result["summary"]["vfxLedgerFiles"])

    def test_duplicate_ledger_id_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            ledger = root / "docs/operations/vfx_school_ledgers/02_duplicate.csv"
            ledger.write_text(
                '"skill_id","family_id"\n"tmb.skill.fist.test.active_01.human","family"\n',
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "duplicate skill_id"):
                builder.build_progress(root, strict=False)


    def test_invalid_catalog_duplicate_skill_id_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            catalog_path = root / "wiki/data/catalog.json"
            catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
            catalog["skills"].append(dict(catalog["skills"][0]))
            catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "empty or duplicate skill IDs"):
                builder.build_progress(root, strict=False)

    def test_missing_packet_asset_is_reported_not_substituted(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            packet_path = root / "docs/operations/vfx_packets/TEST.json"
            packet = json.loads(packet_path.read_text(encoding="utf-8"))
            packet["scene_path"] = "godot/labs/test/missing_scene.tscn"
            packet_path.write_text(json.dumps(packet), encoding="utf-8")
            row = builder.build_progress(root, strict=False)["skills"][0]
            missing = [ref for ref in row["vfx"]["packets"][0]["refs"] if ref["path"] == "godot/labs/test/missing_scene.tscn"]
            self.assertEqual(1, len(missing))
            self.assertFalse(missing[0]["exists"])
            self.assertEqual("MISSING", missing[0]["shaStatus"])

    def test_exact_action_evidence_keeps_status_and_selects_latest_run(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            evidence_path = root / "docs/wiki/TMB_WIKI_V2_GITHUB_EVIDENCE_20261117.json"
            evidence_path.parent.mkdir(parents=True, exist_ok=True)
            evidence_path.write_text(json.dumps({
                "schemaVersion": 1,
                "runs": [
                    {"runId": 9, "skillId": "tmb.skill.fist.test.active_01.human",
                     "conclusion": "failure", "createdAt": "2026-01-01T00:00:00Z"},
                    {"runId": 10, "skillId": "tmb.skill.fist.test.active_01.human",
                     "conclusion": "success", "createdAt": "2026-01-02T00:00:00Z"},
                ],
            }), encoding="utf-8")
            row = builder.build_progress(root, strict=False)["skills"][0]
            self.assertEqual("ACTION_SUCCESS_AT_RECORDED_SHA", row["qa"]["status"])
            self.assertEqual(
                ["ACTION_FAILURE_AT_RECORDED_SHA", "ACTION_SUCCESS_AT_RECORDED_SHA"],
                [run["status"] for run in row["qa"]["githubRuns"]],
            )

    def test_in_progress_exact_sha_is_not_promoted_to_pass(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            evidence_path = root / "docs/wiki/TMB_WIKI_V2_GITHUB_EVIDENCE_20261117.json"
            evidence_path.parent.mkdir(parents=True, exist_ok=True)
            evidence_path.write_text(json.dumps({
                "schemaVersion": 1,
                "runs": [
                    {"runId": 20, "skillId": "tmb.skill.fist.test.active_01.human",
                     "conclusion": "success", "createdAt": "2026-01-01T00:00:00Z"},
                    {"runId": 21, "skillId": "tmb.skill.fist.test.active_01.human",
                     "conclusion": None, "runStatus": "in_progress",
                     "createdAt": "2026-01-02T00:00:00Z"},
                ],
            }), encoding="utf-8")
            result = builder.build_progress(root, strict=False)
            row = result["skills"][0]
            self.assertEqual("ACTION_IN_PROGRESS_AT_RECORDED_SHA", row["qa"]["status"])
            self.assertEqual(1, result["summary"]["exactShaInProgressActionSkills"])
            self.assertEqual(0, result["summary"]["exactShaSuccessfulActionSkills"])

    def test_binary_asset_presence_never_claims_recomputed_hash(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            packet_path = root / "docs/operations/vfx_packets/TEST.json"
            packet = json.loads(packet_path.read_text(encoding="utf-8"))
            packet["asset_files"] = ["godot/labs/test/fake_texture.png"]
            packet_path.write_text(json.dumps(packet), encoding="utf-8")
            asset = root / "godot/labs/test/fake_texture.png"
            asset.write_bytes(b"fixture bytes only")
            row = builder.build_progress(root, strict=False)["skills"][0]
            ref = next(ref for ref in row["vfx"]["packets"][0]["refs"] if ref["path"].endswith("fake_texture.png"))
            self.assertTrue(ref["exists"])
            self.assertEqual("", ref["sourceSha256"])
            self.assertEqual("BINARY_HASH_REQUIRES_MANIFEST_OR_BYTE_READ", ref["shaStatus"])

    def test_baseline_gap_ids_must_not_be_replaced(self) -> None:
        with self.assertRaisesRegex(ValueError, "baseline gap register changed"):
            builder.validate_gap_register([{"id": f"GAP-{n}"} for n in range(10)])

    def test_strict_mode_rejects_incomplete_campaign_inputs(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = self.make_root(Path(temp))
            with self.assertRaisesRegex(ValueError, "expected 12 VFX ledgers"):
                builder.build_progress(root, strict=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
