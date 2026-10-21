# Dev Character Studio MVP

Godot EditorPlugin nội bộ để tra cứu rig Source A thật, xem clip có thật và thử Character Preset JSON. Plugin nằm độc lập trong namespace `res://addons/tmb_character_studio/`.

## Bật plugin

1. Mở project `godot/` bằng Godot **4.7.2**.
2. Chọn **Project → Project Settings → Plugins**.
3. Bật **TMB Dev Character Studio**.
4. Mở dock **Dev Character Studio** ở cạnh phải.

Plugin không sửa `project.godot`; người dùng tự bật/tắt tại Editor.

## Thao tác

- Tab **Rig Source A** liệt kê các actor có trong `DiscipleSourceAVisualPool`; mỗi rig được đối chiếu `asset.json`, scene, atlas, SHA-256 và clip `stand`/`walk`.
- Rig có binary nhưng SHA manifest không khớp sẽ được liệt kê ở trạng thái **CHƯA XÁC MINH**, không được preview/lưu preset; không bỏ qua checksum.
- Chọn `stand`/`walk`, hướng trái/phải, tỷ lệ và pivot. Đường ngang là đường đứng; dấu vàng là pivot. Asset nào thiếu hoặc chưa xác minh sẽ không được thay bằng hình/hoạt ảnh giả.
- Tab **Character Preset** chỉnh ID, tên, giới tính tương thích rig, vai trò, sáu nền tảng thử nghiệm, tọa độ cảnh giới, kỹ năng và recipe equipment.
- Danh sách skill dùng ID và ngưỡng `min_stage` từ `CombatSkillSystem`. Runtime chưa có schema slot; số slot chỉ là thứ tự preset và được ghi rõ **DESIGN-ONLY**.
- Equipment chỉ lưu tham chiếu recipe từ `EquipmentSystem`; không tạo inventory hay item production.
- **Mới / Mở / Lưu / Xuất** làm việc với Character Preset JSON schema version 1. Preset luôn có `scope: dev_character_studio_sandbox` và không chứa seed sinh đệ tử.
- Hồ sơ đọc từ `DisciplePresentationSnapshotV2`; phần stat gọi `DiscipleCombatLoadoutV2`/`CombatStatsV2`. Preview dùng object tạm trong bộ nhớ, không gắn vào runtime và không gọi SaveService.
- V2 birth root/talent chưa có identity hoàn chỉnh thì hiển thị **DESIGN-ONLY**. `Accuracy` và `Evasion` luôn **DESIGN-ONLY**, không nằm trong stat runtime.

## Focused tests

Chạy trong project đã có asset Source A và Godot chính thức 4.7.2:

```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot -s res://addons/tmb_character_studio/tests/run_tests.gd
```

Focused test bao phủ round-trip/determinism, schema version, ID, rig/sex/path, skill ownership/order, equipment recipe/slot, asset manifest/SHA, và `stand`/`walk` thật. Không chạy CI/FULL qua packet này.
