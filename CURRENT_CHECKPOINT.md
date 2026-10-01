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

Latest authoritative user runtime evidence ended with:

- `P2.12 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.12 PHYSIQUE + GRADES + TEMPERING + TRANSFORMATION TEST PASS`
- `P2.12 PHYSIQUE + TEMPERING + TRANSFORMATION GATE: PASS`
- final `P2.12 GATE: PASS`

Do not reopen P0-P2.12 without new regression evidence.

## Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` first before changing any character subsystem.

The master schema decides:

- what a character owns;
- what is rolled once at generation;
- what is derived instead of rolled;
- what is nearly fixed identity;
- what grows through ordinary training;
- what only changes through rare awakening/transformation/item/event mechanics.

Hidden identity is generated once and persisted. Reveal/awakening/transformation must not reroll it.

### Foundation summary

Six permanent foundation dimensions:

- Tư Chất / aptitude;
- Căn Cốt / constitution;
- Cơ Duyên / fortune;
- Thông Tuệ / comprehension;
- Mị Lực / charisma;
- Tiềm Lực / potential.

Disciple quality is derived mainly from these:

`Phàm Thường -> Xuất Chúng -> Thiên Kiêu -> Tuyệt Luân -> Nghịch Thiên`.

### Bloodline

Bloodline is independent from other identity systems. It rolls existence/type/purity once; reveal does not reroll. Awakening/refinement use real resources and effects can overlap with other systems.

### Physique

Physique has two independent axes:

1. grade: `Phàm Thể -> Linh Thể -> Huyền Thể -> Thánh Thể -> Thần Thể`;
2. named type: none / Kiếm Cốt / Kim Cương Bá Thể / Hàn Âm Thể / Hỏa Linh Thể / Vô Cấu Đạo Thể.

Current grade probabilities:

| Grade | Ordinary | Chiêu Hiền | Nhân Duyên |
| --- | ---: | ---: | ---: |
| Phàm Thể | 58% | 40% | 28% |
| Linh Thể | 27% | 32% | 31% |
| Huyền Thể | 11% | 19% | 24% |
| Thánh Thể | 3.5% | 7% | 13% |
| Thần Thể | 0.5% | 2% | 4% |

Named-special chance is separate: ordinary 15%, Chiêu Hiền 28%, Nhân Duyên 40%.

Unnamed type displays only grade. Named type displays e.g. `Kiếm Cốt · Huyền Thể`.

Tempering uses one Yêu Đan and does not reroll type/grade. Transformation uses the pre-generated latent target and preserves grade. Routine tempering does not automatically promote grade.

## Global mechanic-consequence rule

Every named feature must change real play. Valid overlap includes Công, Thủ, HP, cultivation, breakthrough, recovery, profession/mastery, production, economy, AI behavior, risk, movement, cooldown and similar concrete outputs.

**Do not fear overlap.** Systems differ through source, acquisition, progression, cost, conditions, tradeoffs and signature rules — not because each system owns an exclusive stat.

Rare mechanics must be useful before their gimmick/drawback. UI labels without real consequences do not count.

## Core product identity

The player is the **Tông Chủ**. Disciples are autonomous people, not puppets.

Operating rhythm:

`hunt/work -> warehouse -> production/investment -> disciple growth -> harder content`

The player controls infrastructure, recruitment, policy, investment, assignment and temporary strategic intervention. Routine one-by-one micromanagement must remain optional at scale.

## Presentation canon

The product is now **mobile landscape**, base logical resolution **1280×720**.

Primary structural UX reference: **Ta Làm Tông Sư Trong Tiên Môn**.

Use the reference for information hierarchy and interaction rhythm only:

- sect map dominates the screen;
- thin top resource/status bar;
- chapter/task rail at left;
- compact edge/floating actions;
- buildings are tapped directly on the map;
- parchment/scroll overlays preserve map context;
- disciple screen uses vertical roster + large character area + detail panel + lower tabs.

Do not copy proprietary art, text, icons, logo, map or exact pixels. Use original Tông Môn Bá Đạo assets.

## P3.1 — Mobile ngang + Tông Môn Sống V1

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

P3.1 is the base presentation layer:

- landscape shell;
- real action -> visible destination mapping;
- disciples visibly move between work/rest/cultivation/gate destinations;
- building popup reads real state;
- disciple popup reads real state;
- Sect Master quick orders call `WorkforceSystem.issue_command()`;
- no parallel gameplay engine.

P3.1 is not yet runtime-confirmed locally.

## P3.2 — Camera + map selection + real disciple tabs

Status: **IMPLEMENTED CURRENT SLICE / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

This is not full P3.2 art production yet. Current implementation adds interaction on top of P3.1 while preserving simulation authority.

### Camera interaction

Files:

- `godot/src/presentation/p3/sect_map_camera.gd`
- `godot/src/presentation/p3_2_landscape_sect.gd`
- `godot/scenes/p3/p3_2_landscape_sect.tscn`

Contract:

- only the map layer zooms/pans; HUD/popups stay fixed;
- mobile pinch zoom;
- one-finger pan on map;
- desktop wheel zoom + left-drag pan for local testing;
- double-tap/double-click quick zoom;
- fallback buttons `+`, `−`, `Mục`, `Toàn`;
- zoom range `0.75x -> 1.80x`;
- default `1.00x`;
- target focus `1.35x` minimum;
- zoom preserves pointer/pinch anchor;
- camera clamps so the whole sect cannot be dragged away;
- camera gestures are blocked while a popup is open;
- screen/world coordinate helpers are deterministic and presentation-only.

### Real map target focus

Tapping a building or disciple now:

1. stores that entity as the current map focus;
2. moves camera focus toward it;
3. displays a gold selection marker/pulse;
4. opens the existing popup;
5. keeps a `Mục` button so the player can return to that selected target after panning away.

For disciples, the selection marker follows their latest visible actor position, but the camera does **not** forcibly auto-follow every movement tick.

### Disciple management tabs are now real

The old tab placeholder notice has been replaced in P3.2.

Current live tabs:

- `Thuộc tính`;
- `Công pháp`;
- `Trang bị`;
- `Huyết Mạch`;
- `Thể Chất`;
- `Quan hệ`.

They read the same `SimulationState` used by gameplay.

`Thuộc tính` shows realm, cultivation progress, combat/cultivation information, HP/stamina/wallet, six foundation values, path XP and current action.

`Công pháp` shows learned techniques, level/mastery, active technique, contribution and personal spirit stones.

`Trang bị` shows weapon/armor/accessory slots, item quality, auto-vs-locked control and real equipment effects.

`Huyết Mạch`:

- never exposes latent hidden identity before reveal;
- shows type/purity/awakening/refinement and real stat effects after reveal;
- buttons `Thức tỉnh` / `Luyện huyết` call the real `BloodlineSystem` and consume real resources.

`Thể Chất`:

- shows actual type + grade + temper level + transformed status;
- shows real Công/Thủ/Tu/Đột phá/Hồi/path-XP effects;
- buttons `Tôi thể` / `Cải thể` call the real `PhysiqueSystem` and consume real resources.

`Quan hệ` reads actual affinity/trust/respect/interactions and companion assignment from P1.3 state.

No duplicate UI-only Bloodline, Physique, equipment or relationship data was added.

### P3.2 tests/verifier

- `godot/tests/presentation/p3_2_map_camera_test.gd`
  - zoom limits;
  - HUD/map hit region;
  - screen/world coordinate round-trip;
  - anchored zoom;
  - pan clamp;
  - normal/edge focus;
  - reset.

- `godot/tests/presentation/p3_2_disciple_ui_test.gd`
  - real scene instantiation;
  - real stage/foundation text;
  - hidden Bloodline does not leak;
  - real Physique profile is displayed;
  - Tôi thể UI path mutates real profile and consumes Yêu Đan;
  - Thức tỉnh UI path mutates real Bloodline and consumes Yêu Đan;
  - Công pháp/Trang bị/Quan hệ tabs read real state;
  - tab popup hierarchy builds.

Verifier:

- `tools/godot/Verify-P3-2-Camera.ps1`;
- `Verify-P3-2-Camera.cmd`;
- `Sync-P3-2-Camera.cmd`.

The P3.2 verifier always reruns the full P3.1 cumulative chain first.

## Next authoritative local command

When the Windows machine is available:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Camera.cmd
```

A successful tail should include:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- `P3.2 MAP CAMERA TEST PASS`
- `P3.2 DISCIPLE UI INTEGRATION TEST PASS`
- `P3.2 CAMERA + DISCIPLE UI GATE: PASS`
- final `P3.2 INTERACTION GATE: PASS`

Do **not** call P3.1 or P3.2 PASS until the real Windows/Godot output reaches this gate.

If it fails, fix the first real parser/diagnostic/assertion failure only.

## Next development order after this interaction gate is green

1. replace placeholders with original production map/building/actor/UI assets while preserving current interaction hierarchy;
2. bind actor animation to actual simulation state;
3. richer visible building production/assignment/upgrades;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. Kỳ Vật/Truyền Thừa item gacha;
10. active age/lifespan/death/inheritance after simulation-year pacing is proven.
