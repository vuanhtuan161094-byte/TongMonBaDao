# P3.2 — female_normal_v1 Asset Production Checklist + Naming Contract

Date: 2026-10-03
Status: PRODUCTION CONTRACT — FEMALE VERTICAL SLICE

Tài liệu này khóa cách sản xuất asset cho `female_normal_v1` sau khi Character Creator V1 shared-rig scaffold đã PASS thật trên Godot 4.7.2.

Nguồn hình tham chiếu: 2 ảnh mẫu do user cung cấp ngày 2026-10-03.

- Ảnh turnaround nhiều góc là authority chính cho silhouette front/side/back, tóc dài, sừng, tà váy và continuity giữa các hướng.
- Ảnh front đơn là authority chính cho cảm giác mature chibi, khuôn mặt, tỷ lệ đầu-thân, độ nữ tính/quyến rũ nhẹ và độ gọn của outfit.
- Không copy pixel/chi tiết thừa từ ảnh mẫu vào runtime. Production phải giản lược để đọc rõ ở kích thước map actor.

Tài liệu này chi tiết hóa `docs/P3_2_MODULAR_ACTOR_SPEC.md` và `docs/P3_2_ASSET_MANIFEST.md`; không thay đổi gameplay authority.

---

# 1. Mục tiêu của vertical slice

Chứng minh một rig nữ dùng chung motion có thể tạo nhiều đệ tử khác nhau mà không phải làm animation riêng cho từng người.

Vertical slice cuối phải có:

- 1 body: `body_01`;
- 2 face: `face_01`, `face_02`;
- 3 hair: `hair_01`, `hair_02`, `hair_03`;
- 2 outfit: `outfit_01`, `outfit_02`;
- 2 weapon: `weapon_01`, `weapon_02`;
- 1 head accessory: `horn_01`;
- tối thiểu 3 hair tint preset;
- tối thiểu 3 outfit tint preset;
- shared idle + walk;
- ít nhất 6 tổ hợp ngoại hình cùng dùng `female_normal_v1` + cùng AnimationLibrary.

Không làm `male_normal_v1`, heavy rig hoặc asset volume lớn trước khi proof này đạt.

---

# 2. Style lock từ hai ảnh mẫu

`female_normal_v1` là **mature chibi**, không phải trẻ con và không phải tỷ lệ người thật.

Bắt buộc giữ cảm giác:

- đầu lớn vừa phải, compact body;
- eo gọn, hông mềm, chân tương đối dài so với chibi thường;
- tóc đen/nâu đen rất dài, khối tóc là một silhouette chính;
- sừng cong đen là head accessory riêng;
- mắt đỏ nâu;
- outfit tiên hiệp/demoness đen + vàng đồng;
- vai/ngực có độ mở vừa phải, quyến rũ nhẹ nhưng tasteful;
- tay áo và tà váy có độ rủ;
- xẻ tà giúp chân còn đọc được ở map scale;
- giày/sandal dây quấn thuộc outfit;
- silhouette sạch, ít micro-detail.

Được giản lược:

- hoa văn vàng li ti;
- nhiều dây/charm nhỏ;
- lọn tóc cực mảnh;
- đường viền nhỏ hơn 1–2 px sau khi export 128×128;
- chi tiết không còn đọc được ở zoom 0.75x.

Không được giản lược mất:

- tóc dài;
- sừng;
- tỷ lệ đầu-thân mature chibi;
- xẻ tà / khoảng chân đọc được;
- tương phản đen-vàng;
- silhouette nữ rõ.

---

# 3. Registration contract — tuyệt đối không drift

Runtime asset bắt buộc:

- PNG RGBA có alpha;
- canvas đúng `128×128`;
- source foot anchor đúng `(64,104)`;
- trục cơ thể chuẩn đi qua `x = 64`;
- không auto-crop theo bounding box;
- không recenter từng mảnh sau khi tách;
- không đổi canvas giữa body/hair/outfit/face/horn/weapon;
- không để nền xanh chroma trong runtime PNG;
- không bake bóng nền vào body/outfit/hair.

**Mọi cutout đều giữ nguyên full canvas 128×128.**

Ví dụ tay trái chỉ chiếm một vùng nhỏ nhưng file `body_01_down_arm_l.png` vẫn là 128×128 và tay nằm đúng tọa độ gốc của master view. Không crop riêng cánh tay rồi đưa tâm ảnh về giữa.

Nếu artist làm source ở 4× để dễ vẽ:

- working canvas được phép `512×512`;
- mọi pivot/registration nhân đúng 4;
- export runtime phải downsample đúng về `128×128`;
- foot anchor source 4× tương ứng `(256,416)`;
- không thay đổi framing khi downsample.

---

# 4. Direction contract

Public direction luôn là:

- `down` = nhìn chính diện / front;
- `right` = profile nhìn sang phải / side;
- `up` = nhìn từ sau / back;
- `left` = public direction riêng nhưng V1 được phép mirror từ `right`.

Vertical slice đầu **chỉ cần authored master art cho 3 hướng**:

1. `down`;
2. `right`;
3. `up`.

Không vẽ `left` riêng khi toàn variant đang dùng được mirror.

Nếu sau này variant bất đối xứng không mirror-safe, mới bổ sung file `left` authored cho riêng variant đó.

Ảnh 3/4 front/back:

- dùng để kiểm form, tóc, ngực/eo/hông, tà váy và sừng;
- không phải runtime direction V1;
- không xuất thành animation direction.

---

# 5. Master-view production checklist

Trước khi tách layer, phải có một master model nhất quán cho 3 hướng.

## 5.1. Master `down`

Phải khóa:

- hai sừng cùng vị trí tương đối trên đầu;
- khuôn mặt và đường mắt;
- tóc mái + side locks;
- vai, cổ, ngực, eo, hông;
- hai tay buông tự nhiên;
- xẻ tà để chân vẫn đọc được;
- hai chân không dính thành một khối;
- sandal/giày còn silhouette ở 128×128;
- tà váy không che sạch chuyển động chân;
- foot anchor của cả hai chân quy về đường đất `y=104`.

## 5.2. Master `right`

Phải khóa:

- đúng profile đầu/mặt;
- độ dày khối tóc;
- một sừng chính và sừng phía xa vẫn hợp lý;
- ngực/eo/hông nhìn nghiêng;
- tay trước/tay sau không nhập khối hoàn toàn;
- chân trước/chân sau còn phân biệt được;
- tà váy tạo khoảng âm để walk readable;
- foot anchor không đổi so với front.

## 5.3. Master `up`

Phải khóa:

- hai sừng nhìn từ sau;
- hair mass là silhouette chính nhưng không che toàn bộ chân;
- back outfit/tà sau;
- hai tay vẫn đọc được;
- gót/giày đọc được;
- hoa văn lưng/tà chỉ giữ motif lớn;
- không có mắt/mặt front bị leak qua tóc.

## 5.4. Consistency gate trước khi split

Không tách asset nếu còn một trong các lỗi:

- chiều cao đầu khác nhau giữa 3 hướng;
- vai/hông nhảy vị trí rõ;
- sừng đổi kích thước hoặc đổi gốc;
- tóc side ngắn/dài không hợp với front/back;
- tà váy front/side/back không thể là cùng một bộ đồ;
- chân ở 3 hướng không chạm cùng foot registration;
- profile side nhìn như một character khác.

---

# 6. Runtime folder contract

Canonical root:

```text
godot/assets/p3/character_creator/
  shared/
    shadow/
    shaders/
  rigs/
    female_normal_v1/
      rig.tscn
      rig_manifest.tres
      animations/
        female_normal_v1_animation_library.tres
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
```

Hiện repo chưa cần tạo thư mục rỗng chỉ để đủ cây. Thư mục được tạo khi asset đầu tiên tương ứng tồn tại.

---

# 7. Global naming rules

Tất cả ID:

- lowercase;
- snake_case;
- không dấu;
- không khoảng trắng;
- không version suffix ở từng cosmetic variant;
- version chỉ nằm ở rig ID: `female_normal_v1`.

Variant ID:

- `body_01`;
- `face_01`;
- `hair_01`;
- `outfit_01`;
- `horn_01`;
- `weapon_01`.

Runtime cutout file:

```text
<variant>_<direction>_<piece>.png
```

Ví dụ:

```text
body_01_down_torso.png
body_01_right_arm_r.png
hair_02_up_back.png
outfit_01_down_arm_l.png
horn_01_right_main.png
weapon_01_up_main.png
```

Tint mask dùng đúng base filename + suffix:

```text
<variant>_<direction>_<piece>_tint_mask.png
```

Ví dụ:

```text
hair_02_down_back_tint_mask.png
outfit_01_right_torso_tint_mask.png
```

Không dùng các tên kiểu:

- `final.png`;
- `new2.png`;
- `left_fixed.png`;
- `girl_blackdress.png`;
- `hair_final_final.png`.

---

# 8. Anatomical naming rule

`l` / `r` luôn chỉ **trái/phải của nhân vật**, không phải trái/phải trên màn hình.

Ví dụ:

- `arm_l` = tay trái của nhân vật;
- `arm_r` = tay phải của nhân vật;
- `leg_l` = chân trái của nhân vật;
- `leg_r` = chân phải của nhân vật.

Quy tắc này giữ nguyên ở `down`, `right`, `up` và cả khi mirror sang `left`.

Không đổi tên anatomical piece chỉ vì nó xuất hiện bên trái/phải màn hình.

---

# 9. `body_01` production contract

`body_01` là base anatomy/skin, không chứa tóc, sừng hoặc quần áo chính.

Coarse pieces bắt buộc:

- `head`;
- `torso`;
- `arm_l`;
- `arm_r`;
- `leg_l`;
- `leg_r`.

Mỗi piece authored cho:

- `down`;
- `right`;
- `up`.

Expected files:

```text
body_01_down_head.png
body_01_down_torso.png
body_01_down_arm_l.png
body_01_down_arm_r.png
body_01_down_leg_l.png
body_01_down_leg_r.png

body_01_right_head.png
body_01_right_torso.png
body_01_right_arm_l.png
body_01_right_arm_r.png
body_01_right_leg_l.png
body_01_right_leg_r.png

body_01_up_head.png
body_01_up_torso.png
body_01_up_arm_l.png
body_01_up_arm_r.png
body_01_up_leg_l.png
body_01_up_leg_r.png
```

Body được phép có overlap dưới outfit để tránh hở khe khi bone xoay.

Không cắt sát mép quần áo đến mức walk/idle tạo lỗ thủng da.

---

# 10. `face_01..02` production contract

Face là expression/feature overlay gắn với `head`.

Piece duy nhất:

- `main`.

Bắt buộc authored:

- `down`;
- `right`.

`up` không có khuôn mặt nhìn thấy và **không được fallback sang face front**. Runtime manifest/loader về sau phải hide face ở `up`.

Expected files mỗi face:

```text
face_01_down_main.png
face_01_right_main.png

face_02_down_main.png
face_02_right_main.png
```

Không tách riêng mắt trái/mắt phải/mũi/miệng trong V1.

Không bake mái tóc vào face.

---

# 11. `hair_01..03` production contract

Mỗi hair variant tối thiểu gồm:

- `back`;
- `front`.

`back` chứa:

- khối tóc sau đầu;
- tóc dài sau lưng;
- các lọn nằm phía sau thân.

`front` chứa:

- mái;
- side bangs;
- lọn tóc phủ trước mặt/ngực nếu có.

Bắt buộc authored 3 hướng:

- `down`;
- `right`;
- `up`.

Expected pattern:

```text
hair_01_down_back.png
hair_01_down_front.png
hair_01_right_back.png
hair_01_right_front.png
hair_01_up_back.png
hair_01_up_front.png
```

Nếu một direction thực sự không cần `front`, file `front` có thể bỏ và manifest đánh dấu hidden; không tạo PNG rỗng chỉ để đủ số lượng.

### Tint mask

Hair tint mask chỉ bao vùng tóc được đổi màu.

Không mask:

- da;
- mắt;
- sừng;
- khuyên tai/kim loại;
- ornament vàng.

Mask phải cùng full canvas/registration với base texture.

---

# 12. `outfit_01..02` production contract

Outfit là một lựa chọn public nhưng nội bộ là coarse cutout bundle.

Piece set V1:

- `torso`;
- `arm_l`;
- `arm_r`;
- `leg_l`;
- `leg_r`;
- `drape_back`;
- `drape_front`.

Ý nghĩa:

- `torso`: bodice/cổ áo/đai eo/phần váy gắn thân;
- `arm_l`, `arm_r`: tay áo + phần trang phục đi theo tay;
- `leg_l`, `leg_r`: giày/sandal + phần outfit phải đi cùng chân;
- `drape_back`: tà sau hoặc phần phải đứng sau chân;
- `drape_front`: tà trước hoặc phần phủ trước chân.

Bắt buộc authored 3 hướng:

- `down`;
- `right`;
- `up`.

Naming pattern:

```text
outfit_01_down_torso.png
outfit_01_down_arm_l.png
outfit_01_down_arm_r.png
outfit_01_down_leg_l.png
outfit_01_down_leg_r.png
outfit_01_down_drape_back.png
outfit_01_down_drape_front.png
```

Tương tự cho `right` và `up`, rồi `outfit_02`.

### Outfit tint mask

Chỉ mask vùng vải được phép recolor.

Không mask:

- da;
- vàng đồng/kim loại;
- đá/gem;
- mắt;
- tóc;
- sừng;
- phần footwear kim loại nếu không muốn đổi màu.

Nếu một mảnh không có vùng tint, không cần file mask cho mảnh đó.

---

# 13. `horn_01` production contract

Public slot: `head_accessory`.

Piece V1:

- `main` = cả cặp sừng.

Bắt buộc authored:

- `down`;
- `right`;
- `up`.

Expected files:

```text
horn_01_down_main.png
horn_01_right_main.png
horn_01_up_main.png
```

Không bake sừng vào tóc.

Không tách horn trái/phải ở V1 trừ khi art proof chứng minh cần thiết.

`horn_01` mặc định không tint trong vertical slice đầu.

---

# 14. `weapon_01..02` production contract

Weapon visual gắn `hand_weapon`; nó không tự equip gameplay item.

Base pattern:

```text
weapon_01_down_main.png
weapon_01_right_main.png
weapon_01_up_main.png
```

Render-pass metadata theo direction:

- `down`: ưu tiên `front`;
- `up`: ưu tiên `back`;
- `right`: `front`, `back` hoặc `split` tùy silhouette;
- `left`: lấy rule của `right` khi mirror-safe.

Nếu weapon cần split thật:

```text
weapon_02_right_back.png
weapon_02_right_front.png
```

Không nhét chữ `front/back` vào file nếu weapon chỉ có một component `main`; pass là metadata, không phải variant ID mới.

Weapon art phải chịu được mirror. Nếu có chữ/logo/kết cấu một chiều hoặc tay cầm bất đối xứng gây sai khi mirror, variant đó phải đánh dấu authored-left về sau.

---

# 15. Shared shadow

Shadow không thuộc appearance variant.

Path target:

```text
godot/assets/p3/character_creator/shared/shadow/shadow_01.png
```

Rule:

- full canvas `128×128`;
- ellipse mềm dưới chân;
- tâm bám foot anchor;
- không đổi theo hair/outfit;
- không bake vào body/outfit.

---

# 16. Tint palette V1

Catalog hiện có hair tint preset:

- `2b2624`;
- `5b3a2e`;
- `b89a63`.

Outfit tint preset:

- `45675f`;
- `7a3f37`;
- `455472`.

Vertical slice phải dùng đúng các preset này trước để prove pipeline; đổi palette sau là balance/art tuning riêng.

Reference demoness black/gold vẫn có thể dùng base texture đen/nâu đen. Tint mask phải giữ shading/highlight, không biến texture thành flat-color silhouette.

---

# 17. Source/master layer organization

Artist không vẽ từng PNG runtime từ đầu. Một master view phải có layer/group tương ứng piece IDs để batch export.

Ví dụ source tree `down`:

```text
DOWN
  body
    head
    torso
    arm_l
    arm_r
    leg_l
    leg_r
  face
    face_01
    face_02
  hair
    hair_01
      back
      front
  outfit
    outfit_01
      drape_back
      torso
      arm_l
      arm_r
      leg_l
      leg_r
      drape_front
  head_accessory
    horn_01
  weapon
    weapon_01
```

`right` và `up` dùng cùng group IDs.

Layer source phải giữ registration gốc; không move layer để export đẹp hơn.

---

# 18. Production order — không làm asset volume ngay

## Stage A — Pivot-lock sample

Chỉ cần một appearance baseline:

- `body_01`;
- `face_01`;
- `hair_01`;
- `outfit_01`;
- `horn_01`;
- chưa cần `weapon_02`, `hair_02/03`, `outfit_02`.

Mục tiêu:

- gắn vào shared rig;
- nhìn rest pose `down/right/up`;
- chỉnh practical bone pivots nếu art chứng minh scaffold hiện tại cần tune;
- không đổi bone IDs/hierarchy;
- giữ `(64,104)` registration.

Current scaffold bone positions chỉ là starting point; exact art pivots chỉ được khóa sau Stage A.

## Stage B — Shared motion proof

Dùng chính Stage A appearance để làm:

- idle;
- walk;
- public `down/right/up/left`;
- left mirror từ right.

Chỉ cần motion sạch trước, chưa cần 6 appearance.

## Stage C — Modular variant proof

Sau khi pivot + motion ổn mới thêm:

- `face_02`;
- `hair_02`, `hair_03`;
- `outfit_02`;
- `weapon_01`, `weapon_02`;
- tint masks;
- 6 combination proof.

## Stage D — Map-scale proof

Quan sát ít nhất ở:

- zoom `0.75`;
- zoom `1.0`;
- zoom `1.35`.

Không integrate live map trước khi Stage D đạt.

---

# 19. Export checklist cho từng PNG

Mỗi runtime PNG phải PASS tất cả:

- [ ] đúng 128×128;
- [ ] RGBA alpha sạch;
- [ ] không nền xanh/chroma fringe;
- [ ] không auto-crop;
- [ ] foot registration không đổi;
- [ ] piece nằm đúng tọa độ master;
- [ ] file name đúng contract;
- [ ] direction đúng `down/right/up/left`;
- [ ] anatomical `l/r` đúng theo nhân vật;
- [ ] không bake layer khác vào nhầm piece;
- [ ] không có watermark/text;
- [ ] không có micro-detail gây noise ở map scale;
- [ ] nếu có tint mask, mask khớp pixel registration với base;
- [ ] mask không ăn vào skin/metal/face ngoài ý muốn;
- [ ] edge alpha không có viền xanh;
- [ ] visual vẫn đọc được khi scale xuống 0.68.

---

# 20. Mirror-safe checklist

Variant chỉ được dùng mirror-right-to-left nếu:

- [ ] không có chữ/logo;
- [ ] không có ornament bắt buộc ở một bên canonical;
- [ ] không có vết sẹo/mắt đặc biệt một bên cần giữ;
- [ ] weapon không sai tay/cấu trúc khi mirror;
- [ ] hair asymmetry không tạo lỗi nhận diện;
- [ ] outfit asymmetry không làm logic trang phục vô lý;
- [ ] front/back render pass không đổi sai khi mirror.

Nếu FAIL bất kỳ mục nào, variant cần authored `left` riêng về sau.

---

# 21. Readability gate ở kích thước game

Không duyệt asset chỉ bằng ảnh phóng to.

Mỗi baseline/variant phải nhìn ở map scale thật:

## Zoom 0.75

Phải còn phân biệt được:

- tóc dài;
- sừng;
- silhouette outfit;
- hướng nhân vật;
- weapon chính nếu có.

## Zoom 1.0

Phải đọc được:

- hair variant;
- outfit variant;
- face mass/eyes ở mức hợp lý;
- chân/tà váy không nhập một khối;
- black/gold contrast không thành noise.

## Zoom 1.35

Không được lộ lỗi:

- layer drift;
- khe hở vai/hông;
- outline double;
- mask lệch;
- weapon xuyên tay;
- horn không bám đầu;
- face lệch hair/head.

---

# 22. Acceptance gate của asset set

`female_normal_v1` asset set chỉ đủ điều kiện sang visual-slice Godot gate khi:

- [ ] Stage A baseline gắn rig không drift;
- [ ] practical pivots đã được khóa từ art thật;
- [ ] idle/walk dùng chung một AnimationLibrary;
- [ ] `left` mirror không phá baseline;
- [ ] 2 face hoạt động;
- [ ] 3 hair hoạt động;
- [ ] 2 outfit hoạt động;
- [ ] 2 weapon hoạt động;
- [ ] `horn_01` tắt/bật độc lập tóc;
- [ ] hair tint không đổi face/skin/horn;
- [ ] outfit tint không đổi skin/metal;
- [ ] có ít nhất 6 combination cùng chạy;
- [ ] cả 6 cùng dùng một rig/motion library;
- [ ] zoom 0.75/1.0/1.35 đều readable;
- [ ] missing optional component không crash;
- [ ] presentation không mutate `DiscipleState`.

Chỉ sau gate này mới được tích hợp `ModularDiscipleActor` vào live sect map.

---

# 23. Không làm trong bước này

- không vẽ male rig;
- không mass-generate hàng chục tóc/áo;
- không thêm eye/finger/shoe bone;
- không thêm physics hair/skirt;
- không làm cultivate/mining/forging/heal/rest trước idle/walk proof;
- không nối appearance persistence vào generator;
- không đổi gameplay equipment chỉ vì weapon visual;
- không tạo spritesheet/video riêng cho từng combination;
- không dùng profile portrait phóng nhỏ làm map actor;
- không gọi production vertical slice PASS chỉ vì asset nhìn đẹp ngoài Godot.

---

# 24. Next concrete action

Sau khi contract này được khóa, việc tiếp theo là **Stage A — Pivot-lock sample**:

1. dựng một master `female_normal_v1` baseline từ hai ảnh user đã cung cấp;
2. authored 3 master views: `down`, `right`, `up`;
3. giữ canvas/registration tuyệt đối;
4. export `body_01 + face_01 + hair_01 + outfit_01 + horn_01` theo naming contract;
5. gắn vào scaffold Godot;
6. khóa practical pivots bằng hình thật;
7. sau đó mới author idle/walk.
