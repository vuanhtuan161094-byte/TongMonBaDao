# Kiếm Linh Thỉnh Kiếm — source feasibility R1

**Checked checkout:** `integration/pve-p0-playable-ui-20261103` at `cde55abb138d150d39e0eadce7a487c68e841fb7`
**Skill:** `tmb.skill.summon.kiem_linh.active_01.human`
**Status:** `G0_CONTRACT_VERIFIED`; `SUMMON_SOURCE_BLOCKED`; G3/G3.5 not started; owner review pending; `HOLD_V63_OFF`.

## Canonical contract

The combat catalog defines Kiếm Linh Thỉnh Kiếm as `effect=summon`, `shape=single_target`, `target_limit=1`, `form=blade_spirit`, `behavior=ranged`, element `metal`, range 7, cast 0.55 s, cooldown 25 s, and projectile speed 0. Its candidate profile proposes an 18 s actor, 0.6 owner-HP ratio, 0.72 owner-damage ratio, 1.9 s attack interval, 5.0 attack range, and 0.9 move-speed ratio. These are unapproved candidate runtime values. `source_codex_id` is empty, candidate status is `CANDIDATE_GATED_SOURCE_PENDING`, and the V6.3 release gate remains off.

## Actor and source findings

- `godot/src/simulation/combat/v63_summon_skill_combat_system.gd` can create a real bounded simulation actor from an authorized summon cast. The actor carries `is_v63_summon`, `summon_form=blade_spirit`, owner and expiry fields; successful creation emits `v63_summon_created`. No synthetic combat actor was created in this review.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd` consumes real summon lifecycle events, but currently represents `blade_spirit` with a procedural polygon and lines. The presentation manifest calls this a code-drawn event cue and still requires exact-SHA rendering; it is not a sword-spirit sprite source.
- The weapon library contains `owner_liked_jian_existing`, an 887×1774 held-weapon candidate at `godot/assets/p3/baked_candidates/aschar48/AS48_KIEMTU_JIAN_CANDIDATE.png` (SHA-256 `8c9869ba06e39799c5eb3b6b2e3060284c04197abc034993b1831f1572c60285`). Its binding metadata labels it `EXISTING_CANDIDATE_PRESERVED`, sourced from the AS48 Kiếm Tu family, with owner approval pending. It is a held prop, not an independently animated summoned actor, so it was not rebound or altered.
- The library's `summon_contract.png` and `summon_seal.png` are held-focus props, not the `blade_spirit` actor. Existing Sword VFX atlases depict energy effects; they do not supply a real, animated physical sword actor. I found no source manifest for an independently animated, rights-cleared sword-spirit master.

## Gate decision

The runtime actor/event path exists, but the matching summoned-actor art source does not. Reusing an unapproved held weapon or drawing a new sprite would claim an actor identity and animation that the current sources do not establish. I therefore stopped before G3 and recorded `SUMMON_SOURCE_BLOCKED`; no art, LAB, renderer change, or gameplay event was invented. Existing weapon and Sword assets remain untouched.

To unblock, provide or author a rights-cleared frame-by-frame physical sword-spirit master, then review the source at 1× before binding it to the real created/attack/expired actor lifecycle in an isolated LAB. Keep source/art approval separate from event-path TECH PASS and keep PvE off.
