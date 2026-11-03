---
name: tmb-sprite-animation
description: "Audit, preview, produce and verify Tông Môn Bá Đạo real Source A sprite clips, Atlas/SpriteFrames, direction, anchors, sockets, Shadow visual-only effects and Animation Lab on Godot 4.7.2."
---
# TMB Sprite Animation — AN-01/AN-02 skill

## Authority
Read AGENTS.md, architecture, CURRENT_CHECKPOINT, NEXT_CHAT_HANDOFF, project art spec and actual ref before changing files. Use tmb-asset-gate to verify source art and tmb-godot-evidence for QA. This skill does not authorize Combat V2, balance, PvE, SaveService, default game scene or main changes. Owner approval is distinct from source verification.

## Census (AN-01)
1. Enumerate actor IDs and actual Godot SpriteFrames alongside asset.json. Record native clip names, stored frames, per-frame durations, speed, loop, atlas pages, SHA256, anchor offsets, body/weapon identity and license provenance. Source filenames alone do not prove gameplay readiness.
2. For each action and each requested direction, label AUTHORED / MIRRORED / APPROXIMATION / MISSING. An eight-option direction selector does not prove eight authored angles. Note mirrored asymmetrical weapons and accessories.
3. Separate native movement from adapter fallbacks (cast maps to attack1; run maps to walk). Missing true casts must remain explicit. Never silently fabricate a bow pull, fist punch or poison release from a generic Source A attack.
4. For the skill registry, distinguish animation_key/vfx_key identifiers from usable binaries. Group compatible skills into pose families; build real clip/socket/release-marker mapping per family.

## Animation Lab (AN-02)
- Use separate view-only Godot 4.7.2 scene (1280x720). Do not overwrite main_scene, autoload, save or gameplay.
- Load real Source A imported frames and manifest; allow actor, clip, requested direction, speed, pause/restart and Shadow toggle. Expose actual clip, frames, source pack, FPS, fallback, direction fidelity, frame index, and foot anchor.
- Shadow is an experimental ink-silhouette+violet-rim treatment of an authentic source actor clip. Runes/slash streaks are visual-only lab effects, not weapon sockets or Combat V2 hit authority. No UI mockup is an actual Godot capture.
- Avoid overly large opaque VFX covering bosses/HP or low-resolution gameplay. The cinematic preview and 60–75 px map readability must be assessed separately.
- Never let animation frames apply damage, EXP, Warehouse rewards or cooldown changes. Confirm hits/blocks/misses only from canonical combat events in a separately authorized integration packet; avoid replay after Save/Reload.

## Required handoff
Deliver provenance/clip gap matrix, viewable lab scene, exact SHA/change list, focused official Godot logs, 1280x720 screenshots/video, 1/6/30 actor resource budget and explicit OWNER/ANDROID/WINDOWS pending states. Run import/scene smoke only when engine available; static review cannot be called PASS. Source A remains primary; JX/JXQY experimental and separately approved.
