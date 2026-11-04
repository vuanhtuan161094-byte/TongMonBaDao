# TÔNG MÔN BÁ ĐẠO — ONE GAME RELEASE TRAIN (canonical, 2026-11-04)

> **Nơi tra cứu trạng thái mới nhất:** [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) (release checklist R0–R5); [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72) (mã nguồn ứng viên tích hợp). Trước mọi thao tác phải fetch live HEAD. Tệp này là ảnh chụp trạng thái tại 2026-11-04, **không thay thế log/source mới**.

## 1. Một mã nguồn, một điểm vào, một đích merge

- **Ứng viên GAME duy nhất:** PR #72 / `integration/pve-p0-playable-ui-20261103`, HEAD trước tài liệu-cleanup `e888c010d6cfb09a97ce48af19d1a2f42a401240` (code tested `e92ef09fc2c9b2ccb870910577b295881ccc6527`). Các commit tiếp theo có thể chỉ là tài liệu; lấy HEAD mới nhất trước khi làm.
- **PR #67** là nhánh base hiện tại của #72, không merge riêng và không đóng/đổi base tùy tiện.
- **`main`** là đích phát hành cuối cùng, hiện chưa có PR #72. `main` có commit riêng ở `AGENTS.md` chưa nằm trong #72; phải hòa giải trước R5.
- **Không tạo RC/game độc lập mới**, không mở thêm PR cho từng lỗi; chỉ một người chỉnh shared gameplay P3.2/Save/Combat; không blind cherry-pick hoặc reset/clean E.
- **Windows workspace owner:** `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao`. Chưa kiểm chứng đã sao lưu khoảng 196 dirty/untracked local và save; **R0 chưa PASS**. Một launcher duy nhất phải được chọn, sửa và xác minh thực tế (`CHOI-GAME.cmd` / `MO_GAME.cmd` trong những ghi chép cũ); không giả định tên hoặc shortcut cũ hợp lệ.

## 2. Kết quả QA đã có và giới hạn

- Godot 4.7.2 official, source SHA `e92ef09fc2c9b2ccb870910577b295881ccc6527`: import và 14 focused tests **15/15 dòng exit 0**, theo [evidence matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/e888c010d6cfb09a97ce48af19d1a2f42a401240/godot/outputs/qa_evidence/e92ef09_20261104/QA_MATRIX.csv).
- 20 camp, tối đa 30 hunters, 40 quái hoạt động / 200 spawn slots PASS theo `PVE_P0_30_HUNTERS_PASS checks=31`; tập natural solo PASS 10 kills/10 receipts, Tu Vi + Luyện Thể + vật phẩm và cold reload/gen2.
- **PLAYABLE WINDOWS CHƯA PASS:** launcher một lần mở, lần tiếp theo crash `signal 11` trong Intel `ig11icd64.dll` khởi tạo GLES3, một Godot PID bị Windows từ chối query/kill. Thao tác chuột vật lý, vòng New Game→SX→PvE→loot→save/reload trên cùng save, Windows 3 clean starts và Android/touch **chưa xác nhận**. Không gọi harness screenshot là mouse acceptance.
- `main` **chưa merge**; không gắn release tag hay khẳng định toàn bộ game hoàn chỉnh.

## 3. PR backlog và cách đọc đúng

Đã giảm **61 PR đang mở → 18** (đợt dọn 2026-11-04); 43 PR đóng hành chính, **không xóa branch/commits và không merge main**.

### 43 PR đã đóng

- **18 PR là tổ tiên trong lịch sử commit của #72 (đã có commit, không đồng nghĩa mọi GUI đã PASS):** #24 #25 #26 #27 #28 #31 #32 #33 #38 #39 #51 #52 #57 #58 #60 #62 #63 #65.
- **7 PR design/lab/historical không được coi là production code đã tích hợp:** #3 #4 #5 #11 #21 #35 #40. Code và lịch sử được giữ lại trên branch.
- **9 PR archive đợt hai (không khẳng định đã được port vào #72):** #34 (preview bãi săn), #44/#45/#48/#50 (VFX/Save/QA diagnostics), #49 (hướng dẫn hai Codex cũ), #59 (G0 historical evidence), #68/#69 (tiền thân labs AN; #71/#74 kế thừa). **Quan trọng:** R1/R4 phải đối chiếu các testcase và manifest hữu dụng từ #44/#45/#48/#50, không xóa các test do PR đóng.
- **3 PR archive bổ sung:** #13 (LAY-01 chỉ tài liệu thiết kế theo diff PR), #53 (handoff V6.3/Source-A-VFX theo diff PR, lưu tài liệu để R1 tra cứu), #55 (công cụ JX VFX/gallery độc lập chưa duyệt dùng trong game). Branch và code vẫn lưu giữ, không coi là đã tích hợp chức năng.
- **6 PR đóng sau đối chiếu API/test với PR #72:** #29/#30 Combat S1, #46/#47 PvE movement/formation, #61 SX01 JSON, #64 Hall/Residence. Đã ghi căn cứ và nhánh cũ giữ lại; #46 có test diagnostic riêng chưa port, phải xét ở R4. Xem [ma trận chi tiết](TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md).

### 18 PR vẫn mở tại checkpoint

- **Release candidate:** #72.
- **Dependency/base:** #67. Giữ đến khi PR #72 retarget `main` một cách an toàn.
- **14 PR chức năng chưa kết luận parity / còn yêu cầu tích hợp:** #2 #6 #7 #8 #9 #10 #12 #14 #16 #17 #18 #19 #20 #66. Xem [ma trận 20 PR](TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md).
  - Cụm workforce/economy/map #2/#6–#20 (riêng #13 đã archive design PR) có lịch sử khác PR #72, có thể đã bị superseded chức năng nhưng **chưa chứng minh**.
  - Combat/PvE QA cũ #29/#30/#46/#47 đã đóng sau khi xác nhận code/test parity; riêng diagnostic clock/save từ #46 vẫn là R4 QA debt. Các branch QA khác #34/#44/#45/#48/#50 cũng còn dù PR đã archive.
  - #61 SX01 JSON và #64 Hall/Residence đã chứng minh API/source/test parity, đóng hành chính (không merge); **#66 B1 UI vẫn mở do radar Tam Căn/Tứ Tính trên source #72 đang vẽ sáu chỉ số**. #13/#53/#55/#59 đã archive, tài liệu/tool/evidence còn để tra cứu.
- **Animation/asset labs còn mở (không phải production):** #71 #74. Hai nhánh gốc #68/#69 đã đóng PR nhưng được giữ làm ancestor/nguồn tham khảo. Không tự thay thế Source A renderer trong game; cần Owner Visual PASS + Godot QA.

**Quy tắc dọn:** `CLOSED_UNMERGED_SUPERSEDED` không có nghĩa `MERGED_TO_MAIN`, cũng không có nghĩa `CODE_LOST`; giữ nhánh và commit. Chỉ đóng PR đang hoạt động khi có lý do và bất kỳ chức năng chưa port được ghi thành debt trong Issue #56.

## 4. Chuỗi công việc — chạy theo thứ tự, không phân tán

- [ ] **R0 / bảo toàn:** sao lưu E dirty + save + SHA256/manifest; inventory và quyết định 30 PR phần còn lại; xác minh HEAD và file owners.
- [ ] **R1 / hợp nhất game:** forward-port đúng phần đã được duyệt nhưng chưa có từ PR khác vào **chỉ #72**; preserve One Active Job, Injury 0/1/120 ticks, SaveService, Warehouse, 27 Tông Môn ranks, PvE 20×30; giữ đúng nhãn **Tam Căn / Tứ Tính** theo quyết định Owner, đối chiếu authority trước khi sửa thuộc tính.
- [ ] **R2 / launcher Windows:** xử lý crash GLES3/Intel an toàn, 3 clean starts, xác nhận một launcher đúng checkout và fingerprint.
- [ ] **R3 / cùng một save:** New Game → xây Đệ Tử Xá → tuyển → Mỏ/Kho → 1–30 thợ săn + 20 vùng → kill receipt → Tu Vi/Luyện Thể/loot → Save/Exit/Reload → tiếp tục chơi.
- [ ] **R4 / QA:** official Godot 4.7.2, full/focused regression SX/PvE/Boss/Save/injury và GUI mouse thật 1280×720. Android nếu có môi trường/thiết bị kiểm chứng, không giả PASS.
- [ ] **R5 / release:** retarget PR #72 vào `main` sau khi hòa giải commit riêng và PASS gates; merge 1 lần, chạy post-merge SHA, release tag, đồng bộ launcher E an toàn, đóng PR cũ có lý do.

## 5. Chỉ dẫn đọc tài liệu

- **Trạng thái:** Issue #56 (live) → PR #72 + log exact-SHA → tệp này → code thực.
- **Thiết kế:** `docs/GAME_SYSTEM_ARCHITECTURE.md` và subsystem specs, tách `LOCKED/DESIGN/IMPLEMENTED/QA`.
- **Lịch sử không còn là lệnh thực thi:** [archived CURRENT_CHECKPOINT](../archive/checkpoints/CURRENT_CHECKPOINT_LEGACY_PRE_RELEASE_TRAIN_20261104.md), [archived NEXT_CHAT_HANDOFF](../archive/checkpoints/NEXT_CHAT_HANDOFF_LEGACY_PRE_RELEASE_TRAIN_20261104.md). Không hành động theo hướng dẫn cũ về #52, #67, #79dab92, `LOOT_PENDING`, Sync-Main... nếu trái với Issue #56 và source HEAD.
- Báo PASS/FAIL/BLOCKED phải có SHA + log + gate và phân biệt headless/harness/physical GUI/Android.

**Đích cuối:** một `main` đã thử trên exact SHA, một bản game thật mở từ launcher, không còn PR production mồ côi. Đóng PR dọn backlog không làm thay đổi tình trạng release.
