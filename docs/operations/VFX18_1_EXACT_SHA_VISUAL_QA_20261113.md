# VFX18.1 LightCore2D — báo cáo Godot QA + kiểm tra mỹ thuật thực tế, 13/11/2026

**PR #72** `integration/pve-p0-playable-ui-20261103` · Chỉ Combat Lab · Không Codex · Không merge · Không tích hợp PvE khi chủ dự án chưa duyệt.

## Quy trình và căn cứ
- Tự áp dụng skill chuyên trách `.agents/skills/tmb-vfx-art-director/SKILL.md` (TMB Project Copilot v0.2.0) và tài liệu nghiên cứu `VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md`.
- Art brief viết **trước** code: [`VFX18_1_ART_BRIEF_AND_STORYBOARD_20261113.md`](VFX18_1_ART_BRIEF_AND_STORYBOARD_20261113.md) trên commit `a03eb170ea7537e4e94cdda88879c3db070304f2`.
- Mục tiêu: kiếm khí là ánh sáng, không vẽ thân/chỏm kim loại; kiếm trận 16 vệt ánh sáng bất đối xứng, hai lớp trước–sau nhân vật; chỉ một mock-target tiếp xúc trong single, không hit nào trong orbit. Cả hai chỉ là diễn hoạt đồ họa trong Lab.
- Source JX, Source VL, Source A chỉ phục vụ nghiên cứu; **không copy bản quyền kỹ năng**. Godot shader original + 4×4 procedurally white Sprite2D carrier.

## Source code thay đổi trong lượt này
- `godot/labs/combat_lab/research03/research03_arena.gd`: tụ khí 5 dải cong động hội tụ, vệt đuôi sáng mờ dần theo history, 5 tia vỡ đúng vị trí contact, 2 quỹ đạo kiếm trận có độ sâu, độ dài/độ sáng thay đổi; nâng khoảng cách vòng trong khỏi nhân vật.
- `godot/labs/combat_lab/research03/orbit_actor_overlay.gd` **mới**: lớp actor giữa các vệt sáng phía sau (z1) và phía trước (z3), không thay đổi sprite/game character authority.
- `godot/labs/combat_lab/research03/light_contact_2d.gdshader`: lõi vết chém sắc và mảnh hơn, quầng nhỏ giảm nhanh; không tạo flash che toàn màn.
- `godot/tests/labs/combat_lab/research03_contract_test.gd`: kiểm tra tia tụ khí nằm hai phía người thi triển; 16 decorative shards, phân lớp trước–sau, trung tâm trống, số contact hợp lệ, UV hot-tip bám đúng đường bay <0.65 px.
- Không sửa `SaveService`, Combat V2, skill damage, quái, HP, target selector, AI, hay live PvE.
- Art code commits: `cf5b636230ccabf606cab838c6a7c46274d1f4b6` -> `e7966ea46cd2d2da1ce565ab1f8db5ce57aadf04` (sửa parse) -> `72537344bc5776d87ca7dc6a4fa1fec5d8740e57` (sửa clearance, lần QA PASS đầu) -> **`0dd5bd605aff8a41a3808a10d0a366a67fb698f5`** (đánh bóng tụ khí, nhãn VFX18.1; QA PASS).

## EXACT-SHA Godot focused QA
- **Run:** [#43399027318](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43399027318), **SUCCESS**, code SHA `0dd5bd605aff8a41a3808a10d0a366a67fb698f5`.
- Godot `4.7.2.stable.official.ed1daf0bf`, GL Compatibility, strict import/parse, focused `VFX18_LIGHTCORE_FOCUSED_RESULT=PASS failures=0`.
- CI artifact `vfx18-lightcore-0dd5bd605aff8a41a3808a10d0a366a67fb698f5`, ID `14023998077`, 3 native Godot 1280×720 MP4 (`baseline.mp4`, `single.mp4`, `orbit.mp4`), each **204 frames** at fixed encoded 60/1 FPS, 10 frame PNGs per mode, filmstrips, logs and SHA256.
- CI uses a previously documented **uncommitted, disposable checkout-only V63 summon parse shim**. This is *isolated focused QA*, not a clean FULL game PASS; parallel V63 matrix remains FAIL on unrelated scope.
- Windows/Android physical device QA, sustained 6v8 or 30v40 FPS/memory measurements = **PENDING USER**. Fixed-fps encoding is not proof of physical FPS.

## Actual Godot 1× visual review — source clips compared against R2
Compared with exact [R2 run #43395591214](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43395591214) and reviewed true Godot frame samples 0.36, 0.72, 0.95, 1.20, 1.55, 1.85, 2.23, 2.43, 2.76, 3.00 seconds plus 20-panel timelines.

- **0.36s charge:** five animated blue-white filaments are now visually present around and to the right of caster's hand, not hidden entirely inside flat character sprite as in R2. Still room to reduce the "forked lines" appearance when zoomed at 1×.
- **1.55s flight:** single sharp tapered luminous qi with feathered blue edge; spatial head and tail aligned, no metallic sword. Nearly identical main blade to R2 intentionally; do not claim wholesale overhaul here.
- **2.43s contact:** crisp local white incision and small directional sparks appear; contact is still modest relative to the projectile scale and should be improved after owner review. The mock strike is not a real Combat V2 event.
- **1.55s orbit:** 16 non-uniform rotated energy streaks with curved history and gentle ground ambient. Independent back and front CanvasItem strata are verified by QA; center actor stays readable, and ring inner clearance has been increased.
- **Fade:** R18.1 effects disappear on mock timeline, no permanent disk or fake AOE. Dense 30-unit playback not tested.
- Visual self-rating: light material 4/5, sword silhouette 4/5, choreography 3.5/5, orbit composition 4/5, contact 3/5, fade 4/5, crowd perf NOT TESTED. These are **author review estimates, not user approval**.

## Current status and next gate
- `CODE_LAB_READY` / `GODOT_FOCUSED_PASS` / `FRAMES_REVIEWED`.
- `OWNER_VISUAL_PENDING`; **ART_REWORK_REQUIRED** for contact quality and full scene integration; `PVE_INTEGRATION_HOLD`.
- Suggested next isolated step **VFX18.2**: improve impact storytelling and 2.5D ring motion using staged particle energy with **no** hit/HP/AI/Save changes. Require owner visual approval before converting to event-driven live renderer.
