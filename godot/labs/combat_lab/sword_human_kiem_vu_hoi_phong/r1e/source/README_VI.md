# Kiếm Vũ Hồi Phong Nhân — R1E | VFX ONLY (candidate)

- Không có nhân vật, không cắt từ poster, không gắn vào PvE.
- Master: ảnh 12 ô VFX được AI tạo trực tiếp. Master có nhãn số ở góc các ô và nền RGB đen mờ (dù nguồn là RGBA); **master không phải asset runtime**.
- 12 PNG riêng: tách ô trực tiếp từ master sprite sheet, xóa nhãn số ở góc, hiệu chỉnh black matte thành alpha kiểu emissive; ghép atlas 4×3 kích thước 2048×1536.
- VFX nền alpha không có nhân vật; không có chi tiết kiếm rườm rà. Một chuỗi gồm tụ khí, xuất chiêu, quang khí xoay, va chạm và tan quang.
- GIF 1× (174 px) trên nền tối/sáng để duyệt mỹ thuật. Thời lượng của GIF là clock xem hình, **không phải timing runtime 0,36 s**.
- QA kỹ thuật: 12/12 frame RGBA có alpha; 12/12 nội dung khác nhau; 12/12 giữ viền an toàn 8px; có atlas đúng kích thước.
- Giới hạn: Alpha được phục hồi bằng hậu kỳ từ một master đã được AI render với bóng nền đen. Đó là alpha có nguồn gốc hậu kỳ, không phải một bộ 12 lớp alpha gốc được vẽ độc lập. Một số nét quang mảnh sẽ bị nhạt trên nền sáng. G3 mỹ thuật vẫn **CHƯA CHỐT**.
- Không ghi đè R1C-B, không commit GitHub, không Godot, không merge, không Codex Cloud, không rig, không PvE.
