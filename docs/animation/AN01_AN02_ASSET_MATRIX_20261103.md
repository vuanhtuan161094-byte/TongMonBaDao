# AN-01 / AN-02 — Verified Source A clip matrix
Date: 2026-11-03. Base: rc/one-game-playable-20261101 @ 970af33b23076c80d677cf5898a721a27504708f.
Evidence: static GitHub inspection of real godot/assets/actors/*/asset.json and animations.tres, plus combat_v5_source_a/visual_manifest.json. NO new Godot 4.7.2 run.

| Actor / pack | Actual baked clip (stored frames @ 30 FPS) | Gap |
|---|---|---|
| female BASE 1113028_1 | stand 48, walk 24 | Combat separate |
| female COMBAT v5_sa_female_1113028_1 | attack1 29, hit 15, dead 15 | No native cast, guard or verified 8-way |
| male v5_sa_male_body_1110201 | stand 48, walk 24, attack1 29, hit 15, dead 15 | No native cast/guard/8-way |
| male alternate body_1120402 | stand 48, walk 24 | Not full combat |
| Thanh Lang v5_sa_monster_1113031_1 | stand 60, walk 24, attack1 29, hit 10, dead 22 | Enemy not disciple |
| Boss slot v5_sa_boss_410041_1 | stand 60, run 28, attack1 30, hit 15, dead 21 stored (30 logical) | Visual slot not Boss gameplay authority |

Direction: existing atlas adapter reads a single source strip per action and mirrors left/right. No eight authored angles proved. Earlier modular scaffold public contract is four directions; the new lab provides eight *requested* directions but labels rendering as FACING_ONLY/MIRRORED, not authored 8-direction art. 36 frames is NOT a cap on whole character; authentic attack1 has 29 frames.

Clip fallback: cast -> attack1, run -> walk, die -> dead; highlight in lab, never represent fallback as a native skill action. Runtime atlas import may fail if binaries missing on a local checkout; show BLOCKED_BY_ASSET.

Skill data has animation_key/vfx_key entries for V6.3 Nhân/Tiên/Thần but naming does not prove sprite export. Cung needs genuine bow draw/release/socket, Quyền a punch/guard pose, Độc needle throw or cast; each BLOCKED_BY_AUTHENTIC_ANIMATION until independently checked. Shadow Sword is an **experimental stylization of male Source A**, not a new playable class.

Acceptance gates: exact SHA, static file inventory, Godot 4.7.2 editor import, headless scene smoke, actual 1280x720 capture, foot/alpha/frame inspection, source SHA, direction and action fallback truth, 1/6/30 actor frame-time and memory, and Windows/Android owner review. PENDING_ENGINE/PENDING_USER are not PASS.
Standalone scene: res://scenes/labs/an02_animation_lab.tscn. Focused test: res://tests/presentation/an02_animation_lab_contract_test.gd.
Allowed changes: dedicated skill, new isolated lab scene/script/shader/test, animation docs and limited routing/handoff only. No main scene, gameplay, SaveService, combat, PvE, skill balance or merge.
