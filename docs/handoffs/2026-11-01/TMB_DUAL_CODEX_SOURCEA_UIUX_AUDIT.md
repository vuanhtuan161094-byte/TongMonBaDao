# TMB — FULL-PROJECT SYSTEM/ASSET/UI AUDIT AND TWO-CODEX DECISION
**2026-11-01 | Owner: graphical/UX overhaul is a core quality issue.**
**STATUS: evidence-backed source inventory, design/routing only. NOT a gameplay acceptance, asset import, second Codex launch or permission to distribute proprietary assets.**

## 0. Decision

**YES to TWO roles, NO to TWO concurrent overlapping code writers.**
- **Codex A (existing TRI-01 owner):** single write owner for RC gameplay, migration, recruitment, Hall, House, canonical state/save/scheduler, and active `p3_2_landscape_sect.gd`, `dai_dien_screen_v1.gd`, `dan_tien_screen_v2.gd`, `sect_isometric_world_v1.gd`. Current handoff: docs/handoffs/2026-11-01/CODEX_TRI_FACILITY_INTEGRATION_PROMPT.md. Retain existing live ref verification and tests. Never create a second core-state author.
- **Codex B (initially READ-ONLY design/asset audit):** research all game presentation surfaces, verify actual Source A visual/art rights/manifest, propose a new consistent UI design system, validate asset conversion feasibility; may commit **docs-only** to its **own branch**, not change any .gd, scene, resource, binary or root checkpoint. Full prompt in CODEX_B_SOURCEA_UIUX_READONLY_PACKET.md.
- **Phase 2 B native implementation:** ONLY after A has a tested, pinned SHA and owner issues a separate explicit code allowlist. In an isolated branch, build ADDITIVE new reusable Godot UI scene/components and preapproved visual resources; integration owner A alone edits shared host/main screens. Do not run two Godot instances concurrently on the 8 GB RAM machine; no running telemetry or FPS logger.

This separation follows docs/GAME_SYSTEM_ARCHITECTURE.md §4: one writer per overlapping subsystem, concurrent READ-ONLY QA/design permitted. **No second runtime Codex has been launched by this audit.**

## 1. Verified live repository and subsystem map

At audit: `rc/one-game-playable-20261101` = `970af33b23076c80d677cf5898a721a27504708f`; `feature/dai-dien-v2-live-p0-20261101` PR #64 = `bf3ed0310899c554eea4e6b2e1967dcada2d68dd`; C2 PR #60 = `074ca829d2d35a559c445edba17c5e1f9d1dc937`, already an ancestor of RC. Both PRs Draft. `main` = `c0c1382f119599497b52d8ee8abd9e830a883f1e`. Refresh refs at start of each session.

Git tree of RC inspected: **1,328 tracked blob paths**, including **170 GDScript production scripts** under godot/src, **181 GDScript tests** under godot/tests, **237 docs paths** and **171 art/assets paths** under godot/art + godot/assets. These figures describe repository inventory, **not 170 files each individually code-reviewed** and not a claim of test coverage.

| Whole-game domain | Canonical source locations | Impact on three-building visual redesign | Status/gate |
|---|---|---|---|
| State/save/runtime | simulation/state, core, save | All screens must READ state; only existing transaction APIs may mutate | Canonical source, do not duplicate |
| Buildings and construction | simulation/building, P3.7; PR64 governance | Buildings/levels/plots/status and conditions must match art and buttons | PR64 official Godot NOT RUN |
| 27 ranks/offices | PR64 sect_hall_system_v1.gd | Hall overview, role portraits, rank path, cost/delta | Pacing PROVISIONAL, not redesign |
| Rooms/recruitment cap | PR64 sect_residence_system_v1.gd, sect_residence_site_v1.gd | House image, entrance, occupancy/room grid, selected plot | 12 fixed plots, not arbitrary editing |
| Dẫn Tiên C2/D7 | recruitment, DanTienScreenV2 | Candidate photo/radar, guidance selectors, sticky accept/reject | RC official Godot UI 64 assertions PASS; cross-process reload 29 PASS |
| Economy & production | economy, resource, warehouse, building | Mines/forest/field/forge/medicine/market detail panels | Existing Forge P3.4C FAIL, keep as known red |
| Cultivation/medicine | cultivation, needs, building | Work timer, cultivation/pill details; no inaccurate fake resources | B3 CARE / Injury120 locked |
| PvE/skills | combat, technique, p3 visual | UI overlay only if independently scoped later | DO NOT ALTER PvE gameplay/route |
| Character/display | presentation/assets, Source A actor scenes, P3.2 | Reuse verified portraits; no unsourced AI portraits | 7 tracked actor .tscn scenes observed |
| World/map/camera | SectIsometricWorldV1, SectMap25SourceArt, p3_2_landscape_sect.gd | Building sprite visibility, click/focus, door and occlusion | Source SHA gates, isolated 1280x720 QA |
| Device/QA | tests/presentation + Windows scripts | Mouse/touch hit targets, screen clipping, smoke, screenshots | Automated is not physical owner acceptance |

## 2. Confirmed real rendering gap (not just opinion)

At RC 970af33, `SectIsometricWorldV1.HOUSE_TEXTURES` registers only:
- `main_hall -> pv01_assets/main_hall/510052.png`
- `warehouse -> pv01_assets/warehouse/510102.png`
- `forge -> pv01_assets/forge/520081.png`

They load only when `SectMap25SourceArt` verifies SHA256 and `ResourceLoader` opens a valid imported texture. Other building types have no matching HOUSE_TEXTURES key, and `_draw_building` draws fallback **worksite vignette**, compact painted geometry or native icon/label. In particular, **the two core user-requested buildings Residence and Dẫn Tiên have no direct Source A runtime building artwork mapped**. Actual load success of the three registered textures requires engine log/GUI evidence; tracked paths alone do not prove the screenshot looks good.

The Godot game repo includes 3 PV01 PNG building textures, but *not* the other 10 candidate building textures in the imported art path. The optional source catalog at:
- `godot/data/presentation/source_a_candidate_manifest.json`
- `vuanhtuan161094-byte/ZQZS-Source-Knowledge` @ `83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`
- `transferkit/Catalog/BUILDING_VISUAL_INDEX.csv`
records **13 candidate logical building types** (not 13 approved art files). Some share IDs (medicine/alchemy both candidate 520031) or are INFERRED analogs and need per-instance identity verification.

Focus candidates: Hall `510052` (7×5), Residence `510076` (3×3), Guidance/Dẫn Tiên `510111` (3×3), Warehouse `510102` (3×2), Forge `520081` (3×3). Candidate metadata still has `binary_imported=false`, `visual_status=CANDIDATE_NOT_APPROVED`, `release_rights=UNVERIFIED`; for Residence/GUIDANCE no runtime resource path. The 3 imported PV01 textures have their own map25 SHA whitelist, not a blanket license or blanket Source A approval.

**MAJOR DOOR MISMATCH TO VALIDATE VISUALLY:** Source A source catalog's `building.disciple_residence` says doorway_offset **[1,-1]** for rotation-zero, while DD-09.2 SectResidenceSiteV1 uses `DOOR_OFFSET=Vector2i(1,3)` and its map uses an outside-bottom door. This is not safely resolved by picking either number without comparing actual imported sprite orientation/anchor. Codex A owns gameplay/location and decides remedy with test; Codex B ONLY reports visual geometry (width, pivot, projection, transparent padding, orientation and door pixel position), not edits saved placement/actor movement.

**Spine concern:** Source A building entries have atlas+skel+lum+texture dependencies; a standalone extracted texture may be an atlas sheet, not a ready-to-display composited building frame. Do not claim a correct Godot building sprite until frame composition/atlas extraction is visually verified. Existing Spine version compatibility remains a separate gate; prefer proven authorized static render/extraction if possible.

**Rights:** source catalog states `A_USER_AUTHORIZED_LAB; verify redistribution scope before shipping`. Visual references from other commercial games are style/layout studies only. DO NOT commit or redistribute unverified UI atlases/spine/raw game art. In internal development, work only with source files the owner is entitled to use and keep SHA/rights/attribution manifests. If redistribution rights are unknown, mark `RIGHTS_BLOCKED` and supply a clean original-design placeholder. `ZQZS-Source-Knowledge` is largely text/metadata and does NOT itself contain full binary textures/Unity bundles; paths like E:\GameAssetExtract are references to potential local extraction, not verified file availability in a Codex workspace.

## 3. Why building UI feels like text documents

PR64 `godot/src/presentation/dai_dien_screen_v1.gd` builds 6-tab single scrolling VBox content; the Hall overview consists mainly of _label() lines with a few buttons and a small 90×92 Source A portrait for role holders. P3.2's common operation panel is long imperative Control-building code inside ~7.2k-line host script, with dense text labels in many subsystems. C2 `dan_tien_screen_v2.gd` is more focused, using candidate cards/portrait/radar; its RC-only **CandidateDecisionActions** MUST be preserved in UI polish. These are source-level observations, not proof of actual 1280x720 clipping.

Design goal: **“show, not tell”** — default state communicated via building/character art, icons, progress bars, room slots and compact cards, not paragraphs.

## 4. New UI design target: original art direction inspired by Source A, NOT copied game UI

Visual language: ivory parchment / pale jade / dark forest ink / restrained bronze gold; Source-A-like soft fantasy ink accent, subtle roof silhouettes and frame ornament, no full-screen gradient noise, no fake full 3D. Avoid 6 heavy full-width text tabs at top; keep map as main surface. Real 1280×720 landscape, good contrast and minimum touch target 44×44 (prefer 48×48). Any global HUD changes require later owner authorization.

Suggested interactions:
- **Map click 1**: small focus highlight and right-hand 400–440px contextual drawer with art preview, Lv/rank, two key KPIs, actions `Quản lý`, `Nâng cấp`, `Tới`; don't hide the whole map immediately when a building is selected.
- **Hall full detail**: left 32–36% vivid Hall art + 27-rank track and overall influence; right upper 7 role portrait slots (icons/portraits, effect badge), lower context card showing selected office eligibility, assigned disciple and actual producer bonus; fixed bottom `Bổ nhiệm`, `Nâng Đại Điện`, `Thăng Bậc` with cost/delta.
- **Residence detail**: illustration and Level/Bed count above, room occupancy via 2×4/3×4 graphic slot chips, resident avatar grid, status banner for building timer, real plot thumbnail/map doorway; fixed bottom `Xây nhà` / `Nâng cấp` / `Chọn cư dân`. An unfinished Residence has zero usable beds. Door always outside.
- **Dẫn Tiên**: existing RC modal stays; upgrade quality with 6 applicant thumbnails/page, hero portrait, D7 nested radar, limited icon chips for roots/profession, fixed bottom `NHẬN ĐỆ TỬ` / `TỪ CHỐI`, clear capacity/cost and current Chiêu Mộ Lệnh; no gacha rebalancing.
- **Other game surfaces** for later **separate authorization**: Mine/Forest/Spirit Field output inventory,Alchemy/Medicine recipe cards and colors, Workforce priority selector, Disciple profile HS09, Compendium/skills, PvE minimal HUD, Settings/Save. No scope creep into their gameplay during TRI-01.

UI asset render rules: source art portrait/sprite area should be visible at target viewport; no cropped faces; Godot anchors/containers responsive, 24/32-px icon slots with consistent 48px touch surfaces, minimal scroll, interaction feedback inline near the action; dark text on light parchment or light text on dark panels, never low-contrast gold text over busy background. Panel styling should be original and license-safe. Never paste reference-game proprietary screenshot as a game backdrop.

## 5. Source A research targets and exact QA deliverables

| Goal | Source | Proof required |
|---|---|---|
| Complete building-family shortlist | `BUILDING_VISUAL_INDEX.csv`, `godot/data/presentation/source_a_candidate_manifest.json` | model id, exact file expected, SHA, dimensions/alpha, role match, rights status |
| Residence 510076 | Catalog and owner-controlled local extraction if legitimately present | actual clean isometric static frame, 3×3 projected footprint and pixel-door coordinate, correct direction |
| Dẫn Tiên 510111 | Same | candidate verified as guidance building, not another site reused under wrong label |
| Hall 510052 | Existing runtime PV01 and selected SourceA texture | screenshot screenshot crop/anchor versus map footprint and mouse hit area |
| UI building management | UI_PREFAB_PROBE.json: `uibuildingmsgwin.ab`; UI_SCREEN_INDEX.csv | inspect style/layout and information grouping ONLY; prefab/atlases are not imported/approved |
| Build/layout reference | UI_SCREEN_INDEX.csv `ui.building_layout`; `uilayouteditwin` | design patterns, not second building placement authority |
| QA artifacts | Godot actual screenshots at 1280×720, QA checksum/log | Before/after side-by-side, missing icons, cut content, effective click area, Source A SHA list |

Reference research: published screenshots of 最强祖师 show easy-to-scan building cards, illustrated panels and candidate portraits (TapTap/Xiaomi), which support high-level arrangement only. Copying icons, window frames or proprietary graphic files from screenshots is NOT approved.

## 6. Safety and staffing

Codex B phase 0 is `READ-ONLY repo/gameplay + docs-only writes`. Disallowed:
- Git merges, branches moving head, rewriting shared files `godot/src/presentation/p3_2_landscape_sect.gd`, `dai_dien_screen_v1.gd`, `dan_tien_screen_v2.gd`, `sect_isometric_world_v1.gd`.
- Any changes to SimulationState, BuildingState, SaveService, BuildingSystem, recruitment, economy, rankings/odds, pathfinding/doors/footprints.
- Opening a second Godot window or background build while Codex A is testing; modifying active PID/profile/save, installing admin-required software, creating perf monitor.
- Pushing unverified proprietary Source A assets, UI atlases, any JX/JXQY or AI-generated substitute.

Sequencing:
1. Owner sends Codex A previous TRI-01 prompt if not already started; it is single writer in its integration branch.
2. **Parallel Codex B phase 0**: inspect only, propose asset/UX map and prioritized screenshots on docs-only branch; no code merge. Owner reviews.
3. After A produces verified integration HEAD, B phase 1 may make standalone native Godot UI components/clean authorized art on NEW disjoint path allowlist only, with a pinned base and real tests. A remains the sole integration/wire-up owner; Codex B never touches A's files unless A explicitly hands off ownership after closing.
4. Owner reviews actual clickable game/building visuals before deciding acceptance. Merge only with explicit owner authorization.

## 7. Decision

**Recommended NOW: 1 implementation Codex A + 1 design/asset-audit Codex B.** Parallel development without write collisions. No two Godot processes on 8 GB RAM. This is NOT two independent full-stack Codex agents.
