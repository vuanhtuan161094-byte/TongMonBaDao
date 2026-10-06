class_name CharacterModifierSystem
extends RefCounted

const CHANNEL_WORK_SPEED := &"work_speed"
const CHANNEL_PROFESSION_XP := &"profession_xp"
const CHANNEL_CULTIVATION_GAIN := &"cultivation_gain"
const CHANNEL_BODY_TRAINING_GAIN := &"body_training_gain"
const CHANNEL_RARE_CHANCE := &"rare_chance"
const CHANNEL_SOCIAL_EFFECT := &"social_effect"

const FOUNDATION_BASE_FACTOR := 0.75
const FOUNDATION_RANGE_FACTOR := 0.50

var trait_system := TraitSystem.new()
var foundation_system := FoundationSystem.new()

func foundation_factor(value: float) -> float:
    return FOUNDATION_BASE_FACTOR + FOUNDATION_RANGE_FACTOR * clampf(value, 0.0, 1.0)

func foundation_channel_factor(disciple: DiscipleState, channel: StringName) -> float:
    if disciple.foundation_model_version >= FoundationSystem.MODEL_OPEN_POINTS:
        match channel:
            CHANNEL_CULTIVATION_GAIN:
                return foundation_system.cultivation_gain_factor(disciple.aptitude)
            CHANNEL_BODY_TRAINING_GAIN:
                return foundation_system.body_training_gain_factor(disciple.constitution)
            CHANNEL_PROFESSION_XP:
                return foundation_system.learning_gain_factor(disciple.comprehension)
            # Compatibility bridges only. New Fortune/Social content must use
            # FoundationSystem luck/social checks rather than percentage growth.
            CHANNEL_RARE_CHANCE:
                return foundation_system.legacy_bridge_factor(disciple.fortune)
            CHANNEL_SOCIAL_EFFECT:
                return foundation_system.legacy_bridge_factor(disciple.charisma)
            _:
                return 1.0
    match channel:
        CHANNEL_CULTIVATION_GAIN:
            return foundation_factor(disciple.aptitude)
        CHANNEL_BODY_TRAINING_GAIN:
            return foundation_factor(disciple.constitution)
        CHANNEL_RARE_CHANCE:
            return foundation_factor(disciple.fortune)
        CHANNEL_PROFESSION_XP:
            return foundation_factor(disciple.comprehension)
        CHANNEL_SOCIAL_EFFECT:
            return foundation_factor(disciple.charisma)
        _:
            return 1.0

func trait_factor(state: SimulationState, disciple: DiscipleState, channel: StringName) -> float:
    return trait_system.modifier_factor(state, disciple, channel)

func combined_factor(state: SimulationState, disciple: DiscipleState, channel: StringName) -> float:
    return foundation_channel_factor(disciple, channel) * trait_factor(state, disciple, channel)
