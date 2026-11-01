extends SceneTree

# DD-07: fail-closed Hall/Residence save migration and .bak recovery.
# Isolated QA profile only; NEVER use a player's live save path.
# Official Godot 4.7.2: --headless --path godot --script res://tests/dai_dien_dd07_save_recovery_test.gd

const QA_SAVE := "user://qa_dd07_hall_recovery_20261101.json"

func _initialize() -> void:
    call_deferred("_run")

func _expect(works: bool, description: String) -> bool:
    if works:
        return true
    push_error("DD07_SAVE_RECOVERY_FAIL: " + description)
    quit(1)
    return false

func _cleanup() -> void:
    for extension in ["", ".tmp", ".bak"]:
        var exact := ProjectSettings.globalize_path(QA_SAVE + extension)
        if FileAccess.file_exists(QA_SAVE + extension):
            DirAccess.remove_absolute(exact)

func _run() -> void:
    var state := P37Factory.create_state(20261101)
    if not _expect(bool(SectHallSystemV1.ensure_live(state).get("ok", false)),
            "initial Hall/Residence grant"):
        return

    # Missing governance key means legacy; unsupported explicit key MUST remain
    # visible to the caller and must fail validation, not reset to Nhân 1.
    var original := state.sect.to_dict()
    var unsupported := original.duplicate(true)
    var wrong: Dictionary = unsupported["hall_governance"]
    wrong["version"] = 999
    unsupported["hall_governance"] = wrong
    var parsed := SectState.from_dict(unsupported)
    if not _expect(int(parsed.hall_governance.get("version", 0)) == 999,
            "SectState silently dropped unsupported governance version"):
        return
    var wrong_state := SimulationState.from_dict(state.to_dict())
    wrong_state.sect = parsed
    if not _expect(not SectHallSystemV1.validate(wrong_state).is_empty()
            and not bool(SectHallSystemV1.ensure_live(wrong_state).get("ok", true)),
            "unknown Hall schema must reject migration"):
        return
    var malformed := original.duplicate(true)
    malformed["hall_governance"] = "broken"
    if not _expect(not SectState.from_dict(malformed).hall_governance.is_empty(),
            "invalid Hall payload type must not be interpreted as legacy"):
        return
    var legacy := original.duplicate(true)
    legacy.erase("hall_governance")
    if not _expect(SectState.from_dict(legacy).hall_governance.is_empty(),
            "actual legacy save must remain eligible for explicit migration"):
        return

    var orphan_hall := SimulationState.from_dict(state.to_dict())
    orphan_hall.buildings.erase("main_hall_001")
    if not _expect(not bool(SectHallSystemV1.ensure_live(orphan_hall).get("ok", true))
            and not orphan_hall.buildings.has("main_hall_001"),
            "orphaned persisted Hall must not silently recreate a free Hall"):
        return
    var orphan_house := SimulationState.from_dict(state.to_dict())
    orphan_house.buildings.erase("residence_001")
    if not _expect(not bool(SectResidenceSystemV1.ensure_live(orphan_house).get("ok", true))
            and not orphan_house.buildings.has("residence_001"),
            "orphaned saved House must not reset silently to Lv1"):
        return

    # Both economic receipt ledgers are part of the durable state contract.
    # A phantom house or a future-rank paid receipt must never validate.
    var bad_house_receipt := SimulationState.from_dict(state.to_dict())
    bad_house_receipt.sect.hall_governance["residence_build_receipts"] = {
        "fake-request": "residence_099"
    }
    if not _expect(not SectHallSystemV1.validate(bad_house_receipt).is_empty(),
            "phantom paid House receipt must fail validation"):
        return
    var bad_promotion_receipt := SimulationState.from_dict(state.to_dict())
    bad_promotion_receipt.sect.hall_governance["promotion_receipts"] = {
        "fake-promotion": 27
    }
    if not _expect(not SectHallSystemV1.validate(bad_promotion_receipt).is_empty(),
            "future paid promotion receipt must fail validation"):
        return

    # DD-08: malformed office dictionary must be an ordinary validation
    # error, never an unsafe holder_id() cast. No partial migration grants.
    var broken_assignments := SimulationState.from_dict(state.to_dict())
    broken_assignments.sect.hall_governance["assignments"] = "wrong-type"
    if not _expect(not SectHallSystemV1.validate(broken_assignments).is_empty(),
            "malformed saved officer ledger must fail without throwing"):
        return
    var missing_second_receipt := SimulationState.from_dict(state.to_dict())
    var fake_house := BuildingSystem.new().create_building(BuildingSystem.TYPE_RESIDENCE, 2)
    missing_second_receipt.buildings[str(fake_house.id)] = fake_house
    if not _expect(not SectHallSystemV1.validate(missing_second_receipt).is_empty(),
            "unpaid nonstarter House must not validate as a paid building"):
        return
    var corrupt_credit := SimulationState.from_dict(state.to_dict())
    corrupt_credit.sect.hall_governance["legacy_bed_credit"] = "not-an-integer"
    if not _expect(not SectHallSystemV1.validate(corrupt_credit).is_empty(),
            "saved legacy bed credit type must fail closed"):
        return

    # DD-08: lossless V2 decode rejects duplicate raw IDs BEFORE converting
    # the rows into a Dictionary, which otherwise discards the older owner.
    var wire: Dictionary = state.to_dict()
    wire["save_version"] = SaveService.CURRENT_VERSION
    var verifier := SaveService.new()
    if not _expect(verifier._is_payload_shape_valid(wire),
            "valid Hall V2 wire payload rejected by strict shape gate"):
        return
    var duplicate_house_wire := wire.duplicate(true)
    var house_rows: Array = duplicate_house_wire["buildings"]
    house_rows.append(house_rows[0].duplicate(true))
    duplicate_house_wire["buildings"] = house_rows
    if not _expect(not verifier._is_payload_shape_valid(duplicate_house_wire),
            "decoder would silently overwrite duplicate building IDs"):
        return
    var duplicate_disciple_wire := wire.duplicate(true)
    var disciple_rows: Array = duplicate_disciple_wire["disciples"]
    disciple_rows.append(disciple_rows[0].duplicate(true))
    duplicate_disciple_wire["disciples"] = disciple_rows
    if not _expect(not verifier._is_payload_shape_valid(duplicate_disciple_wire),
            "decoder would silently overwrite duplicate disciple IDs"):
        return

    # Two genuine saved generations establish a valid backup copy.
    _cleanup()
    var saves := SaveService.new()
    if not _expect(saves.save_to_path(state, QA_SAVE) == OK
            and saves.save_to_path(state, QA_SAVE) == OK,
            "cannot establish two valid QA save generations"):
        return
    if not _expect(FileAccess.file_exists(QA_SAVE + ".bak"),
            "a valid backup must exist before corrupt-primary test"):
        return
    # Reject writing a corrupt in-memory state without rotating the last good
    # copy; staged verification is a durable transaction boundary.
    var invalid_write := SaveService.new().save_to_path(broken_assignments, QA_SAVE)
    if not _expect(invalid_write != OK and SaveService.new().load_from_path(QA_SAVE) != null,
            "invalid in-memory Hall must never overwrite the last good save"):
        return

    # Corrupt only the isolated QA primary; leave backup pristine. The saved
    # JSON envelope (including floating-point codec and CARE tag) stays intact.
    var source := FileAccess.open(QA_SAVE, FileAccess.READ)
    if not _expect(source != null, "cannot read QA primary"):
        return
    var raw = JSON.parse_string(source.get_as_text())
    source.close()
    if not _expect(raw is Dictionary, "saved primary must be JSON dictionary"):
        return
    var envelope: Dictionary = raw
    var payload_sect: Dictionary = envelope["sect"]
    var governance: Dictionary = payload_sect["hall_governance"]
    governance["version"] = 999
    payload_sect["hall_governance"] = governance
    envelope["sect"] = payload_sect
    var writer := FileAccess.open(QA_SAVE, FileAccess.WRITE)
    if not _expect(writer != null, "cannot modify isolated QA primary"):
        return
    writer.store_string(JSON.stringify(envelope))
    writer.flush()
    writer.close()

    var restored := SaveService.new().load_from_path(QA_SAVE)
    if not _expect(restored != null and SectHallSystemV1.installed(restored)
            and SectHallSystemV1.hall(restored) != null
            and SectResidenceSystemV1.all_houses(restored).size() == 1,
            "SaveService did not reject corrupted primary and recover backup"):
        return
    if not _expect(SectHallSystemV1.validate(restored).is_empty(),
            "restored backup Hall/Residence invariants invalid"):
        return
    _cleanup()
    print("DD07_SAVE_RECOVERY_PASS unsupported_schema=1 corrupt_payload_type=1 legacy=1 orphan_hall=1 orphan_house=1 backup_recovery=1")
    quit(0)
