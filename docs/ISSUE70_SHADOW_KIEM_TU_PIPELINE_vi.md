# Issue #70 — Shadow Kiếm Tu: pipeline 3D → sprite atlas

## Trạng thái bàn giao

Pipeline nhập/kiểm tra rig và bake sprite atlas đã được thêm ở dạng công cụ cách ly trong Godot 4.7.2. **Nhân vật Shadow Kiếm Tu thật đang `BLOCKED_BY_TRIPO_ASSET`**: các thư mục dự án đã kiểm tra không có GLB/GLTF/FBX của nhân vật; không tiêu tốn credit Tripo và không thay bằng model mẫu.

Animation Lab có thể xem model do người dùng cung cấp, liệt kê skeleton/clip thật, đặt camera theo 8 góc azimuth, chạy/tạm dừng/phát lại, điều chỉnh tốc độ/zoom, xem mặt sàn tham chiếu và áp shader bóng tím chỉ cho mục đích trình bày. Shader không thêm tóc, áo giáp, mesh hay chuyển động.

## Phạm vi đã làm

- `shadow_glb_asset_audit.gd`: kiểm tra file nguồn, kiểu scene Godot, số mesh/skeleton/AnimationPlayer, nhóm xương, tên clip bắt buộc, clip tùy chọn `run`, hash nguồn và schema manifest.
- `shadow_3d_animation_lab.tscn/.gd`: lab 3D view-only, không nối gameplay, PvE, Combat V2 hoặc SaveService.
- `shadow_glb_bake_cli.gd`: render từng frame của các clip gốc hiện hữu vào trang PNG RGBA8, 4 hoặc 8 góc camera thật. Trang atlas được chia tối đa 8 cột × 16 hàng; manifest ghi hash nguồn/trang, tên clip gốc, góc camera, FPS, frame, pivot tham chiếu và trạng thái clip.
- `shadow_glb_pipeline_test.gd`: test focused cho file thiếu/sai loại, schema version, hash, dữ liệu sai, JSON xác định và inventory clip.
- `shadow_3d_animation_gui_capture.gd`: chụp framebuffer GUI thật ở 1280×720; khi thiếu model, ảnh chứng minh trạng thái BLOCKED thay vì giả lập nhân vật.

Không có bước Blender tự động hoặc converter Blender mới. Blender chưa được tìm thấy trong môi trường kiểm tra; người dùng có thể dùng Blender để chuẩn bị/xuất model rồi import GLB qua Godot. Tool chỉ đọc scene đã được Godot import.

## Mức xác minh asset

| Hạng mục | Kết quả |
|---|---|
| GLB/GLTF/FBX Shadow Kiếm Tu | **BLOCKED_BY_TRIPO_ASSET** — chưa có file nguồn thật |
| Rig/xương, tóc, áo giáp và dáng nhân vật Shadow | Chưa xác minh |
| Clip stand, walk, run, attack1, hit, dead của Shadow | Chưa xác minh; UI/baker không sinh clip thay thế |
| Atlas 4/8 góc của Shadow | Chưa tạo vì chưa có model thật |
| Shader bóng đen/viền tím | Chỉ là tùy chọn preview trên mesh thật khi có model; không phải tạo hình nhân vật |
| Source A 2D trong AN-02 | Đã preview bằng Godot GUI riêng; đó là nhân vật Source A có sẵn, không phải Shadow Kiếm Tu |
| Owner visual acceptance | **PENDING** |

Kiểm tra năm gói Source A 2D hiện có (`1113028_1`, nữ V5, nam V5, quái V5 và Boss-slot V5) cho thấy hash các trang atlas trùng `asset.json`, nhưng hash `actor.tscn` và `animations.tres` không trùng manifest ở cả năm gói. Giữ nguyên dữ liệu; metadata hai file text đang **UNVERIFIED**. Không sửa manifest chỉ để làm sạch validator.

Không dùng kết quả bake `READY_FOR_VISUAL_REVIEW` làm `COMBAT_READY` hay nghiệm thu hình ảnh. Kiểm tra chân tự động chỉ ghi pivot tham chiếu; tư thế chân từng frame vẫn cần duyệt trực quan.

## Dùng Animation Lab

Không cần sửa `project.godot`. Chạy file `tools/windows/run/Run-Shadow-3D-Animation-Lab.cmd` sau khi đặt biến môi trường `TMB_GODOT_EXE` trỏ tới Godot 4.7.2. Hoặc chạy trực tiếp:

```powershell
& $env:TMB_GODOT_EXE --path .\godot .\godot\scenes\labs\shadow_3d_animation_lab.tscn
```

Import model vào `godot/assets/user_imports/`, đợi Godot hoàn thành import, nhập đường dẫn `res://assets/user_imports/<ten-model>.glb` trong ô Model nguồn và nhấn **Tải rig**. Lab không lấy/đọc credit Tripo.

## Bake atlas sau khi có model

```powershell
tools\windows\run\Bake-Shadow-GLB-To-Atlas.cmd res://assets/user_imports/shadow_kultai.glb 12 256 4
# Xem và duyệt atlas 4 góc trước, sau đó mới chạy bước 8 góc:
tools\windows\run\Bake-Shadow-GLB-To-Atlas.cmd res://assets/user_imports/shadow_kultai.glb 12 256 8
```

Tham số là FPS, cạnh cell và số hướng (`4` hoặc `8`); mặc định là 12 FPS, cell 256 và 4 hướng. Kết quả được ghi vào thư mục tách biệt `godot/outputs/shadow_bake/<asset>_<source-sha-prefix>_d4/` hoặc `_d8/`, không ghi ngược vào asset nguồn hay đè proof 4 hướng. Mỗi hàng manifest giữ `source_clip` chính xác. Clip thiếu được ghi `MISSING`, bake dở dang có trạng thái `INCOMPLETE_REQUIRED_CLIPS`; không tự đổi tên clip hoặc thế clip khác.

## Chạy kiểm tra focused

```powershell
& $env:TMB_GODOT_EXE --headless --path .\godot --script res://tests/presentation/shadow_glb_pipeline_test.gd
```

GUI capture:

```powershell
& $env:TMB_GODOT_EXE --path .\godot --script res://tests/presentation/shadow_3d_animation_gui_capture.gd
```

GUI capture phải chạy ở desktop, không dùng `--headless`. Ảnh output là bằng chứng giao diện và trạng thái asset, không phải bằng chứng có model Shadow.

Kết quả đã chạy với Godot 4.7.2 official:

- `shadow_glb_pipeline_test.gd`: **PASS 15/15** (schema JSON v1, JSON xác định, dữ liệu sai, inventory clip, manifest Source A và trạng thái GLB thiếu).
- `shadow_glb_bake_cli.gd` không tham số: preflight trả đúng `BLOCKED_BY_TRIPO_ASSET`; không tạo atlas.
- `shadow_3d_animation_gui_capture.gd`: **PASS**, GUI thật 1280×720; ảnh nằm tại `godot/outputs/issue70/shadow_3d_lab/shadow_3d_lab_blocked_by_tripo_asset.png` trong workspace chạy QA.
- AN-02 Source A lab: trước đó **PASS 160 checks** và đã chụp 5 framebuffer thật cho nam, shader Shadow thử nghiệm, nữ và quái. Đây là mẫu 2D Source A, không xác minh rig Shadow.
- Godot phát cảnh báo đọc root certificate store; GUI cũng ghi một diagnostic khởi tạo GLES trên Intel Iris Plus nhưng vẫn render/chụp thành công. Không dùng hai diagnostic này làm bằng chứng QA model.

Log focused và log GUI nằm trong `godot/outputs/issue70/qa_logs/` ở workspace chạy kiểm tra; outputs không được commit cùng source.

## Còn cần để nghiệm thu nhân vật

1. Cung cấp GLB/GLTF/FBX model Shadow Kiếm Tu có provenance rõ ràng, sau đó nhập vào `godot/assets/user_imports/`.
2. Xác nhận skeleton, material/texture, scale, hướng trước, sàn/pivot, clip nguyên gốc và quyền dùng runtime/asset.
3. Chạy bake 4 góc smoke trước, xem atlas và chân đứng; sau đó mới xuất 8 góc và kiểm tra alpha/hash/manifest.
4. Duyệt thật tại 1280×720. Tới lúc đó mới cập nhật clip/rig QA; hiện chưa có OWNER VISUAL PASS.

