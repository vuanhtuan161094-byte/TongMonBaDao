# FIST11 Huyết Liệt Quyền — R1 original dark-crimson source → native Godot VFX
2026-11-16 · PR #72 Draft · single `integration/pve-p0-playable-ui-20261103` branch

## Canonical contract (Human)
`tmb.skill.fist.huyet_quyen.active_01.human` is a **single-target damage skill**, Nether element, cast 0.45s, cooldown 8s, projectile_speed 8, range 2.8, radius=0, duration=0. No bleed/mark/stun/poison/AoE effect is authorized. No actual hit/HP is generated in the LAB.

## Original first-party VFX art
- Three independent source-painted 768×768 WEBP alpha masters from `tools/vfx/create_fist11_original_masters.py`: charge current, asymmetric compressed phantom blood-qi FIST with four knuckles, torn contact. Burgundy-black underglow, deep rose/magenta core, pale rose-white luminous knuckle edges. No gore, no generic full-screen circles.
- `tools/vfx/generate_fist11_huyet_liet_quyen.py` bakes 8 distinct charge (256 px), 12 directional projectile poses (320 px), 8 local contact (256 px) on 3 transparent atlas pages (9,109,504 bytes raw RGBA). Separate sprite layers from approved 4dir dummy actor and background. Source/CI deterministic, no external assets, no rig or GIF.
- Synthesis: t0–.45 gather red qi → .45–.80 spectral clenched fist tracks moving single foe → .80–1.36 short local contact/fade. 1.85s LAB loop.
- NOTE: This is the start of Huyết Quyền branch and **new R1 candidate**, not remotely equivalent to owner approval. Source art and QA art must be inspected manually against adopted game style.

## Mandatory Production System V4 QA
- G3.5 screenshots from real native Godot 4.7.2 Compatibility at charge t=.25, flight peak t=.59, one moving-target contact t=.84.
- 1280×720 Godot MP4 and 17+ source timestamps; original alpha and source provenance, focused one-target moving contract, exact SHA Action artifact.
- MUST NOT silently change Combat V2, SaveService, enemy HP, NPC AI, PvE, V6.3 or use Codex/new branch/merge. No GIF, no rig. Physical Android QA and owner art remain **PENDING**.

## Prior acceptance
- FIST09 Trấn Sơn Hộ Đồng owner accepted, untouched.
- FIST10 Bất Động Kim Chung R4 final user removed all hit VFX, preserved in `FIST10_R4_FINAL_NO_HIT_V4`; new native film exact SHA 215e07ba… Action 43900897112 SUCCESS.