# TMB — Weapon Language Guide cho đệ tử 12 phái — 2026-11-17

**Status:** DESIGN_CANDIDATE_OWNER_REVIEW_PENDING · art-only. Không tạo item/effect, không thay số liệu/economy/combat. Vũ khí/đạo cụ trong master là hình tham khảo; production cuối cần asset vũ khí RGBA riêng và grip/z-order theo từng hướng/pose.

## 1. Quan sát nguồn tham khảo

- Pinterest đã được tìm theo các cụm xianxia/chinese fantasy weapon, talisman, fan, sword, spear và dual blades. Công cụ tìm có surfacing các liên kết Pin nhưng không mở được trang Pin công khai; **không tải, không dùng hoặc sao chép ảnh Pinterest nào**, nên đây chưa phải Pinterest art approval/research đầy đủ.
- Các trang tham khảo có thể truy cập dùng để rút ra nguyên tắc hình khối, không trích hình: [artbook gallery Tiên Kiếm 5 tiền truyện](https://pal5q.cubejoy.com/pal5q/pal5q/zhuanti/gallery/index.html) cho cách giữ một motif ngọc/tua/hoa văn nhất quán trên phụ kiện nhỏ; [trang vũ khí Thần Ẩn của Tru Tiên](https://zhuxian.wanmei.com/news/gamenews/20230907/86367.shtml) cho tương phản thân lưỡi–guard–tua và cách giữ silhouette mạnh. Các trang này là IP bên thứ ba, chỉ tham khảo nguyên tắc, không trace, copy, crop hay nhập sprite.
- Ưu tiên cao hơn mọi external reference: Source A asset đã được verify, tài liệu owner lock, asset approved trong repo. Không có Source A character/weapon theo trường phái đủ điều kiện để vẽ đè vào đây.

## 2. Quy tắc hình vũ khí ở scale game

1. **Silhouette trước vật liệu:** khi thu về actor cao 60–75 px, phải đọc được loại vũ khí. Bỏ chi tiết nhỏ mất ở 1×.
2. **Ba khối lớn:** thân/lưỡi/cán; điểm cầm/guard; một dấu motif chính. Tránh chồng 5 loại ngọc, tua, rune và glow.
3. **Một điểm nhấn, một vật liệu phụ:** phản sáng ngắn trên cạnh, tối một bên, accent gem/ribbon chỉ để phân biệt.
4. **Cân trọng lượng:** jian thon và cân; dao rộng lệch trọng tâm; spear dài nhưng đầu nhỏ; bow đọc được limb và string; song đao phải có hai lưỡi tách biệt.
5. **Pose-compatible:** grip tách với bàn tay; ghi socket; mặt trước/mặt sau riêng; dây tua ngắn hơn bề rộng đầu nhân vật để không phá hitbox/occlusion.
6. Không dùng glow để cứu silhouette; VFX luôn layer riêng. Vũ khí không chứa damage/status/AoE/target cap hay vật tư tiêu hao.
7. **Master → item source:** bản master có thể cầm prop để chứng minh thiết kế nhưng không dùng crop bàn tay/vũ khí làm item file. Vẽ item RGBA mới từ master sau khi identity/pose được duyệt.
8. Lớp bàn tay và cán phải có z-order đúng: vũ khí trước tay ở phần guard, sau tay ở chuôi nếu cần; mirror chỉ khi form thật đối xứng và manifest cho phép.

## 3. Hình ngôn ngữ riêng từng phái

| Phái | Hình vũ khí / pháp cụ | Chi tiết riêng để dễ nhớ | Tránh |
|---|---|---|---|
| Cung Tu | Cung recurve nhẹ, thân cong thành cung trăng; limb trên/dưới khác rất nhẹ để có tay cầm dễ nhận | grip bạc mờ, dây tối, một đầu lá bạc; không gắn lưỡi | cung tròn kín, hai cung, projectile trong ảnh |
| Quyền Tu | Không có vũ khí; bọc tay vải + hộ cổ tay | một đường chỉ đồng đỏ, nút buộc phẳng | quyền trảo, găng gai, nắm đấm kim loại |
| Độc Tu | Cặp châm thon và lọ nhỏ nắp niêm, item tách nhau | thân châm tối, một điểm ngọc xanh; dây seal nhỏ | đầu lâu, xích, rắn vật lý, hơi độc VFX |
| Kiếm Tu | Jian hai cạnh, thân thẳng; variant owner-liked là thép đen/đỏ bất đối xứng có cạnh khía hữu dụng, không răng cưa dày | guard nhỏ như cánh kiếm, gem đỏ đơn, chuôi bọc vải | kiếm to như đại đao, glow xanh mặc định, copy vũ khí IP |
| Đao Tu | Đơn đao bản rộng, cong một cạnh, sống lưỡi dày và guard bảo vệ tay | rãnh màu đỏ gạch gần sống/ốp chuôi | kiếm thẳng, hai thanh, rìu cánh lớn |
| Song Đao | Hai đoản đao bất đối xứng cùng family; một có lưng móc nhẹ, một mũi thẳng hơn; ghép đôi tạo cung khuyết | dấu cặp nằm ở pommel, màu accent chỉ một điểm | nhân đôi cùng một lưỡi, hai jian dài |
| Thương Tu | Thương cán dài, mũi lá hẹp, socket chắc, tua ngắn nằm dưới mũi | một vòng kim loại phân vị trí grip | đầu chĩa ba/halberd, cán to lấn thân |
| Chưởng Tu | Không có vũ khí; bao cổ tay mềm và vòng tay jade thấp | đường khâu uốn hướng lòng bàn tay | quạt/kiếm/găng cơ khí |
| Trận Tu | Pháp cụ: tinh bàn/luopan nhỏ và que chỉ điểm | một mặt tám cạnh, 4–8 vạch trừu tượng không phải chữ | khiên/trận vòng quanh actor/vũ khí sắc |
| Triệu Hồi | Khế vật token dạng nút đồng-ngọc ở dây đeo; prop hỗ trợ giao ước, không gây đòn | dây có khóa mở được và một dấu đôi | thú/kiếm linh/khôi lỗi ghép vào ảnh, lồng/xiềng |
| Chú Tu | Chuỗi cộng hưởng đồng nhỏ/thẻ ngắn, không phải vũ khí đánh | 3 hạt kim loại lớn dễ đọc, một chuông rất nhỏ | giấy phù/phù văn bay/chữ neon |
| Phù Tu | Bút lông ngắn + 1–2 lá phù giấy trơn tách layer | cán bút tối, ngòi đỏ, viền giấy nhẹ | lá phù rối, chữ Hán giả, lửa/sét đã bake |

## 4. Nguyên tắc biến thể theo 36 nhánh

- Nhánh đổi **tay cầm/pose/ornament phụ**, không buộc thay loại weapon family nếu source không nói.
- Ngự Kiếm có thể có actor kiếm bay khi gameplay/source thật cấp; master chỉ giữ một kiếm hoặc token chỉ dẫn.
- Hộ Kiếm không tự thêm shield item; tư thế guard và guard weapon design là hình ảnh thôi.
- Thương “Long Thương” không đồng nghĩa mũi spear có dragon sprite; “Hộ Quân” không tự đổi sang khiên.
- Nhánh Phù/Chú/Trận không có quyền biến câu chữ thành tài nguyên/vật phẩm hay projectile.
- Triệu Hồi luôn giữ companion ngoài sprite của chủ, có vòng đời/authority riêng; tài liệu này không yêu cầu integration.
