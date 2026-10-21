# TÔNG MÔN BÁ ĐẠO — So sánh chuyên sâu Combat A (Source A) và B (JX1)

**Ngày:** 2026-10-21  
**Trạng thái:** PHÂN TÍCH / CHƯA CHỐT / KHÔNG CODE  
**Môi trường đích:** Godot 4.7.2, Android landscape 1280×720  
**Nguyên tắc gameplay:** Combat V2 (stat/damage/RNG/element, equipped skills, save) tiếp tục là authority; không coi chỉ thị đổi mỹ thuật là quyền sửa gameplay.

## 1. Kết luận có điều kiện

- **Sản phẩm dài hạn:** nghiêng về **A — hình ảnh Source A/chibi thống nhất tông môn; combat realtime auto-hunt tự thiết kế; skill/VFX do dự án làm**. Điều kiện cứng: chứng minh ít nhất 01 rig đệ tử + 01 rig quái có animation dùng được khi đánh và phương án trang bị/ngoại hình không phá đồng nhất giữa sect và hunt.
- **Pilot kỹ thuật nhanh theo bằng chứng sẵn có:** **B có sẵn hơn về quái hành động** (boss115 4 trạng thái SPR rời), nhưng chưa chắc nhanh hơn để có **trận đánh hoàn chỉnh** vì nam/nữ chơi được cần ghép lớp và map trong PAK chưa decode. **A nhanh hơn về xuất Godot-ready**, nhưng chưa chắc nhanh về animation tấn công. Không kết luận bên thắng trước cổng G0 nhỏ.
- **Không chọn hybrid kiểu nhét boss JX người thật vào đội Source A chibi ngay trong một cảnh.** Hybrid hợp lý là **hệ thống**: giữ core Combat V2 + tự làm AI/skill presentation + nguồn mỹ thuật thống nhất; dùng JX1 làm benchmark hoặc thư viện hiệu ứng chọn lọc đã chỉnh visual language.

## 2. Bằng chứng hiện có và điều không được suy diễn

### A — Source A / 最强祖师

- `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`: Spine 3.8.75, triplet skeleton/atlas/texture PNG. Pipeline đang có tại `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`; output `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472`; raw `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`. **Batch-01 10/10 rig kỹ thuật PASS, 31 clip, 1.016 frame, 28 trang atlas, ~35,6 MB bytes trên đĩa; không phải FPS/VRAM Android**.
- Ba actor MAP25 `1113028_1`, `body_1110201`, `body_1120402` hiện có trong game **chỉ xuất `stand`/`walk`**, không chứng minh skeleton gốc thiếu `attack`/`hit`/`die`. Cần đọc trực tiếp danh sách clip trong `.skel` gốc; thư viện candidate strings có `attack1...`, `hit`, `dead` nhưng **chưa là clip xác thực**.
- Rig `body_1120101_s` từng xuất đủ **13 clip**, nhưng chưa biết tên và chất lượng clip có phù hợp combat không — đọc manifest thật trước khi chọn.
- 32 PNG ENV-02A đã được kiểm nguồn; chủ yếu terrain/road/công trình/cây phục vụ **bản đồ tông môn**. Không được diễn giải là đã có **bản đồ săn quái Source A** hoàn chỉnh.
- Source A chibi cùng family với UI/map/đệ tử; đổi trang phục theo item **không tự có** chỉ vì Spine đã bake. Skin/attachment + slot layers phải kiểm chứng; bake nhiều skin có thể tốn atlas.

### B — Võ Lâm Truyền Kỳ 1/JX1

- `G0C_AUDIT_2026-10-21.zip`, báo cáo kiểm kê client: **21.511 files**, 17.544 `.spr` (~8,1 GB), 32 `.pak` (~7,65 GB), 1.406 SkillId numeric và 987 map ID. Đây là **file inventory** chứ không phải ảnh/animation/runtime đã được import.
- `catalog/boss115_sample.csv` có bốn SPR rời `boss115_st01`, `_wlk`, `_at01`, `_die`, header `SPR\0`, size và SHA-256. Đây là ứng viên kiểm chứng **animation quái** tốt.
- `settings/npcres` có bảng body/layer/weapon của nhân vật nữ, mã FM_BD, FM_RW và biến thể ST/WK/AT. Nhưng `item ID -> player appearance layer` chưa khóa; một phần body SPR có thể nằm trong `.pak`.
- `data/maps.pak` có PACK header nhưng chưa trích map/tile/object/collision để dựng địa hình Godot. Bảng maplist có ID không có nghĩa đã có bản đồ xem được.
- `settings/skills.txt`, `missles.txt` có bảng tham số; các PreCastSpr mẫu SkillId **1584, 1218, 1595** tồn tại rời với SPR header và SHA. Projectile/impact/missile-chain thật vẫn unresolved. Không chuyển số sát thương/cooldown JX1 vào Combat V2.
- Bản source client chính và patch V3.1 khác hash/row; nếu nối asset bản khác nhau, có thể tham chiếu thiếu hoặc sai. Khóa baseline đầu vào trước khi convert hàng loạt.
- Repo game hiện có `CombatV4SpriteAtlas` manifest chỉ `hero`/`wolf`, dù có 5 action + 8 hướng. `MapBattleWorldLayerV2` vẫn có fallback sàn/cây Source A, quái/Boss sói chung artwork; vài cue hiệu ứng JX1 được map. **Không thể xem renderer hiện tại là bản port JX1 visual**.

## 3. Ma trận đánh giá

| Hạng mục | A — Source A + custom VFX | B — JX1 classic source-first | Ảnh hưởng tới quyết định |
|---|---|---|---|
| Cohesion tông môn→hunting | Cao vì cùng chibi/color/material | Thấp hơn do tỷ lệ cơ thể, màu sắc và thế giới võ hiệp | A thắng lâu dài |
| Có animation tấn công **đã xác thực** | Chưa chứng minh cho 3 live rig; 13-clip rig cần kiểm | Boss115 có file attack rời, player attack phụ thuộc bảng+SPR | B nhỉnh ở quái, không đủ kết luận toàn pilot |
| Engine conversion | Spine 3.8→bake Godot 4.7.2 đã thử | SPR reader/PAK/hash tool có nhưng binary owner chưa QA đồng bộ | A giảm rủi ro importer |
| 8/16 hướng, vũ khí đổi hình | Hai hướng/mirror có thể đủ pilot; costume baking phức tạp | JX1 nguồn có 8/16 hướng và layer đổi đồ, nhưng ghép frame/sort/order khó | B có tiềm năng sâu, chi phí cao |
| Skill mới theo linh căn/kiếm/pháp/thể | Chủ động thiết kế, VFX không nhất thiết lệ thuộc clip body | Có kho VFX võ hiệp lớn nhưng mapping/motion logic chưa đủ | A thắng về chủ động bản sắc |
| Map liền mạch/chunk | Cần dựng vùng săn Source A riêng; MAP25 sect không tự là hunting | Map gốc nằm PAK; geometry/collision chưa giải | Cả hai có điểm nghẽn, khác cách giải |
| Android VRAM/draw | Baked RGBA/WebP cần texture budget; ít hướng thì tiết kiệm trang | Multi-direction và nhiều layer tạo nhiều draw/texture changes | Không chọn bên thắng FPS khi chưa benchmark |
| Thời gian ra demo đầy đủ | Nhanh nếu tìm đủ attack/hit/die; chậm nếu cần tạo animation | Nhanh để xem Boss+PreCast; chậm nếu cần player outfit + original map | Quyết theo Gate G0, không ước lượng ngày vô căn cứ |
| Độ phụ thuộc công cụ cũ | Converter Spine native trial riêng, xuất SpriteFrames ổn | PACK/Sprite decoding và bảng/chữ mã hóa/patch version phức tạp | A ít phụ thuộc hơn cho Godot hiện tại |
| Giá trị đầu tư 6–12 tháng | Asset unity family, bổ sung rig/skin và skill thiết kế riêng | Trữ lượng art rất lớn nhưng maintain adapter, visual style riêng | A phù hợp bản sắc sản phẩm |

## 4. Vì sao 'combat mượt' không giải quyết bằng thay asset

**Cần tách ba lớp:**

1. **Sim**: Combat V2 tick 0.25 giây (4 bước/s); bảo toàn deterministic damage/RNG. Nếu view vẽ thẳng vị trí tick, nhân vật sẽ giật. **Interpolate render** giữa snapshot mỗi frame 30/60fps; animation tự chạy đồng hồ visual nhưng không tự gây damage.
2. **Motion/impact**: action clips thực; hướng đánh và foot anchor ổn định; `cast_start`/`release`/`projectile`/`hit`/`die` nối đến sự kiện thật; VFX chỉ minh họa tác động đã được xác nhận. Telegraph dựa sự kiện; không tự tạo status.
3. **GPU/scene**: batch/caching, atlas shared, shader ít overdraw, định mức VFX, text culling, object/decal pooling, chunk/map streaming và viewport culling. 30 đệ tử + 40 quái là fixture stress; không chạy riêng một texture độc lập cho mỗi người nếu cùng loại.

A có nguy cơ **bake atlas quá lớn**, nhiều skin/rig/clip sẽ ăn VRAM. B có nguy cơ **rất nhiều layered sprites + 8/16 hướng**, y-sort và texture binding. Dung lượng compressed trên ổ không đồng nghĩa RAM/GPU. Phép đo thực tế: P50/P95 frame ms, draw calls, số texture resident/VRAM estimate, startup time, input pan latency, FPS Windows/Android. Mục tiêu thiết kế Android 30fps stable (P95 <=33.3ms), tốt hơn nếu 60fps (P95 <=16.7ms); chưa phải kết quả đạt.

## 5. Thử nghiệm A/B nhỏ trước khi quyết định — G0 chỉ kiểm, không code gameplay

**Cùng điều kiện**: một viewport 1280×720, cùng số actor, cùng 1 camera tự do, cùng event Combat V2; không dùng asset giả để điền phần thiếu.

**A — ART PILOT:** Chọn một rig đệ tử Source A có đủ `stand/walk/attack/hit/die` (đọc danh sách clip real), một quái có đủ 4+ trạng thái, thử clip 2 hướng/foot anchor; chứng minh màu/scale đọc ở kích thước thực. Nếu không có clip cần thiết: ghi blocker và ước lượng effort ART; có thể dùng tự làm VFX nhưng không coi VFX là animation cơ thể.

**B — ART PILOT:** Decode loose `boss115` 4 SPR, chọn một player record `男主角`/`女主角`, thử body+weapon actual frame/Dir/offset và validate 1 PreCastSpr. Map: muốn chứng minh full JX1 zone phải decode một entry thật từ maps.pak; nếu không, chỉ được gọi animation/VFX pilot, không phải complete combat map pilot.

**Các câu hỏi quyết định A/B:** (1) nhân vật đánh có tự nhiên và cùng thẩm mỹ sect không? (2) đổi trang phục/vũ khí có nhìn ra và giữ đúng animation? (3) có ít nhất 1 quái + 1 boss khác nhau? (4) cùng camera free pan, VFX không che? (5) FPS/frame time & memory thực trên thiết bị? Nếu A thiếu attack thật nhưng B có player+boss+map render tốt, cân nhắc B nguyên khối, không trộn hai phong cách trong cùng cảnh.

### Gate quyết định

- **Chọn A** khi đủ 1 playable + 1 monster action được xác minh, hoặc khi chi phí bổ sung animation có phạm vi nhỏ/kiểm soát được; độ đồng bộ toàn game là ưu tiên chủ lực.
- **Chọn B** khi mục tiêu cao nhất là trung thành JX1 classic, và một bộ player+weapon+monster+map đã decode/QA chạy thực tế tốt hơn A. Đổi hướng art tông môn/combat cần chủ ý từ owner.
- **Nếu cả hai đều thiếu**, giữ renderer V2 và làm một combat custom prototype tối giản trong Godot, có nhãn custom, không tuyên bố Source A/JX1 gốc; chốt art sau khi có preview thật.

## 6. Khuyến nghị thực hiện không code

Không giao cùng lúc nhiệm vụ “port 17k SPR, 987 maps” và “bake hàng chục nghìn Spine”; không cần. Giao Codex **hai sample gọn, read-only** trên máy Windows; trả kết quả gồm manifest SHA, contact sheet/đoạn video animation loop thật, một ảnh side-by-side 1280×720, lý do thiếu animation/source và đo FPS nếu chạy một scene benchmark đã có. Không đụng `MapBattleV2`, CombatStats, save, skill balance, CI/FULL/merge.

**Thứ tự hợp lý:** trước tiên kiểm đủ clip Source A vì converter đã có; song song chỉ đọc/giải mẫu boss115 + nam/nữ JX1 từ bộ client. Không làm lại asset forge, không chỉnh E:\Source/E:\Tool JX, không upload binary vào repo trước khi chọn. Sau so sánh cùng thước đo, owner quyết định A/B cuối cùng. Quyết định này hiện **CHƯA CHỐT**.

## 7. Prompt Codex G0 — copy-ready (chưa cấp quyền gameplay code)

TÔNG MÔN BÁ ĐẠO — Chỉ thực hiện G0 kiểm chứng hai phương án hình ảnh combat, CHƯA chốt A/B và CHƯA sửa gameplay. Đọc `AGENTS.md`, `P3_ART_BIBLE.md`, `P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`, GitHub branch hiện hành; dùng Source A ở `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract` và công cụ Spine có sẵn; JX1 ở `E:\Source` và `E:\Tool JX`, báo cáo `G0C_AUDIT_2026-10-21.zip`. Đối chứng thực tế: (A) một đệ tử + một quái Source A đủ clip đứng/đi/đánh/trúng/chết; (B) boss115 bốn SPR thật + một player body/weapon đa hướng và một pre-cast thật; thử map JX1 chỉ nếu parser đã đủ dữ liệu, không tạo map giả. Xuất SHA/manifest, ảnh contact sheet và ảnh/video 1280×720 nếu có runner; đối chiếu độ đẹp, anchor, số hướng, ghép trang phục, asset readiness và frame time. Đánh dấu PENDING chính xác nếu thiếu binary/runner. Không quét lại toàn kho, không viết converter mới nếu đã có, không sửa Combat V2/RNG/save/balance, không CI/FULL/merge, không mở rộng quá hai mẫu. Trả bảng đề xuất A/B có điều kiện và 1 pilot art tối thiểu.
