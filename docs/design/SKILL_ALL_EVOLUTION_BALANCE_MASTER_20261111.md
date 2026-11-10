# SKILL-ALL — Catalogue, tiến hóa và tình trạng cân bằng (11/11/2026)

**Nguồn:** PR #72, code fix SHA 9242ded8acc3e0123a07207bae4b188e065126b5, parent 917a7668037133235157ef03ccea26f804d1f54b.  
**Trạng thái:** kiểm kê dữ liệu và regression headless đã chạy; **chưa chấp thuận bật V6.3, chưa chốt cân bằng, chưa nghiệm thu GUI/Android**. Tài liệu này mô tả code/data hiện có, không biến đề xuất thành luật.

## 1. Phạm vi catalogue

File docs/qa/SKILL_ALL_ID_AUDIT.csv giữ nguyên từng định nghĩa nguồn, field thiếu ghi rõ N/A, JSON nguồn gốc và SHA-256 định nghĩa chuẩn hóa.

| Nguồn | Bản ghi | Phân bố |
|---|---:|---|
| V6.3 | 549 ID, 549 tên duy nhất, 105 family | Nhân giới 105 = 35 family × 3 môn; Tiên giới 204 = 68 × 3; Thần giới 240 = 80 × 3 |
| Cung | 183 | Liệp Ảnh, Linh Tiễn, Thiên Vũ |
| Quyền | 183 | Bá Quyền, Kim Cang, Huyết Quyền |
| Độc | 183 | Độc Châm, Cổ Độc, Dược Độc |
| CombatSkillSystem cũ | 9 | Kỹ năng chiến đấu cũ |
| TechniqueSystem | 6 | Bí kíp/tu luyện; không tính nhầm là 6 cast skill mới |
| **Tổng kiểm kê** | **564 ID/entry duy nhất** | Không có ID trùng |

CSV ghi FamilyID, ParentSkillID, ReplacesSkillID, SourceCodexID, tier, slot, stage gate, hệ số, trạng thái runtime, mastery, VFX và raw definition. Audit gồm cả registry cũ; hồ sơ kỹ thuật không phải cast action được đánh dấu riêng, không cộng trùng vào 549.

### Chuỗi thi triển hiện có

V6.3 đi vào bộ phân giải chiến đấu qua MapBattleV2 và các registry Nhân/Tiên/Thần. CombatSkillSystem là registry cast legacy; TechniqueSystem là metadata/bí kíp và tiến trình học, không phải registry cast thứ hai. P1/P2/V2/V65 là handoff, contract hoặc runtime path, không tạo thêm catalogue V6.3 độc lập. Bảng ID dẫn tới nguồn từng hàng để truy ngược.

### Quan hệ tiến hóa

Dữ liệu nguồn mô tả quan hệ theo family_id, parent_skill_id, replaces_skill_id, branch, lineage, tier và stage gate. CSV là đối chiếu từng hàng; regression Cung/Quyền/Độc kiểm tra 183 record mỗi môn. File TMB_DOC_SKILL_EVOLUTION_BALANCE_MASTER_20261110.md và các file candidate khác vẫn là **đề xuất chưa duyệt**; không áp dụng hệ số mới từ chúng.

## 2. Trạng thái cân bằng và feature gates

V63FeatureGates.DEFAULT_FLAGS đều false, gồm content_registry, skill_successors, boss_encounters, sect_codex, technique_learning, human_skill_combat, divine_skill_combat, poison_evolution_strict. Vì vậy các phép đo V6.3 không đồng nghĩa đã phát hành kỹ năng public/live.

Trong audit V6.3:
- 444 entry Tiên/Thần đang mang nhãn candidate trong dữ liệu.
- 70 kỹ năng Nhân giới còn lại là canonical baseline.
- 35 kỹ năng Độc Nhân được đánh dấu PVB1_CANDIDATE_20261110; not owner-approved.
- Trong 183 entry Độc, status luật tiến hóa ghi 26 CODE_CANDIDATE_QA_PENDING, 54 IMPLEMENTING_QA_GATED, 103 không khai báo luật riêng (N/A).

**Không thay đổi** damage, cooldown, xác suất, kinh tế, progression hoặc gate trong commit này.

### PVB1 — luật đang có trong code nhưng vẫn là candidate

Nguồn: v63_human_skill_combat_system.gd, v63_poison_evolution_v1.gd và PVB1 regression. Các giới hạn hiện có trong code:

- Tối đa 5 tầng do cùng caster trên một mục tiêu; tổng mục tiêu Boss tối đa 30 tầng. Tick mỗi 1 giây; một tầng có thời hạn tối đa 10 giây, ratio mỗi tầng bị clamp không vượt 0.20.
- Tiêu Độc sau hit dùng min(0.60, 0.08 × S + 0.40 × R); S là số tầng của chủ thể, R là phần DoT còn lại đã qua diminishing fairness. Chỉ xóa tầng của đúng chủ sau hit có damage thật.
- Ngân sách hồi: cửa sổ 600 giây, giới hạn min(12% MaxHP, 35% damage thật nhận trong cửa sổ); không dùng để chữa Injury.
- Mark Cổ Độc: ICD 8 giây, bonus trực tiếp 0.12 ATK chỉ trên hit đã commit.
- Counter sau cleanse: trạng thái sạch mở cửa 5 giây; hit kế tiếp được 0.08 ATK, ICD 12 giây; không có proc khi cleanse rỗng.
- Spread: bán kính 2.5, tối đa một mục tiêu phụ, tick ratio 65% và clamp 0.20, thời lượng tối đa 5 giây, ICD 6 giây.

Đây là **code candidate gated**, không phải quyết định cân bằng đã được owner duyệt. Những giới hạn trên được giữ nguyên và không đổi trong PR này.

## 3. Đo mô phỏng đã có — không phải PvE thật

File docs/qa/SKILL_ALL_NORMALIZED_MEASUREMENTS_20261111.csv lưu 168 trial từ Godot 4.7.2.stable.official.ed1daf0bf, fixed seed, target 1 và 3, 75 giây mô phỏng/trial, MapBattleV2/MonsterCatalogueV2 fixture, ATK 180/DEF 100, HP mục tiêu 3M.

| Suite / môn | Trials | Mean normalized DPS/ATK | Mean normalized heal/MaxHP |
|---|---:|---:|---:|
| Độc-only 21 profile | 42 | 1.4073 | 0.000180 |
| All-school Cung | 42 | 1.8940 | 0.000080 |
| All-school Quyền | 42 | 1.2441 | 0 |
| All-school Độc | 42 | 1.4104 | 0.000181 |

Trung bình tỷ trọng DoT ở fixture Độc khoảng 0.0383. Đây là **chỉ số đã chuẩn hóa trong fixture**, không thể quy đổi thành DPS người chơi, tỉ lệ thắng hoặc 6/12/18 kill/giờ. Chưa có mô phỏng kinh tế PvE dài hạn 60–180 phút hoặc đo máy Android.

## 4. Hình ảnh / VFX

godot/data/presentation/v63_combat_vfx_manifest.json ghi asset_files: []; runtime dùng cue vector tổng quát từ sự kiện MapBattleV2 (telegraph, hit, phase, status). Lab có brief/preview riêng nhưng không được gắn nhãn là VFX Source A/JX đã duyệt và không chứng minh VFX riêng theo từng skill. Commit này chỉ sửa tooltip lab lấy bán kính và giới hạn mục tiêu từ canonical definition; không sửa renderer live hoặc thêm asset giả.

## 5. Phạm vi code sửa

Trên commit 9242ded8:
- bỏ số bán kính hardcode trong tooltip lab; đọc radius và target_limit từ skill definition;
- sửa bốn regression contract bị lệch nguồn: Bách Độc Tán Châm bán kính 2.8/cap 3; Vạn Linh Giải Ách là AoE heal radius 2.5/cap 3; Giải Độc Hộ Tâm mới là heal đơn range 6.5/cap 1; kiểm tra projection/edge dùng bán kính canonical.

Không sửa Combat V2, SaveService, dữ liệu catalogue, công thức damage, RNG hoặc feature gates.

## 6. Còn chờ quyết định / nghiệm thu

- Owner duyệt hoặc bác từng luật PVB1 candidate trước khi bật gate.
- Godot Actions exact SHA hiện chưa trả workflow/status; xem SKILL_ALL_QA_EVIDENCE_20261111.md.
- GUI Windows 1280×720, chuột vật lý, Android thật, skill VFX theo event trên bản chơi: **PENDING**.
- Cân bằng PvE thực, trận dài và progression/economy: **PENDING**, không suy ra từ fixture.