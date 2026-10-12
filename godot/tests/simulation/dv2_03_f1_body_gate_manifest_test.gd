extends SceneTree

# DV2-03F/F1: static manifest/registry and old-save compatibility ONLY.
# Never approves requirements, consumes resources, grants drops or advances Body.
const EXPECTED_ROWS := [
    ["A",12,4],["A",18,5],["A",24,6],
    ["B",12,1],["B",16,2],["B",24,3],
    ["C",12,3],["C",16,4],["C",22,6],["C",32,8],
    ["D",12,3],["D",16,4],["D",20,5],["D",24,6],
    ["E",12,3],["E",16,4],["E",22,6],
    ["F",14,4],["F",20,6],["F",30,9],
    ["G",12,3],["G",16,4],["G",20,5],["G",24,6],["G",30,8],
    ["H",12,3],["H",18,5],["H",24,7],["H",32,10]
]
const EXPECTED_ITEMS := {
    "A":["thanh_linh_thao","tinh_lang_bi"],
    "B":["tu_van_thao","linh_tuy"],
    "C":["huyet_linh_sam","huyet_thu_tinh_huyet"],
    "D":["kim_cot_thao","linh_thu_cot_ngoc"],
    "E":["tien_tuy_lien","tien_thu_chan_cot"],
    "F":["bat_hoai_tuy_dich","dai_la_kim_cot"],
    "G":["than_mach_tinh","than_thu_cot"],
    "H":["hon_don_tuy_hoa","bat_diet_than_cot"]
}
const EXPECTED_SEALS := {10:"an_nhan_gioi",20:"an_tien_gioi",29:"an_than_gioi"}

func _init() -> void:
    call_deferred("_run")

func _require(yes: bool, reason: String) -> bool:
    if not yes:
        push_error("DV2-03F/F1: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var content := DiscipleBodyGateContentV2.new()
    var registry := ResourceRegistry.new()
    var validated := content.validate()
    if not _require(bool(validated.get("ok",false)),
        "Canonical F1 manifest+registry cannot validate: %s" % str(validated)):
        return

    var manifest: Array = content.all_recipes()
    if not _require(manifest.size()==29 and EXPECTED_ROWS.size()==29 and
        content.material_ids().size()==19,
        "29 rows or 19 typed IDs missing."):
        return
    var sum_main := 0
    var sum_aux := 0
    var sum_seal := 0
    var sums: Dictionary = {}
    var actual_seals: Dictionary = {}
    for source_realm in range(1,30):
        var row: Dictionary = content.recipe(source_realm)
        var expected: Array = EXPECTED_ROWS[source_realm-1]
        var group := str(expected[0])
        var pair: Array = EXPECTED_ITEMS[group]
        var expected_seal := str(EXPECTED_SEALS.get(source_realm,""))
        if not _require(int(row["version"])==1 and
            int(row["source_realm"])==source_realm and
            int(row["target_realm"])==source_realm+1 and
            str(row["group"])==group and
            str(row["main_id"])==str(pair[0]) and
            int(row["main_qty"])==int(expected[1]) and
            str(row["aux_id"])==str(pair[1]) and
            int(row["aux_qty"])==int(expected[2]) and
            str(row["seal_id"])==expected_seal and
            int(row["seal_qty"])==(1 if not expected_seal.is_empty() else 0),
            "Authored source realm %d differs from approved 29-row ledger." % source_realm):
            return
        if not _require(not bool(row["content_available"]) and
            str(row["reason"])=="content_unavailable",
            "F1 illegally activated an unimplemented Body gate."):
            return
        sum_main += int(row["main_qty"])
        sum_aux += int(row["aux_qty"])
        sum_seal += int(row["seal_qty"])
        if not sums.has(group):
            sums[group] = [0,0]
        sums[group][0] = int(sums[group][0]) + int(row["main_qty"])
        sums[group][1] = int(sums[group][1]) + int(row["aux_qty"])
        if not expected_seal.is_empty():
            actual_seals[source_realm] = str(row["seal_id"])
    var expected_sums := {
        "A":[54,15],"B":[52,6],"C":[82,21],"D":[72,18],
        "E":[50,13],"F":[64,19],"G":[102,26],"H":[86,25]
    }
    if not _require(sum_main==562 and sum_aux==143 and sum_seal==3 and
        sums==expected_sums and actual_seals==EXPECTED_SEALS,
        "Per-group ledger totals or exact 10/20/29 seals changed."):
        return
    if not _require(content.recipe(0).is_empty() and
        content.recipe(30).is_empty() and
        content.validate_manifest(manifest).get("ok",false),
        "Manifest bounds or normalization invalid."):
        return
    # F1 content cannot be mutated by a caller's returned reference.
    var first := content.recipe(1)
    first["main_qty"] = 999
    if not _require(int(content.recipe(1)["main_qty"])==12,
        "A caller mutated the canonical F1 manifest."):
        return

    # Malformed/modified catalogue FAILS CLOSED even if totals are unchanged.
    var shortened := manifest.duplicate(true)
    shortened.pop_back()
    if not _require(not content.validate_manifest(shortened).get("ok",true),
        "Truncated Body recipe catalogue was accepted."):
        return
    var wrong := manifest.duplicate(true)
    wrong[3]["main_id"] = "thanh_linh_thao"
    if not _require(not content.validate_manifest(wrong).get("ok",true),
        "Body gate 4 accepted the wrong item identity."):
        return
    var float_quantity := manifest.duplicate(true)
    float_quantity[0]["main_qty"] = 12.0
    if not _require(not content.validate_manifest(float_quantity).get("ok",true),
        "Manifest accepted non-integer quantities."):
        return
    var extra := manifest.duplicate(true)
    extra[0]["requirements_verified"] = true
    if not _require(not content.validate_manifest(extra).get("ok",true),
        "Manifest accepted an unauthorized requirements-verified field."):
        return
    var bad_version := manifest.duplicate(true)
    bad_version[0]["version"] = 2
    if not _require(not content.validate_manifest(bad_version).get("ok",true),
        "Versioned F1 catalogue accepted mismatched version."):
        return
    if not _require(not content.validate_manifest({}).get("ok",true),
        "Non-array catalogue accepted."):
        return

    # Four existing A/B identities must remain intact. F1 only registers
    # twelve new C-H + three realm seals: no fake high-tier drops.
    var preexisting := {
        "thanh_linh_thao":6,
        "tinh_lang_bi":10,
        "tu_van_thao":16,
        "linh_tuy":14
    }
    for id in preexisting:
        if not _require(registry.has(StringName(id)) and
            int(registry.definition(StringName(id))["market_value"])==int(preexisting[id]),
            "F1 altered one of the four original A/B resources."):
            return
    var high_items: Array = []
    for group in ["C","D","E","F","G","H"]:
        for id in EXPECTED_ITEMS[group]:
            high_items.append(str(id))
    # F1 owns the exact 19 Body material identities, not the size of the
    # global ResourceRegistry. Later unrelated systems may add canonical
    # resources (for example O8 Hồi Xuân Đan) without changing this locked
    # Body catalogue.
    var protected_body_ids: Array[String] = []
    for group in ["A","B","C","D","E","F","G","H"]:
        for id in EXPECTED_ITEMS[group]:
            if not protected_body_ids.has(str(id)):
                protected_body_ids.append(str(id))
    for seal in EXPECTED_SEALS.values():
        if not protected_body_ids.has(str(seal)):
            protected_body_ids.append(str(seal))
    protected_body_ids.sort()
    var manifest_ids: Array[String] = []
    for id in content.material_ids():
        manifest_ids.append(str(id))
    manifest_ids.sort()
    if not _require(
        high_items.size()==12
        and protected_body_ids.size()==19
        and manifest_ids==protected_body_ids
        and registry.validate_definitions().is_empty(),
        "Registry no longer preserves the exact 19 protected Body material identities."):
        return
    for id in high_items:
        if not _require(registry.has(StringName(id)) and
            registry.has_tag(StringName(id),&"body_gate_material") and
            int(registry.definition(StringName(id))["market_value"])==0,
            "High-tier resource absent or given an unapproved price."):
            return
    for seal in EXPECTED_SEALS.values():
        if not _require(registry.has(StringName(seal)) and
            registry.has_tag(StringName(seal),&"body_gate_seal") and
            int(registry.definition(StringName(seal))["market_value"])==0,
            "Realm seal not registered with correct closed metadata."):
            return

    # Existing maps still contain only existing drops, with no new C-H/seal
    # source artificially installed as a side effect of registration.
    for map_id in HuntingMapV2.REGION_CONTENT.keys():
        var region: Dictionary = HuntingMapV2.REGION_CONTENT[map_id]
        for resource_id in region["resources"].keys():
            if not _require(not high_items.has(str(resource_id)) and
                not EXPECTED_SEALS.values().has(str(resource_id)),
                "F1 accidentally enabled a new high-tier map reward."):
                return
        if not _require(not high_items.has(str(region["rare"])) and
            not EXPECTED_SEALS.values().has(str(region["rare"])),
            "F1 accidentally enabled a high-tier rare drop."):
            return

    # Old P3.7 save round-trip MUST NOT invent F1 receipts, source counters,
    # items or gate-completions. A purely QA-created stack of a new registered
    # ID can persist via the existing Sect warehouse (not a loot payout).
    var state := P37Factory.create_state(309001)
    var before := JSON.stringify(state.to_dict())
    var saved := SimulationState.from_dict(JSON.parse_string(before))
    if not _require(saved!=null and saved.sect.warehouse_resources==
        state.sect.warehouse_resources and
        saved.sect.v2_pve_reward_claims==state.sect.v2_pve_reward_claims,
        "Existing game save was changed by F1 registration."):
        return
    var warehouse := WarehouseSystem.new()
    if not _require(warehouse.quantity(saved,&"an_nhan_gioi")==0 and
        warehouse.quantity(saved,&"huyet_linh_sam")==0,
        "F1 fabricated new resources for an old save."):
        return
    if not _require(warehouse.add(saved,&"huyet_linh_sam",7) and
        warehouse.add(saved,&"an_nhan_gioi",1),
        "QA fixture could not store newly typed material/Seal in canonical warehouse."):
        return
    var restored := SimulationState.from_dict(
        JSON.parse_string(JSON.stringify(saved.to_dict()))
    )
    if not _require(restored!=null and
        warehouse.quantity(restored,&"huyet_linh_sam")==7 and
        warehouse.quantity(restored,&"an_nhan_gioi")==1,
        "A new registered ID failed an actual state round-trip."):
        return

    print("DV2-03F F1 MANIFEST AND TYPED RESOURCE REGISTRY: PASS; ",
        "gates=29,main=562,aux=143,seals=3,item_ids=19,new_ids=15")
    quit(0)
