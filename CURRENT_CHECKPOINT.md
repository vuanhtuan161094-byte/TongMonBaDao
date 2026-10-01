# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.12 PASS**.

Locked chain:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Combat Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Roots: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths: PASS.
- P2.5 Realtime Combat + Independent Skills: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.
- P2.7 Disciple Life + Workforce + Sect Assignment: LOCKED / PASS.
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources: LOCKED / PASS.
- P2.9 Traits + Quirks + Hidden Reveal: LOCKED / PASS.
- P2.10 Spiritual Root Refinement + Mutation: LOCKED / PASS.
- P2.11 Bloodline + Awakening + Purity: LOCKED / PASS.
- **P2.12 Physique + Grades + Tempering + Transformation: LOCKED / PASS.**

Latest authoritative user runtime evidence on 2026-10-01 ended with:

- `P2.11 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.11 BLOODLINE + AWAKENING TEST PASS`
- `P2.11 BLOODLINE + AWAKENING GATE: PASS`
- `P2.12 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.12 PHYSIQUE + GRADES + TEMPERING + TRANSFORMATION TEST PASS`
- `P2.12 PHYSIQUE + TEMPERING + TRANSFORMATION GATE: PASS`
- final `P2.12 GATE: PASS`

Do not reopen P0-P2.12 without new regression evidence.

## Canonical character authority

Read **`docs/DISCIPLE_MASTER_SCHEMA.md` first** for any future character-system change.

It is the master contract for:

- what a character has;
- what is rolled at generation;
- what is derived rather than rolled;
- what is nearly fixed identity;
- what can progress normally;
- what can only change through rare transformation/awakening/item/event mechanics.

Phase specs may only deepen one slice of that master schema; they may not invent a conflicting character model.

## Core game identity

The player is the **Tông Chủ**. Disciples are autonomous people, not puppets.

Operating loop remains:

`hunt/work -> warehouse -> production/investment -> disciple growth -> harder content`

The player controls infrastructure, recruitment, policy, investment, assignments and temporary direct intervention. Routine one-by-one micromanagement must remain optional at scale.

## Global mechanic-consequence rule

Every gameplay feature must have concrete consequences. It may affect Công, Thủ, HP, cultivation speed, breakthrough, recovery, production, XP, economy, AI behavior, risk, cooldown, movement or other measurable outputs.

**Do not fear overlap.** Linh căn, Huyết Mạch, Thể Chất, Đặc Chất, Công pháp, Trang bị, Thiên Mệnh, buildings and ranks may affect the same stat when logically justified.

Systems differ by source, acquisition, progression, conditions, costs, tradeoffs and signature rules — not by artificially reserving one stat for one system.

Rare/valuable mechanics must be useful before their gimmick or drawback. Gates test real consequences, not labels.

## Locked character foundation through P2.12

### Six foundation dimensions

- Tư Chất / aptitude;
- Căn Cốt / constitution;
- Cơ Duyên / fortune;
- Thông Tuệ / comprehension;
- Mị Lực / charisma;
- Tiềm Lực / potential.

Disciple quality is derived mainly from these:

`Phàm Thường -> Xuất Chúng -> Thiên Kiêu -> Tuyệt Luân -> Nghịch Thiên`.

### Spiritual Root

Root elements/count and purity are separate. Refinement consumes real Linh Tủy, raises purity, preserves ordinary element list and may reveal a deterministic latent mutation.

### Bloodline

Bloodline is its own axis:

- roll whether special bloodline exists;
- roll type if it exists;
- roll starting purity;
- reveal and awakening do not reroll identity;
- post-awakening effects are real and can overlap with other systems.

Current types include Chân Long, Phượng Hoàng, Bạch Hổ, Huyền Vũ and Thao Thiết Tàn Huyết.

### Physique

Physique has **two independent axes**:

1. grade: `Phàm Thể -> Linh Thể -> Huyền Thể -> Thánh Thể -> Thần Thể`;
2. named special type: none / Kiếm Cốt / Kim Cương Bá Thể / Hàn Âm Thể / Hỏa Linh Thể / Vô Cấu Đạo Thể.

Current grade rates:

| Grade | Ordinary | Chiêu Hiền | Nhân Duyên |
| --- | ---: | ---: | ---: |
| Phàm Thể | 58% | 40% | 28% |
| Linh Thể | 27% | 32% | 31% |
| Huyền Thể | 11% | 19% | 24% |
| Thánh Thể | 3.5% | 7% | 13% |
| Thần Thể | 0.5% | 2% | 4% |

Named special-type chance remains separate:

- ordinary 15%;
- Chiêu Hiền 28%;
- Nhân Duyên 40%.

Display:

- unnamed type -> only grade, e.g. `Linh Thể`;
- named type -> e.g. `Kiếm Cốt · Huyền Thể`.

Tempering consumes one Yêu Đan and improves real effects without rerolling type/grade. Transformation from unnamed body uses the deterministic latent target and preserves grade. Routine tempering does not automatically promote physique grade.

## Active phase

# **P3.1 — Mobile ngang + Tông Môn Sống V1**

Status: **IMPLEMENTED FIRST SLICE / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Read:

- `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- this checkpoint.

### Presentation target

The product presentation target is now **mobile landscape**, base logical resolution **1280×720**.

The UX reference is **Ta Làm Tông Sư Trong Tiên Môn** at the structural level:

- map dominates the screen;
- thin top resource bar;
- chapter/task rail on the left;
- edge/floating action buttons;
- buildings are tapped directly on the map;
- parchment/scroll-like popups stay over the map;
- disciple management uses vertical roster + large character area + detail panel + lower tabs.

Do not copy third-party assets, text, logo, icons or exact map art. Use original art while keeping the interaction hierarchy close.

### P3.1 implementation now in repo

- `godot/project.godot` targets 1280×720 landscape, `canvas_items`, `expand`;
- main scene is `res://scenes/p3/p3_1_landscape_sect.tscn`;
- `SectMapPresentation` maps real simulation actions to visible destinations;
- map has Đại Điện, Đệ Tử Xá, Tu Luyện Đài, Kho, Luyện Khí Đường, Dược Phòng, Khai Khoáng and Đại Môn placeholders;
- disciple avatars move by presentation tween toward the destination implied by `current_action`;
- `EVALUATE/IDLE` preserve the prior visible destination instead of snapping back every tick;
- building popup reads actual simulation resources/work state;
- disciple popup exposes roster, V2 identity where available and real direct-order buttons;
- direct orders call the existing `WorkforceSystem.issue_command()` authority;
- two V2 candidates are accepted only in the P3.1 demo presentation state so the modern character schema is visible alongside legacy founders;
- no parallel gameplay engine/state was added.

P0 runtime smoke was pinned explicitly to `res://scenes/p0/p0_sandbox.tscn` so changing the project main scene does not make the P0 gate depend on later presentation code.

### P3.1 verification assets

- `godot/src/presentation/p3/sect_map_presentation.gd`
- `godot/src/presentation/p3_1_landscape_sect.gd`
- `godot/scenes/p3/p3_1_landscape_sect.tscn`
- `godot/tests/presentation/p3_1_landscape_shell_test.gd`
- `tools/godot/Verify-P3-1.ps1`
- `Verify-P3-1.cmd`
- `Sync-P3-1.cmd`

Cumulative gate reruns P0-P2.12 first, then checks landscape project settings, deterministic action-to-map mapping, presentation-only behavior, real direct-command integration and P3.1 scene smoke.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P3-1.cmd
```

Do not call P3.1 PASS until final real Godot 4.7.2 output reaches:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- final `P3.1 GATE: PASS`

If it fails, fix the first real parser/diagnostic/assertion failure only and rerun the same command.

## Planned order after P3.1 runtime green

1. P3.2 production art/animation/UI polish while preserving the locked landscape hierarchy;
2. P3.3 visible building/production assignment/upgrades;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority expansion;
6. master-disciple/teaching;
7. Destiny/awakening;
8. item/transmission gacha that can grant or improve Bloodline/Physique according to the master schema;
9. active age/lifespan/death/inheritance after simulation-year pacing is proven.
