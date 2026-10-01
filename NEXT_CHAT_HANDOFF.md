# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through **P2.12**.

Latest authoritative user evidence ended with:

- `P2.11 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.11 BLOODLINE + AWAKENING TEST PASS`
- `P2.11 BLOODLINE + AWAKENING GATE: PASS`
- `P2.12 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.12 PHYSIQUE + GRADES + TEMPERING + TRANSFORMATION TEST PASS`
- `P2.12 PHYSIQUE + TEMPERING + TRANSFORMATION GATE: PASS`
- final `P2.12 GATE: PASS`

Do not reopen P0-P2.12 without new regression evidence.

## Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` before any character-system work. It is the master schema for what is random, derived, nearly fixed, trainable, awakenable/transformable or acquired.

Key locked principles:

- six foundation dimensions;
- disciple quality derived from foundation;
- roots/Huyết Mạch/Thể Chất/traits/Destiny remain separate axes;
- reveal/awakening/transformation never rerolls pre-generated hidden identity;
- systems may overlap on Công/Thủ/Tu/etc when logical;
- every rare system needs real gameplay value before gimmicks.

P2.12 Physique is now locked/pass:

- grade: Phàm -> Linh -> Huyền -> Thánh -> Thần;
- named type separate: none / Kiếm Cốt / Kim Cương Bá Thể / Hàn Âm / Hỏa Linh / Vô Cấu;
- tempering uses Yêu Đan;
- transformation uses deterministic latent target + Linh Tủy;
- HM + TC bonuses stack.

## Product presentation direction changed

The game is now **mobile landscape**, base logical resolution `1280×720`.

Primary structural UI/UX reference is **Ta Làm Tông Sư Trong Tiên Môn**:

- sect map dominates screen;
- thin top resource bar;
- chapter/task rail at left;
- compact edge/floating actions;
- tap buildings directly;
- parchment/scroll overlays over map;
- disciple UI = vertical roster + large character + right detail + bottom tabs.

Do not copy third-party art/logo/icon/text/exact map. Use original art with closely matching interaction hierarchy.

## Active phase

**P3.1 — Mobile ngang + Tông Môn Sống V1**

Status: **IMPLEMENTED FIRST SLICE / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Read first:

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`
4. `docs/DISCIPLE_MASTER_SCHEMA.md`
5. this file

## P3.1 implementation

### Project target

`godot/project.godot` now uses:

- main scene `res://scenes/p3/p3_1_landscape_sect.tscn`;
- 1280×720 viewport + desktop override;
- handheld landscape orientation;
- `canvas_items` + `expand`.

P0 runtime smoke is explicitly pinned to `res://scenes/p0/p0_sandbox.tscn`, so later main-scene changes do not change P0's runtime smoke target.

### Main files

- `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`
- `godot/src/presentation/p3/sect_map_presentation.gd`
- `godot/src/presentation/p3_1_landscape_sect.gd`
- `godot/scenes/p3/p3_1_landscape_sect.tscn`
- `godot/tests/presentation/p3_1_landscape_shell_test.gd`
- `tools/godot/Verify-P3-1.ps1`
- `Verify-P3-1.cmd`
- `Sync-P3-1.cmd`

### Visible shell

Code-generated placeholder map currently has:

- Tông Môn Đại Điện;
- Đệ Tử Xá;
- Tu Luyện Đài;
- Kho;
- Luyện Khí Đường;
- Dược Phòng;
- Khu Khai Khoáng;
- Tông Môn Đại Môn;
- central courtyard/path/river treatment.

Top bar reads actual treasury/spirit-stone/material state. Left task rail observes real actions/resources. Bottom nav opens disciple/warehouse/building/world/task surfaces.

Building popup reads actual simulation/economy/workforce data.

Disciple popup has:

- left roster;
- central large placeholder portrait;
- right details;
- lower tabs;
- real HP/stamina/action;
- V2 quality/foundation/root/HM/TC when available;
- legacy founder fields show `—` instead of invented data;
- real quick direct commands through `WorkforceSystem.issue_command()`.

### Visible movement authority

`SectMapPresentation` maps real `current_action` to map destinations:

- CULTIVATE/BREAKTHROUGH -> Tu Luyện Đài;
- WORK_MINING -> mine;
- WORK_FORGING -> forge;
- REST -> residence;
- HEAL -> medicine;
- SELL/BUY -> warehouse;
- HUNT/TRAVEL/COMBAT/LOOT/RETURN_SECT -> gate;
- HOLD -> courtyard;
- EVALUATE/IDLE preserve previous visible destination.

Movement is presentation tweening only and must never mutate simulation authority.

P3.1 demo accepts two V2 candidates in its own fresh P2.12 demo state so modern schema fields can be shown alongside the six legacy founders. This is presentation/demo setup, not a migration of locked founders.

## Verification

Run:

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P3-1.cmd
```

Expected final lines:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- `P3.1 GATE: PASS`

If it fails, inspect/fix the first real parser/diagnostic/assertion failure only. Do not weaken locked regression tests.

## After P3.1 runtime green

1. P3.2 production art/animation/UI polish while retaining landscape hierarchy;
2. P3.3 real visible building assignment/production/upgrades;
3. injury/medical;
4. loyalty/stipend/reward;
5. sect rank/authority;
6. master-disciple;
7. Destiny;
8. item/transmission gacha for HM/TC/other acquired transformations;
9. active age/lifespan/death/inheritance after time pacing is proven.
