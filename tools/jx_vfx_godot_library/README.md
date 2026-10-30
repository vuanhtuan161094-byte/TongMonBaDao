# JX VFX Godot Library v1

Standalone, presentation-only tooling for the owner-authorized local WebP inventory. It keeps source textures local, indexes them by SHA-256, and does not author game rules or combat outcomes.

## Contents

- `tools/build_local_library.py` verifies the 889 inventoried WebP paths one at a time, deduplicates identical payloads by SHA-256, and builds the local Godot project, catalog, and offline HTML gallery.
- `tools/export_selected_pack.py` exports only explicitly selected records and their unique texture payloads.
- `tools/static_qa.py` validates paths, hashes, metadata bounds, and index consistency.
- `godot/` contains a shared event-free VFX player API and a catalog browser fixture. Godot runtime validation is separate from Python QA.
- `catalog/library.schema.json` documents the portable catalog contract. Generated source-specific metadata lives in the local output and is intentionally excluded from GitHub.

## Local build

Use Python 3.10+ and the Asset Studio's existing v2 package. Put local source roots in a private JSON config. The config is intentionally outside this repository because it contains machine-specific paths.

```powershell
$studioRoot = "C:\Path\To\AssetStudio"
python tools/build_local_library.py `
  --index "$studioRoot\artifacts\jx_vfx_library_v2\JX_VFX_MASTER_INDEX.json" `
  --source-config "$env:LOCALAPPDATA\TMBD\jx_vfx_source_roots.json" `
  --skill-map "$studioRoot\artifacts\jx_vfx_library_v2\JX_SKILL_VFX_MAP.csv" `
  --pilot-source "$studioRoot\artifacts\jx_vfx_library_v2\selected_godot_ready" `
  --out "$studioRoot\artifacts\jx_vfx_godot_library_v1\local_library" `
  --resume
python tools/static_qa.py "$studioRoot\artifacts\jx_vfx_godot_library_v1\local_library"
python -m unittest discover -s tests -v
```

Source config shape:

```json
{"roots":{"vltk_fx":"E:/GFTU/data/vltk/fx","jx_idle_fx":"E:/GFTU/jx-idle-main/fx"}}
```

The complete config must include every `source_id` in the input index. No recursive source scan is performed: each path is derived from the index's exact filename and the configured source root.

## Godot API

`JXVfxPlayer.play(effect_id, parent, position, options)` only displays the selected texture frames and emits presentation lifecycle signals. It does not select targets, create collisions, apply damage, or change status. Timed playback is refused when frame timing is absent or its unit is unverified. `ANIMATION_DATA_COMPLETE_ENGINE_PENDING` is catalog evidence, not a Godot PASS.

## Rights and handoff

The local inventory and conversions are owner-authorized for local experimental research. That authorization is not a general redistribution or shipped-game-art approval. Do not upload local WebP payloads, machine-specific source paths, or local configuration to GitHub. The GitHub package is tools/schema/runtime code only.

## QA states

- `STATIC_PASS`: Python checks and unit tests pass for the catalog/build tools.
- `PENDING_ENGINE`: Godot is absent; no import or engine-playback claim is made.
- `PENDING_VISUAL`: no engine gallery playback has been reviewed.
- `LOCAL_ONLY`: source WebP payloads stay in the owner-designated local library.

