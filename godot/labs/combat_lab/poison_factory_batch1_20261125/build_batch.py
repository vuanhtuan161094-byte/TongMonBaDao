#!/usr/bin/env python3
"""Add the eligible Poison human cast masters to the shared VFX Factory.

This builder only wires existing source art and existing MapBattle receipts.
It neither changes gameplay data nor creates/recolors skill art.
"""
from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]  # repository/godot
REPO = ROOT.parent
BATCH_REL = "labs/combat_lab/poison_factory_batch1_20261125"
BATCH_RES = "res://" + BATCH_REL
REGISTRY_PATH = ROOT / "labs/combat_lab/vfx_factory/registry.json"
WEB_CATALOG_PATH = REPO / "docs/operations/vfx_web_catalog_v1.json"
LEDGER_PATH = REPO / "docs/operations/vfx_school_ledgers/01_poison_183.csv"
HUMAN_CATALOG_PATH = ROOT / "data/combat/v63_human_combat_catalog.json"
REVIEW_SCENE = "res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn"
CAPTURE_SCENE = "res://labs/combat_lab/vfx_factory/vfx_factory_formation_batch_capture.tscn"


def phase(path: str, cell: tuple[int, int] | None, frames: list[int] | list[str],
          width: int, fps: int = 16, loop: bool = False,
          height: int = 0, columns: int = 4) -> dict:
    """Describe one existing atlas sequence or a sequence of SVG frames."""
    if cell is None:
        frame_rows = [{"path": "res://" + item} for item in frames]
        first_path = frames[0] if frames else path
    else:
        first_path = path
        frame_rows = []
        cell_w, cell_h = cell
        for index in frames:
            frame_rows.append({
                "path": "res://" + path,
                "region": [int(index % columns) * cell_w, int(index // columns) * cell_h,
                           cell_w, cell_h],
            })
    row = {
        "path": "res://" + first_path,
        "frames": frame_rows,
        "display_width_px": width,
        "fps": fps,
        "loop": loop,
    }
    if height:
        row["display_height_px"] = height
    return row


def atlas(path: str, cell: tuple[int, int], count: int, width: int,
          fps: int = 16, loop: bool = False, indices: list[int] | None = None,
          columns: int = 4) -> dict:
    return phase(path, cell, indices if indices is not None else list(range(count)),
                 width, fps, loop, columns=columns)


def svg_frames(paths: list[str], width: int, fps: int = 12,
               loop: bool = False) -> dict:
    return phase(paths[0], None, paths, width, fps, loop)


def all_paths(spec: dict) -> list[str]:
    out: list[str] = []
    for source in spec["phase_sources"].values():
        for frame_row in source.get("frames", []):
            path = str(frame_row.get("path", "")).removeprefix("res://")
            if path and path not in out:
                out.append(path)
    for path in spec.get("source_art_paths", []):
        if path not in out:
            out.append(path)
    return out


def skill_spec(skill_id: str, branch: str, slot: str, name: str, revision: str,
               scene: str, phases: dict, art: list[str], width_hint: int,
               action: str = "cast", layer: str = "FRONT",
               mechanic: str | None = None, fixture_kind: str = "monster",
               targets: int = 1, setup: bool = False) -> dict:
    return {
        "skill_id": skill_id, "branch": branch, "slot": slot,
        "name_vi": name, "source_revision": revision,
        "source_scene": scene + ".tscn", "source_script": scene + ".gd",
        "source_art_paths": art, "phase_sources": phases,
        "actor_action": action, "draw_layer": layer,
        "mechanic_template_override": mechanic,
        "fixture_kind": fixture_kind, "fixture_target_count": targets,
        "fixture_poison_setup": setup, "review_width_reference_px": width_hint,
    }


def seq(root: str, base: str, stem: str, count: int, cell: tuple[int, int], width: int,
        fps: int = 16, loop: bool = False, indices: list[int] | None = None,
        columns: int = 4) -> dict:
    path = f"{root}/{base}/{stem}"
    return atlas(path, cell, count, width, fps, loop, indices, columns)


def build_specs() -> list[dict]:
    p = "labs/combat_lab"
    specs = [
        skill_spec(
            "tmb.skill.poison.basic.human", "shared", "basic", "Độc Châm Thường Thức",
            "poison_basic_human_v2", f"{p}/poison_basic_human_v2/doc_cham_thuong_thuc",
            {
                "charge": seq(p, "poison_basic_human_v2/assets/atlas", "poison_basic_charge_06_rgba.png", 6, (192, 192), 82, 16),
                "flight": seq(p, "poison_basic_human_v2/assets/atlas", "poison_basic_flight_08_rgba.png", 8, (288, 160), 148, 20),
                "contact": seq(p, "poison_basic_human_v2/assets/atlas", "poison_basic_contact_08_rgba.png", 8, (256, 256), 114, 18),
                "fade": seq(p, "poison_basic_human_v2/assets/atlas", "poison_basic_contact_08_rgba.png", 8, (256, 256), 92, 12, False, [6, 7]),
            }, [f"{p}/poison_basic_human_v2/assets/atlas/poison_basic_charge_06_rgba.png",
                f"{p}/poison_basic_human_v2/assets/atlas/poison_basic_flight_08_rgba.png",
                f"{p}/poison_basic_human_v2/assets/atlas/poison_basic_contact_08_rgba.png"], 148,
            action="attack", mechanic="projectile"),
        skill_spec(
            "tmb.skill.poison.co_doc.active_01.human", "co_doc", "active_01", "Phụ Cốt Cổ",
            "poison03/fu_cot_co", f"{p}/poison03/fu_cot_co",
            {
                "charge": svg_frames([f"{p}/poison03/assets/fu_cot_bone_seal.svg"], 56),
                "release": svg_frames([f"{p}/poison03/assets/fu_cot_gu_master.svg"], 118),
                "contact": svg_frames([f"{p}/poison03/assets/fu_cot_bone_seal.svg"], 74),
                "start": svg_frames([f"{p}/poison03/assets/fu_cot_bone_seal.svg"], 58),
                "sustain": svg_frames([f"{p}/poison03/assets/fu_cot_bone_seal.svg"], 52, 6, True),
                "end": svg_frames([f"{p}/poison03/assets/fu_cot_gu_master.svg"], 68),
            }, [f"{p}/poison03/assets/fu_cot_bone_seal.svg", f"{p}/poison03/assets/fu_cot_gu_master.svg"], 118,
            mechanic="debuff"),
        skill_spec(
            "tmb.skill.poison.co_doc.active_02.human", "co_doc", "active_02", "Xà Ảnh Quấn Mạch",
            "poison02/xa_anh_source_vl_remake", f"{p}/poison02/xa_anh_source_vl_remake",
            {
                "charge": seq(p, "poison02/assets", "serpent-bind-back-4pose.webp", 4, (128, 128), 76, 10, columns=2),
                "flight": seq(p, "poison02/assets", "serpent-flight-atlas.webp", 6, (512, 179), 150, 18, columns=3),
                "contact": seq(p, "poison02/assets", "serpent-bind-front-4pose.webp", 4, (128, 128), 112, 12, columns=2),
                "start": seq(p, "poison02/assets", "serpent-bind-front-4pose.webp", 4, (128, 128), 58, 10, columns=2),
                "sustain": seq(p, "poison02/assets", "serpent-bind-front-4pose.webp", 4, (128, 128), 54, 5, True, columns=2),
                "end": seq(p, "poison02/assets", "serpent-bind-back-4pose.webp", 4, (128, 128), 66, 8, columns=2),
            }, [f"{p}/poison02/assets/serpent-flight-atlas.webp", f"{p}/poison02/assets/serpent-bind-back-4pose.webp",
                f"{p}/poison02/assets/serpent-bind-front-4pose.webp", f"{p}/poison02/assets/serpent-head.webp"], 150),
        skill_spec(
            "tmb.skill.poison.co_doc.active_03.human", "co_doc", "active_03", "Cổ Vụ Mê Tung",
            "poison04/co_vu_me_tung", f"{p}/poison04/co_vu_me_tung",
            {
                "charge": svg_frames([f"{p}/poison04/assets/co_vu_smoke_tendril.svg"], 108),
                "release": svg_frames([f"{p}/poison04/assets/co_vu_painted_cloud.svg"], 310),
                "contact": svg_frames([f"{p}/poison04/assets/co_vu_gu_moth.svg"], 70),
                "start": svg_frames([f"{p}/poison04/assets/co_vu_gu_moth.svg"], 48),
                "sustain": svg_frames([f"{p}/poison04/assets/co_vu_painted_cloud.svg"], 270, 6, True),
                "end": svg_frames([f"{p}/poison04/assets/co_vu_smoke_tendril.svg"], 170),
            }, [f"{p}/poison04/assets/co_vu_gu_moth.svg", f"{p}/poison04/assets/co_vu_painted_cloud.svg",
                f"{p}/poison04/assets/co_vu_smoke_tendril.svg"], 310, layer="BEHIND", mechanic="circle_aoe", targets=3),
        skill_spec(
            "tmb.skill.poison.co_doc.active_04.human", "co_doc", "active_04", "Tán Cổ Diễn Nhiễm",
            "poison05/remake_r6", f"{p}/poison05/remake_r6/tan_co_dien_nhiem_r6",
            {
                "charge": svg_frames([f"{p}/poison05/remake_r6/assets/seed_{i}.svg" for i in range(6)], 104, 12),
                "release": svg_frames([f"{p}/poison05/remake_r6/assets/gu_swarm_{i}.svg" for i in range(8)], 250, 16),
                "contact": svg_frames([f"{p}/poison05/remake_r6/assets/mark_{i}.svg" for i in range(6)], 110, 14),
                "start": svg_frames([f"{p}/poison05/remake_r6/assets/mark_{i}.svg" for i in range(6)], 64, 12),
                "sustain": svg_frames([f"{p}/poison05/remake_r6/assets/gu_{i:02d}.svg" for i in range(12)], 105, 8, True),
                "end": svg_frames([f"{p}/poison05/remake_r6/assets/seed_{i}.svg" for i in range(6)], 72, 10),
            }, [f"{p}/poison05/remake_r6/assets/{name}" for name in
                [*(f"gu_{i:02d}.svg" for i in range(12)), *(f"gu_swarm_{i}.svg" for i in range(8)),
                 *(f"mark_{i}.svg" for i in range(6)), *(f"seed_{i}.svg" for i in range(6)), "immortal_valley.svg"]], 250,
            layer="BEHIND", mechanic="circle_aoe", targets=3),
        skill_spec(
            "tmb.skill.poison.co_doc.ultimate.human", "co_doc", "ultimate", "Vạn Cổ Phệ Giới",
            "poison06/r11_candidate", f"{p}/poison06/r11_candidate/van_co_phe_gioi_r11",
            {
                "charge": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 144, 12, False, list(range(0, 8)), 8),
                "release": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 336, 18, False, list(range(8, 22)), 8),
                "contact": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 272, 16, False, list(range(20, 34)), 8),
                "start": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 110, 14, False, list(range(24, 32)), 8),
                "sustain": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 96, 8, True, list(range(28, 44)), 8),
                "end": seq(p, "poison06/r11_candidate/assets", "realm_vortex_r11_48.png", 48, (256, 256), 124, 10, False, list(range(42, 48)), 8),
            }, [f"{p}/poison06/r11_candidate/assets/realm_vortex_r11_48.png",
                *[f"{p}/poison06/assets/abyss_{kind}_{i}.svg" for kind, count in (("brand", 6), ("gu", 8)) for i in range(count)]], 336,
            layer="BEHIND", mechanic="circle_aoe", targets=3),
        skill_spec(
            "tmb.skill.poison.doc_cham.active_01.human", "doc_cham", "active_01", "Xuyên Cốt Độc Châm",
            "poison07/r7_painted", f"{p}/poison07/r7_painted/xuyen_cot_doc_cham_r7",
            {
                "charge": seq(p, "poison07/r7_painted/assets", "painted_charge_r7_10.png", 12, (224, 224), 92, 16, False, list(range(10))),
                "flight": seq(p, "poison07/r7_painted/assets", "painted_needle_r7_12.png", 12, (384, 128), 172, 20),
                "contact": seq(p, "poison07/r7_painted/assets", "painted_puncture_r7_12.png", 12, (224, 224), 132, 18),
                "fade": seq(p, "poison07/r7_painted/assets", "painted_puncture_r7_12.png", 12, (224, 224), 92, 10, False, [10, 11]),
            }, [f"{p}/poison07/r7_painted/assets/{name}" for name in
                ["painted_charge_r7_10.png", "painted_needle_r7_12.png", "painted_puncture_r7_12.png",
                 "master/needle_painted_source.webp", "master/palm_painted_source.webp", "master/puncture_painted_source.webp"]], 172),
        skill_spec(
            "tmb.skill.poison.doc_cham.active_02.human", "doc_cham", "active_02", "Phệ Mạch Độc Thích",
            "poison08/r4_painted", f"{p}/poison08/r4_painted/phe_mach_doc_thich_r4",
            {
                "charge": seq(p, "poison08/r4_painted/assets", "thorn_seed_r4_10.png", 12, (192, 192), 74, 16, False, list(range(10))),
                "flight": seq(p, "poison08/r4_painted/assets", "living_barb_r4_12.png", 12, (384, 128), 170, 20),
                "contact": seq(p, "poison08/r4_painted/assets", "bite_contact_r4_08.png", 8, (192, 192), 114, 18),
                "start": seq(p, "poison08/r4_painted/assets", "vein_mark_r4_12.png", 12, (192, 192), 64, 16),
                "sustain": seq(p, "poison08/r4_painted/assets", "vein_mark_r4_12.png", 12, (192, 192), 54, 7, True),
                "end": seq(p, "poison08/r4_painted/assets", "vein_mark_r4_12.png", 12, (192, 192), 64, 10, False, [9, 10, 11]),
            }, [f"{p}/poison08/r4_painted/assets/{name}" for name in
                ["living_barb_r4_12.png", "thorn_seed_r4_10.png", "bite_contact_r4_08.png", "vein_mark_r4_12.png",
                 "master/toxin_barb_painted.webp"]], 170),
        skill_spec(
            "tmb.skill.poison.doc_cham.active_03.human", "doc_cham", "active_03", "Bách Độc Tán Châm",
            "poison09/r1_painted", f"{p}/poison09/r1_painted/bach_doc_tan_cham_r1",
            {
                "charge": seq(p, "poison09/r1_painted/assets", "poison_fan_charge_r1_12.png", 12, (224, 160), 166, 16),
                "release": seq(p, "poison09/r1_painted/assets", "poison_fan_needle_r1_12.png", 12, (256, 96), 244, 18),
                "contact": seq(p, "poison09/r1_painted/assets", "poison_fan_contact_r1_10.png", 10, (192, 160), 136, 16),
                "start": seq(p, "poison09/r1_painted/assets", "poison_fan_mark_r1_12.png", 12, (192, 160), 72, 14),
                "sustain": seq(p, "poison09/r1_painted/assets", "poison_fan_mark_r1_12.png", 12, (192, 160), 56, 8, True),
                "end": seq(p, "poison09/r1_painted/assets", "poison_fan_mark_r1_12.png", 12, (192, 160), 70, 10, False, [9, 10, 11]),
            }, [f"{p}/poison09/r1_painted/assets/{name}" for name in
                ["poison_fan_charge_r1_12.png", "poison_fan_needle_r1_12.png", "poison_fan_contact_r1_10.png",
                 "poison_fan_mark_r1_12.png", "master/burst_contact_master.webp", "master/fanlotus_charge_master.webp",
                 "master/poison_needle_master.webp", "master/sixsecond_toxin_master.webp"]], 244,
            layer="BEHIND"),
        skill_spec(
            "tmb.skill.poison.doc_cham.active_04.human", "doc_cham", "active_04", "Độc Khí Phệ Tâm",
            "poison10/r2_remake", f"{p}/poison10/r2_remake/doc_khi_phe_tam_r2",
            {
                "charge": seq(p, "poison10/r2_remake/assets", "poison10_r2_charge_10.png", 10, (192, 192), 98, 16),
                "release": seq(p, "poison10/r2_remake/assets", "poison10_r2_bloom_12.png", 12, (384, 256), 306, 18),
                "contact": seq(p, "poison10/r2_remake/assets", "poison10_r2_contact_08.png", 8, (192, 160), 138, 16),
                "start": seq(p, "poison10/r2_remake/assets", "poison10_r2_contact_08.png", 8, (192, 160), 68, 12),
                "sustain": seq(p, "poison10/r2_remake/assets", "poison10_r2_bloom_12.png", 12, (384, 256), 128, 7, True),
                "end": seq(p, "poison10/r2_remake/assets", "poison10_r2_contact_08.png", 8, (192, 160), 82, 10, False, [6, 7]),
            }, [f"{p}/poison10/r2_remake/assets/{name}" for name in
                ["poison10_r2_charge_10.png", "poison10_r2_bloom_12.png", "poison10_r2_contact_08.png",
                 "master/poi10_bloom_master.webp", "master/poi10_charge_master.webp", "master/poi10_contact_master.webp"]], 306,
            layer="BEHIND", mechanic="circle_aoe", targets=3),
        skill_spec(
            "tmb.skill.poison.doc_cham.ultimate.human", "doc_cham", "ultimate", "Vạn Độc Xuyên Tâm",
            "poison11/r1_original", f"{p}/poison11/r1_original/van_doc_xuyen_tam_r1",
            {
                "charge": seq(p, "poison11/r1_original/assets", "poison11_charge_10.png", 10, (192, 192), 124, 16),
                "flight": seq(p, "poison11/r1_original/assets", "poison11_flight_10.png", 10, (224, 160), 164, 18),
                "release": seq(p, "poison11/r1_original/assets", "poison11_crown_10_r9.png", 10, (320, 192), 340, 18),
                "contact": seq(p, "poison11/r1_original/assets", "poison11_contact_08.png", 8, (192, 160), 176, 16),
                "start": seq(p, "poison11/r1_original/assets", "poison11_contact_08.png", 8, (192, 160), 82, 12),
                "sustain": seq(p, "poison11/r1_original/assets", "poison11_crown_10_r9.png", 10, (320, 192), 146, 8, True),
                "end": seq(p, "poison11/r1_original/assets", "poison11_crown_10_r9.png", 10, (320, 192), 102, 10, False, [8, 9]),
            }, [f"{p}/poison11/r1_original/assets/{name}" for name in
                ["poison11_charge_10.png", "poison11_flight_10.png", "poison11_crown_10_r9.png",
                 "poison11_contact_08.png", "poison11_crown_10_r9.png", "master/heart_piercer_source.webp",
                 "master/heart_rupture_source.webp", "master/heart_vortex_source.webp", "master/needle_crown_source.webp"]], 340,
            layer="BEHIND", targets=3),
        skill_spec(
            "tmb.skill.poison.duoc_doc.active_02.human", "duoc_doc", "active_02", "Giải Độc Hộ Tâm",
            "poison13_heal_heart/r2", f"{p}/poison13_heal_heart/r2/giai_doc_ho_tam_energy",
            {
                "charge": seq(p, "poison13_heal_heart/r2/assets", "poi13_r2_charge_08.png", 8, (192, 192), 88, 16),
                "release": seq(p, "poison13_heal_heart/r2/assets", "poi13_r2_release_10.png", 10, (256, 256), 148, 16),
                "contact": seq(p, "poison13_heal_heart/r2/assets", "poi13_r2_aura_12.png", 12, (256, 256), 184, 16),
                "fade": seq(p, "poison13_heal_heart/r2/assets", "poi13_r2_release_10.png", 10, (256, 256), 110, 10, False, [8, 9]),
            }, [f"{p}/poison13_heal_heart/r2/assets/{name}" for name in
                ["poi13_r2_charge_08.png", "poi13_r2_release_10.png", "poi13_r2_aura_12.png",
                 "master/poi13_r2_aura_source_rgba.png", "master/poi13_r2_charge_source_rgba.png",
                 "master/poi13_r2_release_source_rgba.png"]], 184,
            mechanic="heal", fixture_kind="ally", setup=True),
        skill_spec(
            "tmb.skill.poison.duoc_doc.active_03.human", "duoc_doc", "active_03", "Nghịch Độc Phản Chế",
            "poison14_cleanse/r1", f"{p}/poison14_cleanse/r1/nghich_doc_phan_che",
            {
                "charge": seq(p, "poison14_cleanse/r1/assets", "poi14_charge_08.png", 8, (192, 192), 92, 16),
                "release": seq(p, "poison14_cleanse/r1/assets", "poi14_sever_12.png", 12, (256, 256), 158, 18),
                "contact": seq(p, "poison14_cleanse/r1/assets", "poi14_purge_10.png", 10, (256, 256), 164, 16),
                "fade": seq(p, "poison14_cleanse/r1/assets", "poi14_purge_10.png", 10, (256, 256), 104, 10, False, [8, 9]),
            }, [f"{p}/poison14_cleanse/r1/assets/{name}" for name in
                ["poi14_charge_08.png", "poi14_sever_12.png", "poi14_purge_10.png",
                 "master/poi14_charge_source_rgba.png", "master/poi14_purge_source_rgba.png",
                 "master/poi14_sever_source_rgba.png"]], 164,
            mechanic="debuff", fixture_kind="ally", setup=True),
        skill_spec(
            "tmb.skill.poison.duoc_doc.active_04.human", "duoc_doc", "active_04", "Hóa Độc Tán",
            "poison15_hoa_doc_tan/r1", f"{p}/poison15_hoa_doc_tan/r1/hoa_doc_tan",
            {
                "charge": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_charge_08.png", 8, (192, 192), 106, 16),
                "release": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_field_12.png", 12, (320, 320), 274, 18),
                "contact": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_mark_08.png", 8, (128, 128), 108, 16),
                "start": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_mark_08.png", 8, (128, 128), 62, 14),
                "sustain": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_mark_08.png", 8, (128, 128), 52, 6, True),
                "end": seq(p, "poison15_hoa_doc_tan/r1/assets", "poi15_mark_08.png", 8, (128, 128), 66, 9, False, [6, 7]),
            }, [f"{p}/poison15_hoa_doc_tan/r1/assets/{name}" for name in
                ["poi15_charge_08.png", "poi15_field_12.png", "poi15_mark_08.png",
                 "master/poi15_charge_master_rgba.png", "master/poi15_field_master_rgba.png",
                 "master/poi15_mark_master_rgba.png"]], 274,
            layer="BEHIND", mechanic="circle_aoe", targets=3),
        skill_spec(
            "tmb.skill.poison.duoc_doc.ultimate.human", "duoc_doc", "ultimate", "Vạn Linh Giải Ách",
            "poison16_van_linh_giai_ach/r2", f"{p}/poison16_van_linh_giai_ach/r2/van_linh_giai_ach_semantic",
            {
                "charge": seq(p, "poison16_van_linh_giai_ach/r2/assets", "poi16_r2_seed_08.png", 8, (192, 192), 112, 14),
                "release": seq(p, "poison16_van_linh_giai_ach/r2/assets", "poi16_r2_stream_10.png", 10, (384, 96), 192, 18),
                "contact": seq(p, "poison16_van_linh_giai_ach/r2/assets", "poi16_r2_herb_12.png", 12, (384, 320), 218, 16),
                "fade": seq(p, "poison16_van_linh_giai_ach/r2/assets", "poi16_r2_fade_08.png", 8, (256, 224), 176, 12),
            }, [f"{p}/poison16_van_linh_giai_ach/r2/assets/{name}" for name in
                ["poi16_r2_seed_08.png", "poi16_r2_herb_12.png", "poi16_r2_stream_10.png",
                 "poi16_r2_seal_10.png", "poi16_r2_fade_08.png", "master/poi16_r2_fade_master_rgba.png",
                 "master/poi16_r2_herb_master_rgba.png", "master/poi16_r2_seal_master_rgba.png",
                 "master/poi16_r2_seed_master_rgba.png", "master/poi16_r2_stream_master_rgba.png"]], 218,
            mechanic="heal", fixture_kind="ally", targets=3, setup=True),
        skill_spec(
            "tmb.skill.poison.mobility.human", "shared", "mobility", "Yểm Ảnh Bộ",
            "poison17_yem_anh_bo/r1", f"{p}/poison17_yem_anh_bo/r1/yem_anh_bo",
            {
                "charge": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_gather_08.png", 8, (256, 224), 88, 14),
                "release": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_stride_12.png", 12, (320, 160), 180, 18),
                "contact": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_landing_08.png", 8, (256, 224), 152, 16),
                "start": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_footprint_12.png", 12, (256, 192), 96, 16),
                "sustain": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_stride_12.png", 12, (320, 160), 152, 12, True),
                "end": seq(p, "poison17_yem_anh_bo/r1/assets", "poi17_landing_08.png", 8, (256, 224), 166, 12),
            }, [f"{p}/poison17_yem_anh_bo/r1/assets/{name}" for name in
                ["poi17_gather_08.png", "poi17_stride_12.png", "poi17_footprint_12.png", "poi17_landing_08.png",
                 "master/poi17_footprint_master_rgba.png", "master/poi17_gather_master_rgba.png",
                 "master/poi17_landing_master_rgba.png", "master/poi17_stride_master_rgba.png"]], 180,
            action="run", mechanic="mobility"),
    ]
    return specs


def frame_paths(phases: dict) -> list[str]:
    result: list[str] = []
    for row in phases.values():
        for frame_row in row.get("frames", []):
            path = str(frame_row.get("path", "")).removeprefix("res://")
            if path and path not in result:
                result.append(path)
    return result


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    specs = build_specs()
    ledger = {row["skill_id"]: row for row in csv.DictReader(LEDGER_PATH.open(encoding="utf-8-sig"))
              if row["tier"] == "human" and row["visual_work_class"] == "CAST_MASTER"}
    catalog = {row["id"]: row for row in json.loads(HUMAN_CATALOG_PATH.read_text(encoding="utf-8"))["skills"]}
    registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    web = json.loads(WEB_CATALOG_PATH.read_text(encoding="utf-8"))
    batch_ids = {item["skill_id"] for item in specs}
    registry["entries"] = [row for row in registry["entries"] if row.get("skill_id") not in batch_ids]
    web["entries"] = [row for row in web["entries"] if row.get("id") not in batch_ids]
    if len(specs) != 16:
        raise SystemExit(f"Expected 16 source-eligible Poison masters; found {len(specs)}")

    new_entries: list[dict] = []
    new_web_entries: list[dict] = []
    source_rows: list[dict] = []
    for batch_index, spec in enumerate(specs, 1):
        sid = spec["skill_id"]
        owner_row = ledger.get(sid)
        definition = catalog.get(sid)
        if owner_row is None or definition is None:
            raise SystemExit(f"Missing ledger/catalog row for {sid}")
        if sid == "tmb.skill.poison.duoc_doc.active_01.human":
            raise SystemExit("Blocked art-rework skill must not be emitted")
        source_scene = ROOT / spec["source_scene"].removeprefix("res://")
        source_script = ROOT / spec["source_script"].removeprefix("res://")
        if not source_scene.is_file() or not source_script.is_file():
            raise SystemExit(f"Missing frozen source revision for {sid}")
        artwork = frame_paths(spec["phase_sources"])
        for path in artwork:
            if not (ROOT / path).is_file():
                raise SystemExit(f"Missing art source for {sid}: {path}")
        for path in spec["source_art_paths"]:
            if not (ROOT / path).is_file():
                raise SystemExit(f"Missing provenance art source for {sid}: {path}")

        effect = str(definition["effect"])
        shape = str(definition["shape"])
        limit = int(definition["target_limit"])
        is_circle = shape == "circle"
        is_ally = spec["fixture_kind"] == "ally"
        preview_targets: list[dict] = []
        for target_index in range(min(limit, spec["fixture_target_count"])):
            if is_ally:
                x = 4.8 + [0.0, 0.45, -0.4][target_index]
                y = 3.0 + [0.0, 0.15, -0.15][target_index]
                actor_id = f"ally_{batch_index - 1:02d}" if target_index == 0 else f"poison_factory_ally_{batch_index:02d}_{target_index + 1:02d}"
                label = f"ALLY {target_index + 1:02d}"
            elif is_circle:
                x = 5.0 + [0.0, 0.85, 0.3][target_index]
                y = 3.0 + [0.0, 0.05, 0.7][target_index]
                actor_id = f"poison_factory_target_{batch_index:02d}_{target_index + 1:02d}"
                label = f"T{target_index + 1} · IN RANGE"
            else:
                x, y = 5.0, 3.0
                actor_id = f"poison_factory_target_{batch_index:02d}_01"
                label = "TARGET 01 · IN RANGE"
            screen = [round(300 + (x - 2.0) * 130), round(492 + (y - 3.0) * 48)]
            preview_targets.append({
                "id": actor_id, "label": label, "screen_position": screen,
                "fixture_position": [x, y],
                "fixture_motion_delta": [0.0, -0.04] if not is_ally else [0.0, 0.0],
            })
        outside = {"id": f"poison_factory_outside_{batch_index:02d}",
                   "label": "OUTSIDE EFFECT RADIUS · UNCHANGED",
                   "fixture_position": [8.0, 4.6], "screen_position": [1080, 569]}

        target_mode = "ally" if is_ally else ("circle" if is_circle else "single_target")
        if spec["mechanic_template_override"]:
            mechanic = spec["mechanic_template_override"]
        elif effect == "poison":
            mechanic = "circle_aoe" if is_circle else "projectile"
        else:
            mechanic = "projectile" if spec["slot"] == "basic" else effect
        if effect in ["poison", "mark"]:
            mechanics = [mechanic, "debuff", "status"]
        elif effect == "heal":
            mechanics = ["heal"] + (["circle_aoe", "multi_target"] if is_circle else [])
        elif effect == "cleanse":
            mechanics = ["debuff", "status"]
        elif effect == "mobility":
            mechanics = ["mobility"]
        else:
            mechanics = [mechanic]

        bindings = []
        if spec["slot"] != "basic":
            bindings.extend([
                {"event_type": "skill_cast", "caster_slot": "hand_r", "target_slot": "ground",
                 "actor_clip": spec["actor_action"], "visual_phase": "charge"},
                {"event_type": "skill_release", "caster_slot": "hand_r", "target_slot": "ground",
                 "actor_clip": spec["actor_action"], "visual_phase": "release"},
            ])
        if spec["slot"] == "basic":
            bindings.append({"event_type": "hit", "caster_slot": "weapon_tip", "target_slot": "chest",
                             "actor_clip": "attack", "visual_phase": "contact"})
        elif effect in ["damage", "poison", "mark"]:
            bindings.append({"event_type": "v63_skill_hit", "caster_slot": "hand_r", "target_slot": "chest",
                             "actor_clip": "cast", "visual_phase": "contact"})
        elif effect == "heal":
            bindings.append({"event_type": "heal", "caster_slot": "hand_r", "target_slot": "chest",
                             "actor_clip": "cast", "visual_phase": "contact"})
        elif effect == "cleanse":
            bindings.append({"event_type": "cleanse", "caster_slot": "hand_r", "target_slot": "chest",
                             "actor_clip": "cast", "visual_phase": "contact"})
        elif effect == "mobility":
            bindings.append({"event_type": "v63_mobility", "caster_slot": "foot", "target_slot": "foot",
                             "actor_clip": "run", "visual_phase": "start"})
        if effect in ["poison", "mark"]:
            bindings.append({"event_type": "status_applied", "caster_slot": "hand_r", "target_slot": "chest",
                             "actor_clip": "cast", "visual_phase": "start"})

        cast = float(definition.get("cast_time", 0.0))
        duration = float(definition.get("duration", 0.0))
        timeline = {
            "release_at": max(0.16, cast),
            "flight_at": max(0.16, cast),
            "contact_at": max(0.48, cast + 0.45),
            "fade_at": max(0.76, cast + 0.72),
            "loop_seconds": max(1.25, cast + min(duration, 0.0) + 0.9),
            "charge_window_seconds": max(0.16, min(cast, 0.55)),
            "release_window_seconds": 0.18,
            "contact_window_seconds": 0.24,
            "start_window_seconds": 0.18,
            "end_window_seconds": 0.22,
            "fade_window_seconds": 0.28,
            "actor_action_seconds": max(0.28, cast),
            "clock": "MAPBATTLE_RECEIPT_FOR_EVENTS; REVIEW_TIMING_ONLY_FOR_PRECONTACT_CUES",
        }
        # Source status and original owner gate are recorded separately from the
        # new Factory adapter state. No old approval is transferred to the adapter.
        artifact_paths = all_paths(spec)
        source_paths = [
            "data/combat/v63_human_combat_catalog.json",
            "labs/combat_lab/vfx_factory/registry.json",
            "labs/combat_lab/vfx_factory/vfx_factory_review.gd",
            "labs/combat_lab/vfx_factory/vfx_factory_formation_batch_capture.gd",
            "labs/combat_lab/vfx_factory/vfx_factory_review.tscn",
            f"{BATCH_REL}/build_batch.py", f"{BATCH_REL}/manifest.json",
            spec["source_scene"].removeprefix("res://"),
            spec["source_script"].removeprefix("res://"),
            *artifact_paths,
        ]
        entry = {
            "skill_id": sid, "school": "poison", "branch": spec["branch"],
            "name_vi": spec["name_vi"], "catalog_path": "res://data/combat/v63_human_combat_catalog.json",
            "effect": effect, "shape": shape, "target_limit": limit,
            "mechanic_template": mechanic, "mechanic_templates": list(dict.fromkeys(mechanics)),
            "target_mode": target_mode, "preview_target_kind": "ally" if is_ally else "monster",
            "target_actor_id": preview_targets[0]["id"], "outside_actor_id": outside["id"],
            "preview_targets": preview_targets, "preview_outside": outside,
            "showcase_moving_target": not is_ally,
            "actor_sex": "male", "actor_asset_id": 62, "actor_action": spec["actor_action"],
            "facing_vector": [0.0, 1.0], "preview_attachment_override": {"suppress_attachments": True},
            "source_anchor": "target_foot" if is_circle else "hand_r",
            "phase_anchors": {
                "charge": "hand_r", "flight": "hand_r", "release": "target_foot",
                "contact": "target_chest", "fade": "target_chest", "start": "target_chest",
                "sustain": "target_chest", "end": "target_chest",
            },
            "phase_aliases": {"travel": "flight"}, "draw_layer": spec["draw_layer"],
            "phase_layers": {"release": "BEHIND", "start": "FRONT", "sustain": "FRONT",
                             "end": "FRONT", "contact": "FRONT", "fade": "FRONT"},
            "phase_sources": spec["phase_sources"], "delivery_phase": "flight" if "flight" in spec["phase_sources"] else "release",
            "review_timeline": timeline,
            "source_g3": "EXISTING_SOURCE_GATE_PRESERVED; FACTORY_ADAPTER_G3_REVIEW_PENDING",
            "source_revision": spec["source_revision"],
            "source_lab_visual_status": owner_row["lab_visual_status"],
            "source_owner_gate": owner_row["owner_gate"],
            "native_status": "NATIVE_PENDING",
            "native_ready": False,
            "owner_status": "OWNER_VISUAL_PENDING_FACTORY_ADAPTER",
            "motion_status": "SOURCE_FRAME_SEQUENCE_IN_SHARED_RENDERER; CONTINUOUS_STYLE_REVIEW_PENDING",
            "source_batch_manifest": f"{BATCH_RES}/manifest.json",
            "receipt_manifest": {"schema": "tmb.vfx_bindings.v1", "skill_id": sid, "bindings": bindings},
            "native_batch": "poison",
            "review_note": (f"Factory candidate reuses {spec['source_revision']} byte-for-byte; original LAB/owner state is preserved in source metadata. "
                "AS62 and the canonical Human catalog supply scale and mechanic data. Contact and poison state require the exact MapBattle receipt; "
                "only captured actor status-stack expiry is used for poison duration. Factory adapter owner review and native capture are pending; PvE HOLD."),
            "source_paths": list(dict.fromkeys(source_paths)),
        }
        if spec["fixture_poison_setup"]:
            entry["fixture_setup"] = {"skill_id": "tmb.skill.poison.doc_cham.active_02.human",
                                       "targets": [row["id"] for row in preview_targets]}
        new_entries.append(entry)
        source_gate = owner_row["owner_gate"]
        web_entry = {
            "id": sid,
            "name_vi": f"{spec['name_vi']} · Factory candidate ({spec['source_revision']})",
            "school_vi": "Độc Tu",
            "branch_vi": {"shared": "Chung", "co_doc": "Cổ Độc", "doc_cham": "Độc Châm", "duoc_doc": "Dược Độc"}.get(spec["branch"], spec["branch"]),
            "tier": "human", "scene": REVIEW_SCENE, "directions": ["front"],
            "vfx_status": "CANDIDATE_G3",
            "g3_art": f"EXISTING_SOURCE_GATE_PRESERVED_{owner_row['lab_visual_status']}_FACTORY_ADAPTER_PENDING",
            "owner_art": f"FACTORY_ADAPTER_OWNER_REVIEW_PENDING_SOURCE_GATE_{source_gate}",
            "source_paths": list(dict.fromkeys(source_paths)),
            "art_source": f"REUSED_EXISTING_SKILL_SOURCE_{spec['source_revision']}_NO_RECOLOR_OR_NEW_ART",
            "review_note": ("Shared receipt-gated Factory scene. This catalog row does not transfer the source LAB or owner gate to its new adapter. "
                "Native capture uses real MapBattle V2 fixtures; contact/status remains hidden until the matching receipt. PvE HOLD."),
        }
        new_web_entries.append(web_entry)
        source_rows.append({
            "skill_id": sid, "name_vi": spec["name_vi"], "branch": spec["branch"],
            "source_revision": spec["source_revision"], "source_scene": spec["source_scene"],
            "source_script": spec["source_script"], "source_lab_visual_status": owner_row["lab_visual_status"],
            "source_owner_gate": source_gate, "new_factory_adapter": "CANDIDATE_OWNER_REVIEW_PENDING",
            "phase_art_sha256": {path: sha(ROOT / path) for path in artifact_paths},
            "phase_count": {key: len(value.get("frames", [])) for key, value in spec["phase_sources"].items()},
        })

    registry["entries"].extend(new_entries)
    registry.setdefault("native_batches", {})["poison"] = {
        "expected_count": 16, "technical_status": "NATIVE_PENDING",
        "last_capture_index": f"{BATCH_RES}/review/native/poison_batch1_capture_index.json",
        "video": f"{BATCH_RES}/review/native/poison_batch1_native_1280x720.mp4",
        "contact_sheet": f"{BATCH_RES}/review/native/poison_batch1_contact_sheet_1280x720.png",
        "receipt_status": "PENDING_REAL_MAPBATTLE_V2_FIXTURE_CAPTURE; NO_SYNTHETIC_EVENTS",
        "visual_review_status": "PENDING_1X_SPOT_CHECK",
        "owner_approval": "PENDING_FACTORY_ADAPTER_REVIEW", "pve": "HOLD",
    }
    registry.setdefault("batch_status", {})["poison_human_cast_batch1_20261125"] = {
        "source_status": "REUSED_COMMITTED_SOURCE_REVISIONS; FACTORY_ADAPTER_CANDIDATE",
        "source_eligible_skill_count": 16,
        "excluded_art_rework": "tmb.skill.poison.duoc_doc.active_01.human",
        "native_import_capture": "NATIVE_PENDING",
        "owner_approval": "PENDING_FACTORY_ADAPTER_REVIEW", "pve": "HOLD",
    }
    web["entries"].extend(new_web_entries)
    write_json(REGISTRY_PATH, registry)
    write_json(WEB_CATALOG_PATH, web)
    manifest = {
        "schema": "tmb.vfx_factory_source_batch.v1",
        "batch_id": "poison_human_cast_batch1_20261125",
        "source_status": "REUSED_EXISTING_SOURCE; FACTORY_ADAPTER_CANDIDATE; NATIVE_PENDING",
        "factory_scene": REVIEW_SCENE, "native_capture_scene": CAPTURE_SCENE,
        "skill_count": len(source_rows),
        "excluded": [{"skill_id": "tmb.skill.poison.duoc_doc.active_01.human",
                      "reason": ledger["tmb.skill.poison.duoc_doc.active_01.human"]["lab_visual_status"],
                      "owner_gate": ledger["tmb.skill.poison.duoc_doc.active_01.human"]["owner_gate"]}],
        "shared_actor": {"school": "poison", "sex": "male", "aschar_id": 62,
                         "scale_source": "ASCHAR_FACTORY_BRIDGE_AND_GAME_VIEW_SCALE"},
        "source_art_policy": "Existing revision files are read-only; no synthesized, recolored, or copied art.",
        "combat_contract": "Canonical Human catalog + exact MapBattle V2 receipt; no synthetic hit or status.",
        "owner_approval": "PENDING_FACTORY_ADAPTER_REVIEW",
        "pve": "HOLD",
        "skills": source_rows,
    }
    write_json(ROOT / f"{BATCH_REL}/manifest.json", manifest)
    readme = (
        "# Độc Tu · VFX Factory batch 1\n\n"
        "16 source-backed Human cast masters reuse their committed revision and the shared AS62 Factory renderer. "
        "`manifest.json` records original LAB/owner gates and hashes; the new Factory adapter remains a candidate.\n\n"
        "Contact and status cues bind only to exact MapBattle V2 events. Poison expiry is read from the actual actor status stack. "
        "One cleanse/heal fixture first applies a real Poison skill and records setup receipts separately from candidate receipts.\n\n"
        "Native capture and one owner review per batch are pending. PvE remains HOLD."
    )
    (ROOT / f"{BATCH_REL}/README.md").write_text(readme, encoding="utf-8")
    print(f"POISON_FACTORY_CONFIGURED entries={len(new_entries)} assets={sum(len(r['phase_art_sha256']) for r in source_rows)} excluded=1")


if __name__ == "__main__":
    main()
