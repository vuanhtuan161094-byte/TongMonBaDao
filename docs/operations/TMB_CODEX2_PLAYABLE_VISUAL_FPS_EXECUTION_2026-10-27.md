# CODEX 2 — PLAYABLE / SOURCE A VISUAL / JX VFX / FPS (2026-10-27)

**Mission mode: GUI/PRESENTATION CODE + VERIFIED ASSET QA + ACTUAL WINDOWS PLAYABILITY, NOT GAMEPLAY REWRITE.** You are **SOLE WRITER** for presentation, VFX, camera/UI, FPS/launch tools. Codex 1 handles SaveService, clock, MapBattleV2 movement/formation, world-zone simulation and Injury120. Do **not** edit their files, even if your visible symptom seems caused by them: reproduce with precise logs and post issue.

## Authority, input evidence, and branch provenance

Read GitHub Issue #37, #43 and Draft PR [#44](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/44), the latest Codex PvE handoff on active branch, `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, and:
- `docs/operations/TMB_WHOLE_PROJECT_AUDIT_2026-10-27.md` and `docs/operations/TMB_2026-10-27_ONE_SESSION_WINDOWS_EXECUTION.md` on `audit/tmb-whole-project-readiness-20261027`;
- `docs/handoffs/2026-10-27/TMB_PVE_AUX03_VFX_PROVENANCE_AND_EVENT_QA_2026-10-27.md` on `qa/pve-aux03-vfx-provenance-20261027`;
- `godot/data/presentation/pve_aux03_vfx_asset_manifest_v1.json` on that AUX-03 branch;
- `godot/tests/presentation/pve_jx_sword_vfx_adapter_test.gd`, normal P3.2 scene and source files.

Audit 2026-10-27 refs; **re-resolve live heads at start**:
- active `feature/pve-jx-continuous-world-20261026` `6b3fd181392c96c2386e5aa85950d2e993d67dda` (game/test implementation at `7c79a7740938e4a5852234fa3826850db902b167`);
- AUX-03 Draft PR #44 `89d1061770c87858b76b7f940d2c35fae75edf56`;
- audit candidate `audit/tmb-whole-project-readiness-20261027` `d2adf282cbfb4ec362f565c2c7d42de4009bb6df`;
- Codex 1's future candidate is *separate* and must not be overwritten.

**Known proven vs pending:** verified JX #158 three sheet SHA + 10/17/8 frames = 35 legal rect/anchors with max centre error 0.5 px. Unity AnimationClip/Texture2D from owner's authorized E: game source exists, hash/timing recorded; claimed cast/projectile/impact roles remain **candidates**, not prefab/skill bindings. 4 unrelated CRLF-only changes in old AUX-03 worktree were intentionally not staged. No actual Godot runtime test ran for AUX-03 due to nine Godot processes found. P3.2 integration on `7c79a77` had 6 real V2 vs 10 real monsters, 79 s, 9 kills and active Save/Load under controlled simulation; **not proven physical mouse, zone-hop, Injury120, real GUI screenshot or FPS 1%-low**. `PLAYABLE_BLOCKED` remains accurate.

## Worktree ownership & serial engine slot

1. Before edits: `git status --porcelain=v1`, `git worktree list --porcelain`, compare GitHub live SHAs, official `godot --version`, check Godot process ownership. Do not modify, close, clean, reset, move or delete Codex 1's files/worktrees, any existing player save, game-related E: source masters or foreign Godot process. 8 GB Windows may contain old Godot sessions; inventory all of them without assuming that an old process is yours.
2. Create own isolated worktree and branch from latest active PvE feature, named `recovery/pve-playable-visual-a1-20261027` (if collision add suffix). Never commit directly to `main`, current live feature or AUX-03's old branch.
3. Exclusive writable code: `godot/src/presentation/p3_2_landscape_sect.gd`, `godot/src/presentation/p3/pve_sect_world_view_v1.gd`, `godot/src/presentation/p3/sect_isometric_world_v1.gd`, `godot/src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd`, `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd`, bounded `godot/tests/presentation/*` **EXCEPT** imported AUX-02 world-input contract (Codex 1 owns its QA changes), `Run-PVE-FPS-QA.cmd`, `Run-PVE-Play.cmd`, `godot/tools/qa/pve_playable_perf_*.gd`, Source A/JX provenance JSON/manifest/tests, docs under `docs/qa` / `docs/operations`. Any asset addition must have a verified manifest/source right and hash; no rewrites of rendering engine or generated false art.
4. Forbidden code: `godot/src/simulation/save/save_service.gd`, `simulation_runtime_owner_v2.gd`, `godot/src/simulation/combat/map_battle_v2.gd`, `hunting_pve_run_v2.gd`, simulation and warehouse/equipment/gameplay changes, damage/skills numerical rules, Injury120/HP0 reward semantics. Report backend symptoms to Issue #37 as `CODEX2_BACKEND_BLOCKER` with exact screenshot/event trace for Codex 1. Never merge their candidate PR yourself.
5. **Engine seriality:** Codex 1 owns the Windows Godot QA slot first. While it runs, do only read-only source audits, path checks, manifests and isolated presentation code review. Begin your official headless or GUI tests only after reading **`CODEX1_GODOT_QA_RELEASE` on Issue #37** and checking no conflicting Godot GUI/process. Do not wait silently/indefinitely or launch nine more Godot processes: if no release, finish code/static work and mark your runtime tests `PENDING_ENGINE_SLOT`.

## B1 / AUX-03 completion: verify event VFX, not just geometry

Port selectively the tested AUX-03 manifest and relevant `pve_jx_sword_vfx_adapter_test.gd` from PR #44 into own branch, reviewing diff against current source. Inspect the three verified JX #158 sheets, source SHA, 10/17/8 = 35 source regions, atlas bounds and timing. Validate `cast → projectile → positive authoritative hit → impact` once per actual Combat V2 event. Save/Restore/Return must **not replay old VFX**, deal cosmetic duplicate damage or create phantom outcomes. No impact if a skill never hit; verify death animation behavior is idempotent. Existing VFX tests should not replace Combat V2 event receipts. Separate:
- verified fact from manifest/hash/rectangle;
- plausible Unity clip/texture candidate from E:;
- unproved prefab/pivot/caster/skill-ID mapping (label UNKNOWN; do not infer from filename).
Do not bulk convert all Unity Source A clips, embed rights-sensitive APK files in Git or retouch Source A master assets merely to force a visual PASS. A tiny in-engine preview may be added only using already-verified, permitted derivative sprites; show what users can actually see and avoid VFX hiding characters.

## B2 / Game discovery, click, camera and actual 1280×720 UI

Open **normal** `Run-PVE-Play.cmd` from an isolated worktree/save and ensure `Săn quái / Thanh Trúc Lâm` entry is readily found from the Sect main screen, party selector gives 6 *actual* V2 idle/healthy members, enter shows the original Source A forest (expanded 192×192) with readable actors/HP/level/target feedback, pan/zoom/minimap and command cues. Do not fake movement, kill notifications, worksite progress or rewards. Preserve approved Source A look and beautiful production map, no procedural redraw/renderer rewrite.
- Correct visibly proven UI-only issues: overlap/contrast/too-large controls, unreadable badges, camera edge/offset, VFX occluding actor, excessive refresh/UI invalidation. Preserve production worksite progress, ETA, receipts and selected actor gating.
- Test selection/camera in P3.2 1280×720 landscape, then at mobile-layout touch target constraints without claiming Android real device acceptance.
- If physical input or screenshot capture is possible through supported Windows UI, use real mouse/click and saved screen evidence; otherwise explicitly document `MANUAL_MOUSE_PENDING` / `SCREEN_CAPTURE_BLOCKED` and provide exact owner-visible steps rather than inventing a screenshot. A Godot injected pointer test != physical mouse.

## B3 / Measured FPS: classify and correct only proven bottlenecks

Review the audit branch's specific `Run-PVE-FPS-QA.cmd` correction: original script computed timestamped `TMB_LOG` but erroneously passed fixed `normal_gui_<logmode>.godot.log`. Apply **only** its tiny timestamped log + fail-closed exact-SHA change to your branch. Keep a fresh *isolated* save per run, no player progress overwritten. Compare two runs on the **same exact tested SHA**, profiler OFF and /log ON, with one GUI at a time:
```bat
Run-PVE-FPS-QA.cmd
Run-PVE-FPS-QA.cmd /log
```
Set official Godot 4.7.2 console via `TMB_GODOT` if default E: path differs; check successful startup and explicit window process exit. Walk actual phases: 15 s production; open party select; choose six; 30–60 s PvE at a reproducible camp, camera/commands; Save and Return; inspect final Sect after return. Don't compare FPS for different states unknowingly. Explicitly record whether identical fresh saves/inputs were achieved.

Gather JSONL in `godot/outputs/pve_perf_qa_20261026/metrics/`, engine logs, renderer/GPU, node/draw count, RAM/video peak, real per-phase `frame_gaps_ms` and compute P50/P95/P99, max and 1%-low FPS; list top frame spikes with event times. Don't average 3-second percentiles across windows and don't calculate actual GUI performance from MovieWriter. Old observed 59.29 avg FPS could coexist with 149.7ms worst hitch. Only optimize code if actual profile attributes spikes to presentation; simulation/nav/SaveService stall belongs to Codex 1 (report trace, not patch it). If smoothing regresses Combat V2 snapshot identity or Source A actor animation, revert and mark FAIL.

## B4 / Exact QA + owner-ready artifact

After CODEX1_GODOT_QA_RELEASE, run:
- `godot/tests/presentation/pve_jx_sword_vfx_adapter_test.gd` from adopted AUX-03;
- `pve_sourcea_death_snapshot_contract_test.gd`;
- `pve_multicamp_p3_2_live_integration_test.gd`;
- `pve_perf_probe_contract_test.gd`;
- `b3_care_combat_v5_presenter_test.gd`;
- the needed P3.2 Source A UI and camera focused tests.
All on **your exact head SHA**, official Godot 4.7.2; preserve exit codes and engine logs for every suite. When prior failure is from backend pending Codex 1, label `BACKEND_DEPENDENCY_PENDING` rather than silently replacing V2 battle. **No GUI/visual FULL PASS without authentic physical input/capture.**

Commit/push on your own branch; make ONE Draft PR **targeting latest PvE feature**, no `main` merge. PR body: precise Source A/JX frame provenance, which effects verified vs candidates, tested UX/FPS before/after (or PENDING), any 6-person GUI screenshot/video on real runtime, SHA/log links and diffs. Reference #37, #43, #44, and Codex 1's candidate by URL only. Update Issue #37, #43, and log `CODEX2_GUI_QA_RELEASE`.

**Exit contract:** either (i) credible real PvE click/select/visual/FPS/Save-Return with specific proven fixes and clean focused gates, plus AUX-03 provenance/event verification; OR (ii) explicit blocked captures/asset binding gaps/FPS regressions/engine unavailable with exact reproduction. No invented clip mappings, bogus art, false runtime scores, main merge or deletion. Your final answer to owner must be concise Vietnamese table: SOURCE A, JX VFX, UI, REAL MOUSE, FPS OFF/ON, P3.2 SAVE-RETURN, ANDROID, with PASS/FAIL/PENDING, exact SHA and PR URL.
