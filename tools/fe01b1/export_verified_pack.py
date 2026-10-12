#!/usr/bin/env python3
"""FE-01B1 isolated, verified candidate-pack exporter (tooling only).

Source A CSV remains external. Never imports to Godot, registers approval,
changes simulation, configures LFS, or grants distribution rights.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import shutil
import tempfile
from pathlib import Path, PurePosixPath, PureWindowsPath

_HEX64 = re.compile(r"^[a-f0-9]{64}$")
_ID = re.compile(r"^(?:building\.[a-z0-9_]+|actor\.disciple\.[a-zA-Z0-9_]+)$")
_NAME = re.compile(r"^[A-Za-z0-9_.-]+$")
_RESERVED = {"CON", "PRN", "AUX", "NUL", *(f"COM{i}" for i in range(1, 10)),
             *(f"LPT{i}" for i in range(1, 10))}
_README = (
    "# Isolated FE-01B1 candidate pack\n\n"
    "INTERNAL_LAB_ONLY. Source A art distribution rights are UNVERIFIED.\n"
    "This is a checksum-verified source dependency bundle, not a playable Godot scene,\n"
    "approved TongMon production artwork, or proof of Spine playback.\n"
    "Never install this bundle in the game without separate authorization.\n"
)


class PackError(ValueError):
    """Fail-closed integrity, provenance or destination-policy violation."""


def _sha256(path: Path) -> tuple[str, int]:
    digest = hashlib.sha256()
    count = 0
    with path.open("rb") as handle:
        while chunk := handle.read(1024 * 1024):
            count += len(chunk)
            digest.update(chunk)
    return digest.hexdigest(), count


def _safe_name(name: str) -> str:
    if not isinstance(name, str) or not _NAME.fullmatch(name):
        raise PackError(f"Unsafe dependency filename: {name!r}")
    if name in (".", "..") or name[-1] == "." or name.split(".")[0].upper() in _RESERVED:
        raise PackError(f"Non-portable dependency filename: {name!r}")
    return name


def _resolve_source(raw: str, source_root: Path | None,
                    source_prefix: str | None) -> Path:
    if not isinstance(raw, str) or not raw:
        raise PackError("Missing source_path in external catalog")
    if source_root is None:
        if source_prefix is not None:
            raise PackError("--source-prefix requires --source-root")
        path = Path(raw)
        if not path.is_absolute():
            raise PackError("Catalog source path must be absolute without --source-root")
    else:
        if not source_prefix:
            raise PackError("--source-root requires --source-prefix")
        # Preserve Windows drive semantics even when testing on a Linux runner.
        cls = PureWindowsPath if (PureWindowsPath(raw).drive or "\\" in raw) else PurePosixPath
        given = cls(raw)
        prefix = cls(source_prefix)
        if not given.is_absolute() or not prefix.is_absolute():
            raise PackError("Catalog source and prefix must be absolute")
        try:
            relative = given.relative_to(prefix)
        except ValueError as exc:
            raise PackError(f"Source outside declared catalog prefix: {raw}") from exc
        if not relative.parts or any(p in (".", "..") for p in relative.parts):
            raise PackError(f"Unsafe source relative path: {raw}")
        path = source_root.joinpath(*relative.parts)
        try:
            root_real = source_root.resolve(strict=True)
            path_real = path.resolve(strict=True)
        except (FileNotFoundError, NotADirectoryError) as exc:
            raise PackError(f"Missing source dependency or root: {path}") from exc
        if not path_real.is_relative_to(root_real):
            raise PackError(f"Source escaped declared source root: {raw}")
    if path.is_symlink() or not path.is_file():
        raise PackError(f"Missing or symlinked source dependency: {path}")
    return path


def _load_record(catalog: Path, logical_id: str) -> tuple[str, dict, list[dict]]:
    if not _ID.fullmatch(logical_id):
        raise PackError(f"Unrecognized or unsafe logical ID: {logical_id}")
    if not catalog.is_file():
        raise PackError(f"Catalog not found: {catalog}")
    with catalog.open("r", encoding="utf-8-sig", newline="") as handle:
        records = [row for row in csv.DictReader(handle)
                   if row.get("logical_id") == logical_id]
    if len(records) != 1:
        raise PackError(f"Expected one catalog record for {logical_id}; got {len(records)}")
    record = records[0]
    kind = "building" if logical_id.startswith("building.") else "actor"
    key = "dependencies_selected_model" if kind == "building" else "dependencies"
    try:
        dependencies = json.loads(record[key])
    except (KeyError, ValueError, TypeError) as exc:
        raise PackError("Malformed catalog dependencies") from exc
    if not isinstance(dependencies, list) or not dependencies:
        raise PackError("Empty or invalid catalog dependencies")
    return kind, record, dependencies


def _plan(catalog: Path, logical_id: str, source_root: Path | None,
          source_prefix: str | None) -> tuple[dict, list[tuple[Path, str]]]:
    kind, record, dependencies = _load_record(catalog, logical_id)
    files: list[dict] = []
    sources: list[tuple[Path, str]] = []
    names: set[str] = set()
    for dep in dependencies:
        if not isinstance(dep, dict):
            raise PackError("Malformed dependency entry")
        name = dep.get("name", "")
        dep_kind = dep.get("kind", "")
        if dep_kind == "Texture2D" and isinstance(name, str) and not name.lower().endswith(".png"):
            name += ".png"
        name = _safe_name(name)
        if name.casefold() in names:
            raise PackError(f"Case-insensitive filename collision: {name}")
        names.add(name.casefold())
        expected = dep.get("sha256")
        size = dep.get("bytes")
        if not isinstance(expected, str) or not _HEX64.fullmatch(expected):
            raise PackError(f"Invalid dependency SHA-256: {name}")
        if type(size) is not int or size < 0:
            raise PackError(f"Invalid dependency byte count: {name}")
        path = _resolve_source(dep.get("source_path", ""), source_root, source_prefix)
        actual_digest, actual_size = _sha256(path)
        if (actual_digest, actual_size) != (expected, size):
            raise PackError(f"Source hash/size drift: {path}")
        files.append({"name": name, "source_path": dep["source_path"],
                      "sha256": expected, "bytes": size, "kind": dep_kind})
        sources.append((path, name))
    manifest = {
        "schema_version": 1,
        "logical_id": logical_id,
        "source_variant": record.get("source_variant", ""),
        "rights_status": record.get("rights_status", ""),
        "release_rights": "UNVERIFIED",
        "lab_only": True,
        "export_kind": kind,
        "source_evidence_status": record.get("evidence_status", ""),
        "godot_playback": "NOT_TESTED",
        "files": files,
    }
    return manifest, sources


def _manifest_text(manifest: dict) -> str:
    return json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def _verify_existing(target: Path, manifest: dict) -> None:
    if target.is_symlink() or not target.is_dir():
        raise PackError(f"Existing pack is not an ordinary directory: {target}")
    expected_names = {"manifest.json", "README.md"} | {x["name"] for x in manifest["files"]}
    if {x.name for x in target.iterdir()} != expected_names:
        raise PackError(f"Existing pack has missing/unexpected files: {target}")
    for path in target.iterdir():
        if path.is_symlink() or not path.is_file():
            raise PackError(f"Existing pack contains non-file or symlink: {path}")
    if (target / "manifest.json").read_text(encoding="utf-8") != _manifest_text(manifest):
        raise PackError(f"Existing pack manifest differs: {target}")
    if (target / "README.md").read_text(encoding="utf-8") != _README:
        raise PackError(f"Existing pack README differs: {target}")
    for entry in manifest["files"]:
        actual = _sha256(target / entry["name"])
        if actual != (entry["sha256"], entry["bytes"]):
            raise PackError(f"Existing pack file hash/size drift: {entry['name']}")


def _copy_verified(source: Path, dest: Path, expected: dict) -> None:
    # Rehash while copying: detects source modification between planning and copy.
    digest = hashlib.sha256()
    count = 0
    with source.open("rb") as reader, dest.open("xb") as writer:
        while block := reader.read(1024 * 1024):
            writer.write(block)
            digest.update(block)
            count += len(block)
        writer.flush()
        os.fsync(writer.fileno())
    if (digest.hexdigest(), count) != (expected["sha256"], expected["bytes"]):
        raise PackError(f"Source changed while staging: {source}")
    if _sha256(dest) != (expected["sha256"], expected["bytes"]):
        raise PackError(f"Staging output drift: {dest}")


def export_pack(*, catalog: Path, output_root: Path, logical_id: str,
                source_root: Path | None = None, source_prefix: str | None = None,
                dry_run: bool = False) -> dict:
    """Build an isolated pack, publishing only fully verified staging output.

    An O_EXCL lock prevents concurrent invocations of this exporter for one ID.
    External uncooperative writers are not protected by that lock. No overwrite,
    history rewrite, Git/LFS use or Godot import occurs.
    """
    if not _ID.fullmatch(logical_id):
        raise PackError("Unsafe logical ID")
    output_root = Path(output_root)
    if source_root is not None:
        source_root = Path(source_root)
    manifest, sources = _plan(Path(catalog), logical_id, source_root, source_prefix)
    target = output_root / logical_id
    if dry_run:
        return {"status": "DRY_RUN", "target": str(target), "files": len(sources)}
    if output_root.is_symlink():
        raise PackError("Output root cannot be a symlink")
    output_root.mkdir(parents=True, exist_ok=True)
    if not output_root.is_dir():
        raise PackError("Output root must be a directory")
    lock = output_root / f".{logical_id}.fe01b1.lock"
    try:
        fd = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as exc:
        raise PackError(f"Pack export locked; inspect stale/concurrent lock: {lock}") from exc
    staging: Path | None = None
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write("FE-01B1 exclusive export lock\n")
            handle.flush()
        if target.exists() or target.is_symlink():
            _verify_existing(target, manifest)
            return {"status": "UNCHANGED", "target": str(target), "files": len(sources)}
        staging = Path(tempfile.mkdtemp(prefix=f".{logical_id}.stage-", dir=output_root))
        by_name = {entry["name"]: entry for entry in manifest["files"]}
        for src, dest_name in sources:
            _copy_verified(src, staging / dest_name, by_name[dest_name])
        (staging / "manifest.json").write_text(_manifest_text(manifest), encoding="utf-8")
        (staging / "README.md").write_text(_README, encoding="utf-8")
        _verify_existing(staging, manifest)
        # The stage and destination share a filesystem. Under the cooperative lock
        # only fully verified directories are published, never partial files.
        if target.exists() or target.is_symlink():
            raise PackError(f"Destination appeared during staging; never overwrite: {target}")
        os.rename(staging, target)
        staging = None
        return {"status": "EXPORTED", "target": str(target), "files": len(sources)}
    finally:
        if staging is not None and staging.exists():
            shutil.rmtree(staging)
        lock.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("logical_id", help="E.g. building.main_hall")
    parser.add_argument("--catalog", type=Path, required=True, help="External TransferKit CSV")
    parser.add_argument("--output-root", type=Path, required=True, help="Isolated lab pack directory")
    parser.add_argument("--source-root", type=Path, help="Where source bytes now live")
    parser.add_argument("--source-prefix", help="Original absolute catalog source root to rebase")
    parser.add_argument("--dry-run", action="store_true", help="Check only; make no output")
    args = parser.parse_args()
    try:
        result = export_pack(
            catalog=args.catalog, output_root=args.output_root,
            logical_id=args.logical_id, source_root=args.source_root,
            source_prefix=args.source_prefix, dry_run=args.dry_run,
        )
    except (OSError, PackError, ValueError) as exc:
        print(f"FE-01B1 FAIL: {exc}")
        return 1
    print(f"{result['status']} {result['target']} files {result['files']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
