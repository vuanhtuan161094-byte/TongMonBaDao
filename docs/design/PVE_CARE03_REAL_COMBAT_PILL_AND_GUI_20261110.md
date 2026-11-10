# PVE-CARE03 — Hồi Nguyên Đan trong PvE và Điều Trị trọng thương trên One Game

Ngày 10/11/2026 — Release train PR #72, branch `integration/pve-p0-playable-ui-20261103`.

## Phạm vi code đã thực hiện

1. `PveCombatAutoPillV1`: chạy với `MapBattleV2` ở hai runtime P0 (`HuntingPveRunV2._advance_open_world` / `_advance_multicamp`) và B3 (`B3HuntWorld.advance_frame`). Kiểm tra mỗi combat frame **chỉ với disciple đang sống/đã đăng ký**, HP ≤ **80%** battle HP; nguồn thuốc từ `WarehouseSystem` thật và `MedicineCatalogueV2` đúng cảnh giới; chọn phẩm chất hiệu quả nhất giảm lãng phí, thuốc không đủ hiệu quả 2% HP không được tự dùng. Giới hạn **mỗi đệ tử một viên/5 giây chiến đấu** tại `MapBattleV2` actor key `pve_care03_next_pill_at`.
2. Trừ một viên ở Kho, cộng HP ngay vào battle actor, ghi đúng một `b3_pill_state` receipt (sequence, medicine version/potency, injury unchanged) & shared daily meter; không tăng Tu Vi/Luyện Thể giả, không thêm rớt thuốc giả, không đụng SaveService. Sau đó `MapBattleSnapshotV2` và cùng nút lưu/clock owner lưu thống nhất Kho + receipt + combat HP/timer. B3 cập nhật HP nhân vật với HP combat sau frame. P0 vẫn coi combat snapshot là authority cho HP trong lúc đang săn. Timer khi load được preflight không âm/NaN/vượt giới hạn.
3. `PveInjuryTreatmentV1.quote/start` giờ sẵn sàng cho **V2 Economy-A** ngay cả khi rewards thử nghiệm `pve_r12_reward_pilot=false`. Ở Tông Môn, trọng thương Injury1 được trả phí r1 **1.500 LT** / r2 **3.000 LT**, phục hồi sau đúng **30 simulation ticks**, **không tăng HP**. Một receipt `injury-treatment:<request_id>`, chỉ số active `injury-active:<disciple_id>`; không nhân đôi tiền, vẫn có tự khỏi 120 ticks miễn phí nếu không thanh toán.
4. Màn hình duy nhất `p3_2_landscape_sect.gd` bổ sung nút `SectInjuryTreatmentAction` trong tab **Tổng Quan** của hồ sơ V2, có báo giá/thời gian, kiểm tra số tiền, tình trạng vừa điều trị, phản hồi và `LiveGameRuntimeV2.save()`. Không tạo form hồ sơ khác biệt giữa 6 đệ tử cũ và đệ tử chiêu mộ. Đệ tử không thương vẫn nhìn thấy nút Đột Phá Tu Vi như trước.
5. `EconomySystem.buy_personal_hp_service` **từ chối đối với V2 thật** (`hp_service_replaced_by_injury_care_and_pills`); auto HP-for-LT cũng tắt cho V2, còn đối với P2 legacy giữ nguyên để bảo vệ Save. Các lệnh `WorkforceSystem` gán nhóm/công trình, chỉ thị nghề và `perform_work` được chặn trong **30 ticks đã trả phí**. 1.000 Tu Vi/phút vẫn được Scheduler cộng, không làm đình trệ Tu Vi thụ động.

## Các kiểm thử

- `godot/tests/simulation/pve_care03_combat_pill_save_test.gd`: New Game → chiêu mộ V2 → một trận P0 thật; nguồn thuốc được cấp trong fixture QA và được chứng minh trừ **Kho thật**, không tuyên bố có rớt từ quái. Kiểm tra đúng 1 thuốc, receipt, 5s cooldown và nạp cold Save cả HP/timer; sau đó cùng vòng giao dịch trên B3 thật. Marker `PVE_CARE03_BOTH_REAL_PVE_PILL_WAREHOUSE_RECEIPT_COOLDOWN_SAVE_PASS`.
- `godot/tests/presentation/pve_care03_injury_clinic_ui_test.gd`: mở scene One Game ở 1280×720, chiêu mộ V2, đặt **QA fixture Injury1 và 2.000 LT cá nhân**, gọi nút GUI, xác minh còn 500 LT, +1500 Quỹ Sect, due_tick+30, HP giữ nguyên, nút vô hiệu hóa lần hai và cold Save chính xác; kiểm tra không phân công/vận hành nghề trong thời gian điều trị. Marker `PVE_CARE03_GUI_REAL_INJURY_CLINIC_1500LT_30TICKS_SAVE_PASS`.
- `godot/tests/simulation/economy_a_playable_test.gd` cập nhật hợp đồng **V2 không còn mua HP bằng tiền**, không làm mềm bảo vệ nghiệp vụ khác, tiếp tục hồi quy công việc, Phường Thị, quỹ và Save.
- Official Godot **4.7.2** chạy bằng GitHub Actions `.github/workflows/pve-p0-free-hunt.yml` và Economy-A. Bài test P0+B3 và GUI đã có step-level SUCCESS ở [run #42848759696](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42848759696) tại SHA `8350608c` (cần kiểm tra kết luận whole + các commit mới trước khi tuyên bố FULL PASS). Run [#42848603539](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42848603539) bị FAILURE vì file GUI test mới chưa hiện diện ở snapshot cũ dù **combat pill step PASS**; không sử dụng như QA tổng. Các phiên kiểm tra sau cùng của `MapBattleSnapshotV2` cooldown guard, Workforce time-reservation và cumulative phải được kết luận theo **exact SHA**.
- Windows PC E: và thiết bị Android thực: **PENDING USER**, không gọi headless hay giả lập là nghiệm thu máy thật.

## Các giới hạn chưa mở rộng

- Phần thưởng LT r1–r2 trong `PveR12BalanceV1` giữ `pve_r12_reward_pilot=false` và 111 công thức r3+ chưa có source vẫn HOLD. Không mở item giả.
- 20 bãi Thanh Trúc Lâm, 200 slot quái, tối đa 40 quái hoạt động và 30 PvE hunter **không đổi**, không mở map chưa có địa hình thật.
- Cần đo combat thật HP damage, kill/h, Đan/giờ, tỉ lệ tử trận, FPS/CPU/RAM để cân bằng PvE với sản xuất. Run scripted QA cố ý tạo wound fixture không tương đương thống kê tự nhiên. Không dùng giá shadow 2 viên/h giả định như kết quả đo.
- Bản B3 vẫn có công cụ sử dụng thuốc và REST cho các Save/P2 cũ, nhưng đệ tử V2 tự uống thuốc khi săn nay sử dụng lệnh riêng; không tự cấp thuốc.
