#!/usr/bin/env python3
"""Focused tests for optional SHA-only MAP25 asset recovery.

These use synthetic PNG-named bytes exclusively, never counterfeit Source A
files. They demonstrate all-or-none import and non-overwrite behavior.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import tempfile
import unittest
import zipfile

from restore_map25_env02a_art import inspect_archive, import_proven_files


class Map25RecoveryContract(unittest.TestCase):
    def setUp(self) -> None:
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        self.good_a = b"\x89PNG\r\n\x1a\n" + b"A" * 40
        self.good_b = b"\x89PNG\r\n\x1a\n" + b"B" * 40
        self.expected = {
            "pv01_assets/main_hall/510052.png":
                hashlib.sha256(self.good_a).hexdigest(),
            "env01_assets/roads/stone_cross.png":
                hashlib.sha256(self.good_b).hexdigest(),
        }
        self.archive = self.root / "owner.zip"
        self.target = self.root / "art"

    def zip_with(self, rows: dict[str, bytes]) -> None:
        with zipfile.ZipFile(self.archive, "w", zipfile.ZIP_DEFLATED) as zf:
            for name, content in rows.items():
                zf.writestr(name, content)

    def test_original_bytes_restore_by_digest_not_untrusted_name(self) -> None:
        self.zip_with({
            "owner_pack/unknown_hall.png": self.good_a,
            "some_other_prefix/cross.png": self.good_b,
        })
        seen = inspect_archive(self.archive, self.expected)
        self.assertEqual(set(seen), set(self.expected))
        written, preserved = import_proven_files(self.expected, seen, self.target)
        self.assertEqual((written, preserved), (2, 0))
        for rel, digest in self.expected.items():
            self.assertEqual(
                hashlib.sha256((self.target / rel).read_bytes()).hexdigest(),
                digest,
            )
        # A repeated restore must be idempotent.
        written, preserved = import_proven_files(self.expected, seen, self.target)
        self.assertEqual((written, preserved), (0, 2))

    def test_missing_png_refuses_partial_commit(self) -> None:
        self.zip_with({"only-one.png": self.good_a})
        seen = inspect_archive(self.archive, self.expected)
        self.assertEqual(len(seen), 1)
        with self.assertRaisesRegex(ValueError, "Refuse partial"):
            import_proven_files(self.expected, seen, self.target)
        self.assertFalse(self.target.exists())

    def test_byte_modified_or_corrupt_is_never_imported(self) -> None:
        self.zip_with({
            "same-name-a.png": self.good_a + b"tampered",
            "same-name-b.png": self.good_b,
        })
        seen = inspect_archive(self.archive, self.expected)
        self.assertNotIn("pv01_assets/main_hall/510052.png", seen)
        with self.assertRaisesRegex(ValueError, "Refuse partial"):
            import_proven_files(self.expected, seen, self.target)
        self.assertFalse(self.target.exists())

    def test_existing_unverified_destination_fails_before_any_write(self) -> None:
        self.zip_with({"a.png": self.good_a, "b.png": self.good_b})
        seen = inspect_archive(self.archive, self.expected)
        existing = self.target / "pv01_assets/main_hall/510052.png"
        existing.parent.mkdir(parents=True, exist_ok=True)
        existing.write_bytes(b"do not overwrite")
        with self.assertRaisesRegex(ValueError, "Refuse overwrite"):
            import_proven_files(self.expected, seen, self.target)
        self.assertEqual(existing.read_bytes(), b"do not overwrite")
        self.assertFalse((self.target / "env01_assets/roads/stone_cross.png").exists())


if __name__ == "__main__":
    unittest.main()
