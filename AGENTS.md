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
- `Sync-Main.cmd` is the single stable Windows sync entrypoint. Do not create or instruct phase-specific `Sync-*.cmd` launchers as the primary workflow. For a new gate, add/update only its `Verify-*.cmd`, then instruct `Sync-Main.cmd Verify-<gate>.cmd`. This avoids the bootstrap problem where a newly created sync launcher does not yet exist on local. `Sync-Main.cmd` blocks tracked/staged local edits, but untracked files only produce a warning; it never deletes them, and Git itself must refuse any pull that would overwrite an untracked path.
- Hidden identity is generated once and persisted. Reveal/awakening/transformation never rerolls it.
- Before changing a disciple subsystem, reconcile the change against `docs/DISCIPLE_MASTER_SCHEMA.md`; if design changes, update the master first.

## Global mechanic-consequence rule

**Do not fear overlap.** Linh căn, Huyết Mạch, Thể Chất, Đặc Chất, Công pháp, Trang bị, Thiên Mệnh, buildings, ranks and future systems may all affect Công, Thủ, HP, cultivation, breakthrough, recovery, profession/mastery, production, economy, AI behavior, risk, movement, cooldown or similar outputs when logical.

Systems differ by source, acquisition, progression, cost, conditions, tradeoffs, timing and signature rules — not by reserving an exclusive stat for each feature.

A rare/valuable feature must first have meaningful gameplay value. Flavor/humor/drawbacks are secondary.

## Runtime baseline

Real Windows + Godot 4.7.2 evidence confirms:

- P0-P2.12: PASS;
- P3.1 landscape/living-sect shell: PASS;
- P3.2 camera + map selection + real disciple tabs interaction slice: PASS;
- P3.2 Character Creator V1 shared-rig scaffold: PASS.
- P3.2 live modular female map integration: PASS (`[8/8]` real Windows Godot 4.7.2 evidence, 2026-10-04).

These are locked runtime-green baselines. Do not reopen them without new regression evidence.

Latest confirmed Character Creator tail includes:

- `P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS`
- `P3.2 CHARACTER CREATOR SCAFFOLD GATE: PASS`
- `CHARACTER CREATOR V1 SCAFFOLD GATE: PASS`

Important: scaffold PASS does **not** mean full P3.2 production art or the female visual vertical slice is complete.

## Active presentation / gameplay work

Current user priority is **functionality-first living-sect management**, not character-art micro-detail.

Immediate runtime order:

1. P3.2 live modular female map `[8/8]` is real PASS / locked;
2. run/fix/lock P3.3 disciple operational flow;
3. implement/runtime-lock P3.4 building management;
4. implement/runtime-lock P3.5 living-sect cues;
5. judge the result against the P3.6 Sect Master gameplay-loop contract.

Character Creator remains a supporting anti-clone/presentation system. Minimum cosmetic variants can be completed later and must not block P3.3–P3.6 functional work.

Regression launchers:

- `Sync-P3-2-Camera.cmd` — locked P3.1/P3.2 interaction chain;
- `Verify-P3-2-Character-Creator.cmd` — reruns the cumulative P3.2 chain, then the shared-rig Character Creator contract.

Read before P3/character work in this order:

1. `CURRENT_CHECKPOINT.md`;
2. `NEXT_CHAT_HANDOFF.md`;
3. `docs/DISCIPLE_MASTER_SCHEMA.md`;
4. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
5. `docs/P3_1_LANDSCAPE_SECT_SHELL_SPEC.md`;
6. `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`;
7. `docs/P3_4_BUILDING_MANAGEMENT_SPEC.md`;
8. `docs/P3_5_LIVING_SECT_CUES_SPEC.md`;
9. `docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md`;
10. live P3 code/tests.

## Required development loop

read authority -> narrow scope -> patch -> static review -> cumulative headless tests -> scene smoke -> checkpoint

If local Godot is unavailable, presentation code may continue cautiously, but do not claim runtime PASS without real evidence. Never weaken tests to manufacture green.

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

## P3.2 interaction contract — locked runtime green

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

Current real-system tabs:

- Thuộc tính;
- Công pháp;
- Trang bị;
- Huyết Mạch;
- Thể Chất;
- Quan hệ.

Rules:

- hidden Bloodline displays `Chưa xác định` and never leaks latent type/purity;
- Bloodline buttons invoke real `BloodlineSystem` actions and costs;
- Physique buttons invoke real `PhysiqueSystem` actions and costs;
- equipment display reads real item ownership/slot locks;
- relationship display reads actual P1.3 state;
- no tab invents parallel values for presentation.

## Character Creator V1 contract — locked scaffold

Canonical architecture is **modular appearance + shared 2D rig/animation**.

Map actor and profile artwork are separate pipelines.

Initial rig IDs:

- `female_normal_v1`;
- `male_normal_v1`.

Canonical registration:

- source canvas `128×128`;
- source foot anchor `(64,104)`;
- map display scale `0.68` at zoom 1.0;
- actor box `88×92`.

Canonical bones:

`root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.

Canonical render layers:

`shadow -> aura -> hair_back -> weapon_back -> body -> outfit -> face -> hair_front -> head_accessory -> weapon_front -> accessory`.

One rig uses one `AnimationPlayer`/shared `AnimationLibrary` driving `Bone2D` transforms. Do not return to 11 synchronized `AnimatedSprite2D` timelines.

Public directions remain `down/right/up/left`; mirror-safe left may reuse right playback without changing public facing.

Appearance is presentation identity only. Existing disciple `sex_id` cannot be silently overridden. Appearance work must not mutate simulation state or alter P2.8 RNG consumption/order.

The shared-rig scaffold is runtime-green, but it remains isolated from the live map until the production visual proof is accepted.

## Canonical disciple philosophy

`docs/DISCIPLE_MASTER_SCHEMA.md` remains authoritative for the complete character model.

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

## Current next production order

1. P3.2 live modular map `[8/8]` real PASS / locked;
2. P3.3 disciple operational flow gate;
3. P3.4 building management runtime;
4. P3.5 living-sect cues runtime;
5. P3.6 real gameplay-loop playtest;
6. minimum cosmetic variants needed to avoid obvious clones;
7. six-combo/full female visual acceptance when functional map-management is stable;
8. backward-compatible `appearance_profile` persistence;
9. only then expand male rig, action set and asset volume.
