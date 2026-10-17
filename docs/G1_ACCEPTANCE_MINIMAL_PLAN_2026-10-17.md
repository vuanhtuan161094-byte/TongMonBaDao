# G1 ACCEPTANCE — Kế hoạch nghiệm thu gọn (17/10/2026)

**Repo:** `vuanhtuan161094-byte/TongMonBaDao` — draft PR **#20** `g1-disciple-radar-sourcea-pool-20261017` stacked on PR #19. **Engine:** Godot **4.7.2 official**, Android-target landscape **1280×720**.

**Mục tiêu:** Chốt một lần trải nghiệm chơi cho **G1.5–G1.8** sau các lượt code UI. Không mở rộng chức năng, không chạy FULL/CI/600-frame benchmark, không merge hoặc thay đổi gameplay. Chỉ nghiệm thu UX/interaction và giữ đúng authority backend.

## Phạm vi & ưu tiên

- **P0 — Không được sai:** Mở đúng instance ID Mỏ/Linh Lâm/Linh Điền từ bảng Điều hành; phân công/đổi người không xuyên One Active Job; Start chỉ gửi lệnh hợp lệ; timer/plot/quantity/kho từ BuildingSystem + Workforce + Scheduler + Warehouse; mở bảng không thay đổi SimulationState hoặc kích hoạt migration Linh Điền.
- **P1 — Dễ chơi:** `Điều hành → Bảng sản xuất → Cần xử lý → Xử lý`, chọn đúng công trình, chọn/đổi đệ tử, Bắt đầu/Gieo ô tiếp, lý do khi khóa; HUD và panel 1280×720 không chồng/che hành động. Không báo mẻ đã hoàn thành khi scheduler chưa kết toán.
- **P2 — Hình ảnh:** Hai rig nam `body_1120402` / `body_1110201`, rig nữ `1113028_1`; đồng bộ map/roster/hồ sơ, chân chạm đất, tỷ lệ, click target; không giả nguồn Source A.

## Quy trình duy nhất — chỉ khi sẵn sàng nghiệm thu

1. Chạy `Run-G1-Acceptance-Windows.cmd` từ ZIP đính kèm hoặc từ repo. Launcher dùng `-Acceptance -Play`, clone HEAD mới nhất của draft PR #20 sang TEMP riêng, cách ly APPDATA/save, kiểm phiên bản Godot official 4.7.2, import project.
2. **Bốn test tập trung**, không thêm test khác:
   - `sect_g1_disciple_radar_test.gd`: radar, hồ sơ V2, hai giới Source A, hủy lệnh chờ;
   - `sect_source_a_actor_pilot_test.gd`: scene thật, actor nam/nữ, idle/walk/mirror, scale;
   - `gui_workforce_v1_e2e_test.gd`: Mỏ/Linh Lâm/Linh Điền, timer/plot/receipt/save/offline;
   - `gui_multiple_resource_instances_test.gd`: instance #2, bảng sản xuất, bộ lọc Cần xử lý, bất biến read-only, đúng ID.
3. Chỉ khi 4 test PASS, tự mở game với save tạm 1280×720. Người chơi thử trong **5–10 phút**: (a) mở Điều hành > bảng sản xuất > lọc Cần xử lý, (b) mở đúng Mỏ và chọn người, (c) Bắt đầu, xem tiến độ thật và lý do khi bận, (d) thử Linh Lâm/Linh Điền và `Gieo ô tiếp`, (e) mở hồ sơ nam/nữ, quay lại công trình. Đóng game để xuất ZIP logs.
4. Nếu **FAIL**: gửi **một ZIP trong Downloads**. Chỉ sửa lỗi được log/ảnh xác minh, chạy lại focused case lỗi, không mở QA FULL. Nếu chỉ UI xấu/tràn màn, gửi 1–3 ảnh hoặc video ngắn.
5. Nếu 4 test PASS và chủ dự án chấp nhận thao tác/ảnh: ghi `G1 focused Windows PASS` + `G1 visual owner ACCEPTED`; **không tự suy ra Android PASS**. Sau đó mới lập packet **G2 playable core loop** riêng; không merge PR #20 khi chưa quyết định tích hợp stacked PR.

## Điều kiện dừng / chuyển giai đoạn

- **Blocker phải sửa:** sai instance ID, panel click không làm được, chạm nhầm khi đang mẻ, sinh/nhân đôi sản lượng, biến động state chỉ từ việc xem, parser/runtime lỗi.
- **Không tự mở rộng QA:** không benchmark, không 600 frame, không CI, không FULL P3.7, không kiểm thử APK ở lượt này.
- **Trạng thái tại thời điểm lập kế hoạch:** code G1.5–G1.8 đã commit, source-only static checks có kết quả; Godot 4.7.2 runtime trên *HEAD hiện tại* **PENDING**. Male Source A import đã có focused Windows PASS ở commit cũ, không thay cho acceptance mới.

**Quyền và giới hạn:** một Warehouse, một scheduler, một active job, 30×10 Tu Vi/Luyện Thể, Injury 0/1/120, Economy V2, save exactly-once giữ nguyên. Windows game/save gốc phải được bảo vệ.
