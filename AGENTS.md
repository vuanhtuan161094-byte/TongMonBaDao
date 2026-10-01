# AGENTS.md — Tông Môn Bá Đạo AI Development Contract

## Authority order

1. current user instruction;
2. `docs/DISCIPLE_MASTER_SCHEMA.md` for any disciple/character model question;
3. `CURRENT_CHECKPOINT.md`;
4. live code + tests;
5. active phase spec under `docs/`;
6. older discussion only for historical context.

## Non-negotiable engineering rules

- Godot/GDScript is the simulation authority.
- Do not introduce a parallel gameplay engine.
- Static definitions and runtime state remain separated.
- Simulation code must not depend on presentation/UI nodes.
- Randomness must flow through deterministic seeded streams.
- Existing P0 money conservation remains intact unless a source/sink is explicit.
- P2.3 spirit-stone/material economy stays separate from P0 money.
- Every runtime mutation must preserve invariants.
- New mechanics need measurable gameplay consequences; labels alone do not count.
- Never call a phase PASS without its real cumulative Godot gate.
- Never weaken exact persistence/determinism tests just to make a gate pass.
- New phases must be opt-in when changing locked behavior.
- Hidden identity is generated once and persisted. Reveal/transformation never rerolls it.
- Before changing any disciple subsystem, reconcile it against `docs/DISCIPLE_MASTER_SCHEMA.md`. If design changes, update the master first, then the subsystem.

## Global mechanic-consequence rule

**Do not fear overlap.** Different systems may all modify Công, Thủ, HP, cultivation speed, breakthrough, recovery, production, XP, risk, movement, cooldowns or other concrete outputs when logically justified.

Systems are differentiated by source, acquisition, progression, cost, conditions, tradeoffs and signature rules — not by forcing each system to own a unique stat.

A rare/valuable feature must first provide meaningful player value. Humor, flavor and drawbacks are secondary layers and cannot replace its main benefit.

Every new-system gate must test the actual consequence, not just a field or UI label.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms **P0 through P2.12 PASS**.

P0-P2.12 are locked runtime-green baselines. Do not reopen them without new regression evidence.

Latest confirmed final line:

- `P2.12 GATE: PASS`

## Active presentation work

**P3.1 — Mobile ngang + Tông Môn Sống V1** remains the lower presentation base and is implemented but still awaiting its first real cumulative Godot gate.

**P3.2 Camera Interaction Slice — Zoom + Pan + Focus** is now implemented on top of P3.1 and also awaits real Godot evidence.

This is **not full P3.2 PASS**. Production art/animation/UI replacement is still pending.

Read in this order:

1. `docs/DISCIPLE_MASTER_SCHEMA.md` when character data is touched;
2. `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`;
3. `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`;
4. `CURRENT_CHECKPOINT.md`;
5. live P3.1/P3.2 code and tests.

Authoritative launcher for the current implemented slice:

- `Sync-P3-2-Camera.cmd`

It reruns P0-P2.12, then P3.1 contracts/scene smoke, then P3.2 camera contracts/scene smoke. If P3.1 fails, P3.2 camera verification does not continue.

## Required loop

read master/checkpoint/spec -> narrow scope -> patch -> static review -> headless parse -> cumulative tests -> scene smoke -> checkpoint

## Core game identity

The player is the **Tông Chủ**.

The player controls infrastructure, recruitment, policy, investment, assignments and strategic intervention. Disciples are autonomous people who live, work, cultivate, hunt, recover, consume, form relationships and create stories.

Routine one-by-one micromanagement must remain optional at scale.

## Presentation target — canonical from P3

The game is designed for **mobile landscape**, not portrait.

Base logical resolution:

- `1280 × 720`;
- `canvas_items` stretch;
- `expand` aspect;
- handheld landscape orientation.

Primary UI/UX structural reference: **Ta Làm Tông Sư Trong Tiên Môn**.

Use the reference for information hierarchy and interaction rhythm:

- sect map dominates the screen;
- thin resource/status bar at top;
- chapter/task rail at left;
- compact edge/floating actions;
- buildings are tapped directly on the map;
- parchment/scroll-style overlays preserve map context;
- disciple screen uses vertical roster + large character area + details + lower tabs.

Do **not** copy third-party art, logo, icons, text, exact map or proprietary assets. Tông Môn Bá Đạo must use original visual assets while keeping the interaction skeleton close.

Avoid modern SaaS/dashboard styling on the core game screen.

## P3.1 authority contract

P3.1 is presentation over the existing simulation.

- Map/UI must read the actual `SimulationState`.
- Presentation movement must never mutate simulation region/action authority.
- Building panels must read actual inventory/economy/workforce data.
- Disciple action text/position must come from actual `current_action`.
- Sect Master quick commands must call the existing `WorkforceSystem.issue_command()` API.
- Survival emergency remains above direct command as locked in P2.7.
- Do not create duplicate presentation-only economy, jobs or progression.

### Action -> visible destination

- `CULTIVATE`, `BREAKTHROUGH` -> Tu Luyện Đài;
- `WORK_MINING` -> Khu Khai Khoáng;
- `WORK_FORGING` -> Luyện Khí Đường;
- `REST` -> Đệ Tử Xá;
- `HEAL` -> Dược Phòng;
- `SELL`, `BUY` -> Kho;
- `HUNT`, `TRAVEL`, `COMBAT`, `LOOT`, `RETURN_SECT` -> Tông Môn Đại Môn;
- `HOLD` -> sân trung tâm;
- `EVALUATE`, `IDLE` keep the previous visible destination so actors do not visually snap every short decision tick.

## P3.2 camera contract

Camera is presentation-only and must never mutate simulation.

- map world may scale/pan;
- HUD/task rail/menu/popup never scale with the map;
- mobile pinch zoom;
- one-finger pan on free map area;
- desktop wheel + left-drag fallback for testing;
- double-tap/double-click on free map area zooms toward that point;
- fallback buttons `+`, `−`, `Toàn` remain fixed on HUD;
- zoom range `0.75x` to `1.80x`;
- default `1.00x`;
- focus target `1.35x`;
- pinch/wheel anchor must remain stable;
- pan is clamped so the sect cannot be dragged completely off-screen;
- popup-open state blocks map gestures.

Current main scene:

- `res://scenes/p3/p3_2_landscape_sect.tscn`

## Canonical disciple philosophy

`docs/DISCIPLE_MASTER_SCHEMA.md` is authoritative for the complete character model.

Keep separate:

1. innate foundation;
2. learned progression;
3. awakening/realization/transformation;
4. acquired world assets;
5. living state;
6. organization/social state.

Do not collapse Spiritual Root, Bloodline, Physique, Destiny, traits/quirks and personality into one system.

## Locked character summary through P2.12

### Foundation and quality

Six dimensions:

- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Disciple quality is derived:

`Phàm Thường -> Xuất Chúng -> Thiên Kiêu -> Tuyệt Luân -> Nghịch Thiên`.

### Spiritual Root

Element/count and purity are separate. Refinement uses real Linh Tủy, does not ordinarily alter element list, and latent mutation is deterministic before reveal.

### Bloodline

Bloodline is independent. Special awakened bloodlines have real core stat value before gimmicks. Reveal/awakening never rerolls identity. Refinement uses real resources. Bloodline effects can stack with other systems.

### Physique

Physique has two independent axes:

- grade: `Phàm Thể -> Linh Thể -> Huyền Thể -> Thánh Thể -> Thần Thể`;
- named type: none / Kiếm Cốt / Kim Cương Bá Thể / Hàn Âm Thể / Hỏa Linh Thể / Vô Cấu Đạo Thể.

Display unnamed type as only the grade. Display named type as e.g. `Kiếm Cốt · Huyền Thể`.

Tempering improves real effects without rerolling type/grade. Transformation uses the pre-generated latent target and preserves grade. Routine tempering does not automatically promote grade.

## Gacha separation — canonical

1. **Chiêu Hiền / disciple gacha** -> rolls a complete person using the master schema.
2. **Kỳ Vật / Truyền Thừa gacha** -> future item banner for Huyết Tinh, Đạo Thai, Bản Nguyên, manuals, artifacts and other transformative/acquired items.

Item gacha may grant/refine Bloodline/Physique/etc according to explicit rules, but must never silently reroll or overwrite incompatible innate identity.

## Xianxia humor/flavor

Cultivation-story humor is allowed but the game is not a meme game. Humor must come from real simulation causes/consequences and cannot replace the core value of a mechanic.

## Current verification chain

Use:

- `tools/godot/Verify-P3-2-Camera.ps1`
- `Sync-P3-2-Camera.cmd`

The current cumulative gate must prove:

- P0-P2.12 remain green;
- P3.1 landscape shell contracts remain green;
- P3.1 base scene loads headless;
- P3.2 is the active main presentation scene;
- camera zoom is clamped to 0.75x–1.80x;
- zoom preserves anchor position;
- pan cannot move the entire map off-screen;
- focus transform centers an unclamped target;
- reset restores canonical overview;
- P3.2 zoomable scene loads and runs headless.

Never claim P3.1 or P3.2 camera PASS without final real Godot 4.7.2 output.

## After camera runtime green

1. production art/animation/UI replacement while preserving the landscape hierarchy and camera behavior;
2. visible building production, assignment and upgrades;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority;
6. master-disciple/teaching;
7. Destiny;
8. item/transmission gacha;
9. active lifespan/death/inheritance after pacing is proven.
