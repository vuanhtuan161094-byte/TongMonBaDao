# Godot live attempt evidence — 2026-10-27

RC source: remote PR #52 HEAD 0bc96348e6ef1a2eb945e9713e3faeb8912fb07d; tree 485d79b3060f22a8b552b52c3e0352f34ccaefb1. Local staging HEAD was synthetic 8ec30dfbc5734730a01ea7c3fbfb7e0763da6aad with matching tracked tree. These logs are tree-equivalent evidence, not an exact-Git-SHA checkout run.

- [Live attempt report](GODOT_LIVE_ATTEMPT_20261027.md)
- [Stage A install output](STAGE_A_INSTALL_CAPTURED_OUTPUT.txt)
- [First GUI parse-error log](P3_2_GUI_first_start_parse_error.log)
- [Headless editor import log](GODOT_headless_import.log)
- [P3.2 ready log snapshot](P3_2_GUI_ready_snapshot.log)
- [Process resource sample; not FPS](GUI_PROCESS_RESOURCE_SAMPLE.csv)
- [Stage A before hashes](STAGE_A_before_SHA256.csv)
- [Stage A after hashes](STAGE_A_after_SHA256.csv)
- [Local evidence SHA-256 manifest](LOCAL_EVIDENCE_SHA256SUMS.csv)

Stage A install-only passed: expected package SHA-256, .NET fallback used, 42 PNGs, before/after file hashes identical. Headless import exit 0. The GUI runner reported P3.2 runtime ready with 130 disciples, but manual gameplay, Save/Return/Load, screenshots/video, FPS logger OFF/ON, focused regression and canonical exact checkout remain pending.
