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