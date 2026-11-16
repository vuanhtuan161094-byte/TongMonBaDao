#!/usr/bin/env python3
"""Evidence-scoped VFX status from 12 canonical 183-ID school ledgers.

Do NOT infer VFX approval from catalogue/CI/schematic preview. Status records
are scoped to Human cast masters and exact owner art decisions. Immortal/divine
art and passive/event VFX are separate unapproved deliverables.
"""
import csv
from pathlib import Path
from collections import Counter
import argparse

ROOT=Path(__file__).resolve().parents[2]
LEDGERS=ROOT/"docs/operations/vfx_school_ledgers"
SCHOOL_FILES=[
 "01_poison_183.csv","02_talisman_183.csv","03_sword_183.csv",
 "04_bow_183.csv","05_fist_183.csv","06_blade_183.csv",
 "07_dual_blade_183.csv","08_spear_183.csv","09_palm_183.csv",
 "10_curse_183.csv","11_formation_183.csv","12_summon_183.csv"]

# Explicitly linked to actual dedicated game-engine LAB scenes in PR #72.
LABS={
 "tmb.skill.poison.co_doc.active_01":"godot/labs/combat_lab/poison03/fu_cot_co.tscn",
 "tmb.skill.poison.co_doc.active_02":"godot/labs/combat_lab/poison02/xa_anh_source_vl_remake.tscn",
 "tmb.skill.poison.co_doc.active_03":"godot/labs/combat_lab/poison04/co_vu_me_tung.tscn",
 "tmb.skill.poison.co_doc.active_04":"godot/labs/combat_lab/poison05/tan_co_dien_nhiem.tscn",
 "tmb.skill.poison.co_doc.ultimate":"godot/labs/combat_lab/poison06/van_co_phe_gioi.tscn",
 "tmb.skill.poison.doc_cham.active_01":"godot/labs/combat_lab/poison07/xuyen_cot_doc_cham.tscn",
 "tmb.skill.poison.doc_cham.active_02":"godot/labs/combat_lab/poison08/phe_mach_doc_thich.tscn",
 "tmb.skill.poison.doc_cham.active_03":"godot/labs/combat_lab/poison09/r1_painted/bach_doc_tan_cham_r1.tscn",
 "tmb.skill.poison.doc_cham.active_04":"godot/labs/combat_lab/poison10/r1_painted/doc_khi_phe_tam_r1.tscn",
 "tmb.skill.talisman.loi_phu.active_01":"godot/labs/combat_lab/talisman01/dien_quang_khai_phu.tscn",
 "tmb.skill.talisman.loi_phu.active_02":"godot/labs/combat_lab/talisman02/thien_loi_dan_net.tscn",
 "tmb.skill.talisman.loi_phu.active_03":"godot/labs/combat_lab/talisman03/loi_van_truy_an.tscn",
 "tmb.skill.talisman.loi_phu.active_04":"godot/labs/combat_lab/talisman04/cuu_tieu_pha_van.tscn",
 "tmb.skill.talisman.loi_phu.ultimate":"godot/labs/combat_lab/talisman05/cuu_thien_van_loi_phu.tscn",
 "tmb.skill.talisman.hoa_phu.active_01":"godot/labs/combat_lab/talisman06/xich_diem_khai_van.tscn",
 "tmb.skill.talisman.hoa_phu.active_02":"godot/labs/combat_lab/talisman07/lien_diem_phan_gioi.tscn",
 "tmb.skill.talisman.hoa_phu.active_03":"godot/labs/combat_lab/talisman08/hoa_tam_ngung_phu.tscn",
 "tmb.skill.talisman.hoa_phu.active_04":"godot/labs/combat_lab/talisman09/chu_tuoc_hoi_hoan.tscn",
 "tmb.skill.talisman.hoa_phu.ultimate":"godot/labs/combat_lab/talisman10/van_phu_phan_thien.tscn",
 "tmb.skill.fist.ba_quyen.active_01":"godot/labs/combat_lab/fist01/khai_son_trong_quyen.tscn",
 "tmb.skill.fist.ba_quyen.active_02":"godot/labs/combat_lab/fist02/phi_than_lien_cuoc.tscn",
 "tmb.skill.fist.ba_quyen.active_03":"godot/labs/combat_lab/fist04/lei_dinh_chan_quyen.tscn",
 "tmb.skill.fist.ba_quyen.active_04":"godot/labs/combat_lab/fist05/dia_mach_lien_chan.tscn",
 "tmb.skill.fist.kim_cang.active_01":"godot/labs/combat_lab/fist06/tran_dia_quyen.tscn",
 "tmb.skill.fist.kim_cang.active_02":"godot/labs/combat_lab/fist07/kim_cang_ho_the.tscn",
}
# Only human-LAB art approvals explicitly known; not gameplay acceptance.
APPROVED={
 "tmb.skill.poison.co_doc.active_01":"THREE_OWNER_APPROVED_POISON_LABS",
 "tmb.skill.poison.co_doc.active_02":"THREE_OWNER_APPROVED_POISON_LABS",
 "tmb.skill.poison.co_doc.active_03":"THREE_OWNER_APPROVED_POISON_LABS",
 "tmb.skill.talisman.loi_phu.active_02":"OWNER_EXPLICIT_TAL02_R6_APPROVAL",
 "tmb.skill.talisman.loi_phu.active_03":"OWNER_EXPLICIT_TAL03_R4_APPROVAL",
 "tmb.skill.talisman.hoa_phu.active_02":"HF02_R6_OWNER_APPROVAL_20261116",
 "tmb.skill.talisman.hoa_phu.active_03":"HF03_R2_OWNER_APPROVAL_20261116",
}
PREVIEW_ONLY={"tmb.skill.poison.co_doc.ultimate":"POI06_R11_OWNER_PREVIEW_ACCEPTED_NATIVE_QA_PASS"}
IN_PROGRESS={"tmb.skill.talisman.hoa_phu.active_04":"HF04_R3_OWNER_PROVISIONAL_USE_ART_REWORK_DEFERRED",
 "tmb.skill.talisman.hoa_phu.ultimate":"HF05_R2_V4_GODOT_PREVIEW_OWNER_PENDING"}

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--out",default="/tmp/tmb-vfx-progress")
    args=p.parse_args()
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    records=[]
    for filename in SCHOOL_FILES:
        with (LEDGERS/filename).open(encoding="utf-8-sig",newline="") as file:
            rows=list(csv.DictReader(file))
        assert len(rows)==183,(filename,len(rows))
        records+=rows
    assert len(records)==2196,len(records)
    assert len({x["skill_id"] for x in records})==2196,"Duplicate skill ids"
    humans=[r for r in records if r["tier"]=="human" and r["visual_work_class"]=="CAST_MASTER"]
    assert len(humans)==204,len(humans)
    assert len({r["family_id"] for r in humans})==204,"Human cast family count inconsistent"
    assert set(LABS)<={r["family_id"] for r in humans}, "A listed LAB is not a canonical Human cast"
    assert all((ROOT / lab).exists() for lab in LABS.values()),"Missing actual LAB scene"
    assert len(LABS)==25 and len(APPROVED)==7
    for r in records:
        is_human_cast=r["tier"]=="human" and r["visual_work_class"]=="CAST_MASTER"
        fam=r["family_id"]
        r["dedicated_human_lab"]=LABS.get(fam,"") if is_human_cast else ""
        if is_human_cast:
            if fam in APPROVED:r["vfx_actual"]="OWNER_VISUAL_APPROVED_HUMAN_LAB"
            elif fam in PREVIEW_ONLY:r["vfx_actual"]="PREVIEW_ACCEPTED_NATIVE_QA_NOT_FINAL_OWNER"
            elif fam in IN_PROGRESS:
                r["vfx_actual"]=("OWNER_PROVISIONAL_USE_ART_REWORK_DEFERRED" if fam=="tmb.skill.talisman.hoa_phu.active_04"
                    else "LAB_G3_5_ART_REWORK_IN_PROGRESS_OWNER_PENDING")
            elif fam in LABS:r["vfx_actual"]="DEDICATED_LAB_OWNER_PENDING_OR_REWORK"
            else:r["vfx_actual"]="NO_DEDICATED_HUMAN_LAB"
        elif r["visual_work_class"]!="CAST_MASTER":
            r["vfx_actual"]="PASSIVE_EVENT_REQUIRES_RUNTIME_RECEIPT_NOT_CAST_MASTER"
        else:
            r["vfx_actual"]="IMMORTAL_DIVINE_VARIANT_NOT_ART_APPROVED"
        r["owner_art_source_note"]=(APPROVED.get(fam) or PREVIEW_ONLY.get(fam) or IN_PROGRESS.get(fam) or "") if is_human_cast else ""
    columns=list(records[0])  # fields include the three just-added status columns
    with (out/"ALL_2196_VFX_STATUS.csv").open("w",encoding="utf-8-sig",newline="") as file:
        w=csv.DictWriter(file,fieldnames=columns);w.writeheader();w.writerows(records)
    with (out/"HUMAN_204_VFX_STATUS.csv").open("w",encoding="utf-8-sig",newline="") as file:
        w=csv.DictWriter(file,fieldnames=columns);w.writeheader();w.writerows(humans)
    school_rows=[]
    for filename in SCHOOL_FILES:
        school_name=filename.split("_",1)[1].replace("_183.csv","")
        r=[h for h in humans if h["school"]==school_name]
        assert len(r)==17,(school_name,len(r))
        school_rows.append([school_name,17,sum(bool(h["dedicated_human_lab"]) for h in r),
            sum(h["vfx_actual"]=="OWNER_VISUAL_APPROVED_HUMAN_LAB" for h in r)])
    lines=["# VFX production inventory — 16 Nov 2026 / PR #72",
      "", "This is a reproducible **source-catalogue + dedicated-LAB / owner decision** audit, NOT a release completeness claim.",
      "12 schools × 183 IDs = **2,196 IDs**, 420 families; **204 Human CAST_MASTER**",
      "(12 × 17), with other tiers/lineages and passive/event categories requiring separate art/event work.",
      "**25/204** distinct Human cast masters have dedicated isolated Godot LAB scenes, **7/204** have explicit owner-art approval as understood at this checkpoint. **179/204** do not have a dedicated Human cast LAB yet.",
      "Technical CI/illustrative previews do **not** count as owner approval or live PvE integration.",
      "HF02 R6 approved 10/10, exact art SHA b5a29f1504078a0e66acc9c79306dc86f5f28463. POI06 R11 accepted *preview* only. HF03 R2 owner visual approved on 16 Nov 2026; exact native art SHA ac3b02b1aa6c0d7e0c5dd7e418c59c4dc52a0bb4. HF04 R3 owner authorized TEMPORARY use only and criticized phoenix art/smoothness; not owner-final approved. HF05 ultimate new isolated LAB, technical/art gates underway.",
      "", "| School | Human cast | Dedicated LAB | Explicit owner approved | Not yet dedicated |",
      "|---|---:|---:|---:|---:|"]
    for name,allnum,labs,approved in school_rows:
        lines.append(f"| {name} | {allnum} | {labs} | {approved} | {allnum-labs} |")
    lines+=["", "## Every Human cast master (204 rows)", "", "| School / branch | Skill | Current VFX reality | LAB path |",
       "|---|---|---|---|"]
    for r in humans:
        lines.append(f"| {r['school']} / {r['branch']} | {r['name_vi']} | {r['vfx_actual']} | {r['dedicated_human_lab'] or '—'} |")
    lines+=["", "## Gate caveats", "",
       "- The published source ledgers have older `lab_visual_status` values; this inventory adds a separate evidence-scoped `vfx_actual` overlay without changing the catalogue or erasing previous historical fields.",
       "- Other-tier variants are **not** automatically VFX-complete just because their family has an approved Human LAB.",
       "- Prototype/batch auto-generated 201 previews and extra noncanonical experiments are **not** included in the 23 individually staged Human cast scenes.",
       "- All approved art remains `PVE_INTEGRATION_HOLD`, actual Combat V2 receipt mapping and real device QA separate.",
       "- Status overlay must be revised after each exact owner decision and actual Godot technical evidence; this report is a dated snapshot.", ""]
    (out/"HUMAN_204_VFX_STATUS.md").write_text("\n".join(lines),encoding="utf-8")
    sums=Counter(r["vfx_actual"] for r in humans)
    print("VFX_INVENTORY_VERIFIED_ALL_IDS=2196 HUMAN_CAST_MASTERS=204 DEDICATED_LABS=25 OWNER_APPROVED=7 NO_DEDICATED_LABS=179")
    print("VFX_INVENTORY_HUMAN_BUCKETS",dict(sums))
    for name,_,labs,approved in school_rows:
        print("VFX_SCHOOL",name,"LAB",labs,"APPROVED",approved)
if __name__=="__main__":main()
