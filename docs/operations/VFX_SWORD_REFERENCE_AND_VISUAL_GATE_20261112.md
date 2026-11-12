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
