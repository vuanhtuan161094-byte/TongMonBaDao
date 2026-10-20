# TÔNG MÔN BÁ ĐẠO — AF-04 focused QA / source evidence

Date: 2026-10-20. Scope: `tools/asset_forge/` and checkpoint/handoff. Baseline `tools/af-jx1-player-forge-20261020@385d78556e346e40e612979f81c3ca1cd7467f55`.

## Verified source facts

- `kiendaotac/SourceInit-JX1@b2e251a`: `人物类型.txt` contains records `男主角`, `女主角` with `人物类型=特殊npc`, explicit male/female part/section/sort tables. Other `特殊npc` records are not automatically playable.
- The male body `躯体` and right-hand-weapon `右手武器` tables contain actual variant rows/SPR filename references; source `动作贴图顺序表` includes `[DEFAULT] Dir1...` and per-action frame/layer instructions.
- `KNpcResNode.cpp` accesses equipment rows/action columns, `CSortTable::GetSort` owns direction/frame draw order. `XPackFile.cpp` uses `PACK`, compressed size flags and NRV2B.

## Focused checks

- `python -m unittest discover -p 'test_*.py' -v`: 29/29 PASS (Python, Linux).
- Eight-direction, two-equipment-variant synthetic fixture: body loose SPR, weapon from selected PACK; exact virtual hash lookup, bytes validated, JSON provenance and PNG contact sheet created; 8 directions and direction-specific layer order verified.
- Catalog-only works with original-style Kind/Part/Sect text when selected SPR binaries are absent. No original PAK copied/imported for catalog-only.
- Guards verified: wrong/NPC player identity, missing resource, wrong variant, ambiguous/mismatched loose and PAK, source sort missing/invalid, idempotent preview without overwrite.
- Real localhost HTTP smoke: AF-04 catalog endpoint (200), AF-04 image endpoint (200), repeated preview returns verified existing artifact, invalid NPC (400).

## Outstanding — NOT PASS

- **Actual owner raw JX1 binary PAK and SPR:** PENDING; no environment access to the owner's Windows drive.
- **Actual 8-direction character/outfit screenshot and equipment compatibility:** PENDING. Preliminary offset/sort uses real SPR metadata but pixel-level acceptance is not validated.
- Windows launcher/official Godot 4.7.2/Android: PENDING USER; no runtime/gameplay modifications were made.
- Existing M1/M2/V-01 gameplay/save untouched; no CI/FULL/merge.

## Next gate

On user Windows machine use Studio AF-04 with a real source `settings/npcres` + selected original `PACK` and explicit source variant rows to generate a male or female protagonist sheet; inspect 8 directions, body/weapon layering, hash provenance, and report unsupported formats precisely. Keep original source and gameplay unchanged until user visual acceptance and distinct code authorization.