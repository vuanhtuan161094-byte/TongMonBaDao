# P3.2 — Character Creator V1 + Shared 2D Rig Contract

Date: 2026-10-03
Status: SCAFFOLD IMPLEMENTATION / AWAITING REAL GODOT 4.7.2 GATE

## 0. Quyết định canonical

Hướng cũ `mỗi visual family = nhiều AnimatedSprite2D/SpriteFrames chạy song song` bị thay thế bởi:

**CHARACTER CREATOR = modular appearance + shared 2D rig/animation.**

Mục tiêu là một số rig cơ bản dùng chung chuyển động, còn tóc/mặt/trang phục/vũ khí/phụ kiện được đổi độc lập. Hàng chục/hàng trăm đệ tử không cần hàng chục/hàng trăm bộ animation hoàn chỉnh.

Đây vẫn chỉ là presentation identity:

- `SimulationState`/`DiscipleState` giữ gameplay authority;
- actor không được tự tạo cảnh giới, chỉ số, trang bị hay action giả;
- actor không được ghi ngược `current_action` chỉ để đổi animation;
- map actor và portrait/profile artwork là hai pipeline khác nhau;
- profile artwork lớn không được tạo bằng cách phóng map actor.

P3.1/P3.2 vẫn **AWAITING REAL GODOT GATE**. Scaffold Character Creator không làm thay đổi trạng thái gate đó.

---

# 1. Rig V1

Canonical rig IDs ban đầu:

- `female_normal_v1`
- `male_normal_v1`

Chưa sản xuất `heavy` hoặc body đặc biệt cho tới khi normal rig chạy thật và khóa registration.

Body type/gender là lựa chọn người chơi có thể nhìn thấy, nhưng phải tôn trọng identity gameplay:

- `sex_id` của một đệ tử đã sinh vẫn là identity canonical;
- cosmetic editor thường không được silently đổi `sex_id`;
- `rig_id` mặc định được resolve từ `sex_id + body_type`;
- nếu sau này có custom-character creation cho phép chọn giới tính từ đầu, lựa chọn đó phải đi qua character-generation/state authority chứ không phải một biến UI riêng.

---

# 2. Canvas/frame chuẩn của map actor

Nguồn art cho tất cả component của rig V1 dùng chung registration canvas:

- source canvas: **128 × 128 px**, PNG alpha;
- source foot anchor: **(64, 104)**;
- mọi component/cutout export giữ nguyên 128×128, không crop theo bounding box;
- trục nhân vật đi qua x = 64;
- vùng silhouette chính nên nằm khoảng y = 8..104;
- bóng có thể xuống thấp hơn chân nhưng phải còn trong canvas;
- vũ khí/phụ kiện được phép vươn rộng hơn thân nhưng không vượt canvas nếu có thể tránh.

Lý do giữ full canvas cho từng cutout: mỗi mảnh có cùng hệ tọa độ, nên khi gắn vào bone có thể tính offset registration chính xác và không rung/lệch giữa các variant.

---

# 3. Anchor chân và kích thước thật trên map 1280×720

`CharacterRoot` đặt theo **điểm chân**, không theo tâm texture.

Canonical:

- source foot anchor: `(64, 104)`;
- map actor control box scaffold: khoảng `88 × 92` logical px;
- foot trong control box: khoảng `(44, 72)`;
- source-to-map scale ở map zoom `1.0x`: **0.68**;
- silhouette thân mục tiêu ở zoom `1.0x`: khoảng **64–70 logical px** từ đỉnh đầu đến chân;
- toàn bộ actor kể cả tóc/vũ khí nên đọc được trong khoảng **60–75 px** cảm nhận thị giác.

Camera vẫn có zoom `0.75x -> 1.80x`, nên ở toàn cảnh actor có thể nhỏ hơn 60 px; con số 60–75 px là target tại map zoom `1.0x`.

Hit/focus area không phụ thuộc alpha texture. Tap target phải đủ rộng cho mobile dù sprite gầy.

---

# 4. 4 hướng canonical

Public direction contract luôn là:

- `down`
- `right`
- `up`
- `left`

Tên animation public:

`<clip>_<direction>`

Ví dụ:

- `idle_down`
- `walk_right`
- `walk_up`
- `walk_left`

V1 cho phép `left` dùng animation/motion của `right` rồi mirror toàn rig khi asset được đánh dấu mirror-safe. Tuy nhiên public contract vẫn có `left` để code/gameplay không biết bên dưới là mirror hay authored.

Asset bất đối xứng có thể opt-out mirror và cung cấp left-authored sau này.

---

# 5. Rig nội bộ và cosmetic layer

## 5.1. Bone nội bộ

Bone không phải lựa chọn Character Creator. V1 dùng bộ xương thô, đủ để tạo walk/idle có sức sống nhưng không biến asset pipeline thành puppet quá vụn.

Canonical bones:

1. `root`
2. `pelvis`
3. `torso`
4. `head`
5. `arm_l`
6. `arm_r`
7. `hand_weapon`
8. `leg_l`
9. `leg_r`

Không tạo bone cho mắt trái/mắt phải/bàn tay từng ngón/giày riêng trong V1.

## 5.2. Cosmetic/public choices

Người chơi nhìn thấy các lựa chọn:

- body type / giới tính;
- face;
- hair;
- hair tint;
- outfit;
- outfit tint;
- horn/head accessory;
- weapon visual;
- accessory;
- aura.

Canonical render layers từ sau ra trước:

1. `shadow`
2. `aura` (back pass mặc định; aura có thể có front sub-pass nội bộ về sau)
3. `hair_back`
4. `weapon_back`
5. `body`
6. `outfit`
7. `face`
8. `hair_front`
9. `head_accessory`
10. `weapon_front`
11. `accessory`

Body/Outfit là **một lựa chọn** trong creator, nhưng file production có thể là một coarse bundle gồm các cutout tương ứng `head/torso/arm_l/arm_r/leg_l/leg_r`. Đây là chi tiết rig nội bộ; người chơi không chọn từng tay/chân.

---

# 6. Layer order / z-index

Canonical z-index scaffold:

| Layer | z |
| --- | ---: |
| shadow | -100 |
| aura | -80 |
| hair_back | -30 |
| weapon_back | -20 |
| body | 0 |
| outfit | 10 |
| face | 20 |
| hair_front | 30 |
| head_accessory | 40 |
| weapon_front | 50 |
| accessory | 60 |

Nếu một aura cần hạt sáng đi trước người, variant aura có thể có front pass nội bộ ở z > 60 nhưng public slot vẫn chỉ là `aura`.

---

# 7. Kiến trúc Godot

V1 dùng:

```text
ModularDiscipleActor (Control)
├─ VisualRoot (Node2D)              # đặt tại foot anchor, scale 0.68
│  ├─ RigRoot (Node2D)              # nơi xử lý mirror left/right
│  │  └─ Skeleton2D
│  │     └─ Bone2D hierarchy
│  └─ AnimationPlayer               # duy nhất cho actor
├─ ActorButton                       # hit target độc lập alpha
└─ StatusLabel                       # UI presentation
```

**Không dùng 11 AnimatedSprite2D chạy timeline riêng.**

Animation chung tác động vào transform của `Bone2D`. Cosmetic bundle chỉ thay texture/cutout gắn lên các bone/socket tương ứng.

V1 ưu tiên **coarse cutout rig** thay vì mesh deformation phức tạp vì:

- actor chỉ khoảng 60–75 px;
- dễ thay outfit/tóc;
- ít lỗi weight/mesh;
- dễ sản xuất bằng layered artwork;
- dễ debug registration;
- đủ đẹp cho mobile map actor.

Nếu sau này cần váy/tay áo mềm hơn, một số variant có thể dùng `Polygon2D` skinned nội bộ mà không đổi public Character Creator contract.

---

# 8. Shared AnimationPlayer / AnimationLibrary

Mỗi rig dùng **một shared AnimationLibrary**. Các instance nhân vật không tự sở hữu animation riêng.

Target path animation chỉ trỏ tới các bone có tên canonical, nên mọi appearance variant của cùng rig dùng chung motion.

Clip V1 bắt buộc:

- `idle_down/right/up/left`
- `walk_down/right/up/left`

Clip scaffold hỗ trợ sẵn cho phase tiếp theo:

- `cultivate_*`
- `work_*`
- `combat_ready_*`
- `mining_*`
- `forging_*`
- `heal_*`
- `rest_*`
- `leave_*`

AnimationLibrary chỉ là presentation timing. Simulation action/tick không bị animation điều khiển ngược.

---

# 9. LEFT/RIGHT mirror contract

Default V1:

- authored motion: `down`, `right`, `up`;
- public `left` resolve sang `right` motion + `RigRoot.scale.x = -1` nếu rig/variant mirror-safe;
- `facing` của actor vẫn là `left`, không đổi thành `right` trong state.

Không mirror mặc định nếu:

- tóc có chi tiết một bên quan trọng;
- outfit có logo/túi/hoa văn bất đối xứng cần giữ bên;
- vũ khí/phụ kiện cần đúng tay/cấu trúc;
- variant manifest đặt `left_mode = authored`.

Vertical slice đầu tiên được phép dùng mirror-safe để giảm asset production, nhưng architecture phải giữ đường nâng cấp sang authored-left.

---

# 10. Folder/file naming

Canonical root mới:

```text
godot/assets/p3/character_creator/
  shared/
    shadow/
    shaders/
  rigs/
    female_normal_v1/
      rig.tscn
      animations/
        female_normal_v1_animation_library.tres
      rig_manifest.tres
    male_normal_v1/
      ...
  parts/
    female_normal_v1/
      body/
        body_01/
      face/
        face_01/
        face_02/
      hair/
        hair_01/
        hair_02/
        hair_03/
      outfit/
        outfit_01/
        outfit_02/
      head_accessory/
        horn_01/
      weapon/
        weapon_01/
        weapon_02/
      accessory/
      aura/
    male_normal_v1/
      ...
```

Variant IDs dùng snake_case, version suffix chỉ nằm ở rig (`female_normal_v1`), không nhét version vào mọi texture.

Coarse cutout file trong một bundle dùng mẫu:

`<variant>_<direction>_<piece>.png`

Ví dụ:

- `outfit_01_down_torso.png`
- `outfit_01_right_arm_l.png`
- `hair_02_up_back.png`
- `weapon_01_right_main.png`

Mọi PNG vẫn giữ canvas 128×128 và foot registration chung.

---

# 11. Appearance schema trong SimulationState

Không tạo `CharacterCreatorState` UI riêng làm authority.

Canonical appearance payload khi persistence được nối:

```gdscript
appearance_profile = {
    "version": 1,
    "rig_id": "female_normal_v1",
    "body_id": "body_01",
    "face_id": "face_01",
    "hair_id": "hair_02",
    "hair_tint": "5b3a2e",
    "outfit_id": "outfit_01",
    "outfit_tint": "45675f",
    "head_accessory_id": "horn_01",
    "weapon_id": "weapon_01",
    "accessory_id": "",
    "aura_id": ""
}
```

Rules:

- payload thuộc `DiscipleState`/SimulationState persistence, không thuộc UI node;
- default appearance có thể derive deterministic từ `profile_seed + sex_id` để legacy/current disciple luôn có hình ổn định;
- chỉ lưu override khi cần, tránh reroll mỗi load;
- color lưu dạng RGB hex để JSON/save ổn định;
- unknown key bị bỏ qua ở presentation normalizer;
- missing/invalid variant rơi về default an toàn;
- appearance không cộng stat, không đổi quality, không đổi action;
- weapon visual là presentation; khi production equipment mapping đã có, renderer phải ưu tiên visual từ `equipped_items` thật hoặc explicit skin rule, không được giả là đang trang bị món gameplay khác.

Để giảm rủi ro khi P3.1/P3.2 gate còn chưa chạy thật, scaffold hiện tại **chưa sửa locked simulation generator** chỉ để sinh appearance. Việc nối `appearance_profile` vào save/generation phải có persistence contract test riêng trước khi nhập cumulative gate.

---

# 12. Tint tóc / áo

Không tint toàn sprite bằng `modulate` nếu texture có da/kim loại/hoa văn nhiều màu.

Production rule:

- hair/outfit variant có base texture + tint mask;
- một shader/material dùng mask để thay màu vùng được phép;
- shading/highlight gốc vẫn giữ;
- face/body skin không nhận hair/outfit tint;
- tint mặc định `ffffff` hoặc palette canonical của variant;
- vertical slice chỉ cần vài preset tint trước, custom color wheel để sau.

Fallback nếu variant chưa có tint mask: hiển thị base color, không phá texture.

---

# 13. Weapon back/front theo hướng

Một `weapon_id` có metadata theo direction:

- `back`: render ở `weapon_back`;
- `front`: render ở `weapon_front`;
- `split`: variant có cả back + front component.

Default sword/staff rule gợi ý V1:

- `down`: front;
- `right`: front hoặc split tùy weapon;
- `up`: back;
- `left`: dùng rule của right sau mirror nếu mirror-safe.

Weapon gắn vào `hand_weapon` socket của rig. Đổi direction chỉ đổi render pass/socket transform presentation, không equip/unequip gameplay item.

---

# 14. Fallback khi thiếu asset

Thứ tự fail-safe:

1. rig invalid -> resolve lại từ canonical `sex_id`, cuối cùng về normal rig;
2. body missing -> hiện placeholder actor hiện tại, không crash;
3. optional face/hair/outfit missing -> default variant cùng rig;
4. optional head accessory/accessory/aura missing -> ẩn layer;
5. authored-left missing -> mirror-right nếu variant mirror-safe;
6. animation clip missing -> cùng clip `down` -> `idle_<direction>` -> `idle_down`;
7. tint mask missing -> base color;
8. weapon front/back component missing -> dùng component còn lại nếu manifest cho phép, nếu không ẩn weapon visual.

Không bao giờ vì thiếu art mà sửa `DiscipleState.current_action`, equipment hay gameplay identity.

---

# 15. Contract tests bắt buộc

`p3_2_modular_actor_contract_test.gd` phải chứng minh tối thiểu:

1. canonical rig IDs chỉ có `female_normal_v1`, `male_normal_v1` ở V1;
2. source canvas/foot anchor/scale không drift;
3. 9 bone IDs và parent hierarchy ổn định;
4. public 11 render layers + z-order ổn định;
5. action -> clip mapping không đổi gameplay;
6. 4-direction resolver đúng;
7. left mirror resolve đúng mà public facing vẫn là left;
8. appearance fallback deterministic từ persisted identity;
9. invalid appearance profile normalize về default;
10. actor tạo đúng một `Skeleton2D` và một `AnimationPlayer`;
11. actor scaffold không tạo `AnimatedSprite2D` timeline-per-layer;
12. configure/sync presentation không mutate `DiscipleState`;
13. missing art vẫn ở placeholder mode;
14. persistence test riêng phải được thêm trước khi `appearance_profile` được nối vào generator/save authority.

Test Character Creator chưa được thêm vào `Sync-P3-2-Camera.cmd` cho tới khi parser/headless test được chạy thật trên Godot 4.7.2.

---

# 16. Vertical slice tối thiểu

Chỉ sản xuất **female_normal_v1** trước để chứng minh pipeline:

- 1 body: `body_01`;
- 2 face: `face_01..02`;
- 3 hair: `hair_01..03`;
- 2 outfit: `outfit_01..02`;
- 2 weapon: `weapon_01..02`;
- 1 head accessory/horn: `horn_01`;
- accessory/aura có thể để empty ở proof đầu;
- tối thiểu 3 hair tint + 3 outfit tint;
- shared `idle` + `walk` đủ public 4 hướng.

Proof cần tạo ít nhất 6 tổ hợp ngoại hình trên cùng một rig, chạy cạnh nhau, rồi kiểm tra:

- tất cả cùng foot anchor;
- đầu/tóc/mặt không trượt;
- outfit không lệch tay/chân;
- weapon không xuyên sai lớp rõ rệt;
- đổi tint không nhuộm da/mặt;
- left mirror không làm layer order sai;
- 6 actor dùng cùng AnimationLibrary;
- click/focus vẫn đúng;
- ở zoom `1.0x` silhouette đọc rõ, ở `0.75x` vẫn phân biệt tóc/áo/vũ khí chính.

Chỉ sau proof này mới nhân sang `male_normal_v1`, rồi mới cân nhắc heavy/special body type.

---

# 17. Không làm trước khi rig contract chạy thật

- không generate hàng loạt character art;
- không làm 6 visual family sword/spell/body như spec cũ;
- không tách Grok từng face/hair/body rồi cố ghép bằng tay;
- không làm video/spritesheet hoàn chỉnh riêng cho từng đệ tử;
- không thêm body type mới;
- không đưa test scaffold vào cumulative launcher khi chưa chạy Godot thật;
- không gọi P3.1/P3.2/Character Creator PASS chỉ bằng static review.

Video/Grok chỉ được dùng làm motion reference/prototype nếu hữu ích. Pipeline production cuối là shared rig + modular appearance.
