# HS-09 — BACKEND GAP / UI INTEGRATION MATRIX
**Ngày:** 2026-10-31. **Status:** design-only inventory, not Codex instruction.
**Audit code:** `integration/one-game-v65-20261030` (read-only snapshot, không đảm bảo là HEAD hiện tại).

| ID | Mảng | Nguồn hiện có | Việc nối / giới hạn |
| --- | --- | --- | --- |
| BE-01 | Snapshot canonical | `godot/src/presentation/disciple_presentation_snapshot_v2.gd` | Đã trả identity/foundations/life/work/learning/equipment/relations/innate/progression/combat, nhưng chưa có các block V6.3/Đan Bão Hòa đầy đủ; không lấy legacy làm V2 authority. |
| BE-02 | D7 radar | `godot/src/presentation/p3/disciple_six_dimension_radar.gd` | Code hiện vẽ 7 trục liền. Mục tiêu UI: 3+4 polygon chồng một tâm, độc lập tỷ lệ, không mutate points. |
| BE-03 | D7 effects | `foundation_system.gd` | Tư Chất +0.25% tự nhiên/điểm, Căn Cốt +0.20% EXP Luyện Thể/điểm, Tiềm Lực +0.05% core/điểm, Thông Tuệ +0.15% học/nghề/điểm. Tâm Tính chưa có runtime consumer; Cơ Duyên/Mị Lực theo kiểm tra RNG/xã hội, không là cộng % thẳng. |
| BE-04 | Linh Căn & Bẩm Sinh | `disciple_presentation_snapshot_v2.gd`: `innate.spiritual_root, traits, bloodline, physique, destiny, profession_talents` | Chỉ show đặc chất `visible`. Nhiều `effect_status: identity_only`; không khẳng định cộng hiệu ứng combat. |
| BE-05 | Cảnh giới | `DiscipleRealmProgressV2`, snapshot `progression` | Tu Vi/Luyện Thể 30×10; gate, EXP, status; không hiển thị thay legacy fallback nếu V2 chưa sẵn sàng. |
| BE-06 | Life/PvE | snapshot `life` | HP, injury ticks, expedition stamina, action/region, cống hiến, Linh Thạch cá nhân; hiển thị rõ PvE/Injury; không tính thể lực này cho công việc thường. |
| BE-07 | Nghề | snapshot `work.professions` | Sáu nghề, level, xp, preference, progress, site, talents. Roster và action phải đọc source thật; đệ tử đang Active Job không tự tái phân công. |
| BE-08 | Công Pháp V6.3 | `DiscipleState.known_techniques`, `active_technique_main/aux`, `v63_study_job`, `V63LearningSystem` | Mở rộng projection với 3 ô, mastery, nghiên tu, receipt. `V63FeatureGates.DEFAULT_FLAGS` đều false; chỉ enable khi có persisted opt-in thật. |
| BE-09 | Kỹ năng V6.3 | `DiscipleState.v63_*skills`, `V63HumanSkillCombatSystem` | Branch, learned skill, equipped ids, slot, generation; tên/ratio dùng registry; disabled feature không có hiệu ứng live. |
| BE-10 | Trang bị | `EquipmentSystem.VALID_SLOTS` | 3 ô weapon/armor/talisman; thông tin lock. Snapshot `v2_consumer_ready=false` cho authentic V2, đừng cộng legacy stat. |
| BE-11 | Huyết Mạch / Thể Chất | snapshot `innate.bloodline/physique` | Chỉ trạng thái revealed/unrevealed/none, tên/độ thuần hợp lệ; effect còn identity-only ở V2. Không cho nút Tôi thể/Cải thể cũ thay đổi hồ sơ V2. |
| BE-12 | Quan Hệ | snapshot `relationships` | target id/name, affinity/trust/respect/interactions, companion; lưu đúng IDs, không show dữ liệu đoán. |
| BE-13 | Đan Bão Hòa | `B3PillSatietyV1`, `DiscipleState.b3_pill_state` | capacity 1,000,000/ngày, spent/day/receipt khi enabled; không hiển thị số giả hoặc nút uống không có engine. |
| BE-14 | Luyện công & Combat stats | snapshot `combat.stats/resistances/core_breakdown` | Combat core chỉ Realm/Body/Potential. Phân biệt core với future equipment/innate effects. |
| BE-15 | Touch/camera/provenance | `p3_2_landscape_sect.gd`, `DiscipleSourceAVisualPool` | Chỉ hiện source actor khi verified sprite; input/tabs/scroll phải QA trên Godot + Android thật; không làm lại map. |
| BE-16 | Persistence | SaveService, offline/exactly-once authorities | UI read-only không tự tạo gameplay state; validate save/reload, active job/gates/receipts mới khi nối action thật. |

## Release gates tương lai

1. Export snapshot one disciple from actual V2 authority, plus V6.3 projection guarded by persistent feature flags.
2. 7 tab navigation + roster + short overview; no dead/false action buttons.
3. Validate Tam Căn/Tứ Tính polygon geometry, axes, birth/current/delta vs real data.
4. Verify equipment slots & V2 consumer warning; no phantom bonuses.
5. Assert work/pve/injury conditions, no automatic cancellation of existing job.
6. Godot GUI screenshot @1280×720, mouse & Android touch; exact branch SHA & focused suites PASS.
7. Chỉ sau các gates mới bàn giao/merge code. Nhánh này không có mã game.
