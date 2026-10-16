class_name CombatV4TwoWayFacing
extends RefCounted

# Combat V4 presentation ONLY: one authored SIDE profile and horizontal mirroring.
# Vertical movement changes map position, not artwork direction or combat authority.
const RIGHT: StringName = &"right"
const LEFT: StringName = &"left"
const HORIZONTAL_EPSILON := 0.001

static func for_motion(delta: Vector2, previous: StringName = RIGHT) -> StringName:
    if delta.x > HORIZONTAL_EPSILON:
        return RIGHT
    if delta.x < -HORIZONTAL_EPSILON:
        return LEFT
    return previous if previous == LEFT or previous == RIGHT else RIGHT

static func flip_h(facing: StringName, source_faces_left: bool = false) -> bool:
    # Stage A female is authored RIGHT; current concept wolves are authored LEFT.
    return facing == RIGHT if source_faces_left else facing == LEFT

static func directional_motion(facing: StringName) -> Vector2:
    # Reuse only horizontal Stage A authored clip, including for vertical travel.
    return Vector2.LEFT if facing == LEFT else Vector2.RIGHT
