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

## AF-04 — Protagonist catalog → selected PACK → SPR → 8-direction contact sheet

**GitHub implementation:** `jx1_player_pipeline_v4.py` plus the Studio **AF-04** controls in the Playable tab. The source audit on 2026-10-20 verified actual `bin/Client/settings/NpcRes/人物类型.txt` rows `男主角` / `女主角`, whose `人物类型=特殊npc` links to male/female `部件说明文件名`, resource path, part-specific Sect tables and `动作贴图顺序表`. The actual male `躯体` table enumerates `MA_BD_001_ST01.spr`, `MA_BD_002_ST01.spr` etc; the male `右手武器` table names sword variants `单手剑1`, `单手剑2` with action-specific filenames. **These references were checked against the published source tables; they do not prove corresponding binary SPRs exist in the owner's installed JX1.**

1. **Catalog without binaries:** read a selected original Kind/Part/Sect chain and emit variant names, original action references, exact virtual paths and hash IDs. Mark loose-file and selected-PACK index matches; no extraction needed. For large PAKs, refer to the original path directly—never copy an entire archive just to scan it.
2. **Render with source bytes:** choose the exact protagonist (`男主角` or `女主角`), action column (`空手站立1` etc), selected PAK files (0–6) and equipment rows (0-based), e.g. `{"躯体":1,"右手武器":1}`. The adapter joins virtual filename → source JX1 hash ID → selected PAK record (or loose SPR), verifies the archive decoder and SPR header, and reads 8/16 actual sprite directions. Ambiguous pack matches or loose-vs-packed bytes are rejected. Source `动作贴图顺序表` `Dir1..Dir16`, action overrides and matching `LineN` determine per-direction part order. Sprite metadata (`center_x/y`, frame offset) informs rendering; it is **provisional visual positioning until Windows comparison**.
3. **Provenance:** the PNG and its companion JSON go into the external Vault `04_previews/players/`, include source SHA-256, table hashes, selected parts, action, variant rows, sort order and the exact evidence/status. Browser repeats are idempotent for identical hashes, never overwrite a mismatched output. In Studio use `Tự lập catalog trang phục` then `Tự xuất 8 hướng thật`.

The two source protagonist rows are **allowed because public JX1 source tables explicitly name them**. Other `特殊npc` rows are not silently treated as players. This is not a game actor integration or a claim that a particular owner pack was proven.

Direct Windows commands from `tools\asset_forge` (Python 3.10+; `pip install pillow` only for PNG previews):

```powershell
# No SPR binary needed; creates a JSON list of source variants.
py -3 jx1_player_pipeline_v4.py --source-root "E:\JX1" --character "男主角" --action "空手站立1" --catalog-only --out "E:\TongMonBaDao_AssetVault\02_catalog\male_variants.json"

# Requires the actual selected packed SPR resources, never whole-archive import.
py -3 jx1_player_pipeline_v4.py --source-root "E:\JX1" --character "男主角" --action "空手站立1" --choices '{"躯体":1,"右手武器":1}' --pak "E:\JX1\data\sprite.pak" --directions 8 --out "E:\TongMonBaDao_AssetVault\04_previews\players\male_body2_sword1.png"
```

The example paths and variant indices require adjustment to the *actual* owner's files/tables, not automatically inferred; the UI provides selectors. The output is a **visualization of sourced sprites**, not Godot-ready equipment logic. No combat/save/skill rules changed.

**Focused QA:** `python -m unittest discover -p 'test_*.py' -v` — **29/29 PASS**, including a 2-variant 8-direction PACK+loose SPR fixture and real localhost HTTP catalog/sheet/idempotence/error tests. These tests use **synthetic binary fixtures** whose *metadata names* were derived from audited JX1 source tables, not the owner's SPR art. **Windows JX1 binary acceptance, correct garment ordering/pixel alignment, 8-direction real contact sheet, Godot 4.7.2/Android QA: PENDING USER.** No CI/FULL/merge.

Source evidence (public `kiendaotac/SourceInit-JX1@b2e251a93f862571221b17cc1e92ceb121fc3069`): `bin/Client/settings/NpcRes/ÈËÎïÀàÐÍ.txt` (`人物类型.txt` content), `ÄÐÖ÷½ÇÇûÌå.txt` (`男主角躯体.txt` content), `ÄÐÖ÷½ÇÓÒÊÖÎäÆ÷.txt` (`男主角右手武器.txt` content), `ÄÐÖ÷½ÇÌùÍ¼Ë³Ðò±í.txt` (sorting INI content), `SwordOnline/Sources/Core/Src/KNpcResNode.cpp` (rows/actions/sort), `SwordOnline/Sources/Engine/Src/XPackFile.cpp` (`PACK`/NRV2B). The mojibake repository **path names** reflect their stored encoding; original table contents were verified as Chinese columns. No original/source art binaries redistributed.


## Windows: Python da cai nhung launcher bao Microsoft Store (AF-04 PYFIX)

- Chay **`KIEM_TRA_PYTHON.cmd`**. Tool se kiem tra `py -3`, virtualenv/Conda, PATH va thu muc Python thuong dung; loai bo alias `Microsoft\WindowsApps` va thu chay Python 3.10+ that truoc khi chap nhan.
- Neu hien **PASS**, chay **`MO_ASSET_FORGE_STUDIO.cmd`**. Ca test va cac launcher nhap asset cung goi `FIND_PYTHON.cmd`. Khong can cai lai Python neu da tim duoc.
- Neu khong tim thay, trong PowerShell kiem tra `py -0p` va `where.exe python`. Co the chi dinh duong dan Python cua ban trong **cung phien CMD**: `set "TMB_PYTHON_OVERRIDE=C:\Users\Admin\AppData\Local\Programs\Python\Python312\python.exe"` (thay bang duong dan thuc), roi chay `MO_ASSET_FORGE_STUDIO.cmd`. Neu mo bang nhap dup, tao `RUN_WITH_MY_PYTHON.cmd` voi `set ...` va `call MO_ASSET_FORGE_STUDIO.cmd`.
- `where.exe python` in ra `...\Microsoft\WindowsApps\python.exe` khong chung minh Python that da cai. Neu can, tat `python.exe`/`python3.exe` tai **Settings → Apps → Advanced app settings → App execution aliases**.
- Python/Windows runtime can kiem tra tren may Windows that; patch chi xac nhan static va regression Linux cho den khi co log thuc te.


## Windows Python detection V3 (Oct 20)

If the old diagnostic only prints `C:\Users\Admin\AppData\Local\Microsoft\WindowsApps\python.exe`, this is a **Microsoft Store execution alias, not confirmation that Python is installed**. Run `KIEM_TRA_PYTHON.cmd` in the V3 archive; the fallback PowerShell resolver checks Python PEP 514 Registry entries, Conda/uv and common custom D:/E: installation folders, without scanning entire disks. If it finds a working Python 3.10+, launch `MO_ASSET_FORGE_STUDIO.cmd`. If Python is inside an unusual folder, run `CHON_PYTHON.cmd` and select the actual `python.exe`; the choice is saved to `python.local.txt` (local only, ignored by git). `TIM_PYTHON_CHI_TIET.cmd` prints all candidates and their results. **Windows runtime verification still requires the user's actual PC.** No installation or PATH modification occurs automatically.


## C5 / 2026-10-21 — Combat JX1 Source Intake, E:\Source + E:\Tool JX

The user has the full client/server on Windows. Launch `QUET_SOURCE_COMBAT_JX1.cmd` (same folder as `FIND_PYTHON.cmd` and `jx_combat_intake.py`) to enumerate these two exact roots read-only and write evidence under `E:\TongMonBaDao_AssetVault\06_reports\JX1_Combat_Intake` **outside either source folder**. Read `README_COMBAT_INTAKE.md`. It classifies map/sprite/PAK/skills/missles, probes PACK header without unpacking, hashes small key tables, tries source-backed Kind/Part/Sect character catalog when a usable original folder exists; it never executes client/server code or modifies raw/gameplay. `test_jx_combat_intake.py` covers small synthetic fixture inventory, no-write, malicious symlink, bounds, bad signatures and table layout. No original E:-drive evidence is available in this assistant runtime. Real PAK/SPR decoding, camera/frame timing on Windows/Android and Godot source map rendering PENDING USER. This is an intake tool, NOT a combat runtime upgrade.
