# AS-CHAR-49 — HANDOFF sang chat mới sau V9 (2026-11-16)

**Đây là checkpoint nguồn/thực tế, KHÔNG phải nghiệm thu 24/24.** Draft PR #72, chỉ nhánh `integration/pve-p0-playable-ui-20261103`. HEAD ngay trước tạo tài liệu `60a77c250f5cc7b2dbc03a268c3420ee979c057e`; chat mới **phải kiểm tra HEAD mới nhất trước khi làm**.

## Nguồn bàn giao xác minh bytes

1. **Gói chính V9** nằm trong ChatGPT Library: `/TMB-Character-Art/AS_CHAR49_V9_CAST_HIT_FOUR_DIR_CANDIDATE_20261116.zip`. SHA256 `9939b1363d0c8d706f1d3f728ebbc18f6748528ce7253dbad6c2d88dcec8e9e8`, 99,652,900 bytes, **405 entries**, CRC PASS khi kiểm tra lại.
2. **Gói death-source + hướng dẫn chat mới**: `/TMB-Character-Art/AS_CHAR49_DEATH_SOURCES_NEW_CHAT_HANDOFF_20261116.zip`. SHA256 `2581573b6a5639f686df073fbd8818caa15ddc8fedec6313d90d1bd6c0f27ea9`, 4,777,209 bytes, **17 entries**, CRC PASS. Chứa `HANDOFF_START_HERE.md`, `PROVENANCE_SHA256.json`, bốn GIF gốc, một GIF rejected, 4 ref PNG, hình QA, manifest và QA_V9 copy. Nguồn GIF cũ đã được chuyển đuôi `.png` → `.gif` theo **magic GIF89a** mà không sửa bytes.
3. Tài liệu trước đó: `docs/animation/AS_CHAR49_V9_CAST_HIT_FOUR_DIRECTION_EXPORT_20261116.md`; nữ art authority `docs/animation/TMB_KIEM_TU_FEMALE_ART_DIRECTION_AND_PIPELINE_20261114.md`; `AGENTS.md`; Issue #77.

## Trạng thái verified

- `20/24` **technical candidate clips**, **0/24 Godot/production owner-approved**. Idle ×4 (4 frame mỗi hướng); Walk ×4 (8); Attack ×4 (8); Cast ×4 (8); Hit ×4 (8). Tổng **144 PNG RGBA 512², 20 atlas, 20 GIF + 20 APNG**, Godot lab source, HTML review, 24-slot manifest. Re-run `tools/verify_v9.py` thực tế: `PASS V9: 20 clips, 144 frame SHA/alpha/atlases and 40 animated preview probes; 4 Death missing`.
- **Attack 4-view source đã được owner duyệt về hình ảnh**, KHÔNG là full motion/production approval.
- **Death_Front/Right/Back/Left CHƯA ĐẠT**. Bốn GIF 32 frame nguyên bản thực ra là 4 biến thể của chuỗi ngã chứ không phải 4 hướng. Một nguồn từ sau tương đối đúng, vài nguồn nghiêng trước/phải dùng làm ứng viên sau khi kiểm chứng. **Front thực sự và Left thực sự chưa có clip đạt**. GIF mới 8 frame góc trước `chibi_swordswoman_s_dazed_recovery_animation.png` bị loại do **tự đứng dậy ở cuối**, không được dùng làm Death.
- **Cast_Right F5/F6; Cast_Back F4; Hit_Left F3** có VFX/chi tiết chạm biên ô source, art clipping vẫn mở. Có vài frame Attack chạm biên mũi kiếm. Kỹ thuật PASS không đồng nghĩa mỹ thuật PASS.
- Original female four-direction APNG master raw materialization chưa khả dụng; identity/source SHA unverified. Godot **4.7.2 executable không có tại nơi bàn giao**, engine/native capture **NOT_RUN**. Offline video không phải Godot.
- Trong lượt trước nhiều request imagegen ngã/ngất bị chặn nhầm; một lần tạo 8-frame front lại **đứng dậy**, không đạt. Không nên thử vô hạn; giữ source/quy trình có kiểm soát.

## Trình tự đúng cho chat mới

1. Verify PR #72 HEAD, V9 ZIP SHA, death handoff ZIP SHA và từng GIF magic/frame count; đọc `HANDOFF_START_HERE.md`.
2. Sản xuất đúng **Death/Unconscious** không máu me: đứng → mất thăng bằng → khuỵu → nằm **giữ tư thế cuối**. Phải có Front/Right/Back/Left **độc lập**; **không lật/mirror hoặc đổi nhãn 32-frame single-fall**. Kiểm tra game-size 75/150/225 px, 512×512 RGBA, chân (256,442), vũ khí bạc lam gắn trong sprite, tóc tím/hoa lam trắng.
3. **Chỉ khi 4 hướng đúng** xuất 4 GIF/APNG/atlas/PNG, hợp nhất với **20 clip thật từ V9**, QA SHA/atlas/direction/motion, sửa Cast/Hit clipping, tạo V10 ZIP/preview/manifest.
4. Godot 4.7.2 GUI 1280×720 native QA **nếu engine có sẵn**; không bịa native test/owner approval. Giao link file và báo số candidate và approved **riêng**.
5. **Không rig, Codex, branch, merge, gameplay, Combat V2, SaveService, PvE, V6.3, economy, production actor integration**. Người dùng chỉ dùng ChatGPT; không yêu cầu họ chạy Krita/Aseprite.

**Handoff complete ≠ animation complete.** Zip nguồn nằm trong Library, chỉ checkpoint này được đưa lên GitHub.