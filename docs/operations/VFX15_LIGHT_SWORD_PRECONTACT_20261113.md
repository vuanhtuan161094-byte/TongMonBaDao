# VFX15 — KIẾM QUANG 2.5D / PHI VẬT THỂ / DỪNG TRƯỚC QUÁI
**Ngày:** 13/11/2026 · **Repository:** `vuanhtuan161094-byte/TongMonBaDao` · **PR:** #72 · **Sở hữu:** VFX-only

## 1. Góp ý mỹ thuật của chủ dự án (đã chốt)
- Không cần vẽ thanh kiếm rành rọt như đồ vật 3D: game 2D/2.5D, **kiếm là hình quang khí có lõi sáng, vỏ mờ và dư ảnh**, có độ đọc tốt ở kích thước chiến đấu.
- Đầu kiếm bay tới gần quái phải **dừng ngoài hình nhân vật**, co/mờ và **chuyển thành hiệu ứng chạm**: không có frame một thanh kiếm đâm xuyên qua cơ thể quái.
- Giữ điểm tích cực của Godot shader: caster glow, AOE nền, quầng xanh lam, kim quang ngắn. Đọc được trong cảnh nhiều quái. **Không cần model 3D**.

## 2. Kế hoạch thực thi & mục tiêu kiểm tra

| Giai đoạn | Mã thực hiện | Tiêu chí |
|---|---|---|
| V15.0 — Kiếm quang nguyên bản | `combat_lab_v15_sword_fx.gd::_light_blade` | Bỏ chuôi/chắn tay/mặt thép; ánh sáng có dáng kiếm, lõi trắng, vỏ xanh phân lớp; art_source: code |
| V15.1 — Lụa kiếm khí | `_flow_trail` | 5 dải quad lồi + dòng sáng đổi pha; các nét không xuyên lõi vật thể/không tạo ảnh PNG |
| V15.2 — Chạm đúng vị trí | `contact_time`/`contact_point`/`projectile_tip` | End projectile sớm ở 82% flight, mũi dừng ~29px trước ngực quái trong *scale demo*. Không render projectile từ `t >= contact_time`. |
| V15.3 — Biến thành impact | `_impact_burst` | Chuyển va chạm sang vệt chém trắng + halo lam + ring dưới chân. Đợt 1,2 rất nhẹ, đợt 3 mạnh; không nhân 9 hit gameplay. |
| V15.4 — AOE phù văn | `_sigils` | Vòng ngoài trong xuyên sáng và cung phụ, không che 4 quái; chỉ marker những hit_targets được caller cấp |
| V15.5 — Choreography | `render` | 9 kiếm / 3 volley; với AOE chỉ 1 hoặc 2 mục tiêu vẫn giữ đủ 3 đợt. Không phát VFX nếu list mục tiêu trống. |
| V15.6 — Kiểm thử | Godot 4.7.2 CI, contract, MP4 1280×720 | Kiểm chứng đúng code SHA, xem nhiều mốc thời gian, ưu tiên tránh frame xuyên quái và không dùng 60fps encode làm chỉ số hiệu năng thiết bị |

## 3. Bảo vệ gameplay
- Interface: `render(canvas, caster, locked_center, hit_targets, radii_px, progress, zoom, lod)`. **Không được sửa** HP, target selection, V6.3, character movement, timers, SaveService, AI, equipment.
- `hit_targets` và `locked_center` phải đến từ nguồn authoritative khi tích hợp PvE thật; AOE radius `radii_px` dùng trong LAB chỉ là bản chiếu 2D, **KHÔNG đồng nhất 2,7 world-unit** của Kiếm Tu candidate.
- Catalogue Sword V6.3 hiện OFF; màn bấm 4 quái là demo visual-target lock, không phải game chính đã hỗ trợ click-to-target.
- VFX Độc Xà V9 giữ nguyên; V14.2 giữ nguyên file để rollback.
- Giới hạn 3 targets của skill demo; 9 kiếm hình ảnh không tương đương 9 lần gây damage. Lưu ý nợ shared combat: khi có 4+ quái thật trong circle và target limit 3, code duyệt ID có thể bỏ mục tiêu caster chọn. Không sửa shared target selector trong VFX lane.

## 4. CI isolation và báo cáo bắt buộc
- **Official full strict Godot** có nguy cơ FAIL vì lỗi ngoài VFX ở `godot/src/simulation/combat/v63_summon_skill_combat_system.gd:303` — `var candidate := origin+offset` không infer type. Đây là mã do luồng combat quản lý; VFX lane **không commit thay đổi** lên tệp đó.
- Workflow riêng `.github/workflows/vfx-v15-isolated-godot-lab.yml` áp dụng đúng một annotation `Vector2` vào file ngoại vi **trong checkout tạm thời của CI** và thông báo `qa_mode=ISOLATED_UNCOMMITTED_SUMMON_TYPE_SHIM_NOT_FULL_REPO_PASS`. Không sử dụng kết quả này như bằng chứng full clean PR SHA.
- Nếu Godot V15 script lỗi, sửa đúng tệp VFX/test và chạy lại. Nếu khác ngoài VFX lỗi, không âm thầm vá trong PR rồi tuyên bố pass.
- Nghiệm thu phải xem 9 frame thật ở t≈0.40,0.50,0.65,0.85,1.05,1.30,1.55,1.85,2.15 giây; so V14.2 cùng timestamp. Không phê duyệt mỹ thuật thay owner.

**Status lúc lập tài liệu:** V15 renderer committed và đã nối vào Lab; đang kiểm chứng Godot+video. `ART_SOURCE=CODE`; `ART_APPROVAL=OWNER_PENDING`; `LIVE_GAME_PVE=HOLD`.

## 5. Bản thực hiện và bằng chứng QA — 13/11/2026

- Source mới `combat_lab_v15_sword_fx.gd`, sprite/art source **procedural Godot code**; file V14.2 cũ nguyên vẹn. Hoạt ảnh: tụ khí, 3×3 đợt kiếm ánh sáng, co biến hình cuối 34% quỹ đạo, mũi dừng trước ngực quái, chớp tiếp xúc, slash vòng cung, 2D ring và dư quang. Không sinh hạt node.
- Godot 4.7.2 isolated script/check pass tại [run #43354663864](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43354663864) trên code SHA `143b5b9276f868891f8d8b205187a3f91c434e66`, artifact `vfx-v15-isolated-143b5b9276f868891f8d8b205187a3f91c434e66`. Video thật 1280×720, 165 frame, mã hóa 60 FPS; snake overlay vẫn không thay đổi.
- Tự nghiệm thu qua 12 khung đối chiếu V14.2/V15.0/V15.1 ở 0,50–2,18 giây: V14.2 còn lưỡi kiếm vật thể nằm xuyên người quái; V15.1 chỉ có quang kiếm bay ngoài thân, rồi thay bằng contact slash/halo (ở frame 1,65–2,05). Màn demo giữ 3/4 mock targets, không tạo damage gameplay.
- V15.0 impact hơi thiếu lực nên đã sửa V15.1: tăng flash trắng-xanh ngắn, thêm 1 cung chém nóng trắng, shock ring xanh/vàng dưới chân, có wisp thu lại trước va chạm. Ảnh từ Godot (không ImageGen) và GIF từ MP4 là bằng chứng thị giác.
- **Isolated QA != full-branch clean QA**: dòng `godot/src/simulation/combat/v63_summon_skill_combat_system.gd:303` bên combat đang parse FAIL (candidate không infer kiểu). Trong QA riêng, dùng annotation thử nghiệm chỉ trong runner, không commit; trạng thái tổng repo **BLOCKED**, không tự sửa code triệu hồi ngoài lane.
- **OWNER VISUAL APPROVAL PENDING**. Chưa nghiệm thu 30 diễn viên/Android/Windows và chưa đưa vào One Game; 60 FPS xuất phim không tương đương tốc độ máy thật.
