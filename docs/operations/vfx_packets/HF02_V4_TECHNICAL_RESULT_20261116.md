# HF02 — VFX Production System V4 pilot, exact-SHA native evidence (16/11/2026)

- Repository: `vuanhtuan161094-byte/TongMonBaDao` — PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`.
- **Final tested exact source SHA:** `f3d0992e7fc522d1d8e611fc81b65b7020785053`.
- **Official GitHub Actions run:** [#43794060905](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43794060905) — completed **SUCCESS**.
- **Artifact:** [#14193811824](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43794060905/artifacts/14193811824), `vfx-v4-hf02-f3d0992e7fc522d1d8e611fc81b65b7020785053`, expires per GitHub Actions retention (30 days). Original generator/source files are preserved in repo independently.
- Engine: Godot **4.7.2.stable.official**, Compatibility under Xvfb, exact-SHA checkout; mini capture 96 frames at fixed movie clock 60, native **1280×720**, MP4 duration **1.6s**. This is NOT real hardware FPS.

## Technical gate results

| Gate | Result | Evidence |
| --- | --- | --- |
| Canonical skill/timing/provenance packet | **PASS** | `VFX_V4_PACKET_TECHNICAL_PASS`, `HF02_V4_PREFLIGHT.json` |
| Reproduced first-party atlas, size/alpha and integrity | **PASS** | `VFX_V4_ASSETS_TECHNICAL_PASS` |
| Godot strict import / parse / focused moving-target contract | **PASS** | `VFX_TAL07_FOCUSED_RESULT=PASS failures=0` |
| Native 3-frame Godot V4 capture | **PASS technical** | `v4-charge.png` 0.30s; `v4-peak.png` 1.28s; `v4-contact.png` 1.49s |
| Native MP4 and source SHA manifest | **PASS technical** | `VFX_V4_EVIDENCE_TECHNICAL_PASS`, `V4_MANIFEST.json` |
| Negative test — delete contact evidence | **PASS (fail closed)** | Expected `VFX_V4_EVIDENCE_TECHNICAL_FAIL: missing or blank proof: v4-contact.png` |
| Exact source SHA verified at checkout and after proof | **PASS** | `VFX_V4_EXACT_SHA_TECHNICAL_PASS=f3d0992e7fc522d1d8e611fc81b65b7020785053` |
| Source→Godot visual fidelity / actual impact beauty | **MANUAL REVIEW REQUIRED** | Not certified by CI |
| Owner visual acceptance, release integration, device FPS | **PENDING / HOLD** | `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_QA_PENDING` |

### Reproducible evidence SHA-256

- MP4 `v4-hf02-native.mp4`: `76b91bc7ca8685383d92e3fd7ad2700a6be48027dde1027d4087bdb0a9a460f0`.
- Charge PNG: `5106ce2f508ddbcd48ee8ddb79b7ba075ed1963789a695a8114c91d61318fcb9`.
- Peak PNG: `f9c6819c5adcaf64122f0a5feaf203089f7de80945b7bb522a564c56fcc4e714`.
- Contact PNG: `3ec2e06fbe2547f150f03d9f0724726eb189c77a58cb37ee76a5f8b2a9577259`.
- Source R5 fire 320×91 crop: `afed216d57ee15fadd98bc0635911557e1e053cf95d81c0207563d1825d04eff`.
- First-party talisman source 96×132: `39f804d5b3c710a8fca50fa90d79d2b053cb03d707d6ed757a1db82462bcbfdf`.

## Three clocks and visual review limitations

HF02 catalogue: `cast_time=0.62s`, `projectile_speed=0`, FIRE/circle/radius2.1/cap3/1 hit, duration0. Its isolated LAB simulates impact at `1.37s` and fade at `2.62s`; loop `3.30s`. **1.37s is NOT an actual Combat V2 hit receipt**. The moving enemy proof uses real walk sprite animation and scripted displacement in view-only Lab, not live combat.

Human inspection of three native images shows main red-orange horizontal fire painted behind the moving monster group and small local impacts. This is a functional preflight, **not an art approval**. Primary R5 source remains a 320×91 concept crop, so brightness, painterly volume, contact force, readability, and visual faithfulness to owner's reference must be judged manually. A visually rejected source must return to G2/G3; adding glow does not satisfy V4.

## Audit of intermediate revision

Run [#43794029247](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43794029247) failed its evidence stage because the general validator required `proof_contract` markers not yet recorded in that intermediate packet. This was fixed in source `f3d0992...`; its subsequent run was successful. No fail was relabeled as PASS.

## Cross-school handoff

Use [README.md](README.md) and the existing V3+V4 canonical SOP. Reuse school-neutral validator `tools/qa/validate_vfx_v4_packet.py` and create school-owned packets/workflows with real markers, timing, art sources, and moving-target tests. **Only HF02 has a running V4 GitHub Actions pilot today**; other school CI adoption is future work and cannot be claimed globally enforced from a single pilot.

No Codex, no rig, no new branch or merge, no modifications to Combat V2, SaveService, PvE, V6.3 or gameplay in this packet.
