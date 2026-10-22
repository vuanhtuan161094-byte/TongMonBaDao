# TÔNG MÔN BÁ ĐẠO — B3 FAST-TRACK: ONE CODE JOB, ONE PLAYABLE HUNT SLICE

**Date:** 2026-10-22. **Status:** broader, unified CODE packet *proposed for owner approval*; do not start until explicit owner authorization. Replaces PH1A→PH1B→PH2→PH3 as **separate owner-gated jobs**. Codex may internally stage/test/commit in a single isolated branch without repeatedly requesting authorization. Do NOT change Source A, Character Studio, Combat V5, Map/G1 or main. Do not push/merge. This file is the ONE new implementation brief.

## 1. Proven base and exact outcome

- Repo: `vuanhtuan161094-byte/TongMonBaDao`; Github main observed `461caca1171462e0da092f21108c5c1733157ad9`. **Use locally accepted PH0 full-repository commit** `97a3d98094451e85e8d5f26e8986a60968512ee5` as direct ancestor; never start from GitHub main absent PH0, and never import earlier reconstructed `09e97d2`. Owner-reported PH0 official Godot 4.7.2 **5/5 focused regressions PASS**, worktree clean, 3 files, not pushed.
- PH0 accepted local worktree: `E:\codex\2026-10-22\t-ng-m-n-b-o\work\TongMonBaDao_B3_PH0_acceptance`. Use new isolated branch/worktree to avoid mutating it. Codex must read its own actual PH0 QA report and `PH1_CODE_AUTHORIZATION_DRAFT_vi.md`.
- **Single owner-facing result:** runnable standalone B3 **backend-first playable demo** on Godot 4.7.2: real canonical V2 disciple, one authored normal monster, world alive >90s, death→separate respawn, real per-kill registered stackable material added to SAME Sect Warehouse, saved/reloaded with world+receipt/kill generation and exactly-once semantics, return-to-Sect on defeat with original Injury0/1/120 without extra lifespan penalty. A simple temporary debug scene/launcher is allowed under dedicated B3 names if necessary to play/demo. No Source A sprites/production map/V5 visual parity implied.
- Test with at least 3 consecutive kills and a reload mid-world; wait >90s simulation and demonstrate same world rather than resetting finite encounter. Verify no extra payout after re-open/retry or UI event buffer compaction.
- On 8GB RAM machine, **do not interfere with ongoing Source A worker**: bounded Godot focused tests, isolated `user://`; avoid FULL/CI/corpus/bulk imports.

## 2. One explicitly limited PILOT content choice, not canonical rebalancing

To make the first actual per-kill reward observable, propose **B3-VS1-only opt-in** content: normal species `thanh_lang` in authored region `bach_thach_khe` → `1 tinh_lang_bi` for one genuinely committed HP0 kill, 100% chance. Both species/zone and registered material exist in `MonsterCatalogueV2`, `HuntingMapV2.REGION_CONTENT`, `ResourceRegistry` respectively. **This is a NEW intentionally approved first-playable PILOT proposal**, not an existing locked monster drop table, not a global change to `HuntingMapV2.claim_reward`, no equipment, no rare/Boss items, no direct Tu Vi or XP from kill. Must be versioned in a small opt-in B3 content table so next balance pass can replace it cleanly. Passive Tu Vi continues once per canonical scheduler minute; do not double reward per kill.

If this pilot cannot be safely implemented for canonical state without changing approved rules, report **CONTENT BLOCKED**, provide a test-only proof and request owner decision; do not quietly invent production values or turn synthetic B2 loot tables into global content.

## 3. One implementation scope, internal milestones permitted, no repeated authorization

Single-writer `feature/b3-fasttrack-first-hunt-20261022`, parent accepted local PH0 `97a3d980...`. Owner approves the whole **bounded allowlist and outcome**; Codex autonomously implements, tests, fixes, commits inside worktree until acceptance or a genuine blocker.

**May ADD** only B3-prefixed files in:
- `godot/src/simulation/combat/b3_*.gd`: isolated SpawnDirector, world orchestrator, kill-domain→receipt ledger, B3 pilot loot content, actor admission/return logic.
- `godot/tests/simulation/b3_*.gd`: focused tests; preferably one true vertical-slice integration test and a few small subordinate tests.
- `godot/src/presentation/b3_*.gd` and `godot/scenes/b3_*.tscn`: optional **isolated** debug-play scene/launcher, not current map or HUD.
- `godot/tools/b3_*` if an isolated deterministic runner/launcher is needed; avoid scripts touching users' existing saves.

**May MODIFY only these pre-existing canonical owner files if needed to integrate without duplicate authority:**
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/state/simulation_state.gd`
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/save/save_service.gd`
- `godot/src/simulation/core/simulation_runtime_owner_v2.gd`
- `godot/src/simulation/core/simulation_runtime_clock_v2.gd`
- `godot/src/simulation/core/simulation_scheduler.gd`
- `godot/src/simulation/core/live_game_runtime_v2.gd`

**READ / reuse only, don't edit by default:** PH0 `map_battle_v2.gd` and `map_battle_snapshot_v2.gd`; `hunting_pve_run_v2.gd`, `hunting_map_v2.gd`, `disciple_combat_loadout_v2.gd`, `monster_catalogue_v2.gd`, `resource_registry.gd`, `warehouse_system.gd`, `building_system.gd`, `alchemy_recipe_registry.gd`, all existing tests. PH0 API is a contract; if its actual post-PASS code is incompatible, STOP and explain minimal additional owner decision—do not silently edit PH0 or damage legacy.

**Never edit:** `godot/project.godot`, Source A converter/catalog/worktrees, Character Studio, V5/V4, G1/MAP25, other presentation, legacy Combat formulas/skill content, existing map/world assets, unrelated balance. No broad refactor, no new global dependency or second inventory/time/currency owner. Keep original 3-file PH0 commit unchanged.

**Use transaction/save authority correctly:** B3 opt-in world field in canonical `SectState/SimulationState` persisted in same `SaveService` payload, optionally add strict versioned migration if needed. Old saves/modes preserved; invalid B3 data fail closed rather than wipe saves. One Active Job: a disciple in active B3 session cannot work/train/legacy PvE concurrently; no hijack of existing `active_pve_encounter_id` without compatible owner/mode and invariant proof. Injured/active-job disciples rejected for deployment. HP0 ordinary defeat triggers unchanged settled HP1+Injury1+120 sim minute recovery, auto return, no ghost/lifespan reduction.
- World alive when all disciples HP0 or no monster; no fake revive.
- Each monster slot's generation increments; stable `world/zone/slot/generation` kill ID; a **domain** HP0 event, never VFX `events`, is the only source for reward. Frozen per-kill result, immutable receipt state PENDING/COMMITTED; preflight actual `WarehouseSystem.add`/registered material and overflow. Snapshot/receipt/resource must be committed together with the canonical save barrier; retry replays the same result without minting twice. PH0 domain-event ACK **after** durable receipt commit, never before.
- One time owner: current `SimulationRuntimeClockV2` maps 60 real seconds to one simulation minute. Battle uses 0.25s substeps; implement one explicit persisted owner accumulation and bounded backlog, no second standalone time authority. Beware 240 battle frames/minute at scale: no unbounded history or expensive offline render. Online/offline same event order, no guessed rewards-per-hour.
- Existing finite `HuntingPveRunV2` and `HuntingMapV2.claim_reward` must be unchanged and regress. No automatic rare/Boss loot, new multi-team mechanics, age/medicine extension or new skill behavior in this slice.

## 4. Internal stages (Codex executes without asking permission between them)

A. PH0 base and last actual QA / B2.4 source reading, identify exact accepted APIs and state integration points.
B. Real disciple admission + one world/normal monster + independent respawn.
C. Domain death receipt → same canonical registered warehouse through B3 pilot opt-in content.
D. Integrated save/load + migration/rollback/retry semantics, one clock/offline backlog.
E. One runnable simple demo + tests, fix and retest. Each milestone may have a commit for rollback, not a new owner gate.

**Acceptance (official Godot 4.7.2, ONE end-to-end QA sweep):**
1. One real `DiscipleState` from `LiveGameRuntimeV2`/actual recruitment with learned gear/skilled loadout; legitimate busy/injured/old-PvE actor rejected.
2. 3 actual kills of `thanh_lang` in the one B3 pilot map, respawn each generation, stays alive >90s, downed-team idle world remains.
3. ONE EXACT `tinh_lang_bi` added to canonical sect warehouse per true pilot kill; no payout on UI preview, timeout, duplicate kill or replay. No per-kill direct Tu Vi beyond passive minute.
4. Save and reopen midway; world HP/slot/deadline/respawn generation, clock, pending kill receipts, inventory and Injury coherent.
5. Crash/retry simulation at BEFORE/AFTER domain HP0, before warehouse, after warehouse but before save, after save; no duplicate or lost committed rewards, no duplicate Injury.
6. Old finite PvE WIN/DEFEAT/90s, V2 snapshot, GP02C1 Injury, P3.7 Warehouse, Economy-A, live runtime clock/save focused unchanged.
7. Viewed/unviewed deterministic same order and rewards; no use of truncated UI events; bounded memory and event queue.
8. Deliver real run marker, logs/SHA/commit list, modified file allowlist, one screenshot of standalone debug scene **if built**, and precise state PASS/PENDING. No automated claims on Android visual QA or Source A.

If full acceptance is blocked for a hard reason, return completed milestone files/logs and a single clearly named blocker; do not replace the result with a document-only research sprint.

## 5. Future extensions deferred, not extra gates in this sprint

Y Quán/treatment choices, Đan Bão Hòa/tuvi pills, Tinh Nguyên absorption, equipment V2 forge, boss shared HP/co-op, AI aggro/leash, town supply automation, full 192×192 world/Source A art are subsequent playable expansions. Preserve today's approved Injury 120 tick and V2 no-direct-kill-TuVi canon.

## 6. One user-sendable CODE authorization prompt

**TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP CODE B3 FAST-TRACK VERTICAL SLICE.** Đọc `AGENTS.md` và `docs/handoffs/2026-10-22/B3_FAST_TRACK_ONE_SHOT_PLAYABLE_HUNT_2026-10-22.md` trên nhánh `docs/b3-v2-architecture-redesign-20261022`. Lấy commit PH0 Godot PASS **`97a3d98094451e85e8d5f26e8986a60968512ee5`** trong full local worktree làm parent, không lấy remote main hoặc bản PH0 dựng lại; đọc `B3_PH0_ACCEPTANCE_RESULTS.md` và `PH1_CODE_AUTHORIZATION_DRAFT_vi.md`. Lập một worktree/nhánh code cách ly, một writer, có quyền thực hiện tất cả giai đoạn A–E và thay đổi CHỈ trong allowlist của packet này, không phải xin phép từng PH1A/B/PH2/PH3. Mục tiêu: **một đệ tử V2 thật săn Thanh Lang tại Bạch Thạch Khê >90s, quái hồi sinh độc lập, pilot opt-in một Tinh Lang Bì/kill vào Kho thật, save/load replay exactly-once, Injury120 tick, offline chung clock, demo Godot có thể chạy.** Pilot loot được hiểu là cân bằng thử nghiệm mới cho vertical slice, không phải bảng loot khóa toàn game. Giữ nguyên CombatV2/finite PvE và main, không chạm Source A/V5/Character Studio/Map/project.godot, không FULL/CI/push/merge. Tự chạy focused tests official Godot4.7.2 và sửa đến khi PASS trong allowlist; cuối cùng chỉ giao code/commit, số test PASS, bằng chứng chơi thật, số quái/loot và lỗi còn lại. Gặp đòi hỏi sửa ngoài allowlist hoặc rủi ro phá save cũ thì dừng tại blocker và báo, không tự vượt phạm vi.
