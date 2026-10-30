from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path

PACKAGE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PACKAGE / "tools"))
from catalog_core import normalize_animation, portable_record  # noqa: E402
from build_local_library import safe_source_path  # noqa: E402
from export_selected_pack import export_pack  # noqa: E402
from static_qa import validate  # noqa: E402


def _record(record_id: str, sha: str, metadata=None, size=(20, 40)) -> dict:
    return {
        "record_id": record_id,
        "source_id": "test",
        "filename": f"{record_id}.webp",
        "absolute_path": f"E:\\temporary\\{record_id}.webp",
        "sha256": sha,
        "bytes": 4,
        "format": "WEBP",
        "size_px": list(size),
        "metadata": metadata,
        "metadata_status": "LINKED" if metadata else "NO_EXACT_METADATA_JOIN",
        "skill_refs": [],
        "source_authority": "test",
    }


class CatalogNormalizationTests(unittest.TestCase):
    def test_grid_keeps_explicit_ms_and_direction_rows(self):
        row = _record("grid", "a" * 64, {"n": 2, "d": 2, "w": 10, "h": 20, "ax": 4, "ay": 8, "ms": 56})
        animation, state = normalize_animation(row)
        self.assertEqual(state, "ANIMATION_DATA_COMPLETE_ENGINE_PENDING")
        self.assertEqual(animation["frame_ms"], 56)
        self.assertEqual(animation["directions"], 2)
        self.assertTrue(animation["source_dimensions_match"])

    def test_grid_mismatch_is_not_playback_ready(self):
        row = _record("short", "b" * 64, {"n": 2, "d": 2, "w": 10, "h": 20, "ax": 4, "ay": 8, "ms": 56}, size=(19, 40))
        animation, state = normalize_animation(row)
        self.assertEqual(state, "GRID_DIMENSION_MISMATCH")
        self.assertFalse(animation["source_dimensions_match"])

    def test_rect_interval_unit_stays_unverified(self):
        meta = {"frames": 2, "dirs": 1, "rects": [0, 0, 10, 10, 5, 5, 10, 0, 10, 10, 5, 5], "interval": 80}
        animation, state = normalize_animation(_record("rect", "c" * 64, meta, size=(20, 10)))
        self.assertEqual(state, "GEOMETRY_COMPLETE_TIMING_UNVERIFIED")
        self.assertEqual(animation["timing_unit"], "UNVERIFIED")
        self.assertNotIn("frame_ms", animation)

    def test_rect_out_of_bounds_rejected(self):
        meta = {"frames": 1, "dirs": 1, "rects": [19, 0, 2, 10, 0, 0], "frameMs": 60}
        _, state = normalize_animation(_record("bad", "d" * 64, meta, size=(20, 10)))
        self.assertEqual(state, "RECT_BOUNDS_INVALID")

    def test_static_texture_is_not_called_animation(self):
        animation, state = normalize_animation(_record("static", "e" * 64))
        self.assertIsNone(animation)
        self.assertEqual(state, "NO_METADATA_STATIC_TEXTURE")

    def test_portable_record_omits_machine_path(self):
        row = portable_record(_record("portable", "f" * 64))
        self.assertNotIn("absolute_path", row)
        self.assertNotIn("E:\\", json.dumps(row))


class PathAndExportTests(unittest.TestCase):
    def test_source_path_rejects_parent_traversal(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "ok.webp").write_bytes(b"test")
            self.assertEqual(safe_source_path(root, "ok.webp"), (root / "ok.webp").resolve())
            with self.assertRaises(ValueError):
                safe_source_path(root, "..\\outside.webp")

    def test_selected_export_deduplicates_payloads_and_checks_sha(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "library"
            (root / "catalog").mkdir(parents=True)
            (root / "textures").mkdir()
            payload = b"fake-webp-payload"
            sha = hashlib.sha256(payload).hexdigest()
            (root / "textures" / f"{sha}.webp").write_bytes(payload)
            records = [_record("one", sha), _record("two", sha)]
            for item in records:
                item.update({"texture_path": f"textures/{sha}.webp", "catalog_status": "NO_METADATA_STATIC_TEXTURE"})
            (root / "catalog" / "library_index.json").write_text(json.dumps({"records": records}), encoding="utf-8")
            out = Path(tmp) / "pack"
            result = export_pack(root, ["one", "two"], out)
            self.assertEqual(result["record_count"], 2)
            self.assertEqual(result["unique_texture_count"], 1)
            self.assertTrue((out / "pack.json").is_file())
            self.assertTrue((out / "catalog" / "library_index.json").is_file())
            self.assertTrue((out / "project.godot").is_file())
            self.assertTrue((out / "index.html").is_file())
            with self.assertRaises(KeyError):
                export_pack(root, ["missing"], Path(tmp) / "bad-pack")

    def test_static_qa_rejects_missing_runtime_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "catalog").mkdir()
            (root / "textures").mkdir()
            payload = b"webp"
            sha = hashlib.sha256(payload).hexdigest()
            (root / "textures" / f"{sha}.webp").write_bytes(payload)
            row = _record("qa", sha)
            row.update({"texture_path": f"textures/{sha}.webp", "catalog_status": "NO_METADATA_STATIC_TEXTURE", "animation": None})
            catalog = {"statistics": {"source_occurrences": 1}, "records": [row]}
            (root / "catalog" / "library_index.json").write_text(json.dumps(catalog), encoding="utf-8")
            result = validate(root)
            self.assertEqual(result["status"], "FAIL")
            self.assertTrue(any("project.godot" in e for e in result["errors"]))


if __name__ == "__main__":
    unittest.main()

