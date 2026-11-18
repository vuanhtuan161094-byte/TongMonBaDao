#!/usr/bin/env python3
"""Read-only contract: 101 birth identities vs. audited player Wiki trait effects."""
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


def norm(value: str) -> str:
    return "".join(
        c for c in unicodedata.normalize("NFD", value.lower().replace("đ", "d"))
        if unicodedata.category(c) != "Mn" and c.isalnum()
    )


def main() -> None:
    data = json.loads((ROOT / "wiki/data/trait_effect_audit.json").read_text(encoding="utf-8"))
    birth_text = (ROOT / "godot/src/simulation/recruitment/disciple_birth_catalogue_v2.gd").read_text(encoding="utf-8")
    matrix_lines = (ROOT / "docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md").read_text(encoding="utf-8").splitlines()
    legacy = (ROOT / "godot/src/simulation/traits/trait_system.gd").read_text(encoding="utf-8")
    body = birth_text.split("const TRAITS = [", 1)[1].split("# Fate rows:", 1)[0]
    entries = re.findall(r'\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([HSB])"\s*,\s*(\d+)\s*\]', body)
    assert len(entries) == 101, f"Birth catalogue changed: {len(entries)}"
    birth_rows = {row[0]: row for row in entries}
    assert len(birth_rows) == 101
    rows = data["traits"]
    assert len(rows) == 101 and len({r["id"] for r in rows}) == 101

    status = {"EFFECT_SPEC_PENDING": 0, "DEPENDENCY_BLOCKED": 0, "CONCEPT_UNAPPROVED": 0}
    source_ids = set()
    for t in rows:
        assert t["id"] in birth_rows, t["id"]
        entry = birth_rows[t["id"]]
        assert (t["name"], t["nature"], t["birthWeight"]) == (entry[1], entry[2], int(entry[3])), t["id"]
        assert t["codeIdentity"] == "CODED", t["id"]
        assert t["codeEffectV2"] == "NOT_PROVEN", t["id"]
        assert t["runtimeEffectV2"] == "NOT_PROVEN", t["id"]
        assert t["qaEffectV2"] == "NOT_PROVEN", t["id"]
        assert t["designClass"] in status, t["id"]
        assert t["designEffectVi"] and t["remainingWorkVi"] and t["consumerNeededVi"], t["id"]
        line_number = int(t["evidence"]["matrixLine"])
        assert line_number > 0 and line_number <= len(matrix_lines), t["id"]
        actual_line = matrix_lines[line_number - 1]
        assert actual_line.startswith("|") and norm(t["name"]) == norm(actual_line.split("|")[1].strip()), t["id"]
        assert t["designEffectRaw"] == actual_line.split("|")[4].strip(), t["id"]
        source_ids.add(t["id"])
        status[t["designClass"]] += 1
    assert source_ids == set(birth_rows)
    assert status == {"EFFECT_SPEC_PENDING": 41, "DEPENDENCY_BLOCKED": 12, "CONCEPT_UNAPPROVED": 48}, status
    assert data["summary"]["total"] == 101
    assert data["summary"]["identityCoded"] == 101
    assert data["summary"]["verifiedV2Effect"] == 0
    assert data["summary"]["birthAvailable"] == sum(1 for x in rows if x["birthAvailable"])
    assert len(data["legacyRows"]) == 9
    assert len({x["id"] for x in data["legacyRows"]}) == 9
    for entry in data["legacyRows"]:
        assert '"' + entry["id"] + '"' in legacy, entry["id"]
        assert entry["proof"] == "SOURCE_AND_TEST_PRESENT; EXECUTION_CURRENT_SHA_UNVERIFIED"
    assert (ROOT / "godot/tests/simulation/p2_9_traits_test.gd").is_file()
    assert (ROOT / "wiki/traits.html").is_file()
    assert (ROOT / "wiki/traits.js").is_file()
    print("PASS 101/101 trait identities, 41 specified, 12 gated, 48 concept; 9 legacy; no promoted runtime claims")


if __name__ == "__main__":
    main()
