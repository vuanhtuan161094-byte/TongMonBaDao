from __future__ import annotations

import argparse
import copy
import json
import shutil
import subprocess
import sys
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Iterable

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from catalog_core import dump_json, json_sha256, sha256_file  # noqa: E402


def _safe_relative(path: str) -> PurePosixPath:
    value = PurePosixPath(path.replace("\\", "/"))
    if value.is_absolute() or ".." in value.parts or not value.parts:
        raise ValueError(f"unsafe project-relative resource path: {path}")
    return value


def _godot_transform(
    godot_exe: Path,
    source: Path,
    output_dir: Path,
    output_stem: str,
    mapping_path: Path,
    animation: dict,
    mode: str,
    max_page_size: int,
) -> dict:
    script = HERE / "repack_selected_sheet.gd"
    if not godot_exe.is_file():
        raise FileNotFoundError(f"Godot executable not found: {godot_exe}")
    if not script.is_file():
        raise FileNotFoundError(f"Godot repack script not found: {script}")
    frame_size = animation.get("frame_size", [])
    anchor = animation.get("anchor_px", [0, 0])
    if len(frame_size) != 2 or len(anchor) != 2:
        raise ValueError("repack requires verified frame_size and anchor_px")
    pairs = [
        ("mode", mode),
        ("source", str(source.resolve())),
        ("output_dir", str(output_dir.resolve())),
        ("stem", output_stem),
        ("frame_width", str(int(frame_size[0]))),
        ("frame_height", str(int(frame_size[1]))),
        ("frames", str(int(animation.get("frames", 0)))),
        ("directions", str(int(animation.get("directions", 1)))),
        ("anchor_x", str(int(anchor[0]))),
        ("anchor_y", str(int(anchor[1]))),
        ("max_page", str(max_page_size)),
        ("mapping", str(mapping_path.resolve())),
    ]
    command = [str(godot_exe), "--headless", "--script", str(script), "--"]
    for key, value in pairs:
        command.extend([f"--{key}", value])
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(
            f"Godot {mode} transform failed ({result.returncode}).\n"
            f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    if not mapping_path.is_file():
        raise RuntimeError(f"Godot {mode} transform did not write its mapping JSON")
    mapping = json.loads(mapping_path.read_text(encoding="utf-8"))
    return mapping


def export_pack(
    library_root: Path,
    selected_ids: Iterable[str],
    output: Path,
    make_zip: bool = False,
    godot_exe: Path | None = None,
    max_texture_size: int = 2048,
    repack_oversized: bool = False,
    pad_transparent_records: Iterable[str] = (),
) -> dict:
    index_path = library_root / "catalog" / "library_index.json"
    catalog = json.loads(index_path.read_text(encoding="utf-8"))
    by_id = {row["record_id"]: row for row in catalog.get("records", [])}
    ids = list(dict.fromkeys(str(x).strip() for x in selected_ids if str(x).strip()))
    if not ids:
        raise ValueError("at least one record_id is required")
    missing = [record_id for record_id in ids if record_id not in by_id]
    if missing:
        raise KeyError(f"unknown record_id(s): {', '.join(missing)}")
    if output.exists() and any(output.iterdir()):
        raise FileExistsError(f"refusing to overwrite a non-empty export directory: {output}")
    output.mkdir(parents=True, exist_ok=True)
    (output / "textures").mkdir(exist_ok=True)
    selected = [copy.deepcopy(by_id[record_id]) for record_id in ids]
    copied: set[str] = set()
    for row in selected:
        sha = row["sha256"]
        if sha in copied:
            continue
        rel = Path(row["texture_path"])
        if rel.is_absolute() or ".." in rel.parts or rel.as_posix() != f"textures/{sha}.webp":
            raise ValueError(f"unsafe library texture path for {row['record_id']}")
        source = library_root / rel
        if not source.is_file() or sha256_file(source) != sha:
            raise ValueError(f"missing or corrupt source payload for {row['record_id']}")
        target = output / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        copied.add(sha)
    project_template = HERE.parent / "godot_project"
    if project_template.is_dir():
        shutil.copytree(project_template, output, dirs_exist_ok=True)
    elif (HERE.parent / "project.godot").is_file() and (HERE.parent / "godot").is_dir():
        shutil.copy2(HERE.parent / "project.godot", output / "project.godot")
        shutil.copytree(HERE.parent / "godot", output / "godot", dirs_exist_ok=True)
    readme = HERE.parent / "README.md"
    if readme.is_file():
        shutil.copy2(readme, output / "README.md")

    pad_records = set(pad_transparent_records)
    unknown_pad_records = pad_records - set(ids)
    if unknown_pad_records:
        raise ValueError(f"transparent-pad record(s) are not selected: {', '.join(sorted(unknown_pad_records))}")
    transforms: list[dict] = []
    runtime_paths: set[str] = set()
    with tempfile.TemporaryDirectory(prefix="jx_vfx_repack_") as temp_name:
        temp_root = Path(temp_name)
        for row in selected:
            animation = row.get("animation", {})
            if not isinstance(animation, dict) or animation.get("layout") != "grid":
                if row["record_id"] in pad_records:
                    raise ValueError(f"transparent padding requires grid layout: {row['record_id']}")
                continue
            frame_size = animation.get("frame_size", [])
            if len(frame_size) != 2:
                continue
            expected_w = int(frame_size[0]) * int(animation.get("frames", 0))
            expected_h = int(frame_size[1]) * int(animation.get("directions", 1))
            source_w, source_h = (int(x) for x in row.get("size_px", [0, 0]))
            should_pad = row["record_id"] in pad_records
            should_repack = repack_oversized and (source_w > max_texture_size or source_h > max_texture_size)
            if not should_pad and not should_repack:
                if row["record_id"] in pad_records:
                    raise ValueError(f"requested padding has no dimension mismatch: {row['record_id']}")
                continue
            if godot_exe is None:
                raise ValueError("--godot-exe is required to repack oversized or padded grids")
            if should_pad and (source_w > expected_w or source_h > expected_h):
                raise ValueError(f"cannot transparently pad source dimensions larger than the linked grid: {row['record_id']}")
            source_rel = _safe_relative(str(row["texture_path"]))
            source_path = library_root.joinpath(*source_rel.parts)
            runtime_dir = output / "textures" / "runtime"
            runtime_dir.mkdir(parents=True, exist_ok=True)
            stem = str(row["sha256"])
            mapping_path = temp_root / f"{stem}.json"
            mode = "pad" if should_pad else "pages"
            mapping = _godot_transform(
                godot_exe,
                source_path,
                runtime_dir,
                stem,
                mapping_path,
                animation,
                mode,
                max_texture_size,
            )
            if mode == "pad":
                output_abs = Path(mapping["output_path"])
                if not output_abs.is_file() or mapping.get("added_region_alpha_bbox"):
                    raise RuntimeError(f"padding evidence failed for {row['record_id']}: added pixels are not transparent")
                runtime_relative = output_abs.relative_to(output).as_posix()
                animation["runtime_texture_path"] = runtime_relative
                animation["source_dimensions_match"] = True
                if int(animation.get("frame_ms", 0)) <= 0:
                    metadata_ms = int(row.get("metadata", {}).get("ms", 0))
                    if metadata_ms <= 0:
                        raise ValueError(f"no verified millisecond timing for padded record: {row['record_id']}")
                    animation["frame_ms"] = metadata_ms
                    animation["timing_unit"] = "ms"
                row["runtime_transform"] = {
                    "mode": "transparent_edge_padding",
                    "source_dimensions": mapping["source_dimensions"],
                    "packaged_dimensions": mapping["expected_dimensions"],
                    "added_right_px": mapping["added_right_px"],
                    "added_bottom_px": mapping["added_bottom_px"],
                    "added_region_alpha_bbox": mapping["added_region_alpha_bbox"],
                    "runtime_texture_path": runtime_relative,
                }
                runtime_paths.add(runtime_relative)
                transforms.append({"record_id": row["record_id"], **row["runtime_transform"]})
            else:
                frame_regions = []
                page_outputs = []
                for page in mapping.get("pages", []):
                    page_abs = Path(page["path"])
                    if not page_abs.is_file():
                        raise RuntimeError(f"missing repacked page for {row['record_id']}: {page_abs}")
                    if max(int(page["size"][0]), int(page["size"][1])) > max_texture_size:
                        raise RuntimeError(f"repacked page exceeds {max_texture_size}px: {page_abs}")
                    page_outputs.append({
                        "path": page_abs.relative_to(output).as_posix(),
                        "size_px": page["size"],
                        "first_global_frame": page["first_global_frame"],
                        "frame_count": page["frame_count"],
                    })
                for region in mapping.get("frame_regions", []):
                    page_relative = Path(region["texture_path"]).relative_to(output).as_posix()
                    frame_regions.append({
                        "texture_path": page_relative,
                        "rect": region["rect"],
                        "anchor_px": region["anchor_px"],
                    })
                    runtime_paths.add(page_relative)
                if len(frame_regions) != int(animation["frames"]) * int(animation.get("directions", 1)):
                    raise RuntimeError(f"repack frame count mismatch for {row['record_id']}")
                original_layout = animation["layout"]
                animation["layout"] = "paged_rects"
                animation["frame_regions"] = frame_regions
                animation["source_dimensions_match"] = True
                row["runtime_transform"] = {
                    "mode": "frame_preserving_pages",
                    "original_layout": original_layout,
                    "source_dimensions": [source_w, source_h],
                    "max_page_size": max_texture_size,
                    "pages": page_outputs,
                    "frame_region_count": len(frame_regions),
                }
                transforms.append({"record_id": row["record_id"], **row["runtime_transform"]})
    all_resource_paths: set[str] = set(runtime_paths)
    for row in selected:
        animation = row.get("animation", {})
        if isinstance(animation, dict) and animation.get("layout") == "paged_rects":
            for region in animation.get("frame_regions", []):
                if isinstance(region, dict) and region.get("texture_path"):
                    all_resource_paths.add(str(_safe_relative(str(region["texture_path"]))))
        elif isinstance(animation, dict) and animation.get("runtime_texture_path"):
            all_resource_paths.add(str(_safe_relative(str(animation["runtime_texture_path"]))))
        else:
            all_resource_paths.add(str(_safe_relative(str(row["texture_path"]))))
    manifest_lines = ["extends RefCounted", "", "# Static references keep dynamically addressed textures in exported PCK files.", "const TEXTURES: Array[Texture2D] = ["]
    for resource_path in sorted(all_resource_paths):
        manifest_lines.append(f'\tpreload("res://{resource_path}"),')
    manifest_lines.extend(["]", "", "static func referenced_texture_count() -> int:", "\treturn TEXTURES.size()", ""])
    manifest_file = output / "godot" / "scripts" / "jx_vfx_resource_manifest.gd"
    manifest_file.parent.mkdir(parents=True, exist_ok=True)
    manifest_file.write_text("\n".join(manifest_lines), encoding="utf-8")

    pack = {
        "schema_version": "1.0",
        "pack_id": output.name,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "source_catalog_sha256": json_sha256(index_path),
        "record_count": len(selected),
        "unique_texture_count": len(copied),
        "records": selected,
        "runtime_transforms": transforms,
        "max_runtime_texture_size": max_texture_size,
        "resource_manifest": "godot/scripts/jx_vfx_resource_manifest.gd",
        "presentation_only": True,
        "rights_status": "LOCAL_EXPERIMENTAL_RESEARCH; review licensing and owner approval before redistribution",
    }
    dump_json(output / "pack.json", pack)
    source_ids = {row["source_id"] for row in selected}
    portable_sources = [row for row in catalog.get("sources", []) if row.get("source_id") in source_ids]
    skill_bindings = [
        ref for row in selected for ref in row.get("skill_refs", [])
        if isinstance(ref, dict) and ref.get("asset_record_id")
    ]
    subcatalog = {
        "schema_version": "1.0",
        "library_id": "jx_vfx_selected_pack",
        "created_utc": pack["created_utc"],
        "statistics": {
            "source_occurrences": len(selected),
            "unique_sha256_textures": len(copied),
            "duplicate_occurrences_removed_from_texture_pool": len(selected) - len(copied),
            "skill_binding_rows": len(skill_bindings),
            "godot_engine_status": "PENDING_ENGINE",
        },
        "sources": portable_sources,
        "undecoded_sources": [],
        "skill_bindings": skill_bindings,
        "records": selected,
    }
    dump_json(output / "catalog" / "library_index.json", subcatalog)
    schema_source = HERE.parent / "catalog" / "library.schema.json"
    if schema_source.is_file():
        shutil.copy2(schema_source, output / "catalog" / "library.schema.json")
    gallery_template = HERE.parent / "gallery_template.html"
    if gallery_template.is_file():
        template = gallery_template.read_text(encoding="utf-8")
        gallery_data = {"statistics": subcatalog["statistics"], "records": selected}
        embedded = json.dumps(gallery_data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
        (output / "index.html").write_text(template.replace("__JX_VFX_DATA__", embedded), encoding="utf-8")
    packaged_files = []
    for file in sorted(output.rglob("*")):
        if not file.is_file() or file.name == "pack.json" or ".godot" in file.parts:
            continue
        packaged_files.append({
            "path": file.relative_to(output).as_posix(),
            "bytes": file.stat().st_size,
            "sha256": sha256_file(file),
        })
    pack["packaged_files"] = packaged_files
    pack["packaged_file_count_excluding_pack_json"] = len(packaged_files)
    dump_json(output / "pack.json", pack)
    zip_path = None
    if make_zip:
        zip_path = output.with_suffix(".zip")
        with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for file in sorted(output.rglob("*")):
                if file.is_file():
                    archive.write(file, file.relative_to(output).as_posix())
    return {"record_count": len(selected), "unique_texture_count": len(copied), "output": str(output), "zip": str(zip_path) if zip_path else None}


def main() -> None:
    parser = argparse.ArgumentParser(description="Export a small, explicitly selected VFX texture pack.")
    parser.add_argument("--library", required=True, type=Path)
    parser.add_argument("--ids", required=True, help="comma-separated record IDs or a UTF-8 text file with one ID per line")
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--zip", action="store_true")
    parser.add_argument("--godot-exe", type=Path, help="Godot 4 console executable for optional grid transforms")
    parser.add_argument("--max-texture-size", type=int, default=2048)
    parser.add_argument("--repack-oversized", action="store_true", help="repack oversized verified grid sheets into frame-preserving pages")
    parser.add_argument("--pad-transparent-record", action="append", default=[], help="grid record_id whose verified missing right/bottom pixels may be transparent-padded")
    args = parser.parse_args()
    ids_path = Path(args.ids)
    ids = ids_path.read_text(encoding="utf-8").splitlines() if ids_path.is_file() else args.ids.split(",")
    print(json.dumps(export_pack(
        args.library,
        ids,
        args.out,
        args.zip,
        args.godot_exe,
        args.max_texture_size,
        args.repack_oversized,
        args.pad_transparent_record,
    ), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
