# TÔNG MÔN BÁ ĐẠO — ENV-01 WINDOWS QA & NEXT-CHAT HANDOFF

> **Updated:** 2026-10-12. **Type:** documentation-only handoff. **Owner's priority:** inspect and test the already delivered ENV-01 candidate, not restart source research or create another prototype.
>
> **Latest decision:** ENV-01 was explicitly authorized for an **isolated copy** of the PV-01 Godot lab. The owner reports an ENV-01 project was handed off for Windows QA. **No accepted ENV-01 Windows screenshot/two test logs are in this GitHub repository.** Do **not** mark ENV-01 PASS or CLOSED on a report alone.

## 1. Priority and exact next action

**NOW:** Retrieve the existing ENV-01 deliverable and its run instructions, test it in **Godot 4.7.2 on Windows**, collect the **actual Godot-rendered 1280×720 screenshot** and the **two logs required by that deliverable** in `ENV01_TEST_RESULTS`, and inspect the quality/interactions. Correct isolated-lab defects if owner authorizes/within active packet; only then request owner visual acceptance.

- Executable: `E:\Godot_v4.7.2-stable_win64_console.exe`.
- **Do not guess** the ENV-01 ZIP filename, test-script command, exact two log basenames, or location of an artifact absent from the current chat/repository. Read the delivered ZIP's README and validation scripts first.
- If the ENV-01 deliverable is not accessible to the next chat, ask the owner for **only that specific ZIP or actual ENV-01 output directory**. The original `SourceA_Map_Prep_20261012.zip` is a source baseline, **not a proven replacement for the completed ENV-01 deliverable**.
- The assistant in a normal chat has **no direct read/run access to the user's Windows E: drive**. Use uploaded files; for actual Windows QA provide one concise owner command or one Codex-local QA instruction when requested.

## 2. Sources / project identity

- Game: `vuanhtuan161094-byte/TongMonBaDao`, branch `main`, Windows `E:\0.2. TongMonBaDao`.
- Source A knowledge: `vuanhtuan161094-byte/ZQZS-Source-Knowledge`, Windows `E:\ZQZS-Source-Knowledge`.
- Original extracted assets: `E:\GameAssetExtract`.
- Integration workspace: `E:\TongMonIntegrationLab`.
- Existing indexes: `E:\TongMonIntegrationLab\AssetCatalog`, `E:\TongMonIntegrationLab\TransferKit\Catalog`.
- Historical native map demo: `E:\TongMonIntegrationLab\TransferKit\MapPrototype`.
- Existing three-building lab: `E:\TongMonIntegrationLab\PV01_ThreeBuildingsLab`.
- Transfer/export pack evidence: `E:\TongMonIntegrationLab\TransferKit\FE01B2VerifiedPacks`.
- Source handoff archive (owner-created): `E:\TongMonIntegrationLab\ChatGPT_Handoff\SourceA_Map_Prep_20261012.zip`.
- Last read-on-GitHub game `main` HEAD before this handoff: `be559ec1efc277bbc432ca41e24e9d41429f8a61`; Source Knowledge `main`: `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`. Fetch live HEAD again before working.
- Owner reported clean local working trees; game local was behind GitHub by two documentation commits. **Never force reset/pull/clean** to reconcile documentation.

### Authority / read order

Read `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md` → this document → `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` → P3 asset/presentation docs → actual accessible ENV-01 files.

## 3. Work completed before ENV-01 (source and evidence)

1. Source A Home/isometric architecture was studied: `isometricmapsystem`, `ims_design_layout`, `ims_road`, `ims_sundries`, `ims_randomobject`, `mountaincontrol`, `surfacecontrol`, `zongmenmodel`, `zongmencontrol` and related layout/UI modules.
2. Relevant source configs: `config.tileconfig`, `roadstyleconfig`, `mnjyloadsceneconfig`, `monijysfconfig`, `mountainsceneconfig`, `monijyrandomitemconfig`, `monijybuildconfig`, `monijytemplateconfig`, `monijytemplateposconfig`, `monijytemplateposexportconfig`, `maplogiclayerconfig`.
3. Source A contains map/layer templates, `home.ab`, road/surface/water/wall tile data and `mountain1_wx` mesh/texture candidates. **Exact original Home scene placement/material reconstruction is not established**, and is **not a prerequisite** for a visually coherent Godot opening map.
4. Codex completed an owner-reported handoff archive, `SourceA_Map_Prep_20261012.zip`: 28,000,430 bytes (about 26.7 MiB), 428 ZIP entries, 417 traced payload source files + 11 reports/manifests/previews, 47 GDScript/Lua files, 11 map Lua configs, 255 PNGs, 19 atlas .bin, 32 OBJ, one AssetBundle, five .tscn, screenshots/contact sheet. The previous ChatGPT turn reported ZIP integrity and 417/417 manifest hash checks PASS. **These are package tests, not ENV-01 runtime tests.**
5. Environment audit of the accessible ZIP reported single-region atlases for static vegetation, 244 environment PNG file entries / 178 distinct contents, some duplicate road bundles (`roadtile0` vs `roadtile1`), and possible direct static Sprite2D use for trees/decorations. Tile-edge stitching, anchor, depth and visual quality remain Godot-render QA subjects.
6. Source A candidate art rights were affirmed by the owner. The eight historical S3 visual-approved building identities and asset recovery status remain **unchanged**; candidate art must not be silently equated with recovered S3 bytes.

## 4. PV-01 / ENV-01 baseline

**PV-01 known original Source A buildings:**

| Logical ID | Model | Footprint | Door offset | Original texture SHA-256 |
|---|---:|---|---|---|
| `building.main_hall` | 510052 | 7×5 | (3,-1) | `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c` |
| `building.warehouse` | 510102 | 3×2 | (1,-1) | `9bd8b5196ba8b7b79d6f7ef17da07a0d5289fa208ed03484ec1803fd765d9158` |
| `building.forge` | 520081 | 3×3 | (1,-1) | `4225062d48c08f9562be76315f5b8984d4bea0a2311e5762dc844a23e7567458` |

The prior PV-01 **Windows lab** had evidence of rendering these three static PNGs, grid occupancy, doorway rules, click/selection, camera and AStar visual navigation. It does **not** prove the improved ENV-01 was rendered/accepted.

**ENV-01 authorized isolated scope:** visually improved Godot 4.7.2 **LANDSCAPE 1280×720** lab using original Source A ground/path/vegetation/trees/rocks/lamps around the existing three buildings, preserving the existing `TransferMapModel` / grid projection / footprint / doorway / selection / pan-zoom / AStar. All production systems are out of scope.

**ENV-01 current status:** `OWNER-REPORTED DELIVERED FOR WINDOWS QA / NOT YET WINDOWS-ACCEPTED`. There is no independently verified ENV-01 artifact, exact artifact path, new Godot GUI screenshot or two definitive test logs committed to GitHub as of this handoff. Do not invent them.

## 5. Windows acceptance protocol

**First inspect the delivered ENV-01 README/test scripts**. Run only their documented official Godot 4.7.2 commands, using the real extracted ENV-01 project path. Preserve the entire test output under `ENV01_TEST_RESULTS`.

Evidence required:
- A **real Godot 1280×720 screenshot** (not mockup/contact sheet/previous PV-01 screenshot).
- The **two log files named by the ENV-01 deliverable's own test instructions**, complete and with exit status.
- Missing-resource/parser/import error checks.
- Functional checks: building selection, camera pan/zoom, building footprints/doorways, occupancy and AStar path to all three buildings.
- Visual checks: seam-free base terrain, coherent paths, alpha, tree/rock/lamp anchors and scales, Y-sort/depth, no blocked doorway or click target, sufficient readable courtyard, no severe edge crop.

Separate:
1. Archive integrity PASS;
2. Godot import PASS;
3. headless/functional smoke PASS;
4. visible Windows rendering PASS;
5. manual interaction PASS;
6. **OWNER VISUAL APPROVED**.

Only documented evidence may promote each status. Godot exit code 0 alone does **not** establish a usable visible screenshot. If QA fails, inspect causes and prepare a **minimal isolated-lab fix**, not FE-02 migration.

## 6. Architecture and strict scope protections

- Canonical: `SimulationState`, `SectState`, `DiscipleState`, `BuildingState`, `BuildingSystem`, `WorkforceSystem`, `WarehouseSystem`, cultivation, body training, EXP, production and save/load are **immutable without separate approval**.
- ADR-0003: Godot-native, data-driven, V1 fixed-layout; presentation reads canonical queries and calls real commands, but never invents gameplay economy/completions. Visual AStar arrival is not a simulation completion event.
- No second authoritative map/gameplay state; do not wholesale port Unity/Lua `_MapManager` (native internals unknown). Keep an explicit coordinate transform, correct feet/depth sorting, and HUD separate from camera world.
- Production P3.1/P3.2, asset registry approvals and eight S3 arts: **do not change**. No FE-02/G1, no new gameplay phases.
- `DV2-03` remains **PAUSED, NOT CLOSED**.
- The Codex **Spine → Godot** conversion pipeline at `E:\TongMonIntegrationLab\SpineConverted` is a **parallel independent task** with unaccepted visual results. ENV-01 static environment does **not** wait for Spine; do not restart catalog/converter or disturb those files.
- Do not recreate `AssetCatalog` or rescan the ~157,607 previously catalogued paths.

## 7. After Windows QA: single next decision

**IF** valid Godot screenshot, both logs, functional QA and owner visual assessment pass: propose **PV-02 visual acceptance/reconciliation**, with candidate-art identities and screenshot evidence. **Only afterwards** request a separate explicit authorization for **FE-02 production integration** into canonical P3.2, with official Godot regression, Windows visual and real gameplay commands.

**IF** QA fails: show image + errors + narrow fix allowlist, then repair/retest **within the isolated ENV-01 lab only** after confirming permissions. Preserve all other projects.

**IF** ENV-01 deliverable cannot be found: request the **one actual ENV-01 ZIP/directory**; do not re-create it from scratch or pretend the original Source A asset handoff is the ENV-01 implementation.

## 8. Next-chat response expectation

In the first response, identify which **actual** ENV-01 files are accessible, separate evidence from owner reports, and request only the missing Windows screenshot/two logs or ENV-01 ZIP when needed. Do not ask to restart PV-00 or to run long repetitive PowerShell asset scans.

Report statuses explicitly: `PASS`, `FAIL`, `PENDING WINDOWS`, `PENDING OWNER VISUAL`, `BLOCKED MISSING ARTIFACT`.

**User values:** one deliverable-focused packet at a time, avoid repeated preparation, reuse source A and available Godot code, do not destabilize game, finish a beautiful playable map before economy rebalance.

## 9. GitHub and binary-file boundaries

This handoff is documentation, **not** a claim that the 26.7 MiB SourceA ZIP or a runnable ENV-01 ZIP is stored in GitHub. Preserve actual artifact paths and checksums only when confirmed. Do not push Source A binaries/ZIP or force Git LFS policy changes under a docs-only handoff.
