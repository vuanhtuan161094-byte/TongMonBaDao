# VFX KIẾM — THAM KHẢO & CỔNG DUYỆT MỸ THUẬT
**Ngày:** 2026-11-12 · **Engine:** Godot 4.7.2 · **PR:** #72 · **Phạm vi:** Combat Lab only

## Đầu bài và phát hiện nguyên nhân V9–V10 chưa đẹp

Owner nhiều lần không chấp nhận V9.3 và V10. PASS parse/strict render/GitHub Actions chỉ là đạt kỹ thuật, không phải đạt mỹ thuật. Các hình kiếm cũ đều nằm trong CanvasItem `blend_add`, làm **cả thân kiếm thép bị cộng sáng** thành thanh neon trắng, mất độ tương phản, hoa văn và chắn tay. 12 thanh kiếm đều sáng ngang nhau → phân tán điểm nhìn. AOE và va chạm của V10 quá nhỏ, không tạo nhịp mạnh yếu.

## Tham khảo đã đối chiếu (học nguyên lý, không sao chép ảnh/asset/copyright)

1. Võ Lâm Truyền Kỳ Mobile, trang môn phái chính thức, mục Võ Đang/kiếm: https://vltkm.zing.vn/ — tham khảo nội dung gameplay, bóng sáng và nhận dạng kỹ năng trong môi trường chiến đấu đông.
2. **Sword Rain** player example and discussion: https://devforum.roblox.com/t/feedback-on-myswords-rain-road-to-vfx-pro-lvl-255/1613884/3 — nhiều kiếm lao cùng hướng vào vòng ma pháp; có cụm sáng trung tâm và phân cấp thị giác.
3. **Stylized Sword Slash VFX / breakdown:** https://mrdragon.artstation.com/projects/ndYBEO — ribbon có hot core, gradient và impact tách riêng, sau đó dissolve.
4. **Stylized Projectile VFX / charge-up → travel → impact:** https://zoinn.artstation.com/projects/qJ5xVP — tác giả phân tích trường chuyển động theo giai đoạn và so sánh phiên bản sơ khai với thành phẩm.
5. **REEBOO 2D sample, MIT:** https://github.com/REEBO0/godot-stylized-2d-vfx-lite — ví dụ hit flash, slash arc, bright spark + short trail; KHÔNG nhập code/asset bên ngoài.
6. **Godot Compatibility note:** https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html — chọn hạt ít, vòng ảnh hưởng nhẹ, không phụ thuộc GPU/bloom HDR đắt tiền.

## Nguyên tắc thiết kế đã áp dụng ở V11 và V11.1

- **Tách vật thể và năng lượng:** thân kiếm gồm silhouette thép tối, hai mặt vát bạc/xanh; chỉ EDGE/TRAIL/IMPACT được phát sáng. V11 sword demo dùng alpha bình thường; V9 serpent giữ additive.
- **Thứ bậc:** 4 kiếm chính lớn, rõ mũi/chắn tay/chuôi/kim văn; 8 kiếm phụ nhỏ hơn và giảm opacity. Không dùng 12 neon ngang nhau hay lưới ô cứng.
- **Nhịp:** charge → AOE telegraph → flight → spark contact → dissolve. Không để hiệu ứng xuất hiện chồng đồng thời suốt clip.
- **AOE:** vòng tròn elip + phù văn dưới mặt đất và 4 điểm khóa; chỉ là BIỂU DIỄN trong Lab, không quyết định hit/radius.
- **Dissolve:** giữ kiếm khi tới đích, cắm vào mục tiêu ngắn, giảm alpha trong ~0.14 normalized time; impact halo cũng tan.
- **Tối ưu:** giới hạn 12 kiếm, 4 impact, vài tia/hạt không spawn node; 60-FPS offline movie chưa chứng minh máy Android đạt 60 FPS.

## Cổng duyệt BẮT BUỘC trước khi gửi owner

1. Xem đủ frame toàn cảnh (≥8 mốc) 1280×720 và crop 1× (không chỉ thumbnail). Mỗi frame kiểm tra form kiếm, hoa văn, chắn tay, vệt sáng có che vật thể không.
2. So V10 (rejected) với V11 candidate **cùng các mốc** tại charge/travel/impact/dissolve; kiểm tra có cải thiện thực tế, không chỉ CI xanh.
3. AOE hiển thị đúng 4 quái trong demo, màu sắc không che monster sprite; không gán sai hit authority.
4. Parse + strict Godot 4.7.2 + focused VFX & V4 contracts + video thực 1280×720, 60/1 fps, exact SHA; kiểm tra Godot logs errors = 0.
5. Các kỹ năng Độc Xà, chiến đấu, skill V6.3, HP, SaveService, quái và kinh tế KHÔNG sửa.
6. Chỉ đánh dấu **ART_APPROVED** khi chủ dự án đồng ý. Kết quả tác giả tự xem chỉ là `ART_CANDIDATE / OWNER_PENDING`.

**Nguồn mỹ thuật trong code:** original procedural Godot geometry. Không sử dụng PNG kiếm hay lấy asset game thương mại.

## Phân tích chuyên biệt theo dòng JX / Kiếm Thế / Ngạo Kiếm Vô Song (bổ sung 12/11/2026)

### Bằng chứng gốc và giới hạn
- **JX/VLTK 1 cổ điển — kỹ thuật:** Tài liệu cộng đồng phân tích `Skills.txt`, `Missile.txt`, `Script/Skill/*.lua`, asset `.spr` trong `.pak`; các chuyển động SPR được làm từ nhiều frame ảnh: https://www.clbgamesvn.com/diendan/archive/index.php/t-24049.html ; https://admin.jxdocs.com/knowledge_base/view/60 . Đây là tài liệu phân tích cộng đồng, không phải bản thông số chính thức của Kingsoft. Không suy rộng `.spr` sang mọi engine bản Mobile.
- **JX/VLTK — ảnh kỹ năng chiến trường đông:** https://tinhnghiavolam.net/payment (ảnh gameplay JX1 máy chủ cộng đồng, không phải bằng chứng về server chính hãng). Phân loại thị giác: cột sét có trục đứng; lửa ngả cam; vùng tác động theo đất; mỗi họ kỹ năng có hình thái riêng.
- **Kiếm Thế Origin — ảnh AOE gợn sóng đồng tâm:** https://vi.ldplayer.net/blog/1010.html ; **ảnh chiến trường đông**: https://www.bluestacks.com/vi/blog/news/kiem-the-origin-tong-kim-pk-battlefield-vi.html . **Video nhà phát hành**: https://www.youtube.com/watch?v=2dDBWxehdu8 (Game Studio 1 - VNG, 2024, cận cảnh tung chiêu Tiêu Dao); video để tham khảo nhịp chiêu, chưa trích xuất/kiểm chứng từng frame video.
- **Ngạo Kiếm Vô Song 2 — ảnh Hoa Sơn có vòng năng lượng dưới mục tiêu, tia dọc và chớp màu:** https://game8.vn/game-online/tat-tan-tat-ve-mon-phai-moi-hoa-son-trong-ngao-kiem-vo-song-2-70947 ; **ảnh PK nhóm**: https://thanhnien.vn/ngao-kiem-vo-song-2-nhan-nhieu-danh-gia-tich-cuc-1851140542.htm .
- **Ngạo Kiếm Vô Song Origin — kỹ năng gốc:** https://nkvso.gosu.vn/ngao-kiem-ky-thu/he-thong-mon-phai/hoa-son ; Hoa Sơn *Độc Cô Cửu Kiếm* nhiều kiếm khí, Võ Đang *Vạn Kiếm Quy Tông* bí tịch: https://nkvso.gosu.vn/news/tin-tuc/pb1t-them-moi-bi-tich-mon-phai .
- **Ngạo Kiếm Vô Song Mobile — Độc Cô Cửu Kiếm:** https://www.nkvsmobile.vn/articles/huong-dan/mon-phai-hoa-son-K0RbMyF mô tả chính xác: tạo 9 kiếm khí **bay lần lượt về phía mục tiêu** (cấp 100). Dùng làm tham chiếu nhịp và trọng số (không copy nghệ thuật/câu lệnh).
- **Tách quan sát và suy luận:** ảnh chụp cung cấp vị trí vòng AOE, ánh chớp và độ đọc hình; ảnh tĩnh KHÔNG chứng minh đường di chuyển, tốc độ, shader hay số frame. Cấu trúc layer và khoảng thời gian dưới đây là **thiết kế đề xuất** cho Godot chứ không phải thông số đã đo từ các game.

### Tại sao V10–V11 vẫn thiếu cảm giác kiếm hiệp
1. V10/V11 hiển thị **kiếm lớn quá lâu**; JX cần một **hình thái kỹ năng** nhận ra ở tỉ lệ 1×, không cần đọc hết vân khắc kim loại của 12 vật thể.
2. VFX hiện đồng thời gồm **12 kiếm, vòng dưới đất, tia sáng, rune, particle**; chưa có điểm nhấn nhịp. Với 30 chiến binh mỗi người thi triển, nguy cơ thành nhiễu thị giác, che nhân vật/quái.
3. Mẫu Hoa Sơn *Độc Cô Cửu Kiếm* tạo **9 kiếm lần lượt**: không phải 9–12 kiếm tất cả lao đồng thời. Việc phân thời gian giúp nhận ra từng đợt gây sức mạnh.
4. **Missile / effect / status** tách riêng trong JX cổ điển là gợi ý kiến trúc: caster charge, projectile flight, ground marker và hit impact có nhịp riêng, còn vị trí/đòn đánh thuộc authority của game.

### Thiết kế VFX12 đề xuất — CHƯA TRIỂN KHAI / CHƯA DUYỆT
| Pha | Nhịp đề xuất | Trọng điểm thị giác | Kỹ thuật Godot |
| --- | --- | --- | --- |
| Tụ kiếm | 0.00–0.25s | 1 ấn chú dưới chân, **3–4 bóng kiếm** xuất hiện theo cung, không 12 vật thể chói | authored shape/sprite-frame của kiếm có pháp tuyến và điểm neo riêng; animation opacity/scale |
| Khóa vùng | 0.25–0.37s | vòng AOE bán trong suốt trên mặt đất, không che HP/monster | visual cue đọc `target_center`/`radius` thật, không sửa hitbox |
| Phóng kiếm | 0.37–0.75s | **3 đợt × 3 kiếm**, mỗi đợt so le 0.07–0.10s; mỗi thanh có 1 trail ngắn | fixed spline/straight flight từ authoritative event, không tự tính damage |
| Trúng đích | khi authoritative hit xác nhận | chớp trắng ngắn theo điểm va chạm; 1 ring nở + shock streak | chỉ phát impact từ cue thực; cap số impact khi đông |
| Dư âm | 0.10–0.23s sau hit | kiếm thành bóng mờ/tàn quang, ring tan, tránh tắt đột ngột | alpha/fade & bounded particles, không sinh 12 hit giả |
Các khoảng thời gian này chỉ là **proposal mỹ thuật**, cần căn chỉnh theo thời điểm `launch_at/impact_at` thật khi triển khai.

### Quy tắc triển khai
- Không nhập/tách SPR có bản quyền game thương mại; tự thiết kế asset/hình học original. Có thể dựng **chuỗi hình động riêng** hoặc primitive + shader, miễn chất lượng ở 1× và chi phí thực tế được nghiệm thu.
- Hướng tốt hơn chỉ-pure-vector hiện tại: một hình dạng kiếm gốc có silhouette ổn định (authored vector/raster original), được animate bằng transform; lớp ánh sáng và trail thay đổi theo thời gian; tác động có cue riêng. `Texture` trong VFX không đồng nghĩa dùng PNG tĩnh giả làm kỹ năng.
- Giữ `V11.2` ở Combat Lab **OWNER_VISUAL_PENDING**, không tuyên bố game đã đẹp hơn hay tích hợp PvE. Bước tới: chỉ đề xuất/thiết kế rồi code VFX12 sau khi so 8–12 frame và hậu kiểm tải GPU/CPU Android; V6.3/combat/Save giữ nguyên.
