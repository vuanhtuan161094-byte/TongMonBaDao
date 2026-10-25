# TÔNG MÔN BÁ ĐẠO — Disciple Asset Library V2 / Owner correction

Date: 2026-10-26
Status: **OWNER ART REJECTION / DESIGN-AND-PRODUCTION BRIEF ONLY**; NOT IMPLEMENTED; NO GODOT RUNTIME CLAIM
Source PR: #40, branch `art/disciple-asset-pilot-a1-20261025` (A1 local imagegen output, not accepted).

## 0. Quyết định owner thay thế cách làm A1

Owner không chấp nhận sản phẩm chỉ có hai chân dung full-body trông tương tự nhau. Không được tiếp tục lặp hai concept thành 10/100 tranh có cùng khuôn mặt, đầu, áo, pose và bảng màu khác nhau. Người làm asset phải chủ động kiểm tra và tự làm lại khi thấy không đạt; **mục tiêu là một bộ thư viện asset có thể ghép, thay đổi và hoạt hình trong Godot**, chứ không phải tập ảnh chân dung.

**Phân biệt ba loại deliverable:**
1. Concept/profile illustration: tranh xem và duyệt ý tưởng, KHÔNG tính là map asset hay rig.
2. Authored modular production art: cutout body/face/hair/outfit/weapon/accessory/tint mask có hướng và pivot đúng.
3. Runtime-approved asset: (2) đã import, chạy shared rig/idle/walk trong official Godot 4.7.2, có screenshot và test trên exact SHA.

Hai tranh Nam Kiếm Tu/Nữ Pháp Tu trong Recovery A1 chỉ thuộc (1), cần xét lại mỹ thuật, **không được gắn nhãn owner-approved**. File .ora với tranh phẳng và crop chi tiết không được tính là modular source layers.

## 1. Nguồn và giới hạn bất biến

Bắt buộc đọc live `AGENTS.md`, `CURRENT_CHECKPOINT.md`, `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ART_BIBLE.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`, `docs/P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md`, `docs/P3_2_ASSET_MANIFEST.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md` và code/rig hiện hành trước khi sản xuất.

Style **Source A / mature chibi 2D hand-painted xianxia** là hướng đã chọn cho game; không biến toàn game thành pixel art, realistic illustration hay glossy gacha. Tuy nhiên chibi là **tỷ lệ cơ thể**, không phải một khuôn mặt và một bộ đạo bào mặc cho tất cả. Được tự quyết sáng tạo dựa trên phong cách, chức năng, tuổi tác thể hiện qua hình, vùng miền, địa vị, cá tính; không cần bám máy móc hai brief Nam Kiếm Tu/Nữ Pháp Tu cũ.

Để thử xem engine tạo hình hỗ trợ bao nhiêu biến thể, tác giả có thể làm **bảng nghiên cứu A/B/C** tách biệt:
- A. Source A-compatible: mảng màu vẽ tay, bóng mềm, nét mực gọn (default cần chọn).
- B. Ink-wuxia: nét bút/thủy mặc giản lược hơn, bớt bóng, chủ yếu đa dạng silhouette.
- C. Clean stylized 2D: mảng lớn/cel mềm, mặt cách điệu rõ tính cách.
Đánh giá ở **kích thước runtime**. Chỉ style phù hợp art bible mới được đưa vào production; không ghép 3 hệ hình họa khác nhau trên cùng map. A/B/C là art exploration, không phải owner quyết định thay Source A.

## 2. Character diversity: thiết kế danh tính trước, thay vì prompt lặp

Mỗi nhân vật/preset cần **character design identity card** có: tuổi tác biểu kiến (tất cả là nhân vật trưởng thành), khí chất, nét mặt/eyes/eyebrows/face-shape, tóc, khối thân, silhouette trang phục, dấu hiệu nghề/nguồn gốc, màu có lý do, weapon/socket, 3-view continuity. Không gán môn phái, class, sex, stats, quality hay equipment gameplay trái authority; vũ khí preview là cosmetic.

Đề xuất 12 mẫu **phải phân biệt bằng hình dáng ngay cả khi bỏ màu**; danh mục tham khảo, artist được cải tiến:
1. Nam kiếm khách du phương: mặt thon dài, lông mày sắc, tóc buộc thấp lệch, áo ngắn tà xẻ, kiếm thẳng.
2. Nam thư sinh/Pháp tu: mặt thanh tròn, ánh mắt hiền, búi tóc cao, áo ngoài cổ chéo dài, sách/phù hoặc pháp khí.
3. Nam Thể tu: mặt vuông, mày rậm, tóc cắt sát hoặc quấn khăn, băng tay/áo cụt, quyền sáo. Nếu cần heavy rig thì CHƯA production cho đến khi contract mới được duyệt; proof dùng normal rig với silhouette hợp lệ.
4. Nam lão đạo sĩ: mặt gầy nhiều tuổi, ria/râu, tóc bạc búi, áo rộng có lớp choàng, phất trần.
5. Nam luyện đan sư: mắt cụp, búi tóc nhỏ, tạp dề vải và túi dược liệu, cán gỗ/hồ lô.
6. Nam ngự thú/rừng núi: mặt rám/khắc khổ, tóc rối xõa, áo choàng ngắn da-vải, vòng dây/đạo cụ rừng.
7. Nữ kiếm khách lạnh lùng: mặt góc cạnh, mày thẳng, tóc đuôi ngựa cao, áo giáp vải gọn, kiếm dài.
8. Nữ Pháp tu thanh nhã: mặt oval, mắt dài, tóc nửa búi nửa xõa, đạo bào tay rộng có 2 khối tà lớn, trượng/pháp châu.
9. Nữ y tu: mặt tròn phúc hậu, tóc tết gọn, cổ áo kín, áo choàng gọn và túi thuốc.
10. Nữ đan tu: mặt trưởng thành, mày cong, tóc búi thấp kẹp trâm gỗ, tạp dề ngoài đạo phục, hồ lô.
11. Nữ ma tu: gò má sắc, mắt xếch, tóc lệch bên, áo choàng bất đối xứng, phù văn đơn giản; KHÔNG neon hoặc fanservice mặc định.
12. Nữ tu sĩ bình dân: mặt bầu, mắt nhỏ, tóc quấn khăn, áo lao động tay xắn/váy quần, công cụ thật.

Không lấy giới tính làm cách phân biệt duy nhất; trong mỗi nhóm phải có nhiều hình mặt, độ dài tóc và hình cổ áo khác nhau. Mẫu càng khác biệt silhouette thì càng tốt, miễn vẫn cùng visual universe và rig.

**Diversity dimensions tối thiểu**: (a) hình mặt + tỷ lệ mắt/mũi/miệng/lông mày, (b) hair silhouette, (c) cổ/vai/tà áo/cánh tay/trang phục, (d) headwear/phụ kiện/vũ khí. Chỉ đổi màu áo hoặc vật đeo là **KHÔNG đạt**. Lưu metadata tags (e.g. `face_shape`, `expression_family`, `hair_silhouette`, `outfit_silhouette`, `persona`) để có thể kiểm kê trùng lặp.

## 3. Target bộ thư viện, không phải 100 tranh phẳng

**Production target V2** (chỉ target, tuyệt đối không tự gọi hoàn thành):
- Shared rigs: `female_normal_v1`, `male_normal_v1` có ảnh và motion thật; mở rộng heavy/special sau khi proof và owner duyệt, không đổi rig contract hiện hành.
- Mỗi normal rig: **6 face variants**, **8 hair variants**, **6 outfit families** có cấu trúc khác nhau, không phải chỉ tint, và body cutouts chuẩn.
- Thư viện chung tương thích slot: ít nhất **6 weapon/props**, **4 head accessories**, **4 other accessories**, và color palettes/tint masks có chủ đích.
- **12 curated archetype presets** như trên, đồng thời sinh được **100 deterministic appearance presets** khác nhau từ actual parts, KHÔNG vẽ 100 nhân vật full-body độc lập.
- Có đủ **3 authored directions** (down/right/up) cho asset cần thiết; public left từ right only if mirror-safe.
- Có shared idle/walk thực, với z-layer và chân ổn định. Không animate tranh full-body phẳng và coi đó là shared-rig asset.

Kết hợp face/hair/outfit/weapon phải được ràng buộc bằng compatibility manifest, tránh xuyên tóc, va trang phục hoặc giả vờ mọi bộ phận đều hợp nhau. 100 preset là **đầu ra của bộ lắp ghép**, không phải 100 PNG phụ thuộc nhau. Tạo trước 12 preset với profile/lineup rõ nét để kiểm chứng đa dạng, rồi mở rộng theo thực lực pipeline; không dùng tổ hợp lý thuyết làm chứng cứ art hoàn thành.

## 4. Pipeline bắt buộc: art trước, cutout từ nguồn thật, runtime sau

Stage 0 — **Inventory chính xác**: xem pack Source A thật và hiện trạng P3.2 rig, tách baked 768x768 frames khỏi modular 128x128 contract; đối chiếu style từ source, không dùng source để đổi tên thành art mới.

Stage 1 — **Art direction exploration**: một bảng A/B/C với ít nhất 4 archetype có hình mặt, tóc, cổ áo và silhouette khác nhau (không phải 4 recolor). Cho phép tự chọn nhánh phù hợp Source A art bible sau đối chiếu 60–75 px game scale; ghi rationale/nguyên nhân loại, không chờ owner từng bước.

Stage 2 — **Character model sheets**: triển khai 12 identity designs; mỗi mẫu có front/side/back turnarounds nhất quán. Nếu model không tạo được các hướng nhất quán, báo lỗi, vẽ lại / dùng artist cutout — KHÔNG hallucinate 3D views.

Stage 3 — **Source art thật**: tạo riêng từng part (body head/torso/arms/legs, face, hair front/back, outfit per bone, weapon socket, accessory, tint mask) trong file layer gốc, không chỉ crop từ tranh phẳng. 512x512 source master cho 128x128 export hợp lệ. Giữ exact canvas 128x128 và foot anchor (64,104), trục x=64, không recrop. Apply compatibility manifest.

Stage 4 — **Godot runtime**: chạy một shared `Skeleton2D` + `AnimationPlayer` trên normal rig, public idle/walk 4 hướng, chân không trượt; 1280x720 và zoom .75/1/1.35. Preview grid gồm 12 archetypes rồi 100 presets. Chỉ thay presentation asset/tool-owned paths; tuyệt đối không chạm SimulationState/save/combat, không giả equip hay active job.

Stage 5 — **QA độc lập**: kiểm alpha/pivot/transparent edges, seams, direction consistency, mask tint, weapon occlusion, frame stability; official Godot 4.7.2 import/parse/playback nếu môi trường cho phép. Lưu screenshots thật, actual logs + SHA. Test 100 instances trên target profile nếu có khả năng, **không phỏng đoán FPS**.

**Checkpoint nội bộ** sau Stage 1 hoặc một rig proof chỉ là `PARTIAL`, không dừng và nói đã hoàn tất toàn bộ library. Nếu bị chặn bởi công cụ/GUI, output phần thật đã làm và ghi rõ blocker.

## 5. Anti-clone QA: chống 100 nhân vật có một mặt

Các file bằng chứng cần có:
- `style_board_abc.png`: các rendering approaches là nghiên cứu, không phải production được duyệt.
- `12_archetypes_color.png` và `12_archetypes_grayscale.png`, tất cả nhân vật hiển thị **cùng chiều cao trên map**, không phải full-res portraits.
- `face_lineup.png`: ít nhất 6 mặt/rig với mắt, đường hàm, lông mày và hairline có khác biệt thực, tránh cùng một gương mặt rồi chỉ thêm râu.
- `outfit_silhouette.png`: ít nhất 6 outfit/rig, silhouette đọc được khi grayscale, không chỉ màu.
- `100_variants_grid.png`: 100 appearance profiles sinh từ actual asset-part IDs, với seed và mapping tái hiện được; chỉ cung cấp khi đã có art and rig thật.
- `rig_motion_contact_sheet.png`, actual Godot screenshots/logs khi thực sự chạy.
- Source layered document + export PNG RGBA full registration + manifest SHA-256, art provenance + compatibility rules.

**Reject ngay** nếu 12 presets phần lớn cùng mặt/cùng cổ áo, nếu khác biệt chỉ là palette/phụ kiện, nếu ORA là một lớp flatten kèm crop trang trí, nếu không có cutout thực, nếu chỉ ảnh concept mà được gọi runtime, nếu compare chỉ dựa vào ảnh phóng to, hoặc nếu robot tự tuyên bố `PASS` dù Godot chưa chạy. QA nghệ thuật là đánh giá thị giác thực, không thể thay bằng hash pass.

## 6. Storage / repository / phạm vi

A1 PR #40 đang là Draft; không merge. Không tự ý sửa `main`, renderer production, gameplay, simulation, save, combat/economy, hoặc Source A nguyên bản. Nếu repo chưa khóa Git LFS/asset storage, lưu output binary local thành gói có checksum, kèm manifest trong PR và **nói rõ GitHub không chứa PNG/ORA**. Không ghi đường dẫn local giả làm URL xem được trong GitHub. Nếu cần đưa binary lên repo thì phải chốt transport/storage trước.

**Kết quả hiện tại khi viết tài liệu này:** chỉ tạo tài liệu sửa yêu cầu; CHƯA sản xuất thêm asset mới, CHƯA QA runtime. Không dùng PR docs change để gọi Asset Library V2 PASS.

## 7. Command cho agent/Codex tiếp tục

"Đọc `docs/handoffs/2026-10-26/DISCIPLE_ASSET_LIBRARY_V2_OWNER_CORRECTION.md` trên branch `art/disciple-asset-pilot-a1-20261025`, cùng AGENTS/P3 art bible/P3.2 contracts; tạo **thư viện modular đệ tử đa dạng thực sự** thay cho hai profile painting. Tự khảo sát style A/B/C, tự chọn chất lượng Source A hợp nhất, sản xuất body/face/hair/outfit/weapon với file nguồn tách layer, 3 hướng, anchor và cutouts; dựng shared rig, xuất 12 archetypes khác nhau và 100 presets dựa trên actual parts, có QA thị giác ở game scale. Không claim hoàn thành nếu mới làm ảnh portrait, recolor, hash hoặc docs. Không chạm gameplay/production code, không merge; nêu chính xác phần thiếu nếu gặp giới hạn tạo hình/rig/Godot." 
