# ENV-02A ONLY — Tông Môn Bá Đạo / Large-world isolated lab

**Trạng thái bàn giao:** CODE PACKAGE + OFFLINE STATIC QA. **Godot 4.7.2 Windows import, functional/visual QA và Android: PENDING USER.** Không tự nâng thành PASS.

## 1. Chạy một lần trên Windows

1. Giải nén toàn bộ ZIP ra thư mục mới, ví dụ `E:\TongMonIntegrationLab\ENV02A_192World_Lab` (KHÔNG chồng lên ENV-01 v4 hoặc game chính).
2. Mở thư mục có `project.godot`; nhấp đúp **`RUN_ENV02A_WINDOWS.cmd`**.
3. CMD dùng `E:\Godot_v4.7.2-stable_win64_console.exe`. Nếu khác vị trí, mở CMD bằng đường dẫn Godot console làm tham số duy nhất. Cửa sổ sẽ **giữ lại** nếu có lỗi.
4. Launcher chạy **4 gate**: import Godot; legacy ENV-01 20×13; ENV-02A 192×192/3 buildings/roads/camera/chunks; cửa sổ Godot thực tế.
5. Trong cửa sổ Godot: kéo **chuột phải** để đi xa khỏi khu khởi đầu, cuộn để zoom, chuột trái chọn Đại Điện/Kho/Luyện Khí. Chụp hai ảnh **thực tế** ở trung tâm và xa khu khởi đầu (có thể thêm ảnh zoom). Nhấp X đóng Godot thì CMD sẽ báo kết quả.
6. Gửi nguyên thư mục `ENV02A_TEST_RESULTS/` (import.log, env01_regression.log, env02_structure.log, interactive.log, launcher.log) và ảnh Godot.

**Điện thoại:** PC Windows là cổng kiểm thử trước; Android landscape 1280×720 là nền tảng chính, nhưng _chưa xuất APK hoặc benchmark trên thiết bị_. Scene có thao tác chạm chọn, vuốt một ngón, pinch hai ngón (chưa được Android thực nghiệm). Không khẳng định Android PASS từ Windows.

## 2. Phạm vi chỉ ENV-02A

- Thế giới logic `192×192` = 36.864 ô. Lưới phân vùng `16×16` = 144 chunk. Chỉ các chunk nhìn thấy trong viewport (+padding) được vẽ; KHÔNG tạo 36.864 Sprite2D.
- Khu **preview khởi đầu** là `Rect2i(72,72,48,48)`. Vùng ngoài hiển thị tối hơn để phân biệt, **không phải cơ chế mở khóa đất**. Chưa làm gameplay xây nhà tự do, di chuyển, mua đất, unlock, save vị trí hoặc sản lượng.
- `scripts/map_model.gd` vẫn là class `TransferMapModel` duy nhất. `MapModel.new()` giữ default 20×13 và SPAWN=(0,0); scene ENV-02A cấu hình cùng class `MapModel.new(Vector2i(192,192), Vector2i(82,84))`. Footprint, rotated doorway, occupancy và AStar dùng lại logic gốc.
- `scripts/env02_chunk_environment.gd` **extends** renderer ENV-01. Dùng lại cùng 29 texture Source A và 3 ảnh công trình, chỉ thay cách trình bày theo chunk. Culling presentation **không phải navigation authority**.
- Camera giới hạn theo world bounds; pinch zoom bám điểm giữa hai ngón (trừ khi chạm biên). Camera/label nằm riêng CanvasLayer; HUD ENV-02A chỉ dùng dải 56px trên/50px dưới. Đã có camera mobile input, nhưng Android QA còn thiếu.
- 3 nhà **giữ** footprint: 7×5, 3×2, 3×3; đặt trong vùng preview trung tâm. Các tọa độ này chỉ tồn tại trong lab, không ghi vào `BuildingState` hoặc save.
- Scene cũ `scenes/pv01_three_buildings.tscn` giữ nguyên byte, smoke `--env01-verify` vẫn có gate riêng.

## 3. Các file khác với ENV-01 v4

**Đã sửa:** `project.godot` (chuyển main scene lab), `scripts/map_model.gd` (parametrization, giữ default 20×13). **Thêm** `scripts/env02_world.gd`, `scripts/env02_chunk_environment.gd`, `scenes/env02a_large_world.tscn`, launcher/README/scripts QA. Toàn bộ asset/source gốc và scene ENV-01 đã copy byte-identical.

**Không động tới** GitHub production, `SimulationState`, `BuildingState`, EXP, Warehouse, workforce, save, FE-02, S3 assets, source Spine, DV2-03 (`PAUSED NOT CLOSED`). Không tạo map authority mới, không làm ENV-02B/C/D/E.

## 4. Kiểm thử và phân loại bằng chứng

- `tools/verify_env02a_static.py` kiểm asset SHA, cấu trúc ZIP, hợp đồng legacy, footprints, dự đoán BFS và phạm vi chunk/camera theo Python. **Nó không thực thi GDScript và không thay thế Godot.**
- `--env01-verify` kiểm thật scene ENV-01 v4 20×13 trong Godot.
- `--env02-verify` kiểm thật scene ENV-02A, bao gồm AStar, cấu hình grid, camera, asset, culling; kết quả chỉ PASS nếu log có `ENV02A_RESULT PASS_STRUCTURE` và không có lỗi parse/runtime.
- Windows interactive: ảnh chụp cần map liên tục, 3 nhà, camera đi được xa, chunk đếm thay đổi, không có khoảng trống nền gây hiểu nhầm.
- Android touchscreen, FPS, memory chưa có benchmark, giữ **PENDING USER**.

## 5. Giới hạn chủ ý

World 192×192 là **khả năng render/navigate logic để thử nghiệm**, không phải 192×192 ô đã mở khóa hoặc nơi có 100+ công trình. 48×48 là vùng thiết kế ban đầu, không phải quyết định quy hoạch cuối. Hệ xây/move/road gameplay & layout persistence phải có packet riêng được duyệt. Nền ngoài khu trung tâm hiện dùng biến thể ô procedural; không khẳng định Source A có world layout tương đương. Nội dung vùng tiếp theo thuộc ENV-02B/C.