# Combat Lab độc lập (V1)

Combat Lab là scene thử nghiệm chạy trực tiếp trong Godot 4.7.2. Nó không phải màn chơi chính, không thêm AutoLoad và không bật feature gate mặc định.

## Mở và chạy

1. Mở thư mục `godot/` bằng Godot 4.7.2.
2. Mở scene `res://labs/combat_lab/combat_lab.tscn`, nhấn **F6** để chạy riêng scene.
3. Chọn trường phái, cảnh giới, nhánh, truyền thừa, từ 1 đến 6 đệ tử và đối thủ. Chọn 4 kỹ năng chủ động cùng một tuyệt kỹ hợp lệ.
4. **TÁI TẠO TRẬN** tạo fixture mới; **AUTO** chạy từng tick 0,25 giây; **HOLD** dừng mô phỏng; **STEP** chạy đúng một tick. Zoom trong khung xem có 1×/2×/4×/6×.

Có thể chạy scene độc lập bằng lệnh:

```powershell
& 'E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe' --path 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\godot' 'res://labs/combat_lab/combat_lab.tscn'
```

Không cần đổi `project.godot` hoặc main scene.

## Ranh giới dữ liệu và engine

- Trận Lab gọi `MapBattleV2.setup/step`, `CombatStatsV2.derive`, `V63HumanSkillCombatSystem` và các consumer Immortal/Divine hiện hữu. Không có công thức damage/cooldown thứ hai.
- Roster, archive manual, learned/equipped skill và `attach_disciple_loadout` dùng `SimulationState`/`DiscipleState` mới trong bộ nhớ, được đánh dấu `LAB_ONLY`; không truy cập profile, save hoặc SimulationState production.
- Preview gate được truyền riêng vào API V6.3. `V63FeatureGates.DEFAULT_FLAGS` vẫn OFF.
- Trận là finite encounter (`keep_encounter_open=false`), nên không sinh kill receipt, loot, EXP hay thưởng.
- Boss lấy từ catalogue V6.3 và `install_boss_spawn`; quái thường/Tinh Anh lấy từ `MonsterCatalogueV2`.
- VFX chỉ đọc event `MapBattleV2`; cursor là chỉ số mảng cục bộ do source không cấp event ID. Chỉ số cue/floating number lấy từ event thật và `hit` được khử trùng với event semantic/DoT tương ứng. Lab dùng finite encounter; tối đa 2.400 event, event mới bị bỏ khi đầy. Trong `world_mode`, source cuộn mảng tại chỗ nên cursor cục bộ không phát hiện replacement; test xác nhận giới hạn này. Không nối bridge hiện tại vào PvE liên tục trước khi có event ID/cursor authority.
- Hình người và vũ khí trong arena là primitive code-drawn để kiểm thử combat/UI, chưa phải art đã duyệt và không được xem là Source A. Vũ khí placeholder có đường vẽ riêng, độc lập về logic với thân; chưa phải Node/asset có thể gắn rig. Không dùng C2 hoặc clip hoạt ảnh tự tạo.
- Accuracy/Evasion bổ sung, tài nguyên vật phẩm, lưu nhân vật và nối PvE chưa được thêm vào runtime.

## Kiểm thử

Focused test:

```powershell
& 'E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe' --headless --path 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\godot' --script 'res://tests/labs/combat_lab/combat_lab_focused_test.gd'
```

Test xuất ma trận từng `skill_id` vào `user://combat_lab_skill_matrix.csv` với `PASS`, `FAIL` hoặc `NOT_TESTED`. Kết quả thô và log chỉ có giá trị sau khi test hoàn tất; chưa chạy xong thì không xem là QA pass.

## Handoff tích hợp PvE

Để nối roster thật sau này, thay adapter Lab bằng adapter đọc roster/ownership của PvE và giữ nguyên `MapBattleV2` làm engine. Không bỏ fixture vào save. Cần nghiệm thu riêng art nhân vật, input chuột/thực tế và cân bằng trước khi bật bất kỳ gate sản xuất nào.
## V2 — Animation/VFX độc lập (bổ sung 06/11/2026)

V2 thêm mã hiển thị trực tiếp bên trong Lab; **không** thay engine sát thương, PvE hay save.

- **Chibi rig nguyên bản vẽ bằng code**: `combat_lab_actor_rig_v2.gd`. Các bộ phận đầu, tóc, thân/vạt áo, hai tay/chân xoay độc lập; đủ sáu tư thế `idle / walk / attack / cast / hit / death`. Vũ khí đi qua hàm vẽ riêng và chỉ hiện lúc thi triển/đánh. Chân là điểm neo tọa độ thực của `MapBattleV2`. Đây vẫn là **rig minh họa kỹ thuật bằng vector, không phải MASTER sprite cao cấp được duyệt**.
- **Yêu cầu render ở 24 Hz** từ `combat_lab.gd`, độc lập với nhịp HUD 0,15 giây; rig trong `combat_lab_arena.gd` đọc thời gian hiển thị. Đây là tần suất cập nhật được lập trình, **chưa phải FPS đã đo trên GPU**. Không sửa `MapBattleV2.STEP_SECONDS=0.25`.
- **VFX nguyên bản**: `combat_lab_vfx_v2.gd` vẽ cung tên/hạt sáng vàng, nắm đấm/địa chấn cam, độc xanh ngọc, guard khiên hình lục giác, heal, cleanse, mark, DoT, AoE và cảnh báo Boss. Nhân/Tiên/Thần có lớp dấu ấn phân biệt. Tất cả số damage/HP chỉ đọc từ **sự kiện đã commit**.
- **Thử riêng từng kỹ năng trang bị**: chọn một trong 4 chiêu chủ động và Tuyệt Kỹ, nhấn `THỬ CHIÊU (HOLD)`, rồi nhấn `STEP · 0,25s` để hoàn tất cast. Dùng consumer V6.3 thật, không mở khóa kỹ năng hoặc bỏ qua cooldown/range. Nếu skill không hợp lệ, thông báo và không cast thay thế skill khác.
- Ngân sách hiệu ứng: tối đa 64 cue đang tồn tại trong Lab, hoạt ảnh không thay đổi HP, cooldown, loot, save. Lab không sử dụng asset thương mại chưa được duyệt.

### Kiểm thử V2 an toàn trên máy Windows RAM 8GB

Máy 8 GB RAM **không bắt buộc có 3 GiB RAM trống**. Runner kiểm tra RAM khả dụng trước MỖI tiến trình; mặc định yêu cầu tối thiểu **1.024 MiB RAM khả dụng**, chỉ chạy tuần tự và vẫn từ chối nếu có Godot đang chạy. Đây là ngưỡng thử nghiệm tối thiểu, **không phải cam kết máy không treo/BSOD**. Khi RAM thấp, ưu tiên Smoke headless; không mở thêm GUI.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/windows/qa/Run-TMBCombatLabV2.ps1 -GodotExe "E:\\TongMonBaDaoWorkspace\\04_Tools\\Godot\\Godot_v4.7.2-stable_win64_console.exe"
```

Mặc định runner chạy `-Mode Smoke`: Godot import headless, parse và chạy **chỉ focused visual Lab V2**; không chạy ma trận 549 ID. Khi tài nguyên tốt hơn, chọn `-Mode Full` để chạy thêm Lab V1. Runner không kill PID, dùng profile `APPDATA` riêng và chặn khi dưới mức `-MinimumAvailableMB` (mặc định 1024); không giảm ngưỡng này xuống dưới 1024 MiB. **Lệnh này chưa được chạy/ghi PASS trên commit V2 trong phiên tạo code**. Nếu cần nghiệm thu hình ảnh, phải chạy GUI thực sự và chụp ảnh mới, không dùng ảnh V1 hay hình concept làm bằng chứng.

### Bắt buộc để nghiệm thu cuối

1. Godot official import/parse/focused exit 0 trên **exact V2 SHA**.
2. Ảnh hoặc video **từ scene Godot V2 thật** cho cả Cung/Quyền/Độc với sáu tư thế + Boss; thử 1×/2×/4×/6×, kiểm tra crop/foot anchor và FPS.
3. Artist-reviewed, original full-resolution character master/sprite rig. Rig vector lập trình hiện tại là `ART_PLACEHOLDER_V2`, không được ghi là art hoàn chỉnh.
4. Khi nối vào PvE liên tục, xử lý ID/cursor của event ring trong một patch authority được duyệt riêng; V2 vẫn chỉ dùng finite encounter.
5. Quyền/Độc 9 ID `NOT_TESTED` cùng 26 quy tắc Độc Thần `DESIGN_PENDING` được giữ nguyên theo quyết định hoãn của Owner.

### Bản vá timing và giao diện sau V2

- Hiệu ứng gục đọc `downed.actor_id`, đặt tại đúng tọa độ đệ tử/quái bị hạ.
- Hào quang lúc niệm xuất hiện ở **người thi triển**, không phải mục tiêu. Với kỹ năng có đạn bay, Lab dùng `skill_cast.release_at`, `cast_time` và `cast_speed` từ consumer thật để lên lịch đường bay **sau niệm và trước deadline release**. `skill_release` không tạo thêm đạn bay sau hit; bản thân damage vẫn chỉ lấy từ `MapBattleV2`. HOLD giữ nguyên đồng hồ trình diễn, STEP tăng đúng một tick.
- Zoom `1×/2×/4×/6×` giữ tâm thế giới; có thêm các oracle geometry/actor-unchanged trong `combat_lab_v2_visual_test.gd`. **Chưa có ảnh Godot mới xác nhận không clipping/chồng hình ở từng mức.**
- Năm biến môi trường QA tùy chọn: `TMB_COMBAT_LAB_SCHOOL=bow|fist|poison`, `TMB_COMBAT_LAB_GENERATION=human|immortal|divine`, `TMB_COMBAT_LAB_ENEMY=normal|elite|boss`, `TMB_COMBAT_LAB_PARTY=1..6` và `TMB_COMBAT_LAB_ZOOM=1|2|4|6`. Scene bình thường không bị ảnh hưởng.

Chụp **một lần/một tiến trình**, sau khi kiểm tra không có Godot khác và RAM trống >=3 GiB; không chạy cùng các tác vụ Codex đang mở Editor:

```powershell
$env:TMB_COMBAT_LAB_SCHOOL="fist"
$env:TMB_COMBAT_LAB_GENERATION="human"
$env:TMB_COMBAT_LAB_ENEMY="boss"
$env:TMB_COMBAT_LAB_PARTY="6"
$env:TMB_COMBAT_LAB_ZOOM="2"
$env:TMB_COMBAT_LAB_SCREENSHOT="$env:TEMP\combat_lab_fist_2x.png"
$env:TMB_COMBAT_LAB_CAPTURE_DELAY="4"
& 'E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe' --path 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\godot' 'res://labs/combat_lab/combat_lab.tscn'
```

Lặp tuần tự cho Cung, Quyền, Độc và mỗi zoom, đổi tên PNG tương ứng; phân loại rõ `GUI_GODOT` so với `NATIVE_MOUSE`. Ví dụ trên chỉ mô tả **cách chạy**, không phải log PASS. Không thay vũ khí/sprite MASTER khi chưa có asset gốc được Owner duyệt, không bật combat production.

### Lệnh QA cho máy 8 GB RAM

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/windows/qa/Run-TMBCombatLabV2.ps1 -GodotExe "E:\\TongMonBaDaoWorkspace\\04_Tools\\Godot\\Godot_v4.7.2-stable_win64_console.exe" -Mode Smoke
```

Chỉ dùng `-Mode Full` khi không có Godot đang chạy, hệ thống còn đủ RAM và Smoke PASS. Không tự tắt tiến trình Godot đang làm việc của chủ dự án; `BLOCKED_OTHER_GODOT` không phải lỗi game. Vẫn giữ trạng thái **QA_PENDING** cho đến khi test chạy và có log exit code thật trên đúng HEAD.

## VFX V8 — U Minh Độc Xà và Vạn Kiếm Quy Tông (12/11/2026)

V8 là đồ họa **nguyên bản, vẽ bằng GDScript**, không phải GIF concept được nhập làm atlas. Nó bổ sung một con rắn có đầu, mang, hàm, mắt, nanh và thân uốn; kiếm có lưỡi, chuôi, chắn tay và đội hình phân tán. Giữ V4 để có thể đối chiếu.

- **Rắn trong trận Combat Lab thật:** mở `res://labs/combat_lab/combat_lab.tscn` (F6), chọn trường phái **Độc → Cổ Độc**, nạp kỹ năng `tmb.skill.poison.co_doc.active_02.human`, bật nút **VFX V8 · RẮN RÕ HÌNH**, sau đó thử chiêu. V8 chỉ được vẽ theo cue `projectile/impact` từ `MapBattleV2`; không bịa số lần trúng hay sát thương. Có thể bật khi khởi động qua `TMB_POISON_V8_PREVIEW=1` và `TMB_POISON_V4_PREVIEW=1`.
- **Kiếm trận và rắn xem độc lập:** F6 `res://labs/combat_lab/combat_lab_v8_showcase.tscn`. Nhấn **1** / **2** hoặc các nút trên giao diện để chọn skill, Space phát lại, P tạm dừng. Dựng ở 1280×720, chỉ hiển thị chuyển động, KHÔNG phải một trận chiến có hit/HP/target.
- **Kiểm thử chính thức:** `res://tests/labs/combat_lab/v8_jian_serpent_contract_test.gd` và `.github/workflows/vfx-v8-godot-focused.yml`. CI cung cấp artifact ảnh PNG/video MP4 từ engine khi chạy thành công. Không coi ảnh GIF concept như ảnh Godot.
- **Chưa làm:** nối Kiếm Tu vào V6.3 Combat Lab và trận PvE chính, render texture/spritesheet cao cấp đã duyệt, tối ưu FPS/VRAM thực ở 30 đệ tử, nghiệm thu Windows/Android. Không sửa `project.godot`, main scene, Save hoặc combat authority.

