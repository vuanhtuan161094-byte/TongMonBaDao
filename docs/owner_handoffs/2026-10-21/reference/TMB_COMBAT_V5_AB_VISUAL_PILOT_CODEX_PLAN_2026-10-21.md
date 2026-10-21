# TÔNG MÔN BÁ ĐẠO — COMBAT V5: KẾ HOẠCH A/B VISUAL PILOT (SOURCE A CHIBI vs PIXEL-ART)

**Ngày lập:** 2026-10-21  
**Trạng thái:** `DESIGN / PLAN ONLY — CHƯA CHỐT ART STYLE — KHÔNG CODE`  
**Đầu mối thực hiện sau khi được giao:** Codex trên Windows có quyền truy cập asset ổ E:  
**Game:** Godot 4.7.2, Android landscape 1280×720; repository `vuanhtuan161094-byte/TongMonBaDao`.

> **Mục tiêu quyết định:** So sánh hai hình thức trình diễn cho **cùng một trận chiến thực** với cùng diễn biến, đội hình, kỹ năng và camera. Không so sánh ảnh đẹp rời rạc; phải đánh giá hiệu quả trong gameplay và khả năng mở rộng tới nhiều đệ tử.
>
> **Không đổi:** Combat V2 (sát thương, phòng thủ, RNG, tick, mục tiêu, skill, cooldown, trạng thái), save/offline, economy, 30 Tu Vi × 10 tầng, 30 Luyện Thể × 10 tầng, One Active Job. Không tự tăng skill, cấp đồ hay đổi balance để bản mẫu hấp dẫn hơn.

---

## 1. Phạm vi / phân biệt hai giai đoạn

### G0 — CHỈ THIẾT KẾ (phạm vi được phép **ngay bây giờ**)

- Đọc nguồn thẩm quyền, kiểm toán metadata có sẵn, chọn asset cụ thể và xác định blocker.
- Soạn art direction A/B, character/monster/Boss style sheets, storyboard cùng một trận, wireframe HUD/map, VFX timing chart, đề xuất quy tắc trang phục và phương pháp benchmark.
- Tạo **concept tĩnh**, mockup, bảng đối chiếu, contact sheet từ asset có nguồn rõ ràng nếu có thể làm qua công cụ đồ họa *mà không thay repository*. Dùng placeholder có nhãn `CONCEPT_ONLY` khi chưa có asset thật.
- Xuất một packet bàn giao có đường dẫn, checklist, file manifest nguồn, rủi ro, phạm vi G1 và tiêu chí ra quyết định.
- **Không viết/chỉnh code** Godot, Python, shader, plugin, test hoặc launcher; **không push commit/PR**, không CI/FULL/merge, không chạy gameplay/runtime Godot. Nếu có nhu cầu làm code, dừng ở đề xuất packet G1 cần chủ dự án giao riêng.

### G1 — VISUAL PILOT TƯƠNG LAI (chỉ thực hiện sau khi chủ dự án cho phép)

- Dựng hai bản view/render A và B cùng dùng **một nguồn Combat V2 event/snapshot**; triển khai ở nhánh tách biệt, không sửa simulation, skill gameplay hay save.
- Thu capture/video 1280×720, cùng góc, cùng nhân vật/monster, cùng timeline, cùng các sự kiện cast/impact, có overlay FPS và thông tin khung hình.
- Chạy focused tests Godot 4.7.2 và benchmark trên Windows, sau đó Android nếu có thiết bị/runner.
- G1 **không thuộc quyền thực thi của G0**. Không gọi prototype là đã chạy thật khi mới có storyboard/concept.

---

## 2. Nguồn bắt buộc Codex kiểm tra (không dùng suy đoán thay chứng cứ)

### 2.1. Repo Tông Môn Bá Đạo

- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` — đọc HEAD mới nhất trước khi làm.
- `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ART_BIBLE.md` — chuẩn visual, mobile readability, camera/scale và giới hạn VFX.
- `docs/P3_2_MODULAR_ACTOR_SPEC.md` — 2 rig cơ bản, public 4 hướng, 9 bones, 11 render layers, appearance_profile/weapon socket.
- `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md` — pipeline Spine 3.8.75 → atlas/WebP/SpriteFrames Godot 4.7.2 và Batch-01.
- `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`.
- `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md` — các luật mới còn ở mức DESIGN, **không tự bật lên trong pilot**.
- `godot/src/simulation/combat/map_battle_v2.gd`, `jx_pilot_skills_v1.gd`, `jx_pilot_runtime_v1.gd` và các focused tests liên quan.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd`, `combat_v4_sprite_atlas.gd`, `combat_v4_effect_atlas.gd`, các `combat_v4_*pilot.gd`, `sect_map_camera.gd`.
- `godot/data/presentation/c4_jx1_pres00_five_skill_asset_manifest.json`, `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json`.
- `godot/data/presentation/map25_source_a_verified.json`, `godot/assets/actors/` nếu thư mục thực sự tồn tại trên HEAD được xét.

**Lưu ý branch:** bản kế hoạch viết khi đã khảo sát nhánh công cụ `tools/af-jx1-player-forge-20261020` tại `4dcb2daf...` và nhánh chơi thử `work/playfirst-demo-max-v3-20261020` tại `aad7cec...` (thông tin tham khảo ngày 21/10, **không được coi là HEAD mãi mãi**). Codex phải ghi lại SHA thực tế và tránh coi một nhánh thử nghiệm là bản `main` đã merge.

### 2.2. Source A trên máy Windows

- Input theo tài liệu cũ: `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`.
- Spine converter: `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`.
- Batch thành phẩm: `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472`.
- Batch QA manifest/log: `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472\QA_RESULTS\Batch01`.
- Rig ứng viên: nữ `1113028_1`, nam `body_1110201`, `body_1120402`; quái ứng viên `1113031_1`, `410041_1` (phải kiểm bằng ảnh, không tự mặc định cùng loài/Boss).
- **Dữ kiện đã biết:** 10 rig trong Batch-01 đã qua kiểm thử chuyển đổi; các rig đệ tử dùng trong MAP25 đã được export `stand/walk`, **chưa có bằng chứng các clip attack/hit/dead đã được xuất đúng**. Không diễn giải tên `attack*` trong CSV như chứng cứ clip runtime.
- Nếu path trên máy đã thay đổi, **tự dò bằng manifest/log hiện có**; không yêu cầu tải/chuyển toàn bộ Source A lại.

### 2.3. JX1 (chỉ bảo toàn skill/VFX đã có, **không** chuyển art style B thành JX1)

- Client/source: `E:\Source`, `E:\Tool JX`.
- Asset Forge: `tools/asset_forge/` trên nhánh công cụ; source reports G0C khi có.
- Năm pilot **đã code có giới hạn**: `jx_shaolin_15` (Bất Động Minh Vương), `jx_wudang_158` (Kiếm Phi Kinh Thiên), `jx_wudang_159` (Thất Tinh Trận), `jx_wudu_63` (Độc Sa Chưởng), `jx_emei_93` (Từ Hàng Phổ Độ).
- Có VFX đã nhập cho một phần; có skill chỉ có metadata hoặc chưa gắn cast/projectile/impact. **Không tự coi tất cả năm kỹ năng đã có đầy đủ hình ảnh**, không tự quy đổi skill ID với các ID nguồn khác.
- Sử dụng chúng như *dữ liệu event và khả năng tái sử dụng FX*. Có thể làm VFX pixel/chibi mới **chỉ ở tầng presentation**; không thay payload gameplay, source_id hay learned/equipped loadout.

---

## 3. Điều kiện A/B công bằng — khóa cùng một kịch bản

### 3.1. Roster / encounters

- **6 đệ tử**: 2 Kiếm Tu (1 Ngự Kiếm, 1 Hộ/Sát kiếm minh họa), 2 Thể Tu (1 phòng ngự, 1 công kích), 2 Pháp Tu (1 Ngũ Hành, 1 Y Đạo). Những nhánh nêu ở đây là **nhãn vai trò trình diễn** theo V2, không tự cấp skill hoặc stat mới.
- **Một loài quái thường** nhân nhiều instance (đề xuất 4 con cùng loài trong trận) + **1 Boss**: tức cảnh pilot đề xuất 6 vs 4+1; có thêm trang 6 vs 1+1 để đánh giá silhouette khi ít đông.
- Dùng **chính ID actor, vị trí, kích thước hitbox, HP và chuỗi sự kiện** cho cả A/B. Không tăng số người hay giảm HP để tạo cảm giác bên nào hấp dẫn hơn.
- Map: cùng kích thước logic, walkable/blocked geometry, vị trí cây/đá/vật che, camera transform và phạm vi nhìn. A vẽ map chibi bán hiện thực; B vẽ map pixel-isometric **tác phẩm mới**, không chỉ áp filter lên A.
- Các tình huống dùng chung: tiếp cận → dùng skill → trúng đòn → hồi máu/buff → đánh Boss → Boss bị hạ; AoE cảnh báo nếu có event thật.

### 3.2. Skill/event tối thiểu **dùng những gì đã có**, không sáng tác gameplay

| Pilot ID | Vai trò quan sát | Event/VFX đề xuất | Điều kiện trung thực |
|---|---|---|---|
| `jx_wudang_158` | Kiếm Tu/ngự kiếm visual reference | Wind-up → flying sword/projectile → impact | Chỉ hiện damage khi authoritative impact event thực xảy ra |
| `jx_shaolin_15` | Thể Tu/phòng ngự visual reference | Tụ khí/guard shell ngắn | Chỉ hiện guard nếu pilot thật kích hoạt |
| `jx_wudu_63` | Poison/Ngũ Hành visual reference, class mapping **chưa khóa** | Cast → impact → poison debuff tick | Không mặc định dạy skill cho Pháp Tu hoặc Thể Tu |
| `jx_emei_93` | Y Đạo/hỗ trợ visual reference | Cast → HoT từng nhịp | Healing lấy từ event V2, không cộng HP theo frame |
| `jx_wudang_159` | Trận pháp đội ngũ (tùy chọn) | Vòng trận phòng ngự / buff | Chỉ bật nếu packet pilot thực có valid cast/event |

Nếu fixture chuẩn không có learned/equipped skill thì bản visual **được phép thiết kế storyboard mô phỏng ý tưởng** nhưng phải gắn `CONCEPT_ONLY`; bản runtime G1 **chỉ dùng một test actor fixture có opt-in legal pilot loadout**, không đụng production disciples/save.

### 3.3. Capture và kiểm tra đồng nhất

- Ba mức camera: tổng quan toàn đội, cận cảnh 1 kỹ năng, Boss giữa đám đông. Cùng world-to-screen conversion; xem ở 1280×720, zoom 1× và zoom xa 0,75×.
- Khung storyboard cần giống nhau về timestamp giả định và diễn biến: `T0 setup`, `T1 tiếp cận`, `T2 cast`, `T3 impact`, `T4 heal/guard`, `T5 Boss phase/downed`; **không trình bày các mốc này như thời gian Combat V2 đã đo**.
- Trong G1 tương lai, dùng **recorded canonical snapshot/event stream** và replay giống hệt 2 skin; nếu không thể replay cùng tick/seed, bài so sánh cảm giác phải ghi rõ không đồng nhất và không được chấm performance một cách khẳng định.

---

## 4. Phương án A — Source A chibi

### 4.1. Art direction

- Chibi tu tiên trưởng thành, silhouette đọc rõ ở cỡ gameplay, đầu lớn vừa phải, tay/vũ khí không quá mảnh.
- Cùng palette với Đại Điện, Linh Lâm, Linh Điền; thiên về ngọc/bạc/gỗ/đất, VFX có điểm nhấn nhưng không che actor.
- Foot anchor bất biến qua idle/run/attack/hit/down, nhân vật đứng đúng mặt đất isometric, Y-sort theo chân.
- Một đội phải phân biệt Kiếm / Thể / Pháp qua **vũ khí + dáng đứng + bóng VFX**, không tô 6 aura rực liên tục.
- Quái thường có 3–4 tín hiệu silhouette chính; Boss lớn hơn nhưng không che hết đội hình, HP/nameplates có tầng ưu tiên.

### 4.2. Animation

- Mục tiêu danh sách clip: `idle`, `walk/run`, `attack`, `hit`, `down/die`, `cast` (nếu có) + chuyển hướng; clip chỉ được coi là `VERIFIED` khi truy được từ nguồn và xem được frame thật.
- Nên thẩm định **1 đệ tử nam + 1 đệ tử nữ + 1 quái** trước; chỉ sau mới cho đội 6 dùng pool appearance.
- Nếu chỉ có `stand/walk`: dùng làm proof chuyển động, ghi `ART_BLOCKED_ATTACK`, **không đảo ngược clip đi bộ thành đánh** hay dùng particle để che mất động tác.
- Dùng converter Spine đã tồn tại; không viết lại parser/renderer khi chưa có bằng chứng lỗi công cụ.

### 4.3. Trang phục

- Hai tầng: (a) pre-baked actors cho quái/Boss và các NPC đặc biệt; (b) **shared rig + modular cosmetics** cho đệ tử có nhiều trang bị.
- Bảo toàn hướng P3.2: 9 bones, 11 layers, cùng foot/socket. Tóc/mặt/áo/vũ khí đổi lớp; tint dùng mask, không nhuộm toàn body.
- Skin/attachment Spine gốc chỉ tái sử dụng khi có mã/file chứng minh hoạt động với rig đó; **không giả định skeleton nào cũng ghép tùy ý**.
- Trong G0 trình bày **6 tổ hợp appearance trên cùng rig** bằng sơ đồ và input asset đã tìm; nếu chưa có chứng cứ, đánh dấu `NEEDS_ASSET_OR_RIG_WORK`.

---

## 5. Phương án B — Pixel-art gốc, chất lượng tham chiếu King God Castle

**Phạm vi tham chiếu:** King God Castle là chuẩn *mức độ dễ đọc nhân vật nhỏ, contrast, sắc độ, nhịp animation, hit feedback và sự rõ ràng của skill*. **Không sao chép sprite, hero, UI, logo, map, icon hay bảng màu/thiết kế nhân vật cụ thể của game đó.** Hình ảnh phải là pixel fantasy **tu tiên** của Tông Môn Bá Đạo.

### 5.1. Art bible pixel sơ bộ (dự thảo, để test)

- Camera isometric/2.5D giống A về geometry; tile/props pixel cùng góc nhìn, cỡ và ánh sáng, không pha texture mịn của Source A vào battle layer pixel.
- Đề xuất source character **24–32 px cao**, upscale bằng nearest 2× thành khoảng **48–64 px** ở 1280×720, kiểm tra silhouette chứ không khóa số pixel khi chưa có concept. Boss cần vượt trội kích thước nhưng không che gần hết battle.
- Hạn chế palette trên từng character, ánh sáng và độ tương phản ưu tiên phân biệt nghề/địch-ta; vật phẩm và trạng thái nhìn được ở zoom xa.
- Pixel grid nhất quán, outline 1–2 source pixel nếu có, hạn chế nhiều cỡ pixel hỗn hợp.
- UI giữ độ nét chữ ở màn hình 1280×720 (có thể dùng font UI không pixel), pixel-art chủ yếu áp vào world/actor/VFX; phải định nghĩa ranh giới rõ ràng.
- Không dùng `downscale → nearest upscale` Source A rồi tuyên bố đó là pixel art. Nếu dùng Source A làm pose reference, asset B phải được vẽ lại đúng pixel-grid và có source riêng.

### 5.2. Animation pixel

- Motion readability: 4–8 key pose/frame cho basic hit (mốc tham khảo, **không phải clip/FPS cố định**), phân tách anticipation / strike / contact / recovery.
- Source canvas, socket, foot-anchor và frame-duration per action phải đủ để blend chuyển trạng thái không giật chân.
- Định hướng public 4 hướng với mirror-safe trái/phải khi artwork cho phép; clip cần có face/hair/weapon front/back nhất quán qua animation, không quay kiếm sang tay sai.
- Khác biệt nghề: Kiếm Tu kéo vũ khí/kiếm khí rõ; Thể Tu có đòn nặng, hit-stop presentation hợp lý; Pháp Tu đứng xa, cast telegraph và projectile rõ.

### 5.3. Modular pixel equipment (tránh tổ hợp bùng nổ)

- Không bake theo tích số `body × hair × armor × weapon × hướng × frame` cho từng đệ tử.
- Thử shared base body action + accessory sprites và slot draw-order; các mảnh cần cùng registration/socket cho đúng mọi hướng/frame.
- Ưu tiên các nhóm **đầu/tóc, thân + áo, vũ khí, hiệu ứng sau/trước**; không cần biến 10 ô trang bị gameplay thành 10 lớp sprite nếu mắt không phân biệt được ở zoom 0,75×.
- Tối thiểu concept proof: 2 kiểu tóc × 2 áo × 2 vũ khí, **tái sử dụng animation**; ghi rõ nếu phải làm thêm frame vũ khí/áo để khớp hành động.
- Atlas theo family/animation/rig, skin/tint material dùng chung. Không tạo runtime texture riêng cho từng nhân vật.

---

## 6. Camera / battlefield / HUD chung cho hai mẫu

- Android **landscape 1280×720**; camera mặc định **free pan**; chỉ follow khi chủ động chọn một đệ tử; kéo/zoom thủ công hủy follow hợp lý.
- Giữ một world/camera logic; chiến trường là vùng map liên tục trong tương lai, không chấp nhận dùng một đấu trường giả 36×20 làm đích cuối. G0 chỉ *minh họa*, không đổi map authority.
- UI: góc trái trên **5 đội (mỗi đội 6)** với status gọn; chọn đội → focus; chọn đệ tử → panel chi tiết; Boss HP nổi bật; minimap nhỏ có thể ẩn.
- Tên/HP chỉ hiện cho Boss, actor đang chọn và mục tiêu quan trọng; đệ tử/quái thường ưu tiên thanh HP tối giản hoặc chỉ khi bị thương; nút tương tác đủ chạm.
- Không vẽ đầy đủ 30 tên + 40 HP bar + mọi damage number khi benchmark tải lớn. Camera overview cần ưu tiên nhóm được chọn và nguy hiểm thật.
- Damage/crit/heal/miss, vùng AoE, buff/debuff **chỉ hiện khi combat event thật đã được simulation phát**; không tạo feedback giả. Các stat Accuracy/Evasion chưa triển khai không được giả hiệu lực trong G1.

---

## 7. Chất lượng animation và VFX: yêu cầu chung

1. **Event-to-visual synchronization:** `cast_start`, `cast_commit`, `projectile_launch`, `impact`, `status_apply/tick`, `downed` cần có mapping theo ID/event tồn tại; missing stage = ghi `MISSING`, không tự dựng công thức trận đánh.
2. **Phân tầng:** telegraph nằm trên nền đất/dưới chân; projectile cùng world-depth; impact ngắn phía trước mục tiêu; HP/status vẽ sau, không để VFX che UI.
3. **Nhịp animation:** chạy/đứng/đánh/hit/down không giật teleport chân; không loop attack/hit/die như idle; chuyển facing không lật vũ khí sai tay.
4. **4 nhóm VFX dùng để so concept:** đường kiếm (Kiếm), giáp khí/đòn nặng (Thể), đạn/độc nguyên tố (Pháp), hồi phục/hỗ trợ (Y Đạo). Đây là **họ hình ảnh**, không thêm 4 skill gameplay.
5. **JX1 FX:** giữ nguyên file, SHA/provenance; nếu đưa vào A/B thì là asset tham chiếu hoặc reused clip có ghi nguồn, chỉ điều chỉnh presentation. Không coi sprite JX1 là pixel art B mới.
6. **Âm thanh:** bản G0 ghi bảng ý tưởng hit/cast/impact; G1 không cần tự làm audio engine riêng.

---

## 8. Hiệu năng Android & cách benchmark công bằng

### 8.1. Hai cấp kiểm tra

- **S1/visual:** 6 đệ tử + 4 quái cùng loài + 1 Boss; 4–5 FX đồng thời tối đa theo timeline thực, chọn 1 đội, camera/zoom và HP. Đây là **cảnh so sánh nghệ thuật**.
- **S2/stress:** 30 đệ tử + 40 quái trong cùng viewport hoặc vùng lân cận; culling, atlas cache, overdraw, effect budget, label density. Đây là **cảnh đo kỹ thuật**, không chứng minh AI combat thắng/thua đúng nếu không có simulation fixture.

### 8.2. Mục tiêu số (chưa đo; không gọi PASS khi chưa chạy)

| Metric | Mục tiêu khởi điểm | Cách xác nhận G1 |
|---|---:|---|
| Android baseline | 30 FPS | `p95 frame time <= 33.3 ms`, trên thiết bị Android mục tiêu thực |
| Máy mạnh hơn | 60 FPS | `p95 frame time <= 16.7 ms` khi profile hỗ trợ |
| Chuyển camera | Không giật bất thường | Video pan/zoom 1280×720 và quan sát frame spikes |
| VFX occlusion | Không che chân/HP/telegraph | Frame capture cùng mốc skill/Boss |
| Bộ nhớ texture | Không tăng theo số bản sao cùng rig | Profiler Godot/Android, texture counts/VRAM sau warm-up |
| Render cost | Chấp nhận ở S2 | So cùng máy, cùng renderer/backend và cùng capture settings |

**Cách làm:** đo riêng CPU frame, GPU time (nếu thiết bị hỗ trợ), draw calls, visible texture atlas, texture memory, số actor visible, số FX active, p50/p95/p99 frame time qua cửa sổ đo có đủ mẫu, log warming/preload; phân biệt Godot editor vs export. Cùng độ phân giải, renderer, game tick, AI fixture, vùng nhìn, device, thermal state. Không đo A trên desktop rồi B trên điện thoại.

**Chống kết luận sai:** B pixel không đương nhiên nhanh hơn A — nhiều layer/tint/draw call có thể tốn hơn pre-baked sprites. Source A lossless WebP nhỏ trên disk không đồng nghĩa VRAM nhỏ. Không khẳng định Android PASS từ Windows/Linus/synthetic tests.

---

## 9. Ma trận chấm điểm để chủ dự án quyết định

**Trọng số đề xuất** (tổng 100, có thể điều chỉnh trước G1):

| Nhóm tiêu chí | Trọng số | Kiểu bằng chứng |
|---|---:|---|
| Art consistency toàn game tông môn → săn quái | 25 | Cặp cảnh cạnh nhau + map/character/FX cùng family |
| Animation & skill feedback trong combat | 25 | Video cùng timeline; cast/projectile/impact và hit reactions |
| Mobile readability ở zoom xa & 6 vs 5 | 15 | Capture 1280×720, không cần soi phóng to |
| Appearance/equipment variety có thể sản xuất | 15 | 6 hoặc 8 biến thể cùng rig, không atlas per-combination |
| Hiệu năng Android/cảnh đông | 15 | Device profiler/p95, memory/overdraw/culling |
| Công sức/content pipeline thực tế | 5 | Số tài nguyên mới, thao tác tay/skill, hạng mục blocker |

Thang mỗi mục 0–5; tổng điểm = Σ(trọng số × điểm/5). **Điểm hiệu năng trong G0 là `NOT_MEASURED`, không chấm 5/5 theo phỏng đoán.** Nếu G1 thiếu Android thực, ghi `DEVICE_PENDING`; không tổng kết A/B thắng tuyệt đối chỉ vì thiếu mẫu đo.

### Các điều kiện loại (hard gate)

- Actor animation thiếu cử động đánh mà cố dùng idle làm attack rồi gọi `PASS`.
- Source A hoặc pixel B sử dụng ảnh sao chép nguyên mẫu reference mà không có nguồn/thiết kế gốc.
- Lệch asset quality giữa hai mẫu do bên A dùng source verified, bên B chỉ placeholder; phải phân biệt `CONCEPT_CMP` với `RUNTIME_CMP`.
- Trúng đòn/VFX/dodge không tương ứng sự kiện Combat V2 hoặc can thiệp sát thương/RNG/save.
- VFX quá dày không nhìn được actor/HUD ở cảnh S2.

---

## 10. Thứ tự giao Codex — G0 read-only (không code)

**Bước 1 — Kiểm tra đầu vào:** khóa SHA repo đọc-only; bảng asset A/B hiện có; kiểm thật metadata clip Source A, skill pilot/FX và map. Nếu chỉ truy cập manifest mà không có binary thì ghi `BINARY_PENDING`, tuyệt đối không ghi đã render.

**Bước 2 — Bảng phân loại art:** chuẩn hóa `asset_id / family / source_path / sha256 / directions / animations / attachment / confirmed / missing / allowed_use`. Dùng registry hiện có; chỉ đặt danh mục đầu ra nhỏ liên quan pilot.

**Bước 3 — Style sheets:** A và B có **cùng** 6 vai trò, 1 quái, 1 Boss, 4 họ VFX, 1 khu map và HUD. B là pixel art gốc có bản sắc tu tiên, không sao chép King God Castle; A là Source A đủ provenance.

**Bước 4 — Storyboard đối chiếu:** mỗi cặp 6 khung (tương ứng mục 3.3). Diễn giải camera/perspective/timeline, layering actor/boss/FX, vùng tương tác, trạng thái HP. Tạo contact sheets nếu công cụ thiết kế sẵn có cho phép, nhưng đừng giả là screenshot game đang chạy.

**Bước 5 — Modular equipment feasibility:** vẽ/ghi 6–8 tổ hợp appearance, chứng minh share rig/socket/layers về mặt thiết kế; đánh dấu bước cần vẽ lại cutouts hoặc kiểm skin Spine.

**Bước 6 — Benchmark packet:** cụ thể hóa cách ghi FPS/p95/drawcall/VRAM ở hai fixture, rủi ro Android, điều kiện G1 cần code presentation và non-goals.

**Bước 7 — Decision memo:** chấm những mục có chứng cứ; nếu chưa có video/binary/FPS thì giữ `PENDING`, đề xuất rõ lựa chọn ưu tiên G1 và điều kiện khiến kết luận đổi chiều.

---

## 11. Deliverables G0 của Codex

Ưu tiên xuất ngoài repo hoặc trong thư mục thiết kế riêng *trên máy*, không tự push vào GitHub:

```text
E:\TongMonBaDao_AssetVault\06_reports\COMBAT_V5_AB_G0\
  00_README.md
  01_SOURCE_EVIDENCE_AND_GAPS.md
  02_A_SOURCE_A_STYLE_GUIDE.md
  03_B_PIXEL_STYLE_GUIDE.md
  04_SHARED_BATTLE_STORYBOARD.md
  05_SKILL_VFX_EVENT_MAPPING.md
  06_MODULAR_APPEARANCE_FEASIBILITY.md
  07_ANDROID_PERF_TEST_PROTOCOL.md
  08_COMPARISON_SCORECARD.md
  09_G1_IMPLEMENTATION_PACKET_PROPOSAL.md
  pilot_manifest.json
  concept_A/                   # optional; labeled CONCEPT_ONLY
  concept_B/                   # optional; labeled CONCEPT_ONLY
  compare_contact_sheets/      # optional; no fake runtime screenshots
```

Manifest/candidate record tối thiểu: `source_family`, `asset_id`, `original_path`, `sha256_or_pending`, `known_action_clips`, `direction_count`, `outfit_attachment_status`, `visual_style`, `source_evidence`, `qa_status`, `blockers`. Không sao chép kho nguồn lớn vào output.

**Báo cáo cuối:** (a) ảnh/concept có thật; (b) asset nào verified vs chỉ có metadata; (c) liệu kỹ năng 5 pilot gắn được tới đâu; (d) số công việc còn lại cho mỗi mẫu; (e) các mốc G1 có thể triển khai presentation-only; (f) những câu hỏi quyết định art direction; (g) không gọi Android PASS nếu chưa có thiết bị.

---

## 12. Mẫu prompt giao việc Codex — chỉ G0

> **TÔNG MÔN BÁ ĐẠO — COMBAT V5 A/B G0 DESIGN ONLY**  
> Đọc toàn bộ `TMB_COMBAT_V5_AB_VISUAL_PILOT_CODEX_PLAN_2026-10-21.md`. Làm việc trên Windows, chỉ kiểm toán read-only và chuẩn bị art concept + storyboard + tài liệu cho hai hướng trình diễn: A = Source A chibi, B = pixel-art tu tiên gốc lấy King God Castle làm tham chiếu **chất lượng** (không sao chép asset). Dùng cùng 6 đệ tử (Kiếm/Thể/Pháp), 1 loài quái thường, 1 Boss, cùng geometry/camera/event timeline và 5 kỹ năng JX1 pilot đã có. Kiểm tra file Source A/Spine converter/Batch-01 từ `E:\TongMonBaDaoWorkspace` và nguồn JX1 tại `E:\Source`, `E:\Tool JX`; đối chiếu GitHub HEAD, Combat V2, P3 modular rig, skill/event/VFX manifests. Không suy diễn animation `attack/hit/dead` từ tên CSV. Xuất G0 packet/asset evidence/2 art bible/6-shot paired storyboard/skill mapping/appearance plan/Android perf protocol/scorecard/đề xuất allowlist G1 theo mục 11. **Không tạo hoặc sửa code, không đụng gameplay/Combat V2/RNG/save/balance, không sửa repo, không commit/CI/FULL/merge, không chạy runtime game.** Nếu chưa có binary hoặc image concept không thể tạo, báo PENDING cụ thể và hoàn thiện phần thiết kế có chứng cứ còn lại. Không hỏi phê duyệt từng thao tác kiểm toán; chỉ dừng trước bước yêu cầu code hay thay đổi gameplay.

---

## 13. Quy tắc ra quyết định cuối

**Chưa chốt A/B sau G0.** Chỉ được đề xuất G1 khi biết nguồn asset thật và blocker của mỗi hướng. Sau visual pilot thực tế, lựa chọn chính thức phải do chủ dự án duyệt từ ảnh/video có tỷ lệ thật và benchmark so được. Có thể chọn A cho tông môn và B cho combat **chỉ khi có art-direction bridge rõ ràng**; mặc định ưu tiên tính thống nhất trong cùng một game.

**Dừng trạng thái hiện tại:** `G0 PLAN WRITTEN — CODE NOT AUTHORIZED — GAMEPLAY UNCHANGED`.
