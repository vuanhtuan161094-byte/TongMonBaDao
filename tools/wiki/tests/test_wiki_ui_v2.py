from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class WikiV2UiContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.app = (ROOT / "wiki/app.js").read_text(encoding="utf-8")
        cls.html = (ROOT / "wiki/index.html").read_text(encoding="utf-8")
        cls.css = (ROOT / "wiki/styles.css").read_text(encoding="utf-8")
        cls.builder = (ROOT / "tools/wiki/build_skill_progress_v2.py").read_text(encoding="utf-8")

    def test_progress_matrix_and_per_skill_detail_are_routed(self) -> None:
        self.assertIn('data-view="progress"', self.html)
        self.assertIn('data-view="work"', self.html)
        self.assertIn("function renderProgress()", self.app)
        self.assertIn("function skillDetailView()", self.app)
        self.assertIn("function workQueueView()", self.app)
        for axis in ("Thiết kế", "Runtime", "VFX kỹ thuật", "Animation", "QA", "Owner Art"):
            self.assertIn(axis, self.app)

    def test_v63_candidate_is_never_promoted_to_active_runtime(self) -> None:
        self.assertIn('"runtimeAuthority": "V6.3_OFF"', self.builder)
        self.assertIn('"active": False', self.builder)
        self.assertIn("UNKNOWN_NO_SKILL_ID_MAPPING", self.builder)
        self.assertIn("TECH_PASS_REPORTED", self.builder)
        self.assertIn("OWNER_APPROVED_RECORDED", self.builder)

    def test_owner_backup_is_versioned_and_non_overwriting(self) -> None:
        self.assertIn("schemaVersion:2", self.app)
        self.assertIn("bundleType:'tmb-wiki-owner-data'", self.app)
        self.assertIn("if(known.has(row.localId)) continue;", self.app)
        self.assertIn("persistImportedBundles(updates)", self.app)
        self.assertIn("Restore sẽ chỉ thêm bản ghi mới", self.app)

    def test_ui_remains_local_only_and_responsive(self) -> None:
        self.assertIn("LOCAL-ONLY ACCESS GATE", self.app)
        self.assertIn("['localhost','127.0.0.1','::1']", self.app)
        self.assertIn("@media(max-width:760px)", self.css)
        self.assertIn(".progress-table-wrap", self.css)
        self.assertIn("f.branch === 'shared' ? row.branch !== 'shared'", self.app)
        self.assertIn("tools/wiki/SYNC_WIKI_SOURCE.cmd", self.app)
        self.assertIn("ACTION_FAILURE_AT_RECORDED_SHA", self.app)
        self.assertIn("ACTION_IN_PROGRESS_AT_RECORDED_SHA", self.builder)
        self.assertIn("failedActions", self.app)
        self.assertIn("inProgressActions", self.app)
        self.assertIn("QA-ACTION-PENDING", self.app)


if __name__ == "__main__":
    unittest.main(verbosity=2)
