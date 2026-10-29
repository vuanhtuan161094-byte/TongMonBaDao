# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

## 29/10/2026 — D4-B implementation checkpoint

Branch feature/v63-v64-full-combat-20261029 current checkpoint source SHA: bbd6f83984c45e5212847bdaf326f14ef5ab469f. D4-B published source/test SHA: bbd6f83984c45e5212847bdaf326f14ef5ab469f; base feature SHA: 91ae575eb7bf94f09b38fd99403b3b0f7f262079. Stable main remains c0c1382f119599497b52d8ee8abd9e830a883f1e. PR #52 remains Draft/open at f7c33d9c3baba3267a17021718b44f87acd62ef6; no merge or PR mutation.

- D4-B implementation: **HEADLESS_PASS**. Official Windows Godot 4.7.2 import exit 0 and all 16 focused/affected cumulative scripts exit 0 sequentially. Exact log hashes and source parity are in [D4-B evidence](docs/implementation/V65_D4B_HUMAN_BRANCHES_EVIDENCE_20261029.md) and E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D4B_20261029_final.
- Behavior: 105 Human nodes/9 branches, manual-backed learn/equip/Combat V2 casts for each branch, shared-school basic/mobility, 96 archive-source links, branch-derived innate/passives, bounded status/support/AoE, and 3 real telegraph/release Human bosses with one-time phase events.
- D4-A/D4-B GUI and owner visual acceptance: **PENDING**. D4-B changed no UI/scene/assets/VFX; D7 owns the full visual integration matrix. Actual Android/performance QA remains pending.
- Both V6.3 gates remain OFF by default. Balance/economy and Boss coefficients remain candidate only. SaveService/schema, legacy P2/P2.3, One Active Job/scheduler, Injury120, Warehouse authority, production and raw assets remain protected and unchanged in D4-B.
- The seven D4-B source/catalog/test blobs match the canonical Git blobs used for the final run. Generated Godot import sidecars and unrelated PowerShell work remain uncommitted/unpublished.

PR #52 at f7c33d9c3baba3267a17021718b44f87acd62ef6 remains divergent. PR-only profiler wrappers and SaveService/runtime/presentation changes were not imported; this feature branch keeps its D2 receipt settlement, D3 One Active Job guards, and D4 adapter code.

## Next code packet — D5 Immortal lineage and bosses

Issue #54 and the execution contract authorize continuing. Required behavior: nine Immortal branch lineages with distinct A/B successors (learned history may retain both; only one descendant per family active), three real Immortal bosses with their own telegraph/stage/counter mechanics, status reactions, and deterministic breakthrough study through the existing D3 learning/One Active Job authority. Do not clone Human numerics or visuals. All costs, durations, status coefficients, and peak HP remain candidate-only; global gates stay OFF.

Concrete D5 write allowlist (only these paths):
- godot/data/combat/v63_immortal_combat_catalog.json (new)
- godot/data/combat/v63_learning_catalog.json
- godot/data/combat/v63_archive_catalog.json
- godot/src/simulation/archive/v63_sect_archive_system.gd
- godot/src/simulation/technique/v63_learning_system.gd
- godot/src/simulation/combat/v63_immortal_skill_combat_system.gd (new)
- godot/src/simulation/combat/v63_human_skill_combat_system.gd
- godot/src/simulation/combat/map_battle_v2.gd
- godot/tests/simulation/v63_d5_immortal_lineage_combat_test.gd (new)
- godot/tests/simulation/v63_d5_predictable_breakthrough_study_test.gd (new)
- godot/tests/simulation/v63_d4b_human_branches_bosses_test.gd
- godot/tests/simulation/v63_d4b_archive_learning_test.gd
- godot/tests/simulation/v63_d2_sect_archive_test.gd
- godot/tests/simulation/v63_d2_codex_drop_receipts_test.gd
- godot/tests/simulation/v63_d3_learning_job_test.gd
- godot/tests/simulation/v63_d4a_human_combat_test.gd
- godot/tests/simulation/v63_d4a_state_roundtrip_test.gd
- godot/tests/simulation/p2_5_combat_skill_test.gd
- godot/tests/simulation/dv2_02_combat_stats_test.gd
- godot/tests/simulation/p2_3_technique_test.gd
- godot/tests/simulation/p3_7b1_warehouse_test.gd
- godot/tests/simulation/save_service_async_roundtrip_test.gd
- godot/tests/simulation/safe_01_save_recovery_test.gd
- godot/tests/simulation/pve_save_return_reload_exactly_once_test.gd
- godot/tests/simulation/pve_multicamp_combat_hp0_bridge_test.gd
- docs/implementation/V65_COMBAT_COVERAGE_LEDGER_20261029.json
- docs/implementation/V65_D5_IMMORTAL_EVIDENCE_20261029.md (new)
- CURRENT_CHECKPOINT.md
- NEXT_CHAT_HANDOFF.md

D5 protected/excluded: D6 Divine/rare, D7 UI/VFX assets and presentation, D8 endgame balance/performance release tuning, SaveService/schema, CombatStatsV2 formulas, Injury120, Warehouse and scheduler authority, production/economy, raw JX assets, main, PR #52, and merges. Rollback suppresses new D5 effects through the default-OFF gate while preserving knowledge/loadout records; no destructive downgrade or replacement of Human knowledge.

D5 focused/cumulative gates: new Immortal A/B and deterministic study scripts; D4-B and D4-A combat/state tests; D2 archive and exact-once drop receipts; D3 study; P2.3/P2.5/CombatStats; canonical Warehouse; SaveService/SAFE-01; PvE Save/Return/exactly-once and HP0 bridge; official Windows Godot 4.7.2 import; sequential logs/source parity. GUI remains required only when visible files change.

## Superseded checkpoint records

## 29/10/2026 — D4-A implementation checkpoint

Branch feature/v63-v64-full-combat-20261029 source HEAD: 0af2af261e62960ffb4669c8d9d81feb153dd387. Stable main remains c0c1382f119599497b52d8ee8abd9e830a883f1e. PR #52 remains Draft/open at f7c33d9c3baba3267a17021718b44f87acd62ef6; no merge or PR mutation.

- D4-A implementation: **HEADLESS_PASS**. Godot 4.7.2 official headless import exit 0; all 14 focused/affected cumulative scripts exit 0 sequentially. See docs/implementation/V65_D4A_HUMAN_COMBAT_EVIDENCE_20261029.md and E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D4A_20261029_final.
- D4-A behavior: default-OFF Liệp Ảnh Human skill Xuyên Tâm Tiễn, six learned/equipped casts through real MapBattleV2/CombatStatsV2 damage, and Human boss Thiết Giáp Sơn Viên with telegraph/actions/70% and 35% phases. Additive personal skill fields and actor-local pending-cast save/restore.
- D4-A GUI: **PENDING**. Issue #54 calls for an actual live capture. Computer Use launch timed out; no screenshot or owner visual acceptance is claimed. D4-A changed no art/UI.
- Candidate coefficients remain unapproved. SaveService/schema, legacy P2/P2.3, Injury120, One Active Job, canonical Warehouse/scheduler, production/economy and assets are unchanged. Gates default OFF.
- Git transport normalization: code payload d744537069f5c6ae2108a7334321eff6339ec6aa; canonical-LF final source SHA 0af2af261e62960ffb4669c8d9d81feb153dd387. Original dirty E: checkout remains untouched; the isolated scratch working copy's Git HEAD metadata remains at preflight 91cfc7e, while its D4-A source files match the final tested blobs. Godot-generated import sidecars remain untracked and unstaged.

PR #52 conflict matrix remains: its HuntingPveRunV2 lacks this feature branch's D2 codex receipt settlement and D3 One Active Job guards, so preserve feature code. PR-only MapBattle profiler wrappers are not adopted. PR SaveService/runtime changes remain outside scope.

## Next code packet — D4-B full Human branches and 3 bosses

Owner's Issue #54 and execution contract authorize continuing without a new design-only pause. Baseline main SHA c0c1382f119599497b52d8ee8abd9e830a883f1e; feature source SHA 0af2af261e62960ffb4669c8d9d81feb153dd387. Single writer: this task owns the listed D4-B paths.

Required behavior: all nine Human branches with basic, mobility, four active slots, ultimate, five elective passives and derived innate; learn from archived manuals; meaningful branch effects including bounded owner-attributed poison, guard, heal, marks, AoE and AI; three Human Bosses Thiết Giáp Sơn Viên, Xích Viêm Lang Vương and Bách Độc Chu Hậu with real telegraph/release and idempotent 70%/35% phases. Complete D4-B fills remaining Human skill coverage including Liệp Ảnh, whose D4-A pilot is one active only. Candidate balance remains unlocked. Reuse CombatStatsV2, D2 archive/Warehouse receipts, and D4-A gate. Visual cues and original VFX authoring remain D7.

Concrete D4-B write allowlist (only these paths):
- godot/data/combat/v63_human_combat_catalog.json
- godot/src/simulation/combat/v63_human_skill_combat_system.gd
- godot/src/simulation/combat/map_battle_v2.gd
- godot/src/simulation/combat/hunting_pve_run_v2.gd
- godot/src/simulation/state/disciple_state.gd
- godot/src/simulation/state/simulation_state.gd
- godot/tests/simulation/v63_d4b_human_branches_bosses_test.gd (new)
- godot/tests/simulation/v63_d4b_archive_learning_test.gd (new)
- docs/implementation/V65_COMBAT_COVERAGE_LEDGER_20261029.json (new)
- docs/implementation/V65_D4B_HUMAN_BRANCHES_EVIDENCE_20261029.md (new)
- CURRENT_CHECKPOINT.md
- NEXT_CHAT_HANDOFF.md

D4-B protected: SaveService/schema, MapBattleSnapshotV2 schema, CombatStatsV2 formulas, P2/P2.3 legacy behavior, scheduler/One Active Job, Injury120, Warehouse authority/reward economics, production, raw JX assets, main, PR #52. Reuse existing D4-A actor/snapshot adapter; justify and document before widening allowlist.

D4-B gates: two new focused scripts cover all nine branch sample learn/equip/execute paths, every authored slot family, archive-source checks, owner attribution and poison caps, bounded heal/guard/mark/AoE, AI/telegraphs/phases, cast/snapshot resume, and default-OFF legacy. Then run D4-A, P2.5/P2.3, CombatStatsV2, D1–D3, D2 receipts, Warehouse, SaveService, SAFE-01, PvE save-return and HP0 bridge regressions sequentially on official Windows Godot 4.7.2; record source parity, each exit/log hash, GUI evidence if visuals change.

## Superseded checkpoint records

The earlier D4-A preflight and D3 status notes below are preserved for history; where they say code/tests were not started or D4 code needs new authorization, those statements are superseded by this checkpoint and Issue #54.

---

## Historical D4-A preflight / exact allowlist (superseded)

**Historical status at preflight:** D4-A had not started. Superseded by the current implementation evidence above. Base feature HEAD is `a9a7d5ab97c3b02de467c54b94d4d9c4c8d3d9ca`; stable main remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`. Work is in isolated `E:\\TongMonBaDaoWorkspace\\01_Game\\TMB_V65_D4A_20261029`. The original E: feature worktree at `d45ab195c53c00f0f29732124dd7678fd42cb351` retains its dirty files and existing Godot processes.

**D4-A behavior:** default-off, opt-in learned/equipped Liệp Ảnh Human skill events resolve through Combat V2 HP/damage; a Human-tier Thiết Giáp Sơn Viên boss uses real cast/telegraph/hit events; six disciples can auto-cast. Gate-off legacy P2/P2.3 remains byte/behavior stable. No balance coefficients become approved.

**Concrete D4-A allowlist (only these paths):**

- `godot/src/simulation/combat/v63_human_skill_combat_system.gd` (new)
- `godot/src/simulation/combat/v63_human_combat_battle_v2.gd` (new)
- `godot/data/combat/v63_human_combat_catalog.json` (new)
- `godot/src/simulation/combat/v63_feature_gates.gd`
- `godot/src/simulation/combat/map_battle_v2.gd` (one guarded adapter so a V6.3 boss skips only the legacy generic boss cast)
- `godot/src/simulation/combat/hunting_pve_run_v2.gd` (narrow opted-in party/boss construction adapter; keep current D2 receipts and D3 job guards)
- `godot/src/simulation/state/disciple_state.gd`
- `godot/src/simulation/state/sect_state.gd`
- `godot/src/simulation/state/simulation_state.gd`
- `godot/tests/simulation/v63_d4a_human_combat_test.gd` (new)
- `godot/tests/simulation/v63_d4a_state_roundtrip_test.gd` (new)
- `docs/implementation/V65_D4A_HUMAN_COMBAT_EVIDENCE_20261029.md` (new)
- `CURRENT_CHECKPOINT.md`
- `NEXT_CHAT_HANDOFF.md`

The additive disciple records are necessary: legacy `learned_combat_skills` is validated against P2 IDs, so storing `tmb.skill.*` there would corrupt legacy validation. Add empty-default V6.3 knowledge/equipped fields with model-owned `to_dict/from_dict`; `SaveService` remains unchanged because it serializes `SimulationState.to_dict()`. No schema replacement or legacy crosswalk. No `MapBattleSnapshotV2` change is planned; cast state stays in its existing serialized actor/cast records.

**PR #52 conflict matrix, verified against current `f7c33d9`:** `hunting_pve_run_v2.gd` in PR #52 lacks feature-branch D2 codex receipt settlement and D3 One Active Job guards; preserve feature code and only add the opted-in adapter. PR-only MapBattleV2 changes are environment-gated profiler fields/wrappers; this packet adds a separate V6.3 guard and does not adopt those changes. Snapshot PR changes only avoid a deep copy of immutable navigation while this feature currently deep-copies it; leave both versions untouched. PR SaveService/runtime removals and presentation changes are outside this packet. No merge/cherry-pick of PR #52.

**Protected/excluded:** `SaveService`, `MapBattleSnapshotV2`, CombatStatsV2 formulas, the legacy CombatSkillSystem, P2/P2.3 screens, scheduler/One Active Job, Warehouse, Injury120, production, assets/VFX, main and PR #52. D4-A uses the existing `MapBattleV2` hit path; default-off flags and new records remain additive on rollback.

**Test plan:** official Godot 4.7.2 import; new skill/boss and saved-state round-trip tests; gate-off P2.5 and group MapBattle regressions; D1 registry, D2 archive/drop receipts, D3 learning/job/save round-trip, multicamp HP0 bridge and PvE save-return exactly-once regressions, run sequentially. Record exact code SHA, exit codes and logs. Real GUI capture in the existing P3.2 scene remains a required D4-A gate; no GUI PASS is claimed at preflight.

## Older checkpoint archive (superseded)

## 29/10/2026 — Owner authorizes FULL V6.5 execution D4–D8

**Current owner instruction supersedes the previous 'D4 design-only, seek separate CODE permission' note** for the explicitly bounded phase packets in [the V6.5 execution contract](docs/operations/TMB_V65_FULL_COMBAT_EXECUTION_CONTRACT_20261029.md). Windows Codex should implement D4-A → D4-B → D5 → D6 → D7 → D8 consecutively on the existing `feature/v63-v64-full-combat-20261029` feature branch, with phase-specific allowlists, tests and logs. Do not merge or disturb PR #52. Resume only from new current HEAD after fetching; earlier audited head `bbac288acd14b0612414a458c43a4fa8a178e86f` is an anchor, not a frozen ref.

**Critical change:** PR #52 head has advanced to `f7c33d9c3baba3267a17021718b44f87acd62ef6`; full-combat feature and PR #52 have diverged. Compare and reconcile relevant PvE/Save files before altering them. Preserve four dirty EOF-only files in E: by using an isolated E: scratch worktree. D3 is only a gated headless-validated learning implementation; new skill combat / nine active bosses / approved visual gameplay are **NOT DONE**. Full approval requires runtime plus actual GUI & owner review. No automatic owner visual approval or main merge.



## Cập nhật 29/10/2026 — V6.5 full combat task

> Ghi chú hiện tại này thay thế các branch head và gate đã cũ trong snapshot lịch sử bên dưới.
>
> - Stable `main`: `c0c1382f119599497b52d8ee8abd9e830a883f1e`; PvE reference `integration/pve-unified-rc-20261027`: `5005d7508dff4b6a3da3f319de09dac33669882a`.
> - Stable `main` remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`; active no-merge feature branch is `feature/v63-v64-full-combat-20261029`. The D3 implementation is based on live feature head `4b914d05eb601d2788968a0419e5dda63c79b6fc`; code/catalog and initial tests are in `9bbc5edacf73388505a16c8db0e3b9097a41d55a`, followed by a completed-save reload regression in `677184c3f05eb84e31aed66e48ee42c383acc222`.
> - D1 and D2 remain complete at their recorded source SHAs. D2 Sect Archive and exactly-once codex rewards remain gated OFF and candidate-only as documented in [D2 evidence](docs/implementation/V63_D2_ARCHIVE_EVIDENCE_20261029.md).
> - D3 gated personal technique learning is implemented: archived manual source checks, per-disciple timed study as the sole active job, one main + two auxiliary slots, personal mastery, deterministic prerequisites, retry-safe start/cancel/completion receipts, and additive save migration preserving legacy P2.3 fields. No identity crosswalk or live combat effect was added.
> - Exact committed source parity was checked across all 14 D3 code/catalog/test paths against final source/test commit `677184c3f05eb84e31aed66e48ee42c383acc222`. Official Godot `4.7.2.stable.official.ed1daf0bf` Windows headless import and all 10 focused/cumulative scripts PASS, exit 0. See [D3 evidence](docs/implementation/V63_D3_LEARNING_EVIDENCE_20261029.md).
> - Global `technique_learning` and `sect_codex` gates remain OFF by default; candidate costs/ticks are provisional, and combat effects remain disabled. The D3 rollback is gate-off while retaining saved learning records; legacy P2.3 fields remain unchanged.
> - The E: D3 feature worktree was not overwritten because four in-scope files contained uncommitted EOF-only line-ending changes. Validation ran on the Windows scratch checkout whose 14 file contents match the committed code SHA exactly. Physical GUI, Android and owner visual acceptance remain PENDING.
> - PR #52 remains Draft/open; no PR was created and no merge to `main` was performed. Next work is D4 planning and a separate owner-approved CODE packet; do not start D4+ code from this checkpoint.


**Cập nhật 27/10/2026 — Một dự án, một bản game chính thức.** Đọc file này trước; các checkpoint dài cũ là lịch sử, không phải nhiều phiên bản game song song.

## Phiên bản và quyền hạn

| Loại | Nhánh | Trạng thái |
| --- | --- | --- |
| **Stable chính thức** | `main` tại `c0c1382f119599497b52d8ee8abd9e830a883f1e` | Bản đã được chấp nhận; **chưa chứa** PvE mới. Chưa được phép thay đổi. |
| **Bản phát triển tham chiếu** | `feature/pve-jx-continuous-world-20261026` tại `6b3fd181392c96c2386e5aa85950d2e993d67dda` | Nền tảng shared cho hai Codex; giữ nguyên trong kỳ nghiệm thu. |
| **Ứng viên tích hợp DUY NHẤT** | `integration/pve-unified-rc-20261027` | Tổng hợp **PR #51 core + PR #50 visual + tài liệu PR #49**, bảo toàn đúng file/byte và nhánh gốc. PR #52 vẫn Draft, không phải Stable. Focused QA mới nhất và exact HEAD được liên kết từ [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) và PR #52. |
| Core hồi quy đã chạy | [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) SHA `c217471bd3fbe88b95e6e7537b39dc07ae683e41` | Codex 1 **báo cáo 14/14 lệnh Godot 4.7.2 exit 0**; log chi tiết lưu tại E: Windows, chưa tái kiểm tra bằng engine trên RC. |
| Visual & VFX | [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) SHA `59c6dea9041653026e02a55b0bc1f4e298976835` | SHA sheet/manifest Source A/JX static PASS; VFX Save/Resume focused test chạy trên RC; chuột thật/FPS vẫn PENDING. |
| Handoff/Docs | [PR #49](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/49) | Trạng thái được nén, AGENTS và kiến trúc không bị thay; file này cập nhật kết quả Codex 1/2 trên RC. |

**Không merge các PR nguồn #44–#51 riêng lẻ vào main.** Khi nghiệm thu đủ RC và được owner duyệt, một lần review/merge bản chốt vào `main`, tag SHA, đóng các PR được thay thế có dẫn nguồn và thu hồi nhánh sau khi Windows worktree đã nhả.

## Kết quả và gate nghiệm thu

| Gate | Tình trạng có bằng chứng |
| --- | --- |
| Canonical SaveService | **PASS trên PR #51**: lỗi `FAILED=1` trong DV2-03 do fixture thay `aptitude` đệ tử D7 mà không cập nhật quality. SaveService production không sửa, save hợp lệ và backup còn nguyên. Safe recovery và VFX Save/Resume focused checks chạy lại trên RC; không sửa SaveService. |
| PvE move C17 + 6 thành viên | **PASS trên PR #51**: hoàn tất subcell same-cell; sáu đích hợp lệ riêng, cùng connected region, thao tác nguyên tử; Godot focused QA PASS. |
| World 20 camps / autonomous | **PASS trên PR #51**: C01 → C02 sau 10 HP0 tự nhiên, có năm quái C01 respawn, Save/Reload. Kết quả 11 HP0 tổng, 5/6 đội sống tại lúc chụp, `LOOT_PENDING`, Warehouse không phát sinh receipt. |
| Injury120 | **PASS test độc lập** GP-02C1 tại mốc 119/120 tick online/offline trên PR #51. Bài P3.2 70s ở SHA đó có tám kills, **zone-hop và Injury120 chưa tới** trong fixture ngắn này. |
| VFX JX #158 | **PASS focused**: VFX Save/Resume regression chạy trên RC; static 10+17+8=35 frames, frame bounds, sheet hash/anchor và Source A tám clip/texture khớp E:. Binding Unity prefab/pivot và skill mapping vẫn **UNVERIFIED**. |
| Female Stage A / selected-only actor | Installer giữ exact package hash và dùng .NET SHA-256 fallback khi `Get-FileHash` không có; tracked transport và external ZIP fallback đều kiểm tra đủ 42 PNG. Live-map test chọn qua `_open_disciple`, đợi focus camera, xác nhận một actor được dựng trong viewport và roster khác vẫn virtual. Focused PASS trên current PR #52 head; exact log/SHA ở Issue #37. |
| Full regression trên RC | 22/22 PASS, exit 0 từng lượt; Godot 4.7.2.stable.official.ed1daf0bf. Gồm 14 core + 8 presentation, bao phủ clock/D7 Save A-B/C17/formation/20 camp/HP0/Injury120/Save-Return/Source A/VFX/camera/selected-only/UI. Matrix và exact SHA từng lượt nằm trên evidence branch và Issue #37. Đây là headless QA. |
| Hiệu năng headless P3.2 | Test 6v10 dùng roster 130, 50 shared-clock polls và mất 252,956 giây; kết thúc 73 giây mô phỏng/164 actions/10 kills/zone-hop PASS. Đây là dấu hiệu tải mô phỏng cần profiler; không suy ra FPS game thật. |
| GUI bình thường / điều khiển chuột / FPS | PENDING_GUI. Launcher mở P3.2 ở 1280x720; Win32 xác nhận cửa sổ và log runtime-ready, nhưng Sky không liệt kê được cửa sổ nên chưa có thao tác chuột, ảnh/video, Save/Return hoặc FPS logger OFF/ON. Không gọi GUI hoặc PLAYABLE PASS. |
| Android | Chưa có APK/thiết bị thật nghiệm thu. |
| Branch cleanup | Kiểm kê 166 nhánh trước đây, chưa xóa nhánh hay đóng PR nào; không xóa nhánh khi có worktree Codex hoặc dữ liệu độc nhất. |

## Quy tắc kỹ thuật vẫn khóa

- Godot **4.7.2**; landscape **1280×720**.
- Source A đã chốt phong cách và map sản xuất; không làm lại renderer.
- **Combat V2** duy nhất; One Active Job; Injury 0/1 và **120 scheduler ticks**; SaveService/SimulationRuntimeOwner/Warehouse canonical; không cấp phần thưởng đồ rơi giả.
- Các thiết kế công pháp/Boss/Forge/Economy V2 chưa nằm trong code hiện hành không tự trở thành runtime authority khi hợp nhánh.
- Hiện `main` và PvE feature không thay đổi. Draft RC không chứng minh visual acceptance hay performance.

## Bàn giao tiếp

1. Full 22-test headless matrix PASS trên RC; dùng exact SHA, logs và exit codes trong evidence của Issue #37, không ghép kết quả từ SHA cũ.
2. Nghiệm thu GUI chuột thật 1280×720: 15s sản xuất, chọn sáu đệ tử, PvE 30–60s, pan/zoom/minimap, Save/Return; chạy `tools/windows/run/Run-PVE-FPS-QA.cmd` OFF và `/log` ON tuần tự, ghi P50/P95/P99, 1%-low, RAM, worst spikes và ảnh/video thật.
3. Chỉ owner review/duyệt mới merge `main`; không xóa PR/nhánh hoặc hồ sơ, save, E: assets.

Nguồn: [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37) · [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51) · [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50) · [166-branch inventory](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/audit/tmb-whole-project-readiness-20261027/docs/operations/TMB_GITHUB_BRANCH_CONSOLIDATION_REGISTER_2026-10-27.md).

Old full history preserved at [legacy checkpoint](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/6b3fd181392c96c2386e5aa85950d2e993d67dda/CURRENT_CHECKPOINT.md).

