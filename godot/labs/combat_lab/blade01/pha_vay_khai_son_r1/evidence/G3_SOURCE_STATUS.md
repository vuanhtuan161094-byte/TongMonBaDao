# Phá Vây Khai Sơn R1 — source gate status

## Scope and canonical mechanics

- Candidate: `tmb.skill.blade.cuong_dao.active_01.human` — Phá Vây Khai Sơn · Nhân Giai.
- Canonical effect remains `damage`, `single_target`, `target_limit=1`, `hit_count=1`, metal, projectile speed 10. Catalog values inspected read-only: damage ratio 1.35, range 8, cast 0.28 s, cooldown 8 s.
- Art intent only: compressed charge → one broad, heavy, red-bronze metal crescent traveling forward → compact contact glint after a real single-target hit receipt → two separated fading fragments. No area wave, repeat hit, ring, invented target, or damage logic is introduced by these sources.

## Source self-review

`SOURCE_SELF_REVIEW = PASS / recommend owner review` across silhouette at 1×, school distinction from thin Sword qi, phase separation, metal/red-bronze material, restraint, and dark/light contrast. Each phase scored at least 4/5 by the author. See `review/*_1x_dark_light.png` and `review/*_1x_manifest.json`. The four sheets were generated with `tools/vfx/prepare_g3_source_review.py`; its output is source-scale evidence only and says `ART=MANUAL_PENDING`.

`FORMAL_G3 = PENDING HUMAN/OWNER ART REVIEW`. The self-review does not grant owner approval. `OWNER_ART_APPROVAL = PENDING`.

## Native / actor gate

`NATIVE_G3_5 = NOT RUN / BLOCKED`.

The candidate weapon-family binding does list AS-CHAR-50/51 as DAO families and a `curved_dao` candidate asset. However, the AS50 attack manifest labels its attack as body-only and states the saber concepts are not clean production overlays; the AS51 manifest says `NOT_ATTACHED` and DAO socket metadata is pending. The family/binding and socket files remain candidate status. There is no verified single-DAO overlay attached to a matching attack animation, so no actual actor weapon-tip source is available for a LAB preview.

The candidate test source `godot/tests/simulation/v63_s2_blade_skill_test.gd` contains a fixed-fixture Combat V2 active_01 hit/mark path, but it was not run here and is not a captured moving-target receipt. The presentation manifest identifies the travel phase as `event_type: none` and says the renderer does not currently construct a moving projectile. No native moving-target receipt was found for this candidate. No scene, rig, fabricated actor, hit, or PvE test was created/run.

Reference paths (read-only evidence):
- `godot/data/combat/v63_blade_combat_catalog.json` (candidate row; source still pending).
- `godot/assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json` (`CANDIDATE`; DAO family and `curved_dao` library entry).
- `godot/assets/p3/baked_candidates/aschar50_candidate/AS50_idle_front_manifest_SOURCE_933_SNAPSHOT.json` (body-only attack; weapon overlay pending).
- `godot/assets/p3/baked_candidates/aschar51_candidate/AS51_FRONT_CLIPS_manifest_SOURCE_933_SNAPSHOT.json` (overlay not attached; socket metadata pending).
- `godot/tests/simulation/v63_s2_blade_skill_test.gd` (test source only; not executed as this task's moving-target evidence).
- `godot/data/presentation/v63_skill_presentation_manifest_v1.json` (travel phase pending/no moving projectile renderer).

## Runtime and owner status

- `PvE = HOLD_V63_OFF`.
- No shared catalog, ledger, inventory, workflow, gameplay, or other-school files changed.
- No Godot/native test was run. No scene was authored because the matching verified single-DAO actor/weapon and moving-target receipt gate is unsupported.
