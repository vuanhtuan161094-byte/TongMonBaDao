# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Working style / user preference

- User wants direct game coding on GitHub, not mockup images.
- Do not use Codex or Work.
- User is non-technical; after each meaningful phase explain: (1) người chơi sẽ thấy gì, (2) hệ thống phía sau làm gì.
- Do not claim a runtime phase PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable console.

At handoff time live main HEAD was `510478530dbb4fb5a8096497c8c996259c590ca2` (`Advance agent contract to integrated P3.2 interaction`). Re-fetch live HEAD before doing anything.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.12 PASS**.

Latest authoritative user evidence ended with:

- `P2.12 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.12 PHYSIQUE + GRADES + TEMPERING + TRANSFORMATION TEST PASS`
- `P2.12 PHYSIQUE + TEMPERING + TRANSFORMATION GATE: PASS`
- final `P2.12 GATE: PASS`

Do not reopen P0-P2.12 without new regression evidence.

## Character authority

Read `docs/DISCIPLE_MASTER_SCHEMA.md` before any character-system work.

Locked principles:

- six foundation dimensions: Tư Chất / Căn Cốt / Cơ Duyên / Thông Tuệ / Mị Lực / Tiềm Lực;
- disciple quality is derived, not separately rolled;
- Linh căn / Huyết Mạch / Thể Chất / traits / Destiny are separate axes;
- hidden identity is generated once and persisted; reveal/awakening/transformation never rerolls it;
- systems may overlap on Công/Thủ/HP/Tu/Đột phá/Hồi/etc. when logical;
- named mechanics must have real consequences, not UI-only flavor.

### P2.12 Physique locked model

Two independent axes:

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

## Product presentation canon

The game is now **mobile landscape**, base logical resolution **1280×720**.

Primary structural UI/UX reference: **Ta Làm Tông Sư Trong Tiên Môn**.

Use it for information hierarchy and interaction rhythm only:

- sect map dominates screen;
- thin top resource/status bar;
- chapter/task rail at left;
- compact edge/floating actions;
- buildings tapped directly on map;
- parchment/scroll overlays preserve map context;
- disciple screen = vertical roster + large character area + right detail + lower tabs.

Do not copy proprietary art/text/icons/logo/map/exact pixels. Use original assets.

## P3.1 — Mobile ngang + Tông Môn Sống V1

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Base presentation already includes:

- landscape shell;
- real action -> visible map destination mapping;
- disciples visibly move between work/rest/cultivation/gate destinations;
- building popup reads real state;
- disciple popup reads real state;
- quick Sect Master orders call `WorkforceSystem.issue_command()`;
- no parallel gameplay engine.

Important map destinations:

- CULTIVATE/BREAKTHROUGH -> Tu Luyện Đài;
- WORK_MINING -> mine;
- WORK_FORGING -> forge;
- REST -> residence;
- HEAL -> medicine;
- SELL/BUY -> warehouse;
- HUNT/TRAVEL/COMBAT/LOOT/RETURN_SECT -> gate;
- HOLD -> courtyard;
- EVALUATE/IDLE preserve previous visible destination.

## P3.2 — Camera + map selection + real disciple tabs

Status: **IMPLEMENTED CURRENT SLICE / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

This is current active code. Main scene is `res://scenes/p3/p3_2_landscape_sect.tscn`.

### Camera

Files:

- `godot/src/presentation/p3/sect_map_camera.gd`
- `godot/src/presentation/p3_2_landscape_sect.gd`
- `godot/scenes/p3/p3_2_landscape_sect.tscn`

Implemented:

- only map layer zooms/pans; HUD and popups stay fixed;
- mobile pinch zoom;
- one-finger pan;
- desktop wheel zoom + left-drag pan;
- double-tap/double-click quick zoom;
- fallback buttons `+`, `−`, `Mục`, `Toàn`;
- zoom range `0.75x -> 1.80x`, default `1.00x`, focus minimum `1.35x`;
- zoom preserves anchor;
- camera clamp prevents dragging whole sect away;
- popup blocks map camera gestures.

### Map selection / focus

Tapping a building or disciple:

1. stores current target;
2. focuses camera toward it;
3. shows gold selection marker/pulse;
4. opens existing popup;
5. `Mục` returns camera to selected target after panning away.

Disciple selection marker follows latest visible actor position. Camera does not auto-follow every movement tick.

### Real disciple management tabs

Current tabs read the same real `SimulationState`:

- `Thuộc tính`;
- `Công pháp`;
- `Trang bị`;
- `Huyết Mạch`;
- `Thể Chất`;
- `Quan hệ`.

`Thuộc tính`: realm, cultivation progress, combat/cultivation info, HP/stamina/wallet, six foundations, path XP, current action.

`Công pháp`: learned techniques, mastery/level, active technique, contribution, personal spirit stones.

`Trang bị`: weapon/armor/accessory, quality, locked-vs-auto control, real effects.

`Huyết Mạch`: never leaks latent hidden identity; after reveal shows type/purity/awakening/refinement/stat effects. Buttons call real `BloodlineSystem` and consume real resources.

`Thể Chất`: actual type + grade + temper level + transformed status + real stat effects. Buttons call real `PhysiqueSystem` and consume real resources.

`Quan hệ`: real affinity/trust/respect/interactions and companion assignment.

No duplicate UI-only gameplay state was added.

## P3.2 verifier

Tests:

- `godot/tests/presentation/p3_2_map_camera_test.gd`
- `godot/tests/presentation/p3_2_disciple_ui_test.gd`

Verifier/launcher:

- `tools/godot/Verify-P3-2-Camera.ps1`
- `Verify-P3-2-Camera.cmd`
- `Sync-P3-2-Camera.cmd`

The verifier reruns full P3.1 cumulative chain first.

## Next authoritative local command

When Windows machine is available:

```bat
cd /d "E:\0.2. TongMonBaDao"
Sync-P3-2-Camera.cmd
```

Expected successful tail:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- `P3.2 MAP CAMERA TEST PASS`
- `P3.2 DISCIPLE UI INTEGRATION TEST PASS`
- `P3.2 CAMERA + DISCIPLE UI GATE: PASS`
- final `P3.2 INTERACTION GATE: PASS`

Do **not** call P3.1/P3.2 PASS until real user output reaches this gate.

If failure: inspect/fix the **first real parser/diagnostic/assertion failure only**. Do not weaken locked tests.

## Next development order after P3.2 gate green

1. replace placeholders with original production map/building/actor/UI assets while preserving current hierarchy;
2. bind actor animation to actual simulation state;
3. richer visible building production/assignment/upgrades;
4. injury/medical;
5. loyalty + stipend/reward;
6. sect rank/authority expansion;
7. master-disciple/teaching;
8. Destiny/awakening;
9. Kỳ Vật/Truyền Thừa item gacha for HM/TC/other acquired transformations;
10. active age/lifespan/death/inheritance after simulation-year pacing is proven.

## Immediate instruction for the next chat

Start by fetching live `main`, then read `AGENTS.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, and P3 specs. Do not ask the user to repeat context. If the machine is available, prioritize running/fixing the P3.2 cumulative gate. If the machine is still unavailable, continue only safe GitHub-side work and keep status as `AWAITING REAL GODOT GATE`; never claim PASS.