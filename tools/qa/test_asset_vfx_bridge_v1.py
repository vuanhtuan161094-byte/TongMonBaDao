"""Focused contract negative/positive checks. Synthetic fixtures, no art approval."""
import copy
import json
import unittest
from pathlib import Path
from validate_asset_vfx_bridge_v1 import validate

FIXTURES = Path(__file__).resolve().parents[2] / "docs" / "operations" / "visual_bridge_v1"


class TestBridgeV1(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.actor = json.loads((FIXTURES / "fixture_character.json").read_text(encoding="utf-8"))
        cls.vfx = json.loads((FIXTURES / "fixture_vfx.json").read_text(encoding="utf-8"))

    def test_fixture(self):
        self.assertEqual([], validate(self.actor, self.vfx))

    def test_missing_direction_fails_closed(self):
        actor = copy.deepcopy(self.actor)
        del actor["clips"]["cast"]["back"]
        self.assertTrue(validate(actor, self.vfx))

    def test_missing_weapon_tip_fails(self):
        actor = copy.deepcopy(self.actor)
        del actor["clips"]["attack"]["right"][0]["anchors"]["weapon_tip"]
        self.assertTrue(validate(actor, self.vfx))

    def test_no_embedded_fx_in_actor(self):
        actor = copy.deepcopy(self.actor)
        actor["vfx_key"] = "invalid"
        self.assertIn("actor_embeds_vfx_or_gameplay", validate(actor, self.vfx))

    def test_no_embedded_actor_in_vfx(self):
        vfx = copy.deepcopy(self.vfx)
        vfx["actor_asset"] = "invalid"
        self.assertIn("vfx_embeds_actor_or_gameplay", validate(self.actor, vfx))

    def test_no_gameplay_damage(self):
        vfx = copy.deepcopy(self.vfx)
        vfx["damage"] = 99
        self.assertIn("vfx_embeds_actor_or_gameplay", validate(self.actor, vfx))

    def test_duplicate_event_phase(self):
        vfx = copy.deepcopy(self.vfx)
        vfx["bindings"].append(copy.deepcopy(vfx["bindings"][0]))
        self.assertTrue(any("duplicate_event_phase" in e for e in validate(self.actor, vfx)))

    def test_invalid_event(self):
        vfx = copy.deepcopy(self.vfx)
        vfx["bindings"][0]["event_type"] = "fake_hit"
        self.assertTrue(validate(self.actor, vfx))

    def test_invalid_slot(self):
        vfx = copy.deepcopy(self.vfx)
        vfx["bindings"][0]["caster_slot"] = "invented_socket"
        self.assertTrue(validate(self.actor, vfx))

    def test_duplicate_frame(self):
        actor = copy.deepcopy(self.actor)
        actor["clips"]["cast"]["front"].append(copy.deepcopy(actor["clips"]["cast"]["front"][0]))
        self.assertTrue(any("duplicate_frame" in e for e in validate(actor, self.vfx)))

    def test_missing_clip(self):
        actor = copy.deepcopy(self.actor)
        del actor["clips"]["cast"]
        self.assertTrue(validate(actor, self.vfx))

    def test_stale_or_unknown_status(self):
        actor = copy.deepcopy(self.actor)
        actor["source_status"] = "APPROVED_BY_CI"
        self.assertIn("actor_status", validate(actor, self.vfx))


if __name__ == "__main__":
    unittest.main()
