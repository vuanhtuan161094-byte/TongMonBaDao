# PVE-01B → PR #67 G0 — INTEGRATION HANDOFF (NO PR CODE WRITE)

**2026-11-03 · official Godot 4.7.2 · status READY FOR SINGLE-WRITER HANDOFF, NOT INTEGRATED**

## Exact upstream and ownership freeze

> **LIVE HEAD UPDATE:** 2026-11-03 05:50Z: PR #67 moved to `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567` while this handoff was being prepared. Commit modifies TRI-03 UI, Residence construction authority, icon atlas, map and visual tests, but **NOT** either PVE-01B backend file. Cherry-pick blob preflight remains byte-identical. Nevertheless, recheck HEAD immediately before actual integration; any additional PR edits invalidate the assumed scope. PR67 CI on that SHA at 05:51Z: **6 SUCCESS, 9 FAILURE, 1 IN_PROGRESS** — release gate OPEN. Failed old DV2-03 oracle is not yet in PR67; PVE01A test fix exists only on its own branch. O2/GP/O6 real selected-candidate picker regressions or stale locators require triage by TRI-03, not PVE01B backend writer. This new G0–G2 commit is NOT owner-accepted/playable based merely on its title.

- PR: [#67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67), branch `integration/tri-facility-a-b-playable-20261102`. **Latest observed HEAD `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567`**, feat(tri-03): G0–G2 New Game/facility flow, Draft/unmerged. Earlier handoff baseline HEAD was `c136600f5579871d476e0feca2d78ea3c74e6b1f`. Main `c0c1382f119599497b52d8ee8abd9e830a883f1e`.
- PVE QA baseline parent `3ea7916ffcc61bf5e561d5f1b1fe41cd10f9c7f1`; positive PVE-01B branch `feature/pve01b-v63-multicamp-gate-20261103`, clean code/test verified at `ca9fe45914cd9a479babeb32134f1c8f3a59d531`, final initial QA handoff `1dbf226fc09c2dfe65e0605e9845b47ac45ebdd9`.
- **One integration writer only** (TRI-03 / G0). P3.2 file stays exclusively with the original writer. No code was written to #67 or `main` by this handoff. GitHub has no way to prove that a separate local writer does not have unpushed edits: check working tree/locks immediately before adoption.
- The following two exact PR #67 file blobs **still match at new HEAD `36532c39...`** and at old HEAD `c136600f...`, also matching the PVE-01A pre-patch parent: `hunting_pve_run_v2.gd` = `882123cbf8e02ee37288bf90bd35caa07f568d12`; `simulation_runtime_clock_v2.gd` = `13a4ea0a8cbae2863c982495047e85643afb8a59`. The two code commits were created from that parent, each touching exactly ONE backend file.

## Cherry-pick packet — ONLY these TWO commits

1. `a10a1280744850d4bcb2c35d94b3bee60bec500e` — `godot/src/simulation/combat/hunting_pve_run_v2.gd`, **+6/-1**. Under `begin_multicamp()`, derive `V63FeatureGates.persisted_preview_overrides(state)` and pass it to canonical `begin(state,...,party_members,"",persisted_gates)`. This uses persisted *opt-in*, never hard-codes true, never gifts a skill, never alters the Boss start API.
2. `064d1e94148eb37590a5911b38fad13482facc03` — `godot/src/simulation/core/simulation_runtime_clock_v2.gd`, **+5/-1**. On `_advance_multicamp` cache miss / cross-process offline reload, pass `scheduler.v63_preview_overrides` to `HuntingPveRunV2.resume_active(state,encounter,...)`. RuntimeOwner already obtains these flags from the persisted save. Keep the existing one-clock authority.

**DO NOT cherry-pick the PVE01B HEAD or the PVE01A test fixes wholesale.** They include unrelated DV2-03/E3 tests, temporary-then-removed CI evidence commits and docs; two production commits are the minimal compatible packet.

Exact patch context:

```diff
--- a/godot/src/simulation/combat/hunting_pve_run_v2.gd
+++ b/godot/src/simulation/combat/hunting_pve_run_v2.gd
@@ begin_multicamp
-    var started := begin(state,PveMultiCampPopulationV1.ZONE,encounter_id,seed,party_members)
+    # PVE-01B: multicamp is started by the canonical owner, not a preview UI.
+    # Resolve opt-in from the persisted save itself, never an unsaved caller
+    # parameter or a globally enabled feature flag. Legacy/OFF stays OFF.
+    var persisted_gates := V63FeatureGates.persisted_preview_overrides(state)
+    var started := begin(state,PveMultiCampPopulationV1.ZONE,encounter_id,seed,
+        party_members,"",persisted_gates)
--- a/godot/src/simulation/core/simulation_runtime_clock_v2.gd
+++ b/godot/src/simulation/core/simulation_runtime_clock_v2.gd
@@ _advance_multicamp
-        var restored := HuntingPveRunV2.resume_active(state,encounter)
+        # PVE-01B: a cache miss (including fresh process/offline catch-up)
+        # must inherit the canonical runtime's persisted V6.3 opt-in. Passing
+        # the default empty overrides silently disables learned skills.
+        var restored := HuntingPveRunV2.resume_active(
+            state,encounter,scheduler.v63_preview_overrides)
```

**Instructions only after owner grants integration-code permission and TRI-03 writer confirms exclusive ownership, clean checkout and exact current PR HEAD.** Writer should fetch refs, verify both blob SHAs and current HEAD first; abort/rebase if any changed. Then do a no-commit dry run in the authorized isolated worktree:

```bash
git fetch origin integration/tri-facility-a-b-playable-20261102 feature/pve01b-v63-multicamp-gate-20261103
git switch integration/tri-facility-a-b-playable-20261102
git status --short
git rev-parse HEAD
git rev-parse HEAD:godot/src/simulation/combat/hunting_pve_run_v2.gd
git rev-parse HEAD:godot/src/simulation/core/simulation_runtime_clock_v2.gd
# STOP if HEAD/blobs differ, or status is not clean. No write without owner grant.
git cherry-pick -n a10a1280744850d4bcb2c35d94b3bee60bec500e 064d1e94148eb37590a5911b38fad13482facc03
git diff --cached --name-only
# MUST show exactly the two paths listed above. If not, abort and roll back.
# Run Godot focused/cumulative BEFORE an authorized commit/push.
```

For rollback in the separate QA worktree before commit: `git cherry-pick --abort` if cherry-pick conflicts and is still in progress; otherwise reset ONLY after verifying it is a disposable clean worktree and has no user edits. After an authorized integration commit, revert that one scoped integration commit; do not reset PR #67 or delete a user's save. Never merge `main`.

## Runtime evidence (already run on actual PVE-01B code blobs)

- [PVE01B 6v10, gate ON/OFF, real cast and damage, two Godot processes](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41583753724): official Godot `4.7.2.stable.official.ed1daf0bf`, focused **PASS**, child exit `0`. Six genuine V2 QA actors / ten Source A monsters, `v63_human` cast 1, hit 1, 28.562923552199 HP lost; cached and cold-cache clock, Save/Reload in second process, unchanged Warehouse, zero duplicate reward/settlement receipt. This is a 130-roster isolated QA save, NOT naturally recruited New Game.
- [DV2-03 clean-code, without temporary E3 subprocess adapter](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41584031672): **SUCCESS 31/31 GitHub job steps**.
- [P3.7 full cumulative, clean code](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41584031644): **SUCCESS** (last checked 2026-11-03, official Godot 4.7.2).
- [PR67 O2 recruitment/map exact HEAD](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41577153425): **SUCCESS, 25 job steps**; real O2 UI recruits TWO V2 disciples and verifies Save/Reload.
- [DV2-02 five-tier balance failure BEFORE PVE01B](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41494712439): **FAIL** at `dv2_02_five_level_balance_test.gd`, documented in PR #67 comments on 2026-11-02. The later [PVE01B DV2-02 run](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41582871417) fails at the same test; this is a **pre-existing baseline debt**, not proof of a new gate regression. Do not mark the entire DV2-02 workflow PASS or alter balance outside a separately approved packet.

## New Game → genuine V2 party: LEGAL ROUTE EXISTS, E2E UNPROVEN

Source authority on PR #67:
- `LiveGameRuntimeV2.start()` creates via `P37Factory`; six legacy founders stay unconverted. Godot PVE01A observed `initial_roster=6`, `naturally_ready_v2=0` after a real New Game startup. Never rewrite legacy founders or fake six new V2 births.
- `LiveGameRuntimeV2._configure_live_state` sets `disciple_v2_birth_enabled`. `RecruitmentSystem.accept_candidate` requires complete V2 birth profile, initializes BOTH Tu Vi and Body at 1/1, and reserves real Residence capacity. `DanTienScreenV2` UI routes to this authority; O2 real Godot proves 6/8→7/8→8/8 and capacity-full reject.
- `SectResidenceSystemV1` **at latest PR67 HEAD `36532c39`**: starter Residence Lv1 = 8 beds, Lv2 = 10, Lv3 = 12; **a second PAID Residence is now allowed at Hall Lv1** (`maximum_instances = min(10,max(2,1+floor((hall.level-1)/10)))`). Its newly authorized build cost is **40 Linh Mộc + 30 Thanh Thiết + 500 Linh Thạch**, with site/collision/doorway checks and actual construction ticks. A completed Lv1 annex adds 8 physical beds (total 16), but rank Nhân 1 enforces **12 total recruitable slots**. Therefore the legal route 6 founders → 6 real V2 recruits can use **one paid annex**, not necessarily two Lv upgrades. Alternatively, the original house can upgrade Lv1→2→3 (8→10→12 beds). Both require actual resources, stable receipts, and a real SaveService checkpoint; no synthetic `disciple_capacity`. Only 2 house instances are authorized at Hall Lv1 (third requires Hall Lv21), so unlimited free building remains NOT implemented.
- `BuildingSystem.start_upgrade` consumes actual `linh_moc`, `thanh_thiet`, `spirit_stones`, tracks work and an idempotent request receipt. Ordinary resource sources are Mine/Linh Lâm; no QA material injection may be counted as natural New Game economy.
- `RecruitmentSystem` has authentic Dẫn Tiên daily candidate arrivals and paid Chiêu Mộ Lệnh. Daily arrivals depend on simulation time and queue capacity; do not fabricate candidates/tokens. During PvE the chosen six V2 disciples must be healthy, in sect, uninjured, free of conflicting jobs/plots/Body training, then begin via the existing P3.2 picker.

**Required G0 acceptance test not yet run:** New Game fresh isolated save → obtain actual wood/ore/stones from authored sources → **build the now-available second Residence at Hall Lv1 and wait for construction to complete, OR upgrade Residence Lv1→2→3**, with exact paid receipts, site/door and Save/Reload → obtain and ACCEPT six legitimate V2 disciples through Dẫn Tiên (real daily arrivals or paid orders, reject if capacity full) → verify roster 12, 6 eligible V2 profiles with Tu Vi/Body and no active job → open P3.2 PvE selector → actual Source A hunt → save/exit/relaunch → verify one active hunt, six valid V2 actor IDs and no duplicate material/loot. No artificial candidate injections, resource grants or preset 130 roster allowed for *this* New Game acceptance. If it fails, record exact missing gate: resource economy, housing, daily arrivals, job contention, UI, combat or save. Do not call G0 PLAYABLE on static route alone.

**PVE party size semantics:** P3.2 **pilot UI currently demands exactly six for this button**, `HuntingPveRunV2.begin_multicamp` accepts 1–6 per party, `MapBattleV2.MAX_DISCIPLES=30` for a group/cluster. Six-v-ten is one authored demo configuration, NOT a global disciple cap or a promise of all PvE features. Increasing roster/party architecture requires a separate owner design/code contract, not covertly changing this patch.

## Adoption gate checklist (TRI-03, after explicit owner authorization)

1. Recheck live PR #67, Git diff, active single writer, no local overlap. Apply ONLY two commits above, reject any unexpected path.
2. Import Godot 4.7.2 and run focused DV2-03, V63 preview D8, 6v10 ON/OFF with **real cast & HP delta**, two-process Save/Reload, GP Injury, O2 recruitment/room, save exactly-once and P3.7 cumulative **on the adopted integration SHA**. If the PVE test is not added to the integration branch, run it from an isolated throwaway QA checkout/overlay, not by quietly contaminating the production PR.
3. Rerun/check pre-existing DV2-02 balance failure as baseline debt; never hide a new failure.
4. Require separate New Game→6 V2→PvE end-to-end user-facing 1280×720 test and native screenshots, not just endgame seed tests.
5. No schema migration needed, V6.3 default OFF, no invented loot/XP; 20 Source A zones and existing 6v10 pilot remain unchanged.
6. Physical Windows mouse input, human eye UI review and Android/touch **PENDING USER**. Don't report full playable G0/G1/G2 acceptance until these are proved.

**Integration permission:** NOT GRANTED by this handoff alone. This document is a file-scoped patch proposal and test contract, not an implementation change in PR #67.

## Latest PR #67 CI (new G0–G2 commit) — DELTA NOT ATTRIBUTABLE TO PVE01B

The integration writer pushed `36532c39f294e1eb56d73d8ce0c0eb7cb68c5567` after this handoff started. This commit touches Residence site/building and P3.2 UI but **neither** of the two PVE-01B runtime paths. At the first post-push CI poll, 16 checks: **6 SUCCESS, 9 FAILURE, 1 IN_PROGRESS**.

- [O2](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41586058619): FAIL in the attached TRI03 owner matrix at GP01/GP02A/O6 candidate picker exposure. The core O2 UI acceptance step is not by itself proof that all legacy GP locators are valid. TRI-03 must distinguish stale test node selectors from real user-facing inability to choose a candidate. This is NOT a new V6.3 backend failure.
- [DV2-03](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41586058476): FAIL old D7 oracle `Persistent Tu Vi/Body coordinates produced incorrect canonical combat stats`. This was fixed and proven in **PVE-01A independent branch**, not merged into PR67. TRI-03 should separately coordinate the test-only fix; the two production commits here do not address this.
- [O6](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41586058544) and [GP01](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41586058505) also fail the authentic B1 candidate picker condition.
- Economy/GP/O7 have additional failures; their full causal classification is **NOT_TESTED**. Do not label full G0/G1/G2 or PR67 CI PASS.
- P3.7 cumulative on the **independent PVE01B feature code** remains SUCCESS as already documented; it does not substitute for exact-SHA cumulative on the new PR67 head.

**Ownership action:** TRI-03 must retain P3.2/Residence/G0-G2 ownership. Coordinate the two PVE backend commits only after owner authorizes PR67 CODE and verifies no new overlapping unpushed writer edits. Use the fresh current PR HEAD rather than blindly requiring c136600f as checkout HEAD; check **blob identity** and three-way cherry-pick compatibility. No integration action has been performed by this handoff.
