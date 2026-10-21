# TÔNG MÔN BÁ ĐẠO — FOUR ZIP EVIDENCE REVIEW / NEXT CODEX WORK (2026-10-21)

**STATUS:** checkpoint tài liệu. Đã mở trực tiếp và kiểm tra ZIP CRC và SHA-256 cho bốn gói; không có code/gameplay nào được merge. Bổ sung, không thay thế, file TMB_PAUSE_RESUME_PRIORITY_B23_2026-10-21.md.

## Quyết định: 1 chính + 1 phụ; V5.1 và Character V2 giữ nguyên

1. **P0 B2.4 CODE**: hoàn thành một sandbox hunting loop có thể chạy/quan sát bằng Godot, real Editor GUI QA và kiểm soát per-kill ledger, chưa phát hành loot production.
2. **P1 SA-LIB phụ**: refresh current converter fingerprint và chuyển Spine từng batch khi RAM/disk đạt gate, không chạy song song với Godot B2.4.
3. **P2 V5.1 HOLD**: giữ thành quả, bảo quản nhánh dirty, chờ manual UI và owner visual review; không thay Combat V2.
4. **P3 Character V2 HOLD**: addon đã có 8 ảnh GUI thật, chỉ phát triển pack/catalog bridge sau khi có pack SA-LIB QA hiện hành.

## Ma trận theo gói đã đọc

| ZIP | SHA-256 | Đã có bằng chứng | Gap và Git |
|---|---|---|---|
| B2.3 Studio Runtime | f9a934abbc9aa8712296447c466897ef686f27720caddcd2a32b736a9b12408e | 72 entries; 7 focused/regression PASS; editor schema v2/UndoRedo; independent spawn/per-kill/ledger, 30v40×160, snapshot, rollback | Editor **manual GUI PENDING**; default per-kill production table EMPTY; synthetic DoT only; cloned sandbox, no SaveService/live payout. feature/b2-3-spawn-loot-runtime-pilot HEAD 461caca + **5 tracked modified, 24 untracked**, uncommitted. |
| Source A Library | 080c1bc2479f77614a941a096056f75161bf248a2c4ce6af98b0f61d6050b979 | 6,578 indexed rig/20,507 files; 5,328 SOURCE READY/1,250 REVIEW; 10 historical QA PASS; catalog/CLI/resume/2 sample packs | **0 current-converter QA PASS**; 5 Godot processes+1,359 MiB RAM gate stopped work, skin path untested. Branch sa-lib-01-sourcea-spine-library-20261021 @ 87d6b60; 66 detailed metadata chunks LOCAL ONLY, previous GitHub upload was refused, do not retry without separate destination authorization. |
| Combat V5.1 | 9c57d930492343388594e0543aadd588793223b61ded285b506852219e5c7294 | 1280×720 before/after, 32 frames, Source A view/camera/shadow improved; focused 8 actors/5 skills PASS | Owner visual PENDING; reset Button.pressed verified but real mouse click unverified; Android/stress pending. feature/v5-1-sourcea-visual-finalization still **dirty**, HEAD ae3f397c is prior V5, not committed V5.1. |
| Character Studio V2 | 719d1a00f844c87ccae0b26c56feab4cf3610bbe377a52904c2ea75ef7abe9d2 | 7 rig (6 verified, 1 unverified), 42 clip cells (22 verified, 2 unverified, 18 missing), eight actual Editor GUI frames, focused PASS | female base 1113028_1 scene/animation mismatch; 0 verified outfits; some role/skill/stats DESIGN-ONLY. feature/dev-character-studio-v2 local commit 18bf8929, not pushed; unrelated dirty .ps1 not changed. |

**Chú ý mâu thuẫn QA:** B2.3 GP-02C1 PASS là trên checkout riêng, không xóa ba regression FAIL đã tái hiện ở base V5 và V5 (One Active Job, hunting UI smoke, T15_PLANT). Phải so test SHA/fixture/runner trước khi kết luận regression đã sửa.

## Next Codex tasks — chính xác theo trạng thái mới

**CODEX 01 — RUN FIRST: B2.4 sandbox end-to-end.** Bảo toàn toàn bộ dirty+untracked B2.3; tạo scene/launcher sandbox, một runtime tick owner, nhìn thấy per-slot respawn/kill+receipt/warehouse clone và restart; GUI mouse drag/dock test nếu có công cụ; seeded test-only drop, production per-kill table vẫn empty; no live SaveService, no main merge. Bàn giao TMB_B2_4_HUNT_LOOP_REVIEW.zip.

**CODEX 02 — RUN WHEN SAFE: Source A.** Check Run-SourceA-Library.cmd status, giữ RAM >=2,200MiB + disk >=5GiB; không tự kill process. Refresh fingerprint old rigs, test skin-on-demand Godot import, batch 10–25 per checkpoint, 1,250 source REVIEW phân loại. Không upload 66 metadata chunks. Bàn giao TMB_SALIB_CURRENT_QA_BATCH_REVIEW.zip.

**CODEX 03 — HOLD: V5.1.** Backup dirty, chuẩn bị clean scoped commit khi được phép; chứng minh manual reset camera click; chỉ xử lý nameplate/Boss overlay nếu owner cần, giữ sprite overlap tự nhiên có distinct foot shadow/position. No owner visual PASS without owner. Bàn giao TMB_V5_1_CLEAN_VISUAL_GATE_REVIEW.zip.

**CODEX 04 — HOLD: Character V2.** Sau approved SA-LIB current-fingerprint pack, kiểm end-to-end pack import, hash, dependencies, lazy search, selected clip/skin preview, female mismatched hash provenance. Không tạo converter thứ hai, không giả trang phục. Bàn giao TMB_CHARACTER_STUDIO_PACK_BRIDGE_REVIEW.zip.

## Invariant & documentation

Godot 4.7.2, Android landscape 1280×720, Source A visual, Combat V2 authority, One Active Job, Injury 0/1/120 tick, Tu Vi/Luyện Thể 30×10, single Warehouse, exactly-once/save, 6/party, 30v40 battle. B3 rare/drop/gear numeric values remain DESIGN/OPEN. Natural sprite overlap allowed if true foot/shadow locations are distinguishable. Use focused tests; no automatic FULL/CI/merge.

Full prompts + next-chat instructions are in the user download artifact **TMB_NEXT_CODEX_PROMPTS_2026-10-21.zip**, SHA-256 577a0e8ffe44956e2758e5ab119a8eb245c880401c191da5244fd41e8f4f2d4. That conversation ZIP is **not** stored on GitHub. User can share it in a new chat if needed.

**Next chat:** read AGENTS.md, this file and the previous pause/resume checkpoint; fetch live HEAD/check ZIP changes; focus B2.4 now, SA-LIB safe batches later, do not open V5/Character heavy work simultaneously. Every Codex session must return one evidence ZIP with diff, all untracked, SHA, logs, GUI proof when appropriate and Markdown checkpoint.
