# P2.4 — Cultivation Paths / Character Dao Direction

Status: IMPLEMENTED / AWAITING RUNTIME GATE

> **V2 authority note (2026-10-08):** This file remains historical/runtime compatibility authority for P2.4. Future Chủ Đạo / branch / path-history design is superseded by `docs/CULTIVATION_PATH_V2_SPEC.md`. Legacy bounded path XP and generic path stat bonuses are not V2 authority.


## Purpose

P2.4 turns the `path` tags introduced in P2.3 into accumulated character history. A disciple is not assigned a class. Their path identity emerges from the techniques they actually use while cultivating and fighting.

## Paths

Initial paths:

- `sword` — Kiếm;
- `body` — Thể;
- `spell` — Pháp.

Every disciple stores bounded numeric XP for these three paths only.

## Experience sources

The active technique determines which path receives experience.

- successful CULTIVATE action: +10 path XP;
- combat win: +4 path XP;
- combat retreat/defeat: +1 path XP.

Changing active technique changes which path grows. Existing path XP never resets or decays in P2.4.

## Derived identity

No `class` or fixed `path_id` is stored.

Identity is derived from accumulated history:

- below 100 total XP: `Chưa định hình`;
- top path >=65%: `<Path> tu`;
- otherwise, if second path >=25%: `<Path A>–<Path B> song tu`;
- otherwise: dominant path with mixed history.

Examples:

- 700 Kiếm / 300 Pháp -> Kiếm tu;
- 600 Kiếm / 400 Pháp -> Kiếm–Pháp song tu.

## Real consequences

Path depth reaches full P2.4 effect at 1,200 XP and is clamped to 0..1.

### Shared same-path technique expertise

A technique whose path matches accumulated experience receives up to +20% effect strength at full depth. This is applied to the active technique's real cultivation/combat/breakthrough consequences rather than to a display score.

### Kiếm

- up to +4 intrinsic effective combat power;
- increases autonomous HUNT utility by up to +18.

### Thể

- up to 12% intrinsic incoming-damage reduction;
- increases HUNT utility by up to +5;
- increases REST utility by up to +5.

### Pháp

- up to +12% intrinsic cultivation gain;
- increases autonomous CULTIVATE utility by up to +18.

The same-path technique expertise stacks multiplicatively with the relevant P2.3 technique effect, but P2.4 does not stack multiple active techniques because P2.3 still permits only one active technique.

## Switching and mixed development

Switching active technique does not erase old path XP. A disciple can therefore evolve naturally from one dominant path into a mixed identity and eventually another dominant path.

P2.4 intentionally has no respec button, no instant class switch, no permanent class lock and no hard restriction on learning techniques from other paths.

## Compatibility

- `P23Factory` remains path-disabled.
- `P24Factory` creates the full P2.3 state, then enables path tracking.
- Earlier behavior remains unchanged while `cultivation_paths_enabled == false`.
- No new RNG stream is needed for path progression; XP is a deterministic consequence of already-resolved actions.
- P0 money and the P2.3 spirit-stone economy remain unchanged.

## Scale

- exactly three numeric path XP values per participating disciple;
- O(1) lookups per action/combat calculation;
- no N x N structure;
- no population-wide path scan during decisions.

## Verification contract

1. Full P0 through P2.3 gate chain must PASS first.
2. P23Factory must remain path-disabled and have no P2.4 effect.
3. Cultivation and combat using a Sword technique must add Sword XP only.
4. Switching to a Spell technique must add Spell XP without erasing Sword history.
5. 70/30 history must derive a primary identity; 60/40 must derive a mixed identity.
6. Two otherwise equivalent disciples using the same Sword technique must differ in effective combat power when one has deep Sword history.
7. Deep Body history must reduce real incoming-damage multiplier.
8. Deep Spell history must increase real cultivation gain.
9. Path depth must measurably change autonomous action utility.
10. Path XP and sect path flag/counter must survive save/load.
11. Same-seed P2.4 simulation and post-load continuation must remain deterministic.
12. P0/P1/P2.1/P2.2/P2.3 invariants must remain green.
13. P2.4 interaction scene must launch on Godot 4.7.2.

Authoritative command: `Sync-P2-4.cmd`.

## Exclusions

P2.4 does not add master/disciple relationships, technique teaching by masters, combat skills/moves, weapon equipment, Dao comprehension events, special physiques, pills, tribulations, secret realms, bosses/factions, or additional paths such as alchemy/formations/beast-taming. Those require later phases with real gameplay consequences.
