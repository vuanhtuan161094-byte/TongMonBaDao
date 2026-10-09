# TÔNG MÔN BÁ ĐẠO — KẾ HOẠCH HOÀN THIỆN ĐỆ TỬ V2: NHÂN VẬT THẬT, THUỘC TÍNH THẬT

Date: 2026-10-09
Status: **USER-APPROVED PRIORITY / IMPLEMENTATION ROADMAP; NOT IMPLEMENTED; NO ACTIVE PHASE**
This plan supersedes the **next-work priority** in `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` but does not delete, amend or re-lock previously approved Equipment V2 / Sets V2 decisions. **Pháp Bảo, Phù, gear forging/enhancement, profession-economic expansion and advanced relationships are deferred.** This plan is NOT blanket permission to implement gameplay code or claim a test PASS. User must explicitly start the first implementation slice.

## 0. Goal — a genuinely playable disciple, not display-only panels

**Primary target:** A disciple generated through the existing Dẫn Tiên/recruitment authority must become one canonical person with immutable birth/provenance; persist all approved innate and hidden attributes; derive combat and work/cultivation outputs from the same source pipeline; move/work/cultivate/fight using those values; visibly expose only legitimate information in a real disciple UI; and survive save/load, restart, 1,000–3,000 roster scale, old-save migration and deterministic multi-seed tests.

**Definition of "HOÀN THIỆN":** for each approved attribute/source, verify **(A)** generation or explicit no-value default, **(B)** persistent stored owner and version, **(C)** non-fictional derived modifier, **(D)** actual runtime consumer/action, **(E)** source-by-source UI/hidden confidentiality, **(F)** deterministic focused and regression tests. A name shown in a tab without effect is NOT complete. A mechanically blocked advanced effect must be marked BLOCKED/NOT ACTIVE and is not silently presented as working. Do not substitute an unrelated "+Combat Power" placeholder.

A first **vertical slice** is ONE real recruited disciple that progresses, works, fights and updates the same derived stats seen in the UI. Extend afterward to all supported character varieties and mass roster scale.

## 1. Existing runtime evidence — what can be reused, what must migrate

Read current live code, do not assume every old system is V2:

| Existing system / actual file | What exists now | V2 work remaining |
|---|---|---|
| `godot/src/simulation/recruitment/disciple_generator_open_points.gd`, `recruitment/recruitment_system.gd` | P3.7C1 six open-point foundations and Dẫn Tiên recruitment rules; backend LOCKED | Extend ONE whole-person deterministic birth pipeline without rerolling C1 foundations or changing Dẫn Tiên rate/quota |
| `godot/src/simulation/state/candidate_state.gd`, `state/disciple_state.gd` | Existing serialization, profile seeds, some fields and legacy states | V2 identity/hidden states/dual progression, versioned migration and initialized markers; old `combat_power` is compatibility only |
| `godot/src/simulation/foundation/foundation_system.gd` | C1 open-point model, quality, Luck Score and migration | Reuse C1 authority, no parallel six stats/no blanket generic luck%; connect lawful consumers |
| `godot/src/simulation/workforce/character_modifier_system.gd` | Existing work/cultivation channels and legacy bridge | Unified V2 typed source -> modifier -> context -> derived-stats explanation; no generic combat score as truth |
| `godot/src/simulation/cultivation/cultivation_system.gd`, `combat/combat_system.gd` | Legacy realm stages, progress/breakthrough, power-driven fighting | 30×10 Tu Vi + 30×10 Luyện Thể, distinct stats and actual V2 combat pipeline; preserve earlier regression by versioned migration/compatibility |
| `godot/src/simulation/cultivation/spiritual_root_system.gd`, `traits/trait_system.gd`, `bloodline/bloodline_system.gd`, `physique/physique_system.gd` | Earlier P2 compatibility, some real old effects | Implement each **new** V2 contract in new/explicitly migrated authority; do not extend retired P2 grades/purity/Combat Power as V2 |
| `godot/src/simulation/combat/combat_skill_system.gd` | Legacy small skill set and simplified combat effects | Actual 1 basic + 4 active + 6 combat-passive schema; authored Nhân→Tiên→Thần skill families, tags, procs and event ownership |
| P3.2/P3.3/P3.6 presentation + tests | Existing real disciple tabs/map/selection; P3.2 checks old combat-power/physique display | Replace obsolete output with V2 derived breakdown and correct hidden/reveal text; presentation cannot invent data |
| `godot/src/simulation/equipment/equipment_system.gd` | Legacy weapon/armor/talisman and three old quality classes | Keep compatibility initially. Do not start full 10-slot/set/forging V2 as prerequisite to first real character. Add only minimal valid weapon-requirement adapter if required for V2 skill/physique gating |

**Evidence boundary:** last official Godot 4.7.2 documented completed backend remains **P3.7C1**; all new Disciple V2 character/skill/stat subsystems are design authorities, NOT a tested full runtime. UI smoke for old tabs is not a new V2 implementation gate.

## 2. Source-of-truth reading order

1. `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md`;
2. this plan + `docs/DISCIPLE_MASTER_SCHEMA.md` + `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md` + `docs/DISCIPLE_V2_DESIGN_LEDGER.md`;
3. locked subsystem sources: `docs/COMBAT_STATS_V2_SPEC.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/BODY_CULTIVATION_V2_SPEC.md`, `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`, `docs/SPIRITUAL_ROOT_V2_SPEC.md`, `docs/TRAITS_V2_SPEC.md`, `docs/DESTINY_V2_SPEC.md`, `docs/BLOODLINE_V2_SPEC.md`, `docs/PHYSIQUE_V2_SPEC.md`, `docs/TECHNIQUE_V2_SPEC.md`, `docs/CULTIVATION_PATH_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`;
4. P3.7C1 code/tests, actual candidate/DiscipleState, old combat, UI and save/load code.
5. Equipment V2 and Set V2 read **only as compatibility/optional static sources**, not an invitation to implement full gear/forge now.

Latest explicit user direction + more specific locked spec wins over retired P2 schema. Do not reopen approved odds, formulas, identity rates, root behavior, skill loadout or set architecture without a concrete contradiction and user decision.

## 3. Planned sequential slices — future implementation phases, NOT ACTIVE

The labels `DV2-00..DV2-10` are **planning identifiers only**, not active P3.x phase IDs or existing GitHub CI gates. Implement one smallest meaningful slice, focused test, then relevant cumulative real Godot 4.7.2 regression. Do not mark PASS on static reading.

| Sequence | Slice and real deliverable | Minimal acceptance |
|---|---|---|
| **DV2-00** | **READ-ONLY CURRENT-STATE AUDIT**: field/owner/consumer matrix by attribute (implemented/legacy/design-only/blocked), source of truth, save migration map; inventory real UI and test gates | Exhaustive attribute coverage; identify stale `combat_power`, old root/trait/physique grades and absent consumers. No changes to gameplay yet |
| **DV2-01** | **ONE WHOLE-PERSON BIRTH**: Dẫn Tiên candidate→Disciple V2 with seeds/provenance, six foundations birth snapshot, personality, base/mutated root, Trait visible/latent, Destiny present/latent, Bloodline, one Physique Core, profession talent, age, starting realms; no rerolls | Same world seed+source+generation index = same hidden and visible person; no-value results use `initialized`/explicit none, not reroll; accept/save/load unchanged; C1 daily quota/odds untouched |
| **DV2-02** | **ONE DERIVED-MODIFIER ENGINE**: typed flat/percent-add/percentage-points/filter/special rules; complete Combat Stats V2 registry, source breakdown; core Realm+Body+Tiềm Lực ATK/DEF/HP | Deterministic snapshot; source change invalidates appropriate cache; fixed +X remains fixed; Tiềm Lực only modifies RealmBodyCore; old generic power not used as V2 damage authority; meaningful HP-rescale semantics |
| **DV2-03** | **TWO GROWTH TRACKS**: Tu Vi 30 realms×10 floors + Luyện Thể 30×10; valid Tu Vi/progress and breakthrough, Căn Cốt body-XP, expedition stamina distinct from ordinary production | Minor floors auto advance, major gates only; failure contract and resource costs as locked; body/realm independent; 100 daily expedition stamina not spent by sect work; migration/save reload |
| **DV2-04** | **LINH CĂN V2**: 1..5 base elements/per-root purity, resonance, root refinement/creation; mutation latent/awakening/progression; cultivation/skill/matchup consumers | Five-root and 0.20% mutation distributions; purity immutable at birth but improvable; no fake elemental damage; real owned skill events for advanced Lôi/Phong/Băng/Dương/U Minh; blocked combat stage if shared triggers not ready |
| **DV2-05** | **ĐẶC CHẤT + MỆNH CÁCH V2**: Trait strengths/negatives/two-sided/latent/hậu thiên + high-impact multi-fate and Mệnh Cục effects | Actual work/cultivation/combat/valid event consumers; 0.50% congenital fate model; no generic Trait grade or one Chủ-Mệnh slot; history/retroactive reveal and no repetitive event farming |
| **DV2-06** | **HUYẾT MẠCH + THỂ CHẤT V2**: V2 profile/purity/reveal for five Bloodlines, awakened Chân Huyết/Phản Tổ; 15 core physiques, body specializations and legitimate evolution | Bloodline congenital 98/1.6/0.4 and purity 1–100; Physique 97/2.7/0.3, one active Core, **no Physique grade/purity/temper**; tagged combat effect consumers; **Kiếm Cốt must remain visibly blocked until legal sword weapon tag + measurable effect**, not enabled lore-only |
| **DV2-07** | **CÔNG PHÁP / CHỦ ĐẠO / KỸ NĂNG**: 1 Chủ Tu+2 Phụ Tu, Kiếm/Thể/Pháp with branches, AI action choice, 1 basic+4 active+6 passive and skill family Nhân→Tiên→Thần | Skills execute in *real* encounters; damage, heal, shield, DoT, control, crit and ICD follow Combat Stats/Skills V2; no universal Mana/Kiếm Ý/Accuracy; no unbounded proc chains |
| **DV2-08** | **ONE COMPLETE ACTION LOOP**: the same recruit cultivates, works at a real building, hunts/fights and returns with updated stat-based outcomes; HP, rest/recovery, injury/stamina only when owned by real runtime | Every claimed enabled modifier demonstrated by at least one before/after action; no hidden field changes while idle; no separated UI-only "simulation"; outside-map stamina cannot drain ordinary job |
| **DV2-09** | **REAL DISCIPLE UI**: attributes + complete source breakdown, cultivation/body, Root, Trait, Fate, Bloodline, Physique, Path/Technique/Skill, Work, equipped/compat; reveal/latent status and available controls | UI reads same live state and V2 derived combat stats used by fight; no old "combat_power" as factual stat; hidden identity never leaked; actions call valid runtime commands, disabled/blocked effects shown honestly |
| **DV2-10** | **CUMULATIVE CHARACTER RELEASE GATE**: seed determinism, old save migration, broad distributions, PvE/job interactions, long ticks and 1,000–3,000 disciples; preview and real-device-size UI checks | Official Godot 4.7.2 focused + cumulative PASS; versioned save/load integrity and determinism; performance budget bounded and lazy cache; user-owned final visual acceptance |

**Dependency note:** DV2-02 needs at least the canonical progression **growth input contract**; DV2-03 may be split into minimal RealmBodyCore foundation + full 30×10 progression if required by tests. The exact runnable micro-phases shall be sized during DV2-00, not guessed now. DV2-04/05/06 mechanics that rely on advanced skill event/trigger runtime may be completed with DV2-07 as explicitly tracked dependencies; **never call these groups complete while named effects are stubbed**. UI may be integrated progressively for test visibility; DV2-09 is full UI closure, not a rule to hide all progress until then.

## 4. Attribute-to-consumer coverage: no missing or cosmetic stats

| Layer/source | Canonical stored/derived meaning | Actual action/effect to demonstrate |
|---|---|---|
| ID/seed/source, sex/race/origin/age/history | Stable person identity and chronological information | Recruit/accept/save/reload, event history and correct UI identity |
| Tư Chất | Natural cultivation gain +0.25%/point baseline C1 | Same action before/after permanent improvement changes Tu Vi gain, not fixed-value pill amount |
| Căn Cốt | Luyện Thể XP +0.20%/point baseline C1 | Real Luyện Thể action gains extra XP, **not** ordinary work stamina |
| Cơ Duyên | Lucky Score (random 0..9999 + fortune − difficulty), not general % | Actual named rare/lucky event/harvest check only, reproducible seeded result |
| Thông Tuệ | Learning/mastery XP +0.15%/point C1 | Actual studied technique, mastered skill or profession learning consumes correct channel |
| Mị Lực | Social/Dẫn Tiên guide, bounded quality-table application but uncapped guide contribution | Real Dẫn Tiên yield/quality limit; no generic battle damage boost |
| Tiềm Lực | Realm+Body Core long-term growth +0.05%/point C1 baseline | Increase RealmBodyCore HP/Attack/Defense retroactively, NOT a weapon's flat +X |
| Phẩm chất Đệ tử | Label derived from current sum of six permanent values | Promotion after legal permanent increase without rerolling birth value |
| Personality | Behavioral biases and current goals, NOT a combat stat | Predictable different selection/evaluation in existing AI where applicable |
| Tu Vi & Luyện Thể | Independent 300-floor progressions | Real cultivation/body growth, breakthrough and resulting derived stats; expedition stamina rules |
| Linh Căn / Dị Linh Căn | Element(s), independent purity, matchups, mutation stages | Cultivation/skill modifiers and authored combat tags, legal status/proc resolution |
| Đặc Chất | Visible/latent/acquired, positive/negative/mixed effects | Typed modifier actually changes work/skill/behavior; 8% latent rule |
| Mệnh Cách | Multiple compatible rare fates, meaningful high-impact events | Actual named eligibility/counter/event/bonus and Mệnh Cục; no decorative destiny |
| Huyết Mạch | Presence/lineage/purity, awaken/refine/reveal, multiple post-birth | Typed combat/recovery effects, real trigger and correct provenance |
| Thể Chất | One Core, 15 roster identities and transformations | Real valid output for every enabled physique; Sword Bone blocked until mechanism exists |
| Công Pháp / Chủ Đạo / Kỹ Năng | Learned progression and active selection | Real skills/cooldown/cast/status/skills-tag integration, combat AI |
| Profession talent, work XP, current job | Separate natural aptitude and learned skill | Real worker speed/XP/check; no phantom yield inflation |
| Current HP, expedition stamina, injury | Runtime state, not birth random rolls | Damage/heal/expedition/recovery/medical (injury features staged if not built) |
| Mood, loyalty, relation, sư đồ/family | Later life/social authority | Keep existing real fields/actions where present; **DEFER new expansion** to avoid blocking core V2 release |
| Trang Bị / Pháp Bảo / Phù | Other separate source layers | Initially retain legacy compatibility and allow safe typed modifier adapter; **DEFER full new crafting/loot/gear/Pháp Bảo/Phù** |

No attribute is "DONE" without a consumer. When a system needs content still not designed (for example a Thần rule-changing effect, some profession quality checks, complicated life events), mark that **explicit dependency + owner + activation gate**; do not add a fake % placeholder or expose non-working ability as active.

## 5. Shared implementation contracts and failure cases

- **Whole-person RNG**: one canonical generation stream/seed domains, birth snapshot, hidden seeded profile and provenance. Distinguish `not initialized` from valid `none`; revealing is NEVER rerolling. Recruitment source may bias distribution but not schema. New personality/root/bloodline RNG consumption must not perturb previously locked C1 Lục Duy/Dẫn Tiên seed outputs; use independent named substreams if necessary.
- **Migration**: old P0/P1/P2/P3.7C1 saves load unchanged through deterministic, versioned mapping; never silently reassign a preexisting disciple's permanent birth identity. Legacy `combat_power`, old normalized foundation, old physique grade/temper/root quality and P2.6 equipment migrate through explicit adapter until fully retired. Preserve live old tests; do not delete old scripts just because V2 docs exist.
- **One modifier owner**: each source contributes a typed record with source ID, channel, mode, context, acquisition/provenance and enabled state. Derive stats via one pipeline: RealmBodyCore → Tiềm Lực → equipment/fixed flat → percent-add/context → special rules → final. Different speed and crit/status channels retain canonical order. Unknown channels fail validation rather than silently yielding nothing.
- **No infinite combat loops**: event attribution (caster/source/cast/hit/tick), cooldown/ICD, trigger budget, max-hit and stack policy. Real healer/shield/DoT/silence/slow vs Boss soft control. The same stats must drive real combat both shown and resolved off-screen.
- **UI nonleak**: hidden Root/Dị/Traits/Destiny/Bloodline/Physique info is redacted until reveal; stored hidden value still affects only features the locked design authorizes before reveal. No "lore-only" or unavailable effect displayed as unlocked.
- **One-person to mass**: cache derived stats and invalidate only affected source changes; no recalculation of 3,000 character full combat panels every tick. Deterministic batch actions, performance profiles, test fixed seeds and long simulation runs.
- **Resource correctness**: real Sect Warehouse, reserve/consume, no duplicate free material or second reward warehouse. Same work-speed channel modifies duration but never separately multiplies routine yield. Expensive transformations require authored recipes; no mock resources or bypass.

## 6. Test matrix and hard PASS conditions

For each planned slice, define script/test name only when actually implemented; no fake pre-existing tests.

**A — determinism/identity:** multi-seed same birth state, same source/sequence, candidate→disciple, no rerolls on reveal/save/load, stable old saves and C1 odds/quota. Test `none` vs not-initialized.
**B — stat derivation:** HP/ATK/DEF regression against changed Realm/Body/Potential, flat weapon addition, percent-add, elemental resistance, crit, cooldown, shields/healing and explanation breakdown.
**C — gameplay behavior:** compare two otherwise identical disciples varying ONE attribute; actual cultivation, profession, encounter, item assignment or lucky outcome differs exactly where expected.
**D — special systems:** trait negatives, rare destiny history, root resonance/mutation, bloodline awakened effects, 15 physique roster and blocked sword bone.
**E — presentation:** hidden values not leaked; all tabs read authoritative state; actions are actual commands, no display-only values; 1280×720 landscape safe.
**F — scale:** 1,000/3,000 disciples, deterministic continuation after save/load, cache invalidation costs, stable simulation tick and no pathological proc fanout.
**G — regressions:** existing P0–P2.12, P3.1–P3.6A and P3.7A1/A2R/B1/C1 appropriate focused and cumulative tests as required by `AGENTS.md`. Official GitHub Actions Godot 4.7.2 test evidence is valid CI evidence but not a claim of user's Windows run.

A slice can close only when authored code and actual focused tests pass and documented cross-system regression is green. **No run => no PASS.** Final preview/visual acceptance remains user-owned.

## 7. First action in the next chat: concrete handoff

**Do not start with forge/Pháp Bảo/Phù design again.** Fetch LIVE `main`; read `AGENTS.md`, architecture, checkpoint, handoff, this plan, master schema, framework, combat stats, C1 spec and actual runtime. Compare current systems and produce a **DV2-00 field-to-runtime-consumer audit** with 4 labels: `ACTIVE/PASS` only with real gate, `LEGACY-COMPAT`, `DESIGN-ONLY`, `BLOCKED-DEPENDENCY`. Then recommend the smallest first implementation slice **DV2-01 whole-person candidate/recruit** with precise files/tests and preservation of P3.7C1. Begin gameplay code only after the user explicitly authorizes the phase. Avoid generic re-design of previously locked specialties.

**Completion goal** is a real recruited disciple with all approved applicable innate attributes, authentic progression and gameplay consumption, honest UI and persistent/performant state; not another extensive spreadsheet of disconnected systems.

## 8. Deferred queue (intentionally NOT current priority)

1. Ordinary Equipment V2 **forging, enhancement, refining, set creation, realm-tier promotion, individual Chân Văn, loot economy and mass auto-equip** — preserved approved roadmap at `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`.
2. Pháp Bảo V2 and Phù V2 — separate future systems.
3. Personality depth/autonomy, Mood/Loyalty/Injury extended gameplay, advanced professions and recruitment economy, relationships/Sư đồ/Đạo lữ/family — only after character core slice or when a dependency demands the smallest necessary piece.
4. 30 primary maps/300 cluster fully authored content — still planning, not an approved implementation gate.

*Status vocabulary strictly follows `docs/GAME_SYSTEM_ARCHITECTURE.md`: DESIGN LOCKED != code; BACKEND LOCKED requires focused+cumulative real Godot 4.7.2 gates; VISUAL ACCEPTED belongs to the user.*
