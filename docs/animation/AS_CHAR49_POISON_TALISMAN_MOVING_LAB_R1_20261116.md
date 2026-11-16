# AS-CHAR-49 V10 × 7 VFX ĐỘC/PHÙ — Combat Lab di chuyển (BẢN ỨNG VIÊN CHƯA GODOT QA)

## Mục đích
Dựng sân thử **Godot 4.7.2 Compatibility 1280×720** dùng Nữ Kiếm Tu V10 với 23/24 animation gốc, **quái vật thật** `v5_sa_monster_1113031_1/animations.tres` có chuyển động `walk`, và bảy visual skill Độc/Phù đã có quyết định nghệ thuật trước đó. Đây là **test visual mix**, không phải actor/thế giới PvE được kết nối vào Combat V2.

## Chạy đơn giản trên Windows
1. Tải dự án Tông Môn Bá Đạo từ nhánh `integration/pve-p0-playable-ui-20261103` hoặc dùng bản clone đã có. Cần thư mục chứa `godot/project.godot` và assets GitHub hiện tại.
2. Giải nén ZIP này, bấm **`CHAY_THU_VFX.cmd`**, chọn thư mục `godot` của game. Installer chỉ chép thư mục Lab `labs/combat_lab/as_char49_vfx_playtest/` — không ghi đè production. Nếu chưa có Godot 4.7.2, hãy tải bản Godot 4.7.2 chính thức; trình mở file sẽ cho chọn `Godot*.exe`.
3. Trình thử tự mở scene trong Godot nếu có `Godot.exe`. Nếu chưa tìm được executable, mở `godot/project.godot` trong Godot Editor, mở và chạy scene **`res://labs/combat_lab/as_char49_vfx_playtest/playtest.tscn`** (F6).

## Điều khiển
- `W A S D` / `↑ ← ↓ →`: đi bằng nhân vật thật V10, 4 hướng, chuyển Idle/Walk (Cast/Attack khi bấm skill/SPACE).
- Chuột trái chọn quái đang di chuyển; `TAB` đổi mục tiêu.
- `1` Xà Ảnh Quấn Mạch (POI02; serpent 6-flight+4-bind pose, thật)
- `2` Phụ Cốt Cổ (POI03; original winged gu + bone seal)
- `3` Cổ Vụ Mê Tung (POI04; cloud/moth/tendril, đánh vùng cap3)
- `4` Thiên Lôi Dẫn Nét (TAL02; painted 10-frame line, cap3)
- `5` Lôi Văn Truy Ấn (TAL03; 8-frame mark theo ngực quái, mốc demo giữ 6 giây)
- `6` Liên Diệm Phần Giới (HF02 **R6**; atlas gốc chủ sở hữu duyệt, vòng đánh đứng tại tâm được khóa ban đầu, cap3)
- `7` Hỏa Tâm Ngưng Phù (HF03 **R2**; atlas gốc được duyệt, 1 mục tiêu đang đi)
- `SPACE`: Attack animation; `M`: bật/tắt AI; `V`: bật/tắt VFX; `P`: tạm dừng; `R`: reset; `H`: ẩn HUD.

## Nguồn và ranh giới nghiệm thu
- Actor V10: ZIP Library `/TMB-Character-Art/AS_CHAR49_V10_23OF24_TECH_CANDIDATE_20261116.zip` SHA256 `c8290077e0fc8ee9fd99f21b4e69038f2c3fecb9471bde253799bb4ef1fcd4fa`; 240 frame PNG được copy nguyên byte; `.tres` chỉ đổi đường dẫn để đặt trong test LAB.
- Quái: tài nguyên thật từ repo, không nằm trong pack; nếu thiếu, báo `QA49_MISSING_REAL_MONSTER_ASSET` và **không tạo quái giả**.
- POI02/03/04, TAL02/03: **không copy hay chỉnh original**; runtime dẫn thẳng tới approved source art ở `godot/labs/combat_lab/*/assets/`. Mỗi skill cần các file đúng tên. Dừng thay vì vẽ lại nếu asset missing.
- HF02: đã lấy original R6 art từ Actions artifact **14194687188**, source SHA `b5a29f1504078a0e66acc9c79306dc86f5f28463` (owner 10/10).
- HF03: đã lấy original R2 art từ Actions artifact **14195924457**, source SHA `ac3b02b1aa6c0d7e0c5dd7e418c59c4dc52a0bb4`.
- Không đưa trực tiếp scene demo VFX cũ vào sân đấu, vì phần lớn vẽ **diễn viên và mục tiêu cố định của chính scene**. Script **test bridge** dùng atlas/masters nguyên gốc để đi theo tọa độ **hero và quái hiện thời**, phân định front/back, không sửa asset gốc; nhịp/choreography mới của bridge chưa được người dùng duyệt.
- Render `CONTACT` trong Lab có nghĩa **mắt thấy hiệu ứng chạm vào quái**, không phải damage/cast receipt/gameplay. Các skill AoE luôn cap3; HF02 tâm vùng cast cố định, TAL02 có kiểm tra khoảng cách tới đường đánh, mark TAL03 bám mục tiêu đang đi. Không đếm hiệu ứng như damage thật.
- Death_Left V10 **CHƯA CÓ**; lỗi clipping Cast_Right 05–06, Cast_Back 04, Hit_Left 03 còn tồn tại; 0/24 clip chưa qua Godot/owner production approval.
- **QA hiện tại**: kiểm tra ZIP/asset hash+atlas frame layout (static). **Godot 4.7.2 native test chưa chạy được trong môi trường tạo ZIP**, chưa có movie thật, chưa có profiling FPS vật lý; **không được ghi PASS**.

## QA thủ công bắt buộc trước khi xét nghiệm thu
1. Godot 4.7.2 mở/lưu screenshot 1280×720 trên Windows; chụp ngoại quan và chuyển 4 hướng, bấm Cast ngay khi đang di chuyển.
2. Bật quái đi, target click/chuyển TAB và lần lượt bấm 1–7; chụp charge / peak / contact của từng skill với mục tiêu thay vị trí; nhìn clipping và các lớp che mặt.
3. Kiểm tra mark TAL03 bám quái đủ pha visual hold; HF02 không chạy theo quái khi vùng đã khóa; quái có thể rời vùng.
4. Kiểm tra lỗi asset missing và trong log `QA49_VISUAL_CONTACT_ONLY`, đảm bảo **không có HP/damage receipt giả**.
5. Ghi exact source SHA của Godot repo khi chạy, hash PDF/PNG evidence, fps trên máy thực; quan sát lại 1x/2x/3x. Chủ sở hữu duyệt mỹ thuật riêng.

**Không merge, rig, Codex, V6.3 bật, Combat V2/SaveService/economy/AI/PvE thay đổi.**
## R1 transfer / QA checkpoint (do not claim native PASS)
- ChatGPT Library: `/TMB-Character-Art/AS_CHAR49_V10_POISON_TALISMAN_MOVING_LAB_R1_20261116.zip`.
- Transfer ZIP SHA256: `a271446dad18a8c9d5ab3b6a61ac0278b58d6bc950911043a4db32381d05ed28`; 30,698,020 bytes; **256 entries**, ZIP CRC PASS.
- This package contains **240 original V10 PNG** (byte-preserved), retargeted SpriteFrames path only, **8 verified first-party approved HF02 R6/HF03 R2 WEBP atlas assets**, Godot source QA moving stage, installer, and file-hash manifest.
- Original asset evidence: HF02 R6 workflow artifact `14194687188`; HF03 R2 workflow artifact `14195924457`. V10 source ZIP SHA is recorded above.
- Godot scene source committed at `godot/labs/combat_lab/as_char49_vfx_playtest/playtest.{gd,tscn}`, `fx_layer.gd`; **binary character assets intentionally remain only in separate transfer ZIP** to avoid unreviewed production imports or GitHub-large-asset churn. Install ZIP Lab directory locally into the corresponding `godot/` before running.
- Bridge uses original Poison/Talisman source textures by path from the current PR branch. The bridge's new dynamic placements/timing are **not owner approved** merely because the source art is.
- **Static transfer checks: PASS** (240 references resolvable within transfer ZIP; 8 atlas SHA checked; ZIP CRC PASS). **Godot 4.7.2 import/scene/Windows physical QA/native 1280×720 movie: NOT_RUN**. **No real runtime hit receipts / HP/status** by design.
- Controls: WASD/arrows hero move; 3 real moving monster SpriteFrames (if repo asset installed); click/TAB lock target; 1–7 owner-approved visual packs; SPACE attack; M toggle mobs. Death_Left absent; known Cast/Hit clipping unchanged.
- Never mark runtime or owner review PASS until a real native Godot run and human inspection at exact source SHA.
