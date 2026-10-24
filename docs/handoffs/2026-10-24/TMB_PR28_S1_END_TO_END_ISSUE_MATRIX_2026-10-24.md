# Packet B — issue and QA matrix

Branch: `integration/pr28-combat-v3-s1-playable-qa-20261024`  
Final code/test SHA: `4b02a0c61a2771d9d4638129d96b68ad292270dc`  
Evidence: [`sha4b02`](evidence/packet-b/sha4b02/)

| ID | Priority | Item | Evidence / impact | Status |
|---|---|---|---|---|
| PB-01 | P2 | Live Weaken screenshot | Actual P3.2 CARE fight; canonical stage eligibility; Hàn Sương Ấn applied `weaken` to live monster. Capture `13_current_combat_s1_real_weaken.png`. | PASS |
| PB-02 | P2 | Live learned-guard active/expiry screenshots | Actual V2 disciple learned Kim Cương Hộ Thể after canonical cultivation; battle state shows factor 0.62, active at 11s and expired at 14s. Captures `13b` and `13c`. | PASS |
| PB-03 | P2 | Sustained Windows performance not measured | Screenshot samples: Engine FPS 1–24, static memory 62.7–73.7 MiB. Not a sustained benchmark; Windows total RAM query denied. | PENDING human/profiled run |
| PB-04 | P2 | Physical acceptance outstanding | No human mouse/touch session, Android device run, or Owner Visual sign-off in automated capture. | PENDING owner/device QA |
| PB-05 | P2 | Standalone Windows export unavailable | Godot export templates directory is empty. Portable Godot project ZIP `TMB_Playable_Windows_PacketB_4b02.zip` launched with exit 0; no standalone export executable. | Portable project PASS; standalone export unavailable |
| PB-06 | P2 | Windows Godot diagnostics | Focused tests and GUI capture exit 0 with expected markers. Logs include root certificate-store and one non-fatal package shader-cache warning. | Environment diagnostics; no code change |
| PB-07 | P2 | Source A Boss / production action clips | Boss-slot art is in the visual manifest but no Boss was spawned. No unverified Mine/Linh Lâm/Linh Điền action clips or incomplete building packs were installed. | Explicitly outside accepted slice |

## Pass gates

- Exact code/test SHA focused matrix: **28/28 PASS**, separate userdata per test; O9 included.
- S1 edge contract: **56 checks PASS**.
- Exact-SHA P3.2 automated GUI: **19 captured frames at 1280×720**; real burn, Weaken, learned guard active/expiry, kill receipt, canonical Warehouse, same-world respawn and SaveService reload.
- Portable ZIP: extracted project launched with Godot official 4.7.2, exit 0. Non-fatal environment diagnostics retained in log.
- No FULL/CI, no merge, and no changes to PR #28/#29/#30.

See the [implementation report](TMB_PR28_S1_END_TO_END_INTEGRATION_REPORT_2026-10-24.md), [`focused_results.csv`](evidence/packet-b/sha4b02/focused_results.csv), and [`capture_state_manifest.json`](evidence/packet-b/sha4b02/capture_state_manifest.json).
