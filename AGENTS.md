# AGENTS.md — Tông Môn Bá Đạo AI Development Contract

## Authority order

1. current user instruction;
2. `docs/DISCIPLE_MASTER_SCHEMA.md` for any disciple/character model question;
3. `CURRENT_CHECKPOINT.md`;
4. live code + tests;
5. active phase spec under `docs/`;
6. older discussion only for historical context.

## Non-negotiable engineering rules

- Godot/GDScript is the gameplay/simulation authority.
- Do not introduce a parallel gameplay engine or duplicate UI-only progression state.
- Static definitions and runtime state remain separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through deterministic seeded streams.
- Existing P0 money conservation remains intact unless a source/sink is explicit.
- P2.3 spirit-stone/material economy stays separate from P0 money.
- Every runtime mutation must preserve invariants.
- New mechanics need measurable gameplay consequences; labels alone do not count.
- Never call a phase PASS without its real cumulative Godot gate.
- Never weaken persistence/determinism/contract tests merely to make a gate pass.
- Hidden identity is generated once and persisted. Reveal/awakening/transformation never rerolls it.
- Before changing a disciple subsystem, reconcile the change against `docs/DISCIPLE_MASTER_SCHEMA.md`; if design changes, update the master first.

## Global mechanic-consequence rule

**Do not fear overlap.** Linh căn, Huyết Mạch, Thể Chất, Đặc Chất, Công pháp, Trang bị, Thiên Mệnh, buildings, ranks and future systems may all affect Công, Thủ, HP, cultivation, breakthrough, recovery, profession/mastery, production, economy, AI behavior, risk, movement, cooldown or similar outputs when logical.

Systems differ by source, acquisition, progression, cost, conditions, tradeoffs, timing and signature rules — not by reserving an exclusive stat for each feature.

A rare/valuable feature must first have meaningful gameplay value. Flavor/humor/drawbacks are secondary.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.12 PASS**.

P0-P2.12 are locked runtime-green baselines. Do not reopen them without new regression evidence.

Latest confirmed final line:

- `P2.12 GATE: PASS`

## Active presentation work

P3.1 and the current P3.2 interaction slice are implemented but **not yet runtime-confirmed on the user's Windows/Godot machine**.

Never call either PASS before the cumulative local gate returns green.

Current authoritative launcher:

- `Sync-P3-2-Camera.cmd`

Despite the historical filename, this launcher now verifies both P3.2 map-camera interaction and integrated real disciple tabs.

Read in this order:

1. `CURRENT_CHECKPOINT.md`;
2. `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`;
3. `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`;
4. live P3 code/tests;
5. `docs/DISCIPLE_MASTER_SCHEMA.md` whenever character data/mechanics are touched.

## Required development loop

read authority -> narrow scope -> patch -> static review -> cumulative headless tests -> scene smoke -> checkpoint

If local Godot is unavailable, presentation code may continue cautiously, but do not claim runtime PASS. Avoid risky simulation rewrites while the presentation gate is unconfirmed.

## Core game identity

The player is the **Tông Chủ**.

The player controls infrastructure, recruitment, policy, investment, assignments and strategic intervention. Disciples are autonomous people who live, work, cultivate, hunt, recover, consume, form relationships and create stories.

Routine one-by-one micromanagement must remain optional at scale.

## Presentation target — canonical

The game is **mobile landscape**, not portrait.

Base logical resolution:

- `1280 × 720`;
- `canvas_items` stretch;
- `expand` aspect;
- handheld landscape orientation.

Primary structural UI/UX reference: **Ta Làm Tông Sư Trong Tiên Môn**.

Use the reference for hierarchy and interaction rhythm:

- sect map dominates the screen;
- thin resource/status bar at top;
- chapter/task rail at left;
- compact edge/floating actions;
- buildings are tapped directly on the map;
- parchment/scroll overlays preserve map context;
- disciple screen uses vertical roster + large character area + details + lower tabs.

Do not copy third-party art, logo, icons, text, exact map or proprietary assets. Tông Môn Bá Đạo must use original assets.

Avoid modern SaaS/dashboard styling on the core game screen.

## P3.1 authority contract

P3.1 is presentation over existing simulation:

- map/UI reads actual `SimulationState`;
- presentation movement never mutates simulation action/region authority;
- building panels read real inventory/economy/workforce state;
- disciple map action/position comes from actual `current_action`;
- Sect Master quick commands call `WorkforceSystem.issue_command()`;
- survival emergency remains above direct command as locked in P2.7;
- no duplicate presentation-only economy/jobs/progression.

Action -> visible destination:

- `CULTIVATE`, `BREAKTHROUGH` -> Tu Luyện Đài;
- `WORK_MINING` -> Khai Khoáng;
- `WORK_FORGING` -> Luyện Khí Đường;
- `REST` -> Đệ Tử Xá;
- `HEAL` -> Dược Phòng;
- `SELL`, `BUY` -> Kho;
- `HUNT`, `TRAVEL`, `COMBAT`, `LOOT`, `RETURN_SECT` -> Đại Môn;
- `HOLD` -> sân trung tâm;
- `EVALUATE`, `IDLE` preserve the previous visible destination.

## P3.2 interaction contract — current

### Camera

`SectMapCamera` owns presentation-only math for:

- zoom range `0.75x -> 1.80x`;
- default `1.00x`, focus target `1.35x`;
- mobile pinch zoom and one-finger pan;
- desktop wheel/drag equivalents for testing;
- anchored zoom;
- screen/world coordinate conversion;
- pan/focus clamping;
- reset.

Only the map transforms. HUD and popups remain fixed.

### Map target selection

Tapping a building or disciple:

- sets current focus target;
- focuses camera toward it;
- shows a gold selection marker/pulse;
- opens its popup;
- enables `Mục` to return to the selected target after panning.

Disciple marker follows the actor's latest visible position, but camera must not forcibly auto-follow every tick.

### Disciple tabs

P3.2 tab buttons must expose real systems, not placeholder text.

Current tabs:

- Thuộc tính;
- Công pháp;
- Trang bị;
- Huyết Mạch;
- Thể Chất;
- Quan hệ.

Rules:

- hidden Bloodline must display `Chưa xác định` and never leak latent type/purity;
- Bloodline buttons invoke real `BloodlineSystem` actions and real resource costs;
- Physique buttons invoke real `PhysiqueSystem` actions and real resource costs;
- equipment display reads real item ownership/slot locks;
- relationship display reads actual P1.3 state;
- no tab may invent a parallel value just for presentation.

## Canonical disciple philosophy

`docs/DISCIPLE_MASTER_SCHEMA.md` is authoritative for the complete character model.

Keep separate:

1. innate foundation;
2. learned progression;
3. awakening/realization/transformation;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits and personality into one system.

Foundation dimensions:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Quality is derived:

`Phàm Thường -> Xuất Chúng -> Thiên Kiêu -> Tuyệt Luân -> Nghịch Thiên`.

Physique remains two-axis:

- grade `Phàm Thể -> Linh Thể -> Huyền Thể -> Thánh Thể -> Thần Thể`;
- named type separate from grade.

Bloodline + Physique and other logical stat sources are allowed to stack.

## Gacha separation — canonical

1. **Chiêu Hiền / disciple gacha** -> rolls a complete person using the master schema.
2. **Kỳ Vật / Truyền Thừa gacha** -> future item banner for Huyết Tinh, Đạo Thai, Bản Nguyên, manuals, artifacts and other transformative/acquired items.

Item gacha may grant/refine Bloodline/Physique/etc under explicit rules, but must never silently reroll or overwrite incompatible identity.

## Current verification chain

Use:

- `Sync-P3-2-Camera.cmd`.

It must rerun P0-P2.12 and P3.1 before P3.2.

Current P3.2 checks include:

- map camera math and clamp contracts;
- active P3.2 main scene;
- screen/world coordinate round-trip;
- real scene instantiation;
- real disciple tab data;
- hidden Bloodline non-leak;
- real Tôi thể resource/action path;
- real Bloodline awakening resource/action path;
- Công pháp/Trang bị/Quan hệ state reads;
- P3.2 scene smoke.

Expected successful tail:

- `P3.1 LANDSCAPE SECT SHELL TEST PASS`
- `P3.1 LANDSCAPE SECT SHELL GATE: PASS`
- `P3.2 MAP CAMERA TEST PASS`
- `P3.2 DISCIPLE UI INTEGRATION TEST PASS`
- `P3.2 CAMERA + DISCIPLE UI GATE: PASS`
- `P3.2 INTERACTION GATE: PASS`

Do not claim P3.1/P3.2 PASS until real local output proves it.

## After current interaction gate is green

1. production art/animation/UI replacement while preserving current hierarchy and interactions;
2. visible building production/assignment/upgrades;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority;
6. master-disciple/teaching;
7. Destiny;
8. item/transmission gacha;
9. active lifespan/death/inheritance after pacing is proven.
