# MAP-D2 — ART PROVENANCE / OWNER REVIEW REQUIRED

**Authority:** Đây là 3 **hình vector mới sáng tác, thử nghiệm**, KHÔNG thuộc 32 PNG Source A đã khóa SHA và KHÔNG phải nguồn của 8 công trình từng được duyệt. Không thay thế file gốc, không cập nhật registry source đã duyệt, không nhận các hình này làm bản phát hành.

Lý do: MAP-D1B chỉ vẽ marker hình thoi cho 3 trạm sản xuất. Gói MAP-D2 cung cấp hình đại diện trực quan để đánh giá quy mô/vị trí, trong khi vẫn để BuildingState/One Active Job/Kho/SaveService nguyên vẹn. Những hình này là **static visual vignettes**, tuyệt đối không phải clip đang đào/chặt/trồng, không sinh tài nguyên, không tồn tại dưới dạng công trình gameplay mới.

| Loại | Đường dẫn | Git blob SHA | Phân loại |
|---|---|---|---|
| mine | `godot/art/map_d2_candidate/mine_worksite_v1.svg` | `6b346832f5ece6381aab34bf17aa638b0f87368d` | CANDIDATE / UNAPPROVED |
| linh_forest | `godot/art/map_d2_candidate/linh_forest_worksite_v1.svg` | `049e7fdb3c2895c0a781607bd08b92a5da15515f` | CANDIDATE / UNAPPROVED |
| spirit_field | `godot/art/map_d2_candidate/spirit_field_worksite_v1.svg` | `791bef804270fd7dd3191a21405bca2eafcb417e` | CANDIDATE / UNAPPROVED |

**Lưu ý:** Git blob SHA không phải SHA-256; khi có Godot và filesystem thật, cần ghi SHA-256 và kích thước import. Các ảnh dùng SVG `viewBox=240×175`, hiển thị mục tiêu 166×121 trên map. Màu/khối là đề xuất, cần so sánh với mái ngói/chibi Source A. Nếu không phù hợp, chỉ cần bỏ đăng ký candidate, fallback là marker cũ; không ảnh hưởng gameplay.

## Trạng thái chạy thử
- GitHub có mã và file SVG; chưa có kết quả import Godot official 4.7.2 trên thay đổi này.
- Lớp đồ họa `SectMapD2Landscape` dùng nền màu biến thiên, phong cảnh ao nhỏ, reeds và hoa/đá để hạn chế nền lặp. Chúng cũng là **visual S4 candidate**, không đại diện nước/ruộng game thật.
- Sẽ chỉ nâng thành asset được duyệt sau khi có ảnh runtime, test và xác nhận của owner.
