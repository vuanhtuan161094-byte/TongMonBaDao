"""Synthetic-only tests of source intake integrity. NO sprite art acceptance claims."""
import hashlib
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from PIL import Image

from intake_approved_male import intake


class SourceIntakeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.src = self.root / "synthetic.png"
        Image.new("RGBA", (96, 112), (19, 47, 33, 255)).save(self.src)
        self.expected = hashlib.sha256(self.src.read_bytes()).hexdigest()

    def test_preserves_byte_exact_copy_and_marks_visual_pending(self):
        result = intake(self.src, self.root / "receipt", "TEST SYNTHETIC ART", self.expected)
        output = self.root / "receipt" / result["preserved_file"]
        self.assertEqual(output.read_bytes(), self.src.read_bytes())
        self.assertEqual(result["source_integrity_status"], "VERIFIED_COPY_SHA256")
        self.assertEqual(result["art_identity_status"], "VISUAL_MATCH_TO_OWNER_APPROVED_IMAGE_PENDING")
        self.assertTrue(result["image"]["fully_opaque"])

    def test_reject_sha_mismatch(self):
        with self.assertRaisesRegex(ValueError, "SHA256_MISMATCH"):
            intake(self.src, self.root / "receipt", "TEST", "0" * 64)

    def test_reject_non_png(self):
        self.src.write_bytes(b"NOT_A_PNG")
        with self.assertRaisesRegex(ValueError, "SOURCE_NOT_PNG_BYTES"):
            intake(self.src, self.root / "receipt", "TEST", None)

    def test_known_wrong_source_rejected(self):
        with patch("intake_approved_male.checksum", return_value="435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118"):
            with self.assertRaisesRegex(ValueError, "WRONG_MASTER"):
                intake(self.src, self.root / "receipt", "TEST", None)

    def test_reject_existing_conflicting_target(self):
        target = self.root / "receipt"
        target.mkdir()
        (target / f"male_poison_owner_front_{self.expected[:16]}.png").write_bytes(b"OTHER_CONTENT")
        with self.assertRaisesRegex(ValueError, "NONDESTRUCTIVE_REFUSAL"):
            intake(self.src, target, "TEST", self.expected)

    def test_idempotent_if_same_art(self):
        one = intake(self.src, self.root / "receipt", "TEST", self.expected)
        two = intake(self.src, self.root / "receipt", "TEST", self.expected)
        self.assertEqual(one, two)


if __name__ == "__main__":
    unittest.main()
