# V63-ALL36 — G0 inventory baseline & branch contract

**Checked PR #72 head:** `aef95073093d59fa5424e9a453547cc413e6dd97`; branch `integration/pve-p0-playable-ui-20261103`; Draft.  
**Execution packet content SHA:** `3d6934ac73c765f77cc11609d7b2c9d34dfe4206`.  
**Status:** inventory baseline committed; **G0 EXIT OPEN**. This file does not claim implementation or acceptance.

## Source inventory

- `godot/data/combat/v63_content_registry.json`: enabled=false, 3 schools, 9 branches, 105 families.
- Human/Immortal/Divine catalogs: 105/204/240 = **549 actual runtime IDs**, 183 per school.
- Source blob SHAs at inspected HEAD: registry `ec342196c48fecf8f5708d0dac8412a774ac7d4b`; Human `dd0d74b7ec82ccaad03756eef6d6bdb3359484df`; Immortal `96a9339ba4d211d1dfc4abde6206462f854f21c0`; Divine `ced59e0dc9957259882c939546694a5766b95021`.
- Issue #75's official Godot focused tests are inherited. Aggregate catalog/matrix success does **not** prove each of 549 skills' effects, AI, save, or VFX individually accepted.
- The previously described detailed 315-family/1,647-node workbook is not in the current repo or checked Downloads. The 1,647 rows in the companion matrix are structural planning slots with `plan:` keys, **not runtime IDs, names, skills, effects, or recovered historical content**.

## Count contract

| Coverage | Families | Nodes | Truth |
|---|---:|---:|---|
| Cung / Quyền / Độc | 105 | 549 | Existing catalog rows |
| Nine added schools | 315 planned | 1,647 planned | `NOT_AUTHORED` |
| 12-school target | 420 slots | 2,196 rows | Inventory only, not playable coverage |

Each new school has 2 shared family slots (basic/mobility) and 3×11 branch slots (4 active, ultimate, 5 passive, innate). Per school, the planned distribution is 35 Human, 68 Immortal and 80 Divine slots. Divine rare replacement slots mirror the existing structural pattern (ultimate and passive_05 A/B); no combat payload is invented. The ID/effect ledger is `../qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv`.

## Existing branches from the live registry

| School | Slug | Branch | A / B lineage | Rare successors | State |
|---|---|---|---|---|---|
| bow | liep_anh | Liệp Ảnh | Truy Hồn / Xuyên Thành | Thiên Mệnh Đoạn Tinh; Vạn Lý Đoạn Giới | Runtime catalog; per-skill acceptance still open |
| bow | linh_tien | Linh Tiễn | Tụ Nguyên / Thiên Tượng | Tam Tượng Thiên Kiếp; Tam Tượng Thiên Tai | Runtime catalog; per-skill acceptance still open |
| bow | thien_vu | Thiên Vũ | Tiễn Hải / Quy Nhất | Thiên Hà Vạn Tiễn; Thiên Hà Tụ Sát | Runtime catalog; per-skill acceptance still open |
| fist | ba_quyen | Bá Quyền | Phá Quân / Địa Liệt | Quyền Toái Thiên Môn; Thần Sơn Băng Diệt | Runtime catalog; per-skill acceptance still open |
| fist | kim_cang | Kim Cang | Hộ Pháp / Phản Chấn | Vạn Kiếp Bất Hoại Pháp Thân; Vạn Kiếp Nghịch Chấn | Runtime catalog; per-skill acceptance still open |
| fist | huyet_quyen | Huyết Quyền | Huyết Ma / Huyết Sinh | Tuyệt Mệnh Huyết Đế; Huyết Hải Sinh Sinh | Runtime catalog; per-skill acceptance still open |
| poison | doc_cham | Độc Châm | Thực Cốt / Bạo Phệ | Cửu U Vạn Độc Thiên Kiếp; Nhất Niệm Vạn Độc Bạo | Runtime catalog; per-skill acceptance still open |
| poison | co_doc | Cổ Độc | Liên Tâm / Phệ Cổ | Vạn Cổ Phong Thiên Đại Trận; Cổ Hoàng Diệt Mệnh | Runtime catalog; per-skill acceptance still open |
| poison | duoc_doc | Dược Độc | Hồi Thiên / Dĩ Độc | Thái Thượng Nghịch Mệnh Đạo; Thái Thượng Phản Độc | Runtime catalog; per-skill acceptance still open |

## Nine added schools / 27 branch signatures from packet §1

Roles below are bounded implementation directions, not approved numeric balance. Signature names are packet-authored. Branch slugs are planning identifiers. New A/B lineage names, family names and per-skill payloads remain unauthored.

| School | Planning slug | Branch | Signature ultimate | Distinct mechanic direction (candidate) | Missing |
|---|---|---|---|---|---|
| sword | ngu_kiem | Ngự Kiếm | Vạn Kiếm Quy Tông | Ngự kiếm tầm trung/xa, projectile có source/cast rõ; không thêm hit để minh họa. | Lineage names and family mechanics not authored |
| sword | sat_kiem | Sát Kiếm | Nhất Kiếm Đoạn Thiên | Burst đơn mục tiêu có điều kiện authored; không có crit/execute ngầm. | Lineage names and family mechanics not authored |
| sword | ho_kiem | Hộ Kiếm | Thiên Cương Kiếm Giới | Parry/guard rồi phản kích từ sát thương thực hấp thụ; shield có cap. | Lineage names and family mechanics not authored |
| blade | cuong_dao | Cuồng Đao | Cửu Trùng Cuồng Đao | Combo chém cận chiến hữu hạn mỗi cast. | Lineage names and family mechanics not authored |
| blade | tram_phach_dao | Trảm Phách Đao | Trảm Phách Đoạn Thiên | Phá giáp qua effect có định nghĩa, không bỏ qua defense. | Lineage names and family mechanics not authored |
| blade | tran_dao | Trấn Đao | Thiên Sơn Trấn Đao | Giữ tuyến/khống chế mềm có refractory. | Lineage names and family mechanics not authored |
| dual_blade | anh_nhan | Ảnh Nhẫn | Thiên Ảnh Phân Sát | Đánh nhanh/đổi mục tiêu; không tạo afterimage actor/reward. | Lineage names and family mechanics not authored |
| dual_blade | lien_hoan | Liên Hoàn | Thập Nhị Liên Hoàn Trảm | Combo nhiều nhịp có hit/cast cap và proc attribution. | Lineage names and family mechanics not authored |
| dual_blade | huyet_nguyet | Huyết Nguyệt | Huyết Nguyệt Táng Thiên | Đổi HP có ngưỡng hữu hạn lấy burst; không lifesteal vô hạn. | Lineage names and family mechanics not authored |
| spear | pha_tran_thuong | Phá Trận Thương | Nhất Thương Phá Vạn Quân | Đòn thẳng/xuyên tuyến có target cap. | Lineage names and family mechanics not authored |
| spear | long_thuong | Long Thương | Cửu Long Liệt Không | Projectile/line tầm xa, số hit theo skill. | Lineage names and family mechanics not authored |
| spear | ho_quan_thuong | Hộ Quân Thương | Vạn Quân Thương Bích | Bảo hộ theo damage thật đã chặn. | Lineage names and family mechanics not authored |
| palm | liet_duong_chuong | Liệt Dương Chưởng | Thái Dương Phần Thiên | Chưởng lực nặng/diện; không Burn ngầm. | Lineage names and family mechanics not authored |
| palm | han_ngoc_chuong | Hàn Ngọc Chưởng | Cửu Hàn Phong Nguyệt | Slow/Hàn Trệ hữu hạn, có Boss resistance. | Lineage names and family mechanics not authored |
| palm | hoi_phong_chuong | Hồi Phong Chưởng | Thái Thanh Hồi Thiên Chưởng | Heal HP thực; không tự xóa Injury. | Lineage names and family mechanics not authored |
| formation | tu_linh_tran | Tụ Linh Trận | Thái Sơ Vạn Linh Trận | Vùng hỗ trợ có radius/duration/actor cap; không tạo tài nguyên. | Lineage names and family mechanics not authored |
| formation | phong_toa_tran | Phong Tỏa Trận | Cửu Cung Phong Tuyệt Trận | Vùng khóa có duration/ICD/refractory. | Lineage names and family mechanics not authored |
| formation | sat_phat_tran | Sát Phạt Trận | Vạn Tượng Tru Tiên Trận | Zone DoT có source owner; tick không proc dây chuyền. | Lineage names and family mechanics not authored |
| summon | kiem_linh | Kiếm Linh | Thần Kiếm Linh Hợp Nhất | Một kiếm linh có actor budget/lifecycle; không loot độc lập. | Lineage names and family mechanics not authored |
| summon | linh_thu | Linh Thú | Vạn Thú Linh Khế | Một linh thú có target/expiry/cap. | Lineage names and family mechanics not authored |
| summon | khoi_loi_ho_phap | Khôi Lỗi Hộ Pháp | Đại Thiên Cơ Hộ Pháp | Khôi lỗi phòng thủ có HP/expiry/target cap; không ghost snapshot. | Lineage names and family mechanics not authored |
| curse | tran_hon_chu | Trấn Hồn Chú | Cửu U Trấn Hồn Đại Chú | Seal/CC theo tier và duration cap. | Lineage names and family mechanics not authored |
| curse | phe_linh_chu | Phệ Linh Chú | Vạn Hồn Phệ Linh | Siphon theo damage/source owner, không dùng status caster khác. | Lineage names and family mechanics not authored |
| curse | ho_menh_chu | Hộ Mệnh Chú | Thái Thượng Hộ Mệnh Chú | Bảo hộ/defeat intercept hữu hạn; không xóa Injury. | Lineage names and family mechanics not authored |
| talisman | loi_phu | Lôi Phù | Cửu Thiên Vạn Lôi Phù | Projectile/chain có cap, proc một lần/cast. | Lineage names and family mechanics not authored |
| talisman | hoa_phu | Hỏa Phù | Vạn Phù Phần Thiên | Vùng burst/tick hữu hạn; không Burn ngầm. | Lineage names and family mechanics not authored |
| talisman | phong_an_phu | Phong Ấn Phù | Thái Huyền Phong Giới Phù | Seal/dispel chỉ khi tier/effect hợp lệ. | Lineage names and family mechanics not authored |

## Root and element rules for G1

- Five base roots: Kim/Mộc/Thủy/Hỏa/Thổ; Dị roots Lôi/Phong/Băng/Dương/U Minh attach to a base root, never replace it or get a second purity meter.
- Root may scale only skill-authored numeric fields. It does not create status, change target caps, cooldown/cast time, duration, profession speed or rewards.
- Counter cycle from `SPIRITUAL_ROOT_V2_SPEC.md`: Kim > Mộc > Thổ > Thủy > Hỏa > Kim. ×1.25/×0.85/×1.00 are candidate starting factors, behind OFF gates pending engine proof and balance review.
- No element/resistance may be invented on a monster. Existing V63 feature gates remain OFF.

## G0 blockers

1. New rows still lack authored names, per-family source, element/root requirements, effects/formulas, geometry, range/cooldown/target caps, CC, AI priorities and event-mapped VFX. New content must be authored as new, not called recovered.
2. Existing 549 rows have aggregate QA only; each skill/effect/passive/AI/VFX still needs honest evidence, not blanket PASS.
3. No exact PR checkout is available to the local shell: E: production is a dirty PR #67 ancestor and private Git CLI reports `SEC_E_NO_CREDENTIALS`. It remains untouched. GitHub connector will be used for scoped commits; exact-SHA Godot runner is still required.

**G0 result:** baseline/count/provenance recorded; exit criteria not met. Proceed to the independent G1 root evaluator only, without touching shared combat/save/runtime files until source ownership and exact QA path are clear.
