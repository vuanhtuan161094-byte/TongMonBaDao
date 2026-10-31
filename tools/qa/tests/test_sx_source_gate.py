#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Unit tests for SX-GATE-01. Run with Python stdlib:
python -m unittest discover -s tools/qa/tests -p 'test_sx_source_gate.py' -v
"""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sx_source_gate as gate  # noqa: E402


BUILDING = '''
const MATERIAL_ORE := "thanh_thiet"
const MATERIAL_WOOD := "linh_moc"
const MATERIAL_TAM_MACH_BAN := "tam_mach_ban"
const MATERIAL_LINH_TUYEN_HEART := "linh_tuyen_chi_tam"
const MILESTONE_LEVELS := [10, 20]
const LINH_TUYEN_FRAGMENT_PER_HEART := 100
const LINH_TUYEN_FRAGMENT_BASE_CHANCE := 0.05
const MILESTONE_COMPONENTS := {
    "mine": {
        10: MATERIAL_TAM_MACH_BAN
    },
    "spirit_field": {
        10: MATERIAL_LINH_TUYEN_HEART,
        20: MATERIAL_LINH_TUYEN_HEART
    }
}
const DEFINITIONS := {
    "mine": {
        "resource_id": MATERIAL_ORE,
        "base_batch_units": 2,
        "base_worker_slots": 2,
        "worker_slot_every": 5
    },
    "linh_forest": {
        "resource_id": MATERIAL_WOOD,
        "base_batch_units": 2,
        "base_worker_slots": 2,
        "worker_slot_every": 5,
        "upgrade_enabled": false
    },
    "alchemy_hall": {
        "base_worker_slots": 2,
        "upgrade_enabled": false
    },
    "spirit_field": {
        "base_worker_slots": 4,
        "worker_slot_every": 5
    },
    "ren_than_duong": {
        "base_worker_slots": 2,
        "requires_milestone_component": false
    },
    "dan_tien_dai": {
        "base_worker_slots": 0,
        "requires_milestone_component": false
    }
}

func convert_linh_tuyen_fragments() -> void:
    pass

func body_training_upgrade_content_pending() -> void:
    pass
'''

RESOURCES = '''
const DEFINITIONS := {
    "thanh_thiet": {
        "name": "Thanh Thiết",
        "family": "ore"
    },
    "linh_moc": {"name": "Linh Mộc"},
    "tam_mach_ban": {"name": "Tầm Mạch Bàn"},
    "linh_tuyen_chi_tam": {"name": "Linh Tuyền Chi Tâm"}
}
'''

CROPS = '''
const DEFINITIONS := {
    "thanh_linh_thao": {
        "output_resource_id": "thanh_linh_thao"
    }
}
'''

ALCHEMY = '''
const DEFINITIONS := {
    "hoi_xuan_dan": {
        "output_resource_id": "hoi_xuan_dan"
    }
}
'''


class StaticSourceGateTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.write("building/building_system.gd", BUILDING)
        self.write("resource/resource_registry.gd", RESOURCES)
        self.write("building/spirit_crop_registry.gd", CROPS)
        self.write("building/alchemy_recipe_registry.gd", ALCHEMY)

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, relative, content):
        path = self.root / "godot/src/simulation" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def test_balanced_dictionary_does_not_misread_quoted_braces(self):
        snippet = '{"a": "literal } # not a comment", # { comment\n "b": {"c": 3}}'
        self.assertEqual(gate.braced(snippet, 0), snippet)

    def test_p0_unsourced_and_missing_milestone(self):
        result = gate.run(self.root)
        ids = {(x["id"], x["subject"]) for x in result["issues"]}
        self.assertIn(("MILESTONE_NO_SOURCE_FOUND", "tam_mach_ban"), ids)
        self.assertIn(("MILESTONE_UNDEFINED", "mine Lv20"), ids)
        self.assertIn(("UPGRADE_DISABLED", "linh_forest"), ids)
        self.assertIn(("UPGRADE_DISABLED", "alchemy_hall"), ids)
        self.assertNotIn(("MILESTONE_NO_SOURCE_FOUND", "linh_tuyen_chi_tam"), ids)
        self.assertEqual(result["resource_ids_baseline"], 4)
        self.assertFalse(result["medicine"]["present"])

    def test_actual_producer_removes_missing_source_without_changing_gate(self):
        # Replace a real crop entry inside the registry, not a loose text/comment.
        crop = CROPS.replace('"output_resource_id": "thanh_linh_thao"',
                             '"output_resource_id": "tam_mach_ban"')
        self.write("building/spirit_crop_registry.gd", crop)
        result = gate.run(self.root)
        ids = {(x["id"], x["subject"]) for x in result["issues"]}
        self.assertNotIn(("MILESTONE_NO_SOURCE_FOUND", "tam_mach_ban"), ids)
        self.assertIn(("MILESTONE_UNDEFINED", "mine Lv20"), ids)

    def test_commented_out_pseudo_producer_does_not_remove_p0(self):
        self.write("building/spirit_crop_registry.gd",
                   CROPS + '\n# "output_resource_id": "tam_mach_ban"\n')
        result = gate.run(self.root)
        self.assertTrue(any(x["id"] == "MILESTONE_NO_SOURCE_FOUND" and
                            x["subject"] == "tam_mach_ban" for x in result["issues"]))

    def test_commented_pseudo_producer_inside_registry_is_ignored(self):
        crop = CROPS.replace('"output_resource_id": "thanh_linh_thao"',
                             '# "output_resource_id": "tam_mach_ban"\n'
                             '        "output_resource_id": "thanh_linh_thao"')
        self.write("building/spirit_crop_registry.gd", crop)
        result = gate.run(self.root)
        self.assertTrue(any(x["id"] == "MILESTONE_NO_SOURCE_FOUND" and
                            x["subject"] == "tam_mach_ban" for x in result["issues"]))

    def test_tier_coverage_only_counts_authored_recipe_ranks(self):
        self.write("building/medicine_catalogue_v2.gd",
                   "const AUTHORED_RECIPE_REALMS := [1, 2]\n")
        result = gate.run(self.root)
        self.assertEqual(result["medicine"]["authored_recipe_ids_expected"], 4)
        self.assertEqual(result["medicine"]["registered_variants_expected"], 240)
        self.assertTrue(any(x["id"] == "MEDICINE_UNAUTHORED_TIERS" for x in result["issues"]))

    def test_missing_required_source_file_is_an_error_not_pass(self):
        (self.root / "godot/src/simulation/building/building_system.gd").unlink()
        with self.assertRaises(FileNotFoundError):
            gate.run(self.root)


if __name__ == "__main__":
    unittest.main()
