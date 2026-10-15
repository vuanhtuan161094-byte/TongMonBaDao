# TÔNG MÔN BÁ ĐẠO — ISOLATED UNITY / SOURCE-A PILOT

Status (15 Oct 2026): **CODE PREPARED, UNITY RUNTIME / VISUAL / SPINE NOT TESTED**.
Branch `unity-sourcea-pilot-20261015`; based on Godot `main` at
`461caca1171462e0da092f21108c5c1733157ad9`.
This directory is **independent** and is not part of the Godot runtime,
save files, simulation, Economy-A or existing GUI-WORKFORCE-V1 PR #2.

## Purpose

Test whether a **Unity 2020.3 LTS** front end makes it more efficient to
reuse reference Unity UI hierarchy and available Source A assets. It is
not authorization to migrate the game or port its gameplay rules.

- 1280 × 720 logical landscape and parchment / jade / cinnabar palette.
- World-first Tông Môn shell; click the Mine; show right management panel.
- Display 3 mine slots and an explicit roster dialog with search, idle
  filtering, nine portrait-grid entries per page, paging and disabled
  busy workers; one active mock job per disciple.
- Demo timer and ore are intentionally isolated synthetic values. They
  **DO NOT** represent Godot's real production rate, Warehouse, receipts,
  balance, save/offline or runtime authority.
- Optional Spine 3.8 adapter guarded by `TMBD_SPINE38`; not installed,
  licensed, imported, wired or tested as part of this code.

## Running with Unity installed later

1. Install Unity Hub and Unity Editor **2020.3.48f1**, with appropriate
   platform modules when Android is needed.
2. Copy/open **this directory** as a Unity project in Unity Hub.
   (Do not open the Godot repo root as a Unity project.)
3. Allow Unity to resolve the Unity UI and Test Framework packages.
4. Use **Tools > TMBD > Create Pilot Scene** once.
5. Press Play at **1280 × 720** in Game view.
6. Tap `MỎ THANH THIẾT`, then `PHÂN CÔNG ĐỆ TỬ`.
   Verify searching/filtering/paging, selecting an Idle disciple,
   rejection for one currently in Field or PvE, and progress.
7. Run **Window > General > Test Runner > EditMode** tests.
8. Only after Editor proof, assess a real Android landscape build.
   Screenshot approval is required before calling the art/gameplay PASS.

## Spine 3.8 verification separate from UI

Official compatibility: spine-unity 3.8 supports Unity 2017.1–2020.3:
https://esotericsoftware.com/spine-unity-installation
Official package archives: https://esotericsoftware.com/spine-unity-download

A Spine Editor license can grant rights to use Spine Runtimes; a Trial
license does not grant runtime integration rights. Having rights to the
original character artwork does not automatically confer these rights:
https://esotericsoftware.com/spine-runtimes-license
https://esotericsoftware.com/spine-editor-license

Do not commit a license key or copy a bundled Spine runtime into this
repository. After verifying licensing, install the matching 3.8 Unity
runtime, add skeleton, atlas and page textures locally, confirm version,
and enable `TMBD_SPINE38`. Animation names `stand`, `walk`,
`attack1` are hypotheses to confirm per real asset. Test skin,
orientation, atlas pages, frame rate and Android build.

## Source/material evidence

- `ZQZS-Source-Knowledge/docs/UI_UX.md`
- `ZQZS-Source-Knowledge/docs/HOME_BUILDING.md`
- `ZQZS-Source-Knowledge/analysis/DeepAnalysis/data/building_ui.json`
- `ZQZS-Source-Knowledge/indexes/ui_calls.csv`
- TMBĐ: `docs/P3_REFERENCE_UI_AUDIT.md`,
  `docs/P3_UX_BUILDING_INTERACTION.md`,
  `docs/P3_UI_SKIN_AND_ICONOGRAPHY.md`.

Reference data contains Unity/UI metadata, **not the original binary
texture/atlas/bundle assets in GitHub**. The local Source A export must
be retrieved and hash-verified before visual asset ingestion. This pilot
uses explicit placeholder UI; do not present it as a final reference
quality screenshot, and never claim pixel-for-pixel fidelity.

## No migration decision yet

Compare **same** 3 functions (map → mine → pick worker) on real Unity
and Godot screenshots, UI polish time, Spine playback and Android
performance. If Unity wins materially, propose a separate,
owner-authorized migration plan for backend and save data.

## QA status

- Static source scaffold: saved to isolated GitHub branch.
- Unity compile, EditMode, PlayMode, prefab visual fidelity: **NOT RUN**.
- Spine 3.8 animation / mesh / atlas / licensing proof: **PENDING**.
- Android APK and device: **PENDING**.
- Godot production `main` and PR #2: **UNCHANGED**.
