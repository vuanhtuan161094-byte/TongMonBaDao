# V63-G1B — Real PvE mastery receipt / Root V2 official QA evidence
Date: 2026-11-11. Issue #76. Draft PR #72, ONLY branch `integration/pve-p0-playable-ui-20261103`.

## Audited code SHA and official runner

- **Exact tested code SHA:** `ed813ab157fd8c814f8d6b88ebf46aa69b6a58f2`.
- **GitHub Actions** [run #42960950171](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960950171), job `130327084154`, **conclusion SUCCESS** on that SHA.
- Official Godot **4.7.2.stable.official.ed1daf0bf**; Linux package ZIP SHA-256 `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`, pinned in `.github/workflows/v63-g1b-root-mastery.yml`. Project assets restored using pre-existing hashed QA pack, not fake VFX.
- Repo does not have independent access to owner's Windows/Android physical test here: **Windows 1280×720 / Android / user visual: PENDING USER**. `SaveService` disk write/read was tested in the same Godot process with isolated `user://`; independent cold *process* restart / power-loss remains **PENDING**.

## Verified runtime repair

Source defect: `HuntingPveRunV2.begin()` detaches `DiscipleState` intentionally; old `V63HumanSkillCombatSystem.record_cast_mastery()` returned false for null `linked_disciple`, so real PvE skill casts could deal damage but not commit cast mastery. Never rebind battle to live personal state.

- Added `V63PveMasteryReceipts` to queue only meaningful, learned/equipped skill cast receipts on a detached actor with deterministic encounter/actor/sequence ID and bounded root XP snapshot. The action is preserved by the existing `MapBattleSnapshotV2` actor payload.
- `HuntingPveRunV2._persist_live_state()` and `_settle_terminal()` preflight all receipts then atomically settle to the canonical `DiscipleState.v63_learned_skill_nodes` with exactly-once `mastery_cast_receipts`. Existing PvE checkpoint and SaveService persist both together; duplicate snapshot replays have zero extra EXP. Invalid event/provenance fails before mutation.
- No SaveService change, no direct battle-to-persistent HP link, no new branch/merge, no gameplay economy/Warehouse edits.
- Root matching still preview gated OFF; `_root_scaled_passive_modifiers` now affects only authored effect magnitude (outgoing/poison/healing/guard) and does NOT automatically scale crit, cast speed, attack speed, lifesteal or cooldown-recovery passives. Nonzero source passives tested explicitly.
- Actual monster elemental `primary_element` is asserted against `MonsterCatalogueV2.SPECIES[*].element` in the real HuntingPveRunV2 encounter. No invented elemental source. Base-element counter relationships retain 1.25 / 0.85 / 1.0 behind OFF preview. Lôi/Phong/Băng/Dương/U Minh are not implicitly aliased to base roots.

## Focused and cumulative exact-SHA results

| Step | Official log result |
|---|---|
| Official Godot project import and changed script parse | PASS / exit 0 |
| `v63_g1b_pve_mastery_receipt_test.gd` | **52 checks, zero failures**, authentic PvE cast/owner settlement, cold disk SaveService roundtrip in isolated `user://`, stale replay, malformed receipt rejection, genuine monster element |
| `v63_root_v2_runtime_test.gd` | **233 checks, zero failures**, `PASS_PREVIEW_ONLY`, unchanged release gates |
| `v63_d4a_human_combat_test.gd` | PASS: 6 personal casts, CombatStatsV2 damage, Boss phase/telegraph, snapshot/resume, PvE adapter |
| `v63_poison_evolution_balance_test.gd` | **1,475 checks, zero failures**, bounded candidate Poison mechanics (not 30-hunter live acceptance) |
| `v65_poison_combat_contract_test.gd` | PASS: 183 poison records, owner attribution/consume, stack snapshot, respawn |
| `dv2_02_battle_snapshot_test.gd` | PASS: JSON/RNG/HP/cast/events mid-fight |
| `gp_02c1_injury_settlement_test.gd` | PASS: T01–T23 terminal/recovery/compatibility |
| `dv2_02_five_level_pve_test.gd` | PASS: actual equipment/skills, persistent registered rewards and five difficulties |

Original attempts explicitly kept as QA history, NOT relabeled PASS:
- [#42960051297](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960051297): test assertion GDScript parse error, subsequently corrected.
- [#42960195480](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960195480): full-record assertion failed at SaveService read; diagnosed JSON integer 0→0.0/1→1.0 representation; genuine XP and receipt IDs unchanged. Test now checks all record fields with schema-specific normalization for integer fields, preserving the entire receipt and XP equality.
- [#42960381256](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960381256): diagnostic confirmed above.
- [#42960585429](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42960585429): prior exact-code-SHA full SUCCESS (48 mastery / 221 root) before the extra nonzero-passive/source-element assertions.

## Closure labels

- **G1B DETACHED-PVE MASTERY + COMBAT ROOT PREVIEW focused/cumulative QA: PASS** on exact SHA above.
- **G1 full Root V2: PARTIAL / NOT CLOSED.** Missing authorized permanent per-element refinement, real resource acquisition/consumption, matching cultivation activity workflow, full mutation/Dị Linh Căn I–III lifecycle and authored advanced-element triggers, full post-restart cold-process QA. No blanket mutation bonuses or resource sources invented.
- **G0: OPEN** because 1,647 planning slots `NOT_AUTHORED` are not implemented.
- **G2–G6: PENDING** individually implemented skill behavior/VFX/AI and new nine schools / actual offline PK.
- **G7: PARTIAL** scoped headless Godot only; GUI/performance/physical targets still pending.
- **V63FeatureGates.DEFAULT_FLAGS stays OFF**; PR stays Draft; production PvE without explicit preview remains unchanged.

## Next priority

Proceed under Issue #76 with isolated **G1C** source-owned per-element purity/refinement + Dị root design-to-runtime (no fabricated LT/materials, obey one writer per shared authority); test cold **process** save/restart and active-world battle receipts. In parallel G0B may author nine-school skill payloads as content-only, but do not merge any gameplay gates, claim 2,196 runnable skills, or edit `CURRENT_CHECKPOINT.md`/`NEXT_CHAT_HANDOFF.md` while the GP/Economy integration writer owns them. Windows/Android real user acceptance PENDING.
