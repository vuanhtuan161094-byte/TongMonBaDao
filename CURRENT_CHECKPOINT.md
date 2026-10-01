# CURRENT CHECKPOINT

Date: 2026-10-01

## Runtime-confirmed baseline

Real Windows + Godot 4.7.2 cumulative evidence confirms **P0 through P2.11 PASS**.

Locked chain:

- P0 Foundation: LOCKED / PASS.
- P1.1 Goal + Personality: LOCKED / PASS.
- P1.2 Recruitment + Player Choice: LOCKED / PASS.
- P1.3 Relationships + Behavioral Impact: LOCKED / PASS.
- P1.4 Consequential Memory: PASS.
- P1.5 Organization + Teams + Leadership + Combat Roles: PASS.
- P1.6 Sect Life + Needs + Resource Pressure: PASS.
- P2.1 Cultivation + Realms + Breakthrough: PASS.
- P2.2 Spiritual Roots: PASS.
- P2.3 Technique Economy + Library + Mastery: PASS.
- P2.4 Cultivation Paths: PASS.
- P2.5 Realtime Combat + Independent Skills: PASS.
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS.
- P2.7 Disciple Life + Workforce + Sect Assignment: LOCKED / PASS.
- P2.8 Disciple Generation V2 + Phẩm chất + Recruitment Sources: LOCKED / PASS.
- P2.9 Traits + Quirks + Hidden Reveal: LOCKED / PASS.
- P2.10 Spiritual Root Refinement + Mutation: LOCKED / PASS.
- P2.11 Bloodline + Awakening + Purity: LOCKED / PASS.

Authoritative user runtime evidence on 2026-10-01 includes:

- `P2.9 TRAITS + HIDDEN REVEAL GATE: PASS`
- `P2.10 SPIRITUAL ROOT REFINEMENT + MUTATION GATE: PASS`
- `P2.10 GATE: PASS`
- `P2.11 PERSISTENCE DIAGNOSTIC PASS: immediate canonical state identical`
- `P2.11 BLOODLINE + AWAKENING TEST PASS`
- `P2.11 BLOODLINE + AWAKENING GATE: PASS`
- final `P2.11 GATE: PASS`

Do not reopen P0-P2.11 without new regression evidence.

## Active phase

**P2.12 — Thể Chất + Cấp Bậc + Tôi Thể + Cải Thể**

Status: **IMPLEMENTED / AWAITING REAL GODOT 4.7.2 CUMULATIVE GATE**.

Never call P2.12 PASS until `Sync-P2-12.cmd` reaches the final gate on the Windows machine.

Read:

- `docs/P2_12_PHYSIQUE_SPEC.md`
- `docs/P2_11_BLOODLINE_SPEC.md`
- `docs/XIANXIA_FLAVOR_CANON.md`
- `docs/DISCIPLE_GENERATION_CANON.md`

## Core game identity

The player is the **Tông Chủ**. Disciples are autonomous people, not puppets.

Primary operating rhythm remains Evil Hunter Tycoon-like:

`hunt/work -> warehouse -> production/investment -> disciple growth -> harder content`

Character depth is much greater: procedural identity, quality, roots, traits, bloodline, physique, later destiny, profession mastery, relationships, health, loyalty, age/lifespan and organization state.

Routine one-by-one micromanagement must remain optional at scale.

## Global mechanic-consequence rule — canonical

This applies to **all gameplay systems**, not only character identity systems.

Every feature must answer clearly: **what does this actually change in play?** Valid consequence axes include:

- Công / damage / combat power;
- Thủ / HP / resistance / damage reduction;
- tốc độ tu luyện / nghề / mastery;
- xác suất đột phá / thành công / thất bại;
- hồi phục / stamina / injury handling;
- sản lượng / thời gian sản xuất / chất lượng;
- tài nguyên tiêu hao / thu nhập / giá / upkeep;
- AI priority / behavior / access / permission;
- risk / event chance / discovery / loot;
- range / cooldown / movement / targeting / other concrete combat rules.

**Do not fear overlap.** Linh căn, Huyết mạch, Thể chất, Đặc chất, Công pháp, Trang bị, Thiên Mệnh, công trình, chức vị and other systems may affect the same outputs when logically justified.

Systems are differentiated by where the effect comes from, how it is obtained/progressed, cost, conditions, tradeoffs and signature rules — not by artificially forbidding overlap in Công/Thủ/Tốc tu/etc.

Flavor/humor/drawbacks are secondary layers. A rare/valuable mechanic must first have meaningful player value. New-system gates must test real consequences, not field/text existence.

## Locked P2.8-P2.11 character foundation

### P2.8 identity

Six permanent foundation dimensions:

- aptitude — Tư Chất;
- constitution — Căn Cốt;
- fortune — Cơ Duyên;
- comprehension — Thông Tuệ;
- charisma — Mị Lực;
- potential — Tiềm Lực.

Promotable quality:

- Phàm Thường
- Xuất Chúng
- Thiên Kiêu
- Tuyệt Luân
- Nghịch Thiên

Ordinary / Chiêu Hiền / Nhân Duyên share one deterministic generator. Hidden identity is generated once and persisted; reveal never rerolls it.

### P2.9 traits

Visible positive/negative traits have real cultivation/work/combat consequences. Latent traits are generated before reveal and reveal only after lived-history thresholds. Empty visible list is a valid initialized result.

### P2.10 roots

Spiritual-root purity and element count are independent. Refinement consumes real Linh Tủy, raises purity with diminishing returns, preserves the element list and changes real cultivation/breakthrough/technique effects. Root mutation is pre-generated and reveal never rerolls it.

### P2.11 bloodline — locked

A special awakened bloodline must be strong before its gimmick/tradeoff.

Current bloodlines:

- Chân Long Huyết: Công + Thủ + tốc tu + đột phá + hồi phục nền.
- Phượng Hoàng Huyết: Công + Thủ nhẹ + tốc tu + đột phá nhẹ + hồi phục rất cao.
- Bạch Hổ Huyết: Công cao nhất + tốc tu nhỏ.
- Huyền Vũ Huyết: Thủ cao nhất + Công nền + tốc tu + hồi phục.
- Thao Thiết Tàn Huyết: Công + Thủ + tốc tu + hồi phục cao; extra Supply is a tradeoff/humor mechanic.
- none remains a valid common result.

Bloodline awakening/refinement uses real Yêu Đan. Higher purity strengthens real stats. Bloodline effects stack with other logically compatible systems.

## P2.12 implemented contract — Physique

Feature gate:

- `SectState.physiques_enabled`.

Storage authority:

- `SectState.physique_profiles[character_id]`.

Profile schema:

- `initialized`;
- `physique_id`;
- `physique_grade`;
- `initial_physique_id`;
- `temper_level`;
- `transformed`;
- `latent_transformation`.

Candidate -> disciple preserves the exact type + grade profile. Reject removes orphan profile.

### Physique has two independent axes

**Type** describes the body's mechanic:

- no special named physique;
- Kiếm Cốt;
- Kim Cương Bá Thể;
- Hàn Âm Thể;
- Hỏa Linh Thể;
- Vô Cấu Đạo Thể.

**Grade** describes how powerful the body's innate foundation is:

1. **Phàm Thể**;
2. **Linh Thể**;
3. **Huyền Thể**;
4. **Thánh Thể**;
5. **Thần Thể**.

Display contract:

- unnamed ordinary type -> show only grade, e.g. `Linh Thể`;
- special type -> show `Kiếm Cốt · Huyền Thể`, `Hỏa Linh Thể · Thánh Thể`, etc.

Do not display duplicated labels such as `Phàm Thể · Phàm Thể`.

### Grade recruitment probabilities

| Grade | Ordinary | Chiêu Hiền | Nhân Duyên |
| --- | ---: | ---: | ---: |
| Phàm Thể | 58% | 40% | 28% |
| Linh Thể | 27% | 32% | 31% |
| Huyền Thể | 11% | 19% | 24% |
| Thánh Thể | 3.5% | 7% | 13% |
| Thần Thể | 0.5% | 2% | 4% |

Each source distribution sums to 100%. Thần Thể remains possible from ordinary recruitment but is much rarer than gacha/fate.

Current positive-effect scaling by grade:

- Phàm Thể: 0.85x;
- Linh Thể: 1.00x;
- Huyền Thể: 1.20x;
- Thánh Thể: 1.45x;
- Thần Thể: 1.80x.

The grade strengthens real benefits, not only text/color. Current drawbacks do not become harsher merely because grade is higher.

### Current physique types

- **Unnamed ordinary body** — no dead end; tempering gives small general gains and every V2 ordinary body has one deterministic transformation route.
- **Kiếm Cốt** — Công + tốc tu + đột phá nhẹ + strong Sword XP; small recovery drawback before high tempering.
- **Kim Cương Bá Thể** — Công + very high Thủ + recovery + Body XP; real slower cultivation drawback.
- **Hàn Âm Thể** — strong Thủ/Tu/Đột phá/Hồi/Spell XP when paired with Water root; real cultivation/recovery penalty when mismatched.
- **Hỏa Linh Thể** — high Công/Tu/Đột phá/Spell XP when paired with Fire root; much weaker without Fire root.
- **Vô Cấu Đạo Thể** — rare all-rounder with Công/Thủ/Tu/Đột phá/Hồi and all three path XP bonuses.

### Type recruitment probability

Special named physique chance remains separate from grade roll:

- ordinary: 15%;
- gacha: 28%;
- fate: 40%.

Type and grade are deterministic from the same character identity seed but are separate rolls. A common-looking body can still have a high grade; a named special type can exist at a low grade.

### Tempering

`temper_body()`:

- consumes exactly 1 existing Yêu Đan;
- raises temper level up to 5;
- raises real physique consequences;
- does not reroll type or grade;
- no new disconnected currency.

### Transformation

`transform_body()`:

- requires current unnamed ordinary type;
- requires temper level >= 3;
- consumes exactly 2 existing Linh Tủy;
- transforms into the pre-generated `latent_transformation` target;
- never rerolls at transformation time;
- preserves temper level;
- preserves physique grade;
- records `transformed = true`.

### Grade promotion later

Do **not** automatically promote Phàm -> Linh -> Huyền -> Thánh -> Thần just by pressing temper five times.

Physique grade is a major foundation layer. A future promotion action must require rare treasure/material + appropriate progression conditions. P2.12 already provides the grade schema, probability, persistence and stat scaling, but does not trivialize Thần Thể through routine tempering.

### Real consequence hooks

- `CultivationSystem.effective_combat_power()` reads Physique Công.
- `CombatSystem` reads Physique Thủ.
- `CultivationSystem.add_progress()` reads Physique cultivation multiplier.
- `CultivationSystem.breakthrough_success_chance()` reads Physique breakthrough bonus.
- `NeedsSystem.apply_rest()` reads Physique recovery bonus/penalty.
- `CultivationPathSystem.add_experience()` reads Sword/Body/Spell XP affinity.
- `PhysiqueSystem` scales positive effects using physique grade.

### Overlap rule — explicitly tested

Bloodline + Physique are allowed to modify the same stats and **must stack**. A Chân Long + Hỏa Linh Thể · Thánh Thể disciple receives all valid Công/Tu sources. Do not add exclusivity merely because systems affect the same output.

## Xianxia flavor/humor canon

Read `docs/XIANXIA_FLAVOR_CANON.md`.

Cultivation-story humor is allowed but must come from real simulation causes/consequences. Do not turn the game into a meme game and do not replace core power/value with novelty drawbacks.

## P2.12 verification assets

- `godot/src/simulation/physique/physique_system.gd`
- `godot/src/simulation/core/p2_12_factory.gd`
- `godot/tests/simulation/p2_12_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_12_physique_test.gd`
- `godot/src/presentation/p2_12_physique.gd`
- `godot/scenes/p2/p2_12_physique.tscn`
- `tools/godot/Verify-P2-12.ps1`
- `Verify-P2-12.cmd`
- `Sync-P2-12.cmd`

P2.12 verifier reruns P0-P2.11 first and must prove persistence, deterministic type+grade profiles, grade probabilities, real grade scaling, no reroll, real stat value, real drawbacks, elemental synergy, tempering cost, transformation cost/identity/grade preservation, Bloodline+Physique stacking, recruitment lifecycle and scene smoke.

## Next authoritative local command

```bat
cd /d "E:\0.2. TongMonBaDao"
git pull origin main
Sync-P2-12.cmd
```

If it fails, fix the first real parser/diagnostic/assertion failure only, then rerun the same command.

## Planned order after P2.12 runtime green

1. pause backend identity expansion;
2. build the first **visible living sect** slice: map + buildings + disciples physically moving to work/rest/cultivation destinations;
3. injury/medical;
4. loyalty + stipend/reward;
5. sect rank/authority expansion;
6. master-disciple/teaching;
7. Destiny/awakening;
8. active age/lifespan/death/inheritance after pacing is proven.

Do not keep stacking backend identity systems before returning to visible gameplay.
