# TMB — Identity Bible Đệ Tử 12 Trường Phái (bản ứng viên) — 2026-11-17

**Phạm vi:** định hướng mỹ thuật và sản xuất master tĩnh; không thay đổi luật game, animation, VFX hay runtime.  
**Trạng thái:** **DESIGN_CANDIDATE_OWNER_REVIEW_PENDING**. Tên phái/nhánh lấy từ catalogue V63 và TMB_DISCIPLE_SCHOOL_VISUAL_MOTIFS_20261111.md; palette là nhãn gợi ý, không phải thông số gameplay hay RGB đã chốt.

## 1. Nguồn chuẩn và điều đã học

- Master Nữ Độc Tu đã khóa: **godot/labs/character_family/assets/nu_doc_tu_v4_candidate/owner_approved_master.png**, SHA-256 **435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118**. Dùng làm mẫu chất lượng, chất liệu và tỷ lệ; không sao chép nhân vật, mặt, tóc, trang sức hoặc trang phục sang các phái khác.
- Mô tả Kiếm Tu nam tóc bạc-trắng, áo xanh-trắng, kiếm đỏ-đen bất đối xứng và ấn kiếm đỏ là **owner-liked visual direction** trong **docs/animation/TMB_KIEM_TU_MALE_OWNER_VISUAL_REFERENCE_LOCK_20261114.md**; ảnh nguồn gốc không nằm trong checkout này. Master Kiếm mới là diễn giải mới, không phải bản phục dựng hay thay thế ảnh owner.
- Owner thích ba GIF Shadow Pixel-Chibi đầu tiên với pixel cluster gọn, nhân vật trưởng thành và vũ khí đọc rõ. Byte gốc chưa có trong repository; không suy đoán các chi tiết không nhìn thấy.
- Các lượt GIF tái tạo sau đó bị đổi mặt/tóc/giới tính/vũ khí giữa khung. Turnaround novice nam/nữ hiện ở AS-CHAR-38 chỉ là **STATIC_IDLE_CANDIDATE**; chưa có xác nhận thẩm mỹ của owner. Candidate nam có điểm viền màu; candidate nữ có pixel alpha rìa. Không dùng các sheet ấy làm master đã duyệt.
- **docs/animation/TMB_DISCIPLE_SCHOOL_VISUAL_MOTIFS_20261111.md** khóa ngôn ngữ pose 36 nhánh ở mức thiết kế; không khẳng định có sprite hay animation. **12school_palettes.json** ghi palette bằng từ, trạng thái **DESIGN_ONLY_NOT_PIXEL_SOURCE**.
- Không tìm thấy Source A character atlas đã xác minh theo từng trường phái. Không lấy hình actor Source A chưa rõ danh tính để gán trường phái.

### Rút ra cho lô asset này

1. Chỉ một ngôn ngữ render chung: chibi người trưởng thành, vật liệu và độ tương phản gọn; mỗi master có một silhouette, tóc/trang phục và pháp khí riêng.
2. Đọc từ thumbnail trước: một đặc điểm lớn + tối đa vài điểm nhấn; không dựa vào chữ, aura, bảng màu đơn thuần hay background.
3. Vũ khí/đạo cụ được vẽ rõ nhưng master tĩnh **chưa phải** lớp item tách rời. Không bịa hiệu ứng gameplay bằng hình ảnh.
4. VFX, projectile, vòng trận, thú triệu hồi, bóng mờ và chữ chú/phù đều ở ngoài sprite nhân vật.
5. Ảnh mới là master concept ứng viên. Chưa có frame 4 hướng, pivot, layer source hay animation; không gọi là asset runtime.

## 2. Quy tắc chung của family

- Nhân vật là đệ tử trẻ đã trưởng thành, khoảng 3–3.5 đầu; không trẻ con, không già/boss hóa.
- Tỷ lệ, nét mặt, viền, key light và phân tách chất liệu theo family Shadow Pixel-Chibi / 2.5D của TMB; độ tinh xảo ở gần mẫu Nữ Độc Tu đã khóa. Master có thể lớn để giữ chi tiết, nhưng vẫn phải đọc được khi thu nhỏ.
- Mỗi người phải nhận ra phái bằng silhouette + pose + tóc/trang phục + công cụ; không đổi mỗi màu áo.
- Chất liệu đề nghị theo palette vocabulary hiện có, không khóa RGB trước duyệt: vải tối có value group rõ, kim loại có highlight ngắn, ngọc chỉ dùng làm điểm nhấn, không phủ kín.
- Mọi master: nền alpha thật, toàn thân và vũ khí/đạo cụ nằm trong canvas, không chữ/logo, không bệ cảnh, không aura/VFX. Bản candidate chưa được cắt/chỉnh để giả làm sprite.
- Bố trí cho 1280×720 phải giữ vũ khí rõ ở chiều cao actor 60–75 px; master concept hiện tại chưa qua kiểm tra scale in-game.

## 3. Identity card theo từng trường phái

### 01 — Cung Tu
- **Fantasy/chiến đấu:** đạo của khoảng cách; kiên nhẫn, ngắm một đường rõ.
- **Màu:** nguyệt bạc + lam mực; ánh nhấn rất ít.
- **Silhouette/áo:** thân thanh, vai thoáng, đường cánh tay kéo dây cung tạo đường chéo; áo ngắn nhiều lớp để không che cung.
- **Tóc/phụ kiện/ấn:** búi cao gọn hoặc bím sau gáy; trâm cong như vành trăng; dấu cung nhỏ ở ngực/cổ tay.
- **Cung/vũ khí:** cung một thân cong có grip rõ, dây mảnh, một đầu bạc hình lá; không gắn nhiều lưỡi/chuông.
- **Khác biệt/cấm lẫn:** cung và tư thế ngắm là silhouette chính; không cầm kiếm, không có hai lưỡi ngắn hay vòng sáng sau lưng.
- **Nhánh (chỉ tạo hình):** Liệp Ảnh thu vai/đường ngắm thấp; Linh Tiễn mở vai và kéo cao; Thiên Vũ mở khuỷu rộng hơn nhưng vẫn một cây cung.

### 02 — Quyền Tu
- **Fantasy/chiến đấu:** đạo của thân thể; trọng tâm thấp, dồn lực qua một quyền.
- **Màu:** đá tối + đồng đỏ.
- **Silhouette/áo:** vai và cẳng tay chắc, áo ngắn/đai buộc, chân trụ rộng; hai bàn tay luôn đọc rõ.
- **Tóc/phụ kiện/ấn:** tóc buộc sát, băng trán/khuyên đồng nhỏ; dấu nắm tay khắc trên đai tay.
- **Vũ khí/đồ nghề:** không có vũ khí cầm tay; băng quấn, hộ cổ tay và miếng bảo vệ khớp là trang bị mềm.
- **Khác biệt/cấm lẫn:** bàn tay nắm và trục vai-hông là điểm chính; không thêm găng sắt có gai, quyền trảo hay gậy để “làm mạnh”.
- **Nhánh:** Bá Quyền gọn, xoay hông; Kim Cang hai tay khép thủ; Huyết Quyền áp sát nhưng không thêm máu/hiệu ứng lên sprite.

### 03 — Độc Tu
- **Fantasy/chiến đấu:** sinh–diệt, dược và độc chung một tri thức.
- **Màu:** tím-đen + ngọc; giữ Nữ Độc Tu đã khóa làm identity riêng, không làm lại.
- **Silhouette/áo:** tay áo mềm, cổ tay linh hoạt, váy/áo nhiều lớp nhưng không dài đến mức nuốt mất bàn tay.
- **Tóc/phụ kiện/ấn:** nữ master khóa có tóc tím-đen dài, mão ngọc lục và ấn trán; các đệ tử khác cần khác tóc/mặt, không thành bản sao.
- **Vũ khí/đồ nghề:** bộ châm mảnh và một hồ lô nhỏ niêm kín; chất liệu xương/kim loại tối/ngọc chỉ là art proposal, không nói rằng có item/độc mới.
- **Khác biệt/cấm lẫn:** dụng cụ nhỏ tinh xảo và cổ tay mềm; không đầu lâu, không xương gai quá đà, không rắn/vụ nổ/khói trong sprite.
- **Nhánh:** Độc Châm ưu tiên kim; Cổ Độc dùng ấn tay, không vẽ cổ trùng thật; Dược Độc mang túi dược nhỏ, dáng đứng mở.

### 04 — Kiếm Tu
- **Fantasy/chiến đấu:** một lời thề; trục người–kiếm thẳng, tiết chế.
- **Màu:** thép bạc + tím mực, với bộ Kiếm nam owner-liked xanh/trắng/bạc và ấn kiếm đỏ là identity đặc biệt đã ghi nhận.
- **Silhouette/áo:** lưng thẳng, vạt áo dài có đường xẻ cho kiếm; tóc cao dài có dải vải xanh theo owner-liked male direction.
- **Tóc/phụ kiện/ấn:** tóc bạc-trắng buộc cao, trâm/crown xanh; ấn kiếm đỏ dọc giữa trán khi mặt nhìn thấy. Chỉ đây là hướng riêng, không áp toàn bộ phái.
- **Kiếm:** jian thon, thẳng, guard nhỏ; hướng owner-liked là kiếm bất đối xứng đỏ-đen, có cạnh gãy có kiểm soát. Ngự Kiếm giữ kiếm bay thành actor riêng; không nhét nhiều thanh vào tay master.
- **Khác biệt/cấm lẫn:** một đường kiếm thanh và dáng chính trực; không cung, không đại đao, không độc ngọc.
- **Nhánh:** Ngự Kiếm chỉ tay dẫn một kiếm; Sát Kiếm khép kiếm sát thân; Hộ Kiếm tạo đường thủ ngang bằng kiếm.

### 05 — Đao Tu
- **Fantasy/chiến đấu:** quyết đoán và sức nặng phải có trách nhiệm.
- **Màu:** thép sẫm + đỏ gạch.
- **Silhouette/áo:** vai rộng, giáp-vải chồng, đai hông nặng; một lưỡi cong lớn vắt chéo.
- **Tóc/phụ kiện/ấn:** tóc búi thấp, dây buộc đỏ trầm và thẻ kim loại trơn; họa tiết sống núi/đường chém.
- **Đao:** một thanh đơn đao lưỡi cong một cạnh, sống dày, guard chắc; chi tiết đỏ ở vỏ/chuôi, không glow.
- **Khác biệt/cấm lẫn:** một lưỡi rộng, cảm giác quán tính; không biến thành jian thẳng hoặc đôi đoản đao.
- **Nhánh:** Cuồng Đao có thân áo linh hoạt để xoay; Trảm Phách có vai/bao tay thiên lực; Trấn Đao mang hộ thủ ngang.

### 06 — Song Đao
- **Fantasy/chiến đấu:** hai lựa chọn, hai nhịp đối nghịch.
- **Màu:** graphite + đỏ thẫm.
- **Silhouette/áo:** eo gọn, hai cẳng tay tách khỏi thân, đai chia hai vị trí rút; lệch nhẹ bên trái/phải.
- **Tóc/phụ kiện/ấn:** tóc tết hoặc búi lệch, hai khóa đai đối xứng; biểu tượng hai cung đối chiều.
- **Đôi đao:** hai đoản nhận riêng, thiết kế thành cặp nhưng không trùng khuôn; khi đặt cạnh nhau tạo một cung khuyết, mỗi lưỡi vẫn đọc độc lập.
- **Khác biệt/cấm lẫn:** bắt buộc nhìn thấy hai vũ khí độc lập; không dùng một cặp kiếm dài như Kiếm Tu, không thêm afterimage vào sprite.
- **Nhánh:** Ảnh Nhẫn thiên rút một lưỡi trước; Liên Hoàn phân rõ tay dẫn/tay theo; Huyết Nguyệt nhấn hình cung khi giao nhau, không mã hóa HP.

### 07 — Thương Tu
- **Fantasy/chiến đấu:** phòng tuyến và đường đâm thẳng.
- **Màu:** thép lam + vàng cổ.
- **Silhouette/áo:** thân dài, tay cầm hai điểm trên cán, chân trước–sau; áo xẻ tà để cán thương đọc rõ.
- **Tóc/phụ kiện/ấn:** búi cao thấp gọn, vòng chặn trên cán, dây tua ngắn ngay dưới mũi.
- **Thương:** cán dài, mũi lá nhọn thon, socket kim loại rõ; không dùng đầu rìu/halberd để khỏi lẫn Đao.
- **Khác biệt/cấm lẫn:** một trục dọc kéo dài qua toàn thân; không gắn cánh lớn, không vẽ rồng/đường thương bằng VFX vào sprite.
- **Nhánh:** Phá Trận đặt mũi thương trước; Long Thương để cán lệch dọc; Hộ Quân giữ cán ngang thân làm tuyến thủ.

### 08 — Chưởng Tu
- **Fantasy/chiến đấu:** dẫn khí qua lòng bàn tay; mềm nhưng có hướng lực.
- **Màu:** đất ấm + ngọc lạnh (theo nhánh, không đổi luật).
- **Silhouette/áo:** tay áo rộng nhưng thu dần ở cổ tay, lòng bàn tay mở, đường cẳng tay cong; thân cân bằng.
- **Tóc/phụ kiện/ấn:** tóc mềm buộc nửa, vòng cổ tay nhỏ; hình bàn tay mở trên đai áo.
- **Vũ khí/đồ nghề:** không cầm vũ khí; bọc cổ tay vải và vòng tay không gai.
- **Khác biệt/cấm lẫn:** ngón tay mở và đường tay cong; Quyền Tu dùng nắm tay/đòn thân. Không thêm quạt/kiếm để tạo khác biệt giả.
- **Nhánh:** Liệt Dương mở bàn tay hướng ra; Hàn Ngọc có cổ tay mềm, khuỷu thấp; Hồi Phong đưa hai lòng bàn tay về phía mình.

### 09 — Trận Tu
- **Fantasy/chiến đấu:** đạo của vị trí và các điểm neo.
- **Màu:** mực chàm + đá.
- **Silhouette/áo:** đường áo có phân khu thẳng, đai mang vài thẻ vuông/đa giác, pose đặt điểm xuống nền.
- **Tóc/phụ kiện/ấn:** tóc gọn/khăn trùm ngắn để không che thẻ; phụ kiện như la bàn nhỏ gắn thắt lưng.
- **Pháp cụ:** bàn tinh bàn/luopan nhỏ và que chỉ điểm, không phải kiếm; ký hiệu trên mặt là hình học trang trí không phải công thức mới.
- **Khác biệt/cấm lẫn:** thẻ neo và hình học phẳng, ít dây; không có vòng trận/aura vẽ quanh người, không nhầm lá phù cầm tay.
- **Nhánh:** Tụ Linh giữ hai điểm tụ; Phong Tỏa khép cánh tay thành ranh; Sát Phạt chỉ điểm đất rồi thu tay.

### 10 — Triệu Hồi
- **Fantasy/chiến đấu:** khế ước đồng hành có thời hạn, không chiếm đoạt.
- **Màu:** tro tím + ngọc.
- **Silhouette/áo:** một tay mời mở ra, một bên thân chừa khoảng âm cho companion là actor riêng; áo khoác lệch một vai.
- **Tóc/phụ kiện/ấn:** tóc buộc dây khế, vòng nhỏ có nút thắt; huy hiệu hai dấu chấm nối bằng dây.
- **Khế vật:** thẻ khế ước ngọc/đồng nhỏ đeo ở thắt lưng; không vẽ linh thú, kiếm linh hay khôi lỗi trong master nhân vật.
- **Khác biệt/cấm lẫn:** khoảng trống bên cạnh + tay mời; không có sinh vật bám trên vai, không biến khế vật thành vũ khí đánh.
- **Nhánh:** Kiếm Linh nghiêng thân về vị trí kiếm actor; Linh Thú chừa khoảng thấp cạnh người; Khôi Lỗi Hộ Pháp giữ vai che chắn.

### 11 — Chú Tu
- **Fantasy/chiến đấu:** đạo của lời nói, nhịp chú và giới hạn.
- **Màu:** mực tím + đồng.
- **Silhouette/áo:** cổ áo và tay áo đóng khung mặt/miệng, thân áo có nếp gấp dạng nhịp; ngón tay tạo ấn.
- **Tóc/phụ kiện/ấn:** chuỗi hạt/đồng nhỏ gần cổ và vòng âm trang trí trên thắt lưng; không có văn tự bay quanh đầu.
- **Pháp cụ:** chuỗi cộng hưởng hoặc thẻ đồng nhỏ; không mặc định dùng giấy phù làm đạn/vật tư.
- **Khác biệt/cấm lẫn:** dấu hiệu là khẩu hình/ấn tay và chuỗi đồng; Phù Tu mới cầm giấy/bút. Không vẽ chữ chú đọc được hay vòng pháp trận trên cơ thể.
- **Nhánh:** Trấn Hồn khép ấn trước ngực; Phệ Linh kéo một tay rồi thu lại; Hộ Mệnh nâng cẳng tay che ngực.

### 12 — Phù Tu
- **Fantasy/chiến đấu:** đạo của nét mực trên vật mang ý niệm.
- **Màu:** giấy ngà + chu sa.
- **Silhouette/áo:** áo gọn với túi phù/cổ tay xắn, một tay giữ giấy, tay kia có thể cầm bút ngắn; không phủ áo bằng bùa.
- **Tóc/phụ kiện/ấn:** trâm gỗ/bút lông sau tai, đai có hộp bút phẳng; dấu nét mực đơn trên cổ tay.
- **Pháp cụ:** 1–2 lá phù trơn tách lớp + bút lông nhỏ; không có chữ lỗi AI, không giả định lá phù là vật phẩm tiêu hao.
- **Khác biệt/cấm lẫn:** tờ giấy hình chữ nhật và bút là điểm nhận dạng; Chú Tu dùng khẩu hình/chuỗi đồng, Trận Tu dùng tinh bàn/thẻ neo. Không có tia lửa/sét trong ảnh nhân vật.
- **Nhánh:** Lôi Phù nâng tay với lá giấy; Hỏa Phù giữ phù gần ngực; Phong Ấn Phù có động tác đặt/niêm nhưng không vẽ dấu phép phát sáng.

## 4. Bảng phân biệt nhanh

| Phái | Đường silhouette | Điểm nhận dạng thumbnail | Công cụ chính | Điều không được trộn |
|---|---|---|---|---|
| Cung | một đường chéo kéo dây | cung cong + tay ngắm | cung | kiếm/đôi đoản |
| Quyền | thấp, vai–hông xoay | nắm tay, băng cổ tay | không vũ khí cầm tay | móng/găng gai |
| Độc | cổ tay linh, nhiều lớp | châm + túi hồ lô nhỏ | châm/đạo cụ dược | đầu lâu/rắn VFX |
| Kiếm | trục đứng thẳng | jian + tóc/dải cao | kiếm thẳng | cung/đao rộng |
| Đao | vai rộng, lưỡi chéo | một lưỡi cong rộng | đơn đao | kiếm thẳng/đôi nhận |
| Song Đao | eo gọn, hai tay tách | hai đoản nhận | đôi đao | hai kiếm dài |
| Thương | trục dài dọc | mũi thương lá, cán dài | thương | halberd/đao |
| Chưởng | tay mở, đường cong | lòng bàn tay mở | không vũ khí cầm tay | nắm tay/vũ khí |
| Trận | thân cân, pose chỉ điểm | tinh bàn/thẻ neo | tinh bàn + que | giấy phù/vòng VFX |
| Triệu Hồi | một bên thân chừa âm | tay mời + khế vật | token khế ước | companion nằm trong sprite |
| Chú | ngực/cổ khung âm | ấn tay + chuỗi đồng | chuỗi/thẻ chú | giấy phù, chữ bay |
| Phù | tay hướng tờ giấy | phù + bút | phù/bút | vòng trận/chữ lỗi |

## 5. Thứ tự sản xuất đề nghị

1. **Kiếm Tu** — có owner-liked identity/weapon direction cụ thể; validate tóc/ấn/kiếm và giới hạn nguồn tham chiếu.
2. **Cung Tu** — kiểm tra bow readability, đường cong và grip nhỏ.
3. **Đao Tu** — kiểm tra tương phản đơn đao nặng với kiếm thẳng.
4. **Song Đao** — stress-test cặp vũ khí độc lập, tránh clone Kiếm.
5. **Thương Tu** — kiểm tra vũ khí dài trong canvas và contact sheet.
6. **Phù Tu** — paper/brush cần đọc tốt mà không phụ thuộc chữ.
7. **Trận Tu** — phân biệt tool/địa bàn với phù cụ.
8. **Độc Tu** — giữ nguyên nữ identity đã khóa; chỉ phát triển weapon item layer riêng sau duyệt.
9. **Quyền Tu** — kiểm tra silhouette tay nắm khác Chưởng.
10. **Chưởng Tu** — silhouette tay mở, khác Quyền.
11. **Chú Tu** — nhận diện bằng miệng/chuỗi đồng, tránh giống Phù.
12. **Triệu Hồi** — nhất quán khế ước, không vẽ companion hay tạo hiệu ứng mới.

Đây là **thứ tự kiểm chứng rủi ro**, không phải mức độ sức mạnh/nội dung unlock. Sau master của mỗi phái phải review ở 1×/zoom in trước khi mở rộng family. Mọi đệ tử khác trong phái biến thể mặt/tóc/dáng/ornament, nhưng giữ đúng DNA; không nhân bản một body rồi đổi màu.

## 6. Trạng thái owner gate

- **Đã được duyệt/khóa:** Nữ Độc Tu nguyên bản (hash phía trên); visual direction Kiếm Tu nam trong tài liệu owner-lock; quy trình/chất lượng chibi theo các ghi nhận cũ.
- **Candidate chưa duyệt:** các novice turnaround AS-CHAR-38; mọi master được sinh ở lô 2026-11-17; mọi palette expansion / weapon embellishment ở tài liệu này.
- **Thiết kế mới chờ duyệt:** toàn bộ 12 profile chi tiết, weapon form, trật tự sản xuất.
- Master tĩnh concept không đồng nghĩa với frame-ready sprite, game import, animation hoặc runtime integration.
