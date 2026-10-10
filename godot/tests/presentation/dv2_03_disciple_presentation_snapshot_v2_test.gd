extends SceneTree

const TEST_SEED := 26101002

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _recruit_v2(state: SimulationState, generation_index: int) -> DiscipleState:
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,generation_index
    )
    if candidate == null:
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples.get(candidate.id)

func _run() -> void:
    var state := P37Factory.create_state(TEST_SEED)
    var legacy_ids: Array = state.disciples.keys()
    legacy_ids.sort()
    if legacy_ids.is_empty():
        _fail("Snapshot test requires one legacy founder.")
        return

    var legacy: DiscipleState = state.disciples[legacy_ids[0]]
    var legacy_snapshot := DisciplePresentationSnapshotV2.build(state,legacy)
    if not bool(legacy_snapshot.get("ok",false)):
        _fail("Legacy compatibility snapshot failed.")
        return
    if bool(legacy_snapshot.get("authentic_v2",true)):
        _fail("Legacy founder was mislabeled authentic V2.")
        return
    if str(legacy_snapshot.get("authority","")) != "legacy_compatibility":
        _fail("Legacy snapshot does not expose compatibility authority.")
        return
    if str(legacy_snapshot["progression"].get("authority","")) != "legacy_p2":
        _fail("Legacy progression branch was not explicit.")
        return

    var disciple := _recruit_v2(state,901)
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        _fail("Could not recruit a complete authentic V2 disciple.")
        return

    # Install known hidden identities without changing their reveal state. The
    # UI-facing snapshot must not leak any of these stable IDs or hidden values.
    var layers: Dictionary = disciple.v2_birth_profile["layers"]
    var root_ids: Array = layers["spiritual_root"]["current_values"].keys()
    root_ids.sort()
    var base_root := str(root_ids[0])
    var mutation_for_root := {
        "metal":"lightning","wood":"wind","water":"ice","fire":"yang","earth":"nether"
    }
    var hidden_mutation := str(mutation_for_root[base_root])
    layers["root_mutation"] = {
        "initialized":true,
        "mutation_id":hidden_mutation,
        "base_element":base_root,
        "origin":"birth_latent",
        "mutation_realm":"latent",
        "revealed":false,
        "active":false
    }
    layers["traits"] = {
        "initialized":true,
        "visible":[{"id":"ham_hoc","nature":"H","origin":"birth","active":false}],
        "latent":[{"id":"tap_niem","nature":"B","origin":"birth","active":false}]
    }
    layers["bloodline"] = {
        "initialized":true,
        "bloodline_id":"chan_long_huyet",
        "birth_purity":88,
        "current_purity":91,
        "revealed":false,
        "awakened":false,
        "active":false
    }
    layers["physique"] = {
        "initialized":true,
        "physique_id":"kim_cuong_ba_the",
        "revealed":false,
        "active":false,
        "origin":"birth"
    }
    layers["destiny"] = {
        "initialized":true,
        "destiny_id":"pha_quan",
        "revealed":false,
        "origin":"birth",
        "active":false
    }
    disciple.v2_birth_profile["layers"] = layers

    if not DiscipleBirthProfileV2.valid_complete_birth(disciple.v2_birth_profile):
        _fail("Hidden-identity fixture became an invalid V2 birth.")
        return

    var before := state.to_dict().duplicate(true)
    var snapshot := DisciplePresentationSnapshotV2.build(state,disciple)
    if before != state.to_dict():
        _fail("Presentation snapshot mutated simulation state.")
        return
    if not bool(snapshot.get("ok",false)) or not bool(snapshot.get("authentic_v2",false)):
        _fail("Authentic V2 snapshot was not produced.")
        return
    if str(snapshot.get("authority","")) != "authentic_v2":
        _fail("Authentic V2 snapshot authority is wrong.")
        return

    var foundations: Dictionary = snapshot["foundations"]["current"]
    if absf(float(foundations["aptitude"])-disciple.aptitude) > 0.000001:
        _fail("Snapshot changed Tư Chất.")
        return
    if absf(float(foundations["constitution"])-disciple.constitution) > 0.000001:
        _fail("Snapshot changed Căn Cốt.")
        return
    if absf(float(foundations["comprehension"])-disciple.comprehension) > 0.000001:
        _fail("Snapshot changed Thông Tuệ.")
        return
    if absf(float(foundations["potential"])-disciple.potential) > 0.000001:
        _fail("Snapshot changed Tiềm Lực.")
        return

    var progression: Dictionary = snapshot["progression"]
    if not bool(progression.get("ready",false)):
        _fail("Authentic V2 progression snapshot is not ready.")
        return
    var cultivation: Dictionary = progression["cultivation"]
    var body: Dictionary = progression["body"]
    if str(cultivation["name"]) != "Phàm Nhân" or int(cultivation["floor"]) != 1:
        _fail("Snapshot did not read fresh V2 Tu Vi coordinate.")
        return
    if str(body["name"]) != "Phàm Thân" or int(body["floor"]) != 1:
        _fail("Snapshot did not read fresh V2 Luyện Thể coordinate.")
        return
    if int(cultivation["required_xp"]) != DiscipleProgressionBalanceV2.floor_cost(1,1):
        _fail("Snapshot invented a Tu Vi floor cost.")
        return
    if int(body["required_xp"]) != DiscipleProgressionBalanceV2.floor_cost(1,1):
        _fail("Snapshot invented a Body floor cost.")
        return

    var combat: Dictionary = snapshot["combat"]
    if not bool(combat.get("ready",false)) or str(combat.get("authority","")) != "combat_stats_v2":
        _fail("Snapshot did not use CombatStatsV2 authority.")
        return
    var stats: Dictionary = combat["stats"]
    if absf(float(stats["max_hp"])-disciple.max_hp) > 0.0001:
        _fail("Snapshot V2 Max HP differs from live V2 HP authority.")
        return
    if float(stats["attack"]) <= 0.0 or float(stats["defense"]) <= 0.0:
        _fail("Snapshot lost canonical V2 core combat stats.")
        return
    if not (combat.get("applied_sources",[]) as Array).is_empty():
        _fail("Step 2 silently activated unimplemented V2 innate/equipment combat sources.")
        return

    var innate: Dictionary = snapshot["innate"]
    var visible_traits: Array = innate["traits"]["visible"]
    if visible_traits.size() != 1 or str(visible_traits[0].get("name","")) != "Ham Học":
        _fail("Snapshot did not expose the real visible V2 Trait.")
        return
    var serialized := JSON.stringify(snapshot)
    for secret in [
        "tap_niem",
        "chan_long_huyet",
        "kim_cuong_ba_the",
        "pha_quan"
    ]:
        if serialized.contains(secret):
            _fail("Snapshot leaked hidden V2 identity: " + secret)
            return
    var hidden_mutation_row: Dictionary = innate["spiritual_root"]["mutation"]
    if str(hidden_mutation_row.get("status","")) != "unrevealed":
        _fail("Hidden Root Mutation did not collapse to unrevealed.")
        return
    if hidden_mutation_row.has("id") or hidden_mutation_row.has("base_element") or hidden_mutation_row.has("realm"):
        _fail("Hidden Root Mutation identity/provenance leaked into the snapshot.")
        return
    var hidden_bloodline_row: Dictionary = innate["bloodline"]
    if str(hidden_bloodline_row.get("status","")) != "unrevealed":
        _fail("Hidden Bloodline did not collapse to unrevealed.")
        return
    if hidden_bloodline_row.has("birth_purity") or hidden_bloodline_row.has("current_purity"):
        _fail("Hidden Bloodline purity leaked into the snapshot.")
        return
    if str(innate["physique"].get("status","")) != "unrevealed":
        _fail("Hidden Physique did not collapse to unrevealed.")
        return
    if str(innate["destiny"].get("status","")) != "unrevealed":
        _fail("Hidden Destiny did not collapse to unrevealed.")
        return
    # An authentic V2 identity with malformed progression must fail closed in the
    # snapshot. It must not display the legacy P2 stage/combat fallback.
    var malformed := disciple.v2_realm_progress.duplicate(true)
    disciple.v2_realm_progress["cultivation"]["realm"] = 99
    var broken := DisciplePresentationSnapshotV2.build(state,disciple)
    if not bool(broken.get("authentic_v2",false)):
        _fail("Malformed progression incorrectly removed V2 identity ownership.")
        return
    if bool(broken["progression"].get("ready",true)):
        _fail("Malformed V2 progression did not fail closed.")
        return
    if str(broken["progression"].get("authority","")) != "v2_realm_progress":
        _fail("Malformed V2 progression fell back to P2.")
        return
    if bool(broken["combat"].get("ready",true)):
        _fail("Malformed V2 progression produced fake combat stats.")
        return
    disciple.v2_realm_progress = malformed

    print("DV2-03 DISCIPLE PRESENTATION SNAPSHOT V2: PASS")
    quit(0)
