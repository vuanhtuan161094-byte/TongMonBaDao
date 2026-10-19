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
