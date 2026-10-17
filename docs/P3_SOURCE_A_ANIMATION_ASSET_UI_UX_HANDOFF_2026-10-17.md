# Tông Môn Bá Đạo — Source A animation & asset handoff cho UI/UX

**Cập nhật:** 2026-10-17  
**Trạng thái:** TÀI LIỆU BÀN GIAO / inventory thực chứng; **không phải phê duyệt production art hay gameplay**  
**Mục đích:** Để người làm UI/UX/Map/Combat có thể dùng ngay các asset đã chuyển, không nghiên cứu lại pipeline, không tái tạo asset hoặc làm thêm công cụ vô ích.

## 1. Đọc nhanh trước khi làm UI/UX

1. **Game chính:** `vuanhtuan161094-byte/TongMonBaDao`, Godot **4.7.2**, Android **landscape 1280×720**. Gameplay authority luôn thuộc simulation/code V2, không nằm trong asset/UI.
2. **Art/UX authority:** [P3_PRESENTATION_MASTER.md](P3_PRESENTATION_MASTER.md) → [P3_ART_BIBLE.md](P3_ART_BIBLE.md) → spec đúng hạng mục; file này là **inventory kỹ thuật đã có**, không thay/ghi đè chuẩn visual hay modular-actor contract.
3. **Nguồn nhân vật/animation A:** Spine **3.8.75**, triplet `.skel + .atlas + texture PNG`, dữ liệu gốc nhiều clip trong một rig. Game nguồn dùng Spine skeletal runtime; không lưu một ảnh toàn thân cho mỗi khung hình.
4. **Công cụ đã có trên Windows:** Spine 3.8 (Godot 4.5 custom native renderer) → bake → lossless WebP atlas + `SpriteFrames`/`AnimatedSprite2D` để **Godot 4.7.2 chính thức** phát. **Không cần xây lại tool.** Native Spine 3.8 trực tiếp trên Godot 4.7.2 **chưa xác minh**.
5. **Batch-01:** 10/10 rig **trong danh sách cuối đã hiệu chỉnh** đạt PASS kỹ thuật; asset vẫn nằm ngoài GitHub ở ổ E; chưa chứng minh artwork đẹp trong cảnh game thật hay tối ưu Android.
6. **Map25:** mã 2.5D đã gắn vào scene chính trong draft PR [#18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/18). 32 PNG Source A terrain/building/road/vegetation đã được phục hồi và xác minh SHA theo báo cáo, **nhưng binary import vào GitHub/real Windows map render còn PENDING**.
7. **Nguyên tắc triển khai:** chọn một asset cần cho cảnh thật → đưa vào scene game → kiểm tra 1280×720/foot anchor/z-order/touch → user duyệt → mới mở rộng. **Không chuyển cả kho trước.**

## 2. Nơi tìm công cụ, source và output (máy Windows)

| Vai trò | Đường dẫn |
|---|---|
| Workspace | `E:\TongMonBaDaoWorkspace` |
| Mở công cụ một lần nhấp | `E:\TongMonBaDaoWorkspace\MO_CONG_CU_SPINE.cmd` |
| Converter + Python portable | `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472` |
| Source A đã trích xuất | `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract` |
| Asset Godot xuất xong | `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472\<asset_id>` |
| Batch QA + log / manifest | `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472\QA_RESULTS` |
| Batch-01 report | `...\QA_RESULTS\Batch01\BATCH01_REPORT.md` |
| Godot chính thức | `E:\Godot_v4.7.2-stable_win64_console.exe` |
| Native Spine 3.8 trial | Truy tìm tại `E:\TongMonIntegrationLab\SpineNativeTrial` hoặc đường dẫn thực đã cập nhật; **không giả định lab đã được chuyển** |

Launcher có giao diện Việt, tự nhận skeleton/atlas/PNG, tự đọc clip; chọn sẵn `stand/walk`, cho phép chọn riêng/tất cả; mặc định không tạo ZIP. Có batch tuần tự, hiển thị tiến độ, hủy an toàn sau rig đang chạy, skip theo source/config fingerprint và hash output. Không phụ thuộc Python cài trong PATH. Nếu mất runtime/đường dẫn, sửa cấu hình công cụ hiện có, không tạo bản tool thứ hai.

### Gói đầu ra dùng cho game

```text
<asset_id>/
├── actor.tscn          # Scene AnimatedSprite2D
├── animations.tres     # SpriteFrames
├── atlas_00.webp       # Có thể có atlas_01, atlas_02...
└── asset.json          # ID, hash nguồn, clip/duration/FPS/anchor/config
```

WebP **lossless** có alpha, trang atlas tối đa **2048×2048** trong batch mẫu; QA/cache/ảnh trung gian **không nằm trong gói asset**. Output đã được kiểm tra sau khi chép vào `res://assets/actors/<asset_id>/` ở Godot 4.7.2. **Trước khi đưa vào repo, vẫn phải kiểm đúng asset được chọn và đường dẫn resource thực tế.**

### Cách sử dụng trong một scene Godot

- Sao chép **toàn bộ thư mục asset đã được chọn** vào `godot/assets/actors/<asset_id>/` (hoặc nơi tương ứng với `res://assets/actors/<asset_id>/`), không chép PNG rời.
- Instantiate `actor.tscn` hoặc dùng `animations.tres` với `AnimatedSprite2D`; kiểm tên clip từ `asset.json` / `SpriteFrames`. Ví dụ: `$Actor.play("stand")` / `$Actor.play("walk")`.
- Cùng mẫu nhân vật: **chia sẻ** `SpriteFrames` và texture giữa nhiều instance; không tạo bản sao atlas cho từng đệ tử. Đổi hướng trái/phải bằng `flip_h` **nếu rig/skin mirror-safe**; không giả định mọi vũ khí/đồ bất đối xứng có thể mirror.
- **Foot anchor, scale, Y-sort và collision/touch** phải nghiệm thu trong map 1280×720, không lấy trung tâm hình làm điểm đứng trên đất. Nguồn Spine bake **khác** `female_normal_v1` modular canvas `128×128`, anchor `(64,104)`; **không ép đổi spec rig modular** khi chưa có quyền sửa riêng.
- State/command `stand/walk/work/combat` lấy từ presentation của state/event thật; **không để animation tự ra quyết định work, timer, EXP, damage, save**.

## 3. Batch-01 đã kiểm chứng — 2026-10-17

**Báo cáo owner cung cấp:** `04_Tools\SpineToGodot472\QA_RESULTS\Batch01\BATCH01_REPORT.md`.

| Rig ID | Clip đạt | Mục đích sử dụng thử |
|---|---:|---|
| `1113028_1` | 2 | **Nhân vật nữ**; `stand/walk`, ứng viên MAP25 visual pilot |
| `113100_5_s` | 2 | Linh thú / hồi quy pipeline |
| `body_1120101_s` | 13 | Test **toàn bộ clip runtime xác nhận** |
| `body_1120402` | 2 | Nhân vật |
| `body_1110201` | 2 | Nhân vật |
| `1113005_1` | 2 | NPC (thay rig lỗi) |
| `1113031_1` | 2 | Quái (thay rig bị cắt mép) |
| `410041_1` | 2 | Quái |
| `510011` | 2 | Công trình (cần canvas 1024 trong quá trình bake) |
| `113104_5` | 2 | Nhân vật |

**Số đo Batch-01 (máy Windows do owner báo cáo):**

- **10/10 PASS** *sau khi thay hai rig lỗi*; 31 clip, **1.016 frame**, 28 WebP atlas, **35.601.103 bytes** thành phẩm.
- **93 frame mẫu** (đầu/giữa/cuối mỗi clip) khớp pixel **RGBA** với Spine 3.8 runtime capture; Godot 4.7.2 import/resource/playback PASS trên cả 10 bộ.
- Chuyển đổi 10 bộ **558,5 giây** (~55,85 giây/bộ). Chạy lại cùng source/config **5,4 giây**, 10/10 `SKIPPED_VERIFIED`.
- CPU working-set sampled peak **1.105.428.480 bytes** (~1,11 GB); đây **không phải VRAM**, cũng không phải mẫu đo đỉnh tuyệt đối. Android GPU/FPS **chưa đo**.
- `1113001`: `walk` trong suốt với skin mặc định; `Body_430056`: chạm mép đến canvas 2048; **không có asset lỗi được xuất**. PASS 10/10 **không được hiểu** là 12/12 hoặc mọi rig đều tương thích.
- Một số `QA_RESULTS/work_*` bị khóa quyền Windows; đó là **cache QA**, không phải asset game; chỉ dọn khi chắc chắn an toàn.

**Giới hạn chứng cứ:** 93 sample frame khớp pixel **không** chứng minh 1.016/1.016 frame đều khớp, không thay thế xem chuyển động liên tục bằng mắt; `loop` trong gói theo chính sách tên clip của converter; chưa chứng minh logic loop/event gốc cho mọi rig. Sản phẩm **TECHNICAL PASS / UI VISUAL ACCEPTANCE PENDING**.

## 4. Những kỹ thuật đã học, để tránh làm lại

### Source A (game tham khảo 最强祖师)

- Unity asset cấu trúc `Spine.Unity.SkeletonDataAsset`, `SpineAtlasAsset`, `spine-unity.dll`; skeleton timeline + vùng ảnh trong atlas gốc. Ví dụ file `1113028_1` thuộc `body_female`, Spine **3.8.75**; clip `stand/walk` đã bake thành công.
- Runtime Spine tiết kiệm việc lưu toàn ảnh theo từng frame; **không đồng nghĩa đã có Spine runtime tương thích Godot 4.7.2**.
- Mã, mapping, atlas evidence: [ZQZS-Source-Knowledge](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge); [spine_sample.json](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/DeepAnalysis/data/spine_sample.json); [animation asset opportunities](https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge/blob/main/analysis/DarkEdition/ANIMATION_ASSET_OPPORTUNITIES.md).

### Game riêng của owner — Tu Tiên Nhàn Dỗi

Repository: [tutiennhandoi](https://github.com/vuanhtuan161094-byte/tutiennhandoi). **Không phải Source A hay code authority của Tông Môn Bá Đạo.**

- [video_to_godot_animation.py](https://github.com/vuanhtuan161094-byte/tutiennhandoi/blob/main/tools/video_to_godot_animation.py): video/frame → chroma/alpha → **union crop** → stable canvas → dedupe **giữ duration** → WebP lossless atlas → `SpriteFrames.tres`.
- [sprite-sheet.mjs](https://github.com/vuanhtuan161094-byte/tutiennhandoi/blob/main/assets/_pipeline/tools/sprite-sheet.mjs): pack atlas, padding/extrusion, trim tùy chọn.
- [standing_hero.gd](https://github.com/vuanhtuan161094-byte/tutiennhandoi/blob/main/godot/scripts/character/standing_hero.gd), [meditation_hero.gd](https://github.com/vuanhtuan161094-byte/tutiennhandoi/blob/main/godot/scripts/home/meditation_hero.gd): still fallback, **lazy load, bounded cache, release animation** khi không dùng.
- **Không copy cứng 8 FPS hoặc khung hình nhân vật lớn** từ game này sang bản đồ nhỏ 1280×720; Batch-01 dùng **30 FPS**; chỉnh theo nghiệm thu chuyển động và hiệu năng. WebP giảm dung lượng trên đĩa nhưng **không mặc định giảm VRAM khi decode**.

## 5. Context UI/UX đang có trong draft PR #18 (không báo PASS runtime)

- Scene game thật: `res://scenes/p3/p3_2_landscape_sect.tscn`; code chính `godot/src/presentation/p3_2_landscape_sect.gd`. Map25 view-only Node2D/Camera2D/SubViewport trong scene chính; thế giới 192×192, starter 48×48, chunk 16×16, isometric projection. **Không dựng lab hoặc bản đồ thứ hai**.
- Actor layer/HUD và right-panel hiện có nằm ngoài world SubViewport; khi gắn `actor.tscn`, phải bảo đảm **cùng hệ tọa độ screen/world** và lớp render, không để chân sai vị trí hoặc NPC nổi trên mái nhà vô lý.
- 32 ảnh gốc của **ENV-02A** đã được khôi phục và đối chiếu SHA (3 công trình `510052` Đại Điện, `510102` Kho, `520081` Lò Rèn; 4 terrain, 6 roads, 19 vegetation). **Import ảnh thật vào GitHub/runtime chưa xác nhận**. Xem [MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md](MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md) và [MAP25_MAIN_ENV02A_INTEGRATION_2026-10-16.md](MAP25_MAIN_ENV02A_INTEGRATION_2026-10-16.md).
- GUI Workforce V1 đã có luồng chọn công trình Mỏ/Linh Lâm/Linh Điền → panel phải → chọn/đổi đệ tử → giao việc, dùng **BuildingState ID thật** và **One Active Job**. Test runtime của integration branch còn PENDING; xem [GUI_WORKFORCE_V1_INTEGRATION_ACCEPTANCE_2026-10-16.md](GUI_WORKFORCE_V1_INTEGRATION_ACCEPTANCE_2026-10-16.md).
- Không coi art landmarks là công trình `BuildingState` được xây/trả phí; LAY-V2 persistent land/roads/build costs **chưa mở**. Không tạo job/loot/số sản lượng giả để trình diễn UI.

## 6. Việc tiếp theo — theo đúng giá trị sử dụng

1. **MAP25 binary**: kiểm tra/import 32 PNG xác minh theo công cụ có sẵn; nếu bị chặn, ghi BLOCKED, **không vẽ Source A giả**.
2. **Một visual pilot thật trên scene chính:** sử dụng asset `1113028_1` từ ổ E trong bản QA/copy đã kiểm; quan sát `stand → walk → dừng`, mirror trái/phải nếu hợp lệ, foot anchor, tỷ lệ map, z-order với Đại Điện và tương tác đúng nhân vật.
3. **Nghiệm thu bằng ảnh/video Godot 4.7.2 1280×720**; test zoom `0.75×/1.00×/1.35×`, đường đi và touch/panel; Android perf tiếp tục PENDING nếu chưa có runner/device.
4. **Chỉ sau visual approval** mới đưa **những asset cần dùng** vào game repository, kiểm tra đường dẫn portable, QA/Godot regression và cập nhật asset registry/source status. Không push toàn bộ kho, không chuyển batch lớn không có nhu cầu cụ thể.
5. Nhóm tiếp sau: thêm NPC/quái/Boss/skill **theo nhu cầu của màn chơi**. Không thêm GUI cho converter, không viết lại parser/Spine plugin nếu không có lỗi thực tế.

## 7. Điều không được suy diễn

- Asset xuất tại `E:\...\Assets_Godot472` **không tự tồn tại** trên GitHub hoặc điện thoại; GitHub text/metadata không thay thế binary art. Không tự push file art khi chưa xác minh quyền/đường vận chuyển và chưa có nghiệm thu phù hợp.
- Source A được owner cho phép dùng trong dự án cá nhân; **không suy diễn quyền phát hành thương mại hoặc công khai tái phân phối file gốc**.
- Một rig cùng clip có thể dùng cho nhiều **instance**; không phải mỗi đệ tử một bản atlas. Nhưng **rig Spine đã bake** không tự trở thành nhân vật đổi tóc/trang phục modular; hai pipeline độc lập trừ khi có phương án kỹ thuật và quyền thiết kế mới.
- Đừng gọi PR #18, Android, import MAP25 art, visual quality hoặc batch toàn kho **PASS** từ các test từng rig.
- Nếu dữ liệu mới khác tài liệu ngày 2026-10-17, cập nhật phần status/evidence này với SHA và đường dẫn nguồn; **không sửa gameplay canon, không xóa lịch sử QA lỗi**.

## 8. Liên kết chuẩn khi chat UI/UX mới bắt đầu

- [P3_PRESENTATION_MASTER.md](P3_PRESENTATION_MASTER.md) — authority router.
- [P3_ART_BIBLE.md](P3_ART_BIBLE.md) — scale, style, readability; actor mục tiêu khoảng 60–75 px tại zoom 1.00.
- [P3_2_MODULAR_ACTOR_SPEC.md](P3_2_MODULAR_ACTOR_SPEC.md), [P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md](P3_2_FEMALE_NORMAL_V1_ASSET_PRODUCTION.md) — các quy tắc rig modular **riêng**.
- [P3_UX_MAIN_MAP.md](P3_UX_MAIN_MAP.md), [GUI_WORKFORCE_V1_INTEGRATION_ACCEPTANCE_2026-10-16.md](GUI_WORKFORCE_V1_INTEGRATION_ACCEPTANCE_2026-10-16.md) — interaction/state UI.
- [MAP25_MAIN_ENV02A_INTEGRATION_2026-10-16.md](MAP25_MAIN_ENV02A_INTEGRATION_2026-10-16.md) — bản đồ thật trong PR #18.
- [MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md](MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md) — chứng cứ/binary gate 32 ảnh.
- [PR #18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/18), `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` — đọc HEAD/status mới trước khi sửa code.

**Tóm lại:** Tool/BATCH-01 đã tạo được asset. Nút thắt không còn ở số lượng animation được xuất mà là **chọn asset đúng, đưa vào scene thật, duyệt hình và dùng được trong UI/UX mà không phá gameplay**.
