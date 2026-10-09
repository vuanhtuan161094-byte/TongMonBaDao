extends SceneTree

# Focused distribution and determinism check. Sample rates use independent profile
# seeds. Do not compare exact RNG counts to theoretical probabilities.
const SAMPLE_COUNT := 100000
const COUNT_LIMITS := [1,2,3,4,5]
const EXPECTED_ROOTS := [0.07,0.18,0.30,0.28,0.17]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not DiscipleBirthCatalogueV2.valid_catalogue():
        _fail("V2 catalogue does not have 101 unique Traits/24 Fates.")
        return
    var roots := [0,0,0,0,0]
    var trait_counts := [0,0,0]
    var nature_counts := {"H":0,"S":0,"B":0}
    var n_slots := 0
    var latent_traits := 0
    var mutations := 0
    var awakened_mutations := 0
    var bloodlines := 0
    var physiques := 0
    var destiny := 0
    for index in range(1,SAMPLE_COUNT+1):
        var candidate := CandidateState.new({
            "id":"distribution_%d" % index,
            "profile_seed":100013 + index * 19,
            "generated_index":index,
            "recruitment_source":"ordinary"
        })
        var birth := DiscipleBirthRollV2.populate(DiscipleBirthProfileV2.create_envelope(candidate),candidate)
        if birth.is_empty():
            _fail("V2 whole-person birth returned empty.")
            return
        var layers: Dictionary = birth["layers"]
        for name in DiscipleBirthProfileV2.UNINITIALIZED_LAYERS:
            if not bool(layers[name].get("initialized",false)):
                _fail("Layer " + str(name) + " was not born.")
                return
        var root_values: Dictionary = layers["spiritual_root"]["birth_values"]
        var count := root_values.size()
        if count < 1 or count > 5:
            _fail("Invalid number of roots.")
            return
        roots[count-1] += 1
        for value in root_values.values():
            if int(value) < 1 or int(value) > 100:
                _fail("Invalid root purity.")
                return
        var mutation: Dictionary = layers["root_mutation"]
        if mutation["mutation_id"] != "none":
            mutations += 1
            var origin := str(mutation["base_element"])
            if not root_values.has(origin):
                _fail("Mutation was born on a root that does not exist.")
                return
            if mutation["mutation_realm"] == "awakened":
                awakened_mutations += 1
                if int(root_values[origin]) < 80 or not bool(mutation["revealed"]):
                    _fail("Congenital awakened mutation lacks valid birth override.")
                    return
            elif bool(mutation["revealed"]) != (int(root_values[origin]) >= 70):
                _fail("Latent mutation reveal does not reflect actual root purity.")
                return
        var trait_layer: Dictionary = layers["traits"]
        var visibles: Array = trait_layer["visible"]
        var latents: Array = trait_layer["latent"]
        if visibles.size() < 1 or visibles.size() > 3 or latents.size() > 1:
            _fail("Wrong visible/latent Trait count.")
            return
        trait_counts[visibles.size()-1] += 1
        latent_traits += latents.size()
        var owned: Array = []
        for row in visibles + latents:
            if row.has("grade") or bool(row.get("active",true)):
                _fail("Trait V2 has a grade or falsely active effect.")
                return
            var identity := str(row["id"])
            if DiscipleBirthCatalogueV2.conflicts_with(identity,owned) or owned.has(identity):
                _fail("Traits conflict or repeat at birth.")
                return
            owned.append(identity)
        for row in visibles:
            nature_counts[str(row["nature"])] += 1
            n_slots += 1
        if str(layers["bloodline"]["bloodline_id"]) != "none":
            bloodlines += 1
            var purity := int(layers["bloodline"]["birth_purity"])
            if purity < 1 or purity > 100 or bool(layers["bloodline"]["awakened"]):
                _fail("Invalid congenital Bloodline origin/purity.")
                return
        if str(layers["physique"]["physique_id"]) != "none":
            physiques += 1
            if str(layers["physique"]["physique_id"]) == "kiem_cot":
                _fail("A forbidden Kiếm Cốt was born.")
                return
        if str(layers["destiny"]["destiny_id"]) != "none":
            destiny += 1
            if str(layers["destiny"]["destiny_id"]) == "kiem_tien_chuyen_the":
                _fail("Fate with an unspecified birth override entered the pool.")
                return
    for i in range(5):
        if not _near(roots[i],SAMPLE_COUNT*float(EXPECTED_ROOTS[i]),0.02*SAMPLE_COUNT):
            _fail("Root count %d distribution outside 2pp tolerance: %d" % [i+1,roots[i]])
            return
    for i in range(3):
        var expected: float = float([0.60,0.32,0.08][i])
        if not _near(trait_counts[i],SAMPLE_COUNT*expected,0.02*SAMPLE_COUNT):
            _fail("Visible trait-count rate outside 2pp tolerance.")
            return
    for key in ["H","S","B"]:
        var target := float({"H":0.50,"S":0.30,"B":0.20}[key])
        if not _near(int(nature_counts[key]),n_slots*target,0.025*n_slots):
            _fail("Trait nature rates outside 2.5pp tolerance.")
            return
    if not _near(latent_traits,0.08*SAMPLE_COUNT,0.02*SAMPLE_COUNT):
        _fail("Latent Trait rate outside 2pp tolerance.")
        return
    if not _near(bloodlines,0.02*SAMPLE_COUNT,0.012*SAMPLE_COUNT):
        _fail("Bloodline rate outside 1.2pp tolerance.")
        return
    if not _near(physiques,0.03*SAMPLE_COUNT,0.012*SAMPLE_COUNT):
        _fail("Physique rate outside 1.2pp tolerance.")
        return
    if not _near(destiny,0.005*SAMPLE_COUNT,0.004*SAMPLE_COUNT):
        _fail("Fate rate outside 0.4pp tolerance.")
        return
    if not _near(mutations,0.002*SAMPLE_COUNT,0.002*SAMPLE_COUNT):
        _fail("Mutation rate outside 0.2pp tolerance.")
        return
    if awakened_mutations > mutations:
        _fail("Impossible awakened count.")
        return
    print("DV2-01B 100K FULL INNATE BIRTH DISTRIBUTION TEST PASS")
    print("roots=",roots," traits=",trait_counts," latent=",latent_traits,
        " blood=",bloodlines," physique=",physiques," fate=",destiny,
        " mutation=",mutations," awakened=",awakened_mutations)
    quit(0)

func _near(value: int,target: float,tolerance: float) -> bool:
    return absf(float(value)-target) <= tolerance

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
