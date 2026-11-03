# PVE-01B — V6.3 MULTICAMP GATE, TEST-FIRST CLOSED-LOOP EVIDENCE

Date: 2026-11-03 (Asia/Bangkok). Engine: Godot 4.7.2 official. Status: focused GREEN, cumulative tracked separately.

## Source identities and writer isolation

- Repository: \`vuanhtuan161094-byte/TongMonBaDao\`.
- PR #67 live original HEAD: \`c136600f5579871d476e0feca2d78ea3c74e6b1f\`, Draft/unmerged, integration writer owns P3.2.
- \`main\`: \`c0c1382f119599497b52d8ee8abd9e830a883f1e\`, untouched.
- Forked test-first baseline: \`feature/pve01a-dv203-test-first-20261103\` @ \`3ea7916ffcc61bf5e561d5f1b1fe41cd10f9c7f1\`.
- Separate implementation branch: \`feature/pve01b-v63-multicamp-gate-20261103\`.
- **Runtime write allowlist only**:
  - \`godot/src/simulation/combat/hunting_pve_run_v2.gd\`;
  - \`godot/src/simulation/core/simulation_runtime_clock_v2.gd\`.
- **QA changes**: \`godot/tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd\` (previously deliberate RED; now reusable positive regression) and \`docs/qa/PVE01B_V63_MULTICAMP_GATE_20261103.md\` (evidence).
- No P3.2, SaveService, CombatStatsV2, balance, state/schema, loot, economics, source assets, telemetry or PR/main edits. No repository merge. Exact runtime blobs were identical between PR #67 and PVE-01A at start (HuntingPveRunV2 blob \`882123cbf8e02ee37288bf90bd35caa07f568d12\`, clock blob \`13a4ea0a8cbae2863c982495047e85643afb8a59\`). Unpushed local writer state is unknowable from GitHub; do not cherry-pick into PR #67 without an ownership recheck.

## Root causes and code diff

1. \`HuntingPveRunV2.begin_multicamp(owner,...)\` called \`begin(state,...,party_members)\` without the V63 overrides; \`begin\` defaulted to \`{}\`, disabling learned V6.3 actor skills despite both persisted opt-in bits. Fix: read \`V63FeatureGates.persisted_preview_overrides(state)\` from canonical owner state and pass it as the final argument to \`begin\`. No API signature change and no gate flip when opted OUT.
2. \`SimulationRuntimeClockV2._advance_multicamp\` rehydrated a cold-cache battle with \`HuntingPveRunV2.resume_active(state, encounter)\` and default \`{}\`. Fix: pass \`scheduler.v63_preview_overrides\`, already initialized by canonical runtime owner from saved opt-in. Saved and in-memory V63 session gates now match across actual process reload/offline catch-up.
3. Optimization preserved: \`HuntingPveRunV2._advance_open_world\` avoids serializing full 192×192 battle snapshots on every 0.25s movement/damage frame. Initial test incorrectly compared *uncheckpointed persisted* \`battle.now\` immediately after polling; corrected test compares the cached live session, invokes \`runtime.save()\` (which flushes \`_checkpoint_active_multicamp_snapshot\`), then loads/verifies the durable snapshot. **No extra engine checkpointing or telemetry added**.

## Official Godot runtime evidence (actual child processes)

**Authoritative positive CI run with temporary QA adapter present:** https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/41583753724 on commit \`bac70d499bfe61f370ac1955b8aed88de970a9ed\`. Job 125744307761: \`success\`, all 31 DV2-03 job steps passed, Godot \`4.7.2.stable.official.ed1daf0bf\`.

- \`PVE01B_V63_GATE_OFF_PASS\`: opted out but equipped skill preserved, actor V63 disabled, cached scheduler tick still OFF.
- \`PVE01A_6V10_BASELINE_PASS\`: authentic Source A \`sect_isometric_source_a_pve_v1\`, map SHA \`c0e6b9952ce6303718938f5705a0327d0a14b136\`, six legal V2 QA-roster disciples, ten live monsters.
- \`PVE01B_V63_ACTUAL_SKILL_DAMAGE_PASS\`: **one V6.3 skill cast, one positive hit, 28.562923552199 HP loss**, after 3 real MapBattleV2 frames on an independent, authentic World battle snapshot. No injected damage, no synthetic loot.
- Parent initiated another **real operating-system Godot executable** with \`--headless --path ... -s ... -- process2\`. Child process exited **0**. \`PVE01B_PROCESS2_RELOAD_CLOCK_EXACT_ONCE_PASS\`: cold-cache battle clock advanced from 1.0s to 2.0s across 4 legitimate frames, 1 active run, V6.3 actor enabled and equipped, zero pending reward claims and zero terminal settlement receipts, warehouse unchanged; SaveService committed exact battle snapshot.
- \`PVE01B_V63_6V10_GATE_PASS\`: ON, OFF, 6v10, real cast/HP delta, cached/cold clock, true second process, no duplicate reward/settlement, parent disk recheck.
- The temporary CI runner in \`godot/tests/presentation/dv2_03_p3_body_training_building_ui_test.gd\` was **removed** at \`ca9fe45914cd9a479babeb32134f1c8f3a59d531\`; the restored E3 file blob \`3a5f7a1899021129138d7f9f8fb187906e8eca0f\` is byte-identical to the PVE-01A baseline. E3 is never permanently coupled to PvE.
- Final-clean DV2-03 and P3.7 cumulative workflow results should be read from the exact code SHA \`ca9fe45914cd9a479babeb32134f1c8f3a59d531\`; do not infer them from the temporary runner commit. Official CI on clean code verifies parse/standard DV2 regression; the standalone PvE gate was executed and logged on the exact gameplay/test source blobs in the adapter commit.

**Debugging history:** prior official run 41583202241 proved OFF, 6v10, positive skill HP delta but child failed a wrong time oracle; run 41583489787 printed \`frames_run:4, actor_enabled:true, after_time:1.0, before_time:1.0, warehouse_equal:true\`. That is intentional lightweight snapshot lag, not a gameplay bug. Corrected by explicit SaveService checkpoint before rehydrating.

## Boundaries and acceptance

**Focused GREEN:** V6.3 persisted opt-in starts with equipped skill, OFF remains OFF, real skill cast and HP damage, two-process Save/Reload, shared simulation clock resume, no extra warehouse claims or settlement receipts in the tested 2-second interval.

**Not certified by this packet:** full gameplay New Game→six recruited V2 hunters, full AI long-duration rotation, long-horizon resource/loot economy, boss/elite content, performance, 1280×720 physical Windows GUI, Android. New Game still has six legacy founders and \`0\` naturally V2-ready at startup (explicit test observation); it is misleading to claim immediate PvE usability. Normal monster loot remains PVE-00 \`LOOT_PENDING\`; not changed here.

**Save migration:** None. Schema and saved encounter snapshot format unchanged, opt-in flags already persisted via SectState. Legacy/opt-out save remains V6.3 disabled. No player-saved data changed by the isolated QA profile.

**Rollback:** revert the two isolated runtime commits and updated PVE-01A test on this feature branch, or abandon the entire branch (parent stays at \`3ea7916...\`). No cherry-picks/merges into PR #67 or main by this packet. TRI-03 retains exclusive P3.2 writer rights. Physical Windows/Android: \`PENDING USER\`. If integration owner adopts this patch, rebase/cherry-pick with explicit ownership check and rerun exact-SHA Godot gates.

## Commands for future focused rerun

\`\`\`bash
godot --headless --path godot --editor --quit
godot --headless --path godot -s res://tests/simulation/dv2_03_realm_body_progress_test.gd
godot --headless --path godot -s res://tests/simulation/pve_01a_6v10_v63_gate_contract_test.gd
godot --headless --path godot -s res://tests/simulation/pve_save_return_reload_exactly_once_test.gd
godot --headless --path godot -s res://tests/simulation/v63_d8_preview_resume_gate_test.gd
\`\`\`
Do not run a physical Windows or Android assertion on a headless Linux runner.
