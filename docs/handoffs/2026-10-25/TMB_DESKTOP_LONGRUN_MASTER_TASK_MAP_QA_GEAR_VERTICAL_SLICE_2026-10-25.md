# TÔNG MÔN BÁ ĐẠO — CODEX WINDOWS / ENDGAME-FIRST (MASTER WORK V2)
25/10/2026 — NEW OWNER OVERRIDE. Replaces the earlier map-only/one-file scope. This is an actionable Codex assignment, NOT a claim of game completion.

**Goal:** an ACTUALLY PLAYABLE near/full ENDGAME Xianxia sect-management scene, with authentic Source A/Godot assets, meaningful large Sect + hunting maps, functional production, disciples and PvE; not just an empty beginner map or a docs-only prototype. Test early game only for short backwards-compatibility smoke. Long work session without micro-approvals, report honest blockers.

## 0. Read authoritative sources and protect tested gameplay

Repo: vuanhtuan161094-byte/TongMonBaDao. Engine official Godot 4.7.2, Windows desktop, Android landscape 1280x720, owner machine approximately 8 GB RAM.
- main @29b5fba448b0178cb520a4ada44b375b4b934e31 is **NOT** latest playable gameplay.
- PR31 @9eb4fd55733bb49bbb069240b8e332d37d22aced: last integrated CARE/D7/Combat V2+S1 main game baseline. Prior 28/28 focused and 56 S1 checks apply ONLY to prior tested SHA.
- PR32 @c6bde70f6e98f482c91cd6d2c386e58437877209: Option B functional hub, previous 29/29 focused at its SHA.
- PR33 @7a551ca4f8f9b15f3069652c5f557e0fbc29833e: Sect visual candidates and AStar/cache optimization, Godot NOT RUN on these edits.
- PR34 @dae86efd37a61e2e82c64ea00608fc062c4b423c: CARE forest presentation and a 20-camp DESIGN viewer, NOT 300 actual monsters.
- PR35 @f1d0cca3a9ef8c921ad07fafba536fcde4edf313: docs cleanup only, Draft; CODE-CLEAN and CODE-R0 are parallel finite-world migration explorations requiring review before applying anything to save.
- There were 145 GitHub branches and 31 open Draft PRs at audit. DO NOT traverse all of them, merge them wholesale, delete them, or base new gameplay on main. Refresh live heads, inspect relevant diffs.
- Read AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, previous work handoff TMB_WORK_MODE_MASTER_CHECKPOINT_MAP_PR33_PR34_2026-10-25.md, then this file. Interpret earlier one-file limits as obsolete for THIS approved domain.
- ONE integration worktree from current PR33; carefully apply PR34 NET files, not a merge of sibling ancestry. Proposed branch: integration/endgame-maps-assets-playable-20261025. Keep old PRs and user worktrees untouched. Up to TWO new Draft PRs total, no main merge.

## 1. OWNER AUTHORIZATION: FULL ACCESS TO E DRIVE FOR THIS GAME

You may locate, read, write, edit, refactor, move, convert, archive and build ALL GAME-RELATED files/folders on E:, including Tông Môn Bá Đạo repos/worktrees, Source A/JX approved archives, old Spine/PAK/SPR, Godot converted assets, manifests, tools, ZIPs, staging, builds, captures and test save files. Do not confine your changes to a small file allowlist. You may change map presentation, UI, art adapter, simulation/World PvE/Save/Forge code *when required for proper gameplay*, provided migrations, canonical invariant tests and rollback are included. Preserve locked Combat V2 math, Combat V3 S1 consumers, One Active Job, canonical Warehouse, Injury 0/1 with 120-tick recovery, settlement exactly once and legitimate economy sources unless the user separately changes those game rules.

Mandatory safety, NOT a scope restriction:
- First inspect GAME-related E paths, installed Godot executable, git status, free disk/memory, Windows permissions. Do not assume every file on E belongs to this game. Never touch unrelated files, Windows profile/Admin or non-game software.
- Inventory relevant folders and save sources to a path manifest with SHA256; identify source/master, generated, duplicated, active game build and owner changes.
- Before potentially destructive file operations: make verified backup/archive preserving raw unique Source A/JX, zip archives, original Godot worktree, user saves and tool sources; log old/new path and hashes. An identical redundant derived copy may be removed ONLY after source references + hashes + archived recovery are verified. Never delete sole source files, git clean -fdx user worktrees, force-push or mass-delete branches.
- One Godot instance or conversion worker at a time on the 8GB Windows PC. Small batches, monitor RAM/disk, stop+checkpoint if BSOD/memory risk. No Administrator/UAC elevation assumed.
- GitHub holds source/runtime code and reasonable tested derived assets only; no automatic upload of private huge raw archives. Do not invent external source paths. Keep Source A style and licensing/provenance evidence.

## 2. ASSETS ALREADY EXTRACTED — REUSE, VERIFY AND ACTUALLY INTEGRATE

Do NOT rerun extraction from scratch. Inspect game-related E folders and these exact known sources:
- sa-lib-01-sourcea-spine-library-20261021 @87d6b60123c85930e9eb571949f4aafbb8f8ac7d: Run-SourceA-Library.cmd, tools/sourcea-spine-library/sourcea_library.py, library.local.example.json, SpineToGodot472 patch, commands scan/status/inspect/resolve/verify/convert/resume/export-github. Previously 31 clips, 1016 frames, 28 WebP atlases and 10/10 rig pilot QA PASS on historical fingerprint — REVALIDATE CURRENT BYTES.
- PR28 WORKER_ASSET_CATALOG.json, WORKER_ASSET_DISCOVERY.csv, contact sheets for male/female/monster/Boss/rigs.
- PR31/32 have exactly 32 SHA-gated Source A PNGs (4 terrain, 6 roads, 19 vegetation/props, 3 buildings) including verified Main Hall 510052, Warehouse 510102, Forge 520081. Immutable original-byte SHA manifest.
- docs/P3_ASSET_REGISTRY.json, docs/P3_ASSET_BUILDINGS.md, docs/P3_SOURCE_RECOVERY_MANIFEST.md, docs/P3_ART_BIBLE.md and actual raw/derived files on E.
- PR33's 3 Mine/Forest/Field SVGs are *NEW UNAPPROVED visual candidates*, NOT recovered original Source A. Historical 8 approved building identities do not prove 8 raw masters are already available.

Catalog ALL actually accessible Godot-ready images, textures, Godot SpriteFrames .tres/.res, atlas, rig animation (idle/walk/attack/hit/die), building, environment, water, bridge, roads, UI/icons, skills/VFX, monsters, project packs. For each: original locator/type, SHA256, width/height/alpha/pivot, clips/facing/FPS, source/derived fingerprint, potential entity and exact approval/QA status. Deduplicate by HASH, do not reconvert matching QA_PASS, use small batches on 8GB PC.
Real integration is required: bind approved exported assets to live Sect-building instances, disciple walking/idle clips, actual monster/attack/hit effects and terrain layers in playable scenes; measure zoom/crop/occlusion/UI/picking. Never represent static idle as mining/cutting animation; never assume JX art automatically fits Source A chibi aesthetic. Missing source => ART_BLOCKED, not fake Source A. Commit usable derived assets with manifest; leave enormous raw archives outside repo.

## 3. MAP TÔNG MÔN: BEAUTIFUL, FULL WORLD, LEGAL MAX BUILDING COUNT

Read docs/map-d0-sect-main-redesign-20261025/docs/handoffs/2026-10-25/TMB_MAP_D0_SECT_MAIN_REDESIGN_REPORT_2026-10-25.md and docs/map-d2-visual-rebuild-broad-scope-20261025/docs/handoffs/2026-10-25/TMB_MAP_D2_BROAD_SCOPE_VISUAL_WORLD_UPGRADE_CODEX_PACKET_2026-10-25.md. Also building tree and land expansion design.
- Sect map target 192x192 chunk16x16, starter48x48; Option B entrance→courtyard→Main Hall, three functional districts; endgame must use the LARGER unlocked world rather than squeezing everything into starter.
- Current design scale: **30 Mine, 30 Spirit Forest, 40 Spirit Field**, total 100 producer buildings. Hall Lv100 planned; for each other facility discover legal supported max level/instance count from actual BuildingSystem, not invented. Represent all other implemented building families and their REAL state (Warehouse, Forge, residence, cultivation, clinic, alchemy, etc.) where available. If site only exists as an anchor and NOT a canonical BuildingState, report NOT_IMPLEMENTED, do not fake an active building.
- Source A hand-painted Chinese Xianxia map should be clearly better than PR32 blank green tiles: real ground, transitions, main entry and hall forecourt, living/training/production, paths, waterside/bridges and woods with art provenance, active people and work cues. Map uses actual room to expand, readable at 1280x720; free pan/zoom, touch targets, actor depth occlusion, per-building progress/ETA/output/worker from actual state, no overlaid giant labels.
- May refactor relevant renderer, scene, map layout, actor/terrain layers, camera, UI and chunk/LOD when necessary. Keep actual gameplay/selection/save transform coherent; no fake art scene replacing P3.2. Original Source A assets unchanged.

## 4. PRIMARY TEST: PLAY AT ENDGAME, NOT JUST TICK-0 GAME

Create a **deterministic endgame QA world builder and isolated savestate** with stable seed/version/SHA, separate from private owner saves and release distribution. Use actual canonical constructors/state/registries and legal building caps; test factory can seed QA end-state with explicit marker, but it must NOT pretend to prove natural player progression from Lv1 or create a separate fake economy engine. The scene being played must be REAL P3.2. After seeding, actual production, warehouse, camera, combat, inventory, save/reload and actor interaction must execute.

Test matrix:
- BEGINNER_COMPAT (quick smoke): starter recruit/Mine/backward Save. Do not spend most time here.
- MIDGAME: multiple function districts, mixed building levels, 10–30 disciples, real stock.
- **ENDGAME_FULL_SECT — MAIN ACCEPTANCE:** 30/30/40 producer building instances if legal in code, full meaningful opened districts on the 192x192 world, every currently implemented other building at legal highest levels, adequate real worker pool subject to One Active Job, numerous production timers. Actually open the game and pan ALL districts; select 3 producer types, reassign disciples, watch tick/ETA, collect warehouse settlement, show Hall/Lv100, shop/forge/clinic if available, and save/reload. No screenshot of unimplemented virtual buildings counting as pass.
- **ENDGAME_PVE — MAIN ACCEPTANCE:** same endgame save entering one Thanh Trúc Lâm hunting world, up to 30 deployable disciples, target 200–400 actual monsters across 20 camps if world authority implemented; fight/return, per-life loot receipt, camp assignment, camera+minimap, Boss/Elite, correct warehouse after reload. Until implemented, mark PVE_WORLD_PARTIAL, not 300 mobs working.
- SCALE: 30/100/300 actively relevant simulation entities or roster tiers; and 1000/3000 disciple headless scaling IF actually supported. Do not render all 3000 sprites and pretend game supports them. Record CPU/VRAM/RAM, draw calls, FPS p05/min, frame-time p95/p99, save size/load time on same hardware.
- LONG_SIM: endgame real tick/offline/save/restarts, exactly-once work/kill/XP/loot, nonnegative warehouse, stable worker active job, no duplicate receipts. Different test seed snapshots re-runnable.

For every scenario capture actual 1280x720 in-game screenshot/video with camera/save/seed/commit+asset hash, not art mockup. **Human usability** matters: road/collision, no buildings overlap, touch/camera/free pan, readable progress, reasonable loading, real continuous operation. If seeder must bypass progression to create stress state, explicitly separate synthetic-seeded validity from proof of attaining that state in normal gameplay.

## 5. PvE MAP TARGET: REAL 20 CAMPS, NOT ONLY A DESIGN VIEWER

Refer docs/ttl-20-camps-map-topology-five-difficulties-design-20261024, docs/huntworld-20-camps-200-400-mobs-rts-review-20261024 and B3HuntWorld/MapBattleV2/CARE code. PR34 has a 256x192 **design** preview with 20 nodes, 30 paths, 3 bridges, and mock 300 planned mobs, **not a real multi-camp simulation**.
Build progressively toward ONE actually connected world with 20 camps x 10–20 living mobs (200–400) and 30 dispatched disciples. Path/nav across bridge/water, camera RTS/mouse drag/touch/minimap, real farm areas and AI orders, attack ranges/cooldowns, real monster spawn/respawn, Elite/Boss events, loot on actual kill, canonical receipts, Sect Warehouse and save load once. Separate CPU simulation from visible sprite/render culling. Retain Combat V2 formulas, S1 effects and CARE/injury/reward authority. Any necessary change to simulation/world/Save is authorized as game-related CODE when test+migration+rollback justify it; do NOT balance/hardcode arbitrary new monster loot IDs. Stage PVE1 world/actors/nav → PVE2 teams/orders → PVE3 kill/loot/respawn → PVE4 scale. Report partial if not all deliverable; a static camp viewer is never the PASS criterion.

## 6. GEAR — AFTER MAP/ASSET ENDGAME GATES

Read full equipment design lineages by ref from earlier master history. Locked structure: 10 ordinary slots, 3 Phù+2 Pháp Bảo separate, 24 sets x 4 named pieces, equipment realm 1..30 (Nhân/Tiên/Thần), quality grade 1..12 separate, all unique items owned by ONE Sect Warehouse. Blueprint learned once, real recipe/facility/one-worker order, materials reserved, canonical time and receipt, frozen item RNG/ID, assign to one disciple, same-save equip/read-back without duplicating.
**Newest owner override:** BASIC R11 and R21 can be forged at actual Forge Lv30 with legal realm source + blueprint; Lv75 is advanced/set. HIẾM rates, enhancement +3, 80/55% chances, 70% inheritance cost recovery and sample budget curves remain research-only.
After endgame map and PvE core progress, deliver ONE R1 basic Forge→Warehouse→equip→Save genuine vertical slice with official test if source/facility permit. If not, exact GEAR_R1_BLOCKED reason and ready-to-run fixtures, no new fake recipes/materials. Do not multiply 96 items in runtime without transaction core.

## 7. ONE LONG CODEX EXECUTION, INTERNAL PHASES

G0: machine+source worktree inventory, fingerprint/backup, real Godot executable, no Administrator/no parallel processes.
G1: integrate PR33 and PR34 NET changes on fresh branch, focused existing 29/29 + 56 S1 (old results are NOT new PASS), fix true GDScript/GUI/Source A issues.
G2: scan converted art in E, reuse existing verified library rather than reconverting; high-value SOURCE A building/character/map/monster VFX integrations with QA.
G3: extend real Sect map+building presentation and endgame canonical test builder; play **ENDGAME_FULL_SECT** in GUI, capture screenshots, validate large 100-producer occupancy, actual worker/warehouse progress.
G4: implement the connected PvE 20-camp world incrementally and test **ENDGAME_PVE** actual farms/kills/loot/camera; mark incomplete features honestly if full world blocked.
G5: regress scoped tests and S0–SCALE–LONG_SIM endgame as above, FPS/RAM measurements and endgame 1280x720 gameplay capture with exact SHA.
G6: gear R1 Forge first vertical slice if source/governance ready; keep the R11/R21 BASIC Lv30 boundary and unapproved rates separate.
G7: dedup/cache/startup/perf optimization after measured hotspots. Delete/move game-only redundant artifacts **ONLY** after SHA/reference proof and backup.
G8: one Vietnamese master report; one/two Draft PRs maximum, screenshots/logs/video/asset catalogs/ENDGAME QA save+launcher/checksums/source refs, short PASS/FAIL/BLOCKED table, rollback procedure and owner review. No automatic merge, delete old branches, close old PRs or announce release.

**Verification:** Godot 4.7.2 official on final code SHA after last edit, baseline PR32 29 focused + S1 56 checks + added map/endgame/PvE/item tests and affected integration tests; exact command/stdout/exit/file hash and runtime screenshots. Desktop RAM8GB means one Godot process, small conversion batches. Failing load/CI logs 404 are not proof of gameplay fault. If Godot not actually available, keep coding/static work without claiming any runtime PASS.

## 8. COPY INTO LOCAL CODEX

TÔNG MÔN BÁ ĐẠO — OWNER CẤP QUYỀN MỘT CÔNG VIỆC DÀI ENDGAME-FIRST, THỰC THI TRÊN MÁY WINDOWS CÓ GODOT 4.7.2.

Đọc toàn bộ file GitHub tại branch docs/work-mode-handoff-map-qa-integration-20261025, path docs/handoffs/2026-10-25/TMB_DESKTOP_LONGRUN_MASTER_TASK_MAP_QA_GEAR_VERTICAL_SLICE_2026-10-25.md và checkpoint PR33/PR34 cùng nhánh. Theo dõi Issue #37. Đây là bản owner override của packet cũ.

Tôi cho Codex toàn quyền đọc/ghi/sửa/tạo/move/convert các dữ liệu game TÔNG MÔN BÁ ĐẠO trên ổ E, cả project/asset Godot đã bóc tách/source A/JX/công cụ chuyển đổi/ZIP và các hệ thống code liên quan. KHÔNG còn giới hạn một file. Inventory/backup/hash trước thao tác destructive; không đụng dữ liệu không thuộc game, không xóa master, không dùng Administrator, không merge main.

Đặt ENDGAME làm QA chính: không chỉ thử 3 nhà ở đầu game. Tạo save fixture QA cuối game từ canonical game; kiểm thử map tông môn 192x192 với 30 Mỏ+30 Linh Lâm+40 Linh Điền và mọi công trình thực tế có thể xây/cấp cao nhất; nhiều đệ tử làm việc, sản lượng/ETA/Kho/save/offline chạy thật. Chạy GUI 1280x720, pan/zoom mọi khu, bấm công trình, sản xuất và return. Nếu hệ thống thiếu cap/nhà/source thì CODE hợp lệ + ghi blocker, không dùng marker giả.

Tích hợp asset Godot đã chuyển trên ổ E: tận dụng thư viện sa-lib Source A và manifest có sẵn, kiểm SHA, không convert trùng; đưa real building/terrain/worker animations/monster/vfx vào game theo style Source A. Bảo vệ 32 PNG verified.

Map PvE phải tiến dần từ PR34 design-only viewer sang ONE real Thanh Trúc Lâm 20 bãi, 200–400 quái/30 disciple, RTS camera/nav/farm/kill-loot/save, Combat V2 authority không đổi. Rèn trang bị R1 Forge→Kho→equip→save nếu map/endgame/source đủ gate; R11/R21 basic Lv30, Lv75 advanced/set; không tự áp tỷ lệ chưa khóa.

Được code đa module, kể cả world/simulation/save khi phải có migration/regression, nhưng không phá nền Canonical và save người chơi. Chạy một Godot process/lượt vì RAM8GB. Làm G0–G8 liên tục, tự sửa lỗi, chỉ cần owner review cuối. Xuất GitHub Draft PR (tối đa 2), báo cáo exact SHA, asset catalog, endgame QA save chạy được, ảnh/video runtime thật, số liệu FPS/RAM, logs và BLOCKED chính xác. KHÔNG tự merge hay xóa nhánh.

DONE phải là game endgame có thể CHƠI THẬT và đo được, không phải chỉ docs, 3 marker giả hay test PASS của SHA cũ.
