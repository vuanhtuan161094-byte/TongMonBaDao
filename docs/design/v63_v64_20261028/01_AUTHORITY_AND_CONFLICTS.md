# Authority matrix, conflicts and decisions

## Source-of-truth map

| Topic | Existing authority | V6.3/V6.4 extension | Integration decision |
|---|---|---|---|
| Realm and Body | REALM_LADDER_V2_SPEC, COMBAT_STATS_V2_SPEC, real derive() | Human 1–10, Immortal 11–20, Divine 21–30 | Reuse independent 30x10 tracks; never invent character/class level |
| Cultivation paths | CULTIVATION_PATH_V2_SPEC (sword/body/spell) | bow/fist/poison specializations | **Additive path registry, NOT silent remapping**; preserve old sword/body/spell and saves |
| Active technique | TECHNIQUE_V2_SPEC (1 main + 2 auxiliary) | new nine named technique lines + auxiliary content | New normalized owner state; legacy one-active migrates into main slot |
| Combat passive slots | COMBAT_SKILLS_V2_SPEC: six combat passive slots; static self-only passive does not consume one | five elective + one innate per new branch | Keep legacy six learned/equipped slot state; new branch exposes five elective, innate is a derived branch property displayed as a sixth *visual* tile, not an extra independent proc slot; legacy sixth is preserved but inactive for new branch, restored when changing back; requires owner review |
| Basic/actives | V2 1 basic + 4 active + 6 passives | basic +4 active + ultimate + mobility +5 passive + innate | Ultimate and mobility are **explicit action channels** in proposed new loadout, not hidden extras in a combat passive slot; stable cooldown ownership required |
| Learned vs equipped | V2 separate historical learned/active | two evolutions A/B and successor | Keep all learned/mastery; only one successor per family is active; switch out of combat |
| Skills vs techniques | Separate V2 authorities | manuals, techniques, lineage and rare Divine | Technique does not grant full moves; three relationship modes independent/synergy/prerequisite |
| Root | SPIRITUAL_ROOT_V2_SPEC: five base roots; exotic mutations; permanent base passives; resonance | root-matched authored fractions and rare skill mutation | Do not invent poison/blood base root; preserve existing permanent passives & resonance; no double multiplication |
| Combat math | CombatStatsV2 and subsequent locked curves | candidate poison/Blood Demon/boss combat behavior | Reuse ATK, DEF, DR, penetration, real-HP lifesteal; effect tags/ICD bounded |
| Teaching | TECHNIQUE_V2_SPEC | Tàng Kinh Các codices, chapters, bulk teaching | First full manual archives permanent transmission; disciple pays individual costs/time; no learning RNG |
| Loot | P3_7 loadout/warehouse; exactly-once kill events | shards, inheritance seals, boss rewards | Loot into **one sect warehouse**, contribution/XP and stones follow existing owners; receipt idempotence |
| Workforce | One Active Job and scheduler | learning, training, research | One active job per disciple; never overlap PvE/production/study; cancellation semantics must be explicit |
| Boss | MonsterCatalogueV2 pilot, MapBattleV2 telegraphs | nine bosses, phases, summons, break windows | New data-driven boss authoring; keep old 90s isolated modes unchanged |
| Art | Owner-confirmed Source A, no JX gameplay art | VFX/skill telegraphs | Source A primary, original independent VFX when approved; JX is mechanism reference only |

## Explicitly deferred authority disputes

1. Is the new path registered as independent bow/fist/poison, or as sub-school under legacy sword/body/spell? **Recommendation: independent additive paths**. Do not modify historic learned IDs or cast identity. Owner has to approve registry migration.
2. Passive slot #6 for new content: recommend visible reserved innate tile and preserve sixth legacy equipped passive as dormant when switching into new path. If conflicting UX expectations emerge, resolve before data migration.
3. Can a disciple learn both Immortal descendants? Yes, retain both knowledge if earned; equip at most one successor in a family; out-of-combat switch may have separate authored cost/time.
4. Should all skills evolve as a bundle or individually? **Recommendation: sect lineage unlock authorizes, each personally known skill evolves only if its own mastery/gate passes**; do not award unlearned actives.
5. V6.4 105-item count = nine branches x (4 active +1 ultimate +5 elective passive +1 innate) = 99, plus three schools x (1 basic+1 mobility) = 6. It is **105 family slots**, not 105 fully balanced three-generation content rows; descendants add separate IDs and increase authored record count.
6. Luyện Thể-vs-Tu Vi gating: each skill declares tuvi/body/hybrid progression_basis, no one-size realm gate. Hybrid coefficients must be authored.
7. Boss level scaling: take fixed level/floor per zone spawn. **Never scale by the player's currently equipped ATK**. V6.3 40.16 billion HP is provisional for a level 30-10 challenge fixture only, not constant boss HP.
8. No universally mandatory Boss breakbar or healer. Each boss has at least two viable responses: dodge/guard, phase-object destruction, soft-break counter, or good DPS; no permanent boss invulnerability.
9. No new generic mana, unlimited proc chain, universal PvP copy of PvE balance, or automatic revive after Injury.
10. V5.9 skill numerical values are authored concept reference until individual generation stats/passives have validated data and endgame tests. Mark all such coefficients candidate, never mix as runtime canonical.

## ID and lineage policy

Never reuse existing P0/P2 skill IDs (e.g. thanh_phong_tram) or old cultivation path IDs. Namespaced stable IDs:
- family skill: tmb.skill.<school>.<branch>.<slot>; descendant: <family>.human / .immortal.a / .immortal.b / .divine.a / .divine.b, plus optional .rare.a/.rare.b.
- boss: tmb.boss.<slug>; boss skill: tmb.bossskill.<slug>.<slot>; summon: tmb.summon.<slug>.<slot>.
- techniques: tmb.technique.<school>.<branch>.<generation>.<lineage>; codex: tmb.codex.<school>.<branch>.<chapter>.<generation>.<lineage>.
- unique effect/stack group IDs follow semantics (poison_dot, blood_seal, fatal_protection) rather than localized display names.
- Item IDs, codex IDs, learned skill IDs, and effect IDs are immutable across localization; no color/rarity inferred from suffix.

## Safe release boundary

Each new module behind a feature gate. Legacy actors never acquire candidate effects until migrated and eligible; switching gate OFF restores old behavior. Do not change current main or live branches in this documentation package.
