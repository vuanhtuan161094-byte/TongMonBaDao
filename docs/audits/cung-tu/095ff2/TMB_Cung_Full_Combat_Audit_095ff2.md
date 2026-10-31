# Tông Môn Bá Đạo — Cung Tu full combat audit

**Kết luận:** Chưa có bằng chứng đủ để khẳng định đệ tử Cung tự dùng được toàn bộ bộ chiêu hợp lệ, đánh trúng và làm giảm HP quái trong ONE GAME. Bằng chứng hiện có xác nhận một phần: ba nhánh Cung Nhân có active_01 tự cast và tạo hit có damage dương trong focused Combat V2; D4-A còn xác nhận Liệp Ảnh active_01 đi qua adapter PvE và snapshot restore. Tiên/Thần active_01 A/B có cast và hit event, nhưng test không assert damage dương hay HP giảm theo số. Phần lớn ID còn lại mới có catalogue, hoặc chỉ có một phần học/gắn.

Không chạy Godot trong audit này. Issue #56 tại HEAD còn ghi visual/owner acceptance và New Game journey pending; runtime gate tập trung chờ vì Godot thuộc Codex 1. Đây là static audit + harness bàn giao, không phải gameplay PASS.

## Phạm vi và nguồn

- Repository: vuanhtuan161094-byte/TongMonBaDao
- Branch: integration/one-game-v65-20261030
- Reference HEAD: 095ff2f90df8260dd123c06964d20c4f9b571d32 (đã đối chiếu live branch)
- Không sửa production source, shared gameplay, SaveService, P3.2 hay feature branch.
- Checkout local tham chiếu stale ở các catalogue/runtime chính; coverage dưới đây lấy từ GitHub tại đúng HEAD.

| Nguồn | SHA tại HEAD |
|---|---|
| Human catalogue | 4c1c11527e73cb9efe39663c80c5020c8b4baddb |
| Immortal catalogue | d95bce39dd078289ce76e675a4c1ffc8b9856490 |
| Divine catalogue | 78ebe72157fb725744649aa899761b51dcffa7cc |
| Human combat kernel | ef9025381dd0f63c1ac4c038d97882c7c7bac7f7 |
| MapBattleV2 | 1eec2e2051057a3e0843a013fe4552415da7e6a8 |
| HuntingPveRunV2 | 882123cbf8e02ee37288bf90bd35caa07f568d12 |
| Feature gates | da6a19dbb8382c8dfdd9994a0a98e4275734844d |
| P3.2 combat HUD | 199c327eca05a1adc6ce591c1d266d2c6836860d |
| Original VFX adapter | e82e2216b23a420300bd5b6cc39ed103cbfd4e47 |
| Original VFX manifest | 66636c072d5b76386e27f375674455c05abba178 |

## Coverage inventory

CSV có đúng **183 dòng kỹ năng Cung**: 35 Nhân (33 branch skills + basic/mobility), 68 Tiên (66 + basic/mobility), 80 Thần (78 + basic/mobility).

| Kết luận theo từng ID | Số dòng |
|---|---:|
| BUG | 5 |
| NOT_TESTED | 126 |
| PARTIAL | 52 |
| VERIFIED | 0 |
| DATA_ONLY | 0 proven; ID thiếu gameplay proof được ghi NOT_TESTED |
| BUG | 5 |

Không có ID được gọi VERIFIED vì chưa có test per-ID vừa chứng minh học/trang bị, tự cast, đúng target/effect, HP delta số (cho damage/heal), và PvE. DATA_ONLY không được suy ra chỉ vì thiếu test: kernel có generic handler cho effect hiện có; ID chưa có evidence được ghi NOT_TESTED.

## Runtime logic tĩnh

1. **Gate / PvE:** V63FeatureGates mặc định tắt human_skill_combat và divine_skill_combat. Persisted preview bật gate khi cả sect.v63_archive_opt_in và sect.v63_skill_combat_opt_in được lưu. HuntingPveRun gắn loadout khi khởi động session. D8 test chứng minh opt-in restore trong test; New Game journey thực tế còn pending ở #56.
2. **Học/trang bị:** archivable=true đi qua manual → Archive → learn → equip, phụ thuộc branch/lineage/gate. Innate là derived, không phải chiêu cá nhân. Basic/mobility Tiên/Thần có row successor archivable=false; branch path attach chúng tự động.
3. **AI/cooldown:** Human kernel duyệt loadout đã sort, thử active/ultimate/mobility theo thứ tự và bỏ qua chiêu đang hồi hoặc ngoài tầm. Mỗi skill có cooldown riêng; pending cast giữ caster đến release. Chưa có utility rotation; chưa có test multi-skill đủ dài chứng minh slot không bị đói.
4. **Timing:** deadline cộng cast time điều chỉnh theo cast speed với khoảng cách/projectile speed. Projectile speed làm trễ thời điểm resolve; kernel không tạo arrow projectile entity hay multi-hit-per-target. Mỗi lần resolve có tối đa một hit mỗi target.
5. **Targeting:** single target dùng target id; circle chụp tâm tại vị trí mục tiêu lúc bắt đầu; line kiểm tra hành lang rộng 0.85 và dùng radius làm chiều dài; AoE clamp tối đa 3 mục tiêu.
6. **Damage/defense/element:** damage gọi MapBattleV2._deal_direct rồi phát v63_skill_hit có damage, target_hp_before, target_hp_after. Khi damage dương, elemental reaction được gọi. CombatStatsV2 settlement xử lý stats/resist/defense. Không có Cung-specific test cho từng nguyên tố/kháng hay HP0/Injury/kill receipt.
7. **Basic:** dùng nhịp next_basic riêng và _deal_direct(kind=basic); attach gắn basic_ratio, range và basic_element. D4-B có hit basic Cung damage dương trong encounter test.
8. **Passive/innate:** passive IDs gom modifier vào effective attack/guard stats; innate là derived modifier. Mới có một Human Liệp passive_01 test stat delta; trigger/ICD/duration/stacking của từng ID chưa được chứng minh.
9. **Effect set:** ba catalogue Cung dùng damage, mobility, passive, innate, heal, mark. Không thấy poison effect trong Cung.

## Bằng chứng test hiện có

- **D4-A** v63_d4a_human_combat_test.gd: sáu caster Liệp Ảnh học/trang bị active_01; auto cast, hit event và damage > 0; boss phase/telegraph; HuntingPveRun start, snapshot save/restore và adapter advance. Chỉ một skill/branch trong focused PVE integration, không phải New Game journey toàn bộ bộ chiêu.
- **D4-B** v63_d4b_human_branches_bosses_test.gd: 3/3 nhánh Cung Nhân active_01 auto cast + hit damage > 0; shared bow basic hit và mobility movement/evasion; Liệp Ảnh full 12-slot loadout learned/equipped/attached. Full loadout chỉ chứng minh attach, không cast từng active/ultimate/passive.
- **D4-B archive/effects** v63_d4b_archive_learning_test.gd: bow AoE Thiên Vũ active_03 gọi release_cast trực tiếp, fixture ép shape thành circle, xác nhận 3 hit events; Liệp passive_01 tăng effective attack. Generic heal test là Dược Độc, không phải Linh Tiễn.
- **D5** v63_d5_immortal_lineage_combat_test.gd: 18/18 branch×A/B active_01 manual-backed, learned/equipped, cast và v63_skill_hit. Không assert damage>0 hoặc target_hp_after < target_hp_before cho Cung Tiên.
- **D6** v63_d6_divine_lineage_combat_test.gd: tương tự 18/18 active_01 branch×A/B; event presence không phải HP proof.
- **D6 rare** v63_d6_rare_successors_test.gd: rare ultimate/passive_05 successor learned/equipped/replaced; bow rare ultimate release/mastery receipt gần mục tiêu, không assert HP delta/range edge.
- **D7** HUD/archive focused tests xác nhận adapter được mount/consumes fixture event; không chứng minh live Cung projectile, release/impact timing hay screenshot New Game thật. Issue #56 ghi GUI/owner visual acceptance và full P3.2 PvE journey pending.

Không test Godot nào được chạy lại trong audit này.

## Findings

### P0 — Chưa thấy lỗi P0 được chứng minh tĩnh

Focused tests cho thấy active_01 Nhân cast được; chưa có bằng chứng crash, authority sai hoặc save corruption ở phạm vi này. Điều đó không thay thế focused test trên HEAD hiện tại.

### P1 — Runtime / combat

1. **Cung mobility không hoạt động trong world_mode.** _try_mobility trả false nếu battle.world_mode hoặc actor không phải disciple. D4-B chỉ test encounter cô lập. Điều này ngăn Thu Vũ Bộ và successor Tiên/Thần trong PvE world-mode.
2. **Liệp Ảnh Thần line B ultimate sai reach.** Catalogue có range=8.96, shape=line, radius=5.76; cast eligibility dùng range còn line filter dùng radius làm chiều dài. Cast có thể bắt đầu cách 5.76–8.96 nhưng resolve loại mục tiêu. Áp dụng normal Divine ultimate B và rare ultimate B của Liệp Ảnh; D6 test gần mục tiêu nên bỏ sót.
3. **Heal AI có thể tiêu hao Linh Tiễn active_02 khi cả đội đầy HP.** _support_target chọn ally HP-ratio thấp nhất mà không lọc hp<max_hp; full-health vẫn hợp lệ, _heal_target tạo amount 0 sau khi cast/cooldown đã dùng. Chưa có test theo Cung ID.
4. **Chưa chứng minh rotation multi-skill.** AI dùng sort + first-ready; cooldown riêng nhưng chưa có scenario dài ghi số cast mỗi slot. Đây là coverage gap, chưa khẳng định starvation runtime.
5. **Thiếu HP delta assertion trên lineage tests.** D5/D6 kiểm tra skill_cast + v63_skill_hit nhưng không assert damage/HP giảm; cần receipt theo từng ID.

### P2 — Presentation / data identity

1. **HUD đọc sai field tên chiêu.** Catalogue dùng name; v63_combat_hud_v1.gd đọc name_vi rồi display_name và có thể fallback raw ID. Patch tối thiểu: ưu tiên definition.name và thêm presentation assertion.
2. **VFX cursor có thể dừng sau khi event ring đầy trong world-mode.** Adapter fallback sequence về index+1; MapBattle event không có sequence; ring world-mode pop-front ở 2,400 events. Cursor có thể kẹt tại 2,400, làm cue mới bị bỏ qua. Thêm monotonic event sequence + regression test.
3. **Thiếu VFX cung theo skill/projectile.** Catalogue có animation_key/vfx_key; adapter vẽ cue vector generic theo event type, manifest asset_files rỗng, không bind key cho arrow draw/release/travel/impact/damage text. D7 fixture không phải screenshot combat Cung thật.
4. **Trùng mechanics giữa ID khác nhau.** So sánh exact fields effect, ratio, range, cast/cooldown, projectile, element, shape/radius, target limit, power/duration/stacks/passive modifiers; bỏ qua name/animation/vfx:
   - Human: Liệp Ảnh active_01/active_02; active_03/active_04; Linh Tiễn active_03/active_04; Thiên Vũ active_01/active_02; active_03/active_04.
   - Tiên và Thần: Liệp Ảnh B active_01/02/04, Liệp Ảnh A active_03/04; Linh Tiễn A/B active_03/04; Thiên Vũ A active_01/02, A+B active_03/04; mọi nhánh × A/B có passive_01–05 trùng mechanics.
   Đây là P2 về bản sắc/dữ liệu; không đề xuất đổi balance đã khóa.

## Patch proposal / ownership / rollback

Không có production diff. Đề xuất cho ONE-GAME-INTEGRATOR:

| Ưu tiên | Thay đổi tối thiểu | Test bắt buộc | Owner |
|---|---|---|---|
| P1 | Chốt semantics mobility ở world-mode, rồi hỗ trợ movement/evasion nhất quán | Bow mobility world-mode: position/evasion/event, bounds, snapshot | Codex 1 |
| P1 | Align line target length với cast range cho Liệp Ảnh Divine B, không sửa balance row trước khi xác nhận ý đồ | Mục tiêu gần, ở 5.76–8.96, ngoài 8.96; normal/rare B | Codex 1 |
| P1 | Bỏ qua heal khi không có ally thiếu HP | Linh Tiễn active_02: all-full không cast/cooldown; injured có amount>0 và HP delta | Codex 1 |
| P1 | Matrix receipt cho mỗi ID: học/trang bị, cast start, release, target, HP, damage, hit count, cooldown, status, snapshot | Chạy harness trên scratch khi Godot slot rảnh, rồi New Game journey exact HEAD | Codex 1 owns shared runtime |
| P2 | HUD lấy definition.name | Bow label bằng localized catalogue name | Codex 1 / P3.2 owner |
| P2 | Monotonic sequence cho event/VFX | Ring >2,400 events vẫn tiêu thụ cue mới; snapshot không replay cue cũ | Codex 1 |
| P2 | Bind per-skill bow animation/VFX keys vào arrow draw/release/impact | Combat visual capture 1280×720 và owner acceptance riêng | Codex 1 |

**Rollback:** chưa có patch/commit để revert. Nếu tích hợp sau này, revert đúng commit tích hợp riêng; giữ các thay đổi khác của nhánh.
**File ownership:** MapBattle/PvE/SaveService/P3.2 và branch ONE GAME thuộc Codex 1. Harness là scratch artifact, chưa chép vào production.

## Handoff

- Chưa thể nói “all skills complete”.
- Bằng chứng tích cực: Human active_01 cả 3 nhánh auto cast/hit damage>0; D4-A Liệp active_01 có PvE adapter/snapshot path.
- Known gaps: mobility world-mode; Liệp Thần B line reach; heal full-HP cast; toàn bộ matrix HP/effect/rotation; passives/innate triggers; resistance/boss/HP0/kill/injury; SaveService reload; New Game PvE; live bow VFX.
- Harness file: TMB_Cung_Audit_Harness_095ff2.gd — prepared, **not run** do Codex 1 giữ Godot ownership.
- Khi Codex 1 đã nhả Godot, chép harness vào một QA copy riêng rồi chạy từ project root bằng `godot --headless --path <scratch-project> --script <scratch-project>/tests/TMB_Cung_Audit_Harness_095ff2.gd`. Không chạy trên save thật.


