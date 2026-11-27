# MAP01 — approved land allocation (2026-11-27)

Owner-approved A+B palace compound / management layout. Allocation is a target share of usable estate area, not a building cap.

| District | Share |
| --- | ---: |
| Production (fields, forest, mines, storage, forge, alchemy) | 45% |
| Disciple residential expansion | 30% |
| Cultivation and body training | 10% |
| Main Hall | 8% |
| Central court and expedition gate | 7% |

Acceptance requirements:
- Production and residence together occupy 75% of usable estate area; measure actual zone geometry, not number of buildings or decorative perimeter.
- Reserve contiguous expansion space, lay out repeated building instances within their respective districts, preserve canonical instance IDs and production behavior.
- Retain actual paid residence construction, persisted coordinates, save/reload and access paths. Do not silently relocate an existing saved house or overlap its footprint. If a layout migration is needed, preserve legacy maps or implement an explicit tested migration.
- Vacant plots use continuous paving; show plot outlines only in planning/build mode. Forest stays at the exterior. Fixed landmarks remain recognizable. Hall and expedition gate form the civic axis.
- Overview camera fits all principal districts; district focus allows detailed inspection. Keep approved art and avoid detached tiny shadows.
- Current 3198bfb prototype does NOT yet demonstrate these area shares or expanded producer placement. No artistic acceptance before inspecting exact-SHA Godot captures and verifying new construction plus existing saves.
- No rig, Codex Cloud, merge, new AI images required; reuse art and only use outside assets with appropriate license.
