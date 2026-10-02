# P3.2 — Modular Disciple Map Actor Spec

Date: 2026-10-02
Status: IMPLEMENTED SCAFFOLD / AWAITING REAL GODOT 4.7.2 GATE

## 0. Mục tiêu

Map actor của đệ tử dùng kiến trúc **hybrid modular** để tránh phải vẽ một bộ animation hoàn chỉnh cho từng người.

Godot ghép các lớp hình ảnh cùng chung frame/animation. Đây chỉ là presentation. `DiscipleState`, AI, hành động, trang bị, công pháp, Huyết Mạch, Thể Chất và combat vẫn do simulation hiện tại làm authority.

Profile artwork lớn trong màn Đệ Tử là asset riêng, không phóng map actor lên làm portrait.

---

## 1. Nguyên tắc bắt buộc

1. Không tạo gameplay class mới chỉ để phục vụ art.
2. Sáu visual family ban đầu chỉ là template hình ảnh, **không phải Kiếm Tu/Pháp Tu/Thể Tu cố định trong simulation**.
3. Visual family phải chọn ổn định/deterministic để nhân vật không tự đổi thân hình chỉ vì XP đường tu thay đổi.
4. Trang bị/vũ khí về sau có thể phản ánh state thật nhưng actor không được ghi ngược gameplay state.
5. Tất cả layer animation của một actor dùng cùng clip, hướng và frame timeline.
6. Nếu asset production chưa có, actor phải có placeholder fallback thay vì crash/load resource thiếu.
7. P3.1/P3.2 vẫn `AWAITING REAL GODOT GATE`; scaffold này không được gọi PASS trước khi chạy máy Windows thật.

---

## 2. Sáu visual family đầu tiên

Canonical IDs:

- `male_sword`
- `female_sword`
- `male_spell`
- `female_spell`
- `male_body`
- `female_body`

Tên `sword/spell/body` ở đây mô tả **silhouette sản xuất asset**, không khóa đường tu gameplay.

Selection hiện tại:

- giới tính lấy từ `DiscipleState.sex_id` nếu đã có;
- legacy disciple chưa có `sex_id` dùng seed/id deterministic để chọn fallback;
- visual family `sword/spell/body` lấy deterministic từ `profile_seed` (hoặc id legacy), không lấy dominant path XP để tránh đổi ngoại hình theo thời gian.

Sau này outfit, weapon, accessory có thể phản ánh progression/state thật mà không thay base visual family.

---

## 3. Layer stack trong Godot

Từ dưới lên trên:

1. `shadow`
2. `weapon_back`
3. `body`
4. `outfit`
5. `hair`
6. `weapon_front`
7. `accessory`
8. `aura`

Status icon/name/action label là UI overlay, không baked vào sprite.

Tách `weapon_back` và `weapon_front` để kiếm/gậy có thể đi sau hoặc trước thân tùy hướng mà không phải tách tay/chân thành puppet nhỏ.

Không tách cơ thể thành bàn tay/cẳng chân riêng trong vertical slice. `body` là thân + tay + chân đã animate đồng bộ, giúp giữ cảm giác tranh vẽ tay.

---

## 4. Canvas và anchor asset

Map actor production target:

- mỗi frame nguồn: `128×128 px`, PNG alpha;
- logical map actor box: khoảng `86×82`;
- hiển thị ở scale khoảng `0.58` tại zoom map `1.0x`;
- điểm chân canonical trong frame nguồn: gần `(64, 104)`;
- mọi layer phải dùng cùng canvas, cùng điểm chân và cùng registration;
- không crop từng layer theo bounding box riêng;
- không bake shadow vào body/outfit.

Lý do: nếu từng layer crop khác nhau, tóc/áo/vũ khí sẽ rung và lệch frame khi Godot ghép.

---

## 5. Hướng animation

Canonical 4 hướng màn hình:

- `down`
- `right`
- `up`
- `left`

Tên animation:

`<clip>_<direction>`

Ví dụ:

- `idle_down`
- `walk_right`
- `mining_left`
- `cultivate_up`

Production mặc định vẽ đủ 4 hướng. Chỉ mirror `right <-> left` khi outfit/hair/weapon thật sự đối xứng; không mặc định mirror mọi asset.

---

## 6. Clip canonical và frame budget

| Clip | Mục đích | Frame gợi ý | FPS gợi ý |
|---|---|---:|---:|
| `idle` | đứng/chờ/quan sát | 4 | 6 |
| `walk` | đi trong map | 6 | 10 |
| `cultivate` | ngồi tu luyện/phá cảnh base | 6 | 6 |
| `work` | thao tác lao động chung/mua bán | 6 | 8 |
| `mining` | khai khoáng | 8 | 9 |
| `forging` | luyện khí | 8 | 9 |
| `rest` | nghỉ | 4 | 4 |
| `heal` | trị thương | 6 | 6 |
| `combat_ready` | trạng thái sẵn sàng chiến đấu | 4 | 8 |
| `leave` | chuẩn bị/xuất nhập Đại Môn | 6 | 10 |

Frame budget là production target, không phải gameplay timing authority.

---

## 7. Mapping simulation action -> visual clip

- `EVALUATE`, `IDLE`, `HOLD` -> `idle`
- `CULTIVATE`, `BREAKTHROUGH` -> `cultivate`
- `WORK_MINING` -> `mining`
- `WORK_FORGING` -> `forging`
- `SELL`, `BUY` -> `work`
- `REST` -> `rest`
- `HEAL` -> `heal`
- `COMBAT` -> `combat_ready`
- `HUNT`, `TRAVEL`, `LOOT`, `RETURN_SECT` -> `leave`

Khi actor thực sự tween giữa hai điểm map, presentation layer có thể override tạm clip thành `walk`; sau khi tới nơi quay về clip của `current_action`.

Không sửa `current_action` chỉ để chạy animation.

---

## 8. Folder/file contract

Asset production khi bắt đầu vẽ:

```text
godot/assets/p3/actors/
  shared/
    shadow/
  male_sword/
    body/
    outfit/
    hair/
    weapon_back/
    weapon_front/
    accessory/
    aura/
  female_sword/
  male_spell/
  female_spell/
  male_body/
  female_body/
```

SpriteFrames resource đề xuất:

```text
res://assets/p3/actors/<visual_family>/<layer>/<variant>.tres
```

Ví dụ:

```text
res://assets/p3/actors/female_spell/body/base_01.tres
res://assets/p3/actors/female_spell/hair/hair_03.tres
res://assets/p3/actors/female_spell/outfit/robe_02.tres
```

Tất cả `.tres` của các layer ghép với nhau phải tuân cùng animation naming + frame count cho clip tương ứng.

---

## 9. Code scaffold

- `DiscipleActorVisualCatalog`:
  - canonical visual families/layers/directions;
  - deterministic visual family resolver;
  - simulation-action -> clip mapping;
  - direction resolver.

- `ModularDiscipleActor`:
  - tạo 8 `AnimatedSprite2D` layer;
  - đồng bộ clip/hướng;
  - nhận `SpriteFrames` theo layer;
  - placeholder fallback khi chưa có art;
  - chỉ đọc disciple identity/action khi configure/sync;
  - không giữ gameplay progression song song.

- `p3_2_modular_actor_contract_test.gd`:
  - kiểm tra sáu visual family;
  - layer order;
  - deterministic family selection;
  - action mapping;
  - direction mapping;
  - actor không mutate `DiscipleState`.

Test mới **chưa nối vào cumulative launcher** cho tới khi chạy/parser-check thật trên Godot 4.7.2; không được làm current gate rủi ro hơn khi máy user đang không khả dụng.

---

## 10. Thứ tự sản xuất art

Không vẽ 6 family × toàn bộ animation ngay.

### Proof A — body registration

1. `male_sword/body/base_01`
2. `female_spell/body/base_01`
3. `idle_down` + `walk_down/right/up/left`
4. đưa vào Godot, đặt cạnh Đại Điện/Kho/Luyện Khí ở scale thật.

Khóa:

- chiều cao actor;
- tỷ lệ đầu/thân;
- điểm chân;
- readability ở `1.0x` và `0.75x` camera.

### Proof B — modular stacking

Thêm cho hai mẫu:

- 2 tóc;
- 2 outfit;
- 1 weapon;
- shadow.

Kiểm tra không rung/lệch registration qua toàn bộ walk cycle.

### Proof C — action set

Làm `cultivate`, `mining`, `forging`, `rest`, `heal` cho hai mẫu.

Sau khi PASS visual mới nhân ra 6 family.

---

## 11. Definition of ready-for-production

Modular actor architecture chỉ được coi là production-ready khi trên Godot thật:

1. actor scene/class instantiate không lỗi;
2. body/outfit/hair/weapon cùng frame không lệch registration;
3. clip đổi theo simulation action thật;
4. movement dùng walk mà không sửa simulation action;
5. click/focus disciple vẫn hoạt động;
6. zoom map không làm HUD thay đổi;
7. không có gameplay state mới trong actor;
8. P0-P3 cumulative regression vẫn green.
