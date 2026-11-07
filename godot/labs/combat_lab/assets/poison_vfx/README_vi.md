# VFX Độc Tu — master đồ họa

Bộ texture RGBA này thay hình học nguyên mẫu cho VFX Độc Tu trong Combat Lab. Asset là artwork 2D gốc được tạo riêng cho Lab; không lấy sprite bên ngoài và không thay đổi sáu atlas Nữ Độc Tu.

| Nhánh | Master | Cách dùng |
| --- | --- | --- |
| Độc Châm | `doc_cham_needle.png` | Tụ kim, đạn bay, quạt kim theo `target_limit`, điểm trúng |
| Cổ Độc | `co_doc_gu_serpent.png` | Cổ/linh xà, ấn, phệ độc hút vào tâm |
| Dược Độc | `duoc_doc_jade_lotus.png` | Niệm pháp, hồi phục, giải hiệu ứng |
| Dùng chung | `venom_smoke_corrosion.png` | Vệt bay, độc tick, mây/diện tích theo bán kính skill thật |

Renderer hoạt ảnh master bằng vị trí, hướng, tỷ lệ và alpha theo thời gian sự kiện. Đây là texture tĩnh, không được ghi nhận thành flipbook/animation frame riêng. Master không tạo damage, stack, heal, cleanse, loot hoặc vùng hiệu ứng mô phỏng; tất cả số liệu vẫn đến từ V6.3.

Xem `poison_vfx_manifest.json` để biết schema, kích thước, SHA-256 và fingerprint sáu atlas actor được giữ nguyên.
