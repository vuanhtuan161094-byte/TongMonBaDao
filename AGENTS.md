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
- Never call a phase PASS without its real final/cumulative Godot gate.
- During active iteration, use a **FAST gate by default**: parse only changed/adjacent scripts, run the active phase contract, and run the smallest relevant scene smoke. Do **not** rerun locked cumulative baselines after every small patch.
- Run a **FULL cumulative gate only** when preparing to lock a phase PASS, when a change crosses into a previously locked subsystem, or when regression evidence specifically points into that baseline.
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
- P3.3 disciple operational flow: PASS on real Windows Godot 4.7.2.
- P3.4 building management A/B/C: PASS on real Windows Godot 4.7.2.
- P3.5 living-sect cues: PASS on real Windows Godot 4.7.2.

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
2. P3.3 disciple operational flow: real PASS / locked;
3. P3.4 building management: real PASS / locked;
4. P3.5 living-sect cues: real PASS / locked;
5. P3.6A playable vertical slice is implemented/runtime-green; final visual acceptance remains user-owned;
6. long-term direction is now defined by `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`: hunting-centric sect economy, 1,000–3,000 disciples, profession growth, autonomous personal economy and low-micro management.

Character Creator remains a supporting anti-clone/presentation system. Minimum cosmetic variants can be completed later and must not block P3.3–P3.6 functional work.

Regression launchers:

- `Verify-P3-6A-Playable-Slice.cmd` — FAST active-slice verifier; default during P3.6A iteration;
- `Run-P3-6A-Playable-Slice.cmd` — one-click convenience runner: FAST gate -> auto-open preview on PASS;
- `Verify-P3-6A-Playable-Slice-Full.cmd` — FULL cumulative verifier; final/cross-baseline use only;

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
10. `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`;
11. `docs/P3_7_BUILDING_TREE_SPEC.md`;
12. `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`;
13. `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`;
14. `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`;
15. live P3 code/tests.

## GitHub CI preview

GitHub CI preview is restored: `.github/workflows/p3-6a-preview.yml` rebuilds the canonical female Stage A pack from tracked `.github/assets/p3/female_stage_a/*.b64` parts in fixed order, verifies ZIP size `44,838` bytes and SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`, extracts exactly 42 PNGs, imports Godot 4.7.2, runs the P3.6A FAST gate, renders under Xvfb, captures `1280x720` PNG, and uploads it as an artifact. Actor appearance is therefore part of CI preview authority; do not assume female actors are placeholders when this restore step is green.

## Required development loop

read authority -> narrow scope -> patch -> static review -> FAST targeted gate -> scene smoke -> checkpoint; FULL cumulative gate only for final phase lock or justified cross-baseline regression

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

1. P3.2 live modular map `[8/8]`: real PASS / locked;
2. P3.3 disciple operational flow: real PASS / locked;
3. P3.4 building management: real PASS / locked;
4. P3.5 living-sect cues: real PASS / locked;
5. P3.6A playable runtime remains green; visual acceptance is user-owned and not a blocker for backend P3.7;
6. P3.7A1 Building Authority + Mine: official Godot 4.7.2 backend CI green;
7. P3.7A2 Linh Điền on the same BuildingSystem: official Godot 4.7.2 backend CI green, including six-foundation save/load and competing-worker regressions;
8. P3.7B1 Resource Registry + canonical Sect Warehouse: official Godot 4.7.2 backend CI green; all P3.7 material consumers now use one warehouse and legacy P2 stays isolated;
9. **next: P3.7B2 Construction Resolver by material-family Phẩm Lực**, respecting reserve/lock and consuming low-value eligible stock first while milestone specialty items remain exact;
10. then profession Lv.1–1000+ curve/milestones + higher-realm resource discovery;
11. then additional core buildings on the proven BuildingSystem/Warehouse authority;
12. only after backend authority is real should live P3 presentation expose P3.7 building levels/upgrades/production;
13. cosmetic/character-creator expansion remains secondary until functional management is stable.
