# AS-CHAR-49 — BÀN GIAO CHAT MỚI: KIẾM TU NỮ (2026-11-14)

## Mục tiêu duy nhất
Tiếp quản và **thực sự sản xuất** trọn bộ animation **NỮ KIẾM TU** của game Tông Môn Bá Đạo, theo quy trình chất lượng đồ họa cao (Source-A-inspired high-resolution source / display-downscale) đã áp dụng cho Kiếm Tu nam AS-CHAR-48.

**Đừng trả lời bằng kế hoạch hay ảnh turnaround/poster thay cho sản phẩm.** Khi không thể tạo thật một hành động, báo ART_BLOCKED thật và giữ clip không đạt ra khỏi game.

## Dự án / safety contract
- GitHub `vuanhtuan161094-byte/TongMonBaDao`, chỉ **Draft PR #72**, nhánh `integration/pve-p0-playable-ui-20261103`.
- Vào chat mới **luôn kiểm tra HEAD mới nhất**. HEAD đọc khi soạn handoff này: `52dc73450bf05f61afad718624cbe6a3c58ba115`; nó KHÔNG phải khóa vĩnh viễn vì các chat khác cùng làm repo.
- Đọc `AGENTS.md`, tài liệu nữ, báo cáo lỗi AS-CHAR-49, tài liệu nam AS-CHAR-48, và Issue #77. Không tự tạo nhánh, merge hay đụng gameplay/Combat V2/SaveService/economy/V6.3/PvE; không làm rig/Skeleton2D/Bone2D. Đừng dùng Codex vẽ người bằng hình học thô.
- Tài liệu bắt buộc:
  1. `docs/animation/TMB_KIEM_TU_FEMALE_ART_DIRECTION_AND_PIPELINE_20261114.md` (fem art authority)
  2. `docs/animation/AS_CHAR49_FEMALE_SPEC_VIOLATION_AUDIT_20261114.md` (sai lầm đã kiểm)
  3. `docs/handoffs/AS_CHAR48_KIEM_TU_MALE_24_CLIP_TECHNICAL_DRAFT_20261114.md` (pipeline nam; male = technical draft only)
  4. `docs/animation/TMB_KIEM_TU_BAKED_SWORD_OWNER_CHOICE_20261114.md` (vũ khí gắn sẵn, giới hạn chủ yếu dành cho nam)
  5. `docs/animation/TMB_KIEM_TU_SOURCEA_HIRES_ZOOM_LOCK_20261114.md` (chỉ học nguyên lý độ nét, phần tách kiếm cũ đã bị quyết định mới thay thế)
- Source female trong Thư viện ChatGPT cá nhân: `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` (mẫu 4 hướng tóc tím đen, hoa lam-trắng, kiếm bạc lam, không có xác nhận đã cài game); `KIEM_TU_INTERACTIVE_QUALITY_REVIEW.html` (B+C female reference). Nếu kết nối Thư viện không cho materialize raw bytes, đọc ảnh qua Files image_file rồi ghi blocker, KHÔNG bịa nguồn đã có.
- Gói nam chỉ làm pipeline reference, tải từ Library `/TMB-Character-Art/AS_CHAR48_KIEM_TU_MALE_24_CLIP_TECHNICAL_DRAFT_20261114.zip`, SHA256 `0c33c99bffa9911799cf13b23d74c55a36c94764ab6b0ddd721370ef86a5f11f`. Hãy kiểm tra thực tế khi có bytes; không tuyên bố tự đã tải.

## Nhận diện nữ phải nhất quán
- **Tóc tím đen/indigo** dài, búi cao; trâm/hoa trắng-xanh, dây lụa xanh, mắt xanh tím, dấu ấn Kiếm Tu nhỏ trên trán.
- **Áo xanh nhạt/trắng/bạc** nhiều lớp, hoa văn tinh tế, quần tối và giày thấp; nữ trưởng thành chibi khoảng 3–3,5 đầu, dáng nữ phân biệt với nam.
- **Kiếm thẳng bạc lam** phải giữ y hệt trong các frame và **gắn sẵn trong sprite**. Không sử dụng tóc trắng bạc / kiếm đỏ-đen / gương mặt nam của Kiếm Tu nam làm thay thế.
- Bản nữ 4 hướng tạo cuối chat dưới tên `indigo_sword_cultivator_turnaround.png` là **concept chưa được owner duyệt**. Không lấy làm master khóa hoặc kết luận animation hoàn thiện. Các poster “24 clips hoàn chỉnh” và GIF tóc bạc/kiếm đỏ bị loại.

## Hợp đồng sản phẩm
- **24 clip thật** = 4 hướng **front/right/back/left** × **Idle/Walk/Attack/Cast/Hit/Death**; hướng vẽ độc lập không biến dạng/rotate/mirror trái thành phải.
- Frame xuất **512×512 RGBA**, chân chung **(256,442)**, thân hiển thị khoảng **320 px** từ ảnh nguồn lớn; trong map 75px, zoom2 ~150px, zoom3 ~225px. Đủ mép cho tóc/kiếm/VFX, không cắt cụt.
- Idle = thở/tóc/áo động thực; Walk = bước chân trái/phải và đổi trọng tâm; Attack = lấy đà/vung kiếm/thủ thế, cung kiếm đi qua tay thực; Cast = đứng kết ấn/tụ lực/phóng ra rồi hồi, không trá hình Attack; Hit = giật/lùi/hồi, không chém; Death = loạng choạng/ngã/nằm giữ frame cuối, không đồ họa bạo lực.
- Export từng frame PNG RGBA source, 24 atlas độc lập, 24 GIF xem chuyển động, 1 Godot 4.7.2 `SpriteFrames`/scene độc lập, manifest SHA256 cho nguyên bản/các frame/atlas, số frame **distinct** và thời lượng/loop semantics. Chỉ ghi PASS khi thẩm tra nguồn.
- Kiểm soát source **theo magic MIME chứ không theo đuôi**: file đặt tên `.png` có thể thực ra là GIF. GIF từng frame toàn ảnh, KHÔNG cắt từ contact sheet hay poster. Kiểm tra alpha trên nền tối/nhạt, bbox clipping nguồn & ô atlas, foot contact, tóc/kiếm/hoa nhất quán, so sánh 1×/2×/3×, ảnh 512 có đúng pixel và đúng tọa độ.
- **Godot 4.7.2 exact-SHA**: import + preview thực 1280×720 và video/GIF capture từ chính engine, báo log/test; KHÔNG lấy offline FFmpeg/Python render gọi là video Godot. Chưa có engine GUI = ENGINE_PENDING. Nghiệm thu mỹ thuật OWNER riêng.
- Không tự đưa vào game chính / đổi đệ tử nữ cho tới khi 24/24 nguồn/chuyển động QA và owner duyệt.

## Bài học từ lượt cũ: KHÔNG LẶP
1. Chỉ sinh các ảnh tĩnh/turnaround hoặc poster được viết “24 clips”, sau đó tuyên bố thành công: **FAIL**.
2. Gen Walk lặp đi lặp lại trong khi yêu cầu Attack/Cast/Hit/Death: **FAIL**.
3. Đổi sang nữ tóc bạc, nam tóc bạc, kiếm đỏ đen, phụ kiện khác giữa frame: **FAIL**.
4. Dùng preview sheet làm nguồn cắt atlas, alpha giả nền caro/đen, cắt người hụt, khung hình thừa: **FAIL**.
5. Trả về câu hỏi có làm được không, một kế hoạch chung chung, hoặc đòi owner tự dùng LibreSprite: **FAIL**.
6. Nam AS-CHAR-48 đã có 24 slot technical draft nhưng **chưa phải production ART/GODOT PASS**: không viện dẫn làm bằng chứng nữ đã xong.

## Chiến lược chat mới (đừng làm ẩu hàng loạt)
1. Đọc đủ source và review lại toàn bộ before art; kiểm tra HEAD và đúng nguồn nữ.
2. Xuất một **master nữ bốn hướng đẹp/nhất quán** (có thể làm lại từ female B+C chuẩn) và **duyệt mỹ thuật trước**. Nếu master đã có source thật và approved thì reuse, không sáng tác lại.
3. Sản xuất **cặp Walk-right / Attack-right** đúng tư thế thật từ cùng nguồn — kiểm tra một GIF thay đổi từng frame, 512 transparent atlas, quality 1×/3×. Fail phải sửa nguồn, không đổi tên/hạ tiêu chí.
4. Xây dần thật: Walk 4 hướng; Attack 4; Idle, Cast, Hit, Death 4. Tự kiểm trước khi mở rộng. Không phải chờ owner làm thao tác phần mềm.
5. Xuất dự án Godot 4.7.2 và chứng cứ engine, hỏi owner duyệt mỹ thuật sản phẩm thật.
6. Báo tiến độ **x/24 moving candidates, y/24 production approved** hai số riêng, clip thiếu/FAIL rõ. Không được tạo 24 file giả.
7. Lưu binary ZIP nguồn vào Library / bảo đảm hướng dẫn tìm nguồn cho chat sau, tài liệu chứng cứ lên GitHub.

## Trạng thái lúc bàn giao
- Female old refs located in Library, new 2×2 female turnaround concept image generated but **NOT APPROVED**.
- Một số GIF nữ Walk 8–9 frame nằm trong chat cũ, nhiều file có lỗi nguyên liệu (nguồn bị trộn nhân vật, matte opaque, hình thừa).
- **0/24 female clip production approved; no female animation pack with validated 24 GIF+atlas+SpriteFrames; Godot NOT RUN.**
- Các file nguồn binary không phải chỉ cần có đường dẫn Github là tải được; khi cần, phải lấy đúng bằng công cụ Files/Library hoặc file đính kèm.
- Mục tiêu hiện tại là Nữ Kiếm Tu; **không mở rộng 11 môn phái còn lại**.
