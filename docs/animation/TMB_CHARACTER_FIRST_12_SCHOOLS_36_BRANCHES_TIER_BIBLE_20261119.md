# TÔNG MÔN BÁ ĐẠO — CHARACTER-FIRST ART BIBLE · 12 MÔN PHÁI × 36 NHÁNH

**Bản:** CF-36 V1 · 19/11/2026 · **Trạng thái:** DESIGN_DIRECTION_PROPOSED / OWNER_ART_REVIEW_PENDING  
**Đối tượng:** Nhân vật đệ tử trước; VFX gắn sau, nhưng định nghĩa visual hooks ngay từ bây giờ.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · Draft PR #72 · `integration/pve-p0-playable-ui-20261103`  
**HEAD kiểm tra khi mở soạn:** `2d05b7772b8a842cf470fd63b68b37d26126aaee` (không coi là HEAD cố định)  
**Bất biến:** Không Codex Cloud; không rig/skeleton; không GIF mặc định; không sửa gameplay/Combat V2/SaveService/economy/V6.3; không mở PvE/G8; không merge; không thay asset đã được duyệt.

> Tài liệu này là **bản bổ sung định hướng tạo hình từng nhánh** cho `TMB_DISCIPLE_UNIFIED_ART_BIBLE.md`, `TMB_DISCIPLE_SCHOOL_IDENTITY_BIBLE_20261117.md`, `TMB_DISCIPLE_SCHOOL_VISUAL_MOTIFS_20261111.md` và `TMB_DISCIPLE_MODULAR_SPRITE_STANDARD_V1_20261114.md`; **không lập SOP kỹ thuật cạnh tranh**, không thay các bản nguồn owner-lock. Các mô tả Tiên/Thần là **định hướng nghệ thuật đề xuất**, không phải các tier asset/gameplay đã có hoặc đã duyệt.

## 1. Nguồn thẩm quyền và trạng thái thật

1. **Danh mục 12×3 chính xác** lấy từ `docs/operations/TMB_VFX_SCHOOL_BY_SCHOOL_MASTERPLAN_20261113.md`, kiểm tra lại với `docs/operations/vfx_school_ledgers/01_poison_183.csv` đến `12_summon_183.csv` khi sản xuất. 36 tên nhánh là canonical **định danh**, còn tạo hình dưới đây là đề xuất.
2. **Nữ Độc Tu V4 đã khóa tạo hình**: `godot/labs/character_family/assets/nu_doc_tu_v4_candidate/owner_approved_master.png`, SHA-256 `435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118`. Không sao chép y nguyên mặt/tóc cho các môn; không đổi master đã duyệt. Các clip cũ không vì thế được duyệt.
3. **Kiếm Tu nam owner-liked**: tóc bạc trắng buộc cao, xanh/trắng/bạc, ấn kiếm đỏ, vũ khí tham chiếu đỏ-đen bất đối xứng; nguồn ảnh gốc theo tài liệu owner-lock không chắc nằm trên GitHub. **Kiếm Tu nữ** có hướng xanh-bạc/tím chàm riêng. Không thay bản được ưng bằng generic sword style.
4. **Issue #77, 19/11**: 576 clip **BODY CANDIDATE**, có tình trạng không đồng bộ mỹ thuật, thiếu weapon props; đã quan sát lỗi AS65 Back và AS54/55 Downed, nghi vấn alpha Kiếm Tu Right. Các lỗi này **không được xóa bằng bảng đếm hash**. Nguồn bulk E: chưa được xác minh đã nhập đầy đủ vào PR #72.
5. Bộ tạo hình trước đó gắn tên Shadow Pixel-Chibi; **không ép tên style này là phong cách cuối cùng**. Quy chuẩn là **gia đình nhân vật 2D tiên hiệp trưởng thành, độ tinh xảo/màu/tỷ lệ được đo trên những nguồn owner-liked thật**. Hướng sắc nét/pixel cluster có thể dùng **nếu đồng nhất**, không trộn hình smooth/anime với nhân vật pixel mờ. Không tự tái thiết kế nhân vật đã khóa.

## 2. Sáu trục không được đánh đổi

- **Cùng một family:** đầu/thân 3–3,5 đầu, tuổi trưởng thành, cùng tỷ lệ mắt/mũi/miệng, độ tương phản khối vải–tóc–da–kim loại, ánh sáng chính từ trên trái, cùng nét viền/alpha. Không làm 12 phái bằng 12 loại render.
- **Mỗi môn một hình lớn:** cơ thể/áo/tóc + vũ khí hoặc pháp khí phải cho silhouette của môn phái ở màn hình thật; palette chỉ là phụ.
- **Mỗi nhánh ba tín hiệu:** (a) cấu trúc áo–vai–eo hoặc tóc/ornament; (b) vật cầm hoặc vị trí tay đặc trưng; (c) một tư thế động rõ khác nhánh kế bên. Phải phân biệt được trong grayscale và không có VFX.
- **Nam/nữ cùng nhánh không phải clone:** cùng vũ khí–motif nhưng khuôn mặt, tóc, vai, phân bố tà áo khác; tránh tự thay giới tính hoặc vũ khí khi chuyển 4 hướng. Không ép vũ khí theo giới.
- **Body / weapon / VFX tách biệt:** full-body frame-by-frame thật; held items là RGBA độc lập có grip, tay trước/tay sau và thứ tự che; projectile/kiếm bay/linh thú/khôi lỗi/khí sáng là hệ riêng. Quyền/Chưởng tay không.
- **Gameplay-size trước chi tiết:** map actor cỡ hiển thị khoảng 60–75px ở 1× là chuẩn hiện hữu; export P3 128×128 foot (64,104), combat V4 160×192 foot (80,179) là **hai hợp đồng riêng**. Nguồn vẽ lớn (ví dụ các pilot 512×512 / khoảng 400px body) **không phải** lời hứa import trực tiếp; giữ nguồn đủ lớn, xuất bằng bộ chuyển đúng cho từng context, không co giãn tùy tiện.

## 3. Tiến hóa Nhân → Tiên → Thần (chốt cách đánh giá, CHƯA mở sản xuất Tiên/Thần)

| Trục | Nhân — sản xuất trước | Tiên — chỉ thiết kế | Thần — chỉ thiết kế |
|---|---|---|---|
| Nhận diện | Một silhouette, prop và động tác nhất quán | Giữ DNA Nhân, đường áo/vũ khí tinh luyện thành cấu trúc mới | Đạt hình tượng pháp tắc của chính nhánh, **không** đổi thành aura chung |
| Trang phục | 2–3 khối vải/giáp lớn + một ornament chính | thêm một lớp có chức năng thị giác, thay đường may/ngọc/kim khí | đổi tổ chức tà áo/giáp/cổ vai thành hình tượng mạnh hơn, đọc được khi tắt VFX |
| Vũ khí/pháp khí | Một weapon/tool cùng họ thật, gắn đúng tay | thay đổi hình thân, sống/đầu/hộ thủ/khế vật | hình dạng hoàn thiện, nghi lễ/cấu trúc quyền uy nhưng **không tăng số vũ khí/hit** nếu không có contract |
| Hình chuyển động | lực từ vai/hông/tay + follow-through + hồi thế | tiết chế hơn, điều khiển lực bằng nhịp rõ, có độ chính xác | sức nặng/uy thế đến từ bố cục và diễn hoạt, không chỉ chuyển động nhanh/to hơn |
| VFX gắn sau | vật liệu sáng RGBA có hình, một logic đánh | hình tượng tiến hóa có lớp thứ cấp | pháp tắc hóa đúng family, không biến mọi nhánh thành vòng tròn/thiên tượng generic |
| Ranh giới | Không bịa damage/status | Không tự cấp cơ chế mới | Không tự thêm mục tiêu, tick, buff, summon hay đổi tier combat contract |

**Chỉ nhận một tier là khác biệt thực khi tắt toàn bộ VFX và chuyển ảnh sang grayscale vẫn đọc được ít nhất 2 thay đổi về hình dạng/cấu trúc, trong khi identity và weapon family vẫn liên tục.** Hạt sáng/bloom/đổi màu/phóng to không tính là thay đổi tier. Tiên và Thần có thể cần thay pose đích thực, không rig. Giữ Nhân hoàn thiện qua owner gate trước khi tạo asset tier tiếp.

## 4. 12 môn phái · chi tiết đủ 36 nhánh

**Cách đọc:** Mỗi dòng là một *thiết kế ứng viên*, không phải hình ảnh, sprite, trang bị hay VFX đã xuất xưởng. Cột VFX chỉ là visual hook để nhóm VFX về sau bám đúng hành động nhân vật, **không ghi đè** `effect/shape/target_limit` trong catalogue.


### 01. Độc Tu (`poison`)

**DNA:** thao tác cổ tay tinh vi, độc–cổ–dược; áo choàng đen/ngọc có cấu trúc tay áo hữu dụng. **Màu chức năng đề xuất:** ngọc lục / đen tím / vàng cổ. **Cấm lẫn:** không clone mặt/tóc Nữ Độc Tu; không vẽ rắn, độc vụ, ký hiệu gây sát thương vào body.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Độc Châm** | Cổ tay lộ, ống châm dọc cẳng tay, vạt áo ngắn bất đối xứng; tóc thu gọn để tay đọc rõ | Ống kim + một châm tách RGBA; ngón kẹp kim, búng thẳng cổ tay | Tiên: hộp châm ngọc có cấu trúc cánh; Thần: vòng giá châm phân tầng đeo sau vai (trang sức, không tự thêm hit) | kim quang mảnh, điểm chích chính xác |
| **Cổ Độc** | Cổ áo cao, tay áo ngoài rủ như kén, bùa buộc hông nhỏ; silhouette khép kín | Bình cổ/khế hộp nhỏ bên hông; hai tay kết ấn trước ngực, không phóng vật thể giả | Tiên: nếp áo như kén mở; Thần: mảng giáp hữu cơ đối xứng lệch vai, vẫn có khoảng tay ấn | dòng cổ khí hữu cơ, neo bám mục tiêu |
| **Dược Độc** | Thân áo xếp lớp mềm, túi dược nhìn rõ, đai và thắt lưng cân; tư thế bình tĩnh | Hồ lô thuốc / túi dược tách lớp, tay đong–phẩy dược; không lẫn ống kim | Tiên: dây buộc bình ngọc tinh tế; Thần: bệ dược/giá nhỏ đeo sau lưng với hình lá lớn, không tự tạo heal | dược quang tỏa, hạt thuốc–độc riêng biệt |

### 02. Phù Tu (`talisman`)

**DNA:** giấy, bút, ấn giấy, động tác viết–niêm–phát; tay áo gọn; giấy thật là tín hiệu. **Màu chức năng đề xuất:** giấy ngà / chu sa / mực đậm. **Cấm lẫn:** không gắn vòng trận dưới chân, không biến thành Chú Tu chỉ cầm chuỗi hạt; không dùng chữ AI sai.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Lôi Phù** | Vạt áo dựng thẳng như vệt mực, hộp phù trước ngực; cổ tay trái đeo khoen giấy | Một tờ phù dựng thẳng + bút/ống phù; nâng phù rồi chỉ lên | Tiên: mép ấn giấy nhiều tầng; Thần: giá phù ba cánh gấp sau lưng (ornament, không 3 lần sét) | đường lôi từ nét phù, nhánh điện ngắn |
| **Hỏa Phù** | Áo gọn thắt ngang hông, cổ và tay áo có đường xẻ tam giác; dáng phóng nhanh | Phù gập cạnh + bút lông ngắn; rút–vuốt–đưa thẳng tay ra | Tiên: ống đựng giấy cách nhiệt hoa văn răng lửa; Thần: hộp phù xòe như quạt lửa sau vai | mực khai hỏa rồi luồng lửa có hình |
| **Phong Ấn Phù** | Tà áo vuông và khóa đai như niêm phong; vai và cổ tay có hai miếng kẹp đối xứng | Lá niêm/hộp ấn tách lớp; hai tay khép, ấn xuống/đóng lại | Tiên: khóa dấu dạng ngọc vuông; Thần: khung niêm phong 3 tầng sau cổ (không phải vòng AoE) | triện sáng mở–khép, dấu khóa trên mục tiêu |

### 03. Kiếm Tu (`sword`)

**DNA:** trục kiếm thẳng, thân thẳng, thân kiếm thon và dải áo bay theo kiếm; khác đao nặng. **Màu chức năng đề xuất:** lam mực / bạc / trắng; giữ riêng owner-liked Kiếm nam. **Cấm lẫn:** không vẽ cùng một kiếm cho nữ/nam owner-liked; không dùng sword sprite làm kiếm khí nếu không đúng skill.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Ngự Kiếm** | Tay áo dài hẹp, vai thoáng và lưng thẳng; tay dẫn kiếm tạo khoảng âm phía trước | Jian thật tách lớp, một tay chỉ quyết còn một tay đặt cạnh vỏ kiếm | Tiên: trâm kiếm/miếng khiên nhỏ hậu vai; Thần: cổ áo kiếm đạo như hai mũi lưỡi phân tầng | kiếm khí dẫn hướng; kiếm bay riêng chỉ khi contract có |
| **Sát Kiếm** | Thân áo bó phần vai, gấu xẻ sâu, tóc cột chặt; trọng tâm dồn về trước | Kiếm thẳng chuôi ngắn, một tay sẵn rút; trục chém hẹp sát thân | Tiên: sống kiếm và hộ thủ mảnh tinh luyện; Thần: giáp vai lệch hình nhát cắt, không thêm vũ khí | một nhát cắt cực sắc, quang tuyến mỏng |
| **Hộ Kiếm** | Vai vuông, áo ngoài xếp tấm chắn mềm, nẹp cẳng tay có mặt phẳng đọc rõ | Jian và vỏ kiếm cứng chắc, thế kiếm ngang chắn thân | Tiên: nẹp hộ kiếm gập; Thần: tà áo như hai lá chắn mở từ vai, giữ tay kiếm đọc rõ | đường kiếm chắn–gạt, ánh phản chấn có biên |

### 04. Cung Tu (`bow`)

**DNA:** vòng cung thật + dây kéo, thân thanh linh hoạt, bố cục tay nắm–tay kéo; không tay không giả bắn. **Màu chức năng đề xuất:** bạc nguyệt / lam lạnh / nâu da. **Cấm lẫn:** không gắn kiếm, không giấu dây, không biến silhouette thành quyền thủ.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Liệp Ảnh** | Áo ôm gọn, áo choàng một vai tối, bao tên nghiêng; dáng thấp kín | Cung gỗ cong nhỏ + dây thật + ống tên; nắm ngang thấp rồi kéo dứt khoát | Tiên: lớp áo choàng dải hẹp như bóng; Thần: hai cánh ốp cung sau vai, cung vẫn đọc là một | mũi tên ngắm một trục, dư ảnh mỏng |
| **Linh Tiễn** | Cổ áo sáng, tay áo rộng vừa, tóc buộc cao; dáng kéo thẳng và tĩnh | Cung cong đối xứng hơn, sống cung có ngọc nhỏ; kéo dây ngang tầm mắt | Tiên: thanh nẹp ngọc dọc cung; Thần: khung tựa quang vũ trang trí quanh cung không tạo tên phụ | mũi linh tiễn tinh khiết, điểm rơi sắc |
| **Thiên Vũ** | Áo đuôi én xẻ đôi, tay áo tạo hai cánh hướng lên; trọng tâm nâng | Cung lớn hơn nhưng một thân, tay kéo cao chéo, quiver rõ | Tiên: nẹp vai hình vũ; Thần: áo choàng ba lớp như cánh cung mở, không tăng số hit | đường tên hình quạt khi có target contract phù hợp |

### 05. Quyền Tu (`fist`)

**DNA:** nắm đấm, trục vai–hông–chân, lực ép cận chiến; vai chắc, tay gọn. **Màu chức năng đề xuất:** đá tối / đồng / đỏ trầm. **Cấm lẫn:** không dùng palm mở, không thêm găng gai/sword, không vẽ găng khổng lồ bằng glow.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Bá Quyền** | Vai vuông và eo nén, thắt đai rộng, gấu áo ngắn; bước chân trước nặng | Băng quyền dày/giáp mềm cổ tay; 1 quyền kéo hông→đấm thẳng | Tiên: nẹp cổ tay phân đốt; Thần: đai vai trọng lực thành hình núi, không gây hit thêm | khối kình lực nén dày, tiếp xúc cực ngắn |
| **Kim Cang** | Ngực–cẳng tay như tường, tay áo ngắn, hộ vai/đai lớn nhưng không armor full tank | Hai nắm khép trước ngực và chắn; không vũ khí cầm tay | Tiên: tay giáp ngọc nối mạch; Thần: hai tấm giáp vai như trụ bảo hộ, không tự tạo guard buff | sáng hộ thân đặc mà trong, chấn ngắn tại điểm đỡ |
| **Huyết Quyền** | Vai lệch, dây đai bó cẳng tay, áo choàng rách theo thiết kế sạch; dáng tấn rất thấp | Băng quấn son đậm, hai quyền trước–sau, bộc phát một hướng | Tiên: dây quấn như huyết mạch; Thần: giáp ngực có rãnh lực đỏ, không vẽ máu/HP | quyền kình đỏ ruby xuyên sáng, không thành nắm tay rắn |

### 06. Đao Tu (`blade`)

**DNA:** một lưỡi đao cong nặng, vai và hông dẫn quán tính; khác Kiếm thon và Song Đao 2 tay. **Màu chức năng đề xuất:** thép đen / đỏ gạch / đồng. **Cấm lẫn:** không dùng hai vũ khí, không cùng bộ đỏ-đen/tóc của Song Đao mà chỉ đổi tint.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Cuồng Đao** | Vai lệch lớn, áo xẻ vạt xoay rộng, bọc cẳng tay một bên | Một đơn đao lưỡi cong bản lớn; thế mở ngang và bổ quét | Tiên: sống đao nhiều tầng thép; Thần: hộ vai lớn hình cuồng phong có vân dao, một lưỡi duy nhất | mảng trảm khí nặng xoắn ngắn |
| **Trảm Phách Đao** | Cổ áo đứng, vạt trước nhọn và bọc vai sâu; dáng bổ dọc kỷ luật | Một đại đao sống dày, tay hai điểm trên một chuôi khi phù hợp | Tiên: khớp sống đao hình phách; Thần: thân giáp phân khối hình lưỡi chém đổ xuống | trảm khí dọc xé tâm, vệt dư lực dày |
| **Trấn Đao** | Thân đứng vững, áo khoác vai ngang, nẹp cổ tay phẳng; chân trụ mở | Đơn đao đặt ngang chắn; chuôi có khoen chặn lớn | Tiên: nẹp hộ thủ dạng hàm khóa; Thần: cổ áo/giáp vai như thành trì, không tạo AoE giả | nhát gạt chặn, vân lực dồn tại cánh đao |

### 07. Song Đao (`dual_blade`)

**DNA:** hai đoản đao độc lập, nhịp trái–phải và eo linh hoạt; dáng mảnh hơn Đao Tu. **Màu chức năng đề xuất:** than chì / đỏ thẫm / bạc ngắn. **Cấm lẫn:** không vẽ hai kiếm dài, không tạo thêm hit từ dư ảnh, không dùng cùng thiết kế áo giáp Đao Tu.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Ảnh Nhẫn** | Eo rất gọn, một vai trống, bao vũ khí lệch trái–phải; dáng nghiêng | Hai lưỡi ngắn cong khác góc; tay phải rút trước, tay trái giữ sau | Tiên: vạt áo tách hai dải chéo; Thần: cầu vai gấp đôi dấu nhận, hai tay vẫn nhìn được | lát cắt bóng lệch pha, không tự nhân hit |
| **Liên Hoàn** | Vạt ngắn đều hai bên, nẹp tay theo nhịp, tóc cột sát | Hai đao ngắn có chuôi cùng họ nhưng hai tay dẫn–theo đảo nhịp | Tiên: giáp tay mắt xích; Thần: dải áo đan xen đúp, vòng lặp chém có kết thúc rõ | cặp cắt xen kẽ có nhịp |
| **Huyết Nguyệt** | Vạt áo ngoài hai đầu cong như lưỡi liềm, cổ thấp, dáng bắt chéo tay | Hai liềm đoản nhận đối chiều, tay giao trước ngực rồi mở | Tiên: đường viền ngọc nguyệt trên đôi vũ khí; Thần: vai/áo tạo hai cung trăng khuyết, không đổi sang trăng HUD | hai cung sáng cắt nhau đúng 1 event nếu catalogue nói vậy |

### 08. Thương Tu (`spear`)

**DNA:** cán dài hai tay cầm, mũi nhọn tách nền, thân đứng trước–sau; trọng tâm cực rõ. **Màu chức năng đề xuất:** lam thép / đồng xưa / trắng sương. **Cấm lẫn:** không tạo halberd hay gậy trống; thương phải hiện thật đủ dài ở game-size.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Phá Trận Thương** | Vai giáp tam giác hướng trước, vạt áo xẻ dài thẳng, chân bước tấn | Thương mũi lá đơn, hai tay trước–sau; đầu thương chĩa thẳng | Tiên: khóa cán chạm đá; Thần: giáp vai như mũi thương phân tầng | mũi thương đâm một trục; line target đúng cap |
| **Long Thương** | Tóc đuôi ngựa sau gáy, áo dài dải dọc có đường uốn, thân nhẹ | Thương cán mềm hơn cảm giác nhưng không uốn gãy, mũi dài, tua nhỏ; chuyển thân quanh trục | Tiên: tua cán như vân long; Thần: giáp áo dạng vảy dài phân đoạn, không thêm rồng vật lý vào body | đường long khí quấn quanh trục đâm |
| **Hộ Quân Thương** | Giáp vai cân hai bên, váy giáp ngắn, chân trụ rộng; thân che chắn | Thương ngang ngực hai tay giữ, sống cán/đầu lộ ngoài silhouette | Tiên: hộ thủ dọc thân cán; Thần: hai tấm vai như tường quân trận, không sinh đồng đội ảo | đường chắn ngang, kình hồi trả cục bộ |

### 09. Chưởng Tu (`palm`)

**DNA:** bàn tay MỞ, đường truyền lực mềm từ vai ra lòng bàn tay; không cần weapon. **Màu chức năng đề xuất:** đất ấm / hàn ngọc / gió trà. **Cấm lẫn:** không nắm quyền, không cầm kiếm/quạt để khác biệt giả, không đặt vòng dưới chân cho mọi nhánh.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Liệt Dương Chưởng** | Vai mở, áo tay ngắn một phần để lộ hai lòng bàn tay, vạt áo tỏa hình tia | Tay không, một lòng bàn tay áp thẳng trước ngực rồi đẩy ra | Tiên: nẹp tay hình nhật luân; Thần: áo vai như quầng nhật tách lớp, không rải vụ cháy lên body | mặt chưởng áp nhiệt hình quạt đặc có lõi |
| **Hàn Ngọc Chưởng** | Tà áo mềm thu ở cổ tay, vai thấp, tư thế tỉnh lặng; mảng ngọc ở đai | Tay không, ngón mở cân, hai bàn tay hạ–chuyển–đẩy | Tiên: hạt ngọc ở cổ tay/áo; Thần: cổ áo như phiến băng ngọc có khe thở | mặt chưởng lạnh, sương mỏng và xung lực |
| **Hồi Phong Chưởng** | Hai tay áo bất đối xứng một ngắn một dài, eo xoay, tà áo hướng vòng về thân | Tay không, lòng bàn tay vòng về sau rồi đảo chiều | Tiên: tà áo như gió hồi; Thần: hai dải áo cánh hồi khí nhiều lớp (không vòng HUD) | xoáy hồi chưởng mềm có tâm và hướng |

### 10. Chú Tu (`curse`)

**DNA:** ấn ngón tay, lời chú/nhịp và chuỗi đồng; tập trung quanh ngực, cổ và miệng. **Màu chức năng đề xuất:** tím mực / đồng cũ / xám đá. **Cấm lẫn:** không cầm giấy như Phù, không có luopan như Trận; catalogue vfx_key text_pending cần xác minh.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Trấn Hồn Chú** | Cổ áo cao ôm mặt, vạt áo khép như cửa, chuỗi đồng buông thẳng giữa ngực | Chuỗi hạt có quả chốt; hai tay hợp ấn đứng yên | Tiên: chuỗi khóa hồn tinh hơn; Thần: giáp cổ đồng hình chuông im lặng, không tự bổ sung stun | ấn chú trấn tại một mục tiêu khi contract xác minh |
| **Phệ Linh Chú** | Áo tay lệch, tà áo kéo dọc, đai mang thẻ đồng đen; dáng kéo ngược | Vòng đồng nhỏ đeo cổ tay; tay kéo về ngực, ngón tay khum | Tiên: găng tay có rãnh mạch linh; Thần: giáp lưng như khe hút ánh sáng, không tự thêm hút mana | mạch ánh linh dẫn về dấu chú, không giả receipt |
| **Hộ Mệnh Chú** | Vai cân đối, áo ôm và tấm hộ ngực hình khóa, trâm chữ thọ chỉ dạng motif trừu tượng | Chuỗi hạt ngắn; hai cẳng tay nâng chắn ngực | Tiên: khóa ngực ngọc; Thần: vòng cổ giáp hai tầng như sinh mệnh che chở, không tạo shield gameplay mới | dấu bảo hộ/ấn sinh mệnh rõ và nhỏ |

### 11. Trận Tu (`formation`)

**DNA:** điểm neo, bố cục đất và dụng cụ chỉ phương, kỷ luật hình học của PHÁP TRẬN. **Màu chức năng đề xuất:** chàm mực / xám đá / vàng đồng. **Cấm lẫn:** không cầm tờ phù, không cầm chuỗi đồng để thay định vị, không bake trận pháp dưới chân.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Tụ Linh Trận** | Áo xếp dọc đồng tâm nhỏ ở thắt lưng, vạt áo cân, vai mở thu lực | Tinh bàn/la bàn nhỏ + thước/chỉ điểm; hai tay tụ về tâm | Tiên: đai treo nhiều thẻ neo tinh xảo; Thần: giá tinh bàn đeo sau vai dạng khung, không mở AoE buff ảo | điểm sáng quy tụ về một vùng |
| **Phong Tỏa Trận** | Áo vai cứng góc vuông, khóa thắt lưng hình chốt, cổ tay đeo thẻ biên | Tinh bàn vuông + thẻ neo; hai tay khép ranh giới | Tiên: thẻ biên kim loại phân lớp; Thần: trang phục có đường khung không gian gấp kín, không giả crowd-control | đường ranh đóng–khóa, không là UI ring |
| **Sát Phạt Trận** | Giáp áo xẻ tạo mũi nhọn hướng đất, thắt lưng gọn, chân trước hạ sâu | Địa bàn/que chỉ trận rõ; cúi đặt điểm rồi rút tay về | Tiên: thước chỉ trận sắc hơn; Thần: giáp tà áo mang vệt phân cách chiến trận, không tự tạo damage tick | đường thế trận cắt đất, đúng formation_zone |

### 12. Triệu Hồi (`summon`)

**DNA:** khế ước và sự hiện diện của bạn đồng hành; nhân vật chừa khoảng âm cho actor triệu hồi độc lập. **Màu chức năng đề xuất:** tro tím / jade nhạt / đồng. **Cấm lẫn:** không vẽ companion/summon entity vào sprite người, không giả triệu hồi actor chưa có art.

| Nhánh | Character Nhân: silhouette / trang phục | Prop thật + động tác nhận diện | Tiên → Thần (đề xuất hình dạng, chưa sản xuất) | Gợi ý VFX sau này |
|---|---|---|---|---|
| **Kiếm Linh** | Áo cổ dài một bên, vạt hẹp như vỏ kiếm, tay mời mở ra phía trên | Thẻ khế kiếm mỏng/vỏ bọc nhỏ; tay gọi hướng vị trí kiếm linh sẽ xuất hiện | Tiên: thẻ khế mũi kiếm; Thần: áo choàng hình chuôi kiếm mở, không tự thêm số kiếm | kiếm linh/đường khế riêng khi actor thật có |
| **Linh Thú** | Áo cổ thấp, đai bọc mềm và túi linh vật nhỏ, một bên người thoáng thấp | Thẻ khế + túi bùa gọn; một tay hạ thấp ra bên cạnh | Tiên: đai khế dây dệt; Thần: cầu vai hình dấu chân trừu tượng, không gắn thú lên vai | khế quang vươn tới actor thú thật |
| **Khôi Lỗi Hộ Pháp** | Vai một bên nặng hơn, áo như áo thợ tinh cơ, dây khớp trang trí cố định | Bàn điều khiển khôi lỗi nhỏ/khế token; hai ngón tay điều hướng, không diễn rối bằng đường dây giả | Tiên: thẻ khớp cơ quan rõ; Thần: khung tay giáp như điều khiển nhiều khớp, không sinh unit ảo | đường khế nối tới khôi lỗi actor thật |

## 5. Chặn những cặp thường bị lẫn

| Cặp | Phân biệt bắt buộc khi không có tên/VFX |
|---|---|
| **Kiếm / Đao / Song Đao** | Kiếm = một jian thẳng thon; Đao = **một** lưỡi cong bản lớn và thế quán tính; Song Đao = **hai** đoản đao khác tay + eo xoay. Màu đỏ-đen không phải dấu nhận diện riêng. |
| **Quyền / Chưởng** | Quyền = **nắm** tay, vai–hông nén; Chưởng = **mở** lòng bàn tay, đường thân mềm. Cả hai không cần held weapon. |
| **Chú / Phù / Trận** | Chú = kết ấn/chuỗi đồng/ngực–miệng; Phù = tờ giấy/bút/niêm; Trận = tinh bàn/thước/thẻ neo/điểm dưới đất. Không là ba người áo tím tay không. |
| **Cung / Thương** | Cung = cong + dây thật và kéo hai đầu; Thương = cán thẳng dài hai grip với mũi nhọn luôn đọc được. |
| **Độc / Chú** | Độc = bộ châm/dược/cổ, công cụ y dược và cổ tay; Chú = đồng/khóa/khẩu hình, ấn tay trước ngực. |
| **Kiếm Linh / Ngự Kiếm** | Triệu Hồi = chủ nhân dùng **khế vật**, actor kiếm linh nếu có là đối tượng tách biệt; Ngự Kiếm = kiếm thật và chỉ quyết. Không dùng một sprite kiếm nổi thay thế cả hai cơ chế. |

## 6. Cụ thể hóa cho 72 diện mạo theo nhánh và 2 novice

- **Hai novice** nam/nữ chưa chọn phái: ngoại hình trung tính, không mang vũ khí có hiệu lực game theo giới; không gán kỹ năng chỉ từ ngoại hình.
- **36 nhánh × 2 sex = 72 profile ngoại hình mục tiêu** (không phải 72 rig và cũng không tự động là 72 playable actor đã có); một `branch_id` giữ DNA/prop, hai diện mạo phải khác cá nhân. Một mẫu đại diện/phái chưa thay thế được 3 nhánh/phái.
- Khi nhánh chưa có trang phục/prop thật, hiện trạng ghi `ART_PENDING`, không mượn vũ khí trường phái khác; fallback novice phải được ghi là fallback.
- **Đồ mặc và vật cầm**: chỉ là đề xuất hình ảnh cho tới khi nhận quyền từ hệ thống trang bị thật; weapon cosmetic không trao chỉ số/item. Vũ khí/pháp khí không được nhuộm giống màu vải thành một khối; đặt contrast bằng value/material.
- **Nhân vật không biết đánh bằng weapon không có:** mọi Cast/Attack bắt buộc nối đúng mô hình cầm, ống tên, dây cung, cán thương, đôi lưỡi hoặc bàn tay không. Cấm gắn prop chỉ ở Idle rồi biến mất vô cớ ở Attack.

## 7. Giao thức art production *ngắn* và kết quả thật

**Không tạo bộ kiểm thử mới hoặc lab mới cho bản design.** Dùng pipeline hiện có, khắc phục từng nhóm nguồn.

1. **Khóa reference family:** đặt nguồn Nữ Độc và Kiếm nam owner-liked bên 24 actor candidate tại cùng tỷ lệ 1×; giữ hai mốc identity này bất biến. Tách lỗi style mismatch khỏi lỗi missing weapon. Chỉ sửa master lệch family.
2. **Nhân — 12 mẫu base/master:** mỗi phái một gương mặt nam + nữ với chính vũ khí cầm đúng họ, 4 view source alpha, pivot/eye-line/weapon silhouette thống nhất. Đặc biệt sửa nguồn AS65 Back (không phải mặt trước giả) và overflow Downed AS54/55, bảo vệ source tốt cũ. Một batch review thật ở map 1×, không 12 poster.
3. **Nhân — 36 nhánh:** từ 12 family, author cho từng nhánh các mảng áo–tóc–đồ cầm/tư thế khác hình thật; không phải tint. Ưu tiên minh chứng một bộ 3 nhánh cùng một phái ở cùng scale trong grayscale; sau đó mở nam/nữ. Nguồn master và layer gốc giữ bền trên GitHub.
4. **Animation frame-by-frame:** chính xác 4 hướng (front/right/back/left) × Idle/Walk/Attack/Cast/Hit/Death, đúng động tác và weapon riêng; pose không tái chế bằng xoay/lật toàn body; không rig, không bake VFX vào cơ thể. 576 body clip candidate **không** đồng nghĩa hoàn thành weapon/layer/identity/visual approval.
5. **Owner preview:** một lineup đồng nhất 24 đại diện môn phái (nam/nữ), thêm 12 triptych 3 nhánh (có thể ưu tiên 3 môn trọng điểm trước), và một MP4 native Godot 1280×720 ngắn. Gate tách `SOURCE_PRESENT`, `VISUAL_FAMILY`, `BRANCH_IDENTITY`, `HELD_ASSET`, `MOTION`, `GODOT`, `OWNER_ART`, `PVE_HOLD`.

**Minimally acceptable:** 12 môn có silhouette không lẫn; 36 nhánh mỗi nhánh có ít nhất 2 dấu hiệu hình độc lập ngoài màu/VFX; weapon/tool đúng lớp, không thủng alpha; đúng 4 hướng và chân không trượt; các bản đã duyệt không đổi. Ảnh đẹp nhưng không hoạt họa **không** được gọi production animation.

## 8. Bàn giao liên kết VFX theo Art-First V4

- Character team bàn giao từng `school/branch`: four-way locked body masters, 6 action true key poses, pivot, hand grips, weapon front/back, phase release/attack visual event marker, `OWNER_ART` per revision.
- VFX team chỉ bắt đầu **Human** khi nhận actor/weapon có tính nhất quán; từng skill xác minh canonical `skill_id/effect/shape/target_limit`, ba clocks và pose caster. Art-First V4: G0–G2 → **G3 RGBA master & changing poses hard STOP** → G3.5 native moving target → G3.6/3.7 → G4–G7 → owner gate → G8/PvE HOLD.
- POI06 R11 benchmark mỹ thuật, POI19 R3 benchmark ánh sáng động/provisional, POI15 R1B benchmark được duyệt; **không copy hình tượng Độc Tu sang môn khác**. FIST14 R6 là G3 SOURCE FAIL, không dùng làm chuẩn.
- Tiên và Thần: chỉ mở từng nhánh sau khi tương ứng Nhân được duyệt; tier visual phải thay cấu trúc thật như bảng §3/§4, **không kế thừa tự động quyền hiệu lực gameplay**.

## 9. Chứng cứ và quyết định chờ owner

- **Đã thực hiện trong commit tài liệu này:** phân tích tham chiếu repo + định nghĩa đồng bộ 12 môn/36 nhánh + hướng tier + tiêu chí kiểm tra. **Không tạo ảnh/sprite/animation/MP4 mới, không sửa runtime/asset approved.**
- **Chưa được phê duyệt:** toàn bộ đề xuất silhouette và trang phục chi tiết 36 nhánh; Tiên/Thần concept; mọi master mới. Status `DESIGN_DIRECTION_PROPOSED`, không `OWNER_ART_APPROVED`.
- **Chưa thực hiện:** G3 tranh nguồn theo bảng mới, Godot native, exact-SHA asset QA; tất cả `NOT_EXECUTED` cho bản thiết kế này. 576 candidate cũ giữ nguyên trạng thái thực.
- **Hướng quyết định ưu tiên:** chốt 12 school Human signature + ba nhánh cùng phái bằng một group so sánh thật; rồi mới sản xuất 36 branch Humans và quy hoạch Tiên/Thần.
