# V6.3/V6.4 — Data model and runtime authority (design, no GDScript implementation)

## 1. Registries, ownership and lifecycle

Use registries of **immutable authored definitions**, not one giant CombatSkillSystem SKILLS dictionary with hardcoded branches. Preserve legacy IDs and expose new content behind feature gates.

Proposed modules/services (names conceptual, not existing files):
- ContentRegistryV63: validate and load paths, skills/descendants, effect definitions, Techniques, codex chapters, boss catalogue, drop tables; fail-closed unknown refs.
- SkillLineageService: resolve personally known family and one active generation/lineage; do not infer generation from current realm alone.
- TechniqueLearningService + SectArchiveService: sect archive ownership vs disciple learned mastery vs current 1+2 equipped.
- Progression/Job scheduler: one active job/disciple; research jobs at sect level with exactly-once completion.
- BossEncounterStateMachine: per-spawn phase set, queue telegraph/resolve, summon ownership, breakbar only for eligible casts, boss heal budgets.
- CombatEventResolver: deterministic event/source IDs, effect snapshot and bounded proc lineage, damage through CombatStatsV2.
- RewardLedger: warehouse deposits and per-person progression according to existing P3.7 economy; exact receipt ownership.

Example content is pseudo JSON; schemas must be validated at load and still require implementation authoring.

~~~json
{
  "schema_version": 1,
  "family_id": "tmb.skill.poison.doc_cham.active_04",
  "slot_type": "active",
  "school_id": "poison",
  "branch_id": "doc_cham",
  "progression_basis": "tuvi",
  "generations": [
    {
      "id": "tmb.skill.poison.doc_cham.active_04.human",
      "min_realm": 1, "max_skill_level": 10,
      "cast_s": 1.45, "cooldown_s": 20,
      "effects": [
        {"effect_id":"direct_hit", "ratio_atk":1.45, "element_shares":{"wood":0.0}},
        {"effect_id":"consume_owned_poison", "max_stacks":3, "remaining_dot_conversion":0.75}
      ],
      "choice_nodes":{"4":["candidate_human_4_a","candidate_human_4_b"],"7":["candidate_human_7_a","candidate_human_7_b"]},
      "balance_status":"candidate"
    },
    {"id":"tmb.skill.poison.doc_cham.active_04.immortal.a","min_realm":11,"lineage":"a","successor_of":"tmb.skill.poison.doc_cham.active_04.human","balance_status":"candidate"},
    {"id":"tmb.skill.poison.doc_cham.active_04.immortal.b","min_realm":11,"lineage":"b","successor_of":"tmb.skill.poison.doc_cham.active_04.human","balance_status":"candidate"},
    {"id":"tmb.skill.poison.doc_cham.active_04.divine.a","min_realm":21,"lineage":"a","successor_of":"tmb.skill.poison.doc_cham.active_04.immortal.a","balance_status":"candidate"}
  ],
  "unique_family":"poison_explosion", "proc_generation_max":1
}
~~~

Notes: the example human active_04 effects MUST be reconciled with final V6.3 explosion rule before coding. Never treat an incomplete successor record as a live usable skill. The registry validator should reject missing effect values for release-enabled generations; no implicit copy of Human effects into Divine.

### Technique contract

~~~json
{
  "technique_id":"tmb.technique.fist.huyet_quyen.immortal.a",
  "generation":"immortal","grade":"immortal","lineage":"a",
  "main_allowed":true,"aux_allowed":false,
  "prerequisite":{"realm_min":11,"basis":"hybrid","learned":["tmb.technique.fist.huyet_quyen.human.base"],"mastery_min":"da_thanh"},
  "effect_family_keys":["blood_seal","blood_marks"],
  "skill_relationships":[{"mode":"synergy","tag":"blood_fist"}],
  "learning_job_id":"tmb.study.huyet_ma_tien",
  "balance_status":"candidate"
}
~~~

One active main technique, two auxiliary techniques, inactive learned IDs retain mastery/history but yield no ordinary effects. A prerequisite does not imply a free grant of skill. Distinct personal discovery may require Khắc Lục before becoming sect-teachable.

### Sect archive and disciple learning state

~~~json
{
  "sect_archive": {
    "owned_complete_definitions":["tmb.codex.poison.doc_cham.ch1.human.base"],
    "fragments":{"tmb.codex.poison.doc_cham.ch3.human.base":18},
    "research_unlocks":[],
    "provenance_receipts":[]
  },
  "disciple": {
    "learned_skill_families":{"tmb.skill.poison.doc_cham.active_04":{"human_level":7,"xp":1400,"human_choices":{"4":"a","7":"b"},"known_descendants":[]}},
    "known_techniques":{"tmb.technique.poison.doc_cham.human.base":{"mastery_xp":5000,"mastery":"da_thanh"}},
    "active_path_id":"tmb.path.poison.doc_cham",
    "active_technique_main":"tmb.technique.poison.doc_cham.human.base",
    "active_technique_aux":[null,null],
    "active_loadout":{"basic":"tmb.skill.poison.basic","actives":[],"ultimate":null,"mobility":"tmb.skill.poison.mobility","elective_passives":[]},
    "personal_discovery":[],
    "active_job_id":null
  }
}
~~~

Persist **canonical personal owned data** and receipts. Recompute derived stats, effective passive activation, skill effect multipliers and UI every load; never persist cache as authority. Every learned skill family and completed mastered stage survives path switches. Inactive legacy sixth passive remains persisted, never discarded.

## 2. Combat effect resolution

1. Actor chooses valid authored action from learned/equipped and AI. Validate living caster, target, range/LoS, cast state, own cooldown and role.
2. Open unique cast_id = encounter_id/spawn_generation/caster_id/action_seq; spawn telegraph with start_s, release_s, geometry, announced target, and safe/counter categories.
3. On release, ensure cast still legal and resolve target selection. Produce bounded damage/Heal/Shield/DoT packets with (cast_id, effect_index, target_id, event_seq) stable IDs.
4. Resolve defense reductions -> target Defense -> attacker Penetration -> Defense formula -> elemental share/resist -> DR -> actual HP damage; **follow CombatStatsV2 exactly**.
5. Trigger eligible follow-ups only after HP commit. A follow-up must declare can_crit, can_lifesteal, can_proc, owner_id, unique_family, ICD, budget and generation. No reflection of reflection, shared-damage recursion, Cổ Hồn from Cổ Hồn, or repeated atomic settle.
6. Emit combat contribution for mastery once per meaningful action; damage tick spam and overheal are not XP farms.
7. Boss ability/phase changes persist in encounter or deterministic world state by spawn-generation; kill receipt exactly once.

### Poison owner and diminishing

A stack key is (target_id, source_actor_id, source_skill_generation_id, stack_ordinal); expires at 10s unless explicit authored refresh. Per owner max5. Status calculates remaining damage with source attack snapshot policy declared; do not double-apply purity, mastery or poison-resist. Boss 30 owned stacks remain owned; diminished effective DoT allocation must be symmetric and source-order independent; recommended proportional allocation to all owners at identical effect tier. For unequal tier/duration use deterministic per-source weighted credits, document methodology before code; explosion consumes only caster-owned stacks. Immortal/Divine 12/20% ATK per stack-second are **provisional**. Damage from tick not crit/lifesteal by default.

### Blood seal and healing edge cases

Two HP authorities: base_max_hp (unsealed, relevant to damage thresholds) and combat_effective_hp_ceiling (75% Immortal /65% Divine /55% rare of base). Current HP is clamped once at activation without generating on-damage triggers; if HP > ceiling subtract difference as seal, NOT damage. Allied normal heals apply only if current_hp < threshold (40/35% original HP), scale at 60/50% effectiveness, and clamp outcome at combat ceiling. The threshold is checked before each atomic heal: if below threshold a single heal may cross it, but cannot exceed ceiling. An additional heal while above threshold is rejected. No ordinary self heals/lifesteal in Blood Demon; Blood Life remains normal. Rare 55% seal disables all in-combat healing; shield 60% effectiveness. Sacrifice costs 10/12% current HP, nonabsorbed, cannot self-kill and must meet AI safety gate; spent HP is not a damage packet. Two valid Blood Marks activate one 5s frenzy (strongest only, family ICD35s). Divine ultimate scales 4200% × (1+1.2×min(0.8,1-current_hp/base_max_hp)), capped 8232% before eligible separate bonuses.

### Guard, shields and fatal save

Finite shields per recipient and PvE/PvP rule set, sorted deterministic consumption. A lethal-save grant is evaluated before downing, cannot revive Injury; apply per-recipient family cooldown 90s even if multiple sources offer protection. Guard/reflection acts only on committed incoming real damage; no chain transfers. Shield transfer/absorb must not count as free healing.

## 3. Boss encounter authoring

~~~json
{
  "boss_id":"tmb.boss.cuu_tieu_kiep_long",
  "spawn_generation":17,
  "zone_realm_index":30,"zone_floor_index":10,
  "fight_kind":"challenge",
  "phase_thresholds":[0.70,0.35],
  "max_summons_alive":4,
  "skills":[
    {"id":"tmb.bossskill.cuu_tieu_kiep_long.ultimate","cooldown_s":48,"telegraph_s":3.7,"hits":4,"ratio_per_hit":1.60,
     "interruptible":true,"break_gauge":350,
     "counterplay":["geometry_safe_zone","shield","destroy_pillar","break"] }
  ],
  "balance_status":"candidate"
}
~~~

Each ability must additionally authorize safe geometry, target selection, a fallback on no target, finite sustain, release/interrupt/retreat, return of cooldown, and cast-packet accounting. Phases are idempotent: phase_70_done and phase_35_done persist for a living spawn and never reset upon heal. Summons have parent boss and generation and do not award extra boss loot. Breakbar is not globally hard-on for every boss.

Existing MapBattleV2 constant MAX_SECONDS=90 in non-continuous mode; introduce separate BossEncounter duration policy (candidate 150–240s) without altering historical finite-pilot semantics. Step uses deterministic 0.25s now; avoid phantom extra damage from rounding up fast ticks.

### Endgame numeric candidate policy

Actor stats derive from CombatStatsV2 and both realm/body tracks with G = pow(1.65,realm-1)*pow(1.03,floor-1). Boss stats use authored level/floor zones, NEVER scale to party strongest member at runtime. Divine level 30-10 Thái Sơ Pháp Tắc Đế candidate HP 40.16 billion, DEF ~3.5x equal-level baseline disciple ATK, DR18%; **fixture only**. Formal tuning requires event simulation with source + logs, later Godot headless and visual endgame validation.

## 4. Invariants and perf

- All IDs unique; missing descendant fields => invalid content, not a zero-damage skill.
- Max six per team, max30 per cluster; world monster pilot MAX_MONSTERS=40 and AoE limit are compatibility constraints, not automatically sufficient for new 6–10 target skill definitions. Profile before lifting.
- No always-on per-frame scans over 1000–3000 historical learned skills or inactive technique triggers.
- All effects have owner, cast, reason, ICD, max targets and max chains. Visual particles never own game damage.
- Save writes idempotent; reward receipt acknowledged after persistent save barrier, no duplicate on reload/offline.
- Feature gates guard combat, codex and learning independently. Test each gate OFF on legacy fixtures.
