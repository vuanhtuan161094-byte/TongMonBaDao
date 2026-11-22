# Tông Môn Bá Đạo — Disciple Source A retirement and AS-CHAR visual flow (22/11/2026)

**Scope:** One Game PR #72, disciple presentation only. Explicit owner request supersedes Source A disciple starter fallback.

- Removed the five Source A disciple actor asset folders: `1113028_1`, `body_1110201`, `body_1120402`, `v5_sa_female_1113028_1`, `v5_sa_male_body_1110201`. Historical commits retain provenance; no destructive git history rewrite.
- Kept Source A **monster**, **Boss**, vegetation and buildings. The V5 manifest no longer offers `disciple_male` or `disciple_female`.
- **At generation/recruitment:** no school branch assignment. Each existing `DiscipleState` selects an authored AS48–AS71 starter appearance deterministically from `profile_seed` (or saved identity fallback), restricted to its actual sex. No UI reroll and no Source A escape hatch.
- **When a player chooses a real 12-school/36-branch ID:** the same sex's AS-CHAR school art replaces starter art immediately in the live map. The existing one-time branch, at-sect/PvE restrictions, Combat V6.3 OFF gate and SaveService state remain authoritative.
- **Consistent presenters:** One Game map actor, portrait (recruit/profile/workers/roster), CARE/Combat V5, open-world PvE all derive art from the same `SectASCharCandidateBridgeV1.visual_school_for_disciple` view-only selector. Source A fallback is limited to monster/Boss rendering.
- **Compatibility:** old saves without assigned branches derive a stable starter visual without schema migration. The visual choice is not a new gameplay field and has no impact on combat, skills, AI, economy or Save.
- **Visual approval:** AS-CHAR art remains candidate/owner review as recorded; technical/contract tests do not imply physical Windows/Android approval. No rig, no Codex Cloud, no automatic PR merge.

Focused regression: `godot/tests/presentation/aschar_game_school_selection_test.gd`, `aschar_pve_renderer_test.gd`, `aschar_pve_cold_save_reload_test.gd`, `b3_care_combat_v5_presenter_test.gd`, P3.2 live modular map and live save tests.

## CI repair follow-up — 22/11/2026

- Removed the last runtime calls to deleted `DiscipleSourceAVisualPool` in **DaiDienScreenV1** and **DanTienScreenV2**, and use `SectASCharCandidateBridgeV1.preview_texture_for_disciple` for official Hall and recruitment portraits.
- The JX alternate PvE viewer now derives every disciple's `aschar_school` and `aschar_sex` from canonical disciple state; historical `source_a_visual_key` cannot restore a retired disciple actor. Monster/Boss Source A remains unaffected.
- Updated P3.2 live-map regression to assert the AS-CHAR baked sprite, instead of the retired Stage A visual requirement; expanded real-game AS-CHAR screen smoke assertions.
- This is a presentation/test repair only. No changes to candidate birth generation, combat, economy, Save schema, VFX, animation rigging, or PR merge policy. Godot/CI outcomes remain exact-SHA gated.

### B1 adapter final retirement audit — 22/11/2026

- Scanned all 97 GDScript files under `godot/src/presentation`; B1 adapter was the remaining runtime caller of removed `DiscipleSourceAVisualPool`.
- Hall, recruitment candidate and recently recruited disciple B1 data now resolve from the same AS-CHAR bridge and canonical `DiscipleState`.
- B1 recruitment displays available candidate frames, labels them awaiting owner art approval and does not set `source_art_approved=true` merely because a texture loads.
- Legacy Source A use by monster/Boss and environment is retained. No Save, combat, economics or art asset rewrite.
