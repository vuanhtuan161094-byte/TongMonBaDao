from __future__ import annotations

import argparse
import csv
import hashlib
import json
import shutil
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
PACKAGE = HERE.parent
sys.path.insert(0, str(HERE))
from catalog_core import _portable, dump_json, json_sha256, portable_record, sha256_file  # noqa: E402
from export_selected_pack import export_pack  # noqa: E402


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def safe_source_path(root: Path, filename: str) -> Path:
    name = Path(filename).name
    if name != filename or name in {".", ".."}:
        raise ValueError(f"non-basename source filename rejected: {filename!r}")
    base = root.resolve(strict=True)
    candidate = (base / name).resolve(strict=True)
    if candidate.parent != base or not candidate.is_file():
        raise ValueError(f"source path escapes configured root or is not a file: {name}")
    return candidate


def save_checkpoint(path: Path, index_hash: str, done: dict[str, str], count: int) -> None:
    dump_json(path, {
        "schema_version": "1.0",
        "source_index_sha256": index_hash,
        "processed_record_count": count,
        "processed_records": done,
        "updated_utc": datetime.now(timezone.utc).isoformat(),
    })


def build(args: argparse.Namespace) -> dict[str, Any]:
    source_index = Path(args.index)
    source_config = Path(args.source_config)
    output = Path(args.out)
    if not source_index.is_file() or not source_config.is_file():
        raise FileNotFoundError("source index and private source config must exist")
    index_hash = json_sha256(source_index)
    index = read_json(source_index)
    cfg = read_json(source_config)
    roots = {k: Path(v) for k, v in cfg.get("roots", {}).items()}
    records = index.get("vfx_records")
    if not isinstance(records, list) or not records:
        raise ValueError("input index has no vfx_records")
    skill_bindings: list[dict[str, str]] = []
    if args.skill_map:
        with Path(args.skill_map).open("r", encoding="utf-8-sig", newline="") as stream:
            skill_bindings = list(csv.DictReader(stream))
    bindings_by_asset: dict[str, list[dict[str, str]]] = {}
    for binding in skill_bindings:
        bindings_by_asset.setdefault(binding.get("asset_record_id", ""), []).append(binding)

    checkpoint_path = output / "logs" / "build_checkpoint.json"
    done: dict[str, str] = {}
    if args.resume and checkpoint_path.exists():
        checkpoint = read_json(checkpoint_path)
        if checkpoint.get("source_index_sha256") != index_hash:
            raise ValueError("checkpoint belongs to a different source index; choose a fresh output root")
        done = dict(checkpoint.get("processed_records", {}))

    texture_dir = output / "textures"
    texture_dir.mkdir(parents=True, exist_ok=True)
    log_path = output / "logs" / "build_log.jsonl"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    normalized: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    verified_output_hashes: set[str] = set()
    source_bytes = 0

    for position, record in enumerate(records, start=1):
        record_id = str(record.get("record_id", ""))
        source_id = str(record.get("source_id", ""))
        filename = str(record.get("filename", ""))
        expected_sha = str(record.get("sha256", "")).lower()
        expected_bytes = int(record.get("bytes", -1))
        try:
            if source_id not in roots:
                raise KeyError(f"source root missing for {source_id}")
            if not record_id or len(expected_sha) != 64 or expected_bytes < 0:
                raise ValueError("invalid record id, SHA-256, or byte count")
            source_path = safe_source_path(roots[source_id], filename)
            if Path(str(record.get("absolute_path", ""))).name != filename:
                raise ValueError("index basename does not match filename field")
            if source_path.stat().st_size != expected_bytes:
                raise ValueError(f"source byte count changed: {filename}")
            source_sha = sha256_file(source_path)
            if source_sha != expected_sha:
                raise ValueError(f"source SHA-256 mismatch: {filename}")

            dest = texture_dir / f"{expected_sha}.webp"
            if expected_sha not in verified_output_hashes:
                if dest.exists():
                    if dest.stat().st_size != expected_bytes or sha256_file(dest) != expected_sha:
                        raise ValueError(f"existing deduplicated texture is corrupt: {dest.name}")
                else:
                    temporary = dest.with_suffix(".webp.partial")
                    shutil.copyfile(source_path, temporary)
                    if sha256_file(temporary) != expected_sha:
                        temporary.unlink(missing_ok=True)
                        raise ValueError(f"copied payload verification failed: {filename}")
                    temporary.replace(dest)
                verified_output_hashes.add(expected_sha)
            normalized_row = portable_record(record)
            normalized_row["skill_refs"] = list(normalized_row.get("skill_refs", [])) + bindings_by_asset.get(record_id, [])
            normalized.append(normalized_row)
            done[record_id] = expected_sha
            source_bytes += expected_bytes
            if position % args.batch_size == 0 or position == len(records):
                save_checkpoint(checkpoint_path, index_hash, done, position)
                with log_path.open("a", encoding="utf-8") as log:
                    log.write(json.dumps({"processed": position, "total": len(records), "verified_sha_count": len(verified_output_hashes)}, ensure_ascii=False) + "\n")
        except Exception as exc:  # keep processing the bounded manifest and report every bad row
            errors.append({"record_id": record_id, "error": str(exc)})
            with log_path.open("a", encoding="utf-8") as log:
                log.write(json.dumps({"record_id": record_id, "error": str(exc)}, ensure_ascii=False) + "\n")

    if errors:
        save_checkpoint(checkpoint_path, index_hash, done, len(done))
        dump_json(output / "logs" / "build_errors.json", {"errors": errors, "error_count": len(errors)})
        raise RuntimeError(f"{len(errors)} source records failed validation; see logs/build_errors.json")
    if len(normalized) != len(records):
        raise RuntimeError(f"manifest count mismatch: normalized {len(normalized)} of {len(records)}")

    normalized.sort(key=lambda row: row["record_id"])
    unique_count = len({row["sha256"] for row in normalized})
    source_rows = []
    indexed_source_ids = {row["source_id"] for row in normalized}
    for src in index.get("sources", []):
        if src.get("source_id") not in indexed_source_ids and str(src.get("file_extension", "")).lower() != ".spr":
            continue
        row = {k: v for k, v in src.items() if k not in {"absolute_path", "sample_bakes", "missing_expected_bakes"}}
        source_rows.append(_portable(row))
    pending_spr = [
        _portable({k: v for k, v in src.items() if k not in {"absolute_path"}})
        for src in index.get("sources", [])
        if str(src.get("file_extension", "")).lower() == ".spr"
    ]
    stats = {
        "source_occurrences": len(normalized),
        "unique_sha256_textures": unique_count,
        "duplicate_occurrences_removed_from_texture_pool": len(normalized) - unique_count,
        "source_bytes_verified_with_duplicates": source_bytes,
        "unique_texture_bytes": sum(p.stat().st_size for p in texture_dir.glob("*.webp")),
        "source_counts": dict(Counter(row["source_id"] for row in normalized)),
        "catalog_status_counts": dict(Counter(row["catalog_status"] for row in normalized)),
        "skill_binding_rows": len(skill_bindings),
        "exact_source_index_sha256": index_hash,
        "godot_engine_status": "PENDING_ENGINE",
        "rights_status": "OWNER_AUTHORIZED_LOCAL_EXPERIMENTAL_RESEARCH; not blanket shipped-game art approval",
    }
    catalog = {
        "schema_version": "1.0",
        "library_id": "jx_vfx_godot_library_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "statistics": stats,
        "sources": source_rows,
        "undecoded_sources": pending_spr,
        "skill_bindings": _portable(skill_bindings),
        "records": normalized,
    }
    dump_json(output / "catalog" / "library_index.json", catalog)

    # Copy only reviewed code/templates; source textures and the local index never enter GitHub.
    project_template = PACKAGE / "godot_project"
    if project_template.exists():
        shutil.copytree(project_template, output, dirs_exist_ok=True)
    schema_source = PACKAGE / "catalog" / "library.schema.json"
    if schema_source.is_file():
        shutil.copy2(schema_source, output / "catalog" / "library.schema.json")
    sample_ids_path = PACKAGE / "catalog" / "sample_pack_ids.txt"
    if sample_ids_path.is_file():
        sample_ids = sample_ids_path.read_text(encoding="utf-8").splitlines()
        export_pack(output, sample_ids, output / "selected_packs" / "example_v1")
        shutil.copy2(sample_ids_path, output / "catalog" / "sample_pack_ids.txt")
    shutil.copytree(PACKAGE / "tools", output / "tools", dirs_exist_ok=True)
    shutil.copytree(PACKAGE / "tests", output / "tests", dirs_exist_ok=True)
    shutil.copytree(PACKAGE / "docs", output / "docs", dirs_exist_ok=True)
    shutil.copy2(PACKAGE / "README.md", output / "README.md")
    shutil.copy2(PACKAGE / "REVIEW.md", output / "REVIEW.md")
    shutil.copy2(PACKAGE / "CODE_PACKET.md", output / "CODE_PACKET.md")
    shutil.copy2(PACKAGE / "gallery_template.html", output / "gallery_template.html")
    copied_pilots: list[str] = []
    missing_pilots: list[str] = []
    if args.pilot_source:
        pilot_source = Path(args.pilot_source)
        pilot_names = ["duong_mon_m38_skill54", "fx_rar_m38_variant", "thuy_yen_m146_skill336", "fx_rar_m146_scaled_variant"]
        for name in pilot_names:
            source_pilot = pilot_source / name
            if source_pilot.is_dir():
                shutil.copytree(source_pilot, output / "references" / "v2_pilots" / name, dirs_exist_ok=True)
                copied_pilots.append(name)
            else:
                missing_pilots.append(name)
        for filename in ("README.json", "FILE_HASHES.json"):
            source_file = pilot_source / filename
            if source_file.is_file():
                shutil.copy2(source_file, output / "references" / "v2_pilots" / filename)
    gallery_template = PACKAGE / "gallery_template.html"
    if gallery_template.exists():
        template = gallery_template.read_text(encoding="utf-8")
        gallery_data = {"statistics": stats, "records": normalized}
        embedded = json.dumps(gallery_data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
        (output / "index.html").write_text(template.replace("__JX_VFX_DATA__", embedded), encoding="utf-8")
    dump_json(output / "BUILD_REPORT.json", {
        "status": "STATIC_BUILD_PASS_PENDING_ENGINE",
        "statistics": stats,
        "source_validation_errors": 0,
        "source_index_file_count": len(records),
        "source_hash_verified_count": len(done),
        "local_payloads_copied": unique_count,
        "existing_v2_pilots_copied": copied_pilots,
        "existing_v2_pilots_missing": missing_pilots,
        "github_binary_payloads_uploaded": 0,
        "notes": [
            "All indexed source paths were checked individually; no recursive E: scan was used.",
            "Source textures remain local and are addressed by SHA-256.",
            "Godot import and playback were not run in this environment.",
        ],
    })
    return stats


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a SHA-deduplicated local VFX library from an exact manifest.")
    parser.add_argument("--index", required=True, help="existing Asset Studio JX_VFX_MASTER_INDEX.json")
    parser.add_argument("--source-config", required=True, help="private JSON mapping source_id to exact local root")
    parser.add_argument("--out", required=True, help="new output directory")
    parser.add_argument("--skill-map", help="optional existing JX_SKILL_VFX_MAP.csv")
    parser.add_argument("--pilot-source", help="optional existing selected_godot_ready folder from Asset Studio v2")
    parser.add_argument("--resume", action="store_true", help="resume only if the source index fingerprint is unchanged")
    parser.add_argument("--batch-size", type=int, default=50)
    args = parser.parse_args()
    if args.batch_size <= 0:
        parser.error("--batch-size must be positive")
    stats = build(args)
    print(json.dumps(stats, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

