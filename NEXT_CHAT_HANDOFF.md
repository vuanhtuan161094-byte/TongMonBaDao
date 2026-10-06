# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-04

Always fetch/inspect live `main` before editing.

## Working style / user preference

- Code directly through the GitHub connector.
- Do not use Codex or Work.
- Do not ask the user to repeat repo/spec context.
- Explain progress clearly in Vietnamese; user is non-technical.
- Never claim runtime PASS without real Godot 4.7.2 output from the user's Windows machine.
- Never use destructive local git instructions (`reset --hard`, `git clean`, deleting user files, etc.).
- Stable Windows workflow: use root `Sync-Main.cmd` for all future syncs. For a gate run `Sync-Main.cmd Verify-<gate>.cmd`. Do not rely on newly created phase-specific Sync launchers because they may not exist on local before the sync. Untracked local files are warning-only; tracked/staged edits still stop sync.

Repo: `vuanhtuan161094-byte/TongMonBaDao`
Branch: `main`
Local: `E:\0.2. TongMonBaDao`
Godot: 4.7.2 stable.

## Required read order before P3/character work

1. `AGENTS.md`;
2. `CURRENT_CHECKPOINT.md`;
3. `NEXT_CHAT_HANDOFF.md`;
4. `docs/DISCIPLE_MASTER_SCHEMA.md`;
5. `docs/P3_PRESENTATION_MASTER.md` for any UI/UX/art/mockup task;
6. `docs/P3_ART_BIBLE.md`;
7. `docs/P3_ASSET_REGISTRY.json`;
8. `docs/P3_UX_FLOW_V3.md` for core map/disciple interaction work;
9. relevant presentation item MD (`P3_ASSET_BUILDINGS.md`, `P3_ASSET_MAP_ENVIRONMENT.md`, `P3_UX_MAIN_MAP.md`, `P3_UX_DISCIPLE_SCREEN.md`, `P3_UI_SKIN_AND_ICONOGRAPHY.md`);
10. `docs/P3_2_MODULAR_ACTOR_SPEC.md`;
11. `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`;
12. related P3 specs;
13. live P3 code/tests.

For a major long-lived pipeline/architecture change, also inspect `docs/decisions/` before changing direction.

## Presentation workflow — LOCKED 2026-10-03

User explicitly requires a **plan before every image generation/edit/mockup**. Do not call image generation first.

Workflow:

1. read `docs/P3_PRESENTATION_MASTER.md`;
2. read `docs/P3_ART_BIBLE.md`;
3. read the relevant item MD;
4. inspect `docs/P3_ASSET_REGISTRY.json` and reuse previously approved source assets;
5. present a concise plan covering goal, composition, inherited approved assets, locked elements, allowed changes, dimensions/style and differences from previous version;
6. generate only after user approves that plan;
7. after user accepts a visual, update the item MD + registry so the decision/evidence is recoverable from repo.

Existing approved building art must be treated as visual authority. The approved building family predates this handoff and includes Tông Môn Đại Điện, Phòng Ốc/Đệ Tử Xá, Luyện Khí Đường, Kho and later Tu Luyện Đài, Dược Phòng, Khu Khai Khoáng, Tông Môn Đại Môn. Style: hand-painted 2D mobile, light isometric/top-down, pastel/ink-wash, clear silhouettes, simple slightly cute forms, shared camera/scale/footprint. **Do not redesign these buildings in a new mockup just because the image model can invent alternatives.**

The live GitHub repo does not currently contain a reliable tracked binary pack for those approved building images, so their approved status is recorded in `docs/P3_ASSET_BUILDINGS.md` and `docs/P3_ASSET_REGISTRY.json`; when source images are available in chat/library, use them directly as references. Do not silently substitute newly generated architecture.

User also prefers the brighter hand-painted/parchment mood of the 2026-10-03 V3 map mockup over the earlier darker/heavier mockups. This affects UI/map mood, not the identity of already-approved building assets.

### Presentation static audit

- `tools/validate_p3_presentation.py` checks registry/doc integrity only;
- `.github/workflows/p3-presentation-audit.yml` runs it automatically when P3 docs/registry/source-art workflow changes;
- static audit PASS is **never** a substitute for a real Godot runtime gate.

### Decision records

- `docs/decisions/0001-use-p3-presentation-authority-workflow.md` — accepted;
- `docs/decisions/0002-adopt-git-lfs-for-production-art.md` — proposed only.

Do not enable Git LFS for production art until the planned Windows verification is performed. `source_art/` is reserved as the future editable-master root outside `godot/` so Godot does not import source masters.

## UX V3 — USER APPROVED 2026-10-04

Canonical flow is now:

`V3.1 Main Map -> tap disciple -> V3.2 right vertical summary panel -> Xem chi tiết -> V3.3 disciple deep screen -> Back restores map context`.

Read `docs/P3_UX_FLOW_V3.md` before changing this flow.

Locked V3.2 behavior:

- panel is on the **right**, not left and not a floating tooltip;
- approx 280–320 px wide at 1280×720;
- map remains visible;
- shows portrait/name, realm, HP, stamina, cultivation progress, current work, status, location, key stats, skill/technique cues, contextual action and `Xem chi tiết`;
- tap another disciple switches panel;
- X/blank tap closes;
- hidden Bloodline/Physique/traits must not leak.

Locked V3.3 behavior:

- left vertical disciple roster;
- large center character showcase;
- detailed right content;
- exactly six current real tabs: Thuộc tính / Công pháp / Trang bị / Huyết Mạch / Thể Chất / Quan hệ;
- preserve semantic continuity for HP/stamina/cultivation/work/status/location;
- Back should restore selected disciple + V3.2 panel when still valid.

Registry records V3.1/V3.2/V3.3 as visual-approved but source-missing S3 and runtime not integrated. **Do not call them runtime PASS.**

Next UX design step after documentation lock: **building selection/management interaction**. Plan it with user before any new mockup/image.

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 confirms:

- P0-P2.12: PASS;
- P3.1: PASS;
- P3.2 camera/map-selection/real disciple tabs: PASS;
- P3.2 Character Creator shared-rig scaffold: PASS;
- `female_normal_v1` Stage A 3-DIRECTION FAST (down/right/up): PASS; real visual preview accepted.
- `female_normal_v1` shared IDLE/WALK FAST: PASS on real Windows Godot 4.7.2; user motion video accepted.

Real three-direction tail:

```text
P3.2 CHARACTER CREATOR SHARED RIG CONTRACT TEST PASS
P3.2 FEMALE STAGE A DOWN ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION ASSET CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
```

User supplied the real front/side/back preview and accepted the visual proof. Stage A final milestone remains **NOT FULL PASS**; shared motion, variants/tints/six-combo proof and FULL cumulative acceptance are still pending.

## Down/front visual review — accepted

User supplied a real screenshot at `0.75x / 1.00x / 1.35x`.

Accepted:

- head/face/hair/horns coherent;
- arms/shoulders attached;
- no major skirt/outfit seam;
- feet share ground registration;
- silhouette readable at `0.75x`.

Dark hair + skirt merging at `0.75x` is future art contrast work, not a pivot defect. **No bone rest positions were changed.**

## Current active task — P3.6A playable vertical slice (runtime PASS / visual review pending)

Three-direction Stage A is now runtime-green and visually accepted:

- `down` = front;
- `right` = authored side;
- `up` = authored back;
- `left` = mirror-right while safe.

The real Windows FAST gate passed on Godot 4.7.2, then the user reviewed the real preview at map scales. No practical-pivot change is required from this proof.

One shared AnimationLibrary is now implemented and runtime-green for:
- idle down/right/up/left;
- walk down/right/up/left;
- left mirrored from right while mirror-safe;
- no per-disciple animation timelines.

Real Windows FAST tail:

```text
P3.2 FEMALE SHARED IDLE WALK MOTION CONTRACT TEST PASS
P3.2 FEMALE STAGE A 3-DIRECTION FAST CHECK: PASS
P3.2 FEMALE SHARED IDLE WALK FAST CHECK: PASS
FEMALE STAGE A + SHARED MOTION FAST CHECK: PASS
```

User supplied an 11.6-second real motion video. Current V1 idle/walk visual motion is accepted: restrained idle, stable cadence, no obvious anchor jump or severe seam tear, hair/horns stay attached, LEFT mirror is clean. Secondary hair/skirt dynamics remain future polish.

## Binary transport — RESOLVED / CI GREEN

The canonical pack is now tracked text-safely as fixed-order Base64 parts under `.github/assets/p3/female_stage_a/`.

Canonical ZIP:

- `female_normal_v1_stageA_runtime_pack_v2_quant.zip`;
- 44,838 bytes;
- 42 PNGs;
- SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`.

Final corruption diagnosis on 2026-10-05 found one payload typo in `part11.b64`: char index 1432 (0-based) was `a`, canonical is `e`. After that repair and the earlier directory repair, a production-clean workflow (no brute/rebuild patching) reconstructs the exact canonical SHA and passes `unzip -t`.

`.github/workflows/p3-6a-preview.yml` now performs:

`checkout -> Godot 4.7.2 -> fixed-order Base64 restore -> size/SHA/42-PNG checks -> import -> P3.6A FAST -> Xvfb 1280x720 capture -> artifact upload`.

`Install-P3-2-Female-StageA.cmd` now restores from tracked transport first, with external ZIP only as fallback. `Run-P3-6A-Playable-Slice.cmd` installs in install-only mode before the FAST gate and preview.

## NEXT WINDOWS ACTION

P3.6A runtime is **REAL PASS** on Windows Godot 4.7.2 and the GitHub actor-pack preview pipeline is green.

Latest CI visual cleanup:

- real female Stage A actors render in the live map;
- all live disciples now use `ModularDiscipleActor`;
- rigs without authored art use a neutral humanoid silhouette;
- legacy letter-circle actor placeholders are blocked by the P3.6A contract;
- always-on actor status text is hidden from the idle map;
- actor spacing is wider;
- building living cues are lifted above actor clusters.

Final product visual acceptance is still pending user judgment; do not self-declare PASS.

With the Windows machine open, use the canonical single sync entrypoint:

`Sync-Main.cmd Run-P3-6A-Playable-Slice.cmd`

Expected flow:

`safe fetch/pull -> restore tracked 42-PNG pack + canonical SHA -> P3.6A FAST -> auto-open live preview`.

No separate `Sync-P3-6A-*.cmd` should be created. No FULL rerun is needed unless a later change crosses a locked baseline.

## P3.4 — REAL PASS / LOCKED

`docs/P3_4_BUILDING_MANAGEMENT_SPEC.md` is now canonical for the next functional phase.

Locked direction:

- tap building -> fixed operation panel, map remains visible;
- Mine/Forge -> real group assignment + direct work commands;
- Cultivation -> real cultivate command;
- Residence -> real rest command + real lodging expansion;
- Medicine -> real stock/priority only, **no fake HEAL command**;
- Warehouse -> real grouped resources, no invented capacity;
- Gate -> real outside-disciple status + return-sect command;
- Main Hall -> real workforce/needs/equipment policies;
- Forge may expose real `EquipmentSystem.craft()`;
- no building level/queue/upgrade system invented in presentation.

P3.4 prerequisites are now green. Implement P3.4 incrementally: A read-only panel -> gate, then B people management -> gate, then C real building/system actions -> gate.

## P3.5 DESIGN LOCKED — IMPLEMENT AFTER P3.4 GREEN

`docs/P3_5_LIVING_SECT_CUES_SPEC.md` is canonical.

Locked behavior:

- max 3 visible cues;
- deterministic priority S0 Critical -> S1 Actionable -> S2 Operational -> S3 Info;
- disciple cues: Bị thương (<72% HP), Mệt (<42 stamina), Có thể đột phá, Nguy hiểm ngoài tông (personal retreat threshold or stamina <=22);
- building cues: Hết thuốc only when someone actually needs healing, Quá tải lodging, Mine/Forge Thiếu người, Forge Thiếu vật liệu, Gate danger aggregation;
- transient cues derive from real metric/state changes: work completion, breakthrough result, heal/return events;
- tap disciple cue -> P3.3 context;
- tap building cue -> P3.4 context;
- no random speech, fake emotions, fake production event, auto-fix action or hidden identity leak;
- presentation may keep unsaved transient snapshots/cooldowns only for dedupe/event animation.

Do not implement P3.5 before P3.4 is runtime-green because cues must route to working management actions.

## P3.6 GAMEPLAY LOOP DESIGN LOCKED

`docs/P3_6_SECT_MASTER_GAMEPLAY_LOOP_SPEC.md` is canonical for the management rhythm.

Core player-control ladder:

1. sect-wide policy — broad, infrequent;
2. long-term assignment/group/role — structural;
3. direct Sect Master order — short-lived exception;
4. survival emergency remains above direct command.

Canonical 5–10 minute rhythm:

`scan map/cues -> resolve only meaningful exceptions -> make 1–3 strategic decisions -> invest if useful -> watch real consequences -> let the sect continue autonomously`.

Acceptance principles:

- 0–3 meaningful problems in a normal session, not alert spam;
- no mandatory click-every-building/collect loop;
- routine actions ~1–3 taps;
- map remains the primary place to understand consequence;
- player can ignore deep profiles during routine management;
- game continues sensibly when player does nothing for a while;
- no fake work generated just to increase session length.

P3.6 is a product-loop contract, **not** a separate runtime system or PASS. After P3.4/P3.5 green, do a real gameplay-loop playtest against this spec before adding more mechanics.

## FUNCTIONALITY-FIRST PRIORITY — USER DECISION 2026-10-04

Map actors are small, so do not spend disproportionate time on face/hair micro-detail. Character Creator is now a supporting anti-clone system, not the main development blocker.

Current order:

1. P3.2 live modular actor `[8/8]`: **REAL PASS / LOCKED**;
2. run/fix `Verify-P3-3-Disciple-Flow.cmd`;
3. move to P3.4 building management/interactions using real simulation state;
4. then P3.5 living-sect status/action cues;
5. run P3.6 real 5–10 minute management-loop playtest;
6. later add a minimal set of face/hair/outfit/weapon/tints and six combos;
7. FULL female visual gate only after the visible functional slice is stable;
8. male rig remains later.

Do not return to broad cosmetic production before P3.3/P3.4 functional work unless the user explicitly changes priority.


## P3.7 LONG-TERM ECONOMY / HUNTING — NEW CANONICAL DIRECTION

Read first:
`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`

The user has now explicitly selected the long-term game direction:
- 1,000–3,000 disciples;
- roughly 70% hunting/outside / 30% rear-base;
- auto hunting by teams (standard 5), with solo traits allowed;
- defeat -> injury/recovery, not permanent death;
- natural hunting costs: time/stamina/medicine/durability;
- no full personal inventories at scale;
- hunting item/material rewards route directly into the main Sect Warehouse; personal Tu Vi/Contribution/mastery/Spirit-Stone share resolve immediately; team carried inventory is supplies-only;
- Spirit Stone/Contribution personal economy with policy-driven gear allocation;
- professions 1–1000+, +1% efficiency each level, increasing EXP curve, permanent levels, specialization milestones;
- workers still gain passive cultivation and use personal Spirit Stones for Secret Chambers/pills/gear/services;
- one universal material magnitude: Phẩm Lực;
- high realm may do low-value work, low realm profession masters may perform difficult work if facility/skill allows;
- buildings cap around Lv.100 per instance and scale by additional facilities;
- all Sect Treasures may stack/contribute.

Construction authority:
normal upgrade = Linh Mộc + Khoáng Liệu + Linh Thạch, with Phẩm Lực-based material fulfillment;
major milestones add one building-specific specialty component only.

Do not implement a hard material Lv.1–Lv.5 ladder and do not return to a simple mine->iron-only economy.

The building tree is already canonical and P3.7A1 backend implementation has started; use the latest P3.7A1 status below.


## P3.7 BUILDING TREE IS NOW CANONICAL

Read:
`docs/P3_7_BUILDING_TREE_SPEC.md`

Key rules:
- building instance cap Lv.100;
- scale by more instances/land/teams, not Lv.8000 buildings;
- routine upgrade = Linh Mộc + Khoáng Liệu + Linh Thạch;
- milestone = routine cost + one thematic specialty component;
- upgrade material totals are satisfied by eligible Phẩm Lực, with reserve/lock policy;
- resource/production facilities support soft processing penalties instead of hard realm locks;
- milestone mechanics are defined for the main building families;
- first implementation slice contains 13 core buildings, with Mật Thất immediately after personal economy.

Do not start presentation-first fake levels. Next authority work is the data model/contracts that make these levels, costs, capacities and production real.


## P3.7 LOADOUT / HUNTING PROGRESSION — CANONICAL

Read:
`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`

Important:
- future personal loadout expands without becoming a personal warehouse;
- AI equipment selection is default for scale;
- ownership distinguishes sect-loaned vs disciple-owned gear;
- personal gear requisition requires Contribution compensation;
- PvE is now intended as the fastest normal realm-growth path;
- hunting reward uses current-stage requirement + relative monster realm/grade/challenge, so future realms scale without a fixed XP table;
- target: appropriate hunting ~10–20× ordinary-work passive cultivation;
- keep P2.1/P2.3/P2.6 locked until explicit backward-compatible P3.7 migration.


## P3.7 RESOURCE / STORAGE / BASE GROWTH — CANONICAL

Read:
`docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md`

Important corrections:
- do not use warehouse capacity as a gameplay gate;
- do not average different material identities into one PL stack;
- keep distinct resource IDs with realm-grade labels and stable base Phẩm Lực;
- stacks can be extremely large;
- warehouse level governs automation/logistics rather than numeric capacity;
- higher progression introduces new resource types aligned with realm-grade bands;
- all disciples gain passive cultivation;
- integrate the existing six foundation fields rather than inventing a replacement stat block;
- home AI may self-invest Spirit Stones into Secret Chambers and pills.


## LATE CANONICAL CORRECTIONS — 2026-10-05

1. Hunting has no Loot Warehouse and no persistent reward Team Loot Bag.
   - Items/materials -> main Sect Warehouse immediately.
   - Tu Vi/Contribution/mastery/personal Spirit Stone share -> disciples immediately.
   - Team carried inventory is supplies-only.

2. Lifespan expiry does not erase a disciple.
   - transition to Ma/Hồn;
   - remains in roster;
   - Thọ Đan/valid longevity effect may revive;
   - only Trục xuất removes the disciple;
   - ghost-specific gameplay remains undefined until a dedicated spec exists.


## P3.7 TIME / SPEED / COOLDOWN — CANONICAL

Read:
`docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`

Key rules:
- attack speed != movement speed != work speed;
- Mine workers physically travel, mine a batch, haul/deposit through the Mine, then resources enter main Sect Warehouse;
- movement time counts against productive time;
- all building construction/upgrades take real time;
- no universal fake cooldown after upgrade;
- crafting/treatment/Secret Chamber/travel/repair use duration, not instant clicks;
- true cooldown remains for skills and real active powers.


## P3.7A1 + A2 BACKEND — GODOT 4.7.2 CI GREEN

Backend now has one shared building authority, proven by two different production lifecycles.

A1 Mine:
- BuildingState/BuildingSystem/P37Factory;
- Lv.1–100;
- real worker slots using mining_crew;
- timed upgrades;
- travel -> mine -> haul/deposit;
- Mining profession XP;
- Lv.10 Tầm Mạch Bàn;
- movement speed and Căn Cốt have real work-time consequences.

A2 Spirit Field:
- same BuildingSystem, no parallel framework;
- herbalism_crew;
- travel -> tend/plant;
- crop then grows independently in building-owned production_state;
- worker is free while crop grows;
- harvest-ready -> travel/harvest -> haul/deposit;
- Herbalism profession XP;
- Lv.10 Linh Tuyền Chi Tâm;
- competing workers are released cleanly when another worker completes the shared crop phase.

Important persistence fix:
- legacy six-foundation values are now serialized even when profile_seed is zero;
- this fixed the A2 deterministic save/load divergence.

Verification:
- A1 fast: PASS;
- A2 fast: PASS;
- full P0–P2.12 + A1 + A2 cumulative official Godot 4.7.2 CI: PASS.

Presentation remains unmigrated. Do NOT display fake P3.7 levels/progress from the old P3 map authority.

NEXT:
**P3.7B1 Resource Registry + canonical Sect Warehouse backend.**
Replace the temporary forge_materials bridge; do not create a second permanent warehouse/material authority.
