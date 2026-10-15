# UI-REF-01 — Source/Asset Inventory and Reuse Decision

**Date:** 2026-10-15; **mode:** GitHub read-only source audit + this design document.
**No local Windows E:\\ or actual Source A binary textures accessed.** Do not label a listed model `game-ready` on GitHub presence alone.

## A. Source A Unity/Lua — evidence examined

| Source path (repo: `vuanhtuan161094-byte/ZQZS-Source-Knowledge`) | What is actually visible | What can be reused |
| --- | --- | --- |
| `sources/AndroidData/binary/gui.windows.manufacture.uimdiscipleselect_TextAsset_-7732737977019007156.bin.lua` | `UIMDiscipleSelect` binds scroll/role list, search input, filters, work buttons and text; not Unity prefab binary | Structure of selection window |
| `sources/AndroidData/binary/gui.windows.manufacture.uimdiscipleselect_manager_TextAsset_-5550305269121807973.bin.lua` | `onLoaded` registers list scroll and input change; `initDiscipleList` derives profession level; sorts by availability/work/level; `refreshItem` prepares profession/status UI | Profession/relevance sorting, visual role list and context |
| `sources/AndroidData/binary/gui.windows.manufacture.uimdiscipleselect_filter_TextAsset_2023007785045275046.bin.lua` | Dedicated picker filter variant | UX reference only; gameplay filtering authority stays Godot |
| `sources/AndroidData/binary/gui.windows.manufacture.uibuildinginfowin_TextAsset_6753192775076251433.bin.lua` | Building information components include name, level, capacity/cost panels, upgrade progress and scroll window | Layered building detail UI; no automatic feature copy |
| `sources/AndroidData/binary/gui.windows.disciple.uidiscipleselectwin_TextAsset_134244526750417629.bin.lua` | Search, filter/sort control, role list; UI interactions available | Deep disciple roster and component family |
| `analysis/DeepAnalysis/data/building_ui.json` | Unity UI component / RectTransform metadata example, not recovered ready-to-import textures | Verify hierarchy and possible relative dimensions before CODE |
| `docs/UI_UX.md`, `docs/HOME_BUILDING.md` | Verified client/UI and Home evidence with uncertainties; metadata limits explicit | Reference only; not authoritative production gameplay |

The Lua evidence proves the **presence of UI interaction patterns**, not exact look, live server algorithms, exportable Unity scenes or a legal/runtime package. The referenced `ui/windows/main/main_sprite_atlas_pak.ab` from `gui.windows.home.uibuildingmsgwin` is an **asset-bundle identifier**, not an actual atlas file checked into the repository.

## B. Source A building candidate IDs (metadata, NOT imported in repo)

Data: `godot/data/presentation/source_a_candidate_manifest.json` on `TongMonBaDao/main`, 13 candidate entries. `binary_imported=false` for all in that manifest; manifest predates some Windows lab work, so this flag only describes the manifest and does **not erase** documented PV-01/ENV-01 tests on a separate Windows environment.

| Building in game | Source A model ID | Presence & decision |
| --- | --- | --- |
| Mỏ Thanh Thiết | `520051` | VERIFIED model candidate; `520051.png` SHA-256 `b67d43769de14e32a79500a61332078ef56893ca2abcf7aaf89d13a134639aaf`; **source bytes needed** for direct UI/map use |
| Linh Điền | `520091` | VERIFIED candidate; bytes need importing |
| Linh Lâm | `520101` | VERIFIED candidate; bytes need importing |
| Đại Điện | `510052` | VERIFIED; prior PV-01 Windows lab evidence exists separately |
| Kho | `510102` | VERIFIED; prior PV-01 Windows lab evidence exists separately |
| Luyện Khí | `520081` | VERIFIED; prior PV-01 Windows lab evidence exists separately |
| Dược Phòng | `520031` | INFERRED analog in legacy visual mapping; verify chosen building |
| Rèn Thân Đường | `510232` | INFERRED analog; not chosen as core UI proof |

Only **texture/sprite usage** is needed for static building depiction; do not bring Spine Runtimes into this phase. The `.skel` dependency is not proof that a still image requires Spine runtime. Building bitmap bytes must be inspected and imported with correct transparency, size and visual quality. No local source extraction possible without user's PC or exact uploaded pack.

## C. UI and portrait graphic availability

| Item | Known authority / availability | Action now |
| --- | --- | --- |
| V3 mood/reference image | `ui.main_map.v3_mood`, S3, exact bytes missing in registry | Preserve style; do not claim recovered image |
| UI skin production set | `ui.skin.production_set`, S4, production not created/ingested | Produce a small reusable **original** nine-slice + button + tab + portrait frame set in a separately authorized asset pass |
| Source A UI textures/atlas | Lua references to bundles, but `ZQZS-Source-Knowledge` is text/metadata-only; no binary image source in that repo | Query existing local Source A export before recreating art; do not infer path exists in GitHub |
| V3 female stage sample | `actor.female_normal_v1.stage_a.down`, S1 external pack; other registry indicates some repo motion code | May use for **demo portrait silhouette** with proper labeling only; not an individual portrait for every disciple |
| `tutiennhandoi` `assets/dongphu/ui/` | Actual `.webp` frame/button/progress assets in separate **portrait-mode** project owned by user | Optional fallback candidate after visual compatibility/port review; do not assume can transplant 1:1 to 1280×720 |
| Godot `main` Git tree | Current tree contains no directly listed PNG/WebP/SVG/atlas image files (source art packs/lab kept separate) | Never claim all Source A images are already committed to runtime |
| Source A rights | User confirms full rights for personal project source | Record user assertion as usage authority for this private pilot; runtime Spine license is independent |

## D. Minimum UI visual art kit to source

**P0 essential for three-screen slice**: parchment panel 9-slice (large and quick), button primary/secondary/disabled, tab selected/normal, one portrait quality frame family, portrait fallback silhouette, resource chip shell, empty worker slot, progress-bar frame, close button, state icons (working/blocked/ready), and readable Vietnamese font choice (do not ship system/font binaries without permission).

**Re-use priority:**
1. Existing imported Godot official/approved runtime graphics (if exact bytes verified in local archive).
2. User-authorized Source A sprite/texture from local bundles, extracted into a portable minimal UI-only pack; hash/provenance and direct image preview.
3. Suitable user-owned `tutiennhandoi` webp assets if adapted faithfully to landscape.
4. Create original simple hand-painted game controls only for missing items; review screenshot before production lock.

Do **not** extract all 25,815 source text files or huge local texture catalogs for one Mine UI. Candidate kit should be small and usage-driven. Exclude unused prefabs, intermediate unpack files, Spine skeleton, videos and unrelated maps.

## E. Ready-to-code vs blocked

**Ready now:** Source reference table, canonical UI hierarchy, Godot presentation contracts, UI component responsibilities, data ownership, safe selection behavior, test plan and code/asset allowlist proposal.

**Blocked on actual source bytes or runtime:** exact source UI sprite atlas, new approved UI skin texture pack, full portrait sprite set, real 1280×720 Godot screen proof, Android touch, official focused/full QA on new visual code.

**Important:** `UI-REF-01` design is complete only as a scoped **document**, not asset import, not visualization approval and not Godot production integration.
