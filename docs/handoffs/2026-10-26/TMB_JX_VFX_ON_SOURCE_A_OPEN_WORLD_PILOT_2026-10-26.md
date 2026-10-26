# TÔNG MÔN BÁ ĐẠO — PILOT JX VFX TRÊN THẾ GIỚI PvE SOURCE A
**26/10/2026 · HANDOFF cho Codex Windows · source-backed / presentation-only / NOT RUNTIME PASS**

## Kết luận chủ dự án
- **KHÓA visual:** map tông môn/sản xuất đã đẹp, reuse renderer `SectIsometricWorldV1` và Source A assets cho thế giới PvE liên tục. Nhân vật/quái ưu tiên Source A.
- **ƯU TIÊN VFX:** JX/Võ Lâm Truyền Kỳ/Kiếm Thế phù hợp kiếm khí, chiêu chưởng, buff, projectile, impact, skill SFX. Học phong cách/nhịp VFX JX, KHÔNG chuyển map/nền tuyết, sprite nhân vật hay Combat V2 sang JX.
- **Gameplay:** Combat V2/V3 S1, clock, actor positions, real hit, cooldown, RNG, injury, Warehouse, Save là AUTHORITY. VFX **CHỈ HIỂN THỊ**, một event có thể tạo nhiều frame/đạn mỹ thuật nhưng KHÔNG được tự phát damage/loot. Nếu thiếu asset, không mượn một chiêu khác rồi đổi tên thành nguồn gốc JX.

## Tồn kho ĐÃ KIỂM CHỨNG trong GitHub, không cần extract lại
Quan sát trực tiếp cây/manifest theo `feature/endgame-visual-lod-pve-world-foundation-20261025` và `tools/af-jx1-player-forge-20261020`:
- `godot/src/presentation/p3/combat_v4_effect_atlas.gd`: đã đọc `res://assets/combat_v4/source_vl/vfx_manifest.json` và `res://assets/combat_v4/jx1_skill_fx/fx_manifest.json` để render frame/anchor/timing chỉ xem; hiện **chỉ hỗ trợ dirs=1**, không hỗ trợ 16-direction atlas.
- `godot/assets/combat_v4/jx1_skill_fx/`: 7 ảnh WebP đã nhập từ người dùng với SHA theo `godot/data/presentation/c4_jx1_pres00_five_skill_asset_manifest.json` ở nhánh `tools/af-jx1-player-forge-20261020`:
  - **Kiếm** JX ID **158** (`jx_wudang_158`): `3dfcabc2.webp` precast 10f @50ms, `aa93d577.webp` cast 17f @50ms, `361b4525.webp` impact 8f @40ms. Trong `fx_manifest.json` hiện mới bind **impact**; precast/cast WebP là file có sẵn nhưng **chưa có rect/timeline runtime production**.
  - **Độc** JX ID **63** (`jx_wudu_63`): `40a1c4ff.webp` cast 8f × **16 hướng** @50ms, `1fffed7e.webp` impact 13f @~56ms. Hiện chỉ bind **impact**, hướng bay 16-dir phải audit frame rects thực trước khi dùng.
  - **Hỗ trợ** JX ID **93** (`jx_emei_93`): `2f8c6d50.webp` precast 5f @60ms, `e8178d06.webp` impact 18f @100ms; **precast** đã bind, impact chưa có verified runtime atlas rect. Một cast source metadata của #93 chưa được tìm thấy.
  - #15 Bất Động Minh Vương: precast metadata only, file không có trong folder đã audit; #159 Thất Tinh Trận: không có authored clip binding trong source graph đã xác minh. **KHÔNG FAKE SOURCE**.
- `godot/assets/combat_v4/source_vl/vfx_manifest.json`: `sword_cast` 36 frame @30ms, `sword_hit` 21 frame @30ms, nhưng các WebP cần đối chiếu binary/import path thực trước khi áp vào gameplay mới. Source VL là dự án nguồn/phái sinh người dùng, không khẳng định dữ liệu bằng original MMO JX.
- **Có legacy event binding đáng học, KHÔNG merge nguyên branch cũ**: `c4-jx1-rank-and-fx-source-20261019/godot/src/presentation/p3/map_battle_world_layer_v2.gd` đã có `CombatV4EffectAtlas`, `_effect_cues`, xử lý `pilot_cast`, `pilot_impact`, `skill_cast`/real `hit`, fail-closed khi thiếu VFX và budget `MAX_VISIBLE_SOURCE_FX=12`. `c4_jx1_rank_fx_source_test.gd` kiểm tra 3 clip và không ảnh hưởng HP/RNG; **đây là kiểm thử lịch sử của nhánh C4**, không tự là PASS trên PvE mới.
- Chính PR39 hiện có `CombatV4EffectAtlas` và WebP, nhưng `MapBattleWorldLayerV2` ở HEAD audit chỉ là adapter vẽ chấm/HP, **không có active JX VFX event pipeline cho PvE world**. Không được nói "đã tích hợp VFX JX vào map PvE" chỉ vì repo chứa WebP/atlas.

## Kết quả MVP cụ thể, ít gò bó
**Giữ PvE liên tục cùng map đẹp Source A**, lấy đúng **một trận thật** 6 đệ tử vs 10 quái hiện có làm sân chơi kỹ thuật, rồi hiển thị:
1. Kiếm: đệ tử Source A thực sự cast `Ngu Kiem Thuat` hoặc chiêu có gameplay event phù hợp → flash cast → một **cosmetic projectile theo vị trí world**, ảnh hưởng bởi camera nhưng KHÔNG ảnh hưởng hitbox/gameplay → impact JX/Source VL đúng sự kiện authoritative. Nếu dùng asset #158 như skin presentation cho chiêu TMB, ghi `presentation_source=jx_wudang_158`, `canonical_skill_id` riêng; không gọi là cùng SkillId JX. **Không nổ trước khi thực sự trúng**.
2. Độc (chỉ khi có skill/status nguồn thật): cast/impact JX #63 và feedback trạng thái thật, không bịa tick poison. Không có event thì chỉ hiển thị trong **standalone FX laboratory**, không bật trong PvE production.
3. Hỗ trợ: #93 precast nếu có heal/buff cast thật, không tự tạo heal hay biến chiêu TMB thành chiêu Emei.
4. Actor foot/world anchor đúng và layer hợp lý: dưới đất shadow/telegraph, actor, kiếm khí/projectile, impact. Render loop tách VFX animation-time khỏi fixed simulation; render skips outside camera + pool/hard cap prioritized, brightness/source-blend hợp Source A; không vẽ full-white 200 projectile.
5. Minimap không cần render VFX (chỉ vị trí actor/camera). Bấm đất vẫn di chuyển, roam vẫn xảy ra; VFX không tạo modal hoặc dịch world-position.

Codex tự chọn kiến trúc adapter (dùng lại C4 hay viết gọn theo presentation hiện tại); **đừng sao chép nguyên old `MapBattleWorldLayerV2` 36×20 canvas hoặc 50×100 map tuyết vào PvE**. Có thể làm FX test-lab độc lập để xem asset/anchor nhưng cuối cùng cần P3.2 real PvE screenshot/video.

## Safety/acceptance (không ép roadmap)
- Chỉ thực hiện trên local Codex game-owned E: branch/worktree có checkpoint, **không ghi đè nhánh Codex chưa push**. Không merge main hoặc PR39 chỉ để nhập 1 renderer cũ. UI/owner image quality quyết định.
- Bằng chứng: native 1280×720 same scene before/after, ~10–20s combat video gồm cast→flight→impact, 1) no duplicate FX on UI refresh/save reload 2) positive hit/zero hit phân biệt thật 3) no change HP/tick/seed/loot vs baseline 4) screen VFX budget và p95 frame time/FPS đúng máy 8GB 5) art FX không che toàn bộ nhân vật. Không nhận PASS từ static code.
- Trường hợp 16 hướng/atlas thiếu clip/source: chỉ implement clip verified trước; ghi `FX_PARTIAL` nhưng vẫn cho world Source A chạy được. Thiếu loot source để `LOOT_PENDING`, không liên quan VFX pilot.
- Quyền owner là sử dụng trong dự án cá nhân; không tự public bản raw JX archive hoặc xác nhận mọi upstream license cho phân phối.

## PROMPT NGẮN (Codex local)
> TÔNG MÔN BÁ ĐẠO — Giữ nguyên map sản xuất Source A mà tôi đã thích và tái sử dụng cho map PvE. Tôi đặc biệt thích VFX JX/Kiếm Thế, hãy dùng các WebP và manifest JX1 đã có trong repo/ổ E, đặc biệt nhóm chiêu kiếm #158, độc #63 và buff #93. Đọc file `docs/work-mode-handoff-map-qa-integration-20261025/docs/handoffs/2026-10-26/TMB_JX_VFX_ON_SOURCE_A_OPEN_WORLD_PILOT_2026-10-26.md`. Từ trận PvE thật, tạo cảm giác xuất chiêu có cast/projectile/impact đúng tọa độ và event Combat V2, không fake damage/loot, không thay renderer map hay nhân vật Source A. Tự chọn cách hiệu quả, ưu tiên game nhìn thấy và chơi được, so ảnh/video trước sau, kiểm tra FPS và Save. Không merge main, không làm mất local code chưa push, báo chính xác các clip/FX nào đã thật sự chạy.
