# TÔNG MÔN BÁ ĐẠO — AFTER CARE: NEXT PLAYABLE GAMEPLAY & TINH NGUYÊN DESIGN PACKET

> **IMPORTANT DESIGN UPDATE 2026-10-23 — SUPERSEDED DIRECT-XP CHOICE:** The user asked to choose the most fun loop and challenged mandatory Tinh Nguyen absorption. See [B3_DIRECT_KILL_TUVI_RECOMMENDED_GAMEPLAY_2026-10-23.md](B3_DIRECT_KILL_TUVI_RECOMMENDED_GAMEPLAY_2026-10-23.md) for the NEW recommended loop: genuine monster death grants eligible personal fixed Tu Vi directly, alongside one Sect loot receipt. This overrides the earlier recommendation **as design proposal only**; existing canonical \`CULTIVATION_BREAKTHROUGH_V2_SPEC.md\` §2.2 still prohibits direct-kill EXP until separately approved and reconciled. Do not code from either document before CARE integration gates.


**Ngày:** 22/10/2026 · **Loại:** DESIGN + SOURCE CROSSCHECK ONLY · **Không CODE / không sửa Source A / không merge**.  
**Baseline tham chiếu:** GitHub `main=29b5fba448b0178cb520a4ada44b375b4b934e31` tại lúc lập packet; B3 CARE code local `35ffa85fd45da42e43722e7ac74b7423602d4491` chưa coi là đã merge.  
**Nhánh tài liệu riêng:** `docs/b3-postcare-next-playable-design-20261022`. Codex đang tích hợp CARE/skill, **không được chạm vào worktree Codex hoặc `CURRENT_CHECKPOINT.md` của nó**. Sáu TMB skills đã được merge vào main qua PR #23 (`29b5fba4`). PR #22 cũ là draft trùng; không phải baseline triển khai.

## 0. Nền đã đạt và nền chưa đạt — không nhân đôi

**Evidence của CARE từ ZIP người dùng cấp, đã kiểm toán checksum/hash:** `73/73` checksum; Git bundle có lịch sử B3, `15/15` official Godot focused PASS theo log Codex tại CARE HEAD; đã có một vòng săn demo: một đệ tử, hai job đan thật, Tụ Khí +10000 **fixed Tu Vi**, Hồi Xuân +55HP, chết HP0 -> HP1/Injury1 -> đợi đủ 120 phút simulation -> cùng world tái chiến -> tổng 4 `tinh_lang_bi` vào Kho; save/load/offline/crash-retry trong fixture đạt. Số 4 kill thuộc demo, **không** là tỷ lệ giết/phút dùng để cân bằng game. Android physical/GUI manual acceptance còn PENDING. **Owner đã sửa lỗi gõ**: shared medicine satiety **1,000,000/người/ngày simulation** (`floor(tick/1440)`), Hồi Xuân10, Tụ Khí25. Không mở lại tranh luận mức 100,000.

**Chưa hoàn tất/không được tự nhận**: B3 CODE đã merge main; nhiều đội 2–6 đệ tử cùng sống trong world; Boss nhiều đội/đóng góp DPS-tank-heal-support settlement; authored Tinh Nguyên reward và hấp thu; đầy đủ map r2–r30; V2 gear 10 slots/12 grades; Android acceptance; quy mô 1000–3000 units; full CI regression trên integration SHA.

## 1. QUYẾT ĐỊNH THIẾT KẾ ƯU TIÊN — làm cho săn quái có lý do tăng trưởng

### 1.1 Một điểm đang xung đột giữa hai design đời trước

- **CANONICAL OWNER-LOCK** trong `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` §2.2: quái chết **KHÔNG trực tiếp cộng Tu Vi**. Quái rơi **Tinh Nguyên**, khi đệ tử hấp thu mới cấp `fixed +X Tu Vi` qua `DiscipleRealmProgressV2.grant_xp`; `Tư Chất` không nhân fixed XP. Mỗi tick sinh Tu Vi tự nhiên một lần; `CULTIVATE` chỉ tăng nguồn tự nhiên.
- **P3.7 combat/hunting progression** tại `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` §13–15: săn map phù hợp nên phát triển ~**10–20×** tốc độ lao động thường theo *thời gian mô phỏng*, khi tính cả downtime/thuốc/nguy cơ; các phần trăm EXP theo tầng là mục tiêu cân bằng, không phải code live.
- Một số tài liệu B3 trước mô tả "per-kill personal Tu Vi". **Phương án hợp luật:** phát ra *quyền lợi vật liệu/credit Tinh Nguyên* trên real kill receipt; Tu Vi CHỈ tăng khi vật liệu được **hấp thu/tiêu thụ hợp lệ**. HUD có thể báo `Tinh Nguyên thu được`, không ghi `+Tu Vi` trên kill trừ khi cùng tick cũng diễn ra một giao dịch hấp thu đã commit. Không lách bằng cách đổi tên thành "pending XP" rồi cộng XP ở kill.
- Trong `tmb-balance-lab`, không được nhân thẳng `natural Tu Vi` với ×10–20 nữa nếu vẫn có fixed XP từ Tinh Nguyên; toàn hệ thống chỉ có **một nguồn natural + một nguồn fixed được trả lúc hấp thu**. Không double-count việc farm.

### 1.2 Product loop đề xuất — một vòng chơi có thể thấy được

```text
Tông môn phân công Đội Săn -> chọn map & risk policy
 -> quái do Combat V2 thực sự HP0
 -> kill receipt identity bất biến -> Sect Warehouse nhập vật liệu thật & Tinh Nguyên (nếu drop table chốt)
 -> bảng Kho cho thấy số Tinh Nguyên, ai đóng góp, nguồn map/kill
 -> chính sách Tự Hấp Thu/Chỉ Định đệ tử khi ở tông môn và eligible
 -> Warehouse debit atomically + fixed Tu Vi + receipt + saved satiety policy if explicitly authorized
 -> vượt tầng 1–9 theo cost curve; tầng 10 không được vượt cửa đại cảnh giới tự động
 -> đệ tử đủ mạnh, đi map khó hơn -> tiếp tục săn/luyện đan/luyện thể
```

**Khuyến nghị ownership V1:** `Tinh Nguyên` là resource ID có provenance riêng được đăng ký trong canonical Sect Warehouse; chính sách phân phối chọn đệ tử nhận hấp thu. Điều này khớp "mọi đồ/material thuộc Sect" mà không cần sinh ví hay kho riêng mỗi đệ tử. Đệ tử được điểm đóng góp cá nhân theo hành động hợp lệ khi săn nhưng không tự sở hữu resource stack. Đối với Boss và nhiều đội, credit/eligibility riêng được giải quyết bởi Boss-coop contract, không đoán 60/40 hay ngưỡng hỗ trợ.

**Quyền hạn/tiêu thụ OPEN:** Tinh Nguyên có áp dụng Đan Bão Hòa (pool đang có chỉ rõ pills) hay có giới hạn hấp thu riêng? Không tự mở trần thứ hai và không tự áp CAP thuốc cho một item khác loại. Phương án thiết kế mặc định chỉ giới hạn bằng **vật liệu thực + tính hợp lệ tại Sect + gate XP + One Active Job**; mọi chi phí hoặc giới hạn thêm phải qua owner approval cụ thể.

### 1.3 Source/proof boundaries

- Tinh Nguyên **chưa được chứng thực đã có ResourceRegistry item/source và consumer live trong B3 CARE**; cần inspect code trên HEAD tích hợp mới trước CODE. Không tạo `resource_id` hay loot table giả trong game.
- Chỉ có `KillReceiptLedger/RewardEnvelope` một chủ; settlement không được gọi lại legacy `HuntingMapV2.claim_reward` cho cùng death. No cosmetic/VFX creates reward.
- Consumption requires exact actor identity, possession, eligibility, failed gate preflight, replay-proof transaction, SaveService snapshot / negative tests for old-save compatibility. `grant_xp(..., "fixed")` must return explicit `unapplied_overflow`, with no phantom EXP bank.
- Tinh Nguyên dùng chung Kho; nếu thiếu chứng cứ reward không được tự trả thưởng trung bình trên offline, bản copy world/memory, hay reset roll khi đóng GUI.
- Rèn Thân EXP là channel riêng (`production/body_training/expedition` một natural source/tick hoặc fixed verified source). **Tinh Nguyên tu luyện Tu Vi không tự tăng Luyện Thể.**

## 2. Kịch bản định lượng kiểm chứng — không đặt rate production

**Code SOURCE hiện tại:** natural `base TuVi = 1000/simulation minute`; `Tư Chất +0.25%/point`. Ví dụ đệ tử Tư Chất 60 (không modifier khác): `1000×(1+0.0025×60)=1150/min`. Mục tiêu săn theo thiết kế 10–20× lao động thường: **11,500–23,000 Tu Vi/min** tổng (bao gồm natural + Tinh Nguyên thực tế khi hấp thu). Vậy trong một *cửa sổ quan sát dài* lượng Tinh Nguyên hấp thu phải đóng góp bình quân **10,350–21,850/min** nếu giữ cùng baseline. Các số dưới là **FIXTURE/NOT APPROVED**:

| Kill hiệu quả/phút mô phỏng | Tổng XP/tick mục tiêu giả định 15× (=17,250/min) | Fixed XP qua Tinh Nguyên/kill nếu drop 100% & 1 người | Nhận xét |
|---:|---:|---:|---|
| 0.25 | 17,250 | ~64,400 | Mỗi 4 phút 1 real kill, chỉ fixture |
| 0.50 | 17,250 | ~32,200 | Mỗi 2 phút 1 kill, chưa đo gameplay |
| 1.00 | 17,250 | ~16,100 | 1 kill/phút, chưa đo |
| 0.00 | 1,150 natural | Không có fixed XP | Injury/đứng nghỉ, không có phần thưởng ảo |

Đây là **throughput accounting** cho một đệ tử tự hấp thu theo chính sách, không phải rằng mọi quái chắc chắn rơi Tinh Nguyên hoặc chỉ 1 đệ tử nhận mọi reward. Giảm `p_drop` thì mức XP/đơn vị resource nếu giữ mục tiêu có thể tăng theo `1/p_drop` nhưng tăng variance; cần sim P50/P90, rủi ro thiếu vật liệu và time-to-next-floor trước khi owner khóa. Baseline cần lấy *actual active time, real kills, HP/injury downtime* từ Godot fixture mới, không dùng 4 kills/120 Injury ticks làm "kill cadence".

### Unit and sensitivity fixtures
- Tỉ lệ XP từ natural vs absorbed fixed per 1440 sim ticks; `fixed` không nhân Tư Chất.
- Tùy từng r1f1, r1f10, r2f1, r5f1, r10f1, r20f1, r30f1 và Luyện Thể lệch xa, target floor cost r1f1=700,000 canonical.
- Map theo realm/level difficulty; rank quá thấp không sinh exploit farm nhanh; rank quá cao gây injury/downtime, không làm free infinite XP.
- Kho 0/1/100/1e6 Tinh Nguyên, một và 100/1000 đệ tử cùng phân phối; tránh one-stack overspend và bất biến `Warehouse>=0`.
- Offline/replay acceptance: same seed/clock/world/receipt => same grants, không "average kills" không chứng cứ.

## 3. Thứ tự các CODE packets **chỉ đề xuất**, không cấp phép

**Gate 0 — Codex hiện tại:** hoàn thành 6 skills đã có trên main qua merged #23; B3 CARE `35ffa85f...` còn cần PR code riêng, exact integrated SHA, official Godot 4.7.2 focused + affected cumulative, save migration, and owner manual Android/Windows acceptance. Không nhập code từ nhánh B3 docs, G1/MAP25/C4 tràn sang B3. Khi Codex merge, refresh **main SHA**, điều chỉnh nội dung phần đã CODE; bản DOC này không tự cập nhật trạng thái.

**Packet A / B3-PROG-01 — Tinh Nguyên first real source** (sau Care integration/explicit owner CODE approval):
1. Read current HEAD's `ResourceRegistry`, world/kill ledger, `WarehouseSystem`, `DiscipleRealmProgressV2`, `SaveService`, `SimulationRuntimeOwnerV2`.
2. One authored starter monster drop source in **one** world, real kill receipt with resource identity+amount+provenance; no silent drop guarantee for every monster unless owner locks rate.
3. Sect Warehouse receives resource once. One selected disciple may absorb at the Sect, debits item and grants fixed Tu Vi exactly once. UI shows real resource quantity, `Tinh Nguyên hấp thu`, resulting XP, remaining floor/gate; no hypothetical +XP popup.
4. Test incomplete/duplicated kill, no loot, replay, offline/save, resource shortage, actor not eligible, full floor10 gate/overflow, rollback/crash; maintain Injury120 and medicine CAP1e6. Avoid touching Source A.
5. QA: official Godot 4.7.2 exact SHA focused on integrated branch, then at least current B3 CARE, GP-02C1, 30×10 progression, warehouse/save tests; UI/Android owner PENDING.

**Packet B / B3-TEAM-01 — 2–6 real disciples/team and action/evidence AI**:
1. Start single team, no Boss coop yet. Dispatch legal members, preserve One Active Job; actor downed leaves world, other members continue; healer/Tank effective actions must produce CombatV2 evidence, not fake stats.
2. Policy per team: risk/map/danger, HP threshold, supplies, manual pause/retreat. One owner, stable world/save; avoid upgrading AI brains in render loop; unit scale budget.
3. Verify 2–6 members, duplicate deploy, downed/return, EXP/resource allocation according to Packet A, same-world continuity, no ghost kill rewards.
4. VFX/UI only real events, free camera but gameplay not tied to focus/camera selection.

**Packet C / B3-BOSS-01 — same-world shared Boss/2 squads**:
1. Reuse boss multi-team contract and threshold/withdrawal fixtures already on design branch.
2. One instance/HP, exactly one loot pool Sect-owned, DPS/Tank/Healer/Support evidence, no last-hit. Equal per-eligible personal Stones after Sect share; Sect percentage NOT LOCKED (60/40 is only example).
3. No numeric thresholds, guard prevented-damage instrumentation, heal effectiveness or retrait expiration constant may be shipped until tests, owner approval and Combat V2 event trace.
4. Verify Boss HP reset/no duplicate loot, retreat/range/aggro, 2 team collision and contribution persistence.

**Packet D / B3-PROD-01 — r1–r3 tiered field / pill / body materials**:
- Expand actual content **after** A–C mechanisms stabilize. Keep Linh Điền Lv1–100; farm herb/grain valid IDs, new herb by unlock, one appropriately graded medicine and one Body source pilot, one higher risk map. Use `docs/design/TMB_300_REALM_MAP_FIELD_PILL_BALANCE_LAB_2026-10-22.md` as **simulation-only**, don't create r4–30 maps out of speculation.
- Recipe throughput, field slots, costs, XP worth, 1000 disciple logistics model must balance with actual input/output and 1,000,000 shared *pill* satiety, not a hidden medicine nerf.

## 4. First player-play acceptance (to avoid feature creep)

A player should be able to, using actual 1280×720 UI:
1) Launch, know next action; recruit/select, assign one hunter; 2) pick a hunting region with visible challenge; 3) watch authentic continuous combat + own kills; 4) see actual Sect Warehouse loot and Tinh Nguyên earned; 5) return/select Auto Absorb with clear source and amount; 6) see Tu Vi floor progress and gate warning; 7) make/use restorative and Tu Khí medicine; 8) take damage, return at HP0, Injury120, then auto redeploy same world; 9) save/load, no phantom gain/duplicate supplies.  
**No invented action animation**, Source A asset proof separate. An official headless PASS does not replace a user's real-device screen/touch acceptance.

## 5. What ChatGPT and Codex should work on concurrently

- **ChatGPT / Project Copilot (NOW, docs only):** audit Tinh Nguyên vs direct-kill conflict; propose source/consumer/receipt, dynamic XP pacing, resource budget, Boss participation calibration from existing fixtures. This packet is documentation—not a queued Codex code task.
- **Codex (ALREADY ACTIVE):** skill/Care integration, actual Godot testing, separate PRs, no concurrent gameplay writer. Check `main` HEAD on every action.
- **Owner when Codex reports:** decide whether to authorize B3-PROG-01 code; no need to re-decide CAP 1e6, Combat V2 or Injury120. Open issue decisions: Tinh Nguyên transfer/auto-absorb policy, whether it participates in medicine satiety, owner-signed starter drop source and thresholds, Boss eligible threshold/60:40 separate.

## 6. Ready-to-send prompt, only AFTER Code Integration PASS and owner CODE approval

```text
TÔNG MÔN BÁ ĐẠO — B3-PROG-01 DESIGN -> CODE REVIEW. Read docs/design/B3_POST_CARE_NEXT_PLAYABLE_PROGRESSION_DECISION_PACKET_2026-10-22.md from docs/b3-postcare-next-playable-design-20261022 and current main's AGENTS.md, Cultivation Breakthrough V2, ResourceRegistry, canonical B3/Care code. Preserve Combat V2, One Active Job, Injury120, satiety 1000000/day, official Godot4.7.2 and exactly-once ledger. Plan one real Tinh Nguyên drop -> Sect Warehouse -> legal absorption -> fixed Tu Vi -> floor gate, with no XP at monster HP0. First audit current sources/contracts and fixture rates; propose allowlist, tests, save migration and rollback. DO NOT CODE without my separate scope authorization, DO NOT merge/Source A/FULL/CI prematurely. Keep UI evidence genuine and report PASS/PENDING accurately.
```

## Supporting canonical sources
- `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` §2.2: monster HP0 ≠ Tu Vi; Tinh Nguyên only when absorbed.
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` §§13–15: farming 10–20× work as **pacing target**, not literal per-kill multiplier.
- `docs/P3_7_SPIRIT_FIELD_SPEC.md`: 1 plot = 1 timer; reserved worker, Lv1–100, no passive countdown work XP.
- `docs/design/B3_V2_LOOT_BOSS_DISCIPLE_PROGRESSION_ECONOMY_CONTRACT_2026-10-22.md` (on docs branch): channel separation and future Boss-reward contract, not present CODE.
- `docs/design/B3_V2_BOSS_PARTICIPATION_THRESHOLD_WITHDRAWAL_FIXTURES_2026-10-22.md` (on design branch): eligibility numerical candidates, not owner-locked.
- B3 CARE handoff README `35ffa85f`, real demo tick132 return and 4 skins, 15/15 according to local Codex logs; integration status must refresh once merged.
