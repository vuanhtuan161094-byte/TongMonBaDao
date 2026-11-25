# VFX production inventory — generated 2026-11-25

Source of catalog truth is the 12 school ledgers. Scene references come from current LAB scenes and their bound scripts.
Scene presence, source approval, technical status, owner review, and live integration are recorded separately.

- Skill IDs: **2196 unique**
- Skill families: **420**
- Human cast masters: **204**
- Human families with at least one bound LAB scene: **89**
- Human cast families with at least one bound LAB scene: **86**
- Distinct Human LAB scene revisions: **93**
- Every ledger row retains its declared `live_integration` value. PvE status is not inferred from scenes.

## Per-school coverage

| School | IDs | Families | Human cast | Human families with scene | Cast families with scene | All scene revisions | Cast scene revisions | Owner approved | Provisional | Pending | Ledger/effective status conflicts | Tier fallback pending | Tier fallback incompatible | Passive/event receipt gated |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| poison | 183 | 35 | 17 | 17 | 17 | 28 | 28 | 7 | 6 | 4 | 0 | 51 | 19 | 96 |
| talisman | 183 | 35 | 17 | 18 | 15 | 23 | 17 | 2 | 0 | 15 | 0 | 53 | 17 | 96 |
| sword | 183 | 35 | 17 | 17 | 17 | 17 | 17 | 0 | 17 | 0 | 17 | 70 | 0 | 96 |
| bow | 183 | 35 | 17 | 1 | 1 | 1 | 1 | 0 | 0 | 17 | 0 | 49 | 21 | 96 |
| fist | 183 | 35 | 17 | 15 | 15 | 22 | 22 | 0 | 0 | 17 | 0 | 31 | 39 | 96 |
| blade | 183 | 35 | 17 | 1 | 1 | 1 | 1 | 0 | 0 | 17 | 0 | 68 | 2 | 96 |
| dual_blade | 183 | 35 | 17 | 1 | 1 | 1 | 1 | 0 | 0 | 17 | 0 | 70 | 0 | 96 |
| spear | 183 | 35 | 17 | 1 | 1 | 1 | 1 | 0 | 0 | 17 | 0 | 70 | 0 | 96 |
| palm | 183 | 35 | 17 | 1 | 1 | 1 | 1 | 0 | 0 | 17 | 0 | 55 | 15 | 96 |
| curse | 183 | 35 | 17 | 0 | 0 | 0 | 0 | 0 | 0 | 17 | 0 | 70 | 0 | 96 |
| formation | 183 | 35 | 17 | 17 | 17 | 1 | 1 | 0 | 0 | 17 | 0 | 70 | 0 | 96 |
| summon | 183 | 35 | 17 | 0 | 0 | 0 | 0 | 0 | 0 | 17 | 0 | 70 | 0 | 96 |

## Human cast masters

| School | Branch | Skill ID | Ledger owner gate | Ledger-derived owner status | Effective owner status | Decision evidence | Ledger technical/art status | Bound LAB scenes |
|---|---|---|---|---|---|---|---|---|
| poison | shared | `tmb.skill.poison.basic.human` | OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | GODOT_V4_TECH_PASS_V3_1_PROVISIONAL_USE_POLISH_BACKLOG | godot/labs/combat_lab/poison_basic_human_v2/doc_cham_thuong_thuc.tscn; godot/labs/combat_lab/poison_basic_tiers_v3/poison_basic_tiers.tscn |
| poison | co_doc | `tmb.skill.poison.co_doc.active_01.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | LAB_APPROVED_VISUAL_BASELINE | godot/labs/combat_lab/poison03/fu_cot_co.tscn |
| poison | co_doc | `tmb.skill.poison.co_doc.active_02.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | LAB_APPROVED_CHARGE_POLISH_PENDING | godot/labs/combat_lab/poison01/xa_anh_quan_mach.tscn; godot/labs/combat_lab/poison02/xa_anh_source_vl_remake.tscn |
| poison | co_doc | `tmb.skill.poison.co_doc.active_03.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | LAB_APPROVED_VISUAL_BASELINE | godot/labs/combat_lab/poison04/co_vu_me_tung.tscn |
| poison | co_doc | `tmb.skill.poison.co_doc.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | GODOT_LAB_PASS_ART_PENDING | godot/labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.tscn; godot/labs/combat_lab/poison05/tan_co_dien_nhiem.tscn |
| poison | co_doc | `tmb.skill.poison.co_doc.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | GODOT_LAB_PASS_ART_PENDING | godot/labs/combat_lab/poison06/r11_candidate/van_co_phe_gioi_r11.tscn; godot/labs/combat_lab/poison06/van_co_phe_gioi.tscn |
| poison | doc_cham | `tmb.skill.poison.doc_cham.active_01.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | OWNER_VISUAL_APPROVED_R7 | godot/labs/combat_lab/poison07/r6_original/xuyen_cot_doc_cham_r6.tscn; godot/labs/combat_lab/poison07/r7_painted/xuyen_cot_doc_cham_r7.tscn; godot/labs/combat_lab/poison07/xuyen_cot_doc_cham.tscn |
| poison | doc_cham | `tmb.skill.poison.doc_cham.active_02.human` | OWNER_PROVISIONAL_CONTINUE | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | OWNER_PROVISIONAL_R4_POLISH_BACKLOG | godot/labs/combat_lab/poison08/phe_mach_doc_thich.tscn; godot/labs/combat_lab/poison08/r3_painted/phe_mach_doc_thich_r3.tscn; godot/labs/combat_lab/poison08/r4_painted/phe_mach_doc_thich_r4.tscn |
| poison | doc_cham | `tmb.skill.poison.doc_cham.active_03.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | OWNER_VISUAL_APPROVED_R1 | godot/labs/combat_lab/poison09/r1_painted/bach_doc_tan_cham_r1.tscn |
| poison | doc_cham | `tmb.skill.poison.doc_cham.active_04.human` | OWNER_PROVISIONAL_CONTINUE | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | OWNER_PROVISIONAL_R2_CONTINUE | godot/labs/combat_lab/poison10/r1_painted/doc_khi_phe_tam_r1.tscn; godot/labs/combat_lab/poison10/r2_remake/doc_khi_phe_tam_r2.tscn |
| poison | doc_cham | `tmb.skill.poison.doc_cham.ultimate.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | OWNER_VISUAL_APPROVED_R9 | godot/labs/combat_lab/poison11/r1_original/van_doc_xuyen_tam_r1.tscn |
| poison | duoc_doc | `tmb.skill.poison.duoc_doc.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | GODOT_G35_TECH_PASS_ART_REWORK_REQUIRED_R2 | godot/labs/combat_lab/poison12/tay_mach_linh_duoc.tscn |
| poison | duoc_doc | `tmb.skill.poison.duoc_doc.active_02.human` | OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | GODOT_V4_G35_TECH_PASS_R2_PROVISIONAL_KEEP | godot/labs/combat_lab/poison13_heal_heart/r1/giai_doc_ho_tam.tscn; godot/labs/combat_lab/poison13_heal_heart/r2/giai_doc_ho_tam_energy.tscn |
| poison | duoc_doc | `tmb.skill.poison.duoc_doc.active_03.human` | OWNER_PROVISIONAL_ACCEPTED_NOT_FINAL | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | GODOT_V4_TECH_PASS_R1B_PROVISIONAL_KEEP | godot/labs/combat_lab/poison14_cleanse/r1/nghich_doc_phan_che.tscn |
| poison | duoc_doc | `tmb.skill.poison.duoc_doc.active_04.human` | OWNER_VISUAL_APPROVED_R1B | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | GODOT_V4_G35_TECH_PASS_R1B_OWNER_ART_APPROVED | godot/labs/combat_lab/poison15_hoa_doc_tan/r1/hoa_doc_tan.tscn |
| poison | duoc_doc | `tmb.skill.poison.duoc_doc.ultimate.human` | OWNER_PROVISIONAL_ACCEPTED_R2D_POLISH_BACKLOG | OWNER_PROVISIONAL | OWNER_PROVISIONAL | LEDGER_OWNER_GATE | GODOT_V4_G35_G36_TECH_PASS_R2D_PROVISIONAL_KEEP | godot/labs/combat_lab/poison16_van_linh_giai_ach/r1/van_linh_giai_ach.tscn; godot/labs/combat_lab/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic.tscn |
| poison | shared | `tmb.skill.poison.mobility.human` | OWNER_VISUAL_PENDING_R1_G37_SEMANTIC | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | GODOT_V4_G35_G36_TECH_PASS_POI17_R1_MOVING_SHADOW_STEP | godot/labs/combat_lab/poison17_yem_anh_bo/r1/yem_anh_bo.tscn |
| talisman | shared | `tmb.skill.talisman.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| talisman | hoa_phu | `tmb.skill.talisman.hoa_phu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman06/xich_diem_khai_van.tscn |
| talisman | hoa_phu | `tmb.skill.talisman.hoa_phu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman07/lien_diem_phan_gioi.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | hoa_phu | `tmb.skill.talisman.hoa_phu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman08/hoa_tam_ngung_phu.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | hoa_phu | `tmb.skill.talisman.hoa_phu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman09/chu_tuoc_hoi_hoan.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | hoa_phu | `tmb.skill.talisman.hoa_phu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman10/van_phu_phan_thien.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | loi_phu | `tmb.skill.talisman.loi_phu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman01/dien_quang_khai_phu.tscn |
| talisman | loi_phu | `tmb.skill.talisman.loi_phu.active_02.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | ART_APPROVED | godot/labs/combat_lab/talisman02/thien_loi_dan_net.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | loi_phu | `tmb.skill.talisman.loi_phu.active_03.human` | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | OWNER_VISUAL_APPROVED | LEDGER_OWNER_GATE | ART_APPROVED | godot/labs/combat_lab/talisman03/loi_van_truy_an.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | loi_phu | `tmb.skill.talisman.loi_phu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman04/cuu_tieu_pha_van.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | loi_phu | `tmb.skill.talisman.loi_phu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman05/cuu_thien_van_loi_phu.tscn; godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| talisman | shared | `tmb.skill.talisman.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| talisman | phong_an_phu | `tmb.skill.talisman.phong_an_phu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman11/phong_gioi_truy_dau.tscn |
| talisman | phong_an_phu | `tmb.skill.talisman.phong_an_phu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman12/thai_huyen_khep_an.tscn |
| talisman | phong_an_phu | `tmb.skill.talisman.phong_an_phu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman13/tay_tran_giai_phu.tscn |
| talisman | phong_an_phu | `tmb.skill.talisman.phong_an_phu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman14/ho_menh_luu_van.tscn |
| talisman | phong_an_phu | `tmb.skill.talisman.phong_an_phu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/talisman15/r4/thai_huyen_phong_gioi_r4.tscn; godot/labs/combat_lab/talisman15/thai_huyen_phong_gioi_phu.tscn |
| sword | shared | `tmb.skill.sword.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_16_lab.tscn |
| sword | ho_kiem | `tmb.skill.sword.ho_kiem.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_11_lab.tscn |
| sword | ho_kiem | `tmb.skill.sword.ho_kiem.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_12_lab.tscn |
| sword | ho_kiem | `tmb.skill.sword.ho_kiem.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_13_lab.tscn |
| sword | ho_kiem | `tmb.skill.sword.ho_kiem.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_14_lab.tscn |
| sword | ho_kiem | `tmb.skill.sword.ho_kiem.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_15_lab.tscn |
| sword | shared | `tmb.skill.sword.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_17_lab.tscn |
| sword | ngu_kiem | `tmb.skill.sword.ngu_kiem.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/visual_bridge_v1/as48_sword_anchor_lab.tscn |
| sword | ngu_kiem | `tmb.skill.sword.ngu_kiem.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/r1e_lab.tscn |
| sword | ngu_kiem | `tmb.skill.sword.ngu_kiem.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_03_lab.tscn |
| sword | ngu_kiem | `tmb.skill.sword.ngu_kiem.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_04_lab.tscn |
| sword | ngu_kiem | `tmb.skill.sword.ngu_kiem.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_05_lab.tscn |
| sword | sat_kiem | `tmb.skill.sword.sat_kiem.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_06_lab.tscn |
| sword | sat_kiem | `tmb.skill.sword.sat_kiem.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_07_lab.tscn |
| sword | sat_kiem | `tmb.skill.sword.sat_kiem.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch6_20261124/sword_08_lab.tscn |
| sword | sat_kiem | `tmb.skill.sword.sat_kiem.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_09_lab.tscn |
| sword | sat_kiem | `tmb.skill.sword.sat_kiem.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_PROVISIONAL | OWNER_PROMPT_2026-11-25_SWORD_17_OF_17_PROVISIONAL | NOT_ART_APPROVED | godot/labs/combat_lab/sword_batch9_20261124/sword_10_lab.tscn |
| bow | shared | `tmb.skill.bow.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | liep_anh | `tmb.skill.bow.liep_anh.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| bow | liep_anh | `tmb.skill.bow.liep_anh.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | liep_anh | `tmb.skill.bow.liep_anh.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | liep_anh | `tmb.skill.bow.liep_anh.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | liep_anh | `tmb.skill.bow.liep_anh.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | linh_tien | `tmb.skill.bow.linh_tien.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | linh_tien | `tmb.skill.bow.linh_tien.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | linh_tien | `tmb.skill.bow.linh_tien.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | linh_tien | `tmb.skill.bow.linh_tien.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | linh_tien | `tmb.skill.bow.linh_tien.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | shared | `tmb.skill.bow.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | thien_vu | `tmb.skill.bow.thien_vu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | thien_vu | `tmb.skill.bow.thien_vu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | thien_vu | `tmb.skill.bow.thien_vu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | thien_vu | `tmb.skill.bow.thien_vu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| bow | thien_vu | `tmb.skill.bow.thien_vu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| fist | ba_quyen | `tmb.skill.fist.ba_quyen.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist01/khai_son_trong_quyen.tscn |
| fist | ba_quyen | `tmb.skill.fist.ba_quyen.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist02/phi_than_lien_cuoc.tscn |
| fist | ba_quyen | `tmb.skill.fist.ba_quyen.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist04/lei_dinh_chan_quyen.tscn |
| fist | ba_quyen | `tmb.skill.fist.ba_quyen.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist05/dia_mach_lien_chan.tscn |
| fist | ba_quyen | `tmb.skill.fist.ba_quyen.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist03/than_quyen.tscn |
| fist | shared | `tmb.skill.fist.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| fist | huyet_quyen | `tmb.skill.fist.huyet_quyen.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist11/huyet_liet_quyen.tscn |
| fist | huyet_quyen | `tmb.skill.fist.huyet_quyen.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist12/doan_mach_lien_quyen.tscn; godot/labs/combat_lab/fist12/r10/doan_mach_lien_quyen_r10.tscn; godot/labs/combat_lab/fist12/r9/doan_mach_lien_quyen_r9.tscn |
| fist | huyet_quyen | `tmb.skill.fist.huyet_quyen.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist13/huyet_khi_hoi_luu.tscn |
| fist | huyet_quyen | `tmb.skill.fist.huyet_quyen.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist14/liep_huyet_truy_da.tscn; godot/labs/combat_lab/fist14/r11_owner_review/fist14_r11_owner_review.tscn; godot/labs/combat_lab/fist14/r3/liep_huyet_truy_da_r3.tscn; godot/labs/combat_lab/fist14/r4_simple/liep_huyet_truy_da_r4_simple.tscn; godot/labs/combat_lab/fist14/r5/liep_huyet_truy_da_r5.tscn; godot/labs/combat_lab/fist14/r6_luminous/liep_huyet_truy_da_r6_luminous.tscn |
| fist | huyet_quyen | `tmb.skill.fist.huyet_quyen.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist15/huyet_hai_quyen_vuc.tscn |
| fist | kim_cang | `tmb.skill.fist.kim_cang.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist06/tran_dia_quyen.tscn |
| fist | kim_cang | `tmb.skill.fist.kim_cang.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist07/kim_cang_ho_the.tscn |
| fist | kim_cang | `tmb.skill.fist.kim_cang.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist08/phan_chan_quyen.tscn |
| fist | kim_cang | `tmb.skill.fist.kim_cang.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist09/tran_son_ho_dong.tscn |
| fist | kim_cang | `tmb.skill.fist.kim_cang.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/fist10/bat_dong_kim_chung.tscn |
| fist | shared | `tmb.skill.fist.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | shared | `tmb.skill.blade.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | cuong_dao | `tmb.skill.blade.cuong_dao.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/blade01/pha_vay_khai_son_r1/pha_vay_khai_son_preview.tscn |
| blade | cuong_dao | `tmb.skill.blade.cuong_dao.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | cuong_dao | `tmb.skill.blade.cuong_dao.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | cuong_dao | `tmb.skill.blade.cuong_dao.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | cuong_dao | `tmb.skill.blade.cuong_dao.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | shared | `tmb.skill.blade.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tram_phach_dao | `tmb.skill.blade.tram_phach_dao.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tram_phach_dao | `tmb.skill.blade.tram_phach_dao.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tram_phach_dao | `tmb.skill.blade.tram_phach_dao.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tram_phach_dao | `tmb.skill.blade.tram_phach_dao.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tram_phach_dao | `tmb.skill.blade.tram_phach_dao.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tran_dao | `tmb.skill.blade.tran_dao.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tran_dao | `tmb.skill.blade.tran_dao.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tran_dao | `tmb.skill.blade.tran_dao.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tran_dao | `tmb.skill.blade.tran_dao.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| blade | tran_dao | `tmb.skill.blade.tran_dao.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | anh_nhan | `tmb.skill.dual_blade.anh_nhan.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | anh_nhan | `tmb.skill.dual_blade.anh_nhan.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| dual_blade | anh_nhan | `tmb.skill.dual_blade.anh_nhan.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | anh_nhan | `tmb.skill.dual_blade.anh_nhan.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | anh_nhan | `tmb.skill.dual_blade.anh_nhan.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | shared | `tmb.skill.dual_blade.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | huyet_nguyet | `tmb.skill.dual_blade.huyet_nguyet.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | huyet_nguyet | `tmb.skill.dual_blade.huyet_nguyet.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | huyet_nguyet | `tmb.skill.dual_blade.huyet_nguyet.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | huyet_nguyet | `tmb.skill.dual_blade.huyet_nguyet.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | huyet_nguyet | `tmb.skill.dual_blade.huyet_nguyet.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | lien_hoan | `tmb.skill.dual_blade.lien_hoan.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | lien_hoan | `tmb.skill.dual_blade.lien_hoan.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | lien_hoan | `tmb.skill.dual_blade.lien_hoan.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | lien_hoan | `tmb.skill.dual_blade.lien_hoan.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | lien_hoan | `tmb.skill.dual_blade.lien_hoan.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| dual_blade | shared | `tmb.skill.dual_blade.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | shared | `tmb.skill.spear.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | ho_quan_thuong | `tmb.skill.spear.ho_quan_thuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | ho_quan_thuong | `tmb.skill.spear.ho_quan_thuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | ho_quan_thuong | `tmb.skill.spear.ho_quan_thuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | ho_quan_thuong | `tmb.skill.spear.ho_quan_thuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | ho_quan_thuong | `tmb.skill.spear.ho_quan_thuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | long_thuong | `tmb.skill.spear.long_thuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/van_long_diem_thuy_preview.tscn |
| spear | long_thuong | `tmb.skill.spear.long_thuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | long_thuong | `tmb.skill.spear.long_thuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | long_thuong | `tmb.skill.spear.long_thuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | long_thuong | `tmb.skill.spear.long_thuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | shared | `tmb.skill.spear.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | pha_tran_thuong | `tmb.skill.spear.pha_tran_thuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | pha_tran_thuong | `tmb.skill.spear.pha_tran_thuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | pha_tran_thuong | `tmb.skill.spear.pha_tran_thuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | pha_tran_thuong | `tmb.skill.spear.pha_tran_thuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| spear | pha_tran_thuong | `tmb.skill.spear.pha_tran_thuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | shared | `tmb.skill.palm.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | han_ngoc_chuong | `tmb.skill.palm.han_ngoc_chuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/palm01/han_ngoc_chan_mach_r1/lab/han_ngoc_chan_mach_lab.tscn |
| palm | han_ngoc_chuong | `tmb.skill.palm.han_ngoc_chuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | han_ngoc_chuong | `tmb.skill.palm.han_ngoc_chuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | han_ngoc_chuong | `tmb.skill.palm.han_ngoc_chuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | han_ngoc_chuong | `tmb.skill.palm.han_ngoc_chuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | hoi_phong_chuong | `tmb.skill.palm.hoi_phong_chuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | hoi_phong_chuong | `tmb.skill.palm.hoi_phong_chuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | hoi_phong_chuong | `tmb.skill.palm.hoi_phong_chuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | hoi_phong_chuong | `tmb.skill.palm.hoi_phong_chuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | hoi_phong_chuong | `tmb.skill.palm.hoi_phong_chuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | liet_duong_chuong | `tmb.skill.palm.liet_duong_chuong.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | liet_duong_chuong | `tmb.skill.palm.liet_duong_chuong.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | liet_duong_chuong | `tmb.skill.palm.liet_duong_chuong.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | liet_duong_chuong | `tmb.skill.palm.liet_duong_chuong.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | liet_duong_chuong | `tmb.skill.palm.liet_duong_chuong.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| palm | shared | `tmb.skill.palm.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | shared | `tmb.skill.curse.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | ho_menh_chu | `tmb.skill.curse.ho_menh_chu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | ho_menh_chu | `tmb.skill.curse.ho_menh_chu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | ho_menh_chu | `tmb.skill.curse.ho_menh_chu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | ho_menh_chu | `tmb.skill.curse.ho_menh_chu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | ho_menh_chu | `tmb.skill.curse.ho_menh_chu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | shared | `tmb.skill.curse.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | phe_linh_chu | `tmb.skill.curse.phe_linh_chu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | phe_linh_chu | `tmb.skill.curse.phe_linh_chu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | phe_linh_chu | `tmb.skill.curse.phe_linh_chu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | phe_linh_chu | `tmb.skill.curse.phe_linh_chu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | phe_linh_chu | `tmb.skill.curse.phe_linh_chu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | tran_hon_chu | `tmb.skill.curse.tran_hon_chu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | tran_hon_chu | `tmb.skill.curse.tran_hon_chu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | tran_hon_chu | `tmb.skill.curse.tran_hon_chu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | tran_hon_chu | `tmb.skill.curse.tran_hon_chu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| curse | tran_hon_chu | `tmb.skill.curse.tran_hon_chu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| formation | shared | `tmb.skill.formation.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | shared | `tmb.skill.formation.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | phong_toa_tran | `tmb.skill.formation.phong_toa_tran.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | phong_toa_tran | `tmb.skill.formation.phong_toa_tran.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | phong_toa_tran | `tmb.skill.formation.phong_toa_tran.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | phong_toa_tran | `tmb.skill.formation.phong_toa_tran.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | phong_toa_tran | `tmb.skill.formation.phong_toa_tran.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | sat_phat_tran | `tmb.skill.formation.sat_phat_tran.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | sat_phat_tran | `tmb.skill.formation.sat_phat_tran.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | sat_phat_tran | `tmb.skill.formation.sat_phat_tran.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | sat_phat_tran | `tmb.skill.formation.sat_phat_tran.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | sat_phat_tran | `tmb.skill.formation.sat_phat_tran.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | tu_linh_tran | `tmb.skill.formation.tu_linh_tran.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | tu_linh_tran | `tmb.skill.formation.tu_linh_tran.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | tu_linh_tran | `tmb.skill.formation.tu_linh_tran.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | tu_linh_tran | `tmb.skill.formation.tu_linh_tran.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| formation | tu_linh_tran | `tmb.skill.formation.tu_linh_tran.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | godot/labs/combat_lab/vfx_factory/vfx_factory_review.tscn |
| summon | shared | `tmb.skill.summon.basic.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | khoi_loi_ho_phap | `tmb.skill.summon.khoi_loi_ho_phap.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | khoi_loi_ho_phap | `tmb.skill.summon.khoi_loi_ho_phap.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | khoi_loi_ho_phap | `tmb.skill.summon.khoi_loi_ho_phap.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | khoi_loi_ho_phap | `tmb.skill.summon.khoi_loi_ho_phap.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | khoi_loi_ho_phap | `tmb.skill.summon.khoi_loi_ho_phap.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | kiem_linh | `tmb.skill.summon.kiem_linh.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | kiem_linh | `tmb.skill.summon.kiem_linh.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | kiem_linh | `tmb.skill.summon.kiem_linh.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | kiem_linh | `tmb.skill.summon.kiem_linh.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | kiem_linh | `tmb.skill.summon.kiem_linh.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | linh_thu | `tmb.skill.summon.linh_thu.active_01.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | linh_thu | `tmb.skill.summon.linh_thu.active_02.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | linh_thu | `tmb.skill.summon.linh_thu.active_03.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | linh_thu | `tmb.skill.summon.linh_thu.active_04.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | linh_thu | `tmb.skill.summon.linh_thu.ultimate.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |
| summon | shared | `tmb.skill.summon.mobility.human` | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | OWNER_VISUAL_PENDING | LEDGER_OWNER_GATE | NOT_ART_APPROVED | — |

## Interpretation

- Owner status is derived directly from each row's `owner_gate`. `lab_visual_status` remains the technical/art evidence label supplied by that ledger.
- The current owner prompt states that all 17 Sword Human cast reviews are provisionally accepted. The effective Sword status is `OWNER_PROVISIONAL`; raw ledger owner fields remain intact, and this is not final art approval.
- Immortal and Divine cast rows are compared with their Human family on effect, shape, target limit, and work class. A match is only `CONTRACT_COMPATIBLE_HUMAN_FALLBACK_PENDING`; a mismatch is `FALLBACK_INCOMPATIBLE`.
- Passive and event rows remain `PASSIVE_EVENT_RECEIPT_GATED`. This inventory does not invent `NO_VISUAL_REQUIRED`.
- Bound LAB scenes indicate discoverable scene/script references. They do not establish source-art quality, G3 completion, owner approval, or PvE integration.
