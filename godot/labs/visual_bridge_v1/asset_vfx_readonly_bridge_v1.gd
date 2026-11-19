class_name AssetVfxReadOnlyBridgeV1
extends RefCounted

# Isolated read-only presentation contract. NOT attached to PvE or runtime.
# Asset sprite coordinates and VFX art remain independent; no rig or gameplay.
const EVENT_TYPES := ["skill_cast", "hit", "v63_skill_hit", "status_applied", "status_removed", "downed"]
const SOURCE_SLOTS := ["foot", "hand_r", "hand_l", "weapon_grip", "weapon_tip", "chest", "head", "body_center", "ground"]
const TARGET_SLOTS := ["foot", "chest", "head", "body_center", "ground"]
const DIRECTIONS := ["front", "right", "back", "left"]

var _encounter_id: String = ""
var _seen: Dictionary = {}

func begin_encounter(encounter_id: String) -> bool:
    if encounter_id.strip_edges().is_empty():
        return false
    _encounter_id = encounter_id
    _seen.clear()
    return true

func route_authoritative_event(raw: Dictionary, vfx_manifest: Dictionary) -> Dictionary:
    # An event is admitted only if it comes with an existing authoritative ID.
    # A lab can feed labelled synthetic events, but this function never makes one.
    var encounter := str(raw.get("encounter_id", ""))
    var event_id := str(raw.get("event_id", ""))
    var skill_id := str(raw.get("skill_id", ""))
    var event_type := str(raw.get("type", ""))
    if _encounter_id.is_empty() or encounter != _encounter_id:
        return {"ok": false, "reason": "encounter_not_started_or_changed"}
    if event_id.is_empty() or skill_id.is_empty() or not EVENT_TYPES.has(event_type):
        return {"ok": false, "reason": "missing_event_identity_or_type"}
    if str(vfx_manifest.get("schema", "")) != "tmb.vfx_bindings.v1":
        return {"ok": false, "reason": "unknown_vfx_binding_schema"}
    if skill_id != str(vfx_manifest.get("skill_id", "")):
        return {"ok": false, "reason": "skill_mismatch"}
    if _seen.has(event_id):
        return {"ok": false, "reason": "duplicate_event_id"}
    var actor_id := str(raw.get("actor_id", raw.get("caster", "")))
    var target_id := str(raw.get("target_id", raw.get("target", "")))
    if actor_id.is_empty():
        return {"ok": false, "reason": "missing_caster"}
    var bindings: Variant = vfx_manifest.get("bindings", [])
    if not (bindings is Array):
        return {"ok": false, "reason": "invalid_bindings"}
    var emissions: Array[Dictionary] = []
    for raw_binding in bindings:
        if not (raw_binding is Dictionary):
            return {"ok": false, "reason": "invalid_binding_entry"}
        var binding: Dictionary = raw_binding
        if str(binding.get("event_type", "")) != event_type:
            continue
        var caster_slot := str(binding.get("caster_slot", ""))
        var target_slot := str(binding.get("target_slot", ""))
        var actor_clip := str(binding.get("actor_clip", ""))
        var visual_phase := str(binding.get("visual_phase", ""))
        if not SOURCE_SLOTS.has(caster_slot) or not TARGET_SLOTS.has(target_slot) or actor_clip.is_empty() or visual_phase.is_empty():
            return {"ok": false, "reason": "invalid_anchor_or_phase"}
        if target_id.is_empty():
            return {"ok": false, "reason": "missing_target_for_anchor"}
        emissions.append({
            "event_id": event_id,
            "encounter_id": encounter,
            "skill_id": skill_id,
            "event_type": event_type,
            "visual_phase": visual_phase,
            "actor_clip": actor_clip,
            "caster_id": actor_id,
            "target_id": target_id,
            "caster_slot": caster_slot,
            "target_slot": target_slot
        })
    if emissions.is_empty():
        return {"ok": false, "reason": "event_unbound"}
    # Deduplication is visual-only, per instance and per encounter. No HP/event write.
    _seen[event_id] = true
    return {"ok": true, "emissions": emissions}

static func resolve_frame_anchor(character_manifest: Dictionary, actor_clip: String, facing: String, frame_index: int, slot: String, source_to_world: Transform2D) -> Dictionary:
    # source_to_world maps SOURCE pixels relative to the foot pivot into game space.
    # Caller supplies the actor display-scale/offset transform, never inferred here.
    if str(character_manifest.get("schema", "")) != "tmb.character_anchors.v1":
        return {"ok": false, "reason": "unknown_character_schema"}
    if not DIRECTIONS.has(facing) or not SOURCE_SLOTS.has(slot) or frame_index < 0:
        return {"ok": false, "reason": "invalid_direction_slot_frame"}
    var foot: Variant = character_manifest.get("foot_px", [])
    if not (foot is Array) or foot.size() != 2:
        return {"ok": false, "reason": "missing_foot_pivot"}
    var clips: Variant = character_manifest.get("clips", {})
    if not (clips is Dictionary):
        return {"ok": false, "reason": "missing_clips"}
    var directions: Variant = clips.get(actor_clip, {})
    if not (directions is Dictionary):
        return {"ok": false, "reason": "missing_actor_clip"}
    var frames: Variant = directions.get(facing, [])
    if not (frames is Array):
        return {"ok": false, "reason": "missing_facing"}
    for raw_frame in frames:
        if not (raw_frame is Dictionary):
            continue
        var frame: Dictionary = raw_frame
        if int(frame.get("frame", -1)) != frame_index:
            continue
        var anchors: Variant = frame.get("anchors", {})
        if not (anchors is Dictionary):
            break
        var point: Variant = anchors.get(slot, [])
        if not (point is Array) or point.size() != 2:
            break
        var source_offset := Vector2(float(point[0]) - float(foot[0]), float(point[1]) - float(foot[1]))
        return {"ok": true, "world_position": source_to_world * source_offset}
    return {"ok": false, "reason": "missing_authored_frame_anchor"}
