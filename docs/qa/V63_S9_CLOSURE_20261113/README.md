# V63-S9 Closure — 2026-11-13

## Result

S9 Triệu Hồi technically passes on code SHA 6124758ad70fef66a51c0fd94d034b4f65122e89. Official Godot 4.7.2 import, D1 and S0–S9 each exited 0 with their PASS markers. S9 used the Windows OpenGL Compatibility renderer at 1280×720; marker: 2,675 checks, 183 nodes, three branches, runtime actor cap 6, release gate OFF.

This is not full release, physical GUI, Android or art approval. The three VFX captures are sparse test frames (actors, HP bars and one small glyph on the test background). They prove event-to-render and viewport capture only, not production visual quality. OWNER_VISUAL_PENDING; V6.3 remains OFF. The owner has not physically played the GUI.

## Source and safety

- Existing PR branch: integration/pve-p0-playable-ui-20261103.
- Latest remote HEAD integrated before S9 work: 45fda38f67d478bb5a6e6c49a11908c2d667f251. Codex B VFX19 R1/R2 lab renderer changes are retained unchanged.
- Latest remote tip before publication: 9521cc86d99c39bd613f9339a7f8399532643fee; it adds only a VFX19 R2 QA report. No V63 runtime/test code changed after the exact tested SHA.
- Tested code SHA: 6124758ad70fef66a51c0fd94d034b4f65122e89.
- S9 closure changes validator/ledger consistency and real GodotViewport fixture/capture assertions. Only V63 candidate data, validation, presentation catalog, and focused test files were changed.
- QA used a detached worktree and isolated profile; no production checkout/player save was used. No branch was created and nothing was merged.
- SaveService/economy and Combat V2 formulas/balance are unchanged. Production VFX renderer was not modified; work only updates V63 summon candidate metadata/validation/test and ledger/catalog metadata.
- Official Godot: 4.7.2.stable.official.ed1daf0bf; binary SHA-256 AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424.

## Evidence

- QA_MATRIX.csv contains each exact-SHA command, exit code and marker.
- run_metadata.json records engine, renderer, gate and acceptance state.
- raw/ contains sanitized stdout/stderr for version, import and D1/S0–S9.
- diagnostics/DIAGNOSTICS.md records the root certificate warning, GUI/art limitations and preserved D4A/Warehouse debt.
- screenshots/ contains three GodotViewport captures at 1280×720; SHA-256 and dimensions are in screenshots/SHA256SUMS.csv.

Fresh exact-SHA rerun on 6124758ad70fef66a51c0fd94d034b4f65122e89 included the latest VFX19 R2 lab-only tip and used Start-Process -Wait for each Windows Godot process; all stdout/stderr logs are populated and one process ran at a time. Godot logged the Windows root-certificate-store warning on stderr during otherwise successful import/test runs. It did not affect exits or PASS markers.

## Acceptance summary

| Gate | Result |
| --- | --- |
| Godot 4.7.2 version | PASS, exit 0 |
| Project import | PASS, exit 0, environment certificate warning |
| D1 registry | PASS, exit 0 |
| S0 presentation | PASS, exit 0 |
| S1 Kiếm Tu | PASS, exit 0 |
| S2 Đao Tu | PASS, exit 0 |
| S3 Thương Tu | PASS, exit 0 |
| S4 Song Đao | PASS, exit 0 |
| S5 Chưởng Tu | PASS, exit 0 |
| S6 Phù Tu | PASS, exit 0 |
| S7 Chú Tu | PASS, exit 0 |
| S8 Trận Tu | PASS, exit 0 |
| S9 Triệu Hồi, rendered | PASS, exit 0; owner visual approval pending |
| Physical mouse / Android | PENDING |
| VFX art approval | PENDING OWNER |
| D4A/Warehouse baseline | Existing FAIL preserved; not rerun |

The feature gate remains OFF and candidate nodes remain gated. Do not call V6.3 playable or release-ready.