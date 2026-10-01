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
4. `docs/P2_7_DISCIPLE_LIFE_WORKFORCE_SPEC.md`
5. this file

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

- **最强祖师** -> personality/traits, multidimensional disciple value, production specialization, low-combat disciples still useful;
- **The Lost Village** -> work assignment, group/position preferences, work/cultivation/recovery scheduling;
- **鬼谷八荒** -> sect rank, elders, halls/departments, delegation and task authority;
- **Sect Master / 宗门经理人** -> autonomous expedition -> warehouse -> production -> disciple build -> harder expedition and personal-spirit-stone economy.

Do not copy fixed classes, gacha rarity logic or grind structures just because a reference game has them.

## Architecture correction required before/inside P2.7

P1.5 currently has `role_assignments` with `hunter / logistics / guard`.

Do NOT add sect rank or production profession into this same semantic bucket.

Must separate:

1. `sect_rank` — outer / inner / core / deacon / elder / hall master / ...
2. `profession_xp` and work specialization — forging / alchemy / herbalism / mining / logistics / ...
3. combat/adventure role — existing team behavior or future tactical role.

A disciple can simultaneously be:

`Inner disciple + Forging specialist + Hunt-team member`.

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

### Recruitment update

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

## Anti-patterns to avoid

- one overloaded `role` field;
- fixed profession classes;
- assigned work that makes disciples work forever and never cultivate/recover;
- adding 10+ professions before two professions have real consequences;
- making player click each disciple for repetitive routine management;
- decorative aptitude/trait labels without measurable effects;
- AI replacing an active direct Sect Master order.

## Status

P2.7 is **DESIGN CANDIDATE / NOT IMPLEMENTED**.

The research/design direction is now written into the repository, so future chats should continue from it rather than re-deriving the reference-game plan.
