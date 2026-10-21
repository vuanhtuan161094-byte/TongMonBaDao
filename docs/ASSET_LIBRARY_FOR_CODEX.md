# Source A Spine asset library

The library indexes Source A files in place and stores a separate SQLite catalog, a complete input file inventory, JSONL/schema exports, and QA status. It reuses the existing SpineToGodot472 pipeline; baked output is Godot `SpriteFrames`, not a live Spine skeleton.

## Setup

1. Install Python 3 and put `python` on PATH.
2. Copy `library.local.example.json` to `library.local.json` and edit the machine paths.
3. Run `Run-SourceA-Library.cmd scan`, then `Run-SourceA-Library.cmd status`.

## CLI examples

```powershell
Run-SourceA-Library.cmd scan
Run-SourceA-Library.cmd refresh-inventory
Run-SourceA-Library.cmd status
Run-SourceA-Library.cmd find --clip attack1 --skin outfit_blue
Run-SourceA-Library.cmd inspect SOURCE_ID
Run-SourceA-Library.cmd resolve SOURCE_ID
Run-SourceA-Library.cmd verify SOURCE_ID
Run-SourceA-Library.cmd convert SOURCE_ID
Run-SourceA-Library.cmd convert SOURCE_ID --skin body_skin --skin weapon_skin
Run-SourceA-Library.cmd resume
Run-SourceA-Library.cmd export-github
Run-SourceA-Library.cmd export-pack SOURCE_ID --output packs\sample.zip
```

Repeated `--skin` options choose one exact skin combination from the parser-backed list for that rig. The converter rejects unknown names and fingerprints each variant. It does not enumerate all combinations.

## Status values

- `QA_PASS`: Godot 4.7.2 import, resource and playback checks passed for the recorded fingerprint.
- `PARTIAL`: source review, duplicate alias, or older QA output that does not match the current converter fingerprint.
- `BLOCKED`: a precise source, resource, integrity or converter blocker is recorded.
- `SKIPPED_UNSUPPORTED`: a Spine version outside the supported line was found.

The conversion queue is sequential with one worker. Before each batch it checks available RAM, free disk and other Godot processes. Checkpoints are stored per rig; rerun `resume` when resources recover. Roles and gender remain `UNKNOWN` unless evidence supports a classification.

`export-github` writes a chunked path-free metadata snapshot from the local catalog. The complete catalog and generated asset packs are local outputs; this source package contains only tooling, schemas and documentation.

