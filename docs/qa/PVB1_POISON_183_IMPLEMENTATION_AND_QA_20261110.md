# PVB1 — ĐỘC TU NHÂN–TIÊN–THẦN: TRIỂN KHAI 183 NODE / 35 FAMILY, CODE QA GATE

**Ngày** 10/11/2026. **Nhánh** `integration/pve-p0-playable-ui-20261103`, PR #72 Draft. **Source HEAD khi rà soát:** `800023be82ef3acbec01bb172d5429c5d87bbe86`. **Trạng thái:** CODE CHANGED / STATIC DATA PASS / OFFICIAL GODOT 4.7.2 RUN RESULT NOT RETRIEVED / LIVE BALANCE & WINDOWS-ANDROID PENDING. Đây không phải FULL QA PASS.

## 1. Phạm vi được tác động

- `godot/data/combat/v63_human_combat_catalog.json`: 35 Độc Tu Nhân; giữ đủ 105 skill toàn trường, `enabled:false`.
- `godot/data/combat/v63_immortal_combat_catalog.json`: 68 Độc Tu Tiên; giữ đủ 204 toàn trường, `enabled:false`.
- `godot/data/combat/v63_divine_combat_catalog.json`: 80 Độc Tu Thần/hiếm; giữ đủ 240 toàn trường, `enabled:false`.
- `godot/data/combat/v63_content_registry.json` + `godot/src/simulation/combat/v63_content_registry.gd`: nối đúng 6 passive rare của Độc Tu vào gia phả; validator mở đúng sáu node này, không tự thêm rare cho cung/quyền.
- `godot/src/simulation/combat/v63_poison_evolution_v1.gd`: helper toán chiến đấu bounded, tiêu hao DoT theo chủ, giảm hiệu quả 30-stack, đọc receipt sát thương thật cho ngân sách hồi HP, mark/counter hai pha, spread 1 mục tiêu không nổ dây chuyền.
- `godot/src/simulation/combat/v63_human_skill_combat_system.gd`: tích hợp nguồn dữ liệu mới, hiệu quả passive/innate độc+hồi, né/đánh dấu/kích nổ chỉ commit sau damage thực, AI không spam trị liệu khi cạn ngân sách, strict predecessor flag cho người chơi đã opt-in V63.
- `godot/src/simulation/combat/v63_feature_gates.gd`: default `poison_evolution_strict:false`; persisted override true chỉ cho V63 đã opt-in cùng archive/combat.
- `godot/src/simulation/combat/map_battle_v2.gd`: ghi nhận damage thực lên thành viên tham gia V63 làm chứng từ ngân sách trị liệu.
- `godot/tests/simulation/v63_poison_evolution_balance_test.gd`: ma trận gia phả, số liệu, 6 rare, 7 luật Thần, 30-stack fairness, consume, heal/serial, counter, spread.
- `godot/tests/simulation/v63_poison_six_vs_eight_pve_simulation_test.gd`: chiến đấu deterministic trong `MapBattleV2`, 6 đệ tử Thần A/B vs 8 Trúc Thử từ `MonsterCatalogueV2`, log sự kiện thực, không tự tạo tiền/EXP.
- `godot/tests/simulation/v63_doc_full_combat_matrix_test.gd`: sửa fixture hồi phục phải nhận sát thương thật trước; kiểm tra passive `poison_factor` bằng hàm thực, không gán PASS chỉ từ tên modifier.
- `.github/workflows/v63-quyen-doc-matrix.yml`: chạy official pinned Godot 4.7.2 V63 183-ID + PVB1 + 6v8 cùng hồi quy cung/quyền/độc. Báo link CI PR #72 khi run push mới nhất hoàn tất.

**Không sửa** SaveService, hệ thống HP0→fullHP+Injury120, giá chữa Injury, nguồn tiền/EXP PvE, R1/R2 sản xuất, giới hạn 30 hunter/40 mob/20 bãi, runtime skill VFX, các nguyên liệu giả. Không tạo branch, không merge.

## 2. Cơ chế OLD → CODE CANDIDATE

| Hạng mục | Trước | PVB1 ứng viên trong code |
|---|---|---|
| Số kỹ năng | 183 ID/35 family nhưng nhiều cùng tên/đồng cơ chế | 183 ID/35 family, 183 tên riêng, 36 effect changes rõ ràng, parent của hậu duệ |
| DoT consume | +0.05 ratio/tầng cùng chủ, cap +0.75, xóa tầng | +min(0.60, 0.08×S+0.40×R) ratio; R từ tick còn lại × diminishing fairness, xóa duy nhất tầng cùng chủ sau hit thật |
| DoT | max5/caster/target, max30/target | giữ nguyên cap, refresh tối đa một tầng cũ ở Tiên/Thần A; không tạo tầng thứ sáu |
| Spread Cổ Độc A | Divine special `DESIGN_PENDING` | phát 1 tầng độc phụ ở mục tiêu khác trong bán kính 2.5, 65% tick ratio, sống ≤5s, ICD6s, không chain, không fake direct hit |
| Mark Cổ Độc B | chỉ hệ số dấu trong damage | cộng bonus direct 0.12× ATK sau một mark hợp lệ, ICD8s; chỉ trừ dấu/cd sau hit thật; không nhân đôi phần bonus bởi mark multiplier |
| Trị liệu Dược Độc | %MaxHP không gắn nguồn sát thương thật | giới hạn target 10 phút = min(12%MaxHP,35% damage thực); receipt được lưu cùng actor snapshot; không chữa Injury; AI chỉ chọn mục tiêu còn budget |
| Counter Dược Độc B | special `DESIGN_PENDING` | cleanse thật ≥1 trạng thái mở cửa 5s; lần gây sát thương thực kế tiếp +0.08 ATK, ICD12s, không proc trên empty cleanse |
| Bị động cứu tử hiếm A | rare passive chưa gắn fatal-save | passive_05.rare_passive.a của Dược A có 1 charge, dùng `V63DivineSkillCombatSystem.prevent_lethal` cũ với ICD90s |
| Học tiến hóa | `family_id` thay khi trang bị, học thiếu chặn parent | `poison_evolution_strict` cho V63 persisted opt-in: học mới cần ID tiền nhiệm, người đã học vẫn giữ dữ liệu cũ |
| VFX | Lab riêng/ nhiều key dùng chung | chưa đổi VFX runtime; render theo `skill_id` và event thật là cổng tiếp theo |

**Lưu ý:** `poison_evolution_strict` mặc định false; toàn bộ catalogue V63 vẫn `enabled:false`, không bật đại trà. Việc test stat matrix/sim không được nhầm thành kiểm thử Save migration hay Android.

## 3. Kết quả kiểm toán tĩnh tại source SHA

```json
{
  "source_sha": "800023be82ef3acbec01bb172d5429c5d87bbe86",
  "skill_count": 183,
  "families": 35,
  "unique_names": 183,
  "source_effect_changed": 36,
  "catalogue_drift": 0,
  "registry_count": 183,
  "unregistered": 0,
  "rare_passives": 6,
  "gates": [
    false,
    false,
    false,
    false
  ],
  "divine_pending_code": 26
}
```

**Đây chỉ là dữ liệu và đọc code. Không được ghi Godot PASS do chưa có log chính xác từng job của SHA này.**

## 4. QA bắt buộc trước khi chuyển từ candidate sang ready

Official Godot 4.7.2 ở `.github/workflows/v63-quyen-doc-matrix.yml` phải PASS toàn workflow trên exact SHA, không chỉ vài focused step:

```bash
godot --headless --path godot --import
godot --headless --path godot --check-only --script res://src/simulation/combat/v63_poison_evolution_v1.gd
godot --headless --path godot -s res://tests/simulation/v63_poison_evolution_balance_test.gd
godot --headless --path godot -s res://tests/simulation/v63_doc_full_combat_matrix_test.gd
godot --headless --path godot -s res://tests/simulation/v63_poison_six_vs_eight_pve_simulation_test.gd
godot --headless --path godot -s res://tests/simulation/v65_poison_combat_contract_test.gd
```

Then cumulative PVE-P0, world 6/12/18 kills/h with **measured** PvE economics and user Injury120; solo/3/6/30 hunter, 1/3 target, Elite/Boss, Save/Reload mid-combat after heal/counter, duplicate HP0 receipt, physical Windows Android FPS; explicit 21 profile real DPS/HPS/DoT comparison, balance adjustment from logs. Do not call 6v8 fixture an open-world economy acceptance.

## 5. Known technical debt (BLOCKER)

1. 183 source skill ID data/static structure matched, but no same-SHA proof official Godot importer/tests finished. Treat syntax, action semantics and 6v8 still QA OPEN.
2. 26 Divine rules transitioned from DESIGN_PENDING to **CODE_CANDIDATE_QA_PENDING**, not approved/pass.
3. Budget heal depends on actor combat receipt history; check snapshot retention and memory after 60–180min real world, including 30 hunters.
4. No actual per-skill visual capture or real mobile 4v8 performance; VFX design remains existing source, no regeneration.
5. 21 old proxy scenarios are analytical upper-bound opportunities, not actual combat simulation. Official 6v8 test must run and produce measured per-caster events; cannot use paper number as gameplay balance verdict.

**Next release gate:** get GitHub Actions run ID + jobs + logs + exact SHA, fix errors against evidence, re-run focused/cumulative; keep Save and default feature gates unchanged until full balance acceptance.
