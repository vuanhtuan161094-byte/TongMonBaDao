# NEXT CHAT HANDOFF — Tông Môn Bá Đạo

Date: 2026-10-01

Always inspect live `main` before editing.

## Runtime status

Real Windows + Godot 4.7.2 cumulative gate is green through P2.6:

- P0-P1.6: PASS
- P2.1 Cultivation: PASS
- P2.2 Spiritual Roots: PASS
- P2.3 Technique Economy: PASS
- P2.4 Cultivation Paths: PASS
- P2.5 Realtime Combat + Independent Skills: PASS
- P2.6 Forge + Equipment Tycoon: LOCKED / PASS

P2.6 final evidence included persistence diagnostic, forge/equipment contracts, equipment combat-stat consequence contracts and interaction scene smoke.

## Read first

1. `AGENTS.md`
2. `CURRENT_CHECKPOINT.md`
3. `docs/GAMEPLAY_REFERENCE_SYNTHESIS.md`
4. `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md`
5. `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`
6. this file

## Core game identity

The player is the sect master, not an invisible city-builder cursor.

The player controls sect infrastructure, recruitment, policy, resource allocation, production and direct interventions when desired. Disciples should still feel like people who live inside the sect: they cultivate, work, hunt, recover, form relationships and make autonomous choices according to their own state.

Direct control is allowed where it makes sense for a sect master, but routine micromanagement should not be mandatory.

## Reference hierarchy now agreed

Primary operating rhythm: **Evil Hunter Tycoon**.

Use it for:

- autonomous characters moving/living/fighting;
- town/sect economy;
- production/service facilities;
- individual direct commands from the Chief/Sect Master;
- hunt -> materials -> production -> character consumption/growth loop.

Use the other games for narrower problems:

- **最强祖师** -> multidimensional disciple identity, traits/quirks, production professions and progression, low-combat disciples still useful;
- **The Lost Village** -> work assignment, group/position preferences, work/cultivation/recovery scheduling and its micromanagement pitfalls;
- **Amazing Cultivation Simulator** -> work priorities, schedule, mood/needs, inner-vs-outer opportunity cost, master-disciple effects, hall-master competence;
- **鬼谷八荒** -> sect rank, elders, halls/departments, delegation and task authority;
- **Sect Master / 宗门经理人** -> autonomous expedition -> warehouse -> production -> disciple build -> harder expedition and personal-spirit-stone economy;
- **修仙家族模拟器** -> condition-based automatic workforce assignment, stipend/loyalty economy, master-disciple and inheritance hooks;
- **我要当掌门** -> individual schedule and the rule that cultivation time must produce real progression;
- **RimWorld / Oxygen Not Included** -> scalable work priorities, per-character/group templates and task sub-priority for 50-100 autonomous agents.

Do not copy fixed classes, gacha rarity logic, spreadsheet modifier bloat or grind structures just because a reference game has them.

## Important observations from the user-provided 最强祖师 video

The disciple profile visibly separates:

- race, alignment, gender, lifespan, injury and loyalty;
- six base dimensions: aptitude/constitution/fortune/intelligence/charisma/potential;
- positive and negative traits/quirks, destiny and spiritual roots;
- eight separate production proficiencies: cultivation/farming, alchemy, commerce, talismans, forging, formations, husbandry and spirit-gathering;
- equipment;
- cultivation techniques/skills;
- artifacts;
- destiny progression;
- spiritual-root progression;
- detailed combat stats.

Design lesson: disciple life, production, cultivation and combat are independent axes. Do not collapse them into one class or overall score.

## Architecture correction required before/inside P2.7

P1.5 currently has `role_assignments` with `hunter / logistics / guard`.

Do NOT add sect rank or production profession into this same semantic bucket.

Must separate:

1. `sect_rank` — outer / inner / core / deacon / elder / hall master / ...
2. `profession_xp` and work specialization — forging / alchemy / herbalism / mining / logistics / ...
3. `work_group` / department assignment — forge hall / herb garden / mining group / ...
4. combat/adventure team + combat role — existing team behavior or future tactical role.

A disciple can simultaneously be:

`Inner disciple + Forging specialist + Forge Hall member + Hunt-team member`.

## Seven-layer disciple model

Future disciple state should conceptually separate:

1. identity/living state — HP, stamina, injury, later age/lifespan/mood/loyalty;
2. innate potential — personality, roots, later comprehension/constitution/fortune/charisma;
3. learned history — realm, technique mastery, Sword/Body/Spell XP, combat skills, profession XP;
4. traits/quirks — real behavioral/output consequences;
5. organization — sect rank, work group, combat team/role;
6. social identity — existing relationships/memories, later master-disciple/lineage;
7. current authority/intent — emergency, direct Sect Master command, schedule, assignment priority, personal goal.

## Authority order candidate

Use one reusable arbitration order rather than hard-coding each profession into DecisionSystem:

1. critical survival/emergency;
2. direct Sect Master command;
3. mandatory sect duty/event;
4. schedule block;
5. personal/group work priority;
6. personal goal/personality;
7. free autonomous fallback.

Direct commands are temporary overrides. They must complete/expire and return the disciple to autonomy.

## P2.7 design candidate

Working title:

**P2.7 — Disciple Life + Workforce + Sect Assignment**

Do not reduce it to “add several jobs”. It must establish one reusable authority model for later alchemy, fields, warehouse, commerce, halls, elders and master-disciple systems.

Core model:

`personal aptitude + profession XP + work priorities + schedule + group assignment + direct Sect Master command + autonomous fallback`.

### Suggested first vertical slice

- Mining task -> produces real Thanh Thiết into P2.6 forge storage.
- Forging work -> creates a real deterministic effect on P2.6 production.
- Repeated work -> profession XP -> measurable improved work efficiency.
- Schedule -> work cannot permanently suppress cultivation/recovery.
- Direct Sect Master command -> temporary override -> completion/expiry -> return to autonomy.
- Group assignment -> scalable defaults for many disciples.
- Personal override -> wins over group default.
- Candidate generation -> weak fighter can still be rationally valuable because of comprehension/profession talent.

## Recruitment update

Current recruitment mainly differentiates candidates by combat power + risk/spend/survival personality biases.

P2.7 should add enough non-combat information that the user can rationally recruit a weak fighter because they are valuable to the sect.

Candidate preview target:

- current combat potential;
- personality;
- spiritual root;
- comprehension/learning aptitude;
- 0-2 profession traits;
- optional flaw/quirk.

Do not collapse this into one overall score.

## Future systems after workforce is stable

Do NOT put these all into P2.7. They are research-backed candidates for later phases:

### Sect rank + contribution + promotion

- outer / inner / core / deacon / elder / hall master;
- contribution and privileges/duties;
- promotion chosen by Sect Master.

### Mood + loyalty + stipend economy

Strongly supported by ACS and 修仙家族模拟器.

Potential internal loop:

`sect treasury -> stipend/reward -> disciple wallet -> sect shops/services -> sect treasury`.

This preserves internal money conservation while making rank/loyalty/economy meaningful.

### Master-disciple + teaching

Supported by ACS and 修仙家族模拟器:

- mentor improves cultivation;
- same technique/path gives stronger bonus;
- mentor may help breakthroughs and transmit knowledge;
- teaching should consume mentor time.

### Lifespan/death/inheritance

Potentially very strong for generational stories, succession and training replacements, but only activate after pacing has been proven appropriate for this mobile/idle game.

## Current systems to preserve

- GoalSystem survival/personality layer.
- DecisionSystem top-level arbitration concept.
- P1.5 teams and leadership.
- P1.6 recovery/resource pressure.
- P2.1-P2.6 cultivation/build/equipment consequences.
- all P2.6 persistence/determinism/economy contracts.

## Systems to refactor/extend

- `OrganizationSystem`: separate combat role from workforce group and sect rank.
- `DecisionSystem`: do not add one hard-coded branch per profession; integrate a workforce/task authority layer.
- `RecruitmentSystem`: add non-combat aptitude and profession-relevant traits.
- add persistent deterministic direct-command state rather than implementing commands as UI-only side effects.
- design priority/group APIs for bulk management from the start.

## Anti-patterns to avoid

- one overloaded `role` field;
- fixed profession classes;
- one overall/rarity score deciding disciple value;
- assigned work that makes disciples work forever and never cultivate/recover;
- adding 10+ professions before two professions have real consequences;
- making player click each disciple for repetitive routine management;
- decorative aptitude/trait labels without measurable effects;
- AI replacing an active direct Sect Master order;
- activating loyalty + lifespan + master-disciple + workforce in one phase and blowing scope.

## Status

P2.7 is **DESIGN CANDIDATE / NOT IMPLEMENTED**.

Deep disciple research is now recorded in the repository. Future chats should read `docs/DISCIPLE_SYSTEM_DEEP_RESEARCH.md` before changing P2.7 scope.
