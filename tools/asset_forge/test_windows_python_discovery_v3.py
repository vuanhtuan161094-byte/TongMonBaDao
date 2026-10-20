"""Source-level Windows discovery checks; Windows runtime remains pending."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parent


class PythonDiscoveryV3Tests(unittest.TestCase):
    def test_registry_and_external_drives_are_checked(self):
        code = (ROOT / 'FIND_PYTHON.ps1').read_text('utf-8')
        for item in ('HKCU:', 'HKLM:', 'Get-PSDrive', 'Python3*', 'uv\\python', 'Test-Interpreter'):
            with self.subTest(item=item):
                self.assertIn(item, code)
        self.assertNotIn('Get-ChildItem -Recurse', code)

    def test_local_preference_and_powershell_fallback_in_launcher(self):
        cmd = (ROOT / 'FIND_PYTHON.cmd').read_text('utf-8')
        self.assertIn('python.local.txt', cmd)
        self.assertIn('FIND_PYTHON.ps1', cmd)
        self.assertIn('call :check_exe', cmd)
        self.assertIn('WindowsApps', cmd)

    def test_chooser_rejects_alias_and_writes_utf8_without_bom(self):
        chooser = (ROOT / 'CHON_PYTHON.ps1').read_text('utf-8')
        self.assertIn('OpenFileDialog', chooser)
        self.assertIn('Microsoft\\WindowsApps', chooser)
        self.assertIn('UTF8Encoding($false)', chooser)
        self.assertIn('sys.version_info >= (3, 10)', chooser)

    def test_crlf_cmd_and_source_integrity(self):
        for name in ('FIND_PYTHON.cmd', 'CHON_PYTHON.cmd', 'TIM_PYTHON_CHI_TIET.cmd', 'KIEM_TRA_PYTHON.cmd'):
            with self.subTest(name=name):
                data = (ROOT / name).read_bytes()
                self.assertIn(b'\r\n', data)
                self.assertNotIn(b'\n', data.replace(b'\r\n', b''))
        self.assertTrue((ROOT / 'jx1_player_pipeline_v4.py').exists())

if __name__ == '__main__':
    unittest.main()
