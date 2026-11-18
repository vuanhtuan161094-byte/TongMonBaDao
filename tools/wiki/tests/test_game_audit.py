#!/usr/bin/env python3
"""Read-only source-to-Wiki inventory gate. Source presence != runtime PASS."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SIM = ROOT / "godot/src/simulation"


def read_json(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def authored_ids(path, start, end):
    body = (ROOT / path).read_text(encoding="utf-8").split(start, 1)[1].split(end, 1)[0]
    return set(re.findall(r'^\s{4}"([^"]+)":\s*\{', body, re.M))


def main():
    features = read_json("wiki/data/game_system_audit.json")
    items = read_json("wiki/data/game_items_audit.json")
    summary = features["summary"]
    inv = items["summary"]
    assert features["schema"] == 1 and items["schema"] == 2
    modules = [x for x in SIM.iterdir() if x.is_dir() and list(x.glob("*.gd"))]
    source_scripts = list(SIM.rglob("*.gd"))
    assert len(modules) == 24 and summary["sourceModules"] == len(modules)
    assert len(source_scripts) == 134 and summary["sourceSimulationGd"] == len(source_scripts)
    assert len(features["modules"]) == len(modules)
    for module in features["modules"]:
        scripts = set(str(p.relative_to(ROOT)).replace("\\", "/") for p in (SIM / module["id"]).glob("*.gd"))
        assert scripts == set(module["sources"]), module["id"]
        assert module["status"] == "CODE_PRESENT_QA_CURRENT_UNVERIFIED"

    codes = authored_ids("godot/src/simulation/building/building_system.gd",
                         "const DEFINITIONS := {", "\nvar equipment")
    assert len(codes) == 8 and summary["registeredBuildingTypes"] == 8
    design = (ROOT / "docs/P3_7_BUILDING_TREE_SPEC.md").read_text(encoding="utf-8")
    headings = re.findall(r"^# (\d+)\.\s+(.+)$", design, re.M)
    designed = [(int(n), title) for n, title in headings if 10 <= int(n) <= 35]
    assert len(designed) == 26 and summary["designedBuildingTypes"] == 26
    assert len(features["buildings"]) == 28
    assert len(set(x["id"] for x in features["buildings"])) == 28
    assert {x["id"] for x in features["buildings"] if x["codeStatus"] == "REGISTERED_BUILDING"} == codes
    assert len([x for x in features["buildings"] if x["codeStatus"] == "NOT_REGISTERED_AS_BUILDING"]) == 20
    assert summary["designNotRegistered"] == 20

    assert len(features["features"]) == 45 and summary["featureChecklist"] == 45
    for f in features["features"]:
        assert f["finding"] and f["status"] and f["name"]
        assert (ROOT / f["codeSource"]).is_file(), f["id"]
        assert (ROOT / f["designSource"]).is_file(), f["id"]
        assert f["verifiedGodotCurrentSha"] is False, f["id"]

    assert len(features["setFamilies"]) == 24 and summary["plannedSetFamilies"] == 24
    assert len([x for x in features["setFamilies"] if x["status"] == "DESIGN_ONLY_V2"]) == 24
    native = authored_ids("godot/src/simulation/resource/resource_registry.gd",
                          "const DEFINITIONS := {", "\nfunc has(")
    gear = authored_ids("godot/src/simulation/equipment/equipment_system.gd",
                        "const RECIPES := {", "\nconst FORGE_SEED")
    crops = authored_ids("godot/src/simulation/building/spirit_crop_registry.gd",
                         "const DEFINITIONS := {", "\nfunc has(")
    legacy_pills = authored_ids("godot/src/simulation/building/alchemy_recipe_registry.gd",
                               "const DEFINITIONS := {", "\nfunc has(")
    assert len(native) == inv["nativeResources"] == 34
    assert len(gear) == inv["legacyEquipmentRecipes"] == 5
    assert len(crops) == inv["crops"] == 3
    assert len(legacy_pills) == inv["legacyAlchemyRecipes"] == 2
    assert {x["id"] for x in items["nativeResources"]} == native
    assert {x["id"] for x in items["legacyEquipment"]} == gear
    assert {x["id"] for x in items["crops"]} == crops
    assert {x["id"] for x in items["legacyAlchemyRecipes"]} == legacy_pills

    medicine_source = (ROOT / "godot/src/simulation/building/medicine_catalogue_v2.gd").read_text(encoding="utf-8")
    assert 'const MAX_REALM := 30' in medicine_source
    assert 'const MAX_QUALITY := 4' in medicine_source
    assert 'const AUTHORED_RECIPE_REALMS := [1, 2]' in medicine_source
    assert 'const AUTHORED_BODY_REALMS := [1, 2]' in medicine_source
    assert 'const AUTHORED_BREAK_REALMS := [1, 2]' in medicine_source
    meds = items["medicine"]
    assert len(meds) == inv["medicineItems"] == 476
    assert len({x["id"] for x in meds}) == 476
    for m in meds:
        expected = "sx02_%s_r%02d_q%d" % (m["family"], m["realm"], m["quality"])
        assert m["id"] == expected
        assert m["hasRecipe"] == (m["realm"] <= 2)
        assert 1 <= m["realm"] <= 30 and 1 <= m["quality"] <= 4
        assert not (m["family"] == "break" and m["realm"] == 30)
    assert sum(x["hasRecipe"] for x in meds) == inv["medicineItemVariantsWithAuthoredFamilyRealm"] == 32
    assert inv["medicineRecipesDefinedTotal"] == 119
    assert inv["medicineRecipeBodiesAuthored"] == 8

    archive = read_json("godot/data/combat/v63_archive_catalog.json")
    learning = read_json("godot/data/combat/v63_learning_catalog.json")
    assert archive["enabled"] is False and learning["enabled"] is False
    assert len(items["archiveItems"]) == inv["archiveItems"] == len(archive["warehouse_items"]) == 154
    assert len(items["codices"]) == inv["codices"] == len(archive["codices"]) == 159
    assert len(items["techniques"]) == inv["learningTechniques"] == len(learning["techniques"]) == 84
    assert {x["id"] for x in items["archiveItems"]} == {x["id"] for x in archive["warehouse_items"]}
    assert {x["id"] for x in items["codices"]} == {x["id"] for x in archive["codices"]}
    assert {x["id"] for x in items["techniques"]} == {x["id"] for x in learning["techniques"]}

    for target in ["wiki/audit.html", "wiki/audit.js", "wiki/audit.css"]:
        assert (ROOT / target).is_file()
    print("PASS whole game inventory: 24 simulation modules / 134 scripts; 45 features; "
          "26 design + 8 registered buildings; 24 sets; 34 resources, 476 pills, 154 archived items, "
          "159 codices, 84 techniques, 5 gear; SOURCE INVENTORY ONLY — NOT gameplay QA")


if __name__ == "__main__":
    main()
