#!/usr/bin/env python3
"""Only synthetic bytes. No Source A assets and no network required."""
from __future__ import annotations

import csv
import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

module_path = Path(__file__).with_name("export_verified_pack.py")
spec = importlib.util.spec_from_file_location("fe01b1_exporter", module_path)
exporter = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(exporter)


class ExporterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "data"
        self.source.mkdir()
        self.output = self.root / "packs"
        self.catalog = self.root / "catalog.csv"
        self.logical_id = "building.main_hall"
        self.prefix = r"E:\GameAssetExtract"
        self.data = [
            ("510052.png", "Texture2D", b"synthetic png fixture 123"),
            ("510052.atlas", "TextAsset", b"synthetic atlas fixture"),
            ("510052.skel", "TextAsset", b"synthetic skel fixture"),
        ]
        self._write_catalog()

    def _write_catalog(self, mutate=None):
        deps = []
        for filename, kind, content in self.data:
            file = self.source / filename
            file.write_bytes(content)
            deps.append({
                "name": filename.removesuffix(".png") if kind == "Texture2D" else filename,
                "kind": kind,
                "source_path": self.prefix + "\\" + filename,
                "sha256": hashlib.sha256(content).hexdigest(),
                "bytes": len(content),
            })
        if mutate:
            mutate(deps)
        row = {
            "logical_id": self.logical_id, "source_variant": "A_AndroidData",
            "rights_status": "A_USER_AUTHORIZED_LAB",
            "evidence_status": "VERIFIED",
            "dependencies_selected_model": json.dumps(deps),
        }
        with self.catalog.open("w", encoding="utf-8-sig", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(row))
            w.writeheader()
            w.writerow(row)

    def run_export(self, **extra):
        return exporter.export_pack(
            catalog=self.catalog, output_root=self.output,
            logical_id=self.logical_id, source_root=self.source,
            source_prefix=self.prefix, **extra)

    def assert_clean(self):
        self.assertFalse((self.output / self.logical_id).exists())
        if self.output.exists():
            self.assertEqual(list(self.output.iterdir()), [])

    def test_export_then_unchanged_preserves_bytes(self):
        result = self.run_export()
        self.assertEqual(result["status"], "EXPORTED")
        first = self.output / self.logical_id
        self.assertEqual((first / "510052.png").read_bytes(), self.data[0][2])
        self.assertEqual(self.run_export()["status"], "UNCHANGED")
        self.assertEqual(len(list(first.iterdir())), 5)

    def test_dry_run_creates_nothing(self):
        self.assertEqual(self.run_export(dry_run=True)["status"], "DRY_RUN")
        self.assertFalse(self.output.exists())

    def test_wrong_source_hash_fails_before_pack(self):
        self._write_catalog(lambda d: d[0].update(sha256="a" * 64))
        with self.assertRaisesRegex(exporter.PackError, "drift"):
            self.run_export()
        self.assertFalse(self.output.exists())

    def test_missing_source_fails_before_pack(self):
        (self.source / "510052.png").unlink()
        with self.assertRaises(exporter.PackError):
            self.run_export()
        self.assertFalse(self.output.exists())

    def test_existing_pack_tampered_file_fail_closed(self):
        self.run_export()
        target = self.output / self.logical_id / "510052.png"
        target.write_bytes(b"tampered")
        with self.assertRaises(exporter.PackError):
            self.run_export()
        self.assertEqual(target.read_bytes(), b"tampered")

    def test_existing_pack_tampered_manifest_fail_closed(self):
        self.run_export()
        target = self.output / self.logical_id / "manifest.json"
        target.write_text("{}", encoding="utf-8")
        with self.assertRaises(exporter.PackError):
            self.run_export()
        self.assertEqual(target.read_text(encoding="utf-8"), "{}")

    def test_existing_pack_extra_file_fail_closed(self):
        self.run_export()
        (self.output / self.logical_id / "surprise").write_bytes(b"not allowed")
        with self.assertRaises(exporter.PackError):
            self.run_export()

    def test_existing_unmanaged_dir_not_overwritten(self):
        self.output.mkdir()
        target = self.output / self.logical_id
        target.mkdir()
        marker = target / "original.txt"
        marker.write_text("private user data", encoding="utf-8")
        with self.assertRaises(exporter.PackError):
            self.run_export()
        self.assertEqual(marker.read_text(encoding="utf-8"), "private user data")

    def test_partial_copy_failure_cleans_stage_and_lock(self):
        def broken(source, target, expected):
            target.write_bytes(b"partial write")
            raise OSError("simulated disk full")
        with patch.object(exporter, "_copy_verified", side_effect=broken):
            with self.assertRaisesRegex(OSError, "disk full"):
                self.run_export()
        self.assert_clean()

    def test_publish_rename_failure_cleans_stage_and_lock(self):
        with patch.object(exporter.os, "rename", side_effect=PermissionError("locked file")):
            with self.assertRaises(PermissionError):
                self.run_export()
        self.assert_clean()

    def test_preexisting_lock_refuses_concurrent_export(self):
        self.output.mkdir()
        lock = self.output / ".building.main_hall.fe01b1.lock"
        lock.write_text("another process", encoding="utf-8")
        with self.assertRaisesRegex(exporter.PackError, "locked"):
            self.run_export()
        self.assertEqual(lock.read_text(encoding="utf-8"), "another process")
        self.assertFalse((self.output / self.logical_id).exists())

    def test_case_insensitive_collision(self):
        def collide(deps):
            copied = deps[0].copy()
            copied["name"] = "510052.PNG"
            deps.append(copied)
        self._write_catalog(collide)
        with self.assertRaisesRegex(exporter.PackError, "collision"):
            self.run_export()

    def test_unsafe_filename_traversal(self):
        self._write_catalog(lambda deps: deps[0].update(name="../bad"))
        with self.assertRaisesRegex(exporter.PackError, "Unsafe"):
            self.run_export()

    def test_catalog_path_prefix_escape(self):
        self._write_catalog(lambda deps: deps[0].update(source_path=r"E:\OtherRoot\private.png"))
        with self.assertRaisesRegex(exporter.PackError, "outside"):
            self.run_export()

    def test_catalog_relative_traversal_escape(self):
        self._write_catalog(lambda deps: deps[0].update(source_path=r"E:\GameAssetExtract\..\OtherRoot\private.png"))
        with self.assertRaises(exporter.PackError):
            self.run_export()

    def test_invalid_logical_id(self):
        with self.assertRaises(exporter.PackError):
            exporter.export_pack(
                catalog=self.catalog, output_root=self.output, logical_id="../../game",
                source_root=self.source, source_prefix=self.prefix)

    def test_source_symlink_refused(self):
        file = self.source / "510052.png"
        destination = self.source / "original.png"
        file.rename(destination)
        try:
            file.symlink_to(destination)
        except (OSError, NotImplementedError):
            self.skipTest("symlink creation unsupported on this runner")
        with self.assertRaises(exporter.PackError):
            self.run_export()

    def test_source_changes_during_copy_roll_back(self):
        original = exporter._copy_verified
        def tamper_after_plan(source, dest, expected):
            if dest.name == "510052.png":
                source.write_bytes(b"unexpected mutation")
            return original(source, dest, expected)
        with patch.object(exporter, "_copy_verified", side_effect=tamper_after_plan):
            with self.assertRaises(exporter.PackError):
                self.run_export()
        self.assert_clean()

    def test_portable_prefix_and_rights_preserved(self):
        self.run_export()
        stored = json.loads((self.output / self.logical_id / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(stored["rights_status"], "A_USER_AUTHORIZED_LAB")
        self.assertEqual(stored["release_rights"], "UNVERIFIED")
        self.assertTrue(stored["lab_only"])
        self.assertEqual(stored["godot_playback"], "NOT_TESTED")
        self.assertEqual(stored["files"][0]["source_path"], self.prefix + "\\510052.png")


if __name__ == "__main__":
    unittest.main(verbosity=2)
