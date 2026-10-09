class_name DiscipleBirthProfileV2
extends RefCounted

# DV2-01A: deterministic, opt-in birth envelope only.
# Content pools are deliberately uninitialized until each V2 birth table is approved.
# This must not consume the P3.7C1 generator RNG or change its six foundations.
const PROFILE_VERSION := 1
const MODULUS := 2147483629
const BASE_ROOT_IDS := ["metal","wood","water","fire","earth"]
const MUTATION_IDS := ["lightning","wind","ice","yang","nether"]
const PROFESSION_TALENT_IDS := ["forge_talent","miner_instinct","herbalist_affinity"]
const DOMAINS := [
    "spiritual_root",
    "root_mutation",
    "profession_talent",
    "trait_count",
    "trait_identity",
    "trait_latent",
    "bloodline",
    "physique",
    "destiny_presence",
    "destiny_identity",
    "destiny_reveal"
]
const UNINITIALIZED_LAYERS := [
    "spiritual_root",
    "root_mutation",
    "profession_talent",
    "traits",
    "bloodline",
    "physique",
    "destiny"
]

static func create_envelope(candidate: CandidateState) -> Dictionary:
    if candidate.profile_seed <= 0 or candidate.generated_index <= 0 or candidate.recruitment_source == &"":
        return {}

    var seeds: Dictionary = {}
    for domain in DOMAINS:
        seeds[domain] = _derive_domain_seed(candidate.profile_seed, domain)

    var layers: Dictionary = {}
    for layer in UNINITIALIZED_LAYERS:
        # Uninitialized is intentionally NOT a legitimate "none" birth result.
        layers[layer] = {"initialized": false}

    return {
        "version": PROFILE_VERSION,
        "generation_index": candidate.generated_index,
        "domain_seeds": seeds,
        "layers": layers
    }

static func _derive_domain_seed(profile_seed: int, domain: String) -> int:
    var value: int = posmod(profile_seed, MODULUS)
    for index in range(domain.length()):
        value = (value * 131 + domain.unicode_at(index)) % MODULUS
    return maxi(value, 1)

# Godot JSON.parse_string restores nested numeric values as float64.
# Convert only the schema's integer fields back to int on load; never reroll them.
static func normalize_envelope(value: Variant) -> Dictionary:
    if not (value is Dictionary) or value.is_empty():
        return {}
    var normalized: Dictionary = value.duplicate(true)
    normalized["version"] = int(normalized.get("version", 0))
    normalized["generation_index"] = int(normalized.get("generation_index", 0))
    var raw_seeds = normalized.get("domain_seeds", {})
    if raw_seeds is Dictionary:
        var seeds: Dictionary = raw_seeds.duplicate(true)
        for domain in DOMAINS:
            if seeds.has(domain):
                seeds[domain] = int(seeds[domain])
        normalized["domain_seeds"] = seeds
    var raw_layers = normalized.get("layers", {})
    if raw_layers is Dictionary:
        var layers: Dictionary = raw_layers.duplicate(true)
        var root = layers.get("spiritual_root", {})
        if root is Dictionary:
            for field in ["birth_values", "current_values"]:
                var values = root.get(field, {})
                if values is Dictionary:
                    for key in values.keys():
                        values[key] = int(values[key])
                    root[field] = values
            layers["spiritual_root"] = root
        var bloodline = layers.get("bloodline", {})
        if bloodline is Dictionary:
            for field in ["birth_purity", "current_purity"]:
                if bloodline.has(field):
                    bloodline[field] = int(bloodline[field])
            layers["bloodline"] = bloodline
        var talent = layers.get("profession_talent", {})
        if talent is Dictionary:
            var grades = talent.get("talents", {})
            if grades is Dictionary:
                for key in grades.keys():
                    grades[key] = int(grades[key])
                talent["talents"] = grades
            layers["profession_talent"] = talent
        normalized["layers"] = layers
    return normalized

static func valid_envelope(value: Variant) -> bool:
    if not (value is Dictionary):
        return false
    if int(value.get("version", 0)) != PROFILE_VERSION:
        return false
    if int(value.get("generation_index", 0)) <= 0:
        return false
    var seeds = value.get("domain_seeds", {})
    var layers = value.get("layers", {})
    if not (seeds is Dictionary) or not (layers is Dictionary):
        return false
    for domain in DOMAINS:
        if int(seeds.get(domain, 0)) <= 0:
            return false
    for layer in UNINITIALIZED_LAYERS:
        var entry = layers.get(layer, null)
        if not (entry is Dictionary) or not entry.has("initialized"):
            return false
    return true

# The envelope can exist before any content is chosen; a recruited V2 person
# must have a structurally valid immutable identity in every layer. Runtime
# reveal/awakening flags may later change, so this validates identity/provenance
# rather than requiring every effect to remain inactive forever.
static func valid_complete_birth(value: Variant) -> bool:
    if not valid_envelope(value):
        return false
    var layers: Dictionary = value["layers"]
    for layer_id in UNINITIALIZED_LAYERS:
        var entry = layers.get(layer_id, {})
        if not (entry is Dictionary) or not bool(entry.get("initialized", false)):
            return false

    var roots: Dictionary = layers["spiritual_root"].get("birth_values",{})
    var current_roots: Dictionary = layers["spiritual_root"].get("current_values",{})
    if roots.is_empty() or roots.size() > 5 or current_roots.is_empty() or current_roots.size() > 5:
        return false
    # Birth roots are immutable provenance. Current roots may legitimately add
    # a new base root later through the V2 refinement/creation system.
    for root_id in roots.keys():
        var id := str(root_id)
        if not BASE_ROOT_IDS.has(id) or not current_roots.has(id):
            return false
        var birth_value := int(roots[root_id])
        if birth_value < 1 or birth_value > 100:
            return false
    for current_id in current_roots.keys():
        if not BASE_ROOT_IDS.has(str(current_id)):
            return false
        var current_value := int(current_roots[current_id])
        if current_value < 1 or current_value > 100:
            return false

    var mutation: Dictionary = layers["root_mutation"]
    var mutation_id := str(mutation.get("mutation_id",""))
    if mutation_id.is_empty() or (mutation_id != "none" and not MUTATION_IDS.has(mutation_id)):
        return false
    if mutation_id != "none":
        var base_element := str(mutation.get("base_element",""))
        if not BASE_ROOT_IDS.has(base_element) or not current_roots.has(base_element):
            return false

    var talent: Dictionary = layers["profession_talent"]
    var talents = talent.get("talents",{})
    if not (talents is Dictionary):
        return false
    for talent_id in talents.keys():
        if not PROFESSION_TALENT_IDS.has(str(talent_id)):
            return false
        var grade := int(talents[talent_id])
        if grade < 1 or grade > 5:
            return false

    var traits: Dictionary = layers["traits"]
    var visible = traits.get("visible",[])
    var latent = traits.get("latent",[])
    if not (visible is Array) or not (latent is Array):
        return false
    if visible.size() < 1 or visible.size() > 3 or latent.size() > 1:
        return false
    var chosen: Array = []
    for raw_trait in visible + latent:
        if not (raw_trait is Dictionary):
            return false
        var trait_id := str(raw_trait.get("id",""))
        var nature := str(raw_trait.get("nature",""))
        if trait_id.is_empty() or not ["H","S","B"].has(nature):
            return false
        if DiscipleBirthCatalogueV2.TRAIT_BIRTH_EXCLUSIONS.has(trait_id):
            return false
        if chosen.has(trait_id) or DiscipleBirthCatalogueV2.conflicts_with(trait_id,chosen):
            return false
        if not _catalogue_has_id(DiscipleBirthCatalogueV2.TRAITS,trait_id):
            return false
        chosen.append(trait_id)

    var bloodline: Dictionary = layers["bloodline"]
    var bloodline_id := str(bloodline.get("bloodline_id",""))
    if bloodline_id.is_empty() or (bloodline_id != "none" and not DiscipleBirthCatalogueV2.BLOODLINES.has(bloodline_id)):
        return false
    if bloodline_id != "none":
        var birth_purity := int(bloodline.get("birth_purity",0))
        var current_purity := int(bloodline.get("current_purity",0))
        if birth_purity < 1 or birth_purity > 100 or current_purity < 1 or current_purity > 100:
            return false

    var physique_id := str(layers["physique"].get("physique_id",""))
    if physique_id.is_empty() or (physique_id != "none" and not _catalogue_has_id(DiscipleBirthCatalogueV2.PHYSIQUES,physique_id)):
        return false

    var destiny_id := str(layers["destiny"].get("destiny_id",""))
    if destiny_id.is_empty() or (destiny_id != "none" and not _catalogue_has_id(DiscipleBirthCatalogueV2.FATES,destiny_id)):
        return false
    return true

static func _catalogue_has_id(rows: Array, target: String) -> bool:
    for row in rows:
        if row is Array and not row.is_empty() and str(row[0]) == target:
            return true
    return false
