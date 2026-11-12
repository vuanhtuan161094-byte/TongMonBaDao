# VFX13 — TARGET-BOUND KIẾM AOE & GODOT LIGHT ART (2026-11-12)

## Owner yêu cầu
- VFX kiếm đẹp hơn VFX12, đặc biệt ánh sáng Godot, chuyển động, va chạm.
- **Đánh ai phải thực sự đánh người đó**; phân biệt AOE, đơn mục tiêu và đường định hướng.
- Triển khai TRỰC TIẾP trên PR #72/nhánh hiện có; không giao Codex, không tạo nhánh/merge, không sửa combat V6.3, HP, SaveService hoặc VFX Độc Xà.

## Bằng chứng gameplay hiện hành (đối chiếu source)

1. `godot/data/combat/v63_sword_combat_catalog.json`: **enabled=false, release_gate=OFF**, ứng viên có 183 kỹ năng (144 `single_target`, 24 `circle`, 15 `line`, bao gồm node không phải kỹ năng tấn công). *Vạn Kiếm Quy Tông — Nhân giới* `tmb.skill.sword.ngu_kiem.ultimate.human` = `shape=circle`, `radius=2.7` **world units**, `target_limit=3`, `range=9`, `projectile_speed=10`, `cast_time=1.1`. Dữ liệu ứng viên chưa nghiệm thu nguồn và balance, không được quảng bá là tính năng đã mở trong One Game.
2. `godot/src/simulation/combat/map_battle_v2.gd` `_nearest_enemy`: AUTO ưu tiên quái địch còn sống ở gần người thi triển nhất, theo các điều kiện hiện hành (hunt radius/hold/aggro).
3. `godot/src/simulation/combat/v63_human_skill_combat_system.gd` `_begin_cast`: AOE khóa `cast.center = target.position` **lúc cast**; `line` khóa `line_origin` và `line_direction` theo mục tiêu; `single_target` giữ target_id.
4. `_cast_targets`: đến lúc resolve `circle` lấy những actor còn sống trong `cast.center` + `radius`, tối đa `target_limit`; `line` kiểm tra trục hướng đã khóa với bề rộng 0.85 world units mỗi phía; `single_target` theo target_id. Do đó 9 hình kiếm bay KHÔNG tự tạo 9 lần sát thương.
5. **NỢ NGHIỆP VỤ PHẢI SỬA TRƯỚC KHI MỞ KIẾM TU:** `_cast_targets` hiện duyệt ID đã `sort()` và cắt ở `maximum`. Nếu có 4+ quái trong circle mà `target_limit=3`, mục tiêu được chọn làm **tâm AOE** có thể không thuộc danh sách ba mục tiêu nhận damage. Đây là sai khác với kỳ vọng Owner “chọn ai đánh người đó”. Vì đây là **shared combat authority** do luồng kỹ năng khác đang quản lý, KHÔNG được âm thầm sửa trong riêng đợt art VFX; cần yêu cầu đánh giá + regression combat chuyên biệt trước mở gate.

## Thực hiện VFX13, Combat Lab ONLY

- Mã `godot/labs/combat_lab/combat_lab_v13_sword_fx.gd`: người gọi phải truyền trực tiếp `locked_center`, `hit_targets` (danh sách Vector2 được duyệt trước), `radii_px`, `progress`. Renderer không có quyền chọn hit, chỉnh damage, truy vấn scene monsters hay phát event.
- `preview_circle_targets` dùng riêng cho demonstration. Với 4 quái 2×2 ở 1280×720 và `radii_px=(130,120)`, mỗi góc được chọn làm tâm đều có đúng **3 mục tiêu hợp lệ**, quái đối góc nằm ngoài ellipse. Số pixel là bố cục demo, **KHÔNG** thay thế radius world=2.7 trong combat runtime.
- `combat_lab_v9_light_showcase.gd`: bấm chuột vào một trong 4 quái để chuyển `preview_primary_index`, cập nhật `sword_preview_center`, `sword_preview_hits`, vòng shader mặt đất theo đúng tâm đã khóa, phát lại. Màn hình ghi rõ `TÂM QUÁI N · TRÚNG 3/4`. Đây chỉ là Lab mouse targeting test, KHÔNG có bằng chứng One Game đã hỗ trợ click-to-lock enemy trong PvE.
- VFX cải tiến: 9 kiếm khí / 3 volley, rigid blade còn rõ mặt thép, trail tam giác taper với 2 alpha layers + 3 motes có giới hạn, 1 vòng AOE ngoài/trong, 12 dấu phù, 3 vòng dưới quái trúng, mỗi quái có 1 impact flash/cắt và ring. Quái thứ tư KHÔNG có hit flash.
- VFX Độc Xà giữ nguyên; các lớp shader charge/AOE Godot V11 vẫn được sử dụng và chuyển theo tâm AOE; không nhập ảnh VFX có bản quyền.
- Ở chế độ chiến đấu chính, **KHÔNG gắn VFX13 vào kỹ năng đã khóa**. Hiện là scene thử nghiệm và giao diện có thể click; production authority integration `HOLD` cho đến khi gate sword được duyệt.

## Nghiệm thu
- CI Godot 4.7.2 strict import/parse + VFX/V4 contract; test 4 khả năng đổi tâm đều trả 3 mục tiêu, loại quái góc đối, không có target thì không bắn, alpha kiếm mờ dần.
- Visual: đối chiếu 9 frame từ video 1280x720/60 FPS export, kiểm tra khi đổi mục tiêu (GUI click thực trên thiết bị cần user QA), shader không che quái, thử cảnh nhiều người trước đưa vào One Game.
- **ART_CANDIDATE, OWNER_VISUAL_PENDING.** MP4 có mã hóa 60fps KHÔNG bằng FPS thực đo trên Android/Windows. Không tuyên bố đã sửa lỗi `_cast_targets` hoặc kích hoạt Sword Gate.

## Nghiệm thu V13.1 — kết quả cuối 2026-11-12
- V13.1 sword renderer code SHA `f8f73d798a62e2f9fd801b269c269f1f9fdb1b57`: tapered convex light wake behind hilt, bounded motes, white/blue directional impact cut only on explicitly supplied hit targets.
- Final focused Godot 4.7.2 exact-SHA run [#43266009278](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43266009278) **SUCCESS** on `ec48f5738fc6098f7a7cb7c4bb3f8354f7d07901`. Strict import+GDScript, V9/V4 contracts, synthetic click on monster #4, 4 primary positions each binding exactly 3 targets, 4th diagonal excluded, zero target cap, sword dissipation. Generates actual 1280×720 165-frame video with ffprobe 60/1 FPS; QA archive `vfx-v13-godot-ec48f5738fc6098f7a7cb7c4bb3f8354f7d07901`.
- All nine phases reviewed from Godot output; owner has **not** approved art. `ART_CANDIDATE / OWNER_VISUAL_PENDING`; no Android/Windows native runtime FPS proof. The video records initial primary #1; changing the selection for all four corners is covered by Godot code-level synthetic mouse tests, not external mouse GUI video capture.
- The shared `_cast_targets` ID-sorted selection issue mentioned above is still **OPEN**; no claim the LIVE game has target-priority correctness. Sword gate remains OFF and V13 is demonstration only.
