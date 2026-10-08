# P2.1 — Cultivation + Realms + Breakthrough

Date: 2026-09-30
Status: IMPLEMENTED / AWAITING RUNTIME GATE

> **V2 authority note (2026-10-08):** This file remains historical/runtime compatibility authority for locked P2.1 regression behavior. Future Disciple V2 cultivation and breakthrough design is superseded by `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` together with `docs/REALM_LADDER_V2_SPEC.md`. Do not extend P2.1 breakthrough consequences into new V2 gameplay.

Baseline: P1.6 implementation on `a4fe78a8f94d774f9351aaf3b02fd78ad1aaee08`

## Goal

Add the first real cultivation progression loop without introducing spiritual roots, techniques, pills or other later systems.

The mandatory gameplay chain is:

`CULTIVATE -> gain cultivation -> reach threshold -> BREAKTHROUGH -> gain realm power/HP -> later decisions and combat change`

P2.1 is invalid if realms are only names or progression bars.

## Cultivation state

Each disciple stores:

- cultivation stage index;
- cultivation progress;
- realm combat bonus;
- realm HP bonus;
- player directive;
- breakthrough failure count;
- next legal breakthrough tick;
- latest breakthrough outcome.

The old `combat_power` field remains the disciple's base/intrinsic combat power. Realm power is additive and only becomes authoritative when P2.1 is enabled.

## Realms in this slice

P2.1 includes:

- Luyện Khí tầng 1–9;
- Trúc Cơ sơ/trung/hậu/viên mãn;
- Kim Đan sơ/trung/hậu/viên mãn.

The data table is extensible; later realms should be appended without replacing the core progression model.

## Cultivation sources

### Sect cultivation

- available at the sect;
- +8 cultivation per cultivation action;
- costs 12 stamina;
- stops adding progress once the current breakthrough threshold is reached.

### Combat victory

- +2 cultivation per victory;
- enough to allow slow growth from field experience;
- not enough to replace deliberate cultivation as the main progression path.

## Player directives

The player can set one directive per disciple:

- `balanced`;
- `cultivate`;
- `field`.

The directive changes utility weights. It never directly grants cultivation or a realm.

`cultivate` raises cultivation utility and reduces hunting preference.

`field` raises hunting utility and lowers cultivation preference.

Personality remains active: cautious/survival-oriented disciples value cultivation more than reckless disciples under otherwise similar conditions.

## Breakthrough

A breakthrough requires:

- current cultivation threshold reached;
- not already at the maximum P2.1 stage;
- cooldown completed;
- HP >= 75%;
- stamina >= 65.

Breakthrough success chance is stage-dependent with a small condition bonus.

### Success consequence

- stage advances by exactly one;
- current-stage cultivation threshold is consumed;
- realm combat bonus updates;
- max HP bonus updates;
- stamina is consumed;
- short cooldown prevents immediate repeated breakthroughs;
- success metric/event counter increments.

### Failure consequence

- realm does not advance;
- 20% of the required cultivation amount is lost;
- 18% max HP damage is taken;
- 40 stamina is consumed;
- retry is blocked for 90 ticks;
- failure counter increments.

Failure therefore changes future decisions and recovery needs; it is not a cosmetic random result.

## Realm consequences

### Combat power

When cultivation is enabled:

`effective combat power = base combat_power + realm combat bonus`

Effective combat power is used by:

- combat damage;
- region under-power evaluation.

Older P0–P1.6 paths keep using the old base power because cultivation is disabled in their factories.

### HP

Successful breakthroughs update realm HP bonus and max HP. Higher realms therefore survive field combat differently.

## AI consequences

P2.1 introduces two autonomous actions:

- `CULTIVATE`;
- `BREAKTHROUGH`.

Healthy disciples at the sect evaluate cultivation against hunting/rest/buying using personality, active goal and player directive.

A breakthrough-ready disciple may choose `BREAKTHROUGH` only when the safety requirements are met.

## Scale rule

P2.1 is O(1) per disciple decision:

- no cultivation graph;
- no population-wide realm scan;
- one stage lookup per disciple;
- one directive stored on the disciple;
- combat uses one effective-power calculation.

## Exclusions

P2.1 does not add:

- spiritual roots;
- talent/aptitude ratings;
- cultivation techniques;
- pills/elixirs;
- tribulations;
- master/disciple hierarchy;
- realm-specific skills;
- equipment scaling;
- secret realms;
- bosses/factions;
- combat-team V2.

These must build on the validated P2.1 progression loop rather than bypass it.

## Verification contract

1. Full P0 through P1.6 verification chain must pass first.
2. Same-seed P2.1 state and continuation must remain deterministic.
3. Player `cultivate` directive must be able to change a controlled action to CULTIVATE.
4. Player `field` directive must be able to change the same controlled action back to HUNT.
5. Personality must measurably alter cultivation utility.
6. Cultivation action must add progress and consume stamina.
7. Combat victory must add a smaller amount of cultivation.
8. Controlled breakthrough success must advance exactly one stage and increase realm power/HP.
9. Controlled breakthrough failure must preserve stage, lose cultivation/HP/stamina and create retry cooldown.
10. Higher realm effective power must change a controlled region choice.
11. Higher realm effective power must change a controlled combat outcome.
12. Cultivation state/directive/counters must survive save/load.
13. Continuation after save/load must remain deterministic.
14. Cultivation + existing needs/state invariants must remain green.
15. P2.1 interaction scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-1.cmd`.
