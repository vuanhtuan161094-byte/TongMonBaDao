#!/usr/bin/env python3
"""Validate design-only 119 formula identities without minting any game items."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATH = ROOT / "docs/design/PVE_BAL01_119_RECIPES_CANDIDATE_20261110.json"
ROLES = {
    "primary_field_herb", "secondary_field_herb", "forest_herb",
    "grain", "mined_spirit_ore", "forest_wood", "beast_hide",
    "rare_mob_core", "rare_field_catalyst",
}
FAMILIES = ["heal", "tuvi", "body", "break"]


def check() -> None:
    doc = json.loads(PATH.read_text(encoding="utf-8"))
    entries = doc["entries"]
    assert len(entries) == 119
    assert doc["count"] == {"total": 119, "source_backed": 8, "design_only": 111}
    seen = set()
    live = 0
    blocked = 0
    for row in entries:
        realm = row["realm"]
        family = row["family"]
        expected_id = f"sx02_recipe_{family}_r{realm:02d}"
        assert row["recipe_id"] == expected_id
        assert 1 <= realm <= 30 and family in FAMILIES
        assert not (realm == 30 and family == "break")
        assert expected_id not in seen
        seen.add(expected_id)
        assert row["required_hall_level"] >= 1
        assert row["required_field_level"] >= 1
        assert row["required_profession_level"] >= 0
        assert row["explicit_quality_batch"]["cycle_minutes"] == 3
        assert row["explicit_quality_batch"]["base_output_quantity"] == (6 if family == "break" else 36)
        assert set(row["quality_catalysts"]) == {"Q1", "Q2", "Q3", "Q4"}
        if realm <= 2:
            assert row["runtime_enabled"] is True
            assert row["source_status"] == "CODED_SOURCE_BACKED_BOM"
            assert row["candidate_source_roles"] is None
            assert isinstance(row["runtime_inputs"], dict) and row["runtime_inputs"]
            assert all(isinstance(v, int) and v > 0 for v in row["runtime_inputs"].values())
            live += 1
        else:
            assert row["runtime_enabled"] is False
            assert row["source_status"] == "DESIGN_ONLY_UNSOURCED"
            assert row["runtime_inputs"] is None
            assert row["source_role_not_resource_id"] is True
            roles = row["candidate_source_roles"]
            assert isinstance(roles, dict) and roles
            assert set(roles) <= ROLES
            assert all(isinstance(v, int) and v > 0 for v in roles.values())
            for grade, catalysts in row["quality_catalysts"].items():
                assert set(catalysts) <= ROLES
                assert all(isinstance(v, int) and v > 0 for v in catalysts.values())
            blocked += 1
    assert live == 8 and blocked == 111
    print(f"PVE_BAL01_119_RECIPE_SOURCE_GUARD_PASS total={len(seen)} live={live} blocked={blocked}")


if __name__ == "__main__":
    check()
