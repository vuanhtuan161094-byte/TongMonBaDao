# TÔNG MÔN BÁ ĐẠO — COMBAT V5 / SOURCE A CHIBI
## Thiết kế chuyên sâu: săn quái tự động, đội hình, kỹ năng tu tiên, hiển thị và ngoại hình ghép lớp

**Ngày:** 2026-10-21  
**Trạng thái:** `DESIGN PROPOSAL / NOT CODE AUTHORIZATION / OWNER DECISION OPEN`  
**Engine:** Godot 4.7.2 · Android landscape 1280×720 · chủ trương hiệu năng 30 FPS trên thiết bị mục tiêu, 60 FPS là mục tiêu nâng cao (chưa benchmark).  
**Repo đã đọc:** `vuanhtuan161094-byte/TongMonBaDao`; live `main` = `461caca1171462e0da092f21108c5c1733157ad9`, nhánh khảo sát `tools/af-jx1-player-forge-20261020` = `4dcb2daf01e6a14971b32131b7b69d7c67ae563f` vào lúc lập bản thiết kế. Tài liệu đọc từ nhánh khảo sát; phải kiểm tra lại HEAD trước khi code.  
**Không làm trong packet này:** không thay bất kỳ code, balance, save, V2 numeric, Godot scene, CI, merge; chưa nghiệm thu Windows/Android.

## 0. Quyết định đề xuất và nguyên tắc không phá authority

**Phương án chủ đạo:** Gameplay *Evil Hunter Tycoon* ở cấp luồng (đệ tử tự tìm quái, đánh, hồi phục, chuyển mục tiêu, trả về căn cứ); ngôn ngữ mỹ thuật tu tiên chibi đồng bộ Source A; combat là **sản phẩm riêng** của Tông Môn Bá Đạo, không phải mô phỏng đúng JX1 hay bê combat theo lượt từ 最强祖师.

* **Combat V2 duy nhất sở hữu** trạng thái chiến đấu, vị trí authoritative, tính toán attack/defense/crit, target, cast, hit, shield, heal, death, RNG, buff, mastery, loot/reward, save/offline. V5 là thiết kế *view adapter + content authoring + tương lai AI/world contract*, không tạo damage bằng timeline, particle hoặc animation.
* **Không tự triển khai luật thiết kế chưa được code.** `COMBAT_SKILLS_V2_SPEC.md` ghi `DESIGN LOCKED — NOT IMPLEMENTED`; một số cơ chế mới (accuracy/evasion, dodge skill, bản đồ hunting liên tục) có thiết kế nhưng chưa thể coi đã hoạt động. Pilot chỉ dùng event thực của runtime hiện có, hoặc *fixture cách ly* được dán nhãn `VISUAL FIXTURE`, không thưởng/đổi save.
* **Chủ Đạo mềm:** Chưa Định Đạo / Kiếm Tu / Thể Tu / Pháp Tu, một chủ đạo và một nhánh active, lưu lịch sử các nhánh; không có class level. Ba nhánh Kiếm: Ngự Kiếm / Sát Kiếm / Hộ Kiếm; Thể: Bá Thể / Kim Cương / Huyết Thể; Pháp: Ngũ Hành / Y Đạo / Huyền Pháp.
* **Khung tu luyện:** Tu Vi 30 cảnh giới × 10 tầng, Luyện Thể 30 × 10 tầng; Lục Duy và Linh Căn tiếp tục theo authority hiện có; không thêm Mana, Rage, Kiếm Ý hay năng lượng toàn cục.
* **Loadout V2 trưởng thành:** 1 Thường Kỹ + 4 Chủ Động + 6 Bị Động chiến đấu; mở khóa tăng dần. `Nhân (1–10)` lập nền, `Tiên (11–20)` tiến hóa, `Thần (21–30)` kỹ năng hậu duệ theo cơ chế được author, không nhân bừa sát thương.
* **Quy mô:** 6 đệ tử/đội; tối đa 30 đệ tử/cụm (tối đa 5 đội). Đo thử 30 đệ tử + 40 quái, nhưng không giả định tất cả 70 actor phải ở cùng một màn hình ở mọi thời điểm.
* **Kinh tế/save:** One Active Job; Injury 0/1 và 120 tick; kho canonical và exactly-once receipt không đổi. Item/mảnh quái thuộc tông môn vào **Sect Warehouse trực tiếp khi sự kiện reward được kết toán**, không dựng túi loot thứ hai hoặc hiệu ứng +vật phẩm trước khi reward thật.

## 1. Cảm giác chiến đấu mục tiêu — mô tả ở góc nhìn người chơi

1. Tại map săn quái 2.5D có rừng, suối, bụi, đường, đá, khu vực nguy hiểm. Camera đang **tự do**, không bám nhân vật khi vừa mở map. Người chơi có thể kéo map, zoom, bấm chọn một đệ tử để theo dõi; kéo màn hình lại thì ngắt theo dõi.
2. Nhiều đội hoạt động song song trong một cụm: đội tiên phong áp sát, kiếm tu tìm góc đánh, pháp tu giữ cự ly, Y Đạo hồi phục; quái tuần tra/chủ động tấn công theo điều kiện thật.
3. Đánh cơ bản có nhịp và sức nặng. Kỹ năng hiện ra với cảnh báo ngắn, đúng thời điểm phát động/va chạm; không che mất nhân vật. Khi trúng đòn, HP và hiệu ứng là kết quả Combat V2 thực, không do sprite tự tạo.
4. Quái bình thường, tinh anh và Boss phân biệt được bằng **silhouette, tỉ lệ, animation, hành vi và thanh HP**, không chỉ cùng một sprite phóng to hoặc đổi màu.
5. Không khóa người chơi vào màn 6 đấu 5/90 giây. Hunting liên tục là **mục tiêu thiết kế runtime**; trạng thái cũ `ARENA 36×20/MAX_SECONDS 90` vẫn là baseline phải được migrate/thiết kế packet riêng, không xóa trong V5 design.
6. Khi một đội bị thương/cạn tiếp tế hoặc không còn mục tiêu hợp lệ, AI xử lý bằng **điều kiện có thực**; không tự tạo biến cố trúng/né/cứu/chết để cho đẹp. Người chơi quyết định chiến lược ưu tiên, không điều khiển mọi cú đánh.

### Bảng hành vi có thể quan sát

| Tình huống | Hành vi mong muốn | Cần chứng cứ/simulation |
|---|---|---|
| Mở bản đồ săn | Đội tự chạy theo lộ trình; camera giữ vị trí người chơi | Hunt job active thực, position authority |
| Gặp quái | Ai trước mặt chọn mục tiêu, hàng sau định vị theo range | target selection V2 + navigation |
| Kiếm Tu cast | Đổi pose → kiếm khí → trúng mới có impact/sát thương | cast/launch/hit events cùng `cast_id` |
| Hỏa cầu bay | Projectile đi theo launch và thời gian đến đích | authority launch/travel/resolve |
| Boss AoE | Telegraph trên đất; né bằng di chuyển hợp lệ hoặc kỹ năng đã học | event telegraph/resolve; không fake né |
| Y Đạo hồi máu | Hiện lá sáng/gợn xanh khi hồi lượng HP thật | effective heal receipt |
| Quái chết | Hit → death clip → fade/despawn khi authority kết luận | dead/downed event, không nhân đôi drop |
| Offscreen | Mô phỏng cho cùng kết quả với khi đang xem | deterministic replay and receipt |

## 2. Kiến trúc hệ thống — ba tầng phân quyền rõ ràng

### Tầng A — Gameplay authority (HIỆN CÓ, KHÔNG SỬA TRONG THIẾT KẾ)

`SimulationState → Disciple/Equipment/Skills → MapBattleV2 / HuntingV2 → events / snapshots / rewards`.

Luật game và trạng thái có thể ghi save chỉ được cập nhật ở đây. Luật skill nâng cao trong `COMBAT_SKILLS_V2_SPEC.md` sẽ cần packet migration riêng mới được ghi vào runtime.

### Tầng B — Presentation bridge (HƯỚNG KIẾN TRÚC)

Một adapter nhận **immutable snapshot** và **event stream** đã có. Mỗi event cần được gắn/xác định (nếu authority hỗ trợ) các danh tính tối thiểu: `event_sequence`, thời điểm mô phỏng, `source_actor_id`, `target_actor_id`/`world_position`, `skill_id`, `cast_id`, `event_kind`, `resolved_result`, `element`, `status_ids` khi liên quan. Nếu runtime cũ không chứa trường nào, ghi `PENDING ADAPTER CONTRACT`, **không tự tính lại** để điền.

Adapter chỉ tạo `VisualCue` (chơi clip, quỹ đạo, particle, số máu, âm thanh), cập nhật vị trí view bằng nội suy giữa **hai vị trí authority**, không viết ngược gameplay. Tái mở scene, rollback, replay cần cursor/sequence để không phát hai lần cùng một impact/hit.

### Tầng C — Render độc lập (HƯỚNG KIẾN TRÚC)

`HuntingWorldView` (viewport + camera + chunk), `ActorVisual` (rig + animation), `EquipmentSkinView` (modular attachment), `SkillVFXView` (vòng đời VFX), `HUD` (HP/status/selection), `PerformanceDiagnostics` (CPU frame / draw / texture / memory). Các tên trên là đề xuất module, **không phải file đã được code**.

**Quy tắc:** tắt VFX, bật 30/60 FPS, kéo camera hay chuyển app background **không đổi** thứ tự event Combat V2, HP, loot, RNG hoặc công việc của đệ tử.

## 3. Thế giới săn quái nhiều đội

### 3.1 Lớp thế giới

- Không gian vùng săn có `region_id`, tọa độ world cố định, ô/điểm điều hướng, obstacle, spawn zone, route/waypoint. Kích thước vùng săn và chunk size phải do dữ liệu map thật định nghĩa; không áp cấu hình MAP25 tông môn 192×192/16×16 lên mọi map hunting.
- Dùng chunk culling và preload gần camera; collision/pathfinding thuộc authority, không suy ra từ nền texture mờ. Trang trí (đá, bụi, cây) có foot anchor, Y-sort; tán cây có foreground occlusion riêng nếu asset chuẩn hỗ trợ.
- Những vùng chưa được cung cấp art thật không được trình bày là Source A chính thức; placeholder gắn trạng thái. Bản đồ tông môn và bản đồ hunting dùng **cùng chuẩn màu/scale/perspective**, nhưng không ép một scene map quản lý công trình kiêm chủ toàn bộ logic combat.

### 3.2 Tổ chức đội

- `Squad`: tối đa 6 `disciple_id` tham gia (không clone nhân vật), chính sách săn theo khu/vùng, rủi ro, mục tiêu và ưu tiên tự hồi phục.
- `Cluster`: tối đa 5 Squad / 30 người; monster cap fixture 40. Các đội không tự nhiên chia sẻ buff party. Debuff lên cùng Boss là target-scoped; cap chung theo skill-authority; không tạo 5 bộ stack khác nhau.
- Vị trí đội mang tính chiến thuật mềm, không khóa trận hình 3×2; đội có thể tách nhỏ xung quanh terrain. Tập hợp lại nếu xa quá ngưỡng được author, tránh cả đội chồng vào một điểm.
- Công việc hunting là một active job hợp lệ; không xuất hiện đồng thời worker mỏ và fighter đang săn theo One Active Job.

### 3.3 Vòng AI nhiều cấp — tương lai, không thay AI hiện tại

| Cấp | Quyết định | Chu kỳ lý tưởng | Điều kiện |
|---|---|---|---|
| Tông môn | Giao đội / ưu tiên vùng / tiếp tế | Khi chính sách/job đổi | Real roster, policy, workforce |
| Squad | Tới khu, chọn nhóm mục tiêu, giữ khoảng cách nhóm, rút lui | Event hoặc tick simulation | Alive/morale/supply theo authority |
| Disciple | Giữ tầm đánh, chọn target, cast, đổi target | **Bước Combat V2** / sự kiện | Range/HP/learned equipped skill |
| View | Di chuyển mượt, pose, projectile, VFX, HP | Render frame | Snapshot + events, *read-only* |

**Trọng số không áp dụng bừa:** Ưu tiên target (Boss/Elite/low HP/gần nhất) phải do chính sách đội và luật skill quy định, tie-break bằng ID ổn định. Không dùng RNG tùy tiện để 70 actor chuyển mục tiêu mỗi frame.

### 3.4 Vai trò thể hiện bằng Chủ Đạo + nhánh, không phải class khóa cứng

| Chủ Đạo / nhánh | AI khoảng cách / hành vi | Đặc tính hình ảnh |
|---|---|---|
| Kiếm / Ngự Kiếm | Trung–viễn, thả phi kiếm có quỹ đạo | Quang kiếm mảnh, vệt chuyển động gọn |
| Kiếm / Sát Kiếm | Cận–trung, áp sát đúng cửa sổ burst | Flash ngắn ở cạnh mục tiêu, không teleport giả |
| Kiếm / Hộ Kiếm | Bảo hộ, phản kích khi có event | Vòng kiếm bảo hộ, sáng tắt theo status |
| Thể / Bá Thể | Cận chiến, stagger/phá giáp nếu skill thật hỗ trợ | Hit-stop thị giác ngắn, sóng xung kích thấp |
| Thể / Kim Cương | Cận, giữ uy hiếp và bảo vệ | Silhouette chắc, shield/guard arc |
| Thể / Huyết Thể | Cận, rủi ro HP, sustain thực | Aura nhịp theo status, không tự tăng damage |
| Pháp / Ngũ Hành | Trung–xa, theo nguyên tố và target | Hỏa/Thủy/Mộc/Kim/Thổ rõ hình học |
| Pháp / Y Đạo | Hậu tuyến, chỉ heal/buff hợp lệ | Gợn sinh khí ít hạt, màu đọc HP |
| Pháp / Huyền Pháp | Trung–xa, debuff/control | Ấn chú, vòng phù có cảnh báo |

Đệ tử Chưa Định Đạo vẫn có hành vi đánh thường theo loadout thực, không tự động có kỹ năng hoặc class mặc định.

## 4. Animation chiến đấu Source A — chi tiết hợp đồng

### 4.1 Hiện trạng có bằng chứng

- Source A từ Unity dùng Spine 3.8.75 `.skel + .atlas + PNG`; converter có sẵn tại `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472` xuất `actor.tscn`, `animations.tres`, atlas WebP lossless, `asset.json` sang `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472`.
- Batch-01 10/10 rig **trong danh sách pilot được hiệu chỉnh** đạt kỹ thuật (31 clips/1016 frame); không chứng minh toàn nguồn có đủ attack/hit/die. Ba rig đệ tử nhập map `1113028_1`, `body_1110201`, `body_1120402` hiện chỉ có `stand/walk` trong SpriteFrames đã import.
- Danh mục chuỗi dữ liệu có gợi ý `attack1…`, `hit`, `dead` cho một số rig, nhưng **không coi chuỗi byte hay file danh mục là clip được phát thành công**. Kiểm tra đúng skeleton/animation, skin, atlas trước khi công bố.
- Có quái đã được thử bake (`1113031_1`, `410041_1`) nhưng clip combat đúng hình chưa được xác nhận.

### 4.2 Bộ clip tối thiểu cho 1 actor chiến đấu

`idle`, `run/walk`, `attack_light`, `cast/attack_magic` khi tác giả có, `hit_react`, `die`, `recover` (có thể là pose pha cuối hợp lệ; không bắt tạo clip mới). Nguồn nào không có phải ghi `MISSING`, **không đổi tên `walk` thành `attack`**.

Mỗi clip cần: `source_skeleton_sha`, `skin`, `source_animation`, hướng thực (`authored` hoặc `mirrored_safe`), số frame, duration, FPS, chân/socket, alpha edge, điểm commit tương ứng nếu tác giả/nguồn cho phép; kiểm tra idle/walk/attack/die khi chuyển state không giật/teleport.

### 4.3 Timeline trình diễn theo event, không theo animation damage

Đề xuất sơ đồ 6 trạng thái *visual*: `locomotion/idle → windup → release → flight (nếu có) → impact → recovery`. `cast_id` liên kết các cue để dọn dẹp/cancel đúng. **Damage/hit chỉ xảy ra khi authority quyết định**, không đồng nghĩa animation chạm ở frame số X; có thể giữ pose/warp thời gian nhìn thấy trong giới hạn thẩm mỹ *mà không di chuyển event gameplay*.

Khi mất target: hình ảnh projectile biến mất/chuyển dạng tùy **event miss/cancel thật**, không tùy cảm giác mắt. Animation chết không tạo reward, chỉ có death event mới cho phép despawn đúng.

**Hướng di chuyển:** hợp đồng modular actor public là 4 hướng down/right/up/left. Nếu Source A rig chỉ phát thực 2 hướng, chỉ sử dụng 2 hướng cho proof; `left` mirror từ `right` khi mirror-safe. Không tự ghi 8/16-direction vào Source A như JX1, không flip trang bị bất đối xứng bằng suy đoán.

## 5. Đổi trang phục KHÔNG nổ atlas — quyết định kiến trúc quan trọng nhất

### 5.1 Vì sao full-baked mọi tổ hợp không phù hợp

Nếu có 6 tóc × 8 áo × 4 vũ khí × 3 mũ thì 576 hình thái trên **cùng một rig**, chưa kể giới tính, hướng và động tác. Nếu xuất toàn bộ từng tổ hợp dưới dạng chuỗi frame, dung lượng nhân theo số kết hợp và tạo nợ shader/cache/authoring. Con số 576 chỉ minh họa phép nhân, không phải content đã tồn tại.

### 5.2 Ba cách vận hành có phân tầng độ ưu tiên

| Cách | Khi nào dùng | Ưu điểm | Giới hạn |
|---|---|---|---|
| **M1 — Shared modular rig (MỤC TIÊU CHÍNH)** | Đệ tử có tóc/áo/vũ khí đổi được | Một AnimationLibrary chia sẻ; thay attachment và tint-mask theo trang bị | Cần art cutout và 9-bone/socket registration chuẩn |
| **M2 — Original Spine skin swap đã kiểm** | Nếu Source A skeleton/skin thực sự cung cấp slot/attachment tương thích | Tận dụng chuyển động gốc, giảm số motion authoring | Godot 4.7.2 native Spine3.8 chưa xác minh; cần runtime hoặc bake chọn lọc |
| **M3 — Prebaked full sprite (fallback)** | Quái, Boss, NPC cố định trang phục, đệ tử ít chỉnh | Rẻ draw call cho số đông, converter hiện có | Không cho đổi item tùy ý; phải ghi `fixed_visual` |

**Không đồng nhất M1 và M2.** M1 là scaffold Godot `Skeleton2D` 9 bone + 11 render layer theo `P3_2_MODULAR_ACTOR_SPEC.md`. M2 là *skin và slot từ Source A Spine*, không tự động chuyển thành hợp đồng bone Godot. Chỉ dùng một adapter sau khi mapping thực nghiệm xác nhận; không viết converter mới nếu converter/rig có sẵn xử lý được.

### 5.3 Contract M1 giữ nguyên chuẩn P3.2

- Hai rig gốc: `male_normal_v1`, `female_normal_v1`, chưa tự thêm body_type.
- Registration canvas nguồn 128×128, foot `(64,104)`, scale map zoom 1 là 0.68, silhouette khoảng 64–70 logical px. Source A baked art **không tự nhiên cùng canvas**: phải tính normalizing transform per asset và QA ở gameplay size, không lấy giá trị này ép mọi SPR/WebP.
- 9 bone: `root, pelvis, torso, head, arm_l, arm_r, hand_weapon, leg_l, leg_r`.
- Thứ tự lớp (sau ra trước): `shadow, aura, hair_back, weapon_back, body, outfit, face, hair_front, head_accessory, weapon_front, accessory`.
- Tách `visual_equipment_id/skin_id` khỏi `equipped_items` có authority. Khi equipment V2 cung cấp item thực, mapping ngoại hình ưu tiên item đó (hoặc skin override được cấp phép); không để UI hiện kiếm xịn khi game đang cầm gậy mà không có skin rule.
- Một atlas/animation source dùng cho **nhiều instance**. Cập nhật màu tóc/áo bằng tint mask riêng, **không tint toàn body/da/kim loại**. Cache key tham chiếu `rig + attachment IDs + tint palette + direction`, không nhân số lượng texture theo instance đệ tử.
- Nếu visual asset thiếu hoặc không mirror-safe: fallback về variant/default hiện có, giữ stable identity; không sửa save/gameplay để hợp art.
- `appearance_profile` thuộc persistence khi migration được phê duyệt; giai đoạn thiết kế và pilot view dùng dữ liệu/fixture có provenance, không tự thêm trường save.

### 5.4 LOD để nhiều đệ tử không bị giật

- **LOD0 gần/chọn:** modular 11 layers, có vũ khí, aura ngắn, đủ animation.
- **LOD1 trung:** giảm layer mỹ thuật phụ, gộp sprite precomposed theo variant được phép và cache; vũ khí chính vẫn nhận diện.
- **LOD2 xa:** sprite base thấp chi tiết/chỉ idle-run, HP only khi selected/damage; không có hạt sáng riêng per actor.
- **Ngoài màn hình:** không instantiate/update visual actor nếu không cần, *simulation vẫn chạy*. LOD và draw culling không được thay kết quả chiến đấu.
- Không pre-render mọi tổ hợp trong kho: chỉ cache những **appearance signature đang xuất hiện trong viewport** với eviction theo memory budget.

## 6. Quái thường, tinh anh và Boss

- Reuse mô hình `MonsterCatalogueV2` để định danh species/grade/HP/thực lực và skill authoring; art manifest phải ánh xạ `monster_species_id + skin_variant + action` → nguồn đã xác minh.
- Tối thiểu ba silhouette khác nhau cho pilot nếu nguồn hỗ trợ: quái nhỏ phổ thông, elite rõ thiết kế, Boss to với animation riêng. Không coi phóng `wolf` thành 1.52x là Boss Source A chuẩn.
- Quái có `idle/run/attack/hit/death`, khác biệt attack telegraph và HP bar. Nếu thiếu `hit` clip thì status art gap, không giả animation từ idle.
- Boss dùng các primitive V2 (target, cast, warning, AoE) với phase/state được author sau này; warning hiển thị trên mặt đất trước impact, không dựng hitbox từ kích thước VFX.
- Y-sort theo vị trí chân, riêng vật trang trí/tán cây che trước sau; boss bar riêng khi selected hoặc Boss engagement.

## 7. Hệ kỹ năng: nội dung V2 + ngôn ngữ VFX tu tiên

### 7.1 Không tạo hệ gameplay mới

Các họ kỹ năng lấy từ `COMBAT_SKILLS_V2_SPEC.md`; visual family chỉ mô tả hiệu ứng cho **skill đã học và trang bị hợp lệ**. Mỗi skill content khai báo `style_tag`, `weapon_requirement`, `primary_element`, geometry, duration, action timing, effect/target cap, AI điều kiện và VFX family khi được code content thực. *Không được tạo skill free cho đệ tử chỉ để hiện demo.*

Khắc chế Ngũ Hành V2: Kim > Mộc > Thổ > Thủy > Hỏa > Kim; Tương Sinh Mộc→Hỏa→Thổ→Kim→Thủy→Mộc chỉ kích hoạt khi skill author opt-in. Không để màu VFX tự kích hoạt buff/debuff. Dị Linh Căn Lôi/Phong/Băng/Dương/U Minh giữ điều kiện mechanics thuộc authority; chưa có thì preview thuần hình không gây status.

### 7.2 Bốn Visual Family V5-G1 — dùng tên skill có trong tài liệu V2

| Visual family | Skill đại diện (V2 design) | Động tác/khung hình | VFX theo giai đoạn | Giá trị hình ảnh |
|---|---|---|---|---|
| **VFX-01 Kiếm quang** | **Thanh Phong Trảm** (Kiếm), tương lai Phá Giáp Kiếm | Rút tay/nhấc kiếm → chém/vung → thu thế | Windup ánh kim mảnh → vệt kiếm dạng cung → tia impact ngắn | Mạnh, nhanh, rõ hướng; không phủ full màn |
| **VFX-02 Hỏa đạn** | **Hỏa Cầu** (Pháp) | Tay thi pháp → phóng cầu → recover | Quang cầu/trail hạt giới hạn → va chạm nổ nhỏ; Burn chỉ theo event thực | Đọc đường đạn, không tự nhân damage |
| **VFX-03 Ấn trận trên đất** | **Hàn Sương Ấn** (Pháp/Thủy) hoặc một pháp trận Huyền Pháp nếu đã author | Trì chú → vòng telegraph → kết ấn | Vòng rune sát mặt đất → tinh thể/hàn khí → tắt đúng resolution | Phân biệt warning, release, slow/freeze theo receipt |
| **VFX-04 Sinh khí hồi phục** | **Hồi Xuân Thuật** (Pháp/Y Đạo) | Giơ tay/tụ khí → phát tán → recover | Lá sáng/sóng xanh rất ngắn → dấu cộng HP khi heal thật | Ưu tiên khả năng đọc đồng đội, ít hạt |

**Bổ trợ Thể Tu từ cùng thư viện:** `Chấn Sơn Quyền` dùng nguyên lý impact ground/radial ring nhưng palette/geometry khác VFX-03; chưa tính là visual family thứ năm của G1. `Hộ Thể`, `Thổ Linh Thuẫn` về sau dùng material/shape defensive. Không invent tên skill game runtime mới.

### 7.3 Art direction VFX chung

- VFX là thông tin và phản hồi, không phải ánh sáng trang trí toàn màn. Một đòn phải có ba điểm dễ đọc: **người thi triển → đường tác động → đích**. AoE có cảnh báo thấp dưới chân, impact hiện đúng ground plane.
- Phân vai màu: Kim trắng ngà/vàng nhạt; Mộc xanh lá; Thủy lam xanh; Hỏa đỏ cam; Thổ vàng đất; các màu chỉ là đề xuất palette, phải thử tại scene Source A thực.
- Mạnh/yếu dựa hình học và thời gian, không chỉ tăng kích thước. Basic effect giảm chi tiết khi nhiều người dùng cùng kỹ năng.
- Bật audio/vibration phù hợp sau pilot; không cho animation hay âm thanh cập nhật HP.
- Mốc frame và duration là **tùy clip source và event**; không khóa một con số 12 FPS/30 FPS cho mọi actor. Nếu máy chậm, drop cosmetic frames, không kéo dài/sửa combat tick.

## 8. AI chiến đấu có độ thông minh vừa đủ, không làm MOBA AI

### 8.1 Target/position

- Cận chiến tiến tới **tầm đánh thật**, tránh đứng chồng lặp; trung/xa duy trì khoảng cách phù hợp skill profile.
- Chọn target theo điều kiện authored: gần nhất, nguy cơ đối với healer, Boss priority theo policy, execute threshold; tie-break ID ổn định. Khi mục tiêu chết hoặc mất hợp lệ, chọn lại theo authority.
- Nếu gặp vật cản: cần navigation/grid/path hợp lệ từ world data, không `lerp` qua đá chỉ để đẹp. Local pathfinding giản lược theo khu vực + direct steering, không tạo A* mới cho tất cả actor mọi frame.
- Support Y Đạo: heal chỉ với đồng đội **mất HP có thật**; buff/cleanse có điều kiện; không chữa người Bị Hạ bằng heal thường; revive chỉ nếu được author rõ ràng.

### 8.2 Skill-use

- Kiểm Active slot 1→4, mỗi skill phải ready, hợp lệ tầm/target/condition/caster không locked; không có skill dùng Thường Kỹ. Không spam vòng utility-scoring chung không xác định. Không tự động học kỹ năng bằng AI.
- Cooldown, cast time, internal cooldown, basic attack interval và projectile travel time là **năm khái niệm riêng**; motion speed chỉ trình diễn, không rút ngắn cooldown.
- Boss cảnh báo: AI có thể phản ứng bằng chạy bình thường theo **tốc độ authority**, hoặc dùng skill né đã học nếu được phép và đủ điều kiện trong packet riêng. **Không có 100% dodge miễn phí**. Accuracy/evasion là thiết kế tương lai, không hiển thị TRƯỢT/NÉ khi V2 chưa phát event hợp lệ.
- One active action tại mỗi thời điểm (trừ secondary effect được định nghĩa cụ thể). Bị interrupt/cancel phải có receipt từ authority.

### 8.3 Offscreen tương đương onscreen

Cụm hunting ngoài camera vẫn kết toán cùng số HP, vị trí sự kiện, kết quả, loot theo simulation. Không chạy actor animation/vfx cho đệ tử ngoài màn. Không hạ tần số simulation tùy zoom/thiết bị mà gây đổi kết quả. Có thể batch visual snapshot; **không batch damage theo FPS**.

## 9. Camera, điều khiển và HUD cho Android 1280×720

| Tương tác | Hành vi đề xuất | Ghi chú |
|---|---|---|
| Mở khu hunting | Camera free, vùng nhìn hợp lệ | Không auto-lock một actor |
| Kéo chuột trái trên đất/touch drag | Pan camera, hủy follow | UI panel bắt input riêng; không click-through |
| Tap/click vào actor không kéo | Select, mở thông tin gọn, tùy chọn follow | Actor hit-target riêng khác alpha sprite |
| Nút “Theo dõi” | Follow selected actor | Có nút thoát/hủy qua pan |
| Wheel/pinch | Zoom quanh vị trí con trỏ/tâm pinch | Clamp zoom/map bounds theo region |
| Tap vùng trống | Bỏ chọn hoặc giữ info theo UX contract | Không tác động combat targeting mặc định |
| Nút đội | Chuyển focus Squad, hiển thị 6 ô HP và status | Không mở full-screen nhiều lớp che chiến trường |

HUD tối giản: góc trái trên có tên region và trạng thái tự săn; góc phải thông tin đội đang chọn; dưới cùng 3–4 control lớn (đội, quay về, theo dõi, tốc độ xem nếu thật sự có authority). HP bar trên actor chỉ khi selected, đang combat gần camera, hoặc Boss; đừng hiển thị hàng trăm tên và hàng triệu số damage.

Camera và HUD **không phát lệnh tấn công khi drag/tap** trừ khi sau này user chọn chế độ điều khiển riêng có authority.

## 10. Hiệu năng — kế hoạch ngân sách, không phải PASS

**Target kiểm thử** (đề xuất, cần khóa sau profiler trên máy thật): Android phổ thông 30 FPS (frame time p95 ≤33.3 ms), máy khá 60 FPS (p95 ≤16.7 ms); cảnh thử 6v5+1 boss, sau đó 30v40 với camera pan và VFX đồng thời. Tránh chỉ báo FPS trung bình đẹp trong scene tĩnh.

### Những tối ưu quan trọng, theo thứ tự

1. Decode Source A/Spine ở **tool time**; runtime Godot dùng atlas/SpriteFrames hoặc modular rig đã tối ưu, không decode `.skel` hàng loạt khi đánh.
2. Texture cache theo asset ID, load async/prewarm vùng gần camera, evict an toàn khi chuyển vùng; không `load()`/tạo `ImageTexture` mỗi frame.
3. Atlas pages chia theo family và độ phân giải thực; 2048×2048 là giới hạn batch mẫu, **không coi tự động tối ưu RAM**. Tính *decoded VRAM* khi profile, không chỉ kích thước WebP nén.
4. Actor view culling + sprite LOD; chia sẻ material/animation, cache ghép outfit chữ ký xuất hiện; giảm render layers cho actor nhỏ xa.
5. VFX pool và cap draw: ưu tiên dấu skill chính/hit nguy hiểm/heal cứu người; cosmetic trails/particles bị cắt đầu tiên khi tải nặng. Không bỏ warning Boss chỉ vì cosmetic budget, vì nó mang thông tin gameplay.
6. Spatial query theo vùng/cell trong **future authorized simulation packet**, không duyệt 30×40×mọi frame để tìm tất cả mục tiêu; AI dùng event/tick.
7. UIs: gộp combat text, giảm nameplate overlap, không tạo hàng trăm Control node cập nhật mỗi frame.
8. Đo `CPU main`, `render`, draw calls, texture MB, frame spikes khi cast đồng loạt, thời gian mở map/đổi đội và bộ nhớ sau 10 phút combat; chỉ tối ưu theo profiler thay vì giả định nguyên nhân.

**Rủi ro trọng yếu:** transparency/overdraw của Spine/WebP; nhiều atlas bị chia quá nhỏ; quá nhiều layer cho 70 actor; FX overdraw; camera cập nhật redraw toàn map; shader compile spike; draw commands/sort toàn thế giới; animation time/authoritative time lệch. Không thể khẳng định đạt FPS trên Android khi chưa có thiết bị/log.

## 11. Lộ trình triển khai từng cổng — KHÔNG TỰ ĐỘNG CẤP QUYỀN CODE

### G0 — Kiểm chứng nguồn art và design feasibility (READ-ONLY, ưu tiên)

1. Đọc repo/head mới; Source A raw tại `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`; tool `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`; Godot-ready `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472`.
2. Từ ba đệ tử `1113028_1`, `body_1110201`, `body_1120402` chọn 1 rig; kiểm `.skel` có attack/hit/dead, tên clip/skin/attachment thật, không dựa CSV strings. Kiểm thêm một monster/boss Source A và một map combat art thật đủ viewport.
3. Phân loại asset `COMBAT_READY`, `LOCOMOTION_ONLY`, `ATTACHMENT_CANDIDATE`, `BLOCKED`; xuất contact sheet đúng frame gốc, clip/direction proof, metadata SHA, nguồn/đường dẫn.
4. Prototype appearance **chỉ kiểm toán** phương án skin swap/rig/attachment; xác định có thể đổi tóc/áo/vũ khí mà không rebake mọi tổ hợp hay không. Không chỉnh hoặc encode lậu original rig.
5. Nếu thiếu animation: báo thiếu chính xác asset/clip; đề xuất dùng một motion mẫu tự author trong G1 chỉ khi owner chấp thuận. Không tự gọi clip chế tác là `Source A verified`.

**Exit G0:** bộ chứng cứ một nhân vật / một quái / một map có sẵn hoặc ma trận blocker; phương án art & skin rõ ràng. G0 không đòi pilot combat kỹ thuật đã PASS.

### G1 — Visual combat pilot có thể nhìn và thử

- Trên nhánh riêng, theo CODE packet được phê duyệt: 6 đệ tử + 5 quái có một Boss; đúng Source A actor art, 4 VFX family, camera free/follow toggle, HP/status từ event thực; một clip combo kiếm, hỏa projectile, ấn trận, heal khi hợp lệ.
- Godot 4.7.2 1280×720 video/ảnh với source/hash, trace `cast → launch → hit`, thay outfit cho ít nhất **một** actor ở visual test nếu có art compatible; không yêu cầu 70 actor ngay.
- Không cho visual fixture thay thế dữ liệu gameplay thực trong bản chạy chấp nhận; nếu một kỹ năng V2 chỉ ở `design locked`, phải label `visual-only sandbox fixture` và không gắn vào live player.
- Gate: không có giả damage/loot; không sprite trôi khỏi foot/đứng trên mái; thông tin đủ nhìn trên điện thoại; p95 FPS đo thật, lỗi asset cụ thể được ghi.

### G2 — Multi-squad/world integration (CODE packet độc lập)

- Chuyển khỏi arena nhỏ/90s bằng **world/hunting authority migration có review**; không sửa save/RNG ngầm. Chạy 5 Squad/30 đệ tử + 40 quái; navigation, AI target, continuous hunting, offscreen parity, direct warehouse settlement.
- Tối ưu chunk/LOD/memory bằng số đo. Bảo đảm same combat outcomes view/no-view, pause/resume, save/load, exactly-once.
- Nếu accuracy/evasion/move speed bridge/dodge skill còn là DESIGN, làm các packet GP02/03/04 riêng, không vô tình đưa vào G2 như bugfix đồ họa.

### G3 — Nội dung và phong cách cá nhân hóa

- Mở rộng họ skill theo Nhân→Tiên→Thần, unique VFX hợp nhánh và Ngũ Hành; biến thể armor/weapon/tint ít tổ hợp hữu ích trước, không sản xuất vô hạn.
- Thêm boss/region, trạng thái nguy hiểm có audio, màu hiệu ứng thông minh, camera tiện ích; Android touch acceptance.

**QA policy:** focused tests và một màn native QA khi CODE packet được phê duyệt, không CI/FULL/merge mặc định trong vòng phát triển. G0 chỉ audit, không code.

## 12. Những quyết định còn mở cần G0 trả lời (không cần hỏi owner trước khi audit)

1. Rig Source A cụ thể nào có clip `attack/hit/dead` thực tế chạy được trên Godot? Có phù hợp actor 60–75 logical px không?
2. Các skin/attachment của Spine gốc có phân lập tóc/áo/weapon tương thích rig không, hay chỉ có full-sheet cố định?
3. Monster Source A có normal/elite/boss riêng đủ silhouette không? Loại hiệu ứng hit/reaction nào có art thật?
4. Art map săn quái Source A có địa hình/đường/occlusion đủ thật không, hay chỉ có nguồn art tông môn? Cần curate map visual độc lập?
5. Performance thiết bị mục tiêu: xác định Android SoC/RAM/GPU đại diện trước khi chốt texture/culling/LOD budgets, không tự gọi mọi Android là 60 FPS.
6. Một phiên hunting dài có cần tránh asset leak và texture thrash thế nào? Log p95/1% low/VRAM 10 phút khi có prototype.

## 13. Các lựa chọn tương lai cần quyết định sau G0

**Đề xuất A1 (ưu tiên):** tiếp tục Source A family cho tông môn và chiến đấu, chuyển có chọn lọc rig combat thật; modular shared rig cho đệ tử, prebaked cho quái cố định; VFX riêng trong Godot.

**Phương án A2 dự phòng:** Source A map/nhân vật + authored supplemental attack motion (ghi rõ `CUSTOM_V5`) cho các rig thiếu; không giả Source A original clip.

**Phương án B dự phòng có điều kiện:** nếu Source A không đủ clip combat/skin và G0 chứng minh JX1 có player/equipment pipeline tốt hơn, thử riêng JX1 pilot trước khi xin quyết định chuyển art family; **không ghép ngẫu nhiên JX1 player cùng Source A map trong một màn rồi tuyên bố đồng bộ**.

## 14. Handoff Codex — nhiệm vụ kế tiếp, READ-ONLY

> TÔNG MÔN BÁ ĐẠO — CHỈ KHẢO SÁT COMBAT V5-G0, KHÔNG CODE. Đọc `AGENTS.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`, `docs/P3_ART_BIBLE.md`, `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md` và tài liệu V5 này. Kiểm toán nguồn Source A trên Windows từ `E:\TongMonBaDaoWorkspace\02_SourceA\GameAssetExtract`, converter `E:\TongMonBaDaoWorkspace\04_Tools\SpineToGodot472`, các batch Godot-ready; ưu tiên 1 đệ tử + 1 quái/Boss + 1 map. Xác minh animation combat thật, slot/skin/attachment, hướng, anchor, quality và SHA; tạo catalog/contact sheet/evidence read-only từ công cụ có sẵn, không scan lại cả kho. Đề xuất cấu hình modular rig và 4 VFX family bám Combat Skills V2. Phân biệt `SOURCE_VERIFIED / STATIC_CANDIDATE / PENDING / CUSTOM_PROPOSED`. Không sửa gameplay, code, save, import scene, CI/FULL/merge, không báo Windows/Godot PASS khi chưa có runner và bằng chứng thật. Báo cáo blockers và kế hoạch G1 focused rõ file/allowlist, KHÔNG tự tiến sang G1.

## 15. Nguồn đối chiếu trong repo

- `AGENTS.md` — change contract/authority/QA.
- `docs/GAME_SYSTEM_ARCHITECTURE.md` — simulation vs presentation.
- `docs/COMBAT_SKILLS_V2_SPEC.md` — loadout, AI, skill families, target/element and evolutions.
- `docs/COMBAT_STATS_V2_SPEC.md` — stats existing authority; newer hit/evasion design remains pending migration.
- `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md` — owner requested future mechanics, not live.
- `docs/CULTIVATION_PATH_V2_SPEC.md` — one soft active path and branch, Đạo Lịch.
- `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` — sect-owned gear, canonical warehouse, no personal loot bag.
- `docs/P3_2_MODULAR_ACTOR_SPEC.md` — 9 bone, 11 render layers, 4 public directions, 128² registration.
- `docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md` — Source A Spine 3.8/Batch-01/tool evidence.
- `docs/P3_ART_BIBLE.md`, `docs/P3_PRESENTATION_MASTER.md` — art identity and consistency.
- `docs/C4_JX1_SOURCE_FIRST_WORLD_AND_FREE_CAMERA_2026-10-20.md` — owner correction keeps Combat V2 authority; no gameplay port from JX1.
- `godot/src/simulation/combat/map_battle_v2.gd` — STEP_SECONDS .25, current ARENA/90s, `continuous_world` capability; runtime truth requires live commit check.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd` — current snapshot rendering, interpolation, free camera, fallback JX/source atlas.

---

**Status cuối:** Đây là **DESIGN ONLY**, chưa có Godot screenshot mới, không có benchmark Android, không xác minh combat clip mới hay skin swap thật, không đóng bất cứ G0/G1/G2/G3 gate nào. Owner chưa chốt V5. Không tự merge tài liệu này vào repo nếu owner chưa yêu cầu.
