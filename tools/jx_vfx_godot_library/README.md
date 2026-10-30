# JX VFX Godot Library v1

Standalone, presentation-only tooling for the owner-authorized local WebP inventory. It keeps source textures local, indexes them by SHA-256, and does not author game rules or combat outcomes.

## Contents

- `tools/build_local_library.py` verifies the 889 inventoried WebP paths one at a time, deduplicates identical payloads by SHA-256, and builds the local Godot project, catalog, and offline HTML gallery.
- `tools/export_selected_pack.py` exports explicitly selected records, their source payloads, and (when requested) frame-preserving runtime pages.
- `tools/repack_selected_sheet.gd` is the bounded Godot image utility used by the selected-pack exporter; it does not scan or rewrite the source library.
- `tools/static_qa.py` validates paths, hashes, metadata bounds, and index consistency.
- `godot_project/godot/` contains a shared event-free VFX player API and a catalog browser fixture. Godot runtime validation is separate from Python QA.
- `catalog/library.schema.json` documents the portable catalog contract. Generated source-specific metadata lives in the local output and is intentionally excluded from GitHub.

## Local build

Use Python 3.10+ and the Asset Studio's existing v2 package. Put local source roots in a private JSON config. The config is intentionally outside this repository because it contains machine-specific paths.

```powershell
$repoRoot = "C:\Path\To\TongMonBaDao"
$studioRoot = "C:\Path\To\AssetStudio"
Push-Location (Join-Path $repoRoot "tools\jx_vfx_godot_library")
python tools/build_local_library.py `
  --index "$studioRoot\artifacts\jx_vfx_library_v2\JX_VFX_MASTER_INDEX.json" `
  --source-config "$env:LOCALAPPDATA\TMBD\jx_vfx_source_roots.json" `
  --skill-map "$studioRoot\artifacts\jx_vfx_library_v2\JX_SKILL_VFX_MAP.csv" `
  --pilot-source "$studioRoot\artifacts\jx_vfx_library_v2\selected_godot_ready" `
  --out "$studioRoot\artifacts\jx_vfx_godot_library_v1\local_library" `
  --resume
python tools/static_qa.py "$studioRoot\artifacts\jx_vfx_godot_library_v1\local_library"
python -m unittest discover -s tests -v
Pop-Location
```

After the local build, open the output folder (the path passed to `--out`) as the Godot project. It contains `project.godot`, the generated catalog, and the local texture pool. The five-record sample pack is also a standalone candidate project.

Source config shape:

```json
{"roots":{"vltk_fx":"E:/GFTU/data/vltk/fx","jx_idle_fx":"E:/GFTU/jx-idle-main/fx"}}
```

The complete config must include every `source_id` in the input index. No recursive source scan is performed: each path is derived from the index's exact filename and the configured source root.

## Godot API

`JXVfxPlayer.play(effect_id, parent, position, options)` loads imported `res://` textures through `ResourceLoader`, displays selected frames, and emits presentation lifecycle signals. It supports grid, irregular-rectangle, and page-backed frame regions. It does not select targets, create collisions, apply damage, or change status. Timed playback is refused when frame timing is absent or its unit is unverified. `ANIMATION_DATA_COMPLETE_ENGINE_PENDING` is catalog evidence, not a Godot PASS.

## Selected pack texture limits

Grid sheets larger than a target texture limit can be split on frame boundaries into pages, with frame order, direction index, frame size and anchor retained. This requires an installed Godot executable and is opt-in:

```powershell
python tools/export_selected_pack.py `
  --library "C:\Path\To\local_library" `
  --ids "duong_mon_fx:m38_fly.webp,thuy_yen_fx:m146_fly.webp,vltk_native:01744d1a.webp" `
  --out "C:\Path\To\selected_pack" `
  --godot-exe "C:\Path\To\Godot_v4.7.2-stable_win64_console.exe" `
  --max-texture-size 2048 `
  --repack-oversized `
  --pad-transparent-record "thuy_yen_fx:m146_fly.webp"
```

Transparent edge padding is explicit per record. The exporter refuses to remove source pixels and records the original dimensions plus added transparent pixels in `pack.json`. The generated `jx_vfx_resource_manifest.gd` statically preloads every source/runtime texture referenced by the pack so `ResourceLoader.load("res://...")` has export-PCK references. The pack manifest lists per-file sizes and SHA-256 values, excluding its own self-referential checksum.

## Rights and handoff

The local inventory and conversions are owner-authorized for local experimental research. That authorization is not a general redistribution or shipped-game-art approval. Do not upload local WebP payloads, machine-specific source paths, or local configuration to GitHub. The GitHub package is tools/schema/runtime code only.

## QA states

- `STATIC_PASS`: Python checks and unit tests pass for the catalog/build tools.
- `PENDING_ENGINE`: no real Godot import/runtime test has been run; no engine claim is made.
- `ENGINE_IMPORT_PASS`: the selected project imports in the specified Godot version without script, resource or import failures.
- `GODOT_PLAYBACK_TECHNICAL_PASS`: selected animations have been played and observed in Godot; owner review of artistic suitability remains separate.
- `PENDING_EXPORT_PACK`: the standalone project imported and ran, but no exported executable/PCK was built and exercised.
- `PENDING_VISUAL`: no engine gallery playback has been reviewed.
- `LOCAL_ONLY`: source WebP payloads stay in the owner-designated local library.
## Engine gate v1.1 evidence

A bounded selected pack was validated with Godot 4.7.2 stable official on 2026-10-30. The clean extracted project passed import, 14 focused runtime checks, and actual OpenGL GUI playback for three effects. Python unit tests passed 9/9. The full local texture library and an exported PCK remain separate pending gates; see docs/ENGINE_GATE_V1_1.md. No JX binary assets are part of this repository change.
