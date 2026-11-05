# TMB NUMERIC SYSTEMS MASTER V1 — 05/11/2026

> **DESIGN / DATA CONTRACT ONLY — không được tự đọc tệp này trong gameplay.** Đây là bảng điều phối số liệu cho ứng viên duy nhất PR #72, không phải bằng chứng Godot PASS và không phải lệnh thay đổi cân bằng đã khóa. Baseline khi lập: PR #72 HEAD `4e7a89075615d52db3409729075f4b7174974f45`; phải re-fetch HEAD trước bất kỳ packet CODE nào.
>
> **Mục tiêu:** game có chiều sâu từ nhân vật → nghề → sản xuất → trang bị → PvE → loot → đột phá → tông môn, không có nguồn vật phẩm/tài nguyên giả, không tiến trình vô hạn miễn phí, không softlock, không vi phạm SaveService.

## 0. Trạng thái và thẩm quyền

- **LOCKED**: owner đã khóa thông qua nguồn hiện hành; không tự thay đổi.
- **CURRENT_RUNTIME**: phải đối chiếu code ở HEAD khi code; không suy diễn từ spec có nghĩa runtime đã thực hiện.
- **PROPOSED**: công thức/giá trị/đường triển khai mới để duyệt; chưa được phép đưa vào sản xuất.
- **DESIGN_HOLD**: nguồn cũ tồn tại nhưng chưa được phê duyệt tái nhập PR #72.
- **QA_PENDING**: chưa có test exact-source SHA trên Godot/CI, dù công thức có thể kiểm toán thủ công.
- Mọi thay đổi số/luật phải lập changelog `old → new`, tác động người chơi/save, test vectors và rollback. Không dùng mock UI hay ghi sẵn reward để làm kết quả.

**Nguồn thẩm quyền:** `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`, `docs/COMBAT_STATS_V2_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `docs/P3_7_SPIRIT_FIELD_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `CURRENT_CHECKPOINT.md`, Issue #56, live PR #72. Khi nguồn cũ nói 1,000–3,000 đệ tử hoặc cơ chế kinh tế khác quyết định Owner mới hơn, **không dùng số cũ làm luật mới**.

## 1. Số liệu/luật đã có nguồn thiết kế rõ ràng — không phát minh lại

| ID | Hệ thống | Canonical numeric/constraint | Trạng thái và điều cần xác minh |
|---|---|---|---|
| N-001 | Tu Vi | 30 đại cảnh × 10 tầng = 300 tầng | LOCKED design; coverage runtime cần đối chiếu |
| N-002 | Luyện Thể | 30 đại cảnh × 10 tầng = 300 tầng, track độc lập | LOCKED design |
| N-003 | Realm/Body Core | `G(r,f)=1.65^(r-1)*1.03^(f-1)` | LOCKED numeric design 09/10; **không coi là runtime PASS** |
| N-004 | Phân phối core | Realm `HP/ATK/DEF=100/20/12`; Body `90/3/7` tại 1.1 | LOCKED numeric design |
| N-005 | Tiềm Lực | `CoreFactor=1+0.0005*potential`, chỉ áp Realm+Body Core | LOCKED; không nhân lặp vào vũ khí |
| N-006 | DEF thường | `DEF_eff=max(0,DEF*(1-penetration))`; `K=2*attacker_ATK`; `mitigation=K/(K+DEF_eff)` khi `K>0` | LOCKED numeric design; thứ tự buff/status/context theo Combat Stats V2 |
| N-007 | Chỉ số nền | Tư Chất +0.25% EXP Tu Vi/điểm; Căn Cốt +0.20% EXP Luyện Thể/điểm; Thông Tuệ +0.15% EXP nghề/học/điểm; Tiềm Lực +0.05% Core/điểm | LOCKED theo spec; không tự gán tác động combat trực tiếp cho Cơ Duyên/Mị Lực |
| N-008 | D7 | Tam Căn 3 + Tứ Tính 4; nhãn Tâm Tính không đồng nghĩa được thêm buff combat | LOCKED presentation/authority |
| N-009 | Crit baseline | crit chance 5%, crit damage +50% (đòn hợp lệ thành ×1.5) | LOCKED design, kiểm tra hiện thực |
| N-010 | Lifesteal baseline | Hút Máu 0%; Giảm Hút Máu 0%; tính theo actual eligible damage, không theo overkill | LOCKED design |
| N-011 | Nghề | hệ số nghề thiết kế `1 + 0.01*profession_level` | LOCKED P3.7; xem compatibility P2 trước khi đưa runtime |
| N-012 | Linh Điền | một luống có timer và crop state riêng; policy AUTO_DEMAND/PRIORITY/FIXED | LOCKED design, cần xác minh runtime/worker authority |
| N-013 | Kho | Tông môn không có trần dung lượng Warehouse chung theo spec P3.7 | LOCKED design; capacity riêng khác phải có nguồn |
| N-014 | Trang bị | 10 slot thường, realm vật phẩm 1..30, phẩm 1..12; dòng affix phụ thuộc phẩm | LOCKED design, forge detailed odds **OPEN** |
| N-015 | Bộ trang bị | 24 bộ (18 combat, 6 nghề), kích theo 2/3/4 món, tổ hợp 3+3 hợp lệ | LOCKED design, % bonus cụ thể OPEN |
| N-016 | PvE thế giới | tối đa 30 hunter / 20 khu / 40 quái active / 200 vị trí respawn, team tùy chọn ≤6 | CURRENT_RUNTIME + focused PASS theo evidence PR72, không tương đương 19-step GUI |
| N-017 | Injury | 0/1, auto hồi phục 120 ticks, Injury cấm PvE | CURRENT_RUNTIME đã có focused evidence, không sửa |
| N-018 | One Active Job | mỗi đệ tử chỉ có một job active | CURRENT_RUNTIME + regression yêu cầu |
| N-019 | Tông môn | 27 bậc theo owner checkpoint, giới hạn nâng cấp do tu vi/đệ tử & tông môn | Cần bảng yêu cầu theo từng bậc; không tự chọn số từ source cũ |
| N-020 | Linh Điền/kinh tế mở rộng | Bulk `ProductionPlanRegistry`, cap cũ 30/30/40, `FoundationGrowthV2` | **DESIGN_HOLD**; tuyệt đối không tự port công thức/giá/nguồn từ branch cũ |

### 1.1 Các vector chuẩn cho G/DEF (oracle thiết kế, không phải test Godot vừa chạy)

- `r=1,f=1, body=1.1, potential=0` → `HP=190, ATK=23, DEF=19`.
- `r=2,f=1, body=1.1, potential=0` → `HP=255, ATK=36, DEF=26.8`.
- `r=1,f=1, body=1.1, potential=1000` → `HP=285, ATK=34.5, DEF=28.5`; cộng flat weapon Attack riêng, sau core.
- Attacker ATK=23, defender DEF=19, penetration=0 → `23*46/(46+19)=16.276923...`.
- Bất biến: tăng DEF không được tăng damage; ATK=0 ordinary damage=0; HP mới giữ tỷ lệ current/max cũ; không clamp tuỳ tiện đột phá thành x10.

## 2. Các chiều sâu phải thiết kế *và* hiện thực theo từng authority

| Packet | Đầu vào → đầu ra | Bảng số liệu cần chốt trước code | Vùng dữ liệu phải bảo vệ |
|---|---|---|---|
| BAL-01 CHARACTER | tuyển/sinh → D7, linh căn, huyết mạch, thể chất, thiên phú, mệnh cách, thân phận | phân phối sinh, rarity theo nguồn, derived effects, gain cap, re-roll/đột phá, giá trị từng điểm và điều kiện kích hoạt | identity seed, bản ghi sinh một lần, không reroll khi reload |
| BAL-02 REALM | hoạt động/đan/tu luyện → EXP → 300 tầng mỗi track | EXP từng tầng, gate boss/đột phá, thời gian đích p10/p50/p90, chi phí thất bại/hồi phục | Tu Vi / Luyện Thể riêng, earned EXP, save progress |
| BAL-03 PROFESSION | 1 active job → thời gian → EXP nghề + sản lượng | XP curve theo Lv, bonus/tốc, nguyên liệu, sản phẩm, xác suất hiếm, rare factor có giới hạn | Workforce, scheduler, 1 writer/worker |
| BAL-04 ECONOMY | Mine/Forest/Field/PvE → Kho → xây/craft/đan/sử dụng | catalogue resource ID, recipe ID, qty, duration, unlock, sinks, AUTO_DEMAND, cost-coverage | một Warehouse authority, exact-once settlement |
| BAL-05 COMBAT | stats + skill tags → hit/status/crit/mitigation → HP/receipt | ATK/DEF/HP, attack cadence, cast/GCD/ICD, boss defenses, DoT tick, PVE role target | Combat state, status, no duplicate reward |
| BAL-06 GEAR | source/recipe → unique item → 10 slots, phẩm 1..12, set 2/3/4 | affix pools/magnitude, 12-grade odds, enhance/reforge costs, failure semantics, 24 set bonuses | unique item ID, reservations/locks; no item duplications |
| BAL-07 PVE-LOOT | vùng/cấp quái → drop table → kho/đệ tử → tiến triển | quái thường/Elite/Boss, HP/time-to-kill, rarity pity (nếu duyệt), farm yield/hour, spawn density | 20×30 world, 200 slots, receipt generations |
| BAL-08 SECT | nâng bậc/tòa nhà/đệ tử → mở consumer mới | 27 bậc, requisites, công trình lv1..100, xây/xếp, thời gian, tự động hóa và trần hợp lý | building ownership, construction & Save |
| BAL-09 PROGRESSION | đan/tiềm lực/tu luyện/tu hành → sức mạnh | potion tier/quality, saturation, breakthrough materials, weekly unlock pacing | no free stacking, item origin |
| BAL-10 UX NUMERIC | mọi số thật → hiển thị trong Godot | công thức tooltip “nguồn → cộng → tổng”, icon, thời gian/chi phí/xác suất rõ ràng | UI chỉ đọc từ state thật, không ghi chỉ số giả |

**Không triển khai đồng thời tất cả:** một writer per subsystem, một packet CODE có allowlist và test vector; kiến trúc nguồn–tiêu thụ chung phải thống nhất trước khi viết từng vòng riêng.

## 3. Quy tắc xây công thức đề xuất (chưa khóa giá trị đầu vào)

1. EXP: `xp_requirement(track,realm,floor) = approved_curve_table[key]` hoặc hàm deterministic được đối chiếu đủ 300 tầng. Phải mô phỏng p10/p50/p90 ở nhịp chơi ít nạp/không nạp; không tự điền `base`/growth từ tài liệu cũ.
2. Sản xuất: `effective_duration = max(positive_min, base_duration / permitted_speed_multiplier)`; `output_qty = approved_output_formula(level,worker,crop,boost)`. Snapshot timestamp + recipe + worker + policy; reload không thực hiện hai lần và cancel theo luật hiện hành.
3. AUTO_DEMAND: tính **thiếu hụt ròng** `target_stock - available_stock - reserved_incoming + reserved_outgoing`, xét dependency và nguyên liệu, chọn recipe hợp lệ; nếu không có recipe thì hiển thị blocker, **không mint** nguồn vật liệu.
4. Đan/craft: chi phí, reserve, trạng thái `PENDING→RESOLVED→CLAIMED` hoặc cấu trúc canonical tương đương; rng seeded một lần, không random lại khi restart/cancel; sản phẩm unique item gắn receipt.
5. Loot: `(world_id,mob_id,spawn_generation,death_receipt)` là khóa idempotency theo thiết kế tích hợp; sinh lại quái khác generation không được hưởng trùng cái chết trước.
6. Trang bị: chỉ lấy valid affix cho slot và quality; không tính cùng hiệu ứng từ item + set hai lần; so auto-equip theo **tổng loadout** và buff nghề.
7. Stat scaling: component Realm/Body → independent flat → additive-% đúng channel → special; các % giảm incoming compose trên phần sát thương còn lại. Không thêm soft/hard cap tự phát.
8. Every scaling function must define: domain, default, rounding-at-UI-only, upper-bound/overflow policy, upgrade transaction, migration and exact oracle.

## 4. Mô hình player-journey bắt buộc trước khi chốt số

- **J1 New Game không cấp đồ QA:** từ tuyển đầu tiên đến nhân lực sản xuất tự duy trì; bảo đảm người chơi luôn có ít nhất một hành động để thoát điểm nghẽn.
- **J2 Sản xuất 24h / 7 ngày:** 1 Mỏ + 1 Linh Lâm + 1 Linh Điền → thu Kho → tiêu hao đúng công trình/đan; xem lượng thiếu, worker idle, lãng phí và time-to-next-upgrade.
- **J3 PvE solo → 6 người → 30 hunter:** TTK, tử vong, Injury120, HP0 receipt, drop/giờ, không solo fixture làm giả thế giới đầy.
- **J4 27 bậc / ba giới:** ước lượng thời gian p10/median/p90, ngưỡng EXP, bottleneck, khoản chi phí sau đột phá; kiểm soát inflation khi endgame cao.
- **J5 Item loop:** craft→equip→repair/enhance→salvage/reforge→set→boss→new material, item vẫn có giá trị khi thay thế.
- **J6 Offline + Save/Load:** 0 phút/30 phút/1 giờ/1 ngày, qua ba process cold reload, nguyên tắc chống phát sinh tài nguyên và loot hai lần.

Mỗi journey cần bảng: `state_in / actions / elapsed_minutes / resources_in / resources_out / xp_gain / realm_changed / inventory_receipts / state_out / must_not_happen`.

## 5. Schema dữ liệu số (đề xuất, chưa phải runtime)

Một hàng canonical khi chuẩn bị đưa vào `godot/data`:

```json
{
  "id": "sample_catalog_item",
  "schema_version": 1,
  "status": "PROPOSED",
  "system": "production",
  "unlock": {"sect_rank_min": null, "building_level_min": null},
  "inputs": [{"resource_id": "RESOURCE_ID", "qty": null}],
  "outputs": [{"resource_id": "RESOURCE_ID", "qty": null}],
  "duration_seconds": null,
  "rewards": [],
  "formula_ref": "BAL-04",
  "source_authority": "canonical owner-accepted spec",
  "save_compatibility": "no new runtime field",
  "qa_oracles": ["no_negative_inventory", "save_reload_exactly_once"]
}
```

`null` nghĩa là **chưa khóa**; tuyệt đối không tự diễn giải thành giá trị 0 hoặc miễn phí. Mọi ID và enum phải đối chiếu catalogue đang có để không tạo namespace mới.

## 6. Thứ tự triển khai GitHub khi máy Owner tắt

**Wave A — số liệu và oracle an toàn:** rà soát source từng authority; xuất register `LOCKED / EXISTING / MISSING / CONFLICT / PROPOSED`; thêm test vectors và bảng mô phỏng thuần không chạm Save/Combat. Commit design/data-only vào PR #72. Chưa gọi Godot PASS.

**Wave B — code theo packet được Owner duyệt:** ưu tiên **BAL-04 nguồn→tiêu thụ và BAL-03 workforce**, sau đó **BAL-01/02/05** để mọi số combat bắt nguồn từ nhân vật và cảnh giới. Chỉ sửa file cho phép, không mở feature branch mới. Sau mỗi commit: static review/diff, kiểm tra JSON/formula nếu có; khi CI Godot 4.7.2 thực chạy được thì gắn đúng SHA.

**Wave C — chiều sâu endgame:** gear, loot, 27-rank pacing, auto policy; không đưa các công thức vật phẩm/nguồn/bậc cao chưa duyệt vào runtime.

**Wave D — nghiệm thu máy thật:** pull/merge thay đổi E không phá dirty/untracked, tạo lại một offline package; mouse walkthrough 19 bước; chính thức R5 khi đạt đủ release gates.

## 7. Không được tuyên bố

- Không nói "mọi hệ thống đã code" chỉ vì có master schema.
- Không nói tài liệu này khóa các tỉ lệ drop/craft/XP hay trần xây dựng: **chúng chưa được duyệt**.
- Không nói tệp này thay thế các nguồn đã khóa, cũng không tăng thời gian hồi Injury, thêm nguồn tài nguyên, sửa PvE capacity, mở PvP, hoặc nhập hai animation labs.
- Không nói GitHub Actions/Windows/Android PASS nếu không có log thực thi ở đúng source SHA.

**Bước triển khai hợp lý:** khóa packet **BAL-04 bảng source→consumer, 0 softlock, 0 nguồn giả**, xuất catalogue + công thức + test-case; trước khi chỉnh runtime phải lập file allowlist/migration/test theo `AGENTS.md`.
