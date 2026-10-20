# AF-03 — Asset Forge Studio + JX1 verified PACK/NRV2B and source equipment tables

**Isolation:** tooling under `tools/asset_forge/` only; no Godot/simulation/save/balance edits; no asset binaries in Git; no CI/FULL/merge. Branch based on `work/playfirst-demo-max-v3-20261020` HEAD `aad7cec147e5df587ab13614e1c9ef2ac752a8d7` (2026-10-20).

## Windows

Run `MO_ASSET_FORGE_STUDIO.cmd` with Python 3.10+. Browser: `http://127.0.0.1:8791`. For PNG export install Pillow; other catalog operations only need stdlib. Default vault is external (`E:\TongMonBaDao_AssetVault` if E exists, else `AssetVault` beside launcher). `AssetVault` is ignored by Git.

Use `NHAP_JXQY2_PILOT.cmd` or `NHAP_SOURCE_A_3_RIG_GODOT.cmd` for **curated** original data imports. JX1 original data is staged only by explicit selected paths, e.g. `py -3 studio.py stage --vault E:\TongMonBaDao_AssetVault --source-id JX1_OWNER --from-root E:\JX1 --path spr/character/ACTUAL.spr` (change to real path). Files are SHA-checked and never overwritten. No bulk import.

## JX1 (new)

The read-only adapter implements **Kingsoft JX1** `SPR ` (32-byte header, 24-bit palette, per-frame offset and alpha-run decode) from source code `mapic91/MpcAsfTool/SprDecode.cpp@4b7aa5d`. **Correction AF-03:** The actual Kingsoft JX1 `XPackFile.cpp` pack signature is `PACK` (4 bytes), not `PAK ` assumed in the AF-02 provisional adapter. `jx1_pak_v2.py` reads the original 32-byte header and 16-byte ID/index records. Extract methods `0x00` (raw), `0x01` (UCL NRV2B), `0x20` (JX1 new UCL), and frame-split SPR (`0x10`/`0x11`), verifying exact decompressed length. **Method `0x02` BZIP2 remains unsupported**: the inspected Kingsoft XPackFile path leaves it disabled. Every extracted SPR is validated against format/dimensions; unknown methods must fail rather than silently falling back. Untrusted binary input is size bounded; inputs are never executed.

Kingsoft JX1 `ZPackFile.cpp` provides a deterministic path hash. `jx1_path_hash()` uses source-exact ASCII case-folding, byte semantics and 32-bit overflow; **it only resolves the original virtual path supplied by genuine Kind/Part/Sect tables**. A hash hit is not proof that the character is playable or the pixel art correct.

`jx1_tables_v2.py` traverses `settings/npcres/人物类型.txt` → the exact **part table** from `部件说明文件名` → source variant tables named by each part (4x4 grid) → per-equipment row and action-column SPR leaf (see `KNpcResNode.cpp` 58–190). The exact original `资源文件路经` plus leaf can be hashed and matched against selected PACK indices using `--pak` without extracting an entire archive. `特殊npc` means composite resource type, **not automatically a proven player identity**. Frame render order / visual offsets still require authentic source records. Asset bytes on user's PC have not been read in this session.

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

22 synthetic focused tests PASS on Python Linux for this AF-03 batch (Studio + JX1 SPR/PAK + NRV2B + frame-split + exact hash + original table parsing). Windows 4.7.2 and real JX1 sprites **PENDING USER**. No Godot runtime or Windows QA performed, no CI/FULL/merge.

## Sources

- [Kingsoft SPR reader / RLE](https://github.com/mapic91/MpcAsfTool/blob/4b7aa5df0feeac97540ea5f870304d4a61068d42/SprDecode.cpp)
- [JX1 playable modular resource selection](https://github.com/kiendaotac/SourceInit-JX1/blob/b2e251a93f862571221b17cc1e92ceb121fc3069/SwordOnline/Sources/Core/Src/KNpcRes.cpp)
- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DISCIPLE_MASTER_SCHEMA.md` (read before edits)


## AF-03 — Cách dùng ngay

**Giao diện:** tab **Playable & Animation** now includes PAK index/one-ID extraction and source Kind/Part/Sect table scan. To access one archived JX1 `.spr`, stage **only the chosen PAK** into `01_raw/JX1_OWNER`, then fill the staged PAK relative path and an actual integer ID; choose **Kiểm PAK và ID** or **Giải nén một SPR vào 03_derived**. Uncompressed or verified NRV2B and independent-frame SPR variants are decoded without modifying original PAK. A companion provenance JSON contains SHA-256 and source ID. If the PAK is multi-GB / larger than stage limits, **do not copy it**: invoke CLI with its actual Windows path directly (commands below).

```powershell
cd tools\asset_forge
# Work directly on an owner JX1 large original PAK; no bulk copy necessary.
py -3 jx1_adapter.py pak-index "E:\JX1\data\sprite.pak" --out "E:\TongMonBaDao_AssetVault\06_reports\pack-index.json"
py -3 jx1_adapter.py pak-spr "E:\JX1\data\sprite.pak" --id 0x12345678 --out "E:\TongMonBaDao_AssetVault\03_derived\jx1_spr\one.spr"
# Strict source table chain. Source part/sect tables are expected alongside the kind table.
py -3 jx1_tables_v2.py --kind-file "E:\JX1\settings\npcres\人物类型.txt" --table-root "E:\JX1\settings\npcres" --asset-root "E:\JX1" --character "ACTUAL_EXACT_KIND_ROW" --pak "E:\JX1\data\sprite.pak" --out "E:\TongMonBaDao_AssetVault\06_reports\jx1_player_candidates.json"
```

**Evidence / statuses:** source code `KNpcResNode.cpp`, `XPackFile.cpp`, `ZPackFile.cpp`, `CoreUseNameDef.h` in [`kiendaotac/SourceInit-JX1@b2e251a`](https://github.com/kiendaotac/SourceInit-JX1/tree/b2e251a93f862571221b17cc1e92ceb121fc3069), plus published NRV2B specification in UCL sources. Code logic and synthetic tests verified. **Real owner JX1 PACK/SPR, exact equipment rows, contact sheet and Windows UI acceptance still PENDING USER.** Do not import any asset into Godot/gameplay while pending. This plugin source is separate from extracted game art; review any third-party implementation license before distributing a bundle that includes it.