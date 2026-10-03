# source_art — editable production masters

This folder is intentionally **outside `godot/`**.

Purpose:

- store approved editable/master artwork when the Git LFS workflow is accepted;
- keep source art separate from exported runtime textures;
- prevent Godot from importing PSD/Krita/reference/archive files that the game does not load directly.

Planned layout:

```text
source_art/
  p3/
    buildings/
    characters/
    environment/
    ui/
```

Runtime exports belong under `godot/assets/p3/...`.

## Current source state

As of 2026-10-03 this folder contains **no production binary masters yet**. Do not infer that a visual-approved asset is already preserved here.

Canonical source availability is tracked in:

- `docs/P3_ASSET_REGISTRY.json`;
- `docs/P3_SOURCE_RECOVERY_MANIFEST.md`.

Evidence classes:

- S0 = exact canonical repo source;
- S1 = exact external pack/file with checksum;
- S2 = exact persistent external file;
- S3 = historical approved visual, exact bytes not recovered;
- S4 = design only / production source not yet created.

An S3 asset must be recovered, not silently regenerated and relabeled as the historical source.

## Rules

- do not place diagnostic Base64 chunks here;
- do not treat a generated mockup as an approved source asset unless user explicitly approves it;
- source filenames use lowercase snake_case when practical;
- registry entry must point to the authority doc and source path once ingested;
- when ingesting recovered source, record filename/path + SHA-256 where practical;
- source binary policy is currently **PROPOSED**, see `docs/decisions/0002-adopt-git-lfs-for-production-art.md`;
- do not enable/migrate Git LFS from an AI/chat session without the planned Windows verification first.
