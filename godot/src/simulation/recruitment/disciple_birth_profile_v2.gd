class_name DiscipleBirthProfileV2
extends RefCounted

# DV2-01A: deterministic, opt-in birth envelope only.
# Content pools are deliberately uninitialized until each V2 birth table is approved.
# This must not consume the P3.7C1 generator RNG or change its six foundations.
const PROFILE_VERSION := 1
const MODULUS := 2147483629
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
# must instead have each approved birth layer initialized (including legit none).
static func valid_complete_birth(value: Variant) -> bool:
    if not valid_envelope(value):
        return false
    var layers: Dictionary = value["layers"]
    for layer_id in UNINITIALIZED_LAYERS:
        var entry = layers.get(layer_id, {})
        if not (entry is Dictionary):
            return false
        if not bool(entry.get("initialized", false)):
            return false
    return true
