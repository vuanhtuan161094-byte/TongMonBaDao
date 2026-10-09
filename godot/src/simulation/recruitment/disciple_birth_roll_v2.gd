class_name DiscipleBirthRollV2
extends RefCounted

# DV2-01B only: born identity is immutable, consumer effects stay inactive until
# their own tested V2 systems are enabled. No legacy Stat or World RNG is consumed.
const BASE_ROOTS = ["metal", "wood", "water", "fire", "earth"]
const MUTATIONS = {"metal":"lightning","wood":"wind","water":"ice","fire":"yang","earth":"nether"}
const PURITY_EXPONENT = [0.45, 0.70, 1.0, 1.5, 2.3]
const TALENTS = ["forge_talent","miner_instinct","herbalist_affinity"]

static func populate(envelope: Dictionary, candidate: CandidateState) -> Dictionary:
    if not DiscipleBirthProfileV2.valid_envelope(envelope) or not DiscipleBirthCatalogueV2.valid_catalogue():
        return {}
    var profile: Dictionary = envelope.duplicate(true)
    var seeds: Dictionary = profile["domain_seeds"]
    var layers: Dictionary = profile["layers"]
    var roots := _roll_roots(GameRng.new(int(seeds["spiritual_root"])))
    var mutation := _roll_mutation(GameRng.new(int(seeds["root_mutation"])), roots)
    layers["spiritual_root"] = roots
    layers["root_mutation"] = mutation
    layers["traits"] = _roll_traits(
        GameRng.new(int(seeds["trait_count"])),
        GameRng.new(int(seeds["trait_identity"])),
        GameRng.new(int(seeds["trait_latent"]))
    )
    layers["bloodline"] = _roll_bloodline(GameRng.new(int(seeds["bloodline"])))
    layers["physique"] = _roll_physique(GameRng.new(int(seeds["physique"])))
    layers["destiny"] = _roll_destiny(
        GameRng.new(int(seeds["destiny_presence"])),
        GameRng.new(int(seeds["destiny_identity"])),
        GameRng.new(int(seeds["destiny_reveal"]))
    )
    profile["layers"] = layers
    sync_profession_talent(profile, candidate)
    return profile

# Strict intake contract: never accept a partially initialized profile just
# because its envelope has version/seeds. This also rejects post-toggle old candidates.
static func valid_complete_birth(profile: Dictionary) -> bool:
    if not DiscipleBirthProfileV2.valid_envelope(profile):
        return false
    var layers: Dictionary = profile["layers"]
    for layer_id in DiscipleBirthProfileV2.UNINITIALIZED_LAYERS:
        var row = layers.get(layer_id, {})
        if not (row is Dictionary) or not bool(row.get("initialized", false)):
            return false
    var roots: Dictionary = layers["spiritual_root"].get("birth_values", {})
    if roots.is_empty() or roots.size() > 5:
        return false
    for root_id in roots:
        if not BASE_ROOTS.has(str(root_id)) or int(roots[root_id]) < 1 or int(roots[root_id]) > 100:
            return false
    var traits: Dictionary = layers["traits"]
    var visible: Array = traits.get("visible", [])
    var latent: Array = traits.get("latent", [])
    if visible.size() < 1 or visible.size() > 3 or latent.size() > 1:
        return false
    var chosen: Array = []
    for trait in visible + latent:
        if not (trait is Dictionary):
            return false
        var trait_id := str(trait.get("id", ""))
        if chosen.has(trait_id) or DiscipleBirthCatalogueV2.conflicts_with(trait_id, chosen):
            return false
        if DiscipleBirthCatalogueV2.TRAIT_BIRTH_EXCLUSIONS.has(trait_id):
            return false
        if not ["H", "S", "B"].has(str(trait.get("nature", ""))):
            return false
        if bool(trait.get("active", true)) or trait.has("grade"):
            return false
        chosen.append(trait_id)
    var physical_id := str(layers["physique"].get("physique_id", ""))
    if physical_id == "kiem_cot" or physical_id == "":
        return false
    var fate_id := str(layers["destiny"].get("destiny_id", ""))
    if fate_id == "" or DiscipleBirthCatalogueV2.FATE_BIRTH_EXCLUSIONS.has(fate_id):
        return false
    return true

static func sync_profession_talent(profile: Dictionary, candidate: CandidateState) -> void:
    if not DiscipleBirthProfileV2.valid_envelope(profile):
        return
    var talents: Dictionary = {}
    for id_value in candidate.profession_traits:
        var id := str(id_value)
        if TALENTS.has(id):
            talents[id] = int(candidate.profession_trait_grades.get(id, 1))
    profile["layers"]["profession_talent"] = {
        "initialized": true,
        "talents": talents
    }

static func _roll_roots(rng: GameRng) -> Dictionary:
    var roll := rng.randi_range(0, 99)
    var count := 1
    if roll >= 7 and roll < 25:
        count = 2
    elif roll >= 25 and roll < 55:
        count = 3
    elif roll >= 55 and roll < 83:
        count = 4
    elif roll >= 83:
        count = 5
    var remaining: Array = BASE_ROOTS.duplicate()
    var birth: Dictionary = {}
    for step in range(count):
        var index := rng.randi_range(0, remaining.size() - 1)
        var root := str(remaining[index])
        remaining.remove_at(index)
        var purity := clampi(int(round(100.0 * pow(rng.randf(), PURITY_EXPONENT[count-1]))), 1, 100)
        birth[root] = purity
    return {"initialized":true,"birth_values":birth.duplicate(true),"current_values":birth.duplicate(true)}

static func _roll_mutation(rng: GameRng, roots: Dictionary) -> Dictionary:
    var event := rng.randi_range(0, 9999)
    if event >= 20:
        return {"initialized":true,"mutation_id":"none"}
    var elements: Array = roots["birth_values"].keys()
    elements.sort()
    var element := str(elements[rng.randi_range(0,elements.size()-1)])
    var born_awakened := event == 0
    var root_values: Dictionary = roots["birth_values"]
    if born_awakened:
        root_values[element] = maxi(int(root_values[element]), 80)
        roots["current_values"][element] = root_values[element]
    var revealed := born_awakened or int(root_values[element]) >= 70
    return {
        "initialized":true,
        "mutation_id":str(MUTATIONS[element]),
        "base_element":element,
        "origin":"birth_awakened" if born_awakened else "birth_latent",
        "mutation_realm":"awakened" if born_awakened else "latent",
        "revealed":revealed,
        "active":false
    }

static func _roll_nature(rng: GameRng) -> String:
    var roll := rng.randi_range(0,99)
    if roll < 50:
        return "H"
    if roll < 80:
        return "S"
    return "B"

static func _trait_record(trait_id: String, nature: String) -> Dictionary:
    return {"id":trait_id,"nature":nature,"origin":"birth","active":false}

static func _roll_traits(count_rng: GameRng, identity_rng: GameRng, latent_rng: GameRng) -> Dictionary:
    var chance := count_rng.randi_range(0,99)
    var visible_count := 1 if chance < 60 else (2 if chance < 92 else 3)
    var visible: Array = []
    var latent: Array = []
    var owned: Array = []
    for slot in range(visible_count):
        var nature := _roll_nature(identity_rng)
        var pool := DiscipleBirthCatalogueV2.weighted_trait_pool(nature, owned)
        if pool.is_empty():
            push_error("DV2-01B: empty trait nature pool; refusing fake selection.")
            return {"initialized":false}
        var trait_id := str(identity_rng.weighted_pick(pool))
        owned.append(trait_id)
        visible.append(_trait_record(trait_id, nature))
    if latent_rng.chance(0.08):
        var nature := _roll_nature(latent_rng)
        var pool := DiscipleBirthCatalogueV2.weighted_trait_pool(nature, owned)
        if pool.is_empty():
            push_error("DV2-01B: empty latent nature pool.")
            return {"initialized":false}
        var trait_id := str(latent_rng.weighted_pick(pool))
        latent.append(_trait_record(trait_id, nature))
    return {"initialized":true,"visible":visible,"latent":latent}

static func _roll_bloodline(rng: GameRng) -> Dictionary:
    var event := rng.randi_range(0,9999)
    if event >= 200:
        return {"initialized":true,"bloodline_id":"none"}
    var bloodline_id := str(DiscipleBirthCatalogueV2.BLOODLINES[rng.randi_range(
        0,DiscipleBirthCatalogueV2.BLOODLINES.size()-1
    )])
    var purity := clampi(int(round(100.0 * pow(rng.randf(),2.0))),1,100)
    return {
        "initialized":true,"bloodline_id":bloodline_id,"birth_purity":purity,
        "current_purity":purity,"revealed":event < 40,
        "awakened":false,"active":false
    }

static func _roll_physique(rng: GameRng) -> Dictionary:
    var event := rng.randi_range(0,9999)
    if event >= 300:
        return {"initialized":true,"physique_id":"none"}
    var pool: Dictionary = {}
    for row in DiscipleBirthCatalogueV2.PHYSIQUES:
        pool[str(row[0])] = int(row[1])
    var identity := str(rng.weighted_pick(pool))
    return {"initialized":true,"physique_id":identity,"revealed":event < 270,
        "active":false,"origin":"birth"}

static func _roll_destiny(presence_rng: GameRng, identity_rng: GameRng, reveal_rng: GameRng) -> Dictionary:
    if presence_rng.randi_range(0,9999) >= 50:
        return {"initialized":true,"destiny_id":"none"}
    var pool := DiscipleBirthCatalogueV2.weighted_fate_pool()
    if pool.is_empty():
        push_error("DV2-01B: empty eligible Destiny pool.")
        return {"initialized":false}
    var identity := str(identity_rng.weighted_pick(pool))
    return {"initialized":true,"destiny_id":identity,
        "revealed":reveal_rng.randi_range(0,9)==0,"origin":"birth","active":false}
