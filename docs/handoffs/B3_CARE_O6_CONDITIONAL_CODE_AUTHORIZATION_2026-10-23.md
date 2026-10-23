# TÔNG MÔN BÁ ĐẠO — B3 CARE O6 / OWNER CONDITIONAL CODE AUTHORIZATION

**Date:** 2026-10-23. **LATEST OWNER INSTRUCTION:** "cái lỗi này hình như trc đó cũng nói rồi đang batch 2 sang +3. viết lại code nếu cần thiết."  
**Scope:** approve CODE changes **ONLY WHEN CAUSALLY REQUIRED TO FIX O6**, after verifying source and existing policy. This **supersedes the earlier diagnostic packet's READ-ONLY restriction for a narrow O6 fix**, but does not permit other gameplay rewrites. **Not permission to merge PR #24 with a failing test.**

**PR:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/24, currently draft. Tested gameplay SHA as reported by Codex `98ee31e9e87f228da39b3863e76063cb30bc40d1`; PR HEAD `12387e12adc500d84b95cbfc433f297c3f6475f2`; main at earlier check `29b5fba448b0178cb520a4ada44b375b4b934e31`. Refresh exact SHAs before writing to remote branch. Keep one CODE writer, isolated worktree, and original B3 CARE ZIP.

## 1. NOT A NEW PRODUCTION BALANCE REQUEST

- Godot legacy O6 contract tests a Lv1 Mine producing **2 Thanh Thiết/explicit batch** and **4 after two batches** from the isolated QA setup. The actual `BuildingSystem._resource_job_batch_units` on main computes `base_batch_units + floor(building.level/10)`; this yields **2 at Lv1** for that source definition.
- Earlier owner conversations (14–16 Oct) already discussed **O6 producing 5 where the scenario expects 4**, and protecting the exact O6 contract, `carried_units` and all valid output. This recurrence is therefore a known integration failure, **not** a new authorization to globally raise 2->3, modify Economy V2 rate or nerf production.
- Latest Codex ZIP `MAIN_SKILLS_CARE_INTEGRATION_20261022.zip` logs: `diag_batches_baseline.stdout.log` shows batch1 `40→42` (+2), batch2 `42→44` (+2); `diag_batches_published.stdout.log` shows batch1 `40→43` (+3), batch2 `43→45` (+2). **The FIRST batch interval has extra +1; it is NOT two consecutive +3 batches.**
- State diverges at tick0: O6 selects `trieu_linh_nhi` previously, `co_truong_phong` at FASTTRACK. Same seed `31012026`. Both Mine members/worker slots vary after initial load; source factory raw groups and UI stage group assignment must be compared. The changed miner is a signal, not definitive causation.
- Baseline `Warehouse.available_quantity=4`, failed `=5`, with starter 40 reserved and `Mine.metrics.production_batches=2` in both. Single Mine batch metric increment does NOT prove there is only one resource credit into Sect Warehouse.
- The project's economy has BOTH (a) newer timed V2 Mine job with quantity set at job creation, and (b) legacy TRAVEL→EXTRACT→HAUL cycles, and **the legacy `carried_units` must survive save and drain legally**. Other combat/loot/market/legacy worker paths may affect material stock. Do not damage valid independent sources just to force the O6 count.

## 2. AUTHORIZED WORKFLOW — ACT, DON'T ASK AGAIN

1. Work only on a separate O6-fix CODE branch/worktree based on PR #24's latest tested head (check checkpoint docs-only commits). No edits in other ongoing writer's Source A/G1/Map/C4 worktrees.
2. Compare isolated PASS mapped GH commit `a141aa876480da0c4854cef21abd5cbeb6f1fb83` with first O6 FAIL mapped GH commit `a0a489ce3586b6af33e74dbdb5e211468c735357` using the same Godot4.7.2, seed31012026, isolated `user://`, official O6 test. Preserve reproducibility: run >=3 repeats per code state before interpreting chance/ordering differences.
3. Instrument *temporarily* all authoritative `thanh_thiet` warehouse deltas during each O6 batch: `tick,source_kind,building/job_id,actor_id,old_qty,new_qty,output_quantity,phase,carried_units,production_batches,active_resource_timer`. Identify **exact source of +1** (timed job? legitimate legacy HAUL? P2 legacy/combat loot? race/overlapping job? duplicated deposit?). Trace initial roster groups, in-flight jobs and deterministic `active_worker_ids` after SaveService load/UI creation.
4. If +1 is **phantom/duplicate/wrong job ownership**, fix *the true authority that awarded it*, with exactly-once/One Active Job guard, without changing intended successful 2-unit Mine batch yield. Add a regression reproducing the extra-credit condition and check old save/mid-HAUL behavior.
5. If +1 is from **legitimate separate source**, preserve that valid reward, and fix **O6 fixture isolation** only in a way that STILL verifies the full end-to-end required exact conservation `2 completed explicit batch receipts -> 4 newly spendable Thanh Thiết -> 3 spent on Forge -> 7 after 3 more batches -> Mine upgrade -> save/reload continuation`. Derive quantities/provenance from real job/receipt evidence; avoid ignoring phantom additions, raising assertion to 5 or masking a duplicate deposit. Do not hardcode a founder's name in production code to make result deterministic.
6. If a new intentional economy balance legitimately changes the 2/batch O6 contract, **stop and document the actual owner-locked decision and targeted test migration**; no unilateral Economy V2 rewrite. There is no such verified decision authorizing *this* +1.
7. After narrow fix, run O6 isolated repeated (3-5 attempts), then 28 relevant focused/cross-contract tests at the **new actual CODE SHA**, preserving 15/15 original CARE, Injury120, Warehouse/save, legacy carry, timer, wages, and queue job idempotence. Check official runner exit + PASS markers; don't relabel historic 27/28 as new test PASS.
8. FULL `227/240 Parse` from older log remains **INCOMPLETE**, not proof of parse error or success. Diagnose process end/host RAM before spending long cycles; only run authorized wider gate after O6 root cause and focused PASS. Windows GUI/Android/device and owner visual QA still PENDING. PR #24 stays draft until its gates close.
9. Publish a single narrow O6 code fix commit + focused test commit **to the existing CARE PR #24 branch only if safe and scope matches** (else separate PR stacked on #24); send links, exact file allowlist, first-divergence event, before/after stdout, 28/28 status, remaining FULL/GUI debt. Never silently merge. No code changes to B3-XP-01, Source A, Character Studio, G1, MAP25, C4.

## 3. NON-NEGOTIABLE PROJECT LAWS

- Godot 4.7.2, Android landscape 1280×720.
- Combat V2 authoritative, one Warehouse, one simulation clock, One Active Job, no duplicate save/offline reward; no second resource pipeline.
- Economy V2 user-locked rates remain as separately authored. Preserve legacy `carried_units`, labor and correct Warehouse deposit.
- B3 CARE: shared **pill satiety** 1,000,000 points/day/disciple, Injury120, auto-heal/auto-redeploy; don't reset to obsolete 100k.
- The 2026-10-23 owner-locked **direct hunt fixed Tu Vi** design is DOCS ONLY, not part of O6 bugfix. Boss 60/40 contribution thresholds, 300-floor additional tuning and higher map content remain outside scope.

## COPY-PASTE CODEX EXECUTION PROMPT

```text
TÔNG MÔN BÁ ĐẠO — CẤP PHÉP CODE NẾU CẦN THIẾT: SỬA O6 ĐÚNG NGUYÊN NHÂN.

Đọc docs/handoffs/B3_CARE_O6_CONDITIONAL_CODE_AUTHORIZATION_2026-10-23.md ở nhánh docs/b3-care-o6-recovery-and-design-gates-20261023, PR #24 và gói ZIP MAIN_SKILLS_CARE_INTEGRATION_20261022.zip.

Lỗi O6 đã từng phát sinh từ trước: Mine Lv1 dự kiến +2, +2; hiện +3, +2 (tổng 5 thay vì 4). Đây không phải yêu cầu sửa sản lượng Mỏ lên +3. Tìm chính xác giao dịch tạo +1 bằng trace state/tick/worker/warehouse. Baseline chọn trieu_linh_nhi, hiện chọn co_truong_phong; đừng kết luận do chọn người khi chưa có event proof.

TÔI CẤP PHÉP: sau khi có nguồn lỗi xác định, sửa code tối thiểu trong phạm vi O6, gồm production authority nếu sai hoặc cô lập test nếu có phần thưởng ngoài fixture hợp lệ. Không hỏi lại. Giữ O6 thật sự kiểm tra +4 từ hai mẻ, bảo toàn carry-cycle/carried_units, Warehouse, One Active Job, SaveService exactly-once và toàn bộ Economy V2. Không ép test 4 thành 5, không nerf bonus hợp lệ, không sửa Source A/G1/MAP25/C4/B3-XP-01.

Chạy O6 nhiều lượt sạch, rồi 28 focused trên SHA code mới. PR #24 vẫn DRAFT; không merge khi O6/FULL còn nợ. Báo root cause, file đổi, commit và logs; không nhận FULL PASS từ log Parse 227/240 cũ. Nếu không chứng minh được nguồn lỗi, dừng trước khi sửa speculative code, gửi báo cáo các event cần bổ sung.
```

**This document is the record of the latest explicit permission; it is not itself test execution or code delivery.**
