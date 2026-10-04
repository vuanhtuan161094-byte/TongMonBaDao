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

## Current active task — P3.6 real gameplay-loop playtest

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

## Binary transport issue — resolved design, Windows run pending

The previous four tracked `female_normal_v1_stageA_v2q_*.b64` files were proven incomplete after Windows failed with:

```text
Invalid length for a Base-64 char array or string.
```

Canonical source comparison showed the tracked text was missing 1,793 Base64 chars in total. This is a connector/binary-transport tooling defect, not a Godot/art/rig defect.

The malformed v2 chunks plus experimental replacement chunks were removed from live `main`.

Current authoritative diagnostic pack is an external one-time ZIP:

`female_normal_v1_stageA_runtime_pack_v2_quant.zip`

- size: 44,838 bytes;
- exactly 42 Stage A PNGs;
- SHA-256: `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`.

`Install-P3-2-Female-StageA.cmd` now auto-discovers the ZIP in `Downloads`, `Desktop`, repo root, or `STAGE_A_PACK`, including browser duplicate names. It verifies SHA-256 before extraction; wrong/corrupt packs are rejected.

`.gitignore` covers only exact generated Stage A PNGs, `.png.import` sidecars, and an optional repo-root copy of the diagnostic ZIP.


P3.4C first real Windows attempt reached the cumulative P3.4B regression and failed because the old Medicine Hall test incorrectly required zero controls. P3.4C legitimately adds real NeedsSystem priority controls. The regression was corrected in commit `7c4ce83c13d8e6e7ce7e2cef6e53e3472f0375b6` to forbid only fabricated HEAL/direct-treatment actions. P3.4C itself remains runtime pending until rerun.

P3.5 first real Windows attempt failed during GDScript parse because `LivingCueTracker.seed(state)` collided with Godot's built-in `seed(int)`. The tracker method and all callers were renamed to `seed_from_state(state)`; P3.5 remains runtime pending until rerun.

## NEXT WINDOWS ACTION

P3.5 is **REAL PASS** on Windows Godot 4.7.2.

User supplied:

- `P3.5 LIVING CUE CORE TEST PASS`;
- `P3.5 LIVING CUE MAP INTEGRATION TEST PASS`;
- `P3.5 LIVING SECT CUES GATE: PASS`;
- `P3.5 LIVING SECT CUES: PASS`.

Next run:

`Sync-Main.cmd Preview-P3-6-Sect-Master-Loop.cmd`

This opens the real main scene for a 5–10 minute P3.6 product-loop playtest. Do not claim P3.6 accepted until user reports the live interaction result.

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
