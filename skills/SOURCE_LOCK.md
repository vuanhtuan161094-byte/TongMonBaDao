# Godot Skill Source Lock

Pinned upstream:
- repository: `vl4dt/godot-skills`
- commit: `1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0`
- license: MIT
- compatibility: Godot 4.x including 4.7

Selected for this project:

Core from the previous Tu Tiên Nhàn Dỗi workflow:
- godot-architecture
- godot-headless-workflow
- godot-debugging
- godot-code-review
- godot-ui
- godot-animation
- godot-shaders-vfx

Added for this simulation-heavy tycoon:
- godot-project-setup
- godot-gdscript-patterns
- godot-state-management
- godot-inventory-economy
- godot-save-systems
- godot-performance

Stagehand remains a separate pinned tool:
- repository: `mrf/godot-stagehand`
- tag: `v0.4.1`
- commit: `82c6cb96f3cccb067081db17f4c4c8582562e98b`

Rule:
never silently track upstream `main`. Update only by explicit pinned commit after review.
