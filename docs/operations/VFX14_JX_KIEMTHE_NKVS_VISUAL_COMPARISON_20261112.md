# VFX14 — Kiếm khí và pháp trận (đối chiếu JX / Kiếm Thế / Ngạo Kiếm Vô Song)
**Ngày:** 2026-11-12 · **PR:** #72 · **Phạm vi:** Combat Lab-only, không chạm numeric combat, SaveService, kỹ năng Độc Xà

## Nguồn tham khảo: ảnh/video có thể kiểm tra độc lập

- **JX / Võ Lâm Truyền Kỳ Mobile** — ảnh giao tranh có các tinh thể băng dựng trên mặt đất, nhấn hình thái chiêu và vùng tác động: https://2game.vn/tren-tay-ban-vo-lam-truyen-ky-mobile-viet-hoa-cua-vng-post48297.html. Ảnh này không phải skill kiếm, chỉ tham khảo nguyên lý đọc vùng tấn công từ góc nhìn 2.5D.
- **Kiếm Thế Origin** — ảnh thực tế chiến trường Tống Kim với kiếm khí lam/vệt năng lượng nghiêng, tương phản giữa nhân vật và hiệu ứng: https://www.bluestacks.com/vi/blog/news/kiem-the-origin-tong-kim-pk-battlefield-vi.html . Có cảnh đông người nên VFX không thể biến thành một khối sáng đặc che nhân vật.
- **Ngạo Kiếm Vô Song 2 — Hoa Sơn** — screenshot luyện đánh cọc gỗ, pháp trận xanh lục, cột năng lượng bốc lên và vùng trúng rõ trong cùng một frame: https://game8.vn/game-online/tat-tan-tat-ve-mon-phai-moi-hoa-son-trong-ngao-kiem-vo-song-2-70947.
- **Ngạo Kiếm Vô Song Origin — tài liệu môn phái Hoa Sơn** — mô tả `Độc Cô Cửu Kiếm` có 9 đường kiếm khí, không phải 9 lần damage của game mình: https://nkvso.gosu.vn/ngao-kiem-ky-thu/he-thong-mon-phai/hoa-son .
- **NKVS Origin — Bí tịch** — tên skill `Vạn Kiếm Quy Tông` của Võ Đang đã được nhà phát hành liệt kê: https://nkvso.gosu.vn/news/tin-tuc/pb1t-them-moi-bi-tich-mon-phai .
- **Kiếm Thế Origin phát hành chính thức:** https://levelup.vnggames.com/vn/vi/games/ktovn . Nêu rõ game giữ cảm giác 2.5D nhẹ; không suy diễn internal rendering engine từ marketing.

## Kết luận từ screenshot (quan sát được; không giả vờ đo timing video)

| Trục so sánh | JX / Kiếm Thế / NKVS trên ảnh | VFX13.1 trong Godot | VFX14 giải pháp |
|---|---|---|---|
| Hình chiêu | Vệt sáng có khối/độ cong, không chỉ các vật thể rời | 9 thanh kiếm thẳng nhỏ, đầu sáng mảnh | Mũi kiếm vẫn rõ + dải kiếm khí cong thuôn động phía sau, tách ánh sáng khỏi mặt kiếm |
| AOE | Vùng tác động phân biệt nhờ vòng pháp trận, cọc năng lượng và mốc đích | Vòng AOE xanh đơn, phù văn nhỏ dễ bỏ qua | 3 tầng ellipse, 12 glyph, 2 cung quay, chỉ đánh dấu 3 vị trí đã được xác nhận |
| Impact | Chớp ngắn và vùng sáng mạnh tại nơi tấn công | Chớp va chạm nhỏ, có thể như bay xuyên người | Cột kiếm quang xanh lam dựng dọc rất ngắn, lõi trắng sắc, ring lan, vệt cắt chéo |
| Choreography | Chiêu kiếm phải có nhịp và hướng đọc rõ | 9 kiếm/3 volley đúng, nhưng cả cảnh phẳng | Giữ 3 volleys, thêm 3 cung kiếm khí mờ theo nhịp, không tạo hit/damage |
| 30 actor | Ảnh đông người cho thấy độ rối cần giới hạn | V13 khá nhẹ nhưng thiếu lực | Mỗi kiếm giữ fixed 5 segments cho trail, impact một lần mỗi approved target, không spawn particle |
| Gameplay | Skill khác nhau có hình thái khác nhau | Lab chỉ mô phỏng một dạng `circle` | Giữ target-bound circle, chưa tự suy diễn single/line |

**Phương pháp:** không copy sprite, artwork, frame animation hoặc mã của game tham khảo. Toàn bộ VFX14 là procedural geometry tự viết trong Godot. Không công bố video tham khảo là đã xem từng frame nếu chỉ kiểm tra screenshot và mô tả.

## Kỹ thuật và bảo vệ gameplay
- File mới: `godot/labs/combat_lab/combat_lab_v14_sword_fx.gd`; kế thừa interface V13 `render(canvas, caster, locked_center, hit_targets, radii_px, t, zoom, lod)`; mục tiêu/đường kính lấy từ caller, tuyệt đối không quyết định hit hoặc sửa V63.
- Lab: click chọn quái làm tâm, 4 mock monsters, tối đa 3 người được preview kiếm nhắm; primary AOe không chạy theo monster sau khi cast. AOE radius 130×120 là SCREEN PREVIEW, không thay thế V63 world radius.
- Chỉ ảnh chụp đối chiếu mô tả nguyên lý: curved trail, sword flare, cột sáng = thiết kế VFX14 original, không khẳng định đó là rendering nội bộ game tham khảo.
- Full 60-FPS encoded offline movie != native measured GPU FPS. 30 actors/Windows/Android PENDING; no game skill enabled. ART_CANDIDATE, OWNER_PENDING.
