# Song Nhận Đoạt Ảnh R1 — contract and actor/socket evidence

This is a source-only art packet. No shared catalog, ledger, presentation manifest, runtime, workflow, inventory, actor, or PvE file was edited.

## Current lock and runtime contract

The 19 November production lock selects `tmb.skill.dual_blade.anh_nhan.active_02.human` — Song Nhận Đoạt Ảnh — as `damage / single_target / target_limit 1`, with twin-blade/two-beat VFX but no added hit.

Current source files read:
- `docs/operations/vfx_school_ledgers/07_dual_blade_183.csv`
- `godot/data/combat/v63_dual_blade_combat_catalog.json`
- `godot/data/presentation/v63_dual_blade_presentation_manifest_v1.json`
- `docs/operations/TMB_VFX_12_SCHOOL_BATCH_PRODUCTION_LOCK_20261119.md`

The exact current Human catalogue row is:

| Field | Value |
|---|---|
| Effect / shape / target limit | `damage / single_target / 1` |
| Hit count | `1` |
| Damage ratio | `1.25` |
| Range | `2.6` |
| Cast time | `0.4 s` |
| Cooldown | `12 s` |
| Projectile speed | `0` |
| Duration / radius / power | `0 / 0 / 0` |
| Element | `metal`, candidate lore pending authentic codex |
| Health cost | `0` |
| Candidate status | `CANDIDATE_GATED_SOURCE_PENDING` |
| Release gate | `OFF` |

The presentation brief names crossed dual-blade arcs, silver/cinnabar/jade palette, weapon-tip and target-center anchors, and a direct cast without travel event. It calls for a left/right visual sequence but the runtime row has `hit_count=1`; therefore this packet draws no separate contact points or damage marks for the two afterimages. Contact is represented by one shared focal cue. There is no HP-cost/status cue for this Human row.

## Receipt path inspected

`V63HumanSkillCombatSystem.try_cast` routes dual-blade candidates through `V63DualBladeSkillCombatSystem.can_cast`. The Dual Blade adapter delegates release to `V63HumanSkillCombatSystem.release_cast_base`. That release path uses the catalogue `hit_count` for dual-blade damage and emits `v63_dual_blade_hit` only when a real strike settles positive damage. With this row’s `hit_count=1`, the expected receipt is one target and one committed hit.

This was a source-code inspection only. No focused runtime test was run for this Human ID in this source-only task.

## Two-weapon actor/socket gate

Available character evidence is not a verified production-ready two-weapon actor:

- `AS52` and `AS53` are four-direction, six-action, 384 px body-only recreated candidates; each metadata record says `status=CANDIDATE`, `source_status=RECREATED_CANDIDATE`, and `body_mode=one monolithic full-body RGBA cel, no rig`.
- Both actor records say no held weapon or VFX is baked, the twin scabbards are costume details, and separate twin-saber overlays plus per-frame grip metadata are pending.
- The paired `dual_dao_left.png` / `dual_dao_right.png` candidate props exist.
- `AS52_weapon_sockets_v9_3_candidate.json` and `AS53_weapon_sockets_v9_3_candidate.json` each have candidate main/off-hand attachments and 96 per-frame entries, but their status is `CANDIDATE`, owner art approval is `PENDING`, and `proxy_visible_in_production=false`. Their anchors are candidate skin-region detections with fallback markers.

Because the actor overlays and per-frame grips remain unverified, no scene, actor, socket, or renderer was created. The source sprites are not claimed to attach to an actor or to demonstrate timing in Godot. A native scene needs a verified two-weapon actor/socket plus a focused positive `v63_dual_blade_hit` receipt for this Human ID. Keep V6.3/PvE OFF.
