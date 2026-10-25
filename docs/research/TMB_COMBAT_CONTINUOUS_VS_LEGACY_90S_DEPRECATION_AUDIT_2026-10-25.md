# TÔNG MÔN BÁ ĐẠO — AUDIT CHỐNG SỬ DỤNG COMBAT 90s LỖI THỜI
## Canonical continuous hunting; safe deprecation rather than blind delete

**Ngày 2026-10-25. DOCS-ONLY cleanup/audit; KHÔNG đụng CODE, PR #28/#29/#31, UI, asset, merge, CI.** Mục tiêu: nhận diện đúng sự tồn tại của code 90s, ưu tiên nguồn mới và chặn mang luật cũ vào nghiên cứu R11 S1/S2. Chủ dự án yêu cầu rà soát và xóa lỗi thời. *Không thể đánh dấu xóa runtime nếu chưa có code patch/test.*

## 1. Bằng chứng đối chiếu BA baseline, không nhầm main với staging
| Nguồn | SHA kiểm tra | Thực tế | Authority |
|---|---|---|---|
| **main** | 29b5fba448b0178cb520a4ada44b375b4b934e31 | `godot/src/simulation/combat/map_battle_v2.gd`: `MAX_SECONDS=90.0`, `ARENA=36×20`, `timeout_retreat`; `hunting_pve_run_v2.gd` với encounter terminal/claim | Đây là **legacy finite encounter**, không được dùng làm chuẩn luật World R11 |
| **integration/master-v3-combat-d7-uiux-20261024** | path `map_battle_v2.gd`, blob 3790341185e15c3a0d9479cdc906ff650cfa807a | `continuous_mode` tồn tại; timeout chỉ nếu `not continuous_mode` | Continuous kernel là hiện trạng trên nhánh staging |
| **PR #31** `integration/pr28-combat-v3-s1-playable-qa-20261024` | 9eb4fd55733bb49bbb069240b8e332d37d22aced; `map_battle_v2.gd` blob d647fc4c2d28cb27360dc7e7c84a9ab668df1eca | `setup(...,keep_encounter_open=true)` bật `continuous_mode`; `now>=MAX_SECONDS and not continuous_mode`, `add_continuous_monster`, `remove_downed_monster`, `pending_kill_events`, `acknowledge_kill_event`; giới hạn batch 20.000 steps là **budget mỗi call**, không phải thế giới tự kết thúc. | **Gameplay candidate / draft chưa merge**. Not main |
| **PR #31 test** | `godot/tests/simulation/b3_fasttrack_hunt_test.gd` | Assert `battle.now==120.0 and battle.active`, same world >90s, real kills/generation/warehouse | Có test thật trên nhánh PR; evidence tích hợp 28/28 focused tại code SHA 4b02a0c61a2771d9d4638129d96b68ad292270dc; không tự suy ra Android |
| **PR #31 test** | `godot/tests/simulation/b3_ph0_continuous_kernel_test.gd` | Vừa test world >90s, vừa cố tình test finite 90s regression | **Cảnh báo**: xóa MAX_SECONDS đơn lẻ phá historical finite tests; phải quyết định retire legacy cùng mọi caller/tests |

Chênh SHA: `4b02a0c...` → `9eb4fd...` chỉ có docs/evidence bổ sung, không có code changes; mã gameplay vẫn SHA 4b02a0c. README/log của packet B ghi 28/28 focused PASS, 56 checks S1; hiện chưa có FULL/CI hoặc Human Windows/Android. PR #28/#29/#31 vẫn OPEN/DRAFT tại thời điểm kiểm tra.

## 2. OWNER INTENT — CÁC LUẬT MỚI ĐƯỢC ƯU TIÊN
- Săn quái chính là **world/session continuous**, không có trận hết 90s; người chơi hoặc AI có thể rút an toàn. Cùng một vùng, quái tái xuất theo generation, đôi lúc Elite/Boss theo content author; không yêu cầu clear toàn bộ wave để nhận loot.
- **Mỗi quái chết thật** chỉ một kill event, một entitlement Sect Warehouse; cùng một thế hệ/slot không được trả thưởng hai lần; respawn đời mới chỉ khi đúng tick/settlement.
- Giữ **CombatStatsV2 / Combat V2** làm công thức damage/stat/HP/injury; Combat V3-S1 chỉ mở runtime effects/cadence theo mô hình này; đừng đổi cơ chế sang JX, đừng invent combat_power, đừng auto thưởng nếu quái chưa chết.
- **One Active Job, canonical tick / save, Injury0/1 +120 tick**; autoskill, learned skills, gear/build và rút lui không phải phần thưởng ảo.
- R11 S1/S2 cần normal Vân Giác Lộc ở world thực, player gear R10 thu node thật; *không* coi `HuntingPveRunV2` finite-`claim_reward` như nguồn vật tư World mới.
- Giới hạn sự kiện/render budget, backpressure kill journal, số actor active là **safety budget**, không phải thời gian kết thúc thế giới. Không được xóa backpressure để có cảm giác “vô hạn”.

## 3. DANH SÁCH LỖI THỜI: XÓA / DEPRECATE / GIỮ
| Thành phần | Phân loại | Hành động chính xác, nếu code packet được cấp phép |
|---|---|---|
| `MapBattleV2.MAX_SECONDS=90` khi áp dụng cho **world** | **OBSOLETE** | Tuyệt đối không dùng trong continuous mode (PR31 đã bypass). Sau khi đo các call sites, có thể tách `LegacyFiniteBattle` hoặc xóa timeout khỏi toàn hệ khi finite mode hết người dùng; yêu cầu regression. Không xóa hằng số đứng một mình. |
| `MapBattleV2.ARENA=36×20` như toàn bộ world map | **OBSOLETE WORLD ASSUMPTION** | World/region layout/navigation cần owner riêng; 36×20 hiện vẫn là local combat coordinates/render cap. Không lén gọi arena nhỏ là bản đồ R11 lớn. |
| `HuntingPveRunV2.finish/claim_reward` để trả R11 mỗi quái | **NOT APPLICABLE** | Đóng băng làm finite legacy bridge, dừng làm nguồn mới; tương lai sau cutover mới retire, không payout cả per-kill và encounter. |
| `HuntingMapV2.LEVELS[].rare` để suy ra q common hide | **OBSOLETE ASSUMPTION** | Bỏ hoàn toàn cách suy diễn. Rare encounter ≠ vật liệu common Vân Giác Lộc. |
| “Giết đủ wave → payout cuối trận → đổi cảnh → tiếp” như luật World | **DEPRECATED** | Thay bằng life spawn/kill receipt và continuous farm; mọi docs R11 chỉ dùng per-life. |
| Tỷ lệ “sống sót 90s” làm KPI R10→R11 | **DELETE FROM NEW R11 DESIGN** | Thay TTK từng kill, HP/injury qua nhiều kills, time-to-recovery, voluntary retreat, path to node; legacy 90 chỉ làm provenance. |
| `MAX_CONTINUOUS_BATCH_STEPS=20000`, `MAX_PENDING_KILLS=256`, `MAX_REMEMBERED_SPAWN_SLOTS=1024` | **KEEP SAFETY MECHANISM** | Không xóa chỉ vì có chữ MAX; cần kiểm tra backpressure khi >1k agents / dài hạn. |
| `b3_ph0_continuous_kernel_test.gd` có finite test 90 | **KEEP UNTIL RETIRE FINITE CALLERS** | Đang test tương thích cũ, việc nó tồn tại không chứng tỏ World hết hạn 90s. Sau cắt finite mode mới sửa/xóa testcase theo bằng chứng. |
| `CombatStatsV2.resolve_direct_hit`, `DiscipleCombatLoadoutV2` | **KEEP LOCKED AUTHORITY** | Chỉ thay implementation nếu có riêng owner CODE authorization. |
| 3 docs R11 S1/S2 prior | **KEEP; DESIGN PROVENANCE** | Source registry, softlock, warehouse-receipt 36 fixtures không lỗi thời vì 90s; điều chỉnh mô hình R11 theo world continuous. |
| Previous screenshots / QA logs / old branch reports | **ARCHIVE, DO NOT DELETE PROOF** | Gắn nhãn historical; không xóa bằng chứng QA hay source provenance chỉ vì cũ. |

## 4. RỦI RO ĐANG TỒN TẠI: KHÔNG NHẦM “BỎ 90” VỚI “SĂN QUÁI LIÊN TỤC HOÀN CHỈNH”
1. PR31 đã có 120s test, same-world spawn, real kill/loot/save roundtrip trong Packet B; **không bị timeout 90** trong đường B3 world. Trạng thái PR31 vẫn draft và chưa merge main; ai build main sẽ nhìn code cũ.
2. `HuntingPveRunV2` legacy vẫn kết toán whole encounter và `timeout_retreat`; không được import vào vật liệu R11 per-life. Phải xác định một owner payout thống nhất theo reward class.
3. Vân Giác Lộc, Ore/Fiber node, R11 border geography, nav graph, R10 old-gear fixture chưa có runtime. “Continuous kernel PASS” không bằng “R11 S1/S2 PASS”.
4. `MapBattleV2` continuous hiện dùng tọa độ arena36×20 cho actor cục bộ; không tự chứng minh 192×192 world map collision, room-to-room path, offscreen life persistence.
5. Cần gate trường hợp kill events lớn hơn ring capacity, 100 load/save, batch catch-up, backup/corruption, 30–300 roster without 300 sprites, 7/30 ngày không tự sinh drops từ timer.
6. `MAX_CONTINUOUS_BATCH_STEPS` là mỗi lần `run()` giới hạn 20.000 bước, không phải 20.000 bước rồi tự `timeout_retreat`; caller phải tiếp tục qua snapshot + next tick đúng state.
7. Tài liệu kiểm toán này KHÔNG tự áp dụng thay đổi lên PR28/PR29/PR31. Không biến mô phỏng số học thành official Godot pass.

## 5. DEPRECATION GATES — PHẢI ĐÁP ỨNG TRƯỚC KHI XÓA CODE OLD FINITE
**Gate A / Caller inventory:** liệt kê toàn bộ call sites dùng `MapBattleV2.setup(...,false)`, `run/finish`, `timeout_retreat`, `claim_reward`, `HuntingMapV2` và UI còn gọi finite. Chỉ xóa source khi mọi caller đã được chuyển hoặc chọn rõ historical-only, không xóa test để tạo PASS giả.

**Gate B / Continuous canonical end-to-end:** người R10 thật → world admission → spawn normal → actual Combat V2 hit/status → one HP0 kill → one Warehouse credit → one generation increment/respan đúng clock → repeated >90s, >3600s, save/reload, offscreen/camera view parity, 3 normal kills → retreat/recovery. No timeout. Có bảo vệ runaway catch-up; không idle rewards.

**Gate C / Contract and rollback:** 100 repeated save/load, staged write power-cut fault, NO_DROP, duplicate receipt, XP/job/time/injury, baseline legacy-specific tests được migrate/reclassified có lý do; không đổi CombatStatsV2; human QA và device QA nếu gate release yêu cầu.

**Gate D / Retire old code:** xóa các class/constant/finite test chỉ khi Gate A–C PASS, cùng CODE packet allowlist và chiến lược thay thế, không xóa ở nhánh docs. Nếu finite mode vẫn là P2/V2 historical test harness dùng để so sánh, đánh dấu `@legacy_bounded` rõ ràng thay vì lén xóa.

## 6. DOCUMENTATION CLEANUP THỰC HIỆN TRONG NHÁNH NÀY
- Đối chiếu main và PR31, đổi framing R11: **không áp 90s**, không dùng final encounter/wave claim để tính nguồn Bì R11.
- Bảng Combat R10 analytical là **single kill damage calibration**, KHÔNG là trận 90 giây hay xác suất thắng. Acceptance thay bằng continuous HP/injury over multiple kills/retreat; không tự giả world 36×20.
- Bộ sizing quặng/mộc/Lộc Bì vẫn chỉ là envelope và cần physical source+pending receipts.
- Bất kỳ báo cáo cũ nào nói “Combat World vẫn giới hạn 90s” phải được chú giải `SUPERSEDED FOR CONTINUOUS WORLD BY PR31` thay vì xóa provenance.
- **Status**: Docs correction CHECKED; CODE DELETION NOT PERFORMED; PR31 STILL DRAFT/UNMERGED; R11 runtime still BLOCKED.

**Kết luận**: **90 giây đã lỗi thời trong luật săn quái liên tục, nhưng vẫn tồn tại hợp lệ trong nhánh finite legacy.** Việc xóa đúng là cắt sự phụ thuộc của World vào finite encounter rồi retire có kiểm thử. Không phá code live và test chứng minh quyền lợi tài nguyên.
