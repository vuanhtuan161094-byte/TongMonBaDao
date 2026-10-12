#!/usr/bin/env python3
"""Negative/positive tests for FE-01A manifest contract; standard-library only."""
import copy
import json
import unittest

from validate_fe01_manifest import MANIFEST, REGISTRY, validate


class ManifestTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.good = json.loads(MANIFEST.read_text(encoding="utf-8"))
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))

    def fail_case(self, mutate):
        data = copy.deepcopy(self.good)
        mutate(data)
        self.assertTrue(validate(data, self.registry))

    def test_original(self):
        self.assertEqual(validate(self.good, self.registry), [])

    def test_duplicate_candidate(self):
        self.fail_case(lambda d: d["candidates"][1].update(candidate_id=d["candidates"][0]["candidate_id"]))

    def test_duplicate_destination(self):
        self.fail_case(lambda d: d["candidates"][1].update(destination_id=d["candidates"][0]["destination_id"]))

    def test_analog_promoted(self):
        self.fail_case(lambda d: d["candidates"][2].update(evidence_status="VERIFIED"))

    def test_approved_visual_forged(self):
        self.fail_case(lambda d: d["candidates"][0].update(visual_status="approved"))

    def test_runtime_binary_injected(self):
        self.fail_case(lambda d: d["candidates"][0].update(runtime_resource_path="res://unauthorized.png"))

    def test_dependency_hash_tampered(self):
        self.fail_case(lambda d: d["candidates"][0]["source_dependencies"][0].update(sha256="bad"))

    def test_shared_model_silent_remap(self):
        self.fail_case(lambda d: d["candidates"][6].update(source_model_id=123456))

    def test_source_rights_forged(self):
        self.fail_case(lambda d: d["candidates"][0].update(release_rights="GRANTED"))

    def test_different_baseline_approval(self):
        modified_registry = copy.deepcopy(self.registry)
        next(a for a in modified_registry["assets"] if a.get("id") == "building.sect_main_hall")["source_evidence_class"] = "S0"
        self.assertTrue(validate(self.good, modified_registry))

    def test_windows_binary_path_rejected(self):
        self.fail_case(lambda d: d["candidates"][0]["source_dependencies"][0].update(name="E:\\\\bad.png"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
