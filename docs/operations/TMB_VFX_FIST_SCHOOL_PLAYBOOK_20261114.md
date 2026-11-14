# FIST / QUYEN TU — SCHOOL-SPECIFIC VFX PLAYBOOK (2026-11-14)
Technical origin: learn TAL01 Điện Quang Khai Phù's **first-party illustrated master + raster alpha flipbook + split layers + genuine Godot movie**. Do NOT copy the talisman images, violet lightning or another school.

## Visual personalities
- Ba Quyen: blunt compressed physical force, asymmetric ochre-orange/amber heat, meaningful recoil and stone grit. Need recognizable martial fist, not sword beam/magical orange icon. Never invent AoE or fire DoT.
- Kim Cang: tangible stone/metal shell, earthy gold restrained guard and counterforce. Guard is never rendered as new damage.
- Huyet Quyen: dark red organic current, blood-like living movement, event-bound mark only if catalogue/receipts allow.
No 1 master recolored into unrelated skills.

## FIST01 / Khai Son Trong Quyen
Canonical tmb.skill.fist.ba_quyen.active_01.human. Damage, fire, single_target cap=1, cast=0.45s, range=2.8; read-only. R1–R8 failed the owner's artistic standard as generic vector-looking energy despite code QA PASS.

R9 new technique from Loi Phu's production pattern:
- Source: tools/vfx/generate_fist01_painted_atlas.py (first-party Pillow deterministic alpha-painted raster; NOT an ImageGen-sourced master).
- 12 hero poses in 4x3 RGBA 320px cell, 8 charge and 8 impact poses in 4x2 sheets.
- Source scene: godot/labs/combat_lab/fist01/khai_son_trong_quyen.gd. Existing ground/dust and small chest flash are separate layers.
- Workflow: .github/workflows/vfx-fist-01-khai-son-trong-quyen.yml; generator runs before strict Godot import and original atlas files upload with movie.
- Exact R9 tested SHA 7f74ab41c8e4fcff2fdf06787eee145f02f1b1c4, Actions #43580310765 TECH PASS. Native 0.64s revealed a still-flat orange mitten/regular trails even though now PNG rather than SVG. ART_REWORK_REQUIRED, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD. The placeholder actors are Poison Tu IDLE; not genuine fist pose or a rig.
- Next: improve actual painted hero material and pose individuality (ideally independent first-party illustrated master) before anything else; compare 0.26/0.42 charge, 0.57/0.64/0.73 flight, 0.80/0.87/1.02 contact, 1.24/1.49 fade. Do not hide flaws with extra glow.
- Do NOT touch other schools' code or the actual Combat V2, hit/status/HP, economy, SaveService, V6.3 gate or live PvE. No rig, Codex, branches or merge.
