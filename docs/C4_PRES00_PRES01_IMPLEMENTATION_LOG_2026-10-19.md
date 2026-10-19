## 2026-10-19 — real Windows Godot 4.7.2 focused QA result (user-provided logs)

User ran offline helper on exact SHA `4563cddf9b015eaaa56ad638564db61ff9b80dc2`, official Godot `4.7.2.stable.official.ed1daf0bf`. Attached evidence `C4_PRES01_QA_LOGS.zip`: `01_import` completed without parser errors; `02_pilot_status` PASS; `03_snapshot` PASS. `04_group` FAIL (exit 1) due to real GDScript warning promoted to error at `res://src/presentation/p3/map_battle_world_layer_v2.gd:490`: inferred `Variant` from `Dictionary.get()` on the `feedback` lookup. Result: **2/6 focused gates PASS; overall QA FAIL**, `05`–`07`, `08_scene_smoke`, GUI/owner UX/Android all NOT RUN/PENDING. This does not establish a Combat V2 simulation defect.

Authorized targeted repair on same branch: change inferred `var feedback := {...}.get(kind,"")` to explicitly typed `var feedback: String = str({...}.get(kind,""))`. Does not change game rules or actual status-event meanings. Runtime after the repair remains PENDING until new physical Windows evidence.

Owner also explicitly requested log ZIP stay **in the launcher folder**, not deep in TEMP. ChatGPT-distributed one-click launcher v4 is to keep source clone + isolated user profile under TEMP, but write durable per-run `logs/`, `SUMMARY.txt`, per-run archive and a convenience `KET_QUA_C4_PRES01/C4_PRES01_QA_LOGS.zip` beside `CHAY_COMBAT_V4.cmd`. On future failures, provide the file from that visible folder. The companion launcher is outside GitHub and does not modify project gameplay.


# C4 PRES-00 → PRES-01 implementation log — 2026-10-19

## Exact scope and status

- **AUTHORISATION:** user explicitly authorised PRES-00 asset audit and PRES-01 presentation-only code, with simulation authority locked.
- **SOURCE BASE:** branch `c4-pilot04-jx-effects-20261019`, pinned `5c2e42abb44407bfc4d5a14ea2e7b2e966a2c3de`; design blueprint from docs branch commit `98db733`.
- **WRITE BRANCH:** `c4-pres01-jx-motion-readability-20261019`.
- **AUTHORITATIVE V2 GAMEPLAY UNTOUCHED:** no changes in `godot/src/simulation/`, save, economy, main or PR #20.
- **PRES-00 evidence:** Both Drive root folders accessible. Drive1: `img/a` 585 items (117 5-action sets), `fx` 202 visual items and `snd` 232 audio items listed. Drive2: `js` 66 entries; `data/vltk/native/assets` 662 entries (contains WebP and WAV), `data/vltk-fx.json` is a gzip+base64 packed JSON with 270 skill graphs, 176 native sprites and 496 source sound declarations. This is a **fan-game metadata catalog**, not verified official engine provenance or permission.
- **PRES-00 manifest:** `godot/data/presentation/c4_jx1_pres00_five_skill_asset_manifest.json`: five exact EP01 IDs: #15, #158, #159, #63, #93. Seven relevant individual WebP binary files were actually downloaded from Drive and verified with full SHA-256 matching the respective `asset-hashes.json` prefixes. #15 precast and #93 cast are metadata-declared but not found in the inspected FX folder. #159 provides no authored visible cast/impact clip in that specific metadata graph. No corresponding 5-skill audio binary verified. **NOT imported into Godot:** rights/repacking/deployment status pending; Source A disciples' combat clips beyond idle/walk not proven.
- **PRES-01 code:** `godot/src/presentation/p3/map_battle_world_layer_v2.gd`: 0.25-second bounded render interpolation between real V2 actor positions (no extrapolation); FPS-driven sampling, source sprite action age unchanged; school/role marker sourced from actual `pilot_loadout` or role; enemy/Boss z-depth view uses interpolated positions; boss art scale 2.30→1.52; removed debugging grid while retaining original arena transform; health bars deconflicted in a **UI overlay only**; short real-event-only status feedback; `pilot_impact` no longer restarts caster attack.
- **Focus test added:** `godot/tests/presentation/c4_pres01_view_motion_readability_test.gd` checks initial and midpoint interpolated endpoints, cap, authority HP/positions/events/RNG/tick unchanged, school tag and HP overlay layout. Preserve older `c4_vp01_source_vl_battle_visual_test.gd` and `combat_v4_world_layer_cast_schema_test.gd` contracts.
- **PRES-02 not implemented:** no JX projectile sprite, 16-direction FX graph, audio mix or source audio playback is represented as ready. #158/#63/other school FX only when exact source binary mapping is legally and technically cleared.
- **PRES-03 not implemented:** 6 heroes may still converge to the same authoritative positions; this cannot be fixed by cosmetic offsets. No collision/formation/gameplay changes authorised.

## One-click Windows handoff

- `tools/qa/RUN-C4-PRES01-WINDOWS.cmd` invokes `Verify-C4-PRES01-Windows.ps1` in a newly cloned, TEMP-isolated branch. It checks official Godot version, the exact observed HEAD (supports optional `-ExpectedSha`), six existing/new focused markers, immutable tracked-source status during the run and opens the real `combat_v4_jx_pilot.tscn` scene at 1280×720.
- Runtime script **created but not executed or validated in Windows** this session. If the launcher fails, report exact log; do not classify it as a Godot PASS.
- The school badges use source-confirmed opt-in loadout IDs (TL, VD, ND, NM); generic actual roles are distinctly marked, and each pilot actor also gets its stable numeric identifier. The body texture remains provisional `hero`; no false claim of six unique sourced animated bodies.

## 2026-10-19 — focused STATIC re-audit and corrective commits

Review base at start of this pass: `441f55198a89b9ebc810fd117a42d6a222cdb5f9`. GitHub branch comparison showed an exact match before edits. No new Windows QA logs were supplied and no official Godot 4.7.2 executable / PowerShell host is available in this runtime.

**Confirmed from V2 event producer and existing PRES-01 consumer:**

1. `MapBattleV2._release_casts()` emits `skill_hit` then `_deal_direct(...,"learned_skill")` emits `hit`. The earlier renderer restarted the original caster's attack on both resolution notifications, even though `skill_cast` had already started it. PRES-01 now triggers settlement-only basic and boss slam animations, not learned/pilot impact replays. Consecutive basic follow-up hits in one render tick deduplicate the same animation clock.
2. Previous `_draw()` projected source FX at the latest authoritative target or caster coordinate, while the body was drawn at `visual_position()` (0..0.25 seconds behind). FX cues now optionally bind by actor ID, resolve the same view-only interpolation at draw time and retain a stable fallback for deleted/unbound targets. Combat hit receipts remain unchanged.
3. Focused `c4_pres01_view_motion_readability_test.gd` now verifies the exact event-kind policy for `basic`/`basic_followup`/`area_slam` versus learned/pilot releases, and confirms bound FX follows the 50% interpolation point without altering battle authority. **Test code added, not executed on Godot.**
4. Windows TEMP runner hardening: version stdout/stderr handling, fail-closed parse/import diagnostics even when process exits zero, true `combat_v4_jx_pilot.tscn` headless smoke after six focused gates, compare tracked Git diffs both before and after QA even when checkout has pre-existing CRLF status, explicitly run 1280×720 and persist a compressed log bundle. Windows PowerShell and Godot runner **not executed here**.

**Contract unchanged:** no edit to V2 simulation, RNG, HP, target, snapshot, SAVE, economy, main/PR20; no new VFX/SFX binaries introduced. This change prevents a renderer-only double-action error; it is not PRES-02 or PRES-03.

**Current honesty gates:** GitHub source review/comparison is completed. GDScript official parse, actual test markers, headless 6v5 smoke, Windows 1280×720 screenshot/video, frame pacing/FPS, Android hardware and owner visual sign-off are all **PENDING**.

## 2026-10-19 — final pre-Windows PRES-01 source review

Owner requested a detailed second pass before physically running the computer. Starting SHA for this pass: `3337dadaadc815842c93925f0b98cfb29542dfe8`. The original C4 source architecture, authoritative `MapBattleV2.setup/step/_deal_direct/_begin_telegraphed_aoe/_release_casts`, the exact 6-v-5 pilot scene, atlas draw path, test contracts and PowerShell launcher were read again.

**Evidence-based render corrections made on the same PRES-01 branch:**

- HP and school/status tags now share a deterministic UI-only deconfliction pass **after** sprites/effect art so later-drawn sprites cannot obscure role text. The placement prefers original positions, alternates up/down if blocked, constrains labels/bars to the visible stage and does not offset a fighter, camera, hitbox, combat map transform or targeting. The crowded 11-label top-boundary case is asserted in the focused test. A 30-v-30 readability claim is explicitly NOT made.
- Actual `MapBattleV2` emits a Boss/elite `telegraph` event when a real red delayed AoE warning is created; `area_slam` `hit` happens only at release. The renderer now starts the boss attack cue and faces the warning center upon the real `telegraph`, suppressing a second post-impact attack replay. A genuine boss test fixture checks the pre-release cue, warning geometry and no post-release restart.
- The focused test now exercises a **genuine** V2 `ngu_kiem_thuat` cast `skill_cast -> skill_hit -> hit` (not merely the cue-policy helper), confirming no caster replay and one matching positive real-source hit FX.
- The focused test also loads and instantiates the **real** `combat_v4_jx_pilot.tscn` fixture and verifies 6 real disciples, 5 real monsters, enabled presentation and eleven attached V2 positions. The PowerShell launcher explicitly invokes Godot `--scene` for headless smoke and GUI and requires version prefix `4.7.2.stable.official` rather than accepting arbitrary/custom 4.7.2 builds.

**Audit limits:** Only static source read, GitHub branch/blob verification and delimiter/function-duplicate checks have been performed here. Static validation does not prove Godot grammar, shader/art import, actual test passes or Windows PowerShell execution. The Godot 4.7.2 executable and Windows runner are NOT present in this environment. All six focused markers, import, headless real scene, 1280x720 GUI, FPS, screenshot/video and owner UX remain **PENDING**. No QA ZIP/video from a Windows run was supplied for this pass.

**Known residual visual debts (not mislabelled as fixed):** all six disciples still share a provisional hero sprite, 6-v-5 authoritative foot positions may converge because PRES-03 collision/formation is not authorised; five JX skill source-matched projectile/VFX/SFX integration remains PRES-02 and rights-gated; dense 30-actor crowds and Android hardware frame rate require a separate physical test.

**After latest static review:** use the final HEAD of `c4-pres01-jx-motion-readability-20261019` in `RUN-C4-PRES01-WINDOWS.cmd -ExpectedSha <40-character SHA>`. The launcher creates an isolated TEMP checkout and archive (`C4_PRES01_QA_LOGS.zip`); leave the machine untouched until physical owner evidence is returned. No CI/FULL/merge.

## Test and evidence truth

- GitHub connector file read/write and source metadata checks: **completed**.
- SHA-256: **seven source-binary individual files verified from Drive**, not the whole archives.
- Godot 4.7.2 official parser / focused test: **PENDING**, no accessible executable in this session, no successful Godot import or runtime gate.
- Windows 1280×720 6 vs 5 screenshot, >10s recording, FPS: **PENDING USER / physical QA**, no generated footage or fake PASS.
- Owner UX: **NOT ACCEPTED**.
- No CI, FULL or merge attempted.

## Focused QA command (run from isolated working clone)

```powershell
godot --headless --path godot --editor --import
godot --headless --path godot -s res://tests/presentation/c4_pres01_view_motion_readability_test.gd
godot --headless --path godot -s res://tests/presentation/c4_vp01_source_vl_battle_visual_test.gd
godot --headless --path godot -s res://tests/presentation/combat_v4_world_layer_cast_schema_test.gd
godot --headless --path godot -s res://tests/simulation/c4_jx_pilot_effects_test.gd
```

Run Windows manually on `res://scenes/p3/combat_v4_jx_pilot.tscn` in 1280×720, using a temporary clone and isolated `APPDATA`/`LOCALAPPDATA`. No main/PR20/save changes. Verify event and 250ms sprite motion, every HP overlay, Boss, role tags and background. A test is PASS only on real exit 0 and correct success output.

## Acceptance boundary / immediate next step

1. Obtain official Godot 4.7.2 focused parse/test results on the exact PRES-01 branch and fix any parser/render regressions in this **presentation-only** file/test scope.
2. Run physical 6v5 sample at 1280×720 and deliver real still + 10s footage. Owner must explicitly accept UX; static analysis is not acceptance.
3. After that, separate PRES-02 source-linked projectile graph scope. Never import third-party JX media to shared repo until rights and checksums are clear.

**V2 AUTHORITY UNCHANGED; JX-STYLE PRESENTATION ADAPTER.**
