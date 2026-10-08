# P2.5 — Combat Skills / Real-time Auto Combat

Status: IMPLEMENTED / AWAITING RUNTIME GATE

> **V2 authority note (2026-10-08):** This file remains historical/runtime compatibility authority for P2.5. Future combat-skill/loadout/mastery/AI design is superseded by `docs/COMBAT_SKILLS_V2_SPEC.md`. The P2.5 starter library and “all learned skills eligible” model are not final V2 authority.


## Purpose

P2.5 replaces the P2.4-era abstract hit-trading loop with a deterministic real-time combat simulation when P2.5 is explicitly enabled.

The player does not manually press combat skills. Disciples fight autonomously on the map. The simulation remains gameplay authority; presentation only renders emitted combat events later.

P2.4 and earlier factories remain behavior-identical because the legacy combat path is kept intact while `combat_skills_enabled == false`.

## Locked design boundary

P2.5 models only the information that creates visible gameplay consequence:

- combat time in seconds;
- distance between disciple and monster;
- approach / keep-distance movement;
- melee versus ranged basic attacks;
- independent combat skills;
- cast time;
- cooldown;
- projectile travel time where relevant;
- short-lived guard / burn / weaken effects;
- autonomous skill choice;
- retreat, victory and defeat;
- a bounded combat event trace returned by the encounter resolver.

P2.5 does NOT simulate frame-perfect weapon collisions, animation hitboxes, ragdolls, per-pixel projectiles, detailed terrain collision or action-game dodging.

## Technique, realm and combat skill are separate systems

P2.3 technique/cultivation manuals are not combat skill kits.

- Technique = cultivation foundation and passive resonance.
- Realm = what level of combat skill the disciple is capable of learning/using.
- Combat skill = an independently learned action used during combat.

A technique does not automatically grant five moves. A disciple may learn combat skills from different paths and elements.

P2.5 intentionally does not lock a final long-term skill-slot count. Every learned P2.5 skill is currently eligible for autonomous use; a future preparation/loadout phase can add slot rules without rewriting combat resolution.

## Initial combat skill library

The first library is a vertical slice, not a total-game limit.

### Sword

- `Thanh Phong Trảm` — fast melee sword strike.
- `Truy Phong Bộ` — mobility skill that closes distance quickly and deals a light strike.
- `Ngự Kiếm Thuật` — Foundation-stage ranged sword projectile.

### Body

- `Chấn Sơn Quyền` — heavy melee strike that briefly weakens the monster.
- `Kim Cương Hộ Thể` — temporary incoming-damage reduction.
- `Bất Động Thân` — Foundation-stage stronger defensive state.

### Spell

- `Hỏa Cầu` — ranged projectile that applies burn.
- `Hàn Sương Ấn` — ranged control spell that weakens the monster.
- `Liệt Diễm` — Foundation-stage fire burst that gains extra damage against a burning target.

Skills declare their own path, element, minimum cultivation stage, range, cast time, cooldown and concrete effect data.

## Realm gate

Combat skill requirements use the existing P2.1 cultivation stage index.

A disciple can learn/use a skill only if their current cultivation stage meets the skill requirement. This makes realm progression expand capability without making the realm automatically grant a skill.

## Real-time encounter model

P2.5 encounters resolve synchronously inside one simulation action but use an internal deterministic time line.

- fixed simulation quantum: 0.25 seconds;
- bounded encounter duration: 45 seconds;
- actor and monster begin separated by a small distance;
- each side moves according to its desired range;
- basic attacks and skills have independent ready times;
- casting consumes time;
- projectiles land only after deterministic travel time;
- the monster can continue moving/attacking while a disciple is casting or a projectile is travelling.

This is real-time simulation, not a turn/round system. The fixed quantum is an implementation detail and is not tied to rendered frames.

## Path combat identity

P2.5 uses the active technique path only to shape autonomous spacing/basic style, not to decide which skills are legally known.

- Sword: fast movement, close-to-mid range, faster basic attacks.
- Body: shortest range, slower heavy basics, naturally comfortable in contact.
- Spell: prefers distance and uses a ranged basic attack.

Independent combat skills can still cross these styles.

### Combat path growth

P2.4 combat XP amounts remain unchanged: +4 for a win and +1 for retreat/defeat.

Under P2.5, that combat XP follows what the disciple actually used in the fight:

- count combat skills by their Sword/Body/Spell path;
- award the encounter's combat path XP to the most-used skill path;
- ties resolve deterministically by stable path order;
- if no combat skill was used, fall back to the P2.4 active-technique path rule.

This prevents a disciple from repeatedly casting Spell skills while incorrectly growing Sword history merely because a Sword cultivation technique is active.

## Resonance and expertise

Combat skill strength is affected by systems that already exist:

- spiritual-root element affinity modifies the skill effect;
- P2.4 accumulated expertise in the skill's own path modifies the skill effect;
- matching the active technique path gives a small technique resonance bonus;
- matching both technique path and element gives an additional small resonance bonus.

None of these are hard learning restrictions.

## Autonomous combat AI

The disciple chooses from legal ready skills deterministically.

Utility considers:

- whether the target is in range;
- own HP and survival bias;
- expected damage;
- defensive value while wounded;
- burn/weaken synergy;
- whether a mobility skill solves a range problem;
- whether a high-value skill would be wasted.

Ties are resolved by stable skill id order. Skill selection consumes no new RNG stream.

Existing encounter RNG remains responsible for monster selection and damage spread.

## Effects kept intentionally small

P2.5 includes only:

- direct damage;
- movement/reposition;
- guard;
- burn;
- weaken.

There is no global Kiếm-thế / Chiến-ý / combat-mana bar. A later individual skill or technique may introduce a special resource only when that resource creates a distinct build.

## Combat event trace

P2.5 encounter results include a bounded local event trace containing simulation-facing events such as:

- move;
- basic attack;
- cast start;
- skill hit;
- projectile launch/hit;
- buff/debuff;
- retreat;
- victory/defeat.

The trace is not persistent state and is not saved mid-combat. It exists so future Godot presentation can animate what the authoritative simulation already resolved.

## Compatibility

- `P24Factory` remains combat-skill-disabled and uses the exact legacy resolver.
- `P25Factory` creates a full P2.4 state, then enables combat skills.
- no P0 money changes;
- no P2.3 spirit-stone source/sink changes;
- no master/disciple mechanics;
- no combat skill automatically appears from technique level.

## Verification contract

1. Full P0 through P2.4 gate chain must PASS first.
2. P24Factory must remain combat-skill-disabled and preserve legacy combat behavior.
3. P2.5 combat skill learning must obey realm requirements but not path/element hard-locking.
4. P2.5 combat path XP must follow the dominant path of skills actually used, with P2.4 fallback when no skill is used.
5. Learned skills and the sect combat-skill flag/counter must survive save/load.
6. Same-seed P2.5 simulations must remain deterministic.
7. Sword, Body and Spell must produce measurably different spacing/basic behavior.
8. Projectile travel time must delay impact rather than act as instant melee damage.
9. Guard must reduce real incoming damage.
10. Burn and weaken must alter real combat outcomes.
11. Fire combo behavior must make `Liệt Diễm` stronger against a burning target.
12. Spiritual-root affinity and P2.4 path depth must measurably affect a matching combat skill.
13. Combat traces must remain bounded.
14. P0/P1/P2.1/P2.2/P2.3/P2.4 invariants must remain green.
15. P2.5 interaction scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-5.cmd`.

## Explicit exclusions

P2.5 does not add master/disciple relationships, equipment/artifacts, pets, formations, full party-combat V2, multi-monster encounters, bosses/factions, PvP, secret realms, frame-perfect dodge/hitbox simulation, terrain projectile collision, a universal combat resource, a final skill-slot system, or a separate skill-level/material economy.

Real AOE is deferred until multi-target combat exists; adding an AOE label without multiple targets would have no gameplay consequence and is therefore intentionally excluded from this phase.
