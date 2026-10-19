# C4-EP01 — JX1 combat effect consumers, focused integration packet

Date: 2026-10-19. **STATUS: CODE COMMITTED / STATIC CHECKED / GODOT RUNTIME PENDING / OWNER UX PENDING.**
Baseline: C4-VP01 head `b2965d951f8490286c6f75ab3694ab16f02e1446`, separate branch `c4-pilot04-jx-effects-20261019`.
No merge, no CI, no FULL tests, no changes to main, PR20, Economy, SaveService, or production player-skill ownership.

## What is actually implemented

- New `godot/src/simulation/combat/jx_pilot_skills_v1.gd`: data-backed, source-referenced **five** pilot skills only: Thiếu Lâm #15 Bất Động Minh Vương, Võ Đang #158 Kiếm Phi Kinh Thiên, Võ Đang #159 Thất Tinh Trận, Ngũ Độc #63 Độc Sa Chưởng, Nga Mi #93 Từ Hàng Phổ Độ. Exact game-authored baseline follows `COMBAT_V4_FOUR_SCHOOLS_PILOT_LOCK_AND_MULTI_ROOT_CONTRACT_2026-10-19.md` on earlier docs branch.
- New `godot/src/simulation/combat/jx_pilot_runtime_v1.gd`: opt-in pilot cast queue with deterministic tick times, moving projectile *impact delay* based on locked target distance at launch, single actual impact per authorized packet, same-party DEF buff, short personal guard, per-caster poison DoT, single-family ally HoT.
- Small additive hooks in `map_battle_v2.gd`: optional setup payload `pilot_skill_loadout`, `spiritual_root_values`; statuses on actor dictionaries, priority earlier than role-granted free heal/guard; reserved cast branch and status tick; root-magnitude only for explicitly provided actor pilot root snapshot; primary element optional on monster.
- Pending cast IDs + persisted status tick source provenance `cast_id / pilot_id / caster / target`; no animation, random frame, UI visibility or SFX controls gameplay.
- Existing `MapBattleSnapshotV2` saves actors/queues using lossless Variant payload. The new effect state is primitive dictionaries nested under already persisted actors and casts, hence no SaveService or snapshot version edit; **this is an inferred compatibility contract pending actual Godot replay tests**.
- `godot/tests/simulation/c4_jx_pilot_effects_test.gd`: admission invalid IDs, root/math, four-school cast events, actual HoT and poison ticks, same-target global cap 3 across four poison casters, same-party aura isolation, mid-battle JSON Variant snapshot replay, visible/hidden determinism, observational 6-disciple vs 4-monster/boss 8-seed benchmark.
- No other 11 of the 16 proposed active skills are implemented. No 4 × 6 complete passive catalog, no AI build editor, no school teaching/unlock, no learned-skill bridging into player production `DiscipleCombatLoadoutV2`. This packet deliberately does **not** grant free powers just by choosing school.
- No external JX WebP/WAV/MP3 asset copied into this patch. Pilot spell visual mapping still requires C4-VP01 event adapter/metadata, and Source A actor true cast animation matching. VFX is NOT a condition for status truth.

## Gameplay invariants of the pilot

1. 0.25s authoritative tick; cast0.50s =2 ticks; projectile travel quantized up by 0.25s; independent of map camera, FPS and Source JX `ms` frame timing.
2. Root matching: matching root `P` and perfected root count `N` amplify skill's eligible numerical magnitude only, `1 + 0.003 * P * Resonance[N]`. **Does not** apply permanent root stat buffs to an actor at setup; those belong to a later correct `DiscipleCombatLoadoutV2` integration. Input absent => no synthetic root bonus.
3. Source JX faction label != gameplay skill element. Pilot #158 ordinary Thổ-tagged projectile, JX-origin lightning animation not enough to fire Dị Căn Thiên Lôi. Skill element against monster `primary_element` uses Root V2 ×1.25/×0.85/×1.0; explicit target resistances still count.
4. Poison: 85% base application chance + EffectHit - EffectResistance; three global stacks max per target, one `#63` stack per caster, refresh identical identity; exactly three 1s spaced DoT packets of 0.12 × captured ATK, cannot crit or lifesteal; no proc loop.
5. HoT: #93 chooses lowest-HP% living and in-range ally of exact party under70% HP with no existing same-family HoT, 0.40 × snapshotted ATK at t+1/t+2/t+3, caps actual healed HP and never revives.
6. Party DEF: #159 +10% target DEF for 6s (at cast commit), same-party within5 arena units, no other party affected; **source JX accuracy add omitted** because V2 has no headline Accuracy.
7. Guard: #15 personal remaining-damage ×0.75 for 3s only when below70% HP; no automatic taunt or hidden Threat.
8. Explicit learned-skill authority is **NOT** bypassed for ordinary production: this opt-in setup field is for focused pilot actors, not automatically installed by `DiscipleCombatLoadoutV2`. Need future code authorization for true skill teaching/ownership integration.
9. Existing non-pilot actors never lose legacy role heal/guard. Pilot actor with a non-empty pilot loadout does not gain those role abilities free in addition.
10. Expiry, cooldown, hit, cast and status ordering are battle-authoritative; actor state snapshots contain effects; only test runtime can prove absence of Godot parse/restore issues.

## 2026-10-19 — USER-AUTHORIZED QA CONTINUATION / HONEST RUNTIME STATUS

The owner explicitly authorized official Godot 4.7.2 isolated import + **exactly three focused tests**, one 1280×720 visual battle and a six-person benchmark; repair only evidence-backed bugs; no CI/FULL/merge, main/PR20/Economy/Save untouched.

**Environment evidence:** inspected Linux runner environment: no `godot` executable in PATH or local tool locations; no Windows/PowerShell; `git ls-remote` and `curl` GitHub release both failed **Could not resolve host: github.com**. Consequently NO Godot 4.7.2 import, parser test, headless combat, manual 1280×720 capture or actual eight-seed runtime measurements ran. **ALL RUNTIME GATES REMAIN PENDING**, including Windows and Android. GitHub connector code reads/writes succeeded, but do not mistake commits for runtime PASS.

### Proof-driven repairs in this follow-up

- **Missing canonical monster element:** `MonsterCatalogueV2.create_actor` returns `element`, while `MapBattleV2.setup` previously accepted only `primary_element`; ordinary monsters thus became empty-element and pilot attacks always used neutral matchup. Corrected default `primary_element = row.get("primary_element",row.get("element",""))`. Explicit monster primary overrides still work. Added test for a real `truc_thu` canonical wood element; baseline non-pilot damage remains unaffected.
- **Duplicate death event on lethal same-tick Poison stacks:** `JxPilotRuntimeV1.tick` previously processed all poison effects despite target HP reaching zero from the first due stack, repeatedly emitting `downed`. Break processing immediately when target HP is zero; added focused setup 4 poison casters, global cap 3 and assert exactly **one** `downed` receipt when 3 stacks are due at once. Does not modify reward/SaveService.
- **Pilot events invisible to V4 map view:** `MapBattleWorldLayerV2._ingest_authority_events` previously handled `skill_cast` and `skill_hit`, not `pilot_cast` or `pilot_impact`. Added read-only pilot cast and real-damage impact cues in V4 view. Does NOT substitute an unrelated sword VFX for JX skill art or affect battle RNG.
- **Manual QA scene prepared:** `res://scenes/p3/combat_v4_jx_pilot.tscn` with separate `combat_v4_jx_pilot.gd`; 6 fixture disciples across the 4 schools, 5 real wolves including boss (faster visual coverage), 1280×720 inherited Godot project viewport, counters for cast/hit/poison/HoT, replay button; no player save/recruitment/loot/ownership modifications. **Scene import / visible frame PENDING**; do not call it a screenshot or completed manual battle.
- **Multi-root/five-element checks expanded:** all five counter relations and reverse, full-root resonance, independently owned earth root, and canonical monster element preservation; tests written but not run.
- **QA launcher prepared:** `tools/qa/Verify-C4-EP01-Windows.cmd` -> `.ps1`, isolated fresh TEMP clone, isolated `APPDATA/LOCALAPPDATA`, official Godot 4.7.2 version gate, branch commit log and optional `-ExpectedSha` branch drift guard, import and only three focused test scripts with explicit PASS markers. Optional `-OpenVisual` opens isolated manual scene; owner must still review actual output. No automatic CI/FULL/merge/production sync. **The launcher itself has not been run on Windows.**

**Outstanding risks:** GDScript parser unresolved until official import, event fidelity visually unresolved, effect/boss balance not measured, full 16 skills and skill ownership integration outside this QA packet. Existing monster visual art can be fallback; source-specific JX skill FX assets not mapped in this packet.

### Exact execution (when official Windows machine is available)

From the **branch's** checked-out `tools/qa` folder run `Verify-C4-EP01-Windows.cmd` with Godot 4.7.2 available in PATH/Downloads or pass the executable:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/qa/Verify-C4-EP01-Windows.ps1 -GodotExe "C:\\Path\\Godot_v4.7.2-stable_win64_console.exe" -OpenVisual
```

The launcher clones the specified branch into a *separate* TEMP location and prints the EXACT commit SHA in `SUMMARY.txt`; if the owner wants an exact immutable SHA, additionally pass `-ExpectedSha <40-character SHA>`. Preserve `SUMMARY.txt`, `logs/01_import.log` through `logs/04_group.log`, the `C4-JX-PILOT BENCHMARK` line and screenshot/screen recording of manual scene. A successful runner exit does not certify the manual visual frame; owner visual acceptance remains PENDING. No local original clone, untracked files, or player save should be changed.

**No permission implied to merge/main/PR20/Economy/Save, run FULL/CI or unlock extra 11 pilot skills.**

---

## Focused QA instructions, isolated TEMP clone and save

Use official Godot **4.7.2 stable**. Never run from the owner's live game workspace/save. Checkout exact branch HEAD into a *fresh clone under TEMP*, redirect Godot user data to an isolated TEMP location and check clean working tree before/after. Do not download untrusted executable assets from the JX Drive.

Run **only** these focused tests, no CI/FULL:
```powershell
# In isolated Godot project folder (`godot/`) in TEMP clone.
# Use the local official Godot 4.7.2 executable:
& $Godot --headless --path . --editor --import
& $Godot --headless --path . --script res://tests/simulation/c4_jx_pilot_effects_test.gd
& $Godot --headless --path . --script res://tests/simulation/dv2_02_battle_snapshot_test.gd
& $Godot --headless --path . --script res://tests/simulation/dv2_02_group_map_battle_test.gd
```
A single manual 1280×720 combat scene playthrough to verify visual cast/projectile/impact/HP/telegraph consistency ONLY after these focused tests; Android FPS/memory & owner acceptance separately PENDING.

**Pass standard:** Godot logs report the new C4-JX-PILOT test PASS, old DV2-02 snapshot and group map PASS, no parse errors, no status double ticks on save/reload; static grep or code review does not equal runtime success.

### Findings and known limitations

- **Machine environment currently has no Godot runner.** Import, GDScript parse, runtime game scene, Windows and Android all PENDING. 6-person benchmark test is authored but its measured win/time/downed outputs are PENDING; do not invent win rate.
- The code has been mechanically checked for balanced delimiters, tabs, required hooks/catalog entries, and source diff scope, **not compiled**. Tests are authored but unexecuted.
- For visual authenticity, source-vintage assets have copyright/provenance constraints distinct from user's project usage authorization. Their mapping/import is not part of this patch.
- Next authorized stage: run QA first, repair only proven errors; then production learning/ownership bridge, root source contributions, VFX event adapter, and complete 16 skills **in staged packages**, not as implicit scope in EP01.
