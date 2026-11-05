# TRI facility UI/UX evidence — 2026-11-05

This folder contains Godot-rendered 1280×720 BEFORE/AFTER captures for Đại Điện, Đệ Tử Xá, and Dẫn Tiên Đài, plus the local focused QA matrix.

## Scope and honesty

- The edits are presentation-only in the three B1 screens, the D7 radar renderer, and shared neutral portrait sizing. Gameplay authority, Combat V2, SaveService, economy, and PvE simulation were not changed.
- Captures came from the real P3.2 scene via the Godot capture harness, **not native physical mouse input**.
- The capture harness used an isolated QA profile and save; it recruited candidate_0006 from its QA fixture and verified one save/reload. This is not a full New Game production playthrough.
- QA workspace HEAD was e888c010d6cfb09a97ce48af19d1a2f42a401240 and was dirty before these edits. Its P3.2 map script had local uncommitted divergence. The UI files were reviewed and staged against PR #72, but this evidence is **not an exact-SHA test** of the PR commit below. Run affected regressions on the new exact SHA before release.
- PR #72 remains Draft and unmerged.

## Changes

- Hall: clearer seven-role rows, larger portraits and action targets, shorter instruction/cost copy.
- Residence: readable horizontal bed-state legend and clearer resident/empty-room presentation.
- Guidance: larger candidate image area, compact identity/quality/realm badges and readable candidate facts. The building artwork remains separate from the disciple portrait; when no approved disciple art exists the UI says so instead of inventing a portrait.
- D7 radar: Tam Căn axes (jade) and Tứ Tính axes (gold), clearer labels, and compact group labels. No values or gameplay rules changed.
- Shared UI: neutral silhouette scales to the actual portrait frame.

## Godot / Source A

Godot: 4.7.2.stable.official.ed1daf0bf.

The three building PNGs were SHA-256 checked in this QA checkout; alpha scan passed (transparent, opaque and antialiased pixels present):
- 510052 Đại Điện: b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c
- 510076 Đệ Tử Xá: f8e05d7376fc5ddc7b25f56673b6d5f444b10fd759da06a5929ec4f38a68d320
- 510111 Dẫn Tiên Đài: 90b7c595f3b77788c99924ef2eb7ba4b8ede794ccffda1c6808263ba3c711762

A windowed run with the Intel default OpenGL driver crashed in ig11icd64.dll (0xC0000005). The harness completed with gl_compatibility + opengl3_angle; this is an automated render, not confirmation of a normal user launch.

## Screenshots

All images are 1280×720. SHA-256 values are in UIUX_TEST_MATRIX.csv.

| Screen | Before | After |
|---|---|---|
| Đại Điện | [PNG](before/01_hall_live_state.png) | [PNG](after/01_hall_live_state.png) |
| Đệ Tử Xá | [PNG](before/02_residence_live_state.png) | [PNG](after/02_residence_live_state.png) |
| Dẫn Tiên Đài | [PNG](before/03_guidance_live_state.png) | [PNG](after/03_guidance_live_state.png) |

## PvE population clarification

The current PR #72 design describes **1–30 eligible hunters in one persistent world**. A party/team is optional and has a maximum of six members; the six-person requirement applies to the boss gate, not a global PvE roster cap. The world maintains up to 40 live monsters and a 200-slot respawn registry. No combat or population code was changed in this UI patch.

## Remaining acceptance

Native mouse/touch GUI, performance, exact new-commit regressions, full production-to-PvE playthrough, and Windows normal-launch acceptance remain pending. Do not treat these screenshots or headless tests as PLAYABLE PASS.
