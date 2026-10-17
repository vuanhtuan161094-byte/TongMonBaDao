# P3 — PRESENTATION SOURCE RECOVERY MANIFEST

## 2026-10-17 — Source A actor pilot newly ingested

`actor.source_a.1113028_1.map_pilot` is now **S0 repo source candidate** at `godot/assets/actors/1113028_1/`, copied from `E:\TongMonBaDaoWorkspace\05_DauRa\Assets_Godot472\1113028_1`. Its `asset.json` SHA-256 is `daecefdc454883b8613fa2ec8361be1c80b2ddcc162b4aceff84618306e4a637`; that manifest includes hashes of the four Godot resource/atlas files and the three original Spine inputs. Batch-01 technical QA and the focused Windows in-scene stand/walk gate pass. The selected MAP25 visual, roof overlap, owner approval, Android behavior and redistribution rights outside this personal project remain **pending**. This pilot does not replace the approved `female_normal_v1` modular identity or change the S3 recovery status of historical building art.

---

Date: 2026-10-03
Status: CANONICAL SOURCE-AVAILABILITY INVENTORY

## 0. Mục đích

File này trả lời một câu hỏi rất cụ thể:

> **Asset presentation đã được duyệt hoặc đang dùng làm chuẩn hiện có file nguồn thật ở đâu, và có thể lấy lại chính xác hay không?**

Nó không thay `P3_ASSET_REGISTRY.json`, Art Bible hay MD hạng mục.

- `P3_ASSET_REGISTRY.json` = trạng thái máy đọc được.
- file này = inventory/phục hồi source dễ đọc cho người và AI.
- `P3_SOURCE_RECOVERY_LOG.md` = lịch sử đã tìm ở đâu / kết quả gì để không lặp search mù.
- MD hạng mục = art/UX contract chi tiết.

Không được coi `visual approved` đồng nghĩa với `source file đã được bảo quản`.

---

# 1. Evidence classes

| Class | Nghĩa | Được phép làm gì |
|---|---|---|
| **S0 — Repo canonical** | Có exact source bytes ở repo/source-art hoặc LFS; path xác định | Dùng trực tiếp làm source/reference canonical |
| **S1 — Exact external pack** | Exact pack/file ngoài repo nhưng biết tên + checksum/kích thước đủ để xác minh | Có thể phục hồi nguyên byte nếu còn pack đúng checksum |
| **S2 — Persistent external file** | Exact file có locator bền vững trong Library/project storage, nhưng chưa ingest repo | Có thể dùng trực tiếp và sau đó ingest |
| **S3 — Historical approved identity** | Biết asset/reference nào đã được user duyệt, nhưng exact file bytes hiện chưa xác định/recover được | Giữ design/visual authority; **không tự generate asset thay thế rồi gọi đó là source cũ** |
| **S4 — Design only / production pending** | Chỉ có contract/hướng art, chưa có approved exact source | Được sản xuất mới sau plan + user approval |

Nếu source được phục hồi/ingest, cập nhật class lên S2/S1/S0 tương ứng.

---

# 2. Snapshot hiện tại

## A. Công trình — visual đã duyệt, source bytes cần phục hồi

Historical conversation locator đã phục hồi:

- project conversation group `Tông Môn Bá Đạo`;
- khoảng **2026-10-01 22:00 UTC**;
- user xác nhận bộ building family, sau đó khóa đủ 8 building canonical.

Không có exact image ID/filename/URL/attachment/checksum trong recovered context. Git history cũng không chứa building source bytes.

| Asset ID | Tên | Visual | Source class | Exact source hiện có? | Hành động |
|---|---|---|---|---|---|
| `building.sect_main_hall` | Tông Môn Đại Điện | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.disciple_quarters` | Đệ Tử Xá / Phòng Ốc | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.cultivation_platform` | Tu Luyện Đài | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.storage` | Kho | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.forge` | Luyện Khí Đường | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.medicine_hall` | Dược Phòng | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.mining_area` | Khu Khai Khoáng | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |
| `building.sect_gate` | Tông Môn Đại Môn | Approved | S3 | Không | Phục hồi đúng ảnh đã duyệt; sau đó ingest |

**Kết luận:** building family là visual authority thật, nhưng repo hiện không có canonical bytes. Cho tới khi phục hồi, mockup không được redesign các building này. Nếu exact source không có trong session, dùng placeholder/silhouette theo contract thay vì bịa một “bản chuẩn mới”.

---

## B. Map / terrain / environment

| Asset ID | Hạng mục | Trạng thái | Source class | Ghi chú |
|---|---|---|---|---|
| `environment.terrain_base` | Base terrain | Design approved | S4 | Pipeline đã khóa, chưa xác nhận exact approved source bytes |
| `environment.path_grid128` | Dirt/stone path grid 128 | Historical production existed | S3 | Từng có pack/atlas, nhưng exact file và exact chat locator chưa phục hồi |
| `environment.water_stream` | Water/stream | Design approved | S4 | Chưa có canonical exact source trong repo |
| `environment.deco_vegetation` | Trees/rocks/deco | Design approved | S4 | Chưa có canonical production set |

**Kết luận:** path pack cần phục hồi trước khi regenerate. Terrain/water/deco có thể sản xuất mới sau plan vì hiện chỉ có design contract, chưa có exact approved source được xác nhận.

---

## C. UI / UX visual source

V3 conversation locator đã phục hồi ở current project chat:

- khoảng **2026-10-03 11:42–11:46 UTC**;
- plan V3 được user duyệt trước generation;
- sau generation, user xác nhận thích asset/mood này hơn bản trước.

Exact image ID/file locator hiện chưa durable/recover được.

| Asset ID | Hạng mục | Visual | Source class | Hành động |
|---|---|---|---|---|
| `ui.main_map.v3_mood` | V3 main-map mood reference | Approved mood | S3 | Exact generated image chưa được ingest; giữ conversation locator + written mood authority |
| `ui.skin.production_set` | Panel/button/tab/icon runtime family | Pending | S4 | Sản xuất mới theo `P3_UI_SKIN_AND_ICONOGRAPHY.md` sau plan |

V3 chỉ là **mood/layout reference**, không thay building source và không phải bộ runtime 9-slice/icon hoàn chỉnh.

---

## D. Character / actor

| Asset ID | Hạng mục | Visual/runtime | Source class | Source xác minh |
|---|---|---|---|---|
| `actor.female_normal_v1.reference_turnaround` | Approved style/turnaround reference | Reference approved | S3 | Historical user reference; exact durable source chưa ingest |
| `actor.female_normal_v1.reference_front` | Approved front/body-style reference | Reference approved | S3 | Historical user reference; exact durable source chưa ingest |
| `actor.female_normal_v1.stage_a.down` | Stage A down/front | Visual approved + FAST green | **S1** | `female_normal_v1_stageA_runtime_pack_v2_quant.zip`, 44,838 bytes, SHA-256 `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca` |
| `actor.female_normal_v1.stage_a.right_up` | Stage A right/up | Visual/runtime pending | **S1** | Cùng exact pack/checksum phía trên |

Stage A ZIP là diagnostic/runtime proof pack, **không thay editable production master**. Sau khi pipeline source-art được chốt, final editable masters vẫn cần ingest riêng.

---

# 3. Source recovery priority

Không phải mọi source thiếu đều cần phục hồi ngay.

### P0 — cần trước Mockup V3 production

1. 8 building approved sources — historical conversation locator đã có, exact bytes còn thiếu;
2. V3 mood reference exact image — conversation locator đã có, exact bytes còn thiếu;
3. historical path grid 128 pack — exact locator/bytes còn thiếu.

### P1 — cần trước runtime art production rộng

4. female_normal_v1 approved input references;
5. terrain/water/deco source set sau khi user duyệt production;
6. UI skin/icon production source masters.

### P2 — archive sau

7. rejected/superseded mockups chỉ giữ nếu cần audit/history.

---

# 4. Quy tắc phục hồi source

Khi tìm thấy candidate source:

1. **không tự coi là canonical** chỉ vì hình giống;
2. đối chiếu với approval history/MD hạng mục;
3. nếu user xác nhận đúng source, cập nhật registry + file này;
4. nếu có exact bytes, ghi filename/path + SHA-256;
5. khi Git LFS workflow được Windows xác minh, ingest editable master vào `source_art/p3/...`;
6. runtime export vào `godot/assets/p3/...` và giữ import metadata theo Godot production policy.

Không overwrite lịch sử bằng regenerated lookalike.

Chi tiết search/recovery attempt xem `docs/P3_SOURCE_RECOVERY_LOG.md`.

---

# 5. Naming target khi ingest

```text
source_art/p3/buildings/sect_main_hall/<master>
source_art/p3/buildings/disciple_quarters/<master>
source_art/p3/buildings/cultivation_platform/<master>
source_art/p3/buildings/storage/<master>
source_art/p3/buildings/forge/<master>
source_art/p3/buildings/medicine_hall/<master>
source_art/p3/buildings/mining_area/<master>
source_art/p3/buildings/sect_gate/<master>

source_art/p3/environment/terrain/
source_art/p3/environment/path/
source_art/p3/environment/water/
source_art/p3/environment/deco/

source_art/p3/characters/female_normal_v1/
source_art/p3/ui/
```

Filename cụ thể chỉ khóa sau khi source thật được phục hồi; không đoán tên file cũ.

---

# 6. Definition of Done — Bước 1 khóa source presentation

Bước 1 được coi là **hoàn thành về inventory/authority** khi:

- mọi nhóm presentation chính có record trong registry;
- asset visual-approved nhưng thiếu exact source được ghi rõ là `missing/recovery required`;
- external pack exact có checksum;
- source chưa sản xuất được phân biệt khỏi source bị thất lạc;
- recovery priority rõ;
- không còn trường hợp `external_reference` mơ hồ khiến AI tưởng exact file đang tồn tại;
- CI static audit kiểm được quy tắc trên.

**Bước 1 hoàn thành không có nghĩa mọi binary source đã được phục hồi.** Nó có nghĩa repo biết chính xác cái gì đang có, cái gì thất lạc, cái gì chưa sản xuất và phải làm gì tiếp theo.
