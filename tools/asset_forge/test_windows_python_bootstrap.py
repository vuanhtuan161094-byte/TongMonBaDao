"""Static regression checks for Windows launcher dispatch; actual cmd.exe QA remains pending."""
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent


class WindowsBootstrapTests(unittest.TestCase):
    def test_every_python_entrypoint_uses_verified_dispatch(self):
        for name in (
            "MO_ASSET_FORGE_STUDIO.cmd", "CHAY_TEST_NHANH.cmd",
            "CAI_PILLOW_CHI_KHI_CAN.cmd", "NHAP_JXQY2_PILOT.cmd",
            "NHAP_SOURCE_A_3_RIG_GODOT.cmd", "KIEM_TRA_PYTHON.cmd",
        ):
            with self.subTest(name=name):
                data = (HERE / name).read_text("utf-8")
                self.assertIn('FIND_PYTHON.cmd', data)
                self.assertIn('%TMB_PYTHON_EXE%', data)
                self.assertNotIn('set "PY=python"', data)

    def test_python_is_run_for_version_check_not_just_located(self):
        data = (HERE / "FIND_PYTHON.cmd").read_text("utf-8")
        self.assertIn('sys.version_info >= (3, 10)', data)
        self.assertIn('WindowsApps', data)
        self.assertIn('TMB_PYTHON_OVERRIDE', data)
        self.assertIn('py -3 -c', data)
        self.assertIn(':check_exe', data)

    def test_uses_windows_crlf(self):
        for name in ("FIND_PYTHON.cmd", "MO_ASSET_FORGE_STUDIO.cmd"):
            with self.subTest(name=name):
                raw = (HERE / name).read_bytes()
                self.assertIn(b"\r\n", raw)
                self.assertNotIn(b"\n", raw.replace(b"\r\n", b""))
