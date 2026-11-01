# CODEX EXECUTION PROMPT — TRI-01 / ĐẠI ĐIỆN × ĐỆ TỬ XÁ × DẪN TIÊN ĐÀI

**Owner-approved scope: finish integration and repair actual defects in the three existing systems; no redesign, no new systems.**
**Status before Codex starts: ARCHITECTURE FROZEN / NOT ACCEPTED / DOCS-ONLY HANDOFF.**
**No Codex work has been run by the ChatGPT author of this handoff.**

Copy everything below this line into Codex (or provide this GitHub file path as the exact work contract):

---

Bạn là Codex, kỹ sư tích hợp Godot 4.7.2 cho dự án TÔNG MÔN BÁ ĐẠO. Thực thi trực tiếp công việc CODE + QA trên repository vuanhtuan161094-byte/TongMonBaDao, KHÔNG hỏi lại phạm vi đã khóa ở đây. Báo bằng chứng thực, không tuyên bố PASS từ việc đọc source.

## 0. SOURCE OF TRUTH — đọc trước khi sửa

1. Đọc AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md trên checkout/branch đúng SHA. Đọc toàn bộ docs/handoffs/2026-11-01/TMB_TRI_FACILITY_FROZEN_ARCHITECTURE_CODEX_HANDOFF.md và các tài liệu DD/DT đã liên kết.
2. Fetch GitHub, xác minh **live HEAD tại thời điểm bắt đầu**; không tin rằng SHA dưới đây còn mới nhất. Nếu HEAD đổi, ghi cụ thể SHA mới, phạm vi thay đổi và cập nhật phép so sánh trước khi code.
3. Các SHA đã đối chiếu khi lập handoff:
   - MAIN c0c1382f119599497b52d8ee8abd9e830a883f1e — KHÔNG SỬA.
   - ONE GAME RC gốc hợp nhất: rc/one-game-playable-20261101 tại 970af33b23076c80d677cf5898a721a27504708f — MỐC LẤY LÀM NỀN.
   - PR #64 feature/dai-dien-v2-live-p0-20261101 tại bf3ed0310899c554eea4e6b2e1967dcada2d68dd — nguồn thay đổi Đại Điện/Đệ Tử Xá, Draft, CHƯA TEST GODOT 4.7.2.
   - PR #60 feature/dan-tien-c2-ui-p0-20261101 tại 074ca829d2d35a559c445edba17c5e1f9d1dc937 — đã là tổ tiên của RC, KHÔNG MERGE LẠI.
   - Nền RC cũ integration/one-game-v65-20261030 tại 199f888c7fd690830728dfbf29b6b79276e3b283; KHÔNG chọn nhánh cũ này thay RC mới.
4. Tạo nhánh tích hợp MỚI từ live RC HEAD, thí dụ integration/tri-facility-qa-20261101 (nếu tên đã tồn tại, chọn hậu tố mới). KHÔNG sửa main, PR #60, PR #64, PR #52, không cherry-pick nguyên 125 commit mà không review. Không nhập bất kỳ source/asset chưa được phê duyệt nào.

## 1. KHÓA CƠ CHẾ — KHÔNG TỰ THIẾT KẾ LẠI

A. Đại Điện V2: đúng một main_hall_001, Hall Lv1–100, 7 chức vụ (Chưởng Môn, Tiếp Dẫn, Truyền Công, Nội Vụ, Hộ Pháp, Đan Đạo, Giới Luật), một chức vụ chính/đệ tử, bổ nhiệm/cách chức có kiểm tra bận, trạng thái thương tích, PvE và One Active Job; tinh thông chức vụ Lv1–10 và buff đúng nơi có consumer thật. 27 bậc gồm Nhân 1–9, Tiên 1–9, Thần 1–9; gates Đại Điện, nhân lực, cảnh giới, sản xuất, Uy Danh, vật tư; Boss không bắt buộc. Các mốc Nhân ~3 tháng, vào Thần ~12 tháng, hoàn thiện Thần ~24 tháng không nạp chỉ là MỤC TIÊU chưa chứng minh; công thức giá, thời gian, chỉ tiêu nhân lực hiện tại là PROVISIONAL, **KHÔNG TỰ SỬA CÂN BẰNG**.
B. Đệ Tử Xá V2: nhà starter residence_001 không xây lại; tối đa 10 nhà, Lv1–100 mỗi nhà; nhà mua thêm có thời gian xây bằng simulation tick, trả giá và lưu receipt exactly-once; đang xây không có giường/phòng/buff, hoàn thành mới có; giường, phân phòng và giới hạn tuyển theo authority thật. Lô nhà mua thêm chọn qua ResidencePlotSelector trong tập 12 vị trí dự kiến; footprint 3×3, kiểm tra ô cửa bên ngoài, chồng lấn và vùng đất mở; lưu tọa độ versioned site_x/site_y trong chính BuildingState. **Không đòi đường nối, không thêm network đường, không đi vào nội thất.** Đệ tử chỉ chạy đến ô cửa công trình rồi công việc do simulation xử lý. PvE navigation là hệ riêng, không được chạm.
C. Dẫn Tiên Đài V2: giữ flow New Game -> danh sách ứng viên -> hồ sơ D7 đầy đủ -> nhận/từ chối có xác nhận -> roster; chính/phụ Tiếp Dẫn và khóa đệ tử đang bận; odds/Chiêu Mộ Lệnh/định mức và candidate cap 30 như hiện hành tạm thời, KHÔNG tự đổi odds hoặc invent pity. Dẫn Tiên Lv1 là starter building; **chưa có gameplay người chơi tự mua/xây Dẫn Tiên**, không giả lập tính năng ấy. Thực hiện chống debit lặp, candidate identity V2 deterministic và Save/Load.
D. UI Godot native, LANDSCAPE 1280×720, Source A đúng nguồn. Single SimulationState/SaveService/Warehouse/scheduler, injury 0/1 +120 tick, one active job, P2 saves không bị hỏng. Không tự sửa gameplay PvE, kỹ năng, SX01/02, đan dược, kinh tế ngoại vi, không mở gameplay mới, không tạo asset AI. **BỎ giám sát hiệu năng liên tục/telemetry/FPS logger; chỉ chạy tối thiểu QA bắt buộc**, không thêm overhead máy 8 GB RAM.

## 2. TÁCH NHÁNH / HÒA GIẢI XUNG ĐỘT BẮT BUỘC

1. Trên source, chạy:
       git merge-base rc/one-game-playable-20261101 feature/dai-dien-v2-live-p0-20261101
       git diff --name-status rc/one-game-playable-20261101...feature/dai-dien-v2-live-p0-20261101
       git diff rc/one-game-playable-20261101...feature/dai-dien-v2-live-p0-20261101 -- godot/src/presentation/p3_2_landscape_sect.gd godot/src/simulation/recruitment/recruitment_system.gd godot/src/simulation/building/building_system.gd godot/src/simulation/core/live_game_runtime_v2.gd godot/src/simulation/state/sect_state.gd
   Dấu ba chấm là diff từ merge-base; phải so cả **RC-only commit** để không ghi đè bản đã được sửa sau đó.
2. RC commit 970af33 bổ sung live Dẫn Tiên UI, CandidateDecisionActions, _detail_actions/_detail_action_hint, test cập nhật, QA Windows và screenshot. PR #64 được tạo trước commit đó, nên chưa mang sửa đổi này. Tuyệt đối không thay toàn bộ godot/src/presentation/dan_tien_screen_v2.gd bằng bản cũ từ #64/#60. Đối chiếu blob ở thời điểm đóng gói: RC da96d25ffd1db486fa2f9b430af465fd46e7d0dc khác PR #64 d86824e13efe314f69e94df708e0c9398c6df888.
3. Bảo toàn các bản UI Dẫn Tiên RC và các test: dan_tien_rc_live_acceptance.gd, dan_tien_rc_reload_verify.gd, dan_tien_c2_smoke.gd, p3_o2_recruitment_map_test.gd, evidence docs/qa/dan_tien_rc_20261101/; kiểm tra luồng nút NHẬN/TỪ CHỐI còn hiển thị và kích hoạt sau tích hợp.
4. Ghép PR #64 theo từng nhóm nhỏ với review pre/post diff: (i) state+schema+SaveService+receipts, (ii) Hall+effects, (iii) Residence construction+plot, (iv) UI+map+door, (v) tests. Sau mỗi nhóm: import/parse/test liên quan; rollback phạm vi nhóm nếu FAIL. Không chọn cách overwrite nguyên file RC và không dùng test mới để che lỗi đã có.
5. Các file giao nhau/rủi ro cao: p3_2_landscape_sect.gd, recruitment_system.gd, building_system.gd, live_game_runtime_v2.gd, sect_state.gd, simulation_state.gd, save_service.gd, sect_isometric_world_v1.gd. Review mọi điểm dùng state mutation và event/signal. Dẫn Tiên/Đại Điện cùng Tiếp Dẫn: phải có duy nhất một authority; không nhân đôi chức vụ/guidance buff.
6. Chỉ sửa file liên quan trực tiếp các mục đã nêu, test và docs/evidence; mọi sửa Forge, SX, PvE và hệ khác là OUT OF SCOPE, cần phản hồi blocker/đề xuất packet riêng.

## 3. CỔNG TEST CHÍNH THỨC — CHẠY THỰC TẾ

Trên Windows, dùng đúng bản Godot 4.7.2 official, checkout QA riêng trong E:/TongMonBaDaoWorkspace, không dùng máy/game đang chạy, không chạy nhiều Godot/Chrome đồng thời, giới hạn RAM bằng chạy **tuần tự** và timeout hữu hạn. Tạo profile APPDATA riêng, không đụng save người chơi.

Từ root repository (PowerShell; thay đường dẫn chính xác vào $GodotExe):
    & $GodotExe --version
    & $GodotExe --headless --path godot --editor --quit
    if ($LASTEXITCODE -ne 0) { throw "Import FAIL" }

Sau import chạy các suite **tuần tự**; ghi exact SHA, command, exit code, full log:
    res://tests/dai_dien_v1_smoke.gd
    res://tests/dai_dien_dd06_integrity_test.gd
    res://tests/dai_dien_dd07_save_recovery_test.gd
    res://tests/dai_dien_housing_full_loop_test.gd
    res://tests/dai_dien_dd092_door_plot_test.gd
    res://tests/presentation/sect_door_only_navigation_test.gd
    res://tests/dan_tien_c2_smoke.gd
    res://tests/dan_tien_rc_live_acceptance.gd
    res://tests/dan_tien_rc_reload_verify.gd
    res://tests/presentation/p3_o2_recruitment_map_test.gd
    res://tests/presentation/p3_4a_building_operation_panel_test.gd
    res://tests/presentation/p3_4c_building_system_actions_test.gd
    res://tests/simulation/p1_2_recruitment_test.gd
    res://tests/simulation/p2_7_workforce_test.gd
    res://tests/simulation/p3_7a1_building_authority_test.gd
    res://tests/simulation/p3_7c1_foundation_guidance_test.gd
    res://tests/simulation/safe_01_save_recovery_test.gd
    res://tests/simulation/b3_care_pills_autohunt_test.gd
    res://tests/simulation/gp_02c1_injury_settlement_test.gd

**CHÚ Ý:** DanTien RC live acceptance và reload là hai phase dùng cùng file save trong profile; đọc source và chạy đúng thứ tự/cấu hình của test, không chạy reload độc lập với file chưa tạo. Kiểm tra thực tế path/tên test từ repository tại HEAD; nếu path liệt kê không có, ghi NOT FOUND và tìm tên canonical thật, không tự nhận PASS. Các test thích hợp phải chạy theo contract đúng seed/test profile; không chỉ khởi chạy empty test. Dùng command ví dụ:
    & $GodotExe --headless --path godot --script $test
    if ($LASTEXITCODE -ne 0) { throw "FAIL: $test" }

Kịch bản bắt buộc thêm:
- New Game sạch: starter Dẫn Tiên, 6 founders, 3 candidate, 3 order, cap 8; nhận/từ chối bằng nút thực; không lộ hồ sơ riêng, không chấp nhận candidate V2 incomplete, queue cap và daily reset ổn định; tuyển xong danh sách cập nhật chính xác.
- Đại Điện: bổ nhiệm/huỷ bỏ, điều kiện busy/injury/PvE, buff consumer đúng và không nhân đôi; Hall upgrade timer/receipt, giao diện đúng mục; 27-rank transaction fail/pass đúng gates, request id exactly-once và không vượt giới hạn admin; **không đổi balance**.
- Nhà: chọn lô không chồng lấn, không chặn cửa, không cần đường; sau mua nhà đang xây không tăng beds; save/reload giữa chừng, hoàn thành 1 lần; phân phòng không quá giường, door actor target trùng saved plot; legacy residence_001 ổn; replay yêu cầu sau hoàn thành không tiêu tiền lần 2.
- SAVE: Legacy P2/non-Hall, opt-in Hall, unversioned House, versioned House, Backup .bak hồi phục được, corrupt payload fail-closed; atomic writer và first/second process reloading; không tăng resource/tick/vật phẩm giả.
- UI thật Godot tại 1280×720: bản đồ/Đại Điện/Dẫn Tiên/Đệ Tử Xá, Source A portrait, thao tác cảm ứng/chuột, các nút; ảnh PNG/JPEG screenshot từ renderer thật (không mock), text không che icon; di chuyển tới cửa nhà chứ không xuyên mái.
- Regressions tùy ảnh hưởng: B3 CARE, Injury 120, Mine/Forest/Field, alchemy, warehouse, save, legacy recruitment, selected P3.4. Full cumulative sau sửa cross-system nếu có thời gian; nếu chưa chạy gọi PENDING, không tự gọi full PASS.

**Known red baseline:** Windows Dẫn Tiên RC evidence 2026-11-01 có 11 focused PASS / 1 FAIL: p3_4c BuildingSystem Actions: Forge craft không tiêu vật liệu thanh_thiet. Chạy lại đúng SHA để phân biệt lỗi có sẵn với regression mới; KHÔNG tự động sửa Forge ngoài phạm vi. Đưa vào báo cáo với nhãn BASELINE-RED / NEEDS OWNER AUTHORIZATION nếu không thuộc diff đã sửa. Ghi rõ lỗi chứng thư Windows/cache cũ khi import có thể là diagnostic, nhưng không được bỏ qua lỗi parse/runtime thật.

## 4. ĐẦU RA / GATE KẾT THÚC

- Tạo PR **Draft** từ nhánh tích hợp mới về **rc/one-game-playable-20261101**, không merge; không sửa main, không sửa PR #60/#64, không tạo commit trực tiếp lên RC.
- Báo: base SHA, nguồn PR #64 SHA, HEAD mới, danh sách file/scope, merge strategy, các xung đột đã sửa và vì sao không mất CandidateDecisionActions.
- Bảng test MỖI dòng: tên, exact command, Godot version, tested commit SHA, EXIT CODE, PASS/FAIL/BLOCKED/NOT RUN, đường dẫn log/artifact; screenshot renderer thật và trạng thái kiểm tra chuột/touch. Đưa chứng cứ lên GitHub nếu thích hợp và không có dữ liệu riêng.
- Khóa/đối chiếu các API và mã receipt: save trước/sau và cross-process, rollback path, không gãy legacy. Đối với test đỏ phải nêu nguyên nhân đã xác nhận, không thay test để biến đỏ thành xanh.
- Nếu cần đổi một giá/odds/cap/27-rank pacing, hoặc sửa ngoài scope như PvE/SX/Forge, **DỪNG và xin owner quyết định; không tự ý áp dụng**.
- Chỉ đánh dấu READY FOR OWNER REVIEW khi tất cả cổng bắt buộc thực sự PASS. Android/chuột vật lý hoặc kiểm tra chưa chạy ghi PENDING USER. Không gọi MERGED, FULL COMPLETE hay PLAYER ACCEPTED.

BẮT ĐẦU bằng bảng diffs và thứ tự hòa giải, sau đó triển khai code+QA có commit/nhật ký ngay. Không bàn luận lan man, không gọi tác vụ chạy nền không kiểm soát và không thêm telemetry hiệu năng.
