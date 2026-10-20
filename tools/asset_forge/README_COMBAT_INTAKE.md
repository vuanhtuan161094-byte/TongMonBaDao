# Tông Môn Bá Đạo — JX1 Combat Source Intake (21/10/2026)

## Mục tiêu

Dùng **client/server đã có trên PC** tại `E:\Source` và `E:\Tool JX` làm nguồn tìm asset cho combat JX1; **không** thay Combat V2, RNG, số damage, skill cooldown hay gameplay đã khóa. Đích: map gốc, actor/boss Sprite (đủ idle/walk/attack/hit/die), đúng trang phục/phái, missile/skill/VFX theo bảng gốc, camera tự do, Android 1280×720.

## Cách chạy

1. Giải nén ZIP ở thư mục bất kỳ, không đặt trong `E:\Source` hoặc `E:\Tool JX`.
2. Nhấp đúp `QUET_SOURCE_COMBAT_JX1.cmd` trong bộ Asset Forge (Python đã cài).
3. Công cụ đọc **chỉ tên/metadata, vài kilobyte đầu PAK**, file bảng nhỏ. Nó **không giải nén cả PAK/RAR, không chạy exe từ source** và không sao chép asset nặng.
4. Gửi lại **`E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake\JX1_COMBAT_SUMMARY.md`** hoặc ZIP 2 file report (summary + `JX1_COMBAT_SOURCE_MANIFEST.json`). Không gửi tất cả file client/server.

Báo cáo cho biết hai root có những file gì; nơi đặt `skills.txt`, `missles.txt`, `人物类型.txt`, số PAK thật (`PACK`), SPR/Map, thư mục client cần chỉ định. Nếu tìm ra client Kind/Part/Sect, công cụ thử lập catalog nhân vật người chơi, đánh dấu lỗi nếu không đủ dữ liệu.

## Hạn chế rõ ràng

- Không thể đọc trực tiếp ổ E: từ ChatGPT/GitHub connector; phải có **một lần chạy trên Windows** để gửi chứng cứ.
- `JX1_PACK_HEADER_VALID` chỉ là **header**; chưa xác nhận mọi SPR bên trong giải mã được.
- `SOURCE_TABLE_CATALOG_VERIFIED` chỉ là bảng/ID, chưa được gọi là hình ảnh combat đã PASS.
- **Chưa tích hợp hoặc tối ưu runtime Godot**, QA Windows/Android/FPS chưa chạy. Chỉ sau khi có manifest mới chọn những asset thật và làm atlas/streaming/culling đúng cách.

## Ưu tiên tích hợp sau báo cáo

1. MAP: tìm map JX1 chuẩn, phân biệt `.map/.mpi` và `.jpg` từ nguồn khác, xuất tile vùng nhìn thấy, pan/zoom không khóa một actor.
2. ACTOR: NPC/quái/boss vs playable rõ ràng; trang phục đúng bảng Kind/Part/Sect; atlas 8/16 hướng với anchor/z-order thật.
3. SKILL: `skills.txt`, `missles.txt`, projectile/impact/area FX, khớp content ID với bản thân Combat V2 mà không sao chép công thức sát thương JX1.
4. PERFORMANCE: tránh eager decode/texture mỗi tick; cache atlas, interpolate 250ms view snapshots, viewport/chunk culling, giới hạn draw FX, profiler frame time 30 đệ tử + 40 quái.
