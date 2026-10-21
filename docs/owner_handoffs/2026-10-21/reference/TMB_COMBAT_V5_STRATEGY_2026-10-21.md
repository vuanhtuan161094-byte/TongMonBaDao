# TÔNG MÔN BÁ ĐẠO — Combat V5: quyết định kiến trúc và hướng mỹ thuật

**Ngày:** 2026-10-21  
**Trạng thái:** ĐỀ XUẤT THIẾT KẾ; chưa thay luật combat, chưa tạo asset/skill production, chưa có Godot 4.7.2 runtime acceptance.  
**Dự án:** `vuanhtuan161094-byte/TongMonBaDao` — Android landscape 1280×720.  
**Nguồn khảo sát:** `G0C_AUDIT_2026-10-21.zip` của chủ sở hữu, tài liệu `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`, `docs/C4_JX1_SOURCE_FIRST_WORLD_AND_FREE_CAMERA_2026-10-20.md`, các scripts `MapBattleV2`, `MapBattleWorldLayerV2`, `CombatV4SpriteAtlas`, `CombatV4EffectAtlas`.

## 1. Quyết định khuyến nghị

**Chọn Combat V5 TỰ CHỦ / AUTO-REALTIME TU TIÊN**: giữ backend Combat V2 được khóa làm mô hình tác chiến và sát thương; xây riêng presentation, AI policy và nội dung skill *qua những gói được chủ sở hữu phê duyệt riêng*. Dùng **Source A làm định hướng mỹ thuật chính**, không chuyển nguyên cơ chế đánh theo lượt của 《最强祖师》. Tham khảo **Evil Hunter Tycoon** ở gameplay người chơi quản lý đội/hunter, nhân vật tự săn, tự hồi phục, tự trang bị; không sao chép pixel art. **JX1 là nguồn tham khảo hoặc nguồn asset chọn lọc**, không còn là tiêu chí “phải giống nguyên bản” cho production. Không trộn JX1 sprite kích thước/phong cách cũ lẫn Source A chibi trong scene chính nếu không qua kiểm tra visual consistency.

**Điều giữ nguyên:** CombatStatsV2, MapBattleV2 và cơ chế tính sát thương/RNG/element đã khóa; 30 Tu Vi × 10, 30 Luyện Thể × 10; các hệ đệ tử/workforce, injury 0/1/120, one active job, warehouse/save/offline. Gameplay thật nằm ở simulation; presentation dùng event/read-only snapshot. Thay đổi AI/cooldown/targeting/new status/new skill numbers phải là packet riêng có test compatibility.

## 2. Vì sao không nên 'bê nguyên JX1'

1. **Chi phí chuyển đổi không đồng nghĩa chất lượng gameplay.** Báo cáo owner G0C xác minh 17.544 file `.spr`, 32 PAK, 1.406 SkillId và 987 MapId của client, nhưng mới ở mức FILE_VERIFIED; graphics/map/collision và hành vi skill chưa phải CONVERSION/RUNTIME PASS.
2. **Mỹ thuật lệch Source A:** JX1 truyền thống thiên võ hiệp hình người thật/tỉ lệ khác; tông môn Source A thiên chibi tu tiên. Một game có 2 mỹ thuật chưa thống nhất nhìn giống ghép mod.
3. **Cơ chế JX1 không phải mục tiêu tu tiên:** V5 cần số lượng đội lớn, đệ tử tự động săn; nhãn skill gắn với Lục Duy, công pháp, linh căn và mô hình V2, không thay bằng damage/hit/cooldown JX1.
4. **Kỹ thuật:** JX1 trang phục đa lớp có hướng sort/frame/offset riêng; bản AF-04 vẫn đợi xác minh binary thật. Dùng nó làm prerequisite cho toàn bộ combat gây block không cần thiết.
5. **Hiện trạng renderer:** `MapBattleWorldLayerV2` vẫn fallback sàn/cây Source A, map chưa phải JX1 gốc; Atlas nhân vật hiện `hero`/`wolf`, Boss dùng wolf scale; hiệu ứng JX1 mới chỉ map được một số cue. Do đó cảm giác còn khác JX1 là tất yếu.

## 3. Vì sao không lấy nguyên combat Source A

Source A là nguồn tốt cho art direction tông môn, công trình, chân dung, chibi, màu sắc và giao diện. Nhưng 《最强祖师》 có combat tự động theo lượt; game của chúng ta đã khóa **realtime, nhiều đội, tự săn quái liên tục**, không quay về trận đánh theo lượt. Source A chuyển đổi Spine 3.8 → WebP/SpriteFrames đã có **10 rig kỹ thuật PASS, 31 clip**, song ba actor đang dùng cho MAP25 chủ yếu `stand/walk`; chưa có bằng chứng `attack/cast/hit/die` hoàn chỉnh trên các rig đó. Phải làm một art pilot combat trước khi khẳng định sẵn sàng.

## 4. Tầm nhìn sản phẩm và vòng chơi

- Người chơi là tông chủ, **không phải nhân vật ARPG tự điều khiển trực tiếp từng lần đánh**.
- 6 đệ tử/đội, có thể tổ chức nhiều đội trên map mở; 30 đệ tử và 40 quái là bài stress-test, không phải bắt buộc vẽ mọi actor cùng lúc.
- Đệ tử tự chọn mục tiêu, di chuyển, đánh thường, dùng **kỹ năng thực sự đã học/trang bị** theo policy/ưu tiên và cooldown authoritative; auto farm, hunt Boss, rút về hồi phục, vòng lặp tài nguyên do các hệ canonical xử lý.
- Bản đồ 2.5D/chibi tu tiên rộng, camera free pan/zoom, chỉ follow khi chủ động chọn một đệ tử, không khóa vào arena 36×20 mặc định (trạng thái live-world và đường đi cần packet riêng).
- Visual quan trọng: cảm giác đủ nhanh nhưng đọc được diễn biến; nhân vật không bị VFX và nhãn che khuất; Boss telegraph nhận diện rõ.

## 5. Hướng dựng hình thống nhất

**Ưu tiên đầu:** 1 rig thật từ Source A có bằng chứng animation combat; thử một đệ tử, một quái/Boss và map style tương hợp (ưu tiên Source A). Nếu rig gốc không có combat clip, KHÔNG đổi tên `stand/walk` thành `attack`; lập yêu cầu clip gốc hoặc tự dựng action mới mang nhãn `custom`, phân biệt rõ provenance. Với 2 hướng trái/phải, mirror chỉ cho rig, trang bị và hoạt ảnh an toàn; không giả lập 16 hướng khi source không có.

**Tự làm skill/VFX bằng Godot:** Shader 2D / GPUParticles2D / sprite atlas tự tạo + AnimationPlayer/Tween + trail/impact/decal + bounded pooling. VFX phải phát theo event authoritative: `cast_start` → `release/projectile` → `hit/area/status`; thời điểm hit không do frame animation quyết định. Đầu tiên dùng effect độc lập với body animation để không block toàn bộ hệ thống. Mỗi hiệu ứng cần schema: `skill_id`, `event_name`, `duration_ms`, `layer`, `priority`, `sprite/texture`, `tint`, `foot_anchor`, `source_hash`, `max_instances`, `fallback`. Không tạo status/damage hoặc cooldown giả.

**Đề xuất bốn họ VFX thí điểm** (tên/mỹ thuật, không phải skill cân bằng đã được phê duyệt):

| VFX pilot | Trigger hợp lệ | Thiết kế |
|---|---|---|
| Kiếm khí | Basic/skill release + actual hit | Vệt chém mảnh, đường kiếm, impact thoáng dưới 0.3s |
| Ngự hỏa | Projectile launch → impact | Quang cầu có trail ngắn, nổ cỡ nhỏ, không che toàn màn |
| Thủy/Băng | Area cast và hit/active status nếu có | Vòng báo hiệu mặt đất + tinh thể vỡ, tránh giả slow khi simulation không có |
| Hồi xuân | Actual heal event | Lá/làn khí xanh nhạt, icon lượng HP thực tế, không spam |

**Cấm:** biến visual làm nguồn damage/loot/AI; full-screen bloom/spam particles; load SPR/PNG mỗi frame; rải nhãn HP/status không giới hạn. Không trộn VFX JX1 cũ vào final chỉ để có nhiều hiệu ứng.

## 6. Mốc implementation được đề nghị

### V5-G0 — AUDIT/ART DIRECTION (read-only; làm ngay)

- Codex kiểm đúng một rig Source A có khả năng fight và hai rig `body_1120402`, `1113028_1` hiện có; phân loại clip có thật, rig/skin, anchor, size, palette. Kiểm một quái Source A phù hợp; nếu chưa tìm thấy thì đánh dấu missing.
- Dựng 1–2 **contact sheet/preview bằng binary có thật** (không retouch ảnh gốc), chốt tỷ lệ nhân vật/cây/map và nêu bản nào source thật, bản nào custom.
- Đối chiếu Combat V2 event schema và current C4 renderer, không sửa gameplay.
- Quyết định chọn hướng visual chính chỉ sau khi xem video/screenshot chất lượng thực tế.

### V5-G1 — PLAYABLE LOOK PILOT (owner authorize code packet riêng)

- Một map 2.5D có nguồn thống nhất, 6 đệ tử/5 quái, một Boss, camera tự do; không dùng đốm tròn trừ debug và fallback được gắn nhãn rõ.
- Một rig nhân vật có idle/walk/attack/hit/death thật hoặc custom được khai báo rõ; một quái đủ clip; bốn họ VFX event-backed nói trên.
- Giữ Combat V2 nguyên trạng, chỉ đổi renderer/adapters và art manifest; không thay damage, RNG, skill data, active job, save.
- Ảnh chụp/video thật trên 1280×720 và so sánh 2 phong cách nếu còn phân vân.

### V5-G2 — HUNTING OPEN WORLD & 30×40 PERFORMANCE (packet riêng)

- Nhiều đội tự săn, viewport/chunk culling, asset prewarm + atlas shared, render interpolation không tạo gameplay, cache/pool bounded, pan/zoom/touch.
- Đo P50/P95 frame time và bộ nhớ trên Windows và Android thật; mục tiêu thiết kế Android ổn định 30 FPS (P95 ≤33.3ms) trước khi nâng 60 FPS (P95 ≤16.7ms) nếu máy đủ mạnh. Không tự gọi PASS từ synthetic tests.

### V5-G3 — ORIGINAL SKILL LIBRARY (packet nội dung/balance riêng)

- Mở rộng công pháp/linh căn/tu vi/thể tu và VFX theo hệ thống học skill, rarity/tầng/cường hóa hiện có; thêm status/cooldown chỉ khi có quyền đổi Gameplay Combat V2. Catalog ID+event+visual đủ chi tiết cho nhiều kỹ năng dùng chung renderer.

## 7. Quyết định kỹ thuật / không được xóa các kết quả cũ

- Giữ repo/nhánh/manifest C4/JX1, AF04/C5, gói G0C read-only để nghiên cứu và tái sử dụng sau; **không xóa/undo code đã làm chỉ vì đổi art direction**.
- `Source A` là nguồn mỹ thuật chính; `JX1` chỉ làm benchmark/mẫu chọn lọc, source ID phải phân biệt; `custom_v5` là nguồn hiệu ứng/skill tự xây.
- Phân tách **a) luật kỹ năng** (Combat V2) **b) hành vi auto AI** (policy/simulation) **c) visual skill cue** (presentation). Không gộp cả ba trong một script.
- Không sửa Combat V2/save/CI/FULL/merge khi mới ở G0 đọc-only. Không nhận bản demo chỉ có chữ báo PASS, yêu cầu ảnh/video, FPS và dấu vết event.

## 8. Quyết định owner cần cho bước tiếp theo

Đề xuất chốt **V5-G0 source-first visual audit** ngay, rồi owner chọn G1 sau khi có 1 visual sample thật. Câu hỏi lựa chọn: A — nhất quán chibi Source A + custom VFX (đề xuất); B — nhất quán JX1 cổ điển + JX skills/assets (không đề xuất); C — custom từ đầu 100% (đẹp độc lập nhưng công art cao nhất). Không yêu cầu chủ sở hữu chốt từng asset trong G0.
