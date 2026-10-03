# P3 — SOURCE RECOVERY LOG

Date: 2026-10-03
Status: RECOVERY ATTEMPT LOG / DO NOT REPEAT BLIND SEARCHES

## 0. Mục đích

Ghi lại **đã tìm ở đâu, tìm được gì, không tìm được gì** khi phục hồi source presentation cũ.

File này không quyết định art canon. Canon nằm ở:

- `P3_PRESENTATION_MASTER.md`;
- `P3_ASSET_REGISTRY.json`;
- `P3_SOURCE_RECOVERY_MANIFEST.md`;
- MD từng hạng mục.

---

# 1. Kết quả Git history

Đã kiểm live `main` và lịch sử Git giai đoạn 2026-09-25 → 2026-10-04.

Kết quả:

- `godot/assets` không có commit lịch sử trong giai đoạn này;
- top-level `assets` không có commit lịch sử trong giai đoạn này;
- snapshot tree cuối 2026-09-30 không chứa cây asset/building source;
- `source_art/` hiện chỉ có `README.md`.

**Kết luận:** 8 building approved source không thể phục hồi exact bytes từ Git history hiện có.

Không lặp lại việc đào `godot/assets`/`assets` cho cùng giai đoạn trừ khi có bằng chứng mới về một path khác.

---

# 2. Approved building conversation locator

Prior-conversation recovery tìm được locator lịch sử:

- Conversation Group: project `Tông Môn Bá Đạo`;
- thời gian chính: **2026-10-01 khoảng 22:00 UTC**;
- user xác nhận một nhóm ảnh đã chấp nhận;
- nhóm đầu được ghi nhận gồm:
  - Tông Môn Đại Điện;
  - Phòng Ốc / Đệ Tử Xá;
  - Luyện Khí Đường;
  - Kho;
  - UI quản lý Phòng Ốc;
- sau đó user xác nhận canonical building set đủ 8:
  - Tông Môn Đại Điện;
  - Đệ Tử Xá / Phòng Ốc;
  - Tu Luyện Đài;
  - Kho;
  - Luyện Khí Đường;
  - Dược Phòng;
  - Khu Khai Khoáng;
  - Tông Môn Đại Môn.

Không phục hồi được:

- image ID;
- attachment ID;
- filename;
- image URL;
- sandbox path;
- checksum.

**Source class vẫn là S3.** Conversation timestamp chỉ là recovery locator, không phải exact source locator.

---

# 3. V3 main-map mood locator

Current project conversation ngày 2026-10-03:

- khoảng **11:42–11:46 UTC**;
- user đã duyệt plan V3 trước khi tạo ảnh;
- sau ảnh V3, user nói thích asset/mood này hơn bản trước;
- direction được khóa: sáng hơn, hand-painted, parchment/jade, map-first.

Không phục hồi được durable image ID/file locator từ available file/library search.

**Source class vẫn là S3.** Written visual authority được giữ trong `P3_ART_BIBLE.md` và `P3_UI_SKIN_AND_ICONOGRAPHY.md`.

---

# 4. Historical path grid 128

Đã tìm:

- live Git tree;
- Git history phổ biến cho asset paths;
- available conversation/library context;
- source-recovery prior-chat context.

Chỉ phục hồi được fact lịch sử rằng từng có dirt/stone path pack theo **grid 128**, nhiều PNG/atlas.

Không phục hồi được:

- pack filename;
- atlas filename;
- image IDs;
- checksum;
- exact chat locator.

**Source class vẫn là S3.** Không regenerate rồi gọi là exact historical pack.

---

# 5. Exact source đã phục hồi/định danh được

`female_normal_v1` Stage A diagnostic pack:

- filename: `female_normal_v1_stageA_runtime_pack_v2_quant.zip`;
- size: `44,838` bytes;
- SHA-256: `6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca`;
- source class: **S1**.

Đây là exact diagnostic/runtime proof pack, không phải editable art master.

---

# 6. Library / file search caution

Available Library contains nhiều file generic tên `image-gen-*.png`. Semantic search cho game/building trả nhiều false positive từ các dự án khác.

Không được chọn một file chỉ vì:

- tên `image-gen-*` giống;
- màu/perspective gần giống;
- search score cao.

Candidate chỉ được nâng thành canonical khi đối chiếu được approval history hoặc user xác nhận đúng ảnh.

---

# 7. Recovery action khi user có máy

Ưu tiên tìm local exact source theo thứ tự:

1. Downloads / Pictures / thư mục ChatGPT exports quanh 2026-10-01;
2. file ảnh từng lưu từ Conversation Group khoảng 22:00 UTC;
3. path/atlas pack grid-128 nếu từng tải về;
4. nếu tìm thấy candidate, **không đổi tên/xử lý trước**;
5. tính SHA-256, lưu kích thước pixel/file size;
6. user xác nhận visual identity;
7. sau đó mới ingest vào `source_art/p3/...` khi source-art transport workflow được chốt.

---

# 8. Recovery gate hiện tại

P0 source recovery status:

- 8 buildings: **historical locator recovered; exact bytes not recovered**;
- V3 mood: **conversation locator recovered; exact bytes not recovered**;
- path grid 128: **historical existence only; exact locator not recovered**.

Do đó không có asset nào trong ba nhóm trên được nâng từ S3 lên S2/S1/S0 ở lượt này.

Điều này không chặn wireframe/layout work, nhưng **chặn việc gọi một newly generated building là canonical replacement của asset cũ**.
