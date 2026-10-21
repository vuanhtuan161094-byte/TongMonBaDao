#!/usr/bin/env python3
"""Local Source A Spine library built around the existing SpineToGodot472 tool.

The source catalog is read-only. This script stores only the Source A subset and
conversion/QA overlay in the library directory; it never copies raw source files.
"""
from __future__ import annotations

import argparse
import csv
import ctypes
import hashlib
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import traceback
import zipfile
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

SCHEMA_VERSION = "1.0.0"
JSONL_SCHEMA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "urn:tmbd:sourcea-spine-library:catalog:1.0.0",
    "title": "TMB Source A Spine asset metadata",
    "type": "object",
    "required": ["schema_version", "source_id", "source_sha256", "source_status", "qa_status"],
    "properties": {
        "schema_version": {"const": SCHEMA_VERSION},
        "source_id": {"type": "string"},
        "asset_id": {"type": "string"},
        "source_sha256": {"type": ["string", "null"], "pattern": "^[0-9a-f]{64}$"},
        "source_status": {"enum": ["READY", "REVIEW", "UNSUPPORTED", "MISSING"]},
        "spine_version": {"type": ["string", "null"]},
        "clips": {"type": "array", "items": {"type": "object", "required": ["name", "evidence"]}},
        "skins": {"type": "array", "items": {"type": "object", "required": ["name"]}},
        "attachments": {"type": "array", "items": {"type": "object", "required": ["name", "type"]}},
        "role": {"const": "UNKNOWN"},
        "gender": {"const": "UNKNOWN"},
        "library_status": {"enum": ["QA_PASS", "PARTIAL", "BLOCKED", "SKIPPED_UNSUPPORTED"]},
        "qa_status": {"type": "string"},
        "output_sha256": {"type": ["string", "null"]},
        "converter_sha256": {"type": ["string", "null"]},
        "godot_scene": {"type": ["string", "null"]},
        "godot_spriteframes": {"type": ["string", "null"]}
    },
    "additionalProperties": True
}
GITHUB_INDEX_SCHEMA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "urn:tmbd:sourcea-spine-library:github-index:1.0.0",
    "title": "TMB Source A path-free searchable asset index",
    "type": "object",
    "required": ["schema_version", "source_id", "source_sha256", "source_status", "qa_status", "clips", "skins", "attachments"],
    "properties": {
        "schema_version": {"const": SCHEMA_VERSION},
        "source_id": {"type": "string"}, "asset_id": {"type": "string"},
        "source_sha256": {"type": ["string", "null"]}, "atlas_sha256": {"type": ["string", "null"]},
        "source_status": {"enum": ["READY", "REVIEW", "UNSUPPORTED", "MISSING"]},
        "skins": {"type": "array", "items": {"type": "string"}},
        "attachments": {"type": "array", "items": {"type": "string"}},
        "clips": {"type": "array", "items": {"type": "array", "minItems": 2, "maxItems": 2}},
        "role": {"const": "UNKNOWN"}, "gender": {"const": "UNKNOWN"},
        "qa_status": {"type": "string"}, "output_sha256": {"type": ["string", "null"]},
        "godot_scene": {"type": ["string", "null"]}, "skin_bakes": {"type": "array"}
    },
    "additionalProperties": True
}


def now_utc() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def json_dump(value) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def bundle_sha256(files: list[Path]) -> str:
    digest = hashlib.sha256()
    for path in sorted(files, key=lambda item: item.name.casefold()):
        digest.update(path.name.encode("utf-8"))
        digest.update(bytes.fromhex(sha256_file(path)))
    return digest.hexdigest()


def load_config(config_path: Path) -> dict:
    if not config_path.is_file():
        raise ValueError(f"Missing local config: {config_path}. Copy library.local.example.json and edit local paths.")
    config = json.loads(config_path.read_text(encoding="utf-8"))
    for key in ("library_root", "source_root", "source_catalog_db", "source_catalog_prefix",
                "converter_script", "converter_root", "godot45", "spine_project", "godot472"):
        if not config.get(key):
            raise ValueError(f"Config is missing {key}")
    return config


def library_paths(config: dict) -> dict[str, Path]:
    root = Path(config["library_root"]).expanduser().resolve()
    return {
        "root": root,
        "db": root / "catalog.sqlite",
        "jsonl": root / "catalog.jsonl",
        "schema": root / "catalog.schema.json",
        "inventory": root / "reports" / "input_inventory.csv",
        "qa_csv": root / "reports" / "QA.jsonl",
        "summary": root / "reports" / "summary.json",
        "bakes_jsonl": root / "skin_bakes.jsonl",
        "history_jsonl": root / "reports" / "legacy_qa.jsonl",
        "previews": root / "previews",
        "packs": root / "packs",
        "output": Path(config.get("output_root", str(root / "GodotAssets"))).expanduser().resolve(),
    }


def connect_library(config: dict) -> sqlite3.Connection:
    paths = library_paths(config)
    paths["root"].mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(paths["db"])
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA journal_mode=WAL")
    con.execute("PRAGMA synchronous=FULL")
    con.execute("""CREATE TABLE IF NOT EXISTS assets (
        source_key TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        asset_id TEXT NOT NULL,
        duplicate_of TEXT,
        source_dir_rel TEXT NOT NULL,
        skel_rel TEXT NOT NULL,
        atlas_rel TEXT,
        textures_json TEXT NOT NULL DEFAULT '[]',
        source_sha256 TEXT,
        atlas_sha256 TEXT,
        texture_hashes_json TEXT NOT NULL DEFAULT '[]',
        source_status TEXT NOT NULL,
        source_reason TEXT NOT NULL DEFAULT '',
        spine_version TEXT,
        bones INTEGER,
        slots INTEGER,
        skin_count INTEGER,
        skins_json TEXT NOT NULL DEFAULT '[]',
        attachments_json TEXT NOT NULL DEFAULT '[]',
        clips_json TEXT NOT NULL DEFAULT '[]',
        parser_status TEXT NOT NULL DEFAULT 'NOT_RUN',
        source_category_candidate TEXT,
        classification_confidence TEXT,
        role TEXT NOT NULL DEFAULT 'UNKNOWN',
        gender TEXT NOT NULL DEFAULT 'UNKNOWN',
        library_status TEXT NOT NULL DEFAULT 'PARTIAL',
        conversion_status TEXT NOT NULL DEFAULT 'PENDING',
        qa_status TEXT NOT NULL DEFAULT 'NOT_RUN',
        converter_sha256 TEXT,
        bake_config_json TEXT,
        fingerprint TEXT,
        output_path TEXT,
        output_sha256 TEXT,
        godot_scene TEXT,
        godot_spriteframes TEXT,
        atlas_outputs_json TEXT NOT NULL DEFAULT '[]',
        preview_rel TEXT,
        error TEXT,
        updated_utc TEXT NOT NULL
    )""")
    con.execute("CREATE INDEX IF NOT EXISTS assets_source_id ON assets(source_id COLLATE NOCASE)")
    con.execute("CREATE INDEX IF NOT EXISTS assets_status ON assets(library_status, conversion_status)")
    con.execute("CREATE INDEX IF NOT EXISTS assets_spine_version ON assets(spine_version)")
    con.execute("""CREATE TABLE IF NOT EXISTS input_files (
        relative_path TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        sha256 TEXT,
        bytes INTEGER,
        hash_method TEXT NOT NULL,
        referenced_by_rig INTEGER NOT NULL,
        file_status TEXT NOT NULL
    )""")
    con.execute("""CREATE TABLE IF NOT EXISTS bakes (
        bake_key TEXT PRIMARY KEY,
        source_key TEXT NOT NULL,
        source_id TEXT NOT NULL,
        asset_id TEXT NOT NULL,
        skins_json TEXT NOT NULL,
        fingerprint TEXT NOT NULL,
        converter_sha256 TEXT,
        bake_config_json TEXT NOT NULL,
        library_status TEXT NOT NULL,
        conversion_status TEXT NOT NULL,
        qa_status TEXT NOT NULL,
        output_path TEXT,
        output_sha256 TEXT,
        godot_scene TEXT,
        godot_spriteframes TEXT,
        atlas_outputs_json TEXT NOT NULL DEFAULT '[]',
        error TEXT,
        updated_utc TEXT NOT NULL
    )""")
    con.execute("CREATE INDEX IF NOT EXISTS bakes_asset_id ON bakes(asset_id COLLATE NOCASE)")
    con.execute("""CREATE TABLE IF NOT EXISTS qa_history (
        history_id TEXT PRIMARY KEY, source_key TEXT NOT NULL, source_id TEXT NOT NULL,
        attempted_utc TEXT NOT NULL, result TEXT NOT NULL, summary TEXT NOT NULL,
        log_relative_path TEXT NOT NULL
    )""")
    con.execute("""CREATE TABLE IF NOT EXISTS library_meta (
        key TEXT PRIMARY KEY, value TEXT NOT NULL
    )""")
    con.commit()
    return con


def connect_source_catalog(config: dict) -> sqlite3.Connection:
    path = Path(config["source_catalog_db"]).expanduser().resolve()
    if not path.is_file():
        raise ValueError(f"Existing source catalog not found: {path}")
    con = sqlite3.connect(path.as_uri() + "?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def local_from_catalog(config: dict, relative_path: str) -> tuple[Path, str]:
    prefix = str(config["source_catalog_prefix"]).replace("\\", "/").strip("/") + "/"
    normalized = str(relative_path).replace("\\", "/")
    if not normalized.casefold().startswith(prefix.casefold()):
        raise ValueError(f"Catalog path is outside configured SourceA root: {relative_path}")
    return Path(config["source_root"]).expanduser().resolve() / Path(*PurePosixPath(normalized).parts), normalized


def get_parser(config: dict):
    parser_dir = config.get("spine38_parser_dir")
    if parser_dir:
        directory = str(Path(parser_dir).expanduser().resolve())
        if directory not in sys.path:
            sys.path.insert(0, directory)
    try:
        from spine38_binary import parse
        return parse
    except Exception:
        return None


def parse_skeleton(parse, path: Path) -> dict:
    data = parse(str(path))
    if data.get("_end") != data.get("_size"):
        raise ValueError(f"parser_not_eof:{data.get('_end')}/{data.get('_size')}")
    skins = []
    attachment_map = {}
    for skin in data.get("skins", []):
        if not skin:
            continue
        names = []
        for slot_attachments in skin.get("attachments", {}).values():
            for attachment in slot_attachments.values():
                name = str(attachment.get("name") or "")
                if not name:
                    continue
                names.append(name)
                attachment_map[(name, str(attachment.get("type") or "unknown"))] = {
                    "name": name,
                    "type": str(attachment.get("type") or "unknown"),
                    "path": attachment.get("path")
                }
        skins.append({"name": str(skin.get("name") or ""), "attachment_count": len(names),
                      "attachment_names": sorted(set(names), key=str.casefold)})
    clips = [{"name": str(animation.get("name") or ""),
              "duration_seconds": float(animation.get("duration", 0.0)),
              "evidence": "SPINE_3_8_BINARY_PARSE"}
             for animation in data.get("animations", [])]
    return {"spine_version": data.get("version"), "bones": len(data.get("bones", [])),
            "slots": len(data.get("slots", [])), "skins": skins,
            "attachments": sorted(attachment_map.values(), key=lambda item: (item["name"].casefold(), item["type"])),
            "clips": clips}


def cached_or_hash(path: Path, catalog_file: sqlite3.Row | None) -> tuple[str | None, str]:
    if not path.is_file():
        return None, "MISSING"
    if catalog_file and catalog_file["sha256"]:
        stat = path.stat()
        if stat.st_size == catalog_file["size"] and stat.st_mtime_ns == catalog_file["mtime_ns"]:
            return str(catalog_file["sha256"]).lower(), "CACHED_SIZE_MTIME"
    return sha256_file(path), "REHASHED"


def safe_id(stem: str) -> str:
    value = re.sub(r"[^A-Za-z0-9_-]+", "_", stem).strip("_-") or "asset"
    return value[:64]


def input_fingerprint(skel_hash, atlas_hash, texture_hashes, source_paths=None) -> str:
    source_paths = source_paths or {}
    data = {"skeleton": skel_hash or "MISSING:" + str(source_paths.get("skeleton", "")),
            "atlas": atlas_hash or "MISSING:" + str(source_paths.get("atlas", "")),
            "textures": sorted([item.get("sha256") or "MISSING:" + str(item.get("path") or "")
                                for item in texture_hashes])}
    return hashlib.sha256(json_dump(data).encode("utf-8")).hexdigest()


def scan(config: dict, con: sqlite3.Connection) -> dict:
    source = connect_source_catalog(config)
    prefix = str(config["source_catalog_prefix"]).replace("\\", "/").strip("/")
    rows = source.execute("""SELECT g.*, sf.relative_path AS skel_path, sf.sha256 AS skel_sha,
        sf.size AS skel_size, sf.mtime_ns AS skel_mtime_ns, sf.category AS category,
        sf.classification_confidence AS classification_confidence,
        af.relative_path AS atlas_path, af.sha256 AS atlas_sha, af.size AS atlas_size,
        af.mtime_ns AS atlas_mtime_ns
        FROM spine_groups g
        JOIN files sf ON sf.id=g.skel_file_id
        LEFT JOIN files af ON af.id=g.atlas_file_id
        WHERE g.root_alias=? AND g.directory LIKE ?
        ORDER BY g.directory COLLATE NOCASE, g.stem COLLATE NOCASE""",
        (config.get("source_catalog_alias", "A_ASSETS"), prefix + "/%")).fetchall()
    if not rows:
        raise ValueError(f"Existing catalog has no groups under {prefix}")
    all_ids = set()
    for row in rows:
        if row["atlas_file_id"]:
            all_ids.add(row["atlas_file_id"])
        try:
            all_ids.update(int(item) for item in json.loads(row["texture_ids_json"] or "[]"))
        except Exception:
            pass
    id_rows = {}
    if all_ids:
        placeholders = ",".join("?" for _ in all_ids)
        for item in source.execute(f"SELECT * FROM files WHERE id IN ({placeholders})", tuple(all_ids)):
            id_rows[item["id"]] = item
    parse = get_parser(config)
    tool_root = Path(config["converter_root"]).expanduser().resolve()
    converter_files = [Path(config["converter_script"]), tool_root / "native" / "capture_spine.gd",
                       tool_root / "native" / "inspect_spine.gd", tool_root / "asset_bundle.py"]
    converter_hash = bundle_sha256([path for path in converter_files if path.is_file()])
    profile = {key: config.get(key) for key in ("fps", "width", "height", "foot_x", "foot_y")}
    inventory = []
    parsed_count = 0
    rehashed_count = 0
    missing_count = 0
    prepared = []
    for index, row in enumerate(rows, 1):
        skel_path, skel_rel = local_from_catalog(config, row["skel_path"])
        skel_catalog_row = {"sha256": row["skel_sha"], "size": row["skel_size"], "mtime_ns": row["skel_mtime_ns"]}
        skel_sha, skel_hash_method = cached_or_hash(skel_path, skel_catalog_row)
        if skel_hash_method == "REHASHED": rehashed_count += 1
        if skel_hash_method == "MISSING": missing_count += 1
        atlas_path = None
        atlas_rel = None
        atlas_sha = None
        atlas_hash_method = "MISSING"
        if row["atlas_path"]:
            atlas_path, atlas_rel = local_from_catalog(config, row["atlas_path"])
            atlas_catalog_row = {"sha256": row["atlas_sha"], "size": row["atlas_size"], "mtime_ns": row["atlas_mtime_ns"]}
            atlas_sha, atlas_hash_method = cached_or_hash(atlas_path, atlas_catalog_row)
            if atlas_hash_method == "REHASHED": rehashed_count += 1
            if atlas_hash_method == "MISSING": missing_count += 1
        textures = []
        try:
            texture_ids = json.loads(row["texture_ids_json"] or "[]")
        except Exception:
            texture_ids = []
        for file_id in texture_ids:
            file_row = id_rows.get(int(file_id))
            if not file_row:
                textures.append({"path": None, "sha256": None, "hash_method": "MISSING_CATALOG_ROW"})
                continue
            path, rel = local_from_catalog(config, file_row["relative_path"])
            digest, method = cached_or_hash(path, file_row)
            if method == "REHASHED": rehashed_count += 1
            if method == "MISSING": missing_count += 1
            textures.append({"path": rel.replace("\\", "/"), "sha256": digest,
                             "name": file_row["name"], "hash_method": method,
                             "width": file_row["width"], "height": file_row["height"]})
        parse_status = "NOT_RUN"
        meta = {"spine_version": row["spine_version"], "bones": row["bones"], "slots": row["slots"],
                "skins": [], "attachments": [],
                "clips": [{"name": name, "duration_seconds": None, "evidence": "SOURCE_CATALOG_NAME_ONLY"}
                          for name in json.loads(row["clips_json"] or "[]")]}
        if parse and skel_path.is_file():
            try:
                meta = parse_skeleton(parse, skel_path)
                parse_status = "PARSE_PASS"
                parsed_count += 1
            except Exception as exc:
                parse_status = "PARSE_REVIEW"
                meta["parser_error"] = f"{type(exc).__name__}:{str(exc)[:180]}"
        elif not parse:
            parse_status = "PARSER_UNAVAILABLE"
        source_status = str(row["status"] or "REVIEW")
        reasons = [value for value in (row["reason"],) if value]
        if skel_hash_method == "MISSING": reasons.append("source_skeleton_missing")
        if atlas_hash_method == "MISSING": reasons.append("source_atlas_missing_or_ambiguous")
        if any(item.get("hash_method") == "MISSING" for item in textures): reasons.append("source_texture_missing")
        if meta.get("parser_error"): reasons.append(meta["parser_error"])
        if skel_hash_method == "MISSING":
            source_status = "MISSING"
        elif source_status == "READY" and (atlas_hash_method == "MISSING" or
                any(item.get("hash_method") == "MISSING" for item in textures)):
            source_status = "REVIEW"
        if meta.get("spine_version") and not str(meta["spine_version"]).startswith("3.8."):
            source_status = "UNSUPPORTED"
            reasons.append("unsupported_version:" + str(meta["spine_version"]))
        if source_status not in ("READY", "REVIEW", "UNSUPPORTED"):
            source_status = "REVIEW"
        fingerprint = input_fingerprint(skel_sha, atlas_sha, textures,
            {"skeleton": skel_rel, "atlas": atlas_rel})
        prepared.append({
            "source_key": str(row["id"]), "source_id": str(row["stem"]),
            "asset_id": safe_id(str(row["stem"])), "source_dir_rel": str(row["directory"]).replace("\\", "/").removeprefix(prefix + "/"),
            "skel_rel": skel_rel.replace("\\", "/"), "atlas_rel": atlas_rel.replace("\\", "/") if atlas_rel else None,
            "textures": textures, "source_sha256": skel_sha, "atlas_sha256": atlas_sha,
            "source_status": source_status, "source_reason": "; ".join(reasons),
            "spine_version": meta.get("spine_version"), "bones": meta.get("bones"), "slots": meta.get("slots"),
            "skin_count": len(meta.get("skins", [])) if meta.get("skins") else row["skins"],
            "skins": meta.get("skins", []), "attachments": meta.get("attachments", []),
            "clips": meta.get("clips", []), "parser_status": parse_status,
            "category": row["category"], "classification_confidence": row["classification_confidence"],
            "fingerprint": fingerprint, "converter_sha256": converter_hash,
            "bake_config": profile, "updated_utc": now_utc(),
            "hash_methods": {"skeleton": skel_hash_method, "atlas": atlas_hash_method}
        })
        if index % 100 == 0:
            print(f"SCAN {index}/{len(rows)} parsed={parsed_count} rehashed={rehashed_count} missing={missing_count}", flush=True)

    # Disambiguate repeated source stems and alias exact duplicate source triples.
    stems = Counter(item["source_id"].casefold() for item in prepared)
    first_by_fingerprint = {}
    for item in prepared:
        if stems[item["source_id"].casefold()] > 1:
            item["asset_id"] = safe_id(item["source_id"] + "_" + item["source_sha256"][:8])
        prior = first_by_fingerprint.get(item["fingerprint"])
        if prior:
            item["duplicate_of"] = prior["asset_id"]
            item["asset_id"] = prior["asset_id"]
            item["conversion_status"] = "DUPLICATE_ALIAS"
            item["library_status"] = "PARTIAL"
            item["qa_status"] = "NOT_REQUIRED_DUPLICATE"
        else:
            first_by_fingerprint[item["fingerprint"]] = item

    # Include every file in the requested SourceA tree, including Unity AnimationClip JSON.
    inventory_rows = source.execute("""SELECT * FROM files WHERE root_alias=? AND relative_path LIKE ?
        ORDER BY relative_path COLLATE NOCASE""",
        (config.get("source_catalog_alias", "A_ASSETS"), prefix + "/%")).fetchall()
    used_paths = set()
    source_dirs = set()
    for item in prepared:
        used_paths.add(item["skel_rel"].casefold())
        if item["atlas_rel"]: used_paths.add(item["atlas_rel"].casefold())
        used_paths.update((texture.get("path") or "").casefold() for texture in item["textures"])
        source_dirs.add((prefix + "/" + item["source_dir_rel"]).rstrip("/").casefold())
    for file_row in inventory_rows:
        path, rel = local_from_catalog(config, file_row["relative_path"])
        digest, method = cached_or_hash(path, file_row)
        if method == "REHASHED": rehashed_count += 1
        if method == "MISSING": missing_count += 1
        lower_name = file_row["name"].lower()
        suffix = Path(lower_name).suffix
        kind = ("skeleton" if ".skel" in lower_name else "atlas" if ".atlas" in lower_name else
                "texture" if suffix == ".png" else "animation_metadata" if suffix == ".json" else "ancillary")
        rel = rel.replace("\\", "/")
        inventory.append({"kind": kind, "relative_path": rel, "sha256": digest,
                          "bytes": file_row["size"], "hash_method": method,
                          "referenced_by_rig": rel.casefold() in used_paths or
                            str(PurePosixPath(rel).parent).casefold() in source_dirs,
                          "file_status": "PRESENT" if path.is_file() else "MISSING"})

    # Preserve prior conversion records only when the exact source fingerprint is unchanged.
    existing = {row["source_key"]: dict(row) for row in con.execute("SELECT * FROM assets")}
    columns = ["source_key", "source_id", "asset_id", "duplicate_of", "source_dir_rel", "skel_rel", "atlas_rel",
               "textures_json", "source_sha256", "atlas_sha256", "texture_hashes_json", "source_status", "source_reason",
               "spine_version", "bones", "slots", "skin_count", "skins_json", "attachments_json", "clips_json",
               "parser_status", "source_category_candidate", "classification_confidence", "role", "gender", "library_status",
               "conversion_status", "qa_status", "converter_sha256", "bake_config_json", "fingerprint", "output_path",
               "output_sha256", "godot_scene", "godot_spriteframes", "atlas_outputs_json", "preview_rel", "error", "updated_utc"]
    for item in prepared:
        old = existing.get(item["source_key"], {})
        same_source = old.get("fingerprint") == item["fingerprint"] and old.get("source_sha256") == item["source_sha256"]
        if same_source:
            conversion_status = old.get("conversion_status", item.get("conversion_status", "PENDING"))
            qa_status = old.get("qa_status", "NOT_RUN")
            library_status = old.get("library_status", "PARTIAL")
            converter_sha = old.get("converter_sha256") or item["converter_sha256"]
            output_path = old.get("output_path")
            output_sha = old.get("output_sha256")
            godot_scene = old.get("godot_scene")
            godot_spriteframes = old.get("godot_spriteframes")
            atlas_outputs = old.get("atlas_outputs_json", "[]")
            preview_rel = old.get("preview_rel")
            error = old.get("error")
        else:
            conversion_status, qa_status = item.get("conversion_status", "PENDING"), "NOT_RUN"
            library_status = "SKIPPED_UNSUPPORTED" if item["source_status"] == "UNSUPPORTED" else "PARTIAL"
            converter_sha = item["converter_sha256"]
            output_path = output_sha = godot_scene = godot_spriteframes = preview_rel = error = None
            atlas_outputs = "[]"
        item_values = {
            "source_key": item["source_key"], "source_id": item["source_id"], "asset_id": item["asset_id"],
            "duplicate_of": item.get("duplicate_of"), "source_dir_rel": item["source_dir_rel"], "skel_rel": item["skel_rel"],
            "atlas_rel": item["atlas_rel"], "textures_json": json_dump(item["textures"]), "source_sha256": item["source_sha256"],
            "atlas_sha256": item["atlas_sha256"], "texture_hashes_json": json_dump(item["textures"]),
            "source_status": item["source_status"], "source_reason": item["source_reason"],
            "spine_version": item["spine_version"], "bones": item["bones"], "slots": item["slots"],
            "skin_count": item["skin_count"], "skins_json": json_dump(item["skins"]),
            "attachments_json": json_dump(item["attachments"]), "clips_json": json_dump(item["clips"]),
            "parser_status": item["parser_status"], "source_category_candidate": item["category"],
            "classification_confidence": item["classification_confidence"], "role": "UNKNOWN", "gender": "UNKNOWN",
            "library_status": library_status, "conversion_status": conversion_status, "qa_status": qa_status,
            "converter_sha256": converter_sha, "bake_config_json": json_dump(item["bake_config"]),
            "fingerprint": item["fingerprint"], "output_path": output_path, "output_sha256": output_sha,
            "godot_scene": godot_scene, "godot_spriteframes": godot_spriteframes,
            "atlas_outputs_json": atlas_outputs, "preview_rel": preview_rel, "error": error,
            "updated_utc": item["updated_utc"]}
        con.execute(f"INSERT INTO assets ({','.join(columns)}) VALUES ({','.join('?' for _ in columns)}) "
                    f"ON CONFLICT(source_key) DO UPDATE SET {','.join(c+'=excluded.'+c for c in columns if c!='source_key')}",
                    [item_values[column] for column in columns])
    con.execute("INSERT INTO library_meta(key,value) VALUES('schema_version',?) ON CONFLICT(key) DO UPDATE SET value=excluded.value", (SCHEMA_VERSION,))
    con.execute("INSERT INTO library_meta(key,value) VALUES('source_catalog_db',?) ON CONFLICT(key) DO UPDATE SET value=excluded.value", (str(Path(config["source_catalog_db"]).resolve()),))
    con.commit()
    source.close()
    write_exports(config, con, inventory)
    import_existing_passes(config, con)
    import_legacy_attempts(config, con)
    write_exports(config, con)
    return {"discovered_rigs": len(prepared), "input_files": len(inventory),
            "source_ready": sum(item["source_status"] == "READY" for item in prepared),
            "source_review": sum(item["source_status"] == "REVIEW" for item in prepared),
            "source_unsupported": sum(item["source_status"] == "UNSUPPORTED" for item in prepared),
            "parser_pass": parsed_count, "parser_available": parse is not None,
            "hash_recomputed": rehashed_count, "missing_inputs": missing_count,
            "converter_sha256": converter_hash}


def asset_record(row: sqlite3.Row | dict) -> dict:
    value = dict(row)
    clips = json.loads(value.get("clips_json") or "[]")
    skins = json.loads(value.get("skins_json") or "[]")
    attachments = json.loads(value.get("attachments_json") or "[]")
    textures = json.loads(value.get("texture_hashes_json") or "[]")
    status = value.get("library_status")
    return {
        "schema_version": SCHEMA_VERSION,
        "source_id": value.get("source_id"), "asset_id": value.get("asset_id"),
        "source_sha256": value.get("source_sha256"), "atlas_sha256": value.get("atlas_sha256"),
        "source_files": [{"kind": "skeleton", "relative_path": value.get("skel_rel"),
                          "sha256": value.get("source_sha256")},
                         {"kind": "atlas", "relative_path": value.get("atlas_rel"),
                          "sha256": value.get("atlas_sha256")},
                         *[{"kind": "texture", "relative_path": item.get("path"),
                            "sha256": item.get("sha256")} for item in textures]],
        "texture_sha256": sorted({item.get("sha256") for item in textures if item.get("sha256")}),
        "source_status": value.get("source_status"), "source_reason": value.get("source_reason"),
        "spine_version": value.get("spine_version"), "bones": value.get("bones"), "slots": value.get("slots"),
        "skin_count": value.get("skin_count"), "skins": skins,
        "attachments": attachments, "clips": clips,
        "animation_evidence": value.get("parser_status"),
        "role": "UNKNOWN", "gender": "UNKNOWN",
        "source_category_candidate": value.get("source_category_candidate"),
        "classification_confidence": value.get("classification_confidence"),
        "library_status": status, "conversion_status": value.get("conversion_status"),
        "qa_status": value.get("qa_status"), "qa_evidence": portable_evidence(value),
        "converter_sha256": value.get("converter_sha256"),
        "bake_config": json.loads(value.get("bake_config_json") or "{}"),
        "fingerprint": value.get("fingerprint"), "output_sha256": value.get("output_sha256"),
        "godot_scene": value.get("godot_scene"), "godot_spriteframes": value.get("godot_spriteframes"),
        "atlas_outputs": json.loads(value.get("atlas_outputs_json") or "[]"),
        "preview": value.get("preview_rel"),
        "duplicate_of": value.get("duplicate_of")
    }


def portable_evidence(value: dict) -> str | None:
    status = value.get("qa_status")
    if status == "PASS":
        return "Godot 4.7.2 import/resource/playback QA passed; local logs are retained under the converter QA_RESULTS folder."
    error = str(value.get("error") or value.get("source_reason") or "").strip()
    if not error:
        return None
    if error.startswith("RESOURCE_LIMIT:") or error.startswith("Historical QA PASS;"):
        return error
    if value.get("source_status") in ("REVIEW", "MISSING", "UNSUPPORTED"):
        return str(value.get("source_reason") or error)
    return "Detailed conversion/QA reason is retained in the local SQLite catalog and QA log."


def store_inventory(con: sqlite3.Connection, inventory: list[dict]) -> None:
    con.execute("DELETE FROM input_files")
    con.executemany("""INSERT INTO input_files(relative_path,kind,sha256,bytes,hash_method,
        referenced_by_rig,file_status) VALUES(?,?,?,?,?,?,?)""",
        [(row["relative_path"], row["kind"], row.get("sha256"), row.get("bytes"),
          row["hash_method"], int(bool(row["referenced_by_rig"])), row["file_status"])
         for row in inventory])
    con.commit()


def write_exports(config: dict, con: sqlite3.Connection, inventory=None) -> None:
    paths = library_paths(config)
    if inventory is not None:
        store_inventory(con, inventory)
    paths["schema"].parent.mkdir(parents=True, exist_ok=True)
    paths["schema"].write_text(json.dumps(JSONL_SCHEMA, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with paths["jsonl"].open("w", encoding="utf-8", newline="\n") as stream:
        for row in con.execute("SELECT * FROM assets ORDER BY source_id COLLATE NOCASE, source_sha256"):
            record = asset_record(row)
            record["historical_qa"] = [dict(item) for item in con.execute(
                "SELECT attempted_utc,result,summary,log_relative_path FROM qa_history WHERE source_key=? ORDER BY attempted_utc",
                (row["source_key"],))]
            stream.write(json_dump(record) + "\n")
    paths["inventory"].parent.mkdir(parents=True, exist_ok=True)
    with paths["inventory"].open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=["kind", "relative_path", "absolute_path", "sha256",
                                                    "bytes", "hash_method", "referenced_by_rig", "file_status"])
        writer.writeheader()
        root = Path(config["source_root"]).expanduser().resolve()
        for row in con.execute("SELECT * FROM input_files ORDER BY relative_path COLLATE NOCASE"):
            row = dict(row)
            row["referenced_by_rig"] = bool(row["referenced_by_rig"])
            row["absolute_path"] = str(root / Path(*PurePosixPath(row["relative_path"]).parts))
            writer.writerow(row)
    rows = list(con.execute("SELECT library_status,qa_status,source_status,conversion_status,COUNT(*) AS n FROM assets GROUP BY 1,2,3,4"))
    summary = {"generated_utc": now_utc(), "schema_version": SCHEMA_VERSION,
               "source_root": str(Path(config["source_root"]).resolve()),
               "source_catalog": "Existing AssetCatalog, read-only; no database or preview copy made",
               "counts": {"rigs": con.execute("SELECT COUNT(*) FROM assets").fetchone()[0],
                          "input_files": con.execute("SELECT COUNT(*) FROM input_files").fetchone()[0]},
               "input_kind_breakdown": [dict(row) for row in con.execute(
                   "SELECT kind,COUNT(*) AS n FROM input_files GROUP BY kind ORDER BY kind")],
               "status_breakdown": [dict(row) for row in rows]}
    paths["summary"].parent.mkdir(parents=True, exist_ok=True)
    paths["summary"].write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with paths["qa_csv"].open("w", encoding="utf-8", newline="\n") as stream:
        for row in con.execute("SELECT * FROM assets ORDER BY source_id COLLATE NOCASE"):
            stream.write(json_dump({"source_id": row["source_id"], "asset_id": row["asset_id"],
                "source_sha256": row["source_sha256"], "source_status": row["source_status"],
                "library_status": row["library_status"], "conversion_status": row["conversion_status"],
                "qa_status": row["qa_status"], "converter_sha256": row["converter_sha256"],
                "output_sha256": row["output_sha256"], "error": portable_evidence(dict(row))}) + "\n")
    with paths["bakes_jsonl"].open("w", encoding="utf-8", newline="\n") as stream:
        for row in con.execute("SELECT * FROM bakes ORDER BY source_id COLLATE NOCASE, asset_id COLLATE NOCASE"):
            stream.write(json_dump({
                "schema_version": SCHEMA_VERSION, "source_id": row["source_id"],
                "asset_id": row["asset_id"], "skins": json.loads(row["skins_json"]),
                "source_sha256": con.execute("SELECT source_sha256 FROM assets WHERE source_key=?", (row["source_key"],)).fetchone()[0],
                "fingerprint": row["fingerprint"], "converter_sha256": row["converter_sha256"],
                "bake_config": json.loads(row["bake_config_json"]),
                "library_status": row["library_status"], "conversion_status": row["conversion_status"],
                "qa_status": row["qa_status"], "output_sha256": row["output_sha256"],
                "godot_scene": row["godot_scene"], "godot_spriteframes": row["godot_spriteframes"],
                "atlas_outputs": json.loads(row["atlas_outputs_json"] or "[]"),
                "error": portable_evidence({"qa_status": row["qa_status"], "error": row["error"]})
            }) + "\n")
    paths["history_jsonl"].parent.mkdir(parents=True, exist_ok=True)
    with paths["history_jsonl"].open("w", encoding="utf-8", newline="\n") as stream:
        for row in con.execute("SELECT * FROM qa_history ORDER BY source_id COLLATE NOCASE, attempted_utc"):
            stream.write(json_dump({key: row[key] for key in
                ("source_id", "attempted_utc", "result", "summary", "log_relative_path")}) + "\n")


def output_roots(config: dict) -> list[Path]:
    paths = []
    for item in config.get("existing_output_roots", []):
        candidate = Path(item).expanduser().resolve()
        if candidate.is_dir(): paths.append(candidate)
    current = library_paths(config)["output"]
    current.mkdir(parents=True, exist_ok=True)
    paths.append(current)
    return paths


def verify_output(config: dict, asset_id: str) -> dict | None:
    tool_root = Path(config["converter_root"]).expanduser().resolve()
    qa_dir = tool_root / "QA_RESULTS" / ("asset_" + asset_id)
    for root in output_roots(config):
        folder = root / asset_id
        manifest_path = folder / "asset.json"
        if not manifest_path.is_file():
            continue
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            checksums = manifest.get("file_sha256", {})
            if not checksums or not all((folder / name).is_file() and sha256_file(folder / name) == digest
                                        for name, digest in checksums.items()):
                return {"status": "FAIL", "error": "output_hash_mismatch", "path": str(folder), "manifest": manifest}
            verification = json.loads((qa_dir / "verification.json").read_text(encoding="utf-8"))
            latest_status = (qa_dir / "latest_status.txt").read_text(encoding="utf-8", errors="replace")
            if verification.get("status") != "PASS" or verification.get("fingerprint") != manifest.get("fingerprint") or not latest_status.startswith("PASS"):
                return {"status": "PARTIAL", "error": "QA evidence missing_or_mismatched", "path": str(folder), "manifest": manifest}
            return {"status": "PASS", "path": str(folder), "manifest": manifest,
                    "verification": verification, "qa_dir": str(qa_dir)}
        except Exception as exc:
            return {"status": "PARTIAL", "error": f"QA verification read error: {exc}", "path": str(folder)}
    return None


def import_existing_passes(config: dict, con: sqlite3.Connection) -> int:
    imported = 0
    rows = list(con.execute("SELECT * FROM assets WHERE duplicate_of IS NULL"))
    for row in rows:
        result = verify_output(config, row["asset_id"])
        if not result or result.get("status") != "PASS":
            continue
        manifest = result["manifest"]
        expected = [row["source_sha256"], row["atlas_sha256"]] + [item.get("sha256") for item in json.loads(row["texture_hashes_json"] or "[]")]
        actual = [item.get("sha256") for item in manifest.get("source", [])]
        if sorted(x for x in expected if x) != sorted(x for x in actual if x):
            continue
        clip_names = {item.get("name") for item in manifest.get("clips", [])}
        clips = json.loads(row["clips_json"] or "[]")
        for item in clips:
            if item.get("name") in clip_names:
                item["evidence"] = "GODOT_4_7_2_QA_PASS"
        atlases = [page.get("file") for page in manifest.get("atlas_pages", [])]
        output_sha = bundle_sha256([Path(result["path"]) / name for name in manifest.get("file_sha256", {})])
        con.execute("""UPDATE assets SET library_status='QA_PASS',conversion_status='UNCHANGED_SKIPPED',qa_status='PASS',
            output_path=?,output_sha256=?,godot_scene=?,godot_spriteframes=?,atlas_outputs_json=?,
            clips_json=?,error=?,updated_utc=? WHERE source_key=?""",
            (str(Path(result["path"]).resolve()), output_sha,
             f"res://assets/actors/{row['asset_id']}/actor.tscn",
             f"res://assets/actors/{row['asset_id']}/animations.tres",
             json_dump(atlases), json_dump(clips),
             f"Godot 4.7.2 import/resource/playback verified; see {result['qa_dir']}", now_utc(), row["source_key"]))
        # Batch-01 manifests predate library converter fingerprints. Preserve their
        # verified status, but leave the converter hash unknown so resume does not
        # mistake historical outputs for outputs made by the current tool version.
        if not manifest.get("converter_sha256"):
            con.execute("UPDATE assets SET converter_sha256=NULL,conversion_status='HISTORICAL_QA_PASS' WHERE source_key=?",
                        (row["source_key"],))
        else:
            con.execute("UPDATE assets SET converter_sha256=? WHERE source_key=?",
                        (manifest["converter_sha256"], row["source_key"]))
        preview = generate_preview(config, row["asset_id"], result["qa_dir"])
        if preview:
            con.execute("UPDATE assets SET preview_rel=?,updated_utc=? WHERE source_key=?",
                        (preview, now_utc(), row["source_key"]))
        imported += 1
    con.commit()
    write_exports(config, con)
    return imported


def import_legacy_attempts(config: dict, con: sqlite3.Connection) -> int:
    qa_root = Path(config["converter_root"]).expanduser().resolve() / "QA_RESULTS"
    inserted = 0
    for attempt in config.get("legacy_qa_imports", []):
        source_id = str(attempt["source_id"])
        relative = str(attempt["relative_log_path"]).replace("\\", "/")
        summary = str(attempt["summary"])
        path = qa_root / Path(*PurePosixPath(relative).parts)
        if not path.is_file():
            continue
        row = con.execute("SELECT source_key FROM assets WHERE source_id=? COLLATE NOCASE", (source_id,)).fetchone()
        if not row:
            continue
        history_id = hashlib.sha256((row["source_key"] + relative).encode("utf-8")).hexdigest()
        cursor = con.execute("""INSERT OR IGNORE INTO qa_history(history_id,source_key,source_id,
            attempted_utc,result,summary,log_relative_path) VALUES(?,?,?,?,?,?,?)""",
            (history_id, row["source_key"], source_id, attempt.get("attempted_utc", ""), "FAIL_HISTORICAL",
             summary, "QA_RESULTS/" + relative))
        inserted += cursor.rowcount
    con.commit()
    return inserted


def find_asset(con: sqlite3.Connection, identifier: str) -> sqlite3.Row:
    rows = list(con.execute("SELECT * FROM assets WHERE source_key=? OR source_id=? COLLATE NOCASE OR asset_id=? COLLATE NOCASE",
                            (identifier, identifier, identifier)))
    if len(rows) == 1:
        return rows[0]
    if len(rows) > 1:
        raise ValueError(f"Ambiguous id {identifier}; use a stable source_key from inspect/find: " + ", ".join(r["source_key"] for r in rows[:10]))
    raise ValueError(f"Source ID not found: {identifier}. Run scan first.")


def command_status(config: dict, con: sqlite3.Connection) -> None:
    rows = list(con.execute("SELECT library_status,qa_status,source_status,conversion_status,COUNT(*) n FROM assets GROUP BY 1,2,3,4 ORDER BY 1,2,3,4"))
    ready = con.execute("SELECT COUNT(*) FROM assets WHERE source_status='READY'").fetchone()[0]
    converter_sha = bundle_sha256([Path(config["converter_script"]),
        Path(config["converter_root"]) / "native" / "capture_spine.gd",
        Path(config["converter_root"]) / "native" / "inspect_spine.gd",
        Path(config["converter_root"]) / "asset_bundle.py"])
    pending = con.execute("SELECT COUNT(*) FROM assets WHERE source_status='READY' AND duplicate_of IS NULL AND (qa_status!='PASS' OR converter_sha256 IS NULL OR converter_sha256!=?)",
                          (converter_sha,)).fetchone()[0]
    pass_count = con.execute("SELECT COUNT(*) FROM assets WHERE qa_status='PASS'").fetchone()[0]
    current_pass = con.execute("SELECT COUNT(*) FROM assets WHERE qa_status='PASS' AND converter_sha256=?", (converter_sha,)).fetchone()[0]
    historical_pass = pass_count - current_pass
    report = {"generated_utc": now_utc(), "discovered": con.execute("SELECT COUNT(*) FROM assets").fetchone()[0],
              "input_files": con.execute("SELECT COUNT(*) FROM input_files").fetchone()[0],
              "source_ready": ready, "qa_pass": pass_count, "qa_pass_current_converter": current_pass,
              "qa_pass_historical_converter": historical_pass, "pending_ready": pending,
              "duplicate_aliases": con.execute("SELECT COUNT(*) FROM assets WHERE conversion_status='DUPLICATE_ALIAS'").fetchone()[0],
              "historical_failures": con.execute("SELECT COUNT(*) FROM qa_history WHERE result='FAIL_HISTORICAL'").fetchone()[0],
              "estimated_remaining_seconds_at_pilot_rate": round(pending * float(config.get("pilot_seconds_per_asset", 55.85))),
              "available_ram_mib": available_ram_mib(),
              "free_disk_bytes": shutil.disk_usage(library_paths(config)["root"]).free,
              "statuses": [dict(row) for row in rows]}
    print(json.dumps(report, ensure_ascii=False, indent=2))


def command_find(args, con: sqlite3.Connection) -> None:
    rows = list(con.execute("SELECT * FROM assets ORDER BY source_id COLLATE NOCASE"))
    query = (args.query or "").casefold()
    clip = (args.clip or "").casefold()
    skin = (args.skin or "").casefold()
    attachment = (args.attachment or "").casefold()
    result = []
    for row in rows:
        record = asset_record(row)
        text = json_dump({key: record[key] for key in ("source_id", "asset_id", "skins", "attachments", "clips", "source_category_candidate")}).casefold()
        if query and query not in text: continue
        if clip and not any(clip in item.get("name", "").casefold() for item in record["clips"]): continue
        if skin and not any(skin in item.get("name", "").casefold() for item in record["skins"]): continue
        if attachment and not any(attachment in item.get("name", "").casefold() for item in record["attachments"]): continue
        if args.gender and record["gender"] != args.gender.upper(): continue
        if args.role and record["role"] != args.role.upper(): continue
        if args.status and record["library_status"] != args.status.upper(): continue
        result.append({"source_id": record["source_id"], "asset_id": record["asset_id"],
                       "source_sha256": record["source_sha256"], "source_status": record["source_status"],
                       "clips": [item.get("name") for item in record["clips"]],
                       "skins": [item.get("name") for item in record["skins"]],
                       "role": record["role"], "gender": record["gender"],
                       "library_status": record["library_status"], "qa_status": record["qa_status"],
                       "godot_scene": record["godot_scene"]})
    print(json.dumps({"count": len(result), "results": result[:args.limit]}, ensure_ascii=False, indent=2))


def command_inspect(con: sqlite3.Connection, identifier: str) -> None:
    row = find_asset(con, identifier)
    record = asset_record(row)
    record["historical_qa"] = [dict(item) for item in con.execute(
        "SELECT attempted_utc,result,summary,log_relative_path FROM qa_history WHERE source_key=? ORDER BY attempted_utc",
        (row["source_key"],))]
    print(json.dumps(record, ensure_ascii=False, indent=2))


def command_resolve(config: dict, con: sqlite3.Connection, identifier: str, skins: list[str] | None = None) -> None:
    row = find_asset(con, identifier)
    if skins:
        bake = None
        for candidate in con.execute("SELECT * FROM bakes WHERE source_key=?", (row["source_key"],)):
            if json.loads(candidate["skins_json"]) == skins:
                bake = candidate
                break
        if not bake:
            print(json.dumps({"status": "BLOCKED", "source_id": row["source_id"], "skins": skins,
                              "reason": "No bake exists for this exact skin combination; run convert with --skin."},
                             ensure_ascii=False, indent=2))
            return
        bake_status = "QA_PASS" if bake["qa_status"] == "PASS" and bake["library_status"] == "QA_PASS" else (
            "QA_PASS_HISTORICAL" if bake["qa_status"] == "PASS" else bake["library_status"])
        print(json.dumps({"status": bake_status, "source_id": row["source_id"],
            "asset_id": bake["asset_id"], "source_sha256": row["source_sha256"],
            "output_sha256": bake["output_sha256"], "skins": json.loads(bake["skins_json"]),
            "qa_status": bake["qa_status"], "reason": bake["error"],
            "godot_scene": bake["godot_scene"], "godot_spriteframes": bake["godot_spriteframes"],
            "atlas_outputs": json.loads(bake["atlas_outputs_json"] or "[]"),
            "local_output_path": bake["output_path"], "converter_sha256": bake["converter_sha256"]},
            ensure_ascii=False, indent=2))
        return
    if row["qa_status"] != "PASS":
        print(json.dumps({"status": "BLOCKED", "source_id": row["source_id"], "qa_status": row["qa_status"],
                          "reason": row["error"] or row["source_reason"] or "No QA_PASS asset output"}, ensure_ascii=False, indent=2))
        return
    status = "QA_PASS" if row["library_status"] == "QA_PASS" else "QA_PASS_HISTORICAL"
    result = {"status": status, "source_id": row["source_id"], "asset_id": row["asset_id"],
              "source_sha256": row["source_sha256"], "output_sha256": row["output_sha256"],
              "godot_scene": row["godot_scene"], "godot_spriteframes": row["godot_spriteframes"],
              "atlas_outputs": json.loads(row["atlas_outputs_json"] or "[]"),
              "dependencies": ["res://assets/actors/" + row["asset_id"] + "/" + name
                               for name in json.loads(row["atlas_outputs_json"] or "[]")],
              "local_output_path": row["output_path"], "converter_sha256": row["converter_sha256"]}
    print(json.dumps(result, ensure_ascii=False, indent=2))


def available_ram_mib() -> int | None:
    if os.name != "nt":
        return None
    class MEMORYSTATUSEX(ctypes.Structure):
        _fields_ = [("dwLength", ctypes.c_ulong), ("dwMemoryLoad", ctypes.c_ulong),
                    ("ullTotalPhys", ctypes.c_ulonglong), ("ullAvailPhys", ctypes.c_ulonglong),
                    ("ullTotalPageFile", ctypes.c_ulonglong), ("ullAvailPageFile", ctypes.c_ulonglong),
                    ("ullTotalVirtual", ctypes.c_ulonglong), ("ullAvailVirtual", ctypes.c_ulonglong),
                    ("ullAvailExtendedVirtual", ctypes.c_ulonglong)]
    status = MEMORYSTATUSEX()
    status.dwLength = ctypes.sizeof(status)
    try:
        if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
            return int(status.ullAvailPhys // (1024 * 1024))
    except Exception:
        pass
    return None


def godot_processes() -> list[str]:
    if os.name != "nt":
        return []
    try:
        raw = subprocess.check_output(["tasklist", "/FO", "CSV", "/NH"], text=True, encoding="mbcs", errors="replace")
        return [line.split(",", 1)[0].strip('"') for line in raw.splitlines()
                if line.strip('"').casefold().startswith("godot")]
    except Exception:
        return []


def config_fingerprint(config: dict, row: sqlite3.Row) -> tuple[str, str, dict]:
    tool_root = Path(config["converter_root"]).resolve()
    tool_files = [Path(config["converter_script"]).resolve(), tool_root / "native" / "capture_spine.gd",
                  tool_root / "native" / "inspect_spine.gd", tool_root / "asset_bundle.py"]
    converter_sha = bundle_sha256([path for path in tool_files if path.is_file()])
    bake = {key: config.get(key) for key in ("fps", "width", "height", "foot_x", "foot_y")}
    fingerprint = hashlib.sha256(json_dump({"source": row["fingerprint"], "converter": converter_sha, "bake": bake}).encode("utf-8")).hexdigest()
    return converter_sha, fingerprint, bake


def convert_one(config: dict, con: sqlite3.Connection, row: sqlite3.Row) -> bool:
    if row["duplicate_of"]:
        con.execute("UPDATE assets SET conversion_status='DUPLICATE_ALIAS',library_status='PARTIAL',qa_status='NOT_REQUIRED_DUPLICATE',updated_utc=? WHERE source_key=?",
                    (now_utc(), row["source_key"]))
        con.commit()
        return True
    if row["source_status"] == "UNSUPPORTED" or (row["spine_version"] and not str(row["spine_version"]).startswith("3.8.")):
        con.execute("UPDATE assets SET library_status='SKIPPED_UNSUPPORTED',conversion_status='SKIPPED_UNSUPPORTED',qa_status='SKIPPED_UNSUPPORTED',updated_utc=? WHERE source_key=?",
                    (now_utc(), row["source_key"]))
        con.commit()
        return True
    if row["source_status"] != "READY":
        con.execute("UPDATE assets SET library_status='PARTIAL',conversion_status='SKIPPED_SOURCE_REVIEW',qa_status='PARTIAL',updated_utc=? WHERE source_key=?",
                    (now_utc(), row["source_key"]))
        con.commit()
        return True
    ram = available_ram_mib()
    minimum_ram = int(config.get("minimum_available_ram_mib", 2200))
    free_disk = shutil.disk_usage(library_paths(config)["root"]).free
    minimum_disk = int(config.get("minimum_free_disk_bytes", 5 * 1024**3))
    active_godot = godot_processes()
    blockers = []
    if ram is None: blockers.append("cannot_read_available_RAM")
    elif ram < minimum_ram: blockers.append(f"available_RAM_{ram}MiB_below_{minimum_ram}MiB")
    if free_disk < minimum_disk: blockers.append(f"free_disk_{free_disk}_below_reserve_{minimum_disk}")
    if active_godot: blockers.append("another_Godot_process_running:" + ",".join(active_godot))
    if blockers:
        reason = "RESOURCE_LIMIT: " + "; ".join(blockers)
        if row["qa_status"] == "PASS":
            con.execute("UPDATE assets SET library_status='PARTIAL',conversion_status='BLOCKED_RESOURCE_LIMIT_REFRESH',error=?,updated_utc=? WHERE source_key=?",
                        ("Historical QA PASS; current converter refresh " + reason, now_utc(), row["source_key"]))
        else:
            con.execute("UPDATE assets SET library_status='BLOCKED',conversion_status='BLOCKED_RESOURCE_LIMIT',qa_status='BLOCKED',error=?,updated_utc=? WHERE source_key=?",
                        (reason, now_utc(), row["source_key"]))
        con.commit()
        print(json.dumps({"status": "BLOCKED", "source_id": row["source_id"], "reason": reason}, ensure_ascii=False), flush=True)
        return False
    source_root = Path(config["source_root"]).resolve()
    skel = source_root / Path(*PurePosixPath(row["skel_rel"]).parts)
    if not row["atlas_rel"]:
        reason = "BLOCKED: source catalog has no unique atlas for this rig"
        con.execute("UPDATE assets SET library_status='BLOCKED',conversion_status='BLOCKED_SOURCE',qa_status='BLOCKED',error=?,updated_utc=? WHERE source_key=?",
                    (reason, now_utc(), row["source_key"]))
        con.commit()
        return False
    atlas = source_root / Path(*PurePosixPath(row["atlas_rel"]).parts)
    texture_entries = json.loads(row["textures_json"])
    texture_dirs = {str((source_root / Path(*PurePosixPath(item["path"]).parts)).parent) for item in texture_entries if item.get("path")}
    texture_dir = Path(next(iter(texture_dirs))) if len(texture_dirs) == 1 else atlas.parent
    asset_id = row["asset_id"]
    output_root = library_paths(config)["output"]
    output = output_root / asset_id
    converter = Path(config["converter_script"]).resolve()
    converter_sha, fingerprint, bake = config_fingerprint(config, row)
    args = [str(Path(config.get("python", sys.executable))), str(converter),
            "--input", str(skel), "--atlas", str(atlas), "--textures", str(texture_dir),
            "--output", str(output), "--actor-id", asset_id,
            "--godot45", str(Path(config["godot45"]).resolve()),
            "--spine-project", str(Path(config["spine_project"]).resolve()),
            "--godot472", str(Path(config["godot472"]).resolve()),
            "--fps", str(bake["fps"]), "--width", str(bake["width"]),
            "--height", str(bake["height"]), "--foot-x", str(bake["foot_x"]), "--foot-y", str(bake["foot_y"]),
            "--timeout", str(config.get("timeout_seconds", 3600))]
    con.execute("UPDATE assets SET conversion_status='RUNNING',library_status='BLOCKED',qa_status='PENDING',converter_sha256=?,bake_config_json=?,error=NULL,updated_utc=? WHERE source_key=?",
                (converter_sha, json_dump(bake), now_utc(), row["source_key"]))
    con.commit()
    print(f"CONVERT_START {row['source_id']} -> {output}", flush=True)
    try:
        process = subprocess.run(args, text=True, encoding="utf-8", errors="replace",
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 timeout=int(config.get("timeout_seconds", 3600)))
        result = verify_output(config, asset_id)
        if process.returncode == 0 and result and result.get("status") == "PASS":
            manifest = result["manifest"]
            names = [page["file"] for page in manifest.get("atlas_pages", [])]
            digest = bundle_sha256([Path(result["path"]) / name for name in manifest.get("file_sha256", {})])
            con.execute("""UPDATE assets SET library_status='QA_PASS',conversion_status='CONVERTED',qa_status='PASS',
                converter_sha256=?,bake_config_json=?,output_path=?,output_sha256=?,godot_scene=?,godot_spriteframes=?,
                atlas_outputs_json=?,error=?,updated_utc=? WHERE source_key=?""",
                (converter_sha, json_dump(bake), result["path"], digest,
                 f"res://assets/actors/{asset_id}/actor.tscn", f"res://assets/actors/{asset_id}/animations.tres",
                 json_dump(names), None, now_utc(), row["source_key"]))
            con.commit()
            preview = generate_preview(config, asset_id, result["qa_dir"])
            if preview:
                con.execute("UPDATE assets SET preview_rel=?,updated_utc=? WHERE source_key=?",
                            (preview, now_utc(), row["source_key"]))
                con.commit()
            write_exports(config, con)
            print(f"QA_PASS {row['source_id']} {digest}", flush=True)
            return True
        log = (process.stdout or "")[-4000:]
        reason = f"converter_exit={process.returncode}; {log}" if process.returncode else (result or {}).get("error", "Godot QA evidence missing")
    except subprocess.TimeoutExpired as exc:
        reason = f"TIMEOUT after {exc.timeout}s"
    except Exception as exc:
        reason = f"{type(exc).__name__}: {exc}"
    con.execute("UPDATE assets SET library_status='BLOCKED',conversion_status='FAILED',qa_status='FAIL',converter_sha256=?,bake_config_json=?,error=?,updated_utc=? WHERE source_key=?",
                (converter_sha, json_dump(bake), reason[:4000], now_utc(), row["source_key"]))
    con.commit()
    write_exports(config, con)
    print(f"QA_FAIL {row['source_id']}: {reason[:500]}", flush=True)
    return False


def generate_preview(config: dict, asset_id: str, qa_dir: str) -> str | None:
    try:
        from PIL import Image, ImageOps, ImageDraw
    except Exception:
        root = library_paths(config)["previews"]
        root.mkdir(parents=True, exist_ok=True)
        target = root / f"{asset_id}.png"
        if target.is_file():
            return f"previews/{asset_id}.png"
        qa = Path(qa_dir)
        candidates = sorted(qa.glob("*_first_godot472.png")) or sorted(qa.glob("*_first_native45.png"))
        if not candidates:
            return None
        shutil.copy2(candidates[0], target)
        return f"previews/{asset_id}.png"
    root = library_paths(config)["previews"]
    root.mkdir(parents=True, exist_ok=True)
    target = root / f"{asset_id}.png"
    if target.exists():
        return f"previews/{asset_id}.png"
    manifest_path = None
    for output in output_roots(config):
        candidate = output / asset_id / "asset.json"
        if candidate.is_file():
            manifest_path = candidate
            break
    if not manifest_path:
        return None
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    qa = Path(qa_dir)
    thumbnails = []
    for clip in manifest.get("clips", []):
        name = clip["name"]
        for point in ("first", "middle", "last"):
            path = qa / f"{name}_{point}_godot472.png"
            if not path.is_file():
                continue
            image = Image.open(path).convert("RGBA")
            image.thumbnail((256, 256), Image.Resampling.LANCZOS)
            tile = Image.new("RGBA", (280, 300), (34, 39, 49, 255))
            tile.alpha_composite(image, ((280-image.width)//2, 6 + (260-image.height)//2))
            draw = ImageDraw.Draw(tile)
            draw.text((8, 272), f"{name} / {point}", fill=(235, 235, 235, 255))
            thumbnails.append(tile)
        if len(thumbnails) >= 9:
            break
    if not thumbnails:
        return None
    columns = min(3, len(thumbnails))
    rows = (len(thumbnails) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns*280, rows*300), (24, 28, 37, 255))
    for index, tile in enumerate(thumbnails):
        sheet.alpha_composite(tile, ((index % columns)*280, (index // columns)*300))
    sheet.convert("RGB").save(target, quality=92)
    return f"previews/{asset_id}.png"


def command_convert(config: dict, con: sqlite3.Connection, identifier: str, skins: list[str] | None = None) -> None:
    row = find_asset(con, identifier)
    if skins:
        command_convert_skin_variant(config, con, row, skins)
        return
    converter_sha = bundle_sha256([Path(config["converter_script"]),
        Path(config["converter_root"]) / "native" / "capture_spine.gd",
        Path(config["converter_root"]) / "native" / "inspect_spine.gd",
        Path(config["converter_root"]) / "asset_bundle.py"])
    if row["qa_status"] == "PASS" and row["converter_sha256"] == converter_sha:
        print(json.dumps({"status": "UNCHANGED_SKIPPED", "source_id": row["source_id"],
                          "output_sha256": row["output_sha256"], "output_path": row["output_path"]}, ensure_ascii=False, indent=2))
        return
    convert_one(config, con, row)
    write_exports(config, con)


def command_convert_skin_variant(config: dict, con: sqlite3.Connection, row: sqlite3.Row,
                                 skins: list[str]) -> None:
    if not skins:
        raise ValueError("Provide one or more --skin names for an on-demand skin combination")
    available = {item.get("name") for item in json.loads(row["skins_json"] or "[]")}
    missing = [name for name in skins if name not in available]
    if missing:
        raise ValueError("Skin name(s) are not present in this Spine source: " + ", ".join(missing))
    if len(set(skins)) != len(skins):
        raise ValueError("Repeated --skin names are not allowed")
    if row["source_status"] != "READY":
        raise ValueError("Skin bake requires a source rig marked READY; current status=" + row["source_status"])
    converter_sha, base_fingerprint, bake = config_fingerprint(config, row)
    fingerprint = hashlib.sha256(json_dump({"base": base_fingerprint, "skins": skins}).encode("utf-8")).hexdigest()
    variant_id = safe_id(row["asset_id"][:38] + "__s_" + fingerprint[:16])
    bake_key = hashlib.sha256(json_dump({"source_key": row["source_key"], "fingerprint": fingerprint}).encode("utf-8")).hexdigest()
    prior = con.execute("SELECT * FROM bakes WHERE bake_key=?", (bake_key,)).fetchone()
    if prior and prior["qa_status"] == "PASS" and prior["converter_sha256"] == converter_sha:
        result = verify_output(config, variant_id)
        if result and result.get("status") == "PASS":
            print(json.dumps({"status": "UNCHANGED_SKIPPED", "asset_id": variant_id,
                              "source_id": row["source_id"], "skins": skins,
                              "output_sha256": prior["output_sha256"], "output_path": prior["output_path"]},
                             ensure_ascii=False, indent=2))
            return
    ram = available_ram_mib()
    minimum_ram = int(config.get("minimum_available_ram_mib", 2200))
    free_disk = shutil.disk_usage(library_paths(config)["root"]).free
    minimum_disk = int(config.get("minimum_free_disk_bytes", 5 * 1024**3))
    active_godot = godot_processes()
    blockers = []
    if ram is None: blockers.append("cannot_read_available_RAM")
    elif ram < minimum_ram: blockers.append(f"available_RAM_{ram}MiB_below_{minimum_ram}MiB")
    if free_disk < minimum_disk: blockers.append(f"free_disk_{free_disk}_below_reserve_{minimum_disk}")
    if active_godot: blockers.append("another_Godot_process_running:" + ",".join(active_godot))
    output = library_paths(config)["output"] / variant_id
    bake_json = json_dump({**bake, "skins": skins})
    timestamp = now_utc()
    if blockers:
        reason = "RESOURCE_LIMIT: " + "; ".join(blockers)
        con.execute("""INSERT INTO bakes(bake_key,source_key,source_id,asset_id,skins_json,fingerprint,
            converter_sha256,bake_config_json,library_status,conversion_status,qa_status,error,updated_utc)
            VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(bake_key) DO UPDATE SET
            converter_sha256=excluded.converter_sha256,bake_config_json=excluded.bake_config_json,
            library_status=excluded.library_status,conversion_status=excluded.conversion_status,
            qa_status=excluded.qa_status,error=excluded.error,updated_utc=excluded.updated_utc""",
            (bake_key, row["source_key"], row["source_id"], variant_id, json_dump(skins), fingerprint,
             converter_sha, bake_json, "BLOCKED", "BLOCKED_RESOURCE_LIMIT", "BLOCKED", reason, timestamp))
        con.commit(); write_exports(config, con)
        print(json.dumps({"status": "BLOCKED", "asset_id": variant_id, "skins": skins, "reason": reason},
                         ensure_ascii=False, indent=2))
        return
    if not row["atlas_rel"]:
        raise ValueError("Source catalog has no unique atlas for this rig")
    source_root = Path(config["source_root"]).resolve()
    skel = source_root / Path(*PurePosixPath(row["skel_rel"]).parts)
    atlas = source_root / Path(*PurePosixPath(row["atlas_rel"]).parts)
    texture_entries = json.loads(row["textures_json"])
    texture_dirs = {str((source_root / Path(*PurePosixPath(item["path"]).parts)).parent)
                    for item in texture_entries if item.get("path")}
    texture_dir = Path(next(iter(texture_dirs))) if len(texture_dirs) == 1 else atlas.parent
    args = [str(Path(config.get("python", sys.executable))), str(Path(config["converter_script"]).resolve()),
        "--input", str(skel), "--atlas", str(atlas), "--textures", str(texture_dir),
        "--output", str(output), "--actor-id", variant_id,
        "--godot45", str(Path(config["godot45"]).resolve()),
        "--spine-project", str(Path(config["spine_project"]).resolve()),
        "--godot472", str(Path(config["godot472"]).resolve()),
        "--fps", str(bake["fps"]), "--width", str(bake["width"]), "--height", str(bake["height"]),
        "--foot-x", str(bake["foot_x"]), "--foot-y", str(bake["foot_y"]),
        "--timeout", str(config.get("timeout_seconds", 3600))]
    for skin in skins: args.extend(["--skin", skin])
    print(f"CONVERT_SKIN_START {row['source_id']} {skins} -> {output}", flush=True)
    try:
        process = subprocess.run(args, text=True, encoding="utf-8", errors="replace",
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 timeout=int(config.get("timeout_seconds", 3600)))
        result = verify_output(config, variant_id)
        manifest = result["manifest"] if result and result.get("status") == "PASS" else {}
        if process.returncode == 0 and manifest and manifest.get("skin_selection_runtime") == skins:
            digest = bundle_sha256([Path(result["path"]) / name for name in manifest.get("file_sha256", {})])
            pages = [page["file"] for page in manifest.get("atlas_pages", [])]
            values = (bake_key, row["source_key"], row["source_id"], variant_id, json_dump(skins), fingerprint,
                converter_sha, bake_json, "QA_PASS", "CONVERTED", "PASS", result["path"], digest,
                f"res://assets/actors/{variant_id}/actor.tscn", f"res://assets/actors/{variant_id}/animations.tres",
                json_dump(pages), f"Godot 4.7.2 import/resource/playback verified; see {result['qa_dir']}", now_utc())
            con.execute("""INSERT INTO bakes(bake_key,source_key,source_id,asset_id,skins_json,fingerprint,
                converter_sha256,bake_config_json,library_status,conversion_status,qa_status,output_path,
                output_sha256,godot_scene,godot_spriteframes,atlas_outputs_json,error,updated_utc)
                VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(bake_key) DO UPDATE SET
                converter_sha256=excluded.converter_sha256,bake_config_json=excluded.bake_config_json,
                library_status=excluded.library_status,conversion_status=excluded.conversion_status,
                qa_status=excluded.qa_status,output_path=excluded.output_path,output_sha256=excluded.output_sha256,
                godot_scene=excluded.godot_scene,godot_spriteframes=excluded.godot_spriteframes,
                atlas_outputs_json=excluded.atlas_outputs_json,error=excluded.error,updated_utc=excluded.updated_utc""", values)
            con.commit(); write_exports(config, con)
            print(json.dumps({"status": "QA_PASS", "source_id": row["source_id"], "asset_id": variant_id,
                              "skins": skins, "source_sha256": row["source_sha256"], "output_sha256": digest,
                              "scene": f"res://assets/actors/{variant_id}/actor.tscn"}, ensure_ascii=False, indent=2))
            return
        reason = (process.stdout or "")[-4000:] or (result or {}).get("error", "Godot QA evidence missing")
    except subprocess.TimeoutExpired as exc:
        reason = f"TIMEOUT after {exc.timeout}s"
    except Exception as exc:
        reason = f"{type(exc).__name__}: {exc}"
    con.execute("""INSERT INTO bakes(bake_key,source_key,source_id,asset_id,skins_json,fingerprint,
        converter_sha256,bake_config_json,library_status,conversion_status,qa_status,error,updated_utc)
        VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(bake_key) DO UPDATE SET
        library_status='BLOCKED',conversion_status='FAILED',qa_status='FAIL',error=excluded.error,
        updated_utc=excluded.updated_utc""",
        (bake_key, row["source_key"], row["source_id"], variant_id, json_dump(skins), fingerprint,
         converter_sha, bake_json, "BLOCKED", "FAILED", "FAIL", reason[:4000], now_utc()))
    con.commit(); write_exports(config, con)
    print(json.dumps({"status": "FAIL", "source_id": row["source_id"], "asset_id": variant_id,
                      "skins": skins, "reason": reason[-1000:]}, ensure_ascii=False, indent=2))


def command_resume(config: dict, con: sqlite3.Connection, limit: int | None = None) -> None:
    converter_sha = bundle_sha256([Path(config["converter_script"]),
        Path(config["converter_root"]) / "native" / "capture_spine.gd",
        Path(config["converter_root"]) / "native" / "inspect_spine.gd",
        Path(config["converter_root"]) / "asset_bundle.py"])
    rows = list(con.execute("""SELECT * FROM assets WHERE source_status='READY'
        AND duplicate_of IS NULL ORDER BY source_id COLLATE NOCASE"""))
    rows = [row for row in rows if row["qa_status"] != "PASS" or row["converter_sha256"] != converter_sha]
    bake_jobs = list(con.execute("SELECT * FROM bakes WHERE qa_status!='PASS' ORDER BY source_id COLLATE NOCASE,asset_id COLLATE NOCASE"))
    if limit is not None:
        rows = rows[:max(0, limit)]
    ram = available_ram_mib()
    free_disk = shutil.disk_usage(library_paths(config)["root"]).free
    minimum_ram = int(config.get("minimum_available_ram_mib", 2200))
    minimum_disk = int(config.get("minimum_free_disk_bytes", 5 * 1024**3))
    active_godot = godot_processes()
    blockers = []
    if ram is None: blockers.append("cannot_read_available_RAM")
    elif ram < minimum_ram: blockers.append(f"available_RAM_{ram}MiB_below_{minimum_ram}MiB")
    if free_disk < minimum_disk: blockers.append(f"free_disk_{free_disk}_below_reserve_{minimum_disk}")
    if active_godot: blockers.append("another_Godot_process_running:" + ",".join(active_godot))
    if blockers and rows:
        reason = "RESOURCE_LIMIT: " + "; ".join(blockers)
        timestamp = now_utc()
        con.execute("""UPDATE assets SET library_status='PARTIAL',qa_status='NOT_REQUIRED_DUPLICATE',
            error='Exact source fingerprint duplicates another indexed rig; convert once and reuse by alias.',updated_utc=?
            WHERE source_status='READY' AND conversion_status='DUPLICATE_ALIAS'""", (timestamp,))
        con.executemany("""UPDATE assets SET library_status='BLOCKED',conversion_status='BLOCKED_RESOURCE_LIMIT',
            qa_status='BLOCKED',converter_sha256=?,error=?,updated_utc=? WHERE source_key=?""",
            [(converter_sha, reason, timestamp, row["source_key"]) for row in rows if row["qa_status"] != "PASS"])
        con.executemany("""UPDATE assets SET library_status='PARTIAL',conversion_status='BLOCKED_RESOURCE_LIMIT_REFRESH',
            error=?,updated_utc=? WHERE source_key=?""",
            [("Historical QA PASS; current converter refresh " + reason, timestamp, row["source_key"])
             for row in rows if row["qa_status"] == "PASS"])
        con.execute("""UPDATE bakes SET library_status='BLOCKED',conversion_status='BLOCKED_RESOURCE_LIMIT',
            qa_status='BLOCKED',error=?,updated_utc=? WHERE qa_status!='PASS'""", (reason, timestamp))
        con.commit()
        write_exports(config, con)
        print(json.dumps({"status": "BLOCKED", "queued": len(rows), "queued_skin_bakes": len(bake_jobs), "workers": 1,
                          "reason": reason, "checkpoint": "each row marked; rerun resume after resources recover"},
                         ensure_ascii=False, indent=2), flush=True)
        command_status(config, con)
        return
    print(f"RESUME_QUEUE {len(rows)} workers=1", flush=True)
    for index, row in enumerate(rows, 1):
        print(f"RESUME {index}/{len(rows)}", flush=True)
        if not convert_one(config, con, row):
            # A resource or integrity block stops the run; the saved record is resumable.
            if str((con.execute("SELECT error FROM assets WHERE source_key=?", (row["source_key"],)).fetchone() or [""])[0]).startswith("RESOURCE_LIMIT"):
                break
    for index, bake in enumerate(bake_jobs, 1):
        print(f"RESUME_SKIN_BAKE {index}/{len(bake_jobs)}", flush=True)
        base = con.execute("SELECT * FROM assets WHERE source_key=?", (bake["source_key"],)).fetchone()
        command_convert_skin_variant(config, con, base, json.loads(bake["skins_json"]))
    write_exports(config, con)
    command_status(config, con)


def command_verify(config: dict, con: sqlite3.Connection, identifier: str | None) -> None:
    rows = [find_asset(con, identifier)] if identifier else list(con.execute("SELECT * FROM assets ORDER BY source_id COLLATE NOCASE"))
    results = []
    for row in rows:
        source_root = Path(config["source_root"]).resolve()
        checks = [("skeleton", row["skel_rel"], row["source_sha256"]), ("atlas", row["atlas_rel"], row["atlas_sha256"])]
        for item in json.loads(row["textures_json"] or "[]"):
            checks.append(("texture", item.get("path"), item.get("sha256")))
        input_status = []
        for kind, relative, expected in checks:
            if not relative:
                input_status.append({"kind": kind, "status": "MISSING_REFERENCE"})
                continue
            path = source_root / Path(*PurePosixPath(relative).parts)
            if not path.is_file():
                input_status.append({"kind": kind, "path": relative, "status": "MISSING"})
            else:
                actual = sha256_file(path)
                input_status.append({"kind": kind, "path": relative,
                                     "status": "PASS" if actual == expected else "HASH_MISMATCH",
                                     "sha256": actual})
        output = verify_output(config, row["asset_id"])
        results.append({"source_id": row["source_id"], "asset_id": row["asset_id"],
                        "inputs": input_status, "output_status": output.get("status") if output else "NOT_PRESENT",
                        "output_error": output.get("error") if output else None,
                        "qa_status": row["qa_status"], "library_status": row["library_status"]})
    print(json.dumps({"verified": len(results), "results": results}, ensure_ascii=False, indent=2))


def command_refresh_inventory(config: dict, con: sqlite3.Connection) -> None:
    source = connect_source_catalog(config)
    prefix = str(config["source_catalog_prefix"]).replace("\\", "/").strip("/")
    rows = source.execute("SELECT * FROM files WHERE root_alias=? AND relative_path LIKE ? ORDER BY relative_path COLLATE NOCASE",
                          (config.get("source_catalog_alias", "A_ASSETS"), prefix + "/%")).fetchall()
    used_paths = set()
    source_dirs = set()
    for row in con.execute("SELECT * FROM assets"):
        used_paths.add(row["skel_rel"].casefold())
        if row["atlas_rel"]: used_paths.add(row["atlas_rel"].casefold())
        used_paths.update((item.get("path") or "").casefold() for item in json.loads(row["textures_json"] or "[]"))
        source_dirs.add((prefix + "/" + row["source_dir_rel"]).rstrip("/").casefold())
    inventory = []
    for row in rows:
        path, rel = local_from_catalog(config, row["relative_path"])
        digest, method = cached_or_hash(path, row)
        suffix = Path(row["name"]).suffix.lower()
        lower_name = row["name"].lower()
        kind = ("skeleton" if ".skel" in lower_name else "atlas" if ".atlas" in lower_name else
                "texture" if suffix == ".png" else "animation_metadata" if suffix == ".json" else "ancillary")
        rel = rel.replace("\\", "/")
        inventory.append({"kind": kind, "relative_path": rel, "sha256": digest,
            "bytes": row["size"], "hash_method": method,
            "referenced_by_rig": rel.casefold() in used_paths or
                str(PurePosixPath(rel).parent).casefold() in source_dirs,
            "file_status": "PRESENT" if path.is_file() else "MISSING"})
    source.close()
    write_exports(config, con, inventory)
    print(json.dumps({"input_files": len(inventory),
        "by_kind": dict(Counter(item["kind"] for item in inventory)),
        "missing": sum(item["file_status"] == "MISSING" for item in inventory)}, ensure_ascii=False, indent=2))


def command_export_github(config: dict, con: sqlite3.Connection) -> None:
    directory = Path(config.get("github_index_dir", str(library_paths(config)["root"] / "github" / "catalog"))).resolve()
    directory.mkdir(parents=True, exist_ok=True)
    for old in directory.glob("catalog-part-*.jsonl"):
        old.unlink()
    schema_path = directory / "catalog.schema.json"
    schema_path.write_text(json.dumps(GITHUB_INDEX_SCHEMA, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    chunk_size = int(config.get("github_rows_per_file", 100))
    chunk_index = 0
    in_chunk = 0
    records = 0
    handle = None
    parts = []
    for row in con.execute("SELECT * FROM assets ORDER BY source_id COLLATE NOCASE, source_sha256"):
        if handle is None or in_chunk >= chunk_size:
            if handle: handle.close()
            chunk_index += 1; in_chunk = 0
            filename = f"catalog-part-{chunk_index:03d}.jsonl"
            handle = (directory / filename).open("w", encoding="utf-8", newline="\n")
            parts.append({"file": filename, "records": 0})
        raw = asset_record(row)
        histories = [dict(item) for item in con.execute(
            "SELECT attempted_utc,result,summary,log_relative_path FROM qa_history WHERE source_key=? ORDER BY attempted_utc",
            (row["source_key"],))]
        item = {"schema_version": SCHEMA_VERSION, "source_id": raw["source_id"], "asset_id": raw["asset_id"],
            "source_sha256": raw["source_sha256"], "atlas_sha256": raw["atlas_sha256"],
            "source_status": raw["source_status"], "source_reason": raw["source_reason"],
            "spine_version": raw["spine_version"], "bones": raw["bones"], "slots": raw["slots"],
            "skins": [skin.get("name") for skin in raw["skins"]],
            "attachments": sorted({attachment.get("name") for attachment in raw["attachments"] if attachment.get("name")}, key=str.casefold),
            "clips": [[clip.get("name"), clip.get("duration_seconds")] for clip in raw["clips"]],
            "role": raw["role"], "gender": raw["gender"], "source_category_candidate": raw["source_category_candidate"],
            "library_status": raw["library_status"], "conversion_status": raw["conversion_status"],
            "qa_status": raw["qa_status"], "qa_evidence": raw["qa_evidence"],
            "converter_sha256": raw["converter_sha256"], "output_sha256": raw["output_sha256"],
            "godot_scene": raw["godot_scene"], "godot_spriteframes": raw["godot_spriteframes"],
            "atlas_outputs": raw["atlas_outputs"], "duplicate_of": raw["duplicate_of"], "historical_qa": histories,
            "skin_bakes": [{"asset_id": bake["asset_id"], "skins": json.loads(bake["skins_json"]),
                "qa_status": bake["qa_status"], "library_status": bake["library_status"],
                "conversion_status": bake["conversion_status"], "converter_sha256": bake["converter_sha256"],
                "output_sha256": bake["output_sha256"], "godot_scene": bake["godot_scene"],
                "godot_spriteframes": bake["godot_spriteframes"], "atlas_outputs": json.loads(bake["atlas_outputs_json"] or "[]")}
                for bake in con.execute("SELECT * FROM bakes WHERE source_key=? ORDER BY asset_id COLLATE NOCASE", (row["source_key"],))]}
        handle.write(json_dump(item) + "\n")
        in_chunk += 1; records += 1; parts[-1]["records"] += 1
    if handle: handle.close()
    for part in parts:
        path = directory / part["file"]
        part["bytes"] = path.stat().st_size
        part["sha256"] = sha256_file(path)
    manifest = {"schema_version": SCHEMA_VERSION, "generated_utc": now_utc(), "records": records,
        "input_files": con.execute("SELECT COUNT(*) FROM input_files").fetchone()[0],
        "rows_per_file": chunk_size, "schema_file": schema_path.name, "parts": parts,
        "note": "Path-free searchable metadata snapshot. Raw Source A art, local paths, SQLite, and Godot binaries are excluded."}
    manifest["status_breakdown"] = [dict(row) for row in con.execute(
        "SELECT library_status,qa_status,source_status,conversion_status,COUNT(*) AS n FROM assets GROUP BY 1,2,3,4")]
    manifest_path = directory / "catalog.manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"directory": str(directory), "records": records, "parts": len(parts),
        "bytes": sum(item["bytes"] for item in parts), "manifest": str(manifest_path)}, ensure_ascii=False, indent=2))


def find_pack_asset(con: sqlite3.Connection, identifier: str) -> dict:
    try:
        return dict(find_asset(con, identifier))
    except ValueError:
        bake = con.execute("SELECT * FROM bakes WHERE asset_id=? COLLATE NOCASE", (identifier,)).fetchone()
        if not bake:
            raise
        source = con.execute("SELECT * FROM assets WHERE source_key=?", (bake["source_key"],)).fetchone()
        return {**dict(bake), "source_sha256": source["source_sha256"],
                "atlas_outputs_json": bake["atlas_outputs_json"]}


def command_export_pack(config: dict, con: sqlite3.Connection, identifiers: list[str], target: Path, name: str | None) -> None:
    rows = [find_pack_asset(con, identifier) for identifier in identifiers]
    failed = [row["source_id"] for row in rows if row["qa_status"] != "PASS"]
    if failed:
        raise ValueError("Only QA_PASS assets can be packed: " + ", ".join(failed))
    target = target.expanduser().resolve()
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        raise ValueError(f"Pack exists; refusing to overwrite: {target}")
    pack_name = name or target.stem
    with tempfile.TemporaryDirectory(prefix="sourcea_pack_") as tmp:
        root = Path(tmp)
        first_id = rows[0]["asset_id"]
        project = ("config_version=5\n\n[application]\n" 
                   f"config/name=\"SourceA {pack_name}\"\nrun/main_scene=\"res://assets/actors/{first_id}/actor.tscn\"\n\n"
                   "[rendering]\nrenderer/rendering_method=\"gl_compatibility\"\n"
                   "renderer/rendering_method.mobile=\"gl_compatibility\"\n")
        (root / "project.godot").write_text(project, encoding="utf-8")
        pack_records = []
        for row in rows:
            source = Path(row["output_path"])
            dest = root / "assets" / "actors" / row["asset_id"]
            if not source.is_dir():
                raise ValueError(f"QA_PASS output folder missing: {source}")
            shutil.copytree(source, dest)
            pack_records.append({"source_id": row["source_id"], "asset_id": row["asset_id"],
                                 "source_sha256": row["source_sha256"], "output_sha256": row["output_sha256"],
                                 "qa_status": row["qa_status"], "library_status": row["library_status"],
                                 "conversion_status": row["conversion_status"],
                                 "converter_sha256": row["converter_sha256"],
                                 "scene": f"res://assets/actors/{row['asset_id']}/actor.tscn",
                                 "spriteframes": f"res://assets/actors/{row['asset_id']}/animations.tres",
                                 "atlas_outputs": json.loads(row["atlas_outputs_json"] or "[]")})
        (root / "manifest.json").write_text(json.dumps({"schema_version": SCHEMA_VERSION,
            "pack": pack_name, "godot_version": "4.7.2", "assets": pack_records}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        readme = ("# Source A Godot asset pack\n\nOpen this folder or its ZIP with Godot 4.7.2. "
                  "The main scene opens the first actor; each actor uses its original Spine clip names as baked SpriteFrames.\n\n"
                  "These are baked frame assets, not live Spine Skeleton2D rigs. See manifest.json for source/output SHA-256 and QA.\n")
        (root / "README.md").write_text(readme, encoding="utf-8")
        with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
            for path in sorted(root.rglob("*")):
                if path.is_file():
                    archive.write(path, path.relative_to(root).as_posix())
    print(json.dumps({"status": "PACK_CREATED", "path": str(target), "sha256": sha256_file(target),
                      "assets": [row["source_id"] for row in rows]}, ensure_ascii=False, indent=2))


def main() -> int:
    parser = argparse.ArgumentParser(description="Local Source A Spine library; uses the existing SpineToGodot472 converter.")
    parser.add_argument("--config", default=str(Path(__file__).with_name("library.local.json")), help="Local-only path configuration")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("scan", help="Index Source A Spine inputs and export SQLite/JSONL inventories")
    sub.add_parser("refresh-inventory", help="Refresh hashes/status for every file under the SourceA root")
    sub.add_parser("import-history", help="Import verified prior Batch-01 QA blockers into the per-asset history")
    sub.add_parser("export-github", help="Write a path-free, chunked catalog snapshot for the separate GitHub branch")
    sub.add_parser("status", help="Show source, QA, memory, disk and resume estimates")
    find = sub.add_parser("find", help="Search names, clip names, skins and attachments")
    find.add_argument("--query"); find.add_argument("--clip"); find.add_argument("--skin"); find.add_argument("--attachment")
    find.add_argument("--gender", choices=["unknown", "male", "female"]); find.add_argument("--role", choices=["unknown", "npc", "monster", "boss", "mount", "vfx", "ui"])
    find.add_argument("--status"); find.add_argument("--limit", type=int, default=100)
    inspect = sub.add_parser("inspect", help="Show source hashes, clips, skins, attachments, QA and error evidence")
    inspect.add_argument("id")
    resolve = sub.add_parser("resolve", help="Return exact res:// scene, SpriteFrames and atlas dependencies")
    resolve.add_argument("id"); resolve.add_argument("--skin", action="append", default=[])
    verify = sub.add_parser("verify", help="Re-hash source and output dependencies")
    verify.add_argument("id", nargs="?")
    convert = sub.add_parser("convert", help="Convert one READY rig; all runtime-verified clips, one worker")
    convert.add_argument("id"); convert.add_argument("--skin", action="append", default=[],
        help="Bake a validated on-demand skin set; repeat once per selected source skin")
    resume = sub.add_parser("resume", help="Resume the sequential checkpointed conversion queue")
    resume.add_argument("--limit", type=int)
    pack = sub.add_parser("export-pack", help="Build an openable Godot 4.7.2 ZIP from QA_PASS assets")
    pack.add_argument("ids", nargs="+"); pack.add_argument("--output", required=True); pack.add_argument("--name")
    args = parser.parse_args()
    try:
        config = load_config(Path(args.config))
        paths = library_paths(config)
        con = connect_library(config)
        if args.command == "scan":
            result = scan(config, con)
            print(json.dumps(result, ensure_ascii=False, indent=2))
        elif args.command == "refresh-inventory":
            command_refresh_inventory(config, con)
        elif args.command == "export-github":
            command_export_github(config, con)
        elif args.command == "import-history":
            count = import_legacy_attempts(config, con)
            write_exports(config, con)
            print(json.dumps({"historical_attempts_imported": count}, ensure_ascii=False, indent=2))
        elif args.command == "status":
            command_status(config, con)
        elif args.command == "find":
            command_find(args, con)
        elif args.command == "inspect":
            command_inspect(con, args.id)
        elif args.command == "resolve":
            command_resolve(config, con, args.id, args.skin)
        elif args.command == "verify":
            command_verify(config, con, args.id)
        elif args.command == "convert":
            command_convert(config, con, args.id, args.skin)
        elif args.command == "resume":
            command_resume(config, con, args.limit)
        elif args.command == "export-pack":
            command_export_pack(config, con, args.ids, Path(args.output), args.name)
        con.close()
        return 0
    except Exception as exc:
        if os.environ.get("SOURCEA_DEBUG"):
            traceback.print_exc()
        print(f"ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

