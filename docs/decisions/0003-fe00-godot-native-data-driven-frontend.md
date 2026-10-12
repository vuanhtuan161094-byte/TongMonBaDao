# ADR-0003 — FE-00 Godot-native, data-driven production frontend

Status: accepted (DESIGN ONLY; no FE-01 code authorization)
Date: 2026-10-12
Game baseline: `vuanhtuan161094-byte/TongMonBaDao` main `5f5646ce77b7c53b9452a1740070fe9d6e0d84dc`
Source Knowledge baseline: `vuanhtuan161094-byte/ZQZS-Source-Knowledge` main `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`
Evidence: GitHub code/config/document audit + Source A TransferKit V1 reports; NOT a new Godot run.

## Context and options

M1 O1–O6 and M2 O7–O9 are technically accepted on official Godot 4.7.2 Linux CI. Windows landscape visual/click/APK review is still PENDING USER. Existing presentation builds almost everything dynamically in `p3_1_landscape_sect.gd` (~1,078 lines) and `p3_2_landscape_sect.gd` (~3,282 lines); scenes have minimal roots, buildings are code-drawn graybox tokens, and `SectMapPresentation.DESTINATION_POSITIONS` is hardcoded screen-space positioning. This is adequate for opening gameplay regression, but not a durable production world/art/UI boundary.

Options considered:
- A — attach Source A PNGs directly to existing graybox functions: fast first result, unacceptable coupling/rework.
- B — port Unity/Lua/_MapManager architecture and assets wholesale: excessive risk; native algorithms and server behavior unverified.
- C — adopt Godot-native, data-driven presentation with an asset registry, fixed-layout world model, visual-only navigation, view-model adapters and reusable UI components: **ACCEPTED**.

Source A is a benchmark and an authorized **candidate art source**, not simulation authority. Approval to use candidate art in the project does not establish third-party redistribution rights for a shipped/public build.

## Decision 1 — immutable gameplay boundary

Canonical `SimulationState`, `SectState`, `DiscipleState`, `BuildingState`, `BuildingSystem`, `WorkforceSystem`, `WarehouseSystem` and current commands remain gameplay/save authorities. Presentation queries canonical state and dispatches existing real commands; it must never generate EXP, resources, level, staff assignment, production output, damage, cultivation, timers, recruitment, item consumption or persistence values.

Direction: `Simulation -> PresentationQuery -> defensively copied view-model snapshots -> screen/world controllers -> visual components`.
Command direction: `UI input -> controller -> canonical command -> simulation -> fresh snapshot`.
A copied snapshot is a read-only **contract by discipline** (Godot Dictionary itself is mutable), not a second state store. Do not persist view-models as gameplay facts.

## Decision 2 — layout and world coordinates

V1 is **fixed-layout only**, mobile **landscape 1280x720**. Introduce:
- `SectLayoutDefinition`: versioned content entries with `destination_id`, optional **real** `building_instance_id`, `visual_id`, `grid_origin`, `orientation`, `presentation_kind`.
- `BuildingVisualDefinition`: visual ID, footprint, doorway offset, orientation support, sprite anchor, feet/depth/shadow anchors, size/variant/fallback; no production rule.
- `SectMapProjection`: one grid-to-isometric transform; width/height/origin are calibrated content values, NOT unverified constants copied from Source A.
- `SectMapModel`: occupied cells, transformed footprint, doorway, visual roads, presentation-only AStarGrid2D routes, map revision.
- `Camera2D` world transform; HUD/modal in separate `CanvasLayer` outside map transforms; buildings and actors share consistent depth/Y-sort context.

All layout geometry uses `Vector2i` grid coordinates; actors render anchored by feet. Doorway offsets may intentionally be outside a footprint. Coordinate axes, cell origin, 90-degree orientation transform, painter order and exact pixel scale must be calibrated against actual imported art in FE-02 with deterministic tests. No unverified Source A grid metric is locked.

Fixed placement is content-owned, NOT added to `BuildingState`. A future editable-layout feature requires a separately approved persistent `SectLayoutState`/migration and exclusive ownership transfer; it is forbidden to sneak building x/y/orientation into simulation during FE-01/FE-02.

There must be an explicit `presentation_kind` or equivalent for real managed building vs landmark/destination/visual analog; 13 visible tokens do NOT imply 13 real `BuildingState` instances. A UI must never synthesize a level, worker count, or production panel for an unbound landmark.

## Decision 3 — asset ownership, aliases and source evidence

`docs/P3_ASSET_REGISTRY.json` remains the canonical **approved asset/status inventory**, with `docs/P3_SOURCE_RECOVERY_MANIFEST.md` for recoverability and visual authorities `docs/P3_ASSET_BUILDINGS.md` / P3 art docs. TransferKit `transferkit/Catalog/*` is an external **candidate provenance index**, not another production authority. A runtime `VisualAssetRegistry` must resolve curated runtime assets using stable TongMon logical IDs and derived/validated manifests, NOT claim independent authoritative art approvals. Keep explicit TransferKit-to-TongMon alias/source provenance; no ad-hoc hardcoded `E:\\...` or physical PNG paths in screen controllers.

Record source variant, logical ID, source config/model ID, dependency manifest/hash, curated pack hash, Godot resource path, asset type, skin/level variant, evidence status, compatibility status, and fallback. No runtime dependency on the author's local `E:\\GameAssetExtract` or `E:\\TongMonIntegrationLab`.

The eight historically approved TongMon building illustrations are **visual-approved but their exact bytes remain S3/missing**; Source A candidate art is NOT a silent replacement of those approvals. FE-01 may stage/curate candidates with provenance; switching approved presentation identity to a specific new asset requires a separate visual approval/reconciliation. Do not rewrite old approval history or mislabel regenerated/substitute assets as recovered originals.

`docs/decisions/0002-adopt-git-lfs-for-production-art.md` remains **proposed**. Do not enable/force LFS or add binary ZIP/base64 hacks in FE-01 without Windows LFS feasibility and a separately approved handling plan. Production .import sidecar policy stays with ADR-0002.

### Opening Source A candidate mapping (TransferKit V1)

| TongMon destination | TransferKit logical ID | Source config / model | Confidence |
|---|---|---|---|
| `main_hall` | `building.main_hall` | 1 / 510052 | VERIFIED; static texture Godot lab PASS only |
| `residence` | `building.disciple_residence` | 15 / 510076 | VERIFIED; static Godot production NOT TESTED |
| `cultivation` | `building.cultivation_area` | 36 / 510191 | INFERRED_VISUAL_ANALOG |
| `ren_than_duong` | `building.body_training` | 38 / 510232 | INFERRED_VISUAL_ANALOG; not body training equivalence |
| `warehouse` | `building.warehouse` | 14 / 510102 | VERIFIED |
| `forge` | `building.forge` | 7 / 520081 | VERIFIED |
| `medicine` | `building.medicine_hall` | 6 / 520031 | INFERRED_VISUAL_ANALOG; same Source A model as Alchemy |
| `mine` | `building.mine` | 4 / 520051 | VERIFIED |
| `spirit_field` | `building.spirit_field` | 2 / 520091 | VERIFIED |
| `linh_forest` | `building.linh_forest` | 3 / 520101 | VERIFIED |
| `alchemy_hall` | `building.alchemy_hall` | 6 / 520031 | VERIFIED |
| `guidance` | `building.guidance_platform` | 22 / 510111 | VERIFIED |
| `gate` | `building.sect_gate` | 39 / 510163 | VERIFIED |

Confidence means Source A catalog/config/model provenance, **not** verification of complete Spine effects, in-game gameplay equivalence, or current TongMon visual approval. All but `main_hall` have Godot static rendering NOT TESTED in TransferKit V1. Full Spine playback NOT TESTED for buildings.

## Decision 4 — actor, navigation and UI adapters

`ActorPresentationController` maps action/worksite snapshot -> destination -> transformed doorway -> AStarGrid2D visual route -> facing/motion request. `ActorVisualRenderer` renders replaceable Godot sprite/shared modular rig, with optional future Spine renderer. Visual arrival **must not** complete a simulation job, pay a reward or advance the canonical scheduler. Unreachable routes are visual `UNRESOLVED_ROUTE`, not forced gameplay success.

Source A `_MapManager.IsCanPlace`, `FindPath`, culling/sorting/native rules are **UNKNOWN** internally; TransferKit's own Windows map lab verified placement rejection, orientation, doorway, visual routing, and WALK->WORK->IDLE, NOT native parity or production Godot integration. Rig `1113002_1` Spine 3.8.75 is **BLOCKED_NO_SPINE_RUNTIME_IN_LAB**; names `stand/walk/attack*` are unverified binary strings. No Spine dependency in FE-00/FE-01. Existing approved `female_normal_v1` modular rig contract must not be replaced by the Source A rig without a later explicit decision.

Godot UI uses scene + controller + canonical query-derived view-model + reusable components, with event/command dispatch and new snapshot after changes. No label-level direct state mutation. Preserve locked V3 UX: landscape map-first/edge HUD; disciple tap -> right summary -> deep profile with left roster, center showcase, right tabs. `TMPanel`, `TMButton`, `TMTab`, `TMTooltip`, `TMResourceBadge`, `TMProgressBar`, `TMQualityFrame`, `TMDiscipleCard`, `TMBuildingCard`, `TMModal` are FE-04 candidates, NOT all authorized in FE-01. Retain existing accessible click target and camera tests; don't assume moving from `Control` to `Node2D` preserves input behavior.

## Decision 5 — gradual migration and phase gates

Existing P3.2 scene and tests remain the runnable baseline. No big-bang rewrite and no parallel production simulation/map authority.

- **FE-00 (this ADR):** read-only audit + accepted design only; NO code, art generation, runtime test or FE-01 authorization.
- **FE-01 QUEUED, NOT AUTHORIZED:** preflight selected Source A dependencies/rights/size/transport; curate 13 candidates with explicit original-approved-art protection; logical alias + manifest + read-only `VisualAssetRegistry`; schema/hash/load/fallback/path checks. If binary transport/LFS unready, mark import BLOCKED; do not fake PASS. **No main scene, gameplay, world replacement, Spine, or renderer rewrite.** The actual FE-01 implementation must receive separate user authorization and respect one-active-phase rules.
- **FE-02 after separately accepted FE-01:** fixed layout/world projection/footprints/doorways/AStar routes + production Godot scene and visual actor adapters, then map scene interaction parity tests.
- **FE-04 when separately authorized:** reusable production UI, Source A UI evidence only as layout/atlas pattern; preserve existing V3 flows and real commands.
- **Cutover:** only after production map reproduces building/actor selection, camera/mobile interaction, recruitment, Mine/Forest/Field/Alchemy/Forge/Medicine/Guidance, canonical stock, save/reload, real autonomous work and cumulative official Godot 4.7.2 regression. Retire graybox **only after** cutover PASS. Distinguish Linux CI from Windows/manual visual/APK acceptance.

The exact official CI for M2 O9 is #38193051636; DV2-03 #38193051740; P3.7 #38193051669. These are **historical gameplay acceptance**. No FE-00 runtime CI was run and no new FE runtime PASS is claimed.

## Consequences / exclusions

Benefits: data-driven visual swap, one map-coordinate vocabulary, controlled artist asset provenance, stable simulation authority, no Source A dependency or major rewrite. Costs: FE-01 staging/registry and FE-02 projection/parity before final art cutover. Work on DV2-03G1, DV2-04, new gameplay/balance/EXP, player-authored layout, alternative warehouse, runtime Spine, new UI feature scope or FE-01 code is not authorized by FE-00 closure.

## Evidence and links

- `docs/GAME_SYSTEM_ARCHITECTURE.md`, `docs/P3_PRESENTATION_MASTER.md`, `docs/P3_UX_MAIN_MAP.md`, `docs/P3_2_MODULAR_ACTOR_SPEC.md`, `docs/P3_ASSET_REGISTRY.json`, `docs/P3_SOURCE_RECOVERY_MANIFEST.md`.
- Game: `godot/src/presentation/p3_1_landscape_sect.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`, `godot/src/presentation/p3/sect_map_presentation.gd`, `godot/src/simulation/{state,building,workforce,resource}/`.
- Source A: `sources/AndroidData/binary/gamesys.home.ims_design_layout_*.lua`, `gamesys.home.ims_road_*.lua`, `gamesys.home.isometricmapsystem_*.lua`, `gui.windows.layout.uilayouteditwin_*.lua`, `gui.windows.disciple.uidiscipleroleinfowin_*.lua`.
- TransferKit: `transferkit/TECH_TRANSFER_README.md`, `transferkit/Contracts/PRESENTATION_ADAPTER.md`, `transferkit/Reports/{V1_MILESTONE_REPORT,UI_SOURCE_CHAINS,CHARACTER_COMPATIBILITY}.md`, `transferkit/Catalog/{BUILDING_VISUAL_INDEX,UI_SCREEN_INDEX,DISCIPLE_RIG_INDEX,ANIMATION_INDEX,GODOT_COMPATIBILITY_INDEX}.csv`.
