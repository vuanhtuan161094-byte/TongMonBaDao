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
