# AF-02 — Asset Forge Studio + JX1 SPR/PAK playable pilot

**Isolation:** tooling under `tools/asset_forge/` only; no Godot/simulation/save/balance edits; no asset binaries in Git; no CI/FULL/merge. Branch based on `work/playfirst-demo-max-v3-20261020` HEAD `aad7cec147e5df587ab13614e1c9ef2ac752a8d7` (2026-10-20).

## Windows

Run `MO_ASSET_FORGE_STUDIO.cmd` with Python 3.10+. Browser: `http://127.0.0.1:8791`. For PNG export install Pillow; other catalog operations only need stdlib. Default vault is external (`E:\TongMonBaDao_AssetVault` if E exists, else `AssetVault` beside launcher). `AssetVault` is ignored by Git.

Use `NHAP_JXQY2_PILOT.cmd` or `NHAP_SOURCE_A_3_RIG_GODOT.cmd` for **curated** original data imports. JX1 original data is staged only by explicit selected paths, e.g. `py -3 studio.py stage --vault E:\TongMonBaDao_AssetVault --source-id JX1_OWNER --from-root E:\JX1 --path spr/character/ACTUAL.spr` (change to real path). Files are SHA-checked and never overwritten. No bulk import.

## JX1 (new)

The read-only adapter implements **Kingsoft JX1** `SPR ` (32-byte header, 24-bit palette, per-frame offset and alpha-run decode) from source code `mapic91/MpcAsfTool/SprDecode.cpp@4b7aa5d`. PAK `PAK ` header and 16-byte ID/index records are parsed. **PAK entry method=0 and equal stored/uncompressed length only** is extractable; compressed methods are `UNSUPPORTED`, no fake conversion. PAK resource IDs are hashes: never reconstruct filenames by guessing.

```powershell
py -3 jx1_adapter.py spr-info "E:\TongMonBaDao_AssetVault\01_raw\JX1_OWNER\spr\sample.spr"
py -3 jx1_adapter.py pak-index "E:\JX1\data.pak" --out "E:\TongMonBaDao_AssetVault\06_reports\jx1_pak_index.json"
py -3 jx1_adapter.py pak-spr "E:\JX1\data.pak" --id 0x12345678 --out "E:\TongMonBaDao_AssetVault\03_derived\players\checked.spr"
py -3 jx1_adapter.py player-check --spec "E:\TongMonBaDao_AssetVault\02_catalog\jx1_playable_spec.json" --source-root "E:\TongMonBaDao_AssetVault\01_raw\JX1_OWNER"
py -3 jx1_adapter.py player-sheet --spec "E:\TongMonBaDao_AssetVault\02_catalog\jx1_playable_spec.json" --source-root "E:\TongMonBaDao_AssetVault\01_raw\JX1_OWNER" --out "E:\TongMonBaDao_AssetVault\04_previews\players\hero01.png" --loadout '{"armor":"default","helm":"default","weapon":"sword01","body":"default"}'
```

The Playable tab in the browser offers JX1 check and contact sheet after owner stages actual `.spr` and fills out `02_catalog/jx1_playable_spec.json` based on the *real* player/part/sect tables and frame sort. Use `JX1_PLAYABLE_SPEC_TEMPLATE.json` as schema, **not** as finished evidence. `NPC_RES_SPECIAL` alone or an SPR filename is never sufficient to prove a specific player; the proof requires a player-resource record and actual part table link. `z` and per-part `anchor` values must come from source evidence. Costume and weapon variants use explicit `part`/`variant` mapping for each pose, not heuristic overlays.

**Important:** this integration has *synthetic unit tests* for SPR/PAK and the compositing pipeline, NOT a real owner JX1 binary acceptance. Current externally evidenced source code `kiendaotac/SourceInit-JX1` `KNpcResNode.h/.cpp` and `KNpcRes.cpp` confirms modular head/armor/weapon/horse selection and frame ordering; actual JX1 asset table/PAK/SPR variants on the owner's Windows cache still need matching. JXQY2 hero is a different source family and cannot substitute.

## Focused regression

```bash
python -m unittest discover -p 'test_*.py' -v
```

13 synthetic focused tests PASS on Python Linux in this integration batch (8 Studio V1 + 5 JX1 adapter). Windows 4.7.2 and real JX1 sprites **PENDING USER**. No Godot runtime or Windows QA performed, no CI/FULL/merge.

## Sources

- [Kingsoft SPR reader / RLE](https://github.com/mapic91/MpcAsfTool/blob/4b7aa5df0feeac97540ea5f870304d4a61068d42/SprDecode.cpp)
- [JX1 playable modular resource selection](https://github.com/kiendaotac/SourceInit-JX1/blob/b2e251a93f862571221b17cc1e92ceb121fc3069/SwordOnline/Sources/Core/Src/KNpcRes.cpp)
- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DISCIPLE_MASTER_SCHEMA.md` (read before edits)