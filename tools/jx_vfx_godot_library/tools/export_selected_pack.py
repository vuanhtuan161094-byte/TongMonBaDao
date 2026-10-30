from __future__ import annotations

import argparse
import json
import shutil
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from catalog_core import dump_json, json_sha256, sha256_file  # noqa: E402


def export_pack(library_root: Path, selected_ids: Iterable[str], output: Path, make_zip: bool = False) -> dict:
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
    selected = [by_id[record_id] for record_id in ids]
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
    pack = {
        "schema_version": "1.0",
        "pack_id": output.name,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "source_catalog_sha256": json_sha256(index_path),
        "record_count": len(selected),
        "unique_texture_count": len(copied),
        "records": selected,
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
    project_template = HERE.parent / "godot_project"
    if project_template.is_dir():
        shutil.copytree(project_template, output, dirs_exist_ok=True)
    elif (HERE.parent / "project.godot").is_file() and (HERE.parent / "godot").is_dir():
        shutil.copy2(HERE.parent / "project.godot", output / "project.godot")
        shutil.copytree(HERE.parent / "godot", output / "godot", dirs_exist_ok=True)
    readme = HERE.parent / "README.md"
    if readme.is_file():
        shutil.copy2(readme, output / "README.md")
    gallery_template = HERE.parent / "gallery_template.html"
    if gallery_template.is_file():
        template = gallery_template.read_text(encoding="utf-8")
        gallery_data = {"statistics": subcatalog["statistics"], "records": selected}
        embedded = json.dumps(gallery_data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
        (output / "index.html").write_text(template.replace("__JX_VFX_DATA__", embedded), encoding="utf-8")
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
    args = parser.parse_args()
    ids_path = Path(args.ids)
    ids = ids_path.read_text(encoding="utf-8").splitlines() if ids_path.is_file() else args.ids.split(",")
    print(json.dumps(export_pack(args.library, ids, args.out, args.zip), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

