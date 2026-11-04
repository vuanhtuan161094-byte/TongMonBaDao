# PR72 R2/R3/R4 QA evidence — 2026-11-04

Source basis: runtime/launcher code at PR commit 3a829724f07e018d86e435c2a0b06a59b96c7a38; current PR HEAD before this evidence update 6495f0218ac0d407ca59a40a066943978f0a7303 adds only runtime-manifest pin cleanup. The QA file tree under E:\TongMonBaDaoWorkspace\01_Game\QA_WORKTREES\PR72_R2_R3_R4_20261104 matches all 135 runtime pins and fingerprint 961f2cc08b534f93723cf04c3355f76d0937ad9b169a81c98df82013ddc85b97. The local Git metadata remains synthetic/detached at e888c010d6cfb09a97ce48af19d1a2f42a401240 with no branch, so CHOI-GAME.cmd correctly refuses that checkout before launch; no fingerprint gate was bypassed.

- [QA matrix](QA_MATRIX.csv)
- [Godot import log](logs/godot_import.log)
- [CHOI-GAME preflight](logs/choi_game_preflight.log)
- [R2 launcher safety log](logs/r2_launcher_safety.log)
- R3: [phase 1](logs/r3_phase1.log), [phase 2](logs/r3_phase2.log), [phase 3](logs/r3_phase3.log)
- [R4 focused logs](logs/r4_focused.log)
- Screenshots: [map](screenshots/00_p3_2_map_context.png), [Hall](screenshots/01_hall_live_state.png), [Residence](screenshots/02_residence_live_state.png), [Guidance](screenshots/03_guidance_live_state.png), [build mode](screenshots/04_build_mode_new_game_gates.png), [recruitment](screenshots/05_recruitment_success_reveal_qa_fixture.png)

R3 is headless one-save acceptance over three independent Godot processes. R4 screenshots are actual 1280x720 Godot renders with harness-driven controls; native mouse/owner-session GUI remains pending. PID 2188 was not stopped.

## Latest R2/R3/R4 verification (PR 6495f021)

- [Runtime pin verification (135/135)](logs/runtime_source_pin_verification_6495f02.log)
- [Current CHOI-GAME preflight result](logs/choi_game_preflight_6495f02.log)
- [Launcher safety regression, 25 checks](logs/r2_launcher_safety_6495f02.log)
- Direct official Godot 4.7.2 window runs: [run 1](logs/godot_direct_gui_launch_1_6495f02.log), [run 2](logs/godot_direct_gui_launch_2_6495f02.log), [run 3](logs/godot_direct_gui_launch_3_6495f02.log), [launch/window summary](logs/direct_gui_launch_matrix_6495f02.json)
- [Direct window observation](logs/direct_gui_window_observation_6495f02.log)

Results: runtime manifest fingerprint and 135/135 pins PASS. Three direct Godot main-scene opens created distinct native window handles and exited 0; DPI probe was 120, mapping the configured 1280x720 client to 1280x720 physical pixels. Intel Iris Plus OpenGL 3.3 Compatibility initialized; no script/parse errors; Windows root-certificate-store warning fell back to bundled CA. The three direct runs used isolated QA AppData profiles and did not go through the branch-validating launcher. CHOI-GAME.cmd preflight remains BLOCKED at the synthetic detached Git-branch identity gate (exit 6), not at PID 2188 or process-name collision. PowerShell screenshot capture from this session was unavailable/blank; existing six 1280x720 Godot harness renders remain the visual evidence. Harness input is not physical mouse input. PID 2188 was not touched. A longer capture-only run exceeded its 15-second observation window; only the PID started by that probe was stopped, and that probe is excluded from pass results.
