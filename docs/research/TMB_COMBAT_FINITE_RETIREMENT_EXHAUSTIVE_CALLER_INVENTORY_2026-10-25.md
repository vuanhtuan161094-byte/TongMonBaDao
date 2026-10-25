# TÔNG MÔN BÁ ĐẠO — KIỂM TOÁN TOÀN BỘ CALLER COMBAT FINITE / 45s / 90s

**Ngày:** 2026-10-25. **Mức:** RESEARCH + static source audit; không sửa code, không merge, không chạy Godot. **Baseline cố định:** `5fbdbc6309c3f1386f0d8b619831e007c5a52824` trên `code/code-clean-finite-reward-20261025`, kế thừa PR #31 tại `9eb4fd55733bb49bbb069240b8e332d37d22aced`. **Branch docs mới**: `docs/combat-finite-retirement-full-caller-save-migration-20261025`, fork trực tiếp tại SHA trên. Căn cứ `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/handoffs/TMB_COMBAT_CODE_CLEAN_FINITE_WORLD_BOUNDARY_2026-10-25.md`.

## 1. Phạm vi và độ tin cậy của "exhaustive"
- GitHub `GET /git/trees/5fbdbc6309c3f1386f0d8b619831e007c5a52824?recursive=1` trả **999 entries**, `truncated=false`. Tính theo đường dẫn đuôi: **273 tệp .gd** (143 `godot/src`, 123 `godot/tests`, 7 vị trí khác), **43 scene/resource (.tscn/.tres)**, **129 tệp .md** trong toàn repo.
- Đã fetch/inspect nội dung **từng tệp của 273/273 `.gd`** theo thứ tự path sort và **43/43 `.tscn/.tres`**. Lượt GDScript ban đầu dùng regex word boundary cho `MAX_SECONDS|LEGACY_FINITE_MAX_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|v2_pve_active_runs|v2_pve_reward_claims|v2_pve_settlement_receipts|active_pve_encounter_id|MapBattleSnapshotV2|MapBattleV2`; các lượt sau bổ sung `MAX_REALTIME_SECONDS|CombatSystem|resolve_encounter`. `CombatSystem` và `SimulationScheduler` được đọc thủ công bổ sung. Kết quả phản ánh **literal source occurrences**, không tính dynamic dispatch/reflection bên thứ ba.
- Trong 43 scene/resource không có literal nào khớp với `MAX_SECONDS|MAX_REALTIME_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|B3HuntWorld|CombatSystem|MapBattleV2`. **Đây là bằng chứng quét các loại tệp này**, không xác nhận mọi assets/binary, 129 MD lịch sử, CI logs hoặc nhánh ngoài PR31 đều không có ký tự đó.
- **Chưa quét từng nội dung** tất cả `.md/.ps1/.cmd/.py/.yml/.json`, vì vậy đừng gọi đây là exhaustive all-extension grep. Về runtime caller bằng `.gd`, đã quét toàn bộ tại SHA cố định. Nên chạy lệnh rg toàn repo trên Windows/Codex như phần 8 để bổ sung evidence cho non-GDScript mà không giả kết quả.
- **Không chạy engine 4.7.2**, không có trace player runtime thật, không có Android/human QA. File này là STATIC CODE AUDIT, không phải official PASS.

## 2. THỰC CHẤT CÓ BA ĐƯỜNG COMBAT — KHÔNG CHỈ 90s
| ID | Entry / authority / key lines | Time/termination | Payout | Điều kiện xóa |
|---|---|---|---|---|
| L0 — Scheduler P0/P2 | `godot/src/simulation/core/simulation_scheduler.gd:20,160–210` gọi `CombatSystem.resolve_encounter`. `godot/src/simulation/combat/combat_system.gd:19–78,79–185`. | **20 vòng** ở legacy resolver; nếu `combat_skills_enabled`, **MAX_REALTIME_SECONDS=45.0** và trace `timeout_retreat`. Tài nguyên/HP thay đổi theo branch này; thuật toán dùng legacy combat_power (không tự biến thành CombatStatsV2). | Thắng -> `pending_loot` của Disciple, qua action `LOOT` rồi `disciple.add_item`; thêm `technique_system.roll_farm_loot`, `equipment_system.forge_loot_for_victory`. Không phải B3 Warehouse per-life transaction. | **PHẢI** thay dispatcher scheduler/combat action, nghề, NPC AI, saved `LOOT/pending_loot` và các sink/progression trước khi retire |
| L1 — Finite group MapBattle V2 | `godot/src/simulation/combat/map_battle_v2.gd:11,13,217–218,226`. `HuntingPveRunV2.begin` dùng `setup(...,false)`. | **LEGACY_FINITE_MAX_SECONDS=90.0**, alias `MAX_SECONDS`; `win/defeat/timeout_retreat`. | `HuntingPveRunV2.claim` -> `HuntingMapV2.claim_reward` (whole encounter) và `v2_pve_reward_claims`. | Chỉ có thể xóa với migration save in-flight, terminal unclaimed và GP-02C1 tests |
| W — B3 World continuous | `godot/src/simulation/combat/b3_hunt_world.gd:10–27,102–157,160–183`, `map_battle_v2.gd` với `keep_encounter_open=true`; `simulation_runtime_clock_v2.gd:116–147`. | **Không tự timeout 45/90 giây**, persist world/slot generation; bounded frame budget không phải game-over. | HP0 genuine death -> `pending_kill_events` -> one receipt `PENDING/COMMITTED`, paid_generation, Warehouse, save barrier, ACK. | **GIỮ**; tiếp tục phát triển vùng R11, nhiều đội; hiện chỉ là 1 hunter/1 wolf slot trong B3 prototype |

**Chốt:** tên lớp `CombatSystem` không đồng nghĩa với `CombatStatsV2`! Retire legacy encounter/45s nhưng giữ nguyên `CombatSystem.commit_v2_direct_hit` và công thức `CombatStatsV2.resolve_direct_hit`; không xóa class tràn lan nếu caller V2 direct hit vẫn đang dùng.

## 3. GDSCRIPT PRODUCTION CALLER/DEPENDENCY MATRIX — ĐÃ ĐỌC SOURCE
| File : line (tại SHA baseline) | Điều đang phụ thuộc | Action phân loại |
|---|---|---|
| `combat/map_battle_v2.gd:11,13,217–218,226` | 90s legacy timeout, alias, finite run | **DEPRECATE FINITE ONLY**; continuous no time cap; giữ Step, RNG, V3 S1 |
| `combat/combat_system.gd:5,19–79,123,184,393+` | 45s action resolver và V2 direct-hit utility chung class | **SPLIT OWNERS FIRST**; không xóa direct-hit |
| `core/simulation_scheduler.gd:20,81,164–212` | real player scheduler vẫn dispatch legacy COMBAT, pending loot, progress, retreat | **BLOCKER P0**; cần ngắt live dispatch trước khi xóa CombatSystem legacy |
| `combat/hunting_pve_run_v2.gd:1,16–110,112–199,201–380,382–462` | finite begin, step, finish, claim, terminal HP/Injury, reservation reconstruction, legacy save v1 | **MIGRATION ADAPTER REQUIRED** |
| `combat/hunting_map_v2.gd:1,42–145,146–176,179–225` | 5 level spawn, preview, early body sources, 4-win Linh Tủy guarantee, whole-win payout | **SPLIT CONTENT/SINK FROM FINITE REWARD** |
| `combat/map_battle_snapshot_v2.gd:12–15,41–100,107,203–316` | binary Version1 finite; Version2 historical; PH0 Version3 continuous; finite time bound; schema guards | **KEEP OLD READERS UNTIL MIGRATION GATE** |
| `combat/b3_hunt_world.gd:25,62,93,100–164,174–183,225–309` | true continuous world + legacy active run collision check + durable receipt | **KEEP; don't delete legacy collision guard prematurely** |
| `combat/b3_pilot_content.gd:4,14` | references finite `HuntingMapV2.REGION_CONTENT` ONLY for regional scale | **EXTRACT DATA DEPENDENCY before deleting HuntingMapV2** |
| `core/simulation_runtime_clock_v2.gd:116–147` | B3 world frames + scheduler minutes; bounded backlog | **KEEP, single clock** |
| `core/simulation_runtime_owner_v2.gd:79–83` | checkpoint/commit B3 before save barrier | KEEP |
| `state/simulation_state.gd:84,221,335,417–426` | reservation invariant; B3 validation; `HuntingPveRunV2.reconcile_loaded_v2_pve` **during from_dict** | **HIGH-RISK MIGRATION OWNER** |
| `state/sect_state.gd:107–116,218–229,321–346` | persisted b3_hunt, v2_pve_selected_levels, claims, active_runs, terminal receipts, F3 counter | **SAVE FORMAT OWNER** |
| `state/disciple_state.gd:11,307–308,376` | active_pve_encounter_id persisted | **KEEP/OCCUPATION AUTHORITY** |
| `save/save_service.gd:4–5,8–71,96–129,161–223` | Save V3 / CARE V4, stage/backup and float64 tag, typed recovery | **VERSION + ROLLBACK OWNER** |
| `cultivation/disciple_body_gate_transaction_v2.gd:17` | checks `HuntingMapV2.early_body_sources_ready` | **BLOCKER R1–6 BODY**, must preserve earned material path |
| `building/building_system.gd:360,954,1016` | no competing jobs during PvE | KEEP |
| `workforce/workforce_system.gd:111,151,239,305,415` | One Active Job PvE guard | KEEP |
| `cultivation/disciple_body_training_facility_v2.gd:19,173`; `disciple_training_action_v2.gd:21,77,111` | cannot train during PvE | KEEP |
| `economy/economy_system.gd:270` | reserved PvE characters excluded from commerce | KEEP |
| `combat/b3_medical_autoplay_v1.gd:8,44,57,65,145` | live care/recovery and PvE exclusion | KEEP |

## 4. PRESENTATION CALLERS — ĐỪNG NHẦM UI VỚI REWARD OWNER
- `godot/src/presentation/b3_playable_hunt.gd:182–186,230,289`: `B3HuntWorld.begin/return/restore`; UI không thanh toán encounter finite.
- `godot/src/presentation/p3_2_landscape_sect.gd:3317,3461,3495,3506,3539–3607`: B3 world admission, world presenter and controls; view-only. Lines 587,609,616 bảo vệ nhân vật đã PvE.
- `godot/src/presentation/p3/hunting_level_selector_v2.gd:27,29,35,70,87`: vẫn chọn five-level `HuntingMapV2`, **legacy UI** cần re-route hoặc archive trước khi bỏ map level API.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd:18,22`, `p3/b3_care_combat_v5_presenter.gd:30,521` và `p3/jxqy2_source_slice_v1.gd:247,269` nhận/read MapBattle snapshot, **không dùng để create reward**. Không xóa render vì bỏ timeout.
- `godot/src/presentation/disciple_presentation_snapshot_v2.gd:161`: `in_v2_pve` xét `active_pve_encounter_id`; giữ tương thích.

## 5. TEST CALLERS — KHÔNG ĐƯỢC XÓA ĐỂ LÀM QA XANH
| Test/source | Bằng chứng phụ thuộc | Khi retire phải thay thế bằng |
|---|---|---|
| `b3_ph0_continuous_kernel_test.gd:73–86,92–115,188–229` | finite 90 timeout + continuous >3600s + snapshots v1/v2/v3 | old-save compatibility loader tests + continuous stress |
| `b3_fasttrack_hunt_test.gd:108–132,170–229` | World >120s, 3+ kills, receipt, reload and save retry | keep, expand; already World |
| `b3_care_pills_autohunt_test.gd:100,129–160` | injury1 auto-return and 120tick care | KEEP |
| `combat_finite_world_reward_isolation_test.gd:28–105` | cross-mode/no-double-credit negative fixtures (added in CODE-CLEAN) | KEEP until legacy fully drained |
| `dv2_02_five_level_pve_test.gd:18–128,252–405` | 5-grade difficulty, genuine finite combat/win, claim exactly-once, save resume | split source/catalog tests + frozen fixture legacy migration |
| `dv2_02_group_map_battle_test.gd:49–53,92–110` | finite win/defeat/timeout outputs | keep engine math/behavior regression until adapter removed |
| `dv2_02_battle_snapshot_test.gd:50–146` | finite v1 snapshot and exact RNG/HP/casts | permanent migration-fixture test |
| `gp_02c1_injury_settlement_test.gd:54–223,256–278` | finite HP/Injury, timeout retreat, old active/terminal/unclaimed win save, receipt proof | **REQUIRED permanent old-save fixture set** |
| `dv2_03_f0_source_baseline_test.gd:97–173`; `dv2_03_f3_body_material_earned_claim_test.gd:33–119`; `dv2_03_f6_real_earned_body_gate_integration_test.gd:32–160` | material gate and Linh Tủy win cycle via `HuntingMapV2.claim_reward` | genuine World sourcing and unchanged legal body material consumption |
| `dv2_03_f1_body_gate_manifest_test.gd:192–212`; `dv2_03_f5_low_tier_economy_audit_test.gd:25–28` | map source catalog/claimed progress | new non-finite content source registry |
| `dv2_03_realm_body_progress_test.gd:280–303`, `dv2_02_five_level_balance_test.gd:19–45` | setup/admission of `HuntingPveRunV2` | World admission/recovery tests, historical loader fixture retained |
| `p2_1_cultivation_test.gd:237–238`, `p2_5_combat_skill_test.gd:9,90,199`, `p2_6_equipment_combat_effects_test.gd:39–97` | real direct `CombatSystem.resolve_encounter` compatibility | isolate P2 legacy test contract / owner-approved migration |
| `dv2_02_combat_stats_test.gd:260–282` | `CombatSystem.commit_v2_direct_hit` | **KEEP V2 direct-hit** unaffected |
| `combat_v3_s1_effects_test.gd`, `combat_v3_s1_edge_contract_test.gd` | finite+continuous statuses/snapshots, S1 actions | retain V3 S1 behavior + continuous long life |
| `b3_main_hunt_integration_test.gd`, `pr28_s1_combat_status_presenter_test.gd` | presenter sees real continuous owner, does not advance battle | keep |
| `tmb_master_v3_combat_trace_fixture.gd:102` | MapBattle staged fixture | keep math/trace utility |
| `p3_o6_m1_release_rehearsal_test.gd:480` | reserved actor flag | keep One Active Job invariant |

## 6. RETIREMENT DECISION RULES
1. **Retire gameplay entry, not history.** Stop creating legacy encounters from scheduler and five-level UI; keep validated old saves and immutable receipts until migrated.
2. **Do not swap stat engine while retiring flow.** V2 stats/Combat V3 S1 authority persists; legacy P2 tests require compatibility/isolation.
3. **Preserve R1–R6 body gate sources** including `linh_tuy`, `thanh_linh_thao`, `tu_van_thao`, `tinh_lang_bi`; source must become genuine World death/production/earned receipt. Existing four-win guarantee cannot be silently removed without an approved equivalent using per-life receipt or new fully calibrated earning path.
4. **Legacy `LOOT` state is a separate migration debt** from finite V2 encounter claims. Different owner, different receipt representation; don't duplicate cross-layer credits.
5. **Exactly-once is a persisted ledger property**: neither an old claim ID nor World actor life can be redeemed twice. UI/presentation effects never create resources.
6. Save parser must reject malformed or contested state; no auto-win, auto-free-loot, auto-breakthrough, RNG reroll or HP refill.

## 7. ALREADY ISOLATED BY CODE-CLEAN (NOT A DELETE)
- `HuntingMapV2.claim_reward` rejects `continuous_mode` and B3 namespace before any Warehouse credit.
- `HuntingPveRunV2` explicitly uses finite mode and rejects World snapshot begin/restore/settle/claim.
- `LEGACY_FINITE_MAX_SECONDS` labels 90s legacy with an alias for test compatibility; World mode bypasses it.
- These are CODE changes on **parent** CODE-CLEAN; this docs branch does not change a single runtime byte.
- Godot focused tests for CODE-CLEAN are **NOT VERIFIED** at 5fbdbc; prior PR31 28/28 is not acceptance of new branch; CI failures had unavailable step logs.

## 8. REPRODUCIBILITY / SECOND CHANNEL REGEX CHECK (RUN IN AUTHORIZED CHECKOUT)
PowerShell/Codex read-only search at exact SHA:
```powershell
git rev-parse HEAD
git ls-files | Measure-Object
git ls-files '*.gd' | Measure-Object
git grep -n -E 'MAX_SECONDS|LEGACY_FINITE_MAX_SECONDS|MAX_REALTIME_SECONDS|timeout_retreat|HuntingPveRunV2|HuntingMapV2|claim_reward|v2_pve_active_runs|v2_pve_reward_claims|v2_pve_settlement_receipts|active_pve_encounter_id|MapBattleSnapshotV2|MapBattleV2|CombatSystem|resolve_encounter' -- '*.gd' '*.tscn' '*.tres' '*.ps1' '*.cmd' '*.py' '*.yml' '*.yaml' '*.json' '*.md' > COMBAT_FINITE_ALL_CALLERS.txt
git status --short
```
**This command was NOT run as part of the current connector audit.** It should be run by later authorized Windows/Codex QA as independent all-extension verification; saved output is evidence, not a request to rewrite code.

**Verdict:** **EXHAUSTIVE GDSCRIPT/SCENE STATIC SEARCH DONE**, 3 combat authority chains identified, SAVE migration dependencies identified; no runtime deletion, no Godot pass, no claim that historical docs have been scanned line-by-line. See migration and implementation packet companions.
