from __future__ import annotations

import copy
import hashlib
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1] / "tools"
sys.path.insert(0, str(TOOLS))
import as_char38_registry  # noqa: E402
import compose_appearance  # noqa: E402

ROOT = Path(__file__).resolve().parents[5]
REL = Path("godot/labs/character_family/as_char38")


class AsChar38RegistryTests(unittest.TestCase):
    def test_registry_and_real_assets_validate(self) -> None:
        self.assertEqual([], as_char38_registry.validate_registry(ROOT))

    def test_complete_38_groups_and_two_sex_variants(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        groups = registry["groups"]
        self.assertEqual(38, len(groups))
        self.assertEqual(2, sum(group["group_kind"] == "novice" for group in groups))
        branches = [group for group in groups if group["group_kind"] == "branch"]
        self.assertEqual(36, len(branches))
        self.assertEqual(12, len({group["school_id"] for group in branches}))
        for group in branches:
            self.assertEqual({"male", "female"}, set(group["sex_variants"]))
            for variant in group["sex_variants"].values():
                self.assertEqual("ART_PENDING", variant["status"])
                self.assertEqual({"front", "right", "back", "left"}, set(variant["directions"]))
                self.assertEqual({"idle", "walk", "cast", "attack", "hit", "death"}, set(variant["clips"]))

    def test_exact_v63_path_candidate_mapping_and_design_only_rows(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        v63 = as_char38_registry.load_json(ROOT / "godot/data/combat/v63_content_registry.json")
        candidates = {row["id"] for row in v63["paths"]}
        branches = [group for group in registry["groups"] if group["group_kind"] == "branch"]
        mapped = {group["v63_path_candidate_id"] for group in branches if group["v63_path_candidate_id"]}
        self.assertEqual(candidates, mapped)
        self.assertEqual(18, len(mapped))
        self.assertEqual(18, sum(group["v63_path_candidate_id"] is None for group in branches))

    def test_novice_idle_has_four_real_frames_and_no_fake_motion(self) -> None:
        manifest = as_char38_registry.load_json(ROOT / REL / "assets/g1_asset_manifest.json")
        self.assertEqual(2, len(manifest["families"]))
        for family in manifest["families"]:
            self.assertEqual(1, family["frames_per_direction"])
            self.assertEqual("STATIC_POSE_CANDIDATE", family["idle_pose_status"])
            self.assertEqual(4, len(family["directions"]))
            self.assertEqual([64, 104], family["pivot"])
            self.assertEqual(70, family["visible_body_height_px"])
            from PIL import Image
            atlas_path = ROOT / family["atlas_path"]
            with Image.open(atlas_path) as image:
                self.assertEqual((512, 128), image.size)
                self.assertEqual((0, 255), image.getchannel("A").getextrema())
            self.assertEqual(
                {"walk": "ART_PENDING", "cast": "ART_PENDING", "attack": "ART_PENDING", "hit": "ART_PENDING", "death": "ART_PENDING"},
                family["motion_clips"],
            )

    def test_identity_resolution_is_deterministic_and_read_only(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        snapshot = {
            "disciple_id": "disciple.test.01",
            "sex_id": "female",
            "profile_seed": 721,
            "cosmetic_seed": 7,
        }
        before = copy.deepcopy(snapshot)
        first = as_char38_registry.resolve_identity(snapshot, registry)
        second = as_char38_registry.resolve_identity(dict(reversed(list(snapshot.items()))), registry)
        self.assertEqual(first, second)
        self.assertFalse(first["simulation_mutated"])
        self.assertEqual("tmb.as_char38.novice.female", first["render_group_id"])
        self.assertEqual("NOVICE_BASE_STATIC_IDLE_CANDIDATE", first["status"])
        self.assertEqual(before, snapshot)

    def test_known_branch_honestly_falls_back_until_branch_art_exists(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        result = as_char38_registry.resolve_identity({
            "disciple_id": "disciple.poison.01",
            "sex_id": "female",
            "v63_combat_branch_id": "tmb.path.poison.doc_cham",
            "profile_seed": 81,
        }, registry)
        self.assertEqual("tmb.as_char38.branch.poison.doc_cham", result["selected_group_id"])
        self.assertEqual("tmb.as_char38.novice.female", result["render_group_id"])
        self.assertEqual("ART_PENDING_FALLBACK_NOVICE", result["status"])
        self.assertEqual("ART_PENDING", result["branch_art_status"])
        self.assertFalse(result["simulation_mutated"])

    def test_unknown_branch_is_never_reassigned_to_a_different_branch(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        result = as_char38_registry.resolve_identity({
            "disciple_id": "disciple.unknown.01",
            "sex_id": "male",
            "v63_combat_branch_id": "tmb.path.fake.not_real",
        }, registry)
        self.assertEqual("UNKNOWN_BRANCH_FALLBACK_NOVICE", result["status"])
        self.assertIsNone(result["selected_group_id"])
        self.assertEqual("tmb.as_char38.novice.male", result["render_group_id"])

    def test_invalid_sex_and_missing_identity_are_rejected(self) -> None:
        registry = as_char38_registry.load_json(ROOT / REL / "as_char38_registry.json")
        invalid = as_char38_registry.resolve_identity({"disciple_id": "x", "sex_id": "unknown"}, registry)
        missing = as_char38_registry.resolve_identity({"sex_id": "female"}, registry)
        self.assertEqual("INVALID_OR_MISSING_SEX", invalid["status"])
        self.assertIsNone(invalid["render_group_id"])
        self.assertEqual("MISSING_DISCIPLE_ID", missing["status"])

    def _copy_validation_root(self, temp_root: Path) -> None:
        required = [
            REL / "as_char38_registry.json",
            REL / "assets/g1_asset_manifest.json",
            "godot/data/combat/v63_content_registry.json",
        ]
        for relative in required:
            destination = temp_root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / relative, destination)
        manifest = as_char38_registry.load_json(ROOT / REL / "assets/g1_asset_manifest.json")
        for record in manifest["families"]:
            for key in ("source_path", "atlas_path", "spriteframes_path"):
                relative = Path(record[key])
                destination = temp_root / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(ROOT / relative, destination)

    def test_invalid_schema_version_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            temp_root = Path(temporary)
            self._copy_validation_root(temp_root)
            path = temp_root / REL / "as_char38_registry.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            data["schema_version"] = 99
            path.write_text(json.dumps(data), encoding="utf-8")
            errors = as_char38_registry.validate_registry(temp_root)
        self.assertTrue(any("schema_version" in error for error in errors))

    def test_asset_hash_mismatch_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            temp_root = Path(temporary)
            self._copy_validation_root(temp_root)
            path = temp_root / REL / "assets/g1_asset_manifest.json"
            data = json.loads(path.read_text(encoding="utf-8"))
            data["families"][0]["atlas_sha256"] = "0" * 64
            path.write_text(json.dumps(data), encoding="utf-8")
            errors = as_char38_registry.validate_registry(temp_root)
        self.assertTrue(any("atlas SHA-256 mismatch" in error for error in errors))

    def test_missing_atlas_is_reported_not_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            temp_root = Path(temporary)
            self._copy_validation_root(temp_root)
            manifest = as_char38_registry.load_json(temp_root / REL / "assets/g1_asset_manifest.json")
            atlas = temp_root / manifest["families"][0]["atlas_path"]
            atlas.unlink()
            errors = as_char38_registry.validate_registry(temp_root)
        self.assertTrue(any("source, atlas, or SpriteFrames resource missing" in error for error in errors))


class AppearanceComposerTests(unittest.TestCase):
    def _write_layer(self, path: Path, color: tuple[int, int, int, int]) -> str:
        from PIL import Image
        path.parent.mkdir(parents=True, exist_ok=True)
        image = Image.new("RGBA", (512, 128), (0, 0, 0, 0))
        for x in range(16, 24):
            for y in range(24, 40):
                image.putpixel((x, y), color)
        image.save(path, optimize=True)
        return hashlib.sha256(path.read_bytes()).hexdigest()

    def test_layer_composition_is_seeded_and_keeps_atlas_size(self) -> None:
        from PIL import Image
        with tempfile.TemporaryDirectory() as temporary:
            pack = Path(temporary) / "pack"
            base_hash = self._write_layer(pack / "body.png", (50, 45, 60, 255))
            accent_a = self._write_layer(pack / "accents/a.png", (190, 160, 90, 180))
            accent_b = self._write_layer(pack / "accents/b.png", (80, 170, 160, 180))
            layers = [
                {"layer_id": "body", "layer_role": "body_base", "path": "body.png", "sha256": base_hash, "atlas_size": [512, 128], "order": 0, "required": True, "sex_id": "both", "source_status": "SOURCE_AVAILABLE"},
                {"layer_id": "accent-a", "layer_role": "accent", "path": "accents/a.png", "sha256": accent_a, "atlas_size": [512, 128], "order": 20, "required": False, "sex_id": "both", "source_status": "SOURCE_AVAILABLE", "cosmetic_slot": "trim", "variant_id": "a"},
                {"layer_id": "accent-b", "layer_role": "accent", "path": "accents/b.png", "sha256": accent_b, "atlas_size": [512, 128], "order": 20, "required": False, "sex_id": "both", "source_status": "SOURCE_AVAILABLE", "cosmetic_slot": "trim", "variant_id": "b"},
            ]
            manifest_path = pack / "layer_manifest.json"
            manifest_path.write_text(json.dumps({
                "schema_version": 1, "art_status": "SOURCE_AVAILABLE",
                "school_id": "poison", "branch_id": "doc_cham", "sex_id": "both",
                "cell_size": [128, 128], "direction_order": ["front", "right", "back", "left"],
                "layers": layers
            }), encoding="utf-8")
            identity = {"disciple_id": "d1", "sex_id": "female", "school_id": "poison", "branch_id": "doc_cham", "profile_seed": 100, "cosmetic_seed": 4}
            first = pack / "first.png"
            second = pack / "second.png"
            receipt_a = compose_appearance.compose(manifest_path, identity, first)
            receipt_b = compose_appearance.compose(manifest_path, identity, second)
            self.assertEqual(receipt_a["output_sha256"], receipt_b["output_sha256"])
            self.assertEqual(0, receipt_a["generated_frames"])
            self.assertFalse(receipt_a["tint_or_geometry_transform"])
            selected_accent_ids = set()
            for seed in range(24):
                variant_identity = dict(identity, cosmetic_seed=seed)
                variant_receipt = compose_appearance.compose(
                    manifest_path, variant_identity, pack / f"variant-{seed}.png"
                )
                selected_accent_ids.update(
                    source["layer_id"] for source in variant_receipt["source_layers"]
                    if source["layer_id"].startswith("accent-")
                )
            self.assertEqual({"accent-a", "accent-b"}, selected_accent_ids)
            with Image.open(first) as result:
                self.assertEqual((512, 128), result.size)
                self.assertEqual("RGBA", result.mode)

    def test_composer_refuses_pending_or_mismatched_source(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            pack = Path(temporary) / "pack"
            pack.mkdir()
            manifest_path = pack / "layer_manifest.json"
            manifest_path.write_text(json.dumps({
                "schema_version": 1, "art_status": "ART_PENDING",
                "school_id": "poison", "branch_id": "doc_cham", "sex_id": "both",
                "cell_size": [128, 128], "direction_order": ["front", "right", "back", "left"],
                "layers": [{"layer_id": "body", "layer_role": "body_base", "required": True, "source_status": "ART_PENDING"}]
            }), encoding="utf-8")
            with self.assertRaises(compose_appearance.ArtPendingError):
                compose_appearance.compose(manifest_path, {
                    "disciple_id": "d1", "sex_id": "female", "school_id": "poison", "branch_id": "doc_cham"
                }, pack / "out.png")

    def test_composer_rejects_wrong_branch_pack(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            pack = Path(temporary) / "pack"
            pack.mkdir()
            manifest_path = pack / "layer_manifest.json"
            manifest_path.write_text(json.dumps({
                "schema_version": 1, "art_status": "SOURCE_AVAILABLE",
                "school_id": "sword", "branch_id": "ngu_kiem", "sex_id": "both",
                "cell_size": [128, 128], "direction_order": ["front", "right", "back", "left"],
                "layers": []
            }), encoding="utf-8")
            with self.assertRaises(compose_appearance.ArtPendingError):
                compose_appearance.compose(manifest_path, {
                    "disciple_id": "d1", "sex_id": "female", "school_id": "poison", "branch_id": "doc_cham"
                }, pack / "out.png")


if __name__ == "__main__":
    unittest.main()
