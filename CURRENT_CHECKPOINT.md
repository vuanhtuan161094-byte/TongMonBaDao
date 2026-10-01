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

## Active presentation work

# **P3.1 — Mobile ngang + Tông Môn Sống V1**

Status: **IMPLEMENTED FIRST SLICE / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

P3.1 remains the base landscape/living-sect contract. It has not yet received real local runtime evidence.

Read:

- `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`
- `docs/DISCIPLE_MASTER_SCHEMA.md`
- this checkpoint.

### P3.1 contract already implemented

- 1280×720 landscape + `canvas_items` + `expand`;
- map-dominant hierarchy;
- real simulation action -> visible building destination mapping;
- disciple movement tween toward current-action destination;
- building popup reads real resources/work state;
- disciple popup exposes roster/current state/direct orders;
- direct orders call existing `WorkforceSystem.issue_command()`;
- no parallel gameplay state.

P0 runtime smoke remains explicitly pinned to its P0 scene, so advancing the project main scene does not alter the P0 contract.

# **P3.2 Camera Interaction Slice — Zoom + Pan + Focus**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

This is only the camera/interaction slice of P3.2. **Do not call full P3.2 PASS.** Production art/animation/UI replacement remains future work.

Read:

- `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`;
- `godot/src/presentation/p3/sect_map_camera.gd`;
- `godot/src/presentation/p3_2_landscape_sect.gd`.

### Camera contract now implemented

- map only zooms; HUD/task rail/menu/popup do not scale;
- mobile pinch zoom;
- one-finger map pan on empty/unhandled map area;
- desktop wheel zoom + left-drag pan for testing;
- double-tap/double-click on free map area zooms toward that point;
- fixed fallback controls `+`, `−`, `Toàn`;
- zoom limits `0.75x -> 1.80x`;
- default `1.00x`;
- focus zoom target `1.35x`;
- zoom preserves the pinch/wheel screen anchor;
- pan is clamped so the map cannot be dragged completely away;
- popups block camera gestures;
- camera is presentation-only and never mutates simulation state.

The project main scene has advanced to:

- `res://scenes/p3/p3_2_landscape_sect.tscn`

P3.1 verifier was adjusted only so its lower-layer shell contract remains testable after main-scene advancement; it still directly smokes the P3.1 scene.

### P3.2 camera verification assets

- `godot/tests/presentation/p3_2_map_camera_test.gd`
- `tools/godot/Verify-P3-2-Camera.ps1`
- `Verify-P3-2-Camera.cmd`
- `Sync-P3-2-Camera.cmd`

The P3.2 camera verifier first runs the complete P3.1 cumulative chain. If P3.1 fails, camera verification never proceeds.

## Next authoritative local command

When the Windows machine is available:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Camera.cmd
```

Expected successful tail includes:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- `P3.2 MAP CAMERA TEST PASS`
- `P3.2 CAMERA INTERACTION GATE: PASS`
- final `P3.2 CAMERA GATE: PASS`

Do not call P3.1 or P3.2 camera PASS until this real Godot 4.7.2 output is supplied.

If it fails, fix the first real parser/diagnostic/assertion failure only.

## Planned order after camera slice runtime green

1. production art/animation/UI replacement while preserving the landscape hierarchy and camera behavior;
2. visible building/production assignment/upgrades;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority expansion;
6. master-disciple/teaching;
7. Destiny/awakening;
8. item/transmission gacha that can grant or improve Bloodline/Physique according to the master schema;
9. active age/lifespan/death/inheritance after simulation-year pacing is proven.
