# Female Stage A — install-only recovery and exact-RC retest

- RC branch/head tested: integration/pve-unified-rc-20261027 / 4ba1ccad25c1d03053cefbc724c1a19287d4c0f3.
- Godot: 4.7.2.stable.official.ed1daf0bf.
- Installer transport package SHA-256 expected and observed: 6a4213b9129ffb3f438c21cbb5326672ddf8915323836bf80cb33b8e5fabfdca.
- Install-only result: PASS, exit 0; 42 canonical PNGs installed; required hair_01_down_back.png exists. The generated PNGs remain ignored local QA assets and are not in this archive.
- Sync-P3-2-Female-StageA.cmd was not run.
- The first stock installer attempt exited nonzero because child Windows PowerShell reported Get-FileHash unavailable. To complete the requested SHA-gated restore without weakening validation, a temporary equivalent .NET SHA-256 implementation was applied only during the isolated install-only run, then the installer source was restored byte-for-byte. Installer SHA-256 before/after: 43eed8512bc6a516e636c60c216e04b83c46d93f569b0461aa676597524358bb. The package SHA was compared to the same expected constant before extraction.
- Official Godot post-install import: PASS, exit 0.
- res://tests/presentation/p3_2_live_modular_map_test.gd rerun on the same exact RC SHA: FAIL, exit 1. It now gets past asset loading and fails at test line 52 with Chosen disciple disappeared from live actor registry. No gameplay source or test was modified.
- GUI mouse playthrough and FPS logger OFF/ON remain PENDING_GUI; no screenshot/video or phase performance metrics were captured. No PLAYABLE PASS claim.

See logs/female_stage_a_initial_attempt.log, logs/female_stage_a_install_only.log, logs/female_stage_a_postinstall_import.*, and logs/female_stage_a_live_map_retest.* for sanitized raw evidence.