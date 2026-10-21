# TÔNG MÔN BÁ ĐẠO — CHỐT SOURCE A / KIỂM TOÁN HIỆN TRẠNG / LỘ TRÌNH COMBAT V5

**Ngày lập:** 2026-10-21 · **Loại:** quyết định mỹ thuật + kiểm toán GitHub + roadmap khả thi, **chưa thay code**.  
**Game:** Godot 4.7.2, Android landscape 1280×720, game quản lý tông môn + nhóm đệ tử tự săn quái.  
**Repository:** https://github.com/vuanhtuan161094-byte/TongMonBaDao

## 0. Quyết định mới của chủ dự án (ưu tiên cao nhất)

1. **Chốt một phong cách chính: Source A — chibi tu tiên / 2.5D**, dùng chung cho tông môn, công trình, map, nhân vật, quái, chiến đấu và UI. **Dừng thử nghiệm pixel art**, không chuyển dự án sang King God Castle, không phát triển hai bộ art song song.
2. **Combat V2 tiếp tục làm authority:** HP/damage/RNG/cooldown, Tu Vi 30 cảnh giới × 10 tầng, Luyện Thể 30 × 10, Linh Căn/Ngũ Hành, Injury 0/1/120, One Active Job, warehouse canonical, save/offline exactly-once. Không thay logic chỉ vì đổi art.
3. **JX1 không còn là art direction phải sao chép.** Bảo tồn 5 skill pilot, adapter/event code, các VFX đã xác minh; dùng có chọn lọc, kiểm hợp với Source A. Không tự nhập công thức hay cơ chế JX1. JXQY2 demo cũ giữ làm mốc kiểm thử/historical fallback trên nhánh riêng, không biến thành phong cách chính.
4. Mục tiêu người chơi: vào game nhanh, hiểu màn quản lý, đệ tử có động tác thật, chiến đấu liên tục rõ ràng, camera kéo tự do, theo nhân vật **chỉ khi được chọn**, đội 6 đệ tử; cụm tối đa 30; kiểm tải lớn 30 đệ tử + 40 quái.
5. Ưu tiên **thành phẩm có ảnh/video game thật và lỗi được chỉ đúng**, không báo cáo nghiên cứu vô tận; trước khi mở rộng mọi asset phải vượt qua một vertical slice.

## 1. Rà soát GitHub ngày 21/10/2026 — trạng thái đã xác minh từ repository

| Điểm tham chiếu | Commit/đầu nhánh | Nhận xét |
|---|---|---|
| `main` | `461caca1171462e0da092f21108c5c1733157ad9` | Từ 15/10, không phải baseline chứa toàn bộ G1/MAP25/C4/DEMO mới |
| G1 PR #20 / `g1-disciple-radar-sourcea-pool-20261017` | `2219535fc3519ce811265ceed5cb85001efe5e45` | Dựng trên PR MAP25/Economy; SOURCE A visuals, radar, workforce; draft/open |
| `work/playfirst-demo-max-v3-20261020` | `aad7cec147e5df587ab13614e1c9ef2ac752a8d7` | **Baseline thực tế ưu tiên để khảo sát và tạo branch tiếp theo**; chứa G1, real hunt, sandbox DEMO và lát cắt JXQY2; chủ dự án chưa duyệt mỹ thuật chiến đấu |
| `tools/af-jx1-player-forge-20261020` | `4dcb2daf01e6a14971b32131b7b69d7c67ae563f` | Công cụ tài nguyên/AF-C5 riêng; không tự ý trộn vào game runtime |

Kiểm tra `compare_commits`: nhánh Playfirst *ahead* `main` **478 commits**, ahead G1 PR20 **60 commits**, behind 0 đối với hai base tại thời điểm kiểm tra. Điều này **không** chứng minh mọi tính năng end-to-end PASS. Danh sách API GitHub cho thấy **19 PR đang mở**, nhiều PR draft/stacked. Không cherry-pick `main` hoặc merge hàng loạt để “đồng bộ”.

### 1.1 Gameplay/Economy/G1

- Economy V2 có sản xuất Mỏ/Linh Lâm/Linh Điền và kế hoạch sản lượng mới theo các nhánh stacked; thanh timeline/progress theo ID công trình được thiết kế/triển khai. **Không sửa vì combat**.
- G1 MAP25 đã dùng ảnh Source A verified cho terrain, road, vegetation, các công trình mẫu; chế độ 2.5D có camera, pan/zoom, UI đệ tử, radar Lục Duy. Một số hạng mục owner visual/touch/Android còn PENDING.
- Quyết định 18/10 đã **bỏ yêu cầu action đào/chặt/trồng**: chỉ yêu cầu nhân vật `stand/walk` và timeline/sản lượng thật trong production. Không tái mở debt này.
- G1/C4 QA từng ghi có lỗi T15_PLANT của test fixture và các lần recheck khác nhau; đọc checkpoint theo HEAD, **không truyền một PASS SHA cũ sang SHA mới**.

### 1.2 Combat/DEMO

- `MapBattleV2` là lõi simulation. Pilot dùng bước thời gian 0,25 s; renderer có nội suy camera/sprite và effect cues. Không thay tick nếu không có quyết định gameplay riêng.
- `work/playfirst-demo-max-v3-20261020` có `Run-TMB-Demo-Windows.cmd`, demo max test/save cách ly, auto-skill policy và JXQY2 source slice map 50×100 kèm collision/pathfinding. `CURRENT_CHECKPOINT.md` ghi **official Godot Windows 4.7.2 focused PASS** tại checkpoint M2, GUI 1280×720 có ảnh 5 giai đoạn, nhưng **owner visual PENDING**; V-01 sau đó tăng độ rõ; không có Android final PASS.
- M1/M2 có quy tắc chỉ auto cast skill đã học/được trang bị và có consumer hợp lệ. Giữ nguyên. Map JXQY2 50×100 là proof kỹ thuật, **không phải bản đồ Source A cần tái sử dụng làm art chính**.
- 5 skill pilot JX: `jx_shaolin_15`, `jx_wudang_158`, `jx_wudang_159`, `jx_wudu_63`, `jx_emei_93`. Có logic opt-in trong `jx_pilot_skills_v1.gd` và `jx_pilot_runtime_v1.gd`. **Chưa phải hệ thống học/nhận đủ skill production**. Các WebP precast/cast/impact có manifest theo ID nhưng mới map một số event; không được tự tuyên bố đầy đủ.

### 1.3 Source A đang dùng được ở mức nào?

**Kho nguyên liệu/source:** `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract` (máy chủ dự án; chưa được truy cập trực tiếp từ phiên chat). Nguồn kiến thức phụ: `vuanhtuan161094-byte/ZQZS-Source-Knowledge`, catalog đã lập.  
**Converter đã có:** `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472` và launcher `E:\TongMonBaDaoWorkspace\MO_CONG_CU_SPINE.cmd`.  
**Đầu ra:** `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472\<asset_id>`.

- Source A sử dụng Spine **3.8.75** với triplet `.skel + .atlas + PNG`. Công cụ hiện tại đã chuyển theo đường Spine 3.8 → bake lossless WebP atlas → `.tres` SpriteFrames + `.tscn` AnimatedSprite2D cho **Godot 4.7.2**. Không cần làm lại converter. Chạy Spine runtime native trực tiếp trên Godot 4.7.2 **chưa được kiểm chứng** và không phải điều kiện cần trước mắt.
- Batch-01: **10/10 rig trong danh sách hiệu chỉnh, 31 clip, 1.016 frame, 28 WebP atlas, ~35,6 MB**, pass kỹ thuật cục bộ, không tương đương visual approval/Android FPS.
- GitHub nhánh Playfirst hiện chứa **ba rig** có `.tscn + .tres + asset.json + WebP`: `1113028_1`, `body_1110201`, `body_1120402`. **Mỗi rig đã import chỉ có `stand` (48 frame) + `walk` (24 frame).** Không được tuyên bố `attack/hit/dead` đã import chỉ từ string inventory.
- `godot/art/source_a_env02a/` đang có **32 PNG** các nhóm công trình `510052`, `510102`, `520081`, terrain/road/vegetation, trên nhánh Playfirst. Bất kỳ tài liệu cũ nói “chưa có PNG trong repo” là trạng thái trước ngày nhập chúng.
- `body_1120101_s` trong Batch-01 có **13 clip kỹ thuật**, là ứng viên kiểm `attack/hit/die` **nếu thực tế clip có tên/chuyển động phù hợp**. `1113031_1` và `410041_1` là ứng viên quái đã bake `stand/walk`; chưa có bằng chứng quái đã có đủ animation chiến đấu.
- Modular 2D Rig P3.2 (`docs/P3_2_MODULAR_ACTOR_SPEC.md`) có **9 bones**, **11 lớp**, 4 hướng public, canvas 128×128 cho **rig modular riêng**. Spine bake hiện hữu là rig khác, với canvas/anchor khác. **Không ghép các cutout vào Spine bake bằng giả định không có chứng cứ.**

## 2. Trả lời chính xác: “Source A có cần phân tích để Godot đọc được không?”

**Có ở mức metadata/motion/combat/skin phù hợp; KHÔNG cần bóc tất cả file hoặc viết lại engine/converter.** Pipeline hiện đã cho Godot đọc gói đã bake. Phần chưa giải quyết là `clip/source action → atlas frame → cast event V2 → hình động thật`, khả năng đổi trang phục, map combat Source A và hiệu năng trong trận đông người.

Phân tích đúng thứ tự:

1. **Truy nguồn cục bộ và hash:** tìm triplet `.skel/.atlas/PNG` cho 3 rig đã import và ứng viên quái/boss trong catalog; đối chiếu `asset.json` SHA-256 trước khi xử lý. Không quét mù toàn bộ ~157.607 file khi catalog cũ vẫn đủ.
2. **Liệt kê clip thật:** parse animation timeline Spine 3.8 và skin/attachment/slot/bone/draw-order, có duration/frame thật. CSV string scan chỉ là *candidate*, không phải parse clip.
3. **Bằng chứng nhìn thấy:** contact sheet/grid hoặc video playback `stand/walk/attack/hit/dead` từng ứng viên, nói rõ thiếu clip nào. Không tự giả attack bằng `walk` hoặc xê dịch ảnh.
4. **Bake chọn lọc:** chỉ clip cần cho một demo 6 đệ tử + 1 loại quái + 1 Boss; dùng converter hiện có, không sửa đầu vào. Tái sử dụng atlas qua instance, chỉ re-bake khi hash/config/clip thay đổi.
5. **Trang phục:** đánh giá skin/attachment của skeleton gốc; nếu hỗ trợ thì dùng chung rig + set attachments, tint mask và socket vũ khí; nếu không thì 1–3 biến thể trang phục bake trọn người là phương án chuyển tiếp, không cho phép tổ hợp nổ cấp số nhân. Rig modular P3.2 chỉ nối sau khi có proof retarget/registration.
6. **Map Source A:** dùng terrain/road/vegetation đã nhập; phân định map đẹp nhưng được ghép thành tile phù hợp 2.5D, collision từ backend chính xác; không mượn nền JXQY2 hay vẽ giả nhãn `Source A`.
7. **VFX:** adapter hiển thị theo authoritative event (`cast_start`, `cast_commit`, `launch`, `impact`, `hit`, `status`, `downed` nếu có thực); hiệu ứng Godot tự thiết kế được phép theo art bible. JX1 chỉ reuse nếu hòa hợp mỹ thuật; giữ nguyên IDs/logic.

## 3. Kiến trúc đề xuất — không thay gameplay

```text
DiscipleState / Skill ownership / Combat V2 + Hunting backend (UNCHANGED)
                  |
       authoritative combat events
                  v
        V5 Combat Presentation Adapter
         |             |             |
 Actor clip resolver   VFX resolver   Camera/map renderer
 (Source A Spine)      (V2 skill IDs) (Source A art/2.5D)
         |             |             |
  SpriteFrames/skin    Atlas/GPUParticles2D  culling/Y-sort
         \_____________|_____________/
                       v
             Godot 4.7.2 · 1280×720
```

**Không cho** animation-driven hit logic, VFX fake damage, auto unlock skill, auto-equip gear, thay RNG/tick/save. `appearance_profile`/gear look chỉ đọc state thật. Camera mặc định pan tự do, chỉ follow khi chọn actor; không thay pathfinding để che lỗi hình.

## 4. Lộ trình tối ưu (không làm lại những gì đã làm)

| Giai đoạn | Mục tiêu | Công việc tối thiểu | Bàn giao & gate |
|---|---|---|---|
| **P0 — Chính xác baseline** | Bảo toàn thành quả cũ | Fetch mới HEAD của `main`, PR20, Playfirst, Forge; kiểm test/launcher/gói art hiện có, chụp ảnh hiện trạng, SHA and save paths; đánh dấu code vs runtime vs UX | `P0_CURRENT_STATE_MATRIX.md`; commit/branch chính xác; ảnh hiện trạng, no edits gameplay |
| **P1 — Source A Combat Asset Gate** | Tìm được motion thật | Chọn 1 đệ tử (ưu tiên 3 rig rồi `body_1120101_s`), 1 quái, 1 Boss ứng viên, nền map; kiểm skel/atlas/PNG, clip attack/hit/dead, hướng và skin; contact sheets | `SOURCE_A_COMBAT_ASSET_MATRIX.csv`/`.md`, 3+ contact sheets, hash; YES/NO theo từng clip; chỉ đủ source mới mở P2 |
| **P2 — Combat Source A Visual Slice** | Combat chibi thật trước khi mở rộng | Nhánh mới từ Playfirst HEAD, thay lớp presentation của demo thí điểm bằng Source A đã xác minh; 1 đội tối đa 6, wolf+Boss candidate, 2–4 cues skill; V2 untouched | Godot Windows 1280×720 video/screenshot `idle/walk/cast/impact/hit/die`, camera, no placeholders bị gọi là Source A; focused PASS |
| **P3 — Đồng nhất quản lý ↔ săn quái** | Một game nhìn đồng bộ | So scale, anchor, z-order, ánh sáng, cây che nhân vật, chỉ báo HP, màu UI, zoom/touch giữa MAP25/G1 và combat; giữ tiến độ production | A/B ảnh màn G1 và combat chung art bible, owner visual approve |
| **P4 — Tối ưu & packaging** | Mượt máy yếu/Android | Texture/atlas/page budget, culling, VFX pooling, prewarm/reuse, one-click game startup không clone/reimport mỗi lần; stress 30v40 | Windows logs CSV P50/P95 CPU/GPU FPS, draw calls, memory; Android thật PENDING tới khi có device; không đổi deterministic backend |
| **P5 — Thư viện & nội dung** | Mở rộng an toàn | Asset catalog nhóm: environment/building/actor/NPC/monster/boss/UI/icons/VFX; skill visual registry có provenance, pack incremental | Manifest canonical + preview, không trùng asset converter/Forge, không import toàn kho |

**Ưu tiên thực tế lần giao Codex đầu tiên:** P0 + P1 và **P2 vertical slice có điều kiện** (chỉ nếu P1 tìm được clip/asset thật). Không mở P3–P5 cùng lúc. P2 không cần phải chuyển cả game sang Source A ngay lập tức; giữ được bản demo cũ để so sánh.

## 5. Skin/trang phục — quyết định kỹ thuật

- **Option S1 (ưu tiên nếu nguồn hỗ trợ):** Spine gốc có compatible skins/attachments trên cùng skeleton, bake/resolve cùng animation family; thay outfit/tóc/vũ khí là chọn attachment, không tạo một animation toàn thân trên mỗi tổ hợp.
- **Option S2 (chuyển tiếp):** 1–3 whole-body outfits/actor, 1 atlas shared theo bộ, không biến thể từng cá nhân. Chính xác và đủ đẹp hơn một hệ modular giả. Metadata biểu diễn equip look từ item thực.
- **Option S3 (dài hạn):** P3.2 Godot `Skeleton2D` + 9 bones/11 layers có animation riêng; chỉ bridge Source A khi proven-compatible anchor/slot/weight. Không tự suy ra chuyển skeleton tùy tiện.
- Cap variant + atlas pages theo số đo runtime; cache theo (rig_id, skin_id, clip, direction), dedupe hình dùng chung; không sao chép PNG/WebP hàng nghìn lần. Missing visual chỉ có fallback **được gắn nhãn**, không đổi state.

## 6. Ưu tiên bốn VFX + giữ skill JX1

| VFX proof | Skill canonical/nguồn | Visual & tiêu chí |
|---|---|---|
| Kiếm khí | `Thanh Phong Trảm` hoặc `Ngự Kiếm Thuật` khi thật sự có consumer V2 | Slash/projectile trên đúng target/timing, không tự tính sát thương |
| Thể kích | Thể Tu basic/hit event đang được V2 hỗ trợ | Short impact, bụi/đẩy vị trí hiển thị không vượt world coords |
| Hỏa | `Hỏa Cầu` **nếu đã có runtime consumer hợp lệ**, nếu chưa chỉ storyboard | Fireball+impact nhỏ, không cộng burn giả |
| Hồi phục | `Hồi Xuân Thuật` **nếu có thực**, hoặc giữ `jx_emei_93` pilot HoT khi được trang bị hợp lệ | Hiện số heal khi V2 thực sự emit receipt, không hồi máu giả |

5 JX pilot và các raw WebP JX giữ nguyên trong repo/manifest. Trường hợp làm hiệu ứng pixel/Source A tu tiên mới phải mapping Visual Registry nhưng không mutate ID, cooldown, element, damage. Các kỹ năng chưa có consumer production không bật trong game thường chỉ để có VFX.

## 7. KPI, QA và điều kiện nghiệm thu

**Cổng kỹ thuật:**
- Asset nguồn đúng và SHA đúng; Spine `animation name/duration/dir`, `foot_anchor`, slot/socket rõ ràng; gói Godot export đủ `.tscn/.tres/atlas/asset.json` hoặc scene resource tương đương.
- P0 baseline launch được từ bản clone cô lập; save chính trước/sau hash bằng nhau; không chạy lẫn file trong admin profile.
- 6 đệ tử/đội, 1–4 quái thường + 1 Boss; status/số/HP/cast lấy từ V2, idle→walk→cast/attack→hit→die; map camera pan/zoom/follow chọn/không chọn; 1280×720.
- Không có hiện tượng actor lơ lửng, clipping sai, texture bị lỗi, duplicate HP, VFX che mặt/đè UI, atlas memory tăng liên tục sau nhiều wave.
- Performance **target tham chiếu**: Android 30 FPS (P95 frame ≤33,3 ms), thử 60 FPS khi cấu hình cho phép; không công bố đạt nếu không đo trên máy thật. Windows 8 GB RAM cần test one-click + benchmark, tải asset incremental; không chạy FULL/CI.
- Test focused: scene import/parse, asset manifests, visual event adapter, renderer/camera, 6v5 snapshot/replay, save isolation, One Active Job unaffected; stress 30v40 bằng fixture riêng. Hash/save bảo vệ exactly-once.

**Cổng duyệt chủ dự án:** ảnh/video **game chạy thật** với nhãn vị trí nguồn, tên skill/thời điểm, trước/sau transition; phải có hai ảnh G1 và combat ở cùng hệ scale/mood. `technical PASS` không phải `owner UX PASS`.

**Bị chặn nếu:** không có binary Source A, hash khác, `attack/hit/die` vắng mặt, không có source cho Boss, skin không ghép được. Dừng **mốc tương ứng**, ghi rõ `BLOCKED`/`PENDING` và đề xuất đúng danh sách asset thiếu; không thế placeholder là “đã hoàn thành”.

## 8. Quy tắc vận hành trên Windows máy người dùng

- Chỉ dùng Windows account hiện tại; **không dùng Administrator profile**, không ghi file vào `C:\Users\Admin`. Dùng thư mục E: hiện có.
- Với RAM khoảng 8 GB: không sinh 1000 atlas/lượt, không khởi nhiều Godot/Spine song song, không reimport toàn bộ chỉ để chơi; preview incremental, cache dựa fingerprint.
- Nguồn và output tách biệt. Input Source A chỉ đọc; Godot clone + `user://` sandbox; ghi báo cáo vào `E:\TongMonBaDaoWorkspace\05_DauRa\CombatV5_SourceA_Pilot\`, báo cáo kiểm thử vào subfolder `QA`, không ép di chuyển nguyên kho.
- Nếu cần tải lại repo ở máy, dùng đúng account hiện có; không tự cài/bật server/engine lạ hoặc yêu cầu quyền admin. Kết quả cuối cùng phải là path/ảnh/log thật + HEAD/branch; không lấy static scan thay runtime.

## 9. Tài liệu/chương trình phải đọc trước khi Codex làm

- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
- `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_ART_BIBLE.md`, `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`.
- `docs/MAP25_SOURCE_A_ORIGINAL_ASSET_RECOVERY.md`, `docs/G1_SOURCE_A_WORK_ACTION_MINIMAL_PACKET_2026-10-17.md`, `docs/C4_G1_MAP25_COMBAT_INTEGRATION_QA_DEBTS_2026-10-19.md`, `docs/M2_JXQY2_LOCAL_SLICE_QA_2026-10-20.md`.
- `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `godot/src/simulation/combat/map_battle_v2.gd`, `godot/src/simulation/combat/jx_pilot_skills_v1.gd`.
- `godot/assets/actors/{1113028_1,body_1110201,body_1120402}/asset.json` and `animations.tres`, `godot/art/source_a_env02a/`, `godot/src/presentation/p3/disciple_source_a_visual_pool.gd`, `godot/src/presentation/p3/map_battle_world_layer_v2.gd`.
- Source Knowledge: https://github.com/vuanhtuan161094-byte/ZQZS-Source-Knowledge ; prefer previously generated catalogs before recursive source scanning.

## 10. Những gì **KHÔNG** được hiểu nhầm

- 10/10 Batch-01 PASS không đồng nghĩa tất cả đã có attack animation; 31 clips là tổng cho 10 rig.
- Các ảnh pixel concept trước đây chỉ là concept, **không phải lý do sửa art bible**.
- `main` còn cũ không đồng nghĩa code bị mất: nhánh Playfirst đang có G1/Combat; không merge hàng loạt.
- Không chọn JX1 làm style lại chỉ vì Source A một vài clip combat còn thiếu. Thiếu thì tiếp tục tìm trong catalog Source A hoặc đưa ra scoped asset-production gap.
- Không đổi 30×10, save, HP, One Active Job, loot/reward, cooldown hoặc skill ownership để tạo cảm giác “đánh đẹp”.

## 11. Bàn giao kỳ vọng của Codex đầu tiên

1. Trích `P0_CURRENT_STATE_MATRIX.md` phân biệt GitHub code, Windows proven QA, owner visual, Android PENDING.
2. Xuất `SOURCE_A_COMBAT_ASSET_MATRIX.csv` + `.md` với rig IDs, triplet source/hash, clip/skin actual, suitability, Godot destinations; chỉ 5–10 ứng viên ưu tiên, mở rộng nếu thật sự thiếu.
3. Xuất **contact sheet hoặc video** từng actor/monster/clip trên hệ tọa độ nhất quán, kèm số frame/biểu đồ thời gian; chỉ source-verified.
4. Nếu PASS P1, xuất Pilot Godot có **1 nam/nữ Source A + 1 quái + 1 Boss + 2 V2 skill cues**, dùng đội 6 với visual pool hợp lệ nếu mẫu nhân vật giới tính tương ứng đủ. Nghiệm thu bằng capture 1280×720 và focused log. Nếu thiếu asset, không tuyên bố P2 PASS.
5. Chỉ commit trên **nhánh CODE riêng từ Playfirst HEAD mới nhất**, không merge/push source gốc hàng chục GB, không CI/FULL. Sau từng packet báo commit/SHA + khác biệt kỹ thuật/UX; cập nhật đúng checkpoint/handoff.

**Hành động đề xuất:** Giao file prompt độc lập `CODEX_TMB_SOURCE_A_COMBAT_V5_P0_P2_2026-10-21.md`, không cần yêu cầu người dùng chọn lại phong cách.
