# V63 DESIGN AUDIT 01 — 2,196 skills / 420 families / 36 branches

**Audit date:** 2026-11-13. **Source HEAD:** `77d855c0c3660b42b5488decb16bdfc94d8c0279`; PR #72 Draft.

## 2026-11-13 pairing erratum — DESIGN-AUDIT-P1
The earlier matrix paired some `rare.a` nodes with `divine.b` because it matched only family, slot, tier and lineage. The corrected comparator additionally matches **`variant_type` and `rarity`**, and treats `rare_a` / `rare_b` as a distinct pair. This changes the full count from **236 to 237**, P2 from **195 to 196**, and corrects the previously erroneous rare IDs. The 41 P1 pairs are unchanged in count, but rare-a/rare-b exact IDs are corrected. Do not reuse or cite the original matrix without this correction.

## Result
- 12 real `godot/data/combat/v63_*_combat_catalog.json` files inspected, **2,196/2,196 unique skill IDs**, **420 family IDs**. All 12 schools have 183 nodes and 35 families; Human/Immortal/Divine distribution 35/68/80.
- Independent full graph check: 0 dangling parent IDs, 0 out-of-family parents, 0 parent cycles, 0 dangling replaces IDs. Candidate branch elements match all 27 candidate branches. 549 existing / 1,647 gated candidate nodes remain unchanged.
- All **864 A/B lineage pairs matched**, including rare variants. Comparing **32 selected declared gameplay fields** gives **237 pairs with exact attribute equality**: **41 active/ultimate (P1)** and **196 passive/innate (P2)**.
- These are **potential design duplications, not proven identical behavior in every runtime context**. The comparison excludes names/lore, visuals, IDs, and cosmetic keys. It is not a balance simulation or proof of a bug; code may use additional lineage-specific routing.
- No numeric balance changes, source approvals, VFX production edits, release flag changes or gameplay source changes were made. **V6.3 remains OFF**; source/manual/balance and owner acceptance are pending.

| School | A/B pairs | Exact gameplay-field pairs | P1 active/ultimate | P2 passive/innate |
| --- | ---: | ---: | ---: | ---: |
| blade | 72 | 1 | 0 | 1 |
| bow | 72 | 0 | 0 | 0 |
| curse | 72 | 0 | 0 | 0 |
| dual_blade | 72 | 39 | 0 | 39 |
| fist | 72 | 0 | 0 | 0 |
| formation | 72 | 0 | 0 | 0 |
| palm | 72 | 63 | 24 | 39 |
| poison | 72 | 0 | 0 | 0 |
| spear | 72 | 39 | 0 | 39 |
| summon | 72 | 45 | 6 | 39 |
| sword | 72 | 0 | 0 | 0 |
| talisman | 72 | 50 | 11 | 39 |
| **Total** | **864** | **237** | **41** | **196** |

### Priority decisions
**P1: active/ultimate exact equals (41 pairs).** Chưởng: 24 (18 active, 6 ultimate); Phù: 11 active; Triệu Hồi: 6 active. Examples:
- `tmb.skill.palm.liet_duong_chuong.active_01.immortal.a` vs `...b`
- `tmb.skill.talisman.loi_phu.active_01.immortal.a` vs `...b`
- `tmb.skill.summon.kiem_linh.active_03.immortal.a` vs `...b`

**P2: passive/innate exact equals (196 pairs).** Thương, Song Đao, Chưởng, Phù và Triệu Hồi: 39 each, plus 1 rare passive Đao. Shared passives may be intentional and must not be silently treated as errors.

**Owner approval required:** clarify whether A/B active/ultimate are required to differ mechanically or may be aesthetic options; decide whether shared passives are intentional. If changing gameplay, approve specific non-numeric behavior contracts and affected paths, then test Combat V2/AI/snapshots and re-audit. Do not invent or change numerical ratios/cooldowns/caps, provenance or source manuals before approval.

## Evidence and reproducibility
- `LINEAGE_AB_COMPARISON.csv` has **all 864 pairs**, full source node IDs, paired slot/tier, whether all 32 fields are equal, which fields differ, and review priority.
- Comparison includes 32 fields: `effect`, `damage_ratio`, `range`, `cast_time`, `cooldown`, `projectile_speed`, `shape`, `radius`, `target_limit`, `power`, `duration`, `poison_stacks`, `passive_modifiers`, `hit_count`, `health_cost_ratio`, `health_trade_bonus_ratio`, `slow_movement_factor`, `boss_effect_strength_factor`, `boss_duration_factor`, `guard_target_policy`, `guard_mode`, `guard_capacity_ratio`, `slow_status_policy`, `mark_policy`, `target_policy`, `summon_profile`, `formation_zone_tick_interval`, `combat_trait`, `ai_profile`, `required_divine_stage`, `divine_stage_multipliers`, `stage_gate_realms`. JSON-value exact equality after missing keys become null; no tolerance or subjective similarity scoring.
- Branch pair coverage: 36 non-common lineages; each per-school/branch present in the CSV.

## QA gate and blockers
- **STATIC SOURCE AUDIT: PASS** on inspected HEAD for identity, graph and pair coverage.
- **NEW GODOT EXACT-SHA: NOT RUN:** this execution host lacks a Godot executable and repository checkout/network; GitHub connector available for source inspection and commits, but not fresh workflow dispatch. No fake runtime PASS.
- Prior S9 closure official Godot 4.7.2 D1/S0–S9 PASS at code SHA `6124758ad70fef66a51c0fd94d034b4f65122e89` is **previous evidence only**, not a new test of this design-audit commit.
- **PENDING:** 236 owner design decisions, 1,647 candidate manuals/source and balance approval, Windows GUI, Android, owner VFX visual acceptance; D4A/Warehouse baseline FAIL unchanged. PR #72 Draft; no merge.
