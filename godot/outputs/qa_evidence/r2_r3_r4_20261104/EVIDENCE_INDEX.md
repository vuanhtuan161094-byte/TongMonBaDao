# PR72 R2/R3/R4 QA evidence — 2026-11-04

Source basis: PR72 live HEAD 965cf62eb8715f2807c443c01c4eefb86e944d62. The isolated QA tree reconstructed PR source files from GitHub blobs. Its local Git metadata remains detached at e888c010d6cfb09a97ce48af19d1a2f42a401240, so the game launcher preflight correctly refused to run; no fingerprint gate was bypassed.

- [QA matrix](QA_MATRIX.csv)
- [Godot import log](logs/godot_import.log)
- [CHOI-GAME preflight](logs/choi_game_preflight.log)
- [R2 launcher safety log](logs/r2_launcher_safety.log)
- R3: [phase 1](logs/r3_phase1.log), [phase 2](logs/r3_phase2.log), [phase 3](logs/r3_phase3.log)
- [R4 focused logs](logs/r4_focused.log)
- Screenshots: [map](screenshots/00_p3_2_map_context.png), [Hall](screenshots/01_hall_live_state.png), [Residence](screenshots/02_residence_live_state.png), [Guidance](screenshots/03_guidance_live_state.png), [build mode](screenshots/04_build_mode_new_game_gates.png), [recruitment](screenshots/05_recruitment_success_reveal_qa_fixture.png)

R3 is headless one-save acceptance over three independent Godot processes. R4 screenshots are actual 1280x720 Godot renders with harness-driven controls; native mouse/owner-session GUI remains pending. PID 2188 was not stopped.
