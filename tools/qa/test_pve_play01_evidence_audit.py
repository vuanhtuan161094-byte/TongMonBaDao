import json
import tempfile
import unittest
from pathlib import Path
from pve_play01_evidence_audit import audit


class EvidenceAuditTests(unittest.TestCase):
    def run_audit(self, rows):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / 'sample.jsonl'
            path.write_text('\n'.join(json.dumps(row) for row in rows), encoding='utf-8')
            return audit(path)

    def test_window_summary_cannot_prove_global_percentiles(self):
        rows = ([{'kind':'sample','phase':'sect','seconds':3,'frame_ms_p95':16,
                  'frame_ms_max':149.7}]*5 +
                [{'kind':'sample','phase':'pve_active','seconds':3,'frame_ms_p95':16,
                  'frame_ms_max':18}]*10 +
                [{'kind':'sample','phase':'sect','seconds':3,'frame_ms_p95':16,
                  'frame_ms_max':17}]*4)
        report = self.run_audit(rows)
        self.assertEqual(report['status'], 'PLAYABLE_UNVERIFIED')
        self.assertTrue(all(x['estimated_met'] for x in report['coverage']))
        self.assertIn('SEVERE_SPIKE_OVER_100MS', report['flags'])
        self.assertIn('NO_RAW_FRAMES_GLOBAL_P99_1PCT_LOW_UNPROVABLE', report['flags'])

    def test_raw_frame_percentiles_and_one_pct_low(self):
        rows = [{'kind':'frame','phase':'pve_active','frame_ms':16.0} for _ in range(99)]
        rows += [{'kind':'frame','phase':'pve_active','frame_ms':150.0}]
        result = self.run_audit(rows)
        self.assertAlmostEqual(result['by_phase_raw_frames']['pve_active']['one_pct_low_fps'], 6.67)
        self.assertEqual(result['by_phase_raw_frames']['pve_active']['over_100ms'], 1)
        self.assertIn('MISSING_REQUIRED_PHASE_COVERAGE_APPROX', result['flags'])

    def test_invalid_data_is_flagged_not_pass(self):
        report = self.run_audit([{'kind':'frame','frame_ms':-2}])
        self.assertIn('INVALID_JSONL_OR_VALUES', report['flags'])
        self.assertEqual(len(report['parse_errors']), 1)


    def test_codex_schema2_phase_durations_and_top_spikes(self):
        common = {'kind': 'sample', 'schema': 2, 'elapsed_s': 3,
                  'frame_ms_p95': 18, 'frame_ms_p99': 23,
                  'frame_ms_max': 30, 'fps_1pct_low': 40}
        rows = ([dict(common, phase='production') for _ in range(5)] +
                [dict(common, phase='party_selection')] +
                [dict(common, phase='pve') for _ in range(10)] +
                [dict(common, phase='pve_save')] +
                [dict(common, phase='save_return') for _ in range(4)])
        rows[7]['frame_ms_max'] = 151
        rows[7]['top_spikes'] = [
            {'frame_ms': 151, 'elapsed_s': 21.25,
             'godot_process_ms': 110, 'godot_physics_ms': 2}
        ]
        report = self.run_audit(rows)
        self.assertTrue(all(x['estimated_met'] for x in report['coverage']))
        self.assertEqual(report['by_phase_windows']['pve']['windows'], 10)
        self.assertEqual(report['top_actual_frame_spikes'][0]['frame_ms'], 151)
        self.assertIn('SEVERE_SPIKE_OVER_100MS', report['flags'])
        self.assertNotIn('WINDOW_P99_OR_1PCT_LOW_MISSING', report['flags'])
        self.assertIn('NO_RAW_FRAMES_GLOBAL_P99_1PCT_LOW_UNPROVABLE', report['flags'])



if __name__ == '__main__':
    unittest.main()
